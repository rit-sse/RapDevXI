return {
	standalone_difficulty = "hard",
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
		self.time_limit = 15

    self.difficulty = info.difficulty
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
    function Wall:new(hc)
      local o = { blocked = { }, x = love.graphics.getWidth() }
      for i= 0, self.max do
        table.insert(o.blocked, false)
      end

      o.object = hc:addRectangle(love.graphics.getWidth(), 0,
                                 self.image:getWidth(), love.graphics.getHeight())
      setmetatable(o, { __index = Wall })
      return o
    end

    function Wall:update(dt, velocity)
      self.x = self.x - velocity * dt
      self.object:move(- velocity * dt, 0)
    end

    function Wall:add_wall(top, bottom)
      for i = top, bottom do self.blocked[i] = true end

      local has_space = false
      for i = top, bottom do has_space = has_space or not self.blocked[i] end

      if has_space == false then
        self.blocked[math.random(#self.blocked - 1) + 1] = false
      end
    end

    function Wall:draw()
      for i = 0, Opening.max do
        if self.blocked[i] then
          love.graphics.draw(self.image, self.x, (i - 1) * self.image:getHeight())
        end
      end
    end


    JetMan = { gravity = 260, thrust = 520, vertical_speed = 0, up = false, down = false,
               horizontal_speed = 96, left = false, right = false }
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

      if self.up then
        self.vertical_speed = self.vertical_speed - self.thrust * dt
      elseif self.down then
        self.vertical_speed = self.vertical_speed + self.thrust * dt
      else
        self.vertical_speed = self.vertical_speed + self.gravity * dt
      end

      self:move(0, self.vertical_speed * dt)
    end
		
		-- Callbacks
		
		self.getReady = function(self, basePath)
      math.randomseed(os.time())

      -- Difficulty stuff
      self.configuration = {
        easy = {
          cooldown_time = 2,
          section_speed = 80,
          opening_width = 4,
          wall_width    = 3
        }, medium = {
          cooldown_time = 1.4,
          section_speed = 120,
          opening_width = 3,
          wall_width    = 4
        }, hard = {
          cooldown_time = 1.0,
          section_speed = 160,
          opening_width = 2,
          wall_width    = 4
        }, impossible = {
          cooldown_time = 0.8,
          section_speed = 220,
          opening_width = 2,
          wall_width    = 5
        }
      }

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
      Wall.max      = math.floor(love.graphics.getHeight() / Wall.image:getHeight())

      -- Setup collection of walls
      self.sections = { }
      self.cooldown = 0

      -- Set up player
      self.player = JetMan:new(basePath .. "jet-pack.png", self.hc)

			--Also set up your own initial game state here.
			self.elapsed_time = 0
		end

		self.update = function(self, dt)
      -- Update jet man
      self.player:update(dt)

      self:check_lose()

      if self.cooldown < 0 then
        self.cooldown = self.configuration[self.difficulty].cooldown_time
        self:add_section()
      end

      for idx, section in pairs(self.sections) do
        section:update(dt, self.configuration[self.difficulty].section_speed)
      end

			--here we just keep track of how much time has passed
			self.elapsed_time = self.elapsed_time + dt
      self.cooldown = self.cooldown - dt

      self.hc:update(dt)
		end

    self.add_section = function(self)
      if math.random() > 0.3 then
        self:add_opening(math.random(1) + 1)
      else
        self:add_wall(math.random(1) + 1)
      end
    end

    function self:add_opening(times)
      local section = Opening:new(self.hc)
      local width = self.configuration[self.difficulty].opening_width

      for i = 0, times do
        local start = math.random(section.max - width)
        local times = math.random(2) + 1

        section:add_opening(start, start + width)
      end

      table.insert(self.sections, section)
    end

    function self:add_wall(times)
      local section = Wall:new(self.hc)
      local width = self.configuration[self.difficulty].wall_width

      for i = 0, times do
        local start = math.random(section.max - width)
        local times = math.random(1) + 1

        section:add_wall(start, start + width)
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

    function self:collide_section(player, opening)
      local height = opening.image:getHeight()
      for idx, blocked in pairs(opening.blocked) do
        if blocked then
          if (idx - 1) * height < player.y and player.y + player.image:getHeight() < idx * height then
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

			local score_ratio = self.elapsed_time / self.time_limit
      local score = 3 * score_ratio - 2

      if score < -1 then return -1 end
      if score > 1  then return 1  end

      return score
		end
		
		self.keypressed = function(self, key)
			if key == 'left'  then self.player.left  = true end
			if key == 'right' then self.player.right = true end
      if key == 'up'    then self.player.up    = true end
      if key == 'down'  then self.player.down  = true end
		end
		
		self.keyreleased = function(self, key)
			if key == 'left'  then self.player.left  = false end
			if key == 'right' then self.player.right = false end
      if key == 'up'    then self.player.up    = false end
      if key == 'down'  then self.player.down  = false end
		end
	end
}
