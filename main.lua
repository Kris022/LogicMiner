-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
-- Your code here
local lvl = require "mine2"

-- Set up display groups
local backGroup = display.newGroup() -- Display group for the background image
local mainGroup = display.newGroup() -- Display group for the ship, asteroids, lasers, etc.
local uiGroup = display.newGroup() -- Display group for UI objects like the score

-- Load the background
local background = display.newImageRect(backGroup, "images/background1.png", 1400, 800)
background.x = display.contentCenterX
background.y = display.contentCenterY

-- Configure image sheet
local sheetOptions = {
    frames = {{ -- 1) asteroid 1
        x = 0,
        y = 0,
        width = 32,
        height = 30
    }, { -- 2) asteroid 2
        x = 32,
        y = 0,
        width = 32,
        height = 30
    }, { -- 3) asteroid 3
        x = 0,
        y = 30,
        width = 32,
        height = 30
    }, { -- 4) ship
        x = 32,
        y = 30,
        width = 32,
        height = 30
    }}
}

local objectSheet = graphics.newImageSheet( "images/tiles.png", sheetOptions )

local lvl_size = {width = lvl["layers"][1]["width"], height = lvl["layers"][1]["height"]}

local lvl_tiles = lvl["layers"][1]["data"] -- level tiles

mapRows = lvl["layers"][1]["height"] 
mapCols = lvl["layers"][1]["width"] 

x = 0 
y = 1

for i in ipairs(lvl_tiles) do
    if x == mapCols then
        x = 0
        y = y + 1
    end
    if lvl_tiles[i] ~= 0 then
        local tile = display.newImageRect( mainGroup, objectSheet, 1, 32, 30 )
        tile.x = x * 32
        tile.y = y * 30
    end
    x = x + 1
end