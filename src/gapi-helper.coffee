Promise = require 'bluebird'
SCOPES = [
				'https://www.googleapis.com/auth/drive.install',
				'https://www.googleapis.com/auth/drive',
				'openid'
			]

inited = false

class gapiHelper
	init: (params) ->
		@clientId = params.clientId
		@appId = params.appId
		@mimeType = "application/vnd.google-apps.drive-sdk.#{@appId}"
		@defaultTitle = params.defaultTitle || "Untitled"
		inited = true

	_load: ->
		new Promise (fulfill, reject) ->
			gapi.load "auth:client,drive-realtime,drive-share", fulfill

	initialized: -> inited

	authImmediate: ->
		@_load()
		.then =>
			new Promise (fulfill, reject) =>
				gapi.auth.authorize 
					client_id: @clientId
					scope: SCOPES
					immediate: true
				, (authResult) ->
					reject() unless authResult
					if authResult.error then reject authResult else fulfill authResult			

	authWithPopup: ->
		@_load()
		.then =>
			new Promise (fulfill, reject) =>
				#https://github.com/google/google-api-javascript-client/issues/25
				((wrapped) ->
			        window.open = ->
			            # re-assign the original window.open after one usage
			            window.open = wrapped
			            openedWin = wrapped.apply this, arguments
			            i = setInterval -> 
			                if openedWin.closed 
			                    clearInterval i
			                    #cancel has no effect when the promise is already resolved, e.g. by the success handler
			                    #see http://docs.closure-library.googlecode.com/git/class_goog_Promise.html#goog.Promise.prototype.cancel
			                    authorizeDeferred.cancel();
			            , 100
			            return openedWin
				)(window.open);

				authorizeDeferred = gapi.auth.authorize 
					client_id: @clientId
					scope: SCOPES
					immediate: false,
				.then fulfill, reject

	newFile: (title, folderId) ->
		new Promise (fulfill, reject) =>
			gapi.client.load 'drive', 'v2'
			.then =>
				gapi.client.drive.files.insert 
					resource:
						mimeType: @mimeType
						title: title or @defaultTitle
						parents: if folderId then [folderId] else null
				.then(fulfill, reject)
			, reject

	listFiles: (params = {}) ->
		new Promise (fulfill, reject) ->
			handleResponse = (response, fileList, params) ->
				fileList = fileList.concat response.result.items
				nextPageToken = response.result.nextPageToken
				if nextPageToken
					retrievePageOfFiles gapi.client.drive.files.list(pageToken:nextPageToken), fileList, params
				else
					fulfill fileList

			retrievePageOfFiles = (request, fileList, params) ->
				request.then (resp) ->
					handleResponse resp, fileList, params
				, reject

			gapi.client.load 'drive', 'v2'
			.then ->
				initReq = gapi.client.drive.files.list params
				retrievePageOfFiles initReq, [], params
			, reject

	load: (fileId, initModel = ->) ->
		@_load
		.then ->
			new Promise (fulfill, reject) ->
				gapi.drive.realtime.load fileId, fulfill, initModel, reject

	hasToken: ->
		gapi.auth.getToken()
module.exports = new gapiHelper()