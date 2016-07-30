$scope = {}
$methods = {}
calculateFromNumber = (number,cp)->
	pkmn = $scope.pokemons.filter((e)->e.Number is number)[0]
	if pkmn.multipliers?
		min = Math.round pkmn.multipliers[0]*cp
		max = Math.round pkmn.multipliers[1]*cp
	if number isnt "133" #stupid eevee
		if pkmn['Next evolution(s)'][0]?
			next = pkmn['Next evolution(s)'][0].Number
			$(".CPResult#{next}").html min+"<b> CP</b>  "+max+"<b> CP</b>"
			calculateFromNumber next, (min+max)/2
	else
		$(".CPResult134").html min+"<b> CP</b>  "+max+"<b> CP</b>"
		$(".CPResult135").html min+"<b> CP</b>  "+max+"<b> CP</b>"
		$(".CPResult136").html min+"<b> CP</b>  "+max+"<b> CP</b>"

calculate = (number)->
	calculateFromNumber number, ~~$(".value#{number}").val()

addZ = (i,k=3)-> ([0..k].map((e)->'0').join('')+i).slice(-k)

$ ->
	$scope.pokemons = []
	$scope.showPkmns = []
	orden = 0
	$scope.orden = "Number"
	$scope.sidePokemonsWidth = 0

	$scope.hideCover = ->
		$('#cover').animate({
			left : '-100%'
		},100,'linear',->
			$('#cover').remove()
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

	$scope.pokemonOrder = ->
		oA = ["Number","Name"]
		orden = 1-orden
		$scope.orden = oA[orden]

	$scope.toggleSidePokemons = ->
		goal = if $scope.sidePokemonsWidth is 0 then 100 else 0
		$({t:$scope.sidePokemonsWidth}).animate {
			t : goal
		},{
			duration : 100
			easing : 'linear'
			step : (now)-> $scope.sidePokemonsWidth = now
		}


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
		$scope.showPkmns.push $scope.pokemons.filter((e)-> e.Number is selected)[0]
		
	$.get '/pokemons',(pokemons)->
		$scope.pokemons = JSON.parse(JSON.stringify(pokemons))
		# $scope.showPkmns.push $scope.pokemons.filter((e)-> e.Number is "001")[0]

	$scope.deletePk = (event)->
		name = $(event.target).data('name')
		$scope.showPkmns = $scope.showPkmns.filter (e)-> e.Name isnt name

	new Vue({
		el: '#pokeapp'
		data: $scope
		methods: $methods
	})