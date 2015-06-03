React = require 'react'
Router = require 'react-router'
RouteHandler = Router.RouteHandler
NavigationMixin = Router.Navigation
StateMixin = Router.State
ReactRouterBootstrap = require 'react-router-bootstrap'
NavItemLink = ReactRouterBootstrap.NavItemLink
ButtonLink = ReactRouterBootstrap.ButtonLink
{Navbar, Nav, MenuItem, Alert, DropdownButton, PageHeader,Button, Input, Grid, Row} = require "react-bootstrap"
Loader = require('react-loaders').Loader
gapiHelper = require './gapi-helper'

App = React.createClass
  render: ->
    <div className="container-fluid">
      <AppNav/>
      <RouteHandler/>
    </div>

AppNav = React.createClass
	render:->
		<Navbar componentClass='header' staticTop brand='Realtime-Quickstart' inverse toggleNavKey={0}>
			<Nav right eventKey={0}>
				<NavItemLink eventKey={1} to='/'>Home</NavItemLink>
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

AuthMixin = 
	statics:
		willTransitionTo: (transition, params, query, callback)->
			#if no token, try authImmediate
			if !gapiHelper.hasToken()
				gapiHelper.authImmediate()
				.then ->
					#auth success, proceed
					callback()
				.catch ->
					#transition to sign in page and tell sign in to redirect here afterwards
					transition.redirect 'sign in', {}, 
						after: JSON.stringify name: @name, params:params, query:query
					callback()
			else callback()

parseAfterQs = (query) ->
	if query.after
		JSON.parse query.after
	else
		name:"home"
		params: {}
		query: {}


Auth = React.createClass
	mixins: [NavigationMixin]
	statics:
		willTransitionTo: (transition, params, query, callback)->
			after = parseAfterQs query.after
			#if we have token, redirect immediately
			if gapiHelper.hasToken()
					transition.redirect after.name, after.params, after.query
					callback()

			#try to auth using immediate mode and redirect if success
			gapiHelper.authImmediate()
			.then (resp) ->
				console.log resp
				transition.redirect after.name, after.params, after.query
				callback()
			.catch (resp) ->
				#immediate failed, display sign in page
				console.log resp
				callback()

	authWithPopup: ->
		after = parseAfterQs @getQuery()
		gapiHelper.authWithPopup()
		.then (resp) =>
			@transitionTo after.name, after.params, after.query
		.catch (resp) ->
			if resp?.name is "cancel"
				#bug with gapi auth, reload the page as a workaround
				window.location.reload()
			#display error on screen

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
	mixins: [NavigationMixin, AuthMixin]

	componentDidMount: ->
		gapiHelper.listFiles({q:"mimeType='#{gapiHelper.mimeType}' and not trashed"})
		.then (files) =>
			@setState files: files
		.catch (resp) =>
			if resp.status is 401
				@transitionTo 'sign in', {}, after:"home"

	render: ->
		<Grid>
			<PageHeader>Home</PageHeader>
			<div className="CenterAll">
				{if @state?.files then <FileList files={@state.files} /> else <Loader type="line-scale" active=true />}
				<ButtonLink to="create" bsStyle='primary' bsSize='large' >New</ButtonLink>
			</div>
		</Grid>

Create = React.createClass
	mixins: [StateMixin, NavigationMixin, AuthMixin]
	getInitialState: ->
		creating: false
		createResult: null
	doCreate: ->
		@setState 
			creating: true
			createResult: null
		, ()=>
			gapiHelper.newFile @refs.title.getValue() or null
			.then (resp) =>
				@setState 
					createResult: resp
					creating: false
			.catch (resp) =>
				console.log resp
				#display alert
				@setState
					creating: false
					createResult: resp

	renderAlert: ->
		if @state.creating
			return (
				<Alert bsStyle='info' className="CenterAll">
					Creating File...
					<Loader className="test" type="pacman" active={true} />
				</Alert>)
		if @state.createResult
				if @state.createResult.status is 200
					return (
						<Alert bsStyle='success'>
							File {@state.createResult.result.title} created!
						</Alert>)
				else
					return (
						<Alert bsStyle='danger'>
							Something happened!
						</Alert>)	
	render: ->
		<Grid>
			<PageHeader>New File</PageHeader>
			<form>
				{@renderAlert()}
				<Input ref="title" type='text' label='Title' labelClassName='col-xs-2' wrapperClassName='col-xs-10' placeholder='File Title' />
				<Button bsStyle='primary' bsSize='large' disabled={@state.creating}} onClick={@doCreate}>Create</Button>
			</form>
		</Grid>

module.exports = {App, Home, Auth, Create}