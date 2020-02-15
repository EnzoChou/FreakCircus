local composer = require( "composer" )

local scene = composer.newScene()

local score = require("score")

local game = "cannone"

-- Reserve channel 1 for background music
audio.reserveChannels( 1 )

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local physics = require( "physics" )
physics.setReportCollisionsInContentCoordinates( true )
physics.start()

local gameLoopTimer
local rotazioneCannoneTimer
local movimentoBersaglioTimer
local record

local musicTrack
local cannoneSound
local colpitoSound

local sheetOptions = {
    frames = {
        {   -- 1) cannone
            x = 0,
            y = 0,
            width = 321,
            height = 234
        },
        {   -- 2) bersaglio
            x = 321,
            y = 0,
            width = 267,
            height = 321
        },
        {   -- 3) scimmia
            x = 588,
            y = 0,
            width = 244,
            height = 235
        },
        {   -- 4) bersaglio1 meta' sinistra
            x = 832,
            y = 0,
            width = 137,
            height = 321
        },
        {   -- 5) bersaglio2 meta' destra
            x = 993,
            y = 0,
            width = 130,
            height = 321
        }
    }
}

local sheetOptions2 = {
    frames = {
        {   -- 1) pallaDiCannone
            x = 252,
            y = 0,
            width = 75,
            height = 75
        },
        {   -- 2) bucoBersaglio
            x = 327,
            y = 0,
            width = 48,
            height = 63
        }
    }
}

local sheetOptions3 = {
    frames = {
        {   -- 1) pavimento
            x = 0,
            y = 0,
            -- width = ,
            -- height =
        }
    }
}

local oggettiDiScena = graphics.newImageSheet( "images/oggettoni.png", sheetOptions )
local oggettiDiScena2 = graphics.newImageSheet( "images/oggettini.png", sheetOptions2 )
local oggettiDiScena3 = graphics.newImageSheet( "images/pavimento.png", sheetOptions3 )

local punti = 0

local cannone
local pallaDiCannone
local bucoBersaglio
local bersaglio
local bersaglio1
local bersaglio2
local pavimento
local scimmia
local angoloCannone = math.pi/6 --30 gradi (angolo iniziale)

local totalTime = 180 -- 3 minuti
local secondsLeft = totalTime
local puntiText
local clockText
local pauseText

local impulso= 550;

local bersaglioRoundTripDelay = 2000 --5 sec
local cannoneRoundTripDelay = 3000 -- 3 sec


-- punteggio
local function aggiornaText()
    puntiText.text = "Punteggio: " .. punti
end

local function mostraScritta(text,delay)
    local scritta = display.newText( uiGroup, text, 300, 500, native.systemFont, 150 )
    timer.performWithDelay(delay,function () display.remove(scritta) end)
end


local function sparaPallaDiCannone()
    cannone:removeEventListener("tap",sparaPallaDiCannone)
    display.remove( pivotJoint )
    cannone.isBodyActive = false
    angoloCannone = math.pi/6 - cannone.rotation*math.pi/180
    pallaDiCannone:applyLinearImpulse( impulso*math.cos(angoloCannone), -impulso*math.sin(angoloCannone), pallaDiCannone.x, pallaDiCannone.y )
    audio.play( cannoneSound )
end


--rotazione cannone

local function ruotaCannoneOrario()
    transition.to(cannone,{rotation=0,time=cannoneRoundTripDelay/2})
    transition.to(pallaDiCannone,{rotation=0,time=cannoneRoundTripDelay/2})
end

local function ruotaCannoneAntiOrario()
    transition.to(cannone,{rotation=-60,time=cannoneRoundTripDelay/2,onComplete = function() ruotaCannoneOrario() end })
    transition.to(pallaDiCannone,{rotation=-60,time=cannoneRoundTripDelay/2})
end

local function ruotaCannone()
    ruotaCannoneAntiOrario()
    rotazioneCannoneTimer = timer.performWithDelay(cannoneRoundTripDelay, ruotaCannoneAntiOrario, 0 )
end



--movimento bersaglio

local spostamento = 200

local function muoviBersaglioADestra()
    transition.to(bersaglio2,{x=display.contentCenterX+750+spostamento,time=bersaglioRoundTripDelay/2})
    transition.to(bersaglio1,{x=display.contentCenterX+600+spostamento,time=bersaglioRoundTripDelay/2 })
    if(bucoBersaglio ~= nil) then
        transition.to(bucoBersaglio,{x=bucoBersaglio.x+(display.contentCenterX+750-bersaglio2.x+spostamento),time=bersaglioRoundTripDelay/2})
    end
end

