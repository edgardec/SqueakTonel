"
I add behaviour to Encoder to size and emit bytecodes for the Squeak V3.x VM bytecode set, a close variant of the original Smalltalk-80 bytecode set defined in the Blue Book.

	0-15 		0000iiii 	Push Receiver Variable #iiii
	16-31 		0001iiii 	Push Temporary Location #iiii
	32-63 		001iiiii 		Push Literal Constant #iiiii
	64-95 		010iiiii 		Push Literal Variable #iiiii
	96-103 	01100iii 	Pop and Store Receiver Variable #iii
	104-111 	01101iii 	Pop and Store Temporary Location #iii
	112-119 	01110iii 	Push (receiver, true, false, nil, -1, 0, 1, 2) [iii]
	120-123 	011110ii 	Return (receiver, true, false, nil) [ii] From Message
	124-125 	0111110i 	Return Stack Top From (Message, Block) [i]
	(126-127 unassigned)
	128 		10000000 jjkkkkkk 	Push (Receiver Variable, Temporary Location, Literal Constant, Literal Variable) [jj] #kkkkkk
	129 		10000001 jjkkkkkk 	Store (Receiver Variable, Temporary Location, Illegal, Literal Variable) [jj] #kkkkkk
	130 		10000010 jjkkkkkk 	Pop and Store (Receiver Variable, Temporary Location, Illegal, Literal Variable) [jj] #kkkkkk
	131 		10000011 jjjkkkkk 	Send Literal Selector #kkkkk With jjj Arguments
	132 		10000100 iiijjjjj kkkkkkkk 	(Send, Send Super, Push Receiver Variable, Push Literal Constant, Push Literal Variable, Store Receiver Variable, Store-Pop Receiver Variable, Store Literal Variable)[iii] #kkkkkkkk jjjjj (for sends jjjjj = numArgs)
	133 		10000101 jjjkkkkk 	Send Literal Selector #kkkkk To Superclass With jjj Arguments
	134 		10000110 jjkkkkkk 	Send Literal Selector #kkkkkk With jj Arguments
	135 		10000111 	Pop Stack Top
	136 		10001000 	Duplicate Stack Top
	137 		10001001 	Push Active Context
	(138-143 unassigned)
	144-151 	10010iii 		Jump iii + 1 (i.e., 1 through 8)
	152-159 	10011iii 		Pop and Jump 0n False iii +1 (i.e., 1 through 8)
	160-167 	10100iii jjjjjjjj 	Jump(iii - 4) *256+jjjjjjjj
	168-171 	101010ii jjjjjjjj 	Pop and Jump On True ii *256+jjjjjjjj
	172-175 	101011ii jjjjjjjj 	Pop and Jump On False ii *256+jjjjjjjj
	176-191 	1011iiii 		Send Arithmetic Message #iiii
	192-207 	1100iiii 		Send Special Message #iiii
	208-223 	1101iiii 		Send Literal Selector #iiii With No Arguments
	224-239 	1110iiii 		Send Literal Selector #iiii With 1 Argument
	240-255 	1111iiii 		Send Literal Selector #iiii With 2 Arguments

"
Class {
	#name : #EncoderForV3,
	#superclass : #BytecodeEncoder,
	#category : #'Compiler-Kernel'
}

