Class {
	#name : #WebServerHelp,
	#superclass : #CustomHelp,
	#category : #'WebClient-Help'
}

{ #category : #pages }
WebServerHelp class >> addingActions [
	"This method was automatically generated. Edit it using:"
	"WebServerHelp edit: #addingActions"
	^HelpTopic
		title: 'Adding Actions'
		contents: 
'Let''s add some real stuff that might be useful on a server:

	WebServer default addService: ''/smalltalk'' action:[:req| | action |
		action := (req fields at: ''get'' ifAbsent:['''']) asSymbol.
		req send200Response: (Smalltalk perform: action) asString
	].

We can now request some interesting things like:

	(WebClient httpGet:''http://localhost:8080/smalltalk?get=systemInformationString'') content.
	(WebClient httpGet:''http://localhost:8080/smalltalk?get=platformName'') content.
	
Obviously, this poses quite a risk for abuse. One way to limit this risk is to expose specific actions, such as here:

	#(systemInformationString platformName) do:[:symbol|
		WebServer default addService: ''/info/'', symbol action:[:req|
			req send200Response: (Smalltalk perform: symbol) asString]].

	(WebClient httpGet:''http://localhost:8080/info/systemInformationString'') content.
	(WebClient httpGet:''http://localhost:8080/info/platformName'') content.

Alternatively, authentication can be used to limit access to exposed resources. 
!
]style[(61 11 7 1 11 1 12 1 7 2 3 1 1 1 1 6 1 1 3 6 1 2 1 1 3 1 6 1 3 1 5 1 9 4 1 1 8 4 3 1 16 1 1 10 8 1 6 1 1 8 5 51 12 8 61 2 7 14 8 50 2 7 2 121 3 23 1 12 2 3 2 6 1 13 7 1 11 1 8 1 1 6 1 7 1 1 3 1 4 3 1 16 1 1 10 8 1 6 1 1 8 1 3 1 12 8 52 2 7 14 8 41 2 7 2 82),cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,c000000127,cgray;,cblack;,cgray;,cblack;,cgray;,cblack;,cgray;,cblack;,cgray;,cblack;,b,cblack;,c000127000,c000000127,cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,c127000127,c000127000,cblack;,c000000127,cblack;,c000000127,cblack;,c000000127,cblack;,c000127000,cblack;,c000000127,cblack;,cgray;,c000127000,cblack;,c000000127,cblack;,,cblack;,c000000127,c127000127,cblack;,c000000127,cblack;,c000000127,c127000127,cblack;,c000000127,cblack;,,cblack;,c000000127,cblack;,c000000127,cblack;,c000000127,cblack;,c000000127,cgray;,cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,c000000127,cblack;,c000000127,cblack;,c000000127,c000127000,cblack;,c000000127,cgray;,cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,c000000127,c127000127,cblack;,c000000127,c000127000,cblack;,,cblack;,c000000127,c127000127,cblack;,c000000127,cblack;,c000000127,c127000127,cblack;,c000000127,cblack;,!' readStream nextChunkText
]

{ #category : #pages }
WebServerHelp class >> addingServices [
	"This method was automatically generated. Edit it using:"
	"WebServerHelp edit: #addingServices"
	^HelpTopic
		title: 'Adding Services'
		contents: 
'Once the server is running, you can point your browser to http://localhost:8080 but since we haven''t told WebServer what we''d like to do all we get is a 404 (not found) response. To tell WebServer what to do we need to register a service:

	WebServer default addService: ''/hello'' action:[:req|
		req send200Response: ''Hello World''.
	].

The service takes a path (/hello) and an action to perform for any request that maps to this path. We can now fetch the response in a browser by going to http://localhost:8080/hello or directly using WebClient:

	(WebClient httpGet:''http://localhost:8080/hello'') content.
	(WebClient httpGet:''http://localhost:8080/hello/squeak'') content.
!
]style[(240 11 7 1 11 1 8 1 7 2 3 1 3 3 1 16 1 13 6 213 12 8 29 2 7 14 8 36 2 7 2),cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,c000000127,cgray;,cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,,cblack;,c000000127,c127000127,cblack;,c000000127,cblack;,c000000127,c127000127,cblack;,c000000127,cblack;!' readStream nextChunkText
]

{ #category : #pages }
WebServerHelp class >> authentication [
	"This method was automatically generated. Edit it using:"
	"WebServerHelp edit: #authentication"
	^HelpTopic
		title: 'Authentication'
		contents: 
'To add authentication you can use web server as follows:

	WebServer default addService: ''/smalltalk'' action:[:req| | action |
		WebServer default authenticate: req realm: ''squeak'' methods: #(digest basic) do:[
			action := (req fields at: ''get'' ifAbsent:['''']) asSymbol.
			req send200Response: (Smalltalk perform: action) asString.
		].
	].

The above supports both digest as well as basic authentication for accessing the /smalltalk service. Let''s add a user so that we can access it:

	WebServer default passwordAt: ''squeak'' realm: ''squeak'' put: ''squeak''.

The server does NOT store plain text passwords, but rather hashes. To be precise, it stores the ha1 term used in digest authentication which is the same hash produced by htdigest. We can now access the /smalltalk service by providing user name ''squeak'' and password ''squeak''.

	(WebClient httpGet:''http://localhost:8080/smalltalk?get=platformName'') content.

Unfortunately, digest authentication can be slow since our MD5 implementation is rather pathetic. 
!
]style[(58 11 7 1 11 1 12 1 7 2 3 1 1 1 1 6 1 1 13 7 1 13 1 3 1 6 1 8 1 8 3 6 1 5 2 3 1 4 6 1 2 1 1 3 1 6 1 3 1 5 1 9 1 2 1 1 1 8 5 3 1 16 1 1 10 8 1 6 1 1 8 4 1 6 146 11 7 1 11 1 8 1 6 1 8 1 4 1 8 2 278 12 8 50 2 7 2 100),cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,c000000127,cgray;,cblack;,cgray;,cblack;,cgray;,cblack;,cgray;,cblack;,c000000127,cblack;,c000000127,cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,c000000127,cblack;,c000000127,cblack;,c000000127,c000127000,cblack;,cgray;,cblack;,b,cblack;,c127000127,c000000127,cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,c127000000,c127000127,c127000000,c127000127,cblack;,c000000127,cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,cgray;,c127000127,cblack;,c000000127,cblack;,c000127000,cblack;,,cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,c127000127,cblack;,,cblack;,c000000127,c127000127,cblack;,c000000127,cblack;,!' readStream nextChunkText
]

{ #category : #accessing }
WebServerHelp class >> bookName [
	"Returns the name of the custom help book"

	^'WebServer'
]

{ #category : #pages }
WebServerHelp class >> changeLog [
	"This method was automatically generated. Edit it using:"
	"WebServerHelp edit: #changeLog"
	^HelpTopic
		title: 'Versions'
		contents: 
'WebServer 1.4:
* Fixes cookie handling to be in line with RFC 2109
* Support for responses using chunked transfer-encoding

WebServer 1.3:
* Added logging in common log format
* Added support for SSL/TLS via SqueakSSL.

WebServer 1.2:
* Added support for multipart/form-data posts
* Added WebSocket support

WebServer 1.1:
* Added support for specific request methods
* Implement HEAD, TRACE, and OPTIONS in WebServer

WebServer 1.0: 
* Initial release.
!' readStream nextChunkText
]

{ #category : #pages }
WebServerHelp class >> cookies [
	"This method was automatically generated. Edit it using:"
	"WebServerHelp edit: #cookies"
	^HelpTopic
		title: 'Cookies'
		contents: 
'Because of the performance issues with authentication, we''d like to avoid authentication for each request and instead authenticate once and use some persistent session state (cookies). So let''s do that:

	WebServer default addService: ''/smalltalk'' action:[:req| | session |
		session := WebServer default sessionAt: (req cookieAt: ''session'').
		session ifNil:[ "no session, reguire login"
			req send302Response: ''/login?url='', req rawUrl encodeForHTTP.
		] ifNotNil:[ | target action |
			action := (req fields at: ''get'' ifAbsent:['''']) asSymbol.
			req send200Response: (Smalltalk perform: action) asString.
		].
	].

And of course we now need a login service The service will require authentication and provide a session identifier for the client. It then redirects back to where the request was originally made from:

	WebServer default addService: ''/login'' action:[:req| | session |
		WebServer default authenticate: req realm: ''squeak'' methods: #(digest) do:[ | id |
			"We have no session state for now, just remember the session id"
			WebServer default sessionAt: (id := UUID new hex) put: ''''.
			"Send a redirect back to where we came from with a cookie"
			req send302Response: (req fields at: ''url'' ifAbsent:[''/'']) 
				do:[:reply| reply setCookie: ''session'' value: id path: ''/smalltalk'']]].
!
]style[(204 11 7 1 11 1 12 1 7 2 3 1 1 1 1 7 1 1 3 7 1 2 11 7 1 10 1 1 3 1 9 1 9 1 4 7 1 6 1 1 27 4 3 1 16 1 13 1 1 3 1 6 1 13 4 1 1 9 1 1 1 1 6 1 6 1 1 4 6 1 2 1 1 3 1 6 1 3 1 5 1 9 1 2 1 1 1 8 5 3 1 16 1 1 10 8 1 6 1 1 8 4 1 6 203 11 7 1 11 1 8 1 7 2 3 1 1 1 1 7 1 1 13 7 1 13 1 3 1 6 1 8 1 8 3 6 2 3 1 1 1 1 2 1 1 4 64 14 7 1 10 1 1 2 1 2 6 3 1 3 1 1 4 1 2 5 58 4 3 1 16 1 1 3 1 6 1 3 1 5 1 9 1 3 1 1 6 3 1 1 5 1 1 5 1 10 1 9 1 6 1 2 1 5 1 13 1 3),cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,c000000127,cgray;,cblack;,cgray;,cblack;,cgray;,cblack;,cgray;,cblack;,cgray;,cblack;,b,cblack;,c000000127,cblack;,c000000127,cblack;,c000127000,c000000127,cblack;,c000000127,cblack;,c127000127,c000127000,cblack;,cgray;,cblack;,c000000127,c000127000,cblack;,c000127127,cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,c000000127,cblack;,c000000127,cblack;,c000000127,cblack;,c000000127,cblack;,c000127000,cblack;,c000000127,c000127000,cblack;,cgray;,cblack;,cgray;,cblack;,cgray;,cblack;,cgray;,cblack;,cgray;,cblack;,b,cblack;,c127000127,c000000127,cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,c127000000,c127000127,c127000000,c127000127,cblack;,c000000127,cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,cgray;,c127000127,cblack;,c000000127,cblack;,c000127000,cblack;,,cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,c000000127,cgray;,cblack;,cgray;,cblack;,cgray;,cblack;,cgray;,cblack;,c000000127,cblack;,c000000127,cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,c000000127,cblack;,c000000127,c000127000,cblack;,cgray;,cblack;,cgray;,cblack;,cgray;,cblack;,c000127127,cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cgray;,cblack;,b,cblack;,c000000127,cblack;,c000000127,c127000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000127127,cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,c000000127,cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,c127000000,c127000127,c127000000,c127000127,cblack;,c000000127,c127000127,cblack;,c000000127,cgray;,cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,cgray;,cblack;,c000000127,cblack;,c127000127,c000127000,cblack;!' readStream nextChunkText
]

{ #category : #pages }
WebServerHelp class >> errorHandling [
	"This method was automatically generated. Edit it using:"
	"WebServerHelp edit: #errorHandling"
	^HelpTopic
		title: 'Error Handling'
		contents: 
'By default WebServer will send a 500 response with a full debug stack when an error occurs. This may not be appropriate in production environments and consequently, the error handler can be customized. Typically, the error handler will perform one of the following actions:

* Pass the error through. This is useful for debugging, when an error in WebServer should raise a notifier:

	webServer errorHandler:[:err :socket| err pass].

* Send the ''standard'' 500 response (including the full stack): You can simply use WebServer''s default action for this:

	webServer errorHandler:[:err :socket| webServer handleError: err socket: socket.].

* Send a custom 500 response, or perform a redirect, for example:

	webServer errorHandler:[:err :socket|
		[socket sendData:
			''HTTP/1.0 302 Temporary redirect'', String crlf,
			''Location: /error.html'', String crlf,
			String crlf.
		socket close] on: Error do:[
			"Ignore errors in error handling"
		].
	].

Of course, you can use any possible combination; including the ability to turn error handling on and off via WebServer http requests.!
]style[(384 11 13 2 3 2 6 1 1 3 1 4 2 123 10 13 2 3 2 6 1 11 12 1 3 1 7 1 6 3 69 11 13 2 3 2 6 1 3 1 6 1 9 4 33 1 8 5 4 23 1 8 5 11 4 4 6 1 5 1 1 3 7 3 1 4 33 3 1 5 135),cblack;,c000000126,cblack;,c000000126,cblack;,c000000126,cgray;,cblack;,c000000126,cblack;,c000000126,cblack;,,cblack;,c000000126,cblack;,c000000126,cblack;,c000000126,cgray;,cblack;,c000000126,cblack;,c000000126,cblack;,c000000126,cblack;,c000000126,cblack;,,cblack;,c000000126,cblack;,c000000126,cblack;,c000000126,cgray;,cblack;,c000126000,c000000126,cblack;,c000000126,cblack;,c126000126,c000000126,cblack;,c000000126,cblack;,c126000126,c000000126,cblack;,c000000126,cblack;,c000000126,cblack;,c000000126,cblack;,c000000126,c000126000,cblack;,c000000126,cblack;,c000000126,c000126000,cblack;,c000126126,cblack;,c000126000,cblack;,!' readStream nextChunkText
]

{ #category : #pages }
WebServerHelp class >> introduction [
	"This method was automatically generated. Edit it using:"
	"WebServerHelp edit: #introduction"
	^HelpTopic
		title: 'Introduction'
		contents: 
'WebServer is a simple, yet reasonably complete HTTP server implementation. WebServer supports streaming, authentication, cookies, and session handling in a compact and easy to use form.

The primary goal for WebServer is for command-and-control style interfaces. If you would like to add some web-based remote control facility without much fuzz and html goodness around it, WebServer is for you.

WebServer comes together with WebClient which provides a similarly complete and simple HTTP client implementation.!' readStream nextChunkText
]

{ #category : #pages }
WebServerHelp class >> logging [
	"This method was automatically generated. Edit it using:"
	"WebServerHelp edit: #logging"
	^HelpTopic
		title: 'Logging'
		contents: 
'WebServer supports logging in common log format. In order to tell WebServer where to log to you can either give it a stream:

	WebServer default accessLog: Transcript.

or alternatively a file name, for example:

	WebServer default accessLog: ''/var/log/wsd/access_log''.

When used in the latter form, WebServer opens and closes the file for each log entry which provides additional robustness at the cost of some performance.
!
]style[(126 11 7 1 10 12 46 11 7 1 10 1 25 1 157),cblack;,c000000127,cblack;,c000000127,cblack;,,cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,!' readStream nextChunkText
]

{ #category : #accessing }
WebServerHelp class >> pages [ 
	"Returns a collection of method selectors to return the pages of the custom help book"
		
	^#(introduction startingWebServer addingServices serviceHierarchies errorHandling addingActions authentication cookies summary logging sslSupport changeLog)
]

{ #category : #pages }
WebServerHelp class >> serviceHierarchies [
	"This method was automatically generated. Edit it using:"
	"WebServerHelp edit: #serviceHierarchies"
	^HelpTopic
		title: 'Service Hierarchies'
		contents: 
'More specific services are preferred over more general services.  In addition to the /hello service, we can provide a handler for /hello/squeak by adding the following service:

	WebServer default addService: ''/hello/squeak'' action:[:req|
		req send200Response: ''Hello to you too, Squeak!!''.
	].

	(WebClient httpGet:''http://localhost:8080/hello'') content.
	(WebClient httpGet:''http://localhost:8080/hello/squeak'') content.

A default handler for any kind of request can installed by using the ''/'' path:

	WebServer default addService: ''/'' action:[:req|
		req send302Response: ''/hello''. "temporary redirect"
	].

This will make any request that isn''t handled by an explicit action redirect to /hello where it will be handled by the handler established earlier, for example:

	(WebClient httpGet:''http://localhost:8080/foobar'') content.
!
]style[(178 11 7 1 11 1 15 1 7 2 3 1 3 3 1 16 1 27 6 1 12 8 29 2 7 14 8 36 2 7 2 81 11 7 1 11 1 3 1 7 2 3 1 3 3 1 16 1 8 2 20 5 163 12 8 30 2 7 1 1),cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,c000000127,cgray;,cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,,cblack;,c000000127,c127000127,cblack;,c000000127,cblack;,c000000127,c127000127,cblack;,c000000127,cblack;,,cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,c000000127,cgray;,cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000127127,cblack;,,cblack;,c000000127,c127000127,cblack;,c000000127,cblack;,!' readStream nextChunkText
]

{ #category : #pages }
WebServerHelp class >> sslSupport [
	"This method was automatically generated. Edit it using:"
	"WebServerHelp edit: #sslSupport"
	^HelpTopic
		title: 'SSL/TLS Support'
		contents: 
'WebServer supports secure connections over SSL/TLS via SqueakSSL. To install SqueakSSL, execute the following:

	(Installer ss project: ''SqueakSSL'')
		install: ''SqueakSSL-Core'';
		install: ''SqueakSSL-Tests''.

If you have SqueakSSL installed, you can tell WebServer to use a particular cert which puts WebServer into secure mode.

The certName itself is platform dependent. On Unix, the cert name is the path to the .pem file with BOTH the cert and the private key, for example:

	WebServer default certName: ''/home/user/certs/testcert.pem''.

On Windows, the cert name is a string that is matched against the certificate subject. Usually, the certificate subject includes your host name so that you would use:

	WebServer default certName: ''secure.domain.com''.

Client certificate handling is currently not supported.	!
]style[(112 12 2 1 8 1 11 4 8 1 16 4 8 1 17 1 272 11 7 1 9 1 31 1 170 11 7 1 9 1 19 1 58),cblack;,c000000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,c127000127,cblack;,,cblack;,c000000125,cblack;,c000000125,cblack;,c125000125,cblack;,,cblack;,c000000125,cblack;,c000000125,cblack;,c125000125,cblack;,!' readStream nextChunkText
]

{ #category : #pages }
WebServerHelp class >> startingWebServer [
	"This method was automatically generated. Edit it using:"
	"WebServerHelp edit: #startingWebServer"
	^HelpTopic
		title: 'Starting WebServer'
		contents: 
'A WebServer is started by listening on a particular port. The examples below use ''WebServer reset default'' for convenience; specific applications should have their own registry for accessing various WebServer instances.

	(WebServer reset default)
		listenOn: 8080.

The server will persist when the image is restarted and must be stopped explicitly by sending it the #destroy message.
!
]style[(221 12 5 1 7 4 9 1 4 2 120),cblack;,c000000127,cblack;,c000000127,cblack;,c000000127,cblack;,c127000000,cblack;,!' readStream nextChunkText
]

{ #category : #pages }
WebServerHelp class >> summary [
	"This method was automatically generated. Edit it using:"
	"WebServerHelp edit: #summary"
	^HelpTopic
		title: 'Summary'
		contents: 
'At this point, making a request like the following:

	(WebClient httpGet: ''http://localhost:8080/smalltalk?get=platformName'') content.

requires several roundtrips:

	1) The first GET request is redirected from /smalltalk to /login
	2) The request to /login is responded to with an authentication challenge
	3) The request to /login is authenticated and a session cookie is established
	4) The request is redirected back to /smalltalk where it is finally handled.

More examples for using WebServer can be found in class WebServer itself. Here is an overview:

	* exampleDoIt - the simplest possible RPC interface to Squeak.
	* exampleBrowse - browse the files on your local disk
	* exampleSession - a simple session example
	* exampleAuth - a simple authentication example
!
]style[(53 12 8 1 50 2 7 2 639),cblack;,c000000127,cblack;,c127000127,cblack;,c000000127,cblack;,!' readStream nextChunkText
]
