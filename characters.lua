local Characters = {
	ID = {}
}

local charSprites = {}

-- Game constants
local CHAR_SPEED = 0.6
local ANIM_SPEED = 150
local tileSize = 16			-- FIXME: Import dynamically

local testImage

function Characters.load(CharFile, DrawList)

	local zVal

	-- Associate texture array indices with texture names. Required to account for 'Tiled' layer offsets
	print ("Preparing character textures...")
	local charImageFileIndex
	local charImageFileIndices = {}
	for charImageFileIndex in pairs(CharFile.tilesets) do
		charImageFileIndices[CharFile.tilesets[charImageFileIndex].name] = charImageFileIndex
	end

	-- Load character data and images
	print ("Loading characters...")

	-- Load non-PC character data, layer by layer
	local layerIndex
	local layerType
	for layerIndex in pairs(CharFile.layers) do

		-- Only process object layers
		if (CharFile.layers[layerIndex].type == "objectgroup") then

			-- Get elevation value from layer name
			layerType, zVal = getLayerInfo(CharFile.layers[layerIndex].name)

			-- Only look at map file character layers
			if (layerType == "characters") then
				local charIndex

				-- Loop through all characters in layer
				for charIndex in pairs(CharFile.layers[layerIndex].objects) do

					local char = CharFile.layers[layerIndex].objects[charIndex]
					local charTexFile = "characters_"..math.ceil(char.width / tileSize).."_"..math.ceil(char.height / tileSize)

					-- If new sized of character found, load new sprite sheet
					if not (charSprites[char.width]) then charSprites[char.width] = {} end
					if not (charSprites[char.width][charTileHeight]) then
						charSprites[char.width][char.height] = love.graphics.newImage("Assets/"..charTexFile..".png")
						charSprites[char.width][char.height]:setFilter("nearest", "nearest")
					end

					-- Create character object
					Characters.ID[char.name] = Characters:new(char.name, 
																math.floor((char.gid - CharFile.tilesets[charImageFileIndices[charTexFile]].firstgid) / 
																					(CharFile.tilesets[charImageFileIndices[charTexFile]].imagewidth /
																					 CharFile.tilesets[charImageFileIndices[charTexFile]].tilewidth)), 
																char.width, char.height, 
																char.properties.Speed, char.x, char.y, zVal)

					-- Update drawing list for current character
					if not (DrawList[zVal]) then DrawList[zVal] = {} end

					updateDrawOrder(Characters.ID[char.name], DrawList[zVal], true)

				end
			end
		end
	end

	-- Add character to drawing list FIXME: Get sprite and position data from save file
	Characters.ID.player = Characters:new("player", 2, 16, 32, 100, 1200, 800, 1)
	updateDrawOrder(Characters.ID.player, DrawList[Characters.ID.player.zPos], true)

	print("")

end

function Characters:new(name, spriteIndex, width, height, speed, xPos, yPos, elevation)

	print("Loading character "..name.."...")
	
	-- Create new object
	char = {}

	-- Set alias so other functions can refer to "self"
	setmetatable(char, self)
	self.__index = self

	-- Initialize attributes FIXME: Load from file
	char.name = name			-- Name of character
	char.height = height		-- Character height, in number of pixels (used for collision)
	char.width = width			-- Character width, in number of pixels (used for collision)
	char.direction = "down"		-- Orientation character is facing
	char.state = "idle"			-- Current character action
	char.xPos = xPos			-- Character X-coordinate, in pixels from origin
	char.yPos = yPos			-- Character Y-coordinate, in pixels from origin
	char.zPos = elevation		-- Map Z-coordinate of character
	char.speed = speed			-- Character movement speed
	char.anim = {}				-- Animation representing character

	-- Define animation table for each character action
	char.animationSet = {}
	char.animationSet["idle"] = {}
	char.animationSet["moving"] = {}

	-- Assign animations for all character actions
	-- FIXME: Create lookup of animations per index, not character. Only current animation should be tied to character
	char:setSprite(width, height, spriteIndex)

	-- Assign current animation set
	char.anim = char.animationSet["idle"]["down"]

	return char

