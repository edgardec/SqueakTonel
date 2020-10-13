"
This class implements an image that appears one way or another depending upon whether it lies within a spotlight shape that moves with the cursor.  As delivered, the shape is a simple circle, the spotlighted appearance is that of a ColorForm, and the non-highlighted apperarance is a derived gray-scale form.

The implementation will space-efficient if supplied with a ColorForm, because the gray-scale derived form will share the same bitmap.

In general, any two images can be used -- one could be blurred, the other sharp -- and the masking form can be any shape.

At some point this class should be merged somehow with ScreeningMorph.
"
Class {
	#name : #ImageMorphWithSpotlight,
	#superclass : #ImageMorph,
	#instVars : [
		'spotImage',
		'spotShape',
		'spotBuffer',
		'spotOn'
	],
	#category : #'Etoys-Squeakland-Morphic-Demo'
}

{ #category : #all }
ImageMorphWithSpotlight >> backgroundImage: bkgndImage spotImage: anImage spotShape: formOfDepth1 [

	"See class comment."
	spotImage := anImage.
	spotShape := formOfDepth1.
	spotBuffer := Form extent: spotShape extent depth: spotImage depth.
	super image: bkgndImage.
	spotOn := false.
]

{ #category : #drawing }
ImageMorphWithSpotlight >> drawOn: aCanvas [

	super drawOn: aCanvas.
	spotOn ifTrue:
		[aCanvas paintImage: spotBuffer at: spotBuffer offset].

]

{ #category : #accessing }
ImageMorphWithSpotlight >> image: anImage [

	"The spotlight will reveal the original  form supplied
	while the background form will be derived grayscale."
	"See class comment."
	self backgroundImage: anImage asGrayScale
		spotImage: anImage
		spotShape: (Form dotOfSize: 100)

]

{ #category : #all }
ImageMorphWithSpotlight >> spotChanged [

	self invalidRect:
		((spotBuffer offset extent: spotBuffer extent) "intersect: self bounds")
]

{ #category : #'stepping and presenter' }
ImageMorphWithSpotlight >> step [
	| cp |
	((self bounds expandBy: spotBuffer extent // 2) containsPoint: (cp := self cursorPoint))
		ifTrue:
		[(cp - (spotBuffer extent // 2)) = spotBuffer offset ifTrue: [^ self].  "No change"
		"Cursor has moved where its spotShape is visible"
		spotOn := true.
		self spotChanged.
		spotBuffer offset: cp - (spotBuffer extent // 2).
		self spotChanged.
		(BitBlt current toForm: spotBuffer)
			"clear the buffer"
			fill: spotBuffer boundingBox fillColor: (Bitmap with: 0) rule: Form over;
			"Clip anything outside the base form"
			clipRect: (spotBuffer boundingBox
				intersect: (self bounds translateBy: spotBuffer offset negated));
			"Fill the spotBuffer with the spot image"
			copyForm: spotImage to: self position - spotBuffer offset rule: Form over;
			"Mask everything outside the spot shape to 0 (transparent)."
			copyForm: spotShape to: spotShape offset negated rule: Form and
				colorMap: (Bitmap with: 0 with: 16rFFFFFFFF)]
		ifFalse:
		[spotOn ifTrue: [self spotChanged. spotOn := false]]
]

{ #category : #testing }
ImageMorphWithSpotlight >> stepTime [

	^ 20
]
