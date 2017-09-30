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
  love.graphics.scale(self.scaleX, self.scaleY)
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
  self.x = x or self.x
  self.y = y or self.y
end

function Camera:setScale(sx, sy)
  self.scaleX = sx or self.scaleX
  self.scaleY = sy or self.scaleY
end

function Camera:follow(x, y)
  x = x - love.graphics.getWidth() / 2 / self.scaleX
  y = y - love.graphics.getHeight() / 2 / self.scaleY
  self.x = x < 0 and 0 or (x > (World.width - World.displayWidth) * World.tileSize and (World.width - World.displayWidth + 1) * World.tileSize or x)
  self.y = y < 0 and 0 or (y > (World.height - World.displayHeight) * World.tileSize and (World.height - World.displayHeight + 1) * World.tileSize or y)
  
end

return Camera
