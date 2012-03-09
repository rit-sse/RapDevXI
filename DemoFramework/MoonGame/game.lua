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
    self.messages = {
      {
        -1,
        "You can do it!",
        180,
        58,
        0,
        1,
        1
      },
      {
        1,
        "See, you pressed space!",
        50,
        43,
        0,
        1,
        1
      },
      {
        2,
        "Yay, you pressed space!",
        150,
        158,
        0,
        1,
        1
      },
      {
        4,
        "Done with the lame encouragement?",
        130,
        73,
        0.3,
        1.2,
        1.2
      },
      {
        6,
        "Of course not!  You know you love it.",
        140,
        208,
        -0.3,
        1.4,
        1.4
      },
      {
        8,
        "Well I hope this is good for you too...",
        130,
        28,
        0,
        1,
        1
      },
      {
        9,
        "Hope this isn't hurting your hand...",
        25,
        118,
        0,
        1,
        1
      },
      {
        10,
        "Halfway there!  Don't die!",
        120,
        133,
        0,
        2,
        2
      },
      {
        12,
        "THIS IS SO MUCH FUN, I LOVE YOU!",
        45,
        148,
        0.9,
        3,
        3
      },
      {
        14,
        "Getting closer...Ouch, eh?",
        35,
        183,
        -0.6,
        1.2,
        1.2
      },
      {
        16,
        "Meanwhile, in London...",
        58,
        300,
        0,
        4,
        4
      },
      {
        18,
        "OH GOD SWEET RELIEF IS COMING",
        100,
        88,
        1.2,
        5,
        5
      },
      {
        20,
        "VICTORY!!!!!!!!!!!!!",
        100,
        103,
        0,
        5,
        5
      },
      {
        25,
        "You're still playing?",
        100,
        258,
        0,
        2,
        2
      },
      {
        30,
        "My god man!  Stop playing with yourself!",
        80,
        238,
        -1.2,
        6,
        6
      }
    }
    self.counter = 0
    self.goal = 20
    self.eTime = 0
    self.timeLimit = 5.0
  end,
  gdraw = function(self)
    love.graphics.print((self.goal - self.counter) .. "", 100, 108)
    local _list_0 = self.messages
    for _index_0 = 1, #_list_0 do
      local msg = _list_0[_index_0]
      if msg[1] <= self.counter then
        love.graphics.print(msg[2], msg[3], msg[4], msg[5], msg[6], msg[7])
      end
    end
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
    return self.counter >= self.goal
  end
}
preReq(game)
return game
