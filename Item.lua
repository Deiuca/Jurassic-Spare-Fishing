-- Crea e ritorna un item come oggetto display. Usato per le munizioni trovate sul terreno
function new_item(x,y, texture, tag, largezza, altezza)
    local img = display.newImageRect(gr_game, texture, largezza, altezza )
    img.x = x
    img.y = y
    physics.addBody( img, "static")
    img.gravityScale = 0
    img.isSensor = true
    img.tag = tag                                                           --Assegna il tag dato
    return img
end