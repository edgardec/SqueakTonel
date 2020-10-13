Class {
	#name : #TextMorphTest,
	#superclass : #ClassTestCase,
	#category : #'MorphicTests-Basic'
}

{ #category : #testing }
TextMorphTest >> testInitialize [
	"For now, just make sure initialization doesn't throw exception"
	TextMorph initialize.
]
