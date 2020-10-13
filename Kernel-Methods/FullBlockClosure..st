"
Instances of FullBlockClosure represent blocks, a sequence of statements inside square brackets that can be evaluated at any time via one of the value messages (value, value:, value:value:, ..., valueWithArguments:), which answer their last statement.  Blocks therefore allow deferred evaluation and so are used to build control structures where a sequence of statements are evaluated or not depending on other values in the program.

FullBlockClosure is a refinement of BlockClosure that allows the block to use its own method to hold its code instead of embedding that code within its home method.

Instance Variables (inherited)
	numArgs			<SmallInteger> 
	outerContext:		<Context|nil> 
	startpcOrMethod	<CompiledBlock>

Instance Variables
	receiver:			<Object>

numArgs
	- the number of arguments the block expects. This is superfluous; the number of arguments can be obtained from the receiver's compiledBlock.

outerContext
	- the Context of the method or block activation in which the receiver is created.

compiledBlock(startpcOrMethod)
	- reused to refer to the CompiledBlock that implements the receiver's code.

receiver
	- the receiver of the message that created the block's home method activation.


Implementation notes:

A FullBlockClosure is a closure that can be independent of any outerContext if desired.  It has its own method (reusing the startpcOrMethod inst var) and its own receiver.  outerContext can be either a Context or nil.

This closure design, implemented by Eliot Miranda and Clement Bera along with the Sista work, aims to simplify the block closure model while enhacing its capabilities. It allows lazy decompilation of closures and fast machine code dispatch in Cog's JIT, while allowing inlining of methods and blocks to be independent from their enclosing blocks.

At closure creation time, the Sista closure creation bytecode specifies:
- the compiledBlock to execute when executing this block's code (in the literal frame)
- if the receiver is the current receiver or a receiver passed on stack before the copied values.
- if the closure needs an outerContext. outerContexts are used for non local returns and debugging. Blocks with non-local (up arrow) returns have to set their outerContext. For other blocks (97% of blocks), it's a trade-off between performance and debuggability.
"
Class {
	#name : #FullBlockClosure,
	#superclass : #BlockClosure,
	#type : #variable,
	#instVars : [
		'receiver'
	],
	#category : #'Kernel-Methods'
}

