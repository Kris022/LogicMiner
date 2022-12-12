uiOptions = {
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

uiSheet = graphics.newImageSheet("images/uiButtons2.png", uiOptions)

-- Button Images
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

local groupBounds = uiGroup.contentBounds
local groupRegion = display.newRect(0, 0, groupBounds.xMax - groupBounds.xMin + 200,
    groupBounds.yMax - groupBounds.yMin + 200)
groupRegion.x = groupBounds.xMin + (uiGroup.contentWidth / 2)
groupRegion.y = groupBounds.yMin + (uiGroup.height / 2)
groupRegion.isVisible = false
groupRegion.isHitTestable = true

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
                elseif (uiGroup.activeButton.ID == "snag") then
                    --timer.performWithDelay( 1000, removeLastSegment, 2 )
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

groupRegion:addEventListener("touch", handleController)
