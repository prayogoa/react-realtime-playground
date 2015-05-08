React = require("react")

#helper
toSVGCoord = (svg, x, y)->
	uupos = svg.createSVGPoint()
	uupos.x = x
	uupos.y = y
	ctm = svg.getScreenCTM()
	if ctm = ctm.inverse()
		uupos = uupos.matrixTransform ctm
	return uupos

Node = React.createClass

	render: ->
		<ellipse draggable="true" rx='50', ry='50' fill="white" stroke="crimson" {...@props}/>


MainView = React.createClass
	getInitialState: ->
		nodeSelected: null

	nodeMouseDown: (node, e)->
		#make note of the selected node in state
		@setState nodeSelected:node.id

	handleMouseUp: (e)->
		#if theres a node selected, move them
		if id = @state.nodeSelected
			@props.modelRoot.get('nodes').get(id).coords = toSVGCoord(React.findDOMNode(@), e.clientX, e.clientY)
		#clear selected node from state
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