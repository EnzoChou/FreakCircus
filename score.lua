local score = {}
local json = require( "json" )

local network = require( "network" )
local callback

local function networkListener( event )
    local punteggi = {}
    if ( event.isError ) then
        print( "Network error: ", event.response )
    else
        local risultati = json.decode( event.response )
        for k,v in pairs( risultati ) do
            table.insert( punteggi, v.punteggio )
        end
    end
    callback( punteggi )
end


local function carica( url, riempimento )
    callback = riempimento
    -- Access to server
    network.request( url, "GET", networkListener )
end



local function salva( url,punteggio )
    -- Access to server
    local response = network.request( url, "POST", networkListener )
    --local file = io.open( filePath, "r" )
    local punteggi = {}

    --if file then
    --    local contents = file:read( "*a" )
    --    punteggi = json.decode( contents )
    --    if
    --    table.insert( punteggi, punteggio)

        -- Ordina punteggi
    --    local function compare( a, b )
    --         return a > b
    --    end
    --    table.sort( punteggi, compare )

        -- salva max 10 risultati
    --    table.remove(punteggi,11)

    --    io.close( file )
    --else
    --    table.insert( punteggi, punteggio)
    --end


    --sovrascrivi il file (o crealo se non esiste)
    --file = io.open( filePath, "w" )
    --file:write( json.encode( punteggi ) )
    --io.close( file )
end


local function caricaOnline( filePath, arrayJson )
    local table = json.decode( arrayJson )
    for k,v in pairs( table ) do
        print( v.punteggio )
        salva( filePath, v.punteggio )
    end
end


score.carica = carica
score.salva = salva
score.caricaOnline = caricaOnline

return score
