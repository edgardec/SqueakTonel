"
An encoder for the V3 bytecode set augmented with the following bytecodes that are part of the full closure implementation.
	138   10001010 jkkkkkkk		Push (Array new: kkkkkkk) (j = 0)
								or	Pop kkkkkkk elements into: (Array new: kkkkkkk) (j = 1)
	139   10001011 kkkkkkkk jjjjjjjj 	Invoke primitive number jjjjjjjjkkkkkkkk
	140   10001100 kkkkkkkk jjjjjjjj 	Push Temp At kkkkkkkk In Temp Vector At: jjjjjjjj
	141   10001101 kkkkkkkk jjjjjjjj 	Store Temp At kkkkkkkk In Temp Vector At: jjjjjjjj
	142   10001110 kkkkkkkk jjjjjjjj 	Pop and Store Temp At kkkkkkkk In Temp Vector At: jjjjjjjj
	143   10001111 llllkkkk jjjjjjjj iiiiiiii	Push Closure Num Copied llll Num Args kkkk BlockSize jjjjjjjjiiiiiiii
This is an exact duplicate of EncoderForLongFormV3PlusClosures.
Could be a trait (or in Newspeak, a Mixin).
For now we impose upon you to synchronise any and all changes between these two classes.
"
Class {
	#name : #EncoderForV3PlusClosures,
	#superclass : #EncoderForV3,
	#category : #'Compiler-Kernel'
}

