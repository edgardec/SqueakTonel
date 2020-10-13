"
WebClient provides a simple yet complete HTTP client implementation.

To view the documentation evaluate:

	HelpBrowser openOn: WebClientHelp.

"
Class {
	#name : #WebClient,
	#superclass : #Object,
	#instVars : [
		'flags',
		'server',
		'scheme',
		'timeout',
		'stream',
		'cookies',
		'proxyServer',
		'lastScheme',
		'lastServer',
		'lastPort',
		'maxRedirect',
		'redirections',
		'userAgent',
		'authParams',
		'proxyParams',
		'accessLog',
		'debugLog'
	],
	#classVars : [
		'DebugLog',
		'FlagAcceptCookies',
		'FlagAllowAuth',
		'FlagAllowRedirect',
		'ProxyHandler'
	],
	#category : #'WebClient-Core'
}

{ #category : #accessing }
WebClient class >> debugLog [
	"The default debugLog, if any:
		WebClient debugLog: Transcript.
		WebClient debugLog: nil.
	"

	^DebugLog
]

{ #category : #accessing }
WebClient class >> debugLog: aStream [
	"The default debugLog, if any:
		WebClient debugLog: Transcript.
		WebClient debugLog: nil.
	"

	DebugLog := aStream.
]

{ #category : #utilities }
WebClient class >> htmlSubmit: urlString fields: fieldMap [
	"A utility method for html submit operations. The fieldMap can be EITHER
	an array of associations OR a Dictionary of key value pairs (the former is
	useful for providing multiple fields and/or specifying the order of fields).

		WebClient 
			htmlSubmit: 'http://www.google.com/search'
			fields: {
				'hl' -> 'en'.
				'q' -> 'Squeak'
			}
	"
	^self htmlSubmit: urlString 
			fields: fieldMap
			method: 'GET'

]

{ #category : #utilities }
WebClient class >> htmlSubmit: urlString fields: fieldMap method: method [
	"A utility method for html submit operations. The fieldMap can be EITHER
	an array of associations OR a Dictionary of key value pairs (the former is
	useful for providing multiple fields and/or specifying the order of fields).

		WebClient 
			htmlSubmit: 'http://www.google.com/search'
			fields: {
				'hl' -> 'en'.
				'q' -> 'Squeak'
			} method: 'GET'
	"
	^self htmlSubmit: urlString 
			fields: fieldMap
			method: method
			encoding: 'application/x-www-form-urlencoded'

]

{ #category : #utilities }
WebClient class >> htmlSubmit: urlString fields: fields method: method encoding: encoding [
	"A utility method for html submit operations. The fieldMap can be EITHER
	an array of associations OR a Dictionary of key value pairs (the former is
	useful for providing multiple fields and/or specifying the order of fields).

		WebClient 
			htmlSubmit: 'http://www.google.com/search'
			fields: {
				'hl' -> 'en'.
				'q' -> 'Squeak'
			} method: 'GET'
			encoding: 'application/x-www-form-urlencoded'
	"

	method = 'GET' ifTrue:[
		"GET only supports url encoded requests"
		encoding = 'application/x-www-form-urlencoded' 
			ifFalse:[^self error: 'Unsupported encoding: ', encoding].
		^self httpGet: urlString, '?', (WebUtils encodeUrlEncodedForm: fields).
	].

	method = 'POST' ifTrue:[
		"Dispatch on encoding type"
		encoding caseOf: {
			[ 'application/x-www-form-urlencoded'] -> [
				^self httpPost: urlString
					content: (WebUtils encodeUrlEncodedForm: fields)
					type: encoding.
			].
			['multipart/form-data'] -> [
				^self httpPost: urlString multipartFields: fields
			].
		} otherwise:[]
	].

	self error: 'Unsupported method: ', method.

]

{ #category : #methods }
WebClient class >> httpDelete: urlString [
	"Sends a DELETE request"
	"WebClient httpDelete: 'http://ftp.squeak.org/trunk'"

	^self httpDo:[:client| client httpDelete: urlString].

]

{ #category : #methods }
WebClient class >> httpDo: aBlock [
	"Simplified wrapper for running various methods"

	| client response |
	client := self new.
	response := WebUtils handleAuth: [aBlock value: client].
	response content; close.
	^response
]

{ #category : #methods }
WebClient class >> httpGet: urlString [
	"Get the response from the given url"
	"(WebClient httpGet: 'http://www.squeak.org') content"

	^self httpDo:[:client| client httpGet: urlString].
]

{ #category : #methods }
WebClient class >> httpHead: urlString [
	"Sends a HEAD request"
	"WebClient httpHead: 'http://ftp.squeak.org/trunk'"

	^self httpDo:[:client| client httpHead: urlString].

]

{ #category : #methods }
WebClient class >> httpOptions: urlString [
	"Sends an OPTIONS request"
	"WebClient httpOptions: 'http://ftp.squeak.org/*'"
	"WebClient httpOptions: 'http://ftp.squeak.org/4.1/Squeak4.1.zip'"

	^self httpDo:[:client| client httpOptions: urlString]

]

{ #category : #methods }
WebClient class >> httpPost: urlString content: postData type: contentType [
	"Fire off an HTTP post request"

	^self httpDo:[:client| client httpPost: urlString content: postData type: contentType]

]

{ #category : #utilities }
WebClient class >> httpPost: url multipartFields: fieldMap [
	"Make a form submission using multipart/form-data POST.

	The fieldMap may contain MIMEDocument instances to indicate the presence
	of a file to upload to the server. If the MIMEDocument is present, its
	content type and file name will be used for the upload.

	The fieldMap can be EITHER an array of associations OR a Dictionary of 
	key value pairs (the former is useful for providing multiple fields and/or 
	specifying the order of fields)."

	| boundary |
	boundary := WebUtils multipartBoundary.

	^self httpPost: url 
		content: (WebUtils encodeMultipartForm: fieldMap boundary: boundary) 
		type: 'multipart/form-data; boundary=', boundary
]

{ #category : #methods }
WebClient class >> httpPostChunked: urlString content: chunkBlock type: contentType [
	"POST the data to the given url using chunked transfer-encoding.
	The chunkBlock takes a request and can be fed using #nextChunkPut:
	until all the data has been sent.

	Chunked encoding can be used for long-lasting connections to a server,
	but care must be taken to ensure that the client isn't running afoul of
	the server expecting to read the full response (i.e., you should use this
	only if you have control over both ends).

	However, it is a great way to send output from commands that take awhile
	and other time-consuming operations if authentication has been handled."

	^self httpDo:[:client| 
		client httpPostChunked: urlString content: chunkBlock type: contentType]

]

{ #category : #methods }
WebClient class >> httpPut: urlString content: postData type: contentType [
	"Fire off an HTTP PUT request"

	^self httpDo:[:client| client httpPut: urlString content: postData type: contentType]
]

{ #category : #httpsocket }
WebClient class >> httpRequest: method url: urlString headers: hdrs content: contentOrNil response: responseBlock [

	"Sends an HTTP request to the server. Returns a MIMEDocument if successful,
	a string indicating the error otherwise. If a response block is provided, the
	response is fed into into so that the sender can see all the headers."

	| client request response content |
	client := self new.
	client initializeFromUrl: urlString.
	client userAgent: HTTPSocket userAgentString.

	request := client requestWithUrl: urlString.
	request method: method.

	"Set up headers for the request"
	(WebUtils readHeadersFrom: hdrs readStream) 
		do:[:hdr| request addHeader: hdr key value: hdr value].

	WebUtils handleAuth:[
		response := client sendRequest: request 
			content: (contentOrNil ifNotNil:[contentOrNil readStream])
			size: (contentOrNil ifNil:[0] ifNotNil:[contentOrNil size]).
	].

	content := response contentWithProgress:[:total :amount|
		(HTTPProgress new) total: total; amount: amount; signal: 'Downloading...'.
	].
	client close.

	responseBlock ifNotNil:[responseBlock value: response asString].

	^(response isSuccess) 
		ifTrue:[MIMEDocument contentType: response contentType 
				content: content url: urlString]
		ifFalse:[response asString, content].

]

{ #category : #methods }
WebClient class >> httpTrace: urlString [
	"Sends a TRACE request"
	"(WebClient httpTrace: 'http://lists.squeakfoundation.org') content"
	"(WebClient httpTrace: 'http://ftp.squeak.org/trunk') content"

	^self httpDo:[:client| client httpTrace: urlString]
]

{ #category : #'class initialization' }
WebClient class >> initialize [
	"WebClient initialize"

	FlagAcceptCookies := 1.
	FlagAllowAuth := 2.
	FlagAllowRedirect := 4.

	"Default proxy handler"
	ProxyHandler := WebUtils.

	self registerHttpSocketRequestHandler.

]

{ #category : #accessing }
WebClient class >> proxyHandler [
	"The currently registered proxy handler"

	^ProxyHandler
]

{ #category : #accessing }
WebClient class >> proxyHandler: anObject [
	"The currently registered proxy handler"

	ProxyHandler := anObject
]

{ #category : #httpsocket }
WebClient class >> registerHttpSocketRequestHandler [
	"Register WebClient as an HTTPSocket request handler"

	(HTTPSocket respondsTo: #httpRequestHandler:) ifFalse:[^self].

	"Be polite and only register if no other handler was registered."
	HTTPSocket httpRequestHandler == HTTPSocket
		ifTrue:[HTTPSocket httpRequestHandler: self].

]

{ #category : #benchmark }
WebClient class >> requestBenchmark: url persistent: aBool [
	"Run a WebClient benchmark to measure request handling speed.
	Try using a persistent connection if requested.

	1) Launch WebServer  (or Seaside, or whatever):
	
		(WebServer reset default)
			listenOn: 8888;
			addService: '/' action:[:r| r send200Response: ''].

	2) Run the benchmark:

		MessageTally spyOn:[
			WebClient requestBenchmark: 'http://localhost:8888/' persistent: true.
		]
	"

	| time resp startTime endTime count client |
	count := 0.
	client := WebClient new.
	startTime := Time millisecondClockValue.
	[endTime := Time millisecondClockValue.
	(time := Time milliseconds: endTime since: startTime) < 5000] whileTrue:[
		resp := client httpGet: url.
		resp isSuccess ifFalse:[self error: resp status].
		resp content.
		aBool ifFalse:[resp close].
		count := count + 1.
	].
	^(count  * 1000 // time) asStringWithCommas, ' requests/sec'

]

{ #category : #'class initialization' }
WebClient class >> unload [
	"Unregister WebClient as http socket handler when unloaded"

	self unregisterHttpSocketRequestHandler.

]

{ #category : #httpsocket }
WebClient class >> unregisterHttpSocketRequestHandler [
	"Unregister WebClient as an HTTPSocket request handler"

	(HTTPSocket respondsTo: #httpRequestHandler:) ifFalse:[^self].

	HTTPSocket httpRequestHandler == self
		ifTrue:[HTTPSocket httpRequestHandler: nil].

]

{ #category : #websockets }
WebClient class >> webSocket00: serverUrl protocol: protocol [
	"Attempt to connect to the given server url using the WebSocket api"

	| key1 key2 bytes hash client req resp |
	"Fixed keys from spec"
	key1 := 155712099.
	key2 := 173347027.
	bytes := ByteArray new: 8.
	(1 to: bytes size) do:[:i| bytes at: i put: (256 atRandom - 1)].
	hash := WebUtils webSocketHandshake: key1 with: key2 with: bytes.

	client := self new.
	client initializeFromUrl: serverUrl.
	req := client requestWithUrl: serverUrl.
	req method: 'GET'.
	req headerAt: 'Upgrade' put: 'WebSocket'.
	req headerAt: 'Connection' put: 'Upgrade'.
	req headerAt: 'Origin' put: 'null'.
	protocol ifNotNil:[req headerAt: 'Sec-WebSocket-Protocol' put: protocol].
	req headerAt: 'Sec-WebSocket-Key1' put: '18x 6]8vM;54 *(5:  {   U1]8  z [  8'.
	req headerAt: 'Sec-WebSocket-Key2' put: '1_ tx7X d  <  nw  334J702) 7]o}` 0'.
	resp := client sendRequest: req content: bytes readStream size: bytes size.
	resp code = 101 ifFalse:[client close. ^nil].
	(resp stream next: 16) asByteArray = hash ifFalse:[client close. ^nil].

	"Close of stream is left to caller"
	^WebSocket00 on: resp stream.

]

{ #category : #websockets }
WebClient class >> webSocket07: serverUrl protocol: protocol [
	"Attempt to connect to the given server url using the WebSocket api"
	"http://tools.ietf.org/html/draft-ietf-hybi-thewebsocketprotocol-07"

	| hash client req resp nonce |
	nonce := ByteArray new: 16.
	(1 to: nonce size) collect:[:i| nonce at: i put: (256 atRandom - 1)].
	nonce := nonce base64Encoded.

	client := self new.
	client initializeFromUrl: serverUrl.
	req := client requestWithUrl: serverUrl.
	req method: 'GET'.
	req headerAt: 'Upgrade' put: 'WebSocket'.
	req headerAt: 'Connection' put: 'Upgrade'.
	req headerAt: 'Sec-WebSocket-Origin' put: 'null'.
	protocol ifNotNil:[req headerAt: 'Sec-WebSocket-Protocol' put: protocol].
	req headerAt: 'Sec-WebSocket-Key' put: nonce.
	req headerAt: 'Sec-WebSocket-Version' put: '7'.

	resp := client sendRequest: req.
	resp code = 101 ifFalse:[client close. ^nil].

	"Verify WebSocket hash"
	hash := WebUtils webSocketHash07: nonce.
	hash = (resp headerAt: 'Sec-WebSocket-Accept') ifFalse:[client close. ^nil].

	"Close of stream is left to caller"
	^WebSocket07 on: resp stream.

]

{ #category : #websockets }
WebClient class >> webSocket68: serverUrl protocol: protocol [
	"Attempt to connect to the given server url using the WebSocket api"

	| client req resp |
	client := self new.
	client initializeFromUrl: serverUrl.
	req := client requestWithUrl: serverUrl.
	req method: 'GET'.
	req headerAt: 'Upgrade' put: 'WebSocket'.
	req headerAt: 'Connection' put: 'Upgrade'.
	req headerAt: 'Origin' put: 'null'.
	protocol ifNotNil:[req headerAt: 'WebSocket-Protocol' put: protocol].
	resp := client sendRequest: req.
	resp code = 101 ifFalse:[client close. ^nil].

	"Close of stream is left to caller"
	^WebSocket00 on: resp stream.

]

{ #category : #websockets }
WebClient class >> webSocketTo: serverUrl [
	"Attempt to connect to the given server url using the WebSocket api"

	"Testing:

		1) Launch WebSocket example.
		2) Run the following code:
		
		| ws |
		ws := WebClient webSocketTo: 'http://localhost:8080/broadcast'.
		ws onMessage:[:data| Transcript cr; show: data].
		ws fork.
		ws send: 'This is the first message'.
		ws send: 'This is the last message'.
		ws close.

	"

	^self webSocketTo: serverUrl protocol: nil
]

{ #category : #websockets }
WebClient class >> webSocketTo: serverUrl protocol: protocol [
	"Attempt to connect to the given server url using the WebSocket api"

	^self webSocket00: serverUrl protocol: protocol
]

{ #category : #cookies }
WebClient >> acceptCookie: aCookie host: reqHost path: path [
	"Accept a cookie from a prior response"

	self acceptCookies ifTrue:[
		"Set the defaults per RFC 2109 section 4.3.1 "
	
		"Ensure the cookie domain is set"
		aCookie domain ifNil:[aCookie domain: reqHost].

		"Ensure the cookie path is set"
		aCookie path ifNil:[aCookie path: path].

		"Reject the cookie per RFC 2109 section 4.3.2"
		(path beginsWith: aCookie path) ifFalse:[^false].

		aCookie domain = reqHost ifFalse:[ | domain |
			domain := aCookie domain.
			"For misconfigured servers, insert the leading dot into the domain"
			domain first = $. ifFalse:[aCookie domain: (domain := '.', domain)].
			((domain count:[:ch| ch = $.]) >= 2) ifFalse:[^false].
			(reqHost endsWith: domain) ifFalse:[^false].
			((reqHost allButLast: domain size) includes: $.) ifTrue:[^false].
		].
	
		"Remove any old cookies"
		cookies := cookies reject:[:any| any = aCookie].
		
		"Remember the cookie if not expired"
		(aCookie expiry == nil or:[aCookie expiry > DateAndTime now])  ifTrue:[
			cookies add: aCookie.
			^true
		].
	].
	^false
]

{ #category : #cookies }
WebClient >> acceptCookies [
	"Whether we should accept cookies"

	^flags anyMask: FlagAcceptCookies
]

{ #category : #cookies }
WebClient >> acceptCookies: aBool [
	"Whether we should accept cookies"

	flags := aBool ifTrue:[flags bitOr: FlagAcceptCookies] ifFalse:[flags bitClear: FlagAcceptCookies].

]

{ #category : #accessing }
WebClient >> accessLog [
	"The standard access log. Can be either a stream or a string; if the access log
	is a string then the string is assumed to be a file name and the file will be opened 
	and closed for each request."

	^accessLog
]

{ #category : #accessing }
WebClient >> accessLog: aStreamOrFilename [
	"The standard access log. Can be either a stream or a string; if the access log
	is a string then the string is assumed to be a file name and the file will be opened 
	and closed for each request."

	accessLog := aStreamOrFilename
]

{ #category : #accessing }
WebClient >> allowAuth [
	"If true, WebClient will attempt to handle authorization requests"

	^flags anyMask: FlagAllowAuth
]

{ #category : #accessing }
WebClient >> allowAuth: aBool [
	"If true, WebClient will attempt to handle authorization requests"

	flags := aBool ifTrue:[flags bitOr: FlagAllowAuth] ifFalse:[flags bitClear: FlagAllowAuth].

]

{ #category : #accessing }
WebClient >> allowRedirect [
	"If true, WebClient will attempt to handle redirect responses"

	^flags anyMask: FlagAllowRedirect
]

{ #category : #accessing }
WebClient >> allowRedirect: aBool [
	"If true, WebClient will attempt to handle redirect responses"

	flags := aBool ifTrue:[flags bitOr: FlagAllowRedirect] ifFalse:[flags bitClear: FlagAllowRedirect].

]

{ #category : #authentication }
WebClient >> authDispatch: request from: response header: authHeader params: params [
	"Dispatch on an authentication method. 
	Subclasses can extend this method to support more auth methods."

	(authHeader copyUpTo: Character space) caseOf: {
		['Basic'] -> [self basicAuth: request from: response 
							header: authHeader params: params].
		['Digest'] -> [self digestAuth: request from: response 
							header: authHeader  params: params].
		['Bearer'] -> [self bearerAuth: request from: response 
							header: authHeader params: params].
	} otherwise:["ignore"].

]

{ #category : #accessing }
WebClient >> authParams [
	"The authentication parameters"

	^authParams
]

{ #category : #accessing }
WebClient >> authParams: aDictionary [
	"The authentication parameters"

	authParams := aDictionary
]

{ #category : #sending }
WebClient >> authenticate: request from: response [
	"Authenticate after having received a 401/407 response.
	Returns true if we should retry, false if we fail here."

	"NOTE: The first time through we do NOT ask for credentials right away.
	Some authentication mechanisms (NTLM/Negotiate) can use the credentials
	of the currently logged on user. Consequently we only ask for credentials
	if we're unable to do so without asking. Methods that require credentials
	(basic, digest) test for their existence explicitly."

	| headers authHeader params |

	"Pick the right set of parameters"
	response code = 401 ifTrue:[
		params := authParams.
		headers := response headersAt: 'WWW-Authenticate'.
		"If the connection was closed, we need to flush the
		proxy params or we won't pick up prior credentials."
		self isConnected 
			ifFalse:[self flushAuthState: proxyParams].
	] ifFalse:[
		params := proxyParams.
		headers := response headersAt: 'Proxy-Authenticate'.
	].

	"Remove any old response"
	params removeKey: #authResponse ifAbsent:[].

	"Process the authentication header(s)"
	1 to: headers size do:[:i|
		authHeader := headers at: i.
		self authDispatch: request from: response header: authHeader params: params.
		"If we generated an authentication response for the header use it"
		params at: #authResponse ifPresent:[:resp|
			request headerAt: (response code = 401 
								ifTrue:['Authorization'] 
								ifFalse:['Proxy-Authorization'])
					put: (params at: #authMethod), ' ', resp.
			^true].
	].

	"If we fall through here this can have two reasons: One is that we don't have
	a suitable authentication method. Check for that first."
	params at: #authMethod ifAbsent:[^false].

	"The other possibility is that the credentials are wrong. 
	Clean out the previous auth state and go ask for credentials."
	self flushAuthState: params.

	"Clean out old authentication headers"
	response code = 401 
		ifTrue:[request removeHeader: 'Authorization'].
	"Always clean out the proxy auth header since we don't support pre-authentication"
	request removeHeader: 'Proxy-Authorization'.

	"Signal WebAuthRequired"
	(WebAuthRequired client: self request: request response: response)
		signal == true ifFalse:[^false].

	"And retry with the new credentials"
	^self authenticate: request from: response
]

{ #category : #authentication }
WebClient >> basicAuth: request from: response header: header params: params [
	"Provide basic authentication for the request"

	| user pass args |
	authParams at: #authMethod ifPresent:[:method| ^self]. "do not retry repeatedly"
	authParams at: #authMethod put: 'Basic'.

	args := WebUtils parseAuthParams: header.
	args at: 'realm' ifPresent:[:realm| authParams at: #authRealm put: realm].
	
	user := (params at: #username ifAbsent:[nil]) ifNil:[^self].
	pass := (params at: #password ifAbsent:[nil]) ifNil:[^self].
	authParams at: #authResponse put:  (user, ':', pass value) base64Encoded.

]

{ #category : #authentication }
WebClient >> bearerAuth: request from: response header: header params: params [
	"Provide token-based OAuth2 authentication for the request"

	| token args |
	authParams at: #authMethod ifPresent:[:method| ^self]. "do not retry repeatedly"
	authParams at: #authMethod put: 'Bearer'.

	args := WebUtils parseAuthParams: header.
	args at: 'realm' ifPresent:[:realm| authParams at: #authRealm put: realm].

	token := (params at: #token ifAbsent:[nil]) ifNil:[^self].
	authParams at: #authResponse put: token.

]

{ #category : #testing }
WebClient >> canVerify [

	^ (stream respondsTo: #canVerify)
		ifTrue: [stream canVerify]
		ifFalse: [WebUtils platformName ~= 'Mac OS']
]

{ #category : #initialize }
WebClient >> close [
	"Close the client's stream"

	stream ifNotNil:[
		stream isConnected ifTrue: [stream close].
		stream := nil].

]

{ #category : #initialize }
WebClient >> connect [
	"Connect the client to a web server. Returns nil if successful,
	a WebResponse if a proxy CONNECT request fails."

	| actualServer actualPort |

	"Determine which server to connect to (proxy or real)"
	proxyServer ifNil:[
		actualServer := self serverName.
		actualPort := self serverPort.
	] ifNotNil:[
		actualServer := self proxyServerName.
		actualPort := self proxyServerPort.
	].

	"Check if we can use the same stream or if we need to reconnect"
	(stream notNil
		and:[stream isConnected
		and:[lastServer = actualServer
		and:[lastPort = actualPort
		and:[lastScheme = scheme]]]]) ifTrue:[^nil].

	self close.
	lastServer := actualServer.
	lastPort := actualPort.
	lastScheme := scheme.
	stream := SocketStream openConnectionToHostNamed: lastServer port: lastPort.
	stream timeout: timeout.
	"Perform ssl initialization if necessary"
	scheme = 'https' ifTrue:[^self sslConnect].
	^nil
]

{ #category : #initialize }
WebClient >> contentDecoders [

	| result |
	result := nil.
	(self class environment hasBindingOf: #GZipReadStream)
		ifTrue: [result := 'gzip'].
	(self class environment hasBindingOf: #BrotliReadStream)
		ifTrue: [	result := result ifNil: ['br'] ifNotNil: [:r | r, ', br']].
	^ result
]

{ #category : #accessing }
WebClient >> cookies [
	"The cookies that have been set for this session"

	^cookies
]

{ #category : #accessing }
WebClient >> cookies: aCollection [
	"The cookies that have been set for this session"

	cookies := aCollection.
]

{ #category : #accessing }
WebClient >> debugLog [
	"If provided, WebClient will print all requests and responses to the debugLog,
	except from the content of the message. The debug log must be a stream of
	some sort; file names (like for the accessLog are not supported)."

	^debugLog
]

{ #category : #accessing }
WebClient >> debugLog: aStream [
	"If provided, WebClient will print all requests and responses to the debugLog,
	except from the content of the message. The debug log must be a stream of
	some sort; file names (like for the accessLog are not supported)."

	debugLog := aStream
]

{ #category : #initialize }
WebClient >> defaultPort [
	"Return the default port to use if no port was specified.
	Since we only support https and http, default to port 80 unless https."

	^scheme = 'https' 
		ifTrue:[443]
		ifFalse:[80]
]

{ #category : #initialize }
WebClient >> defaultUserAgent [
	"Answer the default User-Agent string to use for WebClient"

	^'WebClient/1.5 (', 
		WebUtils mcVersion, '; ', 
		SystemVersion current version,'-', 
		SystemVersion current highestUpdate printString, '; ', 
		WebUtils platformName,')'.

]

{ #category : #initialize }
WebClient >> destroy [
	"Destroys the client"

	stream ifNotNil:[
		stream destroy.
		stream := nil.
	].

]

{ #category : #initialize }
WebClient >> detectProxyServer [
	"Automatically detect the proxy server to use"

	proxyServer := ProxyHandler proxyServerFor: self server.

]

{ #category : #authentication }
WebClient >> digestAuth: request from: response header: authHeader params: params [
	"Perform digest authentication"

	| realm nonce ha1 ha2 nc cnonce qop header uri md5 key args user pass |
	params at: #authMethod ifPresent:[:method| ^self]. "do not retry repeatedly"
	params at: #authMethod put: 'Digest'.

	args := WebUtils parseAuthParams: authHeader.
	realm := args at: 'realm'.
	authParams at: #authRealm put: realm.

	user := (params at: #username ifAbsent:[nil]) ifNil:[^self].
	pass := (params at: #password ifAbsent:[nil]) ifNil:[^self].

	nonce := args at: 'nonce'.
	uri := request rawUrl.

	"VERY IMPORTANT NOTE: Some servers fail horribly if the nonce count
	isn't precisely eight digits and without quotes."
	nc := args at: 'nc' put: (args at: 'nc' ifAbsent:[0]) + 1.
	nc := nc asString padded: #left to: 8 with: $0.
	
	key := user, ':', realm, ':', pass value.
	ha1 := WebUtils md5Digest: key.
	ha2 := WebUtils md5Digest: request method, ':', uri.
	cnonce := UUID new hex.

	(args includesKey: 'qop') ifTrue:["use qop"
		qop := 'auth'. "the only qop we support"
		md5 := WebUtils md5Digest: ha1, ':', nonce, ':', nc, ':', cnonce, ':', qop, ':', ha2.
		header :=
			'username="', user, '"',
			', realm="', realm, '"',
			', nonce="', nonce, '"',
			', uri="', uri, '"',
			', response="', md5, '"',
			', qop="', qop,'"',
			', nc="', nc, '"',
			', cnonce="', cnonce, '"'.
	] ifFalse:["ignore qop"
		md5 := WebUtils md5Digest: ha1, ':', nonce, ':', ha2.
		header :=
			'username="', user, '"',
			', realm="', realm, '"',
			', nonce="', nonce, '"',
			', uri="', uri, '"',
			', response="', md5, '"'.
	].
	args at: 'opaque' ifPresent: [:opaque | 
		header := header, ', opaque="', opaque, '"'
	].
	params at: #authResponse put: header.
]

{ #category : #initialize }
WebClient >> flushAuthState [
	"Flush all the auth state"

	self flushAuthState: authParams.
	self flushAuthState: proxyParams.
]

{ #category : #authentication }
WebClient >> flushAuthState: params [
	"Fliush authentication state that should not been preserved 
	inbetween failed attempts to authenticate. 
	Subclasses can extend this method to support more auth methods."

	params removeKey: #authMethod ifAbsent:[].

]

{ #category : #methods }
WebClient >> httpDelete: urlString [
	"Sends an DELETE request"

	^self httpDelete: urlString do:[:req]

]

{ #category : #methods }
WebClient >> httpDelete: urlString do: aBlock [
	"Sends a DELETE request"

	| request |
	self initializeFromUrl: urlString.
	request := self requestWithUrl: urlString.
	request method: 'DELETE'.
	userAgent ifNotNil:[request headerAt: 'User-Agent' put: userAgent].
	aBlock value: request.
	^self sendRequest: request.
]

{ #category : #methods }
WebClient >> httpGet: urlString [
	"GET the response from the given url"
	"(WebClient httpGet: 'http://www.squeak.org') content"

	^self httpGet: urlString do:[:req]

]

{ #category : #methods }
WebClient >> httpGet: urlString do: aBlock [
	"GET the response from the given url"
	"(WebClient httpGet: 'http://www.squeak.org') content"

	| request |
	self initializeFromUrl: urlString.
	request := self requestWithUrl: urlString.
	request method: 'GET'.
	userAgent ifNotNil:[:ua | request headerAt: 'User-Agent' put: ua].
	self contentDecoders ifNotNil: [:decoders | request headerAt: 'Accept-Encoding' put: decoders].
	aBlock value: request.
	^self sendRequest: request

]

{ #category : #methods }
WebClient >> httpHead: urlString [
	"Sends a HEAD request"

	^self httpHead: urlString do:[:req]

]

{ #category : #methods }
WebClient >> httpHead: urlString do: aBlock [
	"Sends a HEAD request"

	| request |
	self initializeFromUrl: urlString.
	request := self requestWithUrl: urlString.
	request method: 'HEAD'.
	userAgent ifNotNil:[request headerAt: 'User-Agent' put: userAgent].
	aBlock value: request.
	^self sendRequest: request.
]

{ #category : #methods }
WebClient >> httpOptions: urlString [
	"Sends an OPTIONS request"

	^self httpOptions: urlString do:[:req]

]

{ #category : #methods }
WebClient >> httpOptions: urlString do: aBlock [
	"Sends an OPTIONS request"

	| request |
	self initializeFromUrl: urlString.
	request := self requestWithUrl: urlString.
	request method: 'OPTIONS'.
	userAgent ifNotNil:[request headerAt: 'User-Agent' put: userAgent].
	aBlock value: request.
	^self sendRequest: request

]

{ #category : #methods }
WebClient >> httpPost: urlString content: postData type: contentType [
	"POST the data to the given url"

	^self httpPost: urlString content: postData type: contentType do:[:req]
]

{ #category : #methods }
WebClient >> httpPost: urlString content: postData type: contentType do: aBlock [
	"POST the data to the given url"

	| request |
	self initializeFromUrl: urlString.
	request := self requestWithUrl: urlString.
	request method: 'POST'.
	contentType ifNotNil:[request contentType: contentType].
	request contentLength: postData size.
	userAgent ifNotNil:[request headerAt: 'User-Agent' put: userAgent].
	aBlock value: request.
	^self sendRequest: request content: postData readStream size: postData size
]

{ #category : #methods }
WebClient >> httpPostChunked: urlString content: chunkBlock type: contentType [
	"POST the data to the given url using chunked transfer-encoding.
	The chunkBlock takes a request and can be fed using #nextChunkPut:
	until all the data has been sent.

	Chunked encoding can be used for long-lasting connections to a server,
	but care must be taken to ensure that the client isn't running afoul of
	the server expecting to read the full response (i.e., you should use this
	only if you have control over both ends).

	However, it is a great way to send output from commands that take awhile
	and other time-consuming operations if authentication has been handled."

	^self httpPostChunked: urlString content: chunkBlock type: contentType do: [:req]
]

{ #category : #methods }
WebClient >> httpPostChunked: urlString content: chunkBlock type: contentType do: aBlock [
	"POST the data to the given url using chunked transfer-encoding. 
	The chunkBlock takes a request and can be fed using #nextChunkPut:
	until all the data has been sent. 

	Chunked encoding can be used for long-lasting connections to a server,
	but care must be taken to ensure that the client isn't running afoul of
	the server expecting to read the full response (i.e., you should use this
	only if you have control over both ends).

	However, it is a great way to send output from commands that take awhile
	and other time-consuming operations if authentication has been handled."

	| request |
	self initializeFromUrl: urlString.
	request := self requestWithUrl: urlString.
	request method: 'POST'.
	contentType ifNotNil:[request contentType: contentType].
	request headerAt: 'Transfer-Encoding' put: 'chunked'.
	userAgent ifNotNil:[request headerAt: 'User-Agent' put: userAgent].
	aBlock value: request.
	"Send the chunked data"
	^self sendRequest: request contentBlock:[:aStream| 
		"Set the stream in the request and pass it in the chunk block"
		request stream: aStream.
		chunkBlock value: request.
		"send termination chunk"
		aStream nextPutAll: '0'; crlf; crlf; flush.
	].

]

{ #category : #methods }
WebClient >> httpPut: urlString content: postData type: contentType [
	"PUT the data to the given url"

	^self httpPut: urlString content: postData type: contentType do:[:req]
]

{ #category : #methods }
WebClient >> httpPut: urlString content: postData type: contentType do: aBlock [
	"PUT the data to the given url"

	| request |
	self initializeFromUrl: urlString.
	request := self requestWithUrl: urlString.
	request method: 'PUT'.
	contentType ifNotNil:[request contentType: contentType].
	request contentLength: postData size.
	userAgent ifNotNil:[request headerAt: 'User-Agent' put: userAgent].
	aBlock value: request.
	^self sendRequest: request content: postData readStream size: postData size
]

{ #category : #methods }
WebClient >> httpTrace: urlString [
	"Sends a TRACE request"

	^self httpTrace: urlString do:[:req]

]

{ #category : #methods }
WebClient >> httpTrace: urlString do: aBlock [
	"Sends a TRACE request"

	| request |
	self initializeFromUrl: urlString.
	request := self requestWithUrl: urlString.
	request method: 'TRACE'.
	userAgent ifNotNil:[request headerAt: 'User-Agent' put: userAgent].
	aBlock value: request.
	^self sendRequest: request

]

{ #category : #initialize }
WebClient >> initialize [
	"Initializes the receiver"
	flags := 0.
	super initialize.

	self allowAuth: true.
	self allowRedirect: true.
	self acceptCookies: true.

	timeout := Socket standardTimeout.
	cookies := OrderedCollection new.
	redirections := Dictionary new.
	maxRedirect := 10.
	userAgent := self defaultUserAgent.
	authParams := IdentityDictionary new.
	proxyParams := IdentityDictionary new.

	"Use the default debug log"
	debugLog := DebugLog.

]

{ #category : #initialize }
WebClient >> initializeFromUrl: urlString [
	"Initialize the client from a url string"

	| urlStream serverAndPort userAndPass |
	urlStream := urlString readStream.
	scheme := (urlStream upToAll: '://') asLowercase.
	(scheme = 'http' or:[scheme = 'https'])
		ifFalse:[self error: 'Unsupported scheme: ', scheme].
	serverAndPort := urlStream upTo: $/.

	userAndPass := serverAndPort copyUpTo: $@.
	userAndPass = serverAndPort ifFalse:[
		serverAndPort := serverAndPort copyAfter: $@.
		self username: (userAndPass copyUpTo: $:).
		self password: (userAndPass copyAfter: $:).
	].

	self server: serverAndPort.
	self detectProxyServer.
]

{ #category : #testing }
WebClient >> isConnected [
	"Returns true if the client is still connected"

	^stream notNil and:[stream isConnected]
]

{ #category : #accessing }
WebClient >> maxRedirect [
	"The max. number of redirects we allow for the SAME SITE before giving up.
	Redirects can happen for any number of reasons between any number of sites
	and we give up if we have seen the SAME SITE maxRedirect number of times."

	^maxRedirect
]

{ #category : #accessing }
WebClient >> maxRedirect: aNumber [
	"The max. number of redirects we allow for the SAME SITE before giving up.
	Redirects can happen for any number of reasons between any number of sites
	and we give up if we have seen the SAME SITE maxRedirect number of times."

	maxRedirect := aNumber
]

{ #category : #initialize }
WebClient >> newRequest [
	"Create an return a new WebRequest.
	Subclasses can use this method to override the default request class."

	^WebRequest new
]

{ #category : #accessing }
WebClient >> password [
	"The password for remote authentication.
	The password should generally not be a plain-text
	version but rather a block that can retrieve the password
	when required."

	^authParams at: #password ifAbsent:[nil]
]

{ #category : #accessing }
WebClient >> password: aStringOrValuable [
	"The password for remote authentication.
	The password should generally not be a plain-text
	version but rather a block that can retrieve the password
	when required."

	^authParams at: #password put: aStringOrValuable
]

{ #category : #printing }
WebClient >> printOn: aStream [
	"Print the receiver on aStream"

	aStream nextPutAll: self class name.
	aStream nextPut: $(.
	(stream notNil and:[stream isConnected]) ifTrue:[
		aStream nextPutAll: 'Connected: '.
	].
	scheme ifNotNil:[aStream nextPutAll: scheme, '://'].
	server ifNotNil:[aStream nextPutAll: server].
	aStream nextPut:$).

]

{ #category : #initialize }
WebClient >> proxyConnect [
	"Send a proxy CONNECT request to connect to a remote host via the chosen proxy server"

	| uri request repeatAuth response |
	uri := self serverUrlName,':', self serverPort.
	request := self newRequest.
	request method: 'CONNECT'.
	request rawUrl: uri.

	[repeatAuth := false.

	"The proxy response may use Connection: Close; reconnect when that happens"
	self isConnected ifFalse:[
		stream := SocketStream openConnectionToHostNamed: lastServer port: lastPort.
		stream timeout: timeout.
	].

	debugLog ifNotNil:[
		request writeOn: debugLog.
		debugLog flush.
	].

	"Don't use 'self writeRequestOn:' since this will insert both cookies
	as well as modify the url target when a proxy is present"
	request writeOn: stream.
	stream flush.

	response := request newResponse readFrom: stream.

	debugLog ifNotNil:[
		response writeOn: debugLog.
		debugLog flush.
	].

	"Handle authentication if needed"
	(self allowAuth and:[response code = 407]) ifTrue:[
		"Eat up the content of the previous response"
		response content.
		repeatAuth := self authenticate: request from: response.
	].
	repeatAuth] whileTrue.

	^response
]

{ #category : #proxy }
WebClient >> proxyParams [
	"The proxy authentication parameters"

	^proxyParams
]

{ #category : #proxy }
WebClient >> proxyParams: aDictionary [
	"The proxy authentication parameters"

	proxyParams := aDictionary
]

{ #category : #proxy }
WebClient >> proxyPass [
	"The password for an authenticating proxy.
	The password should generally not be a plain-text
	version but rather a block that can retrieve the password
	when required."

	^proxyParams at: #password
]

{ #category : #proxy }
WebClient >> proxyPass: aStringOrValuable [
	"The password for an authenticating proxy.
	The password should generally not be a plain-text
	version but rather a block that can retrieve the password
	when required."

	proxyParams at: #password put: aStringOrValuable
]

{ #category : #proxy }
WebClient >> proxyServer [
	"The proxy server to use for connections.
	The server should be specified as server:port if the proxy
	port to be used is different from the desitation port."

	^proxyServer
]

{ #category : #proxy }
WebClient >> proxyServer: aString [
	"The proxy server to use for connections.
	The server should be specified as server:port if the proxy
	port to be used is different from the desitation port."

	proxyServer := aString
]

{ #category : #proxy }
WebClient >> proxyServerName [
	"Returns the name part of the server:port description"

	^proxyServer copyUpTo: $:
]

{ #category : #proxy }
WebClient >> proxyServerPort [
	"Returns the port of the proxyServer:port description"

	^(proxyServer copyAfter: $:) 
		ifEmpty:[self serverPort]
		ifNotEmpty:[:portString| portString asInteger].

]

{ #category : #proxy }
WebClient >> proxyUser [
	"The user name for an authenticating proxy"

	^proxyParams at: #username ifAbsent:[nil]
]

{ #category : #proxy }
WebClient >> proxyUser: aString [
	"The user name for an authenticating proxy"

	proxyParams at: #username put: aString
]

{ #category : #sending }
WebClient >> redirect: request from: response [
	"Handle a 3xx redirect response"

	| location max |
	
	"Check if we handle the specific type of redirect here"
	(#(	301 
		302 "Found" 
		303 "See Other" 
		307 "Temporary Redirect")
			includes: response code) ifFalse:[^false].

	"RFC 2616 states that requests other than HEAD and GET MUST NOT be auto
	redirected for 302 and 307 responses"
	(request method = 'GET' or:[request method = 'HEAD']) ifFalse:[
		(response code = 302 or:[response code = 307]) ifTrue:[^false].
	].

	"Find the new location"
	location := response headerAt: 'location'.

	"Check if we've exceeded max redirections"
	max := redirections at: location ifAbsent:[0].
	max > self maxRedirect ifTrue:[^false].
	redirections at: location put: max+1.

	"Do the actual redirect, i.e., set us up for the new url"
	(location findString: '://') > 0 "do we have a scheme:// url?"
		ifTrue:[self initializeFromUrl: location].

	request initializeFromUrl: location.

	^true
]

{ #category : #initialize }
WebClient >> requestWithUrl: urlString [
	"Create and return a new WebRequest initialized with the given url."

	^self  newRequest initializeFromUrl: urlString
]

{ #category : #accessing }
WebClient >> scheme [
	"The scheme used for the request (usually http or https)"

	^scheme
]

{ #category : #accessing }
WebClient >> scheme: aString [
	"The scheme used for the request (usually http or https)"

	scheme := aString
]

{ #category : #sending }
WebClient >> sendRequest: request [
	"Send an http request"

	^self sendRequest: request content: nil size: 0
]

{ #category : #sending }
WebClient >> sendRequest: request content: contentStream size: streamSize [
	"Send an http request"

	^self sendRequest: request contentBlock:[:aStream|
		contentStream ifNotNil:[
			"Upload content if provided"
			contentStream position: 0.
			request streamFrom: contentStream to: aStream size: streamSize 
				progress:[:total :amount|
					(HTTPProgress new) 
						total: total; 
						amount: amount;
						signal: 'Uploading...']]].

]

{ #category : #sending }
WebClient >> sendRequest: request contentBlock: contentBlock [
	"Send an http request"

	|  response repeatRedirect repeatAuth |

	"XXXX: Fixme. Pre-authenticate the request if we have valid auth credentials"

	redirections := Dictionary new.
	
	["The outer loop handles redirections"
	repeatRedirect := false.

	"Always update the host header due to redirect"
	request headerAt: 'Host' put: server.

		["The inner loop handles authentication"
		repeatAuth := false.

		"Connect can fail if SSL proxy CONNECT is involved"
		self connect ifNotNil:[:resp| ^resp].
		
		"Write the request to the debugLog if present"
		debugLog ifNotNil:[self writeRequest: request on: debugLog].

		"Send the request itself"
		self writeRequest: request on: stream.
		contentBlock value: stream.

		response := request newResponse readFrom: stream.
		response url: (scheme, '://', server, request rawUrl).

		debugLog ifNotNil:[
			response writeOn: debugLog.
			debugLog flush.
		].
		response setCookiesDo:[:cookie| 
			self acceptCookie: cookie host: self serverUrlName path: request url.
		].
		accessLog ifNotNil:[
			WebUtils logRequest: request response: response on: accessLog
		].
		"Handle authentication if needed"
		(self allowAuth and:[response code = 401 or:[response code = 407]]) ifTrue:[
			"Eat up the content of the previous response"
			response content.
			repeatAuth := self authenticate: request from: response.
		].

		repeatAuth] whileTrue.

	"Flush previous authState.
	XXXX: Fixme. authState must be preserved for pre-authentication of requests."
	self flushAuthState.

	"Handle redirect if needed"
	(self allowRedirect and:[response isRedirect]) ifTrue:[
		"Eat up the content of the previous response"
		response content.
		repeatRedirect := self redirect: request from: response.
	].
	repeatRedirect] whileTrue:[
		"When redirecting, remove authentication headers"
		request removeHeader: 'Authorization'.
		request removeHeader: 'Proxy-Authorization'.
	].

	"If the response is not a success, eat up its content"
	(response isSuccess or:[response isInformational]) ifFalse:[response content].

	^response
]

{ #category : #accessing }
WebClient >> server [
	"The server to use for connections.
	The server is specified as server:port if needed"

	^server
]

{ #category : #accessing }
WebClient >> server: aString [
	"The server to use for connections.
	The server should be specified as server:port if needed"

	server := aString

]

{ #category : #accessing }
WebClient >> serverName [
	"Returns the name part of the server:port description"
	
	| serverUrlName |
	serverUrlName := self serverUrlName.
	^ (serverUrlName includes: $[)
		ifTrue: [serverUrlName copyFrom: 2 to: serverUrlName size - 1]
		ifFalse: [serverUrlName]
]

{ #category : #accessing }
WebClient >> serverPort [
	"Returns the port of the server:port description"

	(self server copyAfterLast: $:) 
		ifNotEmpty:[:portString| 
			portString isAllDigits
				ifTrue: [^ portString asInteger]].
	^ self defaultPort
]

{ #category : #accessing }
WebClient >> serverUrlName [
	"Returns the name part of the server:port description in the way it would appear in an Url"

	^ (self server includes: $[)
		ifTrue: [self server copyUpThrough: $] ]
		ifFalse: [self server copyUpToLast: $:]
]

{ #category : #initialize }
WebClient >> sslConnect [
	"Do the SSL handshake"
	"Connect the client to a web server"

	| sqSSL |
	proxyServer ifNotNil:[ | resp |
		"If we have a proxy server, do the proxy connect"
		resp := self proxyConnect.
		resp isSuccess ifFalse:[^resp].
	].

	sqSSL := Smalltalk at: #SqueakSSL ifAbsent:[self error: 'SqueakSSL is missing'].
	"Convert the stream to a secure stream"
	stream := sqSSL secureSocketStream on: stream socket.
	stream timeout: timeout.
	self sslConnect: stream to: self serverName.
	"And cert verification"
	self canVerify
		ifTrue: [stream verifyCert: self serverName].
	^ nil"indicating success"

]

{ #category : #initialize }
WebClient >> sslConnect: stream to: lastServer [
	"Do the SSL handshake, use SNI if available"
	(stream respondsTo: #sslConnectTo:)
		ifTrue: [stream sslConnectTo: lastServer]
		ifFalse: [stream sslConnect].
]

{ #category : #accessing }
WebClient >> timeout [
	"Timeout for the http operations"

	^timeout
]

{ #category : #accessing }
WebClient >> timeout: aNumber [
	"Timeout for the http operations"

	timeout := aNumber
]

{ #category : #accessing }
WebClient >> token [
	"The token for remote OAuth2 authentication"

	^authParams at: #token ifAbsent:[nil]
]

{ #category : #accessing }
WebClient >> token: aString [
	"The token for remote OAuth2 authentication"

	authParams at: #token put: aString
]

{ #category : #accessing }
WebClient >> userAgent [
	"The User-Agent string sent to the server"

	^userAgent
]

{ #category : #accessing }
WebClient >> userAgent: aString [
	"The User-Agent string sent to the server. 
	If no user agent should be sent, this value can be set to nil"

	userAgent := aString
]

{ #category : #accessing }
WebClient >> username [
	"The username for remote authentication"

	^authParams at: #username ifAbsent:[nil]
]

{ #category : #accessing }
WebClient >> username: aString [
	"The username for remote authentication"

	authParams at: #username put: aString
]

{ #category : #sending }
WebClient >> writeCookiesFor: request on: stream [
	"Write the cookies for a particular request"

	(cookies select:[:ck| (request acceptsCookie: ck from: self )]) ifNotEmpty:[:ckset|
		stream nextPutAll: 'Cookie: '.
		ckset 
			do:[:ck| stream nextPutAll: ck name,'=', ck value]
			separatedBy:[stream  nextPutAll:'; '].
		stream crlf.
	].

]

{ #category : #sending }
WebClient >> writeHeadersFor: request on: aStream [
	"Write all the headers for the given request on aStream"

	request headersDo:[:key :value| aStream nextPutAll: key, ': ', value asString; crlf].

]

{ #category : #sending }
WebClient >> writeRequest: request on: aStream [
	"Write all the request headers on the given stream"

	self writeRequestLine: request on: aStream.
	self writeHeadersFor: request on: aStream.
	self writeCookiesFor: request on: aStream.
	aStream crlf.
	aStream flush.
]

{ #category : #sending }
WebClient >> writeRequestLine: request on: aStream [
	"Write the HTTP request line on the given stream"

	aStream nextPutAll: request method; space.

	"https proxy support is transparent via CONNECT"
	(proxyServer notNil and:[scheme ~= 'https']) ifTrue:[
		"http://www.ietf.org/rfc/rfc2616.txt 
		5.1.2 Request-URI:
			...
		The absoluteURI form is REQUIRED when the request is being made to a
		proxy. The proxy is requested to forward the request or service it
		from a valid cache, and return the response. Note that the proxy MAY
		forward the request on to another proxy or directly to the server"
		aStream nextPutAll: scheme, '://', self server.

		"XXXX: This is a hack. Indicate that we want the proxy connection 
		to be persistent. This should NOT be necessary; the proxy should
		know that from the HTTP/1.1 request but apparently, squid will fail 
		NTLM and Negotiate authentication unless explicitly instructed to 
		keep the proxy connection alive."
		request headerAt: 'Proxy-Connection' put: 'keep-alive'.
	].

	aStream nextPutAll: request rawUrl; space; nextPutAll: request protocol; crlf.
]
