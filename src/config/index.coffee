#### Config file
# Sets application config parameters depending on `env` name
exports.setEnvironment = (env) ->
  console.log "set app environment: #{env}"
  switch(env)
    when "development"
      exports.DEBUG_LOG = true
      exports.DEBUG_WARN = true
      exports.DEBUG_ERROR = true
      exports.DEBUG_CLIENT = true
      process.env['DATABASE_URL'] = 'pg://shadowjack:@localhost:5432/art_quiz'
      
    when "testing"
      exports.DEBUG_LOG = true
      exports.DEBUG_WARN = true
      exports.DEBUG_ERROR = true
      exports.DEBUG_CLIENT = true

    when "production"
      exports.DEBUG_LOG = false
      exports.DEBUG_WARN = false
      exports.DEBUG_ERROR = true
      exports.DEBUG_CLIENT = false
      process.env['DATABASE_URL'] = 'postgres://ubkjolguybaoep:xDt8jcTHKchp55eShePRoEwnir@ec2-54-197-241-97.compute-1.amazonaws.com:5432/d35pck0slu7rhd'
    else
      console.log "environment #{env} not found"

#TODO: set the 'production' environment on heroku