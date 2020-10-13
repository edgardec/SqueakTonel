"
False defines the behavior of its single instance, false -- logical negation. Notice how the truth-value checks become direct message sends, without the need for explicit testing.

Be aware however that most of these methods are not sent as real messages in normal use. Most are inline coded by the compiler as test and jump bytecodes - avoiding the overhead of the full message sends. So simply redefining these methods here will have no effect.
"
Class {
	#name : #False,
	#superclass : #Boolean,
	#category : #'Kernel-Objects'
}

{ #category : #'as yet unclassified' }
False class >> initializedInstance [
	^ false
]

{ #category : #'logical operations' }
False >> & aBoolean [ 
	"Evaluating conjunction -- answer false since receiver is false, but let the VM quickly check the type of the argument first."

	aBoolean ifFalse: [ ^false ].
	^false
]

{ #category : #'logical operations' }
False >> ==> aBlock [
	^true
]

{ #category : #controlling }
False >> and: alternativeBlock [ 
	"Nonevaluating conjunction -- answer with false since the receiver is false."

	^self
]

{ #category : #printing }
False >> asBit [

	^ 0
]

{ #category : #controlling }
False >> ifFalse: alternativeBlock [ 
	"Answer the value of alternativeBlock. Execution does not actually
	reach here because the expression is compiled in-line."

	^alternativeBlock value
]

{ #category : #controlling }
False >> ifFalse: falseAlternativeBlock ifTrue: trueAlternativeBlock [ 
	"Answer the value of falseAlternativeBlock. Execution does not
	actually reach here because the expression is compiled in-line."

	^falseAlternativeBlock value
]

{ #category : #controlling }
False >> ifTrue: alternativeBlock [ 
	"Since the condition is false, answer the value of the false alternative, 
	which is nil. Execution does not actually reach here because the
	expression is compiled in-line."

	^nil
]

{ #category : #controlling }
False >> ifTrue: trueAlternativeBlock ifFalse: falseAlternativeBlock [ 
	"Answer the value of falseAlternativeBlock. Execution does not
	actually reach here because the expression is compiled in-line."

	^falseAlternativeBlock value
]

{ #category : #'logical operations' }
False >> not [
	"Negation -- answer true since the receiver is false."

	^true
]

{ #category : #controlling }
False >> or: alternativeBlock [ 
	"Nonevaluating disjunction -- answer value of alternativeBlock."

	^alternativeBlock value
]

{ #category : #printing }
False >> printOn: aStream [ 

	aStream nextPutAll: 'false'
]

{ #category : #'logical operations' }
False >> xor: aBoolean [
	"aBoolean is either a boolean, or an object who's #value returns a boolean (usually a block)."
	^aBoolean value ifTrue: [ true ] ifFalse: [ false ]
]

{ #category : #'logical operations' }
False >> | aBoolean [ 
	"Evaluating disjunction (OR) -- could  answer aBoolean since receiver is false, but let the VM quickly check the type of the argument instead."

	aBoolean ifTrue: [ ^true ].
	^false
]
