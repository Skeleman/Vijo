local World = {
	width = 1, height = 1,
	displayWidth= 1, displayHeight = 1,
	tileSize = 16
}

-- Initialized when loaded
local layers = {}

local oldX = 0
local oldY = 0

local zMax

function World.load(worldName, scale)

	-- Reset world FIXME: put in logic to prevent unnecessary unloading
	layers = {}

	local tileInits = {}

	-- Load map file
	print ("Loading '"..worldName..".lua'...")
	local MapFile = require (worldName)	-- FIXME: find way to load file from subdirectory, or write means of paring other file type

	-- Load map parameters
	World.width = MapFile.width
	World.height = MapFile.height
	World.tileSize = MapFile.tilewidth
	World.updateDimension(scale)

	-- Associate texture array indices with texture names. Required to account for 'Tiled' layer offsets
	print ("Parsing texture array...")
	local tilesetIndex
	local tilesetIndices = {}
	for tilesetIndex in pairs(MapFile.tilesets) do
		tilesetIndices[MapFile.tilesets[tilesetIndex].name] = tilesetIndex
	end

	-- Load map coordinate information
	print ("Loading world information...")

	local zVal

	zMax = 0

	-- Load world data, layer by layer
	local layerIndex
	for layerIndex in pairs(MapFile.layers) do

		-- Get elevation value from layer name
		zVal = getElevation(MapFile.layers[layerIndex].name)

		-- Load tile layer info
		if (MapFile.layers[layerIndex].type == "tilelayer") then
			local xVal

			-- Iterate over full world width
			for xVal = 0, World.width - 1 do
				local yVal

				-- Create array of coordinates, starting with X. Do not clear.
				if not (World[xVal]) then World[xVal] = {} end

				-- Iterate over full world height
				for yVal = 0, World.height - 1 do

					-- Create sub-array of Y coordinates. Do not clear.
					if not (World[xVal][yVal]) then World[xVal][yVal] = {} end

					-- Create sub-array of Z coordinates. Do not clear.
					if not (World[xVal][yVal][zVal]) then World[xVal][yVal][zVal] = {} end

					-- Update world array. "parseMapValue" will prevent addition of empty data and account for texture ID offset
					World[xVal][yVal][zVal][getLayerType(MapFile.layers[layerIndex].name)] = 
						parseMapValue(MapFile.layers[layerIndex].data[xVal + (World.width * (yVal)) + 1],
						MapFile.tilesets[tilesetIndices[MapFile.layers[layerIndex].properties.Tileset]].firstgid - 1)
				end
			end

		-- Load object layer info
		elseif (MapFile.layers[layerIndex].type == "objectlayer") then
		end

		-- Keep track of highest layer for given world
		if (zVal > zMax) then zMax = zVal end

	end

	-- Set up tileset and textures
	print ("Loading world textures...")
	for tilesetIndex in pairs(MapFile.tilesets) do
		setUpTileset(MapFile.tilesets[tilesetIndex])
	end

	-- Done using mapfile data; use only custom structures from here
	MapFile = nil

	-- Initialize world tiles
	print ("Initializing world...")
	updateWorldTiles(0, 0)

	return zMax

end

-- Update number of tiles to display on screen
function World.updateDimension(scale)

	World.displayWidth = math.ceil(love.graphics.getWidth() / World.tileSize / scale) + 1
	World.displayHeight =  math.ceil(love.graphics.getHeight() / World.tileSize / scale) + 1

end

-- Loads set of sprites for tileset and quad tiles to draw on-screen
function setUpTileset(tileset)

	-- Keep track of offset applied to each tileset
	local tilesetOffset = tileset.firstgid

	-- Filter out tilesets used only for in-editor icons
	if tilesetValid(tileset.name) then

		local tilesetImage
		local tileXIndex, tileYIndex, tileZIndex
		local quadsIndex = 0
		local zVal

		-- Create new layer if not already created
		if not (layers[tileset.name]) then layers[tileset.name] = {}  end

		print ("Loading textures for "..tileset.name.." layers")

		tilesetImage = love.graphics.newImage(tileset.image)
		tilesetImage:setFilter("nearest", "nearest") -- force no filtering for pixelated look

		-- Create sprite grid to draw
		for zVal = 1, zMax do
			layers[tileset.name][zVal] = {}
			layers[tileset.name][zVal].spriteSet = love.graphics.newSpriteBatch(tilesetImage, World.displayWidth * World.displayHeight)
		end

		-- Split tileset into its tile pieces (only needed once per texture, so elevation is irrelevant)
		layers[tileset.name].quads = {}

		for tileXIndex = 0, (tileset.imagewidth / tileset.tilewidth) - 1 do
			for tileYIndex = 0, (tileset.imageheight / tileset.tileheight) - 1 do
				layers[tileset.name].quads[quadsIndex] = love.graphics.newQuad(tileYIndex * tileset.tilewidth, tileXIndex * tileset.tileheight, 
															tileset.tilewidth, tileset.tileheight, tileset.imagewidth, tileset.imageheight)
				quadsIndex = quadsIndex + 1
			end
		end
	end

	return tilesetOffset

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

-- Render world, layer by layer
function World.draw(layerType, camX, camY, zVal)

	-- Start with base landscape layer
	love.graphics.draw(layers[layerType][zVal].spriteSet, camX - (camX % World.tileSize), camY - (camY % World.tileSize))

end

-- Re-define sprite batch based on what is visible
function updateWorldTiles(screenTileX, screenTileY)

	local xVal, yVal
	local layerName

	-- Rebuild array of visible world tiles
	for layerName in pairs(layers) do

		-- Rebuild array of tiles to display
		for zVal = 1, zMax do

			-- Clear array of tiles to display
			layers[layerName][zVal].spriteSet:clear()
			for xVal = 0, World.displayWidth - 1 do
				for yVal = 0, World.displayHeight - 1 do
					if (World[xVal + screenTileX][yVal + screenTileY][zVal][layerName]) then
						layers[layerName][zVal].spriteSet:add(layers[layerName].quads[World[xVal + screenTileX][yVal + screenTileY][zVal][layerName] - 1],
									  						  xVal * World.tileSize, yVal * World.tileSize)
					end
				end
			end

			-- Update graphics card as soon as new sprite set is ready
			layers[layerName][zVal].spriteSet:flush()
		end
	end

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

-- Determine layer type being loaded
function getLayerType(layerName)

	local validLayers = {"Base", "Objects", "Collision"}
	local compareIndex
	local layerType

	for compareIndex in pairs(validLayers) do
		if string.find(layerName, validLayers[compareIndex]) then
			layerType = validLayers[compareIndex]
		end
	end

	return layerType

end

-- Determine elevation of layer being loaded
function getElevation(LayerName)

	local start = string.find(LayerName, "_")
	local elevation = tonumber(string.sub(LayerName, start + 1))

	return elevation

end

return World
