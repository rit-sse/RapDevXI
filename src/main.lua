--[[ 
    Framework
--]]

local HC = require 'hardoncollider'

math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))

local framework = {
    currentGame = nil,
	modes = {},
    parentGame = {
        __index = {
        getReady = function(self,basePath) end,
        update = function(self, dt) end,
        draw = function(self) end,
        keypressed = function(self, key) end,
        keyreleased = function(self, key) end,
        mousepressed = function(self, x, y, button) end,
        mousereleased = function(self, x, y, button) end,
        getScore = function(self) return -1 end,
        isDone = function(self) return false end,
        on_collision = function( self, dt,shape_a,shape_b,mtv_x,mtv_y) end
    }},
    selectedGames = {},
    outOfGame = nil,
    gameMode = nil, 
    gameList = {},
	elapsed = 0,
	limit = -1
}

--This little trick lets other framework classes require('framework') to get at what they need
--without being in this file
package.loaded.framework = framework


require('initGameState')
require('gameModeChooserState')
require('runGamemodState')

framework.mode = framework.modes.initState

function love.load()
    love.graphics.setMode(400,400,false,true,0)
    
end

function love.update(dt)
	framework.elapsed=framework.elapsed+dt
    if framework.currentGame ~= nil then
        framework.currentGame:update(dt)
    end
    if framework.currentGame == nil or framework.currentGame:isDone() 
		or (framework.limit >0 and framework.elapsed>framework.limit)
	then
		love.audio.stop()
        framework.elapsed = 0
        framework.currentGame = framework.mode()
    end
end

function love.draw()
	love.graphics.setColor(255,255,255)
    if framework.currentGame ~= nil then
        pcall(function() framework.currentGame:draw() end)
    end
end

function love.keypressed(key)
    if framework.currentGame ~= nil then
        pcall(function() framework.currentGame:keypressed(key) end)
    end
    if key == "escape" then
        love.event.push('q')
    end
end

function love.keyreleased(key)
    if framework.currentGame ~= nil then
        pcall(function() framework.currentGame:keyreleased(key) end)
    end
end

function love.mousepressed(x, y, button)
    if framework.currentGame ~= nil then
        pcall(function() framework.currentGame:mousepressed(x, y, button) end)
    end
end

function love.mousereleased(x, y, button)
    if framework.currentGame ~= nil then
        pcall(function() framework.currentGame:mousereleased(x, y, button) end)
    end
end
