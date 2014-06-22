request = require 'supertest'
app = require process.cwd() + '/.app'

describe 'General', ->
  this.timeout 40000

  describe 'Main page', ->
    it "should be here", (done) ->
      request(app)
        .get("/")
        .send( {} )
        .expect(200, {},
                done
        )

  describe "404 Routing", ->
    it "should not be here", (done) ->
      request(app)
        .get('/nonexistent/action')
        .send( {} )
        .expect(404, {},
                done
        )

  describe "Load 10 photos", ->
    it "should load exactly 10 photos", (done) ->
      request(app).get '/load_new_photos?page=120', (err, response, body) ->
        if err done err
        else
          console.log body
          response.statusCode.should.be.equal 200
          body.should.have.a.lengthOf 10
          done()
