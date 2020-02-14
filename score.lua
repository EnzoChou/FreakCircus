local score = {}
local json = require( "json" )

local url = "http://13.73.156.182:8080/scores/"

local network = require( "network" )
local callback

local function getNetworkListener( event )
    local punteggi = {}
    if ( event.isError ) then
        print( "Network error: ", event.response )
    else
        local risultati = json.decode( event.response )
        for k,v in pairs( risultati ) do
            table.insert( punteggi, v.punteggio )
            table.insert ( punteggi, v.nome )
        end
    end
    callback( punteggi )
end

local function postNetworkListener( event )

    if ( event.isError ) then
        print( "Network error: ", event.response )
    else
        print ( "RESPONSE: " .. event.response )
    end
end


local function carica( game, riempimento )
    local link = url .. game
    callback = riempimento
    -- Access to server
    network.request( link, "GET", getNetworkListener )
end



local function salva( game, punteggio, nome )
    local link = url .. game
    -- Access to server
    local response = network.request( link.."?".."score="..punteggio.."&user="..nome, "POST", postNetworkListener )

end


score.carica = carica
score.salva = salva
score.caricaOnline = caricaOnline

return score
