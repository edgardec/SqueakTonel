"
ProtocolClient is the abstract super class for a variety of network protocol clients.
It uses a stream rather than the direct network access so it could also work for streams on serial connections etc.

Structure:
	stream				stream representing the connection to and from the server
	connectInfo			information required for opening a connection
	lastResponse			remembers the last response from the server.
	progressObservers 	any object understanding #show: can be registered as a progress observer (login, transfer, etc)
"
Class {
	#name : #ProtocolClient,
	#superclass : #Object,
	#instVars : [
		'stream',
		'connectInfo',
		'serverCapabilities',
		'lastResponse',
		'pendingResponses',
		'progressObservers'
	],
	#category : #'Network-Protocols'
}

{ #category : #accessing }
ProtocolClient class >> defaultPortNumber [
	self subclassResponsibility
]

{ #category : #accessing }
ProtocolClient class >> logFlag [
	self subclassResponsibility
]

{ #category : #'instance creation' }
ProtocolClient class >> openOnHost: hostIP port: portNumber [
	^self new openOnHost: hostIP port: portNumber
]

{ #category : #'instance creation' }
ProtocolClient class >> openOnHostNamed: hostNameAndPort [
	"If the hostname uses the colon syntax to express a certain port number we use that instead of the default port number."

	^self new openOnHostNamed: hostNameAndPort
	
]

{ #category : #'instance creation' }
ProtocolClient class >> openOnHostNamed: hostName port: portNumber [

	^ self new openOnHostNamed: hostName port: portNumber
]

{ #category : #retrieval }
ProtocolClient class >> retrieveMIMEDocument: aURI [
	self subclassResponsibility
]

{ #category : #'private protocol' }
ProtocolClient >> checkForPendingError [
	"If data is waiting, check it to catch any error reports.
	In case the response is not an error, push it back."

	self stream isDataAvailable
		ifFalse: [^self].
	self fetchNextResponse.
	self
		checkResponse: self lastResponse
		onError: [:response | (TelnetProtocolError protocolInstance: self) signal]
		onWarning: [:response | (TelnetProtocolError protocolInstance: self) signal].
	"if we get here, it wasn't an error"
	self pushResponse: self lastResponse
]

{ #category : #'private protocol' }
ProtocolClient >> checkResponse [
	"Get the response from the server and check for errors."

	self
		checkResponseOnError: [:response | (TelnetProtocolError protocolInstance: self) signal]
		onWarning: [:response | (TelnetProtocolError protocolInstance: self) signal].

]

{ #category : #'private protocol' }
ProtocolClient >> checkResponse: aResponse onError: errorBlock onWarning: warningBlock [
	"Get the response from the server and check for errors. Invoke one of the blocks if an error or warning is encountered. See class comment for classification of error codes."

	self responseIsError
		ifTrue: [errorBlock value: aResponse].
	self responseIsWarning
		ifTrue: [warningBlock value: aResponse].

]

{ #category : #'private protocol' }
ProtocolClient >> checkResponseOnError: errorBlock onWarning: warningBlock [
	"Get the response from the server and check for errors. Invoke one of the blocks if an error or warning is encountered. See class comment for classification of error codes."

	self fetchPendingResponse.
	self checkResponse: self lastResponse onError: errorBlock onWarning: warningBlock
]

{ #category : #actions }
ProtocolClient >> close [
	self stream
		ifNotNil: [
			self stream close.
			stream := nil]
]

{ #category : #private }
ProtocolClient >> connectionInfo [
	connectInfo ifNil: [connectInfo := Dictionary new].
	^connectInfo
]

{ #category : #private }
ProtocolClient >> defaultPortNumber [
	^self class defaultPortNumber
]

{ #category : #private }
ProtocolClient >> ensureConnection [
	self isConnected
		ifTrue: [^self].
	self stream
		ifNotNil: [self stream close].

	self stream: (SocketStream openConnectionToHost: self host port: self port).
	self checkResponse.
	self login
]

{ #category : #'private protocol' }
ProtocolClient >> fetchNextResponse [
	self lastResponse: self stream nextLine
]

{ #category : #'private protocol' }
ProtocolClient >> fetchPendingResponse [
	^pendingResponses
		ifNil: [self fetchNextResponse; lastResponse]
		ifNotNil: [self popResponse]
]

{ #category : #private }
ProtocolClient >> host [
	^self connectionInfo at: #host
]

{ #category : #private }
ProtocolClient >> host: hostId [
	^self connectionInfo at: #host put: hostId
]

{ #category : #private }
ProtocolClient >> hostName [

	^ self connectionInfo at: #hostName ifAbsent: [NetNameResolver nameForAddress: self host]
]

{ #category : #private }
ProtocolClient >> hostName: aString [

	^ self connectionInfo at: #hostName put: aString
]

{ #category : #testing }
ProtocolClient >> isConnected [
	^stream notNil
		and: [stream isConnected]
]

{ #category : #private }
ProtocolClient >> lastResponse [
	^lastResponse
]

{ #category : #private }
ProtocolClient >> lastResponse: aString [
	lastResponse := aString.

]

{ #category : #private }
ProtocolClient >> logFlag [
	^self class logFlag
]

{ #category : #private }
ProtocolClient >> logProgress: aString [
	self progressObservers do: [:each | each show: aString].

]

{ #category : #accessing }
ProtocolClient >> logProgressToTranscript [
	self progressObservers add: Transcript
]

{ #category : #accessing }
ProtocolClient >> messageText [
	^super messageText
		ifNil: [self response]
]

{ #category : #private }
ProtocolClient >> openOnHost: hostIP port: portNumber [
	"open a connection to a specific port on a host for which we have the IP number. 
	We handle any login if the user and password are set"
	self host: hostIP.
	self port: portNumber.
	self ensureConnection
]

{ #category : #private }
ProtocolClient >> openOnHostNamed: hostNameAndPort [
	"If the hostname uses the colon syntax to express a certain port number
	we use that instead of the default port number."

	| thing hostName port |
	"derive a host name and port number"
	thing := hostNameAndPort splitBy: ':'.
	hostName := thing first.
	port := (thing at: 2 ifAbsent: [self defaultPortNumber]) asInteger.
	
	^self openOnHostNamed: hostName port: port
	
]

{ #category : #private }
ProtocolClient >> openOnHostNamed: hostName port: portNumber [
	"open a connection to a specific port on a server"
	| serverIP |
	serverIP := NetNameResolver addressForName: hostName timeout: 20.
	self 
		hostName: hostName;
		openOnHost: serverIP port: portNumber
]

{ #category : #private }
ProtocolClient >> parseCapabilities: lines [

	self serverCapabilities addAll: (lines select: [:l | l notEmpty] 
			thenCollect: [:l | | tokens capability values |
				tokens := l findTokens: String space.
				capability := tokens first asSymbol.
				values := tokens allButFirst
					ifEmpty: [true]
					ifNotEmpty: [:rawValues | rawValues collect: [:v | 
						v isAllDigits
							ifTrue: [v asNumber]
							ifFalse: [v asSymbol]]].
				capability -> values])
]

{ #category : #private }
ProtocolClient >> password [
	^self connectionInfo at: #password
]

{ #category : #private }
ProtocolClient >> password: aString [
	^self connectionInfo at: #password put: aString
]

{ #category : #private }
ProtocolClient >> pendingResponses [
	pendingResponses ifNil: [pendingResponses := OrderedCollection new].
	^pendingResponses
]

{ #category : #private }
ProtocolClient >> popResponse [
	| pendingResponse |
	pendingResponse := self pendingResponses removeFirst.
	pendingResponses isEmpty
		ifTrue: [pendingResponses := nil].
	^pendingResponse
]

{ #category : #private }
ProtocolClient >> port [
	^self connectionInfo at: #port
]

{ #category : #private }
ProtocolClient >> port: aPortNumber [
	^self connectionInfo at: #port put: aPortNumber
]

{ #category : #private }
ProtocolClient >> progressObservers [
	progressObservers ifNil: [progressObservers := OrderedCollection new].
	^progressObservers
]

{ #category : #private }
ProtocolClient >> pushResponse: aResponse [
	self pendingResponses add: aResponse
]

{ #category : #actions }
ProtocolClient >> reopen [
	self ensureConnection
]

{ #category : #private }
ProtocolClient >> resetConnectionInfo [
	connectInfo := nil
]

{ #category : #accessing }
ProtocolClient >> response [
	^self protocolInstance lastResponse
]

{ #category : #'private testing' }
ProtocolClient >> responseIsError [
	self subclassResponsibility
]

{ #category : #'private protocol' }
ProtocolClient >> responseIsSuccess [

	^ self responseCode = 220
]

{ #category : #'private testing' }
ProtocolClient >> responseIsWarning [
	self subclassResponsibility
]

{ #category : #'private protocol' }
ProtocolClient >> sendCommand: aString [
	self stream sendCommand: aString.

]

{ #category : #'private protocol' }
ProtocolClient >> sendStreamContents: aStream [
	self stream sendStreamContents: aStream
]

{ #category : #private }
ProtocolClient >> serverCapabilities [
	serverCapabilities ifNil: [serverCapabilities := Dictionary new].
	^serverCapabilities
]

{ #category : #testing }
ProtocolClient >> serverSupportsStarttls [

	^ self serverCapabilities at: self starttlsVerb ifAbsent: [false]
]

{ #category : #private }
ProtocolClient >> standardTimeout [

	^ Socket standardTimeout
]

{ #category : #'private protocol' }
ProtocolClient >> starttls [
	Smalltalk at: #SqueakSSL ifAbsent:[self error: 'SqueakSSL is missing'].
	
	self sendCommand: self starttlsVerb.
	self checkResponse.
	self responseIsSuccess ifTrue: [
		stream := SqueakSSL secureSocketStream on: stream socket.
		stream sslConnectTo: self hostName.
		self connectionInfo at: #tlsActive put: true].
]

{ #category : #private }
ProtocolClient >> starttlsVerb [

	^ #STARTTLS
]

{ #category : #accessing }
ProtocolClient >> stream [
	^stream
]

{ #category : #accessing }
ProtocolClient >> stream: aStream [
	stream := aStream
]

{ #category : #testing }
ProtocolClient >> tlsIsActive [

	^ self connectionInfo at: #tlsActive ifAbsent: [false]
]

{ #category : #private }
ProtocolClient >> user [
	^self connectionInfo at: #user ifAbsent: [nil]
]

{ #category : #private }
ProtocolClient >> user: aString [
	^self connectionInfo at: #user put: aString
]

{ #category : #'private testing' }
ProtocolClient >> wantsStarttls [

	^ self serverSupportsStarttls
]
