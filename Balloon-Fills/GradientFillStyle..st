"
A gradient fill style is a fill which interpolates smoothly between any number of colors.

Instance variables:
	colorRamp	<Array of: Association> Contains the colors and their relative positions along the fill, which is a number between zero and one.
	pixelRamp	<Bitmap>		A cached version of the colorRamp to avoid needless recomputations.
	radial		<Boolean>	If true, this fill describes a radial gradient. If false, it is a linear gradient.
	isTranslucent	<Boolean>	A (cached) flag determining if there are any translucent colors involved.

Class variables:
	PixelRampCache <LRUCache>	Recently used pixelRamps. They tend to have high temporal locality and this saves space and time.
"
Class {
	#name : #GradientFillStyle,
	#superclass : #OrientedFillStyle,
	#instVars : [
		'colorRamp',
		'pixelRamp',
		'radial',
		'isTranslucent'
	],
	#classVars : [
		'PixelRampCache'
	],
	#category : #'Balloon-Fills'
}

{ #category : #'class initialization' }
GradientFillStyle class >> cleanUp [
	"Flush caches"

	self initPixelRampCache
]

{ #category : #'instance creation' }
GradientFillStyle class >> colors: colorArray [
	"Create a gradient fill style from an array of equally spaced colors"
	^self ramp: (colorArray withIndexCollect:
		[:color :index| (index-1 asFloat / (colorArray size - 1 max: 1)) -> color]).
]

{ #category : #'class initialization' }
GradientFillStyle class >> initPixelRampCache [

"Create an LRUCache to use for accessing pixel ramps."

"Details: when a new pixel ramp is needed, a temporary GradientFillStyle is created so that it can be used to create a new pixel ramp"

^PixelRampCache := LRUCache size: 32 factory:[:key| 
	(GradientFillStyle new colorRamp: key) computePixelRampOfSize: 512]  
]

{ #category : #'class initialization' }
GradientFillStyle class >> pixelRampCache [

"Allow access to my cache of pixel ramps. This is mainly for debugging and profiling purposes."

^PixelRampCache 
]

{ #category : #'instance creation' }
GradientFillStyle class >> ramp: colorRamp [
	^self new colorRamp: colorRamp
]

{ #category : #'instance creation' }
GradientFillStyle class >> sample [
	"GradientFill sample"
	^(self ramp: { 0.0 -> Color red. 0.5 -> Color green. 1.0 -> Color blue})
		origin: 300 @ 300;
		direction: 400@0;
		normal: 0@400;
		radial: true;
	yourself
]

{ #category : #converting }
GradientFillStyle >> asColor [
	"Guess..."
	^colorRamp first value mixed: 0.5 with: colorRamp last value
]

{ #category : #private }
GradientFillStyle >> checkTranslucency [
	^colorRamp anySatisfy: [:any| any value isTranslucent]
]

{ #category : #accessing }
GradientFillStyle >> colorRamp [
	^colorRamp
]

{ #category : #accessing }
GradientFillStyle >> colorRamp: anArray [
	colorRamp := anArray.
	pixelRamp := nil.
	isTranslucent := nil.
]

{ #category : #private }
GradientFillStyle >> computePixelRampOfSize: length [
	"Compute the pixel ramp in the receiver"
	| bits lastValue ramp lastColor lastIndex lastWord |
	ramp := colorRamp sorted:[:a1 :a2| a1 key < a2 key].
	bits := Bitmap new: length.
	lastColor := ramp first value.
	lastWord := lastColor pixelWordForDepth: 32.
	lastIndex := 0.
	ramp do:[:assoc| | nextIndex nextColor distance theta step nextWord |
		nextIndex := (assoc key * length) rounded.
		nextColor := assoc value.
		nextWord := nextColor pixelWordForDepth: 32.
		distance := (nextIndex - lastIndex).
		distance = 0 ifTrue:[distance := 1].
		step := 1.0 / distance asFloat.
		theta := 0.0.
		lastIndex+1 to: nextIndex do:[:i|
			theta := theta + step.
			"The following is an open-coded version of:
				color := nextColor alphaMixed: theta with: lastColor.
				bits at: i put: (color scaledPixelValue32).
			"
			bits at: i put: (self scaledAlphaMix: theta of: lastWord with: nextWord).
		].
		lastIndex := nextIndex.
		lastColor := nextColor.
		lastWord := nextWord.
	].
	lastValue := lastColor scaledPixelValue32.
	lastIndex+1 to: length do:[:i| bits at: i put: lastValue].
	^bits
]

{ #category : #private }
GradientFillStyle >> display [
	| f ramp |
	ramp := self pixelRamp.
	f := Form extent: ramp size @ 1 depth: 32 bits: ramp.
	1 to: 100 do:[:i| f displayAt: 1@i].
	[Sensor anyButtonPressed] whileFalse.
	[Sensor anyButtonPressed] whileTrue.
]

{ #category : #testing }
GradientFillStyle >> isGradientFill [
	^true
]

{ #category : #testing }
GradientFillStyle >> isRadialFill [
	^radial == true
]

{ #category : #testing }
GradientFillStyle >> isSolidFill [
	^false
]

{ #category : #testing }
GradientFillStyle >> isTranslucent [
	^isTranslucent ifNil:[isTranslucent := self checkTranslucency]
]

{ #category : #converting }
GradientFillStyle >> mixed: fraction with: aColor [
	^self copy colorRamp: (colorRamp collect:[:assoc| assoc key -> (assoc value mixed: fraction with: aColor)])
]

{ #category : #accessing }
GradientFillStyle >> pixelRamp [

"Compute a pixel ramp, and cache it for future accesses"

^pixelRamp ifNil:[
	"Insure the PixelRampCache is in place"
	PixelRampCache ifNil:[ self class initPixelRampCache  ].

	"Ask my cache for an existing instance if one is available"
	pixelRamp := PixelRampCache at: colorRamp deepCopy	
].
]

{ #category : #accessing }
GradientFillStyle >> pixelRamp: aBitmap [
	pixelRamp := aBitmap
]

{ #category : #accessing }
GradientFillStyle >> radial [
	^radial ifNil:[false]
]

{ #category : #accessing }
GradientFillStyle >> radial: aBoolean [
	radial := aBoolean
]

{ #category : #private }
GradientFillStyle >> scaledAlphaMix: theta of: lastWord with: nextWord [
	"Open-coded version of alpha mixing two 32bit pixel words and returning the scaled pixel value."
	| word0 word1 a0 a1 alpha v0 v1 vv value |
	word0 := lastWord.
	word1 := nextWord.
	"note: extract alpha first so we'll be in SmallInteger range afterwards"
	a0 := word0 bitShift: -24. a1 := word1 bitShift: -24.
	alpha := a0 + (a1 - a0 * theta) truncated.
	"Now make word0 and word1 SmallIntegers"
	word0 := word0 bitAnd: 16rFFFFFF. word1 := word1 bitAnd: 16rFFFFFF.
	"Compute first component value"
	v0 := (word0 bitAnd: 255). v1 := (word1 bitAnd: 255).
	vv := (v0 + (v1 - v0 * theta) truncated) * alpha // 255.
	value := vv.
	"Compute second component value"
	v0 := ((word0 bitShift: -8) bitAnd: 255). v1 := ((word1 bitShift: -8) bitAnd: 255).
	vv := (v0 + (v1 - v0 * theta) truncated) * alpha // 255.
	value := value bitOr: (vv bitShift: 8).
	"Compute third component value"
	v0 := ((word0 bitShift: -16) bitAnd: 255). v1 := ((word1 bitShift: -16) bitAnd: 255).
	vv := (v0 + (v1 - v0 * theta) truncated) * alpha // 255.
	value := value bitOr: (vv bitShift: 16).
	"Return result"
	^value bitOr: (alpha bitShift: 24)
]
