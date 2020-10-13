"
I represent an accessor for a sequence of objects that can only store objects in the sequence.
"
Class {
	#name : #WriteStream,
	#superclass : #PositionableStream,
	#instVars : [
		'writeLimit',
		'initialPositionOrNil'
	],
	#category : #'Collections-Streams'
}

{ #category : #'instance creation' }
WriteStream class >> on: aCollection from: firstIndex to: lastIndex [ 
	"Answer an instance of me on a copy of the argument, aCollection, 
	determined by the indices firstIndex and lastIndex. Position the instance 
	at the beginning of the collection."

	^self basicNew
		on: aCollection
		from: firstIndex
		to: lastIndex
]

{ #category : #'instance creation' }
WriteStream class >> with: aCollection [ 
	"Answer an instance of me on the argument, aCollection, positioned to 
	store objects at the end of aCollection."

	^self basicNew with: aCollection
]

{ #category : #'instance creation' }
WriteStream class >> with: aCollection from: firstIndex to: lastIndex [ 
	"Answer an instance of me on the subcollection of the argument, 
	aCollection, determined by the indices firstIndex and lastIndex. Position 
	the instance to store at the end of the subcollection."

	^self basicNew with: (aCollection copyFrom: firstIndex to: lastIndex)
]

{ #category : #printing }
WriteStream >> << aCollection [
	"we want a readable version of nextPutAll however it may be difficult to fully recreate nextPutAll:
	for all the different types of stream. Rather then simply send to nextPutAll:
	we handle the String (or ByteArray) argument
	as fast as possible - the rest we delegate to putOn: This means that we handle single characters and bytes 
	whereas nextPutAll: is only for sequencable collections.
	.
	Note this may not work in every case that nextPutAll: does subject to extensive testing, 
	but it should work in the important cases"

	| newEnd |
	collection class == aCollection class ifFalse:
		[ aCollection putOn: self. ^ self ].

	newEnd := position + aCollection size.
	newEnd > writeLimit ifTrue:
		[self growTo: newEnd + 10].

	collection replaceFrom: position+1 to: newEnd  with: aCollection startingAt: 1.
	position := newEnd.


]

{ #category : #private }
WriteStream >> braceArray [
	"This method is used in compilation of brace constructs.
	It MUST NOT be deleted or altered."

	^ collection
]

{ #category : #private }
WriteStream >> braceArray: anArray [
	"This method is used in compilation of brace constructs.
	It MUST NOT be deleted or altered."

	collection := anArray.
	position := 0.
	readLimit := 0.
	writeLimit := anArray size.
]

{ #category : #accessing }
WriteStream >> contents [
	"Answer with a copy of my collection from the start to the current position."
	readLimit := readLimit max: position.
	^collection copyFrom: (initialPositionOrNil ifNil: [1]) to: position
]

{ #category : #'character writing' }
WriteStream >> cr [
	"Append a carriage return character to the receiver."

	self nextPut: Character cr
]

{ #category : #'character writing' }
WriteStream >> crlf [
	"Append a carriage return and a line feed to the receiver."

	self nextPut: Character cr; nextPut: Character lf
]

{ #category : #'character writing' }
WriteStream >> crtab [
	"Append a return character, followed by a single tab character, to the 
	receiver."

	self nextPut: Character cr.
	self nextPut: Character tab
]

{ #category : #'character writing' }
WriteStream >> crtab: anInteger [ 
	"Append a return character, followed by anInteger tab characters, to the 
	receiver."

	self nextPut: Character cr.
	anInteger timesRepeat: [self nextPut: Character tab]
]

{ #category : #'character writing' }
WriteStream >> ensureASpace [
	"Append a space character to the receiver IFF there is not one on the end."

	self ensureEndsWith: Character space
]

{ #category : #'character writing' }
WriteStream >> ensureCr [
	"Append a cr character to the receiver IFF there is not one on the end."

	self ensureEndsWith: Character cr
]

{ #category : #accessing }
WriteStream >> ensureEndsWith: anObject [
	"Append anObject to the receiver IFF there is not one on the end."

	self peekLast = anObject ifFalse:
		[self nextPut: anObject]
]

{ #category : #'character writing' }
WriteStream >> ensureNoSpace [
	"If there is not one on the end, remove it."

	(position > 0 and: [(collection at: position) = Character space]) 
		ifTrue: [self skip: -1].
]

{ #category : #private }
WriteStream >> growTo: anInteger [

   " anInteger is the required minimal new size of the collection "
	| oldSize grownCollection newSize |
	oldSize := collection size.
     newSize := anInteger + (oldSize // 4 max: 20).
	grownCollection := collection class new: newSize.
	collection := grownCollection replaceFrom: 1 to: oldSize with: collection startingAt: 1.
	writeLimit := collection size.

]

{ #category : #'character writing' }
WriteStream >> lf [
	"Append a line feed character to the receiver."

	self nextPut: Character lf
]

{ #category : #accessing }
WriteStream >> next [

	self shouldNotImplement
]

{ #category : #accessing }
WriteStream >> next: anInteger putAll: aCollection startingAt: startIndex [
	"Store the next anInteger elements from the given collection."

	| newEnd |
	anInteger > 0 ifFalse: [ ^aCollection ].
	(collection class == aCollection class
		or: [ collection isString 
			and: [ aCollection isString
			and: [ collection class format = aCollection class format ] ] ]) "Let Strings with the same field size as collection take the quick route too."
		ifFalse: [ ^super next: anInteger putAll: aCollection startingAt: startIndex ].

	newEnd := position + anInteger.
	newEnd > writeLimit ifTrue:
		[self growTo: newEnd + 10].

	collection replaceFrom: position+1 to: newEnd  with: aCollection startingAt: startIndex.
	position := newEnd.

	^aCollection
]

{ #category : #'fileIn\/Out' }
WriteStream >> nextChunkPut: aString [
	"Append the argument, aString, to the receiver, doubling embedded terminators."

	| i remainder terminator |
	terminator := $!.
	remainder := aString.
	[(i := remainder indexOf: terminator) = 0] whileFalse:
		[self nextPutAll: (remainder copyFrom: 1 to: i).
		self nextPut: terminator.  "double imbedded terminators"
		remainder := remainder copyFrom: i+1 to: remainder size].
	self nextPutAll: remainder.
	aString includesUnifiedCharacter ifTrue: [
		self nextPut: terminator.
		self nextPutAll: ']lang['.
		aString writeLeadingCharRunsOn: self.
	].
	self nextPut: terminator.

]

{ #category : #'fileIn\/Out' }
WriteStream >> nextChunkPutWithStyle: aStringOrText [
	"Append the argument, aText, to the receiver, doubling embedded terminators.  Put out one chunk for the string and one for the style runs.  Mark the style with ]style[."

	aStringOrText isString ifTrue: [^ self nextChunkPut: aStringOrText].
	aStringOrText runs coalesce.
	aStringOrText unembellished ifTrue: [^ self nextChunkPut: aStringOrText asString].

	self nextChunkPut: aStringOrText asString.
	self cr; nextPutAll: ']style['.
	self nextChunkPut: 
		(String streamContents: [:strm | 
			aStringOrText runs writeScanOn: strm]).

]

{ #category : #accessing }
WriteStream >> nextPut: anObject [ 
	"Primitive. Insert the argument at the next position in the Stream
	represented by the receiver. Fail if the collection of this stream is not an
	Array or a String. Fail if the stream is positioned at its end, or if the
	position is out of bounds in the collection. Fail if the argument is not
	of the right type for the collection. Optional. See Object documentation
	whatIsAPrimitive."

	<primitive: 66>
	position >= writeLimit
		ifTrue: [^ self pastEndPut: anObject]
		ifFalse: 
			[position := position + 1.
			^collection at: position put: anObject]
]

{ #category : #accessing }
WriteStream >> nextPutAll: aCollection [

	| newEnd |
	(collection class == aCollection class
		or: [ collection class isBits
			and: [ aCollection isString
			and: [ collection class format = aCollection class format ] ] ]) "Let Strings with the same field size as collection take the quick route too."
		ifFalse: [ ^ super nextPutAll: aCollection ].

	newEnd := position + aCollection size.
	newEnd > writeLimit ifTrue:
		[self growTo: newEnd + 10].

	collection replaceFrom: position+1 to: newEnd  with: aCollection startingAt: 1.
	position := newEnd.
	^aCollection
]

{ #category : #private }
WriteStream >> on: aCollection [

	super on: aCollection.
	readLimit := 0.
	writeLimit := aCollection size
]

{ #category : #private }
WriteStream >> on: aCollection from: firstIndex to: lastIndex [

	| len |
	collection := aCollection.
	readLimit := 
		writeLimit := lastIndex > (len := collection size)
						ifTrue: [len]
						ifFalse: [lastIndex].
	position := firstIndex <= 1
				ifTrue: [0]
				ifFalse: [firstIndex - 1].
	initialPositionOrNil := position + 1
]

{ #category : #private }
WriteStream >> pastEndPut: anObject [
	"Grow the collection by doubling the size, but keeping the growth between 20 and 1000000.
	Then put <anObject> at the current write position."

	collection := collection grownBy: ((collection size max: 20) min: 1000000).
	writeLimit := collection size.
	collection at: (position := position + 1) put: anObject.
	^ anObject
]

{ #category : #'character writing' }
WriteStream >> peekLast [
	"Return that item just put at the end of the stream"

	^ position > 0 
		ifTrue: [collection at: position]
		ifFalse: [nil]
]

{ #category : #positioning }
WriteStream >> position: anInteger [ 
	"Refer to the comment in PositionableStream|position:."

	readLimit := readLimit max: position.
	super position: anInteger
]

{ #category : #converting }
WriteStream >> readStream [
	"Answer a readStream on my contents truncated to current position.
	Beware, the readStream shares the contents, so it will be modified if I'm written backward."
	readLimit := readLimit max: position.
	^ReadStream on: collection from: (initialPositionOrNil ifNil: [1]) to: position
]

{ #category : #positioning }
WriteStream >> reset [ 
	"Refer to the comment in PositionableStream|reset."

	readLimit := readLimit max: position.
	position := 0
]

{ #category : #positioning }
WriteStream >> resetToStart [
	readLimit := position := 0.
]

{ #category : #positioning }
WriteStream >> setToEnd [ 
	"Refer to the comment in PositionableStream|setToEnd."

	readLimit := readLimit max: position.
	super setToEnd.
]

{ #category : #accessing }
WriteStream >> size [

	^readLimit := readLimit max: position
]

{ #category : #'character writing' }
WriteStream >> space [
	"Append a space character to the receiver."

	self nextPut: Character space
]

{ #category : #'character writing' }
WriteStream >> space: anInteger [ 
	"Append anInteger space characters to the receiver."

	anInteger timesRepeat: [self space]
]

{ #category : #printing }
WriteStream >> store: anObject [ 
	"Have anObject print on the receiver for purposes of rereading."

	anObject storeOn: self
]

{ #category : #'character writing' }
WriteStream >> tab [
	"Append a tab character to the receiver."

	self nextPut: Character tab
]

{ #category : #'character writing' }
WriteStream >> tab: anInteger [ 
	"Append anInteger tab characters to the receiver."

	anInteger timesRepeat: [self tab]
]

{ #category : #'fileIn\/Out' }
WriteStream >> timeStamp [
	"Append the current time to the receiver as a String."
	self nextChunkPut:	"double string quotes and !s"
		(String streamContents: [:s | Smalltalk timeStamp: s]) printString.
	self cr
]

{ #category : #private }
WriteStream >> with: aCollection [

	super on: aCollection.
	position := readLimit := writeLimit := aCollection size
]

{ #category : #private }
WriteStream >> withAttribute: att do: strmBlock [ 
	"No-op here is overriden in TextStream for font emphasis"
	^ strmBlock value
]

{ #category : #private }
WriteStream >> withAttributes: attributes do: strmBlock [ 
	"No-op here is overriden in TextStream for font emphasis"
	^ strmBlock value
]
