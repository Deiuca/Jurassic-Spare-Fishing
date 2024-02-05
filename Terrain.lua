--Terrain calsse
require("Block")
require("Alga")
require("Item")
--Oggetto terreno

Terrain = {
    lat = 3,
    sabbia = {},          --sabbia è l'array che contiene i blocchi
    gruppo_terreno = nil, --il display.group del terreno
    alghe = {},           --contiene le alghe attualmente presenti sul terreno
    items = {}            --contiene gli item attualmente presenti sul terreno
}

function Terrain:new (b)    
    b = b or {}  
    setmetatable(b, self)
    self.__index = self
    return b
end

--disegna nuova colonna di sabbia
function Terrain:new_colonna_sabbia(x, lat, ind)
    ind = ind or #self.sabbia                                                                                       --ind è l'indice dell'ultimo blocco precendente (da specificare quando terreno va -->)
    local rumore = (math.ceil(0.5*(math.sin(((x)*0.1)/2) + math.sin(((x)*0.1)/math.pi))*5))                         --valore random di una funzione noise per il terreno
    local yfinal = rumore + (display.contentHeight/1.5) + math.random()                                             --crea valore y finale con del random per effetto terreno nn liscio
    table.insert(self.sabbia, ind+1, Block:new({texture="textures/sandc.png", startx=x, starty=yfinal, lato = lat}))--crea nuovo blocco
    self.sabbia[ind+1]:ongame(nil,nil,self.gruppo_terreno)                                                          --disegna blocco
    self.sabbia[ind+1].grafica.fill.effect = "filter.exposure"                                                      --scurisce/illumina blocco
    self.sabbia[ind+1].grafica.fill.effect.exposure = -0.3
    --SPAWN ITEM / ALGE SUL TERRENO e le inserisce nelle rispettive tabelle:
    --ogni volta su 80 spawna un alga aria
    if(math.random(0,80) == 5 and running)then
        local alga = Alga:new()
        alga:disegna(self.gruppo_terreno.x + x, self.gruppo_terreno.y + math.random(yfinal-5, display.contentHeight-20), 0)--disegna alga sul terreno
        table.insert(self.alghe, alga)
    end
    --ogni 50 spawna una alga decorativa
    if(math.random(0,50) == 5)then
        local alga = Alga:new()
        alga:disegna(self.gruppo_terreno.x + x, self.gruppo_terreno.y + math.random(yfinal-5, display.contentHeight-20), 1)--disegna alga sul terreno
        table.insert(self.alghe, alga)
    end
    --ogni volta su 200 spawna una mun special se il game è partito. L'istuzione vale solo fuori dalla boss fight
    if(math.random(0,200) == 5 and running and not bossfight) then
        table.insert(self.items, new_item(self.gruppo_terreno.x + x, self.gruppo_terreno.y + yfinal+3, "textures/lancia2.png", "mun2", 10,2))
    end
    --ogni volta su 70 spawna una mun special se il game è partito. L'istuzione vale solo nella boss fight
    if(math.random(0,70) == 5 and running and bossfight) then
        table.insert(self.items, new_item(self.gruppo_terreno.x + x, self.gruppo_terreno.y + yfinal+3, "textures/lancia4.png", "mun4", 10,2))
    end
    --Fine creazione item/alghe

    --Crea i blocchi per riempire spazio tra il blocco appena creato e il fondo dello schermo
    for n = 2, math.ceil(((display.contentHeight-(self.sabbia[ind+1]:yy()+self.gruppo_terreno.y))/lat) + lat), 1       --calcola e crea il num di cubi necessari a riempire lo schermo
    do
        table.insert(self.sabbia, ind+n, Block:new({texture="textures/sandc.png", startx=x, starty=self.sabbia[ind+n-1]:yy()+(lat), lato = lat}))
        self.sabbia[ind+n]:ongame(nil,nil,self.gruppo_terreno)
        self.sabbia[ind+n].grafica.fill.effect = "filter.exposure"
        self.sabbia[ind+n].grafica.fill.effect.exposure = -0.3
    end
end

--Crea terreno da pt A a punto B
function Terrain:crea_terreno(inizio, fine)
    while (inizio < fine)
    do
       self:new_colonna_sabbia(inizio,self.lat)
        inizio = inizio + self.lat
    end
end

