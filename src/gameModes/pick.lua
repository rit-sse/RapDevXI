
local makeMode = function()
	
	local mode = {
		games = {},
		sel = 1,
		dif = 1,
		givePick = false, --start opposite as we get the results of the gameMode first
		setGameList = function(self,list)
			self.games = list
		end,
		hasNextGame = function(self)
			return true
		end,
		nextGame = function(self)
			if self.givePick then
				return self.pickGame
			else
				return self.games[self.sel]
			end		
		end,
		nextPlayer = function(self) 
			return "YOU"
		end,
		nextDifficulty = function(self)
			return "easy"
		end,
		setResults = function(self, res) 
			print("got results")
			print(res)
			self.givePick = not self.givePick
		end
	}
	local pickGame = {
		___skipSplash = true,
		makeGameInstance = function(self, info)
			self.selector = mode
			self.draw = function(self)
				love.graphics.setColor(255,255,255)
				love.graphics.print(self.selector.sel..": "..(self.selector.games[self.selector.sel].name),10,200)
				love.graphics.print(self.selector.games[self.selector.sel].difficulties[self.selector.dif],10,200+20)
			end
			self.keypressed = function(self,key)
				if key=='up' then
					self.selector.sel = ((self.selector.sel-2)%(#self.selector.games))+1
					self.selector.dif = 1
				end
				if key=='down' then
					self.selector.sel = ((self.selector.sel)%(#self.selector.games))+1
					self.selector.dif = 1
				end
				if key=='right' then
					self.selector.dif = ((self.selector.dif)%(#self.selector.games[self.selector.sel].difficulties))+1
				end
				if key=='left' then
					self.selector.dif = ((self.selector.dif-2)%(#self.selector.games[self.selector.sel].difficulties))+1
				end
				if key=='return' then
					self.done = true
				end
			end
			self.done = false
			self.isDone = function(self)
				return self.done
			end
		end
	}
	mode.pickGame = pickGame
	return mode
end



return makeMode