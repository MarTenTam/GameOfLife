-----------------------------------------------------------------------------------------
--
-- gameScene.lua
--
-- This is the scene in which the game is played and all interaction takes place
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local json = require("json")

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Load matrix functions
local matrixManager = require( "matrixManager" )




local function loadSettings()

    local settings = {}

    local path = system.pathForFile("settings.json", system.ResourceDirectory)

    local file, errorString = io.open(path, "r")

    if not file then

        print( "File error: " .. errorString )
    else
        local contents = file:read("*a") 

        settings = json.decode(contents)

        io.close(file)

        if not settings then
            print("Failed to decode JSON data")
        end
        
    end
    
    return settings
end

local settings = loadSettings()
local matrixSize = settings.matrixSize


local X = display.contentCenterX -- X coordinate of the center of the screen
local Y = display.contentCenterY -- Y coordinate of the center of the screen
local W = display.contentWidth -- content width
local H = display.contentHeight -- content height

local stateMatrix
local sliderTextOptions
local sliderText
local slider
local btnHeight = W/8
local btnWidth = W/3
local padding = H*0.06
local menuBtnY = H-0.5*btnHeight - padding
local sliderY = 1.4*padding
local sliderW = W*0.8
local sliderTextY = sliderY + 0.1*sliderW

local cellBox = {
    size = math.min((W - padding),(H - padding)),
    x = X,
    y = Y
}

local overlayOptions = {
    isModal = false,
    --effect = "fade",
    time = 400
}

local frameRate = 20 -- frames per second
local cells = {}
local aliveCellFillColor = {1, 0.5, 0} -- orange
local deadCellFillColor = {0, 0, 0} -- black
local doLife = true 
local doRandomWithSeed = false
local lifeTimer


local startBtnGroup = display.newGroup()
local sliderGroup = display.newGroup()
local seedingNotificationGroup = display.newGroup()
startBtnGroup.isVisible = false
seedingNotificationGroup.isVisible = false


-- Define a function to update the fill color of the rectangles based on the binary matrix
local function animate(matrix, cells)
    local size = #matrix
    for row = 1, size do
        for col = 1, size do
            local cell = cells[row][col]
            if matrix[row][col] == 1 then
                cell:setFillColor(unpack(aliveCellFillColor))
            else
                cell:setFillColor(unpack(deadCellFillColor))
            end            
        end
    end
end


local function timeBasedAnimate(event)
    animate(stateMatrix, cells)
    if doLife then
       stateMatrix = matrixManager:calculateCellStates(stateMatrix)
    end

end


-- Return from menu
function scene:resumeGame()
    functionName = composer.getVariable("functionName")
    if functionName then
        if functionName == "saveState" then
            matrixManager:saveState(stateMatrix)
        elseif functionName == "randomState" then
            if doLife == true then
                doLife = false
                startBtnGroup.isVisible = true               
            end
            doRandomWithSeed = true
            stateMatrix = matrixManager:clearState(matrixSize)
            sliderGroup.isVisible = false
            seedingNotificationGroup.isVisible = true

        else
            local loadedMatrix = matrixManager[composer.getVariable("functionName")](matrixManager, matrixSize)
            if loadedMatrix then
                stateMatrix = loadedMatrix
            end
        end 
        
    end
end

-- -----------------------------------------------------------------------------------
-- User interface stuff
-- -----------------------------------------------------------------------------------

