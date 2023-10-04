module(..., package.seeall) -- need this to make things visible

-- Test if a when a cell is alive then it stays alive if it has 2 or 3 live neighbours.
function testupdateCell1()
    assert_equal(updateCell(1,2), 1)
    assert_equal(updateCell(1,3), 1)
end

-- Test that otherwise its state changes to dead.
function testupdateCell2()
    assert_equal(updateCell(1,0), 0)
    assert_equal(updateCell(1,1), 0)
    for neighbourStateSum = 4, 8 do     
        assert_equal(updateCell(1,neighbourStateSum), 0)
    end
end

-- Test that if the cell is dead then it becomes alive if it has exactly three living neighbours, in other cases it stays dead.
function testupdateCell3()
    assert_equal(updateCell(0,3), 1)
    for neighbourStateSum = 0, 2 do     
        assert_equal(updateCell(0,neighbourStateSum), 0)
    end   
    for neighbourStateSum = 4, 8 do     
        assert_equal(updateCell(0,neighbourStateSum), 0)
    end
end

-- Test to see if 2 consecutive frames for known patterns are correctly calculated
function testCalculateCellStates1()

    local function doTest(inputFrame, expectedFrame)
        local matrixSize = #inputFrame
        local outputFrame = calculateCellStates(inputFrame)
    
        for row=1, matrixSize do
            for col=1, matrixSize do
                assert_equal(outputFrame[row][col],expectedFrame[row][col])
            end
        end
    end

    --Test to see if logic correct for 2 frames of blinker
    local inputFrame = {
        {0,0,0,0,0},
        {0,0,1,0,0},
        {0,0,1,0,0},
        {0,0,1,0,0},
        {0,0,0,0,0}
    }
    local expectedFrame = {
        {0,0,0,0,0},
        {0,0,0,0,0},
        {0,1,1,1,0},
        {0,0,0,0,0},
        {0,0,0,0,0}
    }
    doTest(inputFrame, expectedFrame)

    -- Test to see if logic correct for 2 frames of still life
    local inputFrame = {
        {0,0,0,0,0},
        {0,0,1,1,0},
        {0,0,1,1,0},
        {0,0,0,0,0},
        {0,0,0,0,0}
    }

    local expectedFrame = {
        {0,0,0,0,0},
        {0,0,1,1,0},
        {0,0,1,1,0},
        {0,0,0,0,0},
        {0,0,0,0,0}
    }
    doTest(inputFrame, expectedFrame)

    -- Test to see if logic correct for 2 frames of glider
    local inputFrame = {
        {0,0,0,0,0},
        {0,0,1,1,0},
        {0,1,0,1,0},
        {0,0,0,1,0},
        {0,0,0,0,0}
    }

    local expectedFrame = {
        {0,0,0,0,0},
        {0,0,1,1,0},
        {0,0,0,1,1},
        {0,0,1,0,0},
        {0,0,0,0,0}
    }
    doTest(inputFrame, expectedFrame)
end