--Genera e elimina terreno fuori dallo schermo 
function Terrain:update_terrain() 
    if(#self.sabbia > 0 and self.sabbia ~= nil)then
        --Rimuove terreno fuori schermo quando terreno <--
        --Se il rpimo blocco è troppo a sx toglie tutti i blocchi fuori schemo come quest'ultimo
        if (self.sabbia[1]:xx()+ self.gruppo_terreno.x < display.screenOriginX-self.lat)then 
            while(self.sabbia[1]:xx()+self.gruppo_terreno.x < display.screenOriginX-self.lat)
            do
                display.remove(self.sabbia[1].grafica)
                table.remove(self.sabbia, 1)
            end
        end

        --Rimuove terreno fuori schermo quando terreno -->
        --Se l'ultimo blocco è troppo dx toglie tutti i blocchi fuori schemo come quest'ultimo
        if (self.sabbia[table.getn(self.sabbia)]:xx()+ self.gruppo_terreno.x > display.contentWidth+screen_buffer)then 
            while(self.sabbia[table.getn(self.sabbia)]:xx()+self.gruppo_terreno.x > display.contentWidth+screen_buffer) 
            do
                display.remove(self.sabbia[table.getn(self.sabbia)].grafica)
                table.remove(self.sabbia, table.getn(self.sabbia))
            end
        end
    
        --Genera il terreno che sta per entrare in schermo
        --generatore terreno quando si va indietro <--. 
        --Se l'ultimo blocco è + a sx della fine del bordo riempie il buco
        if (self.gruppo_terreno.x + self.sabbia[table.getn(self.sabbia)]:xx() <= display.contentWidth+screen_buffer)then
            while ((self.sabbia[table.getn(self.sabbia)]:xx()+self.gruppo_terreno.x) <= display.contentWidth+screen_buffer) do
                 self:new_colonna_sabbia(self.sabbia[table.getn(self.sabbia)]:xx()+self.lat, self.lat)
            end
        end
    
        --genera terreno quando si va avanti --> 
        --Se il primo blocco è + a dx della fine del bordo riempie il buco
        if(self.gruppo_terreno.x + self.sabbia[1]:xx() >= display.screenOriginX-self.lat)then
            while ((self.sabbia[1]:xx()+self.gruppo_terreno.x) >= display.screenOriginX-self.lat) do
                self:new_colonna_sabbia(self.sabbia[1]:xx()-self.lat,self.lat,0)
            end
        end
    end
end

--Aggiorna e sposta le alghe, dato che, se venissero spostate tramite il gr terreno le hitbox non le "seguirebero". Inoltre elimina le alghe fuori dallo schermo o prese dal player
function Terrain:update_alghe(spostamento) 
    if(#self.sabbia > 0 and self.sabbia ~= nil)then
        --per ogni alga nella tabella
        for i = #self.alghe, 1, -1 do
            if(self.alghe[i].alga_dis ~= nil)then
                --se alga è stata contrassegnata verra tolta
                if(self.alghe[i].alga_dis.tag == "togliere") then
                    if(self.alghe[i].alga_dis.tipo == 0) then           --in base al tipo di alga la procedura di rimozione cambia
                        physics.removeBody( self.alghe[i].alga_dis )
                        timer.cancel( self.alghe[i].alga_dis.timer )
                        self.alghe[i].alga_dis:removeSelf()
                        self.alghe[i].alga_dis = nil
                        table.remove(self.alghe, i)
                    else
                        self.alghe[i].alga_dis:removeSelf()
                        self.alghe[i].alga_dis = nil
                        table.remove(self.alghe, i)
                    end
                else
                    --sposta le alge in base allo spostamento del terreno
                    self.alghe[i].alga_dis.x = self.alghe[i].alga_dis.x + spostamento
                    --se le alghe vanno fuori schermo le elimina
                    if((self.alghe[i].alga_dis.x < display.screenOriginX-self.lat*3) or (self.alghe[i].alga_dis.x > display.contentWidth + screen_buffer)) then
                        self.alghe[i].alga_dis.tag = "togliere"
                    end
                end
            end
        end
    end
end 

--aggiorna posizione e stato items sul terreno
function Terrain:update_items(spostamento) 
    if(#self.items > 0 and self.items ~= nil)then
        --per ogni item nella tabella
        for i = #self.items, 1, -1 do
            if(self.items[i] ~= nil)then
                --se un item è stato contrassegnato verra tolto
                if(self.items[i].tag == "togliere") then
                    physics.removeBody( self.items[i])
                    self.items[i]:removeSelf()
                    self.items[i] = nil
                    table.remove(self.items, i)
                else
                    --sposta gli item in base allo spostamento del terreno
                    self.items[i].x = self.items[i].x + spostamento
                    --Se item vanno fuori schermo vanno eliminati (+20 è un buffer aggiuntivo per evitare eliminazioni premature delle lancie)
                    if((self.items[i].x < display.screenOriginX-self.lat*3) or (self.items[i].x > display.contentWidth +20+ screen_buffer)) then
                        self.items[i].tag = "togliere"
                    end
                end
            end
        end
    end
end 

--svuota tabelle del terreno (x riavvio gioco)
function Terrain:elimina()
    while #self.alghe > 0 do
        table.remove(self.alghe)
    end
    while #self.sabbia > 0 do
        table.remove(self.sabbia)
    end
    while #self.items > 0 do
        table.remove(self.items)
    end
    self =nil
end