local widget = require("widget")

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    composer.setVariable("menuBtnY", menuBtnY)

    local startBtn
    local pauseBtn
    local menuBtn

     -- Function to handle button events
    local function handlePauseBtnEvent( event )
        
        if ( "ended" == event.phase ) then
            if doLife == true then
                doLife = false
                startBtnGroup.isVisible = true
            else
                if doRandomWithSeed == true then
                    stateMatrix = matrixManager:randomState(matrixSize, stateMatrix)
                    doRandomWithSeed = false
                    sliderGroup.isVisible = true
                    seedingNotificationGroup.isVisible = false
                end
                doLife = true
                startBtnGroup.isVisible = false
            end
        end
        return true
    end

    -- Function to handle button events
    local function handlemenuBtnEvent( event )
        if ( "ended" == event.phase ) then
            composer.showOverlay( "menuScene", overlayOptions )
        end
        return true
    end

    -- Code here runs when the scene is first created but has not yet appeared on screen

    -- Assign "self.view" to local variable "sceneGroup" for easy reference
    local sceneGroup = self.view

    -- Slider listener
    local function sliderListener( event )
        timer.cancel(lifeTimer)
        frameRate = 29*(event.value/100) + 1
        sliderText.text = "Iteration speed at " .. frameRate .. " FPS"
        lifeTimer = timer.performWithDelay(1000/frameRate, timeBasedAnimate, -1)
        print( "FPS at " .. frameRate )
    end

    local function drawCells(matrix, cellBox)
        local matrixSize = #matrix
     
        -- Calculate the size of each cell and the spacing between cells
        local cellSize =  cellBox.size/matrixSize *0.90
        local spacing = cellSize/0.90*0.1
    
        -- Calculate the starting position of the grid
        local startX = cellBox.x - cellBox.size/2 + 0.5*cellSize
        local startY = cellBox.y - cellBox.size/2 + 0.5*cellSize
    
        -- Define the touchHandler function
        local function touchHandler(event)
            if event.phase == "moved" then
                local row = event.target.row
                local col = event.target.col
    
                stateMatrix[row][col] = 1
    
            end
        end
       
        -- Create the grid of cells
        for row = 1, matrixSize do
                
            cells[row] = {}
            for col = 1, matrixSize do
                local cellX = startX + (col - 1) * (cellSize + spacing)
                local cellY = startY + (row - 1) * (cellSize + spacing)
    
                local cell = display.newRect(cellX, cellY, cellSize, cellSize)
                sceneGroup:insert(cell)
                cells[row][col] = cell
                -- Store the row and column of the cell as properties of the rectangle object
                cell.row = row
                cell.col = col
                if matrix[row][col] == 1 then
                    cell:setFillColor(unpack(aliveCellFillColor))
                else
                    cell:setFillColor(unpack(deadCellFillColor))
                end  
                cell:addEventListener("touch", touchHandler)
            end
        end    
    end
    
    stateMatrix = matrixManager:randomState(matrixSize)
    
    drawCells(stateMatrix, cellBox)
       
    sliderTextOptions = 
    {
        text = "Iteration speed at " .. frameRate .. " FPS",     
        x = X,
        y = sliderTextY,
        width = W,
        font = native.systemFont,   
        fontSize = 12,
        align = "center"  -- Alignment parameter
    }
     
    sliderText = display.newText( sliderTextOptions )
    sliderText:setFillColor( unpack(aliveCellFillColor) )
    sceneGroup:insert(sliderText)
    sliderGroup:insert(sliderText)

    seedingNotificationTextOptions = 
    {
        text = "Draw on the screen to seed the randomness. Then press START",     
        x = X,
        y = sliderTextY,
        width = W,
        font = native.systemFont,   
        fontSize = 12,
        align = "center"  -- Alignment parameter
    }
     
    seedingNotificationText = display.newText( seedingNotificationTextOptions )
    seedingNotificationText:setFillColor( unpack(aliveCellFillColor) )
    sceneGroup:insert(seedingNotificationText)
    seedingNotificationGroup:insert(seedingNotificationText)
        
    -- Create the widget
    slider = widget.newSlider(
        {
            x = X,
            y = sliderY,
            width = sliderW,
            value = 66.6,  -- Start slider at 66.6%
            listener = sliderListener
        }
    )
    sceneGroup:insert(slider)
    sliderGroup:insert(slider)
         
    -- Create the pauseButton
    pauseBtn = widget.newButton(
        {
            label = "PAUSE",
            fontSize = 12,
            labelColor = { default=aliveCellFillColor, over={0,0,0} },
            onEvent = handlePauseBtnEvent,
            emboss = false,
            -- Properties for a rounded rectangle button
            shape = "roundedRect",
            width = btnWidth,
            height = btnHeight,
            cornerRadius = 2,
            fillColor = { default={0,0,0}, over={1,1,1} },
            strokeColor = { default=aliveCellFillColor, over={0,0,0} },
            strokeWidth = 1
        }
    )

    sceneGroup:insert(pauseBtn)
    
    -- Create the startBtn
    startBtn = widget.newButton(
    {
        label = "START",
        onEvent = buttonHandler,
        fontSize = 12,
        labelColor = { default={1,1,1}, over=aliveCellFillColor },
        onEvent = handlePauseBtnEvent,
        emboss = false,
        -- Properties for a rounded rectangle button
        shape = "roundedRect",
        width = btnWidth,
        height = btnHeight,
        cornerRadius = 2,
        fillColor = { default={0,0,0}, over={0,0,0} },
        strokeColor = { default={1,1,1}, over=aliveCellFillColor },
        strokeWidth = 1
        }
    )

    startBtnGroup:insert(startBtn)


    
    
     
    -- Create the menuBtn
    menuBtn = widget.newButton(
        {
            label = "MENU",
            fontSize = 12,
            labelColor = { default=aliveCellFillColor, over={0,0,0} },
            emboss = false,
            -- Properties for a rounded rectangle button
            shape = "roundedRect",
            width = btnWidth,
            height = btnHeight,
            cornerRadius = 2,
            fillColor = { default={0,0,0}, over={1,1,1} },
            strokeColor = { default=aliveCellFillColor, over={0,0,0} },
            strokeWidth = 1
        }
    )

    sceneGroup:insert(menuBtn)
     
    -- Align the buttons
    pauseBtn.x = W-(W/4)
    pauseBtn.y = menuBtnY
    menuBtn.x = W/4
    menuBtn.y = menuBtnY
    startBtn.x = pauseBtn.x
    startBtn.y = menuBtnY
    
    

    menuBtn:addEventListener("touch", handlemenuBtnEvent)

    
    
    
    
    
    
    --Call the updateFillColor function at a specified interval using timer.performWithDelay()
    
    lifeTimer = timer.performWithDelay(1000/frameRate, timeBasedAnimate, -1)
    

 
  
end


-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

    end
end


-- hide()
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen

    end
end


-- destroy()
function scene:destroy( event )

    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------



return scene

