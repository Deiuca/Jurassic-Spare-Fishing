require("Particella") 
--disegna e crea un nuovo colpo
function new_colpo(x, y, tipo, speed, ricorsione)
    speed = speed or 70                             --velocità al colpo
    ricorsione = ricorsione or false                --per evitare che il suono venga riprodotto 3 volte quando si utilizzano le munizioni di tipo 2
    local texture = nil                             --contenitore della texture
    --munizioni base del player = tipo 1
    if(tipo == 1) then  
        --crea il display object per il colpo
        texture = display.newImageRect(gr_game,"textures/lancia1.png", 9, 2)
        -- gli dà fisica e velocità
        physics.addBody( texture, "dynamic" )
        texture.isBullet = true
        texture.isSensor = true
        texture.gravityScale = 0
        texture:setLinearVelocity(speed, 0)    --velocità proiettile
        audio.play(suono_sparo, {channel=1})
        -- sistema per collisioni
        texture.tag = "colpo"   
        texture.collision = colpo_player_colliderfunc(tipo)
        texture:addEventListener("collision")
    --Colpo nemico
    elseif tipo == 3 then
        texture = display.newImageRect(gr_game,"textures/proiettile_nemico.png", 5, 3)
        -- gli dà fisica e velocità
        physics.addBody( texture, "dynamic" )
        texture.isBullet = true
        texture.isSensor = true
        texture.gravityScale = 0
        local dx, dy = DirezioneColpo(x,y, player.img, speed)
        texture:setLinearVelocity(dx,dy)                                        --velocità proiettile e direzione verso  il player
        texture.tag = "colpo_nemico"   
    --colpo speciale x3
    elseif tipo == 2 then                                                       
         --crea il display object per il colpo
         texture = display.newImageRect(gr_game,"textures/lancia2.png", 9, 2)
         if ricorsione then                                                    --Permette di creare i 3 colpi con la ricorsione
            local p2 = new_colpo(player.img.x + 8, player.img.y+9, 2)
            local p3 = new_colpo(player.img.x + 8, player.img.y-5, 2)
            audio.play(suono_sparo, {channel=1})            
         end
         -- gli dà fisica e velocità
         physics.addBody( texture, "dynamic" )
         texture.isBullet = true
         texture.isSensor = true
         texture.gravityScale = 0
         texture:setLinearVelocity(speed, 0)                                    --velocità proiettile
         -- sistema per collisioni
        texture.tag = "colpo"   
        texture.collision = colpo_player_colliderfunc(tipo)
        texture:addEventListener("collision")
    --Muinizioni esplosive speciali (da usare per il boss)
    elseif tipo == 4 then 
       --crea il display object per il colpo
        texture = display.newImageRect(gr_game,"textures/lancia4.png", 9, 2)
       --riproduce suono
        audio.play(suono_sparo, {channel=1})
       -- gli dà fisica e velocità
        physics.addBody( texture, "dynamic" )
        texture.isBullet = true
        texture.isSensor = true
        texture.gravityScale = 0
        texture:setLinearVelocity(speed, 0)                                      --velocità proiettile
       -- sistema per collisioni
        texture.tag = "colpo"   
        texture.collision = colpo_player_colliderfunc(tipo)
        texture:addEventListener("collision")
    end
    --timer per emttere particelle dal retro del proiettile e per controllo posizione colpo
    texture.timer = timer.performWithDelay( 50, function(evt)
        texture.bolle = new_Particella(texture.x,texture.y,500,math.random(-3,0),math.random(-10,10),"textures/bolla1.png")     --Crea nuova particella
        --se il colpo è uscito dallo schemo viene eliminato
        if(texture.x > display.safeActualContentWidth or texture.x < display.screenOriginX)then                                 --cancella il colpo se fuori dallo schermo
                timer.cancel(texture.timer)
                texture:removeSelf()
                texture = nil
        end
    end, -1, "Colpo")
    --Posizione colpo
    texture.x = x
    texture.y = y
    return texture
