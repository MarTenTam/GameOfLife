-- GameOfLife.lua
local widget = require("widget")
local X = display.contentCenterX -- X coordinate of the center of the screen
local Y = display.contentCenterY -- Y coordinate of the center of the screen
local W = display.contentWidth -- content width
local H = display.contentHeight -- content height
local matrixSize = 100

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

local newMatrix = {}

-- Function to calculate the states of all cells for the next frame. 
-- It takes the binary matrix of cells as a table, calculates the new matrix and returns it.
local function calculateCellStates(matrix)

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

    newMatrix = setmetatable({}, metaTable)
    local neighbourStateSum = 0
    local lastRowIndex = #matrix
    local lastColumnIndex = #matrix[1]

-- Check the states of all the 8 surrounding cells, get the total of live cells and update cell state  
    -- Do upper left corner
    neighbourStateSum = matrix[lastRowIndex][lastColumnIndex] + matrix[lastRowIndex][1] + matrix[lastRowIndex][2] + matrix[1][2] + matrix[2][2]
    + matrix[2][1] + matrix[2][lastColumnIndex] + matrix[1][lastColumnIndex]
    -- Save updated cell to new matrix
    newMatrix[1][1] = updateCell(matrix[1][1], neighbourStateSum)
    -- Reset accumulator
    neighbourStateSum = 0

    -- Do upper right corner
    neighbourStateSum = matrix[lastRowIndex][lastColumnIndex-1] + matrix[lastRowIndex][lastColumnIndex] + matrix[lastRowIndex][1] + matrix[1][1] + matrix[2][1]
    + matrix[2][lastColumnIndex] + matrix[2][lastColumnIndex-1] + matrix[1][lastColumnIndex-1]
    -- Save updated cell to new matrix
    newMatrix[1][lastColumnIndex] = updateCell(matrix[1][lastColumnIndex], neighbourStateSum)
    -- Reset accumulator
    neighbourStateSum = 0

    -- Do upper edge middles 
    -- For each element+1 to length-1 in inner table at outer table 1
    for i=2, lastColumnIndex-1 do
        neighbourStateSum = matrix[lastRowIndex][i-1] + matrix[lastRowIndex][i] + matrix[lastRowIndex][i+1] + matrix[1][i+1] + matrix[2][i+1]
        + matrix[2][i] + matrix[2][i-1] + matrix[1][i-1]
         -- Save updated cell to new matrix
        newMatrix[1][i] = updateCell(matrix[1][i], neighbourStateSum)
        -- Reset accumulator
        neighbourStateSum = 0
    end
    
    
    -- For each row(outer table entry) from +1 to len-1, do
    for i=2, lastRowIndex-1 do
        --Do left edge middles
        neighbourStateSum = matrix[i-1][lastColumnIndex] + matrix[i-1][1] + matrix[i-1][2] + matrix[i][2] + matrix[i+1][2]
        + matrix[i+1][1] + matrix[i+1][lastColumnIndex] + matrix[i][lastColumnIndex]
         -- Save updated cell to new matrix
        newMatrix[i][1] = updateCell(matrix[i][1], neighbourStateSum)
        -- Reset accumulator
        neighbourStateSum = 0

        --Do middles without edge cases
        for j=2, lastColumnIndex-1 do
            neighbourStateSum = matrix[i-1][j-1] + matrix[i-1][j] + matrix[i-1][j+1] + matrix[i][j+1] + matrix[i+1][j+1]
            + matrix[i+1][j] + matrix[i+1][j-1] + matrix[i][j-1]
            -- Save updated cell to new matrix
            newMatrix[i][j] = updateCell(matrix[i][j], neighbourStateSum)
            -- Reset accumulator
            neighbourStateSum = 0
        end

        --Do right edge middles
        neighbourStateSum = matrix[i-1][lastColumnIndex-1] + matrix[i-1][lastColumnIndex] + matrix[i-1][1] + matrix[i][1] + matrix[i+1][1]
        + matrix[i+1][lastColumnIndex] + matrix[i+1][lastColumnIndex-1] + matrix[i][lastColumnIndex-1]
         -- Save updated cell to new matrix
        newMatrix[i][lastColumnIndex] = updateCell(matrix[i][lastColumnIndex], neighbourStateSum)
        -- Reset accumulator
        neighbourStateSum = 0

    end

    -- Do lower left corner
    neighbourStateSum = matrix[lastRowIndex-1][lastColumnIndex] + matrix[lastRowIndex-1][1] + matrix[lastRowIndex-1][2] + matrix[lastRowIndex][2] + matrix[1][2]
    + matrix[1][1] + matrix[1][lastColumnIndex] + matrix[lastRowIndex][lastColumnIndex]
    -- Save updated cell to new matrix
    newMatrix[lastRowIndex][1] = updateCell(matrix[lastRowIndex][1], neighbourStateSum)
    -- Reset accumulator
    neighbourStateSum = 0


    -- Do lower right corner
    neighbourStateSum = matrix[lastRowIndex-1][lastColumnIndex-1] + matrix[lastRowIndex-1][lastColumnIndex] + matrix[lastRowIndex-1][1] + matrix[lastRowIndex][1] + matrix[1][1]
    + matrix[1][lastColumnIndex] + matrix[1][lastColumnIndex-1] + matrix[lastRowIndex][lastColumnIndex-1]
    -- Save updated cell to new matrix
    newMatrix[lastRowIndex][lastColumnIndex] = updateCell(matrix[lastRowIndex][lastColumnIndex], neighbourStateSum)
    -- Reset accumulator
    neighbourStateSum = 0
    
    -- Do lower edge middles
    -- For each element+1 to lastColumnIndex-1 in inner table at outer element at lastRowIndex:
    for i=2, lastColumnIndex-1 do
        neighbourStateSum = matrix[lastRowIndex-1][i-1] + matrix[lastRowIndex-1][i] + matrix[lastRowIndex-1][i+1] + matrix[lastRowIndex][i+1] + matrix[1][i+1]
        + matrix[1][i] + matrix[1][i-1] + matrix[lastRowIndex][i-1]
         -- Save updated cell to new matrix
        newMatrix[lastRowIndex][i] = updateCell(matrix[lastRowIndex][i], neighbourStateSum)
        -- Reset accumulator
        neighbourStateSum = 0
    end

    -- Unset the metatable to avoid potential infinite loops when iterating over the table
    setmetatable(newMatrix,nil)
    return newMatrix
