logger = require "logger-sharelatex"
settings = require 'settings-sharelatex'
redis = require("redis-sharelatex")
rclient = redis.createClient(settings.redis.web)

MESSAGE_SIZE_LOG_LIMIT = 1024 * 1024 # 1Mb

module.exports = DocumentUpdaterController =
	# DocumentUpdaterController is responsible for updates that come via Redis
	# Pub/Sub from the document updater.

	listenForUpdatesFromDocumentUpdater: (io) ->
		rclient.subscribe "applied-ops"
		rclient.on "message", (channel, message) ->
			DocumentUpdaterController._processMessageFromDocumentUpdater(io, channel, message)
		
	_processMessageFromDocumentUpdater: (io, channel, message) ->
		if message.length > MESSAGE_SIZE_LOG_LIMIT
			logger.log {length: message.length, head: message.slice(0,200)}, "large message from doc updater"
		message = JSON.parse message
		if message.op?
			DocumentUpdaterController._applyUpdateFromDocumentUpdater(io, message.doc_id, message.op)
		else if message.error?
			DocumentUpdaterController._processErrorFromDocumentUpdater(io, message.doc_id, message.error, message)

	_applyUpdateFromDocumentUpdater: (io, doc_id, update) ->
		for client in io.sockets.clients(doc_id)
			if client.id == update.meta.source
				logger.log doc_id: doc_id, version: update.v, source: update.meta?.source, "distributing update to sender"
				client.emit "otUpdateApplied", v: update.v, doc: update.doc
			else if !update.dup # Duplicate ops should just be sent back to sending client for acknowledgement
				logger.log doc_id: doc_id, version: update.v, source: update.meta?.source, client_id: client.id, "distributing update to collaborator"
				client.emit "otUpdateApplied", update

	_processErrorFromDocumentUpdater: (io, doc_id, error, message) ->
		logger.error err: error, doc_id: doc_id, "error from document updater"
		for client in io.sockets.clients(doc_id)
			client.emit "otUpdateError", error, message
			client.disconnect()




