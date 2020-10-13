"
A subclass of BorderedMorph that supports different fillStyles.

RectangleMorph diagonalPrototype openInWorld.
RectangleMorph gradientPrototype openInWorld.
"
Class {
	#name : #RectangleMorph,
	#superclass : #BorderedMorph,
	#category : #'Morphic-Basic'
}

{ #category : #'parts bin' }
RectangleMorph class >> descriptionForPartsBin [
	^ self partName:	'Rectangle' translatedNoop
		categories:		{'Graphics' translatedNoop. 'Basic' translatedNoop}
		documentation:	'A rectangular shape, with border and fill style' translatedNoop
]

{ #category : #'parts bin' }
RectangleMorph class >> diagonalPrototype [

	| rr |
	rr := self authoringPrototype.
	rr useGradientFill; borderWidth: 0.
	rr fillStyle direction: rr extent.
	^ rr
]

{ #category : #'parts bin' }
RectangleMorph class >> gradientPrototype [

	| rr |
	rr := self authoringPrototype.
	rr useGradientFill; borderWidth: 0.
	^ rr
]

{ #category : #'parts bin' }
RectangleMorph class >> roundRectPrototype [
	"Answer a prototypical RoundRect object for a parts bin."

	^ self authoringPrototype useRoundedCorners 
		color: (Color r: 1.0 g: 0.3 b: 0.6); 
		borderWidth: 1;
		setNameTo: 'RoundRect'
]

{ #category : #'visual properties' }
RectangleMorph >> canHaveFillStyles [
	"Return true if the receiver can have general fill styles; not just colors.
	This method is for gradually converting old morphs."
	^self class == RectangleMorph "no subclasses"
]

{ #category : #initialization }
RectangleMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color
		r: 0.613
		g: 0.903
		b: 1.0
]

{ #category : #accessing }
RectangleMorph >> wantsToBeCachedByHand [
	"Return true if the receiver wants to be cached by the hand when it is dragged around."
	self hasTranslucentColor ifTrue:[^false].
	self bounds = self fullBounds ifTrue:[^true].
	self submorphsDo:[:m|
		(self bounds containsRect: m fullBounds) ifFalse:[
			m wantsToBeCachedByHand ifFalse:[^false].
		].
	].
	^true
]
