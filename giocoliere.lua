local composer = require( "composer" )

local scene = composer.newScene()

local score = require("score")

local punteggiFilePath = system.pathForFile( "punteggigiocoliere.json", system.DocumentsDirectory )

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local physics = require( "physics" )
physics.setReportCollisionsInContentCoordinates( true )
physics.start()
physics.setGravity( 0, 19 ) -- raddoppiata accelerazione caduta palline

--timer
local gameLoopTimer
local lancioLoopTimer
local lancioTimer

local sheetOptions = {
    frames = {
        {   -- 1) giocoliere1 verso destra
            x = 0,
            y = 0,
            width = 164,
            height = 372
        },
        {   -- 2) giocoliere2 verso destra
            x = 165,
            y = 0,
            width = 164,
            height = 372
        },
        {   -- 3) giocoliere3 verso destra
            x = 328,
            y = 0,
            width = 164,
            height = 372
        },
        {   -- 4) giocoliere4 verso destra
            x = 493,
            y = 0,
            width = 164,
            height = 372
        },
        {   -- 5) giocoliere5 verso sinistra
            x = 657,
            y = 0,
            width = 164,
            height = 372
        },
        {   -- 6) giocoliere6 verso sinistra
            x = 821,
            y = 0,
            width = 164,
            height = 372
        },
        {   -- 7) giocoliere7 verso sinistra
            x = 821,
            y = 0,
            width = 164,
            height = 372
        },
        {   -- 8) giocoliere8 verso sinistra
            x = 985,
            y = 0,
            width = 164,
            height = 372
        }
    }
}

local sheetOptions2 = {
    frames = {
        {   -- 1) pallina1
            x = 0,
            y = 100,
            width = 30,
            height = 30
        },
        {   -- 2) pallina2
            x = 31,
            y = 100,
            width = 30,
            height = 30
        },
        {   -- 3) pallina3
            x = 61,
            y = 100,
            width = 30,
            height = 30
        },
        {   -- 4) pallina4
            x = 91,
            y = 100,
            width = 30,
            height = 30
        },
        {   -- 5) pallina5
            x = 121,
            y = 100,
            width = 30,
            height = 30
        }
    }
}

local sheetOptions3 = {
    frames = {
        {   -- 1) pavimento
            x = 0,
            y = 0,
            width = 1280,
            height = 81
        }
    }
}

local sheetOptions4 = {
    frames = {
        {   -- 1) scimmietta
            x = 588,
            y = 0,
            width = 244,
            height = 235
        }
    }
}

local oggettiDiScena = graphics.newImageSheet( "images/giocoliere.png", sheetOptions )
local oggettiDiScena2 = graphics.newImageSheet( "images/oggettini.png", sheetOptions2 )
local oggettiDiScena3 = graphics.newImageSheet( "images/pavimento.png", sheetOptions3 )
local oggettiDiScena4 = graphics.newImageSheet( "images/oggettoni.png", sheetOptions4 )

local vite = 10

local giocoliere
local sequenzaGiocoliere = {
    {
        name = "movimento a destra",
        start = 1,
        count = 4,
        time = 750,
        loopCount = 0,
        loopDirection = "forward"
    },
    {
        name = "movimento a sinistra",
        start = 5,
        count = 8,
        time = 750,
        loopCount = 0,
        loopDirection = "forward"
    }
}


local palline = {}
local pavimento
local scimmia

local seconds = 0
local lifeText
local clockText
local pauseText

local function endGame()
    score.salva(punteggiFilePath,seconds)
    composer.gotoScene( "pausa", { time=2000,params = {scene = "giocoliere",punteggio = seconds} } )
end

local function pausa()
    composer.gotoScene("pausa",{time=10,params = {scene = "giocoliere"} })
end

-- aggiorna vite
local function aggiornaText()
    lifeText.text = "Vite: " .. vite
end

local function mostraScritta(text,delay)
    local scritta = display.newText( uiGroup, text, 300, 500, native.systemFont, 150 )
    timer.performWithDelay(delay,function () display.remove(scritta) end)
end



-- metodi pallina

local function isPallinaPresa(pallina)
    local presa

    if(pallina.y>display.contentHeight-600 or pallina.y<display.contentHeight-800) then
        return false
    end

    if(giocoliere.sequence=="movimento a destra") then
        presa = pallina.x>giocoliere.x+100 and pallina.x<giocoliere.x+175
    else
        presa = pallina.x<giocoliere.x-100 and pallina.x>giocoliere.x-175
    end
    return presa
end


local function rimuoviPallina(pallina)
    display.remove(pallina)
    table.remove(pallina)
end


local function onCollision( pallina,event )

    if ( event.phase == "began" ) then

        local pallina = event.target
        local obj2 = event.other

        if ( obj2.myName == "giocoliere")
        then
            if(isPallinaPresa(pallina)) then
                rimuoviPallina(pallina)
            end
        end

        if ( obj2.myName == "pavimento")
        then
            pallina.collision = nil
            vite = vite - 1 -- il giocatore perde una vita
            aggiornaText()

            --se le vite sono terminate
            if(vite==0)
            then
                pauseText:removeEventListener("tap",pausa)

                --rimuovo i loop
                timer.cancel(lancioLoopTimer)
                timer.cancel( gameLoopTimer )

                -- rimuovi tutti i listener per le collisioni
                for i = #palline, 1, -1 do
                   palline[i].collision = nil
                end

                local endDelay = 2000
                mostraScritta("Game over",endDelay)
                timer.performWithDelay(endDelay, endGame)
            end

        end
    end
