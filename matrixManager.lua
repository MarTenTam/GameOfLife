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

function matrixManager:loadState()

    local stateMatrix= {}

    local path = system.pathForFile("stateMatrix.json", system.ResourceDirectory)

    local file, errorString = io.open(path, "r")

    if not file then

        print( "File error: " .. errorString )
    else
        local contents = file:read("*a") 

        stateMatrix = json.decode(contents)

        io.close(file)

        if not stateMatrix then
            print("Failed to decode JSON data")
        end
        
    end
    
    return stateMatrix
end


function matrixManager:randomState(size)

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

--Function to update cells: takes the cell's current state and the sum of the states of its 8 neighbours and returns its updated state
function matrixManager:updateCell(currentCellState, neighbourStateSum)

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
    local lastIndex = #stateMatrix

-- Check the states of all the 8 surrounding cells, get the total of live cells and update cell state  
    -- Do upper left corner
    neighbourStateSum = stateMatrix[lastIndex][lastIndex] + stateMatrix[lastIndex][1] + stateMatrix[lastIndex][2] + stateMatrix[1][2] + stateMatrix[2][2]
    + stateMatrix[2][1] + stateMatrix[2][lastIndex] + stateMatrix[1][lastIndex]
    -- Save updated cell to new matrix
    tempMatrix[1][1] = matrixManager:updateCell(stateMatrix[1][1], neighbourStateSum)
    -- Reset accumulator
    neighbourStateSum = 0

    -- Do upper right corner
    neighbourStateSum = stateMatrix[lastIndex][lastIndex-1] + stateMatrix[lastIndex][lastIndex] + stateMatrix[lastIndex][1] + stateMatrix[1][1] + stateMatrix[2][1]
    + stateMatrix[2][lastIndex] + stateMatrix[2][lastIndex-1] + stateMatrix[1][lastIndex-1]
    -- Save updated cell to new matrix
    tempMatrix[1][lastIndex] = matrixManager:updateCell(stateMatrix[1][lastIndex], neighbourStateSum)
    -- Reset accumulator
    neighbourStateSum = 0

    -- Do upper edge middles 
    -- For each element+1 to length-1 in inner table at outer table 1
    for i=2, lastIndex-1 do
        neighbourStateSum = stateMatrix[lastIndex][i-1] + stateMatrix[lastIndex][i] + stateMatrix[lastIndex][i+1] + stateMatrix[1][i+1] + stateMatrix[2][i+1]
        + stateMatrix[2][i] + stateMatrix[2][i-1] + stateMatrix[1][i-1]
         -- Save updated cell to new matrix
        tempMatrix[1][i] = matrixManager:updateCell(stateMatrix[1][i], neighbourStateSum)
        -- Reset accumulator
        neighbourStateSum = 0
    end
    
    
    -- For each row(outer table entry) from +1 to len-1, do
    for i=2, lastIndex-1 do
        --Do left edge middles
        neighbourStateSum = stateMatrix[i-1][lastIndex] + stateMatrix[i-1][1] + stateMatrix[i-1][2] + stateMatrix[i][2] + stateMatrix[i+1][2]
        + stateMatrix[i+1][1] + stateMatrix[i+1][lastIndex] + stateMatrix[i][lastIndex]
         -- Save updated cell to new matrix
        tempMatrix[i][1] = matrixManager:updateCell(stateMatrix[i][1], neighbourStateSum)
        -- Reset accumulator
        neighbourStateSum = 0

        --Do middles without edge cases
        for j=2, lastIndex-1 do
            neighbourStateSum = stateMatrix[i-1][j-1] + stateMatrix[i-1][j] + stateMatrix[i-1][j+1] + stateMatrix[i][j+1] + stateMatrix[i+1][j+1]
            + stateMatrix[i+1][j] + stateMatrix[i+1][j-1] + stateMatrix[i][j-1]
            -- Save updated cell to new matrix
            tempMatrix[i][j] = matrixManager:updateCell(stateMatrix[i][j], neighbourStateSum)
            -- Reset accumulator
            neighbourStateSum = 0
        end

        --Do right edge middles
        neighbourStateSum = stateMatrix[i-1][lastIndex-1] + stateMatrix[i-1][lastIndex] + stateMatrix[i-1][1] + stateMatrix[i][1] + stateMatrix[i+1][1]
        + stateMatrix[i+1][lastIndex] + stateMatrix[i+1][lastIndex-1] + stateMatrix[i][lastIndex-1]
         -- Save updated cell to new matrix
        tempMatrix[i][lastIndex] = matrixManager:updateCell(stateMatrix[i][lastIndex], neighbourStateSum)
        -- Reset accumulator
        neighbourStateSum = 0

    end

    -- Do lower left corner
    neighbourStateSum = stateMatrix[lastIndex-1][lastIndex] + stateMatrix[lastIndex-1][1] + stateMatrix[lastIndex-1][2] + stateMatrix[lastIndex][2] + stateMatrix[1][2]
    + stateMatrix[1][1] + stateMatrix[1][lastIndex] + stateMatrix[lastIndex][lastIndex]
    -- Save updated cell to new matrix
    tempMatrix[lastIndex][1] = matrixManager:updateCell(stateMatrix[lastIndex][1], neighbourStateSum)
    -- Reset accumulator
    neighbourStateSum = 0


    -- Do lower right corner
    neighbourStateSum = stateMatrix[lastIndex-1][lastIndex-1] + stateMatrix[lastIndex-1][lastIndex] + stateMatrix[lastIndex-1][1] + stateMatrix[lastIndex][1] + stateMatrix[1][1]
    + stateMatrix[1][lastIndex] + stateMatrix[1][lastIndex-1] + stateMatrix[lastIndex][lastIndex-1]
    -- Save updated cell to new matrix
    tempMatrix[lastIndex][lastIndex] = matrixManager:updateCell(stateMatrix[lastIndex][lastIndex], neighbourStateSum)
    -- Reset accumulator
    neighbourStateSum = 0
    
    -- Do lower edge middles
    -- For each element+1 to lastIndex-1 in inner table at outer element at lastIndex:
    for i=2, lastIndex-1 do
        neighbourStateSum = stateMatrix[lastIndex-1][i-1] + stateMatrix[lastIndex-1][i] + stateMatrix[lastIndex-1][i+1] + stateMatrix[lastIndex][i+1] + stateMatrix[1][i+1]
        + stateMatrix[1][i] + stateMatrix[1][i-1] + stateMatrix[lastIndex][i-1]
         -- Save updated cell to new matrix
        tempMatrix[lastIndex][i] = matrixManager:updateCell(stateMatrix[lastIndex][i], neighbourStateSum)
        -- Reset accumulator
        neighbourStateSum = 0
    end

    -- Unset the metatable to avoid potential infinite loops when iterating over the table
    setmetatable(tempMatrix,nil)
    return tempMatrix
end

return matrixManager