end

-- Main function for updating character status
function Characters.update(dt)

	local name

	-- Loop through all characters and update according to all game systems(FIXME: Only apply to visible characters)
	for name in pairs(Characters.ID) do
		-- Move forward in animations
		Characters.ID[name]:advanceAnimationTime(dt)
	end

end

-- Main function for rendering character sprites
function Characters:draw()

	local spriteNum

	-- Determine frame in animation to display
	spriteNum = math.floor(self.anim.currentTime / self.anim.duration * #self.anim.quads) + 1

	-- Draw selected frame -- FIXME: remove division with new variable
	love.graphics.draw(charSprites[self.width][self.height], self.anim.quads[spriteNum],
						self.xPos, self.yPos,
						0, 1, 1, 
						0, self.height - tileSize)

end

-- Update character position. Split by axis so collision need only block one direction of movement
function Characters:move(dt, magnitude, axis, DrawList)

	if (axis == 'x') then self.xPos = self.xPos + self.speed * CHAR_SPEED * dt * magnitude end
	if (axis == 'y') then self.yPos = self.yPos + self.speed * CHAR_SPEED * dt * magnitude end
	updateDrawOrder(self, DrawList)

end

-- Update counter for character's animation (FIXME: generalize to all animations, not just characters)
function Characters:advanceAnimationTime(dt)

	self.anim.currentTime = self.anim.currentTime + dt
	if self.anim.currentTime >= self.anim.duration then
		self.anim.currentTime = self.anim.currentTime - self.anim.duration
	end

end

-- Set new animation for character
function Characters:nextAnimation(reset)

	self.anim = self.animationSet[self.state][self.direction]
	if reset then
		self.anim.currentTime = 0
	end

end

-- Load new set of animations/sizes for character
function Characters:setSprite(width, height, spriteIndex)

	-- Update character dimensions when new sprite is chosen
	self.width = width
	self.height = height

	self.animationSet["idle"]["down"] = newAnimation(charSprites[width][height], width, height, spriteIndex, {0}, 1)
	self.animationSet["idle"]["up"] = newAnimation(charSprites[width][height], width, height, spriteIndex, {3}, 1)
	self.animationSet["idle"]["left"] = newAnimation(charSprites[width][height], width, height, spriteIndex, {6}, 1)
	self.animationSet["idle"]["right"] = newAnimation(charSprites[width][height], width, height, spriteIndex, {9}, 1)
	self.animationSet["moving"]["down"] = newAnimation(charSprites[width][height], width, height, spriteIndex, {1, 0, 2, 0}, self.speed / ANIM_SPEED)
	self.animationSet["moving"]["up"] = newAnimation(charSprites[width][height], width, height, spriteIndex, {4, 3, 5, 3}, self.speed / ANIM_SPEED)
	self.animationSet["moving"]["left"] = newAnimation(charSprites[width][height], width, height, spriteIndex, {7, 6, 8, 6}, self.speed / ANIM_SPEED)
	self.animationSet["moving"]["right"] = newAnimation(charSprites[width][height], width, height, spriteIndex, {10, 9, 11, 9}, self.speed / ANIM_SPEED)

end

-- Determine layer type being loaded FIXME: find way to share this code with the world.lua copy
function getLayerInfo(layerName)

	local start = string.find(layerName, '_')
	local elevation = tonumber(string.sub(layerName, start + 1))
	local layerType = string.sub(layerName, 1, start - 1)

	return layerType, elevation

end

function updateDrawOrder(char, DrawList, newEntry)

	local arrayIndex
	local added = false
	local removed = false

	local entry = {}
	entry.type = "characters"
	entry.name = char.name
	entry.yPos = char.yPos

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
			if (DrawList[arrayIndex].name == entry.name) then
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

return Characters
