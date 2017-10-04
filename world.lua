local World = {
	width, height,
	displayWidth, displayHeight,
	tileSize
}

local Characters = require("characters")

-- Initialized when loaded
local layers = {}
local quads = {}

local oldX = 0
local oldY = 0

function World.load(worldName, scale)

	local tileInits = {}

	-- Load map file
	print ("Loading '"..worldName..".lua'...")
	local MapFile = require (worldName)	-- FIXME: find way to load file from subdirectory, or write means of paring other file type

	-- Load map parameters
	World.width = MapFile.width
	World.height = MapFile.height
	World.tileSize = MapFile.tilewidth
	World.updateDimension(scale)

	-- Load tilesets used by map FIXME: Properly link names of textures so only layer names need be hardcoded
	print ("Loading world textures...")
	local mapIndex
	local useTileset
	for mapIndex in pairs(MapFile.tilesets) do
		tileInits[MapFile.tilesets[mapIndex].name] = MapFile.tilesets[mapIndex].firstgid

		useTileset = tilesetValid(MapFile.tilesets[mapIndex].name)

		if (useTileset == true) then
			setupTileset(MapFile.tilesets[mapIndex])
		end
	end

	-- Load map coordinate information
	print ("Loading world information...")
	local xCoord
	local yCoord
	-- Prepare world grid
	for xCoord = 0, World.width - 1 do
		World[xCoord] = {}
		for yCoord = 0, World.height - 1 do
			World[xCoord][yCoord] = {}
		end
	end
	-- Load world data
	for mapIndex in pairs(MapFile.layers) do

		-- Load tile layers
		if (MapFile.layers[mapIndex].type == "tilelayer") then
			for xCoord = 0, World.width - 1 do
				for yCoord = 0, World.height - 1 do
					World[xCoord][yCoord][MapFile.layers[mapIndex].name] = parseMapValue(MapFile.layers[mapIndex].data[xCoord + (World.width * (yCoord)) + 1],
																						tileInits[MapFile.layers[mapIndex].properties.Tileset] - 1)
				end
			end
		end

		-- Load object layers
		if (MapFile.layers[mapIndex].type == "objectlayer") then
		end
	end

	-- Done using mapfile data; use only custom structures from here
	MapFile = nil

	-- Initialize world tiles
	print ("Initializing world...")
	updateWorldTiles(0, 0)

end

function World.updateDimension(scale)

	World.displayWidth = math.ceil(love.graphics.getWidth() / World.tileSize / scale) + 1
	World.displayHeight =  math.ceil(love.graphics.getHeight() / World.tileSize / scale) + 1

end

-- Loads set of sprites for tileset and quad tiles to draw on-screen
function setupTileset(tileset)

	print ("Loading textures for "..tileset.name.." layer")

	local tilesetImage
	local tileXIndex, tileYIndex
	local quadsIndex = 0

	tilesetImage = love.graphics.newImage(tileset.image)
	tilesetImage:setFilter("nearest", "nearest") -- force no filtering for pixelated look

	quads[tileset.name] = {}

	for tileXIndex = 0, (tileset.imagewidth / tileset.tilewidth) - 1 do
		for tileYIndex = 0, (tileset.imageheight / tileset.tileheight) - 1 do
			quads[tileset.name][quadsIndex] = love.graphics.newQuad(tileYIndex * tileset.tilewidth, tileXIndex * tileset.tileheight, 
																	tileset.tilewidth, tileset.tileheight, tileset.imagewidth, tileset.imageheight)
			quadsIndex = quadsIndex + 1
		end
	end

	-- Load tileset
	layers[tileset.name] = love.graphics.newSpriteBatch(tilesetImage, World.displayWidth * World.displayHeight)

end

-- Update what portion of the world is graphically defined
function World.update(camX, camY)

	-- Convert camera coordinates into world tile coordinates
	camX = math.floor(camX / World.tileSize)
	camY = math.floor(camY / World.tileSize)

	-- Clamp coordinates to prevent index error
	camX = math.max(math.min(camX, World.width - World.displayWidth), 0)
	camY = math.max(math.min(camY, World.height - World.displayHeight), 0)

	-- Only update if we actually moved
	if camX ~= oldX or camY ~= oldY then
		updateWorldTiles(camX, camY)
	end

	-- Track old values to limit update rate
	oldX = camX
	oldY = camY

end

-- Render world, with offset for smooth scrolling
function World.drawMap(camX, camY)
	 love.graphics.draw(layers["Base"], camX - (camX % World.tileSize), camY - (camY % World.tileSize))
end

function World.drawObjects(camX, camY)
	love.graphics.draw(layers["Objects"], camX - (camX % World.tileSize), camY - (camY % World.tileSize))
end

-- Re-define sprite batch based on what is visible
function updateWorldTiles(screenTileX, screenTileY)

	local xCoord, yCoord

	-- Rebuild array of visible world tiles
	layers["Base"]:clear()
	layers["Objects"]:clear()
	for xCoord = 0, World.displayWidth - 1 do
		for yCoord = 0, World.displayHeight - 1 do
			layers["Base"]:add(quads["Base"][World[xCoord + screenTileX][yCoord + screenTileY]["Base"] - 1],
						  xCoord * World.tileSize, yCoord * World.tileSize)
			-- Add objects, if they exist; FIXME: split layer based on collision
			if (World[xCoord + screenTileX][yCoord + screenTileY]["Objects"]) then
				layers["Objects"]:add(quads["Objects"][World[xCoord + screenTileX][yCoord + screenTileY]["Objects"] - 1],
							  xCoord * World.tileSize, yCoord * World.tileSize)
			end
		end
	end

	-- Send new data to graphics card ASAP
	layers["Base"]:flush()
	layers["Objects"]:flush()

end

-- Convert map zeros to nil to save RAM and processing time
function parseMapValue(mapValue, offset)

	if mapValue == 0 then
		mapValue = nil
	else
		offset = offset or 0
		mapValue = mapValue - offset
	end

	return mapValue

end

-- Determine whether tileset being analyzed has image data that needn't be loaded
function tilesetValid(tilesetName)

	local noTex = {"Collision", "Icons"}
	local compareIndex
	local validName = true

	for compareIndex in pairs(noTex) do
		if tilesetName == noTex[compareIndex] then
			validName = false
		end
	end

	return validName

end

return World
