Browser = require 'zombie'
should = require 'should'
request = require 'request'

BASE_URL = 'http://localhost:3001'
INT_TEST_SRV = 'https://boxecutor-dev-0.scraperwiki.net'

createProfile = (name, password, done) ->
  request.post
    uri: "#{INT_TEST_SRV}/#{name}"
    form:
      apikey: process.env.COTEST_STAFF_API_KEY
      displayname: 'Mr Ickle Test'
      email: 'ickle@example.com'

  , (err, resp, body) ->
    obj = JSON.parse body
    request.post
      uri: "#{BASE_URL}/api/token/#{obj.token}"
      form:
        password: password
    , done

describe 'Login', ->
  browser = null

  before (done) ->
    browser = new Browser()
    createProfile 'ickletest', 'toottoot', done

  context 'when I visit the homepage', ->
    before (done) ->
      browser.visit BASE_URL, done

    context 'when I am not logged in', ->
      it 'shows me a login form', ->
        should.exist browser.query('form')

    context 'when I try to login with valid details', ->
      before (done) ->
        browser.fill '#username', 'ickletest'
        browser.fill '#password', 'toottoot'
        browser.pressButton '#login', done

      it 'shows my name', ->
        browser.text('body').should.include 'Mr Ickle Test'

      it 'shows my datasets', ->
        browser.text('body').should.include 'Your Datasets'

      context 'when I logout', ->
        before (done) ->
          browser.fire 'click', browser.query('li.user a'), ->
            browser.clickLink 'Log Out', done

        it 'redirects me to the login page', ->
          browser.location.href.should.equal "#{BASE_URL}/login"

        context 'when I visit the index page', ->
          it 'should still present a login form'

     context 'when I try to login with my email address as my username', ->

describe 'Switch', ->

  user_a = 'ickletest'
  pass_a = 'toottoot'
  user_b = 'ehg'
  pass_b = 'testing'
  dataset_name = "dataset-#{String(Math.random()*Math.pow(2,32))[0..4]}"

  before (done) ->
    # log in as A
    request.get "#{BASE_URL}/login", ->
      request.post
        uri: "#{BASE_URL}/login"
        form:
          username: user_a
          password: pass_a
      , (err, resp, body) ->
        request.post
          uri: "#{BASE_URL}/api/#{user_a}/datasets/"
          form:
            name: dataset_name
            displayName: dataset_name
            box: 'dummybox'
        , done

  before (done) ->
    @browser = new Browser()
    # Log in as B via zombie
    @browser.visit BASE_URL, =>
      @browser.fill '#username', user_b
      @browser.fill '#password', pass_b
      @browser.pressButton '#login', done

  context 'when I switch context', ->
    before (done) ->
      @browser.visit "#{BASE_URL}/api/switch/#{user_a}", =>
        @browser.visit BASE_URL, done

    it 'shows me datasets of the profile into which I have switched', ->
      @browser.text('#datasets').should.include dataset_name

    it "has the switched to profile's name", ->
      @browser.text('.user').should.include 'Mr Ickle Test'

    it "shows a gravatar", ->
      img = @browser.query('.user a img')
      img.src.should.include 'gravatar'
