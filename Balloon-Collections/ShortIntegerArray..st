"
ShortIntegerArray is an array for efficiently representing integers in the 16bit range.
"
Class {
	#name : #ShortIntegerArray,
	#superclass : #ArrayedCollection,
	#type : #words,
	#classVars : [
		'LastSaveOrder'
	],
	#category : #'Balloon-Collections'
}

{ #category : #'class initialization' }
ShortIntegerArray class >> initialize [
	"ShortIntegerArray initialize"
	Smalltalk addToStartUpList: self after: Delay.
	LastSaveOrder := self new: 2.
	LastSaveOrder at: 1 put: 42.
	LastSaveOrder at: 2 put: 13.
]

{ #category : #'instance creation' }
ShortIntegerArray class >> new: n [
	^super new: n + 1 // 2
]

{ #category : #'system startup' }
ShortIntegerArray class >> startUp: resuming [
	"Check if the word order has changed from the last save"
	resuming ifFalse: [ ^ self ].
	((LastSaveOrder at: 1) = 42 and:[(LastSaveOrder at: 2) = 13]) 
		ifTrue:[^self]. "Okay"
	((LastSaveOrder at: 2) = 42 and:[(LastSaveOrder at: 1) = 13]) 
		ifTrue:[^self swapShortObjects]. "Reverse guys"
	^self error:'This must never happen'
]

{ #category : #'class initialization' }
ShortIntegerArray class >> startUpFrom: endiannessHasToBeFixed [
	"In this case, do we need to swap word halves when reading this segement?"

	^endiannessHasToBeFixed
			ifTrue: [Message selector: #swapShortObjects]		"will be run on each instance"
			ifFalse: [nil].

]

{ #category : #'class initialization' }
ShortIntegerArray class >> swapShortObjects [
	self allSubInstancesDo:[:inst| inst swapShortObjects]
]

{ #category : #accessing }
ShortIntegerArray >> at: index [
	"Return the 16-bit integer value at the given index of the receiver."

	<primitive: 143>
	index isInteger ifTrue: [self errorSubscriptBounds: index].
	index isNumber ifTrue: [^ self at: index truncated].
	self errorNonIntegerIndex.

]

{ #category : #accessing }
ShortIntegerArray >> at: index put: value [
	"Store the given 16-bit integer at the given index in the receiver."

	<primitive: 144>
	index isInteger
		ifTrue: [
			(index >= 1 and: [index <= self size])
				ifTrue: [self errorImproperStore]
				ifFalse: [self errorSubscriptBounds: index]].
	index isNumber ifTrue: [^ self at: index truncated put: value].
	self errorNonIntegerIndex.

]

{ #category : #'objects from disk' }
ShortIntegerArray >> bytesPerBasicElement [
	^4
]

{ #category : #'objects from disk' }
ShortIntegerArray >> bytesPerElement [
	^2
]

{ #category : #accessing }
ShortIntegerArray >> defaultElement [
	^0
]

{ #category : #private }
ShortIntegerArray >> pvtAt: index [
	"Private -- for swapping only"
	<primitive: 143>
	index isInteger ifTrue: [self errorSubscriptBounds: index].
	index isNumber ifTrue: [^ self at: index truncated].
	self errorNonIntegerIndex.

]

{ #category : #private }
ShortIntegerArray >> pvtAt: index put: value [
	"Private -- for swapping only"
	<primitive: 144>
	index isInteger
		ifTrue: [
			(index >= 1 and: [index <= self size])
				ifTrue: [self errorImproperStore]
				ifFalse: [self errorSubscriptBounds: index]].
	index isNumber ifTrue: [^ self at: index truncated put: value].
	self errorNonIntegerIndex.

]

{ #category : #'objects from disk' }
ShortIntegerArray >> restoreEndianness [
	"This word object was just read in from a stream.  It was stored in Big Endian (Mac) format.  Swap each pair of bytes (16-bit word), if the current machine is Little Endian.
	Why is this the right thing to do?  We are using memory as a byteStream.  High and low bytes are reversed in each 16-bit word, but the stream of words ascends through memory.  Different from a Bitmap."

	| hack blt |
	Smalltalk isLittleEndian ifTrue: [
		"The implementation is a hack, but fast for large ranges"
		hack := Form new hackBits: self.
		blt := (BitBlt toForm: hack) sourceForm: hack.
		blt combinationRule: Form reverse.  "XOR"
		blt sourceY: 0; destY: 0; height: hack height; width: 1.
		blt sourceX: 0; destX: 1; copyBits.  "Exchange bytes 0 and 1"
		blt sourceX: 1; destX: 0; copyBits.
		blt sourceX: 0; destX: 1; copyBits.
		blt sourceX: 2; destX: 3; copyBits.  "Exchange bytes 2 and 3"
		blt sourceX: 3; destX: 2; copyBits.
		blt sourceX: 2; destX: 3; copyBits
	].

]

{ #category : #accessing }
ShortIntegerArray >> size [
	^super size * 2
]

{ #category : #private }
ShortIntegerArray >> swapShortObjects [
	"Private -- swap all the short quantities in the receiver"
	| tmp |
	1 to: self basicSize do:[:i|
		tmp := (self pvtAt: i * 2).
		self pvtAt: i * 2 put: (self pvtAt: i * 2 - 1).
		self pvtAt: i * 2 - 1 put: tmp.
	]
]

{ #category : #'objects from disk' }
ShortIntegerArray >> writeOn: aStream [ 

	aStream nextInt32Put: self basicSize.

	1 to: self basicSize do: [ :i | | w |
		w := self basicAt: i.
		Smalltalk isLittleEndian
			ifFalse: [ aStream nextNumber: 4 put:  w ]
			ifTrue: [ aStream
				nextPut: (w digitAt: 2);
				nextPut: (w digitAt: 1);
				nextPut: (w digitAt: 4);
				nextPut: (w digitAt: 3) ]].
]
