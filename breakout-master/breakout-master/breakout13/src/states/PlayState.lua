--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.ball = params.ball
    self.level = params.level

    self.recoverPoints = params.recorverPoints or 5000
    self.PowerPoints = params.PowerPoints or 2500
    self.sizePoints = params.sizePoints or 1000
    -- Number of balls in play. Default is one from Serve State
    self.powerUp = Powerup(0, 0)
    self.powerUp.inPlay = false

    self.balls = {}
    self.balls[1] = self.ball
    self.ball_no = 1
    -- give ball random starting velocity
    self.ball.dx = math.random(-200, 200)
    self.ball.dy = math.random(-50, -60)
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)
    --if powerup is in play update
    if self.powerUp.inPlay then
        self.powerUp:update(dt)
        -- if it goes out of bounds make the powerUp invisible and reset position
        if self.powerUp.y >= VIRTUAL_HEIGHT then
            self.powerUp:reset()
        end
    end
    -- newball takes effect, spawns 2 new balls
    if self.powerUp.inPlay and self.powerUp:collides(self.paddle) then
        --[[ Commented out code for new ball
        for i = 1, 2 do 
            self.ball_no = self.ball_no + 1
            self.balls[self.ball_no] = Ball()
            self.balls[self.ball_no].skin = math.random(7)
            self.balls[self.ball_no].dx = math.random(-200, 200)
            self.balls[self.ball_no].dy = math.random(-50, -60)
            self.balls[self.ball_no].x = self.paddle.x 
            self.balls[self.ball_no].y = self.paddle.y - 8
        end
            self.powerUp.inPlay = false
            ]]
        self.powerUp:effect(self.balls, self.ball_no, self.paddle)
        if self.powerUp.type == 'newball' then
            self.ball_no = self.ball_no + 2
        end
    end

    --self.ball:update(dt)
    -- update all balls in play
    for i = 1, self.ball_no  do
        self.balls[i]:update(dt)
        -- check for collision with paddle
        if self.balls[i]:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            self.balls[i].y = self.paddle.y - 8
            self.balls[i].dy = -self.ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if self.balls[i].x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                self.balls[i].dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - self.balls[i].x))
        
            -- else if we hit the paddle on its right side while moving right...
            elseif self.balls[i].x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                self.balls[i].dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - self.balls[i].x))
            end

            gSounds['paddle-hit']:play()
        end 

        -- detect collision across all bricks with the ball
        for k, brick in pairs(self.bricks) do

            -- only check collision if we're in play
            if brick.inPlay and self.balls[i]:collides(brick) then

                -- add to score
                if not brick.isLocked then
                    self.score = self.score + (brick.tier * 200 + brick.color * 25)
                end

                -- trigger the brick's hit function, which removes it from play
                brick:hit(self.paddle, self.score)

                -- if score is over a certain amount spawn a Powerup
                if self.score > self.PowerPoints then
                    -- other Powerups will not be implemented yet
                    -- So only additional ball is ready to go
                    self.powerUp = Powerup(VIRTUAL_WIDTH / 2 , VIRTUAL_HEIGHT / 2 )  
                    self.powerUp.dx = math.random (-100, 100)
                    self.powerUp.dy = math.random (30, 40)
                    self.PowerPoints = math.min(100000, self.PowerPoints * 2)
                end

                -- if we have enough points increase the size of the paddle
                if self.score > self.sizePoints then
                    self.paddle:changeSize(1)
                    self.sizePoints = math.min (100000, self.sizePoints * 2)
                end
                -- if we have enough points, recover a point of health
                if self.score > self.recoverPoints then
                    -- can't go above 3 health
                    self.health = math.min(3, self.health + 1)

                    -- multiply recover points by 2
                    self.recoverPoints = math.min(100000, self.recoverPoints * 2)

                    -- play recover sound effect
                    gSounds['recover']:play()
                end

                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = self.ball,
                        recoverPoints = self.recoverPoints
                    })
                end

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if self.balls[i].x + 2 < brick.x and self.balls[i].dx > 0 then
                
                    -- flip x velocity and reset position outside of brick
                    self.balls[i].dx = -self.balls[i].dx
                    self.balls[i].x = brick.x - 8
            
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif self.balls[i].x + 6 > brick.x + brick.width and self.balls[i].dx < 0 then
                
                    -- flip x velocity and reset position outside of brick
                    self.balls[i].dx = -self.balls[i].dx
                    self.balls[i].x = brick.x + 32
            
            -- top edge if no X collisions, always check
                elseif self.balls[i].y < brick.y then
                
                    -- flip y velocity and reset position outside of brick
                    self.balls[i].dy = -self.balls[i].dy
                    self.balls[i].y = brick.y - 8
            
                -- bottom edge if no X collisions or top collision, last possibility
                else
                
                    -- flip y velocity and reset position outside of brick
                    self.balls[i].dy = -self.balls[i].dy
                    self.balls[i].y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(self.balls[i].dy) < 150 then
                    self.balls[i].dy = self.balls[i].dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end
        end


        -- if ball goes below bounds, revert to serve state (or game over) and decrease health
        -- Also shrink the paddle
        if self.balls[i].y >= VIRTUAL_HEIGHT then
            self.health = self.health - 1
            gSounds['hurt']:play()

            -- Shrink the paddle
            self.paddle:changeSize(-1)
            --clear all other balls, may be unnecessary

            --reset ball_no to 1
            self.ball_no = 1
            -- Game Over or Serve
            if self.health == 0 then
                gStateMachine:change('game-over', {
                    score = self.score,
                    highScores = self.highScores
                })
            else
                gStateMachine:change('serve', {
                    paddle = self.paddle,
                    bricks = self.bricks,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    level = self.level,
                    recoverPoints = self.recoverPoints,
                    PowerPoints = self.PowerPoints,
                    sizePoints = self.sizePoints
                })
            end
        end
    end
        -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end
    



    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

end
function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()
    --render all balls in play
    for i = 1, self.ball_no  do
        self.balls[i]:render()
    end

    if self.powerUp ~= nil then
        if self.powerUp.inPlay then
            self.powerUp:render()
        end
    end
    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end