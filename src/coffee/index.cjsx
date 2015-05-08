rtclient = require('./realtime-client-utils')
Customs = require('./custom-objects')
MainView = require("./views")
React = require("react")
shortid = require('shortid')


# window.rtclient = rtclient

# window.realtimeOptions = {
#   ###
#    	Client ID from the console.
#   ###
#   clientId: '128992448042-50i5op6k2un2tiu1fd3ahjkartjtg3k8.apps.googleusercontent.com',

#   ###
#     The ID of the button to click to authorize. Must be a DOM element ID.
#   ###
#   authButtonElementId: 'authorizeButton',

#   ###
#    * Function to be called when a Realtime model is first created.
#   ###
#   initializeModel: null,

#   ###
#    * Autocreate files right after auth automatically.
#   ###
#   autoCreate: true,

#   ###
#    * The name of newly created Drive files.
#   ###
#   defaultTitle: "New Realtime Quickstart File",

#   ###
#    * The MIME type of newly created Drive Files. By default the application
#    * specific MIME type will be used:
#    *     application/vnd.google-apps.drive-sdk.
#   ###
#   newFileMimeType: null, # Using default.

#   ###
#    * Function to be called every time a Realtime file is loaded.
#   ###
#   onFileLoaded: null,

#   ###
#    * Function to be called to inityalize custom Collaborative Objects types.
#   ###
#   registerTypes: null, # No action.

#   ###
#    * Function to be called after authorization and before loading files.
#   ###
#   afterAuth: null # No action.
# }

window.CoMapModels or= {}

registerCustomObjects = (realtime)->
	Customs.registerNodeType realtime, CoMapModels

window.init = ->
  console.log 'init'
  registerCustomObjects(gapi.drive.realtime)
  
  #create document and get the model
  model = gapi.drive.realtime.newInMemoryDocument().getModel()

  #attach an Object_changed listener to the root
  root = model.getRoot()
  root.addEventListener gapi.drive.realtime.EventType.OBJECT_CHANGED, (evt) ->
    render(root)

  #create mapping of nodes
  nodes = model.createMap()
  root.set 'nodes', nodes

  #insert a single node
  id = shortid.generate()
  node = model.create CoMapModels.CoMapNode, 
      id: id
      coords: 
        x:0
        y:0
  nodes.set id, node

  #make changes to node
  # tick = 0
  # perTick = Math.PI/180
  # setInterval ()=>
  #   tick+=perTick
  #   node.coords = 
  #     x: Math.sin(tick) * 150
  #     y: Math.cos(tick) * 200
  # , 1000/60

render = (root) ->
  React.render <MainView id="main" modelRoot={root} /> , document.body

gapi.load 'auth:client,drive-realtime,drive-share', ->
	init()