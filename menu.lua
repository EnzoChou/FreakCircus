local composer = require( "composer" )
local widget = require( "widget" )
local scene = composer.newScene()
-- Reserve channel 1 for background music
audio.reserveChannels( 1 )
-- Reduce the overall volume of the channel
audio.setVolume( 0.5, { channel = 1 } )

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

local sheetOptions = {
    frames = {
        {   -- pulsante/biglietto
            x = 0,
            y = 0,
            width = 252,
            height = 100
        },
        {   -- pallina
            x = 0,
            y = 100,
            width = 30,
            height = 30
        }
    }
}

local sheetOptions2 = {
    frames = {
        { -- icona opzioni, credits --> "Icon made by Freepik from www.flaticon.com"
            x = 0,
            y = 0,
            width = 192,
            height = 192
        }
    }
}

local sheetOptions3 = {
    frames = {
        { -- barra audio --> "Icon made by "Apache 2.0" from https://icon-icons.com/icon/minus/111123"
            x = 56,
            y = 246,
            width = 400,
            height = 20
        }
    }
}

local oggettiDiScena = graphics.newImageSheet( "images/oggettini.png", sheetOptions )
local oggettiDiScena2 = graphics.newImageSheet( "images/ingranaggio_giallo.png", sheetOptions2 )
local oggettiDiScena3 = graphics.newImageSheet( "images/minus_111123.png", sheetOptions3 )


-- initialize local variables
local backGroup
local impostazioniGroup
local punteggiGroup
local giochiGroup
local principaleGroup
local gruppoInScena

local background
local title

-- bottoni principaleGroup
local playButton
local impostazioniButton
local punteggiButton

-- bottoni giochiGroup
local cannoneButton
local giocoliereButton

-- bottoni punteggiGroup
local punteggiCannoneButton
local punteggiGiocoliereButton

-- bottone indietro
local indietroButton
local toggleIndietroOnOff = 0

-- bottone impostazioni
local impostazioniButton
local toggleImpostazioniOnOff = 1
local soundtrackAudioBar
local pulsanteAudio

-- audio
local musicTrack
local bottoneMusic


local function gotoCannone( event )
    local phase = event.phase
    if phase == "ended" then
        audio.play( bottoneMusic )
        composer.gotoScene( "cannone" , { time=800, effect = "crossFade" } )
    end
end

local function gotoGiocoliere( event )
    local phase = event.phase
    if phase == "ended" then
        audio.play( bottoneMusic )
        composer.gotoScene( "giocoliere" , { time=800, effect = "crossFade" } )
    end
end

local function goToPunteggiCannone( event )
    local phase = event.phase
    if phase == "ended" then
        audio.play( bottoneMusic )
        composer.gotoScene( "punteggi" , { time=10, params = {game = "cannone"} } )
    end
end

local function goToPunteggiGiocoliere( event )
    local phase = event.phase
    if phase == "ended" then
        audio.play( bottoneMusic )
        composer.gotoScene( "punteggi" , { time=10, params = {game = "giocoliere"} } )
    end
end


local function toggleIndietroButton()
    if ( gruppoInScena ~= principaleGroup ) then
        transition.to( indietroButton, { time = 1000, effect = "fadeIn", alpha = 1 } )
        toggleIndietroOnOff = 1
    else
        transition.to( indietroButton, { time = 1000, effect = "fadeOut", alpha = 0 } )
        toggleIndietroOnOff = 0
    end
end

local function toggleImpostazioniButton()
    if ( toggleImpostazioniOnOff == 0 ) then
        transition.to( impostazioniButton, { time = 1000, effect = "fadeIn", alpha = 1 } )
        toggleImpostazioniOnOff = 1
    else
        transition.to( impostazioniButton, { time = 1000, effect = "fadeOut", alpha = 0 } )
        toggleImpostazioniOnOff = 0
    end
end

local function giochiInScena()
    transition.to( giochiGroup, { time = 1000, transition = easing.inOutElastic,
                                  x = 0 } )
    gruppoInScena = giochiGroup
end

local function gotoGiochi( event )
    local phase = event.phase
    if phase == "ended" then
        transition.to( gruppoInScena, { time = 1000, transition = easing.inOutElastic,
                                          x = -3000,
                                          onStart = giochiInScena
                                        }
                      )
        toggleIndietroButton()
        audio.play( bottoneMusic )
    end
