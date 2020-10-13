Class {
	#name : #TileLikeMorph,
	#superclass : #AlignmentMorph,
	#category : #'Etoys-Scripting Tiles'
}

{ #category : #'user interface' }
TileLikeMorph >> fixLayoutOfSubmorphsNotIn: aCollection [ 
	self minCellSize: 0 @ (Preferences standardEToysFont height rounded + 10).
	self
		allMorphsDo: [:m | (aCollection includes: m)
				ifFalse: [(m respondsTo: #fixLayoutOfSubmorphsNotIn:)
						ifTrue: [m ~~ self
								ifTrue: [m fixLayoutOfSubmorphsNotIn: aCollection]]
						ifFalse: [m layoutChanged].
					aCollection add: m]].
	self layoutChanged; fullBounds
]

{ #category : #scripting }
TileLikeMorph >> isTileLike [
	^true
]

{ #category : #'dropping\/grabbing' }
TileLikeMorph >> justGrabbedFrom: formerOwner [
	| editor |
	formerOwner ifNil:[^self].
	editor := formerOwner topEditor.
	editor ifNotNil:[editor scriptEdited].
]

{ #category : #initialization }
TileLikeMorph >> localeChanged [
	"Update myself to reflect the change in locale"

	self updateWordingToMatchVocabulary.
	self fullBounds.

]

{ #category : #'user interface' }
TileLikeMorph >> updateWordingToMatchVocabulary [
	"If appropriate, change the wording on the receiver to match up with a changed vocabulary."
]
