"
A cheezy morph that simply steps a Nebraska server instance over and over.
"
Class {
	#name : #NebraskaServerMorph,
	#superclass : #AlignmentMorphBob1,
	#instVars : [
		'server',
		'slowCounter',
		'previousBacklog',
		'lastFullUpdateTime',
		'currentStatusString',
		'fullDisplay',
		'previousClients',
		'currentBacklogString'
	],
	#category : #'Nebraska-Morphic-Remote'
}

{ #category : #'as yet unclassified' }
NebraskaServerMorph class >> killOldServers [

	NebraskaServerMorph allInstances do: [ :each |
		each delete.
	].
	NebraskaServer allInstances do: [ :each |
		each stopListening.
		DependentsFields removeKey: each ifAbsent: [].
	].

]

{ #category : #'as yet unclassified' }
NebraskaServerMorph class >> serveWorld [

	^ self serveWorld: self currentWorld

]

{ #category : #'as yet unclassified' }
NebraskaServerMorph class >> serveWorld: aWorld [
	"Check to make sure things won't crash. See Mantis #0000519"
	^aWorld isSafeToServe ifTrue:[
		self serveWorld: aWorld onPort: NebraskaServer defaultPorts]
	
]

{ #category : #'as yet unclassified' }
NebraskaServerMorph class >> serveWorld: aWorld onPort: aPortNumber [

	| server |
	server := NebraskaServer serveWorld: aWorld onPort: aPortNumber.
	(self new) openInWorld: aWorld.
	^server
	"server acceptNullConnection"		"server acceptPhonyConnection."

]

{ #category : #'as yet unclassified' }
NebraskaServerMorph class >> serveWorldButton [

	| button |
	button := SimpleButtonMorph new.
	button target: NebraskaServerMorph.
	button actionSelector: #serveWorld.
	button arguments: #().
	button label: 'Share'.
	button color: Color yellow.
	^ button.

]

{ #category : #'as yet unclassified' }
NebraskaServerMorph class >> supplementaryPartsDescriptions [
	^ {DescriptionForPartsBin
		formalName: 'NebraskaServer' translatedNoop
		categoryList: #()
		documentation: 'A button to start the Nebraska desktop sharing server' translatedNoop
		globalReceiverSymbol: #NebraskaServerMorph
		nativitySelector: #serveWorldButton
	}
]

{ #category : #accessing }
NebraskaServerMorph >> currentBacklogString [

	^currentBacklogString
]

{ #category : #accessing }
NebraskaServerMorph >> currentStatusString [

	^currentStatusString
]

{ #category : #initialization }
NebraskaServerMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color white
]

{ #category : #'submorphs-add\/remove' }
NebraskaServerMorph >> delete [
	self server ifNotNil:[
		(self confirm:'Shutdown the server?' translated) 
			ifTrue:[self world remoteServer: nil]].
	super delete.
]

{ #category : #initialization }
NebraskaServerMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	fullDisplay := false.
	
	lastFullUpdateTime := 0.
	self listDirection: #topToBottom;
		 hResizing: #shrinkWrap;
		 vResizing: #shrinkWrap
]

{ #category : #initialization }
NebraskaServerMorph >> rebuild [

	| myServer toggle closeBox font |

	font := StrikeFont familyName: #Palatino size: 14.
	self removeAllMorphs.
	self setColorsAndBorder.
	self updateCurrentStatusString.
	toggle := SimpleHierarchicalListMorph new perform: (
		fullDisplay ifTrue: [#expandedForm] ifFalse: [#notExpandedForm]
	).
	closeBox := SimpleButtonMorph new borderWidth: 0;
			label: 'X' font: Preferences standardEToysButtonFont; color: Color transparent;
			actionSelector: #delete; target: self; extent: 14@14;
			setBalloonText: 'End Nebraska session' translated.

	self addARow: {
		self inAColumn: {closeBox}.
		self inAColumn: {
			UpdatingStringMorph new
				useStringFormat;
				target:  self;
				font: font;
				getSelector: #currentStatusString;
				contents: self currentStatusString;
				stepTime: 2000;
				lock.
		}.
		self inAColumn: {
			toggle asMorph
				on: #mouseUp send: #toggleFull to: self;
				setBalloonText: 'Show more or less of Nebraska Status' translated
		}.
	}.
	myServer := self server.
	(myServer isNil or: [fullDisplay not]) ifTrue: [
		^self world startSteppingSubmorphsOf: self
	].
	"--- the expanded display ---"
	self addARow: {
		self inAColumn: {
			UpdatingStringMorph new
				useStringFormat;
				target:  self;
				font: font;
				getSelector: #currentBacklogString;
				contents: self currentBacklogString;
				stepTime: 2000;
				lock.
		}.
	}.

	self addARow: {
		self inAColumn: {
			(StringMorph contents: '--clients--' translated) lock; font: font.
		}.
	}.

	myServer clients do: [ :each |
		self addARow: {
			UpdatingStringMorph new
				useStringFormat;
				target: each;
				font: font;
				getSelector: #currentStatusString;
				contents: each currentStatusString;
				stepTime: 2000;
				lock.
		}
	].
	self world startSteppingSubmorphsOf: self.
]

{ #category : #accessing }
NebraskaServerMorph >> server [
	^self world remoteServer
]

{ #category : #initialization }
NebraskaServerMorph >> setColorsAndBorder [
	| worldColor c |
	c := ((Preferences menuColorFromWorld and: [Display depth > 4]) 
				and: [(worldColor := self currentWorld color) isColor]) 
					ifTrue: 
						[worldColor luminance > 0.7 
							ifTrue: [worldColor mixed: 0.8 with: Color black]
							ifFalse: [worldColor mixed: 0.4 with: Color white]]
					ifFalse: [Color r: 0.9 g: 0.9 b: 0.9]. 
	self color: c.
	self borderStyle: (BorderStyle raised width: 1).
	self useRoundedCorners
]

{ #category : #'stepping and presenter' }
NebraskaServerMorph >> step [

	| now |

	self server ifNil: [ ^self ].
	self server step.
	now := Time millisecondClockValue.
	(now - lastFullUpdateTime) abs > 5000 ifTrue: [
		lastFullUpdateTime := now.
		(previousBacklog = self server backlog and: [self server clients = previousClients]) ifFalse: [
			previousClients := self server clients copy.
			self rebuild
		]
	].

]

{ #category : #testing }
NebraskaServerMorph >> stepTime [

	^10
]

{ #category : #initialization }
NebraskaServerMorph >> toggleFull [

	fullDisplay := fullDisplay not.
	self rebuild.

]

{ #category : #updating }
NebraskaServerMorph >> update: aSymbol [

	self rebuild.
]

{ #category : #drawing }
NebraskaServerMorph >> updateCurrentStatusString [

	self server ifNil:[
		currentStatusString := '<Nebraska not active>' translated.
		currentBacklogString := ''.
	] ifNotNil:[
		currentStatusString := 
			' Nebraska: {1} clients' translated format: {self server numClients printString}.
		currentBacklogString := 'backlog: ' translated,
				((previousBacklog := self server backlog) // 1024) printString,'k'
	].

]
