Class {
	#name : #WebClientHelp,
	#superclass : #CustomHelp,
	#category : #'WebClient-Help'
}

{ #category : #pages }
WebClientHelp class >> authentication [
	"This method was automatically generated. Edit it using:"
	"WebClientHelp edit: #authentication"
	^HelpTopic
		title: 'Authentication'
		contents: 
'WebClient supports basic and digest authentication by default. WebClient delegates the retrieval of username/password to WebUtils which prompts the user for credentials. 

WebClient can either be supplied with specific credentials to be used or custom credentials handlers, for example:

	| client |
	client := WebClient new.
	client username: ''squeak''.
	client password: ''squeak''.
	client httpGet: ''http://www.squeak.org/protected''.

Proxy authentication works the same way as authentication but operates on a different authentication context to allow different sets of credentials to work.
!
]style[(288 1 1 1 6 1 1 2 6 1 2 11 3 3 6 1 9 1 8 3 6 1 9 1 8 3 6 1 8 1 33 2 158),cblack;,cgray;,cblack;,c107107107,cblack;,cgray;,cblack;,c107107107,cblack;,b,cblack;,c000000127,cblack;,c107107107,cblack;,c000000127,cblack;,c127000127,cblack;,c107107107,cblack;,c000000127,cblack;,c127000127,cblack;,c107107107,cblack;,c000000127,cblack;,c127000127,cblack;,!' readStream nextChunkText
]

{ #category : #accessing }
WebClientHelp class >> bookName [
	"Returns the name of the custom help book"

	^'WebClient'
]

{ #category : #pages }
WebClientHelp class >> changeLog [
	"This method was automatically generated. Edit it using:"
	"WebClientHelp edit: #changeLog"
	^HelpTopic
		title: 'Version History'
		contents: 
'WebClient 1.4:
* Fixes cookie handling to be in line with RFC 2109
* Provide the final redirect url in requests
* OAuth support via WebUtils.
* Support for POST using chunked transfer-encoding

WebClient 1.3:
* Added logging in common log format
* Added support for SSL/TLS via SqueakSSL.

WebClient 1.2:
* Added support for multipart/form-data posts
* Added WebSocket support

WebClient 1.1:
* Added support for HEAD, TRACE, OPTIONS, and PUT methods

WebClient 1.0: 
* Initial release.
!' readStream nextChunkText
]

{ #category : #pages }
WebClientHelp class >> cookieSupport [
	"This method was automatically generated. Edit it using:"
	"WebClientHelp edit: #cookieSupport"
	^HelpTopic
		title: 'Cookie Support'
		contents: 
'WebClient supports session cookies. Cookies are preserved within one WebClient session but not across multiple session (cookies can be copied or shared between WebClients which makes it easy to support where needed). Support for cookies can be disabled via WebClient''s #acceptCookies: property.
!' readStream nextChunkText
]

{ #category : #pages }
WebClientHelp class >> introduction [
	"This method was automatically generated. Edit it using:"
	"WebClientHelp edit: #introduction"
	^HelpTopic
		title: 'Introduction'
		contents: 
'WebClient is a simple, yet reasonably complete HTTP client. WebClient uses HTTP 1.1, supports proxies (both authenticating and not), redirect support and authentication.

WebClient comes with WebServer, an HTTP server implementation with a similarly simple yet reasonably complete approach.!' readStream nextChunkText
]

{ #category : #pages }
WebClientHelp class >> multipleRequests [
	"This method was automatically generated. Edit it using:"
	"WebClientHelp edit: #multipleRequests"
	^HelpTopic
		title: 'Multiple Requests'
		contents: 
'WebClient can and should be used for multiple requests to the same host. This will ensure persistent connections as well as having cookies processed properly within one session:

	| client resp |
	client := WebClient new.
	resp := client httpGet: ''http://www.squeak.org/''.
	resp := client httpGet: ''http://www.squeak.org/Download''.
	resp := client httpGet: ''http://www.squeak.org/Features''.
	client close.

One important issue to keep in mind is that because WebClient is optimized for persistent connections, you need to close it when you are done. That is not true for WebClient''s class-side convenience APIs, which prefetch the response and close the socket. Generally speaking, whenever you say ''WebClient new'' you need to close the client when you''re done (however, you can do so by sending #close to a response you''ve received). For example:

	"Convenience API. Don''t need to close, but prefetches result."
	WebClient httpGet: ''http://www.squeak.org''.

	| client resp |
	"Regular use. Create WebClient, return after header is read ..."
	client := WebClient new.
	[response := client httpGet: ''http://www.squeak.org/''.
	"... then fetch (or stream) the content ..."
	response content.
	] ensure:[
		"... and close the client when done."
		client close.
	].!
]style[(179 1 1 1 6 1 4 1 1 2 6 1 2 11 3 3 4 1 2 1 6 1 8 1 24 3 4 1 2 1 6 1 8 1 32 3 4 1 2 1 6 1 8 1 32 3 6 1 5 2 443 1 62 12 8 1 23 4 1 1 6 1 4 1 1 2 64 1 1 6 1 2 11 3 4 8 1 2 1 6 1 8 1 24 3 44 2 8 1 7 5 7 4 37 3 6 1 5 5),cblack;,cgray;,cblack;,c107107107,cblack;,c107107107,cblack;,cgray;,cblack;,c107107107,cblack;,b,cblack;,c000000127,cblack;,c107107107,cblack;,b,cblack;,c107107107,cblack;,c000000127,cblack;,c127000127,cblack;,c107107107,cblack;,b,cblack;,c107107107,cblack;,c000000127,cblack;,c127000127,cblack;,c107107107,cblack;,b,cblack;,c107107107,cblack;,c000000127,cblack;,c127000127,cblack;,c107107107,cblack;,c000000127,cblack;,,cblack;,c000127127,cblack;,c000000127,cblack;,c127000127,cblack;,cgray;,cblack;,c107107107,cblack;,c107107107,cblack;,cgray;,cblack;,c000127127,,cblack;,c107107107,cblack;,b,cblack;,c000000127,cblack;,c107107107,cblack;,b,cblack;,c107107107,cblack;,c000000127,cblack;,c127000127,cblack;,c000127127,cblack;,c107107107,cblack;,c000000127,cblack;,c000000127,cblack;,c000127127,cblack;,c107107107,cblack;,c000000127,cblack;!' readStream nextChunkText
]

{ #category : #accessing }
WebClientHelp class >> pages [ 
	"Returns a collection of method selectors to return the pages of the custom help book"
		
	^#(introduction webClientRequests webClientResponses multipleRequests authentication redirectSupport proxySupport cookieSupport changeLog)
]

{ #category : #pages }
WebClientHelp class >> proxySupport [
	"This method was automatically generated. Edit it using:"
	"WebClientHelp edit: #proxySupport"
	^HelpTopic
		title: 'Proxy Support'
		contents: 
'WebClient supports connecting via http proxies, including authenticating proxies. WebClient delegates proxy detection to its ProxyHandler which is responsible for performing the proper actions. Proxy authentication is handled in a similar way as regular authentication. The defaults are implemented in WebUtils.
!' readStream nextChunkText
]

{ #category : #pages }
WebClientHelp class >> redirectSupport [
	"This method was automatically generated. Edit it using:"
	"WebClientHelp edit: #redirectSupport"
	^HelpTopic
		title: 'Redirect Handling'
		contents: 
'WebClient handles http redirect requests (3xx) transparently. WebClient detects infinite redirect loops and gives up after a certain number of attempts, returning the redirect (3xx) response which caused it to give up. Users of WebClient will only see 3xx responses if WebClient has given up (i.e., returning a 3xx should be considered an error).

Redirect handling can be disabled by setting #allowRedirect property to the desired value. When disabled, WebClient will not attempt to perform any redirect handling.!' readStream nextChunkText
]

{ #category : #pages }
WebClientHelp class >> webClientRequests [
	"This method was automatically generated. Edit it using:"
	"WebClientHelp edit: #webClientRequests"
	^HelpTopic
		title: 'Using WebClient'
		contents: 
'The simplest form to use WebClient is by one of its convenience APIs:

	WebClient httpGet: ''http://www.squeak.org/''.
	WebClient httpPost: ''http://www.squeak.org/'' content:''Hello Squeak'' type: ''text/plain''.

For more elaborate use of headers and some other options in the request, a client can utilize modified variants:

	WebClient new httpGet: ''http://www.squeak.org/'' do:[:req|
		"Set an if-modified-since header"
		req headerAt: ''If-Modified-Since'' put: ''Sat, 29 Oct 1994 19:43:31 GMT''.
		"Add several accept headers"
		req addHeader: ''Accept'' value: ''text/plain''.
		req addHeader: ''Accept'' value: ''application/x-foo-bar''.
		req addHeader: ''Accept'' value: ''image/jpg''.
	].

The set of utility methods is limited to a few useful ones but it is easy to do the setup on your own:

	| url client request data |
	data := ''Hello Squeak''.								"POST data"
	url := ''http://www.squeak.org/''.						"POST url"
	client := WebClient new initializeFromUrl: url. 		"sets host etc"
	request := client requestWithUrl: url. 				"sets path etc"
	request method: ''POST''.							"sets method"
	request headerAt: ''Content-Length'' put: data size.
	request headerAt: ''Content-Type'' put: ''text/plain''.
	"... any other headers required ..."
	^client sendRequest: request 
		content: data readStream
		size: data size.

The utility methods like httpGet: etc. are similarly simple requests.
!
]style[(71 11 8 1 24 13 9 1 24 1 8 14 1 5 1 12 2 115 11 3 1 8 1 24 1 3 2 3 1 3 33 3 3 1 9 1 19 1 4 1 31 4 28 3 3 1 10 1 8 1 6 1 12 4 3 1 10 1 8 1 6 1 23 4 3 1 10 1 8 1 6 1 11 6 105 1 1 1 3 1 6 1 7 1 4 1 1 2 4 1 2 1 14 9 11 2 3 1 2 1 24 7 10 2 6 1 2 11 3 1 18 1 3 4 15 2 7 1 2 1 6 1 15 1 3 6 15 2 7 1 7 1 6 8 13 2 7 1 9 1 16 1 4 1 4 1 4 3 7 1 9 1 14 1 4 1 12 3 36 2 1 6 1 12 1 7 4 8 1 4 1 10 3 5 1 4 1 4 2 71),cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,c127000127,cblack;,c000000127,cblack;,c127000127,cblack;,,cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,c000000127,cgray;,cblack;,c000127127,cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000127127,cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,c127000127,cblack;,,cblack;,cgray;,cblack;,c107107107,cblack;,c107107107,cblack;,c107107107,cblack;,c107107107,cblack;,cgray;,cblack;,c107107107,cblack;,b,cblack;,c127000127,cblack;,c000127127,cblack;,c107107107,cblack;,b,cblack;,c127000127,cblack;,c000127127,cblack;,c107107107,cblack;,b,cblack;,c000000127,cblack;,c000000127,cblack;,c107107107,cblack;,c000127127,cblack;,c107107107,cblack;,b,cblack;,c107107107,cblack;,c000000127,cblack;,c107107107,cblack;,c000127127,cblack;,c107107107,cblack;,c000000127,cblack;,c127000127,cblack;,c000127127,cblack;,c107107107,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,c107107107,cblack;,c000000127,cblack;,c107107107,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000127127,cblack;,c127000000,c107107107,cblack;,c000000127,cblack;,c107107107,cblack;,c000000127,cblack;,c107107107,cblack;,c000000127,cblack;,c000000127,cblack;,c107107107,cblack;,c000000127,cblack;,!' readStream nextChunkText
]

{ #category : #pages }
WebClientHelp class >> webClientResponses [
	"This method was automatically generated. Edit it using:"
	"WebClientHelp edit: #webClientResponses"
	^HelpTopic
		title: 'Responses'
		contents: 
'The WebClient request methods return a WebResponse that the client can process:

	| resp |
	resp := WebClient httpGet: ''http://www.squeak.org/''.
	resp isSuccess ifFalse:[^self error: resp status].
	"Process the content from the response"
	^resp content

In addition, content can be streamed from the response so that it does not need to be downloaded all at once:

	| client resp file |
	client := WebClient new.
	[resp := client httpGet: ''http://www.squeak.org/''.
	resp isSuccess ifFalse:[^self error: resp status].
	"Stream the content from the response"
	file := FileStream newFileNamed: ''page.html''.
	resp streamTo: file 
			size: resp contentLength
			progress:[:total :amount].
	file close] ensure:[client close].

The progress block in the above can be omitted but has been included in this example to illustrate its usage. The block takes a total length (which can be nil if the length is not known) and the amount that has been loaded.
!
]style[(81 1 1 1 4 1 1 2 4 1 2 11 8 1 24 3 4 1 9 1 8 1 5 1 6 1 4 1 6 4 39 2 1 4 1 7 1 112 1 1 1 6 1 4 1 4 1 1 2 6 1 2 11 3 4 4 1 2 1 6 1 8 1 24 3 4 1 9 1 8 1 5 1 6 1 4 1 6 1 3 38 2 4 1 2 12 13 1 11 3 4 1 9 1 4 5 5 1 4 1 13 4 9 1 1 5 2 6 1 3 4 1 5 2 7 1 6 1 5 3 225),cblack;,cgray;,cblack;,c107107107,cblack;,cgray;,cblack;,c107107107,cblack;,b,cblack;,c000000127,cblack;,c127000127,cblack;,c107107107,cblack;,c000000127,cblack;,c000000127,cblack;,c127000000,cblack;,c000000127,cblack;,c107107107,cblack;,c000000127,cblack;,c000127127,cblack;,c127000000,c107107107,cblack;,c000000127,cblack;,,cblack;,cgray;,cblack;,c107107107,cblack;,c107107107,cblack;,c107107107,cblack;,cgray;,cblack;,c107107107,cblack;,b,cblack;,c000000127,cblack;,c107107107,cblack;,b,cblack;,c107107107,cblack;,c000000127,cblack;,c127000127,cblack;,c107107107,cblack;,c000000127,cblack;,c000000127,c000127000,c127000000,cblack;,c000000127,cblack;,c107107107,cblack;,c000000127,c000127000,cblack;,c000127127,cblack;,c107107107,cblack;,b,cblack;,c000000127,cblack;,c127000127,cblack;,c107107107,cblack;,c000000127,cblack;,c107107107,cblack;,c000000127,cblack;,c107107107,cblack;,c000000127,cblack;,c000000127,c000127000,cblack;,c000000127,cblack;,c000000127,c000127000,cblack;,c107107107,cblack;,c000000127,cblack;,c000000127,cblack;,c107107107,cblack;,c000000127,cblack;,!' readStream nextChunkText
]
