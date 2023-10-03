local composer = require( "composer" )
local widget = require("widget")


local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

local settings = composer.getVariable("settings")

local saveStateBtn
local loadStateBtn
local clearStateBtn
local randomStateBtn
local backDrop
local menuDummyButton

local btnPadding
local btnHeight
local btnWidth
local backDropX
local backDropY
local backDropW
local backDropH
local topBtnY
local selectedFunction

-- Define the buttonHandler function
local function buttonHandler(event)
    if (event.phase == "ended") then
        if event.target.selectedFunction then
            selectedFunction = event.target.selectedFunction
        end
        composer.hideOverlay( "menuScene" )
    end
end

local function Btn(selectedFunction, label, x, y, w, h)
    -- Create a button
    local btn = widget.newButton(
        {
            label = label,
            onEvent = buttonHandler,
            emboss = false,
            shape = "roundedRect",
            width = w,
            height = h,
            labelColor = { default={1,1,1} },
            fontSize = settings.fontSize,
            cornerRadius = 2,
            fillColor = { default={0,0,0}, over={1,1,1} },
            labelColor = { default=settings.primaryColor, over={0,0,0} },
            strokeColor = { default=settings.primaryColor, over={0,0,0} },
            strokeWidth = 1,
            x = x,
            y = y
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

    backDropX = settings.W/4+settings.W/7
    btnPadding = 18
    
    btnWidth = settings.W*0.6-btnPadding
    backDropY = settings.btnY-settings.H*0.3-settings.W/16-3
    backDropW = settings.W*0.62
    backDropH = settings.H*0.6
    btnHeight = (backDropH - 7*btnPadding) / 4
    topBtnY = backDropY - backDropH/2 + btnHeight/2 + btnPadding*2

    
    backDrop = display.newRect( sceneGroup, backDropX, backDropY, backDropW , backDropH )
    backDrop.strokeWidth = 1
    backDrop:setFillColor( 0, 0, 0 )
    backDrop:setStrokeColor( 1, 1, 1 )

    -- Create the menuDummyButton
    menuDummyButton = widget.newButton(
        {
            label = settings.menuText,
            onEvent = buttonHandler,
            fontSize = settings.fontSize,
            labelColor = { default={1,1,1}, over=settings.primaryColor },
            emboss = false,
            -- Properties for a rounded rectangle button
            shape = "roundedRect",
            width = settings.W/3,
            height = 5+settings.W/8,
            cornerRadius = 2,
            left = settings.W/4-settings.W/6,
            top = settings.btnY-settings.W/16-5,
            fillColor = { default={0,0,0}, over={0,0,0} },
            strokeColor = { default={1,1,1}, over=settings.primaryColor },
            strokeWidth = 1
        }
    )
    menuDummyButton.selectedFunction = false

    

    saveStateBtn = Btn("saveState", settings.saveStateText, backDropX, topBtnY, btnWidth, btnHeight)
    --print(saveStateBtn.selectedFunction)
    loadStateBtn = Btn("loadState", settings.loadStateText, backDropX, topBtnY+btnHeight+btnPadding, btnWidth, btnHeight)
    clearStateBtn = Btn("clearState", settings.clearStateText, backDropX, topBtnY+2*(btnHeight+btnPadding), btnWidth, btnHeight)
    randomStateBtn = Btn("randomState", settings.randomStateText, backDropX, topBtnY+3*(btnHeight+btnPadding), btnWidth, btnHeight)
    sceneGroup:insert(menuDummyButton)
    sceneGroup:insert(backDrop)
    sceneGroup:insert(saveStateBtn)
    sceneGroup:insert(loadStateBtn)
    sceneGroup:insert(clearStateBtn)
    sceneGroup:insert(randomStateBtn)



    


    -- Code here runs when the scene is first created but has not yet appeared on screen

   
end


-- show()
function scene:show( event )

    --composer.setVariable("selectedFunction", false)

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
    local parent = event.parent  -- Reference to the parent scene object
 
    if ( phase == "will" ) then

        parent:returnFromMenu(selectedFunction)

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

