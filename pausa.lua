local composer = require( "composer" )
local score = require("score")
local scene = composer.newScene()
local backScene
local punteggio
local nome
local inserimentoNome

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function resume()
    if ( nome~=nil ) then
        score.salva( backScene, punteggio, nome )
    end
    composer.gotoScene( backScene , { time=10 } )
end

local function goToMenu()
    if ( nome~=nil ) then
        score.salva( backScene, punteggio, nome )
    end
    composer.gotoScene( "menu" , { time=10 } )
    composer.removeScene(backScene) --rimuove la scena se esiste
end

local function formatTime(seconds)
    local minutes = math.floor( seconds / 60 )
    local seconds = seconds % 60
    return string.format( "%02d:%02d", minutes, seconds )
end

local function formattaPunteggio(p)
	if(backScene=="giocoliere") then
		return formatTime(p)
	end
	return p
end

local function salvaNome( event )
    if ( event.phase == "began" ) then
        -- User begins editing "defaultField"

    elseif ( event.phase == "ended" or event.phase == "submitted" ) then
        -- Output resulting text from "defaultField"
        nome = event.target.text

    elseif ( event.phase == "editing" ) then
        --print( event.newCharacters )
        --print( event.oldText )
        --print( event.startPosition )
        nome = event.text
        print( nome )
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	backScene = event.params.scene
	punteggio = event.params.punteggio
  local record = event.params.record.punteggio

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	local background = display.newImageRect( sceneGroup, "images/sfondo2.png", 3000, 1280)
    background.x = display.contentCenterX
	background.y = display.contentCenterY

	local resumeText = "Riprendi"
	local menuText = "Esci"

	if(punteggio) then
		--se la partita è finita
		resumeText = "Rigioca"

		local isRecord = punteggio > record -- se il nuovo punteggio va inserito nella classifica top 10
		local text = formattaPunteggio(punteggio)

		--se il punteggio è il nuovo record
		if( isRecord ) then
			text = text .. " (Record)"
			menuText = "Salva ed esci"
			inserimentoNome = native.newTextField( display.contentCenterX-200, 500, 600, 100 )
	    inserimentoNome.placeholder = "Nome"
		  sceneGroup:insert(inserimentoNome)
      inserimentoNome:addEventListener( "userInput", salvaNome )
		end

		local punteggioText = display.newText( sceneGroup, text, display.contentCenterX, 300, native.systemFont, 200 )
	end

	local resumeButton = display.newText( sceneGroup, resumeText, display.contentCenterX, 810, native.systemFont, 100 )
    local menuButton = display.newText( sceneGroup, menuText, display.contentCenterX, 700, native.systemFont, 100 )

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
		composer.removeScene("pausa")
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
