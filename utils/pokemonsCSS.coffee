pokemons = require '../app/assets/scripts/pokemons.json'
fs = require 'fs'

cols = 10
offsetX = 128
offsetY = 128
rules = [
	"""
	.pokemon
	\t.image
	\t\tbackground-image url("/images/pokemons2.png")
	\t\twidth 127px
	\t\theight 127px
	"""
]

for pokemon,k in pokemons
	row = ~~(k / cols)
	col = k % cols
	rules.push """
	\t\t&.pkmn#{pokemon.Number}
	\t\t\tbackground-position #{(col*offsetX*-1)-1}px #{(row*offsetY*-1)-1}px
	"""

fs.writeFileSync '../app/assets/styles/pokemons.styl', rules.join('\n')
console.log 'done'