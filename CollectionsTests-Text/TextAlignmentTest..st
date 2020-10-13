Class {
	#name : #TextAlignmentTest,
	#superclass : #HashAndEqualsTestCase,
	#category : #'CollectionsTests-Text'
}

{ #category : #running }
TextAlignmentTest >> setUp [
	super setUp.
	prototypes add: TextAlignment centered;
		 add: TextAlignment justified;
		 add: TextAlignment leftFlush;
		 add: TextAlignment rightFlush 
]
