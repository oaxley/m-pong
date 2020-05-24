--[[
	@file	main.lua
	@author	Sebastien LEGRAND
	@email	oaxley@gmail.com
	@date	2012-07-28
	
	@brief	Pong Game with the Corona SDK
]]

----------[ includes ]----------
local pong = require("classes.pong")
require("settings")

----------[ globals ]----------


----------[ functions ]----------
function main( )

	-- remove the status bar
	display.setStatusBar( display.HiddenStatusBar )
    
	-- create the pong object
	local Pong = pong.new( )
	
	-- create the board
	Pong:createBoard( )
	
    -- welcome message
    Pong:welcome( )
    
end

----------[ main entry point ]----------
main( )