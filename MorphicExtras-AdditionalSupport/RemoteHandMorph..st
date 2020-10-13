Class {
	#name : #RemoteHandMorph,
	#superclass : #HandMorph,
	#instVars : [
		'remoteWorldExtent',
		'remoteAddress',
		'sendSocket',
		'sendBuffer',
		'sendState',
		'socket',
		'waitingForConnection',
		'receiveBuffer'
	],
	#category : #'MorphicExtras-AdditionalSupport'
}

{ #category : #utilities }
RemoteHandMorph class >> ensureNetworkConnected [
	"Try to ensure that an intermittent network connection, such as a dialup or ISDN line, is actually connected. This is necessary to make sure a server is visible in order to accept an incoming connection. If the network connection does not work - the user has given up - return false. Otherwise, return true."
	"RemoteHandMorph ensureNetworkConnected"
	| address |
	UIManager default
		informUser: 'Ensuring your network connection works...'
		during: [
			address := (NetNameResolver
				addressForName: 'squeak.org'
				timeout: 30)].
	^ address notNil.
]

{ #category : #private }
RemoteHandMorph >> appendNewDataToReceiveBuffer [
	"Append all available raw data to my receive buffer. Assume that my socket is not nil."

	| newData tempBuf bytesRead |
	socket dataAvailable ifTrue: [
		"get all the data currently available"
		newData := WriteStream on: (String new: receiveBuffer size + 1000).
		newData nextPutAll: receiveBuffer.
		tempBuf := String new: 1000.
		[socket dataAvailable] whileTrue: [
			bytesRead := socket receiveDataInto: tempBuf.
			1 to: bytesRead do: [:i | newData nextPut: (tempBuf at: i)]].
		receiveBuffer := newData contents].

]

{ #category : #drawing }
RemoteHandMorph >> drawOn: aCanvas [
	"For remote cursors, always draw the hand itself (i.e., the cursor)."

	super drawOn: aCanvas.
	aCanvas paintImage: NormalCursor at: self position.

]

{ #category : #private }
RemoteHandMorph >> getNextRemoteEvent [
	"Return the next remote event, or nil if the receive buffer does not contain a full event record. An event record is the storeString for a MorphicEvent terminated by a <CR> character."

	| i s evt |
	self receiveData.
	receiveBuffer isEmpty ifTrue: [^ nil].

	i := receiveBuffer indexOf: Character cr ifAbsent: [^ nil].
	s := receiveBuffer copyFrom: 1 to: i - 1.
	receiveBuffer := receiveBuffer copyFrom: i + 1 to: receiveBuffer size.
	evt := (MorphicEvent readFromString: s).
	evt ifNil:[^nil].
	evt setHand: self.
	evt isKeyboard ifTrue:[evt setPosition: self position].
	^evt resetHandlerFields
]

{ #category : #'events-processing' }
RemoteHandMorph >> handleListenEvent: anEvent [
	"Transmit the event to interested listeners"
	| currentExtent |
	currentExtent := self worldBounds extent.
	self lastWorldExtent ~= currentExtent ifTrue: [
		self transmitEvent: (MorphicUnknownEvent new setType: #worldExtent argument: currentExtent).
		self lastWorldExtent: currentExtent].
	self transmitEvent: anEvent.
]

{ #category : #initialization }
RemoteHandMorph >> initialize [

	super initialize.
	remoteWorldExtent := 100@100.  "initial guess"
	socket := nil.
	waitingForConnection := false.
	receiveBuffer := ''.
	sendState := #unconnected.
]

{ #category : #connections }
RemoteHandMorph >> lastEventTransmitted [
	^self valueOfProperty: #lastEventTransmitted
]

{ #category : #connections }
RemoteHandMorph >> lastEventTransmitted: anEvent [
	^self setProperty: #lastEventTransmitted toValue: anEvent
]

{ #category : #connections }
RemoteHandMorph >> lastWorldExtent [
	^self valueOfProperty: #lastWorldExtent
]

{ #category : #connections }
RemoteHandMorph >> lastWorldExtent: extent [
	^self setProperty: #lastWorldExtent toValue: extent
]

{ #category : #drawing }
RemoteHandMorph >> needsToBeDrawn [

	^true
]

{ #category : #'event handling' }
RemoteHandMorph >> processEvents [
	"Process user input events from the remote input devices."

	| evt |
	evt := self getNextRemoteEvent.
	[evt notNil] whileTrue: 
			[evt type == #worldExtent 
				ifTrue: 
					[remoteWorldExtent := evt argument.
					^self].
			self handleEvent: evt.
			evt := self getNextRemoteEvent]
]

{ #category : #connections }
RemoteHandMorph >> readyToTransmit [
	"Return true if the receiver is ready to send."

	(sendState == #connected) ifTrue:[
		 sendSocket sendDone ifFalse:[^false].
		^true].

	sendState == #opening ifTrue:[
		sendSocket isConnected ifTrue:[^true].
		sendSocket isWaitingForConnection ifFalse:[
			Transcript show: 'trying connection again...'; cr.
			sendSocket destroy.
			sendSocket := Socket new.
			sendSocket connectTo: self remoteHostAddress port: 54323]].

	sendState == #closing ifTrue:[
		sendSocket isUnconnectedOrInvalid ifTrue:[
			sendSocket destroy.
			sendState := #unconnected]].

	^false
]

{ #category : #private }
RemoteHandMorph >> receiveData [
	"Check my connection status and withdraw from the world if the connection has been broken. Append any data that has arrived to receiveBuffer. "

	socket ifNotNil: [
		socket isConnected
			ifTrue: [  "connected"
				waitingForConnection ifTrue: [
					Transcript show: 'Remote hand ', userInitials, ' connected'; cr.
					waitingForConnection := false].
				self appendNewDataToReceiveBuffer]
			ifFalse: [  "not connected"
				waitingForConnection ifFalse: [
					"connection was established, then broken"
					self withdrawFromWorld.
					receiveBuffer := '']]].

]

{ #category : #connections }
RemoteHandMorph >> remoteHostAddress [
	"Return the address of the remote host or zero if not connected."
	^remoteAddress ifNil:[0]
]

{ #category : #connections }
RemoteHandMorph >> startListening [
	"Create a socket and start listening for a connection."

	self stopListening.
	Transcript show: 'My address is ', NetNameResolver localAddressString; cr.
	Transcript show: 'Remote hand ', self userInitials, ' waiting for a connection...'; cr.
	socket := Socket new.
	socket listenOn: 54323.
	waitingForConnection := true.

]

{ #category : #connections }
RemoteHandMorph >> startTransmittingEvents [
	"Attempt to broadcast events from this hand to a remote hand on the host with the given address. This method just creates the new socket and initiates a connection; it does not wait for the other end to answer."
	(sendSocket notNil and:[sendSocket isConnected]) ifTrue:[^self].
	Transcript
		show: 'Connecting to remote WorldMorph at ';
		show: (NetNameResolver stringFromAddress: self remoteHostAddress), ' ...'; cr.
	sendSocket := Socket newTCP.
	sendSocket connectTo: self remoteHostAddress port: 54323.
	sendState := #opening.
	owner primaryHand addEventListener: self.
]

{ #category : #connections }
RemoteHandMorph >> startTransmittingEventsTo: remoteAddr [
	"Attempt to broadcast events from this hand to a remote hand on the host with the given address. This method just creates the new socket and initiates a connection; it does not wait for the other end to answer."
	remoteAddress := remoteAddr.
	(sendSocket notNil and:[sendSocket isConnected]) ifTrue:[^self].
	Transcript
		show: 'Connecting to remote WorldMorph at ';
		show: (NetNameResolver stringFromAddress: self remoteHostAddress), ' ...'; cr.
	sendSocket := Socket newTCP.
	sendSocket connectTo: self remoteHostAddress port: 54323.
	sendState := #opening.
	owner primaryHand addEventListener: self.
]

{ #category : #connections }
RemoteHandMorph >> stopListening [
	"Destroy the socket, if any, terminating the connection."

	socket ifNotNil: [
		socket destroy.
		socket := nil].

]

{ #category : #connections }
RemoteHandMorph >> stopTransmittingEvents [
	"Stop broadcasting events from this world's cursor to a remote cursor on the host with the given address. This method issues a 'close' but does not destroy the socket; it will be destroyed when the other end reads the last data and closes the connection."
	(sendSocket isUnconnectedOrInvalid) ifFalse:[
		sendSocket close.
		sendState := #closing].
	owner primaryHand removeEventListener: self.
]

{ #category : #'event handling' }
RemoteHandMorph >> transmitEvent: aMorphicEvent [
	"Transmit the given event to all remote connections."
	| firstEvt |
	self readyToTransmit ifFalse: [^ self].
	self lastEventTransmitted = aMorphicEvent ifTrue: [^ self].
	sendBuffer ifNil: [sendBuffer := WriteStream on: (String new: 10000)].
	sendBuffer nextPutAll: aMorphicEvent storeString; cr.
	self lastEventTransmitted: aMorphicEvent.

	sendSocket isConnected ifTrue:[
		sendState = #opening ifTrue: [
			"connection established; disable TCP delays on sends"
			sendSocket setOption: 'TCP_NODELAY' value: true.
			"send worldExtent as first event"
			firstEvt := MorphicUnknownEvent type: #worldBounds argument: self worldBounds extent.
			sendSocket sendData: firstEvt storeString, (String with: Character cr).
			Transcript
				show: 'Connection established with remote WorldMorph at ';
				show: (NetNameResolver stringFromAddress: sendSocket remoteAddress); cr.
			sendState := #connected].
		sendSocket sendData: sendBuffer contents.
	] ifFalse: [
		owner primaryHand removeEventListener: self.
		sendState = #connected ifTrue: [
			"other end has closed; close our end"
			Transcript
				show: 'Closing connection with remote WorldMorph at ';
				show: (NetNameResolver stringFromAddress: sendSocket remoteAddress); cr.
			sendSocket close.
		sendState := #closing]].

	sendBuffer reset.

]

{ #category : #other }
RemoteHandMorph >> withdrawFromWorld [
	"Close the socket, if any, and remove this hand from the world."
	| addr |
	addr := self remoteHostAddress.
	addr = 0 ifFalse: [self stopTransmittingEvents].
	self stopListening.
	Transcript show: 'Remote hand ', self userInitials, ' closed'; cr.
	owner ifNotNil: [owner removeHand: self].

]

{ #category : #geometry }
RemoteHandMorph >> worldBounds [

	^ 0@0 extent: remoteWorldExtent

]
