--[[
    @file   scoreboard.lua
    @author Sebastien LEGRAND
    @email  oaxley@gmail.com
    @date   2012-07-30
    
    @brief  Class / Scoreboard management
  ]]

----------[ module settings ]----------
module(..., package.seeall)


----------[ includes ]----------
local settings = require("settings")
local digits = require("classes.digits")

----------[ local functions ]----------

-- create digits table
local function createDigits(params)
    local x, y
    local x0 = params.x0
    local y0 = params.y0
    
    local t = { }
    for y = 1, settings.SCOREBOARD_DIGIT_NUM_BLOCKS do
        for x = 1, settings.SCOREBOARD_DIGIT_NUM_BLOCKS do
            local block = display.newRect(  x0 + (x-1)*settings.SCOREBOARD_DIGIT_BLOCK_SIZE, 
                                            y0 + (y-1)*settings.SCOREBOARD_DIGIT_BLOCK_SIZE,
                                            settings.SCOREBOARD_DIGIT_BLOCK_SIZE,
                                            settings.SCOREBOARD_DIGIT_BLOCK_SIZE)
            block:setFillColor(0,0,0)
            table.insert(t, block)
            params.group:insert(block)
        end
    end

    return t
end


----------[ functions ]----------

-- create the scoreboards
function new(params)
    local size, x0, y0, t, u

    -- score size
    size = settings.SCOREBOARD_DIGIT_WIDTH + settings.SCOREBOARD_DIGIT_SPACE + settings.SCOREBOARD_DIGIT_WIDTH
    
    -- player 1 scoreboard
    x0 = (settings.SCREEN_MAX_X / 2) - (settings.SCOREBOARD_MARGIN + size)
    y0 = settings.SCOREBOARD_POSITION_Y
    
    -- tenth
    t = createDigits({x0 = x0, y0 = y0, group = params.group})
    
    -- unit
    x0 = x0 + settings.SCOREBOARD_DIGIT_WIDTH + settings.SCOREBOARD_DIGIT_SPACE
    u = createDigits({x0 = x0, y0 = y0, group = params.group})
    
    local p1Score = { u, t }
    
    
    -- player 2 scoreboard
    x0 = (settings.SCREEN_MAX_X / 2) + settings.SCOREBOARD_MARGIN
    x0 = x0 + settings.SCOREBOARD_DIGIT_WIDTH + settings.SCOREBOARD_DIGIT_SPACE
    u = createDigits({x0 = x0, y0 = y0, group = params.group})
    
    x0 = x0 - settings.SCOREBOARD_DIGIT_WIDTH - settings.SCOREBOARD_DIGIT_SPACE
    t = createDigits({x0 = x0, y0 = y0, group = params.group})
    
    local p2Score = { u, t}

    return p1Score, p2Score
end

-- make the score
function score(player)
    local value = player.score
    local blockWidth = settings.SCOREBOARD_DIGIT_NUM_BLOCKS

    -- compute the score : score = tenth*10+unit
    local tenth = math.floor(value / 10)
    local unit = value - 10*tenth
    
    -- show the tenth
    if tenth > 0 then
        local mapping = digits.digits[tenth + 1]
        local board = player.scoreboard[2]
        for y=1, blockWidth do
            for x=1, blockWidth do
                if mapping[(y-1)*blockWidth + x] == 1 then
                    board[(y-1)*blockWidth + x]:setFillColor(128,128,128)
                else
                    board[(y-1)*blockWidth + x]:setFillColor(0,0,0)
                end
            end
        end
    else
        local board = player.scoreboard[2]
        for y=1, blockWidth do
            for x=1, blockWidth do
                board[(y-1)*blockWidth + x]:setFillColor(0,0,0)
            end
        end
    end
    
    -- show the unit
    local mapping = digits.digits[unit + 1]
    local board = player.scoreboard[1]
    for y=1, blockWidth do
        for x=1, blockWidth do
            if mapping[(y-1)*blockWidth + x] == 1 then
                board[(y-1)*blockWidth + x]:setFillColor(128,128,128)
            else
                board[(y-1)*blockWidth + x]:setFillColor(0,0,0)
            end
        end
    end
    
end
