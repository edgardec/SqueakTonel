"
A MethodCall is a resendable message-send, complete with receiver, instantiated arguments, and a memory of when it was last evaluated and what the last value was.  

The methodInterface with which it is associated can furnish argument names, documentation, and other information.
"
Class {
	#name : #MethodCall,
	#superclass : #MessageSend,
	#instVars : [
		'lastValue',
		'methodInterface',
		'timeStamp'
	],
	#category : #'Protocols-Kernel'
}

{ #category : #'method interface' }
MethodCall >> ephemeralMethodInterface [
	"Answer a methodInterface for me. If I have one stored, answer it; if 
	not, conjure up an interface and answer it but do NOT store it 
	internally. You can call this directly if you need a method interface 
	for me but do not want any conjured-up interface to persist."
	^ methodInterface
		ifNil: [MethodInterface new
				conjuredUpFor: selector
				class: (self receiver class whichClassIncludesSelector: selector)]
]

{ #category : #evaluation }
MethodCall >> evaluate [
	"Evaluate the receiver, and if value has changed, signal value-changed"

	| result |
	result := arguments isEmptyOrNil
		ifTrue: [self receiver perform: selector]
		ifFalse: [self receiver perform: selector withArguments: arguments asArray].
	timeStamp := Time dateAndTimeNow.
	result ~= lastValue ifTrue:
		[lastValue := result.
		self changed: #value]
	
]

{ #category : #evaluation }
MethodCall >> everEvaluated [
	"Answer whether this method call has ever been evaluated"

	^ timeStamp notNil
]

{ #category : #evaluation }
MethodCall >> lastValue [
	"Answer the last value I remember obtaining from an evaluation"

	^ lastValue
]

{ #category : #'method interface' }
MethodCall >> methodInterface [
	"Answer the receiver's methodInterface, conjuring one up on the spot (and remembering) if not present"

	^ methodInterface ifNil:
		[methodInterface := self ephemeralMethodInterface]
]

{ #category : #'method interface' }
MethodCall >> methodInterface: anInterface [
	"Set my methodInterface"

	methodInterface := anInterface
]

{ #category : #'method interface' }
MethodCall >> methodInterfaceOrNil [
	"Answer my methodInterface, whether it is nil or not"

	^ methodInterface
]

{ #category : #initialization }
MethodCall >> receiver: aReceiver methodInterface: aMethodInterface [
	"Initialize me to have the given receiver and methodInterface"

	| aResultType |
	receiver := aReceiver.
	selector := aMethodInterface selector.
	methodInterface := aMethodInterface.
	arguments := aMethodInterface defaultArguments.

	self flag: #noteToTed.
	"the below can't really survive, I know.  The intent is that if the method has a declared result type, we want the preferred readout type to be able to handle the initial #lastValue even if the MethodCall has not been evaluated yet; thus we'd rather have a boolean value such as true rather than a nil here if we're showing a boolean readout such as a checkbox, and likewise for color-valued and numeric-valued readouts etc, "

	(aResultType := methodInterface resultType) ~~ #unknown ifTrue:
		[lastValue := (Vocabulary vocabularyForType: aResultType) initialValueForASlotFor: aReceiver]        
]

{ #category : #initialization }
MethodCall >> receiver: aReceiver methodInterface: aMethodInterface initialArguments: initialArguments [
	"Set up a method-call for the given receiver, method-interface, and initial arguments"

	receiver := aReceiver.
	selector := aMethodInterface selector.
	methodInterface := aMethodInterface.
	arguments := initialArguments ifNotNil: [initialArguments asArray]

]

{ #category : #'argument access' }
MethodCall >> setArgumentNamed: aName toValue: aValue [
	"Set the argument of the given name to the given value"

	| anIndex |
	anIndex := self methodInterface argumentVariables findFirst:
		[:aVariable | aVariable variableName = aName].
	anIndex > 0
		ifTrue:
			[arguments at: anIndex put: aValue]
		ifFalse:
			[self error: 'argument missing'].
	self changed: #argumentValue
]

{ #category : #initialization }
MethodCall >> valueOfArgumentNamed: aName [
	"Answer the value of the given arguement variable"

	| anIndex |
	anIndex := self methodInterface argumentVariables findFirst:
		[:aVariable | aVariable variableName = aName].
	^ anIndex > 0
		ifTrue:
			[arguments at: anIndex]
		ifFalse:
			[self error: 'variable not found']
]
