return {
    
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
	--  "child"     approprate to show at imagine RIT
	--  "rit"       approprate to show to other RIT students
	--  "sse"       approprate only to show to SSE members
	--  "deans car" this game will be deleted out of the repository on Monday before anyone sees it who wasn't here
	--              (grab your own local copy)
    PR = "child",
	
	--Keys is an indication to the user that says where to put their hands.
	--It needs to be a list with any values from:
	--  {"arrows","wasd","full keyboard","mouse"}
    keys = {"arrows"},
	
	--The longest this game will EVER take. Note: by overriding the isDone method you can end
	--the game sooner. This is just how long until the engine kills your game and asks it for
	--a score by force.
	maxDuration = 10,
	
	--This is where you define what an actual running version of your game is.
	--The first parameter is a table you must fill in with your desired callbacks,
	--as well as any user data. Info is a table with key/values:
	--  difficulty = a value from the difficulties list defined above. You should change at least some aspect
	--               of how your game is initialized based on this difficulty.
	--
	--  player = some string naming the current player. Don't do anything with this but display it, if even that.
	
    makeGameInstance = function(self, info)
	
		--Fill the self table with callback and data
		
		
		--Data members
		self.elapsed_time = 0
		
		-- {x, y, radius, update(self,dt,elapsed_time), color}
		self.floating = {}
		self.lost = false
		
		--The easiest way to change a game based on difficulty is to use a changing time limit
		-- The code below creates a table with keys of the possible difficulties, and values of what
		-- the time limit should be based on it.
		self.time_limit = 15
		self.difMod = ({easy=0.5, medium=0.8, hard=1, impossible=1.5})[info.difficulty]
		--Callbacks
		
		self.playing = false
		
		self.getReady = function(self, basePath)
			self.sound = love.audio.newSource(basePath.."back.mp3")
			local difMod = self.difMod
			self.player = {x=love.graphics.getWidth()/2,y=love.graphics.getHeight()/2,radius=4}
			local spiral = function(self,dt,elapsed_time, time_limit)
				local spinx = math.sin(elapsed_time*self.spin_speed*difMod+self.offset)
				local spiny = math.cos(elapsed_time*self.spin_speed*difMod+self.offset)
				
				local scrunch = (1-(elapsed_time/time_limit)*0.25)
				
				local drift = elapsed_time/time_limit*1000*difMod
				
				self.x = spinx*self.r*scrunch+self.bx+drift
				self.y = spiny*self.r*scrunch+self.bx+drift
				
				self.color[3] = 127+127*math.sin(elapsed_time+self.offset*0.05)
			end
			
			local wall = function (self, dt, elapsed_time, time_limit)
				self.color = {127+127*math.sin(elapsed_time+self.offset*0.1),127+127*math.sin(elapsed_time+self.offset*0.05),127+127*math.cos(elapsed_time+self.offset*0.25)}
				self.x = math.sin(elapsed_time)*0.3+self.x
				self.y = math.cos(elapsed_time)*0.3+self.y
			end
			
			local qty = 8
			
			for ring=5,10 do
				for i=1,qty do
					table.insert(self.floating, {bx=love.graphics.getWidth()/2,by=love.graphics.getWidth()/2,
						x=-10,y=-10,radius=5, color={50+ring*20,127,127}, spin_speed=0.5, r=ring*15,end_portion=1,update=spiral,offset=math.pi/(qty/2)*i-math.pi/(qty*4)*ring}
					)
					table.insert(self.floating, {bx=love.graphics.getWidth()/2,by=love.graphics.getWidth()/2,
						x=-10,y=-10,radius=5, color={127,50+ring*20,127}, spin_speed=-1, r=ring*15,end_portion=1,update=spiral,offset=math.pi/(qty/2)*i+math.pi/(qty*4)*ring}
					)
				end
			end
			
			for ring=5,14 do
				for i=qty/2,qty do
					table.insert(self.floating, {bx=0,by=0,
						x=-10,y=-10,radius=5, color={50+ring*20,127,127}, spin_speed=0.5, r=ring*15,end_portion=1,update=spiral,offset=math.pi/(qty/2)*i+math.pi/(qty*4)*ring}
					)
					table.insert(self.floating, {bx=0,by=0,
						x=-10,y=-10,radius=5, color={127,50+ring*20,127}, spin_speed=-0.5, r=ring*15,end_portion=1,update=spiral,offset=math.pi/(qty/2)*i-math.pi/(qty*4)*ring}
					)
				end
			end
			
			for ring=5,10 do
				for i=qty/2,qty do
					table.insert(self.floating, {bx=-love.graphics.getWidth()/2,by=-love.graphics.getWidth()/2,
						x=-10,y=-10,radius=5, color={50+ring*20,127,127}, spin_speed=0.5, r=ring*15,end_portion=1,update=spiral,offset=math.pi/(qty/2)*i+math.pi/(qty*4)*ring}
					)
					table.insert(self.floating, {bx=-love.graphics.getWidth()/2,by=-love.graphics.getWidth()/2,
						x=-10,y=-10,radius=5, color={127,50+ring*20,127}, spin_speed=-1, r=ring*15,end_portion=1,update=spiral,offset=math.pi/(qty/2)*i-math.pi/(qty*4)*ring}
					)
				end
			end
			
			for i=-10,50 do
				table.insert(self.floating, {x=i*5,y=love.graphics.getHeight()/2+i*5,
					radius=10, color={255,0,0}, end_portion=1,update=wall,offset=i}
				)
				table.insert(self.floating, {x=love.graphics.getWidth()-i*5,y=love.graphics.getHeight()/2+i*5,
					radius=10, color={255,0,0}, end_portion=1,update=wall,offset=i}
				)
				table.insert(self.floating, {x=love.graphics.getWidth()-i*5,y=love.graphics.getHeight()/2-i*5,
					radius=10, color={255,0,0}, end_portion=1,update=wall,offset=i}
				)
			end
			
		end
		
		--update is called in between draws. dt is the time in seconds since the last time
		--update was called
		self.update = function(self, dt)
			self.elapsed_time = self.elapsed_time+dt
			
			if not self.playing then
				self.playing = true
				love.audio.play(self.sound)
			end
			
			for i=1,#self.floating do
				self.floating[i]:update(dt, self.elapsed_time, self.time_limit)
			end
			
			if love.keyboard.isDown("up") then
				self.player.y = self.player.y - 100*dt
			end
			if love.keyboard.isDown("down") then
				self.player.y = self.player.y + 100*dt
			end
			if love.keyboard.isDown("left") then
				self.player.x = self.player.x - 100*dt
			end
			if love.keyboard.isDown("right") then
				self.player.x = self.player.x + 100*dt
			end
			
			
			self:checkPlayer()
		end
        
		self.checkPlayer = function(self)
			for i=1,#self.floating do
				local floater = self.floating[i]
				local dx = floater.x-self.player.x
				local dy = floater.y-self.player.y
				if math.sqrt( dx*dx + dy*dy)< floater.radius + self.player.radius then
					self.lost = true
				end
			end
		end
		
		self.draw = function(self)
			for i=1,#self.floating do
				love.graphics.setColor(self.floating[i].color[1],self.floating[i].color[2],self.floating[i].color[3])
				love.graphics.circle("fill",self.floating[i].x,self.floating[i].y,self.floating[i].radius,6)
			end
			
			love.graphics.setColor(255,255,255)
			love.graphics.circle("fill",self.player.x,self.player.y,self.player.radius,6)
			
			
			love.graphics.print("DODGE!",0,0,0,3,3)
		end
		
		self.isDone = function(self)
			return self.elapsed_time > self.time_limit or self.lost
		end
		
		self.getScore = function(self)
			return self.lost and -1 or 1
		end
		
    end
}
