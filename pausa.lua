local composer = require( "composer" )

local scene = composer.newScene()
local backScene

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function resume()
    composer.gotoScene( backScene , { time=10 } )
end
 
local function goToMenu()
    composer.gotoScene( "menu" , { time=10 } )
    composer.removeScene(backScene)
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	backScene = event.params.scene

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	local background = display.newImageRect( sceneGroup, "images/sfondo2.png", 3000, 1280)
    background.x = display.contentCenterX
	background.y = display.contentCenterY
	
	local resumeButton = display.newText( sceneGroup, "Riprendi", display.contentCenterX, 700, native.systemFont, 100 )
 
    local menuButton = display.newText( sceneGroup, "Menu", display.contentCenterX, 810, native.systemFont, 100 )
	
	resumeButton:addEventListener( "tap", resume )
    menuButton:addEventListener( "tap", goToMenu )
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
