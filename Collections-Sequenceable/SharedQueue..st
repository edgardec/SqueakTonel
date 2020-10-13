"
I provide synchronized communication of arbitrary objects between Processes. An object is sent by sending the message nextPut: and received by sending the message next. If no object has been sent when a next message is sent, the Process requesting the object will be suspended until one is sent.
"
Class {
	#name : #SharedQueue,
	#superclass : #Object,
	#instVars : [
		'contentsArray',
		'readPosition',
		'writePosition',
		'accessProtect',
		'readSynch'
	],
	#category : #'Collections-Sequenceable'
}

{ #category : #'instance creation' }
SharedQueue class >> new [
	"Answer a new instance of SharedQueue that has 10 elements."

	^self new: 10
]

{ #category : #'instance creation' }
SharedQueue class >> new: anInteger [ 
	^super new initialize: anInteger
]

{ #category : #accessing }
SharedQueue >> flush [
	"Throw out all pending contents"
	accessProtect critical: [
		"nil out flushed slots --bf 02/11/2006"
		contentsArray from: readPosition to: writePosition-1 put: nil.
		readPosition := 1.
		writePosition := 1.
		"Reset the read synchronization semaphore"
		readSynch initSignals].
]

{ #category : #accessing }
SharedQueue >> flushAllSuchThat: aBlock [
	"Remove from the queue all objects that satisfy aBlock."
	
	accessProtect critical: [
		| newReadPos |
		newReadPos := writePosition.
		writePosition - 1 to: readPosition by: -1 do: [ :i |
			| value |
			value := contentsArray at: i.
			contentsArray at: i put: nil.
			((aBlock value: value) and: [ (readSynch waitIfLocked: [ nil ]) notNil ]) ifFalse: [
				newReadPos := newReadPos - 1.
				contentsArray at: newReadPos put: value ] ].
		readPosition := newReadPos ]
]

{ #category : #private }
SharedQueue >> initialize: size [

	contentsArray := Array new: size.
	readPosition := 1.
	writePosition := 1.
	accessProtect := Semaphore forMutualExclusion.
	readSynch := Semaphore new
]

{ #category : #testing }
SharedQueue >> isEmpty [
	"Answer whether any objects have been sent through the receiver and 
	not yet received by anyone."

	^readPosition = writePosition
]

{ #category : #private }
SharedQueue >> makeRoomAtEnd [

	| contentsSize newContentsArray |
	contentsSize := writePosition - readPosition.
	newContentsArray := contentsSize * 2 > contentsArray size
		ifTrue: [ contentsArray class new: contentsArray size * 2 ]
		ifFalse: [
			(contentsArray size > 10 and: [ contentsSize * 4 <= contentsArray size ])
				ifTrue: [ contentsArray class new: (contentsSize * 2 max: 10) ]
				ifFalse: [ contentsArray ] ].
	newContentsArray
		replaceFrom: 1
		to: contentsSize
		with: contentsArray
		startingAt: readPosition.
	contentsArray == newContentsArray 
		ifFalse: [ contentsArray := newContentsArray ]
		ifTrue: [ contentsArray from: contentsSize + 1 to: contentsArray size put: nil ].
	readPosition := 1.
	writePosition := contentsSize + 1
]

{ #category : #accessing }
SharedQueue >> next [
	"Answer the object that was sent through the receiver first and has not 
	yet been received by anyone. If no object has been sent, suspend the 
	requesting process until one is."

	readSynch wait.
	^accessProtect
		critical: [
			| value |
			readPosition = writePosition
					ifTrue: 
						[self error: 'Error in SharedQueue synchronization'.
						 value := nil]
					ifFalse: 
						[value := contentsArray at: readPosition.
						 contentsArray at: readPosition put: nil.
						 readPosition := readPosition + 1].
			value].
]

{ #category : #accessing }
SharedQueue >> nextOrNil [
	"Answer the object that was sent through the receiver first and has not 
	yet been received by anyone. If no object has been sent, answer <nil>."

	readSynch waitIfLocked: [ ^nil ].
	^accessProtect
		critical: [
			| value |
			readPosition = writePosition
					ifTrue: 
						[self error: 'Error in SharedQueue synchronization'.
						 value := nil]
					ifFalse: 
						[value := contentsArray at: readPosition.
						 contentsArray at: readPosition put: nil.
						 readPosition := readPosition + 1].
			value ]
]

{ #category : #accessing }
SharedQueue >> nextOrNilSuchThat: aBlock [
	"Answer the next object that satisfies aBlock, skipping any intermediate objects.
	If no object has been sent, answer <nil> and leave me intact.
	NOTA BENE:  aBlock MUST NOT contain a non-local return (^)."

	^accessProtect critical: [
		| value readPos |
		value := nil.
		readPos := readPosition.
		[ readPos < writePosition and: [ value isNil ] ] whileTrue: [
			value := contentsArray at: readPos.
			readPos := readPos + 1.
			(aBlock value: value)
				ifFalse: [ value := nil ]
				ifTrue: [
					readSynch waitIfLocked: [ ^nil ]. "We found the value, but someone else booked it."
					readPosition to: readPos - 1 do: [ :j | contentsArray at: j put: nil ].
					readPosition := readPos ] ].
		value ].
"===
q := SharedQueue new.
1 to: 10 do: [ :i | q nextPut: i].
c := OrderedCollection new.
[
	v := q nextOrNilSuchThat: [ :e | e odd].
	v notNil
] whileTrue: [
	c add: {v. q size}
].
{c. q} explore
==="
]

{ #category : #accessing }
SharedQueue >> nextPut: value [ 
	"Send value through the receiver. If a Process has been suspended 
	waiting to receive a value through the receiver, allow it to proceed."

	accessProtect
		critical: [writePosition > contentsArray size
						ifTrue: [self makeRoomAtEnd].
				 contentsArray at: writePosition put: value.
				 writePosition := writePosition + 1].
	readSynch signal.
	^value
]

{ #category : #accessing }
SharedQueue >> peek [
	"Answer the object that was sent through the receiver first and has not 
	yet been received by anyone but do not remove it from the receiver. If 
	no object has been sent, return nil"

	^readSynch
		critical: [
			accessProtect critical: [
				readPosition >= writePosition ifFalse: [
					contentsArray at: readPosition ] ] ]
		ifLocked: [ nil ]
]

{ #category : #accessing }
SharedQueue >> peekLast [
	"Answer the object that was sent through the receiver last and has not 
	 yet been received by anyone. If  no object has been sent, answer nil"

	"SharedQueue new nextPut: 1; nextPut: 2; peekLast"

	^readSynch
		critical:
			[accessProtect critical:
				[writePosition > 1 ifTrue:
					[contentsArray at: writePosition - 1]]]
		ifLocked: [nil]
]

{ #category : #copying }
SharedQueue >> postCopy [
	super postCopy.
	contentsArray := contentsArray copy.
	accessProtect := Semaphore forMutualExclusion.
	readSynch := Semaphore new
]

{ #category : #private }
SharedQueue >> printOn: aStream [
	super printOn: aStream.
	"Print a guesstimate of the size of the queue without aquiring the lock properly"
	aStream nextPut: $(.
	aStream print: writePosition - readPosition.
	aStream nextPut: $).
]

{ #category : #accessing }
SharedQueue >> size [
	"Answer the number of objects that have been sent through the
	receiver and not yet received by anyone."

	^writePosition - readPosition
]
