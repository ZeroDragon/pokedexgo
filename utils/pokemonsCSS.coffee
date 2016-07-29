pokemons = require '../app/assets/scripts/pokemons.json'
fs = require 'fs'

cols = 16
offset = 81
rules = [
	"""
	.pokemon
	\t.image
	\t\tbackground-image url("/images/pokemons.png")
	\t\twidth 80px
	\t\theight 80px
	"""
]

for pokemon,k in pokemons
	row = ~~(k / cols)
	col = k % cols
	rules.push """
	\t\t&.pkmn#{pokemon.Number}
	\t\t\tbackground-position #{(col*offset*-1)-1}px #{(row*offset*-1)-1}px
	"""

fs.writeFileSync '../app/assets/styles/pokemons.styl', rules.join('\n')
console.log 'done'