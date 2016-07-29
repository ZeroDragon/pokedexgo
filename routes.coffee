main = CT_LoadController 'main'

app.get '/appcache.manifest', (req,res)->
	res.setHeader('content-type','text/cache-manifest')
	res.sendFile "#{process.cwd()}/app/assets/appcache.manifest"

app.get '/pokemons', (req,res)->
	res.sendFile "#{process.cwd()}/app/assets/scripts/pokemons.json"
app.get '/multipliers', (req,res)->
	res.sendFile "#{process.cwd()}/app/assets/scripts/multipliers.json"

app.get '/', main.home