local framework = require('framework')
local makesplashGame = require('makeSplashGame')
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
		
		if gameClass.___skipSplash then
			return game
		else
			return makesplashGame(game,gameClass, info)
		end
	else
		print('out of games')
		return chooser()
	end
end

return rungames