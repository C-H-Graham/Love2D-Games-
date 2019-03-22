--[[ 


]]

Powerup = Class{}

function Powerup:init(x, y, ptype)
	-- positional variables to track our placement and where it spawns
	self.x = x
	self.y = y

	-- the type of powerup created
	self.typeTable = {[1] ='key', [2] = 'newball'}
	self.type =  ptype or self.typeTable[math.random(1, #self.typeTable)]
	-- variables to track of the velocity on both x and y axis as it floats downward.
	self.dx = 0
	self. dy = 0

	self.inPlay = true

	-- dimensional variabes of sprites
	self.width = 16
	self.height = 16
	self.inplay = true
end

-- Similar to the Balls collides function but used to only track against the player to see 
-- if they receive the Powerup
function Powerup:collides(target)
    -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
	if self.x > target.x + target.width or target.x > self.x +self.width then
		return false
	end
    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
	if self.y > target.y + target.height or target.y > self.y + self.height then
		return false 
	end
	self.inPlay = false
	return true
end

function Powerup:update(dt)
	self.x = self.x + self.dx * dt 
    self.y = self.y + self.dy * dt

    -- allow ball to bounce off walls
    if self.x <= 0 then
        self.x = 0
        self.dx = -self.dx
        gSounds['wall-hit']:play()
    end

    if self.x >= VIRTUAL_WIDTH - 8 then
        self.x = VIRTUAL_WIDTH - 8
        self.dx = -self.dx
        gSounds['wall-hit']:play()
    end

    if self.y <= 0 then
        self.y = 0 
        self.dy = -self.dy
        gSounds['wall-hit']:play()
    end
end
function Powerup:reset()
    self.x = VIRTUAL_WIDTH / 2 
    self.y = VIRTUAL_HEIGHT / 2 
    self.dx = 0
    self.dy = 0
    self.inPlay = false
end

function Powerup:render()
	if self.inPlay then
		love.graphics.draw(gTextures['main'], gFrames['powerups'][self.type], 
			self.x, self.y)
	end
end

function Powerup:effect(balls, ball_no, paddle)
	--[[ commented out attempt at making a table of functions for a makeshift switch
	-- statement. It didn't word likely because during initialization it needs to run all of thesew 
	actions = {
		['newball'] = Powerup:newball(balls, ball_no, paddle),
		['key'] = Powerup:key(paddle) 
	}

	return actions[self.type] ]]
	if self.type == 'key' then 
		Powerup:key(paddle)
	elseif self.type == 'newball' then 
		Powerup:newball(balls, ball_no, paddle)
	end
end
function Powerup:newball(balls, ball_no, paddle)

	for i = 1, 2 do 
        ball_no = ball_no + 1
        balls[ball_no] = Ball()
        balls[ball_no].skin = math.random(7)
        balls[ball_no].dx = math.random(-200, 200)
        balls[ball_no].dy = math.random(-50, -60)
        balls[ball_no].x = paddle.x 
        balls[ball_no].y = paddle.y - 8
    end
    self.inPlay = false    

end

function Powerup:key(paddle)
	--sets flag of paddle (player) to true
	paddle.hasKey = true
end