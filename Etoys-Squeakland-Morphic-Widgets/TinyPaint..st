Class {
	#name : #TinyPaint,
	#superclass : #SketchMorph,
	#instVars : [
		'brush',
		'brushSize',
		'brushColor',
		'lastMouse'
	],
	#category : #'Etoys-Squeakland-Morphic-Widgets'
}

{ #category : #menu }
TinyPaint >> addCustomMenuItems: aCustomMenu hand: aHandMorph [

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu add: 'clear' translated action: #clear.
	aCustomMenu add: 'pen color' translated action: #setPenColor:.
	aCustomMenu add: 'pen size' translated action: #setPenSize.
	aCustomMenu add: 'fill' translated action: #fill.

]

{ #category : #menu }
TinyPaint >> brushColor: aColor [

	brushColor := aColor.
	brush color: aColor.

]

{ #category : #menu }
TinyPaint >> clear [

	self form: ((Form extent: 125@100 depth: 8) fillColor: color).
	brush := Pen newOnForm: originalForm.
	brush roundNib: brushSize.
	brush color: brushColor.

]

{ #category : #initialization }
TinyPaint >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color veryVeryLightGray
]

{ #category : #menu }
TinyPaint >> fill [

	| fillPt |
	Cursor blank show.
	Cursor crossHair showWhile:
		[fillPt := Sensor waitButton - self position].
	originalForm shapeFill: brushColor interiorPoint: fillPt.
	self changed.

]

{ #category : #'event handling' }
TinyPaint >> handlesMouseDown: evt [

	^ self inPartsBin not

]

{ #category : #initialization }
TinyPaint >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	
	brushColor := Color red.
	brushSize := 3.
	self clear
]

{ #category : #'event handling' }
TinyPaint >> mouseDown: evt [

	lastMouse := evt cursorPoint.
	brush drawFrom: lastMouse - bounds origin to: lastMouse - bounds origin.
	self invalidRect:
		((lastMouse - brush sourceForm extent) corner:
		 (lastMouse + brush sourceForm extent)).

]

{ #category : #'event handling' }
TinyPaint >> mouseMove: evt [

	| p |
	p := evt cursorPoint.
	p = lastMouse ifTrue: [^ self].
	brush drawFrom: lastMouse - bounds origin to: p - bounds origin.
	self invalidRect: (
		((lastMouse min: p) - brush sourceForm extent) corner:
		((lastMouse max: p) + brush sourceForm extent)).
	lastMouse := p.

]

{ #category : #menu }
TinyPaint >> setPenColor: evt [

	self changeColorTarget: self selector: #brushColor: originalColor: brushColor hand: evt hand.
]

{ #category : #menu }
TinyPaint >> setPenSize [

	| menu sizes nibSize |
	menu := CustomMenu new.
	sizes := (0 to: 5), (6 to: 12 by: 2), (15 to: 40 by: 5).
	sizes do: [:w | menu add: w printString action: w].
	nibSize := menu startUp.
	nibSize ifNotNil: [
		brushSize := nibSize.
		brush roundNib: nibSize].

]
