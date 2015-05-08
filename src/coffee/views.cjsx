React = require("react")

Node = React.createClass

	render: ->
		<ellipse draggable="true" rx='50', ry='50' fill="white" stroke="crimson" {...@props}/>


MainView = React.createClass
	getInitialState: ->
		nodeSelected: null

	nodeMouseDown: (node, e)->
		@setState nodeSelected:node.id

	handleMouseUp: (e)->
		console.log("dragend")
		if id = @state.nodeSelected
			svg =  React.findDOMNode(@)
			uupos = svg.createSVGPoint()
			uupos.x = e.clientX
			uupos.y = e.clientY
			ctm = svg.getScreenCTM()
			if ctm = ctm.inverse()
				uupos = uupos.matrixTransform ctm
			@props.modelRoot.get('nodes').get(id).coords = 
				x: uupos.x
				y: uupos.y
		@setState nodeSelected:null
	render: ->
		nodes = [(<circle key="center" r="2" fill="red" cx="0" cy="0" />)]
		nodes.push(<Node onMouseDown={@nodeMouseDown.bind(@, node)} key={node.id} cx={node.coords.x}, cy={node.coords.y} node={node}/>) for node in @props.modelRoot.get('nodes').values()
		
		(
			<svg onMouseUp={@handleMouseUp} className="MainView" viewBox="-300 -400 600 800" >
				{nodes}
			</svg>
		)

module.exports = MainView