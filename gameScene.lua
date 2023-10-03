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
local widget = require("widget")
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
-- Pass settings for menuScene to access
composer.setVariable("settings", settings)

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

local startBtn
local pauseBtn
local menuBtn

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
    fontSize = settings.fontSize,
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
    fontSize = settings.fontSize,
    align = "center"
}

-- A box of cells with its size, position and colors
local cellBox = {
    size = math.min((settings.W - padding),(settings.H - padding)),
    x = settings.X,
    y = settings.Y,
    cells = {},
    spacing = settings.cellSpacing,
    aliveCellFillColor = settings.primaryColor,
    deadCellFillColor = settings.secondaryColor
}

-- Groups that need to be individually hidden when needed
local startBtnGroup = display.newGroup()
local sliderGroup = display.newGroup()
local seedingNotificationGroup = display.newGroup()
startBtnGroup.isVisible = false -- Only visible when paused, also reflects paused state
seedingNotificationGroup.isVisible = false -- Only visible when seeding

local lifeTimer -- timer for animation, used to cancel when adjusting iteration speed

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
    if startBtnGroup.isVisible == false then
       stateMatrix = matrixManager:calculateCellStates(stateMatrix)
    end
end

-- Function to trigger menu functions when returning to the game scene from the menu.
--  Inputs: 
--          - selectedFunction as a string
--  Outputs: 
--          - manipulates stateMatrix, cellBox, startBtnGroup.isVisible, sliderGroup.isVisible, seedingNotificationGroup.isVisible
--
--  Author: Marten Tammetalu
function scene:returnFromMenu(selectedFunction)
    -- Do only if a menu item was selected
    if selectedFunction then
        if selectedFunction == "saveState" then
            matrixManager:saveState(stateMatrix)
            return
        elseif selectedFunction == "randomState" then
            -- Pause the game, hide slider, inform the user what to do, and clear the matrix
            startBtnGroup.isVisible = true                      
            sliderGroup.isVisible = false
            seedingNotificationGroup.isVisible = true
            stateMatrix = matrixManager:makeZeroMatrix(settings.matrixSize)
            return       
        elseif selectedFunction == "loadState" then
            -- Load new matrix, verify length matches, use as stateMatrix; If not matching, alert user to save new state
            local loadedMatrix = loadJSONFile("stateMatrix.json")
                if #loadedMatrix == #stateMatrix then
                    stateMatrix = loadedMatrix
                else
                    native.showAlert( "", settings.matrixSizeErrorText, { settings.okText } )
                    print(settings.matrixSizeErrorText)
                end
                return
        elseif selectedFunction == "clearState" then
            stateMatrix = matrixManager:makeZeroMatrix(settings.matrixSize)
            return
        end
    end
    -- Handle cases where the user just closes the menu without selecting an item
    if seedingNotificationGroup.isVisible == false then
        startBtnGroup.isVisible = false
        sliderGroup.isVisible = true
        seedingNotificationGroup.isVisible = false
    end   
end

-- Function to handle pause/start button events
--  Inputs: 
--          - Triggering event
--  Outputs: 
--          - manipulates stateMatrix, startBtnGroup.isVisible, sliderGroup.isVisible, seedingNotificationGroup.isVisible
--
--  Author: Marten Tammetalu
local function handlePauseBtnEvent( event )
    -- If not paused, pause    
    if ( "ended" == event.phase ) then
        if startBtnGroup.isVisible == false then
            startBtnGroup.isVisible = true
        else
            -- If paused and in seeding mode, then do new random matrix, bring back slider and hide seeding instructions
            if seedingNotificationGroup.isVisible == true then
                stateMatrix = matrixManager:makeRandomMatrix(settings.matrixSize, stateMatrix)       
                sliderGroup.isVisible = true
                seedingNotificationGroup.isVisible = false
            end
            -- Resume
            startBtnGroup.isVisible = false
        end
    end
end

-- Function to handle menu button events
--  Inputs: 
--          - Triggering event
--  Outputs: 
--          - manipulates startBtnGroup.isVisible
--
--  Author: Marten Tammetalu
local function handleMenuBtnEvent( event )
    if ( "ended" == event.phase ) then
        composer.showOverlay( "menuScene")
        startBtnGroup.isVisible = true
    end
end

