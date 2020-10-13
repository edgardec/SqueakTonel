Class {
	#name : #TextKernTest,
	#superclass : #HashAndEqualsTestCase,
	#category : #'CollectionsTests-Text'
}

{ #category : #tests }
TextKernTest >> setUp [
	super setUp.
	prototypes
		add: (TextKern kern: 1) 
]
