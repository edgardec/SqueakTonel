Class {
	#name : #TextLineTest,
	#superclass : #HashAndEqualsTestCase,
	#category : #'MorphicTests-Text Support'
}

{ #category : #'initialize-release' }
TextLineTest >> setUp [
	super setUp.
	prototypes
		add: (TextLine
				start: 1
				stop: 50
				internalSpaces: 2
				paddingWidth: 1) 
]
