return {
    difficulties = {"easy", "medium", "hard"},
    PR = "child",
    keys = {"mouse"},
    maxDuration = 15,
    makeGameInstance = function(self, info)
        self.score = 1
        self.done = false
        self.torch = {}
        self.targets = 3 -- number of targets
        self.getReady = function(self,basePath)
            self.P = {}
            math.randomseed(os.time())
            for i=1,self.targets do 
                self.P.x = math.random(50,350)
                self.P.y = math.random(50,350)
                self.P.onFire = false
            end
            self.torch.img = love.graphics.newImage("torch.png")
            self.person = love.graphics.newImage("person.png")
            self.speedFactor = ({easy = 1, medium = 2, hard = 3})[info.difficulty]
            self.done = false
            
            self.system = love.graphics.newParticleSystem( self.torch.img, 1000 )
            self.system:setEmissionRate(500)
            self.system:setSpeed(300,400)
            self.system:setGravity(100,200)
            self.system:setSize(1,2)
            self.system:setColor(220, 120, 50, 200, 20, 20, 220, 0)
            self.system:setLifetime(-1) -- infinite
            self.system:setParticleLife(.5)
            self.system:setDirection(0)
            self.system:setSpread(.25)
            self.system:stop()

            self.systemP = love.graphics.newParticleSystem( self.torch.img, 1000 )
            self.systemP:setEmissionRate(200)
            self.systemP:setSpeed(300,400)
            self.systemP:setGravity(100,200)
            self.systemP:setSize(1,.2)
            self.systemP:setColor(220, 120, 20, 255, 220, 20, 20, 0)
            self.systemP:setLifetime(-1) -- infinite
            self.systemP:setParticleLife(.5)
            self.systemP:setDirection(0)
            self.systemP:setSpread(360)
            self.systemP:setTangentialAcceleration(1000)
            self.systemP:setRadialAcceleration(-2000)
            self.systemP:stop()
            self.systemP1 = self.systemP
            self.systemP2 = self.systemP
            self.systemP3 = self.systemP
            self.systemP1:setPosition(self.P1.x+9,self.P1.y+6)
            self.systemP2:setPosition(self.P2.x+9,self.P2.y+6)
            self.systemP3:setPosition(self.P3.x+9,self.P3.y+6)
        end
        
        self.getScore = function(self, key)
            return self.score
        end
        
        self.update = function(self, dt)
            if love.mouse.isDown("l") then
                self.system:start()
            end
            if love.keyboard.isDown("m") then
                self.systemP1:start()
                self.systemP2:start()
                self.systemP3:start()
            end
            if self.P1.onFire then
                self.systemP1:start()
            end
            if self.P2.onFire then
                self.systemP2:start()
            end
            if self.P3.onFire then
                self.systemP3:start()
            end
            self.system:setPosition(love.mouse.getX(), love.mouse.getY())
            self.system:setPosition(love.mouse.getX(), love.mouse.getY())

            self.system:update(dt)
            self.systemP1:update(dt)
            self.systemP2:update(dt)
            self.systemP3:update(dt)
        end
        
        self.draw = function(self)
            love.graphics.setColorMode("modulate")
            love.graphics.setBlendMode("additive")
            love.graphics.draw(self.person,self.P1.x,self.P1.y)
            love.graphics.draw(self.person,self.P2.x,self.P2.y)
            love.graphics.draw(self.person,self.P3.x,self.P3.y)
            love.graphics.draw(self.system,0,0)
            love.graphics.draw(self.systemP1,0,0)
            love.graphics.draw(self.systemP2,0,0)
            love.graphics.draw(self.systemP3,0,0)
        end
        
        self.isDone = function(self,key)
            return self.done
        end
    end
}
