Class {
	#name : #WeakActionSequenceTrappingErrors,
	#superclass : #WeakActionSequence,
	#type : #variable,
	#category : #'System-Change Notification'
}

{ #category : #converting }
WeakActionSequenceTrappingErrors >> asActionSequenceTrappingErrors [

	^self
]

{ #category : #evaluating }
WeakActionSequenceTrappingErrors >> value [
	"Do the same as my parent, but make sure that all actions that do not  
	give errors are evaluated before resignaling the ones that gave errors  
	(giving the chance to clients to handle them)."

	^self valueStartingFrom: 1
]

{ #category : #evaluating }
WeakActionSequenceTrappingErrors >> valueStartingFrom: startIndex [
	"Do the same as my parent, but make sure that all actions that do not 
	give errors are evaluated before resignaling the ones that gave errors 
	(giving the chance to clients to handle them)."

	"Note: I currently trap Halt,Error so that I am sure to get a Halt event in case of a Halt. This is being fixed in the exception system - when the fix is done it will be enough to capture only Error."

	| each answer |
	answer := nil.
	startIndex to: self size do: [:index |
		each := self at: index.
		[
			answer := each valueOtherwise: [ answer ].
		]
			on: Halt , Error
			do: [:exc | 
				self valueStartingFrom: index + 1.
				exc pass]].
	^ answer
]

{ #category : #evaluating }
WeakActionSequenceTrappingErrors >> valueWithArguments: anArray [ 
	"Do the same as my parent, but make sure that all actions that do not 
	give errors are evaluated before resignaling the ones that gave errors 
	(giving the chance to clients to handle them)."

	^self valueWithArguments: anArray startingFrom: 1
]

{ #category : #evaluating }
WeakActionSequenceTrappingErrors >> valueWithArguments: anArray startingFrom: startIndex [
	"Do the same as my parent, but make sure that all actions that do not 
	give errors are evaluated before resignaling the ones that gave errors 
	(giving the chance to clients to handle them)."

	"Note: I currently trap Halt,Error so that I am sure to get a Halt event in case of a Halt. This is being fixed in the exception system - when the fix is done it will be enough to capture only Error."

	| each answer |
	answer := nil.
	startIndex to: self size do: [:index |
		each := self at: index.
		[
			answer := each valueWithArguments: anArray otherwise: [ answer ].
		]
			on: Halt , Error
			do: [:exc | 
				self valueWithArguments: anArray startingFrom: index + 1.
				exc pass]].
	^ answer
]
