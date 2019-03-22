--[[
    -- Tile Class --

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

function Tile:init(x, y, color, variety, isShiny)
    
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety

    -- flag to render tile as being a rare shiny tile
    self.rare = math.random(1, 20)
    self.isShiny = isShiny or false 
    if isShiny == nil and self.rare >= 19 then 
            self.isShiny = true
    end
end

function Tile:render(x, y)
    
    -- draw shadow
    love.graphics.setColor(34, 32, 52, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)

    -- draw shiny shader/rectangle over object if it is shiny
    if self.isShiny then 
        love.graphics.setBlendMode('add')
        love.graphics.setColor(255, 255, 255, 40)
        love.graphics.rectangle('fill', (self.gridX - 1) * 32 + (VIRTUAL_WIDTH - 272),
            (self.gridY - 1) * 32 + 16, 32, 32, 4)

        -- back to alpha
        love.graphics.setBlendMode('alpha')
    end
end