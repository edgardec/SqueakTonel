"
Any message sent to me is returned as a Message object.

""Message catcher"" creates an instance of me.

"
Class {
	#name : #MessageCatcher,
	#superclass : #ProtoObject,
	#instVars : [
		'accumulator'
	],
	#category : #'Kernel-Methods'
}

{ #category : #'as yet unclassified' }
MessageCatcher >> doesNotUnderstand: aMessage [

	accumulator ifNotNil: [accumulator add: aMessage].
	^ aMessage
]

{ #category : #'as yet unclassified' }
MessageCatcher >> privAccumulator [

	^ accumulator
]

{ #category : #'as yet unclassified' }
MessageCatcher >> privAccumulator: collection [

	accumulator := collection
]
