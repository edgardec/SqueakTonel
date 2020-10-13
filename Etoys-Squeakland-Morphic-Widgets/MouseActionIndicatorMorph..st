"
I am used to highlight morphs which have a special mouseup action
"
Class {
	#name : #MouseActionIndicatorMorph,
	#superclass : #Morph,
	#instVars : [
		'siblings'
	],
	#category : #'Etoys-Squeakland-Morphic-Widgets'
}

{ #category : #'as yet unclassified' }
MouseActionIndicatorMorph class >> world: aWorld inner: innerRectangle outer: outerRectangle color: aColor [

	| allRects allMorphs |

	allRects := outerRectangle areasOutside: innerRectangle.
	allMorphs := allRects collect: [ :each |
		self new bounds: each; color: aColor
	].
	allMorphs do: [ :each |
		each siblings: allMorphs; openInWorld: aWorld
	].
	^allMorphs



]

{ #category : #'as yet unclassified' }
MouseActionIndicatorMorph >> deleteWithSiblings [

	siblings do: [ :each | each delete]

]

{ #category : #'event handling' }
MouseActionIndicatorMorph >> handlesMouseOver: evt [

	^true
]

{ #category : #'event handling' }
MouseActionIndicatorMorph >> handlesMouseOverDragging: evt [

	^true
]

{ #category : #initialization }
MouseActionIndicatorMorph >> initialize [

	super initialize.
	siblings := #().
]

{ #category : #'event handling' }
MouseActionIndicatorMorph >> mouseEnter: evt [

	self deleteWithSiblings

]

{ #category : #'event handling' }
MouseActionIndicatorMorph >> mouseEnterDragging: evt [

	self deleteWithSiblings

]

{ #category : #'as yet unclassified' }
MouseActionIndicatorMorph >> siblings: aCollection [

	siblings := aCollection.

]
