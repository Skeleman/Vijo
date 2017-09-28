-- Globals

local Characters = require("characters")
local World = require("world")

-- PRIMARY FUNCTIONS

-- Initialization function: runs once when game starts
function love.load()

	World.load()
	Characters.initialize()
	setupTileset()
--	love.graphics.setFont(12) -- wants a font, not a number

end

-- Main processing function; called continuously; dt = change in time in seconds
function love.update(dt)

	local char

	if love.keyboard.isDown("up") then
		shiftWorld(0, -Characters.ID["player"].speed * tileSize * dt / speedScale)
	end
	if love.keyboard.isDown("down") then
		shiftWorld(0, Characters.ID["player"].speed * tileSize * dt / speedScale)
	end
	if love.keyboard.isDown("left") then
		shiftWorld(-Characters.ID["player"].speed * tileSize * dt / speedScale, 0)
	end
	if love.keyboard.isDown("right") then
		shiftWorld(Characters.ID["player"].speed * tileSize * dt / speedScale, 0)
	end

	-- Loop through all characters (FIXME: Only apply to visible characters)
	for name in pairs(Characters.ID) do
		Characters.ID[name].anim.currentTime = Characters.ID[name].anim.currentTime + dt
		if Characters.ID[name].anim.currentTime >= Characters.ID[name].anim.duration then
			Characters.ID[name].anim.currentTime = Characters.ID[name].anim.currentTime - Characters.ID[name].anim.duration
		end
	end
end

-- Main graphics function; called continuously. love.graphics only has an effect here
function love.draw()

	local scale = 5
	-- drawBackground()
	World.draw(scale)
	-- drawDetails()
	Characters.draw(scale)

	-- print FPS over everything
	love.graphics.print("FPS: "..love.timer.getFPS(), 10, 20)
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
		Characters.ID["player"]:updateAnimation(true)

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
		Characters.ID["player"]:updateAnimation()
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