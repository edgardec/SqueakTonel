"
A morph used to communicate with a remote image.  It sends all mouse/keyboard events to the remote side, and it displays canvas commands that are sent back.
"
Class {
	#name : #NetworkTerminalMorph,
	#superclass : #Morph,
	#instVars : [
		'connection',
		'decoder',
		'eventEncoder',
		'backgroundForm',
		'enteringHand'
	],
	#category : #'Nebraska-Morphic-Remote'
}

{ #category : #'instance creation' }
NetworkTerminalMorph class >> connectTo: hostAndPort [
	| host port |
	host := hostAndPort copyUpTo: $:.
	port := (hostAndPort copyAfter: $:) asInteger.
	port ifNil: [port := NebraskaServer defaultPorts first].
	^self connectTo: host port:port

]

{ #category : #'instance creation' }
NetworkTerminalMorph class >> connectTo: serverHost port: serverPort [

	| stringSock |

	stringSock := self socketConnectedTo: serverHost port: serverPort.
	^self new connection: stringSock

]

{ #category : #'instance creation' }
NetworkTerminalMorph class >> openAndConnectTo: serverHost [

	^self openAndConnectTo: serverHost port: NebraskaServer defaultPort


]

{ #category : #'instance creation' }
NetworkTerminalMorph class >> openAndConnectTo: serverHost port: serverPort [

	| stringSock me |

	stringSock := self socketConnectedTo: serverHost port: serverPort.
	me := self new connection: stringSock.
	^me openInStyle: #naked

]

{ #category : #'instance creation' }
NetworkTerminalMorph class >> socketConnectedTo: serverHost  port: serverPort [

	| sock |

	Socket initializeNetwork.
	sock := Socket new.
	[sock connectTo: (NetNameResolver addressForName: serverHost) port: serverPort]
		on: ConnectionTimedOut
		do: [:ex | self error: 'could not connect to server' translated ].
	^StringSocket on: sock


]

{ #category : #layout }
NetworkTerminalMorph >> acceptDroppingMorph: morphToDrop event: evt [

	| myCopy outData null |

	(morphToDrop isKindOf: NewHandleMorph) ifTrue: [			"don't send these"
		^morphToDrop rejectDropMorphEvent: evt.
	].
	self eToyRejectDropMorph: morphToDrop event: evt.		"we don't really want it"

	"7 mar 2001 - remove #veryDeepCopy"
	myCopy := morphToDrop.	"gradient fills require doing this second"
	myCopy setProperty: #positionInOriginatingWorld toValue: morphToDrop position.

	outData := myCopy eToyStreamedRepresentationNotifying: nil.
	null := String with: 0 asCharacter.
	NebraskaPeerToPeer new 
		sendSomeData: {
			NebraskaIncomingMessage typeMorph,null. 
			Preferences defaultAuthorName,null.
			outData
		}
		to: connection remoteSocketAddress hostNumber
		for: self.

]

{ #category : #'as yet unclassified' }
NetworkTerminalMorph >> addScalingMenuItems: menu hand: aHandMorph [

	"for comaptibility when in scaled frame"
]

{ #category : #drawing }
NetworkTerminalMorph >> areasRemainingToFill: aRectangle [
	"I assume that we are opaque"

	^ aRectangle areasOutside: self bounds
]

{ #category : #'event handling' }
NetworkTerminalMorph >> commResult: anArrayOfAssociations [

	"ignore for now"
]

{ #category : #initialization }
NetworkTerminalMorph >> connection: aConnection [

	connection := aConnection.
	decoder := CanvasDecoder connection: aConnection.
	eventEncoder := MorphicEventEncoder on: aConnection.
]

{ #category : #'shutting down' }
NetworkTerminalMorph >> disconnect [
	connection ifNotNil: [ connection destroy ].
	eventEncoder := connection := decoder := nil.
]

{ #category : #drawing }
NetworkTerminalMorph >> drawOn: aCanvas [

	backgroundForm ifNotNil: [
		aCanvas clipBy: bounds during: [ :c |
			c drawImage: backgroundForm at: bounds topLeft
		].
	].

]

{ #category : #geometry }
NetworkTerminalMorph >> extent: newExtent [

	super extent: newExtent.
	eventEncoder sendViewExtent: self extent
]

{ #category : #drawing }
NetworkTerminalMorph >> forceToFront: aRegion [
	| highQuality |
	"force the given region from the drawing form onto the background form"

	highQuality := false.		"highQuality is slower"

	self updateBackgroundForm.
	backgroundForm
		copy: aRegion
		from: aRegion topLeft
		in: decoder drawingForm
		rule: Form over.
	self invalidRect: (
		highQuality ifTrue: [
			bounds
		] ifFalse: [
			(aRegion expandBy: 4) translateBy: bounds topLeft	"try to remove gribblys"
		]
	)

]

{ #category : #'events-processing' }
NetworkTerminalMorph >> handleKeyDown: anEvent [
	anEvent wasHandled ifTrue:[^self].
	(self handlesKeyboard: anEvent) ifFalse:[^self].
	anEvent wasHandled: true.
	self sendEventAsIs: anEvent.
]

{ #category : #'events-processing' }
NetworkTerminalMorph >> handleKeyUp: anEvent [
	anEvent wasHandled ifTrue:[^self].
	(self handlesKeyboard: anEvent) ifFalse:[^self].
	anEvent wasHandled: true.
	self sendEventAsIs: anEvent.
]

{ #category : #'events-processing' }
NetworkTerminalMorph >> handleKeystroke: anEvent [
	anEvent wasHandled ifTrue:[^self].
	anEvent wasHandled: true.
	self sendEventAsIs: anEvent.
]

{ #category : #'events-processing' }
NetworkTerminalMorph >> handleMouseDown: anEvent [
	anEvent wasHandled ifTrue:[^self].
	anEvent hand removePendingBalloonFor: self.
	anEvent hand removePendingHaloFor: self.
	anEvent wasHandled: true.
	anEvent hand newMouseFocus: self event: anEvent.
	anEvent hand removeHaloFromClick: anEvent on: self.
	self sendEventAsIs: anEvent.
]

{ #category : #'events-processing' }
NetworkTerminalMorph >> handleMouseMove: anEvent [
	anEvent wasHandled ifTrue:[^self]. "not interested"
	(anEvent hand hasSubmorphs) ifTrue:[^self].
	(anEvent anyButtonPressed and:[anEvent hand mouseFocus ~~ self]) ifTrue:[^self].
	anEvent wasHandled: true.
	self sendEventAsIs: anEvent.
]

{ #category : #'events-processing' }
NetworkTerminalMorph >> handleMouseUp: anEvent [
	anEvent wasHandled ifTrue:[^self]. "not interested"
	anEvent hand mouseFocus == self ifFalse:[^self]. "Not interested in other parties"
	anEvent hand releaseMouseFocus: self.
	anEvent wasHandled: true.
	self sendEventAsIs: anEvent.
]

{ #category : #'events-processing' }
NetworkTerminalMorph >> handlerForMouseDown: anEvent [
	^self
]

{ #category : #'event handling' }
NetworkTerminalMorph >> handlesMouseOver: evt [
	^true
]

{ #category : #initialization }
NetworkTerminalMorph >> initialize [
	super initialize.
	backgroundForm := (
		(StringMorph contents: '......' font: (TextStyle default fontOfSize: 24))
			color: Color white
	) imageForm.
	bounds := backgroundForm boundingBox.

]

{ #category : #'event handling' }
NetworkTerminalMorph >> mouseEnter: evt [
	evt hand newKeyboardFocus: self.
	evt hand needsToBeDrawn ifTrue:[Cursor blank show].
]

{ #category : #'event handling' }
NetworkTerminalMorph >> mouseLeave: evt [

	evt hand needsToBeDrawn ifTrue:[Cursor normal show].
]

{ #category : #initialization }
NetworkTerminalMorph >> openInStyle: aSymbol [

	aSymbol == #naked ifTrue: [
		self openInWorld.
	].
	aSymbol == #scaled ifTrue: [
		self openScaled.
	].
	aSymbol == #bordered ifTrue: [
		AlignmentMorph newColumn
			hResizing: 	#shrinkWrap;
			vResizing: 	#shrinkWrap;
			borderWidth: 8;
			borderColor: Color blue;
			addMorph: self;
			openInWorld.
	].

	[
		[self world isNil] whileFalse: [(Delay forSeconds: 2) wait].
		self disconnect.
	] fork.


]

{ #category : #initialization }
NetworkTerminalMorph >> openScaled [

	| window tm |
	window := NetworkTerminalBorderMorph new
		minWidth: 100;
		minHeight: 100;
		borderWidth: 8;
		borderColor: Color orange;
		bounds: (0@0 extent: Display extent * 3 // 4).
	tm := BOBTransformationMorph new.
	tm useRegularWarpBlt: true.		"try to reduce memory used"
	window addMorphBack: tm.
	tm addMorph: self.
	window openInWorld.
	NebraskaNavigationMorph new 
		nebraskaBorder: window;
		nebraskaTerminal: self;
		openInWorld.
]

{ #category : #'shutting down' }
NetworkTerminalMorph >> requestBufferedConnection [

	eventEncoder ifNotNil: [eventEncoder requestBufferedConnection].

]

{ #category : #'event handling' }
NetworkTerminalMorph >> sendEvent: evt [

	self sendEventAsIs: (evt translatedBy: bounds topLeft negated).
]

{ #category : #'event handling' }
NetworkTerminalMorph >> sendEventAsIs: evt [

	eventEncoder ifNil: [ ^self ].
	eventEncoder sendEvent: evt.
]

{ #category : #'stepping and presenter' }
NetworkTerminalMorph >> step [

	decoder ifNil: [ ^self ].
	decoder processIOOnForce: [ :rectangle | self forceToFront: rectangle ].
]

{ #category : #testing }
NetworkTerminalMorph >> stepTime [
	^10
]

{ #category : #drawing }
NetworkTerminalMorph >> updateBackgroundForm [
	"make sure that our background form matches what the server has most recently requested"

	| drawingForm |

	drawingForm := decoder drawingForm.
	(drawingForm extent = backgroundForm extent and: [
		drawingForm depth = backgroundForm depth ]) ifTrue: [
			"they match just fine"
			^self ].

	backgroundForm := drawingForm deepCopy.		"need copy to capture the moment"
	self extent: backgroundForm extent.
]

{ #category : #'dropping\/grabbing' }
NetworkTerminalMorph >> wantsDroppedMorph: aMorph event: evt [

	^true.
]
