"
I am a parse tree leaf representing a selector.
"
Class {
	#name : #SelectorNode,
	#superclass : #LeafNode,
	#category : #'Compiler-ParseNodes'
}

{ #category : #visiting }
SelectorNode >> accept: aVisitor [
	^aVisitor visitSelectorNode: self
]

{ #category : #'code generation' }
SelectorNode >> emitCode: stack args: nArgs encoder: encoder [

	self emitCode: stack
		args: nArgs
		encoder: encoder
		super: false
]

{ #category : #'code generation' }
SelectorNode >> emitCode: stack args: nArgs encoder: encoder super: supered [
	code < Send ifTrue:
		[self internalEncodingError].
	stack pop: nArgs.
	supered
		ifTrue:
			[(encoder supportsFullBlocks
			  and: [encoder generatingFullBlock])
				ifTrue:
					[encoder genPushLiteral: (encoder sharableLitIndex: encoder classEncoding).
					 encoder genSendDirectedSuper: index numArgs: nArgs]
				ifFalse: [encoder genSendSuper: index numArgs: nArgs]]
		ifFalse:
			[encoder genSend: index numArgs: nArgs]
]

{ #category : #'code generation' }
SelectorNode >> emitCodeForEffect: stack encoder: encoder [

	self shouldNotImplement
]

{ #category : #'code generation' }
SelectorNode >> emitCodeForValue: stack encoder: encoder [

	self shouldNotImplement
]

{ #category : #inappropriate }
SelectorNode >> emitForEffect: stack on: strm [

	self shouldNotImplement
]

{ #category : #inappropriate }
SelectorNode >> emitForValue: stack on: strm [

	self shouldNotImplement
]

{ #category : #'code generation' }
SelectorNode >> forSuperSend [
	"Answer the receiver or a derivative, suitable for use in a super send.
	 This is overridden by SpecialSelectorNode to return a SelectorNode clone."
	^self
]

{ #category : #private }
SelectorNode >> internalEncodingError [
	self error: 'with the split between SelectorNode and SpecialSelectorNode code should never be < Send for normal sends.'
]

{ #category : #testing }
SelectorNode >> isForFFICall [
	^key asString includesSubstring: '()/'
]

{ #category : #testing }
SelectorNode >> isPvtSelector [
	"Answer if this selector node is a private message selector."

	^key isPvtSelector
]

{ #category : #printing }
SelectorNode >> key: aSelector [
	"This is for printing of FFI selectors."
	key := aSelector
]

{ #category : #'initialize-release' }
SelectorNode >> key: object code: byte index: idx [

	key := object.
	code := byte.
	index := idx
]

{ #category : #'initialize-release' }
SelectorNode >> name: literal key: object index: i type: type [
	"For compatibility with Encoder>>name:key:class:type:set:"
	^self key: object index: i type: type
]

{ #category : #printing }
SelectorNode >> printAsFFICallWithArguments: aSequence on: aStream indent: level [
	aStream nextPutAll: (key copyUpTo: $)).
	aSequence
		do: [:arg| arg printOn: aStream indent: level]
		separatedBy: [aStream nextPutAll: ', '].
	aStream nextPut: $)
]

{ #category : #printing }
SelectorNode >> printOn: aStream indent: level [ 
	aStream nextPutAll: (key == nil
							ifTrue: ['<key==nil>']
							ifFalse: [key])
]

{ #category : #printing }
SelectorNode >> printWithClosureAnalysisOn: aStream indent: level [ 
	aStream nextPutAll: (key == nil
							ifTrue: ['<key==nil>']
							ifFalse: [key])
]

{ #category : #'code generation' }
SelectorNode >> reserve: encoder [ 
	"If this is a yet unused literal of type -code, reserve it."

	index ifNil:
		[index := encoder sharableLitIndex: key.
		 code := Send]
]

{ #category : #'code generation' }
SelectorNode >> resetForBlockGeneration [
	"Reset the receiver to an unassigned state such that its index
	 in the encoder's literalStream is as yet to be determined."
	code := SendType negated.
	index := nil
]

{ #category : #'code generation' }
SelectorNode >> sizeCode: encoder args: nArgs super: supered [
	self reserve: encoder.
	code < Send ifTrue:
		[self internalEncodingError].
	supered ifFalse:
		[^encoder sizeSend: index numArgs: nArgs].
	(encoder supportsFullBlocks
	 and: [encoder generatingFullBlock]) ifTrue:
		[^(encoder sizePushLiteral: (encoder sharableLitIndex: encoder classEncoding))
		 + (encoder sizeSendDirectedSuper: index numArgs: nArgs)].
	^encoder sizeSendSuper: index numArgs: nArgs
]

{ #category : #'code generation' }
SelectorNode >> sizeCodeForEffect: encoder [

	self shouldNotImplement
]

{ #category : #'code generation' }
SelectorNode >> sizeCodeForValue: encoder [

	self shouldNotImplement
]
