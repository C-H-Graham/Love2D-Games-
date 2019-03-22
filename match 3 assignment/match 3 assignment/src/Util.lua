--[[
    -- StartState Class --

    Helper functions for writing Match-3.
]]

--[[
    Given an "atlas" (a texture with multiple sprites), generate all of the
    quads for the different tiles therein, divided into tables for each set
    of tiles, since each color has 6 varieties.
]]
function GenerateTileQuads(atlas)
    -- tiles are an array of tables, corresponding to the colors 
    local tiles = {}
    --  {1 = {}, 2 = {}, 3 = {} , 4 = {}, 5 = {}, 6 = {}, 7 = {}, 8 = {}, 
    --    9 = {}, 10 = {}, 11 = {}, 12 = {}, 13 = {}, 14 = {}, 15 = {}, 16 = {}, 17 = {}, 18 = {}}

    -- Table with keys equal to color as keyed 
    --[[ local color = { 1 = 'yellow', 3 = 'mustard', 5 = 'forest', 7 = 'green', 9 = 'lime', 
        11 = 'sky', 13 = 'blue', 15 = 'dark purple', 17 = 'purple', 2 = 'pink', 4 = 'peach', 
        6 = 'red', 8 = 'brick', 10 = 'tan', 12 = 'orange', 14 = 'lgray', 16 = 'gray', 18 = 'dgray' }
    ]]
    local color = {'yellow', 'pink', 'mustard', 'peach', 'forest', 'red', 'green', 'brick', 'lime', 
        'tan', 'sky', 'orange', 'blue', 'lgray', 'dark purple', 'gray', 'purple', 'dgray'}
    --[[ For each color table in the tiles table:
        - 1 is flat
        - 2 is cross or 'X'
        - 3 is circle
        - 4 is square
        - 5 is triangle
        - 6 is star
    ]]
    local x = 0
    local y = 0

    local counter = 1

    -- 9 rows of tiles
    for row = 1, 9 do
        
        -- two sets of 6 cols, different tile varietes
        for i = 1, 2 do
            tiles[counter] = {}
            
            for col = 1, 6 do
                table.insert(tiles[counter], love.graphics.newQuad(
                    x, y, 32, 32, atlas:getDimensions()
                ))
                x = x + 32
            end

            counter = counter + 1
        end
        y = y + 32
        x = 0
    end

    return tiles
end



--[[
    Recursive table printing function.
    https://coronalabs.com/blog/2014/09/02/tutorial-printing-table-contents/
]]
function print_r ( t )
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end