--[[
	@file	pong.lua
	@author	Sebastien LEGRAND
	@email	oaxley@gmail.com
	@date	2012-07-28
	
	@brief	Pong Game with the Corona SDK
]]


----------[ includes ]----------
local settings = require("settings")
local board = require("classes.board")
local scoreboard = require("classes.scoreboard")
local ball = require("classes.ball")
local paddle = require("classes.paddle")
local physics = require("physics")

----------[ globals ]----------


----------[ physics simulation ]----------
physics.start( )
physics.setGravity(0, 0)
physics.setDrawMode("normal")

----------[ object definition ]----------
local Pong = { }
local Pong_mt = { __index = Pong }

----------[ local functions ]----------


----------[ object methods ]----------

-- create a new object
function Pong.new(params)
    
	-- create a table
	local pong = {	}
	
	-- initialize the random generator
	math.randomseed(os.time())
	
	-- return the object
	return setmetatable(pong, Pong_mt)
end

-- create the board game
function Pong:createBoard( )
    -- create the board
    local _board, _upperEdge, _lowerEdge = board.createBoard( )
    
    -- create the scoreboard
    local _p1Score, _p2Score = scoreboard.new({group = _board})
    
    -- create player1 paddle
    local _player1 = paddle.new({
                                x = settings.PLAYER1_POSITION_X,
                                y = settings.PLAYER1_POSITION_Y,
                                name = "player1",
                                })
    _player1.scoreboard = _p1Score
    _player1.winAlert = board.winAlert("player1")
    _board:insert(_player1)
  
    
    -- create player2 paddle
    local _player2 = paddle.new({
                                x = settings.PLAYER2_POSITION_X,
                                y = settings.PLAYER2_POSITION_Y,
                                name = "player2",
                                })
    _player2.scoreboard = _p2Score
    _player2.winAlert = board.winAlert("player2")
    _board:insert(_player2)
    

	-- create the ball
    local _ball = ball.new({
                            x = settings.BALL_INIT_X,
                            y = settings.BALL_INIT_Y
                            })
    _board:insert(_ball)
    
    -- reduce the board alpha
    _board.alpha = 0.5
    
    -- add physics
    physics.addBody(_upperEdge, "static", {density = 1, friction = 0, bounce = 0})
    physics.addBody(_lowerEdge, "static", {density = 1, friction = 0, bounce = 0})
    physics.addBody(_player1, "static", {density = 1, friction = 0, bounce = 0})
    physics.addBody(_player2, "static", {density = 1, friction = 0, bounce = 0})
    physics.addBody(_ball, "dynamic", {density = 1, friction = 0, bounce = 0})
    
    -- add objects
    self.board      = _board
    self.player1    = _player1
    self.player2    = _player2
    self.ball       = _ball
    self.isGameOver = false
    
end

-- reset moving objects position
function Pong:resetPositions(trigger)
    -- reset player positions
    self.player1.x = settings.PLAYER1_POSITION_X
    self.player1.y = settings.PLAYER1_POSITION_Y
    self.player2.x = settings.PLAYER2_POSITION_X
    self.player2.y = settings.PLAYER2_POSITION_Y

    -- reset ball positions
    self.ball.x = settings.BALL_INIT_X
    self.ball.y = settings.BALL_INIT_Y
    
    -- set initial ball vector (depending on the trigger: player1, player2 or random)
    ball.init(self.ball, trigger)
end

-- welcome message
function Pong:welcome( )
    local text = display.newText("Tap to start", 0, 0, "Arial", 36)
    
    -- center the text in the middle of the screen
    text:setReferencePoint(display.TopLeftReferencePoint)
    text.x = (settings.SCREEN_MAX_X - text.width) / 2
    text.y = (settings.SCREEN_MAX_Y - text.height) / 2

    -- register the TAP event
    Runtime:addEventListener("tap", self)
    
    -- make the text blink
    local blink = function( )
        if text.isVisible == true then
            text.isVisible = false
        else
            text.isVisible = true
        end
    end
    
    self.welcomeMsg = text
    self.welcomeMsg.timer = timer.performWithDelay(300, blink, 0)
    
end

