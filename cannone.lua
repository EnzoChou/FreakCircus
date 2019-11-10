local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local physics = require( "physics" )
physics.start()

local sheetOptions = {
    frames = {
        {
            x = 0,
            y = 0,
            width = 321,
            height = 234
        },
        {
            x = 321,
            y = 0,
            width = 267,
            height = 321
        },
        {
            x = 588,
            y = 0,
            width = 244,
            height = 235
        }
    }
}

local sheetOptions2 = {
    frames = {
        {
            x = 252,
            y = 0,
            width = 75,
            height = 75
        }
    }
}

local oggettiDiScena = graphics.newImageSheet( "images/oggettoni.png", sheetOptions )
local oggettiDiScena2 = graphics.newImageSheet( "images/oggettini.png", sheetOptions2 )

local cannone
local pallaDiCannone
local bersaglio
local scimmia
local angoloCannone = math.pi/6 --30 gradi (angolo iniziale)

local impulso= 600;


local function sparaPallaDiCannone()
    pallaDiCannone.gravityScale=1
    angoloCannone = math.pi/6 - cannone.rotation*math.pi/180
    pallaDiCannone:applyLinearImpulse( impulso*math.cos(angoloCannone), -impulso*math.sin(angoloCannone), pallaDiCannone.x, pallaDiCannone.y )
end

function ruotaCannone()
    transition.to(cannone,{rotation=-60,time=5000})
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

    bersaglio = display.newImageRect( mainGroup, oggettiDiScena, 2, 400, 300 )
    bersaglio.x=display.contentCenterX+800
    bersaglio.y=display.contentHeight-270
    physics.addBody(bersaglio,"static")

    pallaDiCannone = display.newImageRect( mainGroup, oggettiDiScena2, 1, 100, 100 )
    pallaDiCannone.x=display.contentCenterX-550
    pallaDiCannone.y=display.contentHeight-330
    physics.addBody(pallaDiCannone,"dynamic",{ radius=30, bounce=0.3,density=10})
    pallaDiCannone.gravityScale=0

    cannone = display.newImageRect( mainGroup, oggettiDiScena, 1, 400,300 )
    cannone.x=display.contentCenterX-750
    cannone.y=display.contentHeight-130
    cannone.anchorX =  130/321 --175,642/321
    cannone.anchorY = 176,203/234
    ruotaCannone()
    cannone:addEventListener("tap",sparaPallaDiCannone)

    scimmia = display.newImageRect( mainGroup, oggettiDiScena, 3, 400, 300 )
    scimmia.x=display.contentCenterX-900
    scimmia.y=display.contentHeight-270
    
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