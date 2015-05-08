module.exports.registerNodeType = (realtime, CoMapModels) ->
	CoMapModels.CoMapNode = ->
	realtime.custom.registerType CoMapModels.CoMapNode, 'CoMapNode' 
	CoMapModels.CoMapNode.prototype.coords = realtime.custom.collaborativeField 'coords'
	CoMapModels.CoMapNode.prototype.id = realtime.custom.collaborativeField 'id'
	
	doInitialize= (params)->
		@coords = params.coords
		@id = params.id
		console.log "init "+@id

	realtime.custom.setInitializer CoMapModels.CoMapNode, doInitialize
	