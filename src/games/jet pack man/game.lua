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

    self.lost = false

    -- Hardon Collider
    self.HC = require 'hardoncollider'

    oc  = function(dt, a, b, x, y) self:collide(dt, a, b, x, y) end
    ocl = function(dt, a, b)       self:collide_leave(dt, a, b) end

    self.hc = self.HC(100, oc, ocl)


    -- Classes
    Opening = { class = 'opening' }
    function Opening:new(hc)
      local o = { blocked = { }, x = love.graphics.getWidth() }
      for i=0, self.max do
        table.insert(o.blocked, true)
      end

      o.object = hc:addRectangle(love.graphics.getWidth(), 0,
                                 self.image:getWidth(), love.graphics.getHeight())
      setmetatable(o, { __index = Opening })
      return o
    end

    function Opening:update(dt, velocity)
      self.x = self.x - velocity * dt
      self.object:move(- velocity * dt, 0)
    end

    function Opening:add_opening(top, bottom)
      for i = top, bottom do self.blocked[i] = false end
    end

    function Opening:draw()
      for i = 0, Opening.max do
        if self.blocked[i] then
          love.graphics.draw(self.image, self.x, (i - 1) * self.image:getHeight())
        end
      end
    end

    Wall = { class = 'wall' }
    function Wall:new(top, bottom)
      o = { top = top, bottom = bottom }
      setmetatable(o, { __index = Wall })
      return o
    end

    JetMan = { gravity = 160, thrust = 320, vertical_speed = 0, fire = false,
               horizontal_speed = 48, left = false, right = false }
    function JetMan:new(image, hc)
      local o = {
        image = love.graphics.newImage(image)
      }
      o.y = love.graphics.getHeight() * 0.4 - o.image:getHeight() * 0.5
      o.x = love.graphics.getWidth() * 0.1 - o.image:getWidth() * 0.5

      o.object = hc:addRectangle(o.x,                o.y,
                                 o.image:getWidth(), o.image:getHeight())
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

      if self.fire then
        self.vertical_speed = self.vertical_speed - self.thrust * dt
      else
        self.vertical_speed = self.vertical_speed + self.gravity * dt
      end

      self:move(0, self.vertical_speed * dt)
    end
		
		-- Callbacks
		
		self.getReady = function(self, basePath)
      -- Load Background
      self.background = {
        image  = love.graphics.newImage(basePath .. "cave.jpg")
      }

      self.background.scalex = love.graphics.getWidth() / self.background.image:getWidth()
      self.background.scaley = love.graphics.getHeight() / self.background.image:getHeight()

      -- Class setup
      Opening.image = love.graphics.newImage(basePath .. "wall.png")
      Wall.image    = love.graphics.newImage(basePath .. "wall.png")
      Opening.max   = math.floor(love.graphics.getHeight() / Opening.image:getHeight())

      -- Setup collection of walls
      self.sections = { }
      self.cooldown_start = 3
      self.cooldown = 0

      -- Set up player
      self.player = JetMan:new(basePath .. "jet-pack.png", self.hc)

			--Aso set up your own initial game state here.
			self.elapsed_time = 0
		end

		self.update = function(self, dt)
      -- Update jet man
      self.player:update(dt)
      self.hc:update(dt)

      self:check_lose()

      if self.cooldown < 0 then
        self.cooldown = self.cooldown_start
        self:add_section()
      end

      for idx, section in pairs(self.sections) do
        section:update(dt, 86)
      end

			--here we just keep track of how much time has passed
			self.elapsed_time = self.elapsed_time + dt
      self.cooldown = self.cooldown - dt
		end

    self.add_section = function(self)
      local section = Opening:new(self.hc)
      local start = 0
      local times = 0

      for i = 0, times do
        start = math.random(section.max - 5)
        times = math.random(2) + 1

        section:add_opening(start, start + 5)
      end

      table.insert(self.sections, section)
    end

		self.draw = function(self)
			--here we just put how much time is left in the upper left corner
			-- look at https://love2d.org/wiki/love.graphics for fun drawing stuff
			love.graphics.print( (self.time_limit-self.elapsed_time).."s left", 0,0)

      -- Draw background
      love.graphics.draw(self.background.image, 0, 0, 0, self.background.scalex, self.background.scaley)

      -- Draw player
      self.player:draw()

      -- Draw sections
      for idx, section in pairs(self.sections) do
        section:draw()
      end

		end

    self.check_lose = function(self)
      self.lost = self.lost or self.player.x < -1 * self.player.image:getWidth() * 0.5
                            or self.player.x > love.graphics.getWidth() - self.player.image:getWidth() * 0.5
                            or self.player.y < -1 * self.player.image:getHeight() * 0.5
                            or self.player.y > love.graphics.getHeight() - self.player.image:getHeight() * 0.5

      return self.lost
    end

    function self:collide(dt, a, b, x, y)
      if a == self.player.object then
        self:collide_section(self.player, self:getSectionFromPolygon(b))
      elseif b == self.player.object then
        self:collide_section(self:getSectionFromPolygon(b), self.player)
      end
    end

    function self:getSectionFromPolygon(polygon)
      for idx, section in pairs(self.sections) do
        if section.object == polygon then
          return section
        end
      end

      return nil
    end

    function self:collide_section(player, section)
      if section.class == 'opening' then
        self:collide_opening(player, section)
      end
    end

    function self:collide_opening(player, opening)
      local height = opening.image:getHeight()
      for idx, blocked in pairs(opening.blocked) do
        if blocked then
          if (idx - 1) * height < player.y and player.y < idx * height then
            self.lost = true
          end
        end
      end
    end

    function self:collide_leave(dt, a, b)
    end
		
		self.isDone = function(self)
			--This can return true to have the game end sooner that the time_limit
			--set for the type of game.
	
			--we are done when we are out of time.
			return self.elapsed_time > self.time_limit or self.lost
		end
		
		self.getScore = function(self)
			--return a number -1 to 1. anything >0 is a "passing" score

			return -1 --the player always looses. 
		end
		
		self.keypressed = function(self, key)
			if key == 'left'  then self.player.left  = true end
			if key == 'right' then self.player.right = true end
      if key == 'up'    then self.player.fire  = true end
		end
		
		self.keyreleased = function(self, key)
			if key == 'left'  then self.player.left  = false end
			if key == 'right' then self.player.right = false end
      if key == 'up'    then self.player.fire  = false end
		end
	end
}
