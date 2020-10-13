Class {
	#name : #NebraskaIncomingMessage,
	#superclass : #Object,
	#classVars : [
		'MessageHandlers',
		'MessageTypes'
	],
	#category : #'Nebraska-Network-Communications'
}

{ #category : #'message types' }
NebraskaIncomingMessage class >> allTypes [

	^MessageTypes ifNil: [
		MessageTypes := {
			self typeKeyboardChat.
			self typeMorph.
			self typeFridge.
			self typeStatusRequest.
			self typeStatusReply.
			self typeSeeDesktop.
			self typeMultiChat.
		}
	]

]

{ #category : #'as yet unclassified' }
NebraskaIncomingMessage class >> forType: aMessageType send: aSymbol to: anObject [

	self messageHandlers at: aMessageType put: {aSymbol. anObject}
]

{ #category : #handlers }
NebraskaIncomingMessage class >> handleNewChatFrom: dataStream sentBy: senderName ipAddress: ipAddressString [

	^ NebraskaChatMorph 
		chatFrom: ipAddressString 
		name: senderName 
		text: (self newObjectFromStream: dataStream).
	
]

{ #category : #handlers }
NebraskaIncomingMessage class >> handleNewFridgeMorphFrom: dataStream sentBy: senderName ipAddress: ipAddressString [

	| newObject |

	newObject := self newObjectFromStream: dataStream.
	newObject
		setProperty: #fridgeSender toValue: senderName;
		setProperty: #fridgeIPAddress toValue: ipAddressString;
		setProperty: #fridgeDate toValue: Time dateAndTimeNow.
	WorldState addDeferredUIMessage: [NebraskaFridgeMorph newItem: newObject].
	
]

{ #category : #handlers }
NebraskaIncomingMessage class >> handleNewMorphFrom: dataStream sentBy: senderName ipAddress: ipAddressString [

	| newObject thumbForm targetWorld |

	newObject := self newObjectFromStream: dataStream.
	NebraskaCommunicatorMorph playArrivalSound.
	targetWorld := self currentWorld.
	(NebraskaMorphsWelcomeMorph morphsWelcomeInWorld: targetWorld) ifTrue: [
		newObject position: (
			newObject 
				valueOfProperty: #positionInOriginatingWorld 
				ifAbsent: [(targetWorld randomBoundsFor: newObject) topLeft]
		).
		WorldState addDeferredUIMessage: [
			newObject openInWorld: targetWorld.
		].
		^self
	].
	thumbForm := newObject imageForm scaledToSize: 50@50.
	Smalltalk at: #SugarListenerMorph ifPresent: [:c |
		c addToGlobalIncomingQueue: {
			thumbForm. newObject. senderName. ipAddressString
		}.
		WorldState addDeferredUIMessage: [
			c ensureListenerInCurrentWorld
		].
	].
]

{ #category : #handlers }
NebraskaIncomingMessage class >> handleNewMultiChatFrom: dataStream sentBy: senderName ipAddress: ipAddressString [

	^ NebraskaMultiChatMorph 
		chatFrom: ipAddressString 
		name: senderName 
		text: (self newObjectFromStream: dataStream).
	
]

{ #category : #handlers }
NebraskaIncomingMessage class >> handleNewSeeDesktopFrom: dataStream sentBy: senderName ipAddress: ipAddressString [

	"more later"

	^ NebraskaChatMorph 
		chatFrom: ipAddressString 
		name: senderName 
		text: ipAddressString,' would like to see your desktop' translated.
	
]

{ #category : #handlers }
NebraskaIncomingMessage class >> handleNewStatusReplyFrom: dataStream sentBy: senderName ipAddress: ipAddressString [

	(NebraskaGateKeeperMorph entryForIPAddress: ipAddressString) statusReplyReceived: (
		self newObjectFromStream: dataStream
	)

]

{ #category : #handlers }
NebraskaIncomingMessage class >> handleNewStatusRequestFrom: dataStream sentBy: senderName ipAddress: ipAddressString [

	"more later"

	^ NebraskaChatMorph 
		chatFrom: ipAddressString 
		name: senderName 
		text: ipAddressString,' would like to know if you are available' translated.
	
]

{ #category : #'as yet unclassified' }
NebraskaIncomingMessage class >> initializeMessageHandlers [

	self
		forType: self typeMorph 
		send: #handleNewMorphFrom:sentBy:ipAddress: 
		to: self;

		forType: self typeFridge 
		send: #handleNewFridgeMorphFrom:sentBy:ipAddress: 
		to: self;

		forType: self typeKeyboardChat 
		send: #handleNewChatFrom:sentBy:ipAddress: 
		to: self;

		forType: self typeMultiChat 
		send: #handleNewMultiChatFrom:sentBy:ipAddress: 
		to: self;

		forType: self typeStatusRequest 
		send: #handleNewStatusRequestFrom:sentBy:ipAddress: 
		to: self;

		forType: self typeStatusReply 
		send: #handleNewStatusReplyFrom:sentBy:ipAddress: 
		to: self;

		forType: self typeSeeDesktop 
		send: #handleNewSeeDesktopFrom:sentBy:ipAddress: 
		to: self.



]

{ #category : #'as yet unclassified' }
NebraskaIncomingMessage class >> messageHandlers [

	^MessageHandlers ifNil: [MessageHandlers := Dictionary new].
]

{ #category : #'as yet unclassified' }
NebraskaIncomingMessage class >> newObjectFromStream: dataStream [

	| newObject |

	[newObject := SmartRefStream objectFromStreamedRepresentation: dataStream upToEnd.]
		on: ProgressInitiationException
		do: [ :ex | 
			ex sendNotificationsTo: [ :min :max :curr |
				"self flashIndicator: #working."
			].
		].
	"self resetIndicator: #working."
	^newObject

]

{ #category : #'message types' }
NebraskaIncomingMessage class >> registerType: aMessageType [

	MessageTypes := self allTypes copyWith: aMessageType
]

{ #category : #'message types' }
NebraskaIncomingMessage class >> typeAudioChat [

	^'audiochat'
]

{ #category : #'message types' }
NebraskaIncomingMessage class >> typeAudioChatContinuous [

	^'audiochat2'
]

{ #category : #'message types' }
NebraskaIncomingMessage class >> typeFridge [

	^'fridge'
]

{ #category : #'message types' }
NebraskaIncomingMessage class >> typeKeyboardChat [

	^'chat'
]

{ #category : #'message types' }
NebraskaIncomingMessage class >> typeMorph [

	^'morph'
]

{ #category : #'message types' }
NebraskaIncomingMessage class >> typeMultiChat [

	^'multichat'
]

{ #category : #'message types' }
NebraskaIncomingMessage class >> typeSeeDesktop [

	^'seedesktop'
]

{ #category : #'message types' }
NebraskaIncomingMessage class >> typeStatusReply [

	^'statusreply'
]

{ #category : #'message types' }
NebraskaIncomingMessage class >> typeStatusRequest [

	^'statusrequest'
]

{ #category : #'message types' }
NebraskaIncomingMessage class >> unregisterType: aMessageType [

	MessageTypes := self allTypes copyWithout: aMessageType
]

{ #category : #'as yet unclassified' }
NebraskaIncomingMessage >> incomingMessgage: dataStream fromIPAddress: ipAddress [

	| nullChar messageType senderName  selectorAndReceiver |

	nullChar := 0 asCharacter.
	messageType := dataStream upTo: nullChar.
	senderName := dataStream upTo: nullChar.
	(NebraskaGateKeeperMorph acceptRequest: messageType from: senderName at: ipAddress) ifFalse: [
		^self
	].
	selectorAndReceiver := self class messageHandlers at: messageType ifAbsent: [^self].
	^selectorAndReceiver second 
		perform: selectorAndReceiver first 
		withArguments: {dataStream. senderName. ipAddress}


]
