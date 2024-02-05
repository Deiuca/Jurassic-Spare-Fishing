--Classe cuori 
Cuori = {
    x = 0,
    y = 0,
    width = 10,     --larghezza cuori
    max_cuori = 4,  --cuori massimi
    n_pieni = 4,     --num cuori pieni 
    cuori = {}      --contiene i cuori
}

--carica texture cuoricini
local vuoto = graphics.newImageSheet("textures/cuorevuoto.png", {width = 95, height = 81, numFrames = 1})
local pieno = graphics.newImageSheet("textures/cuorepieno.png", {width = 95, height = 80, numFrames = 1})

function Cuori:new (o)
    o = o or {}   
    setmetatable(o, self)
    self.__index = self
    return o
end

--crea gli oggetti cuori e gli disegna. E gli inserisce in self.cuori
function Cuori:crea()   
	for i = 1, self.max_cuori do
        local c = display.newImageRect(gr_game, pieno, 1, self.width, self.width)
        c.x = self.x + (i*self.width)
        c.y = self.y
        table.insert(self.cuori,c)
    end
end

--toglie num cuori di vita
function Cuori:rimuovi(num) 
    for i = 1, num do
        if(self.n_pieni > 0) then
            self.cuori[self.n_pieni]:removeSelf()                                       -- toglie oggetto cuore alla posizione n_pieni
            self.cuori[self.n_pieni] = nil
            local c = display.newImageRect(gr_game, vuoto, 1, self.width, self.width)   -- rimpiazza il cuore pieno con il cuore vuoto
            c.x = self.x + ((self.n_pieni)*self.width)                                  --Calcola x cuore
            c.y = self.y                                                                  
            self.cuori[self.n_pieni] = c                                                -- Lo rimette
            self.n_pieni = self.n_pieni-1
            --Triggera il GAME OVER!
            if(self.n_pieni == 0)then
                game_over()
            end
        end
    end
end

--Elimina i cuori
function Cuori:elimina()
    while #self.cuori > 0 do
        table.remove(self.cuori)
    end
end