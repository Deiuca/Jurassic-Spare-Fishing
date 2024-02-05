--Classe Avatar 
require("Aria")
Avatar = {
    img = nil    --crea var per contenere display texture player
}

--Crea e ritorna istanza
function Avatar:new (o)
    o = o or {} 
    setmetatable(o, self)
    self.__index = self
    return o
end

--Crea texture player
function Avatar:crea(x,y) 
    self.img = display.newImageRect(gr_game,"textures/personaggio.png", 25,15)
    self.img.x = x
    self.img.y = y
    physics.addBody( self.img, "dynamic", {outline = graphics.newOutline(3, "textures/personaggio.png")})   --Crea hitbox in base a contorni texture
    self.img.gravityScale = 0
    self.img.isSensor = true
    self.img.collision = B_onLocalCollision                                                                 --Collisione player
    self.img.tag = "avatar"
    self.img.feribile = true                                                                                --se true l'avatar può subire danno con relativa perdita di vita
    self.img:addEventListener("collision")
end

--Collisione player
function B_onLocalCollision(self, event)
    if ( event.phase == "began") then
        if(event.other.tag == "nemico" and self.feribile) then    --Se si scontra con nemico ed è feribile          
            event.other.tag = "disabilitato"
            --il nemico scappa dopo aver dato un "morso"
            event.other.xScale = -1
            event.other:setLinearVelocity(90)
            --suono morso
            audio.play(suono_gnam, {channel = 5})
            --il player diventa invulnerabile per 100*12 tick x evitare di perdere troppi cuori al colpo
            self.feribile = false
            timer.performWithDelay( 100, function(eve)          --Fa lampeggiare il player x 12 volte
                if(self.isVisible )then
                    self.isVisible = false
                else
                    self.isVisible = true
                end
                if(eve.count == 12)then
                    self.isVisible = true
                    self.feribile = true
                end
            end, 12)
            cuori:rimuovi(1)                                    --Rimuove 1 cuore
        elseif event.other.tag == "alga" then                   --Se si scontra con alga(quelle ossigenate) agginge aria e play suono
            aria:aggiungi_Aria()
            audio.play(suono_ossigeno,{channel = 6})
            event.other.tag = "togliere"                        --contrassegna l'alga colpita in modo tale che in Terreno:update_alghe venga eliminata
        elseif event.other.tag == "mun2" then                   --aggiunge la mun al player e la toglie dal game
            event.other.tag = "togliere"
            presa_mun(2)
        elseif event.other.tag == "mun4" then                   --aggiunge la mun al player e la toglie dal game
            event.other.tag = "togliere"
            presa_mun(4)
        elseif event.other.tag == "colpo_nemico" then           --Se si scontra con un colpo nemico
            cuori:rimuovi(1)                                    --Rimuove 1 cuore
            self.feribile = false
            timer.performWithDelay( 100, function(eve)           --stesso timer di 41
                if(self.isVisible )then
                    self.isVisible = false
                else
                    self.isVisible = true
                end
                if(eve.count == 12)then
                    self.isVisible = true
                    self.feribile = true
                end
            end, 12)
            --cancella colpo nemico
            timer.cancel(event.other.timer)                 
            event.other:removeSelf()
            event.other = nil 
        end
    end
end
--Abilita colpi speciali e ne setta il tipo. Inoltre aggiorna gli indicatori relativi alle munizioni specali
function presa_mun(tipo) 
    full_mun.isVisible = true
    una_mun.isVisible = true
    meta_mun.isVisible = true
    munizioni_icona.isVisible = true
    munizioni_icona.alpha = 1
    full_mun.alpha = 1
    meta_mun.alpha = 1
    una_mun.alpha = 1
    mun_type = tipo
    mun_num = 3
    mun = true
end
