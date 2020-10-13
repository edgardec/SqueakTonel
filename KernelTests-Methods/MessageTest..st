Class {
	#name : #MessageTest,
	#superclass : #TestCase,
	#category : #'KernelTests-Methods'
}

{ #category : #tests }
MessageTest >> testMessageEquality [

	self assert: (Message selector: #= argument: 1) equals: (Message selector: #= argument: 1).
	self assert: (Message selector: #= argument: 1) hash equals: (Message selector: #= argument: 1) hash.
	self deny: (Message selector: #= argument: 1) equals: (Message selector: #= argument: 1.0)
]
