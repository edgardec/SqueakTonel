"
I am an abstract class that represents an accessor for a sequence of objects. This sequence is referred to as my ""contents"".
"
Class {
	#name : #Stream,
	#superclass : #Object,
	#category : #'Collections-Streams'
}

{ #category : #'instance creation' }
Stream class >> new [

	self error: 'Streams are created with on: and with:'
]

{ #category : #readability }
Stream >> << items [

 	items putOn: self.
	
	^ self
]

{ #category : #'collections - accessing' }
Stream >> any: numberOfElements [
	"See Collection protocol."
	
	^ self next: numberOfElements
]

{ #category : #testing }
Stream >> atEnd [
	"Answer whether the receiver can access any more objects."

	self subclassResponsibility
]

{ #category : #'accessing - multibyte support' }
Stream >> basicNext [

	^ self next.

]

{ #category : #'accessing - multibyte support' }
Stream >> basicNext: anInteger [ 

	^self next: anInteger

]

{ #category : #'accessing - multibyte support' }
Stream >> basicNext: anInteger putAll: aCollection startingAt: startIndex [

	^self next: anInteger putAll: aCollection startingAt: startIndex

]

{ #category : #'accessing - multibyte support' }
Stream >> basicNextPut: anObject [ 

	^ self nextPut: anObject
]

{ #category : #'accessing - multibyte support' }
Stream >> basicNextPutAll: aCollection [ 

	^ self nextPutAll: aCollection.

]

{ #category : #accessing }
Stream >> binary [
]

{ #category : #'file open\/close' }
Stream >> close [
]

{ #category : #testing }
Stream >> closed [
	^ false
]

{ #category : #'collections - enumerating' }
Stream >> collect: block [

	^ Generator on: [:g | 
		[self atEnd] whileFalse: [
			g yield: (self next ifNotNil: [:object | block value: object])]]
]

{ #category : #accessing }
Stream >> contents [
	"Answer all of the contents of the receiver."

	self subclassResponsibility
]

{ #category : #'collections - enumerating' }
Stream >> do: aBlock [ 
	"Evaluate aBlock for each of the objects accessible by receiver."

	[self atEnd]
		whileFalse: [aBlock value: self next]
]

{ #category : #converting }
Stream >> flatten [

	^ Generator on: [:g | 
		[self atEnd] whileFalse: [
			self next in: [:object |
				((object isCollection and: [object isString not]) or: [object isStream])
					ifFalse: [g yield: object]
					ifTrue: [object flatten do: [:each | g yield: each]]]]]
]

{ #category : #converting }
Stream >> flattened [
	"An alias for #flatten
	This message's name is in line with messages like #sorted or #reversed
	while #flatten's is in line with #reverse (as per ANSI, see comment there)"

	^ self flatten
]

{ #category : #accessing }
Stream >> flush [
	"Do nothing by default"
]

{ #category : #'collections - enumerating' }
Stream >> gather: block [

	^ Generator on: [:g | 
		[self atEnd] whileFalse: [
			self next
				ifNil: [g yield: nil]
				ifNotNil: [:object |
					(block value: object) do: [:ea |
						g yield: ea]]]]
]

{ #category : #testing }
Stream >> isStream [
	"Return true if the receiver responds to the stream protocol"
	^true
]

{ #category : #testing }
Stream >> isTypeHTTP [
	^false
]

{ #category : #accessing }
Stream >> localName [
	^'a stream'
]

{ #category : #accessing }
Stream >> next [
	"Answer the next object accessible by the receiver."

	self subclassResponsibility
]

{ #category : #accessing }
Stream >> next: anInteger [ 
	"Answer the next anInteger number of objects accessible by the receiver."

	| aCollection |
	aCollection := OrderedCollection new.
	anInteger timesRepeat: [aCollection addLast: self next].
	^aCollection
]

{ #category : #accessing }
Stream >> next: n into: aCollection [
	"Read n objects into the given collection.
	Return aCollection or a partial copy if less than
	n elements have been read."
	^self next: n into: aCollection startingAt: 1
]

{ #category : #accessing }
Stream >> next: n into: aCollection startingAt: startIndex [
	"Read n objects into the given collection. 
	Return aCollection or a partial copy if less than n elements have been read."
	
	| count |
	count := self readInto: aCollection startingAt: startIndex count: n.
	count = n
		ifTrue:[ ^aCollection ]
		ifFalse:[ ^aCollection copyFrom: 1 to: startIndex + count - 1 ]
]

{ #category : #accessing }
Stream >> next: anInteger put: anObject [ 
	"Make anObject be the next anInteger number of objects accessible by the 
	receiver. Answer anObject."

	anInteger timesRepeat: [self nextPut: anObject].
	^anObject
]

{ #category : #accessing }
Stream >> nextInto: aCollection [
	"Read the next elements of the receiver into aCollection.
	Return aCollection or a partial copy if less than aCollection
	size elements have been read."
	^self next: aCollection size into: aCollection startingAt: 1.
]

{ #category : #accessing }
Stream >> nextInto: aCollection startingAt: startIndex [
	"Read the next elements of the receiver into aCollection.
	Return aCollection or a partial copy if less than aCollection
	size elements have been read."
	^self next: (aCollection size - startIndex+1) into: aCollection startingAt: startIndex.
]

{ #category : #accessing }
Stream >> nextMatchAll: aColl [
    "Answer true if next N objects are the ones in aColl,
     else false.  Advance stream of true, leave as was if false."
    | save |
    save := self position.
    aColl do: [:each |
       (self next) = each ifFalse: [
            self position: save.
            ^ false]
        ].
    ^ true
]

{ #category : #accessing }
Stream >> nextMatchFor: anObject [ 
	"Gobble the next object and answer whether it is equal to the argument, 
	anObject."

	^anObject = self next
]

{ #category : #accessing }
Stream >> nextPut: anObject [ 
	"Insert the argument, anObject, as the next object accessible by the 
	receiver. Answer anObject."

	self subclassResponsibility
]

{ #category : #accessing }
Stream >> nextPutAll: aCollection [ 
	"Append the elements of aCollection to the sequence of objects accessible 
	by the receiver. Answer aCollection."

	aCollection do: [:v | self nextPut: v].
	^aCollection
]

{ #category : #accessing }
Stream >> nextSatisfy: aBlock [

	self do: [:each | (aBlock value: each) ifTrue: [^ each]].
	Error signal: 'No object could satisfy the block'.
]

{ #category : #testing }
Stream >> nextWordsPutAll: aCollection [
	"Write the argument a word-like object in big endian format on the receiver.
	May be used to write other than plain word-like objects (such as ColorArray)."
	aCollection class isPointers | aCollection class isWords not 
		ifTrue: [^self error: aCollection class name,' is not word-like'].
	1 to: aCollection basicSize do:[:i|
		self nextNumber: 4 put: (aCollection basicAt: i).
	].
	^aCollection
]

{ #category : #accessing }
Stream >> openReadOnly [
	^self
]

{ #category : #printing }
Stream >> print: anObject [
	"Have anObject print itself on the receiver."

	anObject printOn: self
]

{ #category : #printing }
Stream >> print: anObject  maxDecimalPlaces: placesDesired [
	"Have anObject print itself on the receiver, with at most the given number of decimal places desired."

	anObject printOn: self maxDecimalPlaces: placesDesired
]

{ #category : #printing }
Stream >> printHtml: anObject [
	anObject printHtmlOn: self
]

{ #category : #printing }
Stream >> printOn: stream [

	super printOn: stream.
"
	stream space.
	self contents printOn: stream.
	
	NOTE: some subclasses actually read from the stream to return its contents.
	To not modify the state we must *not* send contents here. 
"
]

{ #category : #accessing }
Stream >> readInto: aCollection startingAt: startIndex count: n [
	"Read n objects into the given collection. 
	Return number of elements that have been read."
	| obj |
	0 to: n - 1 do: [:i |
		obj := self next ifNil: [ ^i ].
		aCollection at: startIndex + i put: obj].
	^n
]

{ #category : #accessing }
Stream >> readOnly [
	^self
]

{ #category : #'collections - enumerating' }
Stream >> reject: aBlock [

	^ self select: [:element | (aBlock value: element) == false]
]

{ #category : #'collections - enumerating' }
Stream >> select: block [

	^ Generator on: [:g |
		[self atEnd] whileFalse: [
			self next
				ifNil: [g yield: nil]
				ifNotNil: [:object |
					(block value: object)
						ifTrue: [g yield: object]]]]
]

{ #category : #'collections - enumerating' }
Stream >> select: block thenCollect: anotherBlock [

	^ (self select: block) collect: anotherBlock
]

{ #category : #'as yet unclassified' }
Stream >> sleep [

	"an FTP-based stream might close the connection here"
]

{ #category : #'collections - accessing' }
Stream >> take: maxNumberOfElements [
	"See Collection protocol."
	
	^ self any: maxNumberOfElements
]

{ #category : #accessing }
Stream >> upToEnd [
	"Answer the remaining elements in the stream."
	
	| elements |
	elements := OrderedCollection new.
	[self atEnd] whileFalse: [ 
		elements add: self next].
	^ elements
]

{ #category : #'filter streaming' }
Stream >> write:encodedObject [
	^encodedObject putOn:self.

]
