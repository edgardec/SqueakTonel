"
True defines the behavior of its single instance, true -- logical assertion. Notice how the truth-value checks become direct message sends, without the need for explicit testing.

Be aware however that most of these methods are not sent as real messages in normal use. Most are inline coded by the compiler as test and jump bytecodes - avoiding the overhead of the full message sends. So simply redefining these methods here will have no effect.
"
Class {
	#name : #True,
	#superclass : #Boolean,
	#category : #'Kernel-Objects'
}

{ #category : #'as yet unclassified' }
True class >> initializedInstance [
	^ true
]

{ #category : #'logical operations' }
True >> & aBoolean [ 
	"Evaluating conjunction -- could answer aBoolean since receiver is true, but let the VM quickly check the type of the argument instead."

	aBoolean ifFalse: [ ^false ].
	^true
]

{ #category : #'logical operations' }
True >> ==> aBlock [
	^aBlock value
]

{ #category : #controlling }
True >> and: alternativeBlock [ 
	"Nonevaluating conjunction -- answer the value of alternativeBlock since
	the receiver is true."

	^alternativeBlock value
]

{ #category : #printing }
True >> asBit [

	^ 1
]

{ #category : #controlling }
True >> ifFalse: alternativeBlock [ 
	"Since the condition is true, the value is the true alternative, which is nil. 
	Execution does not actually reach here because the expression is compiled 
	in-line."

	^nil
]

{ #category : #controlling }
True >> ifFalse: falseAlternativeBlock ifTrue: trueAlternativeBlock [ 
	"Answer the value of trueAlternativeBlock. Execution does not 
	actually reach here because the expression is compiled in-line."

	^trueAlternativeBlock value
]

{ #category : #controlling }
True >> ifTrue: alternativeBlock [ 
	"Answer the value of alternativeBlock. Execution does not actually 
	reach here because the expression is compiled in-line."

	^alternativeBlock value
]

{ #category : #controlling }
True >> ifTrue: trueAlternativeBlock ifFalse: falseAlternativeBlock [ 
	"Answer with the value of trueAlternativeBlock. Execution does not 
	actually reach here because the expression is compiled in-line."

	^trueAlternativeBlock value
]

{ #category : #'logical operations' }
True >> not [
	"Negation--answer false since the receiver is true."

	^false
]

{ #category : #controlling }
True >> or: alternativeBlock [ 
	"Nonevaluating disjunction -- answer true since the receiver is true."

	^self
]

{ #category : #printing }
True >> printOn: aStream [ 

	aStream nextPutAll: 'true'
]

{ #category : #'logical operations' }
True >> xor: aBoolean [
	"aBoolean is either a boolean, or an object who's #value returns a boolean (usually a block)."
	^aBoolean value ifTrue: [ false ] ifFalse: [ true ]
]

{ #category : #'logical operations' }
True >> | aBoolean [ 
	"Evaluating disjunction (OR) -- answer true since the receiver is true, but let the VM quickly check the type of the argument first."

	aBoolean ifTrue: [ ^true ].
	^true
]
