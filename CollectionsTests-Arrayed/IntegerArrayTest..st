"
Verify storage of integer values in an IntegerArray. An IntegerArray stores 32-bit signed integer values. Lack of range check in primitive fallback code leads to arithmetic overflow errors, so attempts to store out of range values should raise errors.
"
Class {
	#name : #IntegerArrayTest,
	#superclass : #ClassTestCase,
	#category : #'CollectionsTests-Arrayed'
}

{ #category : #tests }
IntegerArrayTest >> testStoreLargeNegativeInteger [
	"A LargeNegativeInteger that does not exceed the range of a 32-bit twos
	complement integer may be stored."

	| ia val |
	ia := IntegerArray new: 1.
	val := (2 raisedTo: 31) negated. "smallest negative 32-bit integer, a LargeNegativeInteger"
	ia at: 1 put: val.
	self assert: ((ia at: 1) = val)

]

{ #category : #tests }
IntegerArrayTest >> testStoreLargePositiveInteger [
	"A LargePositiveInteger that does not exceed the range of a 32-bit twos
	complement integer may be stored."

	| ia val |
	ia := IntegerArray new: 1.
	val := (2 raisedTo: 31) - 1. "largest positive 32-bit integer, a LargePositiveInteger"
	ia at: 1 put: val.
	self assert: ((ia at: 1) = val)

]

{ #category : #tests }
IntegerArrayTest >> testStoreNegativeOutOfRange [
	"A value too small for a 32-bit signed integer should raise an error."

	| ia val |
	ia := IntegerArray new: 1.
	val := (2 raisedTo: 31) negated - 1. " -16r80000001 of range for 32-bit twos complement integer"
	self should: [ | storedValue |
				ia at: 1 put: val. "should raise error here"
				storedValue := ia at: 1. "lack of range check leads to value of 16r7FFFFFFF"
				self assert: val = storedValue "fail here"]
		raise: Error

]

{ #category : #tests }
IntegerArrayTest >> testStorePositiveOutOfRange [
	"A value too large for a 32-bit signed integer should raise an error."

	| ia val |
	ia := IntegerArray new: 1.
	val := 2 raisedTo: 31. "16r80000000 is out of range for 32-bit twos complement"
	self should: [ | storedValue |
				ia at: 1 put: val. "should raise error here"
				storedValue := ia at: 1. "lack of range check leads to value of 16r-80000000"
				self assert: val = storedValue "fail here"]
		raise: Error

]

{ #category : #tests }
IntegerArrayTest >> testStoreSmallInteger [
	"Any SmallInteger may be stored in an IntegerArray in a 32bits VM.
	Not so true for a 64bits spur VM though..."

	| ia val |
	ia := IntegerArray new: 1.
	val := Smalltalk wordSize = 8
		ifTrue: [1 << 31 - 1]
		ifFalse: [SmallInteger maxVal].
	ia at: 1 put: val.
	self assert: ((ia at: 1) = val).

	val := Smalltalk wordSize = 8
		ifTrue: [(1 << 31) negated]
		ifFalse: [SmallInteger minVal].
	ia at: 1 put: val.
	self assert: ((ia at: 1) = val)

]
