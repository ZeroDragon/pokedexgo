ivDatabase = require('./ivDatabase.json')

window.getIVs = (pkmn,stardust,cp,hp,upgraded=false)->
	pkmn = ivDatabase.pokemons.filter((e)-> ~~e.Number is ~~pkmn)[0]
	pivsStamina = pivsAttack = pivsDefense = [0..15]
	possibleLvlMult = ivDatabase.stardust2Lvl[stardust].map((e)-> {lvl:e,mult:ivDatabase.CpMultiplier[e]})

	ivs = []
	tot = 0
	for posA in pivsAttack
		for posD in pivsDefense
			for posS in pivsStamina
				for posM,k in possibleLvlMult
					if !upgraded
						continue if posM.lvl % 1 isnt 0
					else
						continue if k isnt 0
					posCP = Math.floor((pkmn.Stats.BaseAttack + posA) \
						* ((pkmn.Stats.BaseDefense + posD)**0.5) \
						* ((pkmn.Stats.BaseStamina + posS)**0.5) \
						* (posM.mult ** 2) / 10)
					posHP = Math.round((pkmn.Stats.BaseStamina + posS) * posM.mult)
					if posCP is cp and posHP is hp
						ivs.push {Atk:posA,Def:posD,Sta:posS,lvl:posM.lvl,grade:Math.round((posA+posD+posS)*100/45)/10}

	ivs.sort (a,b)-> b.grade-a.grade
	ivs.pop()
	ivs.shift()
	tot += iv.grade for iv in ivs
	worst = ivs[ivs.length-1]
	best = ivs[0]
	prom = Math.round((tot / ivs.length)*10)/10

	return {ivs:ivs,best:best,worst:worst,prom:prom}