{ #category : #'instance creation' }
FullBlockClosure class >> receiver: aReceiver outerContext: aContextOrNil method: aCompiledBlock copiedValues: anArrayOrNil [
	^(self new: anArrayOrNil basicSize)
		receiver: aReceiver
		outerContext: aContextOrNil
		method: aCompiledBlock
		copiedValues: anArrayOrNil
]

{ #category : #comparing }
FullBlockClosure >> = aClosure [
	self == aClosure ifTrue: [^true].
	aClosure class == self class ifFalse: [^false].
	^startpcOrMethod = aClosure method
	 and: [outerContext = aClosure outerContext or: [self isClean]]
]

{ #category : #scanning }
FullBlockClosure >> abstractBytecodeMessagesDo: aBlock [
	^startpcOrMethod abstractBytecodeMessagesDo: aBlock
]

{ #category : #private }
FullBlockClosure >> asContextWithSender: aContext [
	"Inner private support method for evaluation.  Do not use unless you know what you're doing."

	^(Context newForMethod: startpcOrMethod)
		setSender: aContext
		receiver: self receiver
		method: startpcOrMethod
		closure: self
		startpc: startpcOrMethod initialPC;
		privRefresh
]

{ #category : #scanning }
FullBlockClosure >> blockCreationPC [
	self shouldNotImplement
]

{ #category : #accessing }
FullBlockClosure >> endPC [
	^startpcOrMethod endPC
]

{ #category : #scanning }
FullBlockClosure >> hasMethodReturn [
	"Answer whether the receiver has a method-return ('^') in its code."
	^startpcOrMethod hasMethodReturn
]

{ #category : #accessing }
FullBlockClosure >> home [
	^ outerContext ifNotNil: [ outerContext home ]
]

{ #category : #accessing }
FullBlockClosure >> homeMethod [
	^startpcOrMethod homeMethod
]

{ #category : #testing }
FullBlockClosure >> isFullBlock [
	^true
]

{ #category : #accessing }
FullBlockClosure >> method [
	^startpcOrMethod
]

{ #category : #accessing }
FullBlockClosure >> numArgs: n [
	numArgs := n
]

{ #category : #accessing }
FullBlockClosure >> numTemps [
	^startpcOrMethod numTemps
]

{ #category : #accessing }
FullBlockClosure >> outerContext: ctxt [
	outerContext := ctxt
]

{ #category : #'initialize-release' }
FullBlockClosure >> outerContext: aContext startpc: aStartpc numArgs: argCount copiedValues: anArrayOrNil [
	self shouldNotImplement
]

{ #category : #private }
FullBlockClosure >> printOn: s [
	[ super printOn: s ] on: Error do: [ :ex | s << '![' << ex messageText << ']!' ]
]

{ #category : #accessing }
FullBlockClosure >> receiver [
	^ receiver
]

{ #category : #accessing }
FullBlockClosure >> receiver: anObject [
	receiver := anObject
]

{ #category : #'initialize-release' }
FullBlockClosure >> receiver: aReceiver outerContext: aContextOrNil method: aCompiledBlock copiedValues: anArrayOrNil [
	receiver := aReceiver.
	outerContext := aContextOrNil.
	startpcOrMethod := aCompiledBlock.
	numArgs := aCompiledBlock numArgs.
	1 to: self numCopiedValues do:
		[:i|
		self at: i put: (anArrayOrNil at: i)]
]

{ #category : #simulation }
FullBlockClosure >> simulateValueWithArguments: anArray caller: aContext [
	"Simulate the valueWithArguments: primitive. Fail if anArray is not an array of the right arity."
	| newContext |
	newContext := (Context newForMethod: startpcOrMethod)
						setSender: aContext
						receiver: receiver
						method: startpcOrMethod
						closure: self
						startpc: startpcOrMethod initialPC.
	((newContext objectClass: anArray) ~~ Array
	 or: [numArgs ~= anArray size]) ifTrue:
		[^Context primitiveFailTokenFor: nil].
	newContext stackp: startpcOrMethod numTemps.
	1 to: numArgs do:
		[:i| newContext at: i put: (anArray at: i)].
	1 to: self basicSize do:
		[:i| newContext at: i + numArgs put: (self at: i)].
	^newContext
]

{ #category : #accessing }
FullBlockClosure >> size [
	"Answer closure's bytecode size (number of bytes) by accessing
	 the closure's method."
	^startpcOrMethod endPC - startpcOrMethod initialPC + 1
]

{ #category : #accessing }
FullBlockClosure >> startpc [
	^startpcOrMethod initialPC
]

{ #category : #evaluating }
FullBlockClosure >> value [
	"Activate the receiver, creating a closure activation (MethodContext)
	 whose closure is the receiver and whose caller is the sender of this
	 message. Supply the copied values to the activation as its copied
	 temps. Primitive. Essential."
	<primitive: 207>
	| newContext |
	numArgs ~= 0 ifTrue:
		[self numArgsError: 0].
	false
		ifTrue: "Old code to simulate the closure value primitive on VMs that lack it."
			[newContext := self asContextWithSender: thisContext sender.
			thisContext privSender: newContext]
		ifFalse: [self primitiveFailed]
]

{ #category : #evaluating }
FullBlockClosure >> value: firstArg [
	"Activate the receiver, creating a closure activation (MethodContext)
	 whose closure is the receiver and whose caller is the sender of this
	 message. Supply the argument and copied values to the activation
	 as its argument and copied temps. Primitive. Essential."
	<primitive: 207>
	| newContext |
	numArgs ~= 1 ifTrue:
		[self numArgsError: 1].
	false
		ifTrue: "Old code to simulate the closure value primitive on VMs that lack it."
			[newContext := self asContextWithSender: thisContext sender.
			newContext at: 1 put: firstArg.
			thisContext privSender: newContext]
		ifFalse: [self primitiveFailed]
]

{ #category : #evaluating }
FullBlockClosure >> value: firstArg value: secondArg [
	"Activate the receiver, creating a closure activation (MethodContext)
	 whose closure is the receiver and whose caller is the sender of this
	 message. Supply the arguments and copied values to the activation
	 as its arguments and copied temps. Primitive. Essential."
	<primitive: 207>
	| newContext |
	numArgs ~= 2 ifTrue:
		[self numArgsError: 2].
	false
		ifTrue: "Old code to simulate the closure value primitive on VMs that lack it."
			[newContext := self asContextWithSender: thisContext sender.
			newContext at: 1 put: firstArg.
			newContext at: 2 put: secondArg.
			thisContext privSender: newContext]
		ifFalse: [self primitiveFailed]
]

{ #category : #evaluating }
FullBlockClosure >> value: firstArg value: secondArg value: thirdArg [
	"Activate the receiver, creating a closure activation (MethodContext)
	 whose closure is the receiver and whose caller is the sender of this
	 message. Supply the arguments and copied values to the activation
	 as its arguments and copied temps. Primitive. Essential."
	<primitive: 207>
	| newContext |
	numArgs ~= 3 ifTrue:
		[self numArgsError: 3].
	false
		ifTrue: "Old code to simulate the closure value primitive on VMs that lack it."
			[newContext := self asContextWithSender: thisContext sender.
			newContext at: 1 put: firstArg.
			newContext at: 2 put: secondArg.
			newContext at: 3 put: thirdArg.
			thisContext privSender: newContext]
		ifFalse: [self primitiveFailed]
]

{ #category : #evaluating }
FullBlockClosure >> value: firstArg value: secondArg value: thirdArg value: fourthArg [
	"Activate the receiver, creating a closure activation (MethodContext)
	 whose closure is the receiver and whose caller is the sender of this
	 message. Supply the arguments and copied values to the activation
	 as its arguments and copied temps. Primitive. Essential."
	<primitive: 207>
	| newContext |
	numArgs ~= 4 ifTrue:
		[self numArgsError: 4].
	false
		ifTrue: "Old code to simulate the closure value primitive on VMs that lack it."
			[newContext := self asContextWithSender: thisContext sender.
			newContext at: 1 put: firstArg.
			newContext at: 2 put: secondArg.
			newContext at: 3 put: thirdArg.
			newContext at: 4 put: fourthArg.
			thisContext privSender: newContext]
		ifFalse: [self primitiveFailed]
]

{ #category : #evaluating }
FullBlockClosure >> value: firstArg value: secondArg value: thirdArg value: fourthArg value: fifthArg [
	"Activate the receiver, creating a closure activation (MethodContext)
	 whose closure is the receiver and whose caller is the sender of this
	 message. Supply the arguments and copied values to the activation
	 as its arguments and copied temps. Primitive. Essential."
	<primitive: 207>
	| newContext |
	numArgs ~= 5 ifTrue:
		[self numArgsError: 5].
	false
		ifTrue: "Old code to simulate the closure value primitive on VMs that lack it."
			[newContext := self asContextWithSender: thisContext sender.
			newContext at: 1 put: firstArg.
			newContext at: 2 put: secondArg.
			newContext at: 3 put: thirdArg.
			newContext at: 4 put: fourthArg.
			newContext at: 5 put: fifthArg.
			thisContext privSender: newContext]
		ifFalse: [self primitiveFailed]
]

{ #category : #evaluating }
FullBlockClosure >> valueNoContextSwitch [
	"An exact copy of BlockClosure>>value except that this version will not preempt
	 the current process on block activation if a higher-priority process is runnable.
	 Primitive. Essential."
	<primitive: 209>
	numArgs ~= 0 ifTrue:
		[self numArgsError: 0].
	self primitiveFailed
]

{ #category : #evaluating }
FullBlockClosure >> valueNoContextSwitch: anArg [
	"An exact copy of BlockClosure>>value: except that this version will not preempt
	 the current process on block activation if a higher-priority process is runnable.
	 Primitive. Essential."
	<primitive: 209>
	numArgs ~= 1 ifTrue:
		[self numArgsError: 1].
	self primitiveFailed
]

{ #category : #evaluating }
FullBlockClosure >> valueWithArguments: anArray [
	"Activate the receiver, creating a closure activation (MethodContext)
	 whose closure is the receiver and whose caller is the sender of this
	 message. Supply the arguments in an anArray and copied values to
	 the activation as its arguments and copied temps. Primitive. Essential."
	<primitive: 208>
	| newContext |
	numArgs ~= anArray size ifTrue:
		[self numArgsError: anArray size].
	false
		ifTrue: "Old code to simulate the closure value primitive on VMs that lack it."
			[newContext := self asContextWithSender: thisContext sender.
			1 to: numArgs do:
				[:i| newContext at: i put: (anArray at: i)].
			thisContext privSender: newContext]
		ifFalse: [self primitiveFailed]
]
