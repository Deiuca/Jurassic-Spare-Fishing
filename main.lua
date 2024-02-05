-----------------------------------------------------------------------------------------
--GIOCO
-- main.lua
--
-----------------------------------------------------------------------------------------

io.output():setvbuf("no")           --disabilita il buffer di output(xDebug)
system.activate( "multitouch" )     --abilita multi-touch
widget = require("widget")
local physics = require("physics")

-- Importiamo tutti i file he verranno usati in main
require("Block") 
require("Terrain") 
require("Menu")     
require("joystick") 
require("Aria")     
require("Cuori")    
require("Avatar") 
require("Colpo")       
require("Kamikaze")  
require("Alga")
require("Chioccia")
require("Boss")

--Gruppi:
gr_bg = display.newGroup()      --Gr degli sfondi
gr_terreno = display.newGroup() --Gr che contiene i blocchi che compngono il terreno
gr_game = display.newGroup()    --Contiene tutti gli elementi principali per il gameplay, e gli elementi coi quali il giocatore interagisce
gr_menu = display.newGroup()    --Contiene tutto ciò che compone il menu iniziale & di pausa
gr_imp = display.newGroup()     --Contiene tutto ciò che compone il menu impostazioni
gr_over = display.newGroup()    --Contiene tutto ciò che compone il menu di Game over
gr_win = display.newGroup()     --Contiene tutto ciò che compone il menu di Vittoria

--Variabili:
local lat = 2               --lato(dim) blocchi che compongono il terreno
started = false             --la variabile che indica se il gioco è partito o meno
running = false             -- Variabile Globale che determina se il gioco va o è fermo!
local allow_laterale = true --permette movimento leterale terreno
global_tick = 50            --Lo step del timer principale del gioco (global_timer)
screen_buffer = 35          --serve per compensare uno schemo + ampio di .contentWidth
difficolta = 1              --variabile difficoltà (1 norm 2 diffcile)
mun = false                 --tiene conto se le munizioni speciali sono on o off
mun_type = 1                --tiene conto di che tipo di lancia ha in nella fiocina il giocatore (1(norm), 2(x3), 3(Nemici), 4(Esplosive))
mun_num = 0                 --tiene conto di quante mun speciali ha il player (MAX 3)
local vel_colpo = 70        --la velocità delle fiocine del giocatore 
Punti = 0                   --I punti del giocatore (150 x boss)
bossfight = false           --Indicatore per quando il boss è in game (falso = no boss; true = game nella boss fight)
aria_tick = 0               --Usata nella funzione del timer globale, per tenere conto del tempo che deve passare tra le rimovioni dell aria
local Kamikaze_tick = 2500  --Usata nella funzione del timer globale, per tenere conto del tempo che deve passare tra gli spawn dei nemici Kamikaze. A 2.5 sec cosi spawnano subito
local Nemici_time = 0       --Usata nella funzione del timer globale, per tenere conto del tempo che deve passare tra gli spawn dei nemici
local Tempo_fire = 0        --Usata per pulsante sparo, tiene conto di ogni 0.5 sec passati. In modo che si possa sparare solo ogni 0.5s
local Chioccia_timer = 0    --Indica dopo quanto tempo deve iniziare a spawnare questo tipo di nemico   Usata nella funzione del timer globale, per tenere conto del tempo che deve passare tra gli spawn dei nemici Chioccia
local Chioccia_tick = 0     --Tiene conto del tempo passato per far spawnare questo tipo di nemico

--Carica suoni:
suono_sparo = audio.loadSound("Suoni/Sparo.mp3", {channel = 1}) 
suono_gnam = audio.loadSound("Suoni/Gnam.mp3", {channel = 5})
suono_ossigeno = audio.loadSound("Suoni/Ossigeno.mp3", {channel = 6})
suono_kaboom = audio.loadSound("Suoni/Kaboom.mp3",{channel = 7})
--Carica musica
musica_menu_2 = audio.loadStream("Suoni/menu_song2.mp3", {channel = 4})
musica_boss = audio.loadStream("Suoni/Boss_song_.mp3", {channel = 3})

--START

--Crea oggetto Menù e chiama il metodo per disegnarlo
menu = Menu:new({gr_menu = gr_menu, gioca_function = gioca, impostazioni_function=nil})
menu:create()
--crea istanza player
player = Avatar:new({})
--crea istanza Aria
aria = Aria:new({x=180, y=12, width = 8})
--crea istanza Cuori
cuori = Cuori:new({x = 10, y=12,width = 10})
-- crea istanza joystick
controller = joystick:new({x=27,y=85})