end

local function impostazioniInScena()
    transition.to( impostazioniGroup, { time = 1000, transition = easing.inOutElastic,
                                        x = 0 } )
    gruppoInScena = impostazioniGroup
end

local function punteggiInScena()
    transition.to( punteggiGroup, { time = 1000, transition = easing.inOutElastic,
                                  x = 0 } )
    gruppoInScena = punteggiGroup
end

local function gotoPunteggi( event )
    local phase = event.phase
    if phase == "ended" then
        transition.to( gruppoInScena, { time = 1000, transition = easing.inOutElastic,
                                          x = -3000,
                                          onStart = punteggiInScena
                                          }
                     )
        audio.play( bottoneMusic )
        toggleIndietroButton()
    end
end




local function menuPrincipale()
    transition.to( principaleGroup, { time = 1000, transition = easing.inOutElastic,
                                      x = 0 } )
    gruppoInScena = principaleGroup
end

local function tornaMenuPrincipale( event )
    local phase = event.phase
    if phase == "ended" then
        if ( gruppoInScena ~= principaleGroup ) then
            transition.to( gruppoInScena, { time = 1000, transition = easing.inOutElastic,
                                            x = 3000,
                                            onStart = menuPrincipale } )
            audio.play( bottoneMusic )
            toggleIndietroButton()
        end
    end
end

-- funzioni per la pagina impostazioni

local function gotoImpostazioni( event )
    if gruppoInScena ~= impostazioniGroup then
        local phase = event.phase
        if phase == "began" then
            impostazioniButton:rotate( 30 )
        elseif phase == "ended" then
            impostazioniButton:rotate( -30 )
            transition.to( gruppoInScena, { time = 1000, transition = easing.inOutElastic,
                                              x = -3000,
                                              onStart = impostazioniInScena
                                              }
                         )
            audio.play( bottoneMusic )
            toggleIndietroButton()
        end
    end
end

local function dragAudio( event )

    local t = event.target
    local phase = event.phase
    local xMin = soundtrackAudioBar.x-500
    local xMax = soundtrackAudioBar.x+500

    if ( "began" == phase ) then
        -- Set touch focus on the t
        display.currentStage:setFocus( t )
        -- Store initial offset position
        t.touchOffsetX = event.x - t.x

    elseif ( "moved" == phase ) then
        -- Move the t to the new touch position

        t.x = event.x - t.touchOffsetX
        audio.setVolume( ( (t.x-xMin)/2000 ), { channel = 1 } )
        if (t.x < xMin) then t.x = xMin end
        if (t.x > xMax) then t.x = xMax end

    elseif ( "ended" == phase or "cancelled" == phase ) then
        -- Release touch focus on the pallina
        display.currentStage:setFocus( nil )
    end

    return true  -- Prevents touch propagation to underlying objects
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

  -- setup display groups

  backGroup = display.newGroup()
  sceneGroup:insert( backGroup )

  impostazioniGroup = display.newGroup()
  sceneGroup:insert( impostazioniGroup )
  impostazioniGroup.x = 3000

  punteggiGroup = display.newGroup()
  sceneGroup:insert( punteggiGroup )
  punteggiGroup.x = 3000

  giochiGroup = display.newGroup()
  sceneGroup:insert( giochiGroup )
  giochiGroup.x = 3000

  principaleGroup = display.newGroup()
  sceneGroup:insert( principaleGroup )
  gruppoInScena = principaleGroup

	background = display.newImageRect( backGroup, "images/sfondo1.png", 3000, 1280 )
  background.x = display.contentCenterX
	background.y = display.contentCenterY

  --title = display.newText( backGroup, "Freak Circus", display.contentCenterX, 300, native.systemFont, 200 );

  playButton = widget.newButton {
      x = display.contentCenterX,
      y = 1000,
      width = 380, -- valori di default 630
      height = 150, -- valori di default 250
      defaultFile = oggettiDiScena,
      label = "Gioca",
      labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
      fontSize = 70, -- valori di default 100
      onEvent = gotoGiochi,
  }
  principaleGroup:insert( playButton )

  punteggiButton = widget.newButton {
    x = display.contentCenterX,
    y = 1180,
    width = 380, -- valori di default 630
    height = 150, -- valori di default 250
    defaultFile = oggettiDiScena,
    label = "Punteggi",
    labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
    fontSize = 60, -- valori di default 100
    onEvent = gotoPunteggi,
}
principaleGroup:insert( punteggiButton )

  cannoneButton = widget.newButton {
      --left = -850,
      --top = 925,
      x = display.contentCenterX,
      y = 1000,
      width = 380, -- valori di default 630
      height = 150, -- valori di default 250
      defaultFile = oggettiDiScena,
      label = "Cannone",
      labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
      fontSize = 70, -- valori di default 100
      onEvent = gotoCannone,
  }
  giochiGroup:insert( cannoneButton )

  giocoliereButton = widget.newButton {
      x = display.contentCenterX,
      y = 1180,
      width = 380, -- valori di default 630
      height = 150, -- valori di default 250
      defaultFile = oggettiDiScena,
      label = "Giocoliere",
      labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
      fontSize = 70, -- valori di default 100
      onEvent = gotoGiocoliere,
  }
  giochiGroup:insert( giocoliereButton )


  punteggiCannoneButton = widget.newButton {
    x = display.contentCenterX,
    y = 1000,
    width = 380, -- valori di default 630
    height = 150, -- valori di default 250
    defaultFile = oggettiDiScena,
    label = "Cannone",
    labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
    fontSize = 70, -- valori di default 100
    onEvent = goToPunteggiCannone,
}
punteggiGroup:insert( punteggiCannoneButton )

