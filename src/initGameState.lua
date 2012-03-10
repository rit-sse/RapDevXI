local framework = require('framework')
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
                    table.insert(framework.gameList, require("games/"..self.listOfGames[i][1].."/game"))
                end
            end
            self.done = true
        end
    end 

    framework.mode = framework.modes.chooser

    return base
end

framework.modes.initState = initState