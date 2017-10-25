local Entities = require("entities")
local Animations = require("animations")

local Characters = Entities:new()

-- Game constants
local CHAR_SPEED = 0.6
local ANIM_SPEED = 150
local tileSize = 16			-- FIXME: Import dynamically

function Characters:new(ID, name, image, xPos, yPos, elevation, width, height, index, speed, oldEntity)

	print("Loading character "..name.."...")
	
	-- Create new object
	char = {}

	-- Set alias so other functions can refer to "self"
	setmetatable(char, self)
	self.__index = self

	-- Initialize attributes FIXME: Load from file
	char.ID = ID				-- Unique identifier number
	char.name = name			-- Name of character
	char.height = height		-- Character height, in number of pixels (used for collision)
	char.width = width			-- Character width, in number of pixels (used for collision)
	char.direction = "down"		-- Orientation character is facing
	char.state = "idle"			-- Current character action
	char.xPos = xPos			-- Character X-coordinate, in pixels from origin
	char.yPos = yPos			-- Character Y-coordinate, in pixels from origin
	char.zPos = elevation		-- Map Z-coordinate of character
	char.speed = speed			-- Character movement speed
	char.sprite = {}			-- Animation representing character

	-- Assign animations for all character actions
	-- FIXME: Create lookup of animations per index, not character. Only current animation should be tied to character
	char:setSprite(image, width, height, index)

	return char

end

-- Main function for updating character status
-- function Characters:update(dt)
-- end

-- Update character position. Split by axis so collision need only block one direction of movement
function Characters:move(dt, magnitude, axis, DrawList)

	if (axis == 'x') then self.xPos = self.xPos + self.speed * CHAR_SPEED * dt * magnitude end
	if (axis == 'y') then self.yPos = self.yPos + self.speed * CHAR_SPEED * dt * magnitude end
	updateDrawOrder(self, DrawList)

end

-- Set new animation for character
function Characters:nextAnimation(reset)

	self.sprite = self.animationSet[self.state][self.direction]
	if reset then
		self.sprite.currentTime = 0
	end

end

-- Load new set of animations/sizes for character
function Characters:setSprite(image, width, height, spriteIndex)

	-- Update character dimensions when new sprite is chosen
	self.width = width
	self.height = height

	-- Define animation table for each character action
	char.animationSet = {}
	char.animationSet["idle"] = {}
	char.animationSet["moving"] = {}

	-- Build animation library for charater
	self.animationSet["idle"]["down"] = Animations:new(image, width, height, spriteIndex, {0}, 1)
	self.animationSet["idle"]["up"] = Animations:new(image, width, height, spriteIndex, {3}, 1)
	self.animationSet["idle"]["left"] = Animations:new(image, width, height, spriteIndex, {6}, 1)
	self.animationSet["idle"]["right"] = Animations:new(image, width, height, spriteIndex, {9}, 1)
	self.animationSet["moving"]["down"] = Animations:new(image, width, height, spriteIndex, {1, 0, 2, 0}, self.speed / ANIM_SPEED)
	self.animationSet["moving"]["up"] = Animations:new(image, width, height, spriteIndex, {4, 3, 5, 3}, self.speed / ANIM_SPEED)
	self.animationSet["moving"]["left"] = Animations:new(image, width, height, spriteIndex, {7, 6, 8, 6}, self.speed / ANIM_SPEED)
	self.animationSet["moving"]["right"] = Animations:new(image, width, height, spriteIndex, {10, 9, 11, 9}, self.speed / ANIM_SPEED)

	-- Assign current animation set
	char.sprite = char.animationSet[self.state][self.direction]

end

return Characters
