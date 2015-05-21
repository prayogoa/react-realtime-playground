React = require "react"
Bootstrap = require "react-bootstrap"
ReactRouterBootstrap = require 'react-router-bootstrap'
Navbar= Bootstrap.Navbar
Nav = Bootstrap.Nav
NavItemLink = ReactRouterBootstrap.NavItemLink
MenuItem = Bootstrap.MenuItem
DropdownButton = Bootstrap.DropdownButton
PageHeader = Bootstrap.PageHeader
Loader = require('react-loaders').Loader
gapiHelper = require './gapi-helper'
NavigationMixin = require('react-router').Navigation
Button = Bootstrap.Button

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

NavBar = React.createClass
	render:->
		<Navbar componentClass='header' staticTop brand='Realtime-Quickstart' inverse toggleNavKey={0}>
			<Nav right eventKey={0}>
				<NavItemLink eventKey={1} to='/'>Link</NavItemLink>
				<NavItemLink eventKey={2} to='/'>Link</NavItemLink>
				<DropdownButton eventKey={3} title='Dropdown'>
					<MenuItem eventKey='1'>Action</MenuItem>
					<MenuItem eventKey='2'>Another action</MenuItem>
					<MenuItem eventKey='3'>Something else here</MenuItem>
					<MenuItem divider />
					<MenuItem eventKey='4'>Separated link</MenuItem>
				</DropdownButton>
			</Nav>
		</Navbar>

Auth = React.createClass
	mixins: [NavigationMixin]
	statics:
		willTransitionTo: (transition, params, query, callback)->
			#if we have token, redirect immediately
			if gapiHelper.hasToken()
					transition.redirect query.after or 'home'
					callback()

			#try to auth using immediate mode and redirect if success
			gapiHelper.authImmediate()
			.then (resp) ->
				transition.redirect query.after or 'home'
				callback()
			.catch (resp) ->
				#immediate failed, display sign in page
				console.log resp
				callback(resp)

	authWithPopup: ->
		gapiHelper.authWithPopup()
		.then (resp) =>
			console.log resp
			@transitionTo @props.query.after or 'home'
		.catch (resp) ->
			console.log resp
	render:->
		<div>
			<PageHeader>Sign in</PageHeader>
			<Button bsStyle='primary' bsSize='large' onClick={@authWithPopup}>Sign In</Button>
		</div>

FileListItem = React.createClass
	render: ->
		<li>{@props.file.title}</li>

FileList = React.createClass
	render: ->
		<ul>
			{<FileListItem key={file.id} file={file}/> for file in @props.files}
		</ul>

Home = React.createClass
	mixins: [NavigationMixin]
	statics:
		willTransitionTo: (transition, params, query)->
			#if no token, redirect to sign in page
			if !gapiHelper.hasToken()
					transition.redirect 'sign in', {}, after:"home"
	componentDidMount: ->
		gapiHelper.listFiles({q:"'root' in parents and not trashed"})
		.then (files) =>
			@setState files: files
		.catch (resp) =>
			if resp.status is 401
				@transitionTo 'sign in', {}, after:"home"

	render: ->
		console.log 'render home'
		<div>
			<PageHeader>Home</PageHeader>
			<div className="FileListContainer">
				{if @state?.files then <FileList files={@state.files} /> else <Loader type="line-scale" active=true />}
			</div>
		</div>

module.exports = {MainView, Home, NavBar, Auth}