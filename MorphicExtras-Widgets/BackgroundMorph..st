"
This morph incorporates tiling and regular motion with the intent of supporting, eg, panning of endless (toroidal) backgrounds.

The idea is that embedded morphs get displayed at a moving offset relative to my position.  Moreover this display is tiled according to the bounding box of the submorphs (subBounds), as much as necesary to fill the rest of my bounds.
"
Class {
	#name : #BackgroundMorph,
	#superclass : #Morph,
	#instVars : [
		'image',
		'offset',
		'delta',
		'running'
	],
	#category : #'MorphicExtras-Widgets'
}

{ #category : #test }
BackgroundMorph class >> test [
	"BackgroundMorph test"
	^(BackgroundMorph new addMorph: (ImageMorph new image: Form fromUser))openInWorld.
]

{ #category : #menus }
BackgroundMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [ 
	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	running
		ifTrue: [aCustomMenu add: 'stop' translated action: #stopRunning]
		ifFalse: [aCustomMenu add: 'start' translated action: #startRunning]
]

{ #category : #accessing }
BackgroundMorph >> delta [
	^delta
]

{ #category : #accessing }
BackgroundMorph >> delta: aPoint [

	delta := aPoint.
]

{ #category : #drawing }
BackgroundMorph >> drawOn: aCanvas [
	"The tiling is solely determined by bounds, subBounds and offset.
	The extent of display is determined by bounds and the clipRect of the canvas."
	| start d subBnds |
	submorphs isEmpty ifTrue: [^ super drawOn: aCanvas].
	subBnds := self subBounds.
	running ifFalse:
		[super drawOn: aCanvas.
		^ aCanvas fillRectangle: subBnds color: Color lightBlue].
	start := subBnds topLeft + offset - bounds topLeft - (1@1) \\ subBnds extent - subBnds extent + (1@1).
	d := subBnds topLeft - bounds topLeft.
"Sensor redButtonPressed ifTrue: [self halt]."
	start x to: bounds width - 1 by: subBnds width do:
		[:x |
		start y to: bounds height - 1 by: subBnds height do:
			[:y | aCanvas translateBy: (x@y) - d clippingTo: bounds
				during:[:tileCanvas| self drawSubmorphsOn: tileCanvas]]].
]

{ #category : #layout }
BackgroundMorph >> fullBounds [
	^ self bounds
]

{ #category : #drawing }
BackgroundMorph >> fullDrawOn: aCanvas [
	(aCanvas isVisible: self fullBounds) ifFalse:[^self].
	running ifFalse: [
		^aCanvas clipBy: (bounds translateBy: aCanvas origin)
				during:[:clippedCanvas| super fullDrawOn: clippedCanvas]].
	(aCanvas isVisible: self bounds) ifTrue:[aCanvas drawMorph: self].

]

{ #category : #initialization }
BackgroundMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
""
	offset := 0 @ 0.
	delta := 1 @ 0.
	running := true
]

{ #category : #layout }
BackgroundMorph >> layoutChanged [
	"Do nothing, since I clip my submorphs"
]

{ #category : #accessing }
BackgroundMorph >> offset [
	^offset
]

{ #category : #accessing }
BackgroundMorph >> offset: aPoint [
	offset := aPoint
]

{ #category : #accessing }
BackgroundMorph >> slideBy: inc [
	submorphs isEmpty ifTrue: [^ self].
	offset := offset + inc \\ self subBounds extent.
	self changed
]

{ #category : #accessing }
BackgroundMorph >> startRunning [
	running := true.
	self changed
]

{ #category : #'stepping and presenter' }
BackgroundMorph >> step [
	
	running ifTrue: [self slideBy: delta]
]

{ #category : #'stepping and presenter' }
BackgroundMorph >> stepTime [
	"Answer the desired time between steps in milliseconds."

	^ 20
]

{ #category : #accessing }
BackgroundMorph >> stopRunning [
	running := false.
	self changed
]

{ #category : #accessing }
BackgroundMorph >> subBounds [
	"calculate the submorph bounds"

	| subBounds |
	subBounds := (submorphs ifEmpty: [^nil]) anyOne fullBounds copy.
	self submorphsDo: 	[:m | subBounds swallow: m fullBounds].
	^subBounds
]
