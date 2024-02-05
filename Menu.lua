widget = require("widget")

--frasi splash (Quelle che lampeggiano)
local frasi_splash = {
    "Now with fish!",
    "Idroreppellente!",
    "Senza olio di palma!",
    "Acqua non potabile!",
    "Catch 'em all!!",
    "PescePALLA!",
    "Stay hydrated!",
    "Also try Subnautica!",
    "Nico powered!",
    "Batteries not included!!",
    "Pesca sostenibile!",
    "Un'onda di divertimento!",
    "Acqua minerale naturale!",
    "Do not pee in the water!"
}

Menu = {
    gr_menu= nil, 
    bg = nil
}

--Creazione Menu 
function Menu:create()
    --Crea il background del menu
    self.bg = display.newImageRect(self.gr_menu, "textures/Home.png", display.safeActualContentWidth, display.safeActualContentHeight)
    self.bg.x = display.contentWidth/2
    self.bg.y = display.contentHeight/2
    --crea le scritte Uniud 
    local uni = display.newText("Università degli studi di Udine",display.contentWidth/2,display.contentHeight/2 + 40,native.systemFont,5)
    self.gr_menu:insert(uni)
    local corso = display.newText("Corso di Game Programming",display.contentWidth/2,uni.y + 7,native.systemFont,5)
    self.gr_menu:insert(corso)
    local uni_anno = display.newText("Anno:2022/2023",display.contentWidth/2,corso.y + 7,native.systemFont,5)
    self.gr_menu:insert(uni_anno)
    -- Crea il titolo x il menu di pausa e lo nasconde
    title = display.newImageRect(self.gr_menu,"textures/Titolo.png",display.contentWidth/2 + 50,display.contentHeight/2 - 40)
    title.x = display.contentCenterX
    title.y = display.contentCenterY-25
    title.isVisible = false
    
    --Crea frasi splash
    local splash_font = 5 
    local direzione = false
    --crea e sceglie una frase a caso
    local splash = display.newText(frasi_splash[math.random(#frasi_splash)], display.contentWidth-18, display.contentCenterY - 35, native.systemFont, splash_font)
    --crea animazione delle frasi splash
    splashtimer = timer.performWithDelay( 70, function()
        if(direzione)then
            splash_font = splash_font -1
            if(splash_font <= 3)then        --3 dim minima
                direzione = false
            end
        else
            splash_font = splash_font +1
            if(splash_font >= 7)then        --7 dim massima
                direzione = true
            end
        end
        splash.size = splash_font
    end ,0, "splashtimer")
    splash:setTextColor(1,0,0.88)
    splash:rotate(45)               --ruota testo
    self.gr_menu:insert(splash)
    -- Crea il pulsante "Gioca" 
    playButton = widget.newButton({
        label = "Play",
        fontSize = 8,
        labelColor = {default = {0,0,0}, over = {255,127,80}},
        --le due texture per il pulsante premuto e normale
        defaultFile = "textures/gioca.png",                     
        overFile="textures/gioca_pressed.png",
        width = 30,
        height = 15,
        x = display.contentCenterX,
        y = display.contentCenterY+20,
        --quando premuto nasconde menu e scritte e chiama gioca()
        onRelease = function ()
            timer.pause(splashtimer)    
            self.gr_menu.isVisible = false
            uni.isVisible=false
            corso.isVisible=false
            uni_anno.isVisible=false
            gioca()
        end
    })
    self.gr_menu:insert(playButton)

     --Crea e nasconde menu impostazioni:
    --Crea il pulsante delle impostazioni
    local impostazioniButton = widget.newButton({
        defaultFile = "textures/trimone.png",             
        width = 15,
        height = 15,
        x = display.contentWidth - 20,
        y = display.contentHeight - 20,
        --quando premuto nasconde menu pausa e rivela il menu impostazioni
        onRelease = function()
            timer.pause(splashtimer)
            self.gr_menu.isVisible = false
            gr_imp.isVisible = true
            if(started) then                --menu imp non ha sfondo se il gioco è partito
                bg_menu.isVisible = false
            end
        end
    })
    self.gr_menu:insert(impostazioniButton)
    
   --crea sfondo x impostazioni
    bg_menu = display.newImageRect(gr_imp, "textures/Home.png", display.safeActualContentWidth, display.safeActualContentHeight)
    bg_menu.x = display.contentWidth/2
    bg_menu.y = display.contentHeight/2
    bg_menu.alpha = 0.4

    --Scritte varie imp
    local txt_settings = display.newText(gr_imp, "Impostazioni", display.contentCenterX, display.contentCenterY - 25, native.systemFont, 16)
    txt_settings:setFillColor(1,1,1)
    local txt_musica = display.newText(gr_imp, "Musica: ", display.contentCenterX- 51, display.contentCenterY, native.systemFont, 6)
    local txt_suoni = display.newText(gr_imp, "Suoni: ", display.contentCenterX- 53, display.contentCenterY+ 10, native.systemFont, 6)
    local txt_difficolta = display.newText(gr_imp, "Difficoltà: ", display.contentCenterX- 49, display.contentCenterY+ 20, native.systemFont, 6)
    --creazioni degli slider per la musica
    musica_slider = widget.newSlider({
        x = display.contentCenterX,
        y = display.contentCenterY,
        width = 50,
        height = 2,
        handleWidth = 10, 
        handleHeight = 10,
        value = 50,
        listener = function() 
            audio.setVolume(musica_slider.value/100, {channel=3})
            audio.setVolume(musica_slider.value/100, {channel=4})
        end
    })
    --regola il volume dei suoni 
    suoni_slider = widget.newSlider({
        x = display.contentCenterX,
        y = display.contentCenterY+10,
        width = 50,
        height = 2,
        handleWidth = 10, 
        handleHeight = 10,
        value = 50,
        listener = function() 
            audio.setVolume(suoni_slider.value/100, {channel=1})
            audio.setVolume(suoni_slider.value/100, {channel=5})
            audio.setVolume(suoni_slider.value/100, {channel=6})
            audio.setVolume(suoni_slider.value/100, {channel=7})
        end
    })
    --pulsante difficoltà normale --> difficoltà = 1
    normale = widget.newButton({
        defaultFile = "textures/gioca.png",
        overFile="textures/gioca_pressed.png",   
        label = "Normale",
        labelColor = {default = {0,0,0}, over = {255,127,80}},
        fontSize = 5,            
        width = 20,
        height = 10,
        x = display.contentCenterX - 15,
        y = display.contentCenterY + 20,
        onRelease = function()
            difficolta = 1
        end
    })
    --pulsante difficoltà difficile --> difficoltà = 2
    difficile = widget.newButton({
        defaultFile = "textures/gioca.png",
        overFile="textures/gioca_pressed.png",   
        label = "Difficile Ψ(｀∀ ´#)ﾉ",
        labelColor = {default = {0,0,0}, over = {255,127,80}},
        fontSize = 3,          
        width = 30,
        height = 10,
        x = display.contentCenterX + 25,
        y = display.contentCenterY + 20,
        onRelease = function()
            difficolta = 2
        end
    })
    --pulsante indietro per uscire dalle impostazioni
    back_to_menu = widget.newButton({ 
        defaultFile = "textures/gioca.png",
        overFile="textures/gioca_pressed.png",   
        label = "Indietro",
        labelColor = {default = {0,0,0}, over = {255,127,80}},
        fontSize = 5,          
        width = 20,
        height = 10,
        x = display.contentCenterX,
        y = display.contentCenterY + 40,
        onRelease = function()
            self.gr_menu.isVisible = true   --ricompare menu pausa
            gr_imp.isVisible = false
            timer.resume(splashtimer)
        end
    })
    --inserisce tutti gli elementi precedenti nel gr_imp e gli rende non visibili
    gr_imp:insert(back_to_menu)
    gr_imp:insert(normale)
    gr_imp:insert(difficile)
    gr_imp:insert(musica_slider)
    gr_imp:insert(suoni_slider)
    gr_imp.isVisible = false

    --Creazione Menù Game over
    local gameover_txt = display.newText("GAME OVER!", display.contentCenterX, display.contentCenterY - 20, native.systemFont, 30)
    local gradiente = {
        type="gradient",
        color1 = {1,0,0},
        color2 = {0.35,0,0},
        direction = "down"
    }
    gameover_txt:setFillColor(gradiente)
    --pulsante per ricominciare il gioco 
    local reset = widget.newButton({   
        label = "Riavvia",
        fontSize = 8,
        labelColor = {default = {0,0,0}, over = {255,127,80}},
        --le due texture per il pulsante premuto e normale
        defaultFile = "textures/gioca.png",                     
        overFile="textures/gioca_pressed.png",
        width = 40,
        height = 15,
        x = display.contentCenterX,
        y = display.contentCenterY+20,
        onRelease = function ()
            restart()
        end
    })
    --inserisce tutti gli elementi di game over nel gruppo gr_over e gli rende non visibili
    gr_over:insert(gameover_txt)
    gr_over:insert(reset)
    gr_over.isVisible = false

    --Creazione Menu win
    local win_txt = display.newText("HAI VINTO!", display.contentCenterX, display.contentCenterY - 20, native.systemFont, 30)
    local gradiente = {
        type="gradient",
        color1 = {0,0,1},
        color2 = {0,0,0.4},
        direction = "down"
    }
    win_txt:setFillColor(gradiente) --bianco i colori hanno un range 0-1 e non 0-255
    --pulsante per ricominciare il gioco 
    local reset = widget.newButton({
            label = "Riavvia",
            fontSize = 8,
            labelColor = {default = {0,0,0}, over = {255,127,80}},
            --le due texture per il pulsante premuto e normale
            defaultFile = "textures/gioca.png",                     
            overFile="textures/gioca_pressed.png",
            width = 40,
            height = 15,
            x = display.contentCenterX,
            y = display.contentCenterY+20,
            onRelease = function ()
                restart()
        end
    })
    --inserisce tutti gli elementi di game win nel gruppo gr_win e gli rende non visibili
    gr_win:insert(win_txt)
    gr_win:insert(reset)
    gr_win.isVisible = false
end

--Genera e mostra menu pausa:
function Menu:in_game(sfondo)                                   --se sfondo = true crea uno sfondo per imp
    Runtime:removeEventListener("all")
    if(not sfondo)then
        self.bg.isVisible = false
    end
    --Rende visibili elementi menu pausa
    timer.resume(splashtimer)
    title.isVisible = true
    self.gr_menu.isVisible = true
    playButton.isVisible = false
    --crea bottoni menù pausa
    local riprendi = widget.newButton({
        label = "Riprendi",
        fontSize = 8,
        labelColor = {default = {0,0,0}, over = {255,127,80}},
        --le due texture per il pulsante premuto e normale
        defaultFile = "textures/gioca.png",                     
        overFile="textures/gioca_pressed.png",
        width = 40,
        height = 15,
        x = display.contentCenterX,
        y = display.contentCenterY+10,
        onRelease = function ()
            --Ritorna al gioco e nasconde se stesso
            self:off_game()
            pausa()
        end
    })
    self.gr_menu:insert(riprendi)
    local reset = widget.newButton({
        label = "Riavvia",
        fontSize = 8,
        labelColor = {default = {0,0,0}, over = {255,127,80}},
        --le due texture per il pulsante premuto e normale
        defaultFile = "textures/gioca.png",                     
        overFile="textures/gioca_pressed.png",
        width = 40,
        height = 15,
        x = display.contentCenterX,
        y = display.contentCenterY+30,
        onRelease = function ()
            --riavvia gioco
            restart()
        end
    })
    self.gr_menu:insert(reset)
end

--NAsconde menu pausa
function Menu:off_game()
    timer.pause(splashtimer)
    gr_imp.isVisible = false
    self.gr_menu.isVisible = false
end

function Menu:new(b)
    b = b or {}   -- create object if user does not provide one
    setmetatable(b, self)
    self.__index = self
    return b
end