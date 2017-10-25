local WorldManager = {
}

local Characters = require("characters")
local Objects = require("objects")
local Camera = require("camera")
local World = require("world")
local Animations = require("animations")

local Entities = {}
local DrawList = {}
local spriteSheets = {}

local SPRITE_PADDING = 2	-- Amount of pixels on border of sprite to allow collision to overlap
local EPSILON = 0.01

local tileSize = 16			-- FIXME: Import dynamically

-- Initialize game assets and data
function WorldManager.load(worldName, scale)

	-- Load world file
	print ("Loading '"..worldName..".lua'...")
	local MapFile = require (worldName)	-- FIXME: find way to load file from subdirectory, or write means of paring other file type

	-- Associate texture array indices with texture names. Required to account for 'Tiled' layer offsets
	print ("Preparing textures...")
	local imageFileIndex
	local imageFileIndices = {}
	for imageFileIndex in pairs(MapFile.tilesets) do
		imageFileIndices[MapFile.tilesets[imageFileIndex].name] = imageFileIndex
	end

	-- Initialize world data
	World.load(MapFile, imageFileIndices, scale)

	-- Initialize character and object data
	loadEntities(MapFile, imageFileIndices, DrawList)

	-- Initialize camera
	Camera.target = "player"

	-- Done using mapfile data; use only custom structures from here
	MapFile = nil

	print("")

end

-- Update world data
function WorldManager.update(dt)

	-- Update camera
	Camera:follow(Entities[Camera.target].xPos, Entities[Camera.target].yPos, Entities[Camera.target].width,
				  World.width, World.height, World.displayWidth, World.displayHeight, World.tileSize)

	-- Update world
	World.update(Camera.x, Camera.y, dt, World.width, World.height, World.displayWidth, World.displayHeight)

	local yMag = 0
	local xMag = 0

	-- Update player based on user input
	if love.keyboard.isDown("up") then		yMag = yMag - 1 end
	if love.keyboard.isDown("down") then	yMag = yMag + 1 end
	if love.keyboard.isDown("left") then	xMag = xMag - 1 end
	if love.keyboard.isDown("right") then	xMag = xMag + 1 end

	-- Split movement by axis to allow movement along collosiion boundaries
	if (xMag ~= 0) then
		Entities["player"]:move(dt, xMag, 'x', DrawList[Entities["player"].zPos])
		manageCollision(Entities["player"], xMag, 'x')
	end
	if (yMag ~= 0) then
		Entities["player"]:move(dt, yMag, "y", DrawList[Entities["player"].zPos])
		manageCollision(Entities["player"], yMag, 'y')
	end

	local ID
	-- Loop through all entities and update according to all game systems(FIXME: Only apply to visible characters)
	for ID in pairs(Entities) do
		Entities[ID]:update(dt)
	end

end

