class Cu.Model.Dataset extends Backbone.Model
  base_url: 'http://boxecutor-dev-0.scraperwiki.net'
  idAttribute: '_id'
  url: ->
    if @isNew()
      "/api/#{window.user.shortName}/datasets"
    else
      "/api/#{window.user.shortName}/datasets/#{@get '_id'}"

  name: ->
    @get('displayName') or @get('name') or 'no name'

  publishToken: (callback) ->
    if @_publishToken?
      callback @_publishToken
    else
      @exec("cat ~/scraperwiki.json").success (data) ->
        settings = JSON.parse data
        @_publishToken = settings.publish_token
        callback @_publishToken

  exec: (cmd, args) ->
    # Returns an ajax object, onto which you can
    # chain .success and .error callbacks
    boxname = @get 'box'
    boxurl = "#{@base_url}/#{boxname}"
    settings =
      url: "#{boxurl}/exec"
      type: 'POST'
      data:
        apikey: window.user.apiKey
        cmd: cmd
    if args?
      $.extend settings, args
    $.ajax settings

  validate: (attrs) ->
    return "Please enter a name" if 'displayName' of attrs and attrs.displayName.length < 1

class Cu.Collection.DatasetList extends Backbone.Collection
  model: Cu.Model.Dataset
  url: -> "/api/#{window.user.shortName}/datasets"
