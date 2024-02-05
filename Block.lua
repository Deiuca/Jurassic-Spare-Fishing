--Classe blocco

Block = { 
    texture = "",
    startx = 0,
    starty = 0,
    lato = 3,
    scala = 1,
    ancoraX = 0.5, 
    ancoraY = 0.5,
    grafica = nil
}

--Disegna il blocco in game
function Block:ongame (scala, boolcade, gruppo) 
    scala = scala or self.scala                                             --setta la var al valore di default se non viene specificato
    self.grafica = display.newImageRect(self.texture, self.lato,self.lato)
    self.grafica.x = self.startx
    self.grafica.y = self.starty
    --Ancoraggio
    self.grafica.anchorX = self.ancoraX
    self.grafica.anchorY = self.ancoraY
    self:scale(scala)                                                       --Dim dell'blocco
    self.grafica.gravityScale = 0
    if (gruppo ~= nil)then
        gruppo:insert(self.grafica)                                         --Inserisce nel gr
    end
end

--Ritorna x Blocco
function Block:xx(x)                                                        
    x = x or nil
    if (x ~= nil) then
        self.grafica.x = x
    end
    return self.grafica.x
end

--Ritorna y Blocco
function Block:yy(y)
    y = y or nil
    if (y ~= nil) then
        self.grafica.y = y
    end
    return self.grafica.y
end

-- ridimensiona blocco
function Block:scale(scala)
    scala = scala or 1
    self.grafica.xScale = scala
    self.grafica.yScale = scala
end

--Crea istanza
function Block:new (b)
    b = b or {}   
    setmetatable(b, self)
    self.__index = self
    return b
end