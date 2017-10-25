-- Globals

local WorldManager = require("worldmanager")

local scale = 3

local mode

-- PRIMARY FUNCTIONS

-- Initialization function: runs once when game starts
function love.load()

	-- FIXME: Determine name of map to load from save file
	WorldManager.load("Map1", scale)

	mode = "game"
--	love.graphics.setFont(12) -- wants a font, not a number

end

-- Main processing function; called continuously; dt = change in time in seconds
function love.update(dt)

	WorldManager.update(dt)

end

-- Main graphics function; called continuously. love.graphics only has an effect here
function love.draw()

	WorldManager.draw(scale)

	-- print FPS over everything
	love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 20)

end


-- FUNCTIONS

-- EVENTS

-- Process mouse click 
--function love.mousepressed(x, y, button, istouch)
--	if button == 1 then
--	end
--end

-- Process mouse release
--function love.mousereleased(x, y, button, istouch)
--end

-- Determine how to handle key presses
function love.keypressed(key)

	if mode == "game" then

		WorldManager.keypressed(key)

	elseif mode == "menu" then
	end

end

-- Determine how to handle key releases
function love.keyreleased(key)

	if mode == "game" then

		WorldManager.keyreleased(key)

	elseif mode == "menu" then
	end

end

-- Manage focus change
--function love.focus(f)
--	if not f then
--	else
--	end
--end

-- Manage exit
--function love.quit()
--end
