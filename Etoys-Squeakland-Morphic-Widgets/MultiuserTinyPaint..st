"
A very simple paint program that handles multiple users (hands).
Each user has their own brush size and color.

"
Class {
	#name : #MultiuserTinyPaint,
	#superclass : #SketchMorph,
	#instVars : [
		'drawState'
	],
	#classVars : [
		'LastMouseIndex',
		'PenColorIndex',
		'PenIndex',
		'PenSizeIndex'
	],
	#category : #'Etoys-Squeakland-Morphic-Widgets'
}

{ #category : #'class initialization' }
MultiuserTinyPaint class >> initialize [
	"MultiuserTinyPaint initialize"

	"indices into the state array for a given hand"
	PenIndex := 1.
	PenSizeIndex := 2.
	PenColorIndex := 3.
	LastMouseIndex := 4.

]

{ #category : #menu }
MultiuserTinyPaint >> addCustomMenuItems: aCustomMenu hand: aHandMorph [

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu add: 'clear' translated action: #clear.
	aCustomMenu add: 'pen color' translated action: #setPenColor:.
	aCustomMenu add: 'pen size' translated action: #setPenSize:.
"	aCustomMenu add: 'fill' translated action: #fill:."

]

{ #category : #menu }
MultiuserTinyPaint >> brushColor: aColor hand: hand [

	| state |
	(drawState includesKey: hand) ifFalse: [self createDrawStateFor: hand].
	state := drawState at: hand.
	(state at: PenIndex) color: aColor.
	state at: PenColorIndex put: aColor.

]

{ #category : #menu }
MultiuserTinyPaint >> clear [

	| newPen |
	self form: ((Form extent: 400@300 depth: 8) fillColor: color).
	drawState do: [:state |
		newPen := Pen newOnForm: originalForm.
		newPen roundNib: (state at: PenSizeIndex).
		newPen color: (state at: PenColorIndex).
		state at: PenIndex put: newPen].

]

{ #category : #private }
MultiuserTinyPaint >> createDrawStateFor: aHand [

	| pen state |
	pen := Pen newOnForm: originalForm.
	state := Array new: 4.
	state at: PenIndex put: pen.
	state at: PenSizeIndex put: 3.
	state at: PenColorIndex put: Color red.
	state at: LastMouseIndex put: nil.
	drawState at: aHand put: state.

]

{ #category : #initialization }
MultiuserTinyPaint >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color veryVeryLightGray
]

{ #category : #menu }
MultiuserTinyPaint >> fill: evt [

	| state fillPt |
	(drawState includesKey: evt hand) ifFalse: [self createDrawStateFor: evt hand].
	state := drawState at: evt hand.

	Cursor blank show.
	Cursor crossHair showWhile:
		[fillPt := Sensor waitButton - self position].
	originalForm shapeFill: (state at: PenColorIndex) interiorPoint: fillPt.
	self changed.

]

{ #category : #'event handling' }
MultiuserTinyPaint >> handlesMouseDown: evt [

	^ true

]

{ #category : #initialization }
MultiuserTinyPaint >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	
	drawState := IdentityDictionary new.
	self clear
]

{ #category : #'event handling' }
MultiuserTinyPaint >> mouseDown: evt [

	| state |
	(drawState includesKey: evt hand) ifFalse: [self createDrawStateFor: evt hand].
	state := drawState at: evt hand.
	state at: LastMouseIndex put: evt cursorPoint.

]

{ #category : #'event handling' }
MultiuserTinyPaint >> mouseMove: evt [

	| state lastP p pen |
	state := drawState at: evt hand ifAbsent: [^ self].
	lastP := state at: LastMouseIndex.
	p := evt cursorPoint.
	p = lastP ifTrue: [^ self].

	pen := state at: PenIndex.
	pen drawFrom: lastP - bounds origin to: p - bounds origin.
	self invalidRect: (
		((lastP min: p) - pen sourceForm extent) corner:
		((lastP max: p) + pen sourceForm extent)).
	state at: LastMouseIndex put: p.

]

{ #category : #menu }
MultiuserTinyPaint >> penSize: anInteger hand: hand [

	| state |
	(drawState includesKey: hand) ifFalse: [self createDrawStateFor: hand].
	state := drawState at: hand.
	state at: PenSizeIndex put: anInteger.
	(state at: PenIndex) roundNib: anInteger.

]

{ #category : #menu }
MultiuserTinyPaint >> setPenColor: evt [
	| state |
	(drawState includesKey: evt hand) ifFalse: [self createDrawStateFor: evt hand].
	state := drawState at: evt hand.
	self changeColorTarget: self selector: #brushColor:hand: originalColor: (state at: PenColorIndex) hand: evt hand
]

{ #category : #menu }
MultiuserTinyPaint >> setPenSize: evt [

	| menu sizes |
	menu := MenuMorph new.
	sizes := (0 to: 5), (6 to: 12 by: 2), (15 to: 40 by: 5).
	sizes do: [:w |
		menu add: w printString
			target: self
			selector: #penSize:hand:
			argumentList: (Array with: w with: evt hand)].

	menu popUpEvent: evt in: self world
]
