module.exports.registerNodeType = (realtime, CoMapModels) ->
	class CoMapNode
		@id: realtime.custom.collaborativeField 'id'
		@x: realtime.custom.collaborativeField 'x'
		@y: realtime.custom.collaborativeField 'y'
		@doInitialize: (params)->
			@x = params.x
			@y = params.y
			@id = params.id
			console.log "init "+@id
	CoMapModels.CoMapNode = CoMapNode
	realtime.custom.registerType CoMapNode, 'CoMapNode' 
	realtime.custom.setInitializer CoMapNode, CoMapNode.doInitialize