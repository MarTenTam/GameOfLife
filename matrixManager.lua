-----------------------------------------------------------------------------------------
--
-- matrixManager.lua
--
-- Matrix manager for game of life
--
-----------------------------------------------------------------------------------------
local json = require("json")
local matrixManager = {}

function matrixManager:saveState(stateMatrix)

    local stateMatrixString = json.encode(stateMatrix)

    local path = system.pathForFile("stateMatrix.json", system.ResourceDirectory)

    local file, errorString = io.open( path , "w" )

    if not file then
        print( "File error: " .. errorString )
    else
        local contents = stateMatrixString
        file:write(stateMatrixString)

        file:close()
        print("State file saved!")
       
    end
end

function matrixManager:randomState(size, seedMatrix)

    
    --Add up the seedMatrix to form an int as a seed for randomness if seedMatrix is passed
    if seedMatrix then
        local seed = 0
        local seedMatrixSize = #seedMatrix

        for row = 1, seedMatrixSize do
            for col = 1, seedMatrixSize do
                    seed = seed + seedMatrix[row][col]
            end
        end
        print("The seed for randomness is: " .. seed)
        math.randomseed(seed)
    end
    --Create a random binary 2d matrix of cell states

    local matrix = {}

    for row = 1, size do
        matrix[row] = {}
        for col = 1, size do
            if math.random() < 0.5 then
                matrix[row][col] = 0
            else
                matrix[row][col] = 1
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
                matrix[row][col] = 0
        end
    end
    return matrix
end

function matrixManager:calculateCellStates(stateMatrix)
    local lastIndex = #stateMatrix
    local tempMatrix = {}

    -- Function to determine if cell should be alive or dead in the next frame, based on the rules of game of life.
    --  Inputs: 
    --          - current cell state as an integer of 0 or 1
    --          - the sum of the states of all its 8 neighbours as an integer
    --
    --  Outputs: 
    --          - an integer of 0 or 1, symbolising dead or alive 
    --
    --  Author: Marten Tammetalu
    local function updateCell(currentCellState, neighbourStateSum)

        if currentCellState == 1 then
            if (neighbourStateSum == 2 or neighbourStateSum == 3) then
                return 1
            else
                return 0
            end
        elseif currentCellState == 0 then
            if neighbourStateSum == 3 then
                return 1
            else
                return 0
            end
        end
    end

    -- It takes the row and column of the logical neighbour in an unlimited matrix and returns the element at the actual row 
    -- and column according to the last index of the current matrix, wrapping around in all cases where we are on the boundary.
    local function wrapWithModulo(row, col, lastIndex, stateMatrix)
        local r = (row - 1 + lastIndex) % lastIndex + 1
        local c = (col - 1 + lastIndex) % lastIndex + 1
        return stateMatrix[r][c]
    end

    for i = 1, lastIndex do
        tempMatrix[i] = {}
        for j = 1, lastIndex do
            -- First substract state of self
            local neighbourStateSum = 0 - stateMatrix[i][j]

            -- Then, iterate over all 3x3 cells including self and add up states
            for x = -1, 1 do
                for y = -1, 1 do
                    neighbourStateSum = neighbourStateSum + wrapWithModulo(i + x, j + y, lastIndex, stateMatrix)
                end
            end
            tempMatrix[i][j] = updateCell(stateMatrix[i][j], neighbourStateSum)
        end
    end

    return tempMatrix
end

return matrixManager