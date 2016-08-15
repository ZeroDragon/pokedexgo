$scope = {}
$methods = {}

fromMem = localStorage.pokedexGo
if !fromMem?
	fromMem = {
		savingPokemon : false
		lastPokemon : null
		calculatedCP : null
	}
else
	fromMem = JSON.parse fromMem
saveMem = ->
	localStorage.pokedexGo = JSON.stringify fromMem

addCommas = (x)->
	parts = x.toString().split(".")
	parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",")
	return parts.join(".")

calculateFromNumber = (number,cp)->
	pkmn = $scope.pokemons.filter((e)->e.Number is number)[0]
	if pkmn.multipliers?
		min = Math.round pkmn.multipliers[0]*cp
		max = Math.round pkmn.multipliers[1]*cp
	if number isnt "133" #stupid eevee
		if pkmn['Next evolution(s)'][0]?
			next = pkmn['Next evolution(s)'][0].Number
			$(".CPResult#{next}").html addCommas(min)+"<b> CP </b> ~ "+addCommas(max)+"<b> CP</b>"
			calculateFromNumber next, (min+max)/2
	else
		$(".CPResult134").html addCommas(min)+"<b> CP</b> ~ "+addCommas(max)+"<b> CP</b>"
		$(".CPResult135").html addCommas(min)+"<b> CP</b> ~ "+addCommas(max)+"<b> CP</b>"
		$(".CPResult136").html addCommas(min)+"<b> CP</b> ~ "+addCommas(max)+"<b> CP</b>"

calculate = (number)->
	if fromMem.savingPokemon
		fromMem.lastPokemon = number
		fromMem.calculatedCP = ~~$(".value#{number}").val()
		saveMem()
	calculateFromNumber number, ~~$(".value#{number}").val()

addZ = (i,k=3)-> ([0..k].map((e)->'0').join('')+i).slice(-k)

$ ->
	$scope.pokemons = []
	$scope.showPkmns = []
	orden = 0
	timeout = false
	$scope.orden = "Number"
	$scope.sidePokemonsWidth = 0
	$scope.isSaving = false
	$scope.requiredStardust = null
	$scope.hitPoints = null
	$scope.combatPower = null
	$scope.upgraded = false
	$scope.calculatedIV = null

	$methods.addCommas = addCommas

	$scope.hideCover = ->
		$('#cover').animate({
			left : '-100%'
		},100,'linear',->
			$('#cover').remove()
			clearTimeout timeout
		)

	doTimeout = ->
		d = new Date()
		$scope.time = "#{addZ(d.getHours(),2)}:#{addZ(d.getMinutes(),2)}"
		timeout = setTimeout ->
			clearTimeout timeout
			d = new Date()
			$scope.time = "#{addZ(d.getHours(),2)}:#{addZ(d.getMinutes(),2)}"
			doTimeout()
		,1000
	doTimeout()

	$scope.toggleSettings = ->
		$('#settings').toggle()
	$scope.toggleSaveData = ->
		$scope.isSaving = !$scope.isSaving
		fromMem.savingPokemon = $scope.isSaving
		if !fromMem.savingPokemon
			fromMem = {
				savingPokemon : false
				lastPokemon : null
				calculatedCP : null
			}
		saveMem()

	$scope.pokemonOrder = ->
		oA = ["Number","Name"]
		orden = 1-orden
		$scope.orden = oA[orden]

	$scope.toggleSidePokemons = ->
		$('.arrow').remove()
		goal = if $scope.sidePokemonsWidth is 0 then 140 else 0
		$({t:$scope.sidePokemonsWidth}).animate {
			t : goal
		},{
			duration : 100
			easing : 'linear'
			step : (now)-> $scope.sidePokemonsWidth = now
		}

	$scope.calculateIV = ->
		number = ~~$scope.showPkmns[0].Number
		if ~~$scope.combatPower isnt 0 and ~~$scope.hitPoints isnt 0 and ~~$scope.requiredStardust isnt 0
			calc = getIVs(number,~~$scope.requiredStardust,~~$scope.combatPower,~~$scope.hitPoints,$scope.upgraded)
			calc.levels = calc.ivs.map((e)->e.lvl).filter (e,k,s)-> s.indexOf(e) is k
			$scope.calculatedIV = calc

	$scope.outputLvl = (arr)->
		arr = JSON.parse(JSON.stringify(arr))
		if arr.length > 0
			r = ""
			last = "<b>#{arr.pop()}</b>"
			if arr.length > 0
				r = arr.map((e)->"<b>#{e}</b>").join(', ') + " and " + last
			else
				return last
		else
			return null

	$methods.getPkmn = (number,evoK)->
		pkmn = $scope.pokemons.filter((e)->e.Number is addZ(number))[0]
		if evoK is 0
			return pkmn
		else
			prevEvos = pkmn['Next evolution(s)'][evoK].Number
			prevPkmn = $scope.pokemons.filter((e)->e.Number is prevEvos)[0]
			prevNumb = prevPkmn["Previous evolution(s)"][prevPkmn["Previous evolution(s)"].length-1].Number
			return $scope.pokemons.filter((e)->e.Number is prevNumb)[0]

	$methods.addpkmn = (selected)->
		$scope.toggleSidePokemons()
		$scope.showPkmns = []
		$scope.calculatedIV = null
		$scope.showPkmns.push $scope.pokemons.filter((e)-> e.Number is selected)[0]
		fromMem.lastPokemon = selected
		saveMem()
		
	$.get '/pokemons',(pokemons)->
		$scope.pokemons = JSON.parse(JSON.stringify(pokemons))
		
		if fromMem.savingPokemon is true
			$scope.showPkmns.push $scope.pokemons.filter((e)-> e.Number is fromMem.lastPokemon)[0]
			if fromMem.calculatedCP?
				setTimeout ->
					$('#initialCP').val(fromMem.calculatedCP)
					calculate(fromMem.lastPokemon)
				,100
			$scope.isSaving = fromMem.savingPokemon
			$scope.hideCover()

	$scope.deletePk = (event)->
		name = $(event.target).data('name')
		$scope.showPkmns = $scope.showPkmns.filter (e)-> e.Name isnt name

	new Vue({
		el: '#pokeapp'
		data: $scope
		methods: $methods
	})