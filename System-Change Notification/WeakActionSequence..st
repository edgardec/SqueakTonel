Class {
	#name : #WeakActionSequence,
	#superclass : #Array,
	#type : #variable,
	#category : #'System-Change Notification'
}

{ #category : #converting }
WeakActionSequence >> asActionSequence [

	^self
]

{ #category : #converting }
WeakActionSequence >> asActionSequenceTrappingErrors [

	^WeakActionSequenceTrappingErrors withAll: self
]

{ #category : #converting }
WeakActionSequence >> asMinimalRepresentation [

	| valid |
	valid := self reject: [:e | e isReceiverOrAnyArgumentGarbage ].
	valid size = 0
		ifTrue: [ ^nil ].
	valid size = 1
		ifTrue: [ ^valid first ].
	^valid
]

{ #category : #printing }
WeakActionSequence >> printOn: aStream [

	self size < 2 ifTrue: [^super printOn: aStream].
	aStream nextPutAll: '#('.
	self
		do: [:each | each printOn: aStream]
		separatedBy: [aStream cr].
	aStream nextPut: $)
]

{ #category : #evaluating }
WeakActionSequence >> value [
	"Answer the result of evaluating the elements of the receiver.
	Actually, return just the last result."

	^self inject: nil into: [ :previousAnswer :each | 
		each valueOtherwise: [ previousAnswer ]].
]

{ #category : #evaluating }
WeakActionSequence >> valueWithArguments: anArray [
	"Return the last result"

	^self inject: nil into: [ :previousAnswer :each |
		each valueWithArguments: anArray otherwise: [ previousAnswer ]]
]
