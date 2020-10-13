Class {
	#name : #TextStyleTest,
	#superclass : #HashAndEqualsTestCase,
	#category : #'GraphicsTests-Text'
}

{ #category : #'initialize-release' }
TextStyleTest >> setUp [
	super setUp.
	prototypes add: TextStyle default 
]
