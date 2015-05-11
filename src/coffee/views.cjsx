React = require("react")

#helper
toSVGCoord = (svg, x, y)->
	uupos = svg.createSVGPoint()
	uupos.x = x
	uupos.y = y
	ctm = svg.getScreenCTM()
	if ctm = ctm.inverse()
		uupos = uupos.matrixTransform ctm
	x: uupos.x - 40
	y:uupos.y - 40

Node = React.createClass

	render: ->
		<rect width='80', height='80' fill="pink" rx="15" ry="15" {...@props}/>


MainView = React.createClass
	getInitialState: ->
		nodeSelected: null

	nodeMouseDown: (node, e)->
		#make note of the selected node in state
		@setState nodeSelected:node.id

	handleMouseMove: (e)->
		#if theres a node selected, move them
		if @state.nodeSelected
			@props.model.nodeMap.get(@state.nodeSelected).coords = toSVGCoord(React.findDOMNode(@), e.clientX, e.clientY)

	handleMouseUp: (e)->
		#if no node is selected, create a new node
		unless @state.nodeSelected
			newNode = @props.model.newNode toSVGCoord(React.findDOMNode(@), e.clientX, e.clientY) 
			@props.model.nodeMap.set newNode.id, newNode
		#clear selected node from state
		@setState nodeSelected:null

	render: ->
		nodes = [(<circle key="center" r="2" fill="red" cx="0" cy="0" />)]
		for node in @props.model.nodeMap.values()
			nodes.push(<Node onMouseDown={@nodeMouseDown.bind(@, node)} key={node.id} x={node.coords.x}, y={node.coords.y} node={node}/>)	
		(
			<svg onMouseUp={@handleMouseUp} onMouseMove={@handleMouseMove} className="MainView" style={"backgroundColor":"aliceblue"} viewBox="-300 -400 600 800" >
				{nodes}
			</svg>
		)

module.exports = MainView