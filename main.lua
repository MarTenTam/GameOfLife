-- GameOfLife.lua




--Create a random binary 2d matrix of cells
local matrixSize = 200
local a = {}

for row = 1, matrixSize do
    a[row] = {}
    for col = 1, matrixSize do
        if math.random() < 0.5 then
            a[row][col] = 10
        else
            a[row][col] = 11
        end
    end
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
local function calculateCellStates(cellMatrix)

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

    local newCellMatrix = setmetatable({}, metaTable)
    local neighbourStateSum = 0
    local lastRowIndex = #cellMatrix
    local lastColumnIndex = #cellMatrix[1]

-- Check the states of all the 8 surrounding cells, get the total of live cells and update cell state  
    -- Do upper left corner
    neighbourStateSum = cellMatrix[lastRowIndex][lastColumnIndex] + cellMatrix[lastRowIndex][1] + cellMatrix[lastRowIndex][2] + cellMatrix[1][2] + cellMatrix[2][2]
    + cellMatrix[2][1] + cellMatrix[2][lastColumnIndex] + cellMatrix[1][lastColumnIndex]
    -- Save updated cell to new matrix
    newCellMatrix[1][1] = updateCell(cellMatrix[1][1], neighbourStateSum)
    -- Reset accumulator
    neighbourStateSum = 0

    -- Do upper right corner
    neighbourStateSum = cellMatrix[lastRowIndex][lastColumnIndex-1] + cellMatrix[lastRowIndex][lastColumnIndex] + cellMatrix[lastRowIndex][1] + cellMatrix[1][1] + cellMatrix[2][1]
    + cellMatrix[2][lastColumnIndex] + cellMatrix[2][lastColumnIndex-1] + cellMatrix[1][lastColumnIndex-1]
    -- Save updated cell to new matrix
    newCellMatrix[1][lastColumnIndex] = updateCell(cellMatrix[1][lastColumnIndex], neighbourStateSum)
    -- Reset accumulator
    neighbourStateSum = 0

    -- Do upper edge middles 
    -- For each element+1 to length-1 in inner table at outer table 1
    for i=2, lastColumnIndex-1 do
        neighbourStateSum = cellMatrix[lastRowIndex][i-1] + cellMatrix[lastRowIndex][i] + cellMatrix[lastRowIndex][i+1] + cellMatrix[1][i+1] + cellMatrix[2][i+1]
        + cellMatrix[2][i] + cellMatrix[2][i-1] + cellMatrix[1][i-1]
         -- Save updated cell to new matrix
        newCellMatrix[1][i] = updateCell(cellMatrix[1][i], neighbourStateSum)
        -- Reset accumulator
        neighbourStateSum = 0
    end
    
    
    -- For each row(outer table entry) from +1 to len-1, do
    for i=2, lastRowIndex-1 do
        --Do left edge middles
        neighbourStateSum = cellMatrix[i-1][lastColumnIndex] + cellMatrix[i-1][1] + cellMatrix[i-1][2] + cellMatrix[i][2] + cellMatrix[i+1][2]
        + cellMatrix[i+1][1] + cellMatrix[i+1][lastColumnIndex] + cellMatrix[i][lastColumnIndex]
         -- Save updated cell to new matrix
        newCellMatrix[i][1] = updateCell(cellMatrix[i][1], neighbourStateSum)
        -- Reset accumulator
        neighbourStateSum = 0

        --Do middles without edge cases
        for j=2, lastColumnIndex-1 do
            neighbourStateSum = cellMatrix[i-1][j-1] + cellMatrix[i-1][j] + cellMatrix[i-1][j+1] + cellMatrix[i][j+1] + cellMatrix[i+1][j+1]
            + cellMatrix[i+1][j] + cellMatrix[i+1][j-1] + cellMatrix[i][j-1]
            -- Save updated cell to new matrix
            newCellMatrix[i][j] = updateCell(cellMatrix[i][j], neighbourStateSum)
            -- Reset accumulator
            neighbourStateSum = 0
        end

        --Do right edge middles
        neighbourStateSum = cellMatrix[i-1][lastColumnIndex-1] + cellMatrix[i-1][lastColumnIndex] + cellMatrix[i-1][1] + cellMatrix[i][1] + cellMatrix[i+1][1]
        + cellMatrix[i+1][lastColumnIndex] + cellMatrix[i+1][lastColumnIndex-1] + cellMatrix[i][lastColumnIndex-1]
         -- Save updated cell to new matrix
        newCellMatrix[i][lastColumnIndex] = updateCell(cellMatrix[i][lastColumnIndex], neighbourStateSum)
        -- Reset accumulator
        neighbourStateSum = 0

    end

    -- Do lower left corner
    neighbourStateSum = cellMatrix[lastRowIndex-1][lastColumnIndex] + cellMatrix[lastRowIndex-1][1] + cellMatrix[lastRowIndex-1][2] + cellMatrix[lastRowIndex][2] + cellMatrix[1][2]
    + cellMatrix[1][1] + cellMatrix[1][lastColumnIndex] + cellMatrix[lastRowIndex][lastColumnIndex]
    -- Save updated cell to new matrix
    newCellMatrix[lastRowIndex][1] = updateCell(cellMatrix[lastRowIndex][1], neighbourStateSum)
    -- Reset accumulator
    neighbourStateSum = 0


    -- Do lower right corner
    neighbourStateSum = cellMatrix[lastRowIndex-1][lastColumnIndex-1] + cellMatrix[lastRowIndex-1][lastColumnIndex] + cellMatrix[lastRowIndex-1][1] + cellMatrix[lastRowIndex][1] + cellMatrix[1][1]
    + cellMatrix[1][lastColumnIndex] + cellMatrix[1][lastColumnIndex-1] + cellMatrix[lastRowIndex][lastColumnIndex-1]
    -- Save updated cell to new matrix
    newCellMatrix[lastRowIndex][lastColumnIndex] = updateCell(cellMatrix[lastRowIndex][lastColumnIndex], neighbourStateSum)
    -- Reset accumulator
    neighbourStateSum = 0
    
    -- Do lower edge middles
    -- For each element+1 to lastColumnIndex-1 in inner table at outer element at lastRowIndex:
    for i=2, lastColumnIndex-1 do
        neighbourStateSum = cellMatrix[lastRowIndex-1][i-1] + cellMatrix[lastRowIndex-1][i] + cellMatrix[lastRowIndex-1][i+1] + cellMatrix[lastRowIndex][i+1] + cellMatrix[1][i+1]
        + cellMatrix[1][i] + cellMatrix[1][i-1] + cellMatrix[lastRowIndex][i-1]
         -- Save updated cell to new matrix
        newCellMatrix[lastRowIndex][i] = updateCell(cellMatrix[lastRowIndex][i], neighbourStateSum)
        -- Reset accumulator
        neighbourStateSum = 0
    end

    -- Unset the metatable to avoid potential infinite loops when iterating over the table
    setmetatable(newCellMatrix,nil)
    return newCellMatrix
