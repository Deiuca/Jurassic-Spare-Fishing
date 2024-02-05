require("Avatar")
Kamikaze = {
    speed = 50,         -- velocità del pesce
    vita = 2,           --quanti hit servono a farlo morire
    target_obj = nil,   --oggetto target del pesce kamikaze (deve essere oggetto display.)
    enemy_display = nil --contenitore della texture
}

function Kamikaze:new (o)
    o = o or {}  
    setmetatable(o, self)
    self.__index = self
    return o
end 

--disegna nemico schermo
function Kamikaze:spawnNemico(x,y)                    
    self.enemy_display = display.newImageRect(gr_game,"textures/helicoprion.png",  20, 10 )                             --crea la texture del nemico
    self.enemy_display.x = x                                                                                            -- posizione in X del nemico
    self.enemy_display.y = y                                                                                            -- posizione in Y del nemico
    self.enemy_display.vita = self.vita                                                                                 --imagazzina vita dentro enemy_display x utilizzarla nella classe colpo
    physics.addBody( self.enemy_display, "dynamic", {outline =graphics.newOutline( 4,"textures/helicoprion.png" )} )    --si aggiunge un corpo fisico al enemy_display   
    self.enemy_display.gravityScale = 0                                                                                 --toglie la gravità
    self.enemy_display.isSensor = true                                                                                  --attiva modalità sensore per le collisioni
    self.enemy_display.tag = "nemico"                                                                                   -- dà il tag nemico all'oggetto creato
    self.enemy_display.timer = timer.performWithDelay( 500, function(evt)                                               --timer per eliminare nemico che esce dallo schermo
        if(self.enemy_display.x < display.screenOriginX or self.enemy_display.x > display.safeActualContentWidth) then  -- if che cancella il nemico se esce dallo schermo
            timer.cancel( self.enemy_display.timer )
            self.enemy_display:removeSelf()
            self.enemy_display = nil
        end
    end , -1 )
    self:getDirection()                                     
end
-- permette al nemico di andare verso il terget_obj
function Kamikaze:getDirection()                                                                                        

    local Direction_X = self.target_obj.x -  self.enemy_display.x                               --prende la direzione in X  
    local Direction_Y = self.target_obj.y - self.enemy_display.y                                --prende la direzione in Y
    local distanza = math.sqrt(Direction_X^2 + Direction_Y^2)                                   --Calcola la distanza tra i punti

    Direction_X = Direction_X/distanza                                                          --normalizzazione della direzione X
    Direction_Y = Direction_Y/distanza                                                          --normalizzazione della direzione Y

    self.enemy_display:setLinearVelocity(Direction_X * self.speed, Direction_Y *self.speed)     --dà la velocità al nemico
end