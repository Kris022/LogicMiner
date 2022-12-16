local composer = require("composer")

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- Game Display Groups
-- -----------------------------------------------------------------------------------
local mainGroup
local uiGroup -- Display group for UI objects like the score

-- -----------------------------------------------------------------------------------
-- Game Map Loader module
-- -----------------------------------------------------------------------------------
local tileMap

if composer.getVariable("one") then
    tileMap = require "maps.mine1"
elseif composer.getVariable("two") then
    tileMap = require "maps.mine2"
elseif composer.getVariable("three") then
    tileMap = require "maps.mine3"
end

local sheetOptions = {
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
    }, { -- 6) blue dimond
        x = 32,
        y = 60,
        width = 32,
        height = 30
    }, { -- 7) green dimond
        x = 0,
        y = 90,
        width = 32,
        height = 30
    }, { -- 8) red dimond
        x = 32,
        y = 90,
        width = 32,
        height = 30
    }}
}
local objectSheet = graphics.newImageSheet("images/tiles2.png", sheetOptions)

local levelTiles = tileMap["layers"][1]["data"] -- 1D table storing tile values
-- Number of rows and tables the tile map has
local mapRows = tileMap["layers"][1]["height"]
local mapCols = tileMap["layers"][1]["width"]
-- Individual Tile Size
local tileWidth = tileMap["tilewidth"]
local tileHeight = tileMap["tileheight"]

local map_x = 0
local map_y = 0

local dimonds

local function convert1dTo2d(input)
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

local function renderTilesToScreen(input2dTable)

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
                    dimonds[#dimonds + 1] = {tile, row, col, tileId, 6} -- display obj, row, col, tileId, rocks
                    levelTiles[row][col] = 0
                    --  tile = display.newImageRect(dimondGroup, objectSheet, tileId, tileWidth, tileHeight)
                end

                tile.x = tileX
                tile.y = tileY
            end

        end
    end
end

-- -----------------------------------------------------------------------------------
-- Dimond modules
-- -----------------------------------------------------------------------------------
local function removeDimond(index)
    display.remove(dimonds[index][1])
    table.remove(dimonds, index) -- table, index
end

local function moveDimond(index, newRow, newCol)
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

-- -----------------------------------------------------------------------------------
-- Chain modules
-- -----------------------------------------------------------------------------------
local chainOptions = {
    frames = {{ -- 1) vertical
        x = 0,
        y = 0,
        width = 32,
        height = 30
    }, { -- 2) horizontal
        x = 32,
        y = 0,
        width = 32,
        height = 30
    }, { -- 3) vertical L
        x = 0,
        y = 32,
        width = 32,
        height = 30
    }, { -- 4) vertical inverse L
        x = 32,
        y = 32,
        width = 32,
        height = 30
    }, { -- 5) horizontal L
        x = 0,
        y = 60,
        width = 32,
        height = 30
    }, { -- 6) horizontal inverse L
        x = 32,
        y = 60,
        width = 32,
        height = 30
    }}
}

local chainSheet = graphics.newImageSheet("images/chain.png", chainOptions)

local segments
local dir
local isReturning
local hookedDimond

local maxSegments = 30
local segmentsText

local function setDir(newX, newY)
    dir.x = newX
    dir.y = newY
end

