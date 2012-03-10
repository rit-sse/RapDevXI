return {
    difficulties = {"medium","hard","impossible"},
    PR = "sse",
    keys = {"full keyboard"},
	maxDuration = 5,
    makeGameInstance = function(self, info)
        self.getReady = function(self)
            self.score = 0
			self.pressed = 0
        end
        
        self.update = function(self, dt)
        end

        self.draw = function(self)
            love.graphics.setColor(255,255,255)
            love.graphics.print("HOLD THE SPACEBAR!", 20, 20)    
            love.graphics.setColor(20, 20+200*(self.pressed), 20)
            love.graphics.rectangle('fill', 100,100, 150,150)
        end

        self.keypressed = function(self, key)
            if key==" " then
                self.score = 0
				self.pressed = 1
            end
        end

        self.keyreleased = function(self, key)
            if key==" " then
                self.score = 1
				self.pressed = 0
            end
        end
        
        self.getScore = function(self, key)
            return self.score
        end

        self.isDone = function(self,key)
            return self.score > 0
        end
        
    end
}
