"
I am a parse tree leaf representing a literal string or number.
"
Class {
	#name : #LiteralNode,
	#superclass : #LeafNode,
	#category : #'Compiler-ParseNodes'
}

{ #category : #visiting }
LiteralNode >> accept: aVisitor [
	^aVisitor visitLiteralNode: self
]

{ #category : #'code generation' }
LiteralNode >> emitCodeForValue: stack encoder: encoder [
	stack push: 1.
	(encoder isSpecialLiteralForPush: key)
		ifTrue: [encoder genPushSpecialLiteral: key]
		ifFalse: [encoder genPushLiteral: index]
]

{ #category : #evaluation }
LiteralNode >> eval [
	"When everything in me is a constant, I can produce a value.  This is only used by the Scripting system (TilePadMorph tilesFrom:in:)"

	^ key
]

{ #category : #testing }
LiteralNode >> isConstantNumber [
	^ key isNumber
]

{ #category : #testing }
LiteralNode >> isLiteralNode [

	^ true
]

{ #category : #testing }
LiteralNode >> isSpecialConstant [
	^ code between: LdTrue and: LdMinus1+3
]

{ #category : #testing }
LiteralNode >> literalValue [

	^key
]

{ #category : #'initialize-release' }
LiteralNode >> name: literal key: object index: i type: type [
	"For compatibility with Encoder>>name:key:class:type:set:"
	^self key: object index: i type: type
]

{ #category : #printing }
LiteralNode >> printOn: aStream indent: level [

	key isVariableBinding ifTrue:
		[key key isNil
			ifTrue:
				[aStream nextPutAll: '###'; nextPutAll: key value soleInstance name]
			ifFalse:
				[aStream nextPutAll: '##'; nextPutAll: key key].
		^self].
	key isLiteral ifTrue:
		[key printAsLiteralOn: aStream.
		 ^self].
	(key isCompiledCode and: [key isCompiledBlock]) ifTrue:
		[key printOn: aStream.
		 ^self].
	key storeOn: aStream
]

{ #category : #printing }
LiteralNode >> printWithClosureAnalysisOn: aStream indent: level [

	key isVariableBinding
		ifTrue:
			[key key isNil
				ifTrue:
					[aStream nextPutAll: '###'; nextPutAll: key value soleInstance name]
				ifFalse:
					[aStream nextPutAll: '##'; nextPutAll: key key]]
		ifFalse:
			[key storeOn: aStream]
]

{ #category : #'code generation' }
LiteralNode >> reserve: encoder [ 
	"If this is a yet unused literal of type -code, reserve it."

	code < 0 ifTrue:
		[index := key isVariableBinding "true if sending value[:] to a special binding"
					ifTrue: [encoder sharableLitIndex: key]
					ifFalse: [encoder litIndex: key].
		 code := self code: index type: 0 - code]
]

{ #category : #'code generation' }
LiteralNode >> resetForBlockGeneration [
	"Reset the receiver to an unassigned state such that its index
	 in the encoder's literalStream is as yet to be determined."
	code := LdLitType negated.
	index := nil
]

{ #category : #'code generation' }
LiteralNode >> sizeCodeForValue: encoder [
	self reserve: encoder.
	^(encoder isSpecialLiteralForPush: key)
		ifTrue: [encoder sizePushSpecialLiteral: key]
		ifFalse: [encoder sizePushLiteral: index]
]
