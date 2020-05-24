--[[
    @file   ball.lua
    @author Sebastien LEGRAND
    @email  oaxley@gmail.com
    @date   2012-07-30
    
    @brief  Class / Ball management
  ]]

----------[ module settings ]----------
module(..., package.seeall)


----------[ includes ]----------
local settings = require("settings")


----------[ functions ]----------

-- create the ball
function new(params)
    
    local ball = display.newRect(params.x, params.y, settings.BALL_SIZE, settings.BALL_SIZE)
    
    ball.isVisible = false
    ball.vx  = 0                -- velocity X
    ball.vy  = 0                -- velocity y
    ball.svx = 1                -- sign for velocity x
    ball.svy = 1                -- sign for velocity y
    ball.name = "ball"
    
    return ball
end

-- ball initial vector
function init(ball, player)
	local vx, vy
	
	-- randomize vx, vy
	ball.vx = math.random(settings.BALL_MAX_VELOCITY)
	ball.vy = math.random(settings.BALL_MAX_VELOCITY)
	
	if math.random(256) > 128 then
		ball.svy = -1
	end
	
	-- change the sign depending on the player
	if player == "player2" then
		ball.svx = -1
	end

	-- randomized player
	if player == "random" then
		if math.random(256) > 128 then
            ball.svx = -1
        end
	end
end

-- move the ball
function move(ball)
    ball.x = ball.x + ball.svx * ball.vx
    ball.y = ball.y + ball.svy * ball.vy
end
