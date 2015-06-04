Router = require('react-router')
Route = Router.Route
DefaultRoute = Router.DefaultRoute
{App, Home, Auth, Create, FileOpen} = require("./components")
React = require("react")
gapiHelper = require('./gapi-helper')

startApp = (rtprops) ->
  gapiHelper.init(rtprops)
  routes = 
    <Route name="root" path="/" handler={App} >
      <DefaultRoute name="home" handler={Home} />
      <Route name="sign in" handler={Auth} />
      <Route name="create" handler={Create} />
      <Route name="file" path="file/:id" handler={FileOpen} />
    </Route>

  Router.run routes, Router.HashLocation, (Root, state) ->
    React.render <Root rtparams={rtprops}/>, document.body

module.exports = startApp