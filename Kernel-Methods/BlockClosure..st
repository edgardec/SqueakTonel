"
Instances of BlockClosure represent blocks, a sequence of statements inside square brackets that can be evaluated at any time via one of the value messages (value, value:, value:value:, ... valueWithArguments:), which answer their last statement.  Blocks therefore allow deferred evaluation and so are used to build control structures where a sequence of statements are evaluated or not depending on other values in the program.

Blocks can close over variables in their enclosing method or block.  The method in which a block is nested is called its home method.  Blocks can return from their home method via an up-arrow return, and return to the sender of the message that created the home method, just like a return from the method itself.  BlockClosures are fully first-class objects; they can outlive their enclosing method activation and be answered as results and/or assigned to variables.

BlockClosures are central to the implementation of control structures in Smalltalk.  The arguments to the conditional message ifTrue:ifFalse: are zero-argument blocks; the receiver of ifTrue:ifFalse: is a boolean which responds by evaluating ether the first argument or the second.  The bytecode compiler inlines blocks for certain selectors, compiling to conditional branch and branch bytecodes.  This is done for efficiency.  The full list of inlined messages can be found in MessageNode's MacroSelectors class variable (at time of writing ther=se are ifTrue:, ifFalse:, ifTrue:ifFalse:, ifFalse:ifTrue:, and:, or:, whileFalse:, whileTrue:, whileFalse, whileTrue, to:do:, to:by:do:, caseOf:, caseOf:otherwise:, ifNil:, ifNotNil:, ifNil:ifNotNil:, ifNotNil:ifNil: and repeat.

Examples (more can be found in BlockClosureTest's class comment):
	[1@2] value

	| counter |
	counter := 0.
	{ counter. (1 to: 10) collect: [:n| counter := counter + 1. n + counter]. counter }

	| fibonacciBlock |
	fibonacciBlock := [:n|
					n > 1 ifTrue: [(fibonacciBlock value: n - 1) + (fibonacciBlock value: n - 2)] ifFalse: [1]].
	(1 to: 10) collect: fibonacciBlock

	| randomNumbers |
	randomNumbers := Random new next: 20.
	{ randomNumbers. randomNumbers sorted: [:a :b| a > b] }

Implementation:
BlockClosure implements blocks that are nested within an enclosing method or block context.  Further, the bytecodes for the block are embedded within the home method.  BlockClosure's subclass FullBlockClosure has an independent CompiledBlock as its method, and may or may not have an outerContext.

Instance Variables
	numArgs:			<Integer>
	outerContext:		<Context>
	startpcOrMethod:	<Integer|CompiledBlock>

numArgs
	- the number of arguments the block expects

outerContext
	- the Context of the method or block activation in which the receiver is created

startpcOrMethod
	- in BlockClosure this is the pc of the first bytecode of the block.  Its bytecodes are embedded in the bytecodes of the home method.  In FullBlockClosure this is the block's method.
"
Class {
	#name : #BlockClosure,
	#superclass : #Object,
	#type : #variable,
	#instVars : [
		'outerContext',
		'startpcOrMethod',
		'numArgs'
	],
	#category : #'Kernel-Methods'
}

