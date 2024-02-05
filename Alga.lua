
Alga = {
    alga_dis = nil, --contiene display obj particella
}

function Alga:new (o)
    o = o or {}  
    setmetatable(o, self)
    self.__index = self
    return o
end 
--disegna l'alga dandole gravità e sensori
function Alga:disegna(x,y, tipo)
    tipo = tipo or 1
    if(tipo == 0) then                                                  --tipo 0 indica l'alga che fa recuperare l'ossigeno il tipo 1 indica le alghe ornamentali
        self.alga_dis = display.newImageRect(gr_game,"textures/alga_aria.png",  10, 9 )
        physics.addBody( self.alga_dis, "dynamic")
        self.alga_dis.gravityScale = 0
        self.alga_dis.isSensor = true
        self.alga_dis.tag = "alga"
        self.alga_dis.timer = timer.performWithDelay( 400, function(evt)                                --crea l'emitter alle alghe, ogni 400 una nuova bolla
            new_Particella(self.alga_dis.x-3,self.alga_dis.y,700,math.random(-15,10),math.random(-10,-5),"textures/bolla1.png")
            new_Particella(self.alga_dis.x-1,self.alga_dis.y-2,700,math.random(-10,5),math.random(-10,-5),"textures/bolla1.png")
            new_Particella(self.alga_dis.x+3,self.alga_dis.y,700,math.random(-10,10),math.random(-10,-5),"textures/bolla1.png")
        end, -1, "alghe")
    else
        self.alga_dis = display.newImageRect(gr_game,"textures/alga2.png",  8, 9 )
    end
    self.alga_dis.tipo = tipo   --stores il tipo di alga
    self.alga_dis.x = x         --indica la posizione in X
    self.alga_dis.y = y         --indica la posizione in Y
end