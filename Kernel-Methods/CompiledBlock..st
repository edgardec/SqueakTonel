"
CompiledBlock instances are blocks suitable for interpretation by the virtual machine.  They are a specialization of CompiledCode.  This requires both bytecode set and compiler support.  The V3 bytecode (EncoderForV3PlusClosures) does not provide support for CompiledBlock.  The SistaV1 set does (EncoderForSistaV1).

The last literal in a CompiledBlock is reserved for a reference to its enclosing CompiledBlock or CompiledMethod.  Super sends in CompiledBlocks must use the directed super send bytecode.  

By convention the penultimate literal of a method is either its selector or an instance of AdditionalMethodState.  AdditionalMethodState may be used to add instance variables to a method, albeit ones held in the method's AdditionalMethodState.  Subclasses of CompiledBlock that want to add state should subclass AdditionalMethodState to add the state they want, and implement methodPropertiesClass on the class side of the CompiledBlock subclass to answer the specialized subclass of AdditionalMethodState.  Enterprising programmers are encouraged to try and implement this support automatically through suitable modifications to the compiler and class builder.
"
Class {
	#name : #CompiledBlock,
	#superclass : #CompiledCode,
	#type : #compiledMethod,
	#category : #'Kernel-Methods'
}

{ #category : #literals }
CompiledBlock >> codeLiteralsDo: aBlock [
	"Overwritten to not cause infinite loop."

	aBlock value: self.

	self literalsDo: [:literal |
		(literal isCompiledCode and: [literal ~~ self outerCode]) ifTrue: [
			literal codeLiteralsDo: aBlock]].
]

{ #category : #'private-copying' }
CompiledBlock >> copyWithOuterCode: aCompiledCode [
	"Private; answer a shallow copy of the receiver updated with deep copies of
	 embedded block methods and a reference to aCompiledCode as the outer code."
	| numLiterals copy |
	copy := self shallowCopy.
	1 to: (numLiterals := self numLiterals) - 1 do:
		[:i| | lit |
		(lit := copy literalAt: i) isCompiledCode ifTrue:
			[copy literalAt: i put: (lit copyWithOuterCode: copy)]].
	copy literalAt: numLiterals put: aCompiledCode.
	^copy
]

{ #category : #accessing }
CompiledBlock >> encoderClass [
	"Answer the encoder class that encoded the bytecodes in this method.
	 The sign flag bit is used by the VM to select a bytecode set.  This formulation
	 may seem odd but this has to be fast, so no property probe unless needed."

	^self header >= 0
		ifTrue: 
			[PrimaryBytecodeSetEncoderClass]
		ifFalse:
			[PrimaryBytecodeSetEncoderClass == SecondaryBytecodeSetEncoderClass
				ifTrue: "Support for testing prior to installing another set"
					[(self homeMethod propertyValueAt: #encoderClass) ifNil: [SecondaryBytecodeSetEncoderClass]]
				ifFalse:
					[SecondaryBytecodeSetEncoderClass]]
]

{ #category : #comparing }
CompiledBlock >> hasSameLiteralsAs: aMethod [
	"Answer whether the receiver has the same sequence of literals as the argument.
	 Do not fully compare the last literal as this is the outerCode back pointer to the
	 containing method or block, and following it would cause infinite recursion.  In any
	 case this is a useful definition because it considers identical block methods in other-
	 wise different containing blocks or methods to be the same, which makes sense."
	| numLits |
	numLits := self numLiterals.
	numLits = aMethod numLiterals ifFalse: [^false].
	1 to: numLits - 1 do:
		[:i| | lit1 lit2 |
		lit1 := self literalAt: i.
		lit2 := aMethod literalAt: i.
		(lit1 == lit2 or: [lit1 literalEqual: lit2]) ifFalse:
			[^false]].
	^(self literalAt: numLits) isCompiledCode = (aMethod literalAt: numLits) isCompiledCode
]

{ #category : #printing }
CompiledBlock >> headerDescription [
	"Answer a description containing the information about the form of the
	 receiver and the form of the context needed to run the receiver."

	^(ByteString new: 128) writeStream
		print: self header; cr;
		nextPutAll: '"block full'; cr;
		nextPutAll: ' numArgs: '; print: self numArgs; cr;
		nextPutAll: ' numTemps: '; print: self numTemps; cr;
		nextPutAll: ' numLiterals: '; print: self numLiterals; cr;
		nextPutAll: ' frameSize: '; print: self frameSize; cr;
		nextPutAll: ' bytecodeSet: '; nextPutAll: self bytecodeSetName;
		nextPut: $"; cr;
		contents
]

{ #category : #'source code management' }
CompiledBlock >> holdsTempNames [
	^self homeMethod holdsTempNames
]

{ #category : #accessing }
CompiledBlock >> homeMethod [
	"answer the compiled method that I am installed in, or nil if none."
	^self outerCode homeMethod
]

{ #category : #testing }
CompiledBlock >> isCompiledBlock [
	^true
]

{ #category : #testing }
CompiledBlock >> isQuick [
	^false
]

{ #category : #printing }
CompiledBlock >> longPrintOn: aStream indent: tabs [
	"List of all the byte codes in a method with a short description of each"
	(InstructionPrinter on: self) indent: tabs; printInstructionsOn: aStream
]

{ #category : #accessing }
CompiledBlock >> method [
	"answer the compiled method that I am installed in, or nil if none."
	^self outerCode method
]

{ #category : #accessing }
CompiledBlock >> methodClass [
	"Answer the class that I am installed in."
	^self homeMethod methodClass
]

{ #category : #decompiling }
CompiledBlock >> methodForDecompile [
	^self homeMethod methodForDecompile
]

{ #category : #accessing }
CompiledBlock >> methodNode [
	^ self homeMethod methodNode
]

{ #category : #accessing }
CompiledBlock >> numCopiedValues [
	"Answer the number of copied values the receiver expects.
	 This is not fast as it is not expected to be needed from the
	 compiled block itself.  It is available cheaply from a block
	 closure for the method."

	| locator scanner pc |
	locator := BlockStartLocator new.
	scanner := InstructionStream on: self outerCode.
	[pc := scanner pc.
	 self == (scanner interpretNextInstructionFor: locator) ifTrue:
		[^(self outerCode abstractBytecodeMessageAt: pc) arguments second].
	 scanner atEnd] whileFalse.
	self error: 'cannot find the block creation bytecode for this compiled block in its outer code.'
]

{ #category : #accessing }
CompiledBlock >> outerCode [
	"answer the compiled code that I am installed in, or nil if none."
	^self literalAt: self numLiterals
]

{ #category : #accessing }
CompiledBlock >> outerCode: aCompiledCode [
	^self literalAt: self numLiterals put: aCompiledCode
]

{ #category : #copying }
CompiledBlock >> postCopy [
	1 to: self numLiterals - 1 do:
		[:index| | lit |
		 (lit := self literalAt: index) isCompiledCode ifTrue:
			[lit outerCode: self; postCopy]]
]

{ #category : #'accessing-pragmas & properties' }
CompiledBlock >> pragmaAt: aKey [
	"Answer the pragma with selector aKey, or nil if none."
	^self homeMethod pragmaAt: aKey
]

{ #category : #'accessing-pragmas & properties' }
CompiledBlock >> pragmas [
	^self homeMethod pragmas
]

{ #category : #'accessing-pragmas & properties' }
CompiledBlock >> pragmasAt: aSelector [
	"Answer all pragmas with selector aSelector."
	^self homeMethod pragmasAt: aSelector
]

{ #category : #accessing }
CompiledBlock >> primitive [
	^0
]

{ #category : #printing }
CompiledBlock >> printReferenceOn: aStream [
	"Override to indicate that this is a block, and to print a null reference when
	 the CompiledBlock is only partially initialized, as it is during compilation."
	aStream nextPutAll: '[] in '.
	self outerCode isVariableBinding
		ifTrue: [aStream nextPutAll: ' (as yet unbound)']
		ifFalse: [super printReferenceOn: aStream]
]

{ #category : #'accessing-pragmas & properties' }
CompiledBlock >> propertyKeysAndValuesDo: aBlock [
	"Enumerate the receiver with all the keys and values."
	^self homeMethod propertyKeysAndValuesDo: aBlock
]

{ #category : #'accessing-pragmas & properties' }
CompiledBlock >> propertyValueAt: propName [
	^self homeMethod propertyValueAt: propName
]

{ #category : #'accessing-pragmas & properties' }
CompiledBlock >> propertyValueAt: propName ifAbsent: aBlock [
	^self homeMethod propertyValueAt: propName ifAbsent: aBlock
]

{ #category : #'accessing-pragmas & properties' }
CompiledBlock >> propertyValueAt: propName put: propValue [
	"Set or add the property with key propName and value propValue.
	 If the receiver does not yet have a method properties create one and replace
	 the selector with it.  Otherwise, either relace propValue in the method properties
	 or replace method properties with one containing the new property."
	^self homeMethod propertyValueAt: propName put: propValue
]

{ #category : #'accessing-pragmas & properties' }
CompiledBlock >> removeProperty: propName [
	"Remove the property propName if it exists.
	 Do _not_ raise an error if the property is missing."
	^self homeMethod removeProperty: propName
]

{ #category : #'accessing-pragmas & properties' }
CompiledBlock >> removeProperty: propName ifAbsent: aBlock [
	"Remove the property propName if it exists.
	 Answer the evaluation of aBlock if the property is missing."
	^self homeMethod removeProperty: propName ifAbsent: aBlock
]

{ #category : #accessing }
CompiledBlock >> selector [
	^ self homeMethod selector
]