{ #category : #'instance creation' }
BlockClosure class >> outerContext: aContext startpc: aStartpc numArgs: argCount copiedValues: anArrayOrNil [
	^(self new: anArrayOrNil basicSize)
		outerContext: aContext
		startpc: aStartpc
		numArgs: argCount
		copiedValues: anArrayOrNil
]

{ #category : #comparing }
BlockClosure >> = aClosure [
	self == aClosure ifTrue: [^true].
	aClosure class = self class ifFalse: [^false].
	(self method == aClosure method and: [self startpc = aClosure startpc and: [self isClean]])
		ifTrue: [^true].
	^outerContext = aClosure outerContext and: [self startpc = aClosure startpc]
]

{ #category : #scanning }
BlockClosure >> abstractBytecodeMessagesDo: aBlock [
	"Evaluate aBlock with the sequence of abstract bytecodes in the receiver."
	self method
		abstractBytecodeMessagesFrom: startpcOrMethod
		to: self endPC
		do: aBlock

	"| msgs |
	 msgs := OrderedCollection new.
	 (SortedCollection sortBlock: [:a :b| a compare: b caseSensitive: false]) sortBlock
		abstractBytecodeMessagesDo: [:msg| msgs add: msg selector].
	 msgs"
]

{ #category : #accessing }
BlockClosure >> argumentCount [
	"Answers the number of arguments needed to evaluate the receiver.
	For ansi compatibility."
	^ self numArgs
]

{ #category : #scheduling }
BlockClosure >> asContext [
	"Create a Context that is ready to execute self.  Assumes self takes no args (if it does the args will be nil)"

	^self asContextWithSender: nil
]

{ #category : #private }
BlockClosure >> asContextWithSender: aContext [
	"Inner private support method for evaluation.  Do not use unless you know what you're doing."

	^(Context newForMethod: outerContext method)
		setSender: aContext
		receiver: outerContext receiver
		method: outerContext method
		closure: self
		startpc: startpcOrMethod;
		privRefresh
]

{ #category : #'events-support' }
BlockClosure >> asMinimalRepresentation [
	"For use in the when:evaluate: protocol, i.e.,
		foo when: #bar evaluate:[self handleBar].
	Return the receiver."
	^self
]

{ #category : #exceptions }
BlockClosure >> assert [
	self assert: self
]

{ #category : #scanning }
BlockClosure >> blockCreationBytecodeMessage [
	"Answer the abstract bytecode message that created the receiver."
	^self method abstractBytecodeMessageAt: self blockCreationPC

	"(SortedCollection sortBlock: [:a :b| a compare: b caseSensitive: false]) sortBlock blockCreationBytecodeMessage"
]

{ #category : #scanning }
BlockClosure >> blockCreationPC [
	"Answer the pc for the bytecode that created the receiver."
	| method |
	method := self method.
	^method encoderClass
		pcOfBlockCreationBytecodeForBlockStartingAt: startpcOrMethod
		in: method
]

{ #category : #accessing }
BlockClosure >> copiedValueAt: i [
	<primitive: 60>
	^self basicAt: i
]

{ #category : #private }
BlockClosure >> copyForSaving [
	"Answer a copy of the receiver suitable for serialization.
	 Notionally, if the receiver's outerContext has been returned from then nothing
	 needs to be done and we can use the receiver. But there's a race condition
	 determining if the receiver has been returned from (it could be executing in a
	 different process). So answer a copy anyway."
	^self shallowCopy postCopy
]

{ #category : #evaluating }
BlockClosure >> cull: firstArg [
	"Activate the receiver, with one or zero arguments."
	
	numArgs >= 1 ifTrue: [ ^self value: firstArg ].
	^self value
]

{ #category : #evaluating }
BlockClosure >> cull: firstArg cull: secondArg [
	"Activate the receiver, with two or less arguments."
	
	numArgs >= 2 ifTrue: [ ^self value: firstArg value: secondArg ].	
	numArgs = 1 ifTrue: [ ^self value: firstArg ].
	^self value
]

{ #category : #evaluating }
BlockClosure >> cull: firstArg cull: secondArg cull: thirdArg [
	"Activate the receiver, with three or less arguments."
	
	numArgs >= 2 ifTrue: [ 
		numArgs >= 3 ifTrue: [ ^self value: firstArg value: secondArg value: thirdArg ].
		^self value: firstArg value: secondArg ].
	numArgs = 1 ifTrue: [ ^self value: firstArg ].
	^self value
]

{ #category : #evaluating }
BlockClosure >> cull: firstArg cull: secondArg cull: thirdArg cull: fourthArg [
	"Activate the receiver, with four or less arguments."
	
	numArgs >= 3 ifTrue: [
		numArgs >= 4 ifTrue: [
			^self value: firstArg value: secondArg value: thirdArg value: fourthArg ].
		^self value: firstArg value: secondArg value: thirdArg ].
	numArgs = 2 ifTrue: [ ^self value: firstArg value: secondArg ].	
	numArgs = 1 ifTrue: [ ^self value: firstArg ].
	^self value
]

{ #category : #printing }
BlockClosure >> decompile [
	^Decompiler new decompileBlock: self
]

{ #category : #controlling }
BlockClosure >> doWhileFalse: conditionBlock [
	"Evaluate the receiver once, then again as long the value of conditionBlock is false."
 
	| result |
	[result := self value.
	conditionBlock value] whileFalse.

	^ result
]

{ #category : #controlling }
BlockClosure >> doWhileTrue: conditionBlock [
	"Evaluate the receiver once, then again as long the value of conditionBlock is true."
 
	| result |
	[result := self value.
	conditionBlock value] whileTrue.

	^ result
]

{ #category : #accessing }
BlockClosure >> endPC [
	^self blockCreationBytecodeMessage arguments last + startpcOrMethod - 1
]

{ #category : #exceptions }
BlockClosure >> ensure: aBlock [
	"Evaluate a termination block after evaluating the receiver, regardless of
	 whether the receiver's evaluation completes.  N.B.  This method is *not*
	 implemented as a primitive.  Primitive 198 always fails.  The VM uses prim
	 198 in a context's method as the mark for an ensure:/ifCurtailed: activation."

	| complete returnValue |
	<primitive: 198>
	returnValue := self valueNoContextSwitch.
	complete ifNil:[
		complete := true.
		aBlock value.
	].
	^ returnValue
]

{ #category : #private }
BlockClosure >> fixTemps [
	"Fix the values of the temporary variables used in the block that
	 are  ordinarily shared with the method in which the block is defined.
	 This is a no-op for closures, provided for backward-compatibility with
	 old BlockContexts that needed the fixTemps hack to persist."
]

{ #category : #scheduling }
BlockClosure >> fork [
	"Create and schedule a Process running the code in the receiver."

	^ self newProcess resume
]

{ #category : #scheduling }
BlockClosure >> forkAndWait [
	"Suspend current process and execute self in new process, when it completes resume current process"

	| semaphore |
	semaphore := Semaphore new.
	[self ensure: [semaphore signal]] fork.
	semaphore wait.

]

{ #category : #scheduling }
BlockClosure >> forkAt: priority [ 
	"Create and schedule a Process running the code in the receiver at the given priority. Answer the newly created process."

	^ self newProcess
		priority: priority;
		resume
]

{ #category : #scheduling }
BlockClosure >> forkAt: priority named: name [

	"Create and schedule a Process running the code in the receiver at the

	given priority and having the given name. Answer the newly created 

	process."



	| forkedProcess |

	forkedProcess := self newProcess.

	forkedProcess priority: priority.

	forkedProcess name: name.

	^ forkedProcess resume
]

{ #category : #scheduling }
BlockClosure >> forkNamed: aString [

	"Create and schedule a Process running the code in the receiver and

	having the given name."



	^ self newProcess name: aString; resume
]

{ #category : #printing }
BlockClosure >> fullPrintOn: aStream [ 
	aStream
		 print: self ;
		 cr.
	self printSourceOn: aStream
]

{ #category : #testing }
BlockClosure >> hasMethodReturn [
	"Answer whether the receiver has a method-return ('^') in its code."
	| scanner endpc |
	scanner := InstructionStream new method: outerContext method pc: startpcOrMethod.
	endpc := self endPC.
	scanner scanFor: [:byte | (byte between: 120 and: 124) or: [scanner pc > endpc]].
	^scanner pc <= endpc
]

{ #category : #comparing }
BlockClosure >> hash [
	^(self method hash + startpcOrMethod hash) hashMultiply
]

{ #category : #accessing }
BlockClosure >> home [
	^outerContext home
]

{ #category : #accessing }
BlockClosure >> homeMethod [
	^outerContext method
]

{ #category : #exceptions }
BlockClosure >> ifCurtailed: aBlock [
	"Evaluate the receiver with an abnormal termination action.
	 Evaluate aBlock only if execution is unwound during execution
	 of the receiver.  If execution of the receiver finishes normally do
	 not evaluate aBlock.  N.B.  This method is *not* implemented as a
	 primitive.  Primitive 198 always fails.  The VM uses prim 198 in a
	 context's method as the mark for an ensure:/ifCurtailed: activation."
	| complete result |
	<primitive: 198>
	result := self valueNoContextSwitch.
	complete := true.
	^result
]

{ #category : #evaluating }
BlockClosure >> ifError: errorHandlerBlock [
	"Evaluate the block represented by the receiver, and normally return it's value.  If an error occurs, the errorHandlerBlock is evaluated, and it's value is instead returned.  The errorHandlerBlock must accept zero, one, or two parameters (the error message and the receiver)."
	"Examples:
		[1 whatsUpDoc] ifError: [:err :rcvr | 'huh?'].
		[1 / 0] ifError: [:err :rcvr |
			'ZeroDivide' = err
				ifTrue: [Float infinity]
				ifFalse: [self error: err]]
"

	^ self on: Error do: [:ex |
		errorHandlerBlock cull: ex description cull: ex receiver ]
]

{ #category : #accessing }
BlockClosure >> isBlock [

	^ true
]

{ #category : #testing }
BlockClosure >> isClean [
	"Answer if the receiver does not close-over any variables other than globals, and does
	 not ^-return (does not close over the home context).  Clean blocks are amenable to
	 being created at compile-time."
	self numCopiedValues > 0 ifTrue:
		[^false].
	self abstractBytecodeMessagesDo:
		[:msg|
		(#(	pushReceiver
			pushReceiverVariable: popIntoReceiverVariable: storeIntoReceiverVariable:
			methodReturnConstant: methodReturnReceiver methodReturnTop)
				includes: msg selector) ifTrue:
					[^false]].
	^true

	"clean:"
		"[] isClean"
		"[:a :b| a < b] isClean"
	"unclean"
		"[^nil] isClean"
		"[self class] isClean"
		"| v | v := 0.
		 [v class] isClean"
]

{ #category : #testing }
BlockClosure >> isClosure [
	^true
]

{ #category : #testing }
BlockClosure >> isDead [
	"Has self finished"
	^false
]

{ #category : #testing }
BlockClosure >> isFullBlock [
	^false
]

{ #category : #testing }
BlockClosure >> isNestedWithin: aContextOrBlock [
	"Answer if the receiver is nested within aContextOrBlock, which may be ither a Context, or a BlockClosure."
	aContextOrBlock ifNotNil:
		[self outerContextsDo:
			[:ctxt|
			 (ctxt == aContextOrBlock
			  or: [ctxt closure = aContextOrBlock]) ifTrue: [^true]]].
	^false
]

{ #category : #'events-support' }
BlockClosure >> isReceiverOrAnyArgumentGarbage [
	"For use in the when:evaluate: protocol, i.e.,
		foo when: #bar evaluate:[self handleBar].."
	^false
]

{ #category : #accessing }
BlockClosure >> method [
	^outerContext method
]

{ #category : #scheduling }
BlockClosure >> newProcess [
	"Answer a Process running the code in the receiver. The process is not 
	scheduled."
	<primitive: 19> "Simulation guard"
	^Process
		forContext: 
			[self value.
			"Since control is now at the bottom there is no need to terminate (which
			 runs unwinds) since all unwnds have been run.  Simply suspend.
			 Note that we must use this form rather than e.g. Processor suspendActive
			 so that isTerminated answers true.  isTerminated requires that if there is a
			 suspended context it is the bottom-most, but using a send would result in
			 the process's suspendedContext /not/ being the bottom-most."
			Processor activeProcess suspend] asContext
		priority: Processor activePriority
]

{ #category : #scheduling }
BlockClosure >> newProcessWith: anArray [ 
	"Answer a Process running the code in the receiver. The receiver's block 
	arguments are bound to the contents of the argument, anArray. The 
	process is not scheduled."
	<primitive: 19> "Simulation guard"
	^Process
		forContext: 
			[self valueWithArguments: anArray.
			"Since control is now at the bottom there is no need to terminate (which
			 runs unwinds) since all unwnds have been run.  Simply suspend.
			 Note that we must use this form rather than e.g. Processor suspendActive
			 so that isTerminated answers true.  isTerminated requires that if there is a
			 suspended context it is the bottom-most, but using a send would result in
			 the process's suspendedContext /not/ being the bottom-most."
			Processor activeProcess suspend] asContext
		priority: Processor activePriority
]

{ #category : #accessing }
BlockClosure >> numArgs [
	"Answer the number of arguments that must be used to evaluate this block"

	^numArgs
]

{ #category : #'error handing' }
BlockClosure >> numArgsError: numArgsForInvocation [

	| printNArgs |
	printNArgs := [:n| n printString, ' argument', (n = 1 ifTrue: [''] ifFalse:['s'])]. 
	self error: 
			'This block accepts ', (printNArgs value: numArgs), 
			', but was called with ', (printNArgs value: numArgsForInvocation), '.'
]

{ #category : #accessing }
BlockClosure >> numCopiedValues [
	"Answer the number of copied values of the receiver.  Since these are
	 stored in the receiver's indexable fields this is the receiver's basic size.
	 Primitive. Answer the number of indexable variables in the receiver. 
	 This value is the same as the largest legal subscript."

	<primitive: 62>
	^self basicSize
]

{ #category : #accessing }
BlockClosure >> numTemps [
	"Answer the number of temporaries for the receiver; this includes
	 the number of arguments and the number of copied values."
	^self numCopiedValues
	 + self numArgs
	 + (BlockLocalTempCounter
			tempCountForBlockStartingAt: startpcOrMethod
			in: self method)
]

{ #category : #exceptions }
BlockClosure >> on: exceptionOrExceptionSet do: handlerAction [
	"Evaluate the receiver in the scope of an exception handler."

	| handlerActive |
	<primitive: 199>  "just a marker, fail and execute the following"
	handlerActive := true.
	^ self value
]

{ #category : #exceptions }
BlockClosure >> on: exception1 do: block1 on: exception2 do: block2 [

	^[
		self
			on: exception1
			do: block1 ]
		on: exception2
		do: block2
]

{ #category : #exceptions }
BlockClosure >> on: exception1 do: block1 on: exception2 do: block2 on: exception3 do: block3 [

	^[
		self
			on: exception1
			do: block1 ]
		on: exception2
		do: block2
		on: exception3
		do: block3
]

{ #category : #exceptions }
BlockClosure >> on: exceptionOrExceptionSet ensure: aBlock [

	^ self
		on: exceptionOrExceptionSet
		do: [:exception | 
			aBlock value.
			exception pass]
]

{ #category : #exceptions }
BlockClosure >> on: anException1 ensure: aBlock1 on: anException2 ensure: aBlock2 [

	^ [self on: anException1 ensure: aBlock1]
		on: anException2
		ensure: aBlock2
]

{ #category : #exceptions }
BlockClosure >> on: anException1 ensure: aBlock1 on: anException2 ensure: aBlock2 on: anException3 ensure: aBlock3 [

	^ [self on: anException1 ensure: aBlock1]
		on: anException2
		ensure: aBlock2
		on: anException3
		ensure: aBlock3
]

{ #category : #exceptions }
BlockClosure >> onDNU: selector do: handleBlock [
	"Catch MessageNotUnderstood exceptions but only those of the given selector (DNU stands for doesNotUnderstand:)"

	^ self on: MessageNotUnderstood do: [:exception |
		exception message selector = selector
			ifTrue: [handleBlock cull: exception]
			ifFalse: [exception pass]
	  ]
]

{ #category : #evaluating }
BlockClosure >> once [
	"Evaluate the receiver exactly once, so that repeated evaluations
	 answer exactly the same object as the first evaluation.  This
	 allows one to intern values with the idiom
		myResourceMethod
			^[expression] once"

	| cache |
	cache := self method
				propertyValueAt: #onceCache
				ifAbsent: [self method propertyValueAt: #onceCache put: IdentityDictionary new].
	^cache at: startpcOrMethod ifAbsentPut: [self value]
]

{ #category : #accessing }
BlockClosure >> outerContext [
	^outerContext
]

{ #category : #'initialize-release' }
BlockClosure >> outerContext: aContext startpc: aStartpc numArgs: argCount copiedValues: anArrayOrNil [
	outerContext := aContext.
	startpcOrMethod := aStartpc.
	numArgs := argCount.
	1 to: self numCopiedValues do:
		[:i|
		self at: i put: (anArrayOrNil at: i)]
]

{ #category : #private }
BlockClosure >> outerContextsDo: aBlock [
	"Evaluate aBlock with all the outer contexts along the receiver's static chain."
	| outer |
	outer := outerContext.
	[outer notNil] whileTrue:
		[aBlock value: outer.
		 outer := outer closure ifNotNil: [:outerClosure| outerClosure outerContext]]
]

{ #category : #printing }
BlockClosure >> printOn: aStream [
	aStream nextPutAll: '[closure] in '.
	outerContext printOn: aStream
]

{ #category : #printing }
BlockClosure >> printSourceOn: aStream [ 
	self decompile
		ifNil: [ aStream nextPutAll: '--source missing--' ]
		ifNotNil: [ : blockNode | blockNode printOn: aStream indent: 0 ]
]

{ #category : #accessing }
BlockClosure >> receiver [
	^outerContext receiver
]

{ #category : #private }
BlockClosure >> reentrant [
	"Answer a version of the recever that can be reentered.
	 Closures are reentrant (unlike BlockContext), so simply answer self."
	^self
]

{ #category : #controlling }
BlockClosure >> repeat [
	"Evaluate the receiver repeatedly, ending only if the block explicitly returns."

	[self value. true] whileTrue
]

{ #category : #controlling }
BlockClosure >> repeatWithGCIf: testBlock [
	| ans |
	"run the receiver, and if testBlock returns true, garbage collect and run the receiver again"
	ans := self value.
	(testBlock value: ans) ifTrue: [ Smalltalk garbageCollect. ans := self value ].
	^ans
]

{ #category : #'debugger access' }
BlockClosure >> sender [
	"Answer the context that sent the message that created the receiver."

	^outerContext sender
]

{ #category : #'system simulation' }
BlockClosure >> simulateValueWithArguments: anArray caller: aContext [
	"Simulate the valueWithArguments: primitive. Fail if anArray is not an array of the right arity."
	| newContext sz |
	newContext := (Context newForMethod: outerContext method)
						setSender: aContext
						receiver: outerContext receiver
						method: outerContext method
						closure: self
						startpc: startpcOrMethod.
	((newContext objectClass: anArray) ~~ Array
	 or: [numArgs ~= anArray size]) ifTrue:
		[^Context primitiveFailTokenFor: nil].
	sz := self basicSize.
	newContext stackp: sz + numArgs.
	1 to: numArgs do:
		[:i| newContext at: i put: (anArray at: i)].
	1 to: sz do:
		[:i| newContext at: i + numArgs put: (self at: i)].
	^newContext
]

{ #category : #accessing }
BlockClosure >> size [
	"Extract this closure's bytecode size (number of bytes) by accessing
	 the closure creation bytecode in the enclosing method."
	
	^self blockCreationBytecodeMessage arguments last
]

{ #category : #printing }
BlockClosure >> sourceString [
	^ String streamContents: [ : stream | self printSourceOn: stream ]
]

{ #category : #accessing }
BlockClosure >> startpc [
	^startpcOrMethod
]

{ #category : #'objects from disk' }
BlockClosure >> storeDataOn: aDataStream [
	"Blocks are allowed go to out in DataStreams, but only without home senders."

	| contexts |
	contexts := IdentitySet new.
	aDataStream insideASegment ifFalse:
		[self outerContextsDo:
			[:ctxt|
			 contexts add: ctxt.
			 aDataStream replace: ctxt sender with: nil]].
	^[super storeDataOn: aDataStream]
		on: Notification
		do: [:ex|
			(contexts includes: ex tag)
				ifTrue: [ex resume: ex tag]
				ifFalse: [ex pass]]
]

{ #category : #evaluating }
BlockClosure >> value [
	"Activate the receiver, creating a closure activation (Context)
	 whose closure is the receiver and whose caller is the sender of this
	 message. Supply the copied values to the activation as its copied
	 temps. Primitive. Essential."
	<primitive: 201>
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
BlockClosure >> value: firstArg [
	"Activate the receiver, creating a closure activation (Context)
	 whose closure is the receiver and whose caller is the sender of this
	 message. Supply the argument and copied values to the activation
	 as its argument and copied temps. Primitive. Essential."
	<primitive: 202>
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
BlockClosure >> value: firstArg value: secondArg [
	"Activate the receiver, creating a closure activation (Context)
	 whose closure is the receiver and whose caller is the sender of this
	 message. Supply the arguments and copied values to the activation
	 as its arguments and copied temps. Primitive. Essential."
	<primitive: 203>
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
BlockClosure >> value: firstArg value: secondArg value: thirdArg [
	"Activate the receiver, creating a closure activation (Context)
	 whose closure is the receiver and whose caller is the sender of this
	 message. Supply the arguments and copied values to the activation
	 as its arguments and copied temps. Primitive. Essential."
	<primitive: 204>
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
BlockClosure >> value: firstArg value: secondArg value: thirdArg value: fourthArg [
	"Activate the receiver, creating a closure activation (Context)
	 whose closure is the receiver and whose caller is the sender of this
	 message. Supply the arguments and copied values to the activation
	 as its arguments and copied temps. Primitive. Essential."
	<primitive: 205>
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
BlockClosure >> value: firstArg value: secondArg value: thirdArg value: fourthArg value: fifthArg [
	"Activate the receiver, creating a closure activation (Context)
	 whose closure is the receiver and whose caller is the sender of this
	 message. Supply the arguments and copied values to the activation
	 as its arguments and copied temps. Primitive. Essential."
	<primitive: 205>
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
BlockClosure >> valueAt: blockPriority [ 
	"Evaluate the receiver (block), with another priority as the actual one 
	and restore it afterwards. The caller should be careful with using 
	higher priorities."
	| activeProcess result outsidePriority |
	activeProcess := Processor activeProcess.
	outsidePriority := activeProcess priority.
	activeProcess priority: blockPriority.
	result := self ensure: [activeProcess priority: outsidePriority].
	"Yield after restoring lower priority to give the preempted processes a  
	chance to run."
	blockPriority > outsidePriority
		ifTrue: [Processor yield].
	^ result
]

{ #category : #evaluating }
BlockClosure >> valueNoContextSwitch [
	"An exact copy of BlockClosure>>value except that this version will not preempt
	 the current process on block activation if a higher-priority process is runnable.
	 Primitive. Essential."
	<primitive: 221>
	numArgs ~= 0 ifTrue:
		[self numArgsError: 0].
	self primitiveFailed
]

{ #category : #evaluating }
BlockClosure >> valueNoContextSwitch: anArg [
	"An exact copy of BlockClosure>>value: except that this version will not preempt
	 the current process on block activation if a higher-priority process is runnable.
	 Primitive. Essential."
	<primitive: 222>
	numArgs ~= 1 ifTrue:
		[self numArgsError: 1].
	self primitiveFailed
]

{ #category : #evaluating }
BlockClosure >> valueOtherwise: aBlock [
	"Send the message and answer the return value"

	^self value
]

{ #category : #evaluating }
BlockClosure >> valueSupplyingAnswer: anObject [

	^ (anObject isCollection and: [anObject isString not])
		ifTrue: [self valueSupplyingAnswers: {anObject}]
		ifFalse: [self valueSupplyingAnswers: {{'*'. anObject}}]
]

{ #category : #evaluating }
BlockClosure >> valueSupplyingAnswers: aListOfPairs [
	"Evaluate the receiver using a list of questions / answers that might be called upon to automatically respond to Object>>confirm: or FillInTheBlank requests"

	^ self on: ProvideAnswerNotification do: [ :notification |
		| caption |
		caption := notification messageText withSeparatorsCompacted. "to remove new lines"
		aListOfPairs
			detect: [ :each |
				caption = each first
					or: [ (caption includesSubstring: each first caseSensitive: false)
					or: [ (each first match: caption)
					or: [ (caption respondsTo: #matchesRegex:) 
						and: [ [caption matchesRegex: each first] ifError: [false] ] ] ] ] ]
			ifFound: [ :answer | notification resume: answer second ]
			ifNone: [ notification pass ] ]
]

{ #category : #evaluating }
BlockClosure >> valueSuppressingAllMessages [

	^ self valueSuppressingMessages: #('*')
]

{ #category : #evaluating }
BlockClosure >> valueSuppressingMessages: aListOfStrings [

	^ self
		valueSuppressingMessages: aListOfStrings
		supplyingAnswers: #()
]

{ #category : #evaluating }
BlockClosure >> valueSuppressingMessages: aListOfStrings supplyingAnswers: aListOfPairs [

	^ self valueSupplyingAnswers: aListOfPairs, (aListOfStrings collect: [:each | {each. true}])
]

{ #category : #exceptions }
BlockClosure >> valueUninterruptably [
	"Prevent remote returns from escaping the sender.  Even attempts to terminate (unwind) this process will be halted and the process will resume here.  A terminate message is needed for every one of these in the sender chain to get the entire process unwound."

	^ self ifCurtailed: [^ self]
]

{ #category : #private }
BlockClosure >> valueUnpreemptively [
	"Evaluate the receiver (block), without the possibility of preemption by higher priority processes. Use this facility VERY sparingly!"
	"Think about using Block>>valueUninterruptably first, and think about using Semaphore>>critical: before that, and think about redesigning your application even before that! 
	After you've done all that thinking, go right ahead and use it..."
	| activeProcess oldPriority result |
	activeProcess := Processor activeProcess.
	oldPriority := activeProcess priority.
	activeProcess priority: Processor highestPriority.
	result := self ensure: [activeProcess priority: oldPriority].
	"Yield after restoring priority to give the preempted processes a chance to run"
	Processor yield.
	^result
]

{ #category : #evaluating }
BlockClosure >> valueWithArguments: anArray [
	"Activate the receiver, creating a closure activation (Context)
	 whose closure is the receiver and whose caller is the sender of this
	 message. Supply the arguments in an anArray and copied values to
	 the activation as its arguments and copied temps. Primitive. Essential."
	<primitive: 206>
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

{ #category : #evaluating }
BlockClosure >> valueWithArguments: anArray otherwise: aBlock [

	^ self valueWithArguments: anArray
]

{ #category : #evaluating }
BlockClosure >> valueWithEnoughArguments: anArray [
	"call me with enough arguments from anArray"
	| args |
	(anArray size == self numArgs)
		ifTrue: [ ^self valueWithArguments: anArray ].

	args := Array new: self numArgs.
	args replaceFrom: 1
		to: (anArray size min: args size)
		with: anArray
		startingAt: 1.

	^ self valueWithArguments: args
]

{ #category : #evaluating }
BlockClosure >> valueWithExit [ 
	  self value: [ ^nil ]
]

{ #category : #evaluating }
BlockClosure >> valueWithPossibleArgs: anArray [ 

	^numArgs = 0
		ifTrue: [self value]
		ifFalse:
			[self valueWithArguments:
				(numArgs = anArray size
					ifTrue: [anArray]
					ifFalse:
						[numArgs > anArray size
							ifTrue: [anArray, (Array new: numArgs - anArray size)]
							ifFalse: [anArray copyFrom: 1 to: numArgs]])]
]

{ #category : #evaluating }
BlockClosure >> valueWithPossibleArgument: anArg [ 
	"Evaluate the block represented by the receiver. If the block requires one argument, use anArg, if it requires more than one, fill up the rest with nils. See also #cull: if you want to raise an exception for incompatible blocks instead."

	| a |
	numArgs = 0 ifTrue: [^self value].
	numArgs = 1 ifTrue: [^self value: anArg].
	a := Array new: numArgs.
	a at: 1 put: anArg.
	^self valueWithArguments: a
]

{ #category : #controlling }
BlockClosure >> whileFalse [
	"Ordinarily compiled in-line, and therefore not overridable.
	This is in case the message is sent to other than a literal block.
	Evaluate the receiver, as long as its value is false."
 
	^ [self value] whileFalse: []
]

{ #category : #controlling }
BlockClosure >> whileFalse: aBlock [ 
	"Ordinarily compiled in-line, and therefore not overridable.
	This is in case the message is sent to other than a literal block.
	Evaluate the argument, aBlock, as long as the value of the receiver is false."

	^ [self value] whileFalse: [aBlock value]
]

{ #category : #controlling }
BlockClosure >> whileNil [
	"Unlike #whileTrue/False this is not compiled inline."
	| result |
	[(result := self value) isNil] whileTrue.
	^ result
	
]

{ #category : #controlling }
BlockClosure >> whileNil: aBlock [ 
	"Unlike #whileTrue/False: this is not compiled inline."
	| result |
	[(result := self value) isNil] whileTrue: [aBlock value].
	^ result
	
]

{ #category : #controlling }
BlockClosure >> whileNotNil: aBlock [ 
	"Unlike #whileTrue/False: this is not compiled inline."
	^ [self value notNil] whileTrue: [aBlock value]
	
]

{ #category : #controlling }
BlockClosure >> whileTrue [
	"Ordinarily compiled in-line, and therefore not overridable.
	This is in case the message is sent to other than a literal block.
	Evaluate the receiver, as long as its value is true."
 
	^ [self value] whileTrue: []
]

{ #category : #controlling }
BlockClosure >> whileTrue: aBlock [ 
	"Ordinarily compiled in-line, and therefore not overridable.
	This is in case the message is sent to other than a literal block.
	Evaluate the argument, aBlock, as long as the value of the receiver is true."

	^ [self value] whileTrue: [aBlock value]
]
