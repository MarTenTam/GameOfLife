-- GameOfLife.lua
local widget = require("widget")
local X = display.contentCenterX -- X coordinate of the center of the screen
local Y = display.contentCenterY -- Y coordinate of the center of the screen
local W = display.contentWidth -- content width
local H = display.contentHeight -- content height
local matrixSize = 100
local tempMatrix = {}

local function randomMatrix(size)

    --Create a random binary 2d matrix of cell states

    local matrix = {}

    for row = 1, size do
        matrix[row] = {}
        for col = 1, size do
            if math.random() < 0.5 then
                matrix[row][col] = 10
            else
                matrix[row][col] = 11
            end
        end
    end
    return matrix
end

--Function to update cells: takes the cell's current state and the sum of the states of its 8 neighbours and returns its updated state
local function updateCell(currentCellState, neighbourStateSum)

    if currentCellState == 11 then
        if (neighbourStateSum == 82 or neighbourStateSum == 83) then
            return 11
        else
            return 10
        end
    elseif currentCellState == 10 then
        if neighbourStateSum == 83 then
            return 11
        else
            return 10
        end
    end
end



-- Function to calculate the states of all cells for the next frame. 
-- It takes the binary matrix of cells as a table, calculates the new matrix and returns it.
local function calculateCellStates(stateMatrix,tempMatrix)

    -- Create a metatable to be able to handle inputting values into empty tables without creating empty tables manually each time
    local metaTable = {
        -- Define the __index metamethod for the metatable
        __index =
            function(t, k)
                -- Create a new inner table
                local inner = {}
                -- Use rawset to set the value of key 'k' in table 't' to the new inner table
                rawset(t, k, inner)
                -- Return the inner table
                return inner
            end
    }

    tempMatrix = setmetatable({}, metaTable)
    local neighbourStateSum = 0
    local lastRowIndex = #stateMatrix
    local lastColumnIndex = #stateMatrix[1]

