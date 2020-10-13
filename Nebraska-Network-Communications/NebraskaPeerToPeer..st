Class {
	#name : #NebraskaPeerToPeer,
	#superclass : #Object,
	#instVars : [
		'socket',
		'communicatorMorph',
		'process',
		'ipAddress',
		'connectionQueue',
		'dataQueue',
		'remoteSocketAddress',
		'leftOverData'
	],
	#classVars : [
		'DEBUG',
		'PREVTICK'
	],
	#category : #'Nebraska-Network-Communications'
}

{ #category : #'as yet unclassified' }
NebraskaPeerToPeer class >> eToyCommunicationsPort [

	^34151		"picked at random"
]

{ #category : #'as yet unclassified' }
NebraskaPeerToPeer class >> eToyCommunicationsPorts [
	^ 34151 to: 34159
]

{ #category : #'as yet unclassified' }
NebraskaPeerToPeer class >> transmitStreamedObject: outData as: objectCategory to: anIPAddress for: aCommunicator [

	| null |
	null := String with: 0 asCharacter.
	self new 
		sendSomeData: {
			objectCategory,null. 
			Preferences defaultAuthorName,null.
			outData
		}
		to: anIPAddress
		for: aCommunicator


]

{ #category : #receiving }
NebraskaPeerToPeer >> awaitDataFor: aCommunicatorMorph [

	Socket initializeNetwork.
	connectionQueue := ConnectionQueue 
		portNumber: self class eToyCommunicationsPorts 
		queueLength: 6.
	communicatorMorph := aCommunicatorMorph.
	process := [self doAwaitData] newProcess.
	process priority: Processor highIOPriority.
	process resume.

]

{ #category : #receiving }
NebraskaPeerToPeer >> doAwaitData [

	[
		socket := connectionQueue getConnectionOrNilLenient.
		socket ifNil: [
			(Delay forMilliseconds: 50) wait
		] ifNotNil: [
			self class new receiveDataOn: socket for: communicatorMorph
		]
	] repeat

]

{ #category : #sending }
NebraskaPeerToPeer >> doConnectForSend [

	| addr port |

	addr := NetNameResolver addressForName: (ipAddress copyUpTo: $:).
	addr ifNil: [
		communicatorMorph commResult: {#message -> ('could not find ',ipAddress)}.
		^false].

	port := (ipAddress copyAfter: $:) asInteger.
	port ifNil: [port := self class eToyCommunicationsPorts first].

	socket connectNonBlockingTo: addr port: port.
	[socket waitForConnectionFor: 15]
		on: ConnectionTimedOut
		do: [:ex |
			communicatorMorph commResult: {#message -> ('no connection to ',ipAddress,' (',
				ipAddress,')')}.
			^false].
	^true


]

{ #category : #receiving }
NebraskaPeerToPeer >> doReceiveData [

	| answer |

	answer := [self doReceiveOneMessage] 
		on: Error
		do: [ :ex | 
			communicatorMorph commResult: {#message -> (ex description,' ',socket printString)}.
			^false
		].
	communicatorMorph commResult: {
		#message -> 'OK'. 
		#data -> answer .
		#ipAddress -> remoteSocketAddress.
	}.
	^answer size > 0


]

{ #category : #receiving }
NebraskaPeerToPeer >> doReceiveOneMessage [

	| awaitingLength i length answer header |

	awaitingLength := true.
	answer := WriteStream on: String new.
	[awaitingLength] whileTrue: [
		leftOverData := leftOverData , socket receiveData.
		(i := leftOverData indexOf: $ ) > 0 ifTrue: [
			awaitingLength := false.
			header := leftOverData first: i - 1.
			length := header asNumber.
			self parseOptionalHeader: header.
			answer nextPutAll: (leftOverData allButFirst: i).
		].
	].
	leftOverData := ''.
	[answer size < length] whileTrue: [
		answer nextPutAll: socket receiveData.
		communicatorMorph commResult: {#commFlash -> true}.
	].
	answer := answer contents.
	answer size > length ifTrue: [
		leftOverData := answer allButFirst: length.
		answer := answer first: length
	].
	^answer


]

{ #category : #sending }
NebraskaPeerToPeer >> doSendData [

	| totalLength myData allTheData |

	myData := dataQueue next ifNil: [socket sendData: '0 '. ^false].
	totalLength := (myData collect: [ :x | x size]) sum.
	socket sendData: totalLength printString, self makeOptionalHeader, ' '.
	allTheData := WriteStream on: (String new: totalLength).
	myData do: [ :chunk | allTheData nextPutAll: chunk asString].
	NebraskaDebug at: #peerBytesSent add: {totalLength}.
	self sendDataCautiously: allTheData contents.
	^true


]

{ #category : #sending }
NebraskaPeerToPeer >> listeningPort [
	^connectionQueue portNumberOrNil
]

{ #category : #sending }
NebraskaPeerToPeer >> makeOptionalHeader [
	"Optional header format is '(key:value;key:value)' and it must not contain spaces. This is designed to be backwards-compatible with old receivers who receive a header as anything up to a space, but only actually use an initial size integer"

	| args p t |
	args := OrderedCollection new.

	p := NebraskaListenerMorph listeningPort.
	(p notNil and: [p ~= self class eToyCommunicationsPorts first])
		ifTrue: [args add: 'port:', p asString].

	t := (Smalltalk classNamed: 'SugarLauncher') ifNotNil: [:l | l current listeningTube].
	t ifNotNil: [args add: 'tube:', t asString].

	^args isEmpty
		ifTrue: ['']
		ifFalse: [String streamContents: [:strm |
			strm nextPut: $(.
			args
				do: [:arg | strm nextPutAll: arg]
				separatedBy: [strm nextPut: $;].
			strm nextPut: $)]].

]

{ #category : #receiving }
NebraskaPeerToPeer >> parseOptionalHeader: aString [
	"header used to be just an integer, was extended to have optional parameters (see makeOptionalHeader)"

	(((aString copyAfter: $() copyUpTo: $)) findTokens: $;) do: [:item |
		(item beginsWith: 'port:')
			ifTrue: [self receivedPort: (item copyAfter: $:)].
		(item beginsWith: 'tube:')
			ifTrue: [self receivedTube: (item copyAfter: $:)].]
]

{ #category : #receiving }
NebraskaPeerToPeer >> receiveDataOn: aSocket for: aCommunicatorMorph [

	socket := aSocket.
	remoteSocketAddress := socket remoteSocketAddress hostNumber.
	communicatorMorph := aCommunicatorMorph.
	process := [
		leftOverData := ''.
		[self doReceiveData] whileTrue.
		socket closeAndDestroy.
	] newProcess.
	process priority: Processor highIOPriority.
	process resume.

]

{ #category : #receiving }
NebraskaPeerToPeer >> receivedPort: aString [
	(remoteSocketAddress includes: $:) ifFalse: [
		remoteSocketAddress := remoteSocketAddress, ':', aString].
]

{ #category : #receiving }
NebraskaPeerToPeer >> receivedTube: aString [
	"Sender offers a tube for talking back. Get the tube's address."
	| addr |
	addr := (Smalltalk classNamed: 'SugarLauncher')
					ifNotNil: [:l | l current socketAddressForTube: aString].
	addr ifNotNil: [remoteSocketAddress := addr]
]

{ #category : #sending }
NebraskaPeerToPeer >> sendDataCautiously: aStringOrByteArray [
	"Send all of the data in the given array, even if it requires multiple calls to send it all. Return the number of bytes sent. Try not to send too much at once since this seemed to cause problems talking to a port on the same machine"

	| bytesSent bytesToSend count |

	bytesToSend := aStringOrByteArray size.
	bytesSent := 0.
	[bytesSent < bytesToSend] whileTrue: [
		count := socket 
			sendSomeData: aStringOrByteArray 
			startIndex: bytesSent + 1  
			count: (bytesToSend - bytesSent min: 4000).
		bytesSent := bytesSent + count.
		communicatorMorph commResult: {#commFlash -> true}.
		(Delay forMilliseconds: 10) wait.
	].
	^ bytesSent

]

{ #category : #sending }
NebraskaPeerToPeer >> sendSomeData: arrayOfByteObjects to: anIPAddress for: aCommunicatorMorph [

	dataQueue := self 
		sendSomeData: arrayOfByteObjects 
		to: anIPAddress 
		for: aCommunicatorMorph 
		multiple: false.
	dataQueue nextPut: nil.		"only this message to send"

]

{ #category : #sending }
NebraskaPeerToPeer >> sendSomeData: arrayOfByteObjects to: anIPAddress for: aCommunicatorMorph multiple: aBoolean [

	Socket initializeNetwork.
	socket := Socket newTCP.
	dataQueue := SharedQueue new.
	dataQueue nextPut: arrayOfByteObjects.
	communicatorMorph := aCommunicatorMorph.
	ipAddress := anIPAddress.
	process := [
		self doConnectForSend ifTrue: [
			[self doSendData] whileTrue.
			communicatorMorph commResult: {#message -> 'OK'}.
			socket closeAndDestroy.
		].
	] newProcess.
	process priority: Processor highIOPriority.
	process resume.
	^dataQueue

]

{ #category : #receiving }
NebraskaPeerToPeer >> stopListening [

	process ifNotNil: [process terminate. process := nil].
	connectionQueue ifNotNil: [connectionQueue destroy. connectionQueue := nil].


]
