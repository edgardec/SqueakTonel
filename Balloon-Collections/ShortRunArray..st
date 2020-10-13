"
This class is run-length encoded representation of short integer (e.g., 16bit signed integer values)
"
Class {
	#name : #ShortRunArray,
	#superclass : #ArrayedCollection,
	#type : #words,
	#classVars : [
		'LastSaveOrder'
	],
	#category : #'Balloon-Collections'
}

{ #category : #'class initialization' }
ShortRunArray class >> initialize [
	"ShortRunArray initialize"
	Smalltalk addToStartUpList: self after: Delay.
	LastSaveOrder := #(42 42 42) as: self.
]

{ #category : #'instance creation' }
ShortRunArray class >> new [
	^self newFrom: #()
]

{ #category : #'instance creation' }
ShortRunArray class >> new: n [
	"ShortRunArrays must be created with either
		someCollection as: ShortRunArray
	or by using
		ShortRunArray runs: runCollection values: valueCollection.
	"
	^self shouldNotImplement
]

{ #category : #'instance creation' }
ShortRunArray class >> newFrom: aCollection [
	"Compress aCollection into a ShortRunArray"
	| lastValue lastRun runs values |
	aCollection isEmpty ifTrue:[^self runs:#() values: #()].
	runs := WriteStream on: (WordArray new: 100).
	values := WriteStream on: (ShortIntegerArray new: 100).
	lastValue := aCollection first.
	lastRun := 0.
	aCollection do:[:item|
		(item = lastValue and:[lastRun < 16r8000]) ifTrue:[
			lastRun := lastRun + 1.
		] ifFalse:[
			runs nextPut: lastRun.
			values nextPut: lastValue.
			lastRun := 1.
			lastValue := item.
		].
	].
	runs nextPut: lastRun.
	values nextPut: lastValue.
	^self runs: runs contents values: values contents
]

{ #category : #'instance creation' }
ShortRunArray class >> runs: runCollection values: valueCollection [
	^(self basicNew: runCollection size) setRuns: runCollection values: valueCollection
]

{ #category : #'system startup' }
ShortRunArray class >> startUp: resuming [
	"Check if the word order has changed from the last save"
	resuming ifFalse: [ ^ self ].
	((LastSaveOrder valueAtRun: 1) = 42 and:[(LastSaveOrder lengthAtRun: 1) = 3]) 
		ifTrue:[^self]. "Okay"
	((LastSaveOrder lengthAtRun: 1) = 42 and:[(LastSaveOrder valueAtRun: 1) = 3]) 
		ifTrue:[^self swapRuns]. "Reverse guys"
	^self error:'This must never happen'
]

{ #category : #'class initialization' }
ShortRunArray class >> startUpFrom: endiannessHasToBeFixed [ 
	"In this case, do we need to swap word halves when reading this segement?"

	^endiannessHasToBeFixed
		ifTrue: [Message selector: #swapRuns	"will be run on each instance"]
		ifFalse: [nil]
]

{ #category : #'class initialization' }
ShortRunArray class >> swapRuns [
	self allSubInstancesDo:[:inst| inst swapRuns]
]

{ #category : #accessing }
ShortRunArray >> at: index [
	"Return the short value at the given index"
	| rlIndex |
	index < 1 ifTrue:[^self errorSubscriptBounds: index].
	rlIndex := index.
	self lengthsAndValuesDo:[:runLength :runValue|
		rlIndex <= runLength ifTrue:[^runValue].
		rlIndex := rlIndex - runLength].
	"Not found. Must be out of range"
	^self errorSubscriptBounds: index
]

{ #category : #accessing }
ShortRunArray >> at: index put: value [
	"ShortRunArrays are read-only"
	^self shouldNotImplement.
]

{ #category : #accessing }
ShortRunArray >> bytesPerElement [

	^ 4

]

{ #category : #accessing }
ShortRunArray >> compressionRatio [
	"Return the compression ratio.
	The compression ratio is computed based
	on how much space would be needed to
	store the receiver in a ShortIntegerArray"
	^(self size asFloat * 0.5) "Would need only half of the amount in ShortIntegerArray"
		/ (self runSize max: 1)
]

{ #category : #enumerating }
ShortRunArray >> do: aBlock [
	"Evaluate aBlock with all elements of the receiver"
	self lengthsAndValuesDo:[:runLength :runValue|
		"Use to:do: instead of timesRepeat: for compiler optimization"
		1 to: runLength do:[:i|
			aBlock value: runValue.
		].
	].
]

{ #category : #accessing }
ShortRunArray >> lengthAtRun: index [
	"Return the length of the run starting at the given index"
	^(self basicAt: index) bitShift: -16
]

{ #category : #enumerating }
ShortRunArray >> lengthsAndValuesDo: aBlock [
	"Evaluate aBlock with the length and value of each run in the receiver"
	^self runsAndValuesDo: aBlock
]

{ #category : #printing }
ShortRunArray >> printOn: aStream [
	aStream nextPutAll: self class name; nextPutAll:' ( '.
	self lengthsAndValuesDo:[:runLength :runValue |
		aStream
			nextPutAll:' (';
			print: runLength;
			space;
			print: runValue;
			nextPut:$).
	].
	aStream nextPutAll:' )'.
]

{ #category : #private }
ShortRunArray >> pvtAt: index [
	"Private -- for swapping only"
	<primitive: 143>
	index isInteger ifTrue: [self errorSubscriptBounds: index].
	index isNumber ifTrue: [^ self at: index truncated].
	self errorNonIntegerIndex.

]

{ #category : #private }
ShortRunArray >> pvtAt: index put: value [
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
ShortRunArray >> restoreEndianness [
	"This word object was just read in from a stream.  It was stored in Big Endian (Mac) format.  Swap each pair of bytes (16-bit word), if the current machine is Little Endian.
	Why is this the right thing to do?  We are using memory as a byteStream.  High and low bytes are reversed in each 16-bit word, but the stream of words ascends through memory.  Different from a Bitmap."

	| w b1 b2 b3 b4 |
	Smalltalk isLittleEndian ifTrue: [
		1 to: self basicSize do: [:i |
			w := self basicAt: i.
			b1 := w digitAt: 1.
			b2 := w digitAt: 2.
			b3 := w digitAt: 3.
			b4 := w digitAt: 4.
			w := (b1 << 24) + (b2 << 16) + (b3 << 8) + b4.
			self basicAt: i put: w.
		]
	].


]

{ #category : #accessing }
ShortRunArray >> runSize [
	"Return the number of runs in the receiver"
	^self basicSize
]

{ #category : #enumerating }
ShortRunArray >> runsAndValuesDo: aBlock [
	"Evaluate aBlock with the length and value of each run in the receiver"
	| basicValue length value |
	1 to: self basicSize do:[:i|
		basicValue := self basicAt: i.
		length := basicValue bitShift: -16.
		value := basicValue bitAnd: 16rFFFF.
		value := (value bitAnd: 16r7FFF) - (value bitAnd: 16r8000).
		aBlock value: length value: value.
	].
]

{ #category : #private }
ShortRunArray >> setRunAt: i toLength: runLength value: value [
	(value < -16r7FFF or:[value > 16r8000]) ifTrue:[^self errorImproperStore].
	(runLength < 0 or:[runLength > 16rFFFF]) ifTrue:[^self errorImproperStore].
	self basicAt: i put: (runLength bitShift: 16) + 
		((value bitAnd: 16r7FFF) - (value bitAnd: -16r8000)).
]

{ #category : #private }
ShortRunArray >> setRuns: runArray values: valueArray [
	| runLength value |
	1 to: runArray size do:[:i|
		runLength := runArray at: i.
		value := valueArray at: i.
		self setRunAt: i toLength: runLength value: value.
	].
]

{ #category : #accessing }
ShortRunArray >> size [
	"Return the number of elements stored in the receiver"
	| n |
	n := 0.
	"Note: The following loop is open-coded for speed"
	1 to: self basicSize do:[:i|
		n := n + ((self basicAt: i) bitShift: -16).
	].
	^n
]

{ #category : #accessing }
ShortRunArray >> species [
	"Answer the preferred class for reconstructing the receiver."
	^ShortIntegerArray
]

{ #category : #private }
ShortRunArray >> swapRuns [
	"Private -- swap length/value pairs in the receiver"
	| tmp |
	1 to: self basicSize do:[:i|
		tmp := (self pvtAt: i * 2).
		self pvtAt: i * 2 put: (self pvtAt: i * 2 - 1).
		self pvtAt: i * 2 - 1 put: tmp.
	]
]

{ #category : #accessing }
ShortRunArray >> valueAtRun: index [
	"Return the value of the run starting at the given index"
	| uShort |
	uShort := (self basicAt: index) bitAnd: 16rFFFF.
	^(uShort bitAnd: 16r7FFF) - (uShort bitAnd: 16r8000)
]

{ #category : #enumerating }
ShortRunArray >> valuesCollect: aBlock [
	"Evaluate aBlock with each of the receiver's values as the argument. 
	Collect the resulting values into a collection like the receiver. Answer 
	the new collection."
	| newArray newValue |
	newArray := self class basicNew: self basicSize.
	1 to: self runSize do:[:i|
		newValue := aBlock value: (self valueAtRun: i).
		newArray setRunAt: i toLength: (self lengthAtRun: i) value: newValue.
	].
	^newArray
]

{ #category : #enumerating }
ShortRunArray >> valuesDo: aBlock [
	self lengthsAndValuesDo:[:runLength :runValue| aBlock value: runValue]
]
