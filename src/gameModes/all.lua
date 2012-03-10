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
			print('making a game')
			print(self.i)
			local g = {}
			self.games[self.i].makeGameInstance(g, {difficulty='easy'} )
			return g
		end,
		nextPlayer = function(self) 
			return "YOU"
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