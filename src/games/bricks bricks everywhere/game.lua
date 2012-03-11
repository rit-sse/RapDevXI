return {
    
	--Here go all of the static info values for our game
	--  Remember a comma after each entry, as we are in a table initialization
	
	--Difficulties should be a list of difficulties this game can be.
	--For Example:
	--  If your game going to be a medium difficulty, and can't
	--  be made easier or harder just make it {"medium"}
	
	--  If your game can be made to be easy or impossible,
	--  make it {"easy","impossible"}
	difficulties = {"easy","easy","medium","hard","impossible"},
	
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
	maxDuration = 15,
	
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
		self.playerX = 0
		self.bricks = {}
		self.lost = false
		self.playingSound = false
		
		
		--Constants
		self.playerWidth = 10
		self.playerHeight = 5
		self.brickSpeed = ({easy=200, medium=200, hard=200, impossible=400})[info.difficulty]
		self.playerSpeed = self.brickSpeed
		self.brickWidth = 10
		self.brickHeight = 15
		
		
		self.time_limit = ({easy=6, medium=8, hard=10, impossible=15})[info.difficulty]
		self.maxBricks = ({easy=20, medium=60, hard=100, impossible=250})[info.difficulty]
		
		self.timePerBrick = (self.time_limit/self.maxBricks)
		
		--Callbacks
		self.getReady = function(self, basePath)
			self.playerX = love.graphics.getWidth()/2
			self.sound = love.audio.newSource(basePath.."dun da da dun dun.mp3")
		end
		
		
		--update is called in between draws. dt is the time in seconds since the last time
		--update was called
		self.update = function(self, dt)
			if not self.playingSound then
				love.audio.play(self.sound)
				self.playingSound = true
			end
			
			self.elapsed_time = self.elapsed_time+dt
			self:updatePlayer(dt)
			self:updateBricks(dt)
			
			if (self.elapsed_time/self.timePerBrick) > #self.bricks then
				self:addBrick()
			end
			self:checkBricks()
		end
		
		self.checkBricks = function(self)
			for i=1,#self.bricks do
				local brick = self.bricks[i]
				local player = {x=self.playerX, y=love.graphics.getHeight()-self.playerHeight}
				if math.abs(brick.x - player.x)<(self.playerWidth+self.brickWidth) and
					math.abs(brick.y-player.y)<(self.playerHeight+self.brickHeight) then
						self.lost = true
				end
				
			end
		end
		
		self.addBrick = function(self)
			table.insert(self.bricks, 
			{x=math.random(self.brickWidth,love.graphics.getWidth()-self.brickWidth),
			y=0})
		
		end
		
		self.updateBricks = function(self, dt)
			for i=1,#self.bricks do
				self.bricks[i].y = self.bricks[i].y+self.brickSpeed*dt
			end
		end
		
		self.updatePlayer = function(self, dt)
			if love.keyboard.isDown("left") then
				self.playerX = self.playerX - dt*self.playerSpeed
			end
			if love.keyboard.isDown("right") then
				self.playerX = self.playerX + dt*self.playerSpeed
			end
			if self.playerX < self.playerWidth then
				self.playerX = self.playerWidth
			end
			if self.playerX > (love.graphics.getWidth()-self.playerWidth) then
				self.playerX = (love.graphics.getWidth()-self.playerWidth)
			end
		end
        
		self.draw = function(self)
			--here we just put how much time is left in the upper left corner
			love.graphics.print( string.format("%.1fs Left!",self.time_limit-self.elapsed_time), 0,0)
			love.graphics.setColor(255,255,255)
			love.graphics.rectangle( "fill", 
				self.playerX-self.playerWidth,
				love.graphics.getHeight()-self.playerHeight,
				self.playerWidth*2,
				self.playerHeight)
			
			self:drawBricks()
		end
		
		self.drawBricks = function(self)
			love.graphics.setColor(100,20,20)
			for i=1,#self.bricks do
				local brick = self.bricks[i]
				
				
				love.graphics.rectangle("fill",
					brick.x-self.brickWidth,
					brick.y-self.brickHeight,
					2*self.brickWidth,
					2*self.brickHeight)
			end
		end
		
		
		self.isDone = function(self)
			--we are done when we are out of time.
			return (self.elapsed_time > self.time_limit) or self.lost
		end
		
		self.getScore = function(self)
			return self.lost and -1 or 1
		end
		
    end
}