-- Function to handle slider events
--  Inputs: 
--          - Triggering event
--  Outputs: 
--          - manipulates lifeTimer, iSpeed, sliderText.text
--
--  Author: Marten Tammetalu
 local function handleSliderEvent( event )
    -- Cancel current timer
    timer.cancel(lifeTimer)
    -- Adjust iteration speed in the range from 1-30
    iSpeed = 29*(event.value/100) + 1
    -- Inform user what is going on
    sliderText.text = settings.iterationSpeedText .. iSpeed .. settings.fpsText
    -- Animate again by assigning new lifetimer using updated iSpeed
    lifeTimer = timer.performWithDelay(1000/iSpeed, timeBasedAnimate, -1)
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    -- Assign "self.view" to local variable "sceneGroup" for easy reference
    local sceneGroup = self.view

   
    -- Function to draw the cells on screen, add them to the sceneGroup and handle touch events on them
    --  Inputs: 
    --          - the cellBox with cells, box position, colors, size and padding
    --          - the matrix of cell states
    --
    --  Outputs: 
    --          - operates on the cells table in the cellBox table passed by reference
    --
    --  Author: Marten Tammetalu
    local function drawCells(matrix, cellBox)
        local matrixSize = #matrix
     
        -- Calculate the size of each cell based on the spacing, cellBox size and cell amount
        local cellSize = ((-matrixSize+1)*cellBox.spacing+cellBox.size)/matrixSize
    
        -- Calculate the starting position of the grid
        local startX = cellBox.x - cellBox.size/2 + 0.5*cellSize
        local startY = cellBox.y - cellBox.size/2 + 0.5*cellSize
    
        -- Define the touchHandler function to allow live manipulation of cells
        local function touchHandler(event)
            if event.phase == "moved" then
                local row = event.target.row
                local col = event.target.col   
                stateMatrix[row][col] = 1  
            end
        end
       
        -- Populate the cellbox with the grid of cells
        for row = 1, matrixSize do
                
            cellBox.cells[row] = {}
            for col = 1, matrixSize do
                local cellX = startX + (col - 1) * (cellSize + cellBox.spacing)
                local cellY = startY + (row - 1) * (cellSize + cellBox.spacing)
    
                local cell = display.newRect(cellX, cellY, cellSize, cellSize)
                sceneGroup:insert(cell)
                cellBox.cells[row][col] = cell
                -- Store the row and column of the cell as properties of the rectangle object
                cell.row = row
                cell.col = col
                if matrix[row][col] == 1 then
                    cell:setFillColor(unpack(cellBox.aliveCellFillColor))
                else
                    cell:setFillColor(unpack(cellBox.deadCellFillColor))
                end
                -- Each cell should be able to be interacted with 
                cell:addEventListener("touch", touchHandler)
            end
        end    
    end
     
    sliderText = display.newText( sliderTextProperties )
    sliderText:setFillColor( unpack(settings.primaryColor) )
    sceneGroup:insert(sliderText)
    sliderGroup:insert(sliderText)

  
     
    seedingNotificationText = display.newText( seedingNotificationTextProperties )
    seedingNotificationText:setFillColor( unpack(settings.primaryColor) )
    sceneGroup:insert(seedingNotificationText)
    seedingNotificationGroup:insert(seedingNotificationText)
        
    -- Create the widget
    slider = widget.newSlider(
        {
            x = settings.X,
            y = sliderY,
            width = sliderW,
            value = 100*iSpeed/30,  -- Start slider at 66.6%
            listener = handleSliderEvent
        }
    )
    sceneGroup:insert(slider)
    sliderGroup:insert(slider)
         
    -- Create the pauseButton
    pauseBtn = widget.newButton(
        {
            label = settings.pauseText,
            fontSize = settings.fontSize,
            labelColor = { default=settings.primaryColor, over={0,0,0} },
            onEvent = handlePauseBtnEvent,
            emboss = false,
            -- Properties for a rounded rectangle button
            shape = "roundedRect",
            width = btnWidth,
            height = btnHeight,
            cornerRadius = 2,
            fillColor = { default={0,0,0}, over={1,1,1} },
            strokeColor = { default=settings.primaryColor, over={0,0,0} },
            strokeWidth = 1
        }
    )

    sceneGroup:insert(pauseBtn)
    
    -- Create the startBtn
    startBtn = widget.newButton(
    {
        label = settings.startText,
        onEvent = buttonHandler,
        fontSize = settings.fontSize,
        labelColor = { default={1,1,1}, over=settings.primaryColor },
        onEvent = handlePauseBtnEvent,
        emboss = false,
        -- Properties for a rounded rectangle button
        shape = "roundedRect",
        width = btnWidth,
        height = btnHeight,
        cornerRadius = 2,
        fillColor = { default={0,0,0}, over={0,0,0} },
        strokeColor = { default={1,1,1}, over=settings.primaryColor },
        strokeWidth = 1
        }
    )

    startBtnGroup:insert(startBtn)


    
    
     
    -- Create the menuBtn
    menuBtn = widget.newButton(
        {
            label = settings.menuText,
            fontSize = settings.fontSize,
            labelColor = { default=settings.primaryColor, over={0,0,0} },
            emboss = false,
            -- Properties for a rounded rectangle button
            shape = "roundedRect",
            width = btnWidth,
            height = btnHeight,
            cornerRadius = 2,
            fillColor = { default={0,0,0}, over={1,1,1} },
            strokeColor = { default=settings.primaryColor, over={0,0,0} },
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
    
    

    menuBtn:addEventListener("touch", handleMenuBtnEvent)

    -- Check if matrix size has changed, load the matrix, draw the grid
    local loadedMatrix = loadJSONFile("stateMatrix.json")
    if settings.matrixSize == #loadedMatrix then
        stateMatrix = loadedMatrix
    else 
        stateMatrix = matrixManager:makeRandomMatrix(settings.matrixSize)
    end
    drawCells(stateMatrix, cellBox)

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

