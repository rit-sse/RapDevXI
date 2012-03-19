local boardSize = 8
local empty = "EMPTY SQUARE - LUA IS TERRIBLE"
local thug = "THUG SQUARE - LUA SHOULD HAVE ENUMS"
local rock = "ROCK SQUARE - LA LA LA la-LUA, LA LA LA la-LUA"
local thug_moved = "lol I suck"
return {
	standalone_difficulty = "impossible",
	difficulties = {"easy","medium","hard","impossible"},
	
	PR = "child",
	
	keys = {"arrows"},
	
	maxDuration = 15,
	
	makeGameInstance = function(self, info)
		self.time_limit = 15
		self.thugs = ({easy=1, medium=3, hard=4, impossible=10})[info.difficulty]
		self.rocks = ({easy=32, medium=20, hard=20, impossible=10})[info.difficulty]
		
		self.getReady = function(self, basePath)
			self.img = {}
			self.img.troy = love.graphics.newImage(basePath.."troy.png")
			self.img.rowsdower = love.graphics.newImage(basePath.."rowsdower.png")
			self.img.thug = love.graphics.newImage(basePath.."thug.png")
			self.img.city = love.graphics.newImage(basePath.."city.png")
			self.img.rock = love.graphics.newImage(basePath.."rock.png")
			--self.image = love.graphics.newImage(basePath.."sprite.png")
			self.sound = love.audio.newSource(basePath.."sound.mp3")
			
			self.grid = {}
			for i=0,boardSize*2-1 do
				self.grid[i] = {}
				for j=0,boardSize*2-1 do
					self.grid[i][j]=empty
				end
			end
			
			self.troy = {x=0,y=0}
			self.rowsdower = {x=1,y=0}
			
			
			
			for i=1,self.thugs do
				self.grid[math.random(boardSize)-1+boardSize][math.random(boardSize)-1] = thug
			end
			for i=1,self.rocks do
				self.grid[math.random(boardSize*2)-1][math.random(boardSize*2)-1] = rock
			end
			for x=0,5 do
				for y=0,5 do
					if self.grid[x][y] ==thug then self.grid[x][y]=empty end
				end
			end
			for x=0,2 do
				for y=0,2 do
					self.grid[x][y]=empty
				end
			end
			for x=boardSize*2-2,boardSize*2-1 do
				for y=boardSize*2-2,boardSize*2-1 do
					self.grid[x][y]=empty
				end
			end
			
			self.elapsed_time = 0
		end

		self.update = function(self, dt)
			if self.sound then
				love.audio.play(self.sound)
				self.sound = nil
			end
			self.elapsed_time = self.elapsed_time+dt			
		end
		
		self.draw = function(self)
			love.graphics.setColor(255,255,255)
			love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
			self:drawgrid()
			
			for x=0,boardSize*2-1 do
				for y=0,boardSize*2-1 do
					if self.grid[x][y] == thug then
						self:drawSprite(x,y,self.img.thug,1)
					end
					if self.grid[x][y] == rock then
						self:drawSprite(x,y,self.img.rock,1000)
					end
				end
			end
			
			self:drawSprite(boardSize*2-2,boardSize*2-2,self.img.city,1)
			self:drawSprite(self.troy.x,self.troy.y,self.img.troy,1)
			self:drawSprite(self.rowsdower.x,self.rowsdower.y,self.img.rowsdower,1)
			
			love.graphics.setColor(0,0,0)
			love.graphics.print("Find the Lost Xeox City!",10, love.graphics.getHeight()-25,0,2,2)
		end
		
		self.drawgrid = function(self)
			love.graphics.setColor(127,127,127)
			local rootx = love.graphics.getWidth()/2-16*boardSize
			local rooty = love.graphics.getHeight()/2-16*boardSize
			
			local size = boardSize*2*16
			
			for i=0,boardSize*2 do
				love.graphics.line(rootx+i*16,rooty,rootx+i*16,rooty+size)
				love.graphics.line(rootx,rooty+i*16,rootx+size,rooty+i*16)
			end
			
		end
		
		self.drawSprite = function(self, x, y, sprite, period)
			
			local screenx = love.graphics.getWidth()/2-16*(boardSize-x)
			local screeny = love.graphics.getHeight()/2-16*(boardSize-y)
			
			
			
			if math.floor(self.elapsed_time/(period/2))%2==0 then
				love.graphics.setColor(255,255,255)
				love.graphics.draw(sprite, screenx+sprite:getWidth()/2, screeny, 0, -0.5, 0.5)
			else
				love.graphics.setColor(255,255,255)
				love.graphics.draw(sprite, screenx, screeny, 0, 0.5, 0.5)
			end
		end
		
		self.isDone = function(self)
			return self.lost or self.won
		end
		
		self.getScore = function(self)
			return self.won and 1 or -1
		end
		
		self.keypressed = function(self, key)
			local turn = false
			if key=='up' then
				turn = true
				if self.rowsdower.y>0 and self.grid[self.rowsdower.x][self.rowsdower.y-1]==empty then
					self.troy.x = self.rowsdower.x
					self.troy.y = self.rowsdower.y
					self.rowsdower.y = self.rowsdower.y-1
				end
			end
			if key=='down' then
				turn = true
				if self.rowsdower.y<boardSize*2 and self.grid[self.rowsdower.x][self.rowsdower.y+1]==empty then
					self.troy.x = self.rowsdower.x
					self.troy.y = self.rowsdower.y
					self.rowsdower.y = self.rowsdower.y+1
				end
			end
			if key=='left' then
				turn = true
				if self.rowsdower.x>0 and self.grid[self.rowsdower.x-1][self.rowsdower.y]==empty then
					self.troy.x = self.rowsdower.x
					self.troy.y = self.rowsdower.y
					self.rowsdower.x = self.rowsdower.x-1
				end
			end
			if key=='right' then
				turn = true
				if self.rowsdower.x<boardSize*2 and self.grid[self.rowsdower.x+1][self.rowsdower.y]==empty then
					self.troy.x = self.rowsdower.x
					self.troy.y = self.rowsdower.y
					self.rowsdower.x = self.rowsdower.x+1
				end
			end
			
			
			if turn then
				self:turn()
			end
		end
		
		self.turn = function(self) do
		
			if self.troy.x > boardSize*2-3 and self.troy.y > boardSize*2-3 then
				self.won = true
			end
		
			for x=0,boardSize*2-1 do
				for y=0,boardSize*2-1 do
					if self.grid[x][y]==thug then
						local dx = x-self.troy.x
						local dy = y-self.troy.y
						
						local nx = 0
						local ny = 0
						
						if math.abs(dx)>math.abs(dy) then
							nx = (dx > 0) and (x-1) or (x+1)
							ny = y
						else
							nx = x
							ny = (dy > 0) and (y-1) or (y+1)
						end
						
						if self.grid[nx][ny] == empty then
							self.grid[nx][ny]=thug_moved
							self.grid[x][y] = empty
						end
					end
				end
			end
			for x=0,boardSize*2-1 do for y=0,boardSize*2-1 do
				if self.grid[x][y]==thug_moved then self.grid[x][y]= thug end end
			end
			for x=0,boardSize*2-1 do for y=0,boardSize*2-1 do
				if self.grid[x][y]==thug then
					if (x==self.troy.x and y==self.troy.y) or (x==self.rowsdower.x and y==self.rowsdower.y) then
						self.lost = true
					end end
				end
			end
		end
		end
		
	end
}
