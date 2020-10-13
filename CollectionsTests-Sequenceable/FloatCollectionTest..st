Class {
	#name : #FloatCollectionTest,
	#superclass : #ClassTestCase,
	#category : #'CollectionsTests-Sequenceable'
}

{ #category : #tests }
FloatCollectionTest >> testAdd [
	| fc |
	fc := #(1 2 3 4 ) as: FloatCollection.
	fc add: 88.
	self assert: #(1.0 2.0 3.0 4.0 88.0 ) asFloat32Array equals: fc asFloat32Array.
	fc add: 99.
	self assert: (#(1 2 3 4 88 99 ) as: FloatCollection) equals: fc
]

{ #category : #tests }
FloatCollectionTest >> testInternalArray [
	| fc internalArray |
	fc := FloatCollection new.
	self
		 deny: (internalArray := fc instVarNamed: 'array') class isPointers ;
		 assert: fc isEmpty.
	internalArray size + 1 timesRepeat: [ fc add: 0.0 ].
	self
		 assert: fc size = (internalArray size + 1) ;
		 assert: (fc instVarNamed: 'array') size = (internalArray size * 2)
]
