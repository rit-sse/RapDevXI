--[[
    Main Menu
--]]

local HC = require 'hardoncollider'

local game = {

    gload = function(self)

        self.Collider = HC(100, on_collision, collision_stop)

        self.game_dir = "Menu"
        self.eTime = 0
        self.timeLimit = 1
        self.fontSize = 25
        self.fullscreen = false
        self.debug = true
        love.graphics.setFont(self.fontSize)

        self.cursorImg = love.graphics.newImage("Menu/Resources/cursor.gif")


        self.makeButton = function(o, x, y, text, fontSize, r, g, b, runFunction)
            o.x, o.y, o.text, o.r, o.g, o.b = x, y, text, r, g, b
            o.w, o.h = #o.text*(fontSize/1.2), fontSize*1.5
            o.bx, o.by = x-3, y-3
            o.bh, o.bw = o.h+6, o.w+6
            o.br, o.bg, o.bb = r+13, g+13, b+13
            o.hover = false
            o.colBox = self.Collider:addRectangle(o.x,o.y,o.w,o.h)
            o.colBox.parent = o
            o.run = runFunction
        end

        self.drawButton = function(b)
            --Draw Border
            love.graphics.setColor(b.br, b.bg, b.bb)
            love.graphics.rectangle('fill', b.bx, b.by, b.bw, b.bh)
            --Draw Box
            if b.hover then
                love.graphics.setColor(b.r+10, b.g+10, b.b+10)
                love.graphics.rectangle('fill', b.x, b.y, b.w, b.h)
            else
                love.graphics.setColor(b.r, b.g, b.b)
                love.graphics.rectangle('fill', b.x, b.y, b.w, b.h)
            end
            --Draw Text
            love.graphics.setColor(255,255,255)
            love.graphics.print(b.text, b.x+3, b.y+3)
        end

        self.buttons = {}

        --PLAY BUTTON
        self.buttons[1] = {}
        play = function()
            self:gend()
        end
        self.makeButton(self.buttons[1], 50, 50, "PLAY", self.fontSize, 218, 72, 78, play)


        --FULLSCREEN BUTTON
        self.buttons[2] = {}
        fullScreen = function()
            self.fullscreen = not self.fullscreen
            self.yell = true
            self.listen = function()
                return {["fullscreen"]=self.fullscreen}
            end
        end
        self.makeButton(self.buttons[2], 50, 100, "FullScreen", self.fontSize, 218, 72, 78, fullScreen)


        --SCALE BUTTONS
        for i=1,4 do
            self.buttons[2+i] = {}

            scaleFunc = function()
                self.screenScale = i
                love.graphics.scale(self.screenScale, self.screenScale)
                self.yell = true
                self.listen = function()
                    return {["scale"]=i}
                end
            end
            
            self.makeButton(self.buttons[2+i], 50+(i-1)*50, 150, i.."x", self.fontSize, 218, 72, 78, scaleFunc)

        end


        --DEBUG BUTTONS
        self.buttons[7] = {}
        debug = function()
            self.debug = not self.debug
            self.yell = true
            self.listen = function()
                return {["debug"]=self.debug}
            end
        end
        self.makeButton(self.buttons[7], 150, 50, "Debug", self.fontSize, 218, 72, 78, debug)

        -- add a circle to the scene
        self.cursor = self.Collider:addRectangle(0,0,20,20)
        self.cursor:moveTo(love.mouse.getPosition())

    end,

    gdraw = function(self)
        love.graphics.setColor(40, 104, 199)
        love.graphics.rectangle('fill', 0, 0, 400, 400) --bg Shape

        for i=1,#self.buttons do
            self.drawButton(self.buttons[i])
        end

        love.graphics.draw(self.cursorImg, love.mouse.getX(), love.mouse.getY())
    end,

    gupdate = function(self, dt)
        --Elapsed Time does not update; main menu has no time limit
        --self.eTime = self.eTime + dt
        self.cursor:moveTo(love.mouse.getPosition())

        self.Collider:update(dt)
    end,

    request = function(self)
        return {'fullScreen', 'scale'}
    end,

    fillRequest = function(self, data)
        self.fullScreen = data[1]
        self.screenScale = data[2]
    end,

    goc = function (self, dt, shape_a, shape_b, mtv_x, mtv_y)
        if shape_b == self.cursor then
            for i=1,#self.buttons do
                self.buttons[i].hover = false
            end
            shape_a.parent.hover = true
        end
    end,

    gsc = function (self, dt, shape_a, shape_b)
        --NOT WORKING!?!?!?!
        print("COLLISIONS STOPPED")
        if shape_a == self.cursor then
            print("HOVER OFF for "..shape_b.parent.text)
            shape_b.parent.hover = false
        end
    end,

    gmrelease = function (self, x, y, button)
        if button == 'l' then
            for i=1,#self.buttons do
                if self.buttons[i].hover then
                    self.buttons[i]:run()
                    self.buttons[i].hover = false
                end
            end
        end
    end,

        
    gend = function(self) --function called only by Game Framework
        --asks for pass or fail, cleans up any calls to love
        love.graphics.setFont(15)
        self.eTime = 2
        return true --always passes
    end
}

return game --returns game
