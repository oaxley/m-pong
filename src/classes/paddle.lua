--[[
    @file   paddle.lua
    @author Sebastien LEGRAND
    @email  oaxley@gmail.com
    @date   2012-07-30
    
    @brief  Class / Paddle management
  ]]

----------[ module settings ]----------
module(..., package.seeall)


----------[ includes ]----------
local settings = require("settings")


----------[ functions ]----------

-- create a paddle
function new(params)
    
    local paddle = display.newRect(params.x, params.y, settings.PADDLE_WIDTH, settings.PADDLE_HEIGHT)
    paddle:setReferencePoint(display.TopLeftReferencePoint)
    
    paddle.name  = params.name
    paddle.score = 0
    
    return paddle
end

-- move the paddle 
function move(paddle, delta)

    -- move the paddle
    paddle.y = paddle.y + delta
    
    -- check boundaries
    if paddle.y < settings.TABLE_EDGE_THICKNESS then
        paddle.y = settings.TABLE_EDGE_THICKNESS
    end
    
    if paddle.y + settings.PADDLE_HEIGHT > settings.SCREEN_MAX_Y - settings.TABLE_EDGE_THICKNESS then
        paddle.y = settings.SCREEN_MAX_Y - settings.TABLE_EDGE_THICKNESS - settings.PADDLE_HEIGHT
    end
    
end