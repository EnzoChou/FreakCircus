local score = {}
local json = require( "json" )

local function carica(filePath)
    local file = io.open( filePath, "r" )
    local punteggi
 
    if file then
        local contents = file:read( "*a" )
        io.close( file )
        punteggi = json.decode( contents )
    end
 
    if ( punteggi == nil ) then
        punteggi = {} --{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
    end

    return punteggi
end



local function salva(filePath,punteggio)
    local file = io.open( filePath, "r" )

    if file then
        local contents = file:read( "*a" )
        punteggi = json.decode( contents )

        if(punteggi==nil) then
            punteggi = {}
        end

        table.insert( punteggi, punteggio)
       
        -- Ordina punteggi
        local function compare( a, b )
             return a > b
        end
        table.sort( punteggi, compare )

        -- salva max 10 risultati
        table.remove(punteggi,11)

        io.close( file )

        --sovrascrivi il file
        file = io.open( filePath, "w" )
        file:write( json.encode( punteggi ) )
        io.close( file )
    end
end

score.carica = carica
score.salva = salva

return score

