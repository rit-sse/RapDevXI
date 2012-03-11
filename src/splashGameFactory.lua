local framework = require('framework')
makesplashGame = function(game, gameclass, info)
	local splashGame = {
		ready = false,
		realgame = game,
		gameclass = gameclass,
		geninfo = info,
		elapsed = 0,
		delay = 3,
		update = function(self, dt)
			self.elapsed = self.elapsed+dt
			if not self.ready then
				self.realgame:getReady("games/"..self.gameclass.name.."/")
				self.ready = true
			end
		end,
		draw = function(self)
			local timeLeft = math.floor(self.delay - self.elapsed+0.99)
			
			local twitchf = math.floor( (self.delay-self.elapsed)*20)
			local dx1 = (math.floor(self.elapsed*999)%(twitchf)<3) and 2 or 0
			local dy1 = (math.floor(self.elapsed*777)%(twitchf)<3) and 2 or 0
			
			local dx2 = (math.floor(self.elapsed*444)%(twitchf)<3) and 2 or 0
			local dy2 = (math.floor(self.elapsed*1234)%(twitchf)<3) and 2 or 0
		
			
			love.graphics.setColor(255,255,255)
			
			
			love.graphics.print("STARTS IN: "..timeLeft,10+dx1,love.graphics.getHeight()/2+dy1-40,0,2,2)
			
			love.graphics.print("Put your hands on:",10-dx2,love.graphics.getHeight()/2+dy2,0,1.5,1.5)
			local y = love.graphics.getHeight()/2+20
			
			for i=1,#self.gameclass.keys do
				love.graphics.print(self.gameclass.keys[i],10+dx1,y+dy1,0,1.25,1.25)
				y = y+20
			end
			
		end,
		isDone = function(self)
			return self.elapsed > self.delay
		end,
		___isSplash = true
	}
	setmetatable(splashGame, framework.parentGame)
	
	return splashGame
end
return makesplashGame