local function addSegment(row, col)
    -- (next) row = y, (next) col = x
    local tileX = map_x + (col - 1) * tileWidth
    local tileY = map_y + (row - 1) * tileHeight

    -- Adapt segment graphic
    local spriteIndex = 1
    -- check previous segment
    if #segments > 1 then
        local lastSegment = segments[#segments]
        local lastRow = lastSegment[3] -- row value of the last segment
        local lastCol = lastSegment[2] -- col value of the last segment

        if lastRow == row then
            spriteIndex = 2

            -- Check penulitmate segment to adjust the last segment
            local penultimateSegment = segments[#segments - 1]
            local penultimateRow = penultimateSegment[3]
            local penultimateCol = penultimateSegment[2]
            local newLastSegmentGraphic = 2

            -- if penultimate segment is above set sprite index of last segment to 3 = L
            if penultimateRow < lastRow and lastCol < col then
                newLastSegmentGraphic = 3

            elseif penultimateRow < lastRow and lastCol > col then
                newLastSegmentGraphic = 4
            elseif penultimateRow > lastRow and lastCol < col then
                newLastSegmentGraphic = 6
            elseif penultimateRow > lastRow and lastCol > col then
                newLastSegmentGraphic = 5
            end
            -- Change graphic for the last tile
            local lastTileGraphic = display.newImageRect(mainGroup, chainSheet, newLastSegmentGraphic, tileWidth,
                tileHeight)
            lastTileGraphic.x = segments[#segments][4]
            lastTileGraphic.y = segments[#segments][5]

            display.remove(segments[#segments][1])
            segments[#segments][1] = lastTileGraphic

        elseif lastRow ~= row then
            local penultimateSegment = segments[#segments - 1]
            local penultimateRow = penultimateSegment[3]
            local penultimateCol = penultimateSegment[2]
            local newLastSegmentGraphic = 1

            -- if moved up
            if row < lastRow and lastCol < penultimateCol then
                newLastSegmentGraphic = 3
            elseif row < lastRow and lastCol > penultimateCol then
                newLastSegmentGraphic = 4
            end

            -- if the row is biger i.e. if moved down last segment is horizontal 
            if penultimateCol < lastCol and row > lastRow then
                newLastSegmentGraphic = 5
            elseif penultimateCol > lastCol and row > lastRow then
                newLastSegmentGraphic = 6

            end
            -- Change graphic for the last tile
            local lastTileGraphic = display.newImageRect(mainGroup, chainSheet, newLastSegmentGraphic, tileWidth,
                tileHeight)
            lastTileGraphic.x = segments[#segments][4]
            lastTileGraphic.y = segments[#segments][5]
            display.remove(segments[#segments][1])
            segments[#segments][1] = lastTileGraphic

        end
    end

    local tile = display.newImageRect(mainGroup, chainSheet, spriteIndex, tileWidth, tileHeight)
    tile.x = tileX
    tile.y = tileY

    segments[#segments + 1] = {tile, col, row, tile.x, tile.y, spriteIndex}
    levelTiles[row][col] = "s"
end

local function goToWinScreen()
    composer.gotoScene("winScene", {
        time = 800,
        effect = "crossFade"
    })
end

local function removeLastSegment()
    local lastSegment = segments[#segments]
    local lastRow = lastSegment[3] -- row value of the last segment
    local lastCol = lastSegment[2] -- col value of the last segment

    if hookedDimond ~= nil then
        -- Move dimond with the chain
        moveDimond(hookedDimond, lastRow, lastCol)
        -- Check if dimond has reached collection point
        if lastRow == 2 and lastCol == 10 then
            -- remove dimond and increment score
            if dimonds[hookedDimond][4] == 8 then
                maxSegments = maxSegments - 5
            end

            removeDimond(hookedDimond)
            hookedDimond = nil

            -- Check if all dimonds have been collected   
            if #dimonds == 0 then
                goToWinScreen()
            end

        end
    end

    -- change last segment tile back to 0
    levelTiles[lastRow][lastCol] = 0
    -- Remove last segment
    display.remove(segments[#segments][1])
    table.remove(segments, #segments)

    if #segments == 1 then
        isReturning = false
    end
    segmentsText.text = (#segments-1).."/"..maxSegments

end

local function returnToStart()
    -- Disable button while this is happening
    if #segments > 1 then
        timer.performWithDelay(200, removeLastSegment, #segments - 1)
        -- re-enable after this
    end
end

local function manageSegments()
    -- Get the row and col values of the last segment
    local lastSegment = segments[#segments]
    local lastRow = lastSegment[3] -- row value of the last segment
    local lastCol = lastSegment[2] -- col value of the last segment

    -- Compute where the next segment will be
    local nextRow = lastRow + dir.y
    local nextCol = lastCol + dir.x

    -- Do not allow player to move out of bounds
    if nextRow > 1 and not isReturning and hookedDimond == nil then

        -- check if dimond is attached to the chain
        for i in ipairs(dimonds) do
            if dimonds[i][2] == nextRow and dimonds[i][3] == nextCol then
                hookedDimond = i
            end
        end

        -- Check if new segment can be inserted at the position
        if levelTiles[nextRow][nextCol] == 0 and  #segments <= maxSegments then
            -- If position is valid
            addSegment(nextRow, nextCol)

            -- Check if player tried to remove last inserted segment
        elseif levelTiles[nextRow][nextCol] == "s" then
            -- Get penulitmate values
            local penultimateSegment = segments[#segments - 1]
            local penultimateRow = penultimateSegment[3]
            local penultimateCol = penultimateSegment[2]

            -- Check if penultimate segment equals next segment to be inserted
            if penultimateRow == nextRow and penultimateCol == nextCol then
                removeLastSegment()
            end

        end

    end
    segmentsText.text = (#segments-1).."/"..maxSegments

end

-- -----------------------------------------------------------------------------------
-- User Interface Modules
-- -----------------------------------------------------------------------------------
local uiOptions = {
    frames = {{ -- 1) right
        x = 0,
        y = 0,
        width = 64,
        height = 64
    }, { -- 2) down
        x = 64,
        y = 0,
        width = 64,
        height = 64
    }, { -- 3) left
        x = 0,
        y = 64,
        width = 64,
        height = 64
    }, { -- 4) up
        x = 64,
        y = 64,
        width = 64,
        height = 64
    }, { -- 5) snag button
        x = 0,
        y = 64 + 168,
        width = 104,
        height = 104
    }}
}

local uiSheet = graphics.newImageSheet("images/uiButtons2.png", uiOptions)

local groupBounds
local groupRegion

local upButton
local downButton
local leftButton
local rightButton
local snagButton

local resetButton

local function detectButton(event)
    for i = 1, uiGroup.numChildren do
        local bounds = uiGroup[i].contentBounds
        if (event.x > bounds.xMin and event.x < bounds.xMax and event.y > bounds.yMin and event.y < bounds.yMax) then
            return uiGroup[i]
        end
    end
end

local function handleController(event)

    local touchOverButton = detectButton(event)

    if (event.phase == "began") then

        if (touchOverButton ~= nil) then
            if not (uiGroup.touchID) then
                -- Set/isolate this touch ID
                uiGroup.touchID = event.id
                -- Set the active button
                uiGroup.activeButton = touchOverButton

                if (uiGroup.activeButton.ID == "left") then
                    setDir(-1, 0)
                elseif (uiGroup.activeButton.ID == "right") then
                    setDir(1, 0)
                elseif (uiGroup.activeButton.ID == "up") then
                    setDir(0, -1)
                elseif (uiGroup.activeButton.ID == "down") then
                    setDir(0, 1)
                elseif (uiGroup.activeButton.ID == "snag") and not isReturning and #segments > 1 then
                    isReturning = true
                    returnToStart()
                end

            end
            return true
        end

    elseif (event.phase == "moved") then

        -- Handle slide off
        if (touchOverButton == nil and uiGroup.activeButton ~= nil) then
            event.target:dispatchEvent({
                name = "touch",
                phase = "ended",
                target = event.target,
                x = event.x,
                y = event.y
            })
            return true
        end

    elseif (event.phase == "ended" and uiGroup.activeButton ~= nil) then

        if uiGroup.activeButton.ID ~= "snag" then
            -- Add the segment after release
            manageSegments()
        end

        -- Release this touch ID
        uiGroup.touchID = nil
        -- Set that no button is active
        uiGroup.activeButton = nil

        return true
    end
end

local function gotoGame()
    composer.gotoScene("menu", {
        time = 800,
        effect = "crossFade"
    })
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)

    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    local background = display.newImageRect(sceneGroup, "images/background1.png", 1400, 800)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    mainGroup = display.newGroup()
    sceneGroup:insert(mainGroup)
    uiGroup = display.newGroup()
    sceneGroup:insert(uiGroup)

    upButton = display.newImageRect(uiGroup, uiSheet, 4, 64, 64)
    upButton.x = 64 * 1.5
    upButton.y = 64 * 5.5
    upButton.ID = "up"

    downButton = display.newImageRect(uiGroup, uiSheet, 2, 64, 64)
    downButton.x = 64 * 1.5
    downButton.y = 64 * 6.5
    downButton.ID = "down"

    leftButton = display.newImageRect(uiGroup, uiSheet, 3, 64, 64)
    leftButton.x = 64 * 0.5
    leftButton.y = 64 * 6
    leftButton.ID = "left"

    rightButton = display.newImageRect(uiGroup, uiSheet, 1, 64, 64)
    rightButton.x = 64 * 2.5
    rightButton.y = 64 * 6
    rightButton.ID = "right"

    snagButton = display.newImageRect(uiGroup, uiSheet, 5, 104, 104)
    snagButton.x = 64 * 1.65
    snagButton.y = 64 * 3.5
    snagButton.ID = "snag"

    segmentsText = display.newText(uiGroup, "0/" .. maxSegments, 32, 128, native.systemFont, 21)
    segmentsText:setFillColor(255, 255, 255)

    resetButton = display.newText(sceneGroup, "Exit", 32, 64, native.systemFont, 44)
    resetButton:setFillColor(0.82, 0.86, 1)

end

-- show()
function scene:show(event)

    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        groupBounds = uiGroup.contentBounds
        groupRegion = display.newRect(0, 0, groupBounds.xMax - groupBounds.xMin + 200,
            groupBounds.yMax - groupBounds.yMin + 200)
        groupRegion.x = groupBounds.xMin + (uiGroup.contentWidth / 2)
        groupRegion.y = groupBounds.yMin + (uiGroup.height / 2)
        groupRegion.isVisible = false
        groupRegion.isHitTestable = true

        levelTiles = convert1dTo2d(levelTiles)

        dimonds = {}
        segments = {}

        dir = {
            x = 0,
            y = 0
        }

        isReturning = false

        renderTilesToScreen(levelTiles)

        addSegment(1, 10)

    elseif (phase == "did") then
        -- Code here runs when the scene is entirely on screen

        groupRegion:addEventListener("touch", handleController) -- Only detect after scene loaded
        resetButton:addEventListener("tap", gotoGame)

    end
end

-- hide()
function scene:hide(event)

    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Code here runs when the scene is on screen (but is about to go off screen)

    elseif (phase == "did") then
        -- Code here runs immediately after the scene goes entirely off screen
        groupRegion:removeEventListener("touch", handleController)
        resetButton:removeEventListener("tap", gotoGame)
        composer.removeScene("game")
    end
end

-- destroy()
function scene:destroy(event)

    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view

end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
-- -----------------------------------------------------------------------------------

return scene
