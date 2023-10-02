-----------------------------------------------------------------------------------------
--
-- gameScene.lua
--
-- This is the scene in which the game is played and all interaction takes place
--
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local composer = require( "composer" )
local json = require("json")
local scene = composer.newScene()
local matrixManager = require( "matrixManager" ) -- Load matrix functions

-- Function to load in a table from a json file.
--  Inputs: 
--          - the filename in the ResourceDirectory
--  Outputs: 
--          - a table populated with the parsed json data
--  Author: Marten Tammetalu
local function loadJSONFile(fileName)

    -- Open, decode and alert if errors occur
    local parsedTable = {}
    local path = system.pathForFile(fileName, system.ResourceDirectory)
    local file, errorString = io.open(path, "r")

    if not file then
        print( "File error: " .. errorString )
        native.showAlert( "File error", errorString, { "OK" } )                 
    else
        local contents = file:read("*a") 
        parsedTable = json.decode(contents)
        io.close(file)

        if not parsedTable then
            print("Failed to decode JSON data")
            native.showAlert( "Error", "Failed to decode JSON data", { "OK" } )
        end     
    end   
    return parsedTable
end

local stateMatrix -- the state matrix
local iSpeed = 20 -- initial iteration speed fps

-- Get settings
local settings = loadJSONFile("settings.json")
local matrixSize = settings.matrixSize
local primaryColor = settings.primaryColor
local secondaryColor = settings.secondaryColor
local fontSize = settings.fontSize

-- Set width, height, coordinates to settings for menuScene to use
settings.X = display.contentCenterX
settings.Y = display.contentCenterY
settings.W = display.contentWidth
settings.H = display.contentHeight
-- Set padding
local padding = settings.H*0.06

-- Set position and size for buttons
local btnHeight = settings.W/8
local btnWidth = settings.W/3
settings.btnY = settings.H-0.5*btnHeight - padding

-- Settings for slider elements
local slider
local sliderText
local sliderY = 1.4*padding
local sliderW = settings.W*0.8
local sliderTextY = sliderY + 0.1*sliderW
local sliderTextProperties =  {
    text = settings.iterationSpeedText .. iSpeed .. settings.fpsText,     
    x = settings.X,
    y = sliderTextY,
    width = settings.W,
    font = native.systemFont,   
    fontSize = fontSize,
    align = "center"  
}

-- Settings for notification when seeding randomness
local seedingNotificationText
local seedingNotificationTextProperties = 
{
    text = settings.seedingText,     
    x = settings.X,
    y = sliderTextY,
    width = settings.W,
    font = native.systemFont,   
    fontSize = fontSize,
    align = "center"
}

-- A box of cells with its size, position and colors
local cellBox = {
    size = math.min((settings.W - padding),(settings.H - padding)),
    x = settings.X,
    y = settings.Y,
    cells = {},
    aliveCellFillColor = settings.primaryColor,
    deadCellFillColor = settings.secondaryColor
}

local pause = false -- start/stop toggle
local lifeTimer -- timer for animation, used to cancel when adjusting iteration speed


-- Groups that need to be individually hidden when needed
local startBtnGroup = display.newGroup()
local sliderGroup = display.newGroup()
local seedingNotificationGroup = display.newGroup()
startBtnGroup.isVisible = false -- Only visible when paused
seedingNotificationGroup.isVisible = false -- Only visible when seeding


-- Function to update the fill color of the rectangles based on the binary matrix.
--  Inputs: 
--          - the matrix of cell states
--          - the cellBox with cells, box position, colors, size and padding
--
--  Outputs: 
--          - updates the colors of the cells by manipulating the cells table in the cellBox table passed by reference
--
--  Author: Marten Tammetalu 
local function animate(matrix, cellBox)
    local size = #matrix
    for row = 1, size do
        for col = 1, size do
            local cell = cellBox.cells[row][col]
            if matrix[row][col] == 1 then -- if cell is alive, set it to alive color
                cell:setFillColor(unpack(cellBox.aliveCellFillColor))
            else
                cell:setFillColor(unpack(cellBox.deadCellFillColor)) -- if cell is dead, set it to dead color
            end            
        end
    end
end

