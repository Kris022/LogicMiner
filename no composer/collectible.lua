-- Define the Collectable class
local Collectable = {}

-- Create a new instance of the Collectable class
function Collectable:new(x, y, row, col)
  -- Create a new table for the object instance
  local object = {x = x, y = y, row = row, col = col}

  -- Set the object's metatable to the class's metatable
  setmetatable(object, self)
  self.__index = self

  -- Return the new object instance
  return object
end


function Collectable:setGridPos(row, col)
    -- Set the object's x and y coordinates to the new values
    self.row = row
    self.col = col
  end

-- Define the setDir method for the Collectable class
function Collectable:setDir(newX, newY)
  -- Set the object's x and y coordinates to the new values
  self.x = newX
  self.y = newY
end
