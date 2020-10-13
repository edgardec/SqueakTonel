"
FieldNode handles field access in Tweak, e.g. self fieldName := foo => self fieldName: foo.
"
Class {
	#name : #FieldNode,
	#superclass : #VariableNode,
	#instVars : [
		'fieldDef',
		'rcvrNode',
		'readNode',
		'writeNode'
	],
	#category : #'Compiler-ParseNodes'
}

{ #category : #visiting }
FieldNode >> accept: aVisitor [
	^aVisitor visitFieldNode: self
]

{ #category : #testing }
FieldNode >> assignmentCheck: encoder at: location [
	(encoder cantStoreInto: name) ifTrue: [^location].
	fieldDef toSet ifNil:[
		encoder interactive ifTrue:[^location].
		fieldDef := fieldDef shallowCopy assignDefaultSetter.
	].
	^-1
]

{ #category : #'code generation' }
FieldNode >> emitCodeForEffect: stack encoder: encoder [
]

{ #category : #'code generation' }
FieldNode >> emitCodeForLoad: stack forValue: forValue encoder: encoder [
	rcvrNode emitCodeForValue: stack encoder: encoder.
	fieldDef accessKey ifNotNil:
		[super emitCodeForValue: stack encoder: encoder]
]

{ #category : #'code generation' }
FieldNode >> emitCodeForStore: stack encoder: encoder [
	fieldDef accessKey ifNil:[
		writeNode emitCode: stack args: 1 encoder: encoder super: false.
	] ifNotNil:[
		writeNode emitCode: stack args: 2 encoder: encoder super: false.
	].
]

{ #category : #'code generation' }
FieldNode >> emitCodeForStorePop: stack encoder: encoder [
	self emitCodeForStore: stack encoder: encoder.
	encoder genPop.
	stack pop: 1.
]

{ #category : #'code generation' }
FieldNode >> emitCodeForValue: stack encoder: encoder [
	fieldDef accessKey ifNil:[
		rcvrNode emitCodeForValue: stack encoder: encoder.
		readNode emitCode: stack args: 0 encoder: encoder super: false.
	] ifNotNil:[
		rcvrNode emitCodeForValue: stack encoder: encoder.
		super emitCodeForValue: stack encoder: encoder.
		readNode emitCode: stack args: 1 encoder: encoder super: false.
	].
]

{ #category : #'code generation' }
FieldNode >> encodeReceiverOn: encoder [
	"encode the receiver node"
	rcvrNode := encoder encodeVariable: 'self'.
]

{ #category : #accessing }
FieldNode >> fieldDef [
	^fieldDef
]

{ #category : #'initialize-release' }
FieldNode >> fieldDefinition: fieldDefinition [
	self name: fieldDefinition name key: fieldDefinition index: nil type: LdLitType
]

{ #category : #'initialize-release' }
FieldNode >> name: varName key: objRef index: i type: type [
	fieldDef := objRef.
	^super name: varName key: objRef key index: nil type: LdLitType
]

{ #category : #'code generation' }
FieldNode >> resetFromCopy: aFieldNode [
	"Reset the state of the recever to match that of the argument.
	 This is used to reset nodes that may have been repurposed
	 while generatig the compiled method for a full block."

	self assert: (fieldDef == aFieldNode fieldDef
				and: [rcvrNode == (aFieldNode instVarNamed: 'rcvrNode')
				and: [readNode == (aFieldNode instVarNamed: 'readNode')
				and: [writeNode == (aFieldNode instVarNamed: 'writeNode')]]]).
	super resetFromCopy: aFieldNode
]

{ #category : #'code generation' }
FieldNode >> sizeCodeForEffect: encoder [
	^0
]

{ #category : #'code generation' }
FieldNode >> sizeCodeForStore: encoder [
	rcvrNode ifNil:[self encodeReceiverOn: encoder].
	fieldDef accessKey ifNil:[
		writeNode ifNil:[writeNode := encoder encodeSelector: fieldDef toSet].
		^(rcvrNode sizeCodeForValue: encoder) + 
			(writeNode sizeCode: encoder args: 1 super: false)	
	].
	writeNode ifNil:[writeNode := encoder encodeSelector: #set:to:].
	^(rcvrNode sizeCodeForValue: encoder) + 
		(super sizeCodeForValue: encoder) +
			(writeNode sizeCode: encoder args: 2 super: false)
]

{ #category : #'code generation' }
FieldNode >> sizeCodeForStorePop: encoder [
	^(self sizeCodeForStore: encoder) + encoder sizePop
]

{ #category : #'code generation' }
FieldNode >> sizeCodeForValue: encoder [
	rcvrNode ifNil:[self encodeReceiverOn: encoder].
	fieldDef accessKey ifNil:[
		readNode ifNil:[readNode := encoder encodeSelector: fieldDef toGet].
		^(rcvrNode sizeCodeForValue: encoder) + 
			(readNode sizeCode: encoder args: 0 super: false)
	].
	readNode ifNil:[readNode := encoder encodeSelector: #get:].
	^(rcvrNode sizeCodeForValue: encoder) + 
		(super sizeCodeForValue: encoder) + 
			(readNode sizeCode: encoder args: 1 super: false)
]
