return {
	standalone_difficulty = "impossible",
	difficulties = {"easy","medium","hard","impossible"},
	PR = "child",
	keys = {"mouse"},
	maxDuration = 30,
	makeGameInstance = function(self, info)
		self.time_limit = ({easy=30, medium=30, hard=30, impossible=30})[info.difficulty]
		self.lava_speed = ({easy=12, medium=14, hard=16, impossible=20})[info.difficulty]
		self.rock_rate = ({easy=30, medium=25, hard=20, impossible=15})[info.difficulty]
		self.rock_rad = ({easy=25, medium=30, hard=35, impossible=40})[info.difficulty]
		self.gravity = ({easy=10, medium=12, hard=14, impossible=16})[info.difficulty]
		self.stun_period = ({easy=5, medium=4, hard=3, impossible=1})[info.difficulty]
		self.seek_rate = ({easy=30, medium=29, hard=28, impossible=27})[info.difficulty]
		self.init_vel = ({easy=20, medium=15, hard=10, impossible=5})[info.difficulty]

		self.bottom = 0
		self.lava = {y = 10}

		self.hasFloor = true
		self.floor = {x = 0, y = 50} 

		self.died = false
		self.person = {x = 150, y = 100, dx = 0, dy = 0, h = 20, r = 10}
		self.person.dy = self.init_vel

		self.curRock = nil
		self.lastRock = 400
		self.rocks = {
			{x = 50, y = 150,  r = 15, seeking = false},
			--{x = 250, y = 150, r = 15, seeking = false},
			--{x = 50, y = 200,  r = 15, seeking = false},
			{x = 250, y = 200, r = 15, seeking = false},
			{x = 50, y = 250,  r = 15, seeking = false},
			--{x = 250, y = 250, r = 15, seeking = false},
			--{x = 50, y = 300,  r = 15, seeking = false},
			{x = 250, y = 300, r = 15, seeking = false},
			{x = 50, y = 350,  r = 15, seeking = false},
			--{x = 250, y = 350, r = 15, seeking = false},
			--{x = 50, y = 400,  r = 15, seeking = false},
			{x = 250, y = 400, r = 15, seeking = false}
		}

		self.messages = {
			{"Climb",    0, .5, 170, 110},
			{"Climb",    0, .5, 170, 140},
			{"Climb",    0, .5, 170, 170},
			{"------->", 0, .5, 170, 200},
			{"Climb",    .75, 1.25, 170, 110},
			{"Climb",    .75, 1.25, 170, 140},
			{"Climb",    .75, 1.25, 170, 170},
			{"------->", .75, 1.25, 170, 200},
			{"!Climb!",    1.5, 5, 140, 110},
			{"!Climb!",    1.5, 5, 140, 140},
			{"!Climb!",    1.5, 5, 140, 170}
		}
			

		self.curTime = 0
		self.lastColl = -10

		math.randomseed(os.time())
		
		self.revCoord = function(self, x, y)
			local newx = x
			local newy = y
			local height = love.graphics.getHeight()

			newy = height - newy
			newy = newy + self.bottom

			--print("Translated "..x..", "..y.." to "..newx..", "..newy)
			return newx, newy
		end

		self.transCoord = function(self, x, y)
			local newx = x
			local newy = y - self.bottom
			local height = love.graphics.getHeight()
			newy = height - newy

			--print("Translated "..x..", "..y.." to "..newx..", "..newy)
			return newx, newy
		end

		self.getReady = function(self, basePath)
			--self.image = love.graphics.newImage(basePath.."sprite.png")
			--self.sound = love.audio.newSource(basePath.."sound.mp3")
			self.magnet = love.graphics.newImage(basePath.."magnet.png")
			self.music = love.audio.newSource(basePath.."windmill.mp3")
			self:transCoord(self.person.x, self.person.y)
			self.elapsed_time = 0
		end

		self.moveLava = function(self, dt)
			self.lava.y = self.lava.y + self.lava_speed * dt

			if self.lava.y < self.bottom then
				self.lava.y = self.lava.y + self.lava_speed * dt
			end
		end

		self.moveFloor = function(self, dt)
			-- nope, not necessary.  the floor doesn't move!
		end

		self.movePerson = function(self, dt)
			-- bottom is based on person
			self.bottom = self.person.y - 100

			self.person.dy = self.person.dy - self.gravity * dt

			local colliding = self:overlapsAny(self.person)

			if colliding and self.lastColl + self.stun_period < self.curTime then
				self.person.dy = self.person.dy / 2
				self.person.dx = self.person.dx / 2
				self.lastColl = self.curTime
			end

			-- Grabbing a rock?
			if self.curRock and not colliding then
				if self.person.x < self.curRock.x then
					self.person.dx = self.person.dx + self.seek_rate * dt
				elseif self.person.x > self.curRock.x then
					self.person.dx = self.person.dx - self.seek_rate * dt
				end

				if self.person.y < self.curRock.y then
					self.person.dy = self.person.dy + self.seek_rate * dt
				elseif self.person.y > self.curRock.y then
					self.person.dy = self.person.dy - self.seek_rate * dt
				end
			end

			-- On the floor?
			if self.person.y - self.person.r <= self.floor.y then
				self.person.y = self.floor.y + self.person.r
				self.person.dy = math.max(0, self.person.dy)
			end

			local width = love.graphics.getWidth()
			if self.person.x + self.person.r >= width then
				print(math.min(self.person.dx, -self.person.dx))
				self.person.dx = math.min(self.person.dx, -self.person.dx)
			end
			if self.person.x - self.person.r <= 0 then
				print(math.min(self.person.dx, -self.person.dx))
				self.person.dx = math.max(self.person.dx, -self.person.dx)
			end

			self.person.y = self.person.y + self.person.dy * dt
			self.person.x = self.person.x + self.person.dx * dt

			if self.person.y - self.person.r <= self.lava.y then
				-- todo play audio
				self.died = true
			end
		end

		self.makeRocks = function(self, dt)
			if self.lastRock < self.bottom + 450 then
				local rockx = math.random(25, 375)
				local rocky = self.bottom + 450
				local rockr = math.random(4, self.rock_rad)

				table.insert(self.rocks, {x = rockx, y = rocky, r = rockr, false})

				self.lastRock = rocky + 50
			end
		end

		self.updateMouse = function(self)
			self.mouse = {x = love.mouse.getX(), y = love.mouse.getY()}
		end

		self.update = function(self, dt)
			if self.music then love.audio.play(self.music); self.music = nil end

			self:moveLava(dt)
			self:moveFloor(dt)
			self:movePerson(dt)
			self:makeRocks(dt)
			self:updateMouse(dt)

			self.curTime = self.curTime + dt
		end
		
		self.drawLava = function(self)
			local lavax, lavay = self:transCoord(0, self.lava.y)
			love.graphics.setColor(255, 0, 0)
			love.graphics.rectangle('fill', 0, lavay, 400, 400)
		end

		self.drawFloor = function(self)
			local floorx, floory = self:transCoord(0, self.floor.y)
			love.graphics.setColor(183, 143, 143)
			love.graphics.rectangle('fill', 0, floory, 400, 400)
		end

		self.drawPerson = function(self)
			local x, y = self:transCoord(self.person.x, self.person.y)
			love.graphics.setColor(0, 255, 0)
			love.graphics.circle('fill', x, y, self.person.r, 20)
		end

		self.drawRock = function(self, rock)
			local x, y = self:transCoord(rock.x, rock.y)

			if self.curRock and self.curRock == rock then
				love.graphics.setColor(195, 33, 72)
				love.graphics.circle('fill', x, y, rock.r)
			else
				love.graphics.setColor(183, 143, 143)
				love.graphics.circle('fill', x, y, rock.r)
				love.graphics.setColor(0, 0, 0)
				love.graphics.circle('fill', x + rock.r / 2 - 2, y + rock.r / 2 - 2, rock.r - 2)
			end
		end

		self.drawRocks = function(self)
			for i,rock in ipairs(self.rocks) do
				self:drawRock(rock)
			end
		end

		self.drawMouse = function(self)
			if self.mouse then
				love.graphics.draw(self.magnet, self.mouse.x - 5, self.mouse.y - 5)
			end
		end

		self.drawMessages = function(self)
			for i,msg in ipairs(self.messages) do
				if msg[2] < self.curTime and msg[3] > self.curTime then
					love.graphics.print(msg[1], msg[4], msg[5], 0, 1.4, 1.4)
				end
			end
		end

		self.draw = function(self)
			self:drawFloor()
			self:drawRocks()
			self:drawPerson()
			self:drawLava()
			self:drawMouse()
			self:drawMessages()
		end
		
		self.isDone = function(self)
			--This can return true to have the game end sooner that the time_limit
			--set for the type of game.
	
			--we are done when we are out of time.
			return self.died
		end
		
		self.getScore = function(self)
			return self.died and -1 or 1
		end

		self.overlaps = function(self, c1, c2)
			local xdiff = math.abs(c1.x - c2.x)
			local ydiff = math.abs(c1.y - c2.y)
			local r = c1.r + c2.r

			return math.sqrt((xdiff * xdiff) + (ydiff * ydiff)) < r
		end

		self.overlapsAny = function(self, c1)
			for i,rock in ipairs(self.rocks) do
				if self:overlaps(c1, rock) then
					return rock
				end
			end

			return nil
		end
		
		self.keypressed = function(self, key)
			print(key.." was pressed")
		end
		
		self.keyreleased = function(self, key)
			print(key.." was released")
		end

		self.mousepressed = function(self, x, y, button)
			local x, y = self:revCoord(x, y)
			self.curRock = self:overlapsAny({x = x, y = y, r = 5})
			
			if self.curRock then
				self.curRock.seeking = true
			end
		end

		self.mousereleased = function(self, x, y, button)
			self.curRock = nil
		end
	end
}
