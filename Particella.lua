--crea e ritona una nuova particella
function new_Particella(x,y,life,vel_x,vel_y,texture) 
    x = x or 0                                                      --x della paticella
    y = y or 0                                                      --y della particella
    life = life or 100                                              --ms di tempo prima che venga eliminata
    vel_x = vel_x or 0                                              -- velocità della particella in X
    vel_y = vel_y or 0                                              -- velocità della particella in Y
    local particella = display.newImageRect(gr_game,texture, 2,2)   --crea display obj particella
    particella.x = x
    particella.y = y
    particella.tag = "particella"
    physics.addBody( particella, "dynamic" )                        --da una hitbox alla particella
    particella.isSensor = true
    particella.gravityScale = 0
    particella:setLinearVelocity( vel_x, vel_y )                    --da  movimento la particella
    timer.performWithDelay(life, function(ev)                       --timer x durata della particella
        particella:removeSelf()                                     --eliminazione particella allo scadere del timer
        particella = nil
    end,1, "particelle")
    return particella            
end