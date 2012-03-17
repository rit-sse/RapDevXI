local makeMode = function()
	local contains = function(tbl, element)
		for i=1,#tbl do	if tbl[i]==element then return true end	end
		return false
	end
	
	local diffs = {"easy","medium","hard","impossible"}
	
	local mode = {
		games = {},
		sel = 1,
		dif = 1,
		continue = true,
		givePick = false, --start opposite as we get the results of the gameMode first
		setGameList = function(self,list)
			self.games = list
		end,
		hasNextGame = function(self)
			return self.continue
		end,
		nextGame = function(self)
			if self.givePick then
				return self.pickGame
			else
				return self.games[self.sel]
			end		
		end,
		nextPlayer = function(self) 
			return "YOU"
		end,
		nextDifficulty = function(self)
			return self.games[self.sel].difficulties[self.dif]
		end,
		setResults = function(self, res) 
			print("got results")
			print(res)
			self.givePick = not self.givePick
		end
	}
	local pickGame = {
		___skipSplash = true,
		maxDuration = -1,
		makeGameInstance = function(self, info)
			self.selector = mode
			self.getReady = function(self)
				self.imgs = {}
				for i=1,#self.selector.games do
					local game = self.selector.games[i]
					print(game.name)
					self.imgs[game.name] = {
						screen = love.graphics.newImage("games/"..game.name.."/icon-big.png"),
						icon = love.graphics.newImage("games/"..game.name.."/icon.png")
					}
					print(game.name)
				end
			end
			self.draw = function(self)
				
				local game = self.selector.games[self.selector.sel]
				love.graphics.setColor(20,20,20)
				
				love.graphics.rectangle("fill",5,5,love.graphics.getWidth()-10, love.graphics.getWidth()-10)
				
				love.graphics.setColor(255,255,255)
				if self.selector.sel ~=0 then
					
					
					love.graphics.setColor(255,255,255)
					love.graphics.draw(self.imgs[game.name].icon,10,10)
					love.graphics.print(game.name,70,20,0,2,2)
					
					for i=1,#diffs do
						if game.difficulties[self.selector.dif]==diffs[i] then
							love.graphics.setColor(255,255,255)
						else
							love.graphics.setColor(60,60,60)
						end
					
						if contains(game.difficulties, diffs[i]) then
							love.graphics.print(diffs[i], 10+(i-1)*70, 80)
						end
					end
				else
					love.graphics.print("Back to game mode menu",10,200)
				end
				
				love.graphics.setColor(255,255,255)
				love.graphics.draw(self.imgs[game.name].screen,10,100)
				
				love.graphics.print("Uses:", 220, 100)
				for i=1,#game.keys do
					love.graphics.print(game.keys[i],230,100+15*i)
				end
				
				love.graphics.print("Up/Down to change game. Left/Right to select difficulty",15, 320)
				
			end
			self.keypressed = function(self,key)
				if key=='up' then
					self.selector.sel = ((self.selector.sel-1)%(#self.selector.games+1))
					self.selector.dif = 1
				end
				if key=='down' then
					self.selector.sel = ((self.selector.sel+1)%(#self.selector.games+1))
					self.selector.dif = 1
				end
				if key=='right' then
					if self.selector.sel ~= 0  then
						self.selector.dif = ((self.selector.dif)%(#self.selector.games[self.selector.sel].difficulties))+1
					end
				end
				if key=='left' then
					if self.selector.sel ~= 0 then
						self.selector.dif = ((self.selector.dif-2)%(#self.selector.games[self.selector.sel].difficulties))+1
					end
				end
				if key=='return' then
					if self.selector.sel == 0 then
						self.selector.continue = false
					end
					self.done = true
				end
			end
			self.done = false
			self.isDone = function(self)
				return self.done
			end
		end
	}
	mode.pickGame = pickGame
	return mode
end



return makeMode