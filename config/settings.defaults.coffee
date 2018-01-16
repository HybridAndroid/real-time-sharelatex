module.exports =
	redis:
		realtime:
			host: process.env['REDIS_HOST'] or "localhost"
			port: "6379"
			password: ""
			key_schema:
				clientsInProject: ({project_id}) -> "clients_in_project:#{project_id}"
				connectedUser: ({project_id, client_id})-> "connected_user:#{project_id}:#{client_id}"

		documentupdater:
			host: process.env['REDIS_HOST'] or "localhost"
			port: "6379"
			password: ""
			key_schema:
				pendingUpdates: ({doc_id}) -> "PendingUpdates:#{doc_id}"

		websessions:
			host: process.env['REDIS_HOST'] or "localhost"
			port: "6379"
			password: ""

	internal:
		realTime:
			port: 3026
			host: process.env['LISTEN_ADDRESS'] or "localhost"
			user: "sharelatex"
			pass: "password"
			
	apis:
		web:
			url: "http://#{process.env['WEB_HOST'] or "localhost"}:3000"
			user: "sharelatex"
			pass: "password"
		documentupdater:
			url: "http://#{process.env['DOCUPDATER_HOST'] or "localhost"}:3003"
			
	security:
		sessionSecret: "secret-please-change"
		
	cookieName: "sharelatex.sid"
	
	max_doc_length: 2 * 1024 * 1024 # 2mb