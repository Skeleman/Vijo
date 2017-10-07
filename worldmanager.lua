local WorldManager = {
}

local Characters = require("characters")
local Camera = require("camera")
local World = require("world")

local zMax = 1

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
	Camera:follow(Characters.ID[Camera.target].xPos, Characters.ID[Camera.target].yPos)

	-- Update world
	World.update(Camera.x, Camera.y, dt)

	local yDir = 0
	local xDir = 0

	-- Update player based on user input
	if love.keyboard.isDown("up") then		yDir = yDir - 1 end
	if love.keyboard.isDown("down") then	yDir = yDir + 1 end
	if love.keyboard.isDown("left") then	xDir = xDir - 1 end
	if love.keyboard.isDown("right") then	xDir = xDir + 1 end

	if (xDir ~= 0 or yDir ~= 0) then
		local newX, newY
		print ("Char, pre: "..Characters.ID["player"].xPos..", "..Characters.ID["player"].yPos)
		newX, newY = Characters.ID["player"]:prepMove(dt, xDir, yDir)
		local tileX = math.floor(newX / World.tileSize)
		local tileY = math.floor(newY / World.tileSize)
		print ("Move, post: "..newX..", "..newY..","..tileX..", "..tileY)
		if (World[tileX]) then
			if (World[tileX][tileY]) then
				if (World[tileX][tileY][Characters.ID["player"].zPos]) then
					if (World[tileX][tileY][Characters.ID["player"].zPos]["Base"] and (not World[tileX][tileY][Characters.ID["player"].zPos]["Collision"])) then
						Characters.ID["player"]:move(newX, newY)
					else
						Characters.ID["player"]:clamp(xDir, yDir, World.tileSize)
					end
				end
			end
		end
	end

	-- Update characters
	Characters.update(dt)

end

-- Draw world components
function WorldManager.draw(scale)

	Camera:setScale(scale, scale)
	Camera:set()

	-- Draw all elevations
	for zVal = 1, zMax do

		World.draw("Base", Camera.x, Camera.y, zVal)

		-- Draw all characters
		Characters.draw(Camera.x, Camera.y, zVal)

		World.draw("Objects", Camera.x, Camera.y, zVal)

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
