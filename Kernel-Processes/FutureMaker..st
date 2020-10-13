"
Uses #doesNotUnderstand: to transform messages into future messages.  In practice, this class is never used; for efficiency, the Compiler has been modified to use FutureNode to transform code at compile-time to directly send #futureSend:at:args:.  However, this is simply an optimization... the semantics are unchanged.
"
Class {
	#name : #FutureMaker,
	#superclass : #ProtoObject,
	#instVars : [
		'myTarget',
		'deltaMSecs'
	],
	#category : #'Kernel-Processes'
}

{ #category : #comparing }
FutureMaker >> = anObject [
	^self == anObject
]

{ #category : #accessing }
FutureMaker >> basicAt: index [ 
	"Primitive. Assumes receiver is indexable. Answer the value of an 
	indexable element in the receiver. Fail if the argument index is not an 
	Integer or is out of bounds. Essential. Do not override in a subclass. See 
	Object documentation whatIsAPrimitive."

	<primitive: 60>
	index isInteger ifTrue: [self errorSubscriptBounds: index].
	index isNumber
		ifTrue: [^self basicAt: index asInteger]
		ifFalse: [self errorNonIntegerIndex]
]

{ #category : #accessing }
FutureMaker >> basicAt: index put: value [ 
	"Primitive. Assumes receiver is indexable. Store the second argument 
	value in the indexable element of the receiver indicated by index. Fail 
	if the index is not an Integer or is out of bounds. Or fail if the value is 
	not of the right type for this kind of collection. Answer the value that 
	was stored. Essential. Do not override in a subclass. See Object 
	documentation whatIsAPrimitive."

	<primitive: 61 error: ec>
	index isInteger ifTrue:
		[(index >= 1 and: [index <= self basicSize])
			ifTrue:
				[ec == #'no modification' ifTrue:
					[^thisContext modificationForbiddenFor: self at: index put: value].
				 self errorImproperStore]
			ifFalse: [self errorSubscriptBounds: index]].
	index isNumber ifTrue:
		[^self basicAt: index asInteger put: value].
	self errorNonIntegerIndex
]

{ #category : #accessing }
FutureMaker >> basicSize [
	"Primitive. Answer the number of indexable variables in the receiver. 
	This value is the same as the largest legal subscript. Essential. Do not 
	override in any subclass. See Object documentation whatIsAPrimitive."

	<primitive: 62>
	"The number of indexable fields of fixed-length objects is 0"
	^0
]

{ #category : #accessing }
FutureMaker >> doesNotUnderstand: aMessage [
	"Package up the message and send it"
	^myTarget futureSend: aMessage selector at: deltaMSecs args: aMessage arguments
]

{ #category : #comparing }
FutureMaker >> hash [
	^self scaledIdentityHash
]

{ #category : #accessing }
FutureMaker >> instVarAt: index [ 
	"Primitive. Answer a fixed variable in an object. The numbering of the 
	variables corresponds to the named instance variables. Fail if the index 
	is not an Integer or is not the index of a fixed variable. Essential. See 
	Object documentation whatIsAPrimitive."

	<primitive: 173 error: ec>
	self primitiveFailed
]

{ #category : #accessing }
FutureMaker >> instVarAt: anInteger put: anObject [
	"Primitive. Store a value into a fixed variable in the receiver. The 
	numbering of the variables corresponds to the named instance variables. 
	Fail if the index is not an Integer or is not the index of a fixed variable. 
	Answer the value stored as the result. Using this message violates the 
	principle that each object has sovereign control over the storing of 
	values into its instance variables. Essential. See Object documentation 
	whatIsAPrimitive."

	<primitive: 174 error: ec>
	ec == #'no modification' ifTrue:
		[^thisContext modificationForbiddenFor: self instVarAt: anInteger value: anObject].
	self primitiveFailed
]

{ #category : #accessing }
FutureMaker >> isKindOf: aClass [ 
	"--- needed for debugging ---"
	self class == aClass
		ifTrue: [^true]
		ifFalse: [^self class inheritsFrom: aClass]
]

{ #category : #accessing }
FutureMaker >> isMemberOf: aClass [ 
	"Answer whether the receiver is an instance of the class, aClass."
	^self class == aClass
]

{ #category : #testing }
FutureMaker >> isText [
	^false
]

{ #category : #printing }
FutureMaker >> printOn: aStream [
	"Append to the argument, aStream, a sequence of characters that  
	identifies the receiver."
	| title |
	title := self class name.
	aStream
		nextPutAll: (title first isVowel ifTrue: ['an '] ifFalse: ['a ']);
		nextPutAll: title
]

{ #category : #printing }
FutureMaker >> printString [
	"Answer a String whose characters are a description of the receiver. 
	If you want to print without a character limit, use fullPrintString."
	^ self printStringLimitedTo: 50000
]

{ #category : #printing }
FutureMaker >> printStringLimitedTo: limit [
	"Answer a String whose characters are a description of the receiver.
	If you want to print without a character limit, use fullPrintString."
	| limitedString |
	limitedString := String streamContents: [:s | self printOn: s] limitedTo: limit.
	limitedString size < limit ifTrue: [^ limitedString].
	^ limitedString , '...etc...'
]

{ #category : #private }
FutureMaker >> setDeltaMSecs: delta target: futureTarget [
	deltaMSecs := delta.
	myTarget := futureTarget.
]

{ #category : #private }
FutureMaker >> setTarget: aTarget [
	myTarget := aTarget.
]
