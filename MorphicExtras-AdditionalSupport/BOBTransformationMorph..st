Class {
	#name : #BOBTransformationMorph,
	#superclass : #TransformationMorph,
	#instVars : [
		'worldBoundsToShow',
		'useRegularWarpBlt'
	],
	#category : #'MorphicExtras-AdditionalSupport'
}

{ #category : #private }
BOBTransformationMorph >> adjustAfter: changeBlock [ 
	"Cause this morph to remain cetered where it was before, and
	choose appropriate smoothing, after a change of scale or rotation."
	| |

		"oldRefPos := self referencePosition."
	changeBlock value.
	self chooseSmoothing.
		"self penUpWhile: [self position: self position + (oldRefPos - self referencePosition)]."
	self layoutChanged.
	owner ifNotNil: [owner invalidRect: bounds]

]

{ #category : #geometry }
BOBTransformationMorph >> changeWorldBoundsToShow: aRectangle [

	aRectangle area = 0 ifTrue: [^self].
	worldBoundsToShow := aRectangle.
	owner myWorldChanged.
]

{ #category : #drawing }
BOBTransformationMorph >> drawSubmorphsOn: aCanvas [

	| t | 
	t := [
		self drawSubmorphsOnREAL: aCanvas
	] timeToRun.
"Q1 at: 3 put: t."

]

{ #category : #drawing }
BOBTransformationMorph >> drawSubmorphsOnREAL: aCanvas [ 

	| newClip |

	(self innerBounds intersects: aCanvas clipRect) ifFalse: [^self].
	newClip := ((self innerBounds intersect: aCanvas clipRect) expandBy: 1) truncated.
	useRegularWarpBlt == true ifTrue: [
		transform scale asFloat = 1.0 ifFalse: [
			newClip := self innerBounds.		"avoids gribblies"
		].
		^aCanvas 
			transformBy: transform
			clippingTo: newClip
			during: [:myCanvas |
				submorphs reverseDo:[:m | myCanvas fullDrawMorph: m]
			]
			smoothing: smoothing
	].
	aCanvas 
		transform2By: transform		"#transformBy: for pure WarpBlt"
		clippingTo: newClip
		during: [:myCanvas |
			submorphs reverseDo:[:m | myCanvas fullDrawMorph: m]
		]
		smoothing: smoothing

]

{ #category : #geometry }
BOBTransformationMorph >> extent: aPoint [

	| newExtent |

	newExtent := aPoint truncated.
	bounds extent = newExtent ifTrue: [^self].
	bounds := bounds topLeft extent: newExtent.
	self recomputeExtent.


]

{ #category : #geometry }
BOBTransformationMorph >> extentFromParent: aPoint [

	| newExtent |

	submorphs isEmpty ifTrue: [^self extent: aPoint].
	newExtent := aPoint truncated.
	bounds := bounds topLeft extent: newExtent.
	newExtent := self recomputeExtent.
	newExtent ifNil: [^self].
	bounds := bounds topLeft extent: newExtent.


]

{ #category : #layout }
BOBTransformationMorph >> layoutChanged [
	"use the version from Morph"

	| myGuy |
	fullBounds := nil.
	owner ifNotNil: [owner layoutChanged].
	submorphs notEmpty 
		ifTrue: 
			[(myGuy := self firstSubmorph) isWorldMorph 
				ifFalse: 
					[worldBoundsToShow = myGuy bounds 
						ifFalse: [self changeWorldBoundsToShow: (worldBoundsToShow := myGuy bounds)]]

			"submorphs do: [:m | m ownerChanged]"	"<< I don't see any reason for this"]
]

{ #category : #private }
BOBTransformationMorph >> recomputeExtent [

	| scalePt newScale theGreenThingie greenIBE myNewExtent |

	submorphs isEmpty ifTrue: [^self extent].
	worldBoundsToShow ifNil: [worldBoundsToShow := self firstSubmorph bounds].
	worldBoundsToShow area = 0 ifTrue: [^self extent].
	scalePt := owner innerBounds extent / worldBoundsToShow extent.
	newScale := scalePt x min: scalePt y.
	theGreenThingie := owner.
	greenIBE := theGreenThingie innerBounds extent.
	myNewExtent := (greenIBE min: worldBoundsToShow extent * newScale) truncated.
	self
		scale: newScale;
		offset: worldBoundsToShow origin * newScale.
	smoothing := (newScale < 1.0) ifTrue: [2] ifFalse: [1].
	^myNewExtent
]

{ #category : #accessing }
BOBTransformationMorph >> useRegularWarpBlt: aBoolean [

	useRegularWarpBlt := aBoolean
]
