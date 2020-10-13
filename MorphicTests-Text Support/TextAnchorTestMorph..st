Class {
	#name : #TextAnchorTestMorph,
	#superclass : #Morph,
	#category : #'MorphicTests-Text Support'
}

{ #category : #initialization }
TextAnchorTestMorph >> initialize [

	super initialize.
	self height: 20.
]

{ #category : #'text-anchor' }
TextAnchorTestMorph >> myBaseline [

	^ 5
]
