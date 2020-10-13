Class {
	#name : #HighlightMorph,
	#superclass : #Morph,
	#instVars : [
		'target',
		'lastHash',
		'stepTime'
	],
	#category : #'Etoys-Squeakland-Etoys-Debugger'
}

{ #category : #'as yet unclassified' }
HighlightMorph class >> on: targetMorph [
	^ self basicNew initializeWith: targetMorph
]

{ #category : #testing }
HighlightMorph >> containsPoint: aPoint [
^ (self bounds containsPoint: aPoint) and:
	  [(self imageForm isTransparentAt: aPoint - bounds origin) not]
]

{ #category : #stepping }
HighlightMorph >> incrementStepTime [
	stepTime := (stepTime + 1) min: self maximumStepTime
]

{ #category : #'initialize-release' }
HighlightMorph >> initialize [
	super initialize.
	stepTime := self minimumStepTime.
	self color: Color transparent;
		borderWidth: 2;
		borderColor: Color red muchDarker muchDarker
]

{ #category : #'initialize-release' }
HighlightMorph >> initializeWith: targetMorph [
	target := targetMorph.
	self initialize
]

{ #category : #stepping }
HighlightMorph >> maximumStepTime [
	^500
]

{ #category : #stepping }
HighlightMorph >> minimumStepTime [
	^20
]

{ #category : #stepping }
HighlightMorph >> step [
	(target isNil or: [lastHash = (lastHash := target boundsSignatureHash)])
		ifTrue: [self incrementStepTime]
		ifFalse: [stepTime := self minimumStepTime].

	target notNil ifTrue: [
		target isInWorld ifFalse: [^self delete].
		self bounds: target bounds]
]

{ #category : #stepping }
HighlightMorph >> stepTime [
	^ stepTime
]
