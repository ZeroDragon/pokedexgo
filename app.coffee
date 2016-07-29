config = require './config.json'
if process.env.PORT?
	config.port = process.env.PORT
require('chaitea-framework')

CT_Routes -> CT_StartServer()