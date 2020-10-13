"
I am not really a container in the sense of TextContainer.  However, I get stored in the same field of a textMorph.  My baseline specifies the vertical displacement of the character baselines from the curve center (0 means on center, 5 would mean, eg, the character baselines are 5 pixels above the curve center).  This is ssential enduring information.  I also cache temporary layout information, including the locations, angles and bounding boxes of each of the characters as displayed.
"
Class {
	#name : #TextOnCurveContainer,
	#superclass : #Object,
	#instVars : [
		'baseline',
		'inset',
		'textDirection',
		'textSegments'
	],
	#category : #'MorphicExtras-Text Support'
}

{ #category : #accessing }
TextOnCurveContainer >> baseline [
	baseline ifNil: [^ 0].
	^ baseline
]

{ #category : #accessing }
TextOnCurveContainer >> baseline: newBaseline [
	baseline := newBaseline
]

{ #category : #accessing }
TextOnCurveContainer >> bounds [
	textSegments ifNil: [^nil].
	^textSegments inject: (textSegments first first)
		into: [:bnd :each | bnd merge: (each first)]
]

{ #category : #accessing }
TextOnCurveContainer >> paragraphClass [
	^ TextOnCurve
]

{ #category : #caching }
TextOnCurveContainer >> releaseCachedState [
	textSegments := nil.
]

{ #category : #accessing }
TextOnCurveContainer >> textDirection [
	^ textDirection
]

{ #category : #accessing }
TextOnCurveContainer >> textDirection: plusOrMinusOne [
	textDirection := plusOrMinusOne
]

{ #category : #accessing }
TextOnCurveContainer >> textSegments [
	^ textSegments
]

{ #category : #accessing }
TextOnCurveContainer >> textSegments: segments [
	textSegments := segments
]

{ #category : #accessing }
TextOnCurveContainer >> top [
	^ 1  "for compatibility"
]

{ #category : #transforming }
TextOnCurveContainer >> translateBy: delta [ 
	textSegments isNil ifTrue: [^self].
	textSegments := textSegments collect: 
					[:ls | 
					Array 
						with: (ls first translateBy: delta)
						with: (ls second translateBy: delta)
						with: ls third]
]