-- Check the states of all the 8 surrounding cells, get the total of live cells and update cell state  
    -- Do upper left corner
    neighbourStateSum = stateMatrix[lastRowIndex][lastColumnIndex] + stateMatrix[lastRowIndex][1] + stateMatrix[lastRowIndex][2] + stateMatrix[1][2] + stateMatrix[2][2]
    + stateMatrix[2][1] + stateMatrix[2][lastColumnIndex] + stateMatrix[1][lastColumnIndex]
    -- Save updated cell to new matrix
    tempMatrix[1][1] = updateCell(stateMatrix[1][1], neighbourStateSum)
    -- Reset accumulator
    neighbourStateSum = 0

    -- Do upper right corner
    neighbourStateSum = stateMatrix[lastRowIndex][lastColumnIndex-1] + stateMatrix[lastRowIndex][lastColumnIndex] + stateMatrix[lastRowIndex][1] + stateMatrix[1][1] + stateMatrix[2][1]
    + stateMatrix[2][lastColumnIndex] + stateMatrix[2][lastColumnIndex-1] + stateMatrix[1][lastColumnIndex-1]
    -- Save updated cell to new matrix
    tempMatrix[1][lastColumnIndex] = updateCell(stateMatrix[1][lastColumnIndex], neighbourStateSum)
    -- Reset accumulator
    neighbourStateSum = 0

    -- Do upper edge middles 
    -- For each element+1 to length-1 in inner table at outer table 1
    for i=2, lastColumnIndex-1 do
        neighbourStateSum = stateMatrix[lastRowIndex][i-1] + stateMatrix[lastRowIndex][i] + stateMatrix[lastRowIndex][i+1] + stateMatrix[1][i+1] + stateMatrix[2][i+1]
        + stateMatrix[2][i] + stateMatrix[2][i-1] + stateMatrix[1][i-1]
         -- Save updated cell to new matrix
        tempMatrix[1][i] = updateCell(stateMatrix[1][i], neighbourStateSum)
        -- Reset accumulator
        neighbourStateSum = 0
    end
    
    
    -- For each row(outer table entry) from +1 to len-1, do
    for i=2, lastRowIndex-1 do
        --Do left edge middles
        neighbourStateSum = stateMatrix[i-1][lastColumnIndex] + stateMatrix[i-1][1] + stateMatrix[i-1][2] + stateMatrix[i][2] + stateMatrix[i+1][2]
        + stateMatrix[i+1][1] + stateMatrix[i+1][lastColumnIndex] + stateMatrix[i][lastColumnIndex]
         -- Save updated cell to new matrix
        tempMatrix[i][1] = updateCell(stateMatrix[i][1], neighbourStateSum)
        -- Reset accumulator
        neighbourStateSum = 0

        --Do middles without edge cases
        for j=2, lastColumnIndex-1 do
            neighbourStateSum = stateMatrix[i-1][j-1] + stateMatrix[i-1][j] + stateMatrix[i-1][j+1] + stateMatrix[i][j+1] + stateMatrix[i+1][j+1]
            + stateMatrix[i+1][j] + stateMatrix[i+1][j-1] + stateMatrix[i][j-1]
            -- Save updated cell to new matrix
            tempMatrix[i][j] = updateCell(stateMatrix[i][j], neighbourStateSum)
            -- Reset accumulator
            neighbourStateSum = 0
        end

        --Do right edge middles
        neighbourStateSum = stateMatrix[i-1][lastColumnIndex-1] + stateMatrix[i-1][lastColumnIndex] + stateMatrix[i-1][1] + stateMatrix[i][1] + stateMatrix[i+1][1]
        + stateMatrix[i+1][lastColumnIndex] + stateMatrix[i+1][lastColumnIndex-1] + stateMatrix[i][lastColumnIndex-1]
         -- Save updated cell to new matrix
        tempMatrix[i][lastColumnIndex] = updateCell(stateMatrix[i][lastColumnIndex], neighbourStateSum)
        -- Reset accumulator
        neighbourStateSum = 0

    end

    -- Do lower left corner
    neighbourStateSum = stateMatrix[lastRowIndex-1][lastColumnIndex] + stateMatrix[lastRowIndex-1][1] + stateMatrix[lastRowIndex-1][2] + stateMatrix[lastRowIndex][2] + stateMatrix[1][2]
    + stateMatrix[1][1] + stateMatrix[1][lastColumnIndex] + stateMatrix[lastRowIndex][lastColumnIndex]
    -- Save updated cell to new matrix
    tempMatrix[lastRowIndex][1] = updateCell(stateMatrix[lastRowIndex][1], neighbourStateSum)
    -- Reset accumulator
    neighbourStateSum = 0


    -- Do lower right corner
    neighbourStateSum = stateMatrix[lastRowIndex-1][lastColumnIndex-1] + stateMatrix[lastRowIndex-1][lastColumnIndex] + stateMatrix[lastRowIndex-1][1] + stateMatrix[lastRowIndex][1] + stateMatrix[1][1]
    + stateMatrix[1][lastColumnIndex] + stateMatrix[1][lastColumnIndex-1] + stateMatrix[lastRowIndex][lastColumnIndex-1]
    -- Save updated cell to new matrix
    tempMatrix[lastRowIndex][lastColumnIndex] = updateCell(stateMatrix[lastRowIndex][lastColumnIndex], neighbourStateSum)
    -- Reset accumulator
    neighbourStateSum = 0
    
    -- Do lower edge middles
    -- For each element+1 to lastColumnIndex-1 in inner table at outer element at lastRowIndex:
    for i=2, lastColumnIndex-1 do
        neighbourStateSum = stateMatrix[lastRowIndex-1][i-1] + stateMatrix[lastRowIndex-1][i] + stateMatrix[lastRowIndex-1][i+1] + stateMatrix[lastRowIndex][i+1] + stateMatrix[1][i+1]
        + stateMatrix[1][i] + stateMatrix[1][i-1] + stateMatrix[lastRowIndex][i-1]
         -- Save updated cell to new matrix
        tempMatrix[lastRowIndex][i] = updateCell(stateMatrix[lastRowIndex][i], neighbourStateSum)
        -- Reset accumulator
        neighbourStateSum = 0
    end

    -- Unset the metatable to avoid potential infinite loops when iterating over the table
    setmetatable(tempMatrix,nil)
    return tempMatrix
end



local cells = {}
local aliveCellFillColor = {1, 0.5, 0} -- orange
local deadCellFillColor = {0, 0, 0} -- black
local doLife = true
local lifeTimer

local stateMatrix = randomMatrix(matrixSize)

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






drawCells(stateMatrix)

