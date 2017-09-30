Camera = {
  x = 1,
  y = 1,
  scaleX = 1,
  scaleY = 1,
  rotation = 0,
  mode = "followPlayer"
}

local World = require("world")

function Camera:set()   
  love.graphics.push()
  love.graphics.rotate(-self.rotation)
  love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
  love.graphics.translate(-self.x, -self.y)
end

function Camera:unset()
  love.graphics.pop()
end

function Camera:move(dx, dy)
  self.x = self.x + (dx or 0)
  self.y = self.y + (dy or 0)
end

function Camera:rotate(dr)
  self.rotation = self.rotation + dr
end

function Camera:scale(sx, sy)
  sx = sx or 1
  self.scaleX = self.scaleX * sx
  self.scaleY = self.scaleY * (sy or sx)
end

function Camera:setPosition(x, y)
  self.x = x < 0 and 0 or (x > World.width * World.tileSize and (World.width + 1) * World.tileSize or x)
  self.y = y < 0 and 0 or (y > World.height * World.tileSize and (World.height + 1) * World.tileSize or y)
end

function Camera:setScale(sx, sy)
  self.scaleX = sx or self.scaleX
  self.scaleY = sy or self.scaleY
end

return Camera
