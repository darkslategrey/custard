bcrypt = require 'bcrypt'
request = require 'request'

INT_TEST_SRV = 'https://boxecutor-dev-0.scraperwiki.net'

class User
  constructor: (@shortName, @password) ->

  checkPassword: (callback) ->
    options =
      uri: "#{INT_TEST_SRV}/#{@shortName}/auth"
      form:
        password: @password

    request.post options, (err, resp, body) =>
      if resp.statusCode is 200
        obj = JSON.parse body
        @apiKey = obj.apikey
        @displayName = obj.displayname
        @email = obj.email
        callback true, this
      else
        callback false


module.exports = User
