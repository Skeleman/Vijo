local World = {
	mapData = {},
	width, height,
	displayWidth, displayHeight,
	tileSize
}

local Characters = require("characters")

-- Initialized when loaded
local mapLayer
local objectLayer
local mapQuads = {}
local objectQuads = {}

local oldX = 0
local oldY = 0

function World.load(worldName, scale)

	local xCoord
	local yCoord

	print ("Loading world and parameters...")
	local MapFile = require (worldName)	-- FIXME: find way to load file from subdirectory, or write means of paring other file type

	-- Load map parameters
	World.width = MapFile.width
	World.height = MapFile.height
	World.tileSize = MapFile.tilesets[1].tilewidth	-- Fixme: choose tileset based on tileset name

	World.updateDimension(scale)

	-- Load map coordinate information
	for xCoord = 0, World.width - 1 do
		World[xCoord] = {}
		for yCoord = 0, World.height - 1 do
			World[xCoord][yCoord] = {}
			World[xCoord][yCoord].map = parseMapValue(MapFile.layers[1].data[xCoord + (World.width * (yCoord)) + 1])	-- FIXME: Select layers and offsets based on name
			World[xCoord][yCoord].object = parseMapValue(MapFile.layers[2].data[xCoord + (World.width * (yCoord)) + 1], 4096)  -- FIXME: Adjust offset methodology. Force tileset per layer.
			World[xCoord][yCoord].collision = parseMapValue(MapFile.layers[3].data[xCoord + (World.width * (yCoord)) + 1])
		end
	end

	print ("Loading tileset...")
	-- Load map textures
	setupTileset(MapFile.tilesets[1].image, MapFile.tilesets[1].imagewidth / World.tileSize, MapFile.tilesets[1].imageheight / World.tileSize)
	-- Load object textures
--	setupTileset(MapFile.tilesets[1].image, MapFile.tilesets[1].imagewidth / World.tileSize, MapFile.tilesets[1].imageheight / World.tileSize)

	-- Done using mapfile data; use only custom structures from here
	MapFile = nil

end

function World.updateDimension(scale)
	World.displayWidth = math.ceil(love.graphics.getWidth() / World.tileSize / scale) + 1
	World.displayHeight =  math.ceil(love.graphics.getHeight() / World.tileSize / scale) + 1
end

function setupTileset(name, tileXCount, tileYCount)

	local tilesetImage
	local imageWidth, imageHeight
	local tileXIndex, tileYIndex
	local quadsIndex = 0

	tilesetImage = love.graphics.newImage("Assets/tileset.png")
	tilesetImage:setFilter("nearest", "nearest") -- force no filtering for pixelated look

	imageWidth = tilesetImage:getWidth()
	imageHeight = tilesetImage:getHeight()

	for tileXIndex = 0, tileXCount - 1 do
		for tileYIndex = 0, tileYCount - 1 do
			mapQuads[quadsIndex] = love.graphics.newQuad(tileYIndex * World.tileSize, tileXIndex * World.tileSize, World.tileSize, World.tileSize, imageWidth, imageHeight)
			objectQuads[quadsIndex] = love.graphics.newQuad(tileYIndex * World.tileSize, tileXIndex * World.tileSize, World.tileSize, World.tileSize, imageWidth, imageHeight)
			quadsIndex = quadsIndex + 1
		end
	end

	-- Load tileset
	mapLayer = love.graphics.newSpriteBatch(tilesetImage, World.displayWidth * World.displayHeight)
	objectLayer = love.graphics.newSpriteBatch(tilesetImage, World.displayWidth * World.displayHeight)

	-- Initialize
	updateWorldTiles(0, 0)

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
	 love.graphics.draw(mapLayer, camX - (camX % World.tileSize), camY - (camY % World.tileSize))
end

function World.drawObjects(camX, camY)
	love.graphics.draw(objectLayer, camX - (camX % World.tileSize), camY - (camY % World.tileSize))
end

-- Re-define sprite batch based on what is visible
function updateWorldTiles(screenTileX, screenTileY)

	local xCoord, yCoord

	-- Rebuild array of visible world tiles
	mapLayer:clear()
	objectLayer:clear()
	for xCoord = 0, World.displayWidth - 1 do
		for yCoord = 0, World.displayHeight - 1 do
			mapLayer:add(mapQuads[World[xCoord + screenTileX][yCoord + screenTileY].map - 1],
						  xCoord * World.tileSize, yCoord * World.tileSize)
			if (World[xCoord + screenTileX][yCoord + screenTileY].object) then
				objectLayer:add(objectQuads[World[xCoord + screenTileX][yCoord + screenTileY].object - 1],
							  xCoord * World.tileSize, yCoord * World.tileSize)
			end
		end
	end

	-- Send new data to graphics card ASAP
	mapLayer:flush()
	objectLayer:flush()

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

return World
