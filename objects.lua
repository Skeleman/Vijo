local Entities = require("entities")
local Animations = require("animations")

local Objects = Entities:new()

local ANIM_SPEED = 1.5
local tileSize = 16			-- FIXME: Import dynamically

function Objects:new(ID, image, xPos, yPos, elevation, width, height, index, oldEntity)

	print("Loading object "..ID.."...")
	
	-- Create new object
	object = {}

	-- Set alias so other functions can refer to "self"
	setmetatable(object, self)
	self.__index = self

	-- Initialize attributes FIXME: Load from file
	object.ID = ID				-- Object unique identifier
	object.height = height		-- object height, in number of pixels (used for collision)
	object.width = width		-- object width, in number of pixels (used for collision)
	object.state = "idle"		-- Current object action -- FIXME: Design better scheme for static vs. animated objects
	object.xPos = xPos			-- object X-coordinate, in pixels from origin
	object.yPos = yPos			-- object Y-coordinate, in pixels from origin
	object.zPos = elevation		-- Map Z-coordinate of object
	object.sprite = {}			-- Animation representing object

	-- Assign animations for all object actions
	-- FIXME: Create lookup of animations per index, not object. Only current animation should be tied to object
	object:setSprite(image, width, height, index)

	return object

end

function Entities:update(dt)

	self.sprite.currentTime = self.sprite.currentTime + dt
	if(self.sprite.currentTime > self.sprite.duration) then
		self.sprite.currentTime = self.sprite.currentTime - self.sprite.duration
	end

end

return Objects
