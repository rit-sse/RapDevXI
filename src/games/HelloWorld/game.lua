return {
    difficulties = {"easy","medium","hard"},
    PR = "sse",
    keys = {"Arrow Keys"},
    maxDuration = 5,

    makeGameInstance = function(self, info)
        self.getReady = function(self)
            -- initialize library
            HC = require 'hardoncollider'
            
            self.Collider = HC(100, on_collision, collision_stop)

            self.music = love.audio.newSource("games/HelloWorld/f_000240.wav")
            self.sound = love.audio.newSource("games/HelloWorld/BeepWin.wav")
            self.cursor = love.graphics.newImage("games/HelloWorld/block.gif")
            self.circleImg = love.graphics.newImage("games/HelloWorld/circlePoint.gif")

            self.music:setVolume(0.2)
            self.sound:setVolume(3.0)

            --add rectangle
            self.rect = self.Collider:addRectangle(0,350,32,32)
            self.rect.x = 0 
            self.rect.y = 350
    
            self.circle = self.Collider:addCircle(300,300,32)
            self.circle.x = 300
            self.circle.y = 300
    
            self.score = -2

            self.playingMusic = false
        end

        self.draw = function(self)
            love.graphics.setColor(255,0,0)
            love.graphics.setColor(255,255,255)
            love.graphics.draw(self.circleImg, self.circle.x-32, self.circle.y-32)
            love.graphics.draw(self.cursor, self.rect.x, self.rect.y)
            love.graphics.setColor(255,255,255)
            love.graphics.print(self.gScore.."/"..self.req,220,8)
        end

        self.update = function(self, dt)
            if not self.playingMusic then
                love.audio.play(self.music)
                self.playingMusic = true
            end
            speed = 275
            if love.keyboard.isDown("up") then
                if self.rect.y > 50 then
                    self.rect:move(0,-dt*speed)
                    self.rect.y = self.rect.y - dt*speed
                end
            end 
            if love.keyboard.isDown("down") then
                if self.rect.y < (400-32) then
                    self.rect:move(0,dt*speed)
                    self.rect.y = self.rect.y + dt*speed
                end
            end 
            if love.keyboard.isDown("left") then
                if self.rect.x > 0 then
                    self.rect:move(-dt*speed,0)
                    self.rect.x = self.rect.x - dt*speed
                end
            end 
            if love.keyboard.isDown("right") then
                if self.rect.x < (400-32) then
                    self.rect:move(dt*speed,0)
                    self.rect.x = self.rect.x + dt*speed
                end
            end 
            self.Collider:update(dt)
        end

        self.on_collision = function (self, dt, shape_a, shape_b, mtv_x, mtv_y)
            if shape_b == self.circle then
                self.score = self.score + 1
                x = math.random( 0, 400)
                y = math.random( 50, 400)

                self.circle.x = x
                self.circle.y = y
                self.circle:moveTo(x, y)
                love.audio.stop(self.sound)
                love.audio.play(self.sound)
            end
        end

        self.getScore = function(self)
            return self.score
        end
        
        self.isDone = function(self)
            return self.score > 0
        end

    end
}
