"
I am a display object which can both paint myself on a medium (displayOn: messages), and can act as a medium myself. My chief subclass is Form.
"
Class {
	#name : #DisplayMedium,
	#superclass : #DisplayObject,
	#category : #'Graphics-Display Objects'
}

{ #category : #bordering }
DisplayMedium >> border: aRectangle width: borderWidth [ 
	"Paint a border whose rectangular area is defined by aRectangle. The 
	width of the border of each side is borderWidth. Uses black for 
	drawing the border."

	self border: aRectangle width: borderWidth fillColor: Color black.

]

{ #category : #bordering }
DisplayMedium >> border: aRectangle width: borderWidth fillColor: aHalfTone [ 
	"Paint a border whose rectangular area is defined by aRectangle. The 
	width of the border of each side is borderWidth. Uses aHalfTone for 
	drawing the border."

	self border: aRectangle
		widthRectangle: 
			(Rectangle
				left: borderWidth
				right: borderWidth
				top: borderWidth
				bottom: borderWidth)
		rule: Form over
		fillColor: aHalfTone
]

{ #category : #bordering }
DisplayMedium >> border: aRectangle width: borderWidth rule: combinationRule fillColor: aHalfTone [ 
	"Paint a border whose rectangular area is defined by aRectangle. The 
	width of the border of each side is borderWidth. Uses aHalfTone for 
	drawing the border."

	self border: aRectangle
		widthRectangle: 
			(Rectangle
				left: borderWidth
				right: borderWidth
				top: borderWidth
				bottom: borderWidth)
		rule: combinationRule
		fillColor: aHalfTone
]

{ #category : #bordering }
DisplayMedium >> border: aRectangle widthRectangle: insets rule: combinationRule fillColor: aHalfTone [
	"Paint a border whose rectangular area is defined by aRectangle. The 
	width of each edge of the border is determined by the four coordinates 
	of insets. Uses aHalfTone and combinationRule for drawing the border."

	(aRectangle areasOutside: (aRectangle insetBy: insets)) do:
		[:edgeStrip | self fill: edgeStrip rule: combinationRule fillColor: aHalfTone]
]

{ #category : #displaying }
DisplayMedium >> copyBits: sourceRect from: sourceForm at: destOrigin clippingBox: clipRect rule: rule fillColor: aForm [ 
	"Make up a BitBlt table and copy the bits."

	self subclassResponsibility
]

{ #category : #displaying }
DisplayMedium >> deferUpdatesIn: aRectangle while: aBlock [
	"DisplayScreen overrides with something more involved..."
	^aBlock value
]

{ #category : #displaying }
DisplayMedium >> drawLine: sourceForm from: beginPoint to: endPoint clippingBox: clipRect rule: anInteger fillColor: aForm [ 
	"Draw line by copying the argument, sourceForm, starting at location 
	beginPoint and ending at endPoint, clipped by the rectangle, clipRect. 
	The rule and mask for copying are the arguments anInteger and aForm."

	self subclassResponsibility
]

{ #category : #coloring }
DisplayMedium >> fill: aRectangle fillColor: aForm [ 
	"Replace a rectangular area of the receiver with the pattern described by 
	aForm according to the rule over."

	self fill: aRectangle rule: Form over fillColor: aForm
]

{ #category : #coloring }
DisplayMedium >> fill: aRectangle rule: anInteger fillColor: aForm [ 
	"Replace a rectangular area of the receiver with the pattern described by 
	aForm according to the rule anInteger."

	self subclassResponsibility
]

{ #category : #coloring }
DisplayMedium >> fillBlack [
	"Set all bits in the receiver to black (ones)."

	self fill: self boundingBox fillColor: Color black
]

{ #category : #coloring }
DisplayMedium >> fillBlack: aRectangle [ 
	"Set all bits in the receiver's area defined by aRectangle to black (ones)."

	self fill: aRectangle rule: Form over fillColor: Color black
]

{ #category : #coloring }
DisplayMedium >> fillColor: aColor [
	"Set all pixels in the receiver to the color.  Must be a correct color for this depth of medium.  TK 1 Jun 96"

	self fill: self boundingBox fillColor: aColor
]

{ #category : #coloring }
DisplayMedium >> fillGray [
	"Set all bits in the receiver to gray."

	self fill: self boundingBox fillColor: Color gray
]

{ #category : #coloring }
DisplayMedium >> fillGray: aRectangle [
	"Set all bits in the receiver's area defined by aRectangle to the gray mask."

	self fill: aRectangle rule: Form over fillColor: Color gray
]

{ #category : #coloring }
DisplayMedium >> fillShape: aShapeForm fillColor: aColor [
	"Fill a region corresponding to 1 bits in aShapeForm with aColor"

	^ self fillShape: aShapeForm fillColor: aColor at: 0@0
]

{ #category : #coloring }
DisplayMedium >> fillShape: aShapeForm fillColor: aColor at: location [
	"Fill a region corresponding to 1 bits in aShapeForm with aColor"

	((BitBlt destForm: self sourceForm: aShapeForm fillColor: aColor
		combinationRule: Form paint
		destOrigin: location + aShapeForm offset sourceOrigin: 0@0
		extent: self extent clipRect: self boundingBox)
		colorMap: (Bitmap with: 0 with: 16rFFFFFFFF))
		copyBits
]

{ #category : #coloring }
DisplayMedium >> fillWhite [
	"Set all bits in the form to white."

	self fill: self boundingBox fillColor: Color white.

]

{ #category : #coloring }
DisplayMedium >> fillWhite: aRectangle [
	"Set all bits in the receiver's area defined by aRectangle to white."

	self fill: aRectangle rule: Form over fillColor: Color white.

]

{ #category : #coloring }
DisplayMedium >> fillWithColor: aColor [
	"Fill the receiver's bounding box with the given color."

	self fill: self boundingBox fillColor: aColor.

]

{ #category : #coloring }
DisplayMedium >> reverse [
	"Change all the bits in the receiver that are white to black, and the ones 
	that are black to white."

	self fill: self boundingBox rule: Form reverse fillColor: (Color quickHighLight: self depth)
]

{ #category : #coloring }
DisplayMedium >> reverse: aRectangle [
	"Change all the bits in the receiver's area that intersects with aRectangle 
	that are white to black, and the ones that are black to white."

	self fill: aRectangle rule: Form reverse fillColor: (Color quickHighLight: self depth)
]

{ #category : #coloring }
DisplayMedium >> reverse: aRectangle fillColor: aMask [	
	"Change all the bits in the receiver's area that intersects with aRectangle 
	according to the mask. Black does not necessarily turn to white, rather it 
	changes with respect to the rule and the bit in a corresponding mask 
	location. Bound to give a surprise."

	self fill: aRectangle rule: Form reverse fillColor: aMask
]
