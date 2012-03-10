--[[ 
    Framework
--]]

local framework = {
    currentGame = nil,
    parentGame = {
        __index = {
        getReady = function(self) end,
        update = function(self, dt) end,
        draw = function(self) end,
        keypressed = function(self, key) end,
        keyreleased = function(self, key) end,
        mousepressed = function(self, x, y, button) end,
        mousereleased = function(self, x, y, button) end,
        getScore = function(self) return 1 end
    }},
    selectedGames = {},
    outOfGame = nil,
    gameMode = nil, 
}

local base = {}
base.listOfGames = require('listOfGames')
setmetatable(base, framework.parentGame)
for i=1,#base.listOfGames do
    base.listOfGames[i] = {listOfGames[i], false}
end
base.currentPosition = 1

base.draw = function(self, dt)
    love.graphics.setColor(255,255,255)
    love.graphics.print(self.listOfGames[self.currentPosition][1].."|"..
    ((self.listOfGames[self.currentPosition][2]) and "on" or "off"), 
    10, love.graphics.getHeight()/2 )
end

base.keypressed = function(self, key)
    print(key)
    if key == 'up' then
        self.currentPosition = ((self.currentPosition -2) % #self.listOfGames)+1
    end
end

function love.load()
    love.graphics.setMode(400,400,false,true,0)
    framework.currentGame = base
    
end

function love.update(dt)
    if framework.currentGame ~= nil then
        framework.currentGame:update(dt)
    end
end

function love.draw()
    if framework.currentGame ~= nil then
        framework.currentGame:draw()
    end
end

function love.keypressed(key)
    if framework.currentGame ~= nil then
        framework.currentGame:keypressed(key)
    end
end

function love.keyreleased(key)
    if framework.currentGame ~= nil then
        framework.currentGame:keyreleased(key)
    end
end

function love.mousepressed(x, y, button)
    if framework.currentGame ~= nil then
        framework.currentGame:mousepressed(x, y, button)
    end
end

function love.mousereleased(x, y, button)
    if framework.currentGame ~= nil then
        framework.currentGame:mousereleased(x, y, button)
    end
end
