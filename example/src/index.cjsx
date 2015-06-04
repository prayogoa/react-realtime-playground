startApp = require('./lib/index')
{RealtimeModel, ModelComponent} = require('./model')

window.gapiLoaded = ->
  startApp
    clientId: '128992448042-50i5op6k2un2tiu1fd3ahjkartjtg3k8.apps.googleusercontent.com'
    appId: '128992448042'
    modelComponent: ModelComponent
    initModel: RealtimeModel.initialize
    registerTypes:RealtimeModel.registerTypes
    modelWrapper: RealtimeModel





































return
#everything below this line is unused right now

render = (model) ->
  React.render <MainView id="main" model={model} /> , document.getElementById('main-container')

#Start the Realtime loader with the options.
startRealtime = ->
  realtimeOptions =
  ###
    Client ID from the console.
  ###
  clientId: '128992448042-50i5op6k2un2tiu1fd3ahjkartjtg3k8.apps.googleusercontent.com'

  ###
    Application ID found in the Drive SDK API configuration
  ###
  appId: '128992448042'

  ###
    The ID of the button to click to authorize. Must be a DOM element ID.
  ###
  authButtonElementId: 'authorizeButton'

  shareButtonElementId: 'shareButton'
  ###
   * Function to be called when a Realtime model is first created.
  ###
  initializeModel: (model) -> RealtimeModel.initialize model

  ###
   * Autocreate files right after auth automatically.
  ###
  autoCreate: true

  ###
   * The name of newly created Drive files.
  ###
  defaultTitle: "New Realtime Quickstart File"

  ###
   * The MIME type of newly created Drive Files. By default the application
   * specific MIME type will be used:
   *     application/vnd.google-apps.drive-sdk.
  ###
  newFileMimeType: null # Using default.

  ###
   * Function to be called every time a Realtime file is loaded.
  ###
  onFileLoaded: (doc) ->
    model = new RealtimeModel doc.getModel()
    model.addEventListener gapi.drive.realtime.EventType.OBJECT_CHANGED, (evt) ->
      render model
    render model

  ###
   * Function to be called to inityalize custom Collaborative Objects types.
  ###
  registerTypes: () -> RealtimeModel.registerTypes window.gapi.drive.realtime

  ###
   * Function to be called after authorization and before loading files.
  ###
  afterAuth: null # No action.

  realtimeLoader = new rtclient.RealtimeLoader realtimeOptions
  realtimeLoader.start()


startInMemory = ->
  gapi.load 'auth:client,drive-realtime,drive-share', ->
    RealtimeModel.registerTypes gapi.drive.realtime
    doc = gapi.drive.realtime.newInMemoryDocument()
    RealtimeModel.initialize doc.getModel()
    model = new RealtimeModel doc.getModel()
    model.addEventListener gapi.drive.realtime.EventType.OBJECT_CHANGED, (evt) ->
      render model
    render model

startOffline = ->
  model = new OfflineModel()
  model.addEventListener OfflineModel.EventType.OBJECT_CHANGED, (evt)->
    render model
  render model


if location.host.startsWith("localhost") then startInMemory else
window.onload =  startRealtime