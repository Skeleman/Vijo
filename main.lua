-- Globals

local Camera = require("camera")
local Characters = require("characters")
local World = require("world")

local scale = 1

-- PRIMARY FUNCTIONS

-- Initialization function: runs once when game starts
function love.load()

	World.load("Map1", scale)
	Characters.initialize()
	Camera.target = "player"
--	love.graphics.setFont(12) -- wants a font, not a number

end

-- Main processing function; called continuously; dt = change in time in seconds
function love.update(dt)

	Characters.update(dt)
	if(Camera.mode == "followPlayer") then
		Camera:follow(Characters.ID["player"].xPos, Characters.ID["player"].yPos)
	end
	World.update(Camera.x, Camera.y)

end

-- Main graphics function; called continuously. love.graphics only has an effect here
function love.draw()

	Camera:setScale(scale, scale)
	Camera:set()

	-- drawBackground()
	World.draw(Camera.x, Camera.y)
	-- drawDetails()
	Characters.draw(Camera.x, Camera.y)

	Camera:unset()

	-- print FPS over everything
	love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 20)
end


-- FUNCTIONS

function newAnimation(image, Width, height, yIndex, frames, duration)

	local xIndex
	local animation = {}

	animation.spriteSheet = image
	animation.quads = {}

	for xIndex in pairs(frames) do
		table.insert(animation.quads, love.graphics.newQuad(frames[xIndex] * Width, yIndex * height, Width, height, image:getDimensions()))
	end

	animation.duration = duration
	animation.currentTime = 0

	return animation
end

-- EVENTS

-- Process mouse click 
--function love.mousepressed(x, y, button, istouch)
--	if button == 1 then
--	end
--end

-- Process mouse release
--function love.mousereleased(x, y, button, istouch)
--end

-- Process key press
function love.keypressed(key)

	-- Exit game
	if key == "escape" then
		love.event.quit()
	end

	-- Process player movement (FIXME: three keys pressed in circular order causes 'drifting')
	if key == "up" or key == "down" or key == "left" or key == "right" then

		local stateChange
		if Characters.ID["player"].state ~= "moving" then
			stateChange = true
		end

		Characters.ID["player"].direction = key
		Characters.ID["player"].state = "moving"
		Characters.ID["player"]:nextAnimation(true)

	end
end

-- Process key release
function love.keyreleased(key)

	-- Process player movement
	if key == "up" or key == "down" or key == "left" or key == "right" then
		if love.keyboard.isDown("up") then
			Characters.ID["player"].direction = "up"
		elseif love.keyboard.isDown("down") then
			Characters.ID["player"].direction = "down"
		elseif love.keyboard.isDown("left") then
			Characters.ID["player"].direction = "left"
		elseif love.keyboard.isDown("right") then
			Characters.ID["player"].direction = "right"
		else
			Characters.ID["player"].state = "idle"
		end
		Characters.ID["player"]:nextAnimation()
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
