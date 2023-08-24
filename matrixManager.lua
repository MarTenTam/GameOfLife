-----------------------------------------------------------------------------------------
--
-- matrixManager.lua
--
-- Matrix manager for game of life
--
-----------------------------------------------------------------------------------------

local matrixManager = {}

function matrixManager:randomState(size)

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

function matrixManager:clearState(size)

    --Create a binary 2d matrix of dead cells

    local matrix = {}

    for row = 1, size do
        matrix[row] = {}
        for col = 1, size do
                matrix[row][col] = 10
        end
    end
    return matrix
end

--Function to update cells: takes the cell's current state and the sum of the states of its 8 neighbours and returns its updated state
function matrixManager:updateCell(currentCellState, neighbourStateSum)

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
function matrixManager:calculateCellStates(stateMatrix,tempMatrix)

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
    tempMatrix[1][1] = matrixManager:updateCell(stateMatrix[1][1], neighbourStateSum)
    -- Reset accumulator
    neighbourStateSum = 0

    -- Do upper right corner
    neighbourStateSum = stateMatrix[lastRowIndex][lastColumnIndex-1] + stateMatrix[lastRowIndex][lastColumnIndex] + stateMatrix[lastRowIndex][1] + stateMatrix[1][1] + stateMatrix[2][1]
    + stateMatrix[2][lastColumnIndex] + stateMatrix[2][lastColumnIndex-1] + stateMatrix[1][lastColumnIndex-1]
    -- Save updated cell to new matrix
    tempMatrix[1][lastColumnIndex] = matrixManager:updateCell(stateMatrix[1][lastColumnIndex], neighbourStateSum)
    -- Reset accumulator
    neighbourStateSum = 0

    -- Do upper edge middles 
    -- For each element+1 to length-1 in inner table at outer table 1
    for i=2, lastColumnIndex-1 do
        neighbourStateSum = stateMatrix[lastRowIndex][i-1] + stateMatrix[lastRowIndex][i] + stateMatrix[lastRowIndex][i+1] + stateMatrix[1][i+1] + stateMatrix[2][i+1]
        + stateMatrix[2][i] + stateMatrix[2][i-1] + stateMatrix[1][i-1]
         -- Save updated cell to new matrix
        tempMatrix[1][i] = matrixManager:updateCell(stateMatrix[1][i], neighbourStateSum)
        -- Reset accumulator
        neighbourStateSum = 0
    end
    
    
    -- For each row(outer table entry) from +1 to len-1, do
    for i=2, lastRowIndex-1 do
        --Do left edge middles
        neighbourStateSum = stateMatrix[i-1][lastColumnIndex] + stateMatrix[i-1][1] + stateMatrix[i-1][2] + stateMatrix[i][2] + stateMatrix[i+1][2]
        + stateMatrix[i+1][1] + stateMatrix[i+1][lastColumnIndex] + stateMatrix[i][lastColumnIndex]
         -- Save updated cell to new matrix
        tempMatrix[i][1] = matrixManager:updateCell(stateMatrix[i][1], neighbourStateSum)
        -- Reset accumulator
        neighbourStateSum = 0

        --Do middles without edge cases
        for j=2, lastColumnIndex-1 do
            neighbourStateSum = stateMatrix[i-1][j-1] + stateMatrix[i-1][j] + stateMatrix[i-1][j+1] + stateMatrix[i][j+1] + stateMatrix[i+1][j+1]
            + stateMatrix[i+1][j] + stateMatrix[i+1][j-1] + stateMatrix[i][j-1]
            -- Save updated cell to new matrix
            tempMatrix[i][j] = matrixManager:updateCell(stateMatrix[i][j], neighbourStateSum)
            -- Reset accumulator
            neighbourStateSum = 0
        end

        --Do right edge middles
        neighbourStateSum = stateMatrix[i-1][lastColumnIndex-1] + stateMatrix[i-1][lastColumnIndex] + stateMatrix[i-1][1] + stateMatrix[i][1] + stateMatrix[i+1][1]
        + stateMatrix[i+1][lastColumnIndex] + stateMatrix[i+1][lastColumnIndex-1] + stateMatrix[i][lastColumnIndex-1]
         -- Save updated cell to new matrix
        tempMatrix[i][lastColumnIndex] = matrixManager:updateCell(stateMatrix[i][lastColumnIndex], neighbourStateSum)
        -- Reset accumulator
        neighbourStateSum = 0

    end

    -- Do lower left corner
    neighbourStateSum = stateMatrix[lastRowIndex-1][lastColumnIndex] + stateMatrix[lastRowIndex-1][1] + stateMatrix[lastRowIndex-1][2] + stateMatrix[lastRowIndex][2] + stateMatrix[1][2]
    + stateMatrix[1][1] + stateMatrix[1][lastColumnIndex] + stateMatrix[lastRowIndex][lastColumnIndex]
    -- Save updated cell to new matrix
    tempMatrix[lastRowIndex][1] = matrixManager:updateCell(stateMatrix[lastRowIndex][1], neighbourStateSum)
    -- Reset accumulator
    neighbourStateSum = 0


    -- Do lower right corner
    neighbourStateSum = stateMatrix[lastRowIndex-1][lastColumnIndex-1] + stateMatrix[lastRowIndex-1][lastColumnIndex] + stateMatrix[lastRowIndex-1][1] + stateMatrix[lastRowIndex][1] + stateMatrix[1][1]
    + stateMatrix[1][lastColumnIndex] + stateMatrix[1][lastColumnIndex-1] + stateMatrix[lastRowIndex][lastColumnIndex-1]
    -- Save updated cell to new matrix
    tempMatrix[lastRowIndex][lastColumnIndex] = matrixManager:updateCell(stateMatrix[lastRowIndex][lastColumnIndex], neighbourStateSum)
    -- Reset accumulator
    neighbourStateSum = 0
    
    -- Do lower edge middles
    -- For each element+1 to lastColumnIndex-1 in inner table at outer element at lastRowIndex:
    for i=2, lastColumnIndex-1 do
        neighbourStateSum = stateMatrix[lastRowIndex-1][i-1] + stateMatrix[lastRowIndex-1][i] + stateMatrix[lastRowIndex-1][i+1] + stateMatrix[lastRowIndex][i+1] + stateMatrix[1][i+1]
        + stateMatrix[1][i] + stateMatrix[1][i-1] + stateMatrix[lastRowIndex][i-1]
         -- Save updated cell to new matrix
        tempMatrix[lastRowIndex][i] = matrixManager:updateCell(stateMatrix[lastRowIndex][i], neighbourStateSum)
        -- Reset accumulator
        neighbourStateSum = 0
    end

    -- Unset the metatable to avoid potential infinite loops when iterating over the table
    setmetatable(tempMatrix,nil)
    return tempMatrix
end

return matrixManager