local function muoviBersaglioASinistra()
    transition.to(bersaglio1,{x=display.contentCenterX+600-spostamento,time=bersaglioRoundTripDelay/2})
    transition.to(bersaglio2,{x=display.contentCenterX+750-spostamento,time=bersaglioRoundTripDelay/2,onComplete = function() muoviBersaglioADestra() end})
    if(bucoBersaglio ~= nil) then
        transition.to(bucoBersaglio,{x=bucoBersaglio.x+(display.contentCenterX+750-bersaglio2.x-spostamento),time=bersaglioRoundTripDelay/2})
    end
end

local function muoviBersaglio()
    muoviBersaglioASinistra()
    movimentoBersaglioTimer = timer.performWithDelay(bersaglioRoundTripDelay, muoviBersaglioASinistra, 0 )
end




local function riposizionaPallaDiCannone()
    cannone.rotation=0
    pallaDiCannone.x = display.contentCenterX-550
    pallaDiCannone.y = display.contentHeight-360
    cannone.isBodyActive=true
    local pivotJoint = physics.newJoint( "pivot", cannone, pallaDiCannone, pallaDiCannone.x, pallaDiCannone.y )
    cannone:addEventListener("tap",sparaPallaDiCannone)

end


local function formatTime(seconds)
    local minutes = math.floor( seconds / 60 )
    local seconds = seconds % 60
    return string.format( "%02d:%02d", minutes, seconds )
end


local function pausa()
    composer.gotoScene("pausa",{time=10,params = {scene = "cannone"} })
    audio.stop( 1 )
end

local function associaRecord( punteggi )
    record = punteggi[table.maxn(punteggi)]
end

local function endGame()
    composer.gotoScene( "pausa", { time=2000,params = {scene = "cannone", punteggio = punti, record = record} } )
end


local function updateTime()
    secondsLeft = secondsLeft - 1
    clockText.text = formatTime(secondsLeft)

    --se il tempo è scaduto
    if(secondsLeft==0) then
        pauseText:removeEventListener("tap",pausa)
        cannone:removeEventListener("tap",sparaPallaDiCannone)
        timer.cancel( gameLoopTimer )
        local endDelay = 2000
        mostraScritta("Tempo scaduto",endDelay)
        timer.performWithDelay(endDelay, endGame)
    end
end


local function gameLoop()
    updateTime()
    --Se la palla esce fuori dallo schermo riposizionala
    if ( pallaDiCannone.x > display.contentWidth*2 + 100 or
         pallaDiCannone.y < -100 )
    then
            riposizionaPallaDiCannone()
            print("palla fuori schermo")
    end
end


-- calcola punteggio
local function valore( valoreYcolpito, valoreYBersaglio )
    local accuracy = math.abs((valoreYcolpito-valoreYBersaglio)/30)
    local risultato
    if ( accuracy< 0.5 )
        then risultato = 120
    elseif ( accuracy<1.5 )
        then risultato = 100
    elseif ( accuracy<2.5 )
        then risultato = 80
    elseif ( accuracy<3.5 )
        then risultato = 60
    else
        risultato = 5
    end
    return risultato
end



local function colpito( event )

    if ( event.phase == "began" ) then
        local obj1 = event.object1
        local obj2 = event.object2

        --local midX = ( obj1.x + obj2.x ) * 0.5
        --local midY = ( obj1.y + obj2.y ) * 0.5

        if ( ( obj1.myName == "bersaglio" and obj2.myName == "pallaDiCannone" ) or
            ( obj1.myName == "pallaDiCannone" and obj2.myName == "bersaglio" ) )
        then
            audio.play( colpitoSound )
            local risultato = valore( obj2.y, obj1.y )
            mostraScritta("+"..risultato,1000)
            transition.pause()

            if (risultato>5)
            then
                display.remove(bucoBersaglio) --se il buco gia' esiste lo rimuovo
                bucoBersaglio = display.newImageRect( mainGroup, oggettiDiScena2, 2, 32, 42 )
                bucoBersaglio.x = event.x
                bucoBersaglio.y = event.y
            end

            punti = punti + risultato
            aggiornaText()

            timer.performWithDelay( 500, riposizionaPallaDiCannone )
        end

        if ( ( obj1.myName == "pavimento" and obj2.myName == "pallaDiCannone" ) or
        ( obj1.myName == "pallaDiCannone" and obj2.myName == "pavimento" ) )
        then
            transition.pause()
            pallaDiCannone:setLinearVelocity(0,-100) -- la palla rimbalza di poco quando colpisce il pavimento (evita effetto sponda per colpire il bersaglio)
            timer.performWithDelay( 500, riposizionaPallaDiCannone )
        end
    end
end




local function startGame()
    mostraScritta("START",500)

    gameLoopTimer = timer.performWithDelay(1000,gameLoop,0) --inizia il gioco

    --muovi gli oggetti
    ruotaCannone()
    muoviBersaglio()

    --aggiungi i listener
    pauseText:addEventListener("tap",pausa)
    cannone:addEventListener( "tap",sparaPallaDiCannone )
    Runtime:addEventListener( "collision", colpito )