end

--Calcola la direzione da colpo a target
function DirezioneColpo(x,y ,target_obj, speed) 
    local dx = target_obj.x - x                 --trova direzione x
    local dy = target_obj.y - y                 --trova direzione y
    local angolo = math.atan2(dy, dx)           --calcola angolo

    return  speed * math.cos(angolo), speed * math.sin(angolo)
end

--crea e ritorna funzione collider per colpi del player
function colpo_player_colliderfunc(tipo)    
    local fun =  function(self, event)
            if event.phase == "began" then
                if event.other.tag == "nemico" then
                    --toglie vita al nemico colpito e in caso lo elimina se la vita è pari ad 1 al momento della collisione
                    if(event.other.vita == 1)then 
                        timer.cancel(event.other.timer)
                        event.other:removeSelf()
                        event.other = nil
                        Punti = Punti + 10
                    else
                        event.other.vita = event.other.vita-1*tipo
                    end
                    --se colpo è colpo esplosivo; quando collide con un nemico
                    if(tipo == 4)then
                        audio.play(suono_kaboom,{channel = 7})
                        local x = self.x
                        local y = self.y
                        local Timer_explo = timer.performWithDelay(100,function(evt)                            --Timer itera tra i frame dell'esplosione
                            local p = display.newImageRect("textures/explosion/Explo"..evt.count..".png",20,20) --Mette a schermo i vari png in ordine tramite il ciclo di evt.count
                            p.x = x
                            p.y = y
                            --questo timer elimina l'immagine quando è troppo "vecchia"
                            p.timer = timer.performWithDelay(100,function() 
                                p:removeSelf()
                            end, 1)
                            end, 7)
                    end
                    --Il colpo elimina se stesso
                    timer.cancel(self.timer)
                    self:removeSelf()
                    self = nil 
                --Collisione col boss
                elseif event.other.tag == "boss" then   
                    event.other.vita = event.other.vita - 5*tipo                --danno dipende da tipo colpo
                    Punti = Punti + 5 + (tipo*5)                                --I punti dipendono dal tipo di colpo
                    --se colpo è colpo esplosivo; quando collide con un nemico = 109
                    if(tipo == 4)then
                        audio.play(suono_kaboom,{channel = 7})
                        local x = self.x
                        local y = self.y
                        local Timer_explo = timer.performWithDelay(100,function(evt)
                            local p = display.newImageRect("textures/explosion/Explo"..evt.count..".png",20,20)
                            p.x = x
                            p.y = y
                            --questo timer elimina l'immagine quando è troppo "vecchia"
                            p.timer = timer.performWithDelay(100,function() 
                                p:removeSelf()
                            end, 1)
                           end, 7)
                    end
                    --Il colpo elimina se stesso
                    timer.cancel(self.timer)
                    self:removeSelf()
                    self = nil 
                --Colpo nemico
                elseif event.other.tag == "colpo_nemico"then
                    Punti = Punti + 20                          --Punti maggiori in questo caso
                    --Elimina altro proiettile
                    timer.cancel(event.other.timer)
                    event.other:removeSelf()
                    event.other = nil
                    -- = 109
                    if(tipo == 4)then 
                        audio.play(suono_kaboom)
                        local x = self.x
                        local y = self.y
                        local Timer_explo = timer.performWithDelay(100,function(evt)
                            local p = display.newImageRect("textures/explosion/Explo"..evt.count..".png",10,10)
                            p.x = x
                            p.y = y
                            --questo timer elimina l'immagine quando è troppo "vecchia"
                            p.timer = timer.performWithDelay(100,function() 
                                p:removeSelf()
                            end, 1)
                            end, 7)
                    end
                    --Elimina se stesso
                    timer.cancel(self.timer)
                    self:removeSelf()
                    self = nil 
                end
            end
        end
    return fun
end