"
This class stores points that are in short integer range (e.g., -32768 <= value <= 32767). It is used to pass data efficiently to the primitive level during high-bandwidth 2D graphics operations.
"
Class {
	#name : #ShortPointArray,
	#superclass : #ShortIntegerArray,
	#type : #words,
	#category : #'Balloon-Collections'
}

{ #category : #'instance creation' }
ShortPointArray class >> new: n [
	^super new: n * 2
]

{ #category : #accessing }
ShortPointArray >> at: index [
	"Return the element (e.g., point) at the given index"
	^(super at: index * 2 - 1) @ (super at: index * 2)
]

{ #category : #accessing }
ShortPointArray >> at: index put: aPoint [
	"Store the argument aPoint at the given index"
	super at: index * 2 - 1 put: aPoint x asInteger.
	super at: index * 2 put: aPoint y asInteger.
	^aPoint
]

{ #category : #accessing }
ShortPointArray >> bounds [
	| min max |
	min := max := self at: 1.
	self do:[:pt|
		min := min min: pt.
		max := max max: pt].
	^min corner: max
		
]

{ #category : #accessing }
ShortPointArray >> bytesPerElement [

	^ 4.
	
]

{ #category : #accessing }
ShortPointArray >> defaultElement [
	"Return the default element of the receiver"
	^0@0
]

{ #category : #accessing }
ShortPointArray >> size [
	^self basicSize
]
