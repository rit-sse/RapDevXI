--[[ 
    Framework
--]]

local framework = {
    currentGame = nil,
    parentGame = {
        __index = {
        getReady = function(self) end,
        update = function(self, dt) end,
        draw = function(self) end,
        keypressed = function(self, key) end,
        keyreleased = function(self, key) end,
        mousepressed = function(self, x, y, button) end,
        mousereleased = function(self, x, y, button) end,
        getScore = function(self) return -1 end,
        isDone = function(self) return false end 
    }},
    selectedGames = {},
    outOfGame = nil,
    gameMode = nil, 
    gameList = {}
}

initMode = function()
    local base = {}
    local gameNames = require('listOfGames')
    
    base.listOfGames = {}
    setmetatable(base, framework.parentGame)
    for i=1,#gameNames do
        table.insert(base.listOfGames,{gameNames[i], false})
    end
    base.currentPosition = 1
    base.done = false
    base.isDone = function(self)
        return self.done
    end

    base.draw = function(self, dt)
        love.graphics.setColor(255,255,255)
        output = self.currentPosition..": "
        output = output..self.listOfGames[self.currentPosition][1].." | "
        output = output..((self.listOfGames[self.currentPosition][2]) and "on" or "off")
        love.graphics.print(output, 10, love.graphics.getHeight()/2)
        love.graphics.print("PRESS ENTER TO CONTINUE", 10, (love.graphics.getHeight()/2)+20)
    end 

    base.keypressed = function(self, key)
        if key == 'up' then
            self.currentPosition = ((self.currentPosition -2) % #self.listOfGames)+1
        end
        if key == 'down' then
            self.currentPosition = ((self.currentPosition) % #self.listOfGames)+1
        end
        if key == 'left' or key == 'right' then
            self.listOfGames[self.currentPosition][2] = not self.listOfGames[self.currentPosition][2]
        end
        if key == 'return' then
            framework.gameList = {}
            for i=1,#self.listOfGames do
                if self.listOfGames[i][2] then
                    table.insert(framework.gameList, require("games/"..self.listOfGames[i][1].."/game"))
                end
            end
            self.done = true
        end
    end 

    framework.mode = chooser

    return base
end

chooser = function()
    local base = {}
    base.modeNames = require('gameModes')
    
    setmetatable(base, framework.parentGame)
    base.currentPosition = 1
    base.done = false
    base.isDone = function(self)
        return self.done
    end

    base.draw = function(self, dt)
        love.graphics.setColor(255,255,255)
        output = self.currentPosition..": "
        output = output..self.modeNames[self.currentPosition]
        love.graphics.print(output, 10, love.graphics.getHeight()/2)
        love.graphics.print("PRESS ENTER TO CONTINUE", 10, (love.graphics.getHeight()/2)+20)
    end 

    base.keypressed = function(self, key)
        if key == 'up' then
            self.currentPosition = ((self.currentPosition -2) % #self.modeNames)+1
        end
        if key == 'down' then
            self.currentPosition = ((self.currentPosition) % #self.modeNames)+1
        end
        if key == 'return' then
            framework.gameMode = require('gameModes/'..self.modeNames[self.currentPosition])()
			framework.gameMode:setGameList(framework.gameList)
            self.done = true
        end
    end 
    framework.mode = rungames

    return base
end

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
				self.realgame:getReady()
				self.ready = true
			end
		end,
		draw = function(self)
			local dx1 = (math.floor(self.elapsed*100)%5==0) and 1 or 0
			local dy1 = (math.floor(self.elapsed*100)%5==3) and 1 or 0
			
			local dx2 = (math.floor(self.elapsed*100)%5==1) and 1 or 0
			local dy2 = (math.floor(self.elapsed*100)%5==4) and 1 or 0
		
			love.graphics.setColor(255,255,255)
			local timeLeft = math.floor(self.delay - self.elapsed+0.99)
			
			love.graphics.print("STARTS IN: "..timeLeft,10+dx1,love.graphics.getHeight()/2+dy1)
			
			love.graphics.print("Put your hands on:",10+dx2,love.graphics.getHeight()/2+40+dy2)
			local y = love.graphics.getHeight()/2+60
			
			for i=1,#self.gameclass.keys do
				love.graphics.print(self.gameclass.keys[i],10+dx1,y+dy1)
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

rungames = function()
	if framework.currentGame ~= nil then 
		if framework.currentGame.___isSplash then
			return framework.currentGame.realgame
		else
			framework.gameMode:setResults(framework.currentGame:getScore())
		end
	end
	
	if framework.gameMode:hasNextGame() then
		local gameClass = framework.gameMode:nextGame()
		local game = {}
		setmetatable(game, framework.parentGame)
		local info = {
			difficulty = framework.gameMode:nextDifficulty(),
			player = framework.gameMode:nextPlayer()
		}
		gameClass.makeGameInstance(game, info)
		
		return makesplashGame(game,gameClass, info)
	else
		print('out of games')
		return chooser()
	end
end

framework.mode = initMode

function love.load()
    love.graphics.setMode(400,400,false,true,0)
    framework.currentGame = base
    
end

function love.update(dt)
    if framework.currentGame ~= nil then
        framework.currentGame:update(dt)
    end
    if framework.currentGame == nil or framework.currentGame:isDone() then
        print("swapping")
        framework.currentGame = framework.mode()
    end
end

function love.draw()
    if framework.currentGame ~= nil then
        framework.currentGame:draw()
    end
end

function love.keypressed(key)
    if framework.currentGame ~= nil then
        framework.currentGame:keypressed(key)
    end
    if key == "escape" then
        love.event.push('q')
    end
end

function love.keyreleased(key)
    if framework.currentGame ~= nil then
        framework.currentGame:keyreleased(key)
    end
end

function love.mousepressed(x, y, button)
    if framework.currentGame ~= nil then
        framework.currentGame:mousepressed(x, y, button)
    end
end

function love.mousereleased(x, y, button)
    if framework.currentGame ~= nil then
        framework.currentGame:mousereleased(x, y, button)
    end
end
