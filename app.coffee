config = require './config.json'
config.port = process.env.PORT
console.log config.port
require('chaitea-framework')
console.log config.port

CT_Routes -> CT_StartServer()