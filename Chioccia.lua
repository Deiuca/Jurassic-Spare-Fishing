require("Avatar")
require("Colpo")

Chioccia = {
    speed = 50,                     --velocità del pesce
    vita = 1,                       --quanti hit servono a farlo schiattare
    eta = 6,                        --num min di secondi prima di cancellarsi
    target_obj = nil,               --oggetto target del pesce kamikaze (deve essere oggetto display.)
    enemy_display = nil
}

function Chioccia:new (o)
    o = o or {}  
    setmetatable(o, self)
    self.__index = self
    return o
end 

--Disegna nemico schermo:
function Chioccia:spawnNemico(x,y)                                                  
    self.enemy_display = display.newImageRect(gr_game,"textures/Chioccia.png",  20, 10 )    --crea la texture del nemico
    self.enemy_display.x = x                                                                -- posizione in X del nemico
    self.enemy_display.y = y                                                                -- posizione in Y del nemico
    self.enemy_display.vita = self.vita                                                     --imagazzina vita dentro enemy_display x utilizzarla nella classe colpo
    self.enemy_display.tag = "nemico"                                                       -- dà il tag nemico all'oggetto creato
    physics.addBody( self.enemy_display, "dynamic")                                         --si aggiunge un corpo fisico al enemy_display   
    self.enemy_display.gravityScale = 0                                                     --toglie la gravità
    self.enemy_display.isSensor = true                                                      --attiva modalità sensore per le collisioni
    self.enemy_display:setLinearVelocity(0, -30)                                            --da il movimento in Y
    self.enemy_display.aspettativa = 0                                                      --var x tenere conto dell'età del nemico
    self.enemy_display.fire_time = 0                                                        --var x tenere conto di quando sparara
    self.enemy_display.oldage = function() 
        --Elimina il nemico quando diventa troppo vecchio (4sec)
        if(self.enemy_display.aspettativa > self.eta)then
            timer.cancel(self.enemy_display.timer)
            self.enemy_display:removeSelf()
            self.enemy_display = nil
        end
    end               
    --timer per permettere alla chiocciola di sparare ogni 3s
    self.enemy_display.timer = timer.performWithDelay(1000,function() 
        --Se il gioco gira (= nn in pausa)  
        if (running) then 
            if(self.enemy_display.fire_time > 3) then                                   --Se passati 3s spara
                local e = new_colpo(self.enemy_display.x - 12, self.enemy_display.y, 3) 
                self.enemy_display.fire_time = 0
            else
                self.enemy_display.fire_time = self.enemy_display.fire_time +1
            end
            self.enemy_display.aspettativa = self.enemy_display.aspettativa +1      --aggiorna età nemico
            --Impedisce che il nemico esca per sempre dal content space
            if(self.enemy_display.y < display.safeScreenOriginY-5) then
                self.enemy_display:setLinearVelocity(0,0)
                self.enemy_display:setLinearVelocity(0,30)
                self.enemy_display.oldage()                                         --se il nemico, quando è fuori schermo è troppo vecchio, lo elimina
            elseif self.enemy_display.y > display.safeActualContentHeight +5 then
                self.enemy_display:setLinearVelocity(0,0)
                self.enemy_display:setLinearVelocity(0, -30)
                self.enemy_display.oldage()                                         --se il nemico, quando è fuori schermo è troppo vecchio, lo elimina
            end
        end 
    end, -1) 
end