local function timeBasedAnimate(event)
     animate(stateMatrix, cells)
     if doLife then
        stateMatrix = calculateCellStates(stateMatrix, tempMatrix)
     end

end

local frameRate = 20 -- frames per second

local options = 
{
    text = "Iteration speed at " .. frameRate .. " FPS",     
    x = X,
    y = H/14,
    width = W,
    font = native.systemFont,   
    fontSize = 12,
    align = "center"  -- Alignment parameter
}
 
local sliderText = display.newText( options )
sliderText:setFillColor( unpack(aliveCellFillColor) )



-- Slider listener
local function sliderListener( event )
    timer.cancel(lifeTimer)
    frameRate = 30*(event.value/100)
    sliderText.text = "Iteration speed at " .. frameRate .. " FPS"
    lifeTimer = timer.performWithDelay(1000/frameRate, timeBasedAnimate, -1)
    print( "FPS at " .. frameRate )
end
 
-- Create the widget
local slider = widget.newSlider(
    {
        x = X,
        y = 0,
        width = W*0.9,
        value = 66.6,  -- Start slider at 66.6%
        listener = sliderListener
    }
)

local pauseToggle = 0


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
end

 
-- Create the widget
local startButton = widget.newButton(
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

local menuToggle = 0



 
-- Create the menuButton
local menuButton = widget.newButton(
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

-- Create the menuDummyButton
local menuDummyButton = widget.newButton(
    {
        label = "MENU",
        fontSize = 12,
        labelColor = { default={1,1,1}, over=aliveCellFillColor },
        emboss = false,
        -- Properties for a rounded rectangle button
        shape = "roundedRect",
        width = W/3,
        height = 5+W/8,
        cornerRadius = 2,
        left = W/4-W/6,
        top = H-W/16-5,
        fillColor = { default={0,0,0}, over={0,0,0} },
        strokeColor = { default={1,1,1}, over=aliveCellFillColor },
        strokeWidth = 1
    }
)
 
-- Align the buttons
startButton.x = W-(W/4)
startButton.y = H
menuButton.x = W/4
menuButton.y = H


--Create displaygroup for menu
local menuGroup = display.newGroup()

menuGroup:insert(menuDummyButton)
menuGroup.isVisible = false



menuX = menuButton.x+W/7

local backDrop = display.newRect( menuGroup, menuX, H-H*0.3-W/16-3, W*0.62, H*0.6 )
backDrop.strokeWidth = 1
backDrop:setFillColor( 0, 0, 0 )
backDrop:setStrokeColor( 1, 1, 1 )

-- Define the buttonHandler function
local function buttonHandler(event)
    if (event.phase == "ended") then
            
        menuGroup.isVisible = false
        menuToggle = menuToggle + 1
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
            y = y,
            functionName = functionName
        }
    )
    return btn
end

local btnPadding = 14
local btnHeight = H/12
local btnWidth = W*0.6-btnPadding   
local saveStateBtn = Btn(saveState, "SAVE STATE", menuX, H/2, btnWidth, btnHeight)
local loadStateBtn = Btn(loadState, "LOAD STATE", menuX, H/2+btnHeight+btnPadding, btnWidth, btnHeight)
local clearStateBtn = Btn(clearState, "CLEAR STATE", menuX, H/2+2*(btnHeight+btnPadding), btnWidth, btnHeight)
local randomStateBtn = Btn(randomState, "NEW RANDOM STATE", menuX, H/2+3*(btnHeight+btnPadding), btnWidth, btnHeight)
menuGroup:insert(saveStateBtn)
menuGroup:insert(clearStateBtn)
menuGroup:insert(loadStateBtn)
menuGroup:insert(randomStateBtn)

-- Function to handle button events
local function handleMenuButtonEvent( event )
    if ( "ended" == event.phase ) then
        
        if menuToggle % 2 == 0 then
            menuGroup.isVisible = true

        else
            menuGroup.isVisible = false
        end
        menuToggle = menuToggle + 1

        
    end

end

menuButton:addEventListener("touch", handleMenuButtonEvent)
menuDummyButton:addEventListener("touch", handleMenuButtonEvent)

--Call the updateFillColor function at a specified interval using timer.performWithDelay()

lifeTimer = timer.performWithDelay(1000/frameRate, timeBasedAnimate, -1)







