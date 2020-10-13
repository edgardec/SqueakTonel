"
Instances of WeakMessageSend encapsulate message sends to objects, like MessageSend. Unlike MessageSend it is not necessarily a valid message.  A request to value only results in a send if in fact it is valid. 

See MessageSendComments also. WeakMessageSend is used primarily for event registration. 

Unlike MessageSend WeakMessageSend stores receiver (object receiving the message send) as the first and only element of its array as opposed to a named ivar.
But like MessageSend, it does have
 selector		Symbol -- message selector
 arguments		Array -- bound arguments
and it also has
 shouldBeNil	Array of Booleans --  used to track valid nil values in arguments array
"
Class {
	#name : #WeakMessageSend,
	#superclass : #Object,
	#type : #weak,
	#instVars : [
		'selector',
		'shouldBeNil',
		'arguments'
	],
	#category : #'Kernel-Objects'
}

{ #category : #'instance creation' }
WeakMessageSend class >> new [
	^self new: 1

]

{ #category : #'instance creation' }
WeakMessageSend class >> receiver: anObject selector: aSymbol [
	^ self receiver: anObject selector: aSymbol arguments: #()

]

{ #category : #'instance creation' }
WeakMessageSend class >> receiver: anObject selector: aSymbol argument: aParameter [
	^ self receiver: anObject selector: aSymbol arguments: (Array with: aParameter)

]

{ #category : #'instance creation' }
WeakMessageSend class >> receiver: anObject selector: aSymbol arguments: anArray [
	^ self new
		receiver: anObject;
		selector: aSymbol;
		arguments: anArray

]

{ #category : #comparing }
WeakMessageSend >> = anObject [
	"Compare equal to equivalent MessageSend"
	^ anObject isMessageSend
		and: [self receiver == anObject receiver
		and: [selector == anObject selector
		and: [(Array withAll: self arguments) = (Array withAll: anObject arguments)]]]

]

{ #category : #accessing }
WeakMessageSend >> arguments [
	^arguments ifNil: [ Array new ]

]

{ #category : #accessing }
WeakMessageSend >> arguments: anArray [
	arguments := WeakArray withAll: anArray.
	"no reason this should be a WeakArray"
	shouldBeNil := Array withAll: (anArray collect: [ :ea | ea isNil ]).

]

{ #category : #converting }
WeakMessageSend >> asMessageSend [
	^MessageSend receiver: self receiver selector: selector arguments: (Array withAll: self arguments) 

]

{ #category : #converting }
WeakMessageSend >> asMinimalRepresentation [

	^self isReceiverOrAnyArgumentGarbage
		ifTrue: [ nil ]
		ifFalse: [ self ]
]

{ #category : #private }
WeakMessageSend >> collectArguments: anArgArray [
	"Private"
    | staticArgs |
    staticArgs := self arguments.
    ^(anArgArray size = staticArgs size)
        ifTrue: [anArgArray]
        ifFalse:
            [(staticArgs isEmpty
                ifTrue: [ staticArgs := Array new: selector numArgs]
                ifFalse: [Array withAll: staticArgs] )
                    replaceFrom: 1
                    to: (anArgArray size min: staticArgs size)
                    with: anArgArray
                    startingAt: 1]

]

{ #category : #comparing }
WeakMessageSend >> hash [
	"work like MessageSend>>hash"
	^self receiver hash bitXor: selector hash

]

{ #category : #private }
WeakMessageSend >> isAnyArgumentGarbage [
	"Make sure that my arguments haven't gone away"
	arguments ifNotNil: [
		arguments with: shouldBeNil do: [ :arg :flag |
			(flag not and: [arg isNil])
				ifTrue: [^true]
		]
	].
	^false

]

{ #category : #testing }
WeakMessageSend >> isMessageSend [
	^true

]

{ #category : #private }
WeakMessageSend >> isReceiverGarbage [
	"Make sure that my receiver hasn't gone away"
	^self receiver isNil

]

{ #category : #private }
WeakMessageSend >> isReceiverOrAnyArgumentGarbage [
	"Make sure that my receiver hasn't gone away"
	^self isReceiverGarbage 
		or: [self isAnyArgumentGarbage]

]

{ #category : #printing }
WeakMessageSend >> printOn: aStream [

        aStream
                nextPutAll: self class name;
                nextPut: $(.
        selector printOn: aStream.
        aStream nextPutAll: ' -> '.
        self receiver printOn: aStream.
        aStream nextPut: $)

]

{ #category : #accessing }
WeakMessageSend >> receiver [
	^self at: 1

]

{ #category : #accessing }
WeakMessageSend >> receiver: anObject [
	self at: 1 put: anObject

]

{ #category : #accessing }
WeakMessageSend >> selector [
	^selector

]

{ #category : #accessing }
WeakMessageSend >> selector: aSymbol [
	selector := aSymbol

]

{ #category : #evaluating }
WeakMessageSend >> value [
	^self valueOtherwise: []
]

{ #category : #evaluating }
WeakMessageSend >> valueOtherwise: aBlock [

	^ arguments
		ifNil: [
			self withEnsuredReceiverDo: [ :r | r perform: selector ] otherwise: aBlock ]
		ifNotNil: [
			self
				withEnsuredReceiverAndArgumentsDo: [ :r :a |
					r
						perform: selector
						withArguments: a ]
				otherwise: aBlock ]
]

{ #category : #evaluating }
WeakMessageSend >> valueWithArguments: anArray [
	^ self valueWithArguments: anArray otherwise: []
]

{ #category : #evaluating }
WeakMessageSend >> valueWithArguments: anArray otherwise: aBlock [
	| argsToUse |
	
	"Safe to use, because they are built before ensureing receiver and args..."
	argsToUse := self collectArguments: anArray.
	^ self
		withEnsuredReceiverAndArgumentsDo: [ :r :a |
			r
				perform: selector
				withArguments: argsToUse ]
		otherwise: aBlock
]

{ #category : #evaluating }
WeakMessageSend >> valueWithEnoughArguments: anArray [
	"call the selector with enough arguments from arguments and anArray"
	^self
		withEnsuredReceiverAndArgumentsDo: [ :r :a |
			r
				perform: selector
				withArguments: a ]
		withEnoughArguments: anArray
		otherwise: [ ]
]

{ #category : #private }
WeakMessageSend >> withEnsuredReceiverAndArgumentsDo: aBlock otherwise: altBlock [
	"Grab real references to receiver and arguments. If they still exist, evaluate aBlock."

	"Return if my receiver has gone away"
	| r a |
	r := self receiver.
	r ifNil: [ ^altBlock value ].

	
	"Make sure that my arguments haven't gone away"
	a := Array withAll: self arguments.
	a with: shouldBeNil do: [ :arg :flag |
		arg ifNil: [ flag ifFalse: [ ^altBlock value ]]
	].

	^aBlock value: r value: a
]

{ #category : #private }
WeakMessageSend >> withEnsuredReceiverAndArgumentsDo: aBlock withEnoughArguments: anArray otherwise: altBlock [
	"call the selector with enough arguments from arguments and anArray"
	| r selfArgs enoughArgs |
	r := self receiver.
	r ifNil: [ ^altBlock value ].
	
	selfArgs := self arguments.
	selfArgs with: shouldBeNil do: [ :arg :flag |
		arg ifNil: [ flag ifFalse: [ ^altBlock value ]]
	].

	enoughArgs := Array new: selector numArgs.
	enoughArgs replaceFrom: 1
		to: ( selfArgs size min: enoughArgs size)
		with: selfArgs
		startingAt: 1.
	enoughArgs size > selfArgs size ifTrue: [
		enoughArgs replaceFrom: selfArgs size + 1
			to: (selfArgs size + anArray size min: enoughArgs size)
			with: anArray
			startingAt: 1.
	].
	^aBlock value: r value: enoughArgs
]

{ #category : #private }
WeakMessageSend >> withEnsuredReceiverDo: aBlock otherwise: altBlock [
	"Grab a real reference to receive. If still there, evaluate aBlock.
	Use altBlock if my receiver has gone away."
	^self receiver
		ifNil: [ altBlock value ]
		ifNotNil: [:r | aBlock value: r ]
]
