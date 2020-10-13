"
A CircleMorphTest is a subclass of MorphTest.  It was first implemented when removing some unused and broken functionality.

My fixtures are morph, a CircleMorph and world.

"
Class {
	#name : #CircleMorphTest,
	#superclass : #MorphTest,
	#category : #'MorphicTests-Basic'
}

{ #category : #'initialize-release' }
CircleMorphTest >> setUp [
	morph := CircleMorph new
]
