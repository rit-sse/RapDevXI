--[[
    game 'F'
--]]

local HC = require 'hardoncollider'

local game = {
	gload = function(self)
        -- initialize library
        self.Collider = HC(100, on_collision, collision_stop)
        self.game_dir = "F"

        self.music = love.audio.newSource("B/Resources/f_000240.wav")
        self.sound = love.audio.newSource("B/Resources/BeepWin.wav")

        self.music:setVolume(0.2)
        self.sound:setVolume(3.0)

        love.audio.play(self.music)
    end,

    gdraw = function(self)
    end,

    gupdate = function(self, dt)
    end,

    goc = function(self, dt, shape_a, shape_b, mtv_x, mtv_y)
    end,

    gkpress = function(self, key)
    end,

    gend = function(self)
	end
}

return game