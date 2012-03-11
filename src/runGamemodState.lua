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
		local gameClass = framework.gameMode:nextGame()
		framework.limit = gameClass.maxDuration
		print('set duration to',framework.limit)
		local game = {}
		setmetatable(game, framework.parentGame)
		local info = {
			difficulty = framework.gameMode:nextDifficulty(),
			player = framework.gameMode:nextPlayer()
		}
		gameClass.makeGameInstance(game, info)
		
		if gameClass.___skipSplash then
			game:getReady()
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