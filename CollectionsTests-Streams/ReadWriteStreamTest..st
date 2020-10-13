"
This is the unit test for the class ReadWriteStream.
Unit tests are a good way to exercise the
functionality of your system in a repeatable and
automatic manner. They are therefore recommended if
you plan to release anything. For more information,
see: 
	- http://www.c2.com/cgi/wiki?UnitTest
	- http://minnow.cc.gatech.edu/squeak/1547
	- the sunit class category
"
Class {
	#name : #ReadWriteStreamTest,
	#superclass : #ClassTestCase,
	#category : #'CollectionsTests-Streams'
}

{ #category : #tests }
ReadWriteStreamTest >> testConstructionUsingWith [
	"Use the with: constructor."

	| aStream |
	aStream := ReadWriteStream with: #(1 2).
	self assert: (aStream contents = #(1 2)) description: 'Ensure correct initialization.'
]

{ #category : #'tests - testing' }
ReadWriteStreamTest >> testIsEmpty [
	| stream |
	stream := ReadWriteStream on: String new.
	self assert: stream isEmpty.
	stream nextPut: $a.
	self deny: stream isEmpty.
	stream reset.
	self deny: stream isEmpty.
	stream next.
	self deny: stream isEmpty.
]

{ #category : #tests }
ReadWriteStreamTest >> testNew [

	self should: [ReadWriteStream new] raise: Error.
]

{ #category : #tests }
ReadWriteStreamTest >> testOnFromTo [
	self assert: (ReadWriteStream
						on: (String withAll: ((0 to: 255) collect: [:n| n asCharacter]))
						from: $A asInteger + 1
						to: $Z asInteger + 1)
					contents
		equals: (String withAll: ($A to: $Z))
]

{ #category : #tests }
ReadWriteStreamTest >> testOnFromToWriting [
	| aToZ |
	aToZ := String withAll: ($A to: $Z).
	self assert: ((ReadWriteStream
						on: (String withAll: ((0 to: 255) collect: [:n| n asCharacter]))
						from: $A asInteger + 1
						to: $Z asInteger + 1)
					nextPutAll: aToZ;
					contents)
		equals: aToZ
]

{ #category : #tests }
ReadWriteStreamTest >> testReadWriteStreamNextNBug [
	| aStream |
	aStream := ReadWriteStream on: String new.
	aStream nextPutAll: 'Hello World'.
	"This should not fail"
	aStream next: 5.
]