--FUNZIONI

--Metodi utili
function map(x, in_min, in_max, out_min, out_max)                       --per mappare valori
    return out_min + (x - in_min)*(out_max - out_min)/(in_max - in_min)
end

--Chiamata dopo aver premuto play nel Menu, crea comandi e prepara oggetti e variabili per il gioco
function gioca()
    if(not started) then
        physics.start()
        --Creazione dei backgrounds. Vengono creati 2 perchè possano dare l'illusione di essere uno sfondo infinito
        Bg_Sfondo = display.newImageRect(gr_bg,"textures/SFONDO.png", display.contentWidth+300, display.contentHeight)
        Bg_Sfondo2 = display.newImageRect(gr_bg,"textures/SFONDO.png", display.contentWidth+300, display.contentHeight)
        --2° sfondo invertito per che combaci con l'altro
        Bg_Sfondo2.xScale = -1   
        --Posizioni iniziali sfondi                                   
        Bg_Sfondo.x = display.contentWidth/2
        Bg_Sfondo.y = display.contentHeight/2
        Bg_Sfondo2.x = Bg_Sfondo.x + Bg_Sfondo.width 
        Bg_Sfondo2.y =  Bg_Sfondo.y 
        --Crea il testo punti.
        punti_txt = display.newText(gr_game, "", 2, 15, 20,10,native.systemFont, 4)
        punti_txt:setTextColor(0.1,0.1,0.1)
        --Testo Difficoltà (indica in che difficoltà si è)
        difficolta_txt = display.newText(gr_game, "", 2, 30, 20,30, native.systemFont, 3)
        difficolta_txt:setTextColor(0.1,0.1,0.1)
        --Icona/Tasto Munizioni Speciali (Il tasto/Indicatore che abilita i colpi speciali e lo stato delle munizioni speciali)
        munizioni_icona = widget.newButton({
            fontSize = 8,
            labelColor = {default = {0,0,0}, over = {255,127,80}},
            defaultFile = "textures/mun_icona.png",                     
            width = 15,
            height = 15,
            x = display.contentWidth-5,
            y = 95,
            --La funzione abilita/disabilita i colpi speciali modificando il bool mun. Inoltre cambia l'alfa dell'tasto e dei indicatori =
            --della quanità di munizioni speciali per segnalare lo stato di attivo/disattivo
            onRelease = function ()
                if(mun_num > 0)then
                    if(mun and Tempo_fire > 500)then
                        mun = false
                        full_mun.alpha = 0.5
                        meta_mun.alpha = 0.5
                        una_mun.alpha = 0.5
                        munizioni_icona.alpha = 0.5
                    else
                        mun = true
                        full_mun.alpha = 1
                        meta_mun.alpha = 1
                        una_mun.alpha = 1
                        munizioni_icona.alpha = 1
                    end
                end
            end
        })
        --Fa sparire il tasto/indicatore perchè deve comparire per la prima volta solo quando si prende la 1° munizione speciale
        munizioni_icona.isVisible = false
        
        --Rettangoli Segnalatori quantità munizioni speciali.
        full_mun = display.newRect(gr_game, munizioni_icona.x, munizioni_icona.y-munizioni_icona.height/3, munizioni_icona.width, munizioni_icona.height/3)
        full_mun:setFillColor(0,0.5,0, 0.7)
        meta_mun = display.newRect(gr_game, munizioni_icona.x, munizioni_icona.y, munizioni_icona.width, munizioni_icona.height/3)
        meta_mun:setFillColor(1, 0.5, 0, 0.7)
        una_mun = display.newRect(gr_game, munizioni_icona.x, munizioni_icona.y+munizioni_icona.height/3, munizioni_icona.width, munizioni_icona.height/3)
        una_mun:setFillColor(1,0,0,0.7)
        --Li rende invisibili perchè devono comparire con munizioni_icona
        full_mun.isVisible = false
        una_mun.isVisible = false
        meta_mun.isVisible = false

        --Crea Bottone di pausa
        pausa_bottone = widget.newButton({
            label = "| |",
            fontSize = 8,
            labelColor = {default = {0,0,0}, over = {255,127,80}},
            --le due texture per il pulsante premuto e normale
            defaultFile = "textures/gioca.png",                     
            overFile="textures/gioca_pressed.png",
            width = 15,
            height = 15,
            x = display.contentCenterX+5,
            y = 10,
            onRelease = function ()
                pausa()             --richiama la funzione che abilita/disabilita pausa
            end
        })
        gr_game:insert(pausa_bottone)

        --Creazione Terreno
        gr_terreno.y = 20;                                                      --abassa il gruppo terreno
        terreno = Terrain:new({lat=lat, gruppo_terreno= gr_terreno})            --Crea istanza terreno
        terreno:crea_terreno(display.screenOriginX, display.contentWidth+lat*3) --Crea terreno iniziale + punto finale e di origine terreno iniziale

        --Disegna controller e attiva evento touch per controller
        controller:crea()
        --Disegna aria
        aria:crea()
        --Disegna cuori
        cuori:crea()
        --Disegna player in x,y
        player:crea(display.contentWidth/4, display.contentHeight/2)
        
        --Bottone/Cerchio di sparo
        b_spara = display.newCircle( display.contentWidth-30, 95, 12 )
        b_spara:setFillColor(0.5)
        b_spara.alpha = 0.7
        b_spara:addEventListener("touch", fire)

        --Crea rettangolo invisibile per controllare touch del joystick. Il rettangolo si trova della prima metà dello schermo ed =
        --è stato creato per rilevare i tocchi per il joystick. In quando usare il listener touch attaccato al Runtime avrebbe dato problemi col multitouch
        touch_joy = display.newRect(0,display.contentCenterY, display.contentWidth, display.contentHeight)
        touch_joy.alpha = 0
        --Fa si che riveli i tocchi anche quando l'oggetto è invisibile
        touch_joy.isHitTestable = true
        --La funzione che gestisce il listener è all'interno della classe joystick
        touch_joy:addEventListener("touch", controller)
        -- serve per resettare aria_tick ogni volta che si Aggiunge aria
        Runtime:addEventListener("Resetta Aria Tick", function()
            aria_tick = 0
        end)
        --fa partire musica di gioco
        audio.play( musica_menu_2 ,{loops = - 1, channel = 4})
        --Le bool vengono aggiornate
        started = true
        running = true
    end
