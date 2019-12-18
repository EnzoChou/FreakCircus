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


local sheetOptions = {
    frames = {
        {   -- pulsante
            x = 0,
            y = 0,
            width = 252,
            height = 100
        }
    }
}

local oggettiDiScena = graphics.newImageSheet( "images/oggettini.png", sheetOptions )


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

-- bottoni giochiGroup
local cannoneButton
local giocoliereButton

-- bottone indietro
local indietroButton
local toggleIndietroOnOff = 0

-- audio
local musicTrack
local bottone


local function gotoCannone( event )
    local phase = event.phase
    if phase == "ended" then
        composer.gotoScene( "cannone" , { time=800, effect = "crossFade" } )
    end
end

local function gotoGiocoliere( event )
    local phase = event.phase
    if phase == "ended" then
        composer.gotoScene( "giocoliere" , { time=800, effect = "crossFade" } )
    end
end

local function toggleIndietroButton()
    if ( toggleIndietroOnOff == 0 ) then
        transition.to( indietroButton, { time = 1000, effect = "fadeIn", alpha = 1 } )
        toggleIndietroOnOff = 1
    else
        transition.to( indietroButton, { time = 1000, effect = "fadeOut", alpha = 0 } )
        toggleIndietroOnOff = 0
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
        transition.to( principaleGroup, { time = 1000, transition = easing.inOutElastic,
                                          x = -3000,
                                          onStart = giochiInScena,
                                          onComplete = toggleIndietroButton()
                                        }
                      )
    end
end

local function impostazioniInScena()
    transition.to( impostazioniGroup, { time = 1000, transition = easing.inOutElastic,
                                        x = 0 } )
    gruppoInScena = impostazioniGroup
end

local function gotoImpostazioni( event )
    local phase = event.phase
    if phase == "ended" then
        transition.to( principaleGroup, { time = 1000, transition = easing.inOutElastic,
                                          x = -3000,
                                          onStart = impostazioniInScena,
                                          onComplete = toggleIndietroButton()
                                          }
                      )
    end
end

local function menuPrincipale()
    transition.to( principaleGroup, { time = 1000, transition = easing.inOutElastic,
                                      x = 0 } )
end

local function tornaMenuPrincipale( event )
    local phase = event.phase
    if phase == "ended" then
        if ( gruppoInScena ~= principaleGroup ) then
            transition.to( gruppoInScena, { time = 1000, transition = easing.inOutElastic,
                                            x = 3000,
                                            onStart = menuPrincipale } )
            gruppoInScena = principaleGroup
            toggleIndietroButton()
        end
    end
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

	background = display.newImageRect( backGroup, "images/sfondo1.png", 3000, 1280 )
  background.x = display.contentCenterX
	background.y = display.contentCenterY

  title = display.newText( backGroup, "Freak Circus", display.contentCenterX, 300, native.systemFont, 200 );

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

  impostazioniButton = widget.newButton {
      x = display.contentCenterX,
      y = 1180,
      width = 380, -- valori di default 630
      height = 150, -- valori di default 250
      defaultFile = oggettiDiScena,
      label = "Impostazioni",
      labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
      fontSize = 60, -- valori di default 100
      onEvent = gotoImpostazioni,
  }
  principaleGroup:insert( impostazioniButton )

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

  -- zona audio
  musicTrack = audio.loadStream( "audio/Circus.mp3" )


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
