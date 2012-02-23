--[[
    LvlUp game
    *unique in that it is called inbetween games
--]]

local game = {

    gload = function(self)
        self.game_dir = "LvlUp"
        self.music = love.audio.newSource("LvlUp/Resources/BeepBoom.wav")
        self.eTime = 0
        self.timeLimit = 2.0

        love.audio.play(self.music)
        love.graphics.setFont(50)
    end,

    gdraw = function(self)
        love.graphics.setColor(131-self.eTime-self.eTime*40, 192-self.eTime*50, 240-self.eTime*60) --bg Color
        love.graphics.rectangle('fill', 0, 0, 400, 400) --bg Shape
        love.graphics.setColor(205, 227, 161)           --bar border Color
        love.graphics.rectangle('fill', 40, 280, 340, 35) --bar border shape
        love.graphics.setColor(146, 201, 87)            --bar Color
        love.graphics.rectangle('fill', 50, 285, 320*(self.eTime/self.timeLimit), 25) --bar shape

        love.graphics.setColor(255,255,255)
        if self.eTime < 1.5 then
            love.graphics.print(self.gameNumber, 100, 100)
        else
            love.graphics.print(self.gameNumber+1,100, 100)
        end
    end,

    gupdate = function(self, dt)
        self.eTime = self.eTime + dt
    end,

    goc = function(self)
    end,

    request = function(self) --returns a list of data asked for from the framework
        return {'gameNumber'}
    end,

    fillRequest = function(self, data) --data returned by the framework from request
        self.gameNumber = data[1]
        print(self.gameNumber)
    end,   

    gkpress = function(self)
    end,
        
    gend = function(self) --function called only by Game Framework
        --asks for pass or fail, cleans up any calls to love
        love.audio.stop(self.music)
        love.graphics.setFont(15)
        return true --always passes
    end
}

return game --returns game
