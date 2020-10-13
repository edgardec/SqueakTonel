"
====== find and report all instances =====
	EToySenderMorph instanceReport


====== zap a bunch of ipAddresses =====
	EToySenderMorph allInstances do: [ :each | 
		each ipAddress = '11.11.11.11' ifTrue: [each ipAddress: 'whizzbang']
	].
==================== now change one of the whizzbang's back to the right address=====
====== delete the whizzbangs ======
	EToySenderMorph allInstances do: [ :each | 
		each ipAddress = 'whizzbang' ifTrue: [each stopStepping; delete]
	].

"
Class {
	#name : #NebraskaCommunicatorMorph,
	#superclass : #AlignmentMorphBob1,
	#instVars : [
		'fields',
		'resultQueue'
	],
	#classVars : [
		'LastFlashTime'
	],
	#category : #'Nebraska-Morphs'
}

{ #category : #'as yet unclassified' }
NebraskaCommunicatorMorph class >> allForIPAddress: ipString [	"for cleaning up Alan's demo"
"
EToySenderMorph allForIPAddress: '1.2.3.4'
"
	Smalltalk garbageCollect.
	(self allInstances select: [ :each | each ipAddress = ipString]) explore
]

{ #category : #'new-morph participation' }
NebraskaCommunicatorMorph class >> includeInNewMorphMenu [
	"Not to be instantiated from the menu"
	^ self ~~ NebraskaCommunicatorMorph
]

{ #category : #'as yet unclassified' }
NebraskaCommunicatorMorph class >> instanceReport [	"for cleaning up Alan's demo"
"
EToySenderMorph instanceReport
"
	| answer resp |

	Smalltalk garbageCollect.
	answer := self allInstances replace: [ :each |
		{
			each.
			[each ipAddress] on: Error do: [ 'no ipAddress'].
			each owner 
					ifNil: ['* no owner *'] 
					ifNotNil: [each owner innocuousName,' ',each owner printString].
			each world ifNil: ['-----no project-----'] ifNotNil: [each world project name].
		}
	].
	resp := (PopUpMenu labels: 'IP Address\Project\Owner' translated withCRs) startUpWithCaption: 
					'Sorted by' translated.
	resp = 1 ifTrue: [
		^(answer sort: [ :a :b | a second <= b second]) explore
	].
	resp = 2 ifTrue: [
		^(answer sort: [ :a :b | a fourth <= b fourth]) explore
	].
	resp = 3 ifTrue: [
		^(answer sort: [ :a :b | a third <= b third]) explore
	].
	answer explore
]

{ #category : #'as yet unclassified' }
NebraskaCommunicatorMorph class >> otherCleanup [
">>>
	EToySenderMorph allInstances do: [ :each | 
		each ipAddress = '11.11.11.11' ifTrue: [each ipAddress: 'whizzbang']
	].
<<<"
	"==================== now change one of the whizzbang's back to the right address====="
">>>
	EToySenderMorph allInstances do: [ :each | 
		each ipAddress = 'whizzbang' ifTrue: [each delete]
	].
<<<"

]

{ #category : #'as yet unclassified' }
NebraskaCommunicatorMorph class >> playArrivalSound [
	"Make a sound that something has arrived."

	SoundService default playSoundNamedOrBeep: 'chirp'
]

{ #category : #collaborative }
NebraskaCommunicatorMorph >> addGateKeeperMorphs [

	| list currentTime choices |

	self setProperty: #gateKeeperCounterValue toValue: NebraskaGateKeeperMorph updateCounter.
	choices := #(
		(60 'm' 'in the last minute')
		(3600 'h' 'in the last hour')
		(86400 'd' 'in the last day')
	).
	currentTime := Time totalSeconds.
	list := NebraskaGateKeeperMorph knownIPAddresses.
	list do: [ :each | | age row |
		age := each timeBetweenLastAccessAnd: currentTime.
		age := choices
			detect: [ :x | age <= x first]
			ifNone: [{0. '-'. (age // 86400) printString,'days ago'}].
		row := self addARow:
		(NebraskaIncomingMessage allTypes collect: [ :type |
				self toggleButtonFor: each attribute: type]
		),
		{

			(self inAColumn: {
				(StringMorph contents: age second) lock.
			}) layoutInset: 2; hResizing: #shrinkWrap; setBalloonText: 'Last attempt was ',age third.

			(self inAColumn: {
				(StringMorph contents: each ipAddress) lock.
			}) layoutInset: 2; hResizing: #shrinkWrap.

			(self inAColumn: {
				(StringMorph contents: each latestUserName) lock.
			}) layoutInset: 2.
		}.
		row
			color: (Color r: 0.6 g: 0.8 b: 1.0);
			borderStyle: (BorderStyle raised width: 1);
			vResizing: #spaceFill;
			"on: #mouseUp send: #mouseUp:in: to: self;"
			setBalloonText: each fullInfoString
	].
]

{ #category : #'as yet unclassified' }
NebraskaCommunicatorMorph >> buttonNamed: aString action: aSymbol color: aColor help: helpString [

	| f col |
	f := SimpleButtonMorph new
		target: self;
		label: aString;
		color: aColor;
		borderColor: aColor muchDarker;
		actionSelector: aSymbol;
		setBalloonText: helpString.
	self field: aSymbol is: f.
	col := (self inAColumn: {f}) hResizing: #shrinkWrap.
	^col
]

{ #category : #'as yet unclassified' }
NebraskaCommunicatorMorph >> commResult: anArrayOfAssociations [

	| aDictionary |
	aDictionary := Dictionary new.
	anArrayOfAssociations do: [ :each | aDictionary add: each].
	resultQueue nextPut: aDictionary
]

{ #category : #'submorphs-add\/remove' }
NebraskaCommunicatorMorph >> delete [

	super delete.
	self breakDependents
]

{ #category : #'as yet unclassified' }
NebraskaCommunicatorMorph >> editEvent: anEvent for: aMorph [

	| answer |

	(aMorph bounds containsPoint: anEvent cursorPoint) ifFalse: [^self].
	answer := FillInTheBlankMorph
		request: 'Enter a new ',aMorph balloonText
		initialAnswer: aMorph contents.
	answer isEmptyOrNil ifTrue: [^self].
	aMorph contents: answer

]

{ #category : #'as yet unclassified' }
NebraskaCommunicatorMorph >> field: fieldName is: anObject [

	fields at: fieldName put: anObject.
	^anObject
]

{ #category : #'as yet unclassified' }
NebraskaCommunicatorMorph >> flashIndicator: aSymbol [

	| now |

	now := Time millisecondClockValue.
	(LastFlashTime notNil and: [(Time millisecondClockValue - now) abs < 500]) ifTrue: [^self].
	LastFlashTime := now.
	self trulyFlashIndicator: aSymbol

]

{ #category : #'as yet unclassified' }
NebraskaCommunicatorMorph >> handleResult: aDictionary [

	| m |

	aDictionary at: #commFlash ifPresent: [ :ignore | ^self flashIndicator: #communicating].
	self resetIndicator: #communicating.
	m := aDictionary at: #message ifAbsent: ['unknown message'].
	m = 'OK' ifTrue: [^self].
	self reportError: m
]

{ #category : #'as yet unclassified' }
NebraskaCommunicatorMorph >> indicatorFieldNamed: aSymbol color: aColor help: helpString [

	| f col |
	f := EllipseMorph new
		extent: 10@10;
		color: aColor;
		setBalloonText: helpString.
	self field: aSymbol is: f.
	col := (self inAColumn: {f}) hResizing: #shrinkWrap.
	^col
]

{ #category : #initialization }
NebraskaCommunicatorMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	self vResizing: #shrinkWrap;
	 hResizing: #shrinkWrap.
	resultQueue := SharedQueue new.
	fields := Dictionary new.
	self useRoundedCorners
]

{ #category : #'as yet unclassified' }
NebraskaCommunicatorMorph >> open [

	self openInWorld
]

{ #category : #'as yet unclassified' }
NebraskaCommunicatorMorph >> reportError: aString [

	self inform: aString
]

{ #category : #'as yet unclassified' }
NebraskaCommunicatorMorph >> resetIndicator: aSymbol [

	| indicator firstColor |
	indicator := fields at: aSymbol ifAbsent: [^self].
	firstColor := indicator 
		valueOfProperty: #firstColor
		ifAbsent: [^self].
	indicator color: firstColor.
	self refreshWorld.

]

{ #category : #'stepping and presenter' }
NebraskaCommunicatorMorph >> step [

	| state |

	[resultQueue isEmpty] whileFalse: [
		self handleResult: resultQueue next
	].
	(state := self valueOfProperty: #flashingState ifAbsent: [0]) > 0 ifTrue: [
		self borderColor: (
			(self valueOfProperty: #flashingColors ifAbsent: [{Color green. Color red}]) atWrap: state
		).
		self setProperty: #flashingState toValue: state + 1
	].
]

{ #category : #testing }
NebraskaCommunicatorMorph >> stepTime [

	(self valueOfProperty: #flashingState ifAbsent: [0]) > 0 ifTrue: [
		^200
	] ifFalse: [
		^1000
	].
]

{ #category : #'as yet unclassified' }
NebraskaCommunicatorMorph >> stopFlashing [

	self setProperty: #flashingState toValue: 0.
	self borderColor: (self valueOfProperty: #normalBorderColor ifAbsent: [Color blue]).

]

{ #category : #'as yet unclassified' }
NebraskaCommunicatorMorph >> textEntryFieldNamed: aSymbol with: aString help: helpString [

	| f col |
	f := (StringMorph new contents: aString; font: Preferences standardEToysFont; yourself)
		setBalloonText: helpString;
		on: #mouseUp send: #editEvent:for: to: self.
	self field: aSymbol is: f.
	col := (self inAColumn: {f}) color: Color white; hResizing: #shrinkWrap.
	^col
]

{ #category : #'as yet unclassified' }
NebraskaCommunicatorMorph >> toggleButtonFor: entry attribute: attribute [

	^(self inAColumn: {
		self
			simpleToggleButtonFor: entry 
			attribute: attribute 
			help: 'Whether you want "',attribute,'" messages'
	}) hResizing: #shrinkWrap

]

{ #category : #collaborative }
NebraskaCommunicatorMorph >> transmitStreamedObject: outData as: objectCategory to: anIPAddress [

	NebraskaPeerToPeer transmitStreamedObject: outData as: objectCategory to: anIPAddress for: self
]

{ #category : #collaborative }
NebraskaCommunicatorMorph >> transmitStreamedObject: outData to: anIPAddress [

	self transmitStreamedObject: outData as: self transmittedObjectCategory to: anIPAddress

]

{ #category : #'as yet unclassified' }
NebraskaCommunicatorMorph >> trulyFlashIndicator: aSymbol [

	| indicator firstColor |

	indicator := fields at: aSymbol ifAbsent: [^self].
	firstColor := indicator 
		valueOfProperty: #firstColor
		ifAbsent: [
			indicator setProperty: #firstColor toValue: indicator color.
			indicator color
		].
	indicator color: (indicator color = firstColor ifTrue: [Color white] ifFalse: [firstColor]).
	self refreshWorld.

]

{ #category : #testing }
NebraskaCommunicatorMorph >> wantsSteps [

	^true
]
