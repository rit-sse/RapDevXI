--[[
    game 'D'
--]]

local HC = require 'hardoncollider'

local game = {

    gload = function(self)
        -- initialize library
        self.Collider = HC(100, on_collision, collision_stop)
        

        self.game_dir = "D"

        self.music = love.audio.newSource("D/Resources/f_000240.wav")
        self.sound = love.audio.newSource("D/Resources/BeepWin.wav")
        self.dart = {}
        self.board = {}
        self.board.cb = self.Collider:addRectangle(152,10,96,90)
        self.dart.moving_x = true
        self.dart.moving_y = false
        self.dart.x = 0
        self.dart.y = 300
        self.dart.cb = self.Collider:addRectangle(self.dart.x,self.dart.y,4,32)
        self.dart.image = love.graphics.newImage("D/Resources/dart.gif")
        self.board.image = love.graphics.newImage("D/Resources/dartBoard.gif")

        self.music:setVolume(0.2)
        self.sound:setVolume(3.0)

        self.eTime = 0
        self.timeLimit = 5.0

        self.gScore = 0
        self.req = 1
        love.audio.play(self.music)
    end,

    gdraw = function(self)
        love.graphics.draw(self.board.image,152,50,0,3,3)
        love.graphics.draw(self.dart.image,self.dart.x,self.dart.y,0,3,3)

        love.graphics.print(self.gScore.."/"..self.req,220,8)
    end,


    gupdate = function(self, dt)
        maxSpeed = 350
        speed = -math.abs(self.dart.x-200)/40+maxSpeed
        if self.dart.moving_x then
            if math.floor(self.eTime)%2 == 0 then
                self.dart.x = self.dart.x + speed*dt
            elseif math.floor(self.eTime)%2 == 1 then
                self.dart.x = self.dart.x - speed*dt
            end
        end
        if self.dart.moving_y then
            self.dart.y = self.dart.y - maxSpeed*2*dt
        end
        self.dart.cb:moveTo(self.dart.x+12, self.dart.y+16)
        self.eTime = self.eTime + dt

        self.Collider:update(dt)
    end,

    goc = function(self, dt, shape_a, shape_b, mtv_x, mtv_y)
        if shape_b == self.dart.cb then
            self.dart.moving_y = false
            self.gScore = 1
        end
    end,

    gkpress = function(self, key)
        if key == " " then
            self.dart.moving_x = false
            self.dart.moving_y = true
        end
    end,
        
    gend = function(self) --function called only by Game Framework
        --asks for pass or fail, cleans up any calls to love
        love.audio.stop(self.music)
        return self.gScore >= self.req
    end
}

return game --returns game
