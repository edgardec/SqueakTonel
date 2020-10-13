Class {
	#name : #SpecialLiteralNode,
	#superclass : #LiteralNode,
	#category : #'Compiler-ParseNodes'
}

{ #category : #'code generation' }
SpecialLiteralNode >> emitCodeForValue: stack encoder: encoder [
	stack push: 1.
	encoder genPushSpecialLiteral: key
]

{ #category : #'code generation' }
SpecialLiteralNode >> sizeCodeForValue: encoder [
	^encoder sizePushSpecialLiteral: key
]
