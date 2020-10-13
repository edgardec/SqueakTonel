"
A client that has connected to a Nebraska server, seen from the server's point of view.
"
Class {
	#name : #NebraskaClient,
	#superclass : #Object,
	#instVars : [
		'connection',
		'encoder',
		'hand',
		'canvas'
	],
	#category : #'Nebraska-Morphic-Remote'
}

{ #category : #'instance creation' }
NebraskaClient class >> onConnection: aStringSocket [
	^self new initialize: aStringSocket
]

{ #category : #'as yet unclassified' }
NebraskaClient >> backlog [

	^connection backlog
]

{ #category : #attributes }
NebraskaClient >> canvas [
	"return the hand this canvas that should be drawn on for this client"
	^canvas
]

{ #category : #initialization }
NebraskaClient >> convertToBuffered [

	canvas purgeOutputQueue.
	canvas := canvas asBufferedCanvas.
]

{ #category : #'as yet unclassified' }
NebraskaClient >> currentStatusString [

	(connection isNil or: [connection isConnected not]) ifTrue: [^'nada'].
	^connection remoteSocketAddress hostNumber,
		' - ',
		(self backlog // 1024) printString,'k'
]

{ #category : #initialization }
NebraskaClient >> destroy [
	hand ifNotNil:[hand world ifNotNil:[hand world removeHand: hand]].
	connection ifNotNil:[connection destroy].
	encoder := canvas := hand := connection := nil.
]

{ #category : #network }
NebraskaClient >> extent: newExtent  depth: newDepth [
	encoder extent: newExtent  depth: newDepth
]

{ #category : #attributes }
NebraskaClient >> hand [
	"return the hand this client is controlling"
	^hand
]

{ #category : #initialization }
NebraskaClient >> initialize: aConnection [

	| remoteAddress userPicture |

	connection := aConnection.
	hand := RemoteControlledHandMorph on: (MorphicEventDecoder on: aConnection).
	hand nebraskaClient: self.
	remoteAddress := connection remoteSocketAddress.
	userPicture := NebraskaSenderMorph pictureForIPAddress: remoteAddress.
	hand
		userInitials: ((NebraskaSenderMorph nameForIPAddress: remoteAddress) ifNil: ['???'])
		andPicture: (userPicture ifNotNil: [userPicture scaledToSize: 16@20]).
	encoder := CanvasEncoder on: aConnection.
	canvas := RemoteCanvas
		connection: encoder
		clipRect: NebraskaServer extremelyBigRectangle
		transform: MorphicTransform identity
]

{ #category : #network }
NebraskaClient >> isConnected [
	^connection isConnected
]

{ #category : #network }
NebraskaClient >> processIO [
	connection processIO.
]
