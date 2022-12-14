local tileMap = require "maps.mine3"

-- Load the background
background = display.newImageRect(backGroup, "images/background1.png", 1400, 800)
background.x = display.contentCenterX
background.y = display.contentCenterY

-- Configure image sheet
sheetOptions = {
    frames = {
        { -- 1) up wall
        x = 0,
        y = 0,
        width = 32,
        height = 30
    }, { -- 2) down wall
        x = 32,
        y = 0,
        width = 32,
        height = 30
    }, { -- 3) left wall
        x = 0,
        y = 30,
        width = 32,
        height = 30
    }, { -- 4) right wall
        x = 32,
        y = 30,
        width = 32,
        height = 30
    }, { -- 5) black wall
        x = 0,
        y = 60,
        width = 32,
        height = 30
    },
    { -- 6) blue dimond
        x = 32,
        y = 60,
        width = 32,
        height = 30
    },
    { -- 7) green dimond
        x = 0,
        y = 90,
        width = 32,
        height = 30
    },
    { -- 8) red dimond
        x = 32,
        y = 90,
        width = 32,
        height = 30
    }
}}

objectSheet = graphics.newImageSheet("images/tiles2.png", sheetOptions)

-------------------------------------- Level Variables --------------------------------------  

levelTiles = tileMap["layers"][1]["data"] -- 1D table storing tile values

-- Number of rows and tables the tile map has
mapRows = tileMap["layers"][1]["height"]
mapCols = tileMap["layers"][1]["width"]

-- Individual Tile Size
tileWidth = tileMap["tilewidth"]
tileHeight = tileMap["tileheight"]

function convert1dTo2d(input)
    -- Create a new empty 2-dimensional table
    local output = {}

    -- Loop over the elements in the input table
    for i, element in ipairs(input) do
        -- Calculate the row index of the current element
        local row = math.floor((i - 1) / mapCols) + 1

        -- Initialize the current row if it doesn't exist yet
        if output[row] == nil then
            output[row] = {}
        end

        -- Insert the current element into the current row
        table.insert(output[row], element)
    end

    -- Return the resulting 2-dimensional table
    return output
end

function printTilesToConsole(input2dTable)
    -- Allows to see values of individual tiles in the console
    local bigString = ""

    for row in ipairs(input2dTable) do
        bigString = bigString .. "\n"
        for col in ipairs(input2dTable[row]) do
            bigString = bigString .. input2dTable[row][col] .. ", "
        end
    end
    print(bigString)
end

levelTiles = convert1dTo2d(levelTiles)
-- printTilesToConsole(levelTiles)

-- Define the offset for position of the top-left corner of the tilemap on the screen
map_x = 0
map_y = 0

dimonds = {}

function renderTilesToScreen(input2dTable)

    -- Loop over the rows and columns of the tilemap
    for row in ipairs(input2dTable) do
        for col in ipairs(input2dTable[row]) do
           -- Calculate the position of the current tile on the screen
            local tileX = map_x + (col - 1) * tileWidth
            local tileY = map_y + (row - 1) * tileHeight

            local tileId = input2dTable[row][col]

            if tileId ~= 0 then
                -- Render the tile and set its position
                local tile = display.newImageRect(mainGroup, objectSheet, tileId, tileWidth, tileHeight)

                if tileId >= 6 then
                    dimonds[#dimonds+1] = {tile, row, col, tileId, 5} -- display obj, row, col, tileId, rocks
                    levelTiles[row][col] = 0
                  --  tile = display.newImageRect(dimondGroup, objectSheet, tileId, tileWidth, tileHeight)
                end

                tile.x = tileX
                tile.y = tileY
            end
            
        end
    end
end

renderTilesToScreen(levelTiles)

function removeDimond(index)
    -- no need since levelTiles[row][col] = 0
    display.remove(dimonds[index][1])
    table.remove(dimonds, index) -- table, index
end

function moveDimond(index, newRow, newCol)
    local newX = map_x + (newCol - 1) * tileWidth
    local newY = map_y + (newRow - 1) * tileHeight

    -- Check if id is 7 and only allow 5 rocks to spawn
    if dimonds[index][5] > 0 and dimonds[index][4] == 7 then
        dimonds[index][5] = dimonds[index][5] - 1

        local tile = display.newImageRect(mainGroup, objectSheet, 1, tileWidth, tileHeight)
        tile.x = dimonds[index][1].x
        tile.y = dimonds[index][1].y
        -- Set levelTiles row and col to 1 to enable collisions
        local row = (tile.y - map_y) / tileHeight + 1
        local col = (tile.x - map_x) / tileWidth + 1
        levelTiles[row][col] = 1        
    end

    dimonds[index][1].x = newX
    dimonds[index][1].y = newY
end

-- when all dimonds have been collected i.e. the #dimonds == 0 level is complete

-- 6 blue dimond
-- 7 green dimond 
-- 8 red dimond