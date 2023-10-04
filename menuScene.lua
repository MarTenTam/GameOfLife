local composer = require( "composer" )
local widget = require("widget")
local scene = composer.newScene()
local settings = composer.getVariable("settings") -- Get the settings
-- -----------------------------------------------------------------------------------
-- This is the menu scene which runs when the menu is open
-- -----------------------------------------------------------------------------------

-- The buttons and the backdrop rectangle
local saveStateBtn
local loadStateBtn
local clearStateBtn
local randomStateBtn
local menuDummyButton
local backDrop

-- Alignment for the backdrop and buttons based on previous scene
local backDropX = settings.btnX+settings.W/7
local backDropY = settings.btnY-settings.H*0.3-settings.W/16-3
local backDropW = settings.W*0.62
local backDropH = settings.H*0.6

local btnQty = 4 -- How many buttons are there - to calculate heights for buttons
local btnSpacing = 25 -- Space between buttons and button and backdrop edge
local btnW = backDropW-2*btnSpacing
local btnH = (backDropH - 5*btnSpacing) / btnQty
local topBtnY = backDropY - backDropH/2 + btnH/2 + btnSpacing -- Y for the first button

-- For storing what function the button serves
local selectedFunction

-- Function to handle button events. It checks if the button carries a function and if yes, assigns that string to selectedFunction.
--  Inputs: 
--          - Triggering event
--  Outputs: 
--          - manipulates selectedFunction
--
--  Author: Marten Tammetalu
local function buttonHandler(event)
    if (event.phase == "ended") then
        if event.target.selectedFunction then
            selectedFunction = event.target.selectedFunction
        end
        composer.hideOverlay( "menuScene" )
    end
end

-- Function to create menu buttons. It takes parameters and assigns them as properties of the created widget
--  Inputs: 
--          - selectedFunction(string) to associate a function with the button
--          - label for the displayed button label
--          - y position
--  Outputs: 
--          - manipulates selectedFunction
--
--  Author: Marten Tammetalu
local function createMenuBtn(selectedFunction, label, y)
    -- Create a button
    local btn = widget.newButton(
        {
            label = label,
            onEvent = buttonHandler,
            emboss = false,
            shape = "roundedRect",
            width = btnW,
            height = btnH,
            fontSize = settings.fontSize,
            cornerRadius = 2,
            fillColor = { default=settings.secondaryColor, over=settings.buttonPressedColor },
            labelColor = { default=settings.primaryColor, over=settings.secondaryColor },
            strokeColor = { default=settings.primaryColor, over=settings.secondaryColor },
            strokeWidth = 1,
            x = backDropX,
            y = y,
            selectedFunction = selectedFunction
        }
    )

    btn.selectedFunction = selectedFunction

    return btn
end

-- create()
function scene:create( event )

    selectedFunction = false

    -- Assign "self.view" to local variable "sceneGroup" for easy reference
    local sceneGroup = self.view
    
    -- Draw the backdrop, set its strokewidth and colors
    backDrop = display.newRect( sceneGroup, backDropX, backDropY, backDropW , backDropH )
    backDrop.strokeWidth = 1
    backDrop:setFillColor( unpack(settings.secondaryColor) )
    backDrop:setStrokeColor( unpack(settings.buttonPressedColor))

    -- Create a button widget with different color when menu open
    menuDummyButton = widget.newButton(
        {
            label = settings.menuText,
            onEvent = buttonHandler,
            fontSize = settings.fontSize,
            labelColor = { default=settings.buttonPressedColor, over=settings.secondaryColor },
            emboss = false,
            -- Properties for a rounded rectangle button
            shape = "roundedRect",
            width = settings.W/3,
            height = 5+settings.W/8,
            cornerRadius = 2,
            left = settings.btnX-settings.W/6,
            top = settings.btnY-settings.W/16-5,
            fillColor = { default=settings.secondaryColor, over=settings.buttonPressedColor },
            strokeColor = { default=settings.buttonPressedColor, over=settings.buttonPressedColor },
            strokeWidth = 1
        }
    )    

    --Draw the buttons according to the defined settings, manually adjusting the Y coordinate, then add to sceneGroup
    saveStateBtn = createMenuBtn("saveState", settings.saveStateText, topBtnY)
    loadStateBtn = createMenuBtn("loadState", settings.loadStateText, topBtnY+btnH+btnSpacing)
    clearStateBtn = createMenuBtn("clearState", settings.clearStateText, topBtnY+2*(btnH+btnSpacing))
    randomStateBtn = createMenuBtn("randomState", settings.randomStateText, topBtnY+3*(btnH+btnSpacing))
    sceneGroup:insert(menuDummyButton)
    sceneGroup:insert(backDrop)
    sceneGroup:insert(saveStateBtn)
    sceneGroup:insert(loadStateBtn)
    sceneGroup:insert(clearStateBtn)
    sceneGroup:insert(randomStateBtn)
  
end

-- hide()
function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase
    local parent = event.parent  -- Reference to the parent scene object
 
    if ( phase == "will" ) then
        -- Call the function to handle the function that was picked in the other scene and call from matrixManager
        parent:returnFromMenu(selectedFunction)
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "hide", scene )
-- -----------------------------------------------------------------------------------

return scene

