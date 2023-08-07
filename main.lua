-- GameOfLife.lua




--Create a random binary 2d matrix of cell states
local matrixSize = 100
local stateMatrix = {}

for row = 1, matrixSize do
    stateMatrix[row] = {}
    for col = 1, matrixSize do
        if math.random() < 0.5 then
            stateMatrix[row][col] = 10
        else
            stateMatrix[row][col] = 11
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

    local newMatrix = setmetatable({}, metaTable)
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

for i, row in ipairs(stateMatrix) do
    for j, value in ipairs(row) do
        io.write(value, " ")
    end
    io.write("\n")
end



local X = display.contentCenterX -- X coordinate of the center of the screen
local Y = display.contentCenterY -- Y coordinate of the center of the screen
local padding = 10 -- padding around the grid
local aliveCellFillColor = {1, 0.5, 0} -- orange
local deadCellFillColor = {0, 0, 0} -- black

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
    local row = event.target.row
    local col = event.target.col
    if event.phase == "moved" then
        stateMatrix[row][col] = 11
    end
end

-- Create the grid of cells
local cells = {}

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
        cell:addEventListener("touch", touchHandler)
    end
end




-- Define a function to update the fill color of the rectangles based on the binary matrix
local function updateFillColor(event)
    stateMatrix = calculateCellStates(stateMatrix)
    for row = 1, matrixSize do
        for col = 1, matrixSize do
            local cell = cells[row][col]
            if stateMatrix[row][col] == 11 then
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