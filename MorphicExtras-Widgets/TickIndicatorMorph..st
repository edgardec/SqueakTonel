Class {
	#name : #TickIndicatorMorph,
	#superclass : #EllipseMorph,
	#instVars : [
		'stepTime',
		'corners',
		'index',
		'range',
		'isTicking',
		'lastTick'
	],
	#category : #'MorphicExtras-Widgets'
}

{ #category : #accessing }
TickIndicatorMorph >> color: aColor [
	super color: aColor.
	self borderColor: aColor darker.
]

{ #category : #initialization }
TickIndicatorMorph >> defaultBorderColor [
	"answer the default border color/fill style for the receiver"
	^ self defaultColor darker

]

{ #category : #initialization }
TickIndicatorMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color
		r: 0.767
		g: 0.767
		b: 1.0
]

{ #category : #drawing }
TickIndicatorMorph >> drawOn: aCanvas [
	| r center cc deg |
	super drawOn: aCanvas.
	corners ifNil:[
		r := (bounds topCenter - bounds center) r - 2.
		corners := Array new: 32.
		1 to: corners size do:[:i|
			deg := 360.0 / corners size * (i-1).
			corners at: i put: (Point r: r degrees: deg-90) asIntegerPoint]].
	index := index \\ corners size.
	cc := color darker.
	center := bounds center.
	1 to: corners size by: 4 do:[:i|
		aCanvas fillRectangle: (center + (corners at: i)-2  extent: 4@4) color: cc.
	].
	cc := cc darker.
	aCanvas line: center to: center + (corners at: index + 1) width: 2 color: cc.
]

{ #category : #geometry }
TickIndicatorMorph >> extent: aPoint [
	super extent: ((aPoint x max: aPoint y)  asInteger bitClear: 3) asPoint.
	corners := nil.
]

{ #category : #initialization }
TickIndicatorMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""

	self extent: 30 @ 30.
	index := 0
]

{ #category : #accessing }
TickIndicatorMorph >> isTicking [
	^isTicking ifNil:[false].
]

{ #category : #accessing }
TickIndicatorMorph >> isTicking: aBool [
	isTicking := aBool.
]

{ #category : #private }
TickIndicatorMorph >> privateMoveBy: delta [
	corners := nil.
	super privateMoveBy: delta
]

{ #category : #'stepping and presenter' }
TickIndicatorMorph >> stepAt: nowTick [ 
	| delta |
	self isTicking 
		ifTrue: 
			[(lastTick isNil or: [nowTick < lastTick]) ifTrue: [lastTick := nowTick].
			delta := (nowTick - lastTick) // self stepTime.
			delta > 0 
				ifTrue: 
					[index := index + delta.
					lastTick := nowTick.
					self changed]]
]

{ #category : #'stepping and presenter' }
TickIndicatorMorph >> stepTime [
	^(stepTime ifNil:[125]) max: 50
]

{ #category : #accessing }
TickIndicatorMorph >> stepTime: aNumber [
	stepTime := aNumber max: 1.
]

{ #category : #'stepping and presenter' }
TickIndicatorMorph >> wantsSteps [
	^true
]
