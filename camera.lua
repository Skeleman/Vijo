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
  self.x = x or self.x
  self.y = y or self.y
  print ("Width = "..World.width..", tile = "..World.tileSize..", x = "..self.x)
  if(self.x < 0) then
    self.x = 0
  elseif(self.x > World.width * World.tileSize) then
    self.x = World.width * World.tileSize
  end
  if(self.y < 0) then
    self.y = 0
  elseif(self.y > World.height * World.tileSize) then
    self.y = World.height * World.tileSize
  end
end

function Camera:setScale(sx, sy)
  self.scaleX = sx or self.scaleX
  self.scaleY = sy or self.scaleY
end

return Camera
