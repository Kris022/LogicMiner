chainOptions = {
    frames = {{ -- 1) right
        x = 0,
        y = 0,
        width = 32,
        height = 30
    }, { -- 2) down
        x = 32,
        y = 0,
        width = 32,
        height = 30
    }, { -- 3) right L
        x = 0,
        y = 32,
        width = 32,
        height = 30
    }, { -- 4) left L
        x = 32,
        y = 32,
        width = 32,
        height = 30
    }, { -- 5) left L
        x = 0,
        y = 60,
        width = 32,
        height = 30
    }, { -- 6) left L
        x = 32,
        y = 60,
        width = 32,
        height = 30
    }}
}

chainSheet = graphics.newImageSheet("images/chain.png", chainOptions)

-- Holds chain segments
local segments = {}
-- display.newImageRect(mainGroup, chainSheet, 1, 32, 30)

dir = {
    x = 0,
    y = 0
}

function setDir(newX, newY)
    dir.x = newX
    dir.y = newY
end

function addSegment(row, col)
    -- row = y, col = x
    local tileX = map_x + (col - 1) * tileWidth
    local tileY = map_y + (row - 1) * tileHeight

    local tile = display.newImageRect(mainGroup, chainSheet, 1, tileWidth, tileHeight)
    tile.x = tileX
    tile.y = tileY

    segments[#segments+1] = {tile, col, row}
    levelTiles[row][col] = "s"

end

addSegment(1, 9)

function manageSegments()
    -- Get the row and col values of the last segment
    local lastSegment = segments[#segments]
    local lastRow = lastSegment[3] -- row value of the last segment
    local lastCol = lastSegment[2] -- col value of the last segment
    
    -- Compute where the next segment will be
    local nextRow = lastRow + dir.y
    local nextCol = lastCol + dir.x

    -- Check if new segment can be inserted at the position
    if levelTiles[nextRow][nextCol] == 0 then
        -- If position is valid
        addSegment(nextRow, nextCol)

    -- Check if player tried to remove last inserted segment
    elseif levelTiles[nextRow][nextCol] == "s" then
        -- Get penulitmate values
        local penultimateSegment = segments[#segments-1]
        local penultimateRow = penultimateSegment[3]
        local penultimateCol = penultimateSegment[2]

        -- Check if penultimate segment equals next segment to be inserted
        if penultimateRow == nextRow and penultimateCol == nextCol then
            -- change last segment tile back to 0
            levelTiles[lastRow][lastCol] = 0
            -- Remove last segment
            display.remove(segments[#segments][1])
            table.remove(segments, #segments)
        end

    end

    


end





-- ERROR HANDLE TRYING TO MOVE ONTO THE FIRST SEGMENTS POSITION