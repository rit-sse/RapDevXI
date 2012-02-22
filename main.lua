--[[
    Framework for LoveWare 2.0,
    made by Jesse Jurman
--]]

local framework = {
    games = {},         --game modules
    gameNumber = 0,     --score / current game number % number of games
    eTime = 0,          --elapsed time
    fps = 0,            --frames per second
    cGame = {},         --current game module
    difficulty = 1,     --current game speed
    scale = 1,          --current scale for game (400*scale x 400*scale)
    fullscreen = false,

    playGame = function(self, gameNumber)
        --set current game to specific game module
        print("GAMENUMBER: "..gameNumber)
        self.cGame = self.games[gameNumber]

        request = self.cGame:request()  --list of data cGame needs
        data = {}
        for i=1,#request do
            data[i] = self[request[i]]  --fillRequest
        end
        self.cGame:fillRequest(data)    --send data back to cGame

        self.cGame:gload() --load new set of game attributes
        print("LOADING "..self.cGame.game_dir)
    end,

    nextGame = function(self)
        self.eTime = 0
        print("self.GAMENUMBER: "..self.gameNumber)
        if self.cGame.game_dir == "LvlUp" then
            self.gameNumber = self.gameNumber + 1
            self.difficulty = self.difficulty + .1
            print("GAME: "..self.gameNumber..", DIFF: "..self.difficulty)
            self:playGame(math.random(1, #self.games))
        else
            self:playGame(0)
        end
    end
}

function love.load()


    listOfGames = require('listOfGames') --grab list of games
    framework.games[0] = require("LvlUp/game.lua")
    print("Adding LvlUp at 0")
    for i=1,#listOfGames do
        framework.games[i] = require(listOfGames[i].."/game.lua")
        print("Adding "..listOfGames[i].." at "..i)
    end

    love.graphics.setMode(400*framework.scale, 400*framework.scale, fullscreen, true, 0) --set the window dimensions to 400 by 400 with no fullscreen, vsync on, and no antialiasing
    framework:playGame(0) --start playing games

end

function love.draw()
    love.graphics.scale(framework.scale, framework.scale)
    framework.cGame:gdraw() --call cGame's draw method
    love.graphics.setColor(255,255,255)
    if framework.cGame.game_dir ~= "LvlUp" then
        love.graphics.print("FPS: "..framework.fps, 10, 4)
        love.graphics.print("Elapsed Time: "..framework.eTime, 10, 15)
    end
end

function love.update(dt)
    framework.cGame:gupdate(dt*framework.difficulty) --call cGame's update method
    framework.eTime = framework.eTime + dt
    framework.fps = 1/dt
    if framework.cGame.eTime > framework.cGame.timeLimit then
        pass = framework.cGame:gend()
        if pass then
            framework:nextGame()
        else
            print('failed game')
            love.event.push('q')
        end
    end
end

function on_collision(dt, shape_A, shape_B, mtv_x, mtv_y)
    framework.cGame:goc(dt, shape_A, shape_B, mtv_x, mtv_y) --call cGame's on_collision method
end

function love.keypressed(key)
    --quit the game if ESC is pressed
    framework.cGame:gkpress(key)
    if key == 'escape' then
        love.event.push('q')
    end
end
