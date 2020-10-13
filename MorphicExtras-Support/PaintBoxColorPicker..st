"
A pop-up, 32-bit color palette used as part of a PaintBoxMorph.

"
Class {
	#name : #PaintBoxColorPicker,
	#superclass : #ImageMorph,
	#instVars : [
		'currentColor',
		'locOfCurrent'
	],
	#category : #'MorphicExtras-Support'
}

{ #category : #initialization }
PaintBoxColorPicker >> beStatic [

	"an aid for Nebraska: make the color chart a static image to reduce traffic"
	image isStatic ifFalse: [
		image := image as: StaticForm
	].
]

{ #category : #accessing }
PaintBoxColorPicker >> currentColor [

	^ currentColor

]

{ #category : #accessing }
PaintBoxColorPicker >> currentColor: aColor [
	"Force me to select the given color."

	currentColor := aColor.
	locOfCurrent := nil.  "remove the marker"

]

{ #category : #drawing }
PaintBoxColorPicker >> drawOn: aCanvas [
	"Image plus circles for currently selected color."

	| c |
	super drawOn: aCanvas.
	locOfCurrent ifNotNil: [
		c := self ringColor.
		aCanvas
			fillOval: (Rectangle center: locOfCurrent + self topLeft extent: 9@9)
			color: Color transparent
			borderWidth: 1
			borderColor: c].

]

{ #category : #'event handling' }
PaintBoxColorPicker >> endColorSelection: evt [
	"Update current color and report it to paint box."

	self selectColor: evt.
	"restore mouseLeave handling"
	self on: #mouseLeave send: #delete to: self.

]

{ #category : #'event handling' }
PaintBoxColorPicker >> initMouseHandlers [

	self on: #mouseDown send: #startColorSelection: to: self.
	self on: #mouseMove send: #selectColor: to: self.
	self on: #mouseUp send: #endColorSelection: to: self.
	self on: #mouseLeave send: #delete to: self.

]

{ #category : #initialization }
PaintBoxColorPicker >> initialize [

	super initialize.
	currentColor := Color black.
	locOfCurrent := nil.
	self initMouseHandlers.

]

{ #category : #drawing }
PaintBoxColorPicker >> ringColor [
	"Choose a color that contrasts with my current color. If that color isn't redish, return red. Otherwise, return green"

	currentColor isTransparent ifTrue: [^ Color red].
	currentColor red < 0.5 ifTrue: [^ Color red].
	currentColor red > (currentColor green + (currentColor blue * 0.5))
		ifTrue: [^ Color green]
		ifFalse: [^ Color red].

]

{ #category : #'event handling' }
PaintBoxColorPicker >> selectColor: evt [ 
	"Update the receiver from the given event. Constrain locOfCurrent's center to lie within the color selection area. If it is partially in the transparent area, snap it entirely into it vertically."

	| r |

	locOfCurrent := evt cursorPoint - self topLeft.
	r := Rectangle center: locOfCurrent extent: 9 @ 9.
	locOfCurrent := locOfCurrent 
				+ (r amountToTranslateWithin: (8 @ 11 corner: (self image width-6) @ (self image height-6))).
	locOfCurrent x > (self image width-(12+7))  ifTrue: [locOfCurrent := (self image width - 12) @ locOfCurrent y].	"snap into grayscale"
	currentColor := locOfCurrent y < 19
				ifTrue:  
					[locOfCurrent := locOfCurrent x @ 11.	"snap into transparent"
					Color transparent]
				ifFalse: [image colorAt: locOfCurrent].
	(owner isKindOf: PaintBoxMorph) 
		ifTrue: [owner takeColorEvt: evt from: self].
	self changed
]

{ #category : #'event handling' }
PaintBoxColorPicker >> startColorSelection: evt [
	"Start color selection. Make me stay up as long as the mouse is down."

	self on: #mouseLeave send: nil to: nil.
	self selectColor: evt.

]
