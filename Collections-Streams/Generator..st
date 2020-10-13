"
A Generator transforms callback interfaces into stream interfaces. 

When a producer algorithm provide results as callbacks (blocks) and a consumer algorithm expects streamable input, a Generator transforms one into the other, for example:

	| generator |
	generator := Generator on: [:g| Integer primesUpTo: 100 do:[:prime| g yield: prime]].
	[generator atEnd] whileFalse:[Transcript show: generator next].

Instance Variables
	block:		<BlockClosure>	The block associated with the generator.
	continue:	<Context>			The continuation to return to.
	home:		<Context>			The home (root) context of the activated block
	next:		<Object>			The next object to return from the Generator.
"
Class {
	#name : #Generator,
	#superclass : #Stream,
	#instVars : [
		'block',
		'next',
		'continue',
		'home'
	],
	#category : #'Collections-Streams'
}

{ #category : #'instance-creation' }
Generator class >> on: aBlock [
	^ self basicNew initializeOn: aBlock
]

{ #category : #testing }
Generator >> atEnd [
	"Answer whether the receiver can access any more objects."

	^ continue isNil
]

{ #category : #accessing }
Generator >> close [
	"Close the receiving generator and unwind its ensure-blocks."

	continue ifNotNil:[continue unwindTo: home].
	continue := block := next := nil
]

{ #category : #accessing }
Generator >> contents [
	"Answer the contents of this generator. Do not call this method on infinite generators."

	| stream |
	stream := (Array new: 10) writeStream.
	[ self atEnd ]
		whileFalse: [ stream nextPut: self next ].
	^ stream contents
]

{ #category : #private }
Generator >> fork [
	| result |
	home := thisContext.
	block reentrant value: self.
	thisContext swapSender: continue.
	result := next.
	continue := next := home := nil.
	^ result
]

{ #category : #initialization }
Generator >> initializeOn: aBlock [
	block := aBlock.
	self reset
]

{ #category : #accessing }
Generator >> next [
	"Generate and answer the next object in the receiver."

	^ self atEnd ifFalse: [
		home swapSender: thisContext sender.
		continue := thisContext swapSender: continue
	]
]

{ #category : #accessing }
Generator >> nextPut: anObject [
	"Add anObject into the generator. A synonym to #yield: and value:."

	| previous |
	previous := next.
	next := anObject.
	continue := thisContext swapSender: continue.
	^ previous
]

{ #category : #accessing }
Generator >> peek [
	"Answer the upcoming object of the receiver."

	^ next
]

{ #category : #printing }
Generator >> printOn: aStream [
	aStream nextPutAll: self class name; nextPutAll: ' on: '; print: block
]

{ #category : #public }
Generator >> reset [
	"Reset the generator, i.e., start it over"
	continue ifNotNil:[continue unwindTo: home].
	next := nil.
	continue := thisContext.
	[ self fork ] value
]

{ #category : #accessing }
Generator >> size [
	"A generator does not know its size."

	^ self shouldNotImplement
]

{ #category : #public }
Generator >> value: anObject [ 
	"Allows passing generators as arguments to methods expecting blocks.
	A synonym for #yield: / #nextPut:."
	^ self nextPut: anObject
]

{ #category : #public }
Generator >> yield: anObject [ 
	"Yield the next value to the consumer of the generator.
	A synonym for #nextPut:"
	^ self nextPut: anObject
]
