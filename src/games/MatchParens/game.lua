return {
	standalone_difficulty = "impossible",
	difficulties = {"easy","medium","hard","impossible"},
	PR = "rit",
	keys = {"numbers"},
	maxDuration = 7,
	makeGameInstance = function(self, info)
		self.time_limit = ({easy=7, medium=7, hard=7, impossible=7})[info.difficulty]

		--Callbacks

		
		self.getReady = function(self, basePath)
			self.elapsed_time = 0
			self.wrong = love.audio.newSource(basePath.."wrong.mp3")
			self.demotivation = love.graphics.newImage(basePath.."wrong.jpg")
			self.strings = ({
				easy = {
					{"()(((", 3},
					{"(()(", 2},
					{"()()((()))", 0}
				},
				medium = {
					{"(((((())(", 4},
					{"()(()())(()", 1},
					{"(()()(()())(", 2}
				},
				hard = {
					{"()(()(()(()(()()))(", 3},
					{"(((()()))((()((()(", 6},
					{"()(()(()()(((()(())", 5}
				},
				impossible = {
					{"(((()())(())()))((()()))(", 1},
					{"(((()()))((()((()())(()(", 6}
				}
			})[info.difficulty]

			self.answers = {
				"N/A",
				")", 
				"))", 
				")))", 
				"))))", 
				")))))", 
				"))))))"
			}

			print(math.random(1, #self.strings))
			math.randomseed(os.time())
			print(math.random(1, #self.strings))
			local choice = math.random(1, #self.strings)
			self.string = self.strings[choice]

			self.useranswer = 0
		end

		self.update = function(self, dt)
			if not self.playing then
				love.audio.play(self.wrong)
				self.playing = true
			end

			self.elapsed_time = self.elapsed_time+dt
		end
		
		self.draw = function(self)
			love.graphics.draw(self.demotivation, 138, 0)

			love.graphics.print("Match", 25, 180, 0, 2, 2)
			love.graphics.print("the", 30, 230, 0, 2, 2)
			love.graphics.print("parens!", 25, 280, 0, 2, 2)

			love.graphics.print(" >>> "..self.string[1], 25, 330, 0, 1.7, 1.7)

			if self.userinput then
				love.graphics.print(self.userinput, 325, 330, 0, 1.7, 1.7)
			end
		end
		
		self.isDone = function(self)
			--This can return true to have the game end sooner that the time_limit
			--set for the type of game.
	
			--we are done when we are out of time.
			return self.elapsed_time > self.time_limit or self.doneearly
		end
		
		self.getScore = function(self)
			return self.useranswer == self.string[2] and 1 or -1
		end
		
		self.keypressed = function(self, key)
			if key == "backspace" and self.useranswer and self.useranswer > 0 then
				self.useranswer = self.useranswer - 1
				self.userinput = self.answers[self.useranswer + 1]
			end
			if key == "=" and self.useranswer and self.useranswer < 6 then
				self.useranswer = self.useranswer + 1
				self.userinput = self.answers[self.useranswer + 1]
			end
			if tonumber(key) and tonumber(key) + 1 then
				self.useranswer = tonumber(key)
				self.userinput = self.answers[self.useranswer + 1]
			end
			if key == "return" then
				self.doneearly = true
			end
			print(key.." was pressed")
		end
		
		self.keyreleased = function(self, key)
			print(key.." was released")
		end
	end
}
