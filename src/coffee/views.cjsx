React = require("react")

Node = React.createClass
	render: ->
		<ellipse rx='50', ry='50' fill="none" stroke="crimson" {...@props}/>


MainView = React.createClass
	render: ->
		nodes = (<Node key={node.id} cx={node.x}, cy={node.y}/> for node in @props.modelRoot.get('nodes').values())
		nodes.push(<circle key="center" r="2" fill="red" cx="0" cy="0" />)
		(
			<svg className="MainView" viewBox="-300 -400 600 800" >
				{nodes}
			</svg>
		)

module.exports = MainView