local Entities = {
}

local Animations = require("animations")
local sprites = {}

local tileSize = 16			-- FIXME: Import dynamically

function Entities:new(oldEntity)

	print("Running entity constructor")

	-- If an entity was passed, replace it. Otherwise, allocate more memory for new object
    local entity = oldEntity or {}

	-- Set alias so other functions can refer to "self"
    setmetatable(entity, self)
    self.__index = self

    return entity

end

-- Main function for rendering character sprites
function Entities:draw()

	local spriteNum

	-- Determine frame in animation to display
	spriteNum = math.floor(self.sprite.currentTime / self.sprite.duration * #self.sprite.quads) + 1

	-- Draw selected frame -- FIXME: remove division with new variable
	love.graphics.draw(self.sprite.spriteSheet, self.sprite.quads[spriteNum],
						self.xPos, self.yPos,
						0, 1, 1, 
						0, self.height - tileSize)

end

-- Set new animation for character
function Entities:nextAnimation(reset)

	self.sprite = self.animationSet[self.state]
	if reset then
		self.sprite.currentTime = 0
	end

end

-- Load new set of animations/sizes for character
function Entities:setSprite(image, width, height, spriteIndex)

	-- Update character dimensions when new sprite is chosen
	self.width = width
	self.height = height

	-- Define animation table for each character action
	self.animationSet = {}
	self.animationSet["idle"] = {}

	-- Select image for entity
	self.animationSet["idle"] = Animations:newStatic(image, width, height, spriteIndex, {0}, 1)

	-- Assign current animation set
	self.sprite = self.animationSet[self.state]

end

return Entities
