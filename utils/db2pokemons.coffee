pokemons = require '../app/assets/scripts/pokesource.json'
database = require '../app/assets/scripts/database.json'
multipliers = require '../app/assets/scripts/multipliers.json'
maxCP = require '../app/assets/scripts/maxCP.json'
fs = require 'fs'
addZ = (i,z=3)-> ([0..z].map((e)->0).join('')+i).slice(-z)

weakRes = (types)->
	resistance = {}
	weaknesses = {}
	all = {}
	whenDefend = types.map (e)-> defending[e]
	for group in whenDefend
		for type,value of group
			if value < 1
				resistance[type] = true
			if value > 1
				weaknesses[type] = true
			all[type] = true

	cleanResi = []
	cleanWeak = []
	for type,value of resistance
		if !weaknesses[type]?
			cleanResi.push type
	for type,value of weaknesses
		if !resistance[type]?
			cleanWeak.push type

	for item,value of all
		if cleanResi.indexOf(item) isnt -1
			all[item] = 0.8
		else if cleanWeak.indexOf(item) isnt -1
			all[item] = 1.25
		else
			all[item] = 1
	return all

attacking = {}
defending = {}
trimName = (name)->
	name = name.replace(/POKEMON_TYPE_/,'')
	name = name[0]+name[1..].toLowerCase()
	return name
for type in database.PokemonTypes
	EfArr = type.TypeEffective.AttackScalar.map (e,k)->
		return {type : database.TypeScalarArray[k], value : e}
	Effective = {}
	for item in EfArr
		Effective[trimName(item.type)] = item.value
	attacking[trimName(type.TemplateId)] = Effective
for name,Effective of attacking
	for type, value of Effective
		defending[type] ?= {}
		defending[type][name] = value

pokemons = pokemons.map (pokemon)->
	pokemon.types = [].concat(pokemon['Type I'],(pokemon['Type II'] or []))
	delete pokemon['Type I']
	delete pokemon['Type II']
	delete pokemon.Weaknesses
	delete pokemon.Weight
	delete pokemon.Height
	delete pokemon['Fast Attack(s)']

	all = weakRes(pokemon.types)
	pokemon.weakRes = JSON.parse(JSON.stringify(all))
	pkmn = database.Pokemon.filter((e)-> e.TemplateId.indexOf("V#{addZ(pokemon.Number,4)}") isnt -1)[0]
	moves_q = pkmn.Pokemon.QuickMoves
	moves_p = pokemon.types.map((pkType)->
		database.Moves.filter((e)->
			e.Move.Type is "POKEMON_TYPE_#{pkType.toUpperCase()}" and
			e.TemplateId.indexOf("_FAST") is -1
		).map((move)->
			return ~~move.TemplateId.match(/[0-9]{4}/)[0]
		)
	)
	mp = []
	for moves in moves_p
		mp = mp.concat moves
	moves_p = mp

	moves = [].concat(moves_q,moves_p).map((e)->
		move = database.Moves.filter((move)->
			move.TemplateId.indexOf("V#{addZ(e,4)}_MOVE") isnt -1
		)[0]
		move.Move.name = move.TemplateId
		type = move.Move.Type.replace(/POKEMON_TYPE_/,'')
		retval = {group:'fast'}
		if move.Move.name.indexOf('_FAST') is -1
			retval.group = 'possible'
		name = move.Move.name.replace(/^V[0-9]{4}_MOVE_/,'').replace(/_FAST/,'').replace(/_/g,' ')
		retval.type = type[0]+type[1..].toLowerCase()
		retval.name = name[0]+name[1..].toLowerCase()
		return retval
	)

	grupos = {}
	for move in moves
		grupos[move.group] ?= {}
		grupos[move.group][move.type] = true

	groups = []
	for grupo,moves2 of grupos
		for type,meh of moves2
			groups.push type

	groups = groups.filter (e,i,s)-> s.indexOf(e) is i

	pokemon.moves = moves
	pokemon.attackingChart = groups.map((e)->
		return {type:e,values:attacking[e]}
	)

	pokemon.multipliers = multipliers[pokemon.Name] if multipliers[pokemon.Name]?
	pokemon.maxCP = maxCP[pokemon.Name] if maxCP[pokemon.Name]?
	pokemon['Next evolution(s)'] ?= []
	return pokemon

fs.writeFileSync '../app/assets/scripts/pokemons.json', JSON.stringify(pokemons)
console.log 'done'