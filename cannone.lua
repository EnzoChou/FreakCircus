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
        {   -- 1) cannone
            x = 0,
            y = 0,
            width = 321,
            height = 234
        },
        {   -- 2) bersaglio
            x = 321,
            y = 0,
            width = 267,
            height = 321
        },
        {   -- 3) scimmia
            x = 588,
            y = 0,
            width = 244,
            height = 235
        },
        {   -- 4) bersaglio1 meta' sinistra
            x = 832,
            y = 0,
            width = 137,
            height = 321
        },
        {   -- 5) bersaglio2 meta' destra
            x = 993,
            y = 0,
            width = 130,
            height = 321
        }
    }
}

local sheetOptions2 = {
    frames = {
        {   -- 1) pallaDiCannone
            x = 252,
            y = 0,
            width = 75,
            height = 75
        },
        {   -- 2) bucoBersaglio
            x = 327,
            y = 0,
            width = 48,
            height = 63
        }
    }
}

local sheetOptions3 = {
    frames = {
        {   -- 1) pavimento
            x = 0,
            y = 0,
            -- width = ,
            -- height =
        }
    }
}

local oggettiDiScena = graphics.newImageSheet( "images/oggettoni.png", sheetOptions )
local oggettiDiScena2 = graphics.newImageSheet( "images/oggettini.png", sheetOptions2 )
local oggettiDiScena3 = graphics.newImageSheet( "images/pavimento.png", sheetOptions3 )

local cannone
local pallaDiCannone
local bersaglio
local bersaglio1
local bersaglio2
local pavimento
local scimmia
local angoloCannone = math.pi/6 --30 gradi (angolo iniziale)

local impulso= 600;


local function sparaPallaDiCannone()
    cannone:removeEventListener("tap",sparaPallaDiCannone)
    display.remove( pivotJoint )
    cannone.isBodyActive = false
    angoloCannone = math.pi/6 - cannone.rotation*math.pi/180
    pallaDiCannone:applyLinearImpulse( impulso*math.cos(angoloCannone), -impulso*math.sin(angoloCannone), pallaDiCannone.x, pallaDiCannone.y )
end

local function ruotaCannone()
    transition.to(cannone,{rotation=-60,time=5000})
    transition.to(pallaDiCannone,{rotation=-60,time=5000})
end

local function colpito( event )

    if ( event.phase == "began" ) then

        local obj1 = event.object1
        local obj2 = event.object2

        local midX = ( event.object1.x + event.object2.x ) * 0.5
        local midY = ( event.object1.y + event.object2.y ) * 0.5

        if ( ( obj1.myName == "bersaglio2" and obj2.myName == "pallaDiCannone" ) or
            ( obj1.myName == "pallaDiCannone" and obj2.myName == "bersaglio2" ) )
        then
            bucoBersaglio = display.newImageRect( mainGroup, oggettiDiScena2, 2, 48, 63 )
            bucoBersaglio.x = midX
            bucoBersaglio.y = midy
        end
    end
end

Runtime:addEventListener( "collision", colpito )
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
    physics.addBody( pavimento, "static" )

    bersaglio1 = display.newImageRect( mainGroup, oggettiDiScena, 4, 200, 300 )
    bersaglio1.x = display.contentCenterX+600
    bersaglio1.y = display.contentHeight-270

    bersaglio2 = display.newImageRect( mainGroup, oggettiDiScena, 5, 200, 300 )
    bersaglio2.x = display.contentCenterX+800
    bersaglio2.y = display.contentHeight-270
    physics.addBody( bersaglio2, "static" )

    --bersaglio = display.newImageRect( mainGroup, oggettiDiScena, 2, 400, 300 )
    --bersaglio.x = display.contentCenterX+800
    --bersaglio.y = display.contentHeight-270
    --physics.addBody( bersaglio,"static" )

    pallaDiCannone = display.newImageRect( mainGroup, oggettiDiScena2, 1, 100, 100 )
    pallaDiCannone.x = display.contentCenterX-550
    pallaDiCannone.y = display.contentHeight-360
    physics.addBody( pallaDiCannone,"dynamic",{ radius=30, bounce=0.3,density=10 } )

    cannone = display.newImageRect( mainGroup, oggettiDiScena, 1, 400,300 )
    cannone.x=display.contentCenterX-750
    cannone.y=display.contentHeight-130
    cannone.anchorX =  130/321 --175,642/321
    cannone.anchorY = 176,203/234
    physics.addBody(cannone,"static")
    cannone:addEventListener( "tap",sparaPallaDiCannone )

    local pivotJoint = physics.newJoint( "pivot", cannone, pallaDiCannone, pallaDiCannone.x, pallaDiCannone.y )

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
        ruotaCannone()
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
