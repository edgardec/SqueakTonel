"
RawBitsArray is an abstract superclass for all arrays whose elements are not stored as pointer but as raw bits of fixed-width.
See Behavior>>#isBits.
Currently, SpurVM supports arrays of elements with a bit-width of 8, 16, 32, or 64 bits.
When accessing a specific element with #basicAt: or #basicAt:put:, the bits are exchanged under the form of an unsigned Integer.
The range of such integer must be between 0 and 2**bitWidth-1.

The subclasses are free to re-interpret those bits as more specialized Objects.
Unless they represent unisgned Integers, they shall define at least two methods:
- #at:put: should take an object as argument and encode it into raw bits (an unsigned Integer no longer than expected bit-width)
- #at: should convert the raw bits into an Object
Note that SpurVM supports conversion to/from signed integer via primitives 165 and 166.

The name of subclasses is historical and constrained by backward compatibility.
"
Class {
	#name : #RawBitsArray,
	#superclass : #ArrayedCollection,
	#category : #'Collections-Arrayed'
}

{ #category : #accessing }
RawBitsArray >> atAllPut: anObject [
	self isEmpty ifTrue: [^self].
	"Note: #primFill: (primitiveConstantFill) does only handle unsigned integer.
	Let at:put: take care of properly encoding anObject as bits"
	self at: 1 put: anObject.
	self primFill: (self basicAt: 1)
]

{ #category : #private }
RawBitsArray >> primFill: aPositiveInteger [
	"Fill the receiver, an indexable bytes or words object, with the given positive integer.
	The range of possible fill values is :
	- [0..255] for byte arrays;
	- [0..65535] for double byte arrays;
	- [0..(2^32 - 1)] for word arrays;
	- [0..(2^64 - 1)] for double word arrays."

	<primitive: 145>
	self errorImproperStore.
]
