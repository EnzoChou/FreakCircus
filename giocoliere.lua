local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local physics = require( "physics" )
physics.setReportCollisionsInContentCoordinates( true )
physics.start()

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
local sheetGiocoliere = graphics.newImageSheet("images/giocoliere.png", sheetOptions )

local punti = 0

local giocoliere
local sequenzaGiocoliere = {
    {
        name = "movimento braccia",
        start = 1,
        count = 7,
        time = 1500,
        loopCount = 0,
        loopDirection = "forward"
    }
}


local pallina
local pallina1
local pallina2
local pallina3
local pallina4
local pallina5
local pavimento
local scimmia

local secondsLeft = 180 -- 3 minuti
local puntiText
local clockText

local impulso= 550;

local giocoliereRoundTripDelay = 2000 --5 sec
local pallinaRoundTripDelay = 3000 -- 3 sec


-- punteggio
local function aggiornaText()
    puntiText.text = "Punteggio: " .. punti
end

local function mostraScritta(text,delay)
    local scritta = display.newText( uiGroup, text, 300, 500, native.systemFont, 150 )
    timer.performWithDelay(delay,function () display.remove(scritta) end)
end


-- local function lanciaPallina()
--     cannone:removeEventListener("tap", lanciaPallina)
--     +display.remove( pivotJoint )
--     cannone.isBodyActive = false
--     angoloPallina = math.pi/6 - cannone.rotation*math.pi/180
--     pallaDiCannone:applyLinearImpulse( impulso*math.cos(angoloPallina), -impulso*math.sin(angoloPallina), pallaDiCannone.x, pallaDiCannone.y )
-- end


-- --movimento giocoliere

-- local spostamento = 200

-- local function muoviGiocoliereADestra()

-- end

-- local function muoviGiocoliereASinistra()

-- end


-- local function piazzamentoNuovaPallina()
--     pallina.x = 0
--     pallina.y = 0
--     pallina.isBodyActive=true
--     cannone:addEventListener("tap",lanciaPallina)
-- end


local function formatTime(seconds)
    local minutes = math.floor( seconds / 60 )
    local seconds = seconds % 60
    return string.format( "%02d:%02d", minutes, seconds )
end


local function endGame()
    composer.gotoScene( "menu", { time=2000, effect="crossFade" } )
end


local function updateTime()
    secondsLeft = secondsLeft - 1
    clockText.text = formatTime(secondsLeft)

    --se il tempo è scaduto
    if(secondsLeft==0) then
        cannone:removeEventListener("tap",lanciaPallina)
        timer.cancel( gameLoopTimer )
        local endDelay = 2000
        mostraScritta("Tempo scaduto",endDelay)
        timer.performWithDelay(endDelay, endGame)
    end
end


local function gameLoop()
    updateTime()

end


-- calcola punteggio
local function valore(  )

end



-- local function pallinaPresa( event )

-- end


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

    puntiText = display.newText( uiGroup, "Punteggio: " .. punti, 900, 90, native.systemFont, 100 )
    clockText = display.newText( uiGroup, formatTime(secondsLeft), display.contentCenterX, 90, native.systemFont, 100 )

    giocoliere = display.newSprite( mainGroup,sheetGiocoliere, sequenzaGiocoliere )
    giocoliere.x = display.contentCenterX
    giocoliere.y = display.contentHeight - 420
    giocoliere:scale(1.5,1.5)
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
        giocoliere:play()
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
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