{ #category : #'instruction stream support' }
EncoderForV3PlusClosures class >> bytecodeSize: bytecode [
	"Answer the number of bytes in the bytecode."
	bytecode <= 125 ifTrue:
		[^1].
	bytecode >= 176 ifTrue:
		[^1].
	bytecode >= 160 ifTrue: "long jumps"
		[^2].
	bytecode >= 144 ifTrue: "short jumps"
		[^1].
	"extensions"
	bytecode >= 128 ifTrue:
		[^#(2 2 2 2 3 2 2 1 1 1 2 3 3 3 3 4) at: bytecode - 127].
	^nil
]

{ #category : #'bytecode decoding' }
EncoderForV3PlusClosures class >> callPrimitiveCode [
	"139	11101111	iiiiiiii jjjjjjjj	Call Primitive #iiiiiiii + (jjjjjjjj * 256)"
	^139
]

{ #category : #'bytecode decoding' }
EncoderForV3PlusClosures class >> createClosureCode [
	"Answer the create closure bytecode, if it exists in the encoder's bytecode set, or nil if not.
	 Actually this code is that for a closure whose bytecodes are nested within its home method's."
	^143
]

{ #category : #'compiled method support' }
EncoderForV3PlusClosures class >> createClosureScanBlock [
	"Answer a block argument for InstructionStream>>scanFor: that answers true
	 for block closure creation bytecodes."
	^[ :bc | bc = 143]
]

{ #category : #'instruction stream support' }
EncoderForV3PlusClosures class >> interpretNextInstructionFor: aClient in: anInstructionStream [
	"Double-dispatch through the encoder to select the correct instruction set decoder."
	^anInstructionStream interpretNextV3ClosuresInstructionFor: aClient
]

{ #category : #'instruction stream support' }
EncoderForV3PlusClosures class >> isStoreAt: pc in: method [
	"Answer whether the bytecode at pc is a store or store-pop."

	| byte |
	byte := method at: pc.
	^(byte between: 96 and: 142)
		and: [byte <= 111				"96 103	storeAndPopReceiverVariableBytecode"
										"104 111	storeAndPopTemporaryVariableBytecode"
			or: [byte >= 129			"129		extendedStoreBytecode"
				and: [byte <= 130		"130		extendedStoreAndPopBytecode"
					or: [(byte = 132	"132		doubleExtendedDoAnythingBytecode"
						and: [(method at: pc+1) >= 160])
					or: [byte = 141		"141		storeRemoteTempLongBytecode"
					or: [byte = 142		"142		storeAndPopRemoteTempLongBytecode"]]]]]]
]

{ #category : #'instruction stream support' }
EncoderForV3PlusClosures class >> isStorePopAt: pc in: method [
	"Answer whether the bytecode at pc is a store-pop."

	| byte |
	byte := method at: pc.
	^(byte between: 96 and: 111)	"96 103	storeAndPopReceiverVariableBytecode"
									"104 111	storeAndPopTemporaryVariableBytecode"
	  or: [byte = 130				"130		extendedStoreAndPopBytecode"
	  or: [byte = 142]]				"142		storeAndPopRemoteTempLongBytecode"
]

{ #category : #'instruction stream support' }
EncoderForV3PlusClosures class >> isSyntheticStoreAt: pc in: method for: anInstructionStream [
	"Answer whether the bytecode at pc is a store or store-pop of an indirect temp vector,
	 which implement mutable closed-over variables in the the closure implementation.
	 Stores into temp vectors are not real stores.  N.B. pcPreviousTo:in:for: is slow, so filter
	 out any preceding bytecodes other than what looks like a pushNewArrayCode.  But the
	 pcPreviousTo:in:for: is still necessary, since the presence of a pcPreviousTo:in:for: in the
	 right place is potentially ambiguous, possibly part of a different bytecode seqence."

	^(self isTempStoreAt: pc in: method)
	  and: [pc - 2 >= method initialPC
	  and: [(method at: pc - 2) = self pushNewArrayCode
	  and: [(method at: pc - 1) <= 127
	  and: [pc - 2 = (self pcPreviousTo: pc in: method for: anInstructionStream)]]]]
]

{ #category : #'bytecode decoding' }
EncoderForV3PlusClosures class >> pcFollowingBlockAt: pc in: method [
	"Assuming the pc is that of a block creation bytecode, answer the pc immediately following the block,
	 i.e. the next pc after the block creation."
	self assert: (method at: pc) = self createClosureCode.
	^(method at: pc + 2) * 256 + (method at: pc + 3) + pc + 4
]

{ #category : #'bytecode decoding' }
EncoderForV3PlusClosures class >> pcOfBlockCreationBytecodeForBlockStartingAt: startpc in: method [
	"Answer the pc of the push closure bytecode whose block starts at startpc in method.
	 143   10001111 llllkkkk jjjjjjjj iiiiiiii	Push Closure Num Copied llll Num Args kkkk BlockSize jjjjjjjjiiiiiiii"
	^startpc - 4
]

{ #category : #'bytecode decoding' }
EncoderForV3PlusClosures class >> pushClosureBytecodeSize [
	"Answer the size of the push closure bytecode.
	 143   10001111 llllkkkk jjjjjjjj iiiiiiii	Push Closure Num Copied llll Num Args kkkk BlockSize jjjjjjjjiiiiiiii"
	^4
]

{ #category : #'bytecode decoding' }
EncoderForV3PlusClosures class >> pushNewArrayCode [
	"138   10001010 jkkkkkkk		Push (Array new: kkkkkkk) (j = 0)
								or	Pop kkkkkkk elements into: (Array new: kkkkkkk) (j = 1)"
	^138
]

{ #category : #'compiled method support' }
EncoderForV3PlusClosures class >> supportsClosures [
	"Answer if the instruction set supports closures (contains
	 closure creation and indirect temp access bytecodes)."

	^true
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genCallPrimitive: primitiveIndex [
	"139	11101111	iiiiiiii jjjjjjjj	Call Primitive #iiiiiiii + (jjjjjjjj * 256)"
	(primitiveIndex < 1 or: [primitiveIndex > 65535]) ifTrue:
		[self outOfRangeError: 'primitive index' index: primitiveIndex range: 1 to: 65535].
	stream
		nextPut: 139;
		nextPut: (primitiveIndex bitAnd: 255);
		nextPut: (primitiveIndex bitShift: -8)
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genPushClosureCopyNumCopiedValues: numCopied numArgs: numArgs jumpSize: jumpSize [
	"143 	10001111 llllkkkk jjjjjjjj iiiiiiii	Push Closure Num Copied llll Num Args kkkk BlockSize jjjjjjjjiiiiiiii"
	(jumpSize < 0 or: [jumpSize > 65535]) ifTrue:
		[^self outOfRangeError: 'block size' index: jumpSize range: 0 to: 65535].
	(numCopied < 0 or: [numCopied > 15]) ifTrue:
		[^self outOfRangeError: 'num copied' index: numCopied range: 0 to: 15].
	(numArgs < 0 or: [numArgs > 15]) ifTrue:
		[^self outOfRangeError: 'num args' index: numArgs range: 0 to: 15].
	stream
		nextPut: 143;
		nextPut: numArgs + (numCopied bitShift: 4);
		nextPut: (jumpSize bitShift: -8);
		nextPut: (jumpSize bitAnd: 16rFF)
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genPushConsArray: size [
	(size < 0 or: [size > 127]) ifTrue:
		[^self outOfRangeError: 'numElements' index: size range: 0 to: 127].
	"138 	10001010 1kkkkkkk 	Push (Array new: kkkkkkk)"
	stream
		nextPut: 138;
		nextPut: size + 128
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genPushNewArray: size [
	(size < 0 or: [size > 127]) ifTrue:
		[^self outOfRangeError: 'numElements' index: size range: 0 to: 127].
	"138 	10001010 0kkkkkkk 	Pop kkkkkkk into: (Array new: kkkkkkk)"
	stream
		nextPut: 138;
		nextPut: size
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genPushRemoteTemp: tempIndex inVectorAt: tempVectorIndex [
	(tempIndex >= 0 and: [tempIndex < 256
	 and: [tempVectorIndex >= 0 and: [tempVectorIndex < 256]]]) ifTrue:
		["140 	10001100 kkkkkkkk jjjjjjjj 	Push Temp At kkkkkkkk In Temp Vector At: jjjjjjjj"
		 stream
			nextPut: 140;
			nextPut: tempIndex;
			nextPut: tempVectorIndex.
		 ^self].
	tempIndex >= 256 ifTrue:
		[^self outOfRangeError: 'remoteTempIndex' index: tempIndex range: 0 to: 255].
	tempVectorIndex >= 256 ifTrue:
		[^self outOfRangeError: 'tempVectorIndex' index: tempVectorIndex range: 0 to: 255]
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genStorePopRemoteTemp: tempIndex inVectorAt: tempVectorIndex [
	"142 	10001110 kkkkkkkk jjjjjjjj 	Pop and Store Temp At kkkkkkkk In Temp Vector At: jjjjjjjj"
	(tempIndex >= 0 and: [tempIndex < 256
	 and: [tempVectorIndex >= 0 and: [tempVectorIndex < 256]]]) ifTrue:
		[stream
			nextPut: 142;
			nextPut: tempIndex;
			nextPut: tempVectorIndex.
		 ^self].
	tempIndex >= 256 ifTrue:
		[^self outOfRangeError: 'remoteTempIndex' index: tempIndex range: 0 to: 255].
	tempVectorIndex >= 256 ifTrue:
		[^self outOfRangeError: 'tempVectorIndex' index: tempVectorIndex range: 0 to: 255]
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genStoreRemoteTemp: tempIndex inVectorAt: tempVectorIndex [
	"141 	10001101 kkkkkkkk jjjjjjjj 	Store Temp At kkkkkkkk In Temp Vector At: jjjjjjjj"
	(tempIndex >= 0 and: [tempIndex < 256
	 and: [tempVectorIndex >= 0 and: [tempVectorIndex < 256]]]) ifTrue:
		[stream
			nextPut: 141;
			nextPut: tempIndex;
			nextPut: tempVectorIndex.
		 ^self].
	tempIndex >= 256 ifTrue:
		[^self outOfRangeError: 'remoteTempIndex' index: tempIndex range: 0 to: 255].
	tempVectorIndex >= 256 ifTrue:
		[^self outOfRangeError: 'tempVectorIndex' index: tempVectorIndex range: 0 to: 255]
]

{ #category : #testing }
EncoderForV3PlusClosures >> supportsClosureOpcodes [
	^true
]
