request = require 'request'
should = require 'should'
settings = require '../settings.json'

describe 'API', ->
  context "When I'm logged in", ->
    before (done) ->
      @user = 'ickletest'
      @password = 'toottoot'
      @fullName = 'Mr Ickle Test'

      @loginURL = "#{settings.serverURL}/login"
      request.get @loginURL, =>
        request.post
          uri: @loginURL
          form:
            username: @user
            password: @password
        , (err, res) =>
            @loginResponse = res
            done(err)

    it 'managed to log in', ->
      should.exist @loginResponse
      # check we're being redirected to /, as opposed to /login
      @loginResponse.body.should.include 'Redirecting to /'
      @loginResponse.body.should.not.include 'Redirecting to /login'

    describe 'Datasets', ->
      context 'when I create a dataset', ->
        response = null
        dataset = null

        before (done) ->
          request.post
            uri: "#{settings.serverURL}/api/#{@user}/datasets"
            form:
              displayName: 'Biscuit'
              box: 'ickletest/blah'
          , (err, res) ->
            response = res
            dataset = JSON.parse res.body
            done()

        context 'POST /api/:user/datasets', ->
          it 'creates a new dataset', ->
            response.should.have.status 200

          it 'returns the newly created dataset', ->
            should.exist dataset._id
            dataset.displayName.should.equal 'Biscuit'

        context 'GET /api/:user/datasets/:id', ->
          it 'returns a single dataset', (done)  ->
            request.get "#{settings.serverURL}/api/#{@user}/datasets/#{dataset._id}", (err, res) ->
              dataset = JSON.parse res.body
              should.exist dataset._id
              done()

          it "500 errors if the dataset doesn't exist", (done) ->
            request.get "#{settings.serverURL}/api/#{@user}/datasets/NOTEXIST", (err, res) ->
              res.should.have.status 500
              done()

          it "403 errors if the user doesn't exist", (done) ->
            request.get "#{settings.serverURL}/api/MRINVISIBLE/datasets/#{dataset._id}", (err, res) ->
              res.should.have.status 403
              done()

        context 'PUT /api/:user/datasets/:id', ->
          it 'updates a single dataset with new values', (done) ->
            request.put
              uri: "#{settings.serverURL}/api/#{@user}/datasets/#{dataset._id}"
              form:
                displayName: 'Cheese'
            , (err, res) =>
              res.should.have.status 200
              request.get "#{settings.serverURL}/api/#{@user}/datasets/#{dataset._id}", (err, res) ->
                dataset = JSON.parse res.body
                dataset.displayName.should.equal 'Cheese'
                done(err)


          it "500 errors if the dataset doesn't exist", (done) ->
            request.put "#{settings.serverURL}/api/#{@user}/datasets/NOTEXIST", (err, res) ->
              res.should.have.status 500
              done()

      context 'GET: /api/:user/datasets', ->
        it 'returns a list of datasets', (done) ->
          request.get "#{settings.serverURL}/api/#{@user}/datasets", (err, res) ->
            datasets = JSON.parse res.body
            datasets.length.should.be.above 1
            done(err)

    describe 'Users', ->
      context "When I'm a staff member", ->
        before (done) ->
          # logout
          request.get "#{settings.serverURL}/logout", done
        before (done) ->
          @loginURL = "#{settings.serverURL}/login"
          @user = "teststaff"
          @password = process.env.CU_TEST_STAFF_PASSWORD
          request.get @loginURL, =>
            request.post
              uri: @loginURL
              form:
                username: @user
                password: @password
            , (err, res) =>
                @loginResponse = res
                done(err)
        it 'allows me to create a new profile', (done) ->
          @newUser = "new-#{String(Math.random()*Math.pow(2,32))[0..6]}"
          @newPassword = "newpass"
          request.post
            uri: "#{settings.serverURL}/api/#{@newUser}"
            form:
              email: 'random@example.com'
              displayName: 'Ran Dom Test'
          , (err, resp, body) ->
            obj = JSON.parse body
            @token = obj.token
            resp.should.have.status 201
            done(err)
        it '... and I can set the password', (done) ->
          request.post
            uri: "#{settings.serverURL}/api/token/#{@token}"
            form:
              password: @newPassword
          , (err, resp, body) ->
             resp.should.have.status 200
             done(err)

