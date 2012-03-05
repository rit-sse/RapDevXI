local HC = require("hardoncollider")
local preReq
preReq = function(o)
  o.game_dir = "MoonGame"
  o.bindings = {
    "Space"
  }
end
local game = {
  gload = function(self)
    self.sound = love.audio.newSource("MoonGame/Resources/Coin.mp3")
    self.counter = 0
    self.goal = 20
    self.eTime = 0
    self.timeLimit = 5.0
  end,
  gdraw = function(self)
    love.graphics.print("You can do it!", 100, 58)
    return love.graphics.print((self.goal - self.counter) .. "", 100, 108)
  end,
  gupdate = function(self, dt)
    self.eTime = self.eTime + dt
    return self.eTime
  end,
  gkpress = function(self, key)
    if key == " " then
      love.audio.stop(self.sound)
      self.counter = self.counter + 1
      return love.audio.play(self.sound)
    end
  end,
  gend = function(self)
    return self.counter >= 20
  end
}
preReq(game)
return game
