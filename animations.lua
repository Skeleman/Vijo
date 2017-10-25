
local Animations = {}

--FIXME: Make setting new animation check if image was loaded and find correct image
function Animations:new(image, width, height, yIndex, frames, duration)

	local xIndex
	local animation = {}

	animation.spriteSheet = image
	animation.quads = {}

	for xIndex in pairs(frames) do
		table.insert(animation.quads, love.graphics.newQuad(frames[xIndex] * width, yIndex * height, width, height, image:getDimensions()))
	end

	animation.duration = duration
	animation.currentTime = 0

	return animation

end

--FIXME: Make setting new animation check if image was loaded and find correct image
function Animations:newStatic(image, width, height, index)

	local xIndex, yIndex, imageWidth
	local animation = {}

	-- Find number of tiles per row
	imageWidth = image:getWidth() / width

	xIndex = index % imageWidth
	yIndex = math.floor(index / imageWidth)

	animation.spriteSheet = image
	animation.quads = {}

	table.insert(animation.quads, love.graphics.newQuad(xIndex * width, yIndex * height, width, height, image:getDimensions()))

	animation.duration = 1
	animation.currentTime = 0

	return animation

end

return Animations
