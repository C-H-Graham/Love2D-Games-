--[[
    -- Board Class --

    The Board is our arrangement of Tiles with which we must try to find matching
    sets of three horizontally or vertically.
]]

Board = Class{}

function Board:init(x, y, level)
    self.x = x
    self.y = y
    self.matches = {}
    self.level = level or 1
    if self.level < 8 then 
        self.variety =  1
    elseif self.level < 15 then 
        self.variety = self.level - 8

    else 
        self.variety = 6
    end
    self:initializeTiles()
end

function Board:initializeTiles()
    self.tiles = {}
    if self.level < 13 then 
        self.color = self.level + 4
    else
        self.color = 18
    end
    for tileY = 1, 8 do
        
        -- empty table that will serve as a new row
        table.insert(self.tiles, {})

        for tileX = 1, 8 do
            
            -- create a new tile at X,Y with a random color and variety
            -- doing math.random at self.level should allow only flat objects in the first level
            table.insert(self.tiles[tileY], Tile(tileX, tileY, math.random(self.color), math.random(self.variety)))
        end
    end

   -- while self:calculateMatches() do
        
        -- recursively initialize if matches were returned so we always have
        -- a matchless board on start
        --self:initializeTiles()
    --end
    if (not self:canMatch()) or self:calculateMatches() then 
        self:initializeTiles()
    end

    --[[
    -- If you cannot match, then 
    isHorizontal = math.random(1,2)
    -- Is a Horizontal Pattern
    if (isHorizontal ==1) then 
        patternXLength = math.random(3,4)
        if (patternXLength == 4) then 
            patternYLength = 1
            self:insertPossibleMatch(isHorizontal, patternYLength, patternXLength, math.random(self.color))
        else
            patternYLength = 2
            self:insertPossibleMatch(isHorizontal, patternYLength, patternXLength, math.random(self.color))
        end
    -- Is a Vertical Pattern
    else
        patternYLength = math.random(3,4)
        if (patternYLength == 4) then 
            patternXLength = 1
            self:insertPossibleMatch(isHorizontal, patternYLength, patternXLength, math.random(self.color))
        else
            patternXLength = 2
            self:insertPossibleMatch(isHorizontal, patternYLength, patternXLength, math.random(self.color))
        end
    end
    ]]

end

--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the 
    last two haven't been a match.
]]
function Board:calculateMatches()
    local matches = {}

    -- how many of the same color blocks in a row we've found
    local matchNum = 1

    -- Table of rows that contain a shiny tile that is matched
    local shinyMatchRows = {}

    -- horizontal matches first
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color
        local symbolToMatch = self.tiles[y][1].variety
        matchNum = 1
        
        -- every horizontal tile
        for x = 2, 8 do
            
            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].color == colorToMatch or (self.level > 7 and symbolToMatch == self.tiles[y][x].variety) then
                matchNum = matchNum + 1
            else
                
                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color
                symbolToMatch = self.tiles[y][x].variety

                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then
                    local match = {}

                    -- go backwards from here by matchNum
                    for x2 = x - 1, x - matchNum, -1 do

                        -- add each tile to the match that's in that match
                        table.insert(match, self.tiles[y][x2])

                        if self.tiles[y][x2].isShiny then 
                            table.insert(shinyMatchRows, self.tiles[y][x2].gridY)
                        end
                    end

                    -- add this match to our total matches table
                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= 3 then
            local match = {}
            
            -- go backwards from end of last row by matchNum
            for x = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
                if self.tiles[y][x].isShiny then 
                    table.insert(shinyMatchRows, self.tiles[y][x].gridY)
                end
            end

            table.insert(matches, match)
        end
    end

    -- vertical matches
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color
        local symbolToMatch = self.tiles[1][x].variety
        matchNum = 1

        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch or (self.level > 7 and symbolToMatch == self.tiles[y][x].variety) then
                matchNum = matchNum + 1
            else
                colorToMatch = self.tiles[y][x].color

                if matchNum >= 3 then
                    local match = {}

                    for y2 = y - 1, y - matchNum, -1 do
                        table.insert(match, self.tiles[y2][x])
                        if self.tiles[y2][x].isShiny then 
                            table.insert(shinyMatchRows, self.tiles[y2][x].gridY)
                        end
                    end

                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            local match = {}
            
            -- go backwards from end of last row by matchNum
            for y = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
                if self.tiles[y][x].isShiny then 
                    table.insert(shinyMatchRows, self.tiles[y][x].gridY)
                end
            end

            table.insert(matches, match)
        end
    end

    --if shinyMatchRows isn't nil
    if shinyMatchRows ~= nil then 
        -- iterate through shinyMatchRows to add all tiles in that row [y] to matches
        local match = {}
        for i=1, #shinyMatchRows do
            for x=1, 8 do 
                table.insert(match, self.tiles[shinyMatchRows[i]][x] )
            end
            table.insert(matches, match)
        end
    end
    --[[
    for k, match in pairs(matches) do
        for j, tile in pairs(match) do 
            -- if tile is shiny then add its row to shinyMatch rows so that entire row 
            --can be added to matches
            if tile.isShiny then 
                table.insert(shinyMatchRows, tile.gridY)
            end
        end
    end
    ]]

    -- store matches for later reference
    self.matches = matches
    -- return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end