end


for i, row in ipairs(a) do
    for j, value in ipairs(row) do
        io.write(value, " ")
    end
    io.write("\n")
end



local X = display.contentCenterX -- X coordinate of the center of the screen
local Y = display.contentCenterY -- Y coordinate of the center of the screen
local gridSize = #a
local padding = 10 -- padding around the grid
local aliveCellFillColor = {1, 0.5, 0} -- orange
local deadCellFillColor = {0, 0, 0} -- black

-- Calculate the size of each cell and the spacing between cells
local cellSize = math.min(
    (display.contentWidth - padding * 2) / gridSize,
    (display.contentHeight - padding * 2) / gridSize
)
local spacing = cellSize / 10

-- Calculate the starting position of the grid
local startX = X - (gridSize / 2) * (cellSize + spacing)
local startY = Y - (gridSize / 2) * (cellSize + spacing)

-- Create a table to store the rectangle objects
local cells = {}

-- Create the grid of rectangles
for row = 1, gridSize do
    cells[row] = {}
    for col = 1, gridSize do
        local cellX = startX + (col - 1) * (cellSize + spacing)
        local cellY = startY + (row - 1) * (cellSize + spacing)

        local cell = display.newRect(cellX, cellY, cellSize, cellSize)
        cells[row][col] = cell
    end
end


-- Define a function to update the fill color of the rectangles based on the binary matrix
local function updateFillColor(event)
    a = calculateCellStates(a)
    for row = 1, gridSize do
        for col = 1, gridSize do
            local cell = cells[row][col]
            if a[row][col] == 11 then
                cell:setFillColor(unpack(aliveCellFillColor))
            else
                cell:setFillColor(unpack(deadCellFillColor))
            end
        end
    end
end

-- Call the updateFillColor function at a specified interval using timer.performWithDelay()
local frameRate = 10 -- frames per second
local frameDelay = 1000 / frameRate -- delay between frames in milliseconds
timer.performWithDelay(frameDelay, updateFillColor, -1)