local Characters = {
	ID = {}
}

local spriteSheet

-- Game constants
local CHAR_SPEED = 0.6
local ANIM_SPEED = 150
local tileSize = 16			-- FIXME: Import dynamically

function Characters.load(CharFile, DrawList)

	local zVal

	-- Load character images
	print ("Loading character images...")
	-- FIXME: Load character images from names in world file
	spriteSheet = love.graphics.newImage("Assets/characters_1_2.png")
	spriteSheet:setFilter("nearest", "nearest")

	-- Create player character FIXME: Load data from save file
	print ("Initializing characters...")
	Characters.ID.player = Characters:new("player", 2, 16, 32, 100, 1200, 800, 1)

	-- Create array of objects to draw at given height value
	if not (DrawList[Characters.ID.player.zPos]) then DrawList[Characters.ID.player.zPos] = {} end

	-- Add character to drawing list
	updateDrawOrder(Characters.ID.player, DrawList[Characters.ID.player.zPos], true)

	-- Load non-PC character data, layer by layer
	local layerIndex
	local layerType
	for layerIndex in pairs(CharFile.layers) do

		-- Only process object layers
		if (CharFile.layers[layerIndex].type == "objectgroup") then

			-- Get elevation value from layer name
			layerType, zVal = getLayerInfo(CharFile.layers[layerIndex].name)

			if (layerType == "Characters") then
				local charIndex

				for charIndex in pairs(CharFile.layers[layerIndex].objects) do
					local char = CharFile.layers[layerIndex].objects[charIndex]

					Characters.ID[char.name] = Characters:new(char.name, char.properties.ImageIndex, char.width, char.height,
															  char.properties.Speed, char.x, char.y, zVal)

					if not (DrawList[zVal]) then DrawList[zVal] = {} end
					updateDrawOrder(Characters.ID[char.name], DrawList[zVal])
				end
			end
		end
	end

end

function Characters:new(name, spriteIndex, width, height, speed, xPos, yPos, elevation)

	print("Loading character "..name.."...")
	
	-- Create new object
	char = {}

	-- Set alias so other functions can refer to "self"
	setmetatable(char, self)
	self.__index = self

	-- Initialize attributes FIXME: Load from file
	char.name = name					-- Name of character
	char.height = height				-- Character height, in number of tiles
	char.width = Width					-- Character width, in number of tiles
	char.spriteSize = tileSize			-- Pixel count of one tile for character drawing
	char.direction = "down"				-- Orientation character is facing
	char.state = "idle"					-- Current character action
	char.xPos = xPos					-- Character X-coordinate, in pixels from origin
	char.yPos = yPos					-- Character Y-coordinate, in pixels from origin
	char.zPos = elevation				-- Map Z-coordinate of character
	char.speed = speed					-- Character movement speed
	char.anim = {}						-- Animation representing character

	-- Define animation table for each character action
	char.animationSet = {}
	char.animationSet["idle"] = {}
	char.animationSet["moving"] = {}

	-- Assign animations for all character actions
	-- FIXME: Create lookup of animations per index, not character. Only current animation should be stored on character
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

	-- Draw selected frame
	love.graphics.draw(spriteSheet, self.anim.quads[spriteNum],
						self.xPos, self.yPos,
						0, 1, 1, 
						0, self.height - self.spriteSize)

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

	self.width = width
	self.height = height

	self.animationSet["idle"]["down"]= newAnimation(spriteSheet, width, height, spriteIndex, {0}, 1)
	self.animationSet["idle"]["up"] = newAnimation(spriteSheet, width, height, spriteIndex, {3}, 1)
	self.animationSet["idle"]["left"] = newAnimation(spriteSheet, width, height, spriteIndex, {6}, 1)
	self.animationSet["idle"]["right"] = newAnimation(spriteSheet, width, height, spriteIndex, {9}, 1)
	self.animationSet["moving"]["down"]= newAnimation(spriteSheet, width, height, spriteIndex, {1, 0, 2, 0}, self.speed / ANIM_SPEED)
	self.animationSet["moving"]["up"] = newAnimation(spriteSheet, width, height, spriteIndex, {4, 3, 5, 3}, self.speed / ANIM_SPEED)
	self.animationSet["moving"]["left"] = newAnimation(spriteSheet, width, height, spriteIndex, {7, 6, 8, 6}, self.speed / ANIM_SPEED)
	self.animationSet["moving"]["right"] = newAnimation(spriteSheet, width, height, spriteIndex, {10, 9, 11, 9}, self.speed / ANIM_SPEED)

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
	entry.type = "Characters"
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
