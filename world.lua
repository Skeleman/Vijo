local World = {
	map = {}
}

local Characters = require("characters")

-- Adjustable parameters
local speedScale = 0.002
local tileSize = 16

-- Defaults
local camX = 1
local camY = 1
local scale = 3

-- Initialized when loaded
local worldWidth, worldHeight
local screenWidthTileNum, screenHeightTileNum
local tilesetBatch
local mapQuads = {}

function World.load(worldName)

	print ("Loading world...")
	local Map = require (worldName)	-- FIXME: find way to load file from subdirectory, or write means of paring other file type

	local xCoord
	local yCoord

	-- Load map parameters FIXME: Determine from map file
	worldWidth = Map.width
	worldHeight = Map.height

	screenWidthTileNum = math.floor(love.graphics.getWidth() / tileSize / scale) + 1
	screenHeightTileNum =  math.floor(love.graphics.getHeight() / tileSize / scale) + 1

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

	-- grass
--	mapQuads[0] = love.graphics.newQuad(0 * tileSize, 0 * tileSize, tileSize, tileSize,
--		imageWidth, imageHeight)

	-- path
--	mapQuads[1] = love.graphics.newQuad(14 * tileSize, 3 * tileSize, tileSize, tileSize,
--		imageWidth, imageHeight)

	-- deep grass
--	mapQuads[2] = love.graphics.newQuad(1 * tileSize, 0 * tileSize, tileSize, tileSize,
--		imageWidth, imageHeight)

	-- flower grass
--	mapQuads[3] = love.graphics.newQuad(2 * tileSize, 0 * tileSize, tileSize, tileSize,
--		imageWidth, imageHeight)

	-- load tileset
	tilesetBatch = love.graphics.newSpriteBatch(tilesetImage, screenWidthTileNum * screenHeightTileNum)

	updateTilesetBatch()

end

function World.update(dt)

	local oldX = camX
	local oldY = camY

	-- Update world map positioning

	camX = math.max(math.min(Characters.ID["player"].xPos / tileSize, worldWidth - screenWidthTileNum), 1)
	camY = math.max(math.min(Characters.ID["player"].yPos / tileSize, worldHeight - screenHeightTileNum), 1)

	-- only update if we actually moved
	if math.floor(camX) ~= math.floor(oldX) or math.floor(camY) ~= math.floor(oldY) then
		updateTilesetBatch()
	end

end

-- Render world
function World.draw(scale)
	love.graphics.draw(tilesetBatch, 
		math.floor(-scale*(camX%1)*tileSize), math.floor(-scale*(camY%1)*tileSize),
		0, scale, scale)
end

-- Move world
function shiftWorld(dx, dy)

	local oldX = camX
	local oldY = camY

	camX = math.max(math.min(camX + dx, worldWidth - screenWidthTileNum), 1)
	camY = math.max(math.min(camY + dy, worldHeight - screenHeightTileNum), 1)

	-- only update if we actually moved
	if math.floor(camX) ~= math.floor(oldX) or math.floor(camY) ~= math.floor(oldY) then
		updateTilesetBatch()
	end

end

-- Re-define sprite batch based on what is visible
function updateTilesetBatch()

	local xCoord, yCoord

	tilesetBatch:clear()
	for xCoord = 0, screenWidthTileNum - 1 do
		for yCoord = 0, screenHeightTileNum - 1 do
			tilesetBatch:add(mapQuads[World.map[xCoord + math.floor(camX)][yCoord + math.floor(camY)]],
				xCoord * tileSize, yCoord * tileSize)
		end
	end
	tilesetBatch:flush()

end

return World
