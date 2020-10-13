"
My instances are used to transform objects from a source coordinate system to a destination coordinate system. Each instance contains a scale and a translation which can be applied to objects that respond to scaleBy: and translateBy:. It can be created with a default identity scale and translation, or with a specified scale and translation, or with a scale and translation computed from a window (a Rectangle in the source coordinate system) and a viewport (a Rectangle in the destination coordinate system). In applying a WindowingTransformation to an object, the object is first scaled (around the origin of the source coordinate system) and then translated. WindowingTransformations can be composed to form a single compound transformation.
"
Class {
	#name : #WindowingTransformation,
	#superclass : #Object,
	#instVars : [
		'scale',
		'translation'
	],
	#category : #'ST80-Framework'
}

{ #category : #'instance creation' }
WindowingTransformation class >> identity [
	"Answer an instance of me with no scaling (nil) and no translation 
	(0@0)."

	^self new setScale: nil translation: 0 @ 0
]

{ #category : #'instance creation' }
WindowingTransformation class >> scale: aScale translation: aTranslation [ 
	"Answer an instance of me with a scale factor of aScale and a translation 
	offset of aTranslation. When the transformation is applied (see 
	WindowingTransformation|apply:), the scale is applied first, followed by 
	the translation."

	^self new setScale: aScale translation: aTranslation
]

{ #category : #'instance creation' }
WindowingTransformation class >> window: aWindow viewport: aViewport [ 
	"Answer an instance of me with a scale and translation based on 
	aWindow and aViewport. The scale and translation are computed such 
	that aWindow, when transformed, coincides with aViewport."

	| scale translation |
	aViewport width = aWindow width & (aViewport height = aWindow height)
		ifTrue:
			[scale := nil]
		ifFalse:
			[scale := aViewport width asFloat / aWindow width asFloat
						@ (aViewport height asFloat / aWindow height asFloat)].
	scale == nil
		ifTrue: [translation := aViewport left - aWindow left
								@ (aViewport top - aWindow top)]
		ifFalse: [translation := aViewport left - (scale x * aWindow left)
								@ (aViewport top - (scale y * aWindow top))].
	^self new setScale: scale translation: translation
]

{ #category : #transforming }
WindowingTransformation >> align: point1 with: point2 [ 
	"Answer a WindowingTransformation with the same scale as the receiver 
	and with a translation of (aPoint2 - aPoint1). It is normally used when 
	the source and destination coordinate systems are scaled the same (that 
	is, there is no scaling between them), and is then a convenient way of 
	specifying a translation, given two points that are intended to coincide."

	^self translateBy: point2 - point1
]

{ #category : #'applying transform' }
WindowingTransformation >> applyInverseTo: anObject [ 
	"Apply the inverse of the receiver to anObject and answer the result. 
	Used to map some object in destination coordinates to one in source 
	coordinates."

	| transformedObject |
	transformedObject := anObject translateBy: translation x negated @ translation y negated.
	scale == nil
		ifFalse: [transformedObject := transformedObject scaleBy: 1.0 / scale x @ (1.0 / scale y)].
	^transformedObject
]

{ #category : #'applying transform' }
WindowingTransformation >> applyTo: anObject [ 
	"Apply the receiver to anObject and answer the result. Used to map some 
	object in source coordinates to one in destination coordinates."

	| transformedObject |
	scale == nil
		ifTrue: [transformedObject := anObject]
		ifFalse: [transformedObject := anObject scaleBy: scale].
	transformedObject := transformedObject translateBy: translation.
	^transformedObject
]

{ #category : #private }
WindowingTransformation >> checkScale: aScale [
	"Convert aScale to the internal format of a floating-point Point."

 	| checkedScale |
	checkedScale := aScale asPoint.
	^checkedScale x asFloat @ checkedScale y asFloat
]

{ #category : #'applying transform' }
WindowingTransformation >> compose: aTransformation [ 
	"Answer a WindowingTransformation that is the composition of the 
	receiver and aTransformation. The effect of applying the resulting 
	WindowingTransformation to an object is the same as that of first 
	applying aTransformation to the object and then applying the receiver to 
	its result."

	| aTransformationScale newScale newTranslation |
	aTransformationScale := aTransformation scale.
	scale == nil
		ifTrue: 
			[aTransformation noScale
				ifTrue: [newScale := nil]
				ifFalse: [newScale := aTransformationScale].
			newTranslation := translation + aTransformation translation]
		ifFalse: 
			[aTransformation noScale
				ifTrue: [newScale := scale]
				ifFalse: [newScale := scale * aTransformationScale].
			newTranslation := translation + (scale * aTransformation translation)].
	^WindowingTransformation scale: newScale translation: newTranslation
]

{ #category : #transforming }
WindowingTransformation >> noScale [
	"Answer true if the identity scale is in effect; answer false, otherwise."

	^scale == nil
]

{ #category : #printing }
WindowingTransformation >> printOn: aStream [ 
	"Refer to the comment in Object|printOn:."

	aStream nextPutAll: self class name, ' scale: ';
		print: scale; nextPutAll: ' translation: ';
		print: translation
]

{ #category : #transforming }
WindowingTransformation >> scale [
	"Answer a copy of the point that represents the current scale of the 
	receiver."

	scale == nil
		ifTrue: [^1.0 @ 1.0]
		ifFalse: [^scale copy]
]

{ #category : #transforming }
WindowingTransformation >> scaleBy: aScale [ 
	"Answer a WindowingTransformation with the scale and translation of 
	the receiver both scaled by aScale."

	| checkedScale newScale newTranslation |
	aScale == nil
		ifTrue: 
			[newScale := scale.
			newTranslation := translation]
		ifFalse: 
			[checkedScale := self checkScale: aScale.
			scale == nil
				ifTrue: [newScale := checkedScale]
				ifFalse: [newScale := scale * checkedScale].
			newTranslation := checkedScale * translation].
	^WindowingTransformation scale: newScale translation: newTranslation
]

{ #category : #scrolling }
WindowingTransformation >> scrollBy: aPoint [ 
	"Answer a WindowingTransformation with the same scale as the receiver 
	and with a translation of the current translation plus aPoint scaled by 
	the current scale. It is used when the translation is known in source 
	coordinates, rather than scaled source coordinates (see 
	WindowingTransformation|translateBy:). An example is that of scrolling 
	objects with respect to a stationary window in the source coordinate 
	system. If no scaling is in effect (scale = nil), then 
	WindowingTransformation|translateBy: and 
	WindowingTransformation|scrollBy: are equivalent."

	| newTranslation |
	scale == nil
		ifTrue: [newTranslation := aPoint]
		ifFalse: [newTranslation := scale * aPoint].
	^self translateBy: newTranslation
]

{ #category : #private }
WindowingTransformation >> setScale: aScale translation: aTranslation [ 
	"Sets the scale to aScale and the translation to aTranslation."

	scale := aScale.
	translation := aTranslation
]

{ #category : #transforming }
WindowingTransformation >> translateBy: aPoint [ 
	"Answer a WindowingTransformation with the same scale as the receiver 
	and with a translation of the current translation plus aPoint. It is used 
	when the translation is known in scaled source coordinates, rather than 
	source coordinates (see WindowingTransformation|scrollBy:). If no scaling 
	is in effect (scale = nil), then WindowingTransformation|translateBy: and 
	WindowingTransformation|scrollBy: are equivalent."

	^WindowingTransformation scale: scale translation: translation + aPoint
]

{ #category : #transforming }
WindowingTransformation >> translation [
	"Answer a copy of the receiver's translation."

	^translation copy
]
