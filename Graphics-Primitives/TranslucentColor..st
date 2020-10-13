"
A TranslucentColor behaves just like a normal color, except that it will pack its alpha value into the high byte of a 32-bit pixelValue.  This allows creating forms with translucency for use with the alpha blend function of BitBlt.  An alpha of zero is transparent, and 1.0 is opaque.
"
Class {
	#name : #TranslucentColor,
	#superclass : #Color,
	#instVars : [
		'alpha'
	],
	#category : #'Graphics-Primitives'
}

{ #category : #other }
TranslucentColor >> addName: aSymbol [
	"private - associate a name to this color.
	Don't do it, Translucent colors are not uniquely identified by their rgb components"
	
	^self
]

{ #category : #accessing }
TranslucentColor >> alpha [
	"Return my alpha value, a number between 0.0 and 1.0 where 0.0 is completely transparent and 1.0 is completely opaque."

	^ alpha asFloat / 255.0

]

{ #category : #conversions }
TranslucentColor >> alpha: alphaValue [
	alphaValue = 1.0 ifTrue:
		[^ Color basicNew
			setPrivateRed: self privateRed
			green: self privateGreen
			blue: self privateBlue].
	^ super alpha: alphaValue
]

{ #category : #conversions }
TranslucentColor >> asHTMLColor [

	^ super asHTMLColor 
		, (Character digitValue: ((alpha bitShift: -4) bitAnd: 15))
		, (Character digitValue: (alpha bitAnd: 15))
]

{ #category : #conversions }
TranslucentColor >> asNontranslucentColor [
	^ self alpha: 1.0
]

{ #category : #conversions }
TranslucentColor >> balancedPatternForDepth: depth [
	"Return an appropriate bit pattern or stipple.  This will almost never be meaningful for tranlucentColors, except for the degenerate case of tranparency."

	alpha = 0 ifTrue: [^ Bitmap with: 0].
	^ super balancedPatternForDepth: depth
]

{ #category : #conversions }
TranslucentColor >> bitPatternForDepth: depth [
	"Return an appropriate bit pattern or stipple.  This will almost never be meaningful for tranlucentColors, except for the degenerate case of tranparency."

	alpha = 0 ifTrue: [^ Bitmap with: 0].
	^ super bitPatternForDepth: depth
]

{ #category : #'object fileIn' }
TranslucentColor >> convertToCurrentVersion: varDict refStream: smartRefStrm [
	
	"1/13/1999 -- old versions did not have alpha??"
	varDict at: 'alpha' ifAbsent: [^ Color transparent].

	^super convertToCurrentVersion: varDict refStream: smartRefStrm.
	
]

{ #category : #comparing }
TranslucentColor >> hash [

	^ rgb bitXor: alpha

]

{ #category : #queries }
TranslucentColor >> isOpaque [
	^alpha = 255
]

{ #category : #queries }
TranslucentColor >> isTranslucent [
	^ alpha < 255
]

{ #category : #queries }
TranslucentColor >> isTranslucentColor [
	"This means: self isTranslucent, but isTransparent not"
	^ alpha > 0
]

{ #category : #queries }
TranslucentColor >> isTransparent [
	^ alpha = 0
]

{ #category : #other }
TranslucentColor >> name [
	self = Color transparent ifTrue: [^#transparent].
	^nil
]

{ #category : #conversions }
TranslucentColor >> pixelValueForDepth: d [
	"Return the pixel value for this color at the given depth. Translucency only works in RGB; this color will appear either opaque or transparent at all other depths."
	| basicPixelWord |
	alpha = 0 ifTrue: [^ 0].
	basicPixelWord := super pixelValueForDepth: d.
	d < 32
		ifTrue: [^ basicPixelWord]
		ifFalse: [^ (basicPixelWord bitAnd: 16rFFFFFF) bitOr: (alpha bitShift: 24)].

]

{ #category : #conversions }
TranslucentColor >> pixelWordForDepth: depth [
	"Return the pixel value for this color at the given depth. Translucency only works in RGB; this color will appear either opaque or transparent at all other depths."

	| basicPixelWord |
	alpha = 0 ifTrue: [^ 0].
	basicPixelWord := super pixelWordForDepth: depth.
	depth < 32
		ifTrue: [^ basicPixelWord]
		ifFalse: [^ (basicPixelWord bitAnd: 16rFFFFFF) bitOr: (alpha bitShift: 24)].

]

{ #category : #private }
TranslucentColor >> privateAlpha [
	"Return my raw alpha value, an integer in the range 0..255. Used for fast equality testing."

	^ alpha

]

{ #category : #conversions }
TranslucentColor >> scaledPixelValue32 [
	"Return the alpha scaled pixel value for depth 32"
	| pv32 a b g r |
	pv32 := super scaledPixelValue32.
	a := (self alpha * 255.0) rounded.
	b := (pv32 bitAnd: 255) * a // 256.
	g := ((pv32 bitShift: -8) bitAnd: 255) * a // 256.
	r := ((pv32 bitShift: -16) bitAnd: 255) * a // 256.
	^b + (g bitShift: 8) + (r bitShift: 16) + (a bitShift: 24)
]

{ #category : #private }
TranslucentColor >> setRgb: rgbValue alpha: alphaValue [
	"Set the state of this translucent color. Alpha is represented internally by an integer in the range 0..255."

	rgb == nil ifFalse: [self attemptToMutateError].
	rgb := rgbValue.
	alpha := (255.0 * alphaValue) asInteger min: 255 max: 0.

]

{ #category : #printing }
TranslucentColor >> storeArrayValuesOn: aStream [

	self isTransparent ifTrue: [
		^ aStream space].
	super storeArrayValuesOn: aStream.
	aStream
		space;
		print: self alpha maxDecimalPlaces: 3.
]

{ #category : #printing }
TranslucentColor >> storeOn: aStream [

	self isTransparent ifTrue: [^ aStream nextPutAll: '(Color transparent)'].
	super storeOn: aStream.
	aStream
		skip: -1;	  "get rid of trailing )"
		nextPutAll: ' alpha: ';
		print: self alpha maxDecimalPlaces: 3;
		nextPutAll: ')'.

]
