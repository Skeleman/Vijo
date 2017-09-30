local World = {
	map = {}
}

local Characters = require("characters")

-- Adjustable parameters
local tileSize = 16

-- Initialized when loaded
local worldWidth, worldHeight
local screenWidthTileNum, screenHeightTileNum
local tilesetBatch
local mapQuads = {}

local oldX = 0
local oldY = 0

function World.load(worldName, scale)

	print ("Loading world...")
	local Map = require (worldName)	-- FIXME: find way to load file from subdirectory, or write means of paring other file type

	local xCoord
	local yCoord

	World.updateDimension(scale)

	-- Load map parameters FIXME: Determine from map file
	worldWidth = Map.width
	worldHeight = Map.height

	-- Load map coordinate information
	for xCoord = 1, worldWidth do
		World.map[xCoord] = {}
		for yCoord = 1, worldHeight do
			World.map[xCoord][yCoord] = Map.layers[1].data[xCoord + (worldWidth * (yCoord - 1))] - 1
		end
	end

	print ("Loading tileset...")
	-- Load map textures
	setupTileset(Map.tilesets[1].image, Map.tilesets[1].imagewidth / Map.tilesets[1].tilewidth, Map.tilesets[1].imageheight / Map.tilesets[1].tileheight) -- FIXME: Account for directory changes

end

function World.updateDimension(scale)
	screenWidthTileNum = math.ceil(love.graphics.getWidth() / tileSize / scale) + 1
	screenHeightTileNum =  math.ceil(love.graphics.getHeight() / tileSize / scale) + 1
	print ("Width = "..screenWidthTileNum..", Height = "..screenHeightTileNum)
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
			mapQuads[quadsIndex] = love.graphics.newQuad(tileYIndex * tileSize, tileXIndex * tileSize, tileSize, tileSize, imageWidth, imageHeight)
			quadsIndex = quadsIndex + 1
		end
	end

	-- Load tileset
	tilesetBatch = love.graphics.newSpriteBatch(tilesetImage, screenWidthTileNum * screenHeightTileNum)

	-- Initialize
	updateWorldTiles(1, 1)

end

-- Update what portion of the world is graphically defined
function World.update(camX, camY)

	camX = math.ceil(camX / tileSize)
	camY = math.ceil(camY / tileSize)

	-- Clamp coordinates to prevent index error
	camX = math.max(math.min(camX, worldWidth - screenWidthTileNum), 1)
	camY = math.max(math.min(camY, worldHeight - screenHeightTileNum), 1)

	-- only update if we actually moved
	if camX ~= oldX or camY ~= oldY then
		updateWorldTiles(camX, camY)
	end

	oldX = camX
	oldY = camY

end

-- Render world offset for smooth scrolling
function World.draw(camX, camY, scale)
	love.graphics.draw(tilesetBatch, 
		math.floor(-scale * (camX % tileSize)), math.floor(-scale * (camY % tileSize)),
		0, scale, scale)
end

-- Re-define sprite batch based on what is visible
function updateWorldTiles(screenTileX, screenTileY)

	local xCoord, yCoord

	tilesetBatch:clear()
	for xCoord = 0, screenWidthTileNum - 1 do
		for yCoord = 0, screenHeightTileNum - 1 do
			tilesetBatch:add(mapQuads[World.map[xCoord + screenTileX][yCoord + screenTileY]],
				xCoord * tileSize, yCoord * tileSize)
		end
	end
	tilesetBatch:flush()

end

return World
