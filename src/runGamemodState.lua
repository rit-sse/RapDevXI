local framework = require('framework')
local makesplashGame = require('splashGameFactory')

local rungames = function()
	if framework.currentGame ~= nil then 
		if framework.currentGame.___isSplash then
			return framework.currentGame.realgame
		else
			framework.gameMode:setResults(framework.currentGame:getScore())
		end
	end
	
	if framework.gameMode:hasNextGame() then
		local gameClass = nil
		pcall(function() gameClass = framework.gameMode:nextGame() end)
		framework.limit = gameClass.maxDuration
		print('set duration to',framework.limit)
		local game = {}
		setmetatable(game, framework.parentGame)
		local info = {
			difficulty = framework.gameMode:nextDifficulty(),
			player = framework.gameMode:nextPlayer()
		}
		
		pcall(function() gameClass.makeGameInstance(game, info) end)
		
		if gameClass.___skipSplash then
			pcall(function() game:getReady() end)
			return game
		else
			return makesplashGame(game,gameClass, info)
		end
	else
		framework.limit = -1
		return framework.modes.chooser()
	end
end

framework.modes.rungames = rungames
