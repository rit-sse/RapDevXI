return {
    difficulties = {"easy", "medium", "hard"},
    PR = "child",
    keys = {"mouse"},
    maxDuration = 15,
    makeGameInstance = function(self, info)
        self.score = 1
        self.done = false
        self.torch = {}
        self.targets = ({easy = 5, medium = 15, hard = 30})[info.difficulty] -- number of targets
        self.getReady = function(self,basePath)
            self.P = {}
            for i=1,self.targets do
                self.P[i] = {}
            end
            math.randomseed(os.time())
            for i=1,self.targets do 
                self.P[i].x = math.random(50,350)
                self.P[i].y = math.random(50,350)
                self.P[i].onFire = false
            end
            self.torch.img = love.graphics.newImage("torch.png")
            self.person = love.graphics.newImage("person.png")
            self.speedFactor = ({easy = 1, medium = 2, hard = 3})[info.difficulty]
            self.done = false
            
            self.system = love.graphics.newParticleSystem( self.torch.img, 1000 )
            self.system:setEmissionRate(500)
            self.system:setSpeed(300,400)
            self.system:setGravity(100,200)
            self.system:setSize(1,1)
            self.system:setColor(220, 120, 50, 100, 20, 20, 120, 0)
            self.system:setLifetime(-1) -- infinite
            self.system:setParticleLife(.5)
            self.system:setDirection(0)
            self.system:setSpread(.2)
            self.system:start()
            for i=1,self.targets do
                self.P[i].system = love.graphics.newParticleSystem( self.torch.img, 1000 )
                self.P[i].system:setEmissionRate(200)
                self.P[i].system:setSpeed(300,400)
                self.P[i].system:setGravity(100,200)
                self.P[i].system:setSize(1,.2)
                self.P[i].system:setColor(220, 120, 20, 255, 220, 20, 20, 0)
                self.P[i].system:setLifetime(-1) -- infinite
                self.P[i].system:setParticleLife(.5)
                self.P[i].system:setDirection(0)
                self.P[i].system:setSpread(360)
                self.P[i].system:setTangentialAcceleration(1000)
                self.P[i].system:setRadialAcceleration(-2000)
                self.P[i].system:stop()
                self.P[i].system:setPosition(self.P[i].x+9,self.P[i].y+6)
            end
        end
        
        self.getScore = function(self, key)
            return self.score
        end
        
        self.update = function(self, dt)
            for i=1,self.targets do
                local mouseX = self.P[i].x - love.mouse.getX()
                local mouseY = love.mouse.getY() - self.P[i].y
                if mouseX < 80 and mouseY < 32 and mouseX == math.abs(mouseX) and mouseY == math.abs(mouseY) then
                    self.P[i].onFire = true
                end
            end

            for i=1,self.targets do
                if self.P[i].onFire then
                    self.P[i].system:start()
                end
            end
            self.system:setPosition(love.mouse.getX(), love.mouse.getY())
            self.system:update(dt)
            for i=1,self.targets do
                self.P[i].system:update(dt)
            end
            local check = 0
            for i=1,self.targets do
                if self.P[i].onFire then
                    check = check + 1
                end
            end
            if check == self.targets then
                print("you totally won! ps. they're scarecrows!!")
                self.done = true
            end

        end
        
        self.draw = function(self)
            love.graphics.setColorMode("modulate")
            love.graphics.setBlendMode("additive")
            for i=1,self.targets do
                love.graphics.draw(self.person,self.P[i].x,self.P[i].y)
                love.graphics.draw(self.P[i].system,0,0)
            end
            love.graphics.draw(self.system,0,0)
        end
        
        self.isDone = function(self,key)
            return self.done
        end
    end
}