end

--Aggiorna gioco e elementi di gioco (terreno, player, spawn nemici, movimento items e alghe)
function update_game()
    if(started and running) then
        --Aggiorna txt punti
        punti_txt.text = "Punti:"..tostring(Punti)
        --Aggiorna txt Difficoltà
        if(difficolta==1)then
            difficolta_txt.text = "Difficoltà Normale"
        else
            difficolta_txt.text = "Difficoltà Difficile!"
        end
        --Triggera boss fight dopo 150 pt
        if(Punti >= 150 and not bossfight)then
            bossfight = true
            boss_inizio()
        end
        --Aggiorna Aria:
        aria_tick = aria_tick + global_tick
        --Ogni 15000 = 15 sec toglie una bolla
        if(aria_tick>15000)then  
            aria:togliAria()
            aria_tick = 0      
        end
        --Tempo di ricarica sparo incrementato
        Tempo_fire = Tempo_fire + global_tick

        --Nemici Kamikaze spawn:
        Kamikaze_tick = Kamikaze_tick + global_tick
        --Questo spawn si triggera ogni 3s/diff e fuori dalla boss fight
        if(Kamikaze_tick > 3000/difficolta and not bossfight) then                          --sawnano ogni 4sec
            local spawn_rand = math.random(1,3)                                             --determina quale tipo di nemico spawna
            if(spawn_rand == 1 and Nemici_time < 10250) then
                local nemico = Kamikaze:new({speed=25, vita = 1, target_obj = player.img})
                nemico:spawnNemico(display.safeActualContentWidth, player.img.y)
            end
            if(spawn_rand == 2 and Nemici_time > 10250) then    -- partono dalla chiamata successiva 
                local nemico = Kamikaze:new({speed=25, vita = 1, target_obj = player.img})
                nemico:spawnNemico(display.safeActualContentWidth, math.random(0,display.contentHeight))
            end
            if (spawn_rand == 3 and Nemici_time > 5500) then
                local nemico1 = Kamikaze:new({speed=25, vita = 1, target_obj = player.img})
                local nemico2 = Kamikaze:new({speed=25, vita = 1, target_obj = player.img})
                local nemico3 = Kamikaze:new({speed=25, vita = 1, target_obj = player.img})
                nemico1:spawnNemico(display.safeActualContentWidth, player.img.y)
                nemico2:spawnNemico(display.safeActualContentWidth-3, player.img.y+20)
                nemico3:spawnNemico(display.safeActualContentWidth-6, player.img.y-20)
            end
            Nemici_time = Nemici_time + Kamikaze_tick 
            Kamikaze_tick = 0
        end

        --Creazione e spawn Chioccia:
        Chioccia_tick = Chioccia_tick + global_tick
        --Questo spawn si triggera ogni 4s/diff e fuori dalla boss fight
        if (Chioccia_tick > 4000/difficolta and not bossfight) then
            if(Chioccia_timer > 10250) then                                                 -- permette lo spawn di Chioccia quando chioccia_timer raggiunge i 10250 tick
                local Chioccia = Chioccia:new({speed=0, vita = 1, target_obj = player.img})
                Chioccia:spawnNemico(display.safeActualContentWidth -40,display.safeActualContentHeight + 5)
            end
            Chioccia_timer = Chioccia_timer + Chioccia_tick 
            Chioccia_tick = 0
        end

        --Aggiorna Posizione player:
        --Estrapola da joystick e calcola la prossima posizione del player  
        local px = player.img.x + controller.directionX * controller.velocity
        local py = player.img.y + controller.directionY * controller.velocity

        --controlla Boundering player
        --controllo x bordo Dx
        if(px > display.contentWidth - 1) then                          --controlla che nn vada fuori schermo con correzione 1
            px =  display.contentWidth - 1 
        end
        --controllo x bordo Sx
        if(px < display.screenOriginX + player.img.contentWidth/2) then 
            px = display.screenOriginX + player.img.contentWidth/2
        end
        --controllo y bordo inferiore  
        if(py > display.contentHeight - 5) then --controlla che nn vada fuori schermo 
            py =  display.contentHeight - 5
        end
        --controllo y border superiore (+19 per tenerlo sotto i cuori e aria)
        if(py < display.screenOriginY+ 19 + player.img.contentHeight/2)then
            py = display.screenOriginY + player.img.contentHeight/2 + 19
        end

        --Applico Movimeto al player tramite transizione
        transition.to(player.img, {x = px, y = py, time=global_tick/2})
       
        --Movimento Terreno:
        --La velocità del movimento del terreno è dipende dalla posizione del player. Se è a sx va -->; Se è a dx va <--, =
        --più ci si avvicina al pt dove c'è l'inversione di marica del terreno più quest' ultimo rallenta per non avere un cambio brusco di direzione
        local spostamento = 0
        if(px < display.contentWidth/5 and px > display.contentWidth/14 and allow_laterale)then                 --se è nella zona vicina al turn point
            gr_terreno.x = gr_terreno.x - map(px, display.contentWidth/14,  display.contentWidth/5, 0.1, 0.5)
            spostamento = -map(px, display.contentWidth/14,  display.contentWidth/5, 0.1, 0.5)
        elseif (px < display.contentWidth/14 and allow_laterale) then                                           --se è nella zona per tornare indietro
            gr_terreno.x = gr_terreno.x + 0.4
            spostamento = 0.4
        else                                                                                                    --normale movimento in <--
            gr_terreno.x = gr_terreno.x - 0.5
            spostamento = -0.5
        end
        --Lo spostamento viene passato  a queste funzioni per aggiornare pos item sul terreno
        terreno:update_alghe(spostamento)
        terreno:update_items(spostamento)
        --Aggiorna terreno per adattarsi allo spostamento
        terreno:update_terrain()

        --Movimento backgrounds in base al movimento terreno        
        gr_bg.x = gr_bg.x + spostamento                                                         -- spostamento sfondo
        if(spostamento < 0) then                                                                -- se il terreno si sposta all'indietro
            if (Bg_Sfondo.x + gr_bg.x < display.screenOriginX - Bg_Sfondo.width/2) then         -- se la fine di Bg_Sfondo tocca il bordo sinistro dello schermo
                Bg_Sfondo.x =Bg_Sfondo2.width + Bg_Sfondo2.x                                    -- sposta Bg_Sfondo alla fine di Bg_Sfondo2
            elseif(Bg_Sfondo2.x + gr_bg.x < display.screenOriginX - Bg_Sfondo2.width/2) then    -- se la fine di Bg_Sfondo2 tocca il bordo sinistro dello schermo 
                Bg_Sfondo2.x = Bg_Sfondo.x + Bg_Sfondo.width                                    -- sposta Bg_Sfondo2 alla fine di Bg_Sfondo
            end
        else                                                                                    -- altrimenti se il terreno si sposta in avanti
            if (Bg_Sfondo.x + gr_bg.x > display.screenOriginX + Bg_Sfondo.width) then           -- se l'inizio di Bg_sfondo tocca il bordo destro dello schermo
                Bg_Sfondo.x = Bg_Sfondo2.x - Bg_Sfondo2.width                                   -- sposta Bg_Sfondo all' inizio di Bg_Sfondo2
            elseif(Bg_Sfondo2.x + gr_bg.x > display.screenOriginX + Bg_Sfondo2.width) then      -- se l'inizio di Bg_sfondo2 tocca il bordo destro dello schermo
                Bg_Sfondo2.x = Bg_Sfondo.x - Bg_Sfondo.width                                    -- sposta Bg_Sfondo2 all' inizio di Bg_Sfondo
            end
        end
    end