-- start the game
function Pong:start( )
    
    -- reset the GameOver status
    self.isGameOver = false
    
    -- remove "win" alert
    self.player1.winAlert.isVisible = false
    self.player2.winAlert.isVisible = false
    
    -- reset objects position
    self:resetPositions("random")
    
    -- make the ball visible
    self.ball.isVisible = true
    self.ball:toFront()
    
    -- set the initial score
    self.player1.score = 0
    self.player2.score = 0
    scoreboard.score(self.player1)
    scoreboard.score(self.player2)
    
    -- register the events
    Runtime:addEventListener("enterFrame", self)
    Runtime:addEventListener("touch", self)
    Runtime:addEventListener("collision", self)
end

-- detect if ball has crossed the border
function Pong:isOut( )
    local isOut = false
    
    -- select a potential winner depending where the ball is
    local player = nil
    
    if self.ball.x < (settings.SCREEN_MAX_X / 2) then
        player = self.player2
    end
    
    if self.ball.x > (settings.SCREEN_MAX_X / 2) then
        player = self.player1
    end

    -- check if we have an out condition
    if player then
    
        -- control upper and lower edge
        if self.ball.y < 0 or self.ball.y > settings.SCREEN_MAX_Y then
            isOut = true
        else
            -- need to control left & right edges
            if self.ball.x < self.player1.x or self.ball.x > self.player2.x then
                isOut = true
            end
        end

        -- ball is out
        if isOut then
            -- increase player score & change the scoreboard
            player.score = player.score + 1
            scoreboard.score(player)
            
            -- check for winning condition
            if player.score == settings.WINNING_SCORE then
                player.winAlert.isVisible = true
                self.isGameOver = true
            else
                self:resetPositions(player.name)
            end
        end
    end
        
    return isOut
end

----------[ event listeners ]----------

-- tap event
function Pong:tap(event)
    
    -- stop the text blink
    timer.cancel(self.welcomeMsg.timer)
    self.welcomeMsg.isVisible = false
    Runtime:removeEventListener("tap", self)
    
    -- change the alpha value of the board
    self.board.alpha = 1
    
    -- start the game
    self:start( )
   
end

-- enterFrame event
function Pong:enterFrame(event)
    -- update the ball position
    ball.move(self.ball)
    local isOut = self:isOut( )
    
    if self.isGameOver then
        -- remove events
        Runtime:removeEventListener("enterFrame", self)
        Runtime:removeEventListener("touch", self)
        Runtime:removeEventListener("collision", self)
        
        -- run the welcome message in 1s
        timer.performWithDelay(1000, self:welcome())
    else
        if isOut == false then
            -- track the movement of the ball if it is in our direction
            if self.ball.svx > 0 then
                -- move only if it's in our half screen
                if self.ball.x > settings.SCREEN_MAX_X/2 then
                    if self.ball.y > self.player2.y then
                        paddle.move(self.player2, self.ball.vy)
                    else
                        paddle.move(self.player2, -1*self.ball.vy)
                    end
                end
            elseif self.ball.svx < 0 then
                -- move back the paddle in the middle
                if (self.player2.y + settings.PADDLE_HEIGHT/2) > settings.SCREEN_MAX_Y/2 then
                    paddle.move(self.player2, -1)
                else
                    paddle.move(self.player2, 1)
                end
            end
        end
    end
end

-- touch event
function Pong:touch(event)
    
    -- initial touch event
    if event.phase == "began" then
        init = event.y
    end
    
    -- paddle is moving
    if event.phase == "moved" then
        delta = event.y - init
        paddle.move(self.player1, delta)
        init = event.y
    end
    
end

-- collision event
function Pong:collision(event)

    -- bounce the ball around
    if event.phase == "began" then
        -- bounce against upper and lower edges
        if event.object1.name == "upperEdge" or event.object1.name == "lowerEdge" then
            self.ball.svy = -self.ball.svy
        end

        -- bounce against player paddle
        if event.object1.name == "player1" or event.object1.name == "player2" then
            self.ball.svx = -self.ball.svx

            local center = event.object1.y + settings.PADDLE_HEIGHT/2
            
            -- double the speed if we hit the center of the pad (center +/- 5%)
            if  self.ball.y > center*.90 and self.ball.y < center*1.10 then
                self.ball.vx = 2 * self.ball.vx
                if self.ball.vx > settings.BALL_MAX_VELOCITY then
                    self.ball.vx = settings.BALL_MAX_VELOCITY
                end
            else
                -- add some "lift" effect
                self.ball.vy = 1.5 * self.ball.vy
                if self.ball.vy > settings.BALL_MAX_VELOCITY then
                    self.ball.vy = settings.BALL_MAX_VELOCITY
                end
            end
            
        end
    end
end

----------[ end module ]----------
return Pong