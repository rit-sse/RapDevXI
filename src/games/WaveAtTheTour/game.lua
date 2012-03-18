
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
	maxDuration = 12,
	
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
		self.time_limit = ({easy=20, medium=12, hard=8, impossible=7})[info.difficulty]
		
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
			self.move = true
			--Aso set up your own initial game state here.
			self.img = {}
                        self.img.hand = love.graphics.newImage(basePath.."hand01.png")
			self.img.leg = love.graphics.newImage(basePath.."leg2.png")
			self.img.leg2 = love.graphics.newImage(basePath.."leg2.png")
			self.img.body = love.graphics.newImage(basePath.."leg2.png")
			self.img.face = love.graphics.newImage(basePath.."face.png")
			self.img.hand1 = love.graphics.newImage(basePath.."hand01.png")		
			self.img.hand2 = love.graphics.newImage(basePath.."hand01.png")
			self.img.hand3 = love.graphics.newImage(basePath.."hand01.png")
			self.img.hand4 = love.graphics.newImage(basePath.."hand01.png")
			self.img.hand5 = love.graphics.newImage(basePath.."hand01.png")
			self.faceX = 6
			self.faceY = 6
			self.faceS = .7
			self.bodyX = 35
			self.bodyY = 25
			self.bodyT = math.pi/6
			self.legX = 80
			self.legY = 25
			self.legT = math.pi/3
			self.leg2X = 80
			self.leg2Y = 25
			self.leg2T = 0
			self.elapsed_time = 0
                        self.handY =300
                        self.handX =300
			self.handT = math.pi
		end

		self.update = function(self, dt)
			
			if love.keyboard.isDown("right") and not love.keyboard.isDown("left") then --rotates right leg
				if self.handT <= 22*math.pi/21 then
				self.handT = self.handT + dt
				self.faceY = self.faceY + dt*50
				if self.move == true then
					
					self.legT = self.legT - dt/2
					self.leg2T = self.leg2T + dt/2
                                        self.legY = self.legY + dt*50
					self.leg2Y = self.leg2Y + dt*50
					self.bodyY = self.bodyY + dt*50
					if self.legT <= 0 then
						self.move = false
					end
				else
					self.legY = self.legY + dt*50
                             		self.leg2Y = self.leg2Y + dt*50
					self.legT = self.legT + dt/2
					self.leg2T = self.leg2T - dt/2
					self.bodyY = self.bodyY + dt*50

					if self.legT >= math.pi/6 then
						
						self.move = true
					end
				end
				end
			end
			if love.keyboard.isDown("left") and not love.keyboard.isDown("right") then
				
				if self.handT >= 20*math.pi/21 then
				self.handT = self.handT - dt
				self.faceY = self.faceY + dt*50
				if self.move == true then
					
					self.legT = self.legT - dt/2
					self.leg2T = self.leg2T + dt/2
                                        self.legY = self.legY + dt*50
					self.leg2Y = self.leg2Y + dt*50
					self.bodyY = self.bodyY + dt*50

					if self.legT <= 0 then
						self.move = false
					end
				else
					self.legY = self.legY + dt*50
                             		self.leg2Y = self.leg2Y + dt*50
					self.legT = self.legT + dt/2
					self.leg2T = self.leg2T - dt/2
					self.bodyY = self.bodyY + dt*50
					if self.legT >= math.pi/6 then
						
						self.move = true
					end
				end

			end
			
			
			
			
                        
			
			
			
			end










		
			--update is called in between draws. dt is the time in seconds since the last time
			--update was called

			--here we just keep track of how much time has passed
			self.elapsed_time = self.elapsed_time+dt			
		end
		
		self.draw = function(self)

			love.graphics.setColor(127,127,127)
			love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
			love.graphics.setColor(255,255,255)
			--here we just put how much time is left in the upper left corner
			-- look at https://love2d.org/wiki/love.graphics for fun drawing stuff
			love.graphics.draw(self.img.leg,self.legY,self.legX,self.legT,1,1)
			love.graphics.draw(self.img.leg2,self.leg2Y,self.leg2X,self.leg2T,1,1)
			love.graphics.draw(self.img.body,self.bodyY,self.bodyX,self.bodyT,1,1)
			love.graphics.print( (self.time_limit-self.elapsed_time).."s left", 0,0)
			love.graphics.draw(self.img.hand,self.handY,self.handX,self.handT,1,1)
			love.graphics.draw(self.img.face,self.faceY,self.faceX,0,self.faceS,1)
			love.graphics.draw(self.img.hand1,self.handY-220,self.handX-130,self.handT,1,1)
			love.graphics.draw(self.img.hand2,self.handY-100,self.handX-120,self.handT,1,1)
			love.graphics.draw(self.img.hand3,self.handY-135,self.handX-90,self.handT,1,1)
			love.graphics.draw(self.img.hand4,self.handY,self.handX-130,self.handT,1,1)
			love.graphics.draw(self.img.hand5,self.handY-200,self.handX-10,self.handT,1,1)
		end
		
		self.isDone = function(self)
			--This can return true to have the game end sooner that the time_limit
			--set for the type of game.
			if self.leg2Y-15 > love.graphics.getWidth() then
				return true
			end
			--we are done when we are out of time.
			return self.elapsed_time > self.time_limit
		end
		
		self.getScore = function(self)
			--return a number -1 to 1. anything >0 is a "passing" score
			if self.leg2Y-15 > love.graphics.getWidth() then
				return 1
			else
				return -1 --the player always looses. 
			end
		end
		

		






	end
}
