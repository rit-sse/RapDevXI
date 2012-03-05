
--
--Game 'MoonGame'
--By Brian Wyant
--
--Just a demo for one way of getting moonscript
-- into source, if anyone really wants to try it.
--(And by 'one way', I do mean 'simplest way')
--

HC = require "hardoncollider"

preReq = (o) ->
  o.game_dir = "MoonGame"
  o.bindings = {"Space"}

game = {
  gload: =>
    -- Initialize game

    self.sound = love.audio.newSource("MoonGame/Resources/Coin.mp3")
    
    self.counter = 0 -- # of times [space] pressed
    self.goal = 30 -- target # to press space
    self.eTime = 0
    self.timeLimit = 5.0

  gdraw: =>
    love.graphics.print("You can do it!", 100, 58)
    love.graphics.print((self.goal - self.counter) .. "", 100, 108)

  gupdate: (dt) =>
    self.eTime += dt

  gkpress: (key) =>
    if key == " "
      love.audio.stop(self.sound)
      self.counter += 1
      love.audio.play(self.sound)

  gend: =>
    return self.counter >= 20

}

preReq(game)

return game