-- Function to update the fill color of the rectangles based on the binary matrix that is triggered based on time.
--  Inputs: 
--          - the triggering event
--          - accesses stateMatrix and cellBox
--
--  Outputs: 
--          - manipulates stateMatrix and cellBox
--
--  Author: Marten Tammetalu
local function timeBasedAnimate(event)
    animate(stateMatrix, cellBox)
    if pause == false then
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
            if pause == false then
                pause = true
                startBtnGroup.isVisible = true               
            end
        
            stateMatrix = matrixManager:clearState(matrixSize)
            sliderGroup.isVisible = false
            seedingNotificationGroup.isVisible = true
        
        elseif functionName == "loadState" then 
            local loadedMatrix = loadJSONFile("stateMatrix.json")
                if #loadedMatrix == #stateMatrix then
                    stateMatrix = loadedMatrix
                else
                    native.showAlert( "", settings.matrixSizeErrorText, { settings.okText } )
                    print(settings.matrixSizeErrorText)
                end
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

    composer.setVariable("settings", settings) --Settings for menuScene to access

    local startBtn
    local pauseBtn
    local menuBtn

     -- Function to handle button events
    local function handlePauseBtnEvent( event )
        
        if ( "ended" == event.phase ) then
            if pause == false then
                pause = true
                startBtnGroup.isVisible = true
            else
                if seedingNotificationGroup.isVisible == true then
                    stateMatrix = matrixManager:randomState(matrixSize, stateMatrix)
               
                    sliderGroup.isVisible = true
                    seedingNotificationGroup.isVisible = false
                end
                pause = false
                startBtnGroup.isVisible = false
            end
        end
        return true
    end

    -- Function to handle button events
    local function handlemenuBtnEvent( event )
        if ( "ended" == event.phase ) then
            composer.showOverlay( "menuScene")
        end
        return true
    end

    -- Code here runs when the scene is first created but has not yet appeared on screen

    -- Assign "self.view" to local variable "sceneGroup" for easy reference
    local sceneGroup = self.view

    -- Slider listener
    local function sliderListener( event )
        timer.cancel(lifeTimer)
        iSpeed = 29*(event.value/100) + 1
        sliderText.text = settings.iterationSpeedText .. iSpeed .. settings.fpsText
        lifeTimer = timer.performWithDelay(1000/iSpeed, timeBasedAnimate, -1)
        print( "FPS at " .. iSpeed )
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
                
            cellBox.cells[row] = {}
            for col = 1, matrixSize do
                local cellX = startX + (col - 1) * (cellSize + spacing)
                local cellY = startY + (row - 1) * (cellSize + spacing)
    
                local cell = display.newRect(cellX, cellY, cellSize, cellSize)
                sceneGroup:insert(cell)
                cellBox.cells[row][col] = cell
                -- Store the row and column of the cell as properties of the rectangle object
                cell.row = row
                cell.col = col
                if matrix[row][col] == 1 then
                    cell:setFillColor(unpack(primaryColor))
                else
                    cell:setFillColor(unpack(secondaryColor))
                end  
                cell:addEventListener("touch", touchHandler)
            end
        end    
    end
    
    stateMatrix = matrixManager:randomState(matrixSize)
    
    drawCells(stateMatrix, cellBox)
     
    sliderText = display.newText( sliderTextProperties )
    sliderText:setFillColor( unpack(primaryColor) )
    sceneGroup:insert(sliderText)
    sliderGroup:insert(sliderText)

  
     
    seedingNotificationText = display.newText( seedingNotificationTextProperties )
    seedingNotificationText:setFillColor( unpack(primaryColor) )
    sceneGroup:insert(seedingNotificationText)
    seedingNotificationGroup:insert(seedingNotificationText)
        
    -- Create the widget
    slider = widget.newSlider(
        {
            x = settings.X,
            y = sliderY,
            width = sliderW,
            value = 100*iSpeed/30,  -- Start slider at 66.6%
            listener = sliderListener
        }
    )
    sceneGroup:insert(slider)
    sliderGroup:insert(slider)
         
    -- Create the pauseButton
    pauseBtn = widget.newButton(
        {
            label = settings.pauseText,
            fontSize = fontSize,
            labelColor = { default=primaryColor, over={0,0,0} },
            onEvent = handlePauseBtnEvent,
            emboss = false,
            -- Properties for a rounded rectangle button
            shape = "roundedRect",
            width = btnWidth,
            height = btnHeight,
            cornerRadius = 2,
            fillColor = { default={0,0,0}, over={1,1,1} },
            strokeColor = { default=primaryColor, over={0,0,0} },
            strokeWidth = 1
        }
    )

    sceneGroup:insert(pauseBtn)
    
    -- Create the startBtn
    startBtn = widget.newButton(
    {
        label = settings.startText,
        onEvent = buttonHandler,
        fontSize = fontSize,
        labelColor = { default={1,1,1}, over=primaryColor },
        onEvent = handlePauseBtnEvent,
        emboss = false,
        -- Properties for a rounded rectangle button
        shape = "roundedRect",
        width = btnWidth,
        height = btnHeight,
        cornerRadius = 2,
        fillColor = { default={0,0,0}, over={0,0,0} },
        strokeColor = { default={1,1,1}, over=primaryColor },
        strokeWidth = 1
        }
    )

    startBtnGroup:insert(startBtn)


    
    
     
    -- Create the menuBtn
    menuBtn = widget.newButton(
        {
            label = settings.menuText,
            fontSize = fontSize,
            labelColor = { default=primaryColor, over={0,0,0} },
            emboss = false,
            -- Properties for a rounded rectangle button
            shape = "roundedRect",
            width = btnWidth,
            height = btnHeight,
            cornerRadius = 2,
            fillColor = { default={0,0,0}, over={1,1,1} },
            strokeColor = { default=primaryColor, over={0,0,0} },
            strokeWidth = 1
        }
    )

    sceneGroup:insert(menuBtn)
     
    -- Align the buttons
    pauseBtn.x = settings.W-(settings.W/4)
    pauseBtn.y = settings.btnY
    menuBtn.x = settings.W/4
    menuBtn.y = settings.btnY
    startBtn.x = pauseBtn.x
    startBtn.y = settings.btnY
    
    

    menuBtn:addEventListener("touch", handlemenuBtnEvent)

    
    
    
    
    
    
    --Call the updateFillColor function at a specified interval using timer.performWithDelay()
    
    lifeTimer = timer.performWithDelay(1000/iSpeed, timeBasedAnimate, -1)
    

 
  
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

