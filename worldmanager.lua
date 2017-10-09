local WorldManager = {
}

local Characters = require("characters")
local Camera = require("camera")
local World = require("world")

local SPRITE_PADDING = 2	-- Amount of pixels on border of sprite to allow collision to overlap

local zMax 

--local squareX = {}
--local squareY = {}

-- Initialize game assets and data
function WorldManager.load(mapName, scale)

	-- Initialize world data
	zMax = World.load(mapName, scale)

	-- Initialize character data
	Characters.load()

	-- Initialize camera
	Camera.target = "player"

end

-- Update world data
function WorldManager.update(dt)

	-- Update camera
	Camera:follow(Characters.ID[Camera.target].xPos, Characters.ID[Camera.target].yPos, Characters.ID[Camera.target].width)

	-- Update world
	World.update(Camera.x, Camera.y, dt)

	local yMag = 0
	local xMag = 0

	-- Update player based on user input
	if love.keyboard.isDown("up") then		yMag = yMag - 1 end
	if love.keyboard.isDown("down") then	yMag = yMag + 1 end
	if love.keyboard.isDown("left") then	xMag = xMag - 1 end
	if love.keyboard.isDown("right") then	xMag = xMag + 1 end

	if (xMag ~= 0) then
		Characters.ID["player"]:move(dt, xMag, 'x')
		manageCollision(Characters.ID["player"], xMag, 'x')
	end
	if (yMag ~= 0) then
		Characters.ID["player"]:move(dt, yMag, "y")
		manageCollision(Characters.ID["player"], yMag, 'y')
	end
	-- Update characters
	Characters.update(dt)

end

function manageCollision(char, magnitude, axis)

	local moveSuccess = true

	local xIndex
	local yIndex

--	squareX = {}
--	squareY = {}

	local minX = math.floor((char.xPos + SPRITE_PADDING) / World.tileSize)
	local maxX = math.floor((char.xPos + char.width - SPRITE_PADDING - 0.01) / World.tileSize)
	local minY = math.floor((char.yPos + SPRITE_PADDING) / World.tileSize)
	local maxY = math.floor((char.yPos + char.width - SPRITE_PADDING - 0.01) / World.tileSize)
	local maxZ = char.height + 1 -- FIXME: Implement collision based on walking into ceilings

	-- FIXME: See if there's a way to try/catch bad array indices
	for xIndex = minX, maxX do
		for yIndex = minY, maxY do
--			squareX[xIndex] = xIndex
--			squareY[yIndex] = yIndex
			if (World[xIndex]) then
				if (World[xIndex][yIndex]) then
					if (World[xIndex][yIndex][char.zPos]) then
						if (World[xIndex][yIndex][char.zPos]["Base"] and (not World[xIndex][yIndex][char.zPos]["Collision"])) then
							moveSuccess = true
						else
							moveSuccess = false
							break
						end
					else
						moveSuccess = false
						break
					end
				else
					moveSuccess = false
					break
				end
			else
				moveSuccess = false
				break
			end
		end
		if (moveSuccess == false) then break end
	end

	if (moveSuccess == false) then
		if (axis == 'x') then
			if (magnitude < 0) then
				char.xPos = math.ceil(char.xPos / World.tileSize) * World.tileSize - SPRITE_PADDING
			elseif (magnitude > 0) then
				char.xPos = math.floor(char.xPos / World.tileSize) * World.tileSize - 0.01 + SPRITE_PADDING
			end
		elseif (axis == 'y') then
			if (magnitude < 0) then
				char.yPos = math.ceil(char.yPos / World.tileSize) * World.tileSize - SPRITE_PADDING
			elseif (magnitude > 0) then
				char.yPos = math.floor(char.yPos / World.tileSize) * World.tileSize - 0.01 + SPRITE_PADDING
			end
		end

	end

end

-- Draw world components
function WorldManager.draw(scale)

	Camera:setScale(scale, scale)
	Camera:set()

	local xIndex, yIndex

	-- Draw all elevations
	for zVal = 1, zMax do

		-- Start by drawing base layer
		World.draw("Base", Camera.x, Camera.y, zVal)

--		love.graphics.setColor(255,255,255)
--		if (zVal == 1) then
--			for xIndex in pairs(squareX) do
--				for yIndex in pairs(squareY) do
--					love.graphics.rectangle("fill", squareX[xIndex] * 16, squareY[yIndex] * 16, 16, 16)
--				end
--			end
--		end
--		love.graphics.setColor(100,100,100)

		--Then draw collision walls
		World.draw("Walls", Camera.x, Camera.y, zVal)

		-- Draw all characters and objects based on Y coordinates
		Characters.draw(Camera.x, Camera.y, zVal)

	end

	Camera:unset()

end

function WorldManager.keypressed(key)

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

	-- Debug
	if key == "1" then
		Characters.ID["player"]:setSprite(1, 2, 0)
		Characters.ID["player"]:nextAnimation()
	elseif key == "2" then
		Characters.ID["player"]:setSprite(1, 2, 1)
		Characters.ID["player"]:nextAnimation()
	elseif key == "3" then
		Characters.ID["player"]:setSprite(1, 2, 2)
		Characters.ID["player"]:nextAnimation()
	end

end

function WorldManager.keyreleased(key)

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

return WorldManager
