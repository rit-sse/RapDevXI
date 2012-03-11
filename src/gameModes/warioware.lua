local makeMode = function() 
	local mode = {
		games = {},
		numgames = 0,
		curgame = 0,
		lives = 3,
		setGameList = function(self,list)
			self.numgames = #list
			self.lives = 3

			self.games.easy = {}
			self.games.medium = {}
			self.games.hard = {}
			self.games.impossible = {}

			self.hasdif = function(self, game, dif)
				for i,gamedif in ipairs(game.difficulties) do
					if gamedif == dif then
						table.insert(self.games[dif], game)
					end
				end
			end
			for i,game in ipairs(list) do
				self:hasdif(game, "easy")
				self:hasdif(game, "medium")
				self:hasdif(game, "hard")
				self:hasdif(game, "impossible")
			end
		end,
		hasNextGame = function(self)
			return self.curgame <= 20 and self.lives > 0
		end,
		nextGame = function(self)
			self.dif = "impossible"
			if self.curgame <= 5 then
				self.dif = "easy"
			elseif self.curgame <= 10 then
				self.dif = "medium"
			elseif self.curgame <= 15 then
				self.dif = "hard"
			end

			return self:chooseGame(self.dif)
		end,
		nextPlayer = function(self) 
			return "YOU"
		end,
		nextDifficulty = function(self)
			return self.dif
		end,
		setResults = function(self, res) 
			if self.curgame == 0 then
				self.curgame = 1
				return
			end

			--print("got results")
			--print(res)
			if res < 0 then
				print("Lost a game!")
				self.lives = self.lives - 1
			else
				print("Won a game")
			end
			self.curgame = self.curgame+1
		end,
		
		draw = function(self)
			love.graphics.print(""..self.lives,love.graphics.getWidth()-30,30,0,3,3)
		end
	}

	chooseGame = function(self, dif)
		if #self.games[dif] == 0 then
			return self.chooseGame(self:lowerDif(dif))
		end

		return self.games[dif][math.random(1, #self.games[dif])]
	end

	lowerDif = function(self, dif)
		if dif == "easy" then
			return "impossible"
		elseif dif == "medium" then
			return "easy"
		elseif dif == "hard" then
			return "medium"
		end
		return "hard"
	end

	mode.chooseGame = chooseGame
	mode.lowerDif = lowerDif
	return mode
end

return makeMode
