--[[
    @file   board.lua
    @author Sebastien LEGRAND
    @email  oaxley@gmail.com
    @date   2012-07-30
    
    @brief  Class / Create the Pong Board
  ]]

----------[ module settings ]----------
module(..., package.seeall)


----------[ includes ]----------
local settings = require("settings")
local digits = require("classes.digits")


----------[ local functions ]----------

-- create the middle line
local function middleLine(group)
	local x    = settings.SCREEN_MAX_X / 2
	local ymin = settings.TABLE_EDGE_THICKNESS
	local ymax = settings.SCREEN_MAX_Y - settings.TABLE_EDGE_THICKNESS*2
	local step = settings.MIDDLE_LINE_STEPS
	
	for y = ymin, ymax, step do
		local line = display.newLine(x, y, x, y+step-5)
		line:setColor(255,255,255)
		line.width = 3
		line.alpha = settings.TABLE_ALPHA_VALUE
        group:insert(line)
	end
end

-- create the upper edge
local function createEdge(params)
	-- edges parameters
	local width = settings.SCREEN_MAX_X - settings.TABLE_REDUCTION_RATIO * settings.TABLE_EDGE_THICKNESS
	local height = settings.TABLE_EDGE_THICKNESS
	local x = settings.TABLE_EDGE_THICKNESS * (settings.TABLE_REDUCTION_RATIO / 2)
    local y = params.y
		
	-- create upper edge
	local upper = display.newRect(x, y, width, height)
	upper.alpha = settings.TABLE_ALPHA_VALUE
	upper.name = params.name
    
    return upper
end

----------[ functions ]----------

-- create the Pong board
function createBoard( )

    local board = display.newGroup( )
    
    -- create the middle line
    middleLine(board)
    
    -- create the upper edge
    local upperEdge = createEdge({
                                    y = 0, 
                                    name = "upperEdge"
                                    })
    board:insert(upperEdge)
    
    -- create the lower edge
    local lowerEdge = createEdge({
                                    y = settings.SCREEN_MAX_Y - settings.TABLE_EDGE_THICKNESS, 
                                    name = "lowerEdge"
                                    })
    board:insert(lowerEdge)
    
    -- return everything
    return board, upperEdge, lowerEdge
end

-- create the win Alert
function winAlert(player)
    -- aliases
    local numblocks = settings.SCOREBOARD_DIGIT_NUM_BLOCKS
    local blocksize = settings.SCOREBOARD_DIGIT_BLOCK_SIZE
    local spacesize = 5
    
    -- WiN size 5blocks * 10px each * 3letters + 2spaces * 5px each
    local width = 3 * numblocks * blocksize + 2 * spacesize
    local height = numblocks * blocksize
    
    -- put the WiN in the middle of the lower screen
    local x0 = ((settings.SCREEN_MAX_X/2) - width) / 2
    local y0 = (settings.SCREEN_MAX_Y/2) + ((settings.SCREEN_MAX_Y/2) - height) / 2
    
    -- add half of the screen to put it in the middle of the player2 area
    if player == "player2" then
        x0 = x0 + settings.SCREEN_MAX_X/2
    end
    
    -- new group
    local group = display.newGroup( )
    
    -- print letters
    for i = 1, 3 do
        local letter = digits.win[i]
        for y = 1, numblocks do
            for x = 1, numblocks do
                if letter[(y-1)*numblocks + x] == 1 then
                    local block = display.newRect(x0 + (x-1)*blocksize, y0 + (y-1)*blocksize, blocksize, blocksize)
                    block:setFillColor(255, 255, 255)
                    group:insert(block)
                end
            end
        end
    
        -- next letter position
        x0 = x0 + numblocks * blocksize + spacesize
    end
    
    -- make the group invisible for now
    group.isVisible = false
    
    return group
end
