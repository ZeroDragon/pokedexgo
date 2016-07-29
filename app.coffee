config = require './config.json'
config.port = process.env.PORT
require('chaitea-framework')

CT_Routes -> CT_StartServer()