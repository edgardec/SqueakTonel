Class {
	#name : #EToyTextNodeWrapper,
	#superclass : #ListItemWrapper,
	#instVars : [
		'parentWrapper'
	],
	#category : #'Etoys-Outliner'
}

{ #category : #'as yet unclassified' }
EToyTextNodeWrapper class >> with: anObject model: aModel parent: anotherWrapper [

	^self new
		setItem: anObject model: aModel;
		parentWrapper: anotherWrapper
]

{ #category : #'as yet unclassified' }
EToyTextNodeWrapper >> addNewChildAfter: anotherOrNil [

	item addNewChildAfter: anotherOrNil.

]

{ #category : #'as yet unclassified' }
EToyTextNodeWrapper >> addSibling [

	parentWrapper ifNil: [^Beeper beep].
	parentWrapper addNewChildAfter: item.
]

{ #category : #converting }
EToyTextNodeWrapper >> asString [

	^item contents
]

{ #category : #'as yet unclassified' }
EToyTextNodeWrapper >> contents [

	^item children collect: [ :each | 
		EToyTextNodeWrapper with: each model: model parent: self
	].

]

{ #category : #'as yet unclassified' }
EToyTextNodeWrapper >> delete [

	parentWrapper ifNil: [^Beeper beep].
	parentWrapper withoutListWrapper removeChild: item withoutListWrapper.

]

{ #category : #'as yet unclassified' }
EToyTextNodeWrapper >> hasContents [

	^true
]

{ #category : #'as yet unclassified' }
EToyTextNodeWrapper >> parentWrapper: anotherWrapper [

	parentWrapper := anotherWrapper

]