--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
function Board:getFallingTiles()
    -- tween table, with tiles as keys and their x and y as the to values
    local tweens = {}

    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            
            -- if our last tile was a space...
            local tile = self.tiles[y][x]
            
            if space then
                
                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then
                    
                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY

                    -- set this back to 0 so we know we don't have an active space
                    spaceY = 0
                end
            elseif tile == nil then
                space = true
                
                -- if we haven't assigned a space yet, set this to it
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then

                -- new tile with random color and variety
                local tile = Tile(x, y, math.random(self.color), math.random(self.variety))
                tile.y = -32
                self.tiles[y][x] = tile

                -- create a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end 

        end
    end

    return tweens
end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end
end

-- function used to check if a tile can be swapped in any valid direction
-- and create a match, if possible returns true
-- uses tiles
function Board:canMatch()
    local isMatchable = false
    --[[
        // Reset moves
        moves = []
 
        // Check horizontal swaps
        for (var j=0; j<level.rows; j++) {
            for (var i=0; i<level.columns-1; i++) {
                // Swap, find clusters and swap back
                swap(i, j, i+1, j);
                findClusters();
                swap(i, j, i+1, j);
 
                // Check if the swap made a cluster
                if (clusters.length > 0) {
                    // Found a move
                    moves.push({column1: i, row1: j, column2: i+1, row2: j});
                }
            }
        }
 
        // Check vertical swaps
        for (var i=0; i<level.columns; i++) {
            for (var j=0; j<level.rows-1; j++) {
                // Swap, find clusters and swap back
                swap(i, j, i, j+1);
                findClusters();
                swap(i, j, i, j+1);
 
                // Check if the swap made a cluster
                if (clusters.length > 0) {
                    // Found a move
                    moves.push({column1: i, row1: j, column2: i, row2: j+1});
                }
            }
        }
    ]]

    -- Horizontal Matches
    for y=1, 8, 1 do 
        for x=1, 7, 1 do
            self:swapTiles(self.tiles[y][x], self.tiles[y][x+1])
            self:calculateMatches()
            self:swapTiles(self.tiles[y][x+1], self.tiles[y][x])

            --Did the swap make a match
            if(#self.matches > 0) then 
                return true
            end


        end
    end 
    -- Vertical Matches
    for y=1, 8, 1 do
        for x=1, 8, 1 do
            self:swapTiles(self.tiles[y][x], self.tiles[y +1][x])
            self:calculateMatches()
            self:swapTiles(self.tiles[y+1][x], self.tiles[y][x])

            --Did the swap make a match
            if(#self.matches > 0) then 
                return true
            end
        end
    end

    return false
end

function Board:insertPossibleMatch(horizontal,Ylength, XLength, tileColor )
--[[    look for specific match 3 pattens
    -- x= any color
    -- c= color we are checking
    --1. c x c | 2. c c x c
    --   x c x |
    ------------------------  
    --3. x c c | 4. c x x
    --   c x x |    x c c
    -----------------------
    --5. x c x | 6. c x c c
    --   c x c |
    ------------------------
    --7. x x c | 8. c c x
    --   c c x |    x x c
    -------------------------
    --9. c     | 10. c
    --   x     |     c
    --   c     |     x 
    --   c     |     c
    ------------------------
    --11.x c   | 12.  c x
    --   x c   |      c x
    --   c x   |      x c
    ------------------------
    --12. c x  | 13. x c
    --`   x c  |     c x
          c x  |     x c
    --------------------------            
      14. c x  | 15.   x c
          x c  |       c x
          x c  |       c x

    Create 3d array of these patterns
    
    -- Initiate the table
    ]]
    if (horizontal) then 

    end
    --table.insert(self.tiles[tileY], Tile(tileX, tileY, math.random(self.color), math.random(self.variety)))
    --find a start index for y
    --tileXStart = math.random(8-patternXLength)
    --tileYStart = math.random(8-patternYLength)
    --find a start index for x
    xCount = 0
    YCount = 0
    lastXNull = false 
    lastYNull = true 

    for startYIndex = math.random(8-YLength), 8,1 do
        if (YCount < YLength) then
            for startXIndex = math.random(8-XLength), 8, 1 do
                if (xCount < XLength) then
                    table.insert(self.tiles[startYIndex], startXIndex, Tile(startYIndex, startXIndex, tileColor, math.random(self.variety)))
                    xCount = xCount + 1
                else
                    break
                end
            end
        else
            break
        end

    end
    -- Tile:init(x, y, color, variety, isShiny)

    return true
end

function Board:swapTiles(tile1, tile2) 
    local tempX = tile1.gridX
    local tempY = tile1.gridY

    tile1.gridX = tile2.gridX
    tile1.gridY = tile2.gridY
    tile2.gridX = tempX
    tile2.gridY = tempY

    self.tiles[tile1.gridY][tile1.gridX] = tile1
    self.tiles[tile2.gridY][tile2.gridX] = tile2
end

