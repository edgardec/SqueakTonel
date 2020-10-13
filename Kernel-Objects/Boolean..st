"
Boolean is an abstract class defining the protocol for logic testing operations and conditional control structures for the logical values represented by the instances of its subclasses True and False.

Boolean redefines #new so no instances of Boolean can be created. It also redefines several messages in the 'copying' protocol to ensure that only one instance of each of its subclasses True (the global true, logical assertion) and False (the global false, logical negation) ever exist in the system.
"
Class {
	#name : #Boolean,
	#superclass : #Object,
	#category : #'Kernel-Objects'
}

{ #category : #'instance creation' }
Boolean class >> initializedInstance [
	^ nil
]

{ #category : #testing }
Boolean class >> isAbstract [
	^self = Boolean
]

{ #category : #'instance creation' }
Boolean class >> new [
	self error: 'You may not create any more Booleans - this is two-valued logic'
]

{ #category : #'logical operations' }
Boolean >> & aBoolean [ 
	"Evaluating conjunction. Evaluate the argument. Then answer true if 
	both the receiver and the argument are true."

	self subclassResponsibility
]

{ #category : #'logical operations' }
Boolean >> ==> aBlock [
	"this is material implication, a ==> b, also known as:
			b if a 
			a implies b
			if a then b
			b is a consequence of a
			a therefore b (but note: 'it is raining therefore it is cloudy' is implication; 'it is autumn therefore the leaves are falling' is equivalence).
		
	Here is the truth table for material implication (view in a monospaced font):
	
	   p   |   q   |   p ==> q
	-------|-------|-------------
	   T   |   T   |      T
	   T   |   F   |      F
	   F   |   T   |      T
	   F   |   F   |      T
	"

	self subclassResponsibility
]

{ #category : #controlling }
Boolean >> and: alternativeBlock [ 
	"Nonevaluating conjunction. If the receiver is true, answer the value of 
	the argument, alternativeBlock; otherwise answer false without 
	evaluating the argument."

	self subclassResponsibility
]

{ #category : #controlling }
Boolean >> and: block1 and: block2 [
	"Nonevaluating conjunction without deep nesting.
	The receiver is evaluated, followed by the blocks in order.
	If any of these evaluates as false, then return false immediately,
		without evaluating any further blocks.
	If all return true, then return true."

	self ifFalse: [^ false].
	block1 value ifFalse: [^ false].
	block2 value ifFalse: [^ false].
	^ true
]

{ #category : #controlling }
Boolean >> and: block1 and: block2 and: block3 [
	"Nonevaluating conjunction without deep nesting.
	The receiver is evaluated, followed by the blocks in order.
	If any of these evaluates as false, then return false immediately,
		without evaluating any further blocks.
	If all return true, then return true."

	self ifFalse: [^ false].
	block1 value ifFalse: [^ false].
	block2 value ifFalse: [^ false].
	block3 value ifFalse: [^ false].
	^ true
]

{ #category : #controlling }
Boolean >> and: block1 and: block2 and: block3 and: block4 [
	"Nonevaluating conjunction without deep nesting.
	The receiver is evaluated, followed by the blocks in order.
	If any of these evaluates as false, then return false immediately,
		without evaluating any further blocks.
	If all return true, then return true."

	self ifFalse: [^ false].
	block1 value ifFalse: [^ false].
	block2 value ifFalse: [^ false].
	block3 value ifFalse: [^ false].
	block4 value ifFalse: [^ false].
	^ true
]

{ #category : #printing }
Boolean >> asBit [
	"My numerical interpretation, as one-bit number. This extends nicely to n-bit numbers,
	as long as they treat 0 as false, and anything else as true"
	^ self subclassResponsibility
]

{ #category : #converting }
Boolean >> asInteger [
	"It is sufficient to treat this boolean as bit so as to interpret it as a number"
	^ self asBit
]

{ #category : #converting }
Boolean >> asNumber [
	"It is sufficient to treat this boolean as bit so as to interpret it as a number"
	^ self asBit
]

{ #category : #copying }
Boolean >> deepCopy [ 
	"Receiver has two concrete subclasses, True and False.
	Only one instance of each should be made, so return self."
]

{ #category : #'logical operations' }
Boolean >> eqv: aBoolean [ 
	"Answer true if the receiver is equivalent to aBoolean."

	^self == aBoolean
]

{ #category : #controlling }
Boolean >> ifFalse: alternativeBlock [ 
	"If the receiver is true (i.e., the condition is true), then the value is the 
	true alternative, which is nil. Otherwise answer the result of evaluating 
	the argument, alternativeBlock. Create an error notification if the 
	receiver is nonBoolean. Execution does not actually reach here because 
	the expression is compiled in-line."

	self subclassResponsibility
]

{ #category : #controlling }
Boolean >> ifFalse: falseAlternativeBlock ifTrue: trueAlternativeBlock [ 
	"Same as ifTrue:ifFalse:."

	self subclassResponsibility
]

{ #category : #controlling }
Boolean >> ifTrue: alternativeBlock [ 
	"If the receiver is false (i.e., the condition is false), then the value is the 
	false alternative, which is nil. Otherwise answer the result of evaluating 
	the argument, alternativeBlock. Create an error notification if the 
	receiver is nonBoolean. Execution does not actually reach here because 
	the expression is compiled in-line."

	self subclassResponsibility
]

{ #category : #controlling }
Boolean >> ifTrue: trueAlternativeBlock ifFalse: falseAlternativeBlock [
	"If the receiver is true (i.e., the condition is true), then answer the value 
	of the argument trueAlternativeBlock. If the receiver is false, answer the 
	result of evaluating the argument falseAlternativeBlock. If the receiver 
	is a nonBoolean then create an error notification. Execution does not 
	actually reach here because the expression is compiled in-line."

	self subclassResponsibility
]

{ #category : #testing }
Boolean >> isBoolean [
	^ true
]

{ #category : #printing }
Boolean >> isLiteral [ 
	^ true
]

{ #category : #'logical operations' }
Boolean >> not [
	"Negation. Answer true if the receiver is false, answer false if the 
	receiver is true."

	self subclassResponsibility
]

{ #category : #controlling }
Boolean >> or: alternativeBlock [ 
	"Nonevaluating disjunction. If the receiver is false, answer the value of 
	the argument, alternativeBlock; otherwise answer true without 
	evaluating the argument."

	self subclassResponsibility
]

{ #category : #controlling }
Boolean >> or: block1 or: block2 [
	"Nonevaluating alternation without deep nesting.
	The receiver is evaluated, followed by the blocks in order.
	If any of these evaluates as true, then return true immediately,
		without evaluating any further blocks.
	If all return false, then return false."

	self ifTrue: [^ true].
	block1 value ifTrue: [^ true].
	block2 value ifTrue: [^ true].
	^ false
]

{ #category : #controlling }
Boolean >> or: block1 or: block2 or: block3 [
	"Nonevaluating alternation without deep nesting.
	The receiver is evaluated, followed by the blocks in order.
	If any of these evaluates as true, then return true immediately,
		without evaluating any further blocks.
	If all return false, then return false."

	self ifTrue: [^ true].
	block1 value ifTrue: [^ true].
	block2 value ifTrue: [^ true].
	block3 value ifTrue: [^ true].
	^ false
]

{ #category : #controlling }
Boolean >> or: block1 or: block2 or: block3 or: block4 [
	"Nonevaluating alternation without deep nesting.
	The receiver is evaluated, followed by the blocks in order.
	If any of these evaluates as true, then return true immediately,
		without evaluating any further blocks.
	If all return false, then return false."

	self ifTrue: [^ true].
	block1 value ifTrue: [^ true].
	block2 value ifTrue: [^ true].
	block3 value ifTrue: [^ true].
	block4 value ifTrue: [^ true].
	^ false
]

{ #category : #controlling }
Boolean >> or: block1 or: block2 or: block3 or: block4 or: block5 [
	"Nonevaluating alternation without deep nesting.
	The receiver is evaluated, followed by the blocks in order.
	If any of these evaluates as true, then return true immediately,
		without evaluating any further blocks.
	If all return false, then return false."

	self ifTrue: [^ true].
	block1 value ifTrue: [^ true].
	block2 value ifTrue: [^ true].
	block3 value ifTrue: [^ true].
	block4 value ifTrue: [^ true].
	block5 value ifTrue: [^ true].
	^ false
]

{ #category : #printing }
Boolean >> printAsLiteralOn: aStream [
	^self printOn: aStream
]

{ #category : #copying }
Boolean >> shallowCopy [ 
	"Receiver has two concrete subclasses, True and False.
	Only one instance of each should be made, so return self."
]

{ #category : #printing }
Boolean >> storeOn: aStream [ 
	"Refer to the comment in Object|storeOn:."

	self printOn: aStream
]

{ #category : #copying }
Boolean >> veryDeepCopy [
	"Overridden for performance to avoid #fixDependents."
	^ self
]

{ #category : #copying }
Boolean >> veryDeepCopyWith: deepCopier [
	"Return self.  I can't be copied.  Do not record me."
]

{ #category : #'logical operations' }
Boolean >> xor: aBoolean [ 
	"Exclusive OR. Answer true if the receiver is not equivalent to aBoolean."

	^(self == aBoolean) not
]

{ #category : #'logical operations' }
Boolean >> | aBoolean [ 
	"Evaluating disjunction (OR). Evaluate the argument. Then answer true 
	if either the receiver or the argument is true."

	self subclassResponsibility
]
