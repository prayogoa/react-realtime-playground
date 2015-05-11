EventEmitter = require('emitters').ChainedEmitter
shortid = require('shortid')

class RealtimeModel
	class Node
		@doInitialize: (params) ->
			@coords = params.coords
			console.log "init "+ @id

	@registerTypes: (realtime) ->
		realtime.custom.registerType Node, 'Node' 
		Node::coords = realtime.custom.collaborativeField 'coords'
		Object.defineProperty Node::, "id",
			get: () -> realtime.custom.getId @
		realtime.custom.setInitializer Node, Node.doInitialize

	@initialize: (model) ->
		#create mapping of nodes
		model.getRoot().set 'nodes', model.createMap()

	constructor: (@model) ->
		Object.defineProperty @, 'nodeMap', 
			get: -> @model.getRoot().get 'nodes'
		@

	newNode: (coords) ->
		@model.create Node, coords:coords

	addEventListener: (eventType, handler) ->
		@model.getRoot().addEventListener eventType, handler


class OfflineModel extends EventEmitter
	@EventType = 
		OBJECT_CHANGED: 'object_changed'

	class Node extends EventEmitter
		constructor: (coords) ->
			super()
			coord = coords
			Object.defineProperty @, "id", 
				value: shortid.generate(),
				writable: false

			Object.defineProperty @, "coords",
				get: -> coord
				set: (newCoords) ->
					coord = newCoords
					@emit OfflineModel.EventType.OBJECT_CHANGED
					coords

	class NodeMap extends EventEmitter
		constructor: ->
			super()
			nodes = {}

			@set = (id, node)=>
				node.parentEmitter @
				nodes[id] = node
				@emit OfflineModel.EventType.OBJECT_CHANGED

			@get = (id)=>
				nodes[id]

			@values = ->
				node for id, node of nodes

	constructor: ->
		super()
		Object.defineProperty @, 'nodeMap',
			value:new NodeMap()
			writable: false

		@nodeMap.parentEmitter @

		@addEventListener= @on

	newNode: (coords) ->
		new Node coords, @

module.exports = {RealtimeModel, OfflineModel}