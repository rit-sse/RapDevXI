local tvimage = love.graphics.newImage("gameModes/flip_data/tv.png")
local makeMode = function() 
	local mode = {
		static = false,
		i = 1,
		baseTime = 2,
		modTime = 1,
		games = {},
		
		setGameList = function(self, list)
			self.games = {}
			for i=1,#list do
				local gameWrapper = {}
				setmetatable(gameWrapper,{__index=list[i]})
				gameWrapper.maxDuration = 1.5
				gameWrapper.makeGameInstance = function(self, info)
					list[i].makeGameInstance(self,info)
					self.isDone = function(self)
						return false
					end
					self.___olddraw = self.draw
					self.draw = function(self)
						love.graphics.setColor(255,255,255)
						pcall(function() self:___olddraw() end)
						love.graphics.setColor(255,255,255)
						love.graphics.draw(tvimage,0,0)
					end
				end
				gameWrapper.___skipSplash = true
				table.insert(self.games, gameWrapper)
			end
		end,
		
		hasNextGame = function(self)
			return true
		end,
		
		nextGame = function(self)
			if self.static then
				return self.staticGame
			else
				self.games[self.i].maxDuration = self.baseTime + self.modTime
				self.modTime = self.modTime*0.7
				return self.games[self.i]
			end
		end,
		
		nextPlayer = function(self)
			return "Viewer"
		end,
		
		nextDifficulty = function(self)
			return self.games[self.i].difficulties[#self.games[self.i].difficulties]
		end,
		
		setResults = function(self, res)
			self.i = math.random(#self.games*100)%#self.games+1
			self.static = not self.static
		end,
		
		
		staticGame = {
			maxDuration = .2,
			___skipSplash = true,
			makeGameInstance = function(self, info) 
				self.getReady = function(self,basepath)
					print('making ready')
					self.elapsed = 0
					self.sound = love.audio.newSource("gameModes/flip_data/static.wav")
					self.images = { love.graphics.newImage("gameModes/flip_data/noise1.png"), love.graphics.newImage("gameModes/flip_data/noise2.png") }
				end
				self.playingSound = false
				self.update = function(self, dt)
					self.elapsed = self.elapsed+dt
					if not self.playingSound then
						print('playing sound',self.sound)
						love.audio.play(self.sound)
						self.playingSound = true
					end
				end
				self.draw = function(self)
					love.graphics.setColor(255,255,255)
					love.graphics.draw(
						self.images[(math.floor(1000*self.elapsed)%2)+1],
						0,0,0,
						love.graphics.getWidth()/400, 
						love.graphics.getHeight()/400,0,0)
					
						love.graphics.setColor(255,255,255)
						love.graphics.draw(tvimage,0,0)
				end
				
			end
		}
	}
	
	
	return mode
end

return makeMode