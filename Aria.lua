Aria = {
	x = 0,
	y = 0,
	width = 10,		--larghezza bolle
	n_bolle = 4, 	--Massimo num bolle (4)
	bolle = {}		--contiene obj display delle bolle
}

--Crea e ritorna istanza
function Aria:new (o)
      o = o or {}   
      setmetatable(o, self)
      self.__index = self
      return o
end

--Aggiunge una bolla d'aria 
function Aria:aggiungi_Aria()
	Runtime:dispatchEvent({name = "Resetta Aria Tick"}) 									--triggera in main l'evento per resettare aria_tick
	if(#self.bolle < self.n_bolle) then 													--l'aggiunta di bolle è possibile solo se il contenuto di bolle è minore di n_bolle (max)
		local r = #self.bolle or 0
		local b = display.newImageRect(gr_game, "textures/bolla1.png", self.width,self.width)
		b.x = (self.x) + (self.width * r) 													--calcola posizione bolla
		b.y =  self.y
		table.insert(self.bolle,b)
	end
end

--crea bolle in partenza (chaiamta in gioca())
function Aria:crea()
	for i = 1, self.n_bolle do
		self:aggiungi_Aria()
	end
end

--Toglie aria
function Aria:togliAria()
	if(table.getn(self.bolle) > 1) then						-- toglie l'aria solo se la tabella bolle è maggiore di 1
		display.remove(self.bolle[#self.bolle]) 
		table.remove(self.bolle, table.getn(self.bolle))
	else
		display.remove(self.bolle[#self.bolle]) 			-- manda in game over se la tabella bolle è minore di 1
		table.remove(self.bolle, table.getn(self.bolle))
		game_over()											--Se l'aria è finita si va in GAME OVER!
	end
end	

-- elimina le bolle dalla tabella al reset
function Aria:elimina() 
	while #self.bolle > 0 do
        table.remove(self.bolle)
    end
end