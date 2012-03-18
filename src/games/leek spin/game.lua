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
	keys = {"mouse"},
	
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
		self.time_limit = 10
		
		--Callbacks
		
		self.getReady = function(self, basePath)
			--get ready is called during the splash screen.
			--The intent is to load all sounds and images during getReady

			--Concatenate basePath with any resource names. This makes your game work in both standalone
			--and the main game mode

			--DON'T START SOUNDS IN GET READY! They will begin playing during the splash screen, and
			--be stopped before your game is actually shown

			--self.image = love.graphics.newImage(basePath.."sprite.png")
			--self.sound = love.sound.newSource(basePath.."sound.mp3")
      self.bgm = love.audio.newSource(basePath .. "loituma.mp3")
      self.bgm_on = false

      self.quads = { false, false, false, false }
      self.spins_required = { easy       = 3,
                              medium     = 5,
                              hard       = 7,
                              impossible = 9 }
      self.spins_left = self.spins_required[info.difficulty]
      print(info.difficulty)

      -- Setup background
      self.bg = love.graphics.newImage(basePath .. "bg.png")
      self.leek = {
        image = love.graphics.newImage(basePath .. "leek.png"),
        rotation_center_x = 0.70,
        rotation_center_y = 0.70,
        bg_center_x = 0.50,
        bg_center_y = 0.50
      }

			--Aso set up your own initial game state here.
			self.elapsed_time = 0
		end

    function self:ensure_bgm()
      if not self.bgm_on then
        self.bgm:play()
        self.bgm_on = true
      end
    end

    function self:update_spin_quads()
      local bg_width    = love.graphics.getWidth()
      local bg_height   = love.graphics.getHeight()
      local screen_x    = bg_width  * self.leek.bg_center_x
      local screen_y    = bg_height * self.leek.bg_center_y
      local x = love.mouse.getX() - screen_x
      local y = love.mouse.getY() - screen_y

      if x >=0 and y >= 0 then      -- Quadrant 1
        self.quads[1] = true
      elseif x >=0 and y < 0 then   -- Quadrant 1
        self.quads[2] = true
      elseif x < 0 and y < 0 then   -- Quadrant 1
        self.quads[3] = true
      elseif x < 0 and y >= 0 then  -- Quadrant 1
        self.quads[4] = true
      end

      if self:has_spun() then
        self:reset_quads()
        self.spins_left = self.spins_left - 1
        print(self.spins_left)
      end
    end

    function self:has_spun()
      local has_spun = true

      for q = 1, 4 do
        has_spun = has_spun and self.quads[q]
      end

      return has_spun
    end

    function self:reset_quads()
      for q = 1, 4 do
        self.quads[q] = false
      end
    end

		self.update = function(self, dt)
			--update is called in between draws. dt is the time in seconds since the last time
			--update was called
      self:ensure_bgm()

      self:update_spin_quads()

			--here we just keep track of how much time has passed
			self.elapsed_time = self.elapsed_time+dt			
		end
		
		self.draw = function(self)
			--here we just put how much time is left in the upper left corner
			-- look at https://love2d.org/wiki/love.graphics for fun drawing stuff
			love.graphics.print( (self.time_limit-self.elapsed_time).."s left", 0,0)

      self:draw_background()
      self:draw_leek()
    end

    function self:draw_background()
      local scalex = love.graphics.getWidth() / self.bg:getWidth()
      local scaley = love.graphics.getHeight() / self.bg:getHeight()

      love.graphics.draw(self.bg, 0, 0, 0, scalex, scaley)
    end

    function self:draw_leek()
      local bg_width    = love.graphics.getWidth()
      local bg_height   = love.graphics.getHeight()
      local leek_width  = self.leek.image:getWidth()
      local leek_height = self.leek.image:getHeight()

      local screen_x    = bg_width  * self.leek.bg_center_x
      local screen_y    = bg_height * self.leek.bg_center_y

      local offset_x    = leek_width  * self.leek.rotation_center_x
      local offset_y    = leek_height * self.leek.rotation_center_y

      local radians     = self:getMouseRadians(screen_x, screen_y)

      love.graphics.draw(self.leek.image,
          screen_x, screen_y, radians, 1, 1, offset_x, offset_y)
    end

    function self:getMouseRadians(sx, sy)
      local x = love.mouse.getX() - sx
      local y = love.mouse.getY() - sy

      if x > 0 then
        return math.atan(y / x) + math.pi / 2
      else
        return 3 * math.pi / 2 + math.atan(y / x)
      end
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
	end
}
