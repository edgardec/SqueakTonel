"
Instances of MessageSend encapsulate message sends to objects. Arguments can be either predefined or supplied when the message send is performed. 

Use #value to perform a message send with its predefined arguments and #valueWithArguments: if additonal arguments have to supplied.

Structure:
 receiver		Object -- object receiving the message send
 selector		Symbol -- message selector
 arguments		Array -- bound arguments
"
Class {
	#name : #MessageSend,
	#superclass : #Object,
	#instVars : [
		'receiver',
		'selector',
		'arguments'
	],
	#category : #'Kernel-Objects'
}

{ #category : #'instance creation' }
MessageSend class >> receiver: anObject selector: aSymbol [
	^ self receiver: anObject selector: aSymbol arguments: #()
]

{ #category : #'instance creation' }
MessageSend class >> receiver: anObject selector: aSymbol argument: aParameter [
	^ self receiver: anObject selector: aSymbol arguments: (Array with: aParameter)
]

{ #category : #'instance creation' }
MessageSend class >> receiver: anObject selector: aSymbol arguments: anArray [
	^ self new
		receiver: anObject;
		selector: aSymbol;
		arguments: anArray
]

{ #category : #comparing }
MessageSend >> = anObject [
	^ anObject species == self species 
		and: [receiver == anObject receiver
		and: [selector == anObject selector
		and: [arguments = anObject arguments]]]
]

{ #category : #accessing }
MessageSend >> arguments [
	^ arguments
]

{ #category : #accessing }
MessageSend >> arguments: anArray [
	arguments := anArray
]

{ #category : #converting }
MessageSend >> asMessage [
	^ Message selector: selector arguments: arguments.
]

{ #category : #converting }
MessageSend >> asMinimalRepresentation [
	^self
]

{ #category : #private }
MessageSend >> collectArguments: anArgArray [
	"Private"

    | staticArgs |
    staticArgs := self arguments.
    ^(anArgArray size = staticArgs size)
        ifTrue: [anArgArray]
        ifFalse:
            [(staticArgs isEmpty
                ifTrue: [ staticArgs := Array new: selector numArgs]
                ifFalse: [staticArgs copy] )
                    replaceFrom: 1
                    to: (anArgArray size min: staticArgs size)
                    with: anArgArray
                    startingAt: 1]
]

{ #category : #evaluating }
MessageSend >> cull: firstArg [
	"Send the message with these optional arguments and answer the return value"

	selector numArgs >= 1 ifTrue: [ ^self value: firstArg ].
	^self value
]

{ #category : #evaluating }
MessageSend >> cull: firstArg cull: secondArg [
	"Send the message with these optional arguments and answer the return value"

	| numArgs |
	(numArgs := selector numArgs) >= 2 ifTrue: [ ^self value: firstArg value: secondArg ].	
	numArgs = 1 ifTrue: [ ^self value: firstArg ].
	^self value
]

{ #category : #evaluating }
MessageSend >> cull: firstArg cull: secondArg cull: thirdArg [
	"Send the message with these optional arguments and answer the return value"

	| numArgs |
	(numArgs := selector numArgs) >= 2 ifTrue: [ 
		numArgs >= 3 ifTrue: [ ^self value: firstArg value: secondArg value: thirdArg ].
		^self value: firstArg value: secondArg ].
	numArgs = 1 ifTrue: [ ^self value: firstArg ].
	^self value
]

{ #category : #evaluating }
MessageSend >> cull: firstArg cull: secondArg cull: thirdArg cull: fourthArg [
	"Send the message with these optional arguments and answer the return value"

	| numArgs |
	(numArgs := selector numArgs) >= 3 ifTrue: [
		numArgs >= 4 ifTrue: [
			^self value: firstArg value: secondArg value: thirdArg value: fourthArg ].
		^self value: firstArg value: secondArg value: thirdArg ].
	numArgs = 2 ifTrue: [ ^self value: firstArg value: secondArg ].	
	numArgs = 1 ifTrue: [ ^self value: firstArg ].
	^self value
]

{ #category : #comparing }
MessageSend >> hash [
	^ receiver hash bitXor: selector hash
]

{ #category : #testing }
MessageSend >> isMessageSend [
	^true

]

{ #category : #private }
MessageSend >> isReceiverOrAnyArgumentGarbage [
	^false
]

{ #category : #accessing }
MessageSend >> numArgs [
	^ selector numArgs
]

{ #category : #printing }
MessageSend >> printOn: aStream [

        aStream
                nextPutAll: self class name;
                nextPut: $(.
        selector printOn: aStream.
        aStream nextPutAll: ' -> '.
        receiver printOn: aStream.
        aStream nextPut: $)
]

{ #category : #accessing }
MessageSend >> receiver [
	^ receiver
]

{ #category : #accessing }
MessageSend >> receiver: anObject [
	receiver := anObject
]

{ #category : #accessing }
MessageSend >> selector [
	^ selector
]

{ #category : #accessing }
MessageSend >> selector: aSymbol [
	selector := aSymbol
]

{ #category : #evaluating }
MessageSend >> value [
	"Send the message and answer the return value"

	arguments ifNil: [^ receiver perform: selector].

	^ receiver 
		perform: selector 
		withArguments: (self collectArguments: arguments)
]

{ #category : #evaluating }
MessageSend >> value: firstArg [
	"Send the message with these arguments and answer the return value"

	^receiver perform: selector with: firstArg
]

{ #category : #evaluating }
MessageSend >> value: firstArg value: secondArg [
	"Send the message with these arguments and answer the return value"

	^receiver perform: selector with: firstArg with: secondArg
]

{ #category : #evaluating }
MessageSend >> value: firstArg value: secondArg value: thirdArg [
	"Send the message with these arguments and answer the return value"

	^receiver perform: selector with: firstArg with: secondArg with: thirdArg
]

{ #category : #evaluating }
MessageSend >> value: firstArg value: secondArg value: thirdArg value: fourthArg [
	"Send the message with these arguments and answer the return value"

	^receiver perform: selector with: firstArg with: secondArg with: thirdArg with: fourthArg
]

{ #category : #evaluating }
MessageSend >> value: firstArg value: secondArg value: thirdArg value: fourthArg value: fifthArg [
	"Send the message with these arguments and answer the return value"

	^receiver perform: selector with: firstArg with: secondArg with: thirdArg with: fourthArg with: fifthArg
]

{ #category : #evaluating }
MessageSend >> valueOtherwise: aBlock [
	"Send the message and answer the return value"

	^self value
]

{ #category : #evaluating }
MessageSend >> valueWithArguments: anArray [

	^ receiver 
		perform: selector 
		withArguments: (self collectArguments: anArray)
]

{ #category : #evaluating }
MessageSend >> valueWithArguments: anArray otherwise: aBlock [

	^ self valueWithArguments: anArray
]

{ #category : #evaluating }
MessageSend >> valueWithEnoughArguments: anArray [
	"call the selector with enough arguments from arguments and anArray"
	| args |
	args := Array new: selector numArgs.
	args replaceFrom: 1
		to: (arguments size min: args size)
		with: arguments
		startingAt: 1.
	args size > arguments size ifTrue: [
		args replaceFrom: arguments size + 1
			to: (arguments size + anArray size min: args size)
			with: anArray
			startingAt: 1.
	].
	^ receiver perform: selector withArguments: args
]

{ #category : #evaluating }
MessageSend >> valueWithPossibleArgs: anArray [
	"Send selector to the receiver with arguments in anArray. Only use enough arguments for the arity of the selector; supply nils for missing ones."
	
	^receiver perform: selector withEnoughArguments: anArray
]