end

local function start()
    --countdown
    local countdown = 3
    mostraScritta(countdown,1000)
    timer.performWithDelay(1000,function () countdown= countdown-1 mostraScritta(countdown,1000) end,countdown-1)

    --fa partire il gioco
    timer.performWithDelay(countdown*1000,startGame,1)
    audio.play( musicTrack, { channel=1, loops=-1 } )
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    physics.pause()

    -- Set up display groups
    backGroup = display.newGroup()
    sceneGroup:insert( backGroup )

    mainGroup = display.newGroup()
    sceneGroup:insert( mainGroup )

	uiGroup = display.newGroup()
	sceneGroup:insert( uiGroup )

  score.carica( game, associaRecord )

    local background = display.newImageRect( backGroup, "images/sfondo2.png", 3000, 1280 )
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    pavimento = display.newImageRect( mainGroup, oggettiDiScena3, 1, 3000, 200 )
    pavimento.x = display.contentCenterX
    pavimento.y = display.contentHeight-50
    pavimento.myName = "pavimento"
    physics.addBody( pavimento, "static" )

    bersaglio1 = display.newImageRect( mainGroup, oggettiDiScena, 4, 150, 200 )
    bersaglio1.x = display.contentCenterX+600
    bersaglio1.y = display.contentHeight-250

    bersaglio2 = display.newImageRect( mainGroup, oggettiDiScena, 5, 150, 200 )
    bersaglio2.x = display.contentCenterX+750
    bersaglio2.y = display.contentHeight-250
    bersaglio2.myName="bersaglio"
    physics.addBody( bersaglio2, "static" )

    --bersaglio = display.newImageRect( mainGroup, oggettiDiScena, 2, 400, 300 )
    --bersaglio.x = display.contentCenterX+800
    --bersaglio.y = display.contentHeight-270
    --physics.addBody( bersaglio,"static" )

    pallaDiCannone = display.newImageRect( mainGroup, oggettiDiScena2, 1, 75, 75 )
    pallaDiCannone.x = display.contentCenterX-600
    pallaDiCannone.y = display.contentHeight-290
    pallaDiCannone.myName="pallaDiCannone"
    physics.addBody( pallaDiCannone,"dynamic",{ radius=30, bounce=0.3,density=8 } )

    cannone = display.newImageRect( mainGroup, oggettiDiScena, 1, 300,200 )
    cannone.x=display.contentCenterX-750
    cannone.y=display.contentHeight-130
    cannone.anchorX =  130/321 --175,642/321
    cannone.anchorY = 176,203/234
    physics.addBody(cannone,"static")

    local pivotJoint = physics.newJoint( "pivot", cannone, pallaDiCannone, pallaDiCannone.x, pallaDiCannone.y )

    scimmia = display.newImageRect( mainGroup, oggettiDiScena, 3, 300, 300 )
    scimmia.x=display.contentCenterX-900
    scimmia.y=display.contentHeight-290

    puntiText = display.newText( uiGroup, "Punteggio: " .. punti, 900, 90, native.systemFont, 100 )
    clockText = display.newText( uiGroup, formatTime(secondsLeft), display.contentCenterX, 90, native.systemFont, 100 )
    pauseText = display.newText(uiGroup,"Pausa",display.contentCenterX-900,90,native.systemFont,100)

    -- zona audio
    musicTrack = audio.loadStream( "audio/Clown_and_wizards.mp3" )
    cannoneSound = audio.loadSound( "audio/Cannon.mp3" )
    colpitoSound = audio.loadSound( "audio/targetCrack.mp3" )

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
    audio.play( musicTrack, { channel=1, loops=-1 } )

	elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        physics.start()

        if(secondsLeft==totalTime) then
            -- all'inizio del gioco
            start()
        else
            --durante il gioco
            transition.resume()
            timer.resume(gameLoopTimer)
            timer.resume(movimentoBersaglioTimer)
            timer.resume(rotazioneCannoneTimer)
            Runtime:addEventListener( "collision", colpito )
        end

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        Runtime:removeEventListener( "collision", colpito )

        -- se il gioco non è finito metti in pausa il timer
        if(secondsLeft~=0) then
            timer.pause(gameLoopTimer)
        end

        timer.pause(rotazioneCannoneTimer)
        timer.pause(movimentoBersaglioTimer)
        transition.pause()
        physics.pause()
	elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        if(secondsLeft==0) then
            composer.removeScene( "cannone" )
            audio.stop( 1 )
        end
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
  audio.stop( 1 )
  audio.dispose( musicTrack )
  audio.dispose( cannoneSound )
  audio.dispose( colpitoSound )

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
