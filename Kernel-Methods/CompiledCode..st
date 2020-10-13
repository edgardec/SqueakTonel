"
CompiledCode instances are methods suitable for execution by the virtual machine.  Instances of CompiledCode and its subclasses are the only objects in the system that have both indexable pointer fields and indexable 8-bit integer fields.  The pointer fields are used for literals and metadata, and the bytes are used for bytecodes and a variety of encoded informaton such as source code, source code position, etc.  The first part of a CompiledCode object is pointers, the second part is bytes.  CompiledCode inherits from ByteArray to avoid duplicating some of ByteArray's methods, not because a CompiledCode is-a ByteArray.

Instance variables: *indexed* (no named inst vars)

Class variables:
SmallFrame								- the number of stack slots in a small frame Context
LargeFrame							- the number of stack slots in a large frame Context
PrimaryBytecodeSetEncoderClass		- the encoder class that defines the primary instruction set
SecondaryBytecodeSetEncoderClass	- the encoder class that defines the secondary instruction set

The current format of a CompiledCode object is as follows:

	header (4 or 8 bytes, SmallInteger)
	literals (4 or 8 bytes each, Object, see ""The last literal..."" below)
	bytecodes  (variable, bytes)
	trailer (variable, bytes)

The header is a SmallInteger (which in the 32-bit system has 31 bits, and in the 64-bit system, 61 bits) in the following format:

	(index 0)		15 bits:	number of literals (#numLiterals)
	(index 15)		  1 bit:	jit without counters - reserved for methods that have been optimized by Sista
	(index 16)		  1 bit:	has primitive
	(index 17)		  1 bit:	whether a large frame size is needed (#frameSize => either SmallFrame or LargeFrame)
	(index 18)		  6 bits:	number of temporary variables (#numTemps)
	(index 24)		  4 bits:	number of arguments to the method (#numArgs)
	(index 28)		  2 bits:	reserved for an access modifier (00-unused, 01-private, 10-protected, 11-public), although accessors for bit 29 exist (see #flag).
	sign bit:		  1 bit: selects the instruction set, >= 0 Primary, < 0 Secondary (#signFlag)

If the method has a primitive then the first bytecode of the method must be a callPrimitive: bytecode that encodes the primitive index.  This bytecode can encode a primitive index from 0 to 65535.

The trailer is an encoding of an instance of CompiledMethodTrailer.  It is typically used to encode the index into the source files array of the method's source, but may be used to encode other values, e.g. tempNames, source as a string, etc.  See the class CompiledMethodTrailer.

While there are disadvantages to this ""flat"" representation (it is impossible to add named instance variables to CompiledCode or its subclasses, but it is possible indirectly; see AdditionalMethodState) it is effective for interpreters.  It means that both bytecodes and literals can be fetched directly from a single method object, and that only one object, the method, must be saved and restored on activation and return.  A more natural representation, in which there are searate instance variables for the bytecode, and (conveniently) the literals, requires either much more work on activation and return setting up references to the literals and bytecodes, or slower access to bytecodes and literals, indirecting on each access.

The last literal of a CompiledCode object is reserved for special use by the kernel and/or the virtual machine.  In CompiledMethod instances it must either be the methodClassAssociation, used to implement super sends, or nil, if the method is anonymous. In CompiledBlock it is to be used for a reference to the enclosing method or block object.

By convention, the penultimate literal is reserved for special use by the kernel. In CompiledMethod instances it must either be the method selector, or an instance of AdditionalMethodState which holds the selector and any pragmas or properties in the method.  In CompiledBlock it is reserved for use for an AdditionalMethodState.

Note that super sends in CompiledBlock instances do not use a methodClass association, but expect a directed supersend bytecode, in which the method class (the subclass of the class in which to start the lookup) is a literal.  Logically when we switch to a bytecode set that supports the directed super send bytecode, and discard the old super send bytecodes, we can use the last literal to store the selector or the enclosing method/block or an AdditionalMethodState, and the AdditionalMethodState can hold the selector and/or the enclosing method/block.
"
Class {
	#name : #CompiledCode,
	#superclass : #ByteArray,
	#type : #compiledMethod,
	#classVars : [
		'LargeFrame',
		'PreferredBytecodeSetEncoderClass',
		'PrimaryBytecodeSetEncoderClass',
		'SecondaryBytecodeSetEncoderClass',
		'SmallFrame'
	],
	#category : #'Kernel-Methods'
}

{ #category : #'instance creation' }
CompiledCode class >> basicNew [
	^self newMethodViaNewError
]

{ #category : #'instance creation' }
CompiledCode class >> basicNew: size [
	^self newMethodViaNewError
]

{ #category : #constants }
CompiledCode class >> fullFrameSize [  "CompiledMethod fullFrameSize"
	^ LargeFrame
]

{ #category : #private }
CompiledCode class >> handleFailingFailingNewMethod: numberOfBytes header: headerWord [
	"This newMethod:header: gets sent after handleFailingBasicNew: has done a full
	 garbage collection and possibly grown memory.  If this basicNew: fails then the
	 system really is low on space, so raise the OutOfMemory signal.

	 Primitive. Answer an instance of this class with the number of indexable variables
	 specified by the argument, headerWord, and the number of bytecodes specified
	 by numberOfBytes.  Fail if this if the arguments are not Integers, or if numberOfBytes
	 is negative, or if the receiver is not a CompiledMethod class, or if there is not enough
	 memory available. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 79>
	"space must be low."
	OutOfMemory signal.
	"retry if user proceeds"
	^self newMethod: numberOfBytes header: headerWord
]

{ #category : #private }
CompiledCode class >> handleFailingNewMethod: numberOfBytes header: headerWord [
	"This newMethod:header: gets sent after newMethod:header: has failed
	 and allowed a scavenging garbage collection to occur.  The scavenging
	 collection will have happened as the VM is activating the (failing) basicNew:.
	 If handleFailingBasicNew: fails then the scavenge failed to reclaim sufficient
	 space and a global garbage collection is required.  Retry after garbage
	 collecting and growing memory if necessary.

	 Primitive. Answer an instance of this class with the number of indexable variables
	 specified by the argument, headerWord, and the number of bytecodes specified
	 by numberOfBytes.  Fail if this if the arguments are not Integers, or if numberOfBytes
	 is negative, or if the receiver is not a CompiledMethod class, or if there is not enough
	 memory available. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 79>
	| bytesRequested |
	bytesRequested := (headerWord bitAnd: 16rFFFF) + 1 * Smalltalk wordSize + numberOfBytes + 16.
	Smalltalk garbageCollect < bytesRequested ifTrue:
		[Smalltalk growMemoryByAtLeast: bytesRequested].
	"retry after global garbage collect and possible grow"
	^self handleFailingFailingNewMethod: numberOfBytes header: headerWord
]

{ #category : #'method encoding' }
CompiledCode class >> headerFlagForEncoder: anEncoder [
	"This allows subclasses for compiler variants such as the ScriptEncoder in EToys
	 to continue to function."
	(anEncoder isKindOf: PrimaryBytecodeSetEncoderClass) ifTrue:
		[^0].
	(anEncoder isKindOf: SecondaryBytecodeSetEncoderClass) ifTrue:
		[^SmallInteger minVal].
	self error: 'The encoder is not one of the two installed bytecode sets'
]

{ #category : #'class initialization' }
CompiledCode class >> initialize [    "CompiledMethod initialize"
	"Initialize class variables specifying the size of the temporary frame
	needed to run instances of me."

	SmallFrame := 16.	"Context range for temps+stack"
	LargeFrame := 56.
	PrimaryBytecodeSetEncoderClass ifNil:
		[PrimaryBytecodeSetEncoderClass := EncoderForV3PlusClosures].
	SecondaryBytecodeSetEncoderClass ifNil:
		[SecondaryBytecodeSetEncoderClass := EncoderForSistaV1]
]

{ #category : #'instance creation' }
CompiledCode class >> initializedInstance [
	"Don't even think of it.
	This low level machinery is not for general use."
	
	^nil
]

{ #category : #'class initialization' }
CompiledCode class >> installPrimaryBytecodeSet: aBytecodeEncoderSubclass [
	PrimaryBytecodeSetEncoderClass == aBytecodeEncoderSubclass ifTrue:
		[^self].
	(aBytecodeEncoderSubclass inheritsFrom: BytecodeEncoder) ifFalse:
		[self error: 'A bytecode set encoder is expected to be a subclass of BytecodeEncoder'].
	(self allSubInstances
			detect: [:m| m header >= 0 and: [m encoderClass ~~ aBytecodeEncoderSubclass]]
			ifNone: []) ifNotNil:
		[Warning signal: 'There are existing CompiledMethods with a different encoderClass.'].
	PrimaryBytecodeSetEncoderClass := aBytecodeEncoderSubclass
]

{ #category : #'class initialization' }
CompiledCode class >> installSecondaryBytecodeSet: aBytecodeEncoderSubclass [
	PrimaryBytecodeSetEncoderClass == aBytecodeEncoderSubclass ifTrue:
		[^self].
	(aBytecodeEncoderSubclass inheritsFrom: BytecodeEncoder) ifFalse:
		[self error: 'A bytecode set encoder is expected to be a subclass of BytecodeEncoder'].
	(self allSubInstances
			detect: [:m| m header < 0 and: [m encoderClass ~~ aBytecodeEncoderSubclass]]
			ifNone: []) ifNotNil:
		[Warning signal: 'There are existing CompiledMethods with a different encoderClass.'].
	SecondaryBytecodeSetEncoderClass := aBytecodeEncoderSubclass
]

{ #category : #constants }
CompiledCode class >> maxNumLiterals [
	"The current header format and the VM's interpretation of it allows for a maximum of 32767 literals."
	^32767
]

{ #category : #'method encoding' }
CompiledCode class >> multipleBytecodeSetsActive: aBoolean [
	"Inform the VM when multiple bytecode sets, typically the Sista bytecodes
	in addition to the traditional V3 bytecode set, are now in use is this image.
	The VM may use this information to update the image format number when
	saving the image to the file system."

	<primitive: 'primitiveMultipleBytecodeSetsActive'>

]

{ #category : #'instance creation' }
CompiledCode class >> new [
	^self newMethodViaNewError
]

{ #category : #'instance creation' }
CompiledCode class >> new: size [
	^self newMethodViaNewError
]

{ #category : #'instance creation' }
CompiledCode class >> newBytes: numberOfBytes trailerBytes: trailer nArgs: nArgs nTemps: nTemps nStack: stackSize nLits: nLits primitive: primitiveIndex [
	"Answer an instance of me. The header is specified by the message 
	 arguments. The remaining parts are not as yet determined."
	| method pc |
	nArgs > 15 ifTrue:
		[^self error: 'Cannot compile -- too many arguments'].
	nTemps > 63 ifTrue:
		[^self error: 'Cannot compile -- too many temporary variables'].	
	nLits > 32767 ifTrue:
		[^self error: 'Cannot compile -- too many literals'].

	method := trailer
				createMethod: numberOfBytes
				class: self
				header:    (nArgs bitShift: 24)
						+ (nTemps bitShift: 18)
						+ ((nTemps + stackSize) > SmallFrame ifTrue: [1 bitShift: 17] ifFalse: [0])
						+ nLits
						+ (primitiveIndex > 0 ifTrue: [1 bitShift: 16] ifFalse: [0]).
	primitiveIndex > 0 ifTrue:
		[pc := method initialPC.
		 method
			at: pc + 0 put: method encoderClass callPrimitiveCode;
			at: pc + 1 put: (primitiveIndex bitAnd: 16rFF);
			at: pc + 2 put: (primitiveIndex bitShift: -8)].
	^method
]

{ #category : #'instance creation' }
CompiledCode class >> newBytes: numberOfBytes trailerBytes: trailer nArgs: nArgs nTemps: nTemps nStack: stackSize nLits: nLits primitive: primitiveIndex flag: flag [
	"Answer an instance of me. The header is specified by the message 
	 arguments. The remaining parts are not as yet determined."
	| method pc |
	nArgs > 15 ifTrue:
		[^self error: 'Cannot compile -- too many arguments'].
	nTemps > 63 ifTrue:
		[^self error: 'Cannot compile -- too many temporary variables'].	
	nLits > 32767 ifTrue:
		[^self error: 'Cannot compile -- too many literals'].

	method := trailer
				createMethod: numberOfBytes
				class: self
				header:    (nArgs bitShift: 24)
						+ (nTemps bitShift: 18)
						+ ((nTemps + stackSize) > SmallFrame ifTrue: [1 bitShift: 17] ifFalse: [0])
						+ nLits
						+ (primitiveIndex > 0 ifTrue: [1 bitShift: 16] ifFalse: [0])
						+ (flag ifTrue: [1 bitShift: 29] ifFalse: [0]).
	primitiveIndex > 0 ifTrue:
		[pc := method initialPC.
		 method
			at: pc + 0 put: method encoderClass callPrimitiveCode;
			at: pc + 1 put: (primitiveIndex bitAnd: 16rFF);
			at: pc + 2 put: (primitiveIndex bitShift: -8)].
	^method
]

{ #category : #'instance creation' }
CompiledCode class >> newFrom: aCompiledMethod [
	"Clone the argument, aCompiledMethod"
	| inst |
	"CompiledMethod newFrom: CompiledMethod class >> #newFrom:"
	inst := self newMethod: aCompiledMethod basicSize - aCompiledMethod initialPC + 1
				header: aCompiledMethod header.
	1 to: aCompiledMethod numLiterals do:
		[:index|
		inst literalAt: index put: (aCompiledMethod literalAt: index)].
	aCompiledMethod initialPC to: aCompiledMethod size do:
		[:index |
		inst at: index put: (aCompiledMethod at: index)].
	inst postCopy.
	^inst
]

{ #category : #'instance creation' }
CompiledCode class >> newInstanceFrom: oldInstance variable: variable size: instSize map: map [
	"Create a new instance of the receiver based on the given old instance.
	The supplied map contains a mapping of the old instVar names into
	the receiver's instVars"
	| new |
	new := self newFrom: oldInstance.
	1 to: instSize do: 
		[:offset |  (map at: offset) > 0 ifTrue:
			[new instVarAt: offset
					put: (oldInstance instVarAt: (map at: offset))]].
	^new
]

{ #category : #'instance creation' }
CompiledCode class >> newMethod: numberOfBytes header: headerWord [
	"Primitive. Answer an instance of me. The number of literals (and other 
	 information) is specified by the headerWord (see my class comment).
	 The first argument specifies the number of fields for bytecodes in the
	 method. Fail if either argument is not a SmallInteger, or if numberOfBytes
	 is negative, or if memory is low. Once the header of a method is set by
	 this primitive, it cannot be changed to change the number of literals.
	 Essential. See Object documentation whatIsAPrimitive."

	<primitive: 79 error: ec>
	ec == #'insufficient object memory' ifTrue:
		[^self handleFailingNewMethod: numberOfBytes header: headerWord].
	^self primitiveFailed
]

{ #category : #private }
CompiledCode class >> newMethodViaNewError [

	^self error: self class name, 's may only be created with newMethod:header:'
]

{ #category : #preferences }
CompiledCode class >> preferredBytecodeSetEncoderClass [
	<preference: 'Preferred bytecode set encoder class'
	  category: 'Compiler'
	  description: 'The system supports up to two bytecode sets; select the preferred one to use here.  See CompiledCode class variables PrimaryBytecodeSetEncoderClass and SecondaryBytecodeSetEncoderClass.'
	  type: #Class>
	^PreferredBytecodeSetEncoderClass ifNil: [PrimaryBytecodeSetEncoderClass]
]

{ #category : #preferences }
CompiledCode class >> preferredBytecodeSetEncoderClass: aBytecodeEncoderSubclass [
	"Set the class that determines the bytecode set used to compile methods with.
			[| nPrimary nSecondary |
			nPrimary := nSecondary := 0.
			self allSubInstancesDo:
				[:cm|
				cm header >= 0
					ifTrue: [nPrimary := nPrimary + 1]
					ifFalse: [nSecondary := nSecondary + 1]].
			{nPrimary. nSecondary}]"
	| nPrimary nSecondary |
	self assert: (aBytecodeEncoderSubclass includesBehavior: BytecodeEncoder).
	(aBytecodeEncoderSubclass == PrimaryBytecodeSetEncoderClass
	 or: [aBytecodeEncoderSubclass == SecondaryBytecodeSetEncoderClass]) ifTrue:
		[PreferredBytecodeSetEncoderClass := aBytecodeEncoderSubclass.
		 ^self].
	nPrimary := nSecondary := 0.
	self allSubInstancesDo:
		[:cm|
		 cm header >= 0
			ifTrue: [nPrimary := nPrimary + 1]
			ifFalse: [nSecondary := nSecondary + 1]].
	nPrimary = 0 ifTrue:
		[self installPrimaryBytecodeSet: aBytecodeEncoderSubclass.
		 ^self preferredBytecodeSetEncoderClass: aBytecodeEncoderSubclass].
	nSecondary = 0 ifTrue:
		[self installSecondaryBytecodeSet: aBytecodeEncoderSubclass.
		 ^self preferredBytecodeSetEncoderClass: aBytecodeEncoderSubclass].
	self error: 'Cannot set preferred bytecode set.  Both of the current sets appear to be in use.'
]

{ #category : #'method encoding' }
CompiledCode class >> primaryBytecodeSetEncoderClass [
	^PrimaryBytecodeSetEncoderClass
]

{ #category : #scanning }
CompiledCode class >> scanBlocksForLiteral: aLiteral do: aBinaryBlock [
	"Evaluate aBinaryBlock with the literal scanners for aLiteral (which will be nil
	 if there are no special bytecodes that access aLiteral), and answer its value."
	^aBinaryBlock
		value: (PrimaryBytecodeSetEncoderClass scanBlockOrNilForLiteral: aLiteral)
		value: (SecondaryBytecodeSetEncoderClass scanBlockOrNilForLiteral: aLiteral)
]

{ #category : #'method encoding' }
CompiledCode class >> secondaryBytecodeSetEncoderClass [
	^SecondaryBytecodeSetEncoderClass
]

{ #category : #constants }
CompiledCode class >> smallFrameSize [

	^ SmallFrame
]

{ #category : #'method encoding' }
CompiledCode class >> useSista: useSistaEncoder [
	"Switch to or from the Sista bytecode encoder, and recompile the system
	using that encoder. Assumes that Compiler recompileAll is working for the
	existing system. Assumes that the currently available primary and secondary
	bytecode encoders are EncoderForV3PlusClosures and EncoderForSistaV1.
	This is a convenience method that must be updated as the available encoders
	are changed."

	"CompiledCode useSista: true"
	"CompiledCode useSista: false"

	| standardEncoder sistaEncoder activeEncoder |
	standardEncoder := Smalltalk classNamed: #EncoderForV3PlusClosures.
	sistaEncoder := Smalltalk classNamed: #EncoderForSistaV1.
	activeEncoder := self preferredBytecodeSetEncoderClass.
	useSistaEncoder
		ifTrue: [sistaEncoder ifNil: [self error: 'EncoderForSistaV1 not present in this image'].
			self preferredBytecodeSetEncoderClass: sistaEncoder.
			activeEncoder ~= sistaEncoder
				ifTrue: [(Smalltalk classNamed: #Compiler) recompileAll.
			self multipleBytecodeSetsActive: true "VM should support Sista plus V3" ]]
		ifFalse: [standardEncoder ifNil: [self error: 'EncoderForV3PlusClosures not present in this image'].
			self preferredBytecodeSetEncoderClass: standardEncoder.
			activeEncoder ~= standardEncoder
				ifTrue: [(Smalltalk classNamed: #Compiler) recompileAll.
			self multipleBytecodeSetsActive: false "VM needs to support V3 only" ]].


]

{ #category : #comparing }
CompiledCode >> = aMethod [
	"Answer whether the receiver implements the same code as the argument, aMethod.
	 Here ``same code'' means that if the receiver's source is compiled with the same
	 compiler it should produce the same sequence of bytecodes and literals, same
	 trailer and same properties.  Hence this definition of #= (only one of many plausible
	 definitions) can be used to quickly identify changes in the compiler's output."
	self == aMethod ifTrue:
		[^true].
	(aMethod isCompiledCode
	 and: [self size = aMethod size
	 and: [self header = aMethod header]]) ifFalse:"N.B. includes numLiterals comparison."
		[^false].
	self initialPC to: self endPC do:
		[:i | (self at: i) = (aMethod at: i) ifFalse: [^false]].
	^self hasSameLiteralsAs: aMethod
]

{ #category : #scanning }
CompiledCode >> abstractBytecodeMessageAt: pc [
	"Answer the abstract bytecode message at pc in the receiver."
	^[(InstructionStream new method: self pc: pc) interpretNextInstructionFor: nil]
		on: MessageNotUnderstood
		do: [:ex| ex message]
]

{ #category : #scanning }
CompiledCode >> abstractBytecodeMessagesAndPCs [
	"Answer the receiver's sequence of abstract bytecodes as a sequence of tuples of bytecode message and pc."
	"(CompiledCode >> #abstractBytecodeMessagesAndPCs) abstractBytecodeMessagesAndPCs"
	| msgs initial endpc pc scanner encoderClass |
	scanner := InstructionStream new method: self pc: (initial := self initialPC).
	msgs := OrderedCollection new: (endpc  := self endPC) - initial.
	encoderClass := self encoderClass.
	[(pc := scanner pc) <= endpc] whileTrue:
		"i.e. nil will not understand any message and so the exception block will collect all of them."
		[[encoderClass interpretNextInstructionFor: nil in: scanner]
			on: MessageNotUnderstood
			do: [:ex| msgs addLast: { ex message. pc }]].
	^msgs
]

{ #category : #scanning }
CompiledCode >> abstractBytecodeMessagesDo: aBlock [
	"Evaluate aBlock with the sequence of abstract bytecodes in the receiver"
	self abstractBytecodeMessagesFrom: self initialPC
		to: self endPC
		do: aBlock

	"| msgs |
	 msgs := OrderedCollection new.
	 CompiledCode >> #abstractBytecodeMessagesFrom:to: abstractBytecodeMessagesDo:
		[:msg| msgs addLast: msg selector].
	 msgs"
]

{ #category : #scanning }
CompiledCode >> abstractBytecodeMessagesFrom: startpc to: endpc do: aBlock [
	"Evaluate aBlock with the sequence of abstract bytecodes from startpc through endpc in the receiver"
	| scanner encoderClass |
	scanner := InstructionStream new method: self pc: startpc.
	encoderClass := self encoderClass.
	[scanner pc <= endpc] whileTrue:
		"i.e. nil will not understand any message and so the exception block will collect all of them."
		[[encoderClass interpretNextInstructionFor: nil in: scanner]
			on: MessageNotUnderstood
			do: [:ex| aBlock value: ex message]]

	"| m msgs |
	 msgs := OrderedCollection new.
	 (m := CompiledCode >> #abstractBytecodeMessagesFrom:to:do:)
		abstractBytecodeMessagesFrom: m initialPC
		to: m endPC
		do: [:msg| msgs add: msg selector].
	 msgs"
]

{ #category : #literals }
CompiledCode >> allLiterals [
	"Skip compiled-code objects. Keep literal arrays, bindings, etc."
	
	^ Array streamContents: [:result |
		self allLiteralsDo: [:literal | result nextPut: literal]]
]

{ #category : #literals }
CompiledCode >> allLiteralsDo: aBlock [
	"Enumerate all literals thoroughly. Follow nested instances of CompiledCode. Do not treat compiled code as literals here."
	
	self codeLiteralsDo: [:compiledCode | compiledCode literalsDo: [:literal |
		literal isCompiledCode ifFalse: [literal allLiteralsDo: aBlock] ]].

	"Enumerate special selectors."
	self flag: #todo.
	
	"Enumerate special literals such as true and false."
	self flag: #todo.
]

{ #category : #converting }
CompiledCode >> asString [

	^self printString
]

{ #category : #accessing }
CompiledCode >> at: index ifAbsent: exceptionBlock [ 
	"Answer the element at my position index. If I do not contain an element 
	at index, answer the result of evaluating the argument, exceptionBlock."

	(index <= self size  and: [self initialPC <= index]) ifTrue: [^self at: index].
	^exceptionBlock value
]

{ #category : #accessing }
CompiledCode >> bytecodeSetName [
	^self encoderClass name copyReplaceAll: 'EncoderFor' with: ''
]

{ #category : #accessing }
CompiledCode >> clearFlag [
	"Clear the user-level flag bit"

	self objectAt: 1 put: (self header bitAnd: (1 << 29) bitInvert)
]

{ #category : #accessing }
CompiledCode >> clearSignFlag [
	"Clear the sign flag bit.  The sign flag bit may be
	 used by the VM to select an alternate bytecode set."

	self signFlag ifTrue:
		[self objectAt: 1 put: self header - SmallInteger minVal]
]

{ #category : #literals }
CompiledCode >> codeLiterals [

	^ Array streamContents: [:stream |
		self codeLiteralsDo: [:compiledCode | stream nextPut: compiledCode]]
]

{ #category : #literals }
CompiledCode >> codeLiteralsDo: aBlock [
	"Enumerate all literals that represent instances of CompiledCode. This is especially required for SistaV1."
	
	aBlock value: self.
	
	self literalsDo: [:literal | literal isCompiledCode ifTrue: [
		literal codeLiteralsDo: aBlock]].
]

{ #category : #copying }
CompiledCode >> copyFrom: anotherObject [
	"Copy to myself all instance variables I have in common with anotherObject.
	 This is dangerous because it ignores an object's control over its own inst vars."

	<primitive: 168>
	anotherObject isCompiledCode
		ifTrue:
			[1 to: self numLiterals do:
				[:i| self literalAt: i put: (anotherObject literalAt: i)]]
		ifFalse:
			[1 to: self numLiterals do:
				[:i| self literalAt: i put: (anotherObject at: i)]].
	self initialPC to: (self basicSize min: anotherObject basicSize) do:
		[:i|
		 self basicAt: i put: (anotherObject basicAt: i)]
]

{ #category : #decompiling }
CompiledCode >> decompile [
	"Return the decompiled parse tree that represents self"

	|  class selector |
	class := self methodClass ifNil: [Object].
	selector := self selector ifNil: [self defaultSelector].
	^class decompilerClass new decompile: selector in: class method: self methodForDecompile
]

{ #category : #decompiling }
CompiledCode >> decompileWithTemps [
	"Answer the decompiled parse tree that represents self, but with the temp names obtained
	 either by compiling the source code, or directly if the method has temps in its trailer."

	^self homeMethod decompileWithTemps
]

{ #category : #accessing }
CompiledCode >> encoderClass [
	"Answer the encoder class that encoded the bytecodes in this method.
	 The sign flag bit is used by the VM to select a bytecode set.  This formulation
	 may seem odd but this has to be fast, so no property probe unless needed."

	^self header >= 0
		ifTrue: 
			[PrimaryBytecodeSetEncoderClass]
		ifFalse:
			[PrimaryBytecodeSetEncoderClass == SecondaryBytecodeSetEncoderClass
				ifTrue: "Support for testing prior to installing another set"
					[(self propertyValueAt: #encoderClass) ifNil: [SecondaryBytecodeSetEncoderClass]]
				ifFalse:
					[SecondaryBytecodeSetEncoderClass]]
]

{ #category : #accessing }
CompiledCode >> endPC [
	"Answer the index of the last bytecode."
	^ self trailer endPC

]

{ #category : #accessing }
CompiledCode >> flag [
	"Answer the user-level flag bit"

	^((self header bitShift: -29) bitAnd: 1) = 1
]

{ #category : #cleaning }
CompiledCode >> flushCache [
	"Tell the virtual machine to remove all references to this method from its method
	 lookup cache(s), if it has them. This is provided for backwards compatibility.
	 When a method is redefined (added to, removed from, or replaced in, a method
	 dictionary) then Symbol flushCache should be used. This is because adding or
	 removing a method may alter the method that a given selector should invoke
	 for methods other than the receiver.  For example, if a subclass inherits a
	 method and this is overridden, flushing the new method will not flush the existing
	 method.

	 If a method is modified in-place (for example, some bytecode is replaced by
	 bytecode that effects a breakpoint) then voidCogVMState should be used."

	<primitive: 116>
]

{ #category : #accessing }
CompiledCode >> frameSize [
	"Answer the size of temporary frame needed to run the receiver."
	"NOTE:  Versions 2.7 and later use two sizes of contexts."

	(self header noMask: 16r20000)
		ifTrue: [^ SmallFrame]
		ifFalse: [^ LargeFrame]

]

{ #category : #'source code management' }
CompiledCode >> getSource [
	^ self getSourceFor: self selector in:self methodClass.
]

{ #category : #'source code management' }
CompiledCode >> getSourceFor: selector in: class [
	"Retrieve or reconstruct the source code for this method."

	^self method getSourceFor: selector in: class
]

{ #category : #literals }
CompiledCode >> hasLiteral: aLiteral [
	"Overwrite this method to invoke the bytecode encoder scanner explicitely. This might be removed if there would be a way to enumerate special literals in a compiled-code object. See #allLiteralsDo:."

	^ self
		hasLiteral: aLiteral
		scanForSpecial: (BytecodeEncoder canBeSpecialLiteral: aLiteral)
]

{ #category : #literals }
CompiledCode >> hasLiteral: aLiteral scanForSpecial: aBoolean [
	"Like #hasLiteral: but can scan for encoder-specific special literals. Not that scanning has a noticeable performance impact."

	| scanBlock |
	(super hasLiteral: aLiteral) ifTrue: [^ true].
	
	aBoolean ifFalse: [^ false].

	scanBlock := self class
		scanBlocksForLiteral: aLiteral
		do: [:primaryScanner :secondaryScanner |
			"E.g., scanner for SistaV1 or scanner for V3PlusClosures"
			self signFlag ifTrue: [secondaryScanner] ifFalse: [primaryScanner]].
	
	self codeLiteralsDo: [:compiledCode |
		(compiledCode scanFor: scanBlock) ifTrue: [^ true]].

	^ false
]

{ #category : #testing }
CompiledCode >> hasMethodReturn [
	"Answer whether the receiver has a method-return ('^') in its code."

	| scanner |
	self codeLiteralsDo: [:compiledCode | 
		scanner := InstructionStream on: compiledCode.
		(scanner scanFor: [:x | (scanner willReturn
				and: [scanner willBlockReturn not])
				"and: [scanner willReturnTopFromMethod not]" "-> Not supported in EncoderForSistaV1"])
			ifTrue: [^ true]].
	^ false
]

{ #category : #accessing }
CompiledCode >> hasNoCountersFlag [
	"The Cog Sista VMs interpret bit 16 of the method header as suppressing the generation of performance counters."
	^self header anyMask: 16r8000
]

{ #category : #comparing }
CompiledCode >> hasSameLiteralsAs: aMethod [
	"Answer whether the receiver has the same sequence of literals as the argument."
	self subclassResponsibility
]

{ #category : #comparing }
CompiledCode >> hash [
	"CompiledMethod>>#= compares code, i.e. same literals and same bytecode.
	 So we look at the header, methodClass and some bytes between initialPC and endPC,
	 but /not/ the selector because the equal method does not compare selectors.
	 Note that we must override ByteArray>hash which looks at all bytes of the receiver.
	 Using bytes from the pointer part of a COmpiledmethod can lead to a variable hash
	 if and when when the GC moves literals in the receiver."
	| initialPC endPC hash |
	initialPC := self initialPC.
	endPC := self endPC.
	hash := self species hash + self header + initialPC + endPC + self methodClass hash bitAnd: 16rFFFFFFF.
	"sample approximately 20 bytes"
	initialPC to: endPC by: (endPC - initialPC // 20 max: 1) do:
		[:i| hash := hash + (self at: i)].
	^hash

	"(CompiledMethod>>#hash) hash"
]

{ #category : #literals }
CompiledCode >> header [
	"Answer the word containing the information about the form of the 
	 receiver and the form of the context needed to run the receiver.

		sign:1 29-28:accessModifier 27-24:numArgs 23-18:numTemps 17:largeFrameFlag 16:hasPrimitive 15:isOptimized 14-0:numLits"

	^self objectAt: 1
]

{ #category : #printing }
CompiledCode >> headerDescription [
	"Answer a description containing the information about the form of the
	 receiver and the form of the context needed to run the receiver."

	self subclassResponsibility
]

{ #category : #accessing }
CompiledCode >> homeMethod [
	"Answer the home method associated with the receiver."

	^self subclassResponsibility
]

{ #category : #accessing }
CompiledCode >> initialPC [
	"Answer the program counter for the receiver's first bytecode."

	^ (self numLiterals + 1) * Smalltalk wordSize + 1

]

{ #category : #testing }
CompiledCode >> isCompiledBlock [
	^false
]

{ #category : #testing }
CompiledCode >> isCompiledCode [
	^true
]

{ #category : #testing }
CompiledCode >> isCompiledMethod [
	^false
]

{ #category : #testing }
CompiledCode >> isQuick [

	self subclassResponsibility.
]

{ #category : #literals }
CompiledCode >> literalAt: index [ 
	"Answer the literal indexed by the argument."

	^self objectAt: index + 1
]

{ #category : #literals }
CompiledCode >> literalAt: index put: value [ 
	"Replace the literal indexed by the first argument with the second 
	argument. Answer the second argument."

	^self objectAt: index + 1 put: value
]

{ #category : #literals }
CompiledCode >> literals [
	
	^ Array streamContents: [:result |
		self literalsDo: [:lit | result nextPut: lit]]
]

{ #category : #literals }
CompiledCode >> literalsDo: aBlock [
	"Evaluate aBlock for each of the literals referenced by the receiver. Note that this (raw) enumeration addresses *all* objects stored *after* the method header and *before* the first byte code. If you require a deep and meaningful enumeration of literals use #allLiteralsDo: or #codeLiteralsDo:."
	
	1 to: self numLiterals do: [:index |
		aBlock value: (self literalAt: index)].
]

{ #category : #printing }
CompiledCode >> longPrintOn: aStream [
	"List of all the byte codes in a method with a short description of each" 

	self longPrintOn: aStream indent: 0
]

{ #category : #scanning }
CompiledCode >> messages [
	"Answer a Set of all the message selectors sent by this method."

	| result |
	result := Set new.
	self selectorsDo: [:selector | result add: selector].
	^ result
]

{ #category : #scanning }
CompiledCode >> messagesDo: workBlock [
	"Evaluate aBlock with all the message selectors sent by me. Duplicate seletors are possible."

	"If anything should be deprecated it is messagesDo:; it can be an extension in AST/Refactoring.
	 This method enumerates over selectors, not messages.  c.f. Behavior>>selectorsDo: etc"
	^self selectorsDo: workBlock
]

{ #category : #scanning }
CompiledCode >> messagesSequence [
	"Answer a sequence of all the message selectors sent by this method in the order they are sent. Unlike #messages this may include duplicates. Note that both the sources and the decompiled sources might suggest different results. The returned information reflect the actual bytecode."

	^ Array streamContents: [:result |
		self selectorsDo: [:selector | result nextPut: selector]]
]

{ #category : #accessing }
CompiledCode >> method [
	"Answer the home method associated with the receiver."

	^self subclassResponsibility
]

{ #category : #accessing }
CompiledCode >> methodClass [
	"Answer the class that I am installed in."
	^self subclassResponsibility
]

{ #category : #'initialize-release' }
CompiledCode >> needsFrameSize: newFrameSize [
	"Set the largeFrameBit to accomodate the newFrameSize"
	| largeFrameBit header |
	largeFrameBit := 16r20000.
	(self numTemps + newFrameSize) > LargeFrame ifTrue:
		[^ self error: 'Cannot compile -- stack including temps is too deep'].
	header := self objectAt: 1.
	(header bitAnd: largeFrameBit) ~= 0
		ifTrue: [header := header - largeFrameBit].
	self objectAt: 1 put: header
			+ ((self numTemps + newFrameSize) > SmallFrame
					ifTrue: [largeFrameBit]
					ifFalse: [0])
]

{ #category : #accessing }
CompiledCode >> numArgs [
	"Answer the number of arguments the receiver takes."

	^ (self header bitShift: -24) bitAnd: 16r0F
]

{ #category : #accessing }
CompiledCode >> numLiterals [
	"Answer the number of literals used by the receiver."
	^self header bitAnd: 16r7FFF
]

{ #category : #accessing }
CompiledCode >> numTemps [
	"Answer the number of temporary variables used by the receiver."
	
	^ (self header bitShift: -18) bitAnd: 16r3F
]

{ #category : #literals }
CompiledCode >> objectAt: index [ 
	"Primitive. Answer the method header (if index=1) or a literal (if index 
	>1) from the receiver. Essential. See Object documentation 
	whatIsAPrimitive."

	<primitive: 68>
	self primitiveFailed
]

{ #category : #literals }
CompiledCode >> objectAt: index put: value [ 
	"Primitive. Store the value argument into a literal in the receiver. An 
	index of 2 corresponds to the first literal. Fails if the index is less than 2 
	or greater than the number of literals. Answer the value as the result. 
	Normally only the compiler sends this message, because only the 
	compiler stores values in CompiledMethods. Essential. See Object 
	documentation whatIsAPrimitive."

	<primitive: 69>
	self primitiveFailed
]

{ #category : #tracing }
CompiledCode >> outboundPointersDo: aBlock [

	| numLiterals |
	aBlock value: self class.
	numLiterals := self numLiterals.
	1 to: numLiterals do: [:i | aBlock value: (self literalAt: i)]
]

{ #category : #scanning }
CompiledCode >> pcPreviousTo: thePC [
	"Answer the pc of the bytecode before the bytecode at thePC."
	| pc prevPc byte encoderClass |
	thePC > self endPC ifTrue: [^self endPC].
	pc := self initialPC.
	encoderClass := self encoderClass.
	[pc < thePC] whileTrue:
		[byte := self at: (prevPc := pc).
		 [pc := pc + (encoderClass bytecodeSize: byte).
		  encoderClass isExtension: byte] whileTrue:
			[byte := self at: pc]].
	^prevPc
]

{ #category : #printing }
CompiledCode >> printOn: aStream [ 
	"Overrides method inherited from the byte arrayed collection."
	aStream nextPut: $(.
	self printReferenceOn: aStream.
	aStream space; nextPut: $".
	self printNameOn: aStream.
	aStream nextPut: $(;
		 print: self identityHash;
		 nextPut: $);
		 nextPut: $";
		 nextPut: $)
]

{ #category : #printing }
CompiledCode >> printReferenceOn: aStream [ 
	"Print a string that can be used to access the currently installed method."
	aStream print: self methodClass;
		 nextPutAll: '>>';
		 nextPutAll: self selector storeString
]

{ #category : #accessing }
CompiledCode >> protocol [
	^self methodClass ifNotNil:
		[:class|
		self selector ifNotNil:
			[:selector|
			class whichCategoryIncludesSelector: selector]]
]

{ #category : #'file in\/out' }
CompiledCode >> readDataFrom: aDataStream size: varsOnDisk [
	"Fill in my fields.  My header and number of literals are already installed.  Must read both objects for the literals and bytes for the bytecodes."

	self error: 'Must use readMethod'.
]

{ #category : #printing }
CompiledCode >> reference [
	^ String streamContents: [ : stream | self printReferenceOn: stream ]
]

{ #category : #accessing }
CompiledCode >> referredInstVars [
	"Answer a Set of the inst var names the receiver accesses."
	| allInstVarNames instVarNames |
	allInstVarNames := self methodClass allInstVarNames.
	self isReturnField ifTrue:
		[^Set with: (allInstVarNames at: self returnField + 1)].
	instVarNames := Set new.
	self abstractBytecodeMessagesDo:
		[:msg|
		(#(#popIntoReceiverVariable:
		    #pushReceiverVariable:
		    #storeIntoReceiverVariable:) includes: msg selector) ifTrue:
			[instVarNames add: (allInstVarNames at: msg argument + 1)]].
	^instVarNames

	"Dictionary newFromPairs: (Point selectors collect: [:s| { s. (Point >> s) referredInstVars}])"
]

{ #category : #scanning }
CompiledCode >> scanFor: byteOrClosure [
	"Answer whether the receiver contains the argument as a bytecode, if it is a number,
	 or evaluates to true if a block.  If a block it can take from one to four bytes."
	| s end |
	^(s := InstructionStream on: self)
		scanFor: (byteOrClosure isBlock
					ifTrue: [byteOrClosure numArgs caseOf: {
							[1] -> [byteOrClosure].
							[2] -> [[:byte| byteOrClosure value: byte value: s secondByte]].
							[3] -> [end := self endPC - 2.
									[:byte|
									s pc <= end
									and: [byteOrClosure
											value: byte
											value: s secondByte
											value: s thirdByte]]].
							[4] -> [end := self endPC - 3.
									[:byte|
									s pc <= end
									and: [byteOrClosure
											value: byte
											value: s secondByte
											value: s thirdByte
											value: s fourthByte]]] }]
					ifFalse: [[:instr | instr = byteOrClosure]])
"
SystemNavigation default browseAllSelect: [:m | m scanFor: 134]
"
]

{ #category : #accessing }
CompiledCode >> scanner [

	^ InstructionStream on: self
]

{ #category : #accessing }
CompiledCode >> selector [
	^self subclassResponsibility
]

{ #category : #scanning }
CompiledCode >> selectorsDo: workBlock [
	"Evaluate aBlock with all the message selectors sent by me. Duplicate selectors are possible."

	| encoderClass |
	self isQuick ifTrue: [^self].
	encoderClass := self encoderClass.
	self codeLiteralsDo:
		[:compiledCode | | scanner limit |
		limit := compiledCode size - 1.
		(scanner := InstructionStream on: compiledCode) scanFor:
			[:byte| | selector |
			(selector := scanner selectorToSendOrSelf) ~~ scanner ifTrue:
				[workBlock value: selector].
			((encoderClass isExtension: byte)
			 and: [scanner pc < limit]) ifTrue:
				[scanner pc: scanner pc + (encoderClass bytecodeSize: (compiledCode at: scanner pc + 2))].
			false "keep scanning"]]
]

{ #category : #testing }
CompiledCode >> sendsMessage: aSelector [
	"eem: this should be deprecated. This method does not check if a method sends a message;
	 it checks if a method sends a message with a particular selector."
	self flag: #todo.
	self messagesDo: [:selector |
		selector = aSelector ifTrue: [^ true]].
	^ false
]

{ #category : #testing }
CompiledCode >> sendsSelector: aSelector [ 
	"Answer if the receiver sends a message whose selector is aSelector."

	self selectorsDo:
		[:selector | selector = aSelector ifTrue: [^true]].
	self flag: #todo. "The use of #= instead of #== is extremely dubious, and IMO erroneous. eem 2/18/2020"
	^false
]

{ #category : #testing }
CompiledCode >> sendsToSuper [
	"Answer whether the receiver sends any message to super."

	| scanner |
	self codeLiteralsDo: [:compiledCode | 
		scanner := InstructionStream on: compiledCode.
		(scanner scanFor: (self encoderClass superSendScanBlockUsing: scanner))
			ifTrue: [^ true]].
	^ false
]

{ #category : #accessing }
CompiledCode >> setHasNoCountersFlag [
	"The Cog Sista VMs interpret bit 16 of the method header as suppressing the generation of performance counters."
	self objectAt: 1 put: (self header bitOr: 16r8000)
]

{ #category : #accessing }
CompiledCode >> setSignFlag [
	"Set the sign flag bit.  The sign flag bit may be
	 used by the VM to select an alternate bytecode set."

	self signFlag ifFalse:
		[self objectAt: 1 put: self header + SmallInteger minVal]
]

{ #category : #accessing }
CompiledCode >> signFlag [
	"Answer the sign flag bit.  The sign flag bit may be
	 used by the VM to select an alternate bytecode set."

	^self header < 0
]

{ #category : #'file in\/out' }
CompiledCode >> storeDataOn: aDataStream [
	"Store myself on a DataStream.  I am a mixture of objects and raw data bytes.  Only use this for blocks.  Normal methodDictionaries should not be put out using ReferenceStreams.  Their fileOut should be attached to the beginning of the file."

	| byteLength lits |
	"No inst vars of the normal type"
	byteLength := self basicSize.
	aDataStream
		beginInstance: self class
		size: byteLength.
	lits := self numLiterals + 1.	"counting header"
	1 to: lits do:
		[:ii | aDataStream nextPut: (self objectAt: ii)].
	self initialPC to: byteLength do:
		[:ii | aDataStream byteStream nextPut: (self basicAt: ii)].
			"write bytes straight through to the file"
]

{ #category : #printing }
CompiledCode >> storeOn: aStream [
	| noneYet |
	aStream nextPutAll: '(('.
	aStream nextPutAll: self class name.
	aStream nextPutAll: ' newMethod: '.
	aStream store: self size - self initialPC + 1.
	aStream nextPutAll: ' header: '.
	aStream store: self header.
	aStream nextPut: $).
	noneYet := self storeElementsFrom: self initialPC to: self endPC on: aStream.
	1 to: self numLiterals do:
		[:index |
		noneYet
			ifTrue: [noneYet := false]
			ifFalse: [aStream nextPut: $;].
		aStream nextPutAll: ' literalAt: '.
		aStream store: index.
		aStream nextPutAll: ' put: '.
		aStream store: (self literalAt: index)].
	noneYet ifFalse: [aStream nextPutAll: '; yourself'].
	aStream nextPut: $)
]

{ #category : #printing }
CompiledCode >> symbolic [
	"Answer a String that contains a list of all the byte codes in a method 
	with a short description of each."

	| aStream |
	aStream := WriteStream on: (String new: 1000).
	self longPrintOn: aStream.
	^aStream contents
]

{ #category : #printing }
CompiledCode >> symbolicLinesDo: aBlock [
	"Evaluate aBlock with each of the lines in the symbolic output."

	| aStream pc |
	aStream := (String new: 64) writeStream.
	self isQuick ifTrue:
		[self longPrintOn: aStream.
		 aBlock value: 0 value: aStream contents.
		 ^self].

	self primitive ~= 0 ifTrue:
		[self printPrimitiveOn: aStream.
		 aBlock value: 1 value: aStream contents.
		 aStream resetContents].

	pc := self initialPC.
	(InstructionPrinter on: self)
		indent: 0;
		printPC: false; "explorer provides pc anyway"
		printInstructionsOn: aStream
		do:	[:printer :scanner :stream| | line index |
			line := stream contents allButLast.
			(line includes: Character cr) ifTrue:
				[line := (line copyUpTo: Character cr), '...'' (continues)'].
			(index := line indexOf: $>) > 0 ifTrue:
				[[(line at: index + 1) isSeparator] whileTrue: [index := index + 1].
				 line := ((line copyFrom: 1 to: index) copyReplaceAll: (String with: Character tab) with: (String new: 8 withAll: Character space)),
						(line copyFrom: index + 1 to: line size)].
			aBlock value: pc value: line.
			pc := scanner pc.
			stream resetContents]
]

{ #category : #accessing }
CompiledCode >> trailer [
	"Answer the receiver's trailer"
	^ CompiledMethodTrailer new method: self

]

{ #category : #'file in\/out' }
CompiledCode >> veryDeepCopyWith: deepCopier [
	"Return self.  I am always shared.  Do not record me.  Only use this for blocks.  Normally methodDictionaries should not be copied this way."
]

{ #category : #cleaning }
CompiledCode >> voidCogVMState [
	"Tell the VM to remove all references to any machine code form of the method.
	 This primitive must be called whenever a method is in use and modified.  This is
	 more aggressive (and *much* more costly) than flushCache since it must search
	 through all context objects, making sure that none have a (hidden) machine code pc
	 in the receiver.  Since modifying a method will likely change the generated machine code,
	 modifying a method (rather than redefining it) requires this more aggressive flush."

	<primitive: 215>
	^self flushCache
]
