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
    lives = 3,          --number of lives
    lastPass = true,    --status of the last game player
    fullscreen = false, --status of fullscreen
    debug = true,       --allows debug options (skip games, see FPS/eTime, etc...)

    playGame = function(self, gameNumber)
        --set current game to specific game module
        print("GAMENUMBER: "..gameNumber)
        self.cGame = self.games[gameNumber]

        if self.cGame.request ~= nil then
            request = self.cGame:request()  --list of data cGame needs
            data = {}
            for i=1,#request do
                data[i] = self[request[i]]  --fillRequest
            end
            self.cGame:fillRequest(data)    --send data back to cGame
        end

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

--this function is called exactly once at the beginning of the game
function love.load()

    listOfGames = require('listOfGames') --grab list of games
    framework.games[-1] = require("Menu/game.lua")
    print("Adding Menu at -1")
    framework.games[0] = require("LvlUp/game.lua")
    print("Adding LvlUp at 0")
    for i=1,#listOfGames do
        framework.games[i] = require(listOfGames[i].."/game.lua")
        print("Adding "..listOfGames[i].." at "..i)
    end

    love.mouse.setVisible(false)
    love.graphics.setColorMode('replace')
    love.graphics.setMode(400*framework.scale, 400*framework.scale, framework.fullscreen, true, 0) --set the window dimensions to 400 by 400 with no fullscreen, vsync on, and no antialiasing

    math.randomseed( os.time() ) --set the seed to the clock
    

    framework:playGame(-1) --start playing games

end

--callback function used to draw on the screen every frame
function love.draw()
    love.graphics.scale(framework.scale, framework.scale)
    framework.cGame:gdraw() --call cGame's draw method
    love.graphics.setColor(255,255,255)
    if framework.debug then
        love.graphics.print("FPS: "..framework.fps, 10, 4)
        love.graphics.print("Elapsed Time: "..framework.eTime, 10, 15)
    end
end

--callback function used to update the state of the game every frame
function love.update(dt)

    framework.cGame:gupdate(dt*framework.difficulty) --call cGame's update method
    framework.eTime = framework.eTime + dt
    framework.fps = 1/dt
    if framework.cGame.eTime > framework.cGame.timeLimit then
        framework.lastPass = framework.cGame:gend()
        if not framework.lastPass then
            framework.lives = framework.lives - 1
        end
        if framework.lives == 0 then
            print("Out of lives")
            love.event.push('q')
        end
        framework:nextGame()
    end

    if framework.cGame.yell ~= nil then --the game is trying to change the framework
        if framework.cGame.game_dir == "Menu" then --only allow certain games this access
            data = framework.cGame.listen()
            if data.scale ~= nil then --trying to change scale
                framework.scale = data.scale
                love.graphics.setMode(400*framework.scale, 400*framework.scale, framework.fullscreen, true, 0)
            elseif data.fullscreen ~= nil then --trying to change fullScreen
                framework.fullscreen = data.fullscreen
                love.graphics.setMode(400*framework.scale, 400*framework.scale, framework.fullscreen, true, 0)
            elseif data.debug ~= nil then --trying to set debug status
                framework.debug = data.debug

            elseif data.games ~= nil then --trying to set list of games
                framework.games = data.games
            end 
        end
        framework.cGame.yell = nil
    end

end

-- this is called when two shapes collide; called by HardonCollider
function on_collision(dt, shape_a, shape_b, mtv_x, mtv_y)
    if framework.cGame.goc ~= nil then
        framework.cGame:goc(dt, shape_a, shape_b, mtv_x, mtv_y) --call cGame's on_collision method
    end
end

-- this is called when two shapes stop colliding; called by HardonCollider
function collision_stop(dt, shape_a, shape_b)
    if framework.cGame.gcs ~= nil then
        framework.cGame:gcs(dt, shape_a, shape_b)
    end
end

--callback function triggered when a key is pressed
function love.keypressed(key)
    if framework.cGame.gkpress ~= nil then
        framework.cGame:gkpress(key)
    end
    --quit the game if ESC is pressed
    if key == 'n' and framework.debug then
        framework.cGame:gend()
        framework:nextGame()
    end
    if key == 'escape' then
        love.event.push('q')
    end
end

--callback function triggered when a key is released
function love.keyreleased(key)
    if framework.cGame.gkrelease ~= nil then
        framework.cGame:gkrelease(key)
    end
end 

--callback function triggered when a mouse button is pressed
function love.mousepressed(x, y, button)
    if framework.cGame.gmpress ~= nil then
        framework.cGame:gmpress(x, y, button)
    end
end

--callback function triggered when a mouse button is released
function love.mousereleased( x, y, button )
    if framework.cGame.gmrelease ~= nil then
        framework.cGame:gmrelease(x, y, button)
    end
end
