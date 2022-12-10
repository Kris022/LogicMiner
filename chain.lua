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
    },
    { -- 6) left L
        x = 32,
        y = 60,
        width = 32,
        height = 30
    }
}
}

chainSheet = graphics.newImageSheet("images/chain.png", chainOptions)

-- hook line segments
local segments = {display.newImageRect(mainGroup, chainSheet, 1, 32, 30)}
segments[1].x = 32 * 8
segments[1].y = 30 * 1

dir = {
    x = 0,
    y = 0
}

-- add 1 to x column

function setDir(newX, newY)
    dir.x = newX
    dir.y = newY
end

function vlidatePosition(row, col)
    local tileIndex = (row * mapCols) + col
    local tileIndex = ((nextSegment.y / 30 + 1) * mapCols) + (nextSegment.x / 32 + 1)

    if lvl_tiles[tileIndex] == "0" then
        return true
    else
        return false
    end
end

function addSegment(nx, ny)
    -- swap segment image so it faces movement direction  
    local chainOrientation
    if dir.x ~= 0 then
        chainOrientation = 2
    else
        chainOrientation = 1
    end

    -- checks if there is sufficent number of segments
  --  if #segments > 1 then
        -- check if previous segment is above
      --  if segments[#segments - 1].y < segments[#segments].y then
            -- if last added segment image is horizontal and moved down set current[now prev]to L down 
            
    --    end
    --end


    -- check if previous segment is to the left or right 

    -- if only above change previosu segment

    -- check position of prev segment relative to current 
    if #segments > 1 and segments[#segments - 1].y < segments[#segments].y and segments[#segments].x < nx then
        local temp = {
            x = segments[#segments].x,
            y = segments[#segments].y
        }
        display.remove(segments[#segments])
        segments[#segments] = display.newImageRect(mainGroup, chainSheet, 3, 32, 30)
        segments[#segments].x = temp.x
        segments[#segments].y = temp.y
        -- elseif segments[#segments].x > nx then
        --     segments[#segments]:setFrame( 4 )
    end

    -- display segment
    table.insert(segments, display.newImageRect(mainGroup, chainSheet, chainOrientation, 32, 30))
    segments[#segments].x = nx -- segments[#segments - 1].x + (dir.x * 32)
    segments[#segments].y = ny -- segments[#segments - 1].y + (dir.y * 30)
end

function removeSegment()
    display.remove(segments[#segments])
    table.remove(segments, #segments)
end

function getLastSegment(chainOrientation)

end

function mapCoordinatesToTableIndex(givenX, givenY, length)
    return givenY * length + givenX
end

function getMapIndex(x, y)
    local col = (x / 32) + 1
    local row = (y / 30) - 1
    return (row * 31) + col
end

function manageSegments()
    -- get position of the next segment
    local nextSegment = {
        x = segments[#segments].x + (dir.x * 32),
        y = segments[#segments].y + (dir.y * 30)
    }

    -- index tiles table
    local col = (nextSegment.x / 32) + 1
    local row = (nextSegment.y / 30) - 1
    local r = (row * 31) + col
    print(lvl_tiles[r])

    -- check if can insert
    if lvl_tiles[r] == 0 then
        -- check if player is going back
        if #segments > 1 and nextSegment.x == segments[#segments - 1].x and nextSegment.y == segments[#segments - 1].y then
            removeSegment()
        else
            addSegment(nextSegment.x, nextSegment.y)
        end
    end

end