-- Load characters
function loadEntities(MapFile, imageFileIndices, DrawList)

	local zVal

	-- Load character data and images
	print ("Loading characters and objects...")

	spriteSheets["characters"] = {}
	spriteSheets["objects"] = {}

	-- Load non-PC character data, layer by layer
	local layerIndex
	local layerType
	for layerIndex in pairs(MapFile.layers) do

		-- Only process object layers
		if (MapFile.layers[layerIndex].type == "objectgroup") then

			-- Get elevation value from layer name
			layerType, zVal = getLayerInfo(MapFile.layers[layerIndex].name)

			-- Only look at map file character layers
			if (layerType == "characters") then

				local index

				-- Loop through all characters in layer
				for index in pairs(MapFile.layers[layerIndex].objects) do

					local char = MapFile.layers[layerIndex].objects[index]
					local charTexFile = "characters_"..math.ceil(char.width / tileSize).."_"..math.ceil(char.height / tileSize)

					-- If new sized of character found, load new sprite sheet
					if not (spriteSheets["characters"][char.width]) then spriteSheets["characters"][char.width] = {} end
					if not (spriteSheets["characters"][char.width][char.height]) then
						spriteSheets["characters"][char.width][char.height] = love.graphics.newImage("Assets/"..charTexFile..".png")
						spriteSheets["characters"][char.width][char.height]:setFilter("nearest", "nearest")
					end
					-- Create character object
					Entities[char.id] = Characters:new(char.id, char.name, spriteSheets["characters"][char.width][char.height],
														char.x, char.y, zVal, char.width, char.height,
														math.floor((char.gid - MapFile.tilesets[imageFileIndices[charTexFile]].firstgid) / 
																	(MapFile.tilesets[imageFileIndices[charTexFile]].imagewidth /
																	 MapFile.tilesets[imageFileIndices[charTexFile]].tilewidth)),
														char.properties.speed)

					-- Update drawing list for current character
					if not (DrawList[zVal]) then DrawList[zVal] = {} end

					updateDrawOrder(Entities[char.id], DrawList[zVal], true)

				end

			-- FIXME: Simplify same-type opbject instantiation
			-- Only look at map file object layers
			elseif (layerType == "objects") then
				local index

				-- Loop through all Objects in layer
				for index in pairs(MapFile.layers[layerIndex].objects) do

					local object = MapFile.layers[layerIndex].objects[index]
					local objectTexFile = "objects_"..math.ceil(object.width / tileSize).."_"..math.ceil(object.height / tileSize)

					-- If new sized of object found, load new sprite sheet
					if not (spriteSheets["objects"][object.width]) then spriteSheets["objects"][object.width] = {} end
					if not (spriteSheets["objects"][object.width][objectTileHeight]) then
						spriteSheets["objects"][object.width][object.height] = love.graphics.newImage("Assets/"..objectTexFile..".png")
						spriteSheets["objects"][object.width][object.height]:setFilter("nearest", "nearest")
					end

					-- Create object object
					Entities[object.id] = Objects:new(object.id, spriteSheets["objects"][object.width][object.height],
																object.x, object.y, zVal, object.width, object.height,
																(object.gid - MapFile.tilesets[imageFileIndices[objectTexFile]].firstgid))
					print(object.gid..", "..MapFile.tilesets[imageFileIndices[objectTexFile]].firstgid)

					-- Update drawing list for current object
					if not (DrawList[zVal]) then DrawList[zVal] = {} end

					updateDrawOrder(Entities[object.id], DrawList[zVal], true)

				end
			end
		end
	end

	-- Add character to drawing list FIXME: Get sprite and position data from save file
	Entities["player"] = Characters:new("player", "player", spriteSheets["characters"][16][32], 1200, 800, 1, 16, 32, 2, 100)
	updateDrawOrder(Entities["player"], DrawList[Entities["player"].zPos], true)

	print("")

end

function manageCollision(char, magnitude, axis)

	local moveSuccess = true

	local xIndex
	local yIndex

	local minX = math.floor((char.xPos + SPRITE_PADDING) / World.tileSize)
	local maxX = math.floor((char.xPos + char.width - SPRITE_PADDING - 0.01) / World.tileSize)
	local minY = math.floor((char.yPos + SPRITE_PADDING) / World.tileSize)
	local maxY = math.floor((char.yPos + char.width - SPRITE_PADDING - 0.01) / World.tileSize)
	local maxZ = char.height + 1 -- FIXME: Implement collision based on walking into ceilings

	-- FIXME: See if there's a way to try/catch bad array indices
	for xIndex = minX, maxX do
		for yIndex = minY, maxY do
			if (World[xIndex]) then
				if (World[xIndex][yIndex]) then
					if (World[xIndex][yIndex][char.zPos]) then
						if (World[xIndex][yIndex][char.zPos]["base"] and (not World[xIndex][yIndex][char.zPos]["walls"])) then
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
				char.xPos = math.floor(char.xPos / World.tileSize) * World.tileSize - EPSILON + SPRITE_PADDING
			end
		elseif (axis == 'y') then
			if (magnitude < 0) then
				char.yPos = math.ceil(char.yPos / World.tileSize) * World.tileSize - SPRITE_PADDING
			elseif (magnitude > 0) then
				char.yPos = math.floor(char.yPos / World.tileSize) * World.tileSize - EPSILON + SPRITE_PADDING
			end
		end

	end

