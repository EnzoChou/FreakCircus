local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local physics = require( "physics" )
physics.setReportCollisionsInContentCoordinates( true )
physics.start()
physics.setGravity(0,19) -- raddoppiata accelerazione caduta palline 

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
local oggettiDiScena4 = graphics.newImageSheet( "images/OGGETTONI.png", sheetOptions4 )

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

-- punteggio
local function aggiornaText()
    lifeText.text = "Vite: " .. vite
end

local function mostraScritta(text,delay)
    local scritta = display.newText( uiGroup, text, 300, 500, native.systemFont, 150 )
    timer.performWithDelay(delay,function () display.remove(scritta) end)
end


-- calcola punteggio
local function valore(  )

end



-- metodi pallina

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
    physics.addBody(pallina,"dynamic",{radius=50})
end


local function lanciaPallina()
    local pallina = display.newImageRect(mainGroup,oggettiDiScena2,math.random(1,5),50,50)
    pallina.myName = "pallina"
    table.insert(palline,pallina)

    if(giocoliere.sequence=="movimento a destra") then
        pallina.x = giocoliere.x+120
    else
        pallina.x = giocoliere.x-120
    end
    pallina.y = display.contentHeight-600
    
    transition.to(pallina,{y=-40,time=700}) -- lancia pallina

    timer.performWithDelay(3000,function () precipitaPallina(pallina) end,1)
end


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




local function colpito( event )

    if ( event.phase == "began" ) then

        local obj1 = event.object1
        local obj2 = event.object2

        if ( ( obj1.myName == "giocoliere" and obj2.myName == "pallina" ) or
            ( obj1.myName == "pallina" and obj2.myName == "giocoliere" ) )
        then
            local pallina = obj2
            if(obj1.myName=="pallina") then
                pallina=obj1
            end

            if(isPallinaPresa(pallina)) then
                rimuoviPallina(pallina)
            end
        end

        if ( ( obj1.myName == "pavimento" and obj2.myName == "pallina" ) or
        ( obj1.myName == "pallina" and obj2.myName == "pavimento" ) )
        then
            local pallina = obj2
            if(obj1.myName=="pallina") then
                pallina=obj1
            end 

            rimuoviPallina(pallina)
            vite = vite - 1 -- il giocatore perde una vita
            aggiornaText()
        end
    end
end





local function formatTime(seconds)
    local minutes = math.floor( seconds / 60 )
    local seconds = seconds % 60
    return string.format( "%02d:%02d", minutes, seconds )
end


local function endGame()
    composer.gotoScene( "menu", { time=2000, effect="crossFade" } )
end


local function updateTime()
    seconds = seconds + 1
    clockText.text = formatTime(seconds)

    --se le vite sono terminate
    if(vite==0) then
        Runtime:removeEventListener( "collision", colpito )
        timer.cancel(lancioLoopTimer)
        timer.cancel( gameLoopTimer )
        local endDelay = 2000
        mostraScritta("Game over",endDelay)
        timer.performWithDelay(endDelay, endGame)
    end
end


local function gameLoop()
    updateTime()
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

    giocoliere = display.newSprite( mainGroup,oggettiDiScena, sequenzaGiocoliere )
    giocoliere.x = display.contentCenterX
    giocoliere.y = display.contentHeight - 520
    giocoliere.myName = "giocoliere"
    giocoliere:scale(2,2)
    giocoliere:addEventListener("touch",muoviGiocoliere)
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
        gameLoopTimer = timer.performWithDelay(1000,gameLoop,0)
        lancioLoopTimer = timer.performWithDelay(2000,lanciaPallina,0)
        giocoliere:play()
        lanciaPallina()
        Runtime:addEventListener( "collision", colpito )
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        giocoliere:removeEventListener("touch",muoviGiocoliere)
        giocoliere:pause()
        physics.pause()
	elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
		composer.removeScene( "giocoliere" )
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
