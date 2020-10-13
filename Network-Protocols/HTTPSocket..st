"
HTTPSockets is a facade for handling common HTTP requests. It provides a minimal implementation of the HTTP protocol, but can be extended by third party clients that register themselves as #httpRequestHandler (see class-side protocol).

A third-party request handler needs to implement the single method

	#httpRequest:url:headers:content:response:

in a way that is compatible with the baseline implementation in HTTPSocket.

"
Class {
	#name : #HTTPSocket,
	#superclass : #Object,
	#classVars : [
		'HTTPBlabEmail',
		'HTTPPort',
		'HTTPProxyCredentials',
		'HTTPProxyExceptions',
		'HTTPProxyPort',
		'HTTPProxyServer',
		'HTTPRequestHandler'
	],
	#category : #'Network-Protocols'
}

{ #category : #'proxy settings' }
HTTPSocket class >> addProxyException: domainName [
	"Add a (partial, wildcard) domain name to the list of proxy exceptions"
	"HTTPSocket addProxyException: '*.online.disney.com'"

	self httpProxyExceptions add: domainName
]

{ #category : #utilities }
HTTPSocket class >> argString: args [
	"Return the args in a long string, as encoded in a url"

	| argsString first |
	args isString ifTrue: ["sent in as a string, not a dictionary"
		^ (args first = $? ifTrue: [''] ifFalse: ['?']), args].
	argsString := WriteStream on: String new.
	argsString nextPut: $?.
	first := true.
	args associationsDo: [ :assoc |
		assoc value do: [ :value |
			first ifTrue: [ first := false ] ifFalse: [ argsString nextPut: $& ].
			argsString nextPutAll: assoc key encodeForHTTP.
			argsString nextPut: $=.
			argsString nextPutAll: value encodeForHTTP. ] ].
	^ argsString contents

]

{ #category : #'class initialization' }
HTTPSocket class >> blabEmail: aRequest [
	"Of the form 'From: me@isp.com <crlf>'"
	HTTPBlabEmail := aRequest
]

{ #category : #'class initialization' }
HTTPSocket class >> defaultPort [
	"default port to connect on"
	^80
]

{ #category : #'proxy settings' }
HTTPSocket class >> fetchExternalSettingsIn: aDirectory [
	"Scan for server configuration files"
	"HTTPSocket fetchExternalSettingsIn: (FileDirectory default directoryNamed: 'prefs')"

	| stream entries |
	(aDirectory fileExists: self proxySettingsFileName)
		ifFalse: [^self].
	stream := aDirectory readOnlyFileNamed: self proxySettingsFileName.
	stream
		ifNotNil: [
			[entries := ExternalSettings parseServerEntryArgsFrom: stream]
				ensure: [stream close]].

	entries ifNil: [^self].

	self httpProxyServer:  (entries at: 'host' ifAbsent: [nil]).
	self httpProxyPort: ((entries at: 'port' ifAbsent: ['80']) asInteger ifNil: [self defaultPort]).
	HTTPSocket addProxyException: (entries at: 'exception' ifAbsent: [nil])
]

{ #category : #'get the page' }
HTTPSocket class >> httpFileIn: url [
	"Do a regular file-in of a file that is served from a web site.  If the file contains an EToy, then open it.  Might just be code instead.  tk 7/23/97 17:10"
	"Notes: To store a file on an HTTP server, use the program 'Fetch'.  After indicating what file to store, choose 'Raw Data' from the popup menu that has MacBinary/Text/etc.  Use any file extension as long as it is not one of the common ones.  The server does not have to know about the .sqo extension in order to send your file.  (We do not need a new MIME type and .sqo does not have to be registered with the server.)"
	"	HTTPSocket httpFileIn: 'www.webPage.com/~kaehler2/sample.etoy'	 "
	"	HTTPSocket httpFileIn: '206.18.68.12/squeak/car.sqo'	 "
	"	HTTPSocket httpFileIn: 'jumbo/tedk/sample.etoy'	 "

	| doc eToyHolder |
	doc := self httpGet: url accept: 'application/octet-stream'.
	doc isString ifTrue:
			[self inform: 'Cannot seem to contact the web site'].
	doc reset.
	eToyHolder := doc fileInObjectAndCode.

	eToyHolder ifNotNil: [eToyHolder open].
	"Later may want to return it, instead of open it"

]

{ #category : #'get the page' }
HTTPSocket class >> httpFileInNewChangeSet: url [
	"Do a regular file-in of a file that is served from a web site.  Put it into a new changeSet."
	"Notes: To store a file on an HTTP server, use the program 'Fetch'.  After indicating what file to store, choose 'Raw Data' from the popup menu that has MacBinary/Text/etc.  Use any file extension as long as it is not one of the common ones."
	"	HTTPSocket httpFileInNewChangeSet: '206.18.68.12/squeak/updates/83tk:=test.cs'	 "

	| doc |
	doc := self httpGet: url accept: 'application/octet-stream'.
	doc isString ifTrue:
			[self inform: 'Cannot seem to contact the web site'].
	doc reset.
	ChangeSet newChangesFromStream: doc
				named: (url findTokens: '/') last.
]

{ #category : #'get the page' }
HTTPSocket class >> httpGet: url [
	"Return the exact contents of a web page or other web object. The parsed header is saved.  Use a proxy server if one has been registered.  tk 7/23/97 17:21"
	"	HTTPSocket httpShowPage: 'http://www.altavista.digital.com/index.html'	 "
	"	HTTPSocket httpShowPage: 'www.webPage.com/~kaehler2/ab.html'	 "
	"	HTTPSocket httpShowPage: 'www.exploratorium.edu/index.html'	 "
	"	HTTPSocket httpShowPage: 'www.apple.com/default.html'	 "
	"	HTTPSocket httpShowPage: 'www.altavista.digital.com/'	 "
	"	HTTPSocket httpShowPage: 'jumbo/tedk/ab.html'	 "

	^ self httpGet: url accept: '*/*'

]

{ #category : #'get the page' }
HTTPSocket class >> httpGet: url accept: mimeType [
	"Return the exact contents of a web object. Asks for the given MIME type. If mimeType is nil, use 'text/html'. The parsed header is saved. Use a proxy server if one has been registered.
	Note: To fetch raw data, you can use the MIME type 'application/octet-stream'.  To accept anything, use '*/*'."

	^self httpGet: url  args: nil accept: mimeType
]

{ #category : #'get the page' }
HTTPSocket class >> httpGet: url args: args accept: mimeType [

	^self httpGet: url args: args accept: mimeType request: ''
]

{ #category : #'get the page' }
HTTPSocket class >> httpGet: url args: args accept: mimeType request: requestString [
	"Return the exact contents of a web object. Asks for the given MIME type. If mimeType is nil, use 'text/html'. The parsed header is saved. Use a proxy server if one has been registered.  tk 7/23/97 17:12"
	"Note: To fetch raw data, you can use the MIME type 'application/octet-stream'."

	| document |
	document := self httpGetDocument: url  args: args  accept: mimeType request: requestString.
	(document isString) ifTrue: [
		"strings indicate errors"
		^ document ].

	^ (RWBinaryOrTextStream with: document content) reset

]

{ #category : #'get the page' }
HTTPSocket class >> httpGetDocument: url [
	"Return the exact contents of a web page or other web object. The parsed header is saved.  Use a proxy server if one has been registered.  tk 7/23/97 17:21"
	"	HTTPSocket httpShowPage: 'http://www.altavista.digital.com/index.html'	 "
	"	HTTPSocket httpShowPage: 'www.webPage.com/~kaehler2/ab.html'	 "
	"	HTTPSocket httpShowPage: 'www.exploratorium.edu/index.html'	 "
	"	HTTPSocket httpShowPage: 'www.apple.com/default.html'	 "
	"	HTTPSocket httpShowPage: 'www.altavista.digital.com/'	 "
	"	HTTPSocket httpShowPage: 'jumbo/tedk/ab.html'	 "

	^ self httpGetDocument: url args: nil accept: 'application/octet-stream' request: ''

]

{ #category : #'get the page' }
HTTPSocket class >> httpGetDocument: url accept: mimeType [
	"Return the exact contents of a web object. Asks for the given MIME type. If mimeType is nil, use 'text/html'. The parsed header is saved. Use a proxy server if one has been registered.  tk 7/23/97 17:12"
	^self httpGetDocument: url args: nil accept: mimeType request: ''
]

{ #category : #'get the page' }
HTTPSocket class >> httpGetDocument: url args: args [
	"Return the exact contents of a web object. Asks for the given MIME type. If mimeType is nil, use 'text/html'. The parsed header is saved. Use a proxy server if one has been registered.  tk 7/23/97 17:12"
	"Note: To fetch raw data, you can use the MIMI type 'application/octet-stream'."
	^self httpGetDocument: url args: args accept: 'application/octet-stream' request: ''
]

{ #category : #'get the page' }
HTTPSocket class >> httpGetDocument: url args: args accept: mimeType [
	"Return the exact contents of a web object. Asks for the given MIME type. If mimeType is nil, use 'text/html'. The parsed header is saved. Use a proxy server if one has been registered.  Note: To fetch raw data, you can use the MIME type 'application/octet-stream'."

	^ self httpGetDocument: url args: args accept: mimeType request: ''
]

{ #category : #'get the page' }
HTTPSocket class >> httpGetNoError: url args: args accept: mimeType [
	"Return the exact contents of a web file.  Do better error checking.  Asks for the given MIME type.  To fetch raw data, you can use the MIMI type 'application/octet-stream'.  If mimeType is nil, use 'text/html'.  The parsed header is saved. Use a proxy server if one has been registered."

"Edited to remove a lineFeed from the source 4/4/99 - di"

	| document data |
	document := self httpGetDocument: url  args: args  accept: mimeType.
	(document isString) ifTrue: [
		"strings indicate errors"
		^ document ].
	data := document content.
	(data beginsWith: '<HTML><HEAD>' , (String with: Character linefeed) , '<TITLE>4')
		ifTrue: ["an error message  404 File not found"
				^ data copyFrom: 21 to: data size-16].	

	^ (RWBinaryOrTextStream with: data) reset

]

{ #category : #'get the page' }
HTTPSocket class >> httpGif: url [
	"Fetch the given URL, parse it using the GIF reader, and return the resulting Form."
	"	HTTPSocket httpShowGif: 'www.altavista.digital.com/av/pix/default/av-adv.gif'	 "
	"	HTTPSocket httpShowGif: 'www.webPage.com/~kaehler2/ainslie.gif'	 "

	| doc ggg |
	doc := self httpGet: url accept: 'image/gif'.
	doc isString ifTrue: [
		self inform: 'The server with that GIF is not responding'.
		^ ColorForm extent: 20@20 depth: 8].
	doc binary; reset.
	(ggg := GIFReadWriter new) setStream: doc.
	^ ggg nextImage.

]

{ #category : #'get the page' }
HTTPSocket class >> httpJpeg: url [
	"Fetch the given URL, parse it using the JPEG reader, and return the resulting Form."

	| doc ggg |
	doc := self httpGet: url.
	doc binary; reset.
	(ggg := JPEGReadWriter new) setStream: doc.
	^ ggg nextImage.

]

{ #category : #'get the page' }
HTTPSocket class >> httpPost: url  args: argsDict accept: mimeType [ 
	"like httpGET, except it does a POST instead of a GET.  POST allows data to be uploaded"
	| document |
	document := self httpPostDocument: url  args: argsDict  accept: mimeType  request: ''.
	(document isString) ifTrue: [ 
		"strings indicate errors"
		^document ].

	
	^RWBinaryOrTextStream with: document content
]

{ #category : #'get the page' }
HTTPSocket class >> httpPostDocument: url  args: argsDict [
	"like httpGET, except it does a POST instead of a GET.  POST allows data to be uploaded"

	^self httpPostDocument: url args: argsDict accept: 'application/octet-stream' request: ''
]

{ #category : #'get the page' }
HTTPSocket class >> httpPostDocument: url  args: argsDict accept: mimeType [ 
	"like httpGET, except it does a POST instead of a GET.  POST allows data to be uploaded"

	^ self httpPostDocument: url args: argsDict accept: mimeType request: ''

]

{ #category : #'proxy settings' }
HTTPSocket class >> httpProxyExceptions [
	HTTPProxyExceptions ifNil: [HTTPProxyExceptions := OrderedCollection new].
	^HTTPProxyExceptions
]

{ #category : #'proxy settings' }
HTTPSocket class >> httpProxyPort [
	"answer the httpProxyPort"
	<preference: 'HTTP Proxy Port'
		category: 'HTTP Proxy'
		description: 'HTTP Proxy Port'
		type: #Number>
	^HTTPProxyPort ifNil:[80]
]

{ #category : #'proxy settings' }
HTTPSocket class >> httpProxyPort: aPortNumber [
	"Set the proxy port"
	HTTPProxyPort := aPortNumber.
]

{ #category : #'proxy settings' }
HTTPSocket class >> httpProxyServer [
	"answer the httpProxyServer. Take into account that as a Preference the Server might appear as an empty string but HTTPSocket expect it to be nil"
	<preference: 'HTTP Proxy Server'
		category: 'HTTP Proxy'
		description: 'HTTP Proxy Server. Leave blank if you don''t want to use a Proxy'
		type: #String>
	^HTTPProxyServer ifNil:['']

]

{ #category : #'proxy settings' }
HTTPSocket class >> httpProxyServer: aString [
	"answer the httpProxyServer. Take into account that as a Preference the Server might appear as an empty string but HTTPSocket expect it to be nil"
	HTTPProxyServer := aString.

]

{ #category : #'get the page' }
HTTPSocket class >> httpRequest: method url: urlString headers: hdrs content: contentOrNil response: responseBlock [

	"Sends an HTTP request to the server. Returns a MIMEDocument if successful,
	a string indicating the error otherwise. If a response block is provided, the
	response is fed into into so that the sender can see all the headers.
	The url string is assumed to be properly escaped by the sender."

	| index serverAndPort server port rawUrl stream resp code headers 
	  contentLength contentType content |

	(urlString beginsWith: 'http://') ifFalse:[self error: 'Not a http url'].

	"Extract server, port, and url"
	index := urlString indexOf: $/ startingAt: 8 ifAbsent:[urlString size+1]. "past http://"
	serverAndPort := urlString copyFrom: 8 to: index-1.
	server := serverAndPort copyUpTo: $:.
	port := ((serverAndPort copyAfter: $:) ifEmpty:['80']) asNumber.

	"Prepare the request URI"
	rawUrl := urlString copyFrom: index to: urlString size.
	(rawUrl beginsWith: '/') ifFalse:[rawUrl := '/', rawUrl].

	"Check for proxy"
	(self shouldUseProxy: server) ifTrue:[
		self httpProxyServer ifNotEmpty:[
			rawUrl := 'http://', serverAndPort, rawUrl. "per RFC 2616"
			server := self httpProxyServer.
			port := self httpProxyPort.
		].
	].

	"Fire off the request"
	stream := SocketStream openConnectionToHostNamed: server port: port.
	stream nextPutAll: method; space; nextPutAll: rawUrl; space; nextPutAll: 'HTTP/1.0'; crlf.
	stream nextPutAll: 'Host: ', serverAndPort; crlf.
	stream nextPutAll: 'Connection: close'; crlf.
	stream nextPutAll: 'User-Agent: ', self userAgentString; crlf.
	stream nextPutAll: 'Accept-Encoding: gzip'; crlf.
	stream nextPutAll: hdrs.
	stream crlf.

	contentOrNil ifNotNil:[
		| contentStream |
		"Upload request content"
		contentStream := contentOrNil readStream.
		[contentStream atEnd] whileFalse:[
			(HTTPProgress new) total: contentOrNil size; 
				amount: contentStream position; signal: 'Uploading...'.
			stream nextPutAll: (contentStream next: 4096).
			stream flush.
		].
	].

	stream flush.

	"Read the response"
	resp := stream upToAll: String crlfcrlf.
	"Extract the response code"
	code := ((resp copyUpTo: String cr) findTokens: ' ') second asNumber.
	"And the response headers"
	headers := Dictionary new.
	resp lines allButFirstDo: [ :nextLine |
		headers at: (nextLine copyUpTo: $:) asLowercase 
			put: (nextLine copyAfter: $:) withBlanksTrimmed ].

     	(code between: 301 and: 303)
		ifTrue:[
			 headers at: 'location' ifPresent: [:location |
				stream close.
				^ self httpRequest: method url: location headers: hdrs content: contentOrNil response: responseBlock]].


	"Read response content"
	contentLength := headers at: 'content-length' ifAbsent:[nil].
	contentType := headers at: 'content-type' ifAbsent:['application/octet-stream'].

	"Fixme - Provide HTTProgress"
	contentLength 
		ifNil: [ content := stream upToEnd ]
		ifNotNil: [
			contentLength := contentLength asInteger.
			content := String new: contentLength.
			index := 1.
			[ index <= contentLength ] whileTrue: [
				| bytesRead |
				bytesRead := stream readInto: content startingAt: index count: ((contentLength - index + 1) min: 8192).
				index := index + bytesRead.
				HTTPProgress new
						total: contentLength; 
						amount: index;
						signal: 'Downloading...' ] ].

	responseBlock ifNotNil:[responseBlock value: resp].

	(headers at: 'content-encoding' ifAbsent: [ nil ]) = 'gzip' ifTrue: [
		content := (GZipReadStream on: content) upToEnd ].

	^(code between: 200 and: 299) 
		ifTrue:[MIMEDocument contentType: contentType 
				content: content url: urlString]
		ifFalse:[resp asString, content].

]

{ #category : #handler }
HTTPSocket class >> httpRequestHandler [
	"Answer the registered handler for http requests. The handler needs to implement 
	#httpRequest:url:headers:content:response: compatible with the baseline version
	in HTTPSocket. If no handler is registered, answer the receiver"

	^HTTPRequestHandler ifNil:[self]
]

{ #category : #handler }
HTTPSocket class >> httpRequestHandler: anObject [
	"Set the registered handler for http requests. The handler needs to implement 
	#httpRequest:url:headers:content:response: compatible with the baseline version
	in HTTPSocket."

	HTTPRequestHandler := anObject
]

{ #category : #'get the page' }
HTTPSocket class >> httpShowChunk: url [
	"From a Swiki server, get a text chunk in the changes file.  Show its text in a window with style.  Vertical bar separates class and selector.  BE SURE TO USE ; instead of : in selectors!"
	"	HTTPSocket httpShowChunk: 'http://206.16.12.145:80/OurOwnArea.chunk.Socket|Comment'	 "
	"	HTTPSocket httpShowChunk: 'http://206.16.12.145:80/OurOwnArea.chunk.Point|class|x;y;'	"

	| doc text |
	doc := (self httpGet: url accept: 'application/octet-stream').
"	doc size = 0 ifTrue: [doc := 'The server does not seem to be responding']."
	doc isString ifTrue: [text := doc] ifFalse: [text := doc nextChunkText].
	(StringHolder new contents: text) openLabel: url.

]

{ #category : #'get the page' }
HTTPSocket class >> httpShowGif: url [
	"Display the picture retrieved from the given URL, which is assumed to be a GIF file.
	See examples in httpGif:."

	self showImage: (self httpGif: url) named: (url findTokens: '/') last
]

{ #category : #'get the page' }
HTTPSocket class >> httpShowJpeg: url [
	"Display the picture retrieved from the given URL, which is assumed to be a JPEG file.
	See examples in httpGif:."

	self showImage: (self httpJpeg: url) named: (url findTokens: '/') last
]

{ #category : #'get the page' }
HTTPSocket class >> httpShowPage: url [
	"Display the exact contents of the given URL as text. See examples in httpGet:"

	| doc |
	doc := (self httpGet: url accept: 'application/octet-stream') contents.
	doc size = 0 ifTrue: [^ self error: 'Document could not be fetched' translated].
	(StringHolder new contents: doc) openLabel: url.

]

{ #category : #'class initialization' }
HTTPSocket class >> initialize [
	"HTTPSocket initialize"

	HTTPPort := 80.
	self httpProxyServer: nil.
	HTTPBlabEmail := ''.  "	'From: somebody@no.where', CrLf	"
	HTTPProxyCredentials := ''.

	ExternalSettings registerClient: self.
	self removeHTTPProxyPreferences.
]

{ #category : #'proxy settings' }
HTTPSocket class >> proxySettingsFileName [
	^'proxySettings'
]

{ #category : #'proxy settings' }
HTTPSocket class >> proxyUser: userName password: password [
	"Store  HTTP 1.0 basic authentication credentials
	Note: this is an ugly hack that stores your password
	in your image.  It's just enought to get you going
	if you use a firewall that requires authentication"
	| encoded |
	encoded := (userName, ':', password) base64Encoded.
	HTTPProxyCredentials := 'Proxy-Authorization: Basic ' , encoded, String crlf
]

{ #category : #'proxy settings' }
HTTPSocket class >> removeHTTPProxyPreferences [
	" This method will remove the old HTTP Proxy preferences. "
	(Preferences valueOfPreference: #httpProxyServer) ifNotNil:[
		HTTPProxyServer := Preferences valueOfPreference: #httpProxyServer.
		Preferences removePreference: #httpProxyServer.
	].
	(Preferences valueOfPreference: #httpProxyPort) ifNotNil:[
		HTTPProxyPort := Preferences valueOfPreference: #httpProxyPort.
		Preferences removePreference: #httpProxyPort.
	].

]

{ #category : #'proxy settings' }
HTTPSocket class >> removeProxyException: domainName [
	"Remove a (partial, wildcard) domain name from the list of proxy exceptions"

	self httpProxyExceptions remove: domainName ifAbsent: []
]

{ #category : #utilities }
HTTPSocket class >> shouldUseProxy: serverName [
	"Retrieve the server and port information from the URL, match it to the proxy settings and open a http socket for the request."

	self httpProxyServer ifNotEmpty: [
		self httpProxyExceptions
			detect: [:domainName | domainName match: serverName]
			ifNone: [^true]].
	^false

]

{ #category : #utilities }
HTTPSocket class >> showImage: image named: imageName [

	Project current showImage: image named: imageName

]

{ #category : #'proxy settings' }
HTTPSocket class >> stopUsingProxyServer [
	"Stop directing HTTP request through a proxy server."

	self httpProxyServer: nil.
	self httpProxyPort: 80.
	HTTPProxyCredentials := ''

]

{ #category : #'proxy settings' }
HTTPSocket class >> useProxyServerNamed: proxyServerName port: portNum [
	"Direct all HTTP requests to the HTTP proxy server with the given name and port number."

	proxyServerName ifNil: [  "clear proxy settings"
		self httpProxyServer: nil.
		self httpProxyPort: 80.
		^ self].

	proxyServerName isString
		ifFalse: [self error: 'Server name must be a String or nil'].
	self httpProxyServer: proxyServerName.

	self httpProxyPort: portNum.
	(self httpProxyPort isKindOf: String) ifTrue: [HTTPPort := portNum asNumber].
	self httpProxyPort ifNil: [self httpProxyPort: self defaultPort].
]

{ #category : #'proxy settings' }
HTTPSocket class >> useProxyServerNamed: proxyServerName port: portNum proxyUser: aString password: anotherString [
	self useProxyServerNamed: proxyServerName port: portNum.
	self proxyUser: aString password: anotherString
]

{ #category : #utilities }
HTTPSocket class >> userAgentString [ 
	"self userAgentString"

	^'User-Agent: ',
		SystemVersion current version, '-', 
		SystemVersion current highestUpdate printString
]