end



local cells = {}
local aliveCellFillColor = {1, 0.5, 0} -- orange
local deadCellFillColor = {0, 0, 0} -- black
local doLife = true
local lifeTimer

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

            newMatrix[row][col] = 11

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

local stateMatrix = randomMatrix(matrixSize)




drawCells(stateMatrix)

local function timeBasedAnimate(event)
     animate(stateMatrix, cells)
     if doLife then
        stateMatrix = calculateCellStates(stateMatrix)
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

--Create displaygroup for menu
local menuGroup = display.newGroup()

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
        strokeColor = { default=aliveCellFillColor, over={1,1,1} },
        strokeWidth = 1
    }
)

local menuToggle = 0



 
-- Create the widget
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
        strokeColor = { default=aliveCellFillColor, over={1,1,1} },
        strokeWidth = 1
    }
)


 
-- Align the buttons
startButton.x = W-(W/4)
startButton.y = H
menuButton.x = W/4
menuButton.y = H

menuX = menuButton.x+W/6

local backDrop = display.newRoundedRect( menuGroup, menuX, H-H*0.3-W/16, W*0.6, H*0.6, 2 )
backDrop.strokeWidth = 1
backDrop:setFillColor( 0, 0, 0 )
backDrop:setStrokeColor( unpack(aliveCellFillColor) )

local function Btn(functionName, label, x, y, w, h)

    -- Define the buttonHandler function
    local function buttonHandler(event)
        if (event.phase == "ended") then
            
            menuGroup.isVisible = false
            menuToggle = menuToggle + 1
        end
    end

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
            strokeColor = { default=aliveCellFillColor, over={1,1,1} },
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
menuGroup.isVisible = false

-- Function to handle button events
local function handleMenuButtonEvent( event )
    
    if ( "ended" == event.phase ) then
        
        if menuToggle % 2 == 0 then
            menuGroup.isVisible = true
            menuButton:setFillColor(1,1,1)
        else
            menuGroup.isVisible = false
            menuButton:setFillColor(0,0,0)
        end
        menuToggle = menuToggle + 1
        print(menuGroup.isVisible==isVisible)
        
    end

end

menuButton:addEventListener("touch", handleMenuButtonEvent)


--Call the updateFillColor function at a specified interval using timer.performWithDelay()

lifeTimer = timer.performWithDelay(1000/frameRate, timeBasedAnimate, -1)







