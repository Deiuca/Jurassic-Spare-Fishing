joystick= {
    x=0,
    y=0,
    width=16,
    directionX = 0,
    directionY = 0,
    velocity = 0
}

max_velocity = 5  --massima velocità palyer

function joystick:new (o)
    o = o or {}   
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Crea il joystick
function joystick:crea()
    --Cerchio di sfondo del Joystick
    joystickBg = display.newCircle(gr_game, self.x,self.y, self.width )
    joystickBg:setFillColor( 0.5 )
    joystickBg.alpha = 0.5

    -- Crea il  cerchio di controllo joystick
    joystickCen = display.newCircle(gr_game, self.x, self.y, self.width/2 )
    joystickCen:setFillColor( 0.9 )
    joystickCen.alpha = 0.70

    -- Variabili per il movimento del joystick
    joystickRadius = joystickBg.contentWidth/2
    joystickX, joystickY = joystickBg.x, joystickBg.y

end

-- Funzione di touch per il joystick
function joystick:touch(event)
    if(running) then
        display.getCurrentStage():setFocus(event.target, event.id)
        --solo gli input nella 1° pt schermo (all interno di touch_joy)
        if ( event.phase == "moved"  and  event.x < 102) then                               
            -- Calcola la distanza tra la posizione del touch e la posizione del joystick
             distX = event.x - joystickX
             distY = event.y - joystickY
    
            -- Calcola l'angolo tra la posizione del touch e la posizione del joystick
             angle = math.atan2( distY, distX )
    
            -- Calcola la distanza massima tra la posizione del touch e la posizione del joystick
             dist = math.sqrt( distX*distX + distY*distY )
    
            -- Imposta la posizione del joystick se la distanza non supera il raggio
            if ( dist <= joystickRadius ) then
                joystickCen.x, joystickCen.y = event.x, event.y
            else
            -- Altrimenti, imposta la posizione del joystick al limite del raggio
                joystickCen.x = joystickX + math.cos( angle ) * joystickRadius
                joystickCen.y = joystickY + math.sin( angle ) * joystickRadius
            end
            
            -- Calcola la direzione e la velocità del movimento del joystick (rispetto all'origine)
             self.directionX = ( joystickCen.x - joystickX ) / joystickRadius
             self.directionY = ( joystickCen.y - joystickY ) / joystickRadius
             local vel = dist / joystickRadius
             -- Setta una velocità limite
             if(vel >= max_velocity) then   
                self.velocity = max_velocity
            else
                self.velocity = vel
            end 
    
        elseif ( event.phase == "ended" or event.phase == "cancelled"  or event.x > 102) then
             -- Riporta il joystick alla posizione originale quando si solleva il dito
            self.directionX = 0
            self.directionY = 0
            self.velocity = 0
            joystickCen.x, joystickCen.y = joystickX, joystickY
        end
        return true
    end
end