{ #category : #'compiled method support' }
EncoderForV3 class >> bindingReadScanBlockFor: bindingLitIndex using: scanner [
	"Answer a block argument for InstructionStream>>scanFor: that answers true
	 for reads of the value of the binding with zero-relative index litVarIndex.
	 N.B. Don't assume the compiler uses the most compact encoding available."
	^[:b|
	   b >= 64
	   and: [b <= 95
			ifTrue: [b - 64 = bindingLitIndex]
			ifFalse:
				[b = 128
					ifTrue: [scanner followingByte - 192 = bindingLitIndex]
					ifFalse:
						[b = 132
						 and: [(scanner followingByte between: 128 and: 159)
						 and: [scanner thirdByte = bindingLitIndex]]]]]]
]

{ #category : #'compiled method support' }
EncoderForV3 class >> bindingWriteScanBlockFor: bindingLitIndex using: scanner [
	"Answer a block argument for InstructionStream>>scanFor: that answers true
	 for writes of the value of the binding with zero-relative index bindingLitIndex.
	 N.B. Don't assume the compiler uses the most compact encoding available."
	^[:b|
	  (b = 129 or: [b = 130])
		ifTrue: [scanner followingByte - 192 = bindingLitIndex]
		ifFalse:
			[b = 132
			 and: [scanner followingByte >= 224
			 and: [scanner thirdByte = bindingLitIndex]]]]
]

{ #category : #'instruction stream support' }
EncoderForV3 class >> bytecodeSize: bytecode [
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
		[^#(2 2 2 2 3 2 2 1 1 1 nil nil nil nil nil nil) at: bytecode - 127].
	^nil
]

{ #category : #'compiled method support' }
EncoderForV3 class >> createClosureScanBlock [
	"Answer a block argument for InstructionStream>>scanFor: that answers true
	 for block closure creation bytecodes."
	^[:b| false]
]

{ #category : #'instruction stream support' }
EncoderForV3 class >> extensionsAt: pc in: aCompiledMethod into: trinaryBlock [
	"If the bytecode at pc is an extension then evaluate aTrinaryBlock
	 with the values of extA and extB and number of extension *bytes*.
	 If the bytecode at pc is not an extension then evaluate with 0, 0, 0.
	 There are no extensions in the SqueakV3/Smalltalk-80 bytecode set, so..." 
	^trinaryBlock value: 0 value: 0 value: 0
]

{ #category : #'instruction stream support' }
EncoderForV3 class >> extensionsFor: pc in: aCompiledMethod into: trinaryBlock [
	"If the bytecode at pc is an extension, or if the bytecode at pc is preceeded by extensions,
	 then evaluate aTrinaryBlock with the values of extA and extB and number of extension *bytes*.
	 If the bytecode at pc is neither an extension or extended then evaluate with 0, 0, 0.
	 There are no extensions in the SqueakV3/Smalltalk-80 bytecode set, so..." 
	^trinaryBlock value: 0 value: 0 value: 0
]

{ #category : #'compiled method support' }
EncoderForV3 class >> instVarReadScanBlockFor: varIndexCode using: scanner [
	"Answer a block argument for InstructionStream>>scanFor: that answers true
	 for reads of the inst var with zero-relative index varIndexCode.
	 N.B. Don't assume the compiler uses the most compact encoding available."
	^[:b|
	   b < 16
		ifTrue: [b = varIndexCode]
		ifFalse:
			[b = 128
				ifTrue: [scanner followingByte = varIndexCode and: [varIndexCode <= 63]]
				ifFalse:
					[b = 132
					 and: [(scanner followingByte between: 64 and: 95)
					 and: [scanner thirdByte = varIndexCode]]]]]
]

{ #category : #'compiled method support' }
EncoderForV3 class >> instVarWriteScanBlockFor: varIndexCode using: scanner [
	"Answer a block argument for InstructionStream>>scanFor: that answers true
	 for writes of the inst var with zero-relative index varIndexCode.
	 N.B. Don't assume the compiler uses the most compact encoding available."
	^[:b|
	   b >= 96
	   and: [b <= 103
			ifTrue: [b - 96 = varIndexCode]
			ifFalse:
				[(b = 129 or: [b = 130])
					ifTrue: [scanner followingByte = varIndexCode and: [varIndexCode <= 63]]
					ifFalse:
						[b = 132
						 and: [(scanner followingByte between: 160 and: 223)
						 and: [scanner thirdByte = varIndexCode]]]]]]
]

{ #category : #'instruction stream support' }
EncoderForV3 class >> interpretJumpIfCondIn: anInstructionStream [
	"Double-dispatch through the encoder to select the correct conditional jump decoder for the instruction set."
	^anInstructionStream interpretV3JumpIfCond
]

{ #category : #'instruction stream support' }
EncoderForV3 class >> interpretJumpIn: anInstructionStream [
	"Double-dispatch through the encoder to select the correct jump interpreter for the instruction set."
	^anInstructionStream interpretV3Jump
]

{ #category : #'instruction stream support' }
EncoderForV3 class >> interpretNextInstructionFor: aClient in: anInstructionStream [
	"Double-dispatch through the encoder to select the correct instruction set decoder."
	^anInstructionStream interpretNextV3InstructionFor: aClient
]

{ #category : #'instruction stream support' }
EncoderForV3 class >> isBlockReturnAt: pc in: method [
	"Answer whether the bytecode at pc is a return from block."

	^(method at: pc) = 125
]

{ #category : #'instruction stream support' }
EncoderForV3 class >> isBranchIfFalseAt: pc in: method [
	"Answer whether the bytecode at pc is a conditional branch-if-false."
	| bytecode |
	bytecode := method at: pc.
	^(bytecode between: 152 and: 159) or: [bytecode between: 172 and: 175]
]

{ #category : #'instruction stream support' }
EncoderForV3 class >> isBranchIfTrueAt: pc in: method [
	"Answer whether the bytecode at pc is a conditional branch-if-true."
	^(method at: pc) between: 168 and: 171
]

{ #category : #'instruction stream support' }
EncoderForV3 class >> isExtension: bytecode [
	"Answer if the bytecode is an extension bytecode, i.e. one that extends the
	 range of the following bytecode.  The Smalltalk-80/V3 sets don't use extensions."
	^false
]

{ #category : #'instruction stream support' }
EncoderForV3 class >> isJumpAt: pc in: method [
	"Answer whether the bytecode at pc is an (unconditional) jump."
	| bytecode |
	bytecode := method at: pc.
	^(bytecode between: 144 and: 151) or: [bytecode between: 160 and: 167]
]

{ #category : #'instruction stream support' }
EncoderForV3 class >> isJustPopAt: pc in: method [
	"Answer whether the bytecode at pc is a pop."

	^(method at: pc) = 135	"135 		10000111 	Pop Stack Top"
]

{ #category : #'instruction stream support' }
EncoderForV3 class >> isRealSendAt: pc in: method [
	"Answer whether the bytecode at pc is a real message-send, not blockCopy:."

	| byte |
	byte := method at: pc.
	^byte >= 176			"special send or short send"
	  or: [byte >= 131
		 and: [byte <= 134	"long sends"	
		 and: [byte ~= 132	"double extended do anything"
			or: [(method at: pc + 1) // 32 <= 1]]]]
]

{ #category : #'instruction stream support' }
EncoderForV3 class >> isReturnAt: pc in: method [
	"Answer whether the bytecode at pc is a return."

	^(method at: pc) between: 120 and: 125
]

{ #category : #'instruction stream support' }
EncoderForV3 class >> isReturnTopFromMethodAt: pc in: method [
	"Answer whether the bytecode at pc is a return stack top from method."

	^(method at: pc) = 124
]

{ #category : #'instruction stream support' }
EncoderForV3 class >> isSendAt: pc in: method [
	"Answer whether the bytecode at pc is a message-send."

	| byte |
	byte := method at: pc.
	^byte >= 176			"special send or short send"
	 or: [byte >= 131
		 and: [byte <= 134	"long sends"	
		 and: [byte ~= 132	"double extended do anything"
			or: [(method at: pc + 1) // 32 <= 1]]]]
]

{ #category : #'instruction stream support' }
EncoderForV3 class >> isStoreAt: pc in: method [
	"Answer whether the bytecode at pc is a store or store-pop."

	| byte |
	byte := method at: pc.
	^(byte between: 96 and: 132)
		and: [byte <= 111				"96 103	storeAndPopReceiverVariableBytecode"
										"104 111	storeAndPopTemporaryVariableBytecode"
			or: [byte >= 129			"129		extendedStoreBytecode"
				and: [byte <= 130		"130		extendedStoreAndPopBytecode"
					or: [byte = 132		"132		doubleExtendedDoAnythingBytecode"
						and: [(method at: pc+1) >= 160]]]]]
]

{ #category : #'instruction stream support' }
EncoderForV3 class >> isStorePopAt: pc in: method [
	"Answer whether the bytecode at pc is a store-pop."

	| byte |
	byte := method at: pc.
	^(byte between: 96 and: 111)	"96 103	storeAndPopReceiverVariableBytecode"
									"104 111	storeAndPopTemporaryVariableBytecode"
	  or: [byte = 130]				"130		extendedStoreAndPopBytecode"
]

{ #category : #'instruction stream support' }
EncoderForV3 class >> isSyntheticStoreAt: pc in: method for: anInstructionStream [
	"Answer whether the bytecode at pc is a store or store-pop of an indirect temp vector,
	 which implement mutable closed-over variables in the the closure implementation.
	 Stores into temp vectors are not real stores."

	^false
]

{ #category : #'instruction stream support' }
EncoderForV3 class >> isTempStoreAt: pc in: method [
	"Answer whether the bytecode at pc is a store or store-pop into a temporary variable.
	 104-111 	01101iii 	Pop and Store Temporary Location #iii
	 129 		10000001 jjkkkkkk 	Store (Receiver Variable, Temporary Location, Illegal, Literal Variable) [jj] #kkkkkk
	 130 		10000010 jjkkkkkk 	Pop and Store (Receiver Variable, Temporary Location, Illegal, Literal Variable) [jj] #kkkkkk"

	| byte |
	byte := method at: pc.
	^byte >= 104
	  and: [byte <= 111
			or: [byte <= 130 and: [byte >= 129 and: [(method at: pc + 1) >> 6 = 1]]]]
]

{ #category : #'compiled method support' }
EncoderForV3 class >> markerOrNilFor: aMethod [
	"If aMethod is a marker method, answer the symbol used to mark it.  Otherwise
	 answer nil.  What is a marker method?  It is method with body like 
		'self subclassResponsibility' or '^ self subclassResponsibility' 
	 used to indicate ('mark') a special property.

	Marker methods compile to two bytecode forms, this:
		self
		send: <literal 1>
		pop
		returnSelf
	or this:
		self
		send: <literal 1>
		returnTop"
	| expectedHeaderPlusLliteralSize e byte |
	expectedHeaderPlusLliteralSize := Smalltalk wordSize * 4.
	^(((e := aMethod endPC - expectedHeaderPlusLliteralSize) = 3 or: [e = 4]) 
	  and: [aMethod numLiterals = 3
	  and: [(aMethod at: expectedHeaderPlusLliteralSize + 1) = 16r70 "push self"
	  and: [(aMethod at: expectedHeaderPlusLliteralSize + 2) = 16rD0 "send"
	  and: [(byte := aMethod at: expectedHeaderPlusLliteralSize + 3) = 16r87 "pop" or: [byte = 16r7C "returnTop"]]]]])
		ifTrue: [aMethod literalAt: 1]
]

{ #category : #scanning }
EncoderForV3 class >> method: method readsField: varIndex [
	"Answer if method loads the instance variable indexed by varIndex.
	 N.B. Don't assume the compiler uses the most compact encoding available.
	0-15 		0000iiii 	Push Receiver Variable #iiii
	128 		10000000 jjkkkkkk 	Push (Receiver Variable, Temporary Location, Literal Constant, Literal Variable) [jj] #kkkkkk
	132 		10000100 iiijjjjj kkkkkkkk 	(Send, Send Super, Push Receiver Variable, Push Literal Constant, Push Literal Variable, Store Receiver Variable, Store-Pop Receiver Variable, Store Literal Variable)[iii] #kkkkkkkk jjjjj (for sends jjjjj = numArgs)"
	| varIndexCode scanner |
	varIndexCode := varIndex - 1.
	method isReturnField ifTrue:
		[^method returnField = varIndexCode].
	^(scanner := InstructionStream on: method) scanFor:
		[:b|
		b < 16
			ifTrue: [b = varIndexCode]
			ifFalse:
				[b = 128
					ifTrue: [scanner followingByte = varIndexCode and: [varIndexCode <= 63]]
					ifFalse:
						[b = 132
						 and: [(scanner followingByte between: 64 and: 95)
						 and: [scanner thirdByte = varIndexCode]]]]]
]

{ #category : #scanning }
EncoderForV3 class >> method: method writesField: varIndex [
	"Answer if method stores into the instance variable indexed by varIndex.
	 N.B. Don't assume the compiler uses the most compact encoding available.
	96-103 	01100iii 	Pop and Store Receiver Variable #iii
	129 		10000001 jjkkkkkk 	Store (Receiver Variable, Temporary Location, Illegal, Literal Variable) [jj] #kkkkkk
	130 		10000010 jjkkkkkk 	Pop and Store (Receiver Variable, Temporary Location, Illegal, Literal Variable) [jj] #kkkkkk
	132 		10000100 iiijjjjj kkkkkkkk 	(Send, Send Super, Push Receiver Variable, Push Literal Constant, Push Literal Variable, Store Receiver Variable, Store-Pop Receiver Variable, Store Literal Variable)[iii] #kkkkkkkk jjjjj (for sends jjjjj = numArgs)"
	| varIndexCode scanner |
	method isQuick ifTrue: [^false].
	varIndexCode := varIndex - 1.
	^(scanner := InstructionStream on: method) scanFor:
		[:b|
		b >= 96
		and: [b <= 103
				ifTrue: [b - 96 = varIndexCode]
				ifFalse:
					[(b = 129 or: [b = 130])
						ifTrue: [scanner followingByte = varIndexCode and: [varIndexCode <= 63]]
						ifFalse:
							[b = 132
							 and: [(scanner followingByte between: 160 and: 223)
							 and: [scanner thirdByte = varIndexCode]]]]]]
]

{ #category : #'instruction stream support' }
EncoderForV3 class >> nonExtensionBytecodeAt: pc in: method [
	"Answer the actual bytecode at pc in method, skipping past any preceeding extensions."
	^method at: pc
]

{ #category : #'bytecode decoding' }
EncoderForV3 class >> pushNilCode [
	"Answer the pushNil bytecode.
	 112-119 	01110iii 	Push (receiver, true, false, nil, -1, 0, 1, 2) [iii]"
	^115
]

{ #category : #scanning }
EncoderForV3 class >> scanBlockOrNilForLiteral: aLiteral [
	"Answer a block argument for CompiledMethod>>#scanFor: that answers
	 if the method refers to the literal implicitly via a special bytecode.
	 If the literal is not accessible via a special bytecode, answer nil."
	| value |
	"176-191 	1011iiii 	Send Arithmetic Message #iiii
	 192-207 	1100iiii 	Send Special Message #iiii"
	(aLiteral isSymbol or: [aLiteral isInteger]) ifTrue:
		[value := aLiteral isSymbol
					ifTrue: [176 + ((Smalltalk specialSelectors indexOf: aLiteral ifAbsent: [^nil]) // 2)]
					ifFalse: [(aLiteral between: -1 and: 2) ifFalse: [^nil].
							aLiteral + 117].
		 ^[:byte| byte = value]].
	"112-119 	01110iii 	Push (receiver, true, false, nil, -1, 0, 1, 2) [iii]
	 120-123 	011110ii 	Return (receiver, true, false, nil) [ii] From Message"
	aLiteral == true ifTrue:
		[^[:byte| byte = 113 or: [byte = 121]]].
	aLiteral == false ifTrue:
		[^[:byte| byte = 114 or: [byte = 122]]].
	aLiteral == nil ifTrue:
		[^[:byte| byte = 115 or: [byte = 123]]].
	^nil
]

{ #category : #'instruction stream support' }
EncoderForV3 class >> selectorToSendOrItselfFor: anInstructionStream in: method at: pc [
	"If anInstructionStream is at a send bytecode then answer the send's selector,
	 otherwise answer anInstructionStream itself.  The rationale for answering
	 anInstructionStream instead of, say, nil, is that potentially any existing object
	 can be used as a selector, but since anInstructionStream postdates the method,
	 it can't be one of them."

	| byte byte2 |
	byte := method at: pc.
	byte < 131 ifTrue: [^anInstructionStream].
	byte >= 176
		ifTrue: 
			["special byte or short send"
			byte >= 208
				ifTrue: [^method literalAt: (byte bitAnd: 15) + 1]
				ifFalse: [^Smalltalk specialSelectorAt: byte - 176 + 1]]
		ifFalse: 
			[byte <= 134 ifTrue: 
				[byte2 := method at: pc + 1.
				 byte = 131 ifTrue: [^method literalAt: byte2 \\ 32 + 1].
				 byte = 132 ifTrue: [byte2 < 64 ifTrue: [^method literalAt: (method at: pc + 2) + 1]].
				 byte = 133 ifTrue: [^method literalAt: byte2 \\ 32 + 1].
				 byte = 134 ifTrue: [^method literalAt: byte2 \\ 64 + 1]]].
	^anInstructionStream
]

{ #category : #'compiled method support' }
EncoderForV3 class >> superSendScanBlockUsing: scanner [
	"Answer a block argument for InstructionStream>>scanFor:
	 that answers true for super sends."
	^[:instr |
	   instr = 16r85
	   or: [instr = 16r84
		and: [scanner followingByte between: 16r20 and: 16r3F]]]
]

{ #category : #'compiled method support' }
EncoderForV3 class >> supportsClosures [
	"Answer if the instruction set supports closures (contains
	 closure creation and indirect temp access bytecodes)."

	^false
]

{ #category : #'bytecode decoding' }
EncoderForV3 class >> unusedBytecode [
	"Answer the opcode of a single-byte unused bytecode, if it exists in the encoder's bytecode set, or nil if not."
	^126
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genBranchPopFalse: distance [
	"See BlueBook page 596"
	distance < 0 ifTrue:
		[^self outOfRangeError: 'distance' index: distance range: 0 to: 1023].
	(distance > 0 and: [distance < 9]) ifTrue:
		["152-159 	10011iii 	Pop and Jump 0n False iii +1 (i.e., 1 through 8)"
		 stream nextPut: 152 + distance - 1.
		 ^self].
	distance < 1024 ifTrue:
		["172-175 	101011ii jjjjjjjj 	Pop and Jump On False ii *256+jjjjjjjj"
		 stream
			nextPut: 172 + (distance bitShift: -8);
			nextPut: distance + 1024 \\ 256.
		 ^self].
	^self outOfRangeError: 'distance' index: distance range: 0 to: 1023
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genBranchPopTrue: distance [
	"See BlueBook page 596"
	distance < 0 ifTrue:
		[^self outOfRangeError: 'distance' index: distance range: 0 to: 1023].
	distance < 1024 ifTrue:
		["168-171 	101010ii jjjjjjjj 	Pop and Jump On True ii *256+jjjjjjjj"
		 stream
			nextPut: 168 + (distance bitShift: -8);
			nextPut: distance + 1024 \\ 256.
		 ^self].
	^self outOfRangeError: 'distance' index: distance range: 0 to: 1023
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genDup [
	"See BlueBook page 596"
	"136 	10001000 	Duplicate Stack Top"
	stream nextPut: 136
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genJump: distance [
	"See BlueBook page 596"
	(distance > 0 and: [distance < 9]) ifTrue:
		["144-151 	10010iii 	Jump iii + 1 (i.e., 1 through 8)"
		 stream nextPut: 144 + distance - 1.
		 ^self].
	"160-167 	10100iii jjjjjjjj 	Jump(iii - 4) *256+jjjjjjjj"
	^self genJumpLong: distance
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genJumpLong: distance [
	"See BlueBook page 596"
	(distance >= -1024 and: [distance < 1024]) ifTrue:
		["160-167 	10100iii jjjjjjjj 	Jump(iii - 4) *256+jjjjjjjj"
		 stream
			nextPut: 160 + (distance + 1024 bitShift: -8);
			nextPut: distance + 1024 \\ 256.
		 ^self].
	^self outOfRangeError: 'distance' index: distance range: -1024 to: 1023
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genPop [
	"See BlueBook page 596"
	"135 	10000111 	Pop Stack Top"
	stream nextPut: 135
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genPushInstVar: instVarIndex [
	"See BlueBook page 596"
	instVarIndex >= 0 ifTrue:
		[instVarIndex < 16 ifTrue:
			["0-15 	0000iiii 	Push Receiver Variable #iiii"
			 stream nextPut: 0 + instVarIndex.
			 ^self].
		instVarIndex < 64 ifTrue:
			["128 	10000000 jjkkkkkk 	Push (Receiver Variable, Temporary Location, Literal Constant, Literal Variable) [jj] #kkkkkk"
			 stream
				nextPut: 128;
				nextPut: instVarIndex.
			 ^self]].
	self genPushInstVarLong: instVarIndex
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genPushInstVarLong: instVarIndex [
	"See BlueBook page 596"
	"See also MaybeContextInstanceVariableNode"
	(instVarIndex >= 0 and: [instVarIndex < 256]) ifTrue: 
		["132 	10000100 iiijjjjj kkkkkkkk 	(Send, Send Super, Push Receiver Variable, Push Literal Constant, Push Literal Variable, Store Receiver Variable, Store-Pop Receiver Variable, Store Literal Variable)[iii] #kkkkkkkk jjjjj"
		 stream
			nextPut: 132;
			nextPut: 64;
			nextPut: instVarIndex.
		 ^self].
	^self outOfRangeError: 'index' index: instVarIndex range: 0 to: 255
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genPushLiteral: literalIndex [
	"See BlueBook page 596"
	literalIndex < 0 ifTrue: 
		[^self outOfRangeError: 'index' index: literalIndex range: 0 to: 255].
	literalIndex < 32 ifTrue: 
		["32-63 	001iiiii 	Push Literal Constant #iiiii"
		 stream nextPut: 32 + literalIndex.
		 ^self].
	literalIndex < 64 ifTrue: 
		["128 	10000000 jjkkkkkk 	Push (Receiver Variable, Temporary Location, Literal Constant, Literal Variable) [jj] #kkkkkk"
		 stream
			nextPut: 128;
			nextPut: 128 + literalIndex.
		 ^self].
	literalIndex < 256 ifTrue: 
		["132 	10000100 iiijjjjj kkkkkkkk 	(Send, Send Super, Push Receiver Variable, Push Literal Constant, Push Literal Variable, Store Receiver Variable, Store-Pop Receiver Variable, Store Literal Variable)[iii] #kkkkkkkk jjjjj"
		 stream
			nextPut: 132;
			nextPut: 96;
			nextPut: literalIndex.
		 ^self].
	^self outOfRangeError: 'index' index: literalIndex range: 0 to: 255
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genPushLiteralVar: literalIndex [
	"See BlueBook page 596"
	literalIndex < 0 ifTrue: 
		[^self outOfRangeError: 'index' index: literalIndex range: 0 to: 255].
	literalIndex < 32 ifTrue: 
		["64-95 	010iiiii 	Push Literal Variable #iiiii"
		 stream nextPut: 64 + literalIndex.
		 ^self].
	literalIndex < 64 ifTrue: 
		["128 	10000000 jjkkkkkk 	Push (Receiver Variable, Temporary Location, Literal Constant, Literal Variable) [jj] #kkkkkk"
		 stream
			nextPut: 128;
			nextPut: 192 + literalIndex.
		 ^self].
	literalIndex < 256 ifTrue: 
		["132 	10000100 iiijjjjj kkkkkkkk 	(Send, Send Super, Push Receiver Variable, Push Literal Constant, Push Literal Variable, Store Receiver Variable, Store-Pop Receiver Variable, Store Literal Variable)[iii] #kkkkkkkk jjjjj"
		 stream
			nextPut: 132;
			nextPut: 128;
			nextPut: literalIndex.
		 ^self].
	^self outOfRangeError: 'index' index: literalIndex range: 0 to: 255
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genPushReceiver [
	"See BlueBook page 596"
	"112-119 	01110iii 	Push (receiver, true, false, nil, -1, 0, 1, 2) [iii]"
	stream nextPut: 112
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genPushSpecialLiteral: aLiteral [
	"112-119 	01110iii 	Push (receiver, true, false, nil, -1, 0, 1, 2) [iii]"
	| index |
	index := #(true false nil -1 0 1 2) indexOf: aLiteral.
	index = 0 ifTrue:
		[^self error: 'push special literal: ', aLiteral printString,  ' is not one of true false nil -1 0 1 2'].
	stream nextPut: index + 112
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genPushTemp: tempIndex [
	"See BlueBook page 596"
	tempIndex < 0 ifTrue:
		[^self outOfRangeError: 'index' index: tempIndex range: 0 to: 63].
	tempIndex < 16 ifTrue: 
		["16-31 	0001iiii 	Push Temporary Location #iiii"
		 stream nextPut: 16 + tempIndex.
		 ^self].
	tempIndex < 64 ifTrue: 
		["128 	10000000 jjkkkkkk 	Push (Receiver Variable, Temporary Location, Literal Constant, Literal Variable) [jj] #kkkkkk"
		 stream
			nextPut: 128;
			nextPut: 64 + tempIndex.
		 ^self].
	^self outOfRangeError: 'index' index: tempIndex range: 0 to: 63
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genPushTempLong: tempIndex [
	"See BlueBook page 596"
	(tempIndex >= 0 and: [tempIndex < 64]) ifTrue: 
		["128 	10000000 jjkkkkkk 	Push (Receiver Variable, Temporary Location, Literal Constant, Literal Variable) [jj] #kkkkkk"
		 stream
			nextPut: 128;
			nextPut: 64 + tempIndex.
		 ^self].
	^self outOfRangeError: 'index' index: tempIndex range: 0 to: 63
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genPushThisContext [
	"See BlueBook page 596"
	"137 	10001001 	Push Active Context"
	stream nextPut: 137
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genReturnReceiver [
	"See BlueBook page 596"
	"120-123 	011110ii 	Return (receiver, true, false, nil) [ii] From Message"
	stream nextPut: 120
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genReturnSpecialLiteral: aLiteral [
	"120-123 	011110ii 	Return (receiver, true, false, nil) [ii] From Message"
	| index |
	index := #(true false nil) indexOf: aLiteral.
	index = 0 ifTrue:
		[^self error: 'return special literal: ', aLiteral printString,  ' is not one of true false nil'].
	stream nextPut: 120 + index
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genReturnTop [
	"See BlueBook page 596"
	"124-125 	0111110i 	Return Stack Top From (Message, Block) [i]"
	stream nextPut: 124
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genReturnTopToCaller [
	"See BlueBook page 596"
	"124-125 	0111110i 	Return Stack Top From (Message, Block) [i]"
	stream nextPut: 125
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genSend: selectorLiteralIndex numArgs: nArgs [
	"See BlueBook page 596 (with exceptions for 132 & 134)"
	nArgs < 0 ifTrue:
		[^self outOfRangeError: 'numArgs' index: nArgs range: 0 to: 31 "!!"].
	selectorLiteralIndex < 0 ifTrue:
		["Special selector sends.
			176-191 	1011iiii 	Send Arithmetic Message #iiii
			192-207 	1100iiii 	Send Special Message #iiii"
		self flag: #yuck.
		 (selectorLiteralIndex negated between: 176 and: 207) ifFalse:
			[^self outOfRangeError: 'special selector code' index: selectorLiteralIndex negated range: 176 to: 207].
		 stream nextPut: selectorLiteralIndex negated.
		 ^self].
	(selectorLiteralIndex < 16 and: [nArgs < 3]) ifTrue:
		["	208-223 	1101iiii 	Send Literal Selector #iiii With No Arguments
			224-239 	1110iiii 	Send Literal Selector #iiii With 1 Argument
			240-255 	1111iiii 	Send Literal Selector #iiii With 2 Arguments"
		 stream nextPut: 208 + (nArgs * 16) + selectorLiteralIndex.
		 ^self].
	(selectorLiteralIndex < 32 and: [nArgs < 8]) ifTrue: 
		["	131 	10000011 jjjkkkkk 	Send Literal Selector #kkkkk With jjj Arguments"
		 stream
			nextPut: 131;
			nextPut: ((nArgs bitShift: 5) + selectorLiteralIndex).
		 ^self].
	(selectorLiteralIndex < 64 and: [nArgs < 4]) ifTrue: 
	 	["In Squeak V3
			134 	10000110 jjjjjjjj kkkkkkkk 	Send Literal Selector #kkkkkkkk To Superclass With jjjjjjjj Arguments
		 is replaced by
			134 	10000110 jjkkkkkk 	Send Literal Selector #kkkkkk With jj Arguments"
		 stream
			nextPut: 134;
			nextPut: ((nArgs bitShift: 6) + selectorLiteralIndex).
		 ^self].
	(selectorLiteralIndex < 256 and: [nArgs < 32]) ifTrue: 
		["In Squeak V3
			132 	10000100 jjjjjjjj kkkkkkkk 	Send Literal Selector #kkkkkkkk With jjjjjjjj Arguments
		  is replaced by
			132 	10000100 ooojjjjj kkkkkkkk
				ooo = 0 => Send Literal Selector #kkkkkkkk With jjjjj Arguments
				ooo = 1 => Send Literal Selector #kkkkkkkk To Superclass With jjjjj Arguments"
		stream
			nextPut: 132;
			nextPut: nArgs;
			nextPut: selectorLiteralIndex.
		 ^self].
	nArgs >= 32 ifTrue:
		[^self outOfRangeError: 'numArgs' index: nArgs range: 0 to: 31].
	selectorLiteralIndex >= 256 ifTrue: 
		[^self outOfRangeError: 'selector literal index' index: selectorLiteralIndex range: 0 to: 255]
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genSendSpecial: specialSelectorIndex numArgs: nArgs [
	"See BlueBook page 596"
	self assert: (specialSelectorIndex between: 1 and: Smalltalk specialSelectorSize).
	self assert: nArgs = (Smalltalk specialNargsAt: specialSelectorIndex).
	"Special selector sends.
		176-191 	1011iiii 	Send Arithmetic Message #iiii
		192-207 	1100iiii 	Send Special Message #iiii"
	stream nextPut: specialSelectorIndex + 175
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genSendSuper: selectorLiteralIndex numArgs: nArgs [
	"See BlueBook page 596 (with exceptions for 132 & 134)"
	nArgs < 0 ifTrue:
		[^self outOfRangeError: 'numArgs' index: nArgs range: 0 to: 31 "!!"].
	selectorLiteralIndex < 0 ifTrue:
		[^self outOfRangeError: 'selector literal index' index: selectorLiteralIndex range: 0 to: 255].
	(selectorLiteralIndex < 32 and: [nArgs < 8]) ifTrue: 
		["	133 	10000011 jjjkkkkk 	Send Literal Selector #kkkkk To Superclass With jjj Arguments"
		 stream
			nextPut: 133;
			nextPut: ((nArgs bitShift: 5) + selectorLiteralIndex).
		 ^self].
	(selectorLiteralIndex < 256 and: [nArgs < 32]) ifTrue: 
		["In Squeak V3
			132 	10000100 jjjjjjjj kkkkkkkk 	Send Literal Selector #kkkkkkkk With jjjjjjjj Arguments
		  is replaced by
			132 	10000100 ooojjjjj kkkkkkkk
				ooo = 0 => Send Literal Selector #kkkkkkkk With jjjjj Arguments
				ooo = 1 => Send Literal Selector #kkkkkkkk To Superclass With jjjjj Arguments"
		stream
			nextPut: 132;
			nextPut: 32 + nArgs;
			nextPut: selectorLiteralIndex.
		 ^self].
	nArgs >= 32 ifTrue:
		[^self outOfRangeError: 'numArgs' index: nArgs range: 0 to: 31].
	selectorLiteralIndex >= 256 ifTrue: 
		[^self outOfRangeError: 'selector literal index' index: selectorLiteralIndex range: 0 to: 255]
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genStoreInstVar: instVarIndex [
	"See BlueBook page 596"
	(instVarIndex >= 0 and: [instVarIndex < 64]) ifTrue: 
		["129 	10000001 jjkkkkkk 	Store (Receiver Variable, Temporary Location, Illegal, Literal Variable) [jj] #kkkkkk"
		 stream
			nextPut: 129;
			nextPut: instVarIndex.
		 ^self].
	self genStoreInstVarLong: instVarIndex
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genStoreInstVarLong: instVarIndex [
	"See BlueBook page 596"
	"See also MaybeContextInstanceVariableNode"
	(instVarIndex >= 0 and: [instVarIndex < 256]) ifTrue: 
		["132 	10000100 iiijjjjj kkkkkkkk 	(Send, Send Super, Push Receiver Variable, Push Literal Constant, Push Literal Variable, Store Receiver Variable, Store-Pop Receiver Variable, Store Literal Variable)[iii] #kkkkkkkk jjjjj"
		 stream
			nextPut: 132;
			nextPut: 160;
			nextPut: instVarIndex.
		 ^self].
	^self outOfRangeError: 'index' index: instVarIndex range: 0 to: 255
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genStoreLiteralVar: literalIndex [
	"See BlueBook page 596"
	literalIndex < 0 ifTrue:
		[^self outOfRangeError: 'index' index: literalIndex range: 0 to: 255].
	literalIndex < 64 ifTrue: 
		["129 	10000001 jjkkkkkk 	Store (Receiver Variable, Temporary Location, Illegal, Literal Variable) [jj] #kkkkkk"
		 stream
			nextPut: 129;
			nextPut: 192 + literalIndex.
		 ^self].
	literalIndex < 256 ifTrue: 
		["132 	10000100 iiijjjjj kkkkkkkk 	(Send, Send Super, Push Receiver Variable, Push Literal Constant, Push Literal Variable, Store Receiver Variable, Store-Pop Receiver Variable, Store Literal Variable)[iii] #kkkkkkkk jjjjj"
		 stream
			nextPut: 132;
			nextPut: 224;
			nextPut: literalIndex.
		 ^self].
	^self outOfRangeError: 'index' index: literalIndex range: 0 to: 255
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genStorePopInstVar: instVarIndex [
	"See BlueBook page 596"
	instVarIndex >= 0 ifTrue:
		[instVarIndex < 8 ifTrue:
			["96-103 	01100iii 	Pop and Store Receiver Variable #iii"
			 stream nextPut: 96 + instVarIndex.
			 ^self].
		instVarIndex < 64 ifTrue:
			["130 	10000010 jjkkkkkk 	Pop and Store (Receiver Variable, Temporary Location, Illegal, Literal Variable) [jj] #kkkkkk"
			 stream
				nextPut: 130;
				nextPut: instVarIndex.
			 ^self]].
	self genStorePopInstVarLong: instVarIndex
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genStorePopInstVarLong: instVarIndex [
	"See BlueBook page 596"
	"See also MaybeContextInstanceVariableNode"
	(instVarIndex >= 0 and: [instVarIndex < 256]) ifTrue: 
		["132 	10000100 iiijjjjj kkkkkkkk 	(Send, Send Super, Push Receiver Variable, Push Literal Constant, Push Literal Variable, Store Receiver Variable, Store-Pop Receiver Variable, Store Literal Variable)[iii] #kkkkkkkk jjjjj"
		 stream
			nextPut: 132;
			nextPut: 192;
			nextPut: instVarIndex.
		 ^self].
	^self outOfRangeError: 'index' index: instVarIndex range: 0 to: 255
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genStorePopLiteralVar: literalIndex [
	"See BlueBook page 596"
	literalIndex < 0 ifTrue:
		[^self outOfRangeError: 'index' index: literalIndex range: 0 to: 255].
	literalIndex < 64 ifTrue: 
		["130 	10000010 jjkkkkkk 	Pop and Store (Receiver Variable, Temporary Location, Illegal, Literal Variable) [jj] #kkkkkk"
		 stream
			nextPut: 130;
			nextPut: 192 + literalIndex.
		 ^self].
	literalIndex < 256 ifTrue: 
		["132 	10000100 iiijjjjj kkkkkkkk 	(Send, Send Super, Push Receiver Variable, Push Literal Constant, Push Literal Variable, Store Receiver Variable, Store-Pop Receiver Variable, Store Literal Variable)[iii] #kkkkkkkk jjjjj"
		 stream
			nextPut: 132;
			nextPut: 224;
			nextPut: literalIndex.
		 self genPop.
		 ^self].
	^self outOfRangeError: 'index' index: literalIndex range: 0 to: 255
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genStorePopTemp: tempIndex [
	"See BlueBook page 596"
	tempIndex < 0 ifTrue:
		[^self outOfRangeError: 'index' index: tempIndex range: 0 to: 63].
	tempIndex < 8 ifTrue: 
		["104-111 	01101iii 	Pop and Store Temporary Location #iii"
		 stream nextPut: 104 + tempIndex.
		 ^self].
	tempIndex < 64 ifTrue: 
		["130 	10000010 jjkkkkkk 	Pop and Store (Receiver Variable, Temporary Location, Illegal, Literal Variable) [jj] #kkkkkk"
		 stream
			nextPut: 130;
			nextPut: 64 + tempIndex.
		 ^self].
	^self outOfRangeError: 'index' index: tempIndex range: 0 to: 63
]

{ #category : #'bytecode generation' }
EncoderForV3 >> genStoreTemp: tempIndex [
	"See BlueBook page 596"
	tempIndex < 0 ifTrue:
		[^self outOfRangeError: 'index' index: tempIndex range: 0 to: 63].
	tempIndex < 64 ifTrue: 
		["129 	10000001 jjkkkkkk 	Store (Receiver Variable, Temporary Location, Illegal, Literal Variable) [jj] #kkkkkk"
		 stream
			nextPut: 129;
			nextPut: 64 + tempIndex.
		 ^self].
	^self outOfRangeError: 'index' index: tempIndex range: 0 to: 63
]

{ #category : #'special literal encodings' }
EncoderForV3 >> if: code isSpecialLiteralForPush: aBlock [
	"If code is that of a special literal for push then evaluate aBlock with the special literal
	 The special literals for push are nil true false -1 0 1 & 2 which have special encodings
	 in the blue book bytecode set.  Answer whether it was a special literal."
	^(code between: LdTrue and: LdNil + 4)
	    and: [aBlock value: (#(true false nil -1 0 1 2) at: code - LdSelf).
			true]
]

{ #category : #'special literal encodings' }
EncoderForV3 >> if: code isSpecialLiteralForReturn: aBlock [
	"If code is that of a special literal for return then evaluate aBlock with the special literal.
	 The special literals for return are nil true false which have special encodings
	 in the blue book bytecode set.  Answer whether it was a special literal."
	^(code between: LdTrue and: LdNil)
	   and: [aBlock value: (#(true false nil) at: code - LdSelf).
			true]
]

{ #category : #'special literal encodings' }
EncoderForV3 >> isSpecialLiteralForPush: literal [
	^literal isInteger
		ifFalse:
			[false == literal
			 or: [true == literal
			 or: [nil == literal]]]
		ifTrue: [literal between: -1 and: 2]
]

{ #category : #'special literal encodings' }
EncoderForV3 >> isSpecialLiteralForReturn: literal [
	^literal == false
	  or: [literal == true
	  or: [literal == nil]]
]

{ #category : #'bytecode generation' }
EncoderForV3 >> maxIndexableLiterals [
	"This bytecode set can index up to 256 literals."
	^256
]

{ #category : #testing }
EncoderForV3 >> supportsFullBlocks [
	"Answer if the instruction set supports full closures (closure creation from
	 specfic methods instead of bytecodes embedded in an outer home method)."
	
	^false
]
