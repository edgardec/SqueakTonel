"
I represent a particular kind of Rectangle that has a border and inside color.
"
Class {
	#name : #Quadrangle,
	#superclass : #Rectangle,
	#instVars : [
		'borderWidth',
		'borderColor',
		'insideColor'
	],
	#category : #'Graphics-Primitives'
}

{ #category : #'instance creation' }
Quadrangle class >> exampleInViewer [
	"Create a sample Quadrangle and open a Viewer on it"

	(self region: (100@100 extent: 100@50) borderWidth: (1 + (6 atRandom)) borderColor: Color black insideColor: (Color perform: #(green red blue yellow) atRandom)) beViewed

"Quadrangle exampleInViewer"
]

{ #category : #'instance creation' }
Quadrangle class >> origin: originPoint corner: cornerPoint [ 
	"Override Rectangles origin:corner: in order to get initialized.

	Answer an instance of me whose corners (top left and bottom right) are 
	determined by the arguments."

	^self new setOrigin: originPoint corner: cornerPoint
]

{ #category : #'instance creation' }
Quadrangle class >> region: aRectangle borderWidth: anInteger borderColor: aMask1 insideColor: aMask2 [
	"Answer an instance of me with rectangle, border width and color, and 
	inside color determined by the arguments."

	^super new
		setRegion: aRectangle
		borderWidth: anInteger
		borderColor: aMask1
		insideColor: aMask2
]

{ #category : #transforming }
Quadrangle >> align: aPoint1 with: aPoint2 [ 
	"Answer a new Quadrangle translated by aPoint2 - aPoint1.
	 5/24/96 sw: removed hard-coded class name so subclasses can gain same functionality."

	^ self class
		region: (super translateBy: aPoint2 - aPoint1)
		borderWidth: borderWidth
		borderColor: borderColor
		insideColor: insideColor
]

{ #category : #transforming }
Quadrangle >> alignedTo: alignPointSelector [
	"Return a copy with offset according to alignPointSelector which is one of...
	#(topLeft, topCenter, topRight, leftCenter, center, etc)
	 5/24/96 sw: removed hard-coded class name so subclasses can gain same functionality."

	^ self class
		region: (super translateBy: (0@0) - (self perform: alignPointSelector))
		borderWidth: borderWidth
		borderColor: borderColor
		insideColor: insideColor
]

{ #category : #bordering }
Quadrangle >> borderColor [
	"Answer the form that is the borderColor of the receiver."

	^borderColor
]

{ #category : #bordering }
Quadrangle >> borderColor: aColor [ 
	"Set the borderColor of the receiver to aColor, a Form."

	borderColor := aColor
]

{ #category : #bordering }
Quadrangle >> borderWidth [
	"Answer the borderWidth of the receiver."

	^borderWidth
]

{ #category : #bordering }
Quadrangle >> borderWidth: anInteger [ 
	"Set the borderWidth of the receiver to anInteger."

	borderWidth := anInteger
]

{ #category : #bordering }
Quadrangle >> borderWidthLeft: anInteger1 right: anInteger2 top: anInteger3 bottom: anInteger4 [
	"Set the border width of the receiver to a Rectangle that represents the 
	left, right, top, and bottom border widths."

	borderWidth := anInteger1 @ anInteger3 corner: anInteger2 @ anInteger4
]

{ #category : #'displaying-Display' }
Quadrangle >> display [ 
	"Display the border and insideRegion of the receiver on the Display."

	self displayOn: Display
]

{ #category : #'displaying-Display' }
Quadrangle >> displayAlign: aPoint1 with: aPoint2 clippingBox: aRectangle [ 
	"Display the border and region of the receiver on the Display so that its 
	position at aPoint1 is aligned with position aPoint2. The displayed 
	information should be clipped so that only information with the area 
	determined by aRectangle is displayed." 

	self displayOn: Display align: aPoint1 with: aPoint2 clippingBox: aRectangle
]

{ #category : #'displaying-generic' }
Quadrangle >> displayOn: aDisplayMedium [
	"Display the border and insideRegion of the receiver."

	borderWidth ~= 0 ifTrue: [
		aDisplayMedium
			border: self region
			widthRectangle: borderWidth
			rule: Form over
			fillColor: borderColor ].
	insideColor ifNotNil: [
		aDisplayMedium fill: self inside fillColor: insideColor ]
]

{ #category : #'displaying-generic' }
Quadrangle >> displayOn: aDisplayMedium align: aPoint1 with: aPoint2 clippingBox: aRectangle [
	"Display the border and region of the receiver so that its position at 
	aPoint1 is aligned with position aPoint2. The displayed information 
	should be clipped so that only information with the area determined by 
	aRectangle is displayed."

	| savedRegion |
	savedRegion := self region.
	self region: ((savedRegion align: aPoint1 with: aPoint2) intersect: aRectangle).
	self displayOn: aDisplayMedium.
	self region: savedRegion
]

{ #category : #'displaying-generic' }
Quadrangle >> displayOn: aDisplayMedium transformation: aWindowingTransformation clippingBox: aRectangle [
	"Display the border and region of the receiver so that it is scaled and 
	translated with respect to aWindowingTransformation. The displayed 
	information should be clipped so that only information with the area 
	determined by aRectangle is displayed."

	| screenRectangle |
	screenRectangle := 
		(aWindowingTransformation applyTo: self) intersect: aRectangle.
	(borderWidth ~= 0 and: [ insideColor notNil ])
		ifTrue: 
			[aDisplayMedium fill: screenRectangle fillColor: Color black "borderColor".
			aDisplayMedium
				fill: (screenRectangle insetBy: borderWidth)
				fillColor: insideColor]
]

{ #category : #'displaying-generic' }
Quadrangle >> displayOnPort: aPort at: p [
	"Display the border and insideRegion of the receiver."

	(insideColor == nil or: [borderWidth <= 0])
		ifFalse: [aPort fill: (self region translateBy: p) 
			fillColor: borderColor rule: Form over].
	insideColor == nil
		ifFalse: [aPort fill: (self inside translateBy: p) 
			fillColor: insideColor rule: Form over]
]

{ #category : #'displaying-Display' }
Quadrangle >> displayTransformation: aWindowingTransformation clippingBox: aRectangle [ 
	"Display the border and region of the receiver on the Display so that it 
	is scaled and translated with respect to aWindowingTransformation. The 
	displayed information should be clipped so that only information with 
	the area determined by aRectangle is displayed." 

	self displayOn: Display transformation: aWindowingTransformation clippingBox: aRectangle
]

{ #category : #'initialize-release' }
Quadrangle >> initialize [
	"Initialize the region to a null Rectangle, the borderWidth to 1, the 
	borderColor to black, and the insideColor to white."

	origin := 0 @ 0.
	corner := 0 @ 0.
	borderWidth := 1.
	borderColor := Color black.
	insideColor := Color white.

]

{ #category : #bordering }
Quadrangle >> inside [
	"Answer a Rectangle that is the receiver inset by the borderWidth."

	^self insetBy: borderWidth
]

{ #category : #bordering }
Quadrangle >> insideColor [
	"Answer the form that is the insideColor of the receiver."

	^insideColor
]

{ #category : #bordering }
Quadrangle >> insideColor: aColor [ 
	"Set the insideColor of the receiver to aColor, a Form."

	insideColor := aColor
]

{ #category : #'rectangle functions' }
Quadrangle >> intersect: aRectangle [ 
	"Answer a new Quadrangle whose region is the intersection of the 
	receiver's area and aRectangle.
	 5/24/96 sw: removed hard-coded class name so subclasses can gain same functionality."

	^ self class
	 	region: (super intersect: aRectangle)
		borderWidth: borderWidth
		borderColor: borderColor
		insideColor: insideColor
]

{ #category : #bordering }
Quadrangle >> region [
	"Answer a Rectangle that defines the area of the receiver."

	^origin corner: corner
]

{ #category : #bordering }
Quadrangle >> region: aRectangle [ 
	"Set the rectangular area of the receiver to aRectangle."

	origin := aRectangle origin.
	corner := aRectangle corner
]

{ #category : #transforming }
Quadrangle >> scaleBy: aPoint [ 
	"Answer a new Quadrangle scaled by aPoint.
	 5/24/96 sw: removed hard-coded class name so subclasses can gain same functionality."

	^ self class
		region: (super scaleBy: aPoint)
		borderWidth: borderWidth
		borderColor: borderColor
		insideColor: insideColor
]

{ #category : #bordering }
Quadrangle >> setHeight: aNumber [ 
	"Set the receiver's height"

	self region: (origin extent: (self width @ aNumber))
]

{ #category : #bordering }
Quadrangle >> setLeft: aNumber [ 
	"Move the receiver so that its left edge is given by aNumber.  An example of a setter to go with #left"

	self region: ((aNumber @ origin y) extent: self extent)
]

{ #category : #private }
Quadrangle >> setRegion: aRectangle borderWidth: anInteger borderColor: aMask1 insideColor: aMask2 [

	origin := aRectangle origin.
	corner := aRectangle corner.
	borderWidth := anInteger.
	borderColor := aMask1.
	insideColor := aMask2
]

{ #category : #bordering }
Quadrangle >> setRight: aNumber [ 
	"Move the receiver so that its right edge is given by aNumber.  An example of a setter to go with #right"

	self region: ((origin x + (aNumber - self right) @ origin y) extent: self extent)
]

{ #category : #bordering }
Quadrangle >> setWidth: aNumber [ 
	"Set the receiver's width"

	self region: (origin extent: (aNumber @ self height))
]

{ #category : #transforming }
Quadrangle >> translateBy: aPoint [ 
	"Answer a new Quadrangle translated by aPoint.
	 5/24/96 sw: removed hard-coded class name so subclasses can gain same functionality."

	^ self class
		region: (super translateBy: aPoint)
		borderWidth: borderWidth
		borderColor: borderColor
		insideColor: insideColor
]
