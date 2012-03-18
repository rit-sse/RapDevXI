--This file make a game run as a standalone game
--local HC = require 'hardoncollider' --if your game needs HC in standalone, copy the directory into your path and uncomment this. Don't comit that copy though

local game = {
        getReady = function(self,basePath) end,
        update = function(self, dt) end,
        draw = function(self) end,
        keypressed = function(self, key) end,
        keyreleased = function(self, key) end,
        mousepressed = function(self, x, y, button) end,
        mousereleased = function(self, x, y, button) end,
        getScore = function(self) return -1 end,
        isDone = function(self) return false end
}

local gameClass = require('game.lua')
local difficulty = gameClass.standalone_difficulty
if difficulty == 0 then difficulty = gameClass.difficulties[1] end
gameClass.makeGameInstance(game,{difficulty=difficulty, player="player1"})

function love.load()
    love.graphics.setMode(400,400,false,true,0)
    
end

local ready = false
local elapsed = 0
function love.update(dt)
	if not ready then
		ready = true
		game:getReady("")
	else
		if not (game:isDone() or elapsed> gameClass.maxDuration) then
			elapsed = elapsed+dt
			game:update(dt)
		end
	end
end

function love.draw()
	if (game:isDone() or elapsed> gameClass.maxDuration) then
		love.graphics.setColor(255,255,255)
		love.graphics.print("Score was: "..game:getScore(),10,10)
	else
		love.graphics.setColor(255,255,255)
		game:draw()
	end

	
end

function love.keypressed(key)
    game:keypressed(key)
    if key == "escape" then
        love.event.push('q')
    end
end

function love.keyreleased(key)
    game:keyreleased(key)
end

function love.mousepressed(x, y, button)
	game:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    game:mousereleased(x, y, button)
end

function on_collision(self, dt, shape_a, shape_b, mtv_x, mtv_y)
    game:on_collision(self, dt, shape_a, shape_b, mtv_x, mtv_y)
end
