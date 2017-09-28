
local Characters = {
	ID = {}
}

local spriteSheet
local speedScale = 100

function Characters.initialize()

	-- Load character images
	spriteSheet = love.graphics.newImage("Assets/characters.png")
	spriteSheet:setFilter("nearest", "nearest")

	-- Create player character
	Characters.ID["player"] = Characters:new("player", 0, 16, 32, 100)

end

function Characters:new(name, type, width, height, speed)

	-- Create new object
	char = {}

	-- Set alias so other functions can refer to "self"
	setmetatable(char, self)
	self.__index = self

	-- Initialize attributes
	char.name = name			-- Name of character
	char.direction = "down"		-- Orientation character is facing
	char.state = "idle"			-- Current character action
	char.xPos = 100				-- Character X-coordinate
	char.yPos = 100				-- Character Y-coordinate
	char.speed = speed			-- Character movement speed
	char.anim = {}				-- Animation representing character

	-- Define animations
	char.animationSet = {}
	char.animationSet["idle"] = {}
	char.animationSet["moving"] = {}

	char.animationSet["idle"]["down"]= newAnimation(spriteSheet, width, height, type, {0}, 1)
	char.animationSet["idle"]["up"] = newAnimation(spriteSheet, width, height, type, {3}, 1)
	char.animationSet["idle"]["left"] = newAnimation(spriteSheet, width, height, type, {6}, 1)
	char.animationSet["idle"]["right"] = newAnimation(spriteSheet, width, height, type, {9}, 1)
	char.animationSet["moving"]["down"]= newAnimation(spriteSheet, width, height, type, {1, 0, 2, 0}, speed / speedScale)
	char.animationSet["moving"]["up"] = newAnimation(spriteSheet, width, height, type, {4, 3, 5, 3}, speed / speedScale)
	char.animationSet["moving"]["left"] = newAnimation(spriteSheet, width, height, type, {7, 6, 8, 6}, speed / speedScale)
	char.animationSet["moving"]["right"] = newAnimation(spriteSheet, width, height, type, {10, 9, 11, 9}, speed / speedScale)

	-- Assign current animation set
	char.anim = char.animationSet["idle"]["down"]

	return char

end

function Characters:updateAnimation(reset)

	self.anim = self.animationSet[self.state][self.direction]

	if reset then
		self.anim.currentTime = 0
	end

end

function Characters.draw(scale)

	local spriteNum

	-- Loop through all created characters
	for name in pairs(Characters.ID) do

		-- Determine frame in animation to display
		spriteNum = math.floor(Characters.ID[name].anim.currentTime / Characters.ID[name].anim.duration * #Characters.ID[name].anim.quads) + 1
		-- Draw selected frame
		love.graphics.draw(spriteSheet, Characters.ID[name].anim.quads[spriteNum], Characters.ID[name].xPos, Characters.ID[name].yPos, 0, scale, scale)

	end

end

return Characters
