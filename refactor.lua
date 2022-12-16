function adjustSegmentGraphic(row, col)
    local spriteIndex = 1

    -- check previous segment
    if #segments > 1 then
        local lastSegment = segments[#segments]
        local lastRow = lastSegment[3] -- row value of the last segment
        local lastCol = lastSegment[2] -- col value of the last segment

        -- Check penulitmate segment to adjust the last segment
        local penultimateSegment = segments[#segments - 1]
        local penultimateRow = penultimateSegment[3]
        local penultimateCol = penultimateSegment[2]
        local newLastSegmentGraphic = 2


        if lastRow == row then
            spriteIndex = 2
            -- if penultimate segment is above set sprite index of last segment
            if penultimateRow < lastRow and lastCol < col then
                newLastSegmentGraphic = 3
            elseif penultimateRow < lastRow and lastCol > col then
                newLastSegmentGraphic = 4

            elseif penultimateRow > lastRow and lastCol < col then
                newLastSegmentGraphic = 6
            elseif penultimateRow > lastRow and lastCol > col then
                newLastSegmentGraphic = 5
            end

        
        elseif lastRow ~= row then
            -- if moved up and right
            if row < lastRow and lastCol < penultimateCol then
                newLastSegmentGraphic = 3
            elseif row < lastRow and lastCol > penultimateCol then
                newLastSegmentGraphic = 4
            end

            -- if the row is biger i.e. if moved down last segment is horizontal 
            if lastSegment[6] == 2 and penultimateCol < lastCol and row > lastRow then
                newLastSegmentGraphic = 5
            elseif lastSegment[6] == 2 and penultimateCol > lastCol and row > lastRow then
                newLastSegmentGraphic = 6
            end

        end
        -- Change graphic for the last tile
        local lastTileGraphic =
            display.newImageRect(mainGroup, chainSheet, newLastSegmentGraphic, tileWidth, tileHeight)
        lastTileGraphic.x = segments[#segments][4]
        lastTileGraphic.y = segments[#segments][5]
        display.remove(segments[#segments][1])
        segments[#segments][1] = lastTileGraphic
    end

    return spriteIndex

end
