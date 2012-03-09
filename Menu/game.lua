--[[
    Main Menu
--]]

local HC = require 'hardoncollider'

preReq = function(o)
    o.game_dir = "Menu"
    o.bindings = {"Mouse"}
end

local game = {

    gload = function(self)

        self.Collider = HC(100, on_collision, collision_stop)

        self.eTime = 0
        self.timeLimit = 1
        self.fontSize = 25
        self.fullscreen = false
        self.debug = true
        love.graphics.setFont(self.fontSize)

        self.cursorImg = love.graphics.newImage("Menu/Resources/cursor.gif")
        self.music = love.audio.newSource("Menu/Resources/heman.mp3")
        self.music:setVolume(0.5)

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
                love.graphics.setColor(b.r+15, b.g+15, b.b+15)
                love.graphics.rectangle('fill', b.x, b.y, b.w, b.h)
            else
                love.graphics.setColor(b.r-5, b.g-5, b.b-5)
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


        --DEBUG BUTTON
        self.buttons[7] = {}
        debug = function()
            self.debug = not self.debug
            self.yell = true
            self.listen = function()
                return {["debug"]=self.debug}
            end
        end
        self.makeButton(self.buttons[7], 150, 50, "Debug", self.fontSize, 218, 72, 78, debug)

        --GAME BUTTONS
        --(must be the last buttons created)
        function tWidth(text, size) -- Determines pixel width of text
          return #text * size / 1.2 -- Algorithm based on self.makeButton
        end
        window_width = love.graphics.getWidth()
        cursorCol, cursorRow = 0, 0 -- "Where to start drawing" (x,y) coordinates
        colOffset, rowOffset = 50, 250 -- Initial location of x, y
        rowHeight = 50 -- Row height
        for i=1,#self.games do
            self.buttons[#self.buttons+1] = {}

            setGameFunc = function()
                self.yell = true
                store = {[-1]=self.games[-1], [0]=self.games[0], [1]=self.games[i]}
                self.listen = function()
                    return {["games"]=store}
                end
            end

            game_name = self.games[i].game_dir -- Less typing

            button_right_bound = colOffset + cursorCol + tWidth(game_name, self.fontSize) 
            -- if right bound of button can be shown and not edge case...
            if button_right_bound > window_width and cursorCol ~= 0 then
              cursorCol = 0
              cursorRow = cursorRow + rowHeight
            end
            
            self.makeButton(self.buttons[#self.buttons],
              colOffset + cursorCol,
              -- 50+((i-1) % rowMax)*30,
              rowOffset + cursorRow,
              --250+50*(math.floor((i-1)/rowMax)),
              game_name,
              self.fontSize,
              218, 72, 78,
              setGameFunc)

            -- Advance cursor
            cursorCol = cursorCol + tWidth(game_name, self.fontSize) + 12
        end


        -- add a circle to the scene
        self.cursor = self.Collider:addRectangle(0,0,20,20)
        self.cursor:moveTo(love.mouse.getPosition())

        love.audio.play(self.music)

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
        return {'fullScreen', 'scale', 'games'}
    end,

    fillRequest = function(self, data)
        self.fullScreen = data[1]
        self.screenScale = data[2]
        self.games = data[3]
    end,

    goc = function (self, dt, shape_a, shape_b, mtv_x, mtv_y)
        if shape_b == self.cursor then
            shape_a.parent.hover = true
        end
    end,

    gcs = function (self, dt, shape_a, shape_b)
        for i=1,#self.buttons do
            self.buttons[i].hover = false
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
        love.audio.stop(self.music)
        return true --always passes
    end
}

preReq(game)
return game --returns game
