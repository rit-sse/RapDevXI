local framework = require('framework')

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
                    table.insert(framework.gameList, loadGame(self.listOfGames[i][1]))
                end
            end
            self.done = true
        end
    end 

    framework.mode = framework.modes.chooser
	framework.limit = -1 -- about to be in the game menu, no limit on time
    return base
end

framework.modes.initState = initState