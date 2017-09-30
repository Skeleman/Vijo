
local Characters = {
	ID = {}
}

local spriteSheet
local speedScale = 2
local animScale = 0.01

function Characters.initialize()

	-- Load character images
	spriteSheet = love.graphics.newImage("Assets/characters.png")
	spriteSheet:setFilter("nearest", "nearest")

	-- Create player character
	Characters.ID["player"] = Characters:new("player", 16, 2, 1, 2, 100)

end

function Characters:new(name, tileSize, spriteIndex, width, height, speed)

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
	char.xPos = 100				-- Character X-coordinate
	char.yPos = 100				-- Character Y-coordinate
	char.speed = speed			-- Character movement speed
	char.anim = {}				-- Animation representing character

	-- Define animations
	char.animationSet = {}
	char.animationSet["idle"] = {}
	char.animationSet["moving"] = {}

	char.animationSet["idle"]["down"]= newAnimation(spriteSheet, width * tileSize, height * tileSize, spriteIndex, {0}, 1)
	char.animationSet["idle"]["up"] = newAnimation(spriteSheet, width * tileSize, height * tileSize, spriteIndex, {3}, 1)
	char.animationSet["idle"]["left"] = newAnimation(spriteSheet, width * tileSize, height * tileSize, spriteIndex, {6}, 1)
	char.animationSet["idle"]["right"] = newAnimation(spriteSheet, width * tileSize, height * tileSize, spriteIndex, {9}, 1)
	char.animationSet["moving"]["down"]= newAnimation(spriteSheet, width * tileSize, height * tileSize, spriteIndex, {1, 0, 2, 0}, speed * animScale)
	char.animationSet["moving"]["up"] = newAnimation(spriteSheet, width * tileSize, height * tileSize, spriteIndex, {4, 3, 5, 3}, speed * animScale)
	char.animationSet["moving"]["left"] = newAnimation(spriteSheet, width * tileSize, height * tileSize, spriteIndex, {7, 6, 8, 6}, speed * animScale)
	char.animationSet["moving"]["right"] = newAnimation(spriteSheet, width * tileSize, height * tileSize, spriteIndex, {10, 9, 11, 9}, speed * animScale)

	-- Assign current animation set
	char.anim = char.animationSet["idle"]["down"]

	return char

end

function Characters.update(dt)

	local name

	-- Update player based on user input
	if love.keyboard.isDown("up") then
		Characters.ID["player"]:move(dt, "up")
	end
	if love.keyboard.isDown("down") then
		Characters.ID["player"]:move(dt, "down")
	end
	if love.keyboard.isDown("left") then
		Characters.ID["player"]:move(dt, "left")
	end
	if love.keyboard.isDown("right") then
		Characters.ID["player"]:move(dt, "right")
	end

	-- Loop through all characters and update according to all game systems(FIXME: Only apply to visible characters)
	for name in pairs(Characters.ID) do
		-- Move forward in animations
		Characters.ID[name]:updateAnimationTime(dt)
	end
end

function Characters:updateAnimationTime(dt)
	self.anim.currentTime = self.anim.currentTime + dt
	if self.anim.currentTime >= self.anim.duration then
		self.anim.currentTime = self.anim.currentTime - self.anim.duration
	end
end

function Characters:nextAnimation(reset)
	self.anim = self.animationSet[self.state][self.direction]
	if reset then
		self.anim.currentTime = 0
	end
end

function Characters:move(dt, direction)

	local distance = self.speed * speedScale * dt

	if (direction == "up") then
		self.yPos = self.yPos - distance
	elseif (direction == "down") then
		self.yPos = self.yPos + distance
	elseif (direction == "left") then
		self.xPos = self.xPos - distance
	else
		self.xPos = self.xPos + distance
	end

end

function Characters.draw()


	local spriteNum

	-- Loop through all created characters
	for name in pairs(Characters.ID) do

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

return Characters
