"
This is a socket which sends arrays of strings back and forth.  This is less convenient than ObjectSockets, but it is more secure and it makes it easier to reason about updates to the protocol.

An array of strings is represented on the network as:

	4-bytes		number of strings in the array
	4-byte		number of bytes in the first string
	n1-bytes		characters in the first string
	4-bytes		number of bytes in the second string
	n2-bytes	characters in the second string
	...


"
Class {
	#name : #StringSocket,
	#superclass : #ObjectSocket,
	#instVars : [
		'numStringsInNextArray',
		'stringsForNextArray',
		'nextStringSize',
		'files',
		'startTime',
		'stringCounter',
		'socketWriterProcess',
		'outputQueue',
		'bytesInOutputQueue',
		'extraUnsentBytes',
		'transmissionError',
		'readBuffer'
	],
	#classVars : [
		'MaxRatesSeen',
		'RecentSendHistory',
		'RunningSendCount'
	],
	#category : #'Nebraska-Network-ObjectSocket'
}

{ #category : #'as yet unclassified' }
StringSocket class >> clearRatesSeen [
"
StringSocket clearRatesSeen
"
	MaxRatesSeen := nil 
]

{ #category : #'as yet unclassified' }
StringSocket class >> compareFiles [
"
StringSocket compareFiles
"
	| data1 data2 |

	data1 := (FileStream fileNamed: 'Macintosh HD:bob:nebraska test:58984048.1')
			contentsOfEntireFile.
	data2 := (FileStream fileNamed: 'BobsG3:squeak:dsqueak:DSqueak2.7 folder:58795431.3')
			contentsOfEntireFile.
	1 to: (data1 size min: data2 size) do: [ :i |
		(data1 at: i) = (data2 at: i) ifFalse: [self halt].
	].

]

{ #category : #'as yet unclassified' }
StringSocket class >> showRatesSeen [
"
StringSocket showRatesSeen
"
	| answer |

	MaxRatesSeen ifNil: [^Beeper beep].
	answer := WriteStream on: String new.
	MaxRatesSeen keys asArray sort do: [ :key |
		answer nextPutAll: key printString,'  ',((MaxRatesSeen at: key) // 10000) printString; cr
	].
	StringHolder new contents: answer contents; openLabel: 'send rates at 10 second intervals'.
]

{ #category : #'private-IO' }
StringSocket >> addToInBuf: aString [

	| newAlloc |
	newAlloc := aString size * 2 max: 80000.
	inBuf ifNil: [
		inBuf := String new: newAlloc.
		inBufIndex := 1.
		inBufLastIndex := 0.
	].
	aString size > (inBuf size - inBufLastIndex) ifTrue: [
		inBuf := inBuf , (String new: newAlloc)
	].
	inBuf 
		replaceFrom: inBufLastIndex + 1 
		to: inBufLastIndex + aString size
		with: aString 
		startingAt: 1.
	inBufLastIndex := inBufLastIndex + aString size.

]

{ #category : #'private-IO' }
StringSocket >> addToOutBuf: arrayToWrite [

	| size newAlloc |
	size := self spaceToEncode: arrayToWrite.
	newAlloc := size * 2 max: 8000.	"gives us room to grow"
	outBuf ifNil: [
		outBuf := String new: newAlloc.
		outBufIndex := 1.
	].
	outBuf size - outBufIndex + 1 < size ifTrue: [
		outBuf := outBuf , (String new: newAlloc).
	].
	CanvasEncoder at: 1 count: arrayToWrite size + 1.
	outBuf putInteger32: arrayToWrite size at: outBufIndex.
	outBufIndex := outBufIndex + 4.
	arrayToWrite do: [ :each |
		outBuf putInteger32: each size at: outBufIndex.
		outBufIndex := outBufIndex + 4.
		outBuf 
			replaceFrom: outBufIndex 
			to: outBufIndex + each size - 1 
			with: each 
			startingAt: 1.
		outBufIndex := outBufIndex + each size.
	].
	^size
]

{ #category : #'private-IO' }
StringSocket >> backlog [

	^bytesInOutputQueue + extraUnsentBytes
]

{ #category : #'as yet unclassified' }
StringSocket >> destroy [

	socketWriterProcess ifNotNil: [socketWriterProcess terminate. socketWriterProcess := nil].
	outputQueue := nil.
	bytesInOutputQueue := 0.
	socket ifNotNil: [socket destroy. socket := nil.].

]

{ #category : #'private-IO' }
StringSocket >> gotSomething [

	numStringsInNextArray ifNil: [^self tryForNumStringsInNextArray ].
	numStringsInNextArray = 0 ifTrue: [
		inObjects add: #().
		numStringsInNextArray := nil.
		^true ].
	nextStringSize ifNil: [^ self tryForNextStringSize ].
	^self tryForString

]

{ #category : #'private-IO' }
StringSocket >> inBufNext: anInteger [
	
	| answer |
	answer := inBuf copyFrom: inBufIndex to: inBufIndex + anInteger - 1.
	inBufIndex := inBufIndex + anInteger.
	^answer
]

{ #category : #'private-IO' }
StringSocket >> inBufSize [

	inBuf ifNil: [^0].
	^inBufLastIndex - inBufIndex + 1
]

{ #category : #'as yet unclassified' }
StringSocket >> initialize: aSocket [

	transmissionError := false.
	super initialize: aSocket.
	outputQueue := SharedQueue new.
	extraUnsentBytes := bytesInOutputQueue := 0.
	socketWriterProcess := [
		[self transmitQueueNext] whileTrue.
		socketWriterProcess := nil.
		outputQueue := nil.
		bytesInOutputQueue := 0.
	] forkAt: Processor lowIOPriority.
]

{ #category : #'private-IO' }
StringSocket >> isConnected [

	^super isConnected and: [socketWriterProcess notNil]
]

{ #category : #'private-IO' }
StringSocket >> nextPut: anObject [

	socketWriterProcess ifNil: [^self].
	outObjects addLast: anObject.
	"return the argument - added by kwl"
	^ anObject
]

{ #category : #'private-IO' }
StringSocket >> processIO [
	"do some as much network IO as possible"

	socketWriterProcess ifNil: [^self].
	self processOutput.
	self processInput.
]

{ #category : #'private-IO' }
StringSocket >> processInput [
	| totalReceived chunkOfData |
	"do as much input as possible"

	self flag: #XXX.  "should have resource limits here--no more than X objects and Y bytes"

	chunkOfData := socket receiveAvailableDataIntoBuffer: self readBuffer.
	self addToInBuf: chunkOfData.
	totalReceived := chunkOfData size.

	totalReceived > 0 ifTrue: [
		NebraskaDebug at: #SendReceiveStats add: {'GET'. totalReceived}.
	].

	[ self gotSomething ] whileTrue: [].		"decode as many string arrays as possible"

	self shrinkInBuf.
]

{ #category : #'private-IO' }
StringSocket >> processOutput [

	| arrayToWrite size bytesSent timeStartSending t itemsSent now timeSlot bucketAgeInMS bytesThisSlot |

	outBufIndex := 1.
	itemsSent := bytesSent := 0.
	timeStartSending := Time millisecondClockValue.
	[outObjects isEmpty not and: [self isConnected]] whileTrue: [
		arrayToWrite := outObjects removeFirst.
		size := self addToOutBuf: arrayToWrite.
		bytesSent := bytesSent + size.
		itemsSent := itemsSent + 1.
		outBufIndex > 10000 ifTrue: [self queueOutBufContents].
	].
	outBufIndex > 1 ifTrue: [self queueOutBufContents].
	bytesSent > 0 ifTrue: [
		MaxRatesSeen ifNil: [MaxRatesSeen := Dictionary new].
		now := Time millisecondClockValue.
		t := now - timeStartSending.
		timeSlot := now // 10000.	"ten second buckets"
		bucketAgeInMS := now \\ 10.
		bytesThisSlot := (MaxRatesSeen at: timeSlot ifAbsent: [0]) + bytesSent.
		MaxRatesSeen 
			at: timeSlot 
			put: bytesThisSlot.
		NebraskaDebug 
			at: #SendReceiveStats 
			add: {'put'. bytesSent. t. itemsSent. bytesThisSlot // (bucketAgeInMS max: 100)}.
	].

]

{ #category : #'private-IO' }
StringSocket >> purgeOutputQueue [

	bytesInOutputQueue := 0.
	[outputQueue nextOrNil == nil] whileFalse.
]

{ #category : #'private-IO' }
StringSocket >> queueOutBufContents [

	bytesInOutputQueue := bytesInOutputQueue + outBufIndex - 1.
	outputQueue nextPut: {outBuf. outBufIndex - 1}.
	NebraskaDebug at: #queuedbufferSizes add: {outBufIndex - 1}.
	outBufIndex := 1.
	outBuf := String new: 11000.
	

]

{ #category : #'as yet unclassified' }
StringSocket >> readBuffer [

	^ readBuffer ifNil: [readBuffer := String new: 20000].

]

{ #category : #'as yet unclassified' }
StringSocket >> remoteSocketAddress [

	^ socket remoteSocketAddress
]

{ #category : #'private-IO' }
StringSocket >> sendDataCautiously: aStringOrByteArray bytesToSend: bytesToSend [
	"Send all of the data in the given array, even if it requires multiple calls to send it all. Return the number of bytes sent. Try not to send too much at once since this seemed to cause problems talking to a port on the same machine"

	| bytesSent count |

	bytesSent := 0.
	[bytesSent < bytesToSend] whileTrue: [
		extraUnsentBytes := bytesToSend - bytesSent.
		count := socket 
			sendSomeData: aStringOrByteArray 
			startIndex: bytesSent + 1  
			count: (bytesToSend - bytesSent min: 6000).
		bytesSent := bytesSent + count.
		(Delay forMilliseconds: 1) wait.
	].
	extraUnsentBytes := 0.
	^ bytesSent

]

{ #category : #'private-IO' }
StringSocket >> shrinkInBuf [

	inBuf ifNil: [^self].
	inBufLastIndex < inBufIndex ifTrue: [
		inBufLastIndex := 0.
		inBufIndex := 1.
		inBuf size > 20000 ifTrue: [inBuf := nil].	"if really big, kill it"
		^self
	].
	inBuf := inBuf copyFrom: inBufIndex to: inBufLastIndex.
	inBufLastIndex := inBuf size.
	inBufIndex := 1.


]

{ #category : #'private-IO' }
StringSocket >> spaceToEncode: anArray [
	"return the number of characters needed to encode the given string array"
	^anArray inject: 4 into: [ :sum :array |
		sum + (array size + 4) ].
]

{ #category : #'private-IO' }
StringSocket >> transmitQueueNext [

	| bufTuple |

	bufTuple := outputQueue next.
	bytesInOutputQueue := bytesInOutputQueue - bufTuple second max: 0.
	[
		self 
			sendDataCautiously: bufTuple first 
			bytesToSend: bufTuple second.
	]
		on: Error
		do: [ :ex |
			transmissionError := true.
		].
	^transmissionError not


]

{ #category : #'private-IO' }
StringSocket >> tryForNextStringSize [
	"grab the size of the next string, if it's available"

	self inBufSize >= 4 ifFalse: [^false].

	nextStringSize := inBuf getInteger32: inBufIndex.
	"nextStringSize > 100000 ifTrue: [self barf]."
	inBufIndex := inBufIndex + 4.
	
	nextStringSize < 0 ifTrue: [
		socket disconnect.
		^false ].
	
	^true

]

{ #category : #'private-IO' }
StringSocket >> tryForNumStringsInNextArray [
	"input numStringsInNextARray, if 4 bytes are available"

	self inBufSize >= 4 ifFalse: [^false].

	numStringsInNextArray := inBuf getInteger32: inBufIndex.
	"(numStringsInNextArray > 100 or: [numStringsInNextArray < 1]) ifTrue: [self barf]."
	inBufIndex := inBufIndex + 4.

	numStringsInNextArray < 0 ifTrue: [
		socket disconnect.
		^false ].
	
	stringsForNextArray := Array new: numStringsInNextArray.
	stringCounter := 0.
	nextStringSize := nil. 
	^true
]

{ #category : #'private-IO' }
StringSocket >> tryForString [
	"try to grab an actual string"

	self inBufSize >= nextStringSize ifFalse: [^false].

	stringsForNextArray 
		at: (stringCounter := stringCounter + 1)
		put: (self inBufNext: nextStringSize) asString.

	stringCounter = numStringsInNextArray ifTrue: [	"we have finished another array!"
		inObjects addLast: stringsForNextArray.
		stringCounter := stringsForNextArray := numStringsInNextArray := nextStringSize := nil.
	] ifFalse: [	"still need more strings for this array"
		nextStringSize := nil.
	].

	^true

]
