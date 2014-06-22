express = require 'express'
stylus = require 'stylus'
assets = require 'connect-assets'
session = require('express-session')
cookieParser = require('cookie-parser')
bodyParser = require("body-parser")

#### Basic application initialization
# Create app instance.
app = express()

# Define Port & Environment
app.port = process.env.PORT or process.env.VMC_APP_PORT or 3333
env = process.env.NODE_ENV or "development"

# Config module exports has `setEnvironment` function that sets app settings depending on environment.
config = require "./config"
config.setEnvironment env

#### View initialization 
# Add Connect Assets.
app.use assets()
# Set the public folder as static assets.
app.use express.static(process.cwd() + '/public')

# Express Session
console.log "setting session/cookie"
app.use cookieParser()

# Set View Engine.
app.set 'view engine', 'jade'

# [Body parser middleware](http://www.senchalabs.org/connect/middleware-bodyParser.html) parses JSON or XML bodies into `req.body` object
app.use bodyParser()


#### Finalization
# Initialize routes
routes = require './routes'
routes(app)


# Export application object
module.exports = app

