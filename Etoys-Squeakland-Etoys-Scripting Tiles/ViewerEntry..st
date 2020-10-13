Class {
	#name : #ViewerEntry,
	#superclass : #AlignmentMorph,
	#instVars : [
		'helpPane'
	],
	#category : #'Etoys-Squeakland-Etoys-Scripting Tiles'
}

{ #category : #menu }
ViewerEntry >> codePaneMenu: aMenu shifted: shifted [
	^ aMenu 
		labels: 'menu
eventually
will
be
useful'
		lines: #(1)
		selections: #(beep flash beep flash beep)
]

{ #category : #contents }
ViewerEntry >> contents: c notifying: k [
	"later, spruce this up so that it can accept input such as new method source"
	| info |
	(info := self userSlotInformation)
		ifNotNil:
			[info documentation: c.
			^ true].
	Beeper beep.
	^ false
]

{ #category : #contents }
ViewerEntry >> contentsSelection [
	"Not well understood why this needs to be here!"
	^ 1 to: 0
]

{ #category : #initialization }
ViewerEntry >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color
		r: 1.0
		g: 0.985
		b: 0.985
]

{ #category : #access }
ViewerEntry >> entryType [
	^ self viewerRow entryType
]

{ #category : #initialization }
ViewerEntry >> initialize [
"initialize the state of the receiver"
	super initialize.
""
	self layoutInset: 0
]

{ #category : #access }
ViewerEntry >> playerBearingCode [
	^ owner owner scriptedPlayer
]

{ #category : #slot }
ViewerEntry >> slotName [
	"Assuming the receiver represents a slot, return its name"

	^  self viewerRow elementSymbol
]

{ #category : #slot }
ViewerEntry >> userSlotInformation [
	"If the receiver represents a user-defined slot, then return its info; if not, retun nil"
	| aSlotName info |
	((self entryType == #systemSlot) or: [self entryType == #userSlot])
		ifFalse:
			[^ nil].
	aSlotName := self slotName.
	^ ((info := self playerBearingCode slotInfo) includesKey: aSlotName)
		ifTrue:
			[info at: aSlotName]
		ifFalse:
			[nil]
]

{ #category : #access }
ViewerEntry >> viewerRow [
	"Answer the ViewerRow object, that contains the controls and the phraseTile"
	^ submorphs first
]
