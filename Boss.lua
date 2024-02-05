Boss = {
    img = nil,      --contiene display object del boss
    life_img = nil  --contiene display object della barra vita
}
--Crea e ritorna istanza
function Boss:new (o)
    o = o or {} 
    setmetatable(o, self)
    self.__index = self
    return o
end

--Crea il boss a schermo
function Boss:crea()
    self.img = display.newImageRect( gr_game,  "textures/prova2boss.png",  60, 30 )                         
    self.img.x = display.safeActualContentWidth-13
    self.img.y = display.contentCenterY
    self.img.vita = 400                                                                                     --variabile che tiene conto della vita del boss
    physics.addBody( self.img, "dynamic", {outline =graphics.newOutline( 6,"textures/prova2boss.png" )})    --crea hitbox in base alle forme della texture del boss
    self.img.tag = "boss"
    self.img.gravityScale = 0
    self.life_img = self:disegnavita(self.img.x-10, self.img.y-25)                                          --disegna la vita sopra la testa del boss
    self.img.firetick = 0                                                                                   --Variabile x rate di fuoco di boss
    self.img.timer = timer.performWithDelay( 30, function()                                                 --Aggiorna il boss e li fa fare azioni
        --Aggiorna pos e velocità boss/healthbar se si avvicina a limiti schemo
        if(self.img.y > display.safeActualContentHeight-40)then
            self.img:setLinearVelocity(0, -10)
        elseif self.img.y < display.safeScreenOriginY+10 then
            self.img:setLinearVelocity(0, 10)
        end
        self:update_vita()
        --Spara ogni 3sec (100x30ms)
        if(self.img.firetick > 100)then
            new_colpo(self.img.x-5, self.img.y,3,50+(difficolta*50))
            self.img.firetick = 0
        else
            self.img.firetick = self.img.firetick +1
        end
        --Evoca Nemici
        if(math.random(0,(300/(difficolta))) == 5)then                                                      -- possibilità di spawnare i nemici aumenta con la difficoltà
            if(difficolta == 2)then                                                                         -- spawna Chioccia solo se la difficoltà è su 2
                local c = Chioccia:new({speed = 50, vita = 1, eta = 2})
                c:spawnNemico(self.img.x-7, self.img.y,3)
            end
            local k = Kamikaze:new({speed = 50, vita = 1, target_obj = player.img})
            k:spawnNemico(self.img.x-7, self.img.y,3)
        end
    end ,-1, "boss")
    self.img:setLinearVelocity(0, -10)                                                                      -- Da velocità iniziale boss
end

--Crea gli oggetti display che costituiscono la barra della vita                                            
function Boss:disegnavita(x,y)
    local bg_vita = display.newRect( gr_game, x, y, 40, 2 )                                                                        --crea sfondo barra vita
    bg_vita:setFillColor(0.5,0.5,0.5,0.5)
    bg_vita.pezzi_vita = {}                                                                                                        --contiene le 4 sezioni 
    for i = 0, 3, 1 do
        --crea rettangolo 1/4 vita e ne calcola la pos = bg_vita.x-(3/8 * bg_vita larghezza)                                       
        local v = display.newRect(gr_game, bg_vita.x-(bg_vita.width*3/8)+(((bg_vita.width/4))*i), bg_vita.y,(bg_vita.width/4),2)   
        v:setFillColor(0.5+(i/10),(i/10),0)                                                                                        --shade diventa + chiara
        table.insert(bg_vita.pezzi_vita, v)
    end
    return bg_vita
end

--Aggiorna posizione e visibilità elementi healthbar; triggera Il win menu
function Boss:update_vita()
    --in base alla vita la healthbar si modifica. La ridondanza di alcune operazioni è messa nel caso che alcuni colpi facciano molti pt di danno
    if(self.img.vita > 300)then
        --Più la vita si abbassa in quel 1/4 di vita, più il rettangolo corrispondente si accorcia (su se stesso)
        self.life_img.pezzi_vita[4].width = map(self.img.vita, 0, 400, 0, (self.life_img.width/4))
    elseif(self.img.vita > 200 and self.img.vita <= 300)then
        self.life_img.pezzi_vita[4].isVisible = false                                               -- fa sparire il rettangolo di vita che nn serve più
        self.life_img.pezzi_vita[3].width = map(self.img.vita, 0, 400, 0, (self.life_img.width/4))
    elseif(self.img.vita > 100 and self.img.vita <= 200)then
        self.life_img.pezzi_vita[4].isVisible = false
        self.life_img.pezzi_vita[3].isVisible = false
        self.life_img.pezzi_vita[2].width = map(self.img.vita, 0, 400, 0, (self.life_img.width/4))
    elseif self.img.vita > 0 and self.img.vita <= 100 then
        self.life_img.pezzi_vita[4].isVisible = false
        self.life_img.pezzi_vita[3].isVisible = false
        self.life_img.pezzi_vita[2].isVisible = false
        self.life_img.pezzi_vita[1].width = map(self.img.vita, 0, 400, 0, (self.life_img.width/4))
    else
        --Quando la vita è 0 la healthbar scopare e il win menu è creato
        self.life_img.isVisible = false
        self.life_img.pezzi_vita[4].isVisible = false
        self.life_img.pezzi_vita[3].isVisible = false
        self.life_img.pezzi_vita[2].isVisible = false
        self.life_img.pezzi_vita[1].isVisible = false
        game_vinto()
    end
    --Muove barre vita con boss
    self.life_img.x = self.img.x-10
    self.life_img.y = self.img.y-25
    for i = 1, #self.life_img.pezzi_vita, 1 do
        self.life_img.pezzi_vita[i].y = self.life_img.y
    end
end