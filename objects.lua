local Objects = {
	ID = {}
}

function Objects.load(ObjFile, DrawList)

	local zVal

	-- Load object images
	print ("Loading object images...")
	-- FIXME: Load object images from names in world file
	spriteSheet = love.graphics.newImage("Assets/objects.png")
	spriteSheet:setFilter("nearest", "nearest")

	-- Create player character FIXME: Load data from save file
	print ("Initializing world objects...")

	-- Create array of objects to draw at given height value
	if not (DrawList[Characters.ID.player.zPos]) then DrawList[Characters.ID.player.zPos] = {} end

	-- Add character to drawing list
	updateDrawOrder(Characters.ID.player, DrawList[Characters.ID.player.zPos], true)

	-- Load non-PC character data, layer by layer
	local layerIndex
	local layerType
	for layerIndex in pairs(ObjFile.layers) do

		-- Only process object layers
		if (ObjFile.layers[layerIndex].type == "objectgroup") then

			-- Get elevation value from layer name
			layerType, zVal = getLayerInfo(ObjFile.layers[layerIndex].name)

			if (layerType == "Characters") then
				local charIndex

				for charIndex in pairs(ObjFile.layers[layerIndex].objects) do
					local obj = ObjFile.layers[layerIndex].objects[charIndex]

					Characters.ID[char.name] = Characters:new(char.name, char.properties.ImageIndex, char.width, char.height,
															  char.properties.Speed, char.x, char.y, zVal)

					updateDrawOrder(Characters.ID[char.name], DrawList[zVal])
				end
			end
		end
	end

end

return Objects
