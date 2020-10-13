"
This class stores 32bit Integer points in place. It is used to pass data efficiently to the primitive level during high-bandwidth 2D graphics operations.
"
Class {
	#name : #PointArray,
	#superclass : #SignedWordArray,
	#type : #words,
	#category : #'Balloon-Collections'
}

{ #category : #'instance creation' }
PointArray class >> new: n [
	^super new: n*2
]

{ #category : #converting }
PointArray >> asPointArray [
	^ self
]

{ #category : #accessing }
PointArray >> at: index [
	"Return the element (e.g., point) at the given index"
	^(super at: index * 2 - 1) @ (super at: index * 2)
]

{ #category : #accessing }
PointArray >> at: index put: aPoint [
	"Store the argument aPoint at the given index"
	super at: index * 2 - 1 put: aPoint x asInteger.
	super at: index * 2 put: aPoint y asInteger.
	^aPoint
]

{ #category : #accessing }
PointArray >> bounds [
	| min max |
	min := max := self at: 1.
	self do:[:pt|
		min := min min: pt.
		max := max max: pt].
	^min corner: max
		
]

{ #category : #accessing }
PointArray >> bytesPerElement [
	"Each element occupy two slots"
	^ 8
]

{ #category : #accessing }
PointArray >> defaultElement [
	"Return the default element of the receiver"
	^0@0
]

{ #category : #accessing }
PointArray >> size [
	"Return the number of elements in the receiver"
	^super size // 2
]
