return {
	standalone_difficulty = "impossible",
	difficulties = {"easy","medium","hard","impossible"},
	PR = "child",
	keys = {"arrows"},
	maxDuration = 15,
	
	
	makeGameInstance = function(self, info)
		self.time_limit = 15
		self.goal = ({easy=15, medium=10, hard=8, impossible=4})[info.difficulty]
		self.lost = false
		self.score = 0
		self.speed = ({easy=1.0,medium=1.1,hard=1.5,impossible=1.9})[info.difficulty]
		self.freq = ({easy=1,medium=1.5,hard=2,impossible=2.5})[info.difficulty]
		self.count = 0
		self.antSpeed = 200*self.speed
		self.foodSpeed = 250*self.speed
		self.food = {}
		self.lastfood = -1/self.freq
		local HC = require 'hardoncollider'

		on_collision  = function(dt, shape_a, shape_b, mtv_x, mtv_y) 
			self:collision(dt, shape_a, shape_b, mtv_x, mtv_y)
		end
		self.collider = HC(100, on_collision)

		self.getReady = function(self, basePath)
			self.ant = {img1 = love.graphics.newImage(basePath.."ant1.png"), img2=love.graphics.newImage(basePath.."ant2.png"),
				 x = 0, y = 351, colObj= self.collider:addRectangle(0, 351, 49,49)}
			self.ant.cur = self.ant.img1
			self.grass = love.graphics.newImage(basePath.."grass.png")
			self.foodImg = {love.graphics.newImage(basePath.."pancake.png"), love.graphics.newImage(basePath.."waffle.png"),
						love.graphics.newImage(basePath.."frenchtoast.png")}
			self.music = love.audio.newSource(basePath.."waffles.mp3")
			self.eat = love.audio.newSource(basePath.."chomp.mp3")
			self.playing = false
			math.randomseed(os.time())
			self.elapsed_time = 0
		end

		self.update = function(self, dt)
			for i,v in ipairs(self.food) do
				v.y = v.y + self.foodSpeed*dt
				v.colObj:move(0, self.foodSpeed*dt)
			end
			if not self.playing then
				self.playing = true
				love.audio.play(self.music)
			end
			if love.keyboard.isDown("left") then
	            if self.ant.x > 0 then
	                self.ant.x = self.ant.x - dt*self.antSpeed
	                self.ant.colObj:move(-dt*self.antSpeed, 0)
	            end
	        end 
	        if love.keyboard.isDown("right") then
	            if self.ant.x < (400-49) then
	                self.ant.x = self.ant.x + dt*self.antSpeed
	                self.ant.colObj:move(dt*self.antSpeed, 0)
	            end
	        end 
	        if self.elapsed_time > self.lastfood + 1/self.freq then
	        	rx = math.random(0,love.graphics.getWidth()-49)
	        	rn = math.random(1,3)
	        	table.insert(self.food, {hit=false, img=self.foodImg[rn], y = 0, x = rx, colObj=self:mkObj(rx,rn)})
	        	self.lastfood = self.elapsed_time
	        	self:swapAnt()
	        end
			self.elapsed_time = self.elapsed_time+dt
			self.collider:update(dt)
		end

		self.swapAnt = function(self)
			if self.ant.img1 == self.ant.cur then
				self.ant.cur = self.ant.img2
			else
				self.ant.cur = self.ant.img1
			end
		end

		self.mkObj = function(self, x, num)
			local colObj 
			if num == 1 then 
				colObj = self.collider:addCircle(x+24.5, 24.5, 24.5)
			else 
				colObj = self.collider:addRectangle(x, 0, self.foodImg[num]:getWidth(),self.foodImg[num]:getHeight())
			end
			self.collider:addToGroup("food", self.collision_object)
			return colObj
		end	
		
		self.draw = function(self)
			love.graphics.draw(self.grass, 0,0)
			love.graphics.draw(self.ant.cur, self.ant.x, self.ant.y)
			for i,v in ipairs(self.food) do
				if not v.hit  then 
					love.graphics.draw(v.img, v.x, v.y)
				end
			end
			love.graphics.print( (self.time_limit-self.elapsed_time).."s left", 0,0)
		end

		self.collision = function(self, dt, shape_a, shape_b, mtv_x, mtv_y)
			local food
			if shape_a == self.ant.colObj then
				food = shape_b
			else
				food = shape_a
			end
			for i,v in ipairs(self.food) do
				if food == v.colObj then
					v.hit = true
					love.audio.play(self.eat)
				end
			end
		end
		
		self.isDone = function(self)
			return self.elapsed_time > self.time_limit
		end
		
		self.getScore = function(self)
			hit = 0
			for i,v in ipairs(self.food) do
				if v.hit then
					hit = hit+1
				end
			end
			return (hit/#self.food) > .5  and 1 or -1
		end
	end
}
