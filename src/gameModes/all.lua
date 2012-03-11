local makeMode = function() 
	local mode = {
		games = {},
		i = 0,
		setGameList = function(self,list)
			self.games = list
		end,
		hasNextGame = function(self)
			return self.i <= #self.games
		end,
		nextGame = function(self)
			return self.games[self.i]
		end,
		nextPlayer = function(self) 
			return "YOU"
		end,
		nextDifficulty = function(self)
			return self.games[self.i].difficulties[1]
		end,
		setResults = function(self, res) 
			print("got results")
			print(res)
			self.i = self.i+1
		end
	}

	return mode
end

return makeMode
