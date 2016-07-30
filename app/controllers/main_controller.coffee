request = require 'request'

exports.home = (req,res)->
	res.render "#{CT_Static}/main/index.jade",{
		pretty:true
	}

getDistanceFromLatLonInKm = (lat1,lon1,lat2,lon2)->
  R = 6371 # Radius of the earth in km
  dLat = deg2rad(lat2-lat1)  # deg2rad below
  dLon = deg2rad(lon2-lon1)
  a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * Math.sin(dLon/2) * Math.sin(dLon/2)
  c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
  d = R * c # Distance in km
  return d

deg2rad = (deg)-> return deg * (Math.PI/180)

# exports.pkmnByLocation = (req,res)->
# 	request.get "https://pokevision.com/map/data/#{req.params.lat}/#{req.params.lon}",{json:true}, (err,data,body)->
# 		body = body.pokemon.map((e)->
# 			e.distance = getDistanceFromLatLonInKm req.params.lat,req.params.lon,e.latitude,e.longitude
# 			return e).filter (e)-> e.distance < 0.3
# 		console.log body
# 		res.sendStatus 200