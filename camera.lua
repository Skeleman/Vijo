Camera = {
  x = 1,
  y = 1,
  scaleX = 1,
  scaleY = 1,
  rotation = 0,
  target = "player"
}

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

function Camera:follow(x, y, size, width, height, displayWidth, displayHeight, tileSize)
  x = x - love.graphics.getWidth() / 2 / self.scaleX + size / 2
  y = y - love.graphics.getHeight() / 2 / self.scaleY + size / 2
  self.x = x < 0 and 0 or (x > (width - displayWidth) * tileSize and (width - displayWidth) * tileSize or x)
  self.y = y < 0 and 0 or (y > (height - displayHeight) * tileSize and (height - displayHeight) * tileSize or y)
  
end

return Camera
