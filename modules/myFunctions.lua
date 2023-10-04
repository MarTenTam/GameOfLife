-- Function to determine if cell should be alive or dead in the next frame, based on the rules of game of life.
--  Inputs: 
--          - current cell state as an integer of 0 or 1
--          - the sum of the states of all its 8 neighbours as an integer
--
--  Outputs: 
--          - an integer of 0 or 1, symbolising dead or alive 
--
--  Author: Marten Tammetalu
function updateCell(currentCellState, neighbourStateSum)

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
function wrapWithModulo(row, col, lastIndex, stateMatrix)
    local r = (row - 1 + lastIndex) % lastIndex + 1
    local c = (col - 1 + lastIndex) % lastIndex + 1
    return stateMatrix[r][c]
end

-- Function to calculate the matrix of updated cell states for the next frame.
--  Inputs: 
--          - a binary matrix of cell states in the form of a 2d table with integer values of 1 or 0 symbolizing the dead/alive states
--
--  Outputs: 
--          - a binary matrix of cell states in the form of a 2d table with integer values of 1 or 0 with each cell state updated using
--            updateCell()
--
--  Author: Marten Tammetalu
function calculateCellStates(stateMatrix)
    local lastIndex = #stateMatrix
    local tempMatrix = {}

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