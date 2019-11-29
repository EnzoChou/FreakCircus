local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

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


local function gotoCannone()
    composer.gotoScene( "cannone" , { time=800, effect = "crossFade" } )
end

local function gotoGiocoliere()
    composer.gotoScene( "giocoliere" , { time=800, effect = "crossFade" } )
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
                                  x=0 } )
    gruppoInScena=giochiGroup
end

local function gotoGiochi()
    transition.to( principaleGroup, { time = 1000, transition = easing.inOutElastic,
                                      x = -3000,
                                      onStart = giochiInScena,
                                      onComplete = toggleIndietroButton() } )
end

local function gotoImpostazioni()

end

local function menuPrincipale()
    transition.to( principaleGroup, { time = 1000, transition = easing.inOutElastic,
                                      x = 0 } )
end

local function tornaMenuPrincipale()
    if ( gruppoInScena ~= principaleGroup ) then
        transition.to( gruppoInScena, { time = 1000, transition = easing.inOutElastic,
                                    x = 3000,
                                    onStart = menuPrincipale } )
        gruppoInScena = principaleGroup
        toggleIndietroButton()
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

  -- bottoni principaleGroup
  playButton = display.newText( principaleGroup, "Gioca", display.contentCenterX, 1000, native.systemFont, 100 )
      playButton:setFillColor( 1, 1, 1 )

  impostazioniButton = display.newText( principaleGroup, "Impostazioni", display.contentCenterX, 1150, native.systemFont, 100 )
      playButton:setFillColor( 1, 1, 1 )

  -- bottoni giochiGroup
	cannoneButton = display.newText( giochiGroup, "Cannone", display.contentCenterX, 1000, native.systemFont, 100 )
      cannoneButton:setFillColor( 1, 1, 1 )

  giocoliereButton = display.newText( giochiGroup, "Giocoliere", display.contentCenterX, 1150, native.systemFont, 100 )
      giocoliereButton:setFillColor( 1, 1, 1 )

  -- bottone indietro al menu principale
  indietroButton = display.newText( backGroup, "Indietro", -500, 150, native.systemFont, 100 )
      indietroButton:setFillColor( 1, 1, 1 )
      indietroButton.alpha = 0

  playButton:addEventListener( "tap", gotoGiochi )
  impostazioniButton:addEventListener( "tap", gotoImpostazioni )
  cannoneButton:addEventListener( "tap", gotoCannone )
  giocoliereButton:addEventListener( "tap", gotoGiocoliere )
  indietroButton:addEventListener( "tap", tornaMenuPrincipale )
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

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
