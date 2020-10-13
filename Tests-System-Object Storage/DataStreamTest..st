Class {
	#name : #DataStreamTest,
	#superclass : #TestCase,
	#category : #'Tests-System-Object Storage'
}

{ #category : #helper }
DataStreamTest >> get: aSerialized [

	^ self streamClass unStream: aSerialized
]

{ #category : #helper }
DataStreamTest >> put: anObject [

	^ self streamClass streamedRepresentationOf: anObject.
]

{ #category : #constants }
DataStreamTest >> streamClass [
	^ DataStream
]

{ #category : #tests }
DataStreamTest >> testCharacter [
	| c |
	c := Character value: 16r271D.
	self assert: c equals: (self testObject: c) description: 'Characters should be serializable'
]

{ #category : #tests }
DataStreamTest >> testFloat [
	| f |
	f := Float pi.
	self assert: f equals: (self testObject: f) description: 'Floats should be serializable'.

]

{ #category : #tests }
DataStreamTest >> testLargeIntergers [
	| i |
	i := 123456789012345678901234567890.
	self assert: i equals: (self testObject: i) description: 'A large positive integer should be serializable'.
	
	i := -123456789012345678901234567890.
	self assert: i equals: (self testObject: i) description: 'A large negative integer should be serializable'
]

{ #category : #tests }
DataStreamTest >> testNotTooLargeIntergers [
	| i |
	i := 1234567890123.
	self assert: i equals: (self testObject: i) description: 'A larger, but not too large positive integer should be serializable'.
	
	i := -1234567890123.
	self assert: i equals: (self testObject: i) description: 'A  larger, but not too large negative integer should be serializable'
]

{ #category : #helper }
DataStreamTest >> testObject: anObject [
	
	| serialized |
	serialized :=  self put: anObject.
	^ self get: serialized
]

{ #category : #tests }
DataStreamTest >> testSmallInteger [
	| i |
	i := SmallInteger maxVal.
	self assert: i equals: (self testObject: i) description: 'The maximum small integer should be serializable'.
	
	i := SmallInteger minVal.
	self assert: i equals: (self testObject: i) description: 'The minimum small integer should be serializable'
]
