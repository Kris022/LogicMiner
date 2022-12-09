chainOptions = {
    frames = {{ -- 1) right
        x = 0,
        y = 0,
        width = 31,
        height = 30
    }, { -- 2) down
        x = 32,
        y = 0,
        width = 32,
        height = 30
    }, { -- 3) left
        x = 0,
        y = 32,
        width = 32,
        height = 30
    }, { -- 4) up
        x = 32,
        y = 32,
        width = 32,
        height = 30
    }}
}

chainSheet = graphics.newImageSheet("images/chain.png", chainOptions)

-- hook line segments
local segments = {display.newImageRect(mainGroup, chainSheet, 1, 32, 30)}
segments[1].x = 32 * 8
segments[1].y = 30 * 2

dir = {
    x = 0,
    y = 0
}

function setDir(newX, newY)
    dir.x = newX
    dir.y = newY
end

function vlidatePosition(row, col)
    local tileIndex = (row * mapCols) + col
    if tileIndex == 0 then
        return true
    else
        return false
    end
end

function addSegment(nx, ny)
    -- check if segment insertion position is valid
    -- insert into table if valid
    table.insert(segments, display.newImageRect(mainGroup, chainSheet, 1, 32, 30))
    segments[#segments].x = nx--segments[#segments - 1].x + (dir.x * 32)
    segments[#segments].y = ny--segments[#segments - 1].y + (dir.y * 30)
end

function removeSegment()
    display.remove( segments[#segments] )
    table.remove(segments, #segments)
end

function manageSegments()
    -- get position of the next segment
    local nextSegment = {
        x = segments[#segments].x + (dir.x * 32),
        y = segments[#segments].y + (dir.y * 30)
    }


    if #segments>1 and nextSegment.x == segments[#segments-1].x and nextSegment.y == segments[#segments-1].y then
        removeSegment()
    else
        addSegment(nextSegment.x, nextSegment.y)
    end

end

