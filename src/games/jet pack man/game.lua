return {
	standalone_difficulty = "easy",
	--Here go all of the static info values for our game
	--  Remember a comma after each entry, as we are in a table initialization
	
	--Difficulties should be a list of difficulties this game can be.
	--For Example:
	--  If your game going to be a medium difficulty, and can't
	--  be made easier or harder just make it {"medium"}
	
	--  If your game can be made to be easy or impossible,
	--  make it {"easy","impossible"}
	difficulties = {"easy","medium","hard","impossible"},
	
	--PR is how appropriate your game is. Valid values are:
	--  "child"	 approprate to show at imagine RIT
	--  "rit"	   approprate to show to other RIT students
	--  "sse"	   approprate only to show to SSE members
	--  "deans car" this game will be deleted out of the repository on Monday before anyone sees it who wasn't here
	--			  (grab your own local copy)
	PR = "child",
	
	--Keys is an indication to the user that says where to put their hands.
	--It needs to be a list with any values from:
	--  {"arrows","wasd","full keyboard","mouse","space"}
	keys = {"arrows"},
	
	--The longest this game will EVER take. Note: by overriding the isDone method you can end
	--the game sooner. This is just how long until the engine kills your game and asks it for
	--a score by force.
	maxDuration = 15,
	
	--This is where you define what an actual running version of your game is.
	--The first parameter is a table you must fill in with your desired callbacks,
	--as well as any user data. Info is a table with key/values:
	--  difficulty = a value from the difficulties list defined above. You should change at least some aspect
	--			   of how your game is initialized based on this difficulty.
	--
	--  player = some string naming the current player. Don't do anything with this but display it, if even that.
	
	makeGameInstance = function(self, info)
		--Each game may choose how to scale difficulty. The template imposes a time limit
		--that is modified by the difficulty of the game
		self.time_limit = ({easy=15, medium=10, hard=8, impossible=4})[info.difficulty]

    -- Hardon Collider
    local HC = require 'hardoncollider'

    self.hc = HC(100, oc, ocl)

    local oc  = function(dt, a, b, x, y) self:collide(dt, a, b, x, y) end
    local ocl = function(dt, a, b)       self:collide_leave(dt, a, b) end

    -- Classes
    Opening = { }
    function Opening:new(top, bottom)
      o = { top = top, bottom = bottom }
      setmetatable(o, { __index = Opening })
      return o
    end

    JetMan = { gravity = 10, thrust = 14, fire = false,
               horizontal_speed = 12, left = false, right = false }
    function JetMan:new(image, hc)
      o = {
        image = love.graphics.newImage(image),
        y = love.graphics.getHeight() * 0.4,
        x = love.graphics.getWidth() * 0.1
      }

      o.object = hc:addRectangle(o.x + 1,                o.y + 1,
                                 o.image:getWidth() - 1, o.image:getHeight() - 1)
      o.object:moveTo(love.graphics.getWidth() * 0.1,
                     love.graphics.getHeight() * 0.4)
      setmetatable(o, { __index = JetMan })
      return o
    end

    function JetMan:draw()
      love.graphics.draw(self.image, self.x, self.y)
    end

    function JetMan:move(dx, dy)
      self.x = self.x + dx
      self.y = self.y + dy

      self.object:move(dx, dy)
    end

    function JetMan:update(dt)
      if self.left then
        self:move(-self.horizontal_speed * dt, 0) -- negative -> left
      elseif self.right then
        self:move(self.horizontal_speed * dt, 0)  -- positive -> right
      end

      if self.thrust then
        self:move(0, self.thrust * dt)
      else
        self:move(0, -self.gravity * dt)
      end
    end
		
		-- Callbacks
		
		self.getReady = function(self, basePath)
      -- Load hardoncollider
      -- Load Background
      self.background = {
        image  = love.graphics.newImage(basePath .. "cave.jpg")
      }

      self.background.scalex = love.graphics.getWidth() / self.background.image:getWidth()
      self.background.scaley = love.graphics.getHeight() / self.background.image:getHeight()

      -- Set up player
      self.player = JetMan:new(basePath .. "jet-pack.png", self.hc)

			--Aso set up your own initial game state here.
			self.elapsed_time = 0
		end

		self.update = function(self, dt)
      -- Update jet man
      self.player:update(dt)

			--here we just keep track of how much time has passed
			self.elapsed_time = self.elapsed_time+dt			
		end
		
		self.draw = function(self)
			--here we just put how much time is left in the upper left corner
			-- look at https://love2d.org/wiki/love.graphics for fun drawing stuff
			love.graphics.print( (self.time_limit-self.elapsed_time).."s left", 0,0)

      -- Draw background
      love.graphics.draw(self.background.image, 0, 0, 0, self.background.scalex, self.background.scaley)

      -- Draw player
      self.player:draw()
		end

    function self.collide(self, dt, a, b, x, y)
      -- TODO
    end

    function self.collide_leave(self, dt, a, b)
      -- TODO
    end
		
		self.isDone = function(self)
			--This can return true to have the game end sooner that the time_limit
			--set for the type of game.
	
			--we are done when we are out of time.
			return self.elapsed_time > self.time_limit
		end
		
		self.getScore = function(self)
			--return a number -1 to 1. anything >0 is a "passing" score

			return -1 --the player always looses. 
		end
		
		self.keypressed = function(self, key)
			
			print(key.." was pressed")
		end
		
		self.keyreleased = function(self, key)
			print(key.." was released")
		end
	end
}
