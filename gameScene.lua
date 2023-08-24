-----------------------------------------------------------------------------------------
--
-- gameScene.lua
--
-- This is the scene in which the game is played and all interaction takes place
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Load matrix functions
local matrixManager = require( "matrixManager" )


local X = display.contentCenterX -- X coordinate of the center of the screen
local Y = display.contentCenterY -- Y coordinate of the center of the screen
local W = display.contentWidth -- content width
local H = display.contentHeight -- content height
local matrixSize = 100
local tempMatrix = {}
local stateMatrix
local sliderOptions
local sliderText
local slider
local pauseToggle = 0

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
local lifeTimer





-- Define a function to update the fill color of the rectangles based on the binary matrix
local function animate(matrix, cells)
    local size = #matrix
    for row = 1, size do
        for col = 1, size do
            local cell = cells[row][col]
            if matrix[row][col] == 11 then
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
       stateMatrix = matrixManager:calculateCellStates(stateMatrix, tempMatrix)
    end

end


-- Return from menu
function scene:resumeGame()
    if composer.getVariable("functionName") then
        stateMatrix = matrixManager[composer.getVariable("functionName")](matrixManager, matrixSize)
        print(composer.getVariable("functionName"))
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

    local startButton
    local menuButton

     -- Function to handle button events
    local function handleStartButtonEvent( event )
        
        if ( "ended" == event.phase ) then
            if pauseToggle % 2 == 0 then
                doLife = false
            else
                doLife = true
            end
            pauseToggle = pauseToggle + 1
        end
        return true
    end

    -- Function to handle button events
    local function handleMenuButtonEvent( event )
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
        frameRate = 30*(event.value/100)
        sliderText.text = "Iteration speed at " .. frameRate .. " FPS"
        lifeTimer = timer.performWithDelay(1000/frameRate, timeBasedAnimate, -1)
        print( "FPS at " .. frameRate )
    end

    local function drawCells(matrix)
        local matrixSize = #matrix
        local padding = 10 -- padding around the grid
        
    
        -- Calculate the size of each cell and the spacing between cells
        local cellSize = math.min(
            (display.contentWidth - padding * 2) / matrixSize,
            (display.contentHeight - padding * 2) / matrixSize
        )
        local spacing = cellSize / 10
    
        -- Calculate the starting position of the grid
        local startX = X - (matrixSize / 2) * (cellSize + spacing)
        local startY = Y - (matrixSize / 2) * (cellSize + spacing)
    
        -- Define the touchHandler function
        local function touchHandler(event)
            if event.phase == "moved" then
                local row = event.target.row
                local col = event.target.col
    
                stateMatrix[row][col] = 11
    
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
                if matrix[row][col] == 11 then
                    cell:setFillColor(unpack(aliveCellFillColor))
                else
                    cell:setFillColor(unpack(deadCellFillColor))
                end  
                cell:addEventListener("touch", touchHandler)
            end
        end    
    end
    
    stateMatrix = matrixManager:randomState(matrixSize) 
    
    drawCells(stateMatrix)
       
    sliderOptions = 
    {
        text = "Iteration speed at " .. frameRate .. " FPS",     
        x = X,
        y = H/14,
        width = W,
        font = native.systemFont,   
        fontSize = 12,
        align = "center"  -- Alignment parameter
    }
     
    sliderText = display.newText( sliderOptions )
    sliderText:setFillColor( unpack(aliveCellFillColor) )
    sceneGroup:insert(sliderText)
        
    -- Create the widget
    slider = widget.newSlider(
        {
            x = X,
            y = 0,
            width = W*0.9,
            value = 66.6,  -- Start slider at 66.6%
            listener = sliderListener
        }
    )
    sceneGroup:insert(slider)
         
    -- Create the widget
    startButton = widget.newButton(
        {
            label = "START/PAUSE",
            fontSize = 12,
            labelColor = { default=aliveCellFillColor, over={0,0,0} },
            onEvent = handleStartButtonEvent,
            emboss = false,
            -- Properties for a rounded rectangle button
            shape = "roundedRect",
            width = W/3,
            height = W/8,
            cornerRadius = 2,
            fillColor = { default={0,0,0}, over={1,1,1} },
            strokeColor = { default=aliveCellFillColor, over={0,0,0} },
            strokeWidth = 1
        }
    )

    sceneGroup:insert(startButton)
    
    
    
    
     
    -- Create the menuButton
    menuButton = widget.newButton(
        {
            label = "MENU",
            fontSize = 12,
            labelColor = { default=aliveCellFillColor, over={0,0,0} },
            emboss = false,
            -- Properties for a rounded rectangle button
            shape = "roundedRect",
            width = W/3,
            height = W/8,
            cornerRadius = 2,
            fillColor = { default={0,0,0}, over={1,1,1} },
            strokeColor = { default=aliveCellFillColor, over={0,0,0} },
            strokeWidth = 1
        }
    )

    sceneGroup:insert(menuButton)
     
    -- Align the buttons
    startButton.x = W-(W/4)
    startButton.y = H
    menuButton.x = W/4
    menuButton.y = H
    
    

    menuButton:addEventListener("touch", handleMenuButtonEvent)
    
    
    
    
    
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