end

-- Update list of entities to draw
function updateDrawOrder(entity, DrawList, newEntry)

	local arrayIndex
	local added = false
	local removed = false

	local entry = {}
	entry.ID = entity.ID
	entry.yPos = entity.yPos

	newEntry = newEntry or false

	-- Compare to all values in array
	for arrayIndex in pairs(DrawList) do

		-- If the entry has not yet been added, check if it is less than the current value
		if (not added) then
			if (entry.yPos <= DrawList[arrayIndex].yPos) then
				table.insert(DrawList, arrayIndex, entry)
				arrayIndex = arrayIndex + 1
				added = true

				-- If nothing to remove, no need to look further
				if (newEntry or removed) then break end
			end
		end

		-- If attempting to reorder instead of add, look for old entry to remove
		if (not newEntry) then
			if (DrawList[arrayIndex].ID == entry.ID) then
				table.remove(DrawList, arrayIndex)
				removed = true

				-- If entry was already added, no need to look further
				if added then break end
			end
		end
	end

	-- If the entry was not added, it needs to be added to the end of the table
	if (not added) then
		table.insert(DrawList, entry)
	end

end

-- Draw world components
function WorldManager.draw(scale)

	Camera:setScale(scale, scale)
	Camera:set()

	local drawIndex

	-- Draw all elevations
	for zVal = 1, World.zMax do

		-- Start by drawing base layer
		World.draw("base", Camera.x, Camera.y, zVal)

		-- Then draw landscape overlays
		World.draw("overlays", Camera.x, Camera.y, zVal)

		-- Then draw collision walls
		World.draw("walls", Camera.x, Camera.y, zVal)

		-- Then draw details
		World.draw("detail", Camera.x, Camera.y, zVal)

		-- Draw all characters and objects based on Y coordinates
		if (DrawList[zVal]) then
			for drawIndex in pairs(DrawList[zVal]) do
				Entities[DrawList[zVal][drawIndex].ID]:draw(Camera.x, Camera.y, zVal)
			end
		end

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
		if Entities["player"].state ~= "moving" then
			stateChange = true
		end

		Entities["player"].direction = key
		Entities["player"].state = "moving"
		Entities["player"]:nextAnimation(true)

	end

	-- Debug ==F
	if key == "1" then
		Entities["player"]:setSprite(Entities["player"].sprite.spriteSheet, 16, 32, 0)
		Entities["player"]:nextAnimation()
	elseif key == "2" then
		Entities["player"]:setSprite(Entities["player"].sprite.spriteSheet, 16, 32, 1)
		Entities["player"]:nextAnimation()
	elseif key == "3" then
		Entities["player"]:setSprite(Entities["player"].sprite.spriteSheet, 16, 32, 2)
		Entities["player"]:nextAnimation()
	elseif key == "4" then
		Entities["player"]:setSprite(Entities["player"].sprite.spriteSheet, 32, 32, 0)
		Entities["player"]:nextAnimation()
	end

end

function WorldManager.keyreleased(key)

	-- Process player movement
	if key == "up" or key == "down" or key == "left" or key == "right" then
		if love.keyboard.isDown("up") then
			Entities["player"].direction = "up"
		elseif love.keyboard.isDown("down") then
			Entities["player"].direction = "down"
		elseif love.keyboard.isDown("left") then
			Entities["player"].direction = "left"
		elseif love.keyboard.isDown("right") then
			Entities["player"].direction = "right"
		else
			Entities["player"].state = "idle"
		end
		Entities["player"]:nextAnimation()
	end

end

-- Determine layer type being loaded FIXME: find way to share this code with the world.lua copy
function getLayerInfo(layerName)

	local start = string.find(layerName, '_')
	local elevation = tonumber(string.sub(layerName, start + 1))
	local layerType = string.sub(layerName, 1, start - 1)

	return layerType, elevation

end

return WorldManager