end

--Funzione chiamata dal tocco del pulsante sparo, serve per spawnare i colpi del giocatore
function fire(evt)
    --Usato per mettere in evidenza il pulsante sparo nella stack del gr_game e associa l'id del tocco multitouch all pulsante
    display.getCurrentStage():setFocus(evt.target, evt.id)                           
    if(running and Tempo_fire > 500) then                                                           --Se il gameplay è on e se è passato abbastanza tempo
        if(mun_type == 1 or not mun) then                                                           --Check se le munizini normali sono selezionate
            local p = new_colpo(player.img.x + 13, player.img.y+2, 1 ,vel_colpo)                    --Colpo normale    
        elseif(mun_num > 0 and mun)then                                                             --Se le munizioni speciali sono selezionate e se ce ne solo abbastanza
            if(mun_type == 2)then                                                                   
                local p = new_colpo(player.img.x + 13, player.img.y+2, mun_type,vel_colpo, true)    --Evoca la fiocina speciale di tipo 2
            elseif(mun_type == 4)then
                local p = new_colpo(player.img.x + 13, player.img.y+2, 4 ,vel_colpo)                --Evoca la fiocina esplosiva
            end
            mun_num = mun_num-1                                                                     --Diminuisce num munizioni speciali
            update_mun()                                                                            --Aggiorna tutti gli indicatori e variabili relative alle munizioni
        end
        Tempo_fire = 0                                                                              --Resetta indicatore tempo sparo
    end
