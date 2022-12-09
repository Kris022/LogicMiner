local lvl = require "mine2"

-- Load the background
background = display.newImageRect(backGroup, "images/background1.png", 1400, 800)
background.x = display.contentCenterX
background.y = display.contentCenterY

-- Configure image sheet
sheetOptions = {
    frames = {{ -- 1) up wall
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
    }}
}
objectSheet = graphics.newImageSheet("images/tiles.png", sheetOptions)

lvl_size = {
    width = lvl["layers"][1]["width"],
    height = lvl["layers"][1]["height"]
}
lvl_tiles = lvl["layers"][1]["data"] -- level tiles

mapRows = lvl["layers"][1]["height"]
mapCols = lvl["layers"][1]["width"]

local x = 0
local y = 1
-- render map
for i in ipairs(lvl_tiles) do
    if x == mapCols then
        x = 0
        y = y + 1
    end
    if lvl_tiles[i] ~= 0 then
        local tile = display.newImageRect(mainGroup, objectSheet, lvl_tiles[i], 32, 30)
        tile.x = x * 32
        tile.y = y * 30
    end
    x = x + 1
end
