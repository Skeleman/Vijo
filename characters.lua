local Characters = {
	ID = {}
}

local spriteSheet

-- Game constants
local speedScale = 1
local animScale = 150
local tileSize = 16

function Characters.load()

	-- Load character images
	print ("Loading character images...")
	spriteSheet = love.graphics.newImage("Assets/characters.png")
	spriteSheet:setFilter("nearest", "nearest")

	-- Create player character
	print ("Initializing characters...")
	Characters.ID["player"] = Characters:new("player", 2, 1, 2, 100)

end

function Characters:new(name, spriteIndex, width, height, speed)

	-- Create new object
	char = {}

	-- Set alias so other functions can refer to "self"
	setmetatable(char, self)
	self.__index = self

	-- Initialize attributes
	char.name = name			-- Name of character
	char.height = height		-- Character height, in number of tiles
	char.width = width			-- Character width, in number of tiles
	char.spriteSize = tileSize	-- Pixel count of one tile for character drawing
	char.direction = "down"		-- Orientation character is facing
	char.state = "idle"			-- Current character action
	char.xPos = 1200			-- Character X-coordinate
	char.yPos = 800				-- Character Y-coordinate
	char.zPos = 1				-- Character elevation
	char.speed = speed			-- Character movement speed
	char.anim = {}				-- Animation representing character

	-- Define animation table for each character action
	char.animationSet = {}
	char.animationSet["idle"] = {}
	char.animationSet["moving"] = {}

	-- Assign animations for all character actions
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
function Characters.draw(camX, camY, elevation)

	local spriteNum

	-- Loop through all created characters
	for name in pairs(Characters.ID) do
		if (Characters.ID[name].zPos == elevation) then
			-- Determine frame in animation to display
			spriteNum = math.floor(Characters.ID[name].anim.currentTime / Characters.ID[name].anim.duration * #Characters.ID[name].anim.quads) + 1
			-- Draw selected frame
			love.graphics.draw(spriteSheet, Characters.ID[name].anim.quads[spriteNum],
								Characters.ID[name].xPos, 
								Characters.ID[name].yPos,
								 0, 1, 1,
								(Characters.ID[name].width * Characters.ID[name].spriteSize / 2),
								(Characters.ID[name].height * Characters.ID[name].spriteSize / 2))
		end
	end

end

-- Update character position
function Characters:moveX(dt, xDir)

	self.xPos = self.speed * speedScale * dt * xDir


end

function Characters:move(xPos, yPos)

	self.xPos = xPos
	self.yPos = yPos

end

-- Clamp character to tile boundaries
function Characters:clamp(xDir, yDir, tileSize)

	if (xDir > 0) then
		self.xPos = math.ceil(self.xPos / tileSize) * tileSize
	elseif (xDir < 0) then
		self.xPos = math.floor(self.xPos / tileSize) * tileSize
	end

	if (yDir > 0) then
		self.yPos = math.ceil(self.yPos / tileSize) * tileSize
	elseif (yDir < 0) then
		self.yPos = math.floor(self.yPos / tileSize) * tileSize
	end

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

	self.animationSet["idle"]["down"]= newAnimation(spriteSheet, width * tileSize, height * tileSize, spriteIndex, {0}, 1)
	self.animationSet["idle"]["up"] = newAnimation(spriteSheet, width * tileSize, height * tileSize, spriteIndex, {3}, 1)
	self.animationSet["idle"]["left"] = newAnimation(spriteSheet, width * tileSize, height * tileSize, spriteIndex, {6}, 1)
	self.animationSet["idle"]["right"] = newAnimation(spriteSheet, width * tileSize, height * tileSize, spriteIndex, {9}, 1)
	self.animationSet["moving"]["down"]= newAnimation(spriteSheet, width * tileSize, height * tileSize, spriteIndex, {1, 0, 2, 0}, self.speed / animScale)
	self.animationSet["moving"]["up"] = newAnimation(spriteSheet, width * tileSize, height * tileSize, spriteIndex, {4, 3, 5, 3}, self.speed / animScale)
	self.animationSet["moving"]["left"] = newAnimation(spriteSheet, width * tileSize, height * tileSize, spriteIndex, {7, 6, 8, 6}, self.speed / animScale)
	self.animationSet["moving"]["right"] = newAnimation(spriteSheet, width * tileSize, height * tileSize, spriteIndex, {10, 9, 11, 9}, self.speed / animScale)

end


return Characters
