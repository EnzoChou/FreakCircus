local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function gotoCannone()
    composer.gotoScene( "cannone" , { time=800, effect="crossFade" } )
end

local function gotoGiocoliere()
    composer.gotoScene( "giocoliere" , { time=800, effect="crossFade" } )
end

local function aggiungiGiochiListener()
    cannoneButton:addEventListener( "tap", gotoCannone )
    giocoliereButton:addEventListener( "tap", gotoGiocoliere )
end

local function rimuoviGiochiListener()
    cannoneButton:removeEventListener( "tap", gotoCannone )
    giocoliereButton:RemoveEventListener( "tap", gotoGiocoliere )
end

local function aggiungiprincipaleListener()
    playButton:addEventListener( "tap", gotoGiochi )
end

local function rimuoviPrincipaleListener()
    playButton:removeEventListener( "tap", gotoGiochi )
end

local function gotoGiochi()
    transition.to( principaleGroup, { time=500, effect="crossFade",
                                      onStart=rimuoviPrincipaleListener,
                                      onComplete=aggiungiGiochiListener} )
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

  -- setup display groups

  local backGroup = display.newGroup()
  sceneGroup:insert( backGroup )

  local impostazioniGroup = display.newGroup()
  sceneGroup:insert( impostazioniGroup )

  local punteggiGroup = display.newGroup()
  sceneGroup:insert( punteggiGroup )

  local giochiGroup = display.newGroup()
  sceneGroup:insert( giochiGroup )

  local principaleGroup = display.newGroup()
  sceneGroup:insert( principaleGroup )

	local background = display.newImageRect( backGroup, "images/sfondo1.png", 3000, 1280 )
  background.x = display.contentCenterX
	background.y = display.contentCenterY

  local title = display.newText( backGroup, "Freak Circus", display.contentCenterX, 300, native.systemFont, 200 );

  -- bottoni principaleGroup
  local playButton = display.newText( principaleGroup, "Gioca", display.contentCenterX, 1000, native.systemFont, 100 )
      playButton:setFillColor( 1, 1, 1 )

  -- bottoni giochiGroup
	local cannoneButton = display.newText( giochiGroup, "Cannone", display.contentCenterX, 1050, native.systemFont, 100 )
      cannoneButton:setFillColor( 1, 1, 1 )

  local giocoliereButton = display.newText( giochiGroup, "Giocoliere", display.contentCenterX, 1150, native.systemFont, 100 )
      giocoliereButton:setFillColor( 1, 1, 1 )

  playButton:addEventListener( "tap", gotoGiochi )
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
