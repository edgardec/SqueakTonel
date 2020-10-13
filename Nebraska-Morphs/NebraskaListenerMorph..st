"
EToyListenerMorph new open
EToyListenerMorph startListening.
EToyListenerMorph stopListening.

""
EToyListenerMorph listens for messgaes from other EToy communicators. You need one of these open to receive messages from elsewhere.
- Received Morphs are shown in a list. Items can be grabbed (a copy) or deleted.
- Chat messages are sent to an appropriate EToyChatMorph (created if necessary)
""


"
Class {
	#name : #NebraskaListenerMorph,
	#superclass : #NebraskaCommunicatorMorph,
	#instVars : [
		'listener',
		'updateCounter'
	],
	#classVars : [
		'GlobalIncomingQueue',
		'GlobalListener',
		'QueueSemaphore',
		'UpdateCounter',
		'WasListeningAtShutdown'
	],
	#category : #'Nebraska-Morphs'
}

{ #category : #'as yet unclassified' }
NebraskaListenerMorph class >> addToGlobalIncomingQueue: aMorphTuple [

	self critical: [
		self globalIncomingQueue add: aMorphTuple.
		self bumpUpdateCounter.
	].
]

{ #category : #'as yet unclassified' }
NebraskaListenerMorph class >> bumpUpdateCounter [

	UpdateCounter := (UpdateCounter ifNil: [0]) + 1.

]

{ #category : #'as yet unclassified' }
NebraskaListenerMorph class >> commResult: anArrayOfAssociations [

	WorldState addDeferredUIMessage: [self commResultDeferred: anArrayOfAssociations].
]

{ #category : #'as yet unclassified' }
NebraskaListenerMorph class >> commResultDeferred: anArrayOfAssociations [

	| m ipAddress aDictionary |

	"to be run as part of the UI process in case user interaction is required"

	aDictionary := Dictionary new.
	anArrayOfAssociations do: [ :each | aDictionary add: each].
	
	aDictionary at: #commFlash ifPresent: [ :ignore | ^self].
	m := aDictionary at: #message ifAbsent: [^self].
	m = 'OK' ifFalse: [^self].
	ipAddress := aDictionary at: #ipAddress.

	NebraskaIncomingMessage new 
		incomingMessgage: (ReadStream on: (aDictionary at: #data)) 
		fromIPAddress: ipAddress

	
]

{ #category : #'as yet unclassified' }
NebraskaListenerMorph class >> confirmListening [

	self isListening ifFalse: [
		(self confirm: 'You currently are not listening and will not hear a reply.
Shall I start listening for you?' translated) ifTrue: [
			self startListening
		].
	].

]

{ #category : #'as yet unclassified' }
NebraskaListenerMorph class >> critical: aBlock [

	QueueSemaphore ifNil: [QueueSemaphore := Semaphore forMutualExclusion].
	^QueueSemaphore critical: aBlock

]

{ #category : #'parts bin' }
NebraskaListenerMorph class >> descriptionForPartsBin [
	^ self partName: 	'Listener' translatedNoop
		categories:		#()
		documentation:	'A tool for receiving things from other Squeak users' translatedNoop
]

{ #category : #'as yet unclassified' }
NebraskaListenerMorph class >> ensureListenerInCurrentWorld [

	| w |
	w := self currentWorld.
	NebraskaListenerMorph allInstances 
		detect: [ :each | each world == w]
		ifNone: [NebraskaListenerMorph new open]
]

{ #category : #'as yet unclassified' }
NebraskaListenerMorph class >> flashIndicator: ignoredForNow [
]

{ #category : #'as yet unclassified' }
NebraskaListenerMorph class >> globalIncomingQueue [

	^GlobalIncomingQueue ifNil: [GlobalIncomingQueue := OrderedCollection new].
]

{ #category : #'as yet unclassified' }
NebraskaListenerMorph class >> globalIncomingQueueCopy [

	^self critical: [self globalIncomingQueue copy].

]

{ #category : #'class initialization' }
NebraskaListenerMorph class >> initialize [
"
EToyListenerMorph initialize
"
	
	Smalltalk addToStartUpList: self.
	Smalltalk addToShutDownList: self.

]

{ #category : #'as yet unclassified' }
NebraskaListenerMorph class >> isListening [

	^GlobalListener notNil

]

{ #category : #'as yet unclassified' }
NebraskaListenerMorph class >> listeningPort [

	^GlobalListener ifNotNil: [GlobalListener listeningPort]

]

{ #category : #'as yet unclassified' }
NebraskaListenerMorph class >> makeListeningToggle: withEars [

	| background c capExtent bgExtent earExtent earDeltaX earDeltaY botCent factor parts |

	factor := 2.
	bgExtent := (50@25) * factor.
	capExtent := (30@30) * factor.
	earExtent := (15@15) * factor.
	earDeltaX := capExtent x // 2.
	earDeltaY := capExtent y // 2.
	background := Form extent: bgExtent depth: 8.
	botCent := background boundingBox bottomCenter.
	c := background getCanvas.
	"c fillColor: Color white."
	parts := {
		(botCent - (capExtent // 2)) extent: capExtent.
	}.
	withEars ifTrue: [
		parts := parts , {
			(botCent - (earDeltaX @ earDeltaY) - (earExtent // 2)) extent: earExtent.
			(botCent - (earDeltaX negated @ earDeltaY) - (earExtent // 2)) extent: earExtent.
		} 
	].
	parts do: [ :each |
		c
			fillOval: each
			color: Color black 
			borderWidth: 0 
			borderColor: Color black.
	].
	^background

"=====
	f2 := Form extent: 30@15 depth: 8.
	background displayInterpolatedOn: f2.
	f2 replaceColor: Color white withColor: Color transparent.
	^f2
====="


	
]

{ #category : #'as yet unclassified' }
NebraskaListenerMorph class >> makeListeningToggleNew: activeMode [

	| background c baseExtent bgExtent botCent factor len endPts base |

	factor := 2.
	bgExtent := (50@25) * factor.
	baseExtent := (15@15) * factor.
	background := Form extent: bgExtent depth: 8.
	botCent := background boundingBox bottomCenter.
	c := background getCanvas.
"c fillColor: Color white."
	base :=  (botCent - (baseExtent // 2)) extent: baseExtent.
	c
		fillOval: base
		color: Color black 
		borderWidth: 0 
		borderColor: Color black.
	activeMode ifTrue: [
		len := background boundingBox height - 15.
		endPts := {botCent - (len@len). botCent - (len negated@len)}.
		endPts do: [ :each |
			c line: botCent to: each width: 2 color: Color black.
		].
		endPts do: [ :each |
			#(4 8 12) do: [ :offset |
				c frameOval: (each - offset corner: each + offset) color: Color red
			].
		].
	].
"background asMorph openInWorld."
	^background


	
]

{ #category : #'as yet unclassified' }
NebraskaListenerMorph class >> removeAllFromGlobalIncomingQueue [

	self critical: [
		GlobalIncomingQueue := OrderedCollection new.
		self bumpUpdateCounter.
	].
]

{ #category : #'as yet unclassified' }
NebraskaListenerMorph class >> removeFromGlobalIncomingQueue: theActualObject [

	self critical: [
		GlobalIncomingQueue := self globalIncomingQueue reject: [ :each | 
			each second == theActualObject
		].
		self bumpUpdateCounter.
	].
]

{ #category : #'as yet unclassified' }
NebraskaListenerMorph class >> resetIndicator: ignoredForNow [
]

{ #category : #'system startup' }
NebraskaListenerMorph class >> shutDown: quitting [

	WasListeningAtShutdown := GlobalListener notNil.
	self stopListening.

]

{ #category : #'as yet unclassified' }
NebraskaListenerMorph class >> startListening [

	self stopListening.
	GlobalListener := NebraskaPeerToPeer new awaitDataFor: self.
	self bumpUpdateCounter.


]

{ #category : #'system startup' }
NebraskaListenerMorph class >> startUp: resuming [

	WasListeningAtShutdown == true ifTrue: [
		self startListening.
	].

]

{ #category : #'as yet unclassified' }
NebraskaListenerMorph class >> stopListening [
	GlobalListener ifNotNil:
		[GlobalListener stopListening.
		GlobalListener := nil.
		self bumpUpdateCounter]

	"EToyListenerMorph stopListening"
]

{ #category : #'class initialization' }
NebraskaListenerMorph class >> unload [
	Smalltalk removeFromStartUpList: self.
	Smalltalk removeFromShutDownList: self.

]

{ #category : #'as yet unclassified' }
NebraskaListenerMorph >> addNewObject: newObject thumbForm: aForm sentBy: senderName ipAddress: ipAddressString [

	| thumb row |

	thumb := aForm asMorph.
	thumb setProperty: #depictedObject toValue: newObject.
	row := self addARow: {
		thumb. 
		self inAColumn: {
			StringMorph new contents: senderName; lock.
			StringMorph new contents: ipAddressString; lock.
		}
	}.
	true ifTrue: [	"simpler protocol"
		row on: #mouseUp send: #mouseUpEvent:for: to: self.
	] ifFalse: [
		row on: #mouseDown send: #mouseDownEvent:for: to: self.
	].


]

{ #category : #initialization }
NebraskaListenerMorph >> defaultBorderColor [
	"answer the default border color/fill style for the receiver"
	^ Color blue
]

{ #category : #initialization }
NebraskaListenerMorph >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 4
]

{ #category : #initialization }
NebraskaListenerMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color lightBlue
]

{ #category : #'submorphs-add\/remove' }
NebraskaListenerMorph >> delete [

	listener ifNotNil: [listener stopListening. listener := nil].	
					"for old instances that were locally listening"
	super delete.
]

{ #category : #initialization }
NebraskaListenerMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	self listDirection: #topToBottom;
		 layoutInset: 4;
		 rebuild 
]

{ #category : #'as yet unclassified' }
NebraskaListenerMorph >> listeningPort [
	^self class listeningPort
]

{ #category : #'as yet unclassified' }
NebraskaListenerMorph >> mouseDownEvent: event for: aMorph [ 
	| menu selection depictedObject |
	depictedObject := aMorph firstSubmorph valueOfProperty: #depictedObject.
	menu := CustomMenu new.
	menu
		add: 'Grab' translated action: [event hand attachMorph: depictedObject veryDeepCopy];
		add: 'Delete' translated
			action: 
				[self class removeFromGlobalIncomingQueue: depictedObject.
				self rebuild].
	selection := menu build startUpCenteredWithCaption: 'Morph from ' translated
						, (aMorph submorphs second) firstSubmorph contents.
	selection ifNil: [^self].
	selection value
]

{ #category : #'as yet unclassified' }
NebraskaListenerMorph >> mouseUpEvent: event for: aMorph [

	| depictedObject |

	depictedObject := aMorph firstSubmorph valueOfProperty: #depictedObject.
	event hand attachMorph: depictedObject.
	self class removeFromGlobalIncomingQueue: depictedObject.
	self rebuild.

]

{ #category : #'as yet unclassified' }
NebraskaListenerMorph >> rebuild [

	| earMorph |
	updateCounter := UpdateCounter.
	self removeAllMorphs.
	self addGateKeeperMorphs.
	GlobalListener ifNil: [
		earMorph := (self class makeListeningToggleNew: false) asMorph.
		earMorph setBalloonText: 'Click to START listening for messages' translated.
		earMorph on: #mouseUp send: #startListening to: self.
	] ifNotNil: [
		earMorph := (self class makeListeningToggleNew: true) asMorph.
		earMorph setBalloonText: 'Click to STOP listening for messages' translated.
		earMorph on: #mouseUp send: #stopListening to: self.
	].
	self addARow: {self inAColumn: {earMorph}}.
	self
		addARow: {
			self inAColumn: {(StringMorph contents: 'Incoming communications' translated ) lock}.
			self indicatorFieldNamed: #working color: Color blue help: 'working' translated.
			self indicatorFieldNamed: #communicating color: Color green help: 'receiving' translated.
		}.
	"{thumbForm. newObject. senderName. ipAddressString}"
	self class globalIncomingQueueCopy do: [ :each |
		self
			addNewObject: each second 
			thumbForm: each first 
			sentBy: each third 
			ipAddress: each fourth.
	].
]

{ #category : #'as yet unclassified' }
NebraskaListenerMorph >> startListening [

	self class startListening
]

{ #category : #'stepping and presenter' }
NebraskaListenerMorph >> step [

	| needRebuild |
	super step.
	needRebuild := false.
	(self valueOfProperty: #gateKeeperCounterValue) = 
			NebraskaGateKeeperMorph updateCounter ifFalse: [needRebuild := true].
	updateCounter = UpdateCounter ifFalse: [
		needRebuild := true.
	].
	needRebuild ifTrue: [self rebuild].

]

{ #category : #'as yet unclassified' }
NebraskaListenerMorph >> stopListening [

	self class stopListening
]