end

--Aggiorna tutti gli indicatori e variabili relative alle munizioni:
function update_mun() 
    if(mun_num == 0)then                --se colpi specali sono finiti cambia a colpi normali e disabilita speciali
        mun_type = 1
        mun = false                
        munizioni_icona.alpha = 0.5
        una_mun.isVisible = false       --toglie ultimo indicatore (l'ultimo rimasto)
        full_mun.alpha = 0.5
        meta_mun.alpha = 0.5
        una_mun.alpha = 0.5
    elseif(mun_num == 2)then            --toglie 3° indicatore
        full_mun.isVisible = false     
        meta_mun.isVisible = true
        una_mun.isVisible = true
    else
        meta_mun.isVisible = false      --toglie indicatore di metà
        una_mun.isVisible = true
        full_mun.isVisible = false
    end
end

--Naconde-Mette in pausa alcuni elementi di gioco e fa comparire menù pausa:
function pausa()
    --Se il gioco va mette in pausa altrimenti lo fa riprendere
    if(running)then
        audio.pause()                           
        physics.pause()
        --mette in pausa tutti i timer necessari
        timer.pause("Colpo")
        timer.pause(global_timer)
        timer.pause("particelle")
        timer.pause("alghe")
        timer.pause("boss")
        --Pausa transizioni
        transition.pauseAll()
        --Nasconde Icone/Pulsanti/Joystick
        joystickBg.alpha = 0
        munizioni_icona.alpha = 0
        full_mun.isVisible = false
        una_mun.isVisible = false
        meta_mun.isVisible = false
        joystickCen.alpha = 0
        b_spara.alpha = 0
        menu:in_game(false)     --Fa comparire menu pausa
        running = false
    else
        physics.start()
        audio.resume()
        --Fa ripartire timers/transizioni
        timer.resume("Colpo")
        timer.resume(global_timer)
        timer.resume("particelle")
        timer.resume("alghe")
        timer.resume("boss")
        transition.resumeAll()
        --Ricompaiono Icone/Pulsanti/Joystick
        joystickCen.alpha = 0.75
        munizioni_icona.alpha = 1
        update_mun()
        joystickBg.alpha = 0.5
        b_spara.alpha = 0.5
        menu:off_game()         --Nasconde Menu pausa
        running = true
    end
end

function restart()
    --ferma musiche e resetta volumi x il next game
    audio.stop()
    audio.setVolume(0.5, {channel=3})
    audio.setVolume(0.5, {channel=4})
    audio.setVolume(0.5, {channel=1})
    audio.setVolume(0.5, {channel=5})
    audio.setVolume(0.5, {channel=6})
    audio.setVolume(0.5, {channel=7})
    --Elimina le tabelle di item/alghe/aria/cuori
    terreno:elimina()
    aria:elimina()
    cuori:elimina()
    --Rimuove Event Listeners
    touch_joy:removeEventListener("touch", controller)
    munizioni_icona:removeEventListener("tap",function()
        if(mun_num > 0)then
            if(mun)then
                mun = false
                munizioni_icona.alpha = 0.7
            else
                mun = true
                munizioni_icona.alpha = 1
            end
        end
    end)
    Runtime:removeEventListener("Resetta Aria Tick", function() -- serve per resettare aria_tick ogni volta che si aggiunde aria
        aria_tick = 0
    end)
    --cancella i gruppi e i loro elementi
    gr_win:removeSelf()
    gr_win = 0
    gr_over:removeSelf()
    gr_over = nil
    gr_imp:removeSelf()
    gr_imp = nil
    gr_game:removeSelf()
    gr_game = nil
    gr_menu:removeSelf()
    gr_menu = nil
    gr_bg: removeSelf()
    gr_bg = nil
    gr_terreno:removeSelf()
    gr_terreno = nil
    --Ricreo i gruppi nello stesso ordine
    gr_bg = display.newGroup()
    gr_terreno = display.newGroup()
    gr_game = display.newGroup()
    gr_menu = display.newGroup()
    gr_imp = display.newGroup()
    gr_over = display.newGroup()
    gr_win = display.newGroup()
    --Cancella e restarta timers
    timer.cancelAll()
    global_timer = timer.performWithDelay( global_tick, update_game, -1 , "globale")
    --Crea nuove istanze
    player = Avatar:new({})
    aria = Aria:new({x=180, y=12, width = 8})
    cuori = Cuori:new({x = 10, y=12, width = 10})
    controller = joystick:new({x=30, y=95})
    --Resetta variabili
    started = false
    running = false
    bossfight = false  
    aria_tick = 0 
    Kamikaze_tick = 2500
    Nemici_time = 0             
    difficolta = 1
    Tempo_fire = 0
    Chioccia_timer = 0
    Chioccia_tick = 0
    mun_type = 1               
    mun_num = 0                
    Punti = 0 
    mun = true
    menu = nil
    --Ricrea e disegna un nuovo menu iniziale
    menu = Menu:new({gr_menu = gr_menu, impostazioni_function=nil})
    menu:create()
end

--Triggera il game over menu, rendendolo visibile:
function game_over()
   fine_game_operazioni()
    gr_over.isVisible = true
end

--Tutte le operazioni per la messa a schermo del boss:
function boss_inizio()
    boss = Boss:new({})--Crea Istanza Boss
    boss:crea() --crea a schermo il boss e la barra vita
    audio.stop(4)
    audio.play(musica_boss, {loops = -1, channel = 3})
end

--Triggera il game win menu, rendendolo visibile
function game_vinto()
    fine_game_operazioni()
    gr_win.isVisible = true
end

--Effettua tutte le op per fermare il gioco dopo una sconfitta/vittoria
function fine_game_operazioni()
    --Ferma Musiche
    audio.stop(4)
    audio.stop(3)
    --Ferma timer
    timer.pause("Colpo")
    timer.pause(global_timer)
    timer.pause("particelle")
    timer.pause("alghe")
    timer.pause("boss")
    timer.pauseAll()
    physics.pause()
    touch_joy.isHitTestable = false     --Disabilita touch_joy in modo tale che non interferisca con pulsante riavvia
    transition.pauseAll()
    --Elimina controlli
    joystickBg.alpha = 0
    munizioni_icona.alpha = 0
    full_mun.isVisible = false
    pausa_bottone.isVisible = false
    una_mun.isVisible = false
    meta_mun.isVisible = false
    joystickCen.alpha = 0
    b_spara.alpha = 0
end

--Timer globale
global_timer = timer.performWithDelay( global_tick, update_game, -1 , "globale") --il timer globale