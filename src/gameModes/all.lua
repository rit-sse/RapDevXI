local mode = {
	games = {},
	i = 1,
	hasNextGame = function(self) {
		return self.i <= #self.games
	},
	nextGame = function(self) {
		return = games[i]	
	},
	nextPlayer = function(self) {
		return "YOU"
	},
	setResults = function(self, res) {
		i+=1
	}
}

return mode;