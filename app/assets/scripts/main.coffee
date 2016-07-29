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

$ ->
	$scope.selected = ""
	$scope.pokemons = []
	$scope.showPkmns = []

	$methods.getPkmn = (number,evoK)->
		addZ = (i)-> ('000'+i).slice(-3)
		pkmn = $scope.pokemons.filter((e)->e.Number is addZ(number))[0]
		if evoK is 0
			return pkmn
		else
			prevEvos = pkmn['Next evolution(s)'][evoK].Number
			prevPkmn = $scope.pokemons.filter((e)->e.Number is prevEvos)[0]
			prevNumb = prevPkmn["Previous evolution(s)"][prevPkmn["Previous evolution(s)"].length-1].Number
			return $scope.pokemons.filter((e)->e.Number is prevNumb)[0]

	$scope.addpkmn = ->
		unless $scope.showPkmns.filter((e)->e.Number is $scope.selected)[0]?
			$scope.showPkmns = []
			$scope.showPkmns.push $scope.pokemons.filter((e)-> e.Number is $scope.selected)[0]
			$scope.selected = ""
		
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