punteggiGiocoliereButton = widget.newButton {
    x = display.contentCenterX,
    y = 1180,
    width = 380, -- valori di default 630
    height = 150, -- valori di default 250
    defaultFile = oggettiDiScena,
    label = "Giocoliere",
    labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
    fontSize = 70, -- valori di default 100
    onEvent = goToPunteggiGiocoliere,
}
punteggiGroup:insert( punteggiGiocoliereButton )


  indietroButton = widget.newButton {
      x = -500,
      y = 150,
      width = 380, -- valori di default 630
      height = 150, -- valori di default 250
      defaultFile = oggettiDiScena,
      label = "Indietro",
      labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
      fontSize = 70, -- valori di default 100
      onEvent = tornaMenuPrincipale,
  }
  indietroButton.alpha = 0
  backGroup:insert( indietroButton )

  impostazioniButton = widget.newButton {
      x = 1300,
      y = 150,
      width = 150,
      height = 150,
      defaultFile = oggettiDiScena2,
      onEvent = gotoImpostazioni,
  }
  backGroup:insert( impostazioniButton )

  bigliettoAudio = display.newImageRect( impostazioniGroup, oggettiDiScena, 1, 1500, 150 )
  bigliettoAudio.x = display.contentCenterX
  bigliettoAudio.y = display.contentCenterY+300

  soundtrackAudioBar = display.newImageRect( impostazioniGroup, oggettiDiScena3, 1, 1200, 20 )
  soundtrackAudioBar.x = display.contentCenterX
  soundtrackAudioBar.y = display.contentCenterY+300
  soundtrackAudioBar.myName = "audioBar"

  pulsanteAudio = display.newImageRect( impostazioniGroup, oggettiDiScena, 2, 40, 40 )
  pulsanteAudio.x = display.contentCenterX
  pulsanteAudio.y = display.contentCenterY+300
  physics.addBody( pulsanteAudio, { radius=40, isSensor=true } )
  pulsanteAudio.myName = "pulsanteAudio"


  -- zona audio
  musicTrack = audio.loadStream( "audio/Circus.mp3" )
  bottoneMusic = audio.loadSound( "audio/Tiny Button Push-SoundBible.com-513260752.wav" )

  pulsanteAudio:addEventListener( "touch", dragAudio )
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
    -- parte la musica
    audio.rewind( musicTrack )
    audio.play( musicTrack, { channel=1, loops=-1 } )

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
    -- ferma la musica
    audio.stop( 1 )
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
  -- Dispose audio
  audio.dispose( musicTrack )
  audio.dispose( bottoneMusic )

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
