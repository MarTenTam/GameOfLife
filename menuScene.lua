local composer = require( "composer" )
local widget = require("widget")


local scene = composer.newScene()

local aliveCellFillColor = {1, 0.5, 0} -- orange
local deadCellFillColor = {0, 0, 0} -- black

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

local X = display.contentCenterX -- X coordinate of the center of the screen
local Y = display.contentCenterY -- Y coordinate of the center of the screen
local W = display.contentWidth -- content width
local H = display.contentHeight -- content height


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

-- Define the buttonHandler function
local function buttonHandler(event)
    if (event.phase == "ended") then
        if event.target.functionName then
            composer.setVariable("functionName", event.target.functionName)
        end
        composer.hideOverlay( "menuScene" )
    end
end

local function Btn(functionName, label, x, y, w, h)
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
            fontSize = 12,
            cornerRadius = 2,
            fillColor = { default={0,0,0}, over={1,1,1} },
            labelColor = { default=aliveCellFillColor, over={0,0,0} },
            strokeColor = { default=aliveCellFillColor, over={0,0,0} },
            strokeWidth = 1,
            x = x,
            y = y
        }
    )

    btn.functionName = functionName

    return btn
end


-- create()
function scene:create( event )

    composer.setVariable("functionName", false)

    -- Assign "self.view" to local variable "sceneGroup" for easy reference
    local sceneGroup = self.view

    backDropX = W/4+W/7
    menuBtnY = composer.getVariable("menuBtnY")
    btnPadding = 18
    
    btnWidth = W*0.6-btnPadding
    backDropY = menuBtnY-H*0.3-W/16-3
    backDropW = W*0.62
    backDropH = H*0.6
    btnHeight = (backDropH - 7*btnPadding) / 4
    topBtnY = backDropY - backDropH/2 + btnHeight/2 + btnPadding*2

    
    backDrop = display.newRect( sceneGroup, backDropX, backDropY, backDropW , backDropH )
    backDrop.strokeWidth = 1
    backDrop:setFillColor( 0, 0, 0 )
    backDrop:setStrokeColor( 1, 1, 1 )

    -- Create the menuDummyButton
    menuDummyButton = widget.newButton(
        {
            label = "MENU",
            onEvent = buttonHandler,
            fontSize = 12,
            labelColor = { default={1,1,1}, over=aliveCellFillColor },
            emboss = false,
            -- Properties for a rounded rectangle button
            shape = "roundedRect",
            width = W/3,
            height = 5+W/8,
            cornerRadius = 2,
            left = W/4-W/6,
            top = menuBtnY-W/16-5,
            fillColor = { default={0,0,0}, over={0,0,0} },
            strokeColor = { default={1,1,1}, over=aliveCellFillColor },
            strokeWidth = 1
        }
    )
    menuDummyButton.functionName = false

    

    saveStateBtn = Btn("saveState", "SAVE STATE", backDropX, topBtnY, btnWidth, btnHeight)
    --print(saveStateBtn.functionName)
    loadStateBtn = Btn("loadState", "LOAD STATE", backDropX, topBtnY+btnHeight+btnPadding, btnWidth, btnHeight)
    clearStateBtn = Btn("clearState", "CLEAR STATE", backDropX, topBtnY+2*(btnHeight+btnPadding), btnWidth, btnHeight)
    randomStateBtn = Btn("randomState", "NEW RANDOM STATE", backDropX, topBtnY+3*(btnHeight+btnPadding), btnWidth, btnHeight)
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

    --composer.setVariable("functionName", false)

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

        parent:resumeGame()

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

