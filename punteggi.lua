local composer = require( "composer" )

local scene = composer.newScene()
local backScene

local score = require("score")

local punteggi
local filePath

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function resume()
    composer.gotoScene( backScene , { time=10 } )
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    backScene = event.params.scene
    filePath = system.pathForFile( "punteggi".. backScene ..".json", system.DocumentsDirectory )

    punteggi = score.carica(filePath)

	local sceneGroup = self.view
	local background = display.newImageRect( sceneGroup, "images/sfondo2.png", 3000, 1280)
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    
    for i = 1, 10 do
        if ( punteggi[i] ) then
            local yPos = 0 + ( i * 120 )

            local rank = display.newText( sceneGroup, i .. ")", display.contentCenterX-50, yPos, native.systemFont, 80 )
            rank.anchorX = 1
 
            local punteggio = display.newText( sceneGroup, punteggi[i], display.contentCenterX-30, yPos, native.systemFont, 80 )
            punteggio.anchorX = 0
        end
    end
	
	local resumeButton = display.newText( sceneGroup, "Riprendi", display.contentCenterX-900, 60, native.systemFont, 100 )
	resumeButton:addEventListener( "tap", resume )
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
        composer.removeScene( "punteggi" )
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