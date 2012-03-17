local framework = require('framework')

local keyrep = 0.15

local loadGame = function(gameName)
	local gameClass = nil
	if pcall(function()
		gameClass = require("games/"..gameName.."/game")
		
		gameClass.name = gameName --useful to have around later
		
		--Check that all difficulties are recognized difficulties
		local valid_dif = {easy=true,medium=true,hard=true,impossible=true}
		for i=1,#gameClass.difficulties do
			if not valid_dif[gameClass.difficulties[i]] then
				print("rejecting game",gameName,"for unrecognized difficulty setting",gameClass.difficulties[i])
				error()
			end
		end
		
		--Check that the PR setting is recognized
		local valid_pr = {child=true,rit=true,sse=true}
		valid_pr['deans car']=true
		if not valid_pr[gameClass.PR] then
			print("rejecting game",gameName,"for unrecognized PR setting",gameClass.PR)
			error()
		end
		
		--Check that the max duration is in range
		if gameClass.maxDuration==nil or gameClass.maxDuration>30 or gameClass.maxDuration<0 then
			print("rejecting game",gameName,"because max duration is invalid",gameClass.maxDuration)
			error()
		end
		
	end) then
		return gameClass
	else
		print('Could not load game',gameName)
		return nil
	end
end

local initState =  function()
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

    base.keytime = 0
    base.keyed = false
    base.key = ""
    
    base.update = function(self, dt)
	self.keytime = self.keytime - dt
	if self.keytime <0 then
		self.keytime = keyrep
		if self.keyed then
			self:keypressed(self.key)
		end
		
	end
    end
    
    base.draw = function(self)
	local pm = 9
	local by = 15+15*(pm)
	local ny = by+15*(pm+1)+10
	
	love.graphics.setColor(20,20,20)
	love.graphics.rectangle("fill",5,5,love.graphics.getWidth()-10, love.graphics.getWidth()-10)
	love.graphics.setColor(255,255,255)
        love.graphics.rectangle('line',10,by-pm*15-5,love.graphics.getWidth()-20,15*(pm*2+1)+10)
	love.graphics.rectangle('line',10,ny,love.graphics.getWidth()-20,love.graphics.getHeight()-ny-10)
	
	love.graphics.print('>', 5,by)
	love.graphics.print('>', 10,by)
	
        for i=self.currentPosition-pm,self.currentPosition+pm do
		local reali = i
		if reali < 1 then reali = reali+#self.listOfGames end
		if reali > #self.listOfGames then reali = reali-#self.listOfGames end
	
		local color = (self.listOfGames[reali][2]) and 255 or 60
		love.graphics.setColor( color,color,color)
		
		local output = self.listOfGames[reali][1]
		love.graphics.print(output, 20, by+(i-self.currentPosition)*15)
	end
	
	love.graphics.setColor(255,255,255)
        love.graphics.print("Press Left/Right to enable/disable selected game", 15, ny+5)
        love.graphics.print("Press 'a' to select all games", 15, ny+20)
	love.graphics.print("Press 'o' to turn of all games", 15, ny+35)
        love.graphics.print("PRESS ENTER TO CONTINUE", 15, ny+50)
    end 

    base.keypressed = function(self, key)
	self.keyed = true
	self.key = key
	self.keytime = keyrep
    
        if key == 'up' then
            self.currentPosition = ((self.currentPosition -2) % #self.listOfGames)+1
        end
        if key == 'down' then
            self.currentPosition = ((self.currentPosition) % #self.listOfGames)+1
        end
        if key == 'left' or key == 'right' then
            self.listOfGames[self.currentPosition][2] = not self.listOfGames[self.currentPosition][2]
        end
        if key == 'a' then
            for i,game in ipairs(self.listOfGames) do
                game[2] = true
            end
        end
        if key == 'o' then
            for i,game in ipairs(self.listOfGames) do
                game[2] = false
            end
        end
        if key == 'return' then
            framework.gameList = {}
            for i=1,#self.listOfGames do
                if self.listOfGames[i][2] then
                    table.insert(framework.gameList, loadGame(self.listOfGames[i][1]))
                end
            end
            self.done = true
        end
    end 
    
    base.keyreleased = function(self, key)
	self.keyed = false
    end

    framework.mode = framework.modes.chooser
        framework.limit = -1 -- about to be in the game menu, no limit on time
    return base
end

framework.modes.initState = initState
