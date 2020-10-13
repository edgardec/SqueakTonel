Class {
	#name : #TextFontReferenceTest,
	#superclass : #HashAndEqualsTestCase,
	#category : #'CollectionsTests-Text'
}

{ #category : #tests }
TextFontReferenceTest >> setUp [
	super setUp.
	prototypes
		add: (TextFontReference
				toFont: (StrikeFont familyName: 'NewYork' size: 15)) 
]
