"
I'm the abstract class Magnitude that provides common protocol for objects that have
the ability to be compared along a linear dimension, such as dates or times.
Subclasses of Magnitude include Date, ArithmeticValue, and Time, as well as
Character and LookupKey.
 
 
My subclasses should implement
  < aMagnitude 
  = aMagnitude 
  hash

Here are some example of my protocol:
     3 > 4
     5 = 6
     100 max: 9
	7 between: 5 and: 10 

"
Class {
	#name : #Magnitude,
	#superclass : #Object,
	#category : #'Kernel-Numbers'
}

{ #category : #comparing }
Magnitude >> < aMagnitude [ 
	"Answer whether the receiver is less than the argument."

	^self subclassResponsibility
]

{ #category : #comparing }
Magnitude >> <= aMagnitude [ 
	"Answer whether the receiver is less than or equal to the argument."

	^(self > aMagnitude) not
]

{ #category : #sorting }
Magnitude >> <=> anotherObject [
	"Return a collation order of -1, 0, or 1, indicating whether I should be collated before the receiver, am equal, or after.
	See also:  http://en.wikipedia.org/wiki/Spaceship_operator"

	self = anotherObject ifTrue: [ ^0 ].
	self < anotherObject ifTrue: [ ^-1 ].
	^1
]

{ #category : #comparing }
Magnitude >> = aMagnitude [ 
	"Compare the receiver with the argument and answer with true if the 
	receiver is equal to the argument. Otherwise answer false."

	^self subclassResponsibility
]

{ #category : #comparing }
Magnitude >> > aMagnitude [ 
	"Answer whether the receiver is greater than the argument."

	^aMagnitude < self
]

{ #category : #comparing }
Magnitude >> >= aMagnitude [ 
	"Answer whether the receiver is greater than or equal to the argument."

	^aMagnitude <= self
]

{ #category : #comparing }
Magnitude >> between: min and: max [ 
	"Answer whether the receiver is less than or equal to the argument, max, 
	and greater than or equal to the argument, min."

	min <= self ifFalse: [ ^false ].
	^self <= max
]

{ #category : #testing }
Magnitude >> clampHigh: highMagnitude [
"Answer my value, but keep it less than highMagnitude"

	^ self min: highMagnitude
]

{ #category : #testing }
Magnitude >> clampLow: lowMagnitude [
"Answer my value, but keep it greater than lowMagnitude"

	^ self max: lowMagnitude
]

{ #category : #testing }
Magnitude >> clampLow: lowMagnitude high: highMagnitude [
"Answer my value, but keep it between lowMagnitude and highMagnitude"

	^ self min: highMagnitude max: lowMagnitude
]

{ #category : #comparing }
Magnitude >> hash [
	"Hash must be redefined whenever = is redefined."

	^self subclassResponsibility
]

{ #category : #comparing }
Magnitude >> inRangeOf: first and: second [ 
	"Answer whether the receiver is in the range between first and second, even if first is > second."
	^ first < second
		ifTrue:
			[ self
				between: first
				and: second ]
		ifFalse:
			[ self
				between: second
				and: first ]
]

{ #category : #testing }
Magnitude >> max: aMagnitude [ 
	"Answer the receiver or the argument, whichever has the greater 
	magnitude."

	self > aMagnitude
		ifTrue: [^self]
		ifFalse: [^aMagnitude]
]

{ #category : #testing }
Magnitude >> min: aMagnitude [ 
	"Answer the receiver or the argument, whichever has the lesser 
	magnitude."

	self < aMagnitude
		ifTrue: [^self]
		ifFalse: [^aMagnitude]
]

{ #category : #testing }
Magnitude >> min: aMin max: aMax [ 

	^ (self min: aMin) max: aMax
]

{ #category : #streaming }
Magnitude >> putOn: aStream [

	(aStream isBinary ifTrue: [ self asByteArray ] ifFalse: [ self asString]) putOn: aStream
	
 
]
