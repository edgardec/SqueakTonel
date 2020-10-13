"
This class displays images from the PlayingCard class as morphs.  It attempts to be space-efficient by only producing its images on demand.
"
Class {
	#name : #PlayingCardMorph,
	#superclass : #ImageMorph,
	#instVars : [
		'cardNumber',
		'suitNumber'
	],
	#category : #'Etoys-Squeakland-Morphic-Games'
}

{ #category : #access }
PlayingCardMorph class >> cardSize [
	" a real hack, but I don't want to muck with Dan's class "
	^71@96.
]

{ #category : #access }
PlayingCardMorph class >> height [
	^self cardSize y
]

{ #category : #'new-morph participation' }
PlayingCardMorph class >> includeInNewMorphMenu [

	^false
]

{ #category : #access }
PlayingCardMorph class >> suits [
	^ #(clubs diamonds hearts spades)
]

{ #category : #testing }
PlayingCardMorph class >> test [    "Display all cards in the deck"
	"MessageTally spyOn: [20 timesRepeat: [PlayingCardMorph test]]"
	| table row |
	table := AlignmentMorph newColumn.
	self suits do: [:suit | 
		row := AlignmentMorph newRow.
		table addMorph: row.
		1 to: 13 do: [:cn |
			row addMorph: 
			(PlayingCardMorph the: cn of: suit)]].
	table openInWorld.
]

{ #category : #'initialize-release' }
PlayingCardMorph class >> the: cardNumber of: suit [

	^ self new 
		image: (PlayingCard the: cardNumber of: suit) cardForm;
		cardNumber: cardNumber suitNumber: (self suits indexOf: suit)
]

{ #category : #access }
PlayingCardMorph class >> width [
	^self cardSize x
]

{ #category : #'dropping\/grabbing' }
PlayingCardMorph >> aboutToBeGrabbedBy: aHand [
	"I'm about to be grabbed by the hand.  If other cards are above me in a deck,
	then move them from the deck to being submorphs of me"
	| i |
	super aboutToBeGrabbedBy: aHand.
	self removeProperty: #undoGrabCommand.  "So it won't interfere with overall move"
	self board captureStateBeforeGrab.
	i := owner submorphs indexOf: self ifAbsent: [^ self].
	i = 1 ifTrue: [^ self].
	(owner submorphs copyFrom: 1 to: i-1) do:
		[:m | m class = self class ifTrue: [self addMorphBack: m]].

]

{ #category : #access }
PlayingCardMorph >> board [

	^ owner owner owner
]

{ #category : #access }
PlayingCardMorph >> cardDeck [

	^self owner
]

{ #category : #access }
PlayingCardMorph >> cardNumber [
	^cardNumber
]

{ #category : #access }
PlayingCardMorph >> cardNumber: c suitNumber: s [
	cardNumber := c.
	suitNumber := s.
]

{ #category : #'event handling' }
PlayingCardMorph >> click: evt [
	
	"since we really want to know about double-clicks before making our move, ignore this and wait until #firstClickTimedOut: arrives"
]

{ #category : #'event handling' }
PlayingCardMorph >> doubleClick: evt [

	^self cardDeck doubleClickOnCard: self
]

{ #category : #'event handling' }
PlayingCardMorph >> firstClickTimedOut: evt [ 
	| root popUp |
	root := owner rootForGrabOf: self.
	root isNil 
		ifTrue: 
			["Display hidden card in front"

			popUp := self copy.
			self board owner owner addMorphFront: popUp.
			self world displayWorld.
			(Delay forMilliseconds: 750) wait.
			popUp delete]
		ifFalse: [evt hand grabMorph: root]
]

{ #category : #'event handling' }
PlayingCardMorph >> handlesMouseDown: evt [

	^ true
]

{ #category : #'dropping\/grabbing' }
PlayingCardMorph >> justDroppedInto: newOwner event: evt [

	(newOwner isKindOf: PlayingCardDeck)
		ifFalse: ["Can't drop a card anywhere but on a deck"
				self rejectDropMorphEvent: evt].
	^super justDroppedInto: newOwner event: evt
]

{ #category : #'event handling' }
PlayingCardMorph >> mouseDown: evt [
	"Do nothing upon mouse-down except inform the hand to watch for a double-click; wait until an ensuing click:, doubleClick:, or drag: message gets dispatched"

	evt hand waitForClicksOrDrag: self event: evt selectors: { #click:. #doubleClick:. #firstClickTimedOut:. nil} threshold: 5
]

{ #category : #printing }
PlayingCardMorph >> printOn: aStream [

	aStream
		print: cardNumber;
		nextPutAll: ' of ';
		print: (self class suits at: suitNumber).
]

{ #category : #'dropping\/grabbing' }
PlayingCardMorph >> slideBackToFormerSituation: evt [

	super slideBackToFormerSituation: evt.
	self board removeProperty: #stateBeforeGrab.
	self hasSubmorphs ifTrue:
		["Just cancelled a drop of multiple cards -- have to unload submorphs"
		self submorphs reverseDo: [:m | owner addMorphFront: m]].

]

{ #category : #access }
PlayingCardMorph >> suit [
	^self class suits at: suitNumber
]

{ #category : #access }
PlayingCardMorph >> suitColor [
	^#(black red red black) at: suitNumber
]

{ #category : #access }
PlayingCardMorph >> suitNumber [

	^suitNumber
]
