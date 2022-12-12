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
                tile.x = tileX
                tile.y = tileY
            end
            
        end
    end

end

renderTilesToScreen(levelTiles)
