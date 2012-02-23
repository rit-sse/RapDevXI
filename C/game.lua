--[[
    game 'C'
--]]

local game = {

    gload = function(self)
        -- initialize library
        self.game_dir = "C"
        self.music = love.audio.newSource("C/Resources/f_000240.wav")
        self.sound = love.audio.newSource("C/Resources/BeepWin.wav")
        self.arrow = love.graphics.newImage("C/Resources/arrow.gif")
        self.aR = {}
        self.aR[0] ={0,0, (math.pi/2)*0} --left
        self.aR[1]={32,0, (math.pi/2)*1} --up
        self.aR[2]={32,32,(math.pi/2)*2} --right
        self.aR[3]={0,32, (math.pi/2)*3} --down
        self.music:setVolume(0.2)
        self.sound:setVolume(3.0)
        self.goal = 4
        self.eTime = 0
        self.timeLimit = 5.0
        
        --list of rotations (from 0-3)
        self.rotList = {}
        for i=0,self.goal do
           self.rotList[i] = math.random(0,3)
           io.write(self.rotList[i])
           print()
        end

        -- current number
        self.n = 0
    
        self.gScore = 0
        self.req = self.goal

        love.audio.play(self.music)
    end,

    gdraw = function(self)
        love.graphics.setColor(255,255,255)
        love.graphics.rectangle( "fill", 20+32*self.n,20,32,32)
        for i=0,(self.goal-1) do
            x = self.aR[self.rotList[i]][1]
            y = self.aR[self.rotList[i]][2]
            rot = self.aR[self.rotList[i]][3]
            love.graphics.draw(self.arrow, 20+(32*i)+x, 20+y, rot)
        end
        if self.n < self.goal then
            ba= self.aR[self.rotList[self.n]]
            love.graphics.draw(self.arrow, 64+(ba[1])*5, 64+(ba[2])*5, ba[3], 5, 5) 
            love.graphics.print(self.gScore.."/"..self.req,220,8)
        end
    end,

    gupdate = function(self, dt)
        self.eTime = self.eTime + dt
    end,

    gkpress = function(self, key)
        keyBind = {} 
        keyBind[2]='left' keyBind[3]='up' keyBind[0]='right' keyBind[1]='down'
        -- print("key pushed:"..key..", Key wanted: "..keyBind[self.rotList[self.n]])
        if key == keyBind[self.rotList[self.n]] and self.gScore <= self.goal-1 then
            self.n = self.n + 1
            self.gScore = self.gScore + 1
        elseif self.gScore <= self.goal-1 then
            self.n = 0
            self.gScore = 0
        end
    end,
        
    gend = function(self) --function called only by Game Framework
        --asks for pass or fail, cleans up any calls to love
        love.audio.stop(self.music)
        return self.gScore >= self.req
    end
}

return game --returns game
