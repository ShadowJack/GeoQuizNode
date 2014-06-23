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

  describe "Load photos", ->
    it "should load from 1 to 20 photos", (done) ->
      page = Math.floor(Math.random*400)
      request(app)
        .get('/load_new_photos?page=' + page)
        .expect( 200, (err, res)->
          if err
            done err
          else
            res.type.should.be.eql 'application/json'
            res.body.length.should.be.within 1, 20
            done()
        )

  describe "Load countries", ->
    it "should load photos with valid countries", (done) ->
      page = Math.floor(Math.random*400)
      request(app)
        .get('/load_new_photos?page=' + page)
        .expect( 200, (err, res)->
          if err
            done err
          else
            res.type.should.be.eql 'application/json'
            res.body.should.matchEach((val) ->
              val.country.should.be.ok
            )
            done()
        )  
