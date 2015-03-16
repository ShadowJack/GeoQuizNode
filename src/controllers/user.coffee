pg = require('pg')

DATABASE_URL = process.env.DATABASE_URL

"""
post /user_score?uid=vk_uid&score=new_score

Updates user score into db.
If there is no such user in db - create it.
"""
exports.set_user_score = (req, res) ->
  pg.connect DATABASE_URL, (err, client, done) ->
    if err
      console.log "DB_set_user_score connection: " + err
      res.send {error: 'Cannot update user score: ' + err}
      return done()
    
    # TOO BAD: doesn't escape data from client!
    q = "UPDATE users SET score = score + (" + req.body.score + ") WHERE vk_id=" + req.body.uid + " RETURNING score;"
    console.log q
    client.query q, (err, result) ->
      console.log "User " + req.body.uid + " score after update: " + result
      if err || result.rows.length == 0
        console.log "DB_set_user_score update" + err
        res.send {error: 'Cannot update user score: ' + err}
        return done()
      res.send {score: result.rows[0].score}
      done() 
      

"""
get /user_score?uid=vk_uid&score=vk_score

Returns current user score for user
If there is no such user in the db - create it using score from params

param: vk_uid - user id from vk
       score - user score from vk db
"""      
exports.get_user_score = (req, res) ->
  pg.connect DATABASE_URL, (err, client, done) ->
    if err
      console.log err
      res.send {error: 'Cannot connect to db:' + err}
      return done()

    client.query "SELECT * FROM users WHERE vk_id=" + req.query.uid + ";", (err, result) ->
      if err
        console.log "get_user_score: select user with vk_id=" + req.query.uid + ". Got error:   " + err
        res.send {error: 'User query error: ' + err }
        return done()
        
      console.log "Get from db: ", result
      if result.rows.length == 0
        # create new user
        console.log "Uid: " + req.query.uid + ", score: " + req.query.score
        client.query "INSERT INTO users (vk_id, score) VALUES (" + req.query.uid + ", " + req.query.score + ");", (err, result) ->
          if err
            console.log err
            res.send {error: 'Cannot create a new user: ' + err}
            return done()
          res.send {score: req.query.score}
      else
        res.send {score: result.rows[0].score}
      done()
        
"""
get /leaders

Returns top 8 users of the app
"""
exports.leaders = (req, res) ->
  pg.connect DATABASE_URL, (err, client, done) ->
    if err
      console.log "leaders: Error while connecting to db - " + err
      res.send {error: 'Cannot connect to db:' + err}
      return done()

    client.query "SELECT * FROM users ORDER BY score desc LIMIT 8;", (err, result) ->
      if err
        console.log "leaders: select top 10 users error - " + err
        res.send {error: 'User query error: ' + err }
        return done()
        
      console.log "Get from db: ", result
      
      res.send { result: result.rows }
      done()