end


local function precipitaPallina(pallina)
    local minX = pallina.x-100
    local maxX = pallina.x+100

    if minX<display.contentCenterX-1000 then
        pallina.x = display.contentCenterX -1000

    elseif maxX>display.contentCenterX+1000 then
        pallina.x = display.contentCenterX +1000

    else pallina.x = math.random(minX,maxX)
    end

    -- la pallina cade per la gravità
    physics.addBody(pallina,"dynamic",{radius=30})
end


local function lanciaPallina()
    local pallina = display.newImageRect(mainGroup,oggettiDiScena2,math.random(1,5),50,50)
    pallina.myName = "pallina"
    pallina.collision = onCollision
    pallina:addEventListener("collision")
    table.insert(palline,pallina)

    if(giocoliere.sequence=="movimento a destra") then
        pallina.x = giocoliere.x+120
    else
        pallina.x = giocoliere.x-120
    end
    pallina.y = display.contentHeight-600

    transition.to(pallina,{y=-40,time=700}) -- lancia pallina

    lancioTimer = timer.performWithDelay(2000,function () precipitaPallina(pallina) end,1)
end




-- movimento giocoliere

local function muoviGiocoliere( event )

    local giocoliere = event.target
    local phase = event.phase

    if ( "began" == phase ) then
       display.currentStage:setFocus(giocoliere )
       giocoliere.touchOffsetX = event.x -giocoliere.x

    elseif ( "moved" == phase ) then
       if(giocoliere.x < event.x-giocoliere.touchOffsetX) then
        giocoliere:setSequence("movimento a destra")
       else
        giocoliere:setSequence("movimento a sinistra")
       end

       giocoliere:play()
       giocoliere.x = event.x -giocoliere.touchOffsetX

    elseif ( "ended" == phase or "cancelled" == phase ) then
        display.currentStage:setFocus( nil )
    end
    return true
end




local function formatTime(seconds)
    local minutes = math.floor( seconds / 60 )
    local seconds = seconds % 60
    return string.format( "%02d:%02d", minutes, seconds )
end


local function updateTime()
    seconds = seconds + 1
    clockText.text = formatTime(seconds)
end


local function gameLoop()
    updateTime()
end

local function startGame()
    mostraScritta("START",500)

    --inizia il gioco
    gameLoopTimer = timer.performWithDelay(1000,gameLoop,0)
    lancioLoopTimer = timer.performWithDelay(2000,lanciaPallina,0)

    --lancia la prima pallina
    lanciaPallina()
    
    --aggiungi i listener
    pauseText:addEventListener("tap",pausa)
    giocoliere:addEventListener("touch",muoviGiocoliere)
end

local function start ()
      --countdown
      local countdown = 3
      mostraScritta(countdown,1000)
      timer.performWithDelay(1000,function () countdown = countdown-1 mostraScritta(countdown,1000) end,countdown-1)
  
      --fa partire il gioco
      timer.performWithDelay(countdown*1000,startGame,1)
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

    local background = display.newImageRect( backGroup, "images/sfondo2.png", 3000, 1280 )
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    pavimento = display.newImageRect( mainGroup, oggettiDiScena3, 1, 3000, 200 )
    pavimento.x = display.contentCenterX
    pavimento.y = display.contentHeight-50
    pavimento.myName = "pavimento"
    physics.addBody( pavimento, "static" )

    scimmia = display.newImageRect( mainGroup, oggettiDiScena4, 3, 300, 300 )
    scimmia.x=display.contentCenterX-900
    scimmia.y=display.contentHeight-290

    lifeText = display.newText( uiGroup, "Vite: " .. vite, 900, 90, native.systemFont, 100 )
    clockText = display.newText( uiGroup, formatTime(seconds), display.contentCenterX, 90, native.systemFont, 100 )
    pauseText = display.newText(uiGroup,"Pausa",display.contentCenterX-900,90,native.systemFont,100)

    giocoliere = display.newSprite( mainGroup,oggettiDiScena, sequenzaGiocoliere )
    giocoliere.x = display.contentCenterX-300
    giocoliere.y = display.contentHeight - 520
    giocoliere.myName = "giocoliere"
    giocoliere:scale(2,2)
    physics.addBody(giocoliere,"static")
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        physics.start()
        giocoliere:play()

        if(seconds==0) then
            --all'inizio del gioco
            start()
        else
            timer.resume(gameLoopTimer)
            timer.resume(lancioLoopTimer)
            timer.resume(lancioTimer)
        end
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)

        -- se il gioco non è ancora finito metti in pausa i timer
        if(vite~=0) then
            timer.pause(gameLoopTimer)
            timer.pause(lancioLoopTimer)
            timer.pause(lancioTimer)
        end

        giocoliere:pause()
        physics.pause()

	elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen

        if(vite==0) then
            composer.removeScene("giocoliere")
        end
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

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
