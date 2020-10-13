"
Class GradientFillMorph is obsolete. For getting gradient fills use a BorderedMorph with an appropriate fill style, e.g.,

	| morph fs |
	morph := BorderedMorph new.
	fs := GradientFillStyle ramp: {0.0 -> Color red. 1.0 -> Color green}.
	fs origin: morph bounds center.
	fs direction: (morph bounds width // 2) @ 0.
	fs radial: true.
	morph fillStyle: fs.
	Project current world primaryHand attachMorph: morph.

Here's the old (obsolete) comment:
GradientFills cache an array of bitpatterns for the colors across their rectangle.  It costs a bit of space, but makes display fast enough to eschew the use of a bitmap.  The array must be recomputed whenever the colors, dimensions or display depth change.
"
Class {
	#name : #GradientFillMorph,
	#superclass : #RectangleMorph,
	#instVars : [
		'fillColor2',
		'gradientDirection',
		'colorArray',
		'colorDepth'
	],
	#category : #'MorphicExtras-Widgets'
}

{ #category : #menu }
GradientFillMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu add: 'gradient color' translated action: #setGradientColor:.
	gradientDirection == #vertical
		ifTrue: [aCustomMenu add: 'horizontal pan' translated action: #beHorizontal]
		ifFalse: [aCustomMenu add: 'vertical pan' translated action: #beVertical].

]

{ #category : #menu }
GradientFillMorph >> beHorizontal [
	gradientDirection := #horizontal.
	self changed
]

{ #category : #menu }
GradientFillMorph >> beVertical [
	gradientDirection := #vertical.
	self changed
]

{ #category : #updating }
GradientFillMorph >> changed [
	super changed.
	self releaseCachedState
]

{ #category : #drawing }
GradientFillMorph >> drawOn: aCanvas [ 
	"Note that this could run about 4 times faster if we got hold of
	the canvas's port and just sent it copyBits with new coords and color"

	| style |
	super drawOn: aCanvas.
	(color isColor) ifFalse: [^self].	"An InfiniteForm, for example"
	color = Color transparent ifTrue: [^self].	"Skip the gradient attempts, which will drop into debugger"
	color = fillColor2 ifTrue: [^self].	"same color; no gradient"
	"Check if we can use the cached gradient fill"
	((self valueOfProperty: #cachedGradientColor1) = color 
		and: [(self valueOfProperty: #cachedGradientColor2) = fillColor2]) 
			ifTrue: [style := self valueOfProperty: #cachedGradientFill].
	style ifNil: 
			[style := GradientFillStyle ramp: { 
								0.0 -> color.
								1.0 -> fillColor2}.
			self setProperty: #cachedGradientColor1 toValue: color.
			self setProperty: #cachedGradientColor2 toValue: fillColor2.
			self setProperty: #cachedGradientFill toValue: style].
	style origin: self position.
	style direction: (gradientDirection == #vertical 
				ifTrue: [0 @ self height]
				ifFalse: [self width @ 0]).
	aCanvas fillRectangle: self innerBounds fillStyle: style
]

{ #category : #accessing }
GradientFillMorph >> gradientFillColor: aColor [

	fillColor2 := aColor.
	self changed.

]

{ #category : #accessing }
GradientFillMorph >> hasTranslucentColor [
	"Answer true if this any of this morph is translucent but not transparent."

	(color isColor and: [color isTranslucentColor]) ifTrue: [^ true].
	(fillColor2 isColor and: [fillColor2 isTranslucentColor]) ifTrue: [^ true].
	^ false

]

{ #category : #initialization }
GradientFillMorph >> initialize [
	super initialize.
	self borderWidth: 0.
	fillColor2 := Color black.
	gradientDirection := #vertical
]

{ #category : #menu }
GradientFillMorph >> setGradientColor: evt [

	self changeColorTarget: self selector: #gradientFillColor: originalColor: fillColor2 hand: evt hand
]
