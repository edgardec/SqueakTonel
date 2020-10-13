"
My instances hold all the dynamic state associated with the execution of either a method activation resulting from a message send or a block activation resulting from a block evaluation.  In addition to their inherited state, this includes the receiver (self), the closure for a BlockClosure activation (which is nil for a method activation), a CompiledMethod, and space in the variable part of the context for arguments, temporary variables, and intermediate results, and the stack pointer to the top of stack in this variable part.

Contexts are created automatically (at least conceptually (*)) whenever a message send activates a method, or a block evaluation activates a block.  The current context can always be accessed via the thisContext pseudo-variable.  For example, explore the following:
	{ thisContext. thisContext copy. thisContext method. thisContext pc. thisContext receiver. thisContext stackPtr. thisContext sender }.

Contexts refer to the context in which they were created via the sender inst var.  An execution stack is made up of of a linked list of contexts, linked through their sender inst var. Returning involves returning back to the sender.  When a context is returned from its sender and pc are nilled, and, if the context is still referred to, the virtual machine guarantees to preserve only the arguments after a return.  A Smalltalk Process is simply a chain of contexts specific to that process.  The debugger is essentially a Process inspector.  Stepping in the debugger is done by sending messages to contexts to get them to execute their bytecodes.  See methods in the instruction decoding protocol.

Contexts, though normal in their variable size, are actually only used in two sizes, small and large, which are determined by the temporary space required by the method being executed.

Contexts must only be created using the method newForMethod:.  Note that it is impossible to determine the real object size of a Context except by asking for the frameSize of its method.  Any fields above the stack pointer (stackp) are truly invisible -- even (and especially!) to the garbage collector.  Any store into stackp other than by the primitive method stackp: is potentially fatal.

(*) efficient virtual machines create contexts lazily on demand, avoiding the overhead of creating them on every message send and of copying receiver and arguments from sender context to caller context.  This optimization is invisible to the Smalltalk system.
"
Class {
	#name : #Context,
	#superclass : #InstructionStream,
	#type : #variable,
	#instVars : [
		'stackp',
		'method',
		'closureOrNil',
		'receiver'
	],
	#classVars : [
		'MaxLengthForASingleDebugLogReport',
		'MaxStackDepthForASingleDebugLogReport',
		'PrimitiveFailToken',
		'QuickStep',
		'ValueIndex'
	],
	#category : #'Kernel-Methods'
}

{ #category : #enumerating }
Context class >> allInstances [
	"Answer all instances of the receiver."
	<primitive: 177>
	"The primitive can fail because memory is low.  If so, fall back on the old
	 enumeration code, which gives the system a chance to GC and/or grow.
	 Because aBlock might change the class of inst (for example, using become:),
	 it is essential to compute next before aBlock value: inst.
	 Only count until thisContext since this context has been created only to
	 compute the existing instances."
	| inst insts next |
	insts := WriteStream on: (Array new: 64).
	inst := self someInstance.
	[inst == thisContext or: [inst == nil]] whileFalse:
		[next := inst nextInstance.
		 insts nextPut: inst.
		 inst := next].
	^insts contents
]

{ #category : #private }
Context class >> allInstancesDo: aBlock [
	"Evaluate aBlock with each of the current instances of the receiver."
	| instances inst next |
	instances := self allInstancesOrNil.
	instances ifNotNil:
		[instances do: aBlock.
		 ^self].
	"allInstancesOrNil can fail because memory is low.  If so, fall back on the old
	 enumeration code.  Because aBlock might change the class of inst (for example,
	 using become:), it is essential to compute next before aBlock value: inst.
	 Only count until thisContext since evaluation of aBlock will create new contexts."
	inst := self someInstance.
	[inst == thisContext or: [inst == nil]] whileFalse:
		[next := inst nextInstance.
		 aBlock value: inst.
		 inst := next]
]

{ #category : #'instance creation' }
Context class >> basicNew: size [ 
	^ (size = CompiledMethod smallFrameSize or: [ size = CompiledMethod fullFrameSize ])
		ifTrue: [ super basicNew: size ]
		ifFalse: [ self error: 'Contexts must be ' , CompiledMethod smallFrameSize , ' or ' , CompiledMethod fullFrameSize , ' bytes.' ]
]

{ #category : #private }
Context class >> carefullyPrint: anObject on: aStream [
	aStream nextPutAll: ([anObject printString]
		on: Error
		do: ['unprintable ' , anObject class name])
]

{ #category : #'special context creation' }
Context class >> contextEnsure: block [
	"Create an #ensure: context that is ready to return from executing its receiver.
	
	As ctxt is *not* a top context as required by #jump, we need to put a (fake) return value (nil) on its stack. Otherwise, #jump will pop something different from the stack. Concretely, this caused the bug described in [1] (Scenario 1) because the latest stack top was the closure vector {chain}. This closure vector was accidently popped away so that in the final return statement, #pushRemoteTemp:inVectorAt: raised an error subscript bounds (because the next stack item was not variable). Read the linked bug report for more details.

	[1] http://forum.world.st/BUG-s-in-Context-control-jump-runUntilErrorOrReturnFrom-td5107263.html"

	| ctxt chain |
	ctxt := thisContext.
	[chain := thisContext sender cut: ctxt.
	ctxt push: nil. "fake return value"
	ctxt jump] ensure: block.
	"jump above will resume here without unwinding chain"
	^ chain
]

{ #category : #'special context creation' }
Context class >> contextOn: exceptionClass do: block [
	"Create an #on:do: context that is ready to return from executing its receiver.
	
	As ctxt is *not* a top context as required by #jump, we need to put a (fake) return value (nil) on its stack. Otherwise, #jump will pop something different from the stack. Concretely, this caused the bug described in [1] (Scenario 1) because the latest stack top was the closure vector {chain}. This closure vector was accidently popped away so that in the final return statement, #pushRemoteTemp:inVectorAt: raised an error subscript bounds (because the next stack item was not variable). Read the linked bug report for more details.

	[1] http://forum.world.st/BUG-s-in-Context-control-jump-runUntilErrorOrReturnFrom-td5107263.html"

	| ctxt chain |
	ctxt := thisContext.
	[chain := thisContext sender cut: ctxt.
	ctxt push: nil. "fake return value"
	ctxt jump] on: exceptionClass do: block.
	"jump above will resume here without unwinding chain"
	^ chain
]

{ #category : #'class initialization' }
Context class >> initialize [
	ValueIndex := 2.
	self assert: (Association instVarNameForIndex:ValueIndex) = 'value'.
	PrimitiveFailToken class ~~ Object ifTrue:
		[PrimitiveFailToken := Object new]
]

{ #category : #'instance creation' }
Context class >> initializedInstance [
	^ nil
]

{ #category : #private }
Context class >> isContextClass [
	^true
]

{ #category : #preferences }
Context class >> maxLengthForASingleDebugLogReport [
	<preference: 'Max. Debug Report Length'
		category: 'debug'
		description: 'The description of an Exception stack will be truncated so as to not exceed this value'
		type: #Number>
	^MaxLengthForASingleDebugLogReport ifNil: [40000]
]

{ #category : #preferences }
Context class >> maxLengthForASingleDebugLogReport: anInteger [
	MaxLengthForASingleDebugLogReport := anInteger
]

{ #category : #preferences }
Context class >> maxStackDepthForASingleDebugLogReport [
	<preference: 'Max. Debug Report Stack Depth'
		category: 'debug'
		description: 'In an exception stack, any sender deeper than this value will not be logged.'
		type: #Number>
	^MaxStackDepthForASingleDebugLogReport ifNil: [60]
]

{ #category : #preferences }
Context class >> maxStackDepthForASingleDebugLogReport: anInteger [
	MaxStackDepthForASingleDebugLogReport := anInteger
]

{ #category : #'instance creation' }
Context class >> new [

	self error: 'Contexts must only be created with newForMethod:'
]

{ #category : #'instance creation' }
Context class >> new: size [

	self error: 'Contexts must only be created with newForMethod:'
]

{ #category : #'instance creation' }
Context class >> newForMethod: aMethod [
	"This is the only method for creating new contexts, other than primitive cloning.
	Any other attempts, such as inherited methods like shallowCopy, should be
	avoided or must at least be rewritten to determine the proper size from the
	method being activated.  This is because asking a context its size (even basicSize!)
	will not return the real object size but only the number of fields currently
	accessible, as determined by stackp."

	^ super basicNew: aMethod frameSize
]

{ #category : #simulation }
Context class >> primitiveFailToken [

	^ PrimitiveFailToken
]

{ #category : #simulation }
Context class >> primitiveFailTokenFor: errorCode [

	^{PrimitiveFailToken. errorCode}
]

{ #category : #simulation }
Context class >> runSimulated: aBlock [
	"Simulate the execution of the argument, current. Answer the result it 
	returns."

	^ thisContext sender
		runSimulated: aBlock
		contextAtEachStep: [:ignored]

	"Context runSimulated: [Pen new defaultNib: 5; go: 100]"
]

{ #category : #'instance creation' }
Context class >> sender: s receiver: r method: m arguments: args [ 
	"Answer an instance of me with attributes set to the arguments."

	^(self newForMethod: m) setSender: s receiver: r method: m arguments: args
]

{ #category : #examples }
Context class >> tallyInstructions: aBlock [
	"This method uses the simulator to count the number of occurrences of
	each of the Smalltalk instructions executed during evaluation of aBlock.
	Results appear in order of the byteCode set."
	| tallies |
	tallies := Bag new.
	thisContext sender
		runSimulated: aBlock
		contextAtEachStep:
			[:current | tallies add: current nextByte].
	^tallies sortedElements

	"Context tallyInstructions: [3.14159 printString]"
]

{ #category : #examples }
Context class >> tallyMethods: aBlock [
	"This method uses the simulator to count the number of calls on each method
	invoked in evaluating aBlock. Results are given in order of decreasing counts."
	| prev tallies |
	tallies := Bag new.
	prev := aBlock.
	thisContext sender
		runSimulated: aBlock
		contextAtEachStep:
			[:current |
			current == prev ifFalse: "call or return"
				[prev sender == nil ifFalse: "call only"
					[tallies add: current printString].
				prev := current]].
	^tallies sortedCounts

	"Context tallyMethods: [3.14159 printString]"
]

{ #category : #'special context creation' }
Context class >> theReturnMethod [

	| meth |
	meth := self lookupSelector: #return:.
	meth primitive = 0 ifFalse: [^ self error: 'expected #return: to not be a primitive'].
	^ meth
]

{ #category : #examples }
Context class >> trace: aBlock [		"Context trace: [3 factorial]"
	"This method uses the simulator to print calls and returned values in the Transcript."

	Transcript clear.
	^ self trace: aBlock on: Transcript
]

{ #category : #examples }
Context class >> trace: aBlock on: aStream [		"Context trace: [3 factorial]"
	"This method uses the simulator to print calls to a file."
	| prev |
	prev := aBlock.
	^ thisContext sender
		runSimulated: aBlock
		contextAtEachStep:
			[:current |
			Sensor anyButtonPressed ifTrue: [^ nil].
			current == prev
				ifFalse:
					[prev sender ifNil:
						[aStream space; nextPut: $^.
						self carefullyPrint: current top on: aStream].
					aStream cr.
					(current depthBelow: aBlock) timesRepeat: [aStream space].
					self carefullyPrint: current receiver on: aStream.
					aStream space; nextPutAll: current selector; flush.
					prev := current]]
]

{ #category : #examples }
Context class >> trace: aBlock onFileNamed: fileName [
	"Context trace: [3 factorial] onFileNamed: 'trace'"
	"This method uses the simulator to print calls to a file."

	^FileStream fileNamed: fileName do: [ :file |
		self trace: aBlock on: file ]
]

{ #category : #private }
Context >> aboutToReturn: result through: firstUnwindContext [ 
	"Called from VM when an unwindBlock is found between self and its home.
	 Return to home's sender, executing unwind blocks on the way."

	self methodReturnContext return: result through: firstUnwindContext
]

{ #category : #controlling }
Context >> activateMethod: newMethod withArgs: args receiver: rcvr class: class [ 
	"Answer a Context initialized with the arguments."

	^Context 
		sender: self
		receiver: rcvr
		method: newMethod
		arguments: args
]

{ #category : #private }
Context >> activateReturn: aContext value: value [
	"Activate 'aContext return: value' in place of self, so execution will return to aContext's sender"

	^Context 
		sender: self
		receiver: aContext
		method: Context theReturnMethod
		arguments: {value}
]

{ #category : #accessing }
Context >> activeHome [
	"If executing closure, search senders for the activation of the original
	 (outermost) method that (indirectly) created my closure (the closureHome).
	 If the closureHome is not found on the sender chain answer nil."

	| methodReturnContext |
	self isExecutingBlock ifFalse: [^self].
	self sender ifNil: [^nil].
	methodReturnContext := self methodReturnContext.
	^self sender findContextSuchThat: [:ctxt | ctxt = methodReturnContext]
]

{ #category : #accessing }
Context >> activeOuterContext [
	"If executing closure, search senders for the activation in which the receiver's
	 closure was created (the receiver's outerContext).  If the outerContext is not
	 found on the sender chain answer nil."

	| outerContext |
	self isExecutingBlock ifFalse: [^self].
	self sender ifNil: [^nil].
	outerContext := self outerContext.
	^self sender findContextSuchThat: [:ctxt | ctxt = outerContext]
]

{ #category : #'private-debugger' }
Context >> actualStackSize [ "For use only by Debugger, Inspectors etc"
	^ stackp - method numTemps
]

{ #category : #accessing }
Context >> arguments [
	"Answer the receiver's arguments as an Array.
	 We could use simply ^(1 to: self numArgs) collect: [:i| self tempAt: i]
	 but for performance and minimality we use the implementation below."
	| n args |
	args := Array new: (n := self numArgs).
	1 to: n do: [:i| args at: i put: (self tempAt: i)].
	^args
]

{ #category : #'closure support' }
Context >> asContext [

	^ self
]

{ #category : #converting }
Context >> asMessage [
	| selector args |
	selector := sender method selector.
	args := Array new: selector numArgs.
	1 to: selector numArgs do: [ :i | args at: i put: (sender tempAt: i)].
	^ Message selector: selector arguments: args.
]

{ #category : #accessing }
Context >> at: index [
	"Primitive. Assumes receiver is indexable. Answer the value of an
	 indexable element in the receiver. Fail if the argument index is not an
	 Integer or is out of bounds. Essential. See Object documentation
	 whatIsAPrimitive.  Override the default primitive to give latitude to
	 the VM in context management."

	<primitive: 210>
	index isInteger ifTrue:
		[self errorSubscriptBounds: index].
	index isNumber
		ifTrue: [^self at: index asInteger]
		ifFalse: [self errorNonIntegerIndex]
]

{ #category : #accessing }
Context >> at: index put: value [
	"Primitive. Assumes receiver is indexable. Answer the value of an
	 indexable element in the receiver. Fail if the argument index is not
	 an Integer or is out of bounds. Essential. See Object documentation
	 whatIsAPrimitive.  Override the default primitive to give latitude to
	 the VM in context management."

	<primitive: 211>
	index isInteger ifTrue:
		[self errorSubscriptBounds: index].
	index isNumber
		ifTrue: [^self at: index asInteger put: value]
		ifFalse: [self errorNonIntegerIndex]
]

{ #category : #testing }
Context >> atEnd [
	^ self isExecutingBlock
		ifTrue: [ self closure startpc + self closure size - 1 = self pc ]
		ifFalse: [ self pc >= self method endPC ]
]

{ #category : #'read-only objects' }
Context >> attemptToAssign: value to: anObject withIndex: index [
	"Sent by the execution simulation machinery when attempting to assign an instance
	 variable of an read-only object.  This mimics the VM's send of attemptToAssign:withIndex:
	 when trying to do the same. Upon return, executing will resume *after* the inst var assignment.
	 This method differs from Object>>attemptToAssign:withIndex: in not doing a Context>>jump,
	 which does not simulate properly."
	
	self modificationForbiddenFor: anObject instVarAt: index put: value
]

{ #category : #accessing }
Context >> basicAt: index [
	"Primitive. Assumes receiver is indexable. Answer the value of an
	 indexable element in the receiver. Fail if the argument index is not an
	 Integer or is out of bounds. Essential. See Object documentation
	 whatIsAPrimitive.  Override the default primitive to give latitude to
	 the VM in context management."

	<primitive: 210>
	index isInteger ifTrue:
		[self errorSubscriptBounds: index].
	index isNumber
		ifTrue: [^self at: index asInteger]
		ifFalse: [self errorNonIntegerIndex]
]

{ #category : #accessing }
Context >> basicAt: index put: value [
	"Primitive. Assumes receiver is indexable. Answer the value of an
	 indexable element in the receiver. Fail if the argument index is not
	 an Integer or is out of bounds. Essential. See Object documentation
	 whatIsAPrimitive.  Override the default primitive to give latitude to
	 the VM in context management."

	<primitive: 211>
	index isInteger ifTrue:
		[self errorSubscriptBounds: index].
	index isNumber
		ifTrue: [^self at: index asInteger put: value]
		ifFalse: [self errorNonIntegerIndex]
]

{ #category : #accessing }
Context >> basicSize [
	"Primitive. Answer the number of indexable variables in the receiver. 
	This value is the same as the largest legal subscript. Essential. Do not 
	override in any subclass. See Object documentation whatIsAPrimitive.  Override the default primitive to give latitude to
	 the VM in context management."

	<primitive: 212>
	"The number of indexable fields of fixed-length objects is 0"
	^self primitiveFailed
]

{ #category : #'instruction decoding' }
Context >> blockReturnConstant: value [
	"Simulate the interpreter's action when a ReturnConstantToCaller bytecode is 
	 encountered in the receiver.  This should only happen in a closure activation."
	self assert: closureOrNil isClosure.
	^self return: value from: self
]

{ #category : #'instruction decoding' }
Context >> blockReturnTop [
	"Simulate the interpreter's action when a ReturnTopOfStackToCaller bytecode is 
	 encountered in the receiver.  This should only happen in a closure activation."
	self assert: closureOrNil isClosure.
	^self return: self pop from: self
]

{ #category : #query }
Context >> bottomContext [
	"Return the last context (the first context invoked) in my sender chain"

	^ self findContextSuchThat: [:c | c sender isNil]
]

{ #category : #'instruction decoding' }
Context >> callPrimitive: primNumber [
	"Evaluate the primitive, either normal or inlined, and answer the new context resulting from that
	 (either the sender if a successful non-inlined primitive, or the current context, if not)."
	| maybePrimFailToken |
	primNumber >= (1 << 15) ifTrue: "Inlined primitive, cannot fail"
		[^self callInlinedPrimitive: primNumber].
	maybePrimFailToken := self doPrimitive: primNumber
								method: method
								receiver: receiver
								args: self arguments.
	"Normal primitive. Always at the beginning of methods."
	(self isPrimFailToken: maybePrimFailToken) ifFalse: "On success return the result"
		[^self methodReturnTop].
	"On failure, store the error code if appropriate and keep interpreting the method"
	(method encoderClass isStoreAt: pc in: method) ifTrue:
		[self at: stackp put: maybePrimFailToken last].
	^self
]

{ #category : #'private-exceptions' }
Context >> canHandleSignal: exception [
	"Sent to handler (on:do:) contexts only.  If my exception class (first arg) handles exception then return true, otherwise forward this message to the next handler context.  If none left, return false (see nil>>canHandleSignal:)"

	^ (((self tempAt: 1) handles: exception) and: [self tempAt: 3])
		or: [self nextHandlerContext canHandleSignal: exception].

]

{ #category : #'private-exceptions' }
Context >> cannotReturn: result [

	closureOrNil notNil ifTrue:
		[^self cannotReturn: result to: self home sender].
	Processor activeProcess
		debug: thisContext
		title: 'computation has been terminated'
		full: false.
]

{ #category : #private }
Context >> cannotReturn: result to: homeContext [
	"The receiver tried to return result to homeContext that no longer exists."

	^ BlockCannotReturn new
		result: result;
		deadHome: homeContext;
		signal
]

{ #category : #accessing }
Context >> client [
	"Answer the client, that is, the object that sent the message that created this context."

	^sender receiver
]

{ #category : #accessing }
Context >> closure [
	^closureOrNil
]

{ #category : #'system simulation' }
Context >> completeCallee: aContext [
	"Simulate the execution of bytecodes until a return to the receiver."
	| ctxt current ctxt1 |
	ctxt := aContext.
	[ctxt == current or: [ctxt hasSender: self]]
		whileTrue: 
			[current := ctxt.
			ctxt1 := ctxt quickStep.
			ctxt1 ifNil: [self halt].
			ctxt := ctxt1].
	^self stepToSendOrReturn
]

{ #category : #accessing }
Context >> contextForLocalVariables [
	"Answer the context in which local variables (temporaries) are stored."

	self subclassResponsibility
]

{ #category : #'debugger access' }
Context >> contextStack [ 
	"Answer an Array of the contexts on the receiver's sender chain."

	^self stackOfSize: 100000
]

{ #category : #'closure support' }
Context >> contextTag [
	"Context tags may be used for referring to contexts instead of contexts themselves as they can be copied and will continue to work in other processes (continuations). By default, we use the context itself to as its tag."
	^self
]

{ #category : #query }
Context >> copyStack [

	^ self copyTo: nil
]

{ #category : #query }
Context >> copyTo: aContext [
	"Copy self and my sender chain down to, but not including, aContext. End of copied chain will have nil sender. Assume that there is no loop in the context chain."

	| currentContext senderContext copy |
	self == aContext ifTrue: [ ^nil ].
	currentContext := copy := self copy.
	[ 
		senderContext := currentContext sender ifNil: [ ^copy ].
		senderContext == aContext ifTrue: [ 
			currentContext privSender: nil.
			^copy ].
		senderContext := senderContext copy.
		currentContext privSender: senderContext.
		currentContext := senderContext ] repeat
]

{ #category : #query }
Context >> copyTo: aContext bottomContextDo: aBlock [
	"Copy self and my sender chain down to, but not including, aContext.  End of copied chain will have nil sender. Evaluate aBlock with the copy of bottom context when it still points to the original sender."

	| copy |
	self == aContext ifTrue: [ ^nil ].
	copy := self copy.
	sender
		ifNil: [ aBlock value: copy ]
		ifNotNil: [
			sender == aContext ifTrue: [ aBlock value: copy ].
			copy privSender: (sender copyTo: aContext bottomContextDo: aBlock) ].
	^copy
]

{ #category : #private }
Context >> cut: aContext [
	"Cut aContext and its senders from my sender chain"

	| ctxt callee |
	ctxt := self.
	[ctxt == aContext] whileFalse: [
		callee := ctxt.
		ctxt := ctxt sender.
		ctxt ifNil: [aContext ifNotNil: [self error: 'aContext not a sender']].
	].
	callee privSender: nil.

]

{ #category : #'debugger access' }
Context >> depthBelow: aContext [
	"Answer how many calls there are between this and aContext."

	| this depth |
	this := self.
	depth := 0.
	[this == aContext or: [this == nil]]
		whileFalse:
			[this := this sender.
			depth := depth + 1].
	^depth
]

{ #category : #'instruction decoding' }
Context >> directedSuperSend: selector numArgs: numArgs [
	"Simulate the action of bytecodes that send a message with selector, selector,
	 starting the message lookup in the superclass of the class on top of stack.
	 The arguments of the message are found in the next numArgs locations on
	 the stack and the receiver just below them."

	| class receiver arguments |
	class := self pop.
	arguments := Array new: numArgs.
	numArgs to: 1 by: -1 do: [ :i | arguments at: i put: self pop].
	receiver := self pop.
	QuickStep == self ifTrue:
		[QuickStep := nil.
		^self quickSend: selector to: receiver with: arguments lookupIn: class superclass].
	^self send: selector to: receiver with: arguments lookupIn: class superclass
]

{ #category : #'instruction decoding' }
Context >> doDup [
	"Simulate the action of a 'duplicate top of stack' bytecode."

	self push: self top
]

{ #category : #'instruction decoding' }
Context >> doPop [
	"Simulate the action of a 'remove top of stack' bytecode."

	self pop
]

{ #category : #private }
Context >> doPrimitive: primitiveIndex method: meth receiver: receiver args: arguments [
	"Simulate a primitive method whose index is primitiveIndex.  The simulated receiver and
	 arguments are given as arguments to this message. If successful, push result and return
	 resuming context, else ^ {errCode, PrimitiveFailToken}. Any primitive which provokes
	 execution needs to be intercepted and simulated to avoid execution running away."

	| value |
	"Judicious use of primitive 19 (a null primitive that doesn't do anything) prevents
	 the debugger from entering various run-away activities such as spawning a new
	 process, etc.  Injudicious use results in the debugger not being able to debug
	 interesting code, such as the debugger itself.  Hence use primitive 19 with care :-)"
	"SystemNavigation new browseAllSelect: [:m| m primitive = 19]"
	primitiveIndex = 19 ifTrue: [
		Processor activeProcess
			debug: self
			title:'Code simulation error'
			full: false].

	((primitiveIndex between: 201 and: 222)
	 and: [(self objectClass: receiver) includesBehavior: BlockClosure]) ifTrue:
		[(primitiveIndex = 206
		  or: [primitiveIndex = 208]) ifTrue:						"[Full]BlockClosure>>valueWithArguments:"
			[^receiver simulateValueWithArguments: arguments first caller: self].
		 ((primitiveIndex between: 201 and: 209)			 "[Full]BlockClosure>>value[:value:...]"
		  or: [primitiveIndex between: 221 and: 222]) ifTrue: "[Full]BlockClosure>>valueNoContextSwitch[:]"
			[^receiver simulateValueWithArguments: arguments caller: self]].

	primitiveIndex = 83 ifTrue: "afr 9/11/1998 19:50" "Object>>perform:[with:...]"
		[^self send: arguments first to: receiver with: arguments allButFirst].
	primitiveIndex = 84 ifTrue: "afr 9/11/1998 19:50 & eem 8/18/2009 17:04" "Object>>perform:withArguments:"
		[^self send: arguments first to: receiver with: (arguments at: 2) lookupIn: (self objectClass: receiver)].
	primitiveIndex = 100 ifTrue: "eem 8/18/2009 16:57" "Object>>perform:withArguments:inSuperclass:"
		[^self send: arguments first to: receiver with: (arguments at: 2) lookupIn: (arguments at: 3)].

	"Mutex>>primitiveEnterCriticalSection
	 Mutex>>primitiveTestAndSetOwnershipOfCriticalSection"
	(primitiveIndex = 186 or: [primitiveIndex = 187]) ifTrue:
		[| effective |
		 effective := Processor activeProcess effectiveProcess.
		 "active == effective"
		 value := primitiveIndex = 186
					ifTrue: [receiver primitiveEnterCriticalSectionOnBehalfOf: effective]
					ifFalse: [receiver primitiveTestAndSetOwnershipOfCriticalSectionOnBehalfOf: effective].
		 ^(self isPrimFailToken: value)
			ifTrue: [value]
			ifFalse: [self push: value]].

	primitiveIndex = 188 ifTrue:	"Object>>withArgs:executeMethod:
									CompiledMethod class>>receiver:withArguments:executeMethod:
									VMMirror>>ifFail:object:with:executeMethod: et al"
		[| n args methodArg thisReceiver |
		 ((n := arguments size) between: 2 and: 4) ifFalse:
			[^self class primitiveFailTokenFor: #'unsupported operation'].
		 ((self objectClass: (args := arguments at: n - 1)) == Array
		  and: [(self objectClass: (methodArg := arguments at: n)) includesBehavior: CompiledMethod]) ifFalse:
			[^self class primitiveFailTokenFor: #'bad argument'].
		 methodArg numArgs = args size ifFalse:
			[^self class primitiveFailTokenFor: #'bad number of arguments'].
		 thisReceiver := arguments at: n - 2 ifAbsent: [receiver].
		 methodArg primitive > 0 ifTrue:
			[methodArg isQuick ifTrue:
				[^self push: (methodArg valueWithReceiver: thisReceiver arguments: args)].
			 ^self doPrimitive: methodArg primitive method: meth receiver: thisReceiver args: args].
		 ^Context
			sender: self
			receiver: thisReceiver
			method: methodArg
			arguments: args].

	primitiveIndex = 118 ifTrue: "[receiver:]tryPrimitive:withArgs:; avoid recursing in the VM"
		[(arguments size = 3
		  and: [(self objectClass: arguments second) == SmallInteger
		  and: [(self objectClass: arguments last) == Array]]) ifTrue:
			[^self doPrimitive: arguments second method: meth receiver: arguments first args: arguments last].
		 (arguments size = 2
		 and: [(self objectClass: arguments first) == SmallInteger
		 and: [(self objectClass: arguments last) == Array]]) ifFalse:
			[^self class primitiveFailTokenFor: nil].
		 ^self doPrimitive: arguments first method: meth receiver: receiver args: arguments last].

	value := primitiveIndex = 120 "FFI method"
				ifTrue: [(meth literalAt: 1) tryInvokeWithArguments: arguments]
				ifFalse:
					[primitiveIndex = 117 "named primitives"
						ifTrue: [self tryNamedPrimitiveIn: meth for: receiver withArgs: arguments]
						ifFalse: "should use self receiver: receiver tryPrimitive: primitiveIndex withArgs: arguments but this is only in later VMs (and appears to be broken)"
							[receiver tryPrimitive: primitiveIndex withArgs: arguments]].

	^(self isPrimFailToken: value)
		ifTrue: [value]
		ifFalse: [self push: value]
]

{ #category : #private }
Context >> endPC [
	^closureOrNil
		ifNil:	[self method endPC]
		ifNotNil: [closureOrNil endPC]
]

{ #category : #accessing }
Context >> exceptionMessage [
	^ self selector caseOf: {
			[#doesNotUnderstand:] -> [self tempAt: 1].
			[#notYetImplemented] -> [self asMessage].
			[#shouldBeImplemented] -> [self asMessage].
			[#subclassResponsibility] -> [self asMessage]}
		otherwise: [self error: 'This context is not the result of a message exception.'].
]

{ #category : #'system simulation' }
Context >> failPrimitiveWith: maybePrimFailToken [
	"The receiver is a freshly-created context on a primitive method.  Skip the callPrimitive:
	 bytecode and store the primitive fail code if there is one and the method consumes it."
	self skipCallPrimitive.
	((self isPrimFailToken: maybePrimFailToken)
	  and: [method encoderClass isStoreAt: pc in: method]) ifTrue:
		[self at: stackp put: maybePrimFailToken last]
]

{ #category : #query }
Context >> findContextSuchThat: testBlock [
	"Search self and my sender chain for first one that satisfies testBlock.  Return nil if none satisfy"

	| ctxt |
	ctxt := self.
	[ctxt isNil] whileFalse: [
		(testBlock value: ctxt) ifTrue: [^ ctxt].
		ctxt := ctxt sender.
	].
	^ nil
]

{ #category : #'private-exceptions' }
Context >> findNextHandlerContextStarting [
	"Return the next handler marked context, returning nil if there is none.  Search starts with self and proceeds up to nil."

	| ctx |
	<primitive: 197>
	ctx := self.
		[ctx isHandlerContext ifTrue:[^ctx].
		(ctx := ctx sender) == nil ] whileFalse.
	^nil
]

{ #category : #'private-exceptions' }
Context >> findNextUnwindContextUpTo: aContext [
	"Return the next unwind marked above the receiver, returning nil if there is none.  Search proceeds up to but not including aContext."

	| ctx |
	<primitive: 195>
	ctx := self.
	[(ctx := ctx sender) == nil or: [ctx == aContext]] whileFalse:
		[ ctx isUnwindContext ifTrue: [^ctx]].
	^nil
]

{ #category : #query }
Context >> findSecondToOldestSimilarSender [
	"Search the stack for the second-to-oldest occurance of self's method.  Very useful for an infinite recursion.  Gets back to the second call so you can see one complete recursion cycle, and how it was called at the beginning."

	| sec ctxt bot |
	sec := self.
	ctxt := self.
	[	bot := ctxt findSimilarSender.
		bot isNil
	] whileFalse: [
		sec := ctxt.
		ctxt := bot.
	].
	^ sec

]

{ #category : #query }
Context >> findSimilarSender [
	"Return the closest sender with the same method, return nil if none found"

	| meth |
	meth := self method.
	self sender ifNil: [^nil].
	^ self sender findContextSuchThat: [:c | c method == meth]
]

{ #category : #'private-exceptions' }
Context >> handleSignal: exception [
	"Sent to handler (on:do:) contexts only.  If my exception class (first arg) handles exception
	 and the handler is active then execute my handle block (second arg), otherwise forward
	 this message to the next handler context.  If none left, execute exception's defaultAction
	 (see nil>>handleSignal:)."

	| handlerActive val |
	"If the context has been returned from the handlerActive temp var may not be accessible."
	handlerActive := stackp >= 3 and: [(self tempAt: 3) == true].
	(((self tempAt: 1) handles: exception) and: [handlerActive]) ifFalse:
		[^self nextHandlerContext handleSignal: exception].

	exception privHandlerContext: self contextTag.
	self tempAt: 3 put: false.  "disable self while executing handle block"
	val := [(self tempAt: 2) cull: exception]
			ensure: [self tempAt: 3 put: true].
	self return: val  "return from self if not otherwise directed in handle block"

]

{ #category : #query }
Context >> hasContext: aContext [ 
	"Answer whether aContext is me or one of my senders"

	^ (self findContextSuchThat: [:c | c == aContext]) notNil
]

{ #category : #accessing }
Context >> hasInstVarRef [
	"Answer whether the receiver references an instance variable."

	^self method hasInstVarRef.
]

{ #category : #accessing }
Context >> hasMethodReturn [
	^closureOrNil hasMethodReturn
]

{ #category : #controlling }
Context >> hasSender: context [ 
	"Answer whether the receiver is strictly above context on the stack."

	| s |
	self == context ifTrue: [^false].
	s := sender.
	[s == nil]
		whileFalse: 
			[s == context ifTrue: [^true].
			s := s sender].
	^false
]

{ #category : #accessing }
Context >> home [ 
	"Answer the context in which the receiver was defined."

	closureOrNil == nil ifTrue:
		[^self].
	^closureOrNil outerContext home
]

{ #category : #private }
Context >> insertSender: aContext [
	"Insert aContext and its sender chain between me and my sender.  Return new callee of my original sender."

	| ctxt |
	ctxt := aContext bottomContext.
	ctxt privSender: self sender.
	self privSender: aContext.
	^ ctxt
]

{ #category : #private }
Context >> instVarAt: index put: value [
	index = 3 ifTrue: [self stackp: value. ^ value].
	^ super instVarAt: index put: value
]

{ #category : #query }
Context >> isBottomContext [
	"Answer if this is the last context (the first context invoked) in my sender chain"

	^sender isNil
]

{ #category : #'closure support' }
Context >> isClosureContext [
	^closureOrNil ~~ nil
]

{ #category : #query }
Context >> isContext [
	^true
]

{ #category : #query }
Context >> isDead [
	"Has self finished"

	^ pc isNil
]

{ #category : #accessing }
Context >> isExecutingBlock [
	"Is this executing a block versus a method?  In the new closure
	 implemetation this is true if closureOrNil is not nil, in which case
	 it should be holding a BlockClosure."

	^closureOrNil isClosure
]

{ #category : #'private-exceptions' }
Context >> isHandlerContext [
"is this context for  method that is marked?"
	^method primitive = 199
]

{ #category : #testing }
Context >> isMethodContext [
	^closureOrNil == nil
]

{ #category : #private }
Context >> isPrimFailToken: anObject [
	^(self objectClass: anObject) == Array
	  and: [anObject size = 2
	  and: [anObject first == PrimitiveFailToken]]
]

{ #category : #'private-exceptions' }
Context >> isUnwindContext [
"is this context for  method that is marked?"
	^method primitive = 198
]

{ #category : #controlling }
Context >> jump [
	"Abandon thisContext and resume self instead (using the same current process).  You may want to save thisContext's sender before calling this so you can jump back to it.
	Self MUST BE a top context (ie. a suspended context or a abandoned context that was jumped out of).  A top context already has its return value on its stack (see Interpreter>>primitiveSuspend and other suspending primitives).
	thisContext's sender is converted to a top context (by pushing a nil return value on its stack) so it can be jump back to."

	| top |
	"Make abandoned context a top context (has return value (nil)) so it can be jumped back to"
	thisContext sender push: nil.

	"Pop self return value then return it to self (since we jump to self by returning to it)"
	stackp = 0 ifTrue: [self stepToSendOrReturn].
	stackp = 0 ifTrue: [self push: nil].  "must be quick return self/constant"
	top := self pop.
	thisContext privSender: self.
	^ top
]

{ #category : #'instruction decoding' }
Context >> jump: distance [ 
	"Simulate the action of a 'unconditional jump' bytecode whose offset is 
	the argument, distance."

	pc := pc + distance
]

{ #category : #'instruction decoding' }
Context >> jump: distance if: condition [ 
	"Simulate the action of a 'conditional jump' bytecode whose offset is the 
	 argument, distance, and whose condition is the argument, condition."

	| bool |
	bool := self pop.
	condition == bool
		ifTrue: [self jump: distance]
		ifFalse:
			[(true == bool or: [false == bool]) ifFalse:
				[^self send: #mustBeBooleanIn: to: bool with: {self}]]
]

{ #category : #'debugger access' }
Context >> longStack [
	"Answer a String showing the top 100 contexts on my sender chain."

	^ String streamContents:
		[:strm |
		(self stackOfSize: 100)
			do: [:item | strm print: item; cr]]
]

{ #category : #accessing }
Context >> method [

	^method
]

{ #category : #accessing }
Context >> methodClass [ 
	"Answer the class in which the receiver's method was found."
	
	^self method methodClass ifNil: [self objectClass: self receiver].
]

{ #category : #accessing }
Context >> methodNode [
	^ self method methodNode.
]

{ #category : #accessing }
Context >> methodNodeFormattedAndDecorated: decorate [
	"Answer a method node made from pretty-printed (and colorized, if decorate is true) 
	 source text."

	^ self method methodNodeFormattedAndDecorated: decorate.
]

{ #category : #'instruction decoding' }
Context >> methodReturnConstant: value [
	"Simulate the action of a 'return constant' bytecode whose value is the
	 argument, value. This corresponds to a source expression like '^0'."

	^self return: value from: self methodReturnContext
]

{ #category : #accessing }
Context >> methodReturnContext [
	"Answer the context from which an ^-return should return from."

	closureOrNil == nil ifTrue:
		[^self].
	^closureOrNil outerContext methodReturnContext
]

{ #category : #'instruction decoding' }
Context >> methodReturnReceiver [
	"Simulate the action of a 'return receiver' bytecode. This corresponds to
	 the source expression '^self'."

	^self return: self receiver from: self methodReturnContext
]

{ #category : #'instruction decoding' }
Context >> methodReturnTop [
	"Simulate the action of a 'return top of stack' bytecode. This corresponds
	 to source expressions like '^something'."

	^self return: self pop from: self methodReturnContext
]

{ #category : #'read-only objects' }
Context >> modificationForbiddenFor: target at: index put: anObject [
	^(ModificationForbidden new
		mirror: self
		object: target
		index: index
		newValue: anObject
		retrySelector: #object:basicAt:put:) signal
]

{ #category : #'read-only objects' }
Context >> modificationForbiddenFor: target at: index putCharacter: aCharacter [
	"eem 3/11/2020 13:09 this may be a mistake.  Instead perhaps String clients should
	 send asInteger and use modificationForbiddenFor:at:put:.  Opinions appreciated."
	^(ModificationForbidden new
		mirror: self
		object: target
		index: index
		newValue: (aCharacter isCharacter ifTrue: [aCharacter asInteger] ifFalse: [aCharacter])
		retrySelector: #object:basicAt:put:) signal
]

{ #category : #'read-only objects' }
Context >> modificationForbiddenFor: target instVarAt: index put: anObject [
	^(ModificationForbidden new
		mirror: self
		object: target
		index: index
		newValue: anObject
		retrySelector: #object:instVarAt:put:) signal
]

{ #category : #'private-exceptions' }
Context >> nextHandlerContext [

	^ self sender findNextHandlerContextStarting
]

{ #category : #accessing }
Context >> numArgs [
	"Answer the number of arguments for this activation."
	^closureOrNil
		ifNil: [method numArgs]
		ifNotNil: [closureOrNil numArgs]
]

{ #category : #accessing }
Context >> numTemps [
	"Answer the number of temporaries for this activation; this includes
	 the number of arguments, and for blocks, the number of copied values."
	^closureOrNil
		ifNil: [method numTemps]
		ifNotNil: [closureOrNil numTemps]
]

{ #category : #'mirror primitives' }
Context >> object: anObject basicAt: index [ 
	"Answer the value of an indexable element in the argument anObject without sending
	 it a message. Fail if the argument index is not an Integer or is out of bounds, or if
	 anObject is not indexable. This mimics the action of the VM when it indexes an object.
	 Used to simulate the execution machinery by, for example, the debugger.
	 Primitive.  See Object documentation whatIsAPrimitive."

	<primitive: 60>
	index isInteger ifTrue: [self errorSubscriptBounds: index].
	index isNumber
		ifTrue: [^self object: anObject basicAt: index asInteger]
		ifFalse: [self errorNonIntegerIndex]
]

{ #category : #'mirror primitives' }
Context >> object: anObject basicAt: index put: value [ 
	"Store the last argument value in the indexable element of the argument anObject
	 indicated by index without sending anObject a message. Fail if the argument index
	 is not an Integer or is out of bounds, or if anObject is not indexable, or if anObject is
	 read-only, or if value is an inappropriate value for anObject's indexable slots.
	 This mimics the action of the VM when it indexes an object. Used to simulate
	 the execution machinery by, for example, the debugger.
	 Primitive.  See Object documentation whatIsAPrimitive."

	<primitive: 61 error: ec>
	index isInteger ifTrue:
		[(index >= 1 and: [index <= (self objectSize: anObject)])
			ifTrue:
				[ec == #'no modification' ifTrue:
					[^self modificationForbiddenFor: anObject at: index put: value].
				 self errorImproperStore]
			ifFalse: [self errorSubscriptBounds: index]].
	index isNumber ifTrue:
		[^self object: anObject basicAt: index asInteger put: value].
	self errorNonIntegerIndex
]

{ #category : #'mirror primitives' }
Context >> object: anObject eqeq: anOtherObject [ 
	"Answer whether the first and second arguments are the same object (have the
	 same object pointer) without sending a message to the first argument.  This
	 mimics the action of the VM when it compares two object pointers.  Used to
	 simulate the execution machinery by, for example, the debugger.
	 Primitive.  See Object documentation whatIsAPrimitive."

	<primitive: 110>
	self primitiveFailed
]

{ #category : #'mirror primitives' }
Context >> object: anObject instVarAt: anIndex [
	"Primitive. Answer a fixed variable in an object. The numbering of the 
	 variables corresponds to the named instance variables. Fail if the index 
	 is not an Integer or is not the index of a fixed variable. Essential for the
	 debugger. See  Object documentation whatIsAPrimitive."

	<primitive: 173 error: ec>
	self primitiveFailed
]

{ #category : #'mirror primitives' }
Context >> object: anObject instVarAt: anIndex put: aValue [ 
	"Primitive. Store a value into a fixed variable in the argument anObject.
	 The numbering of the variables corresponds to the named instance
	 variables.  Fail if the index is not an Integer or is not the index of a
	 fixed variable, or if anObject is read-only.  Answer the value stored as
	 the result. Using this message violates the  principle that each object
	 has sovereign control over the storing of values into its instance variables.
	 Essential for the debugger. See Object documentation whatIsAPrimitive."

	<primitive: 174 error: ec>
	ec == #'no modification' ifTrue:
		[^self modificationForbiddenFor: anObject instVarAt: anIndex put: aValue].
	self primitiveFailed
]

{ #category : #'mirror primitives' }
Context >> object: anObject perform: selector withArguments: argArray inClass: lookupClass [
	"Send the selector, aSymbol, to anObject with arguments in argArray.
	 Fail if the number of arguments expected by the selector 
	 does not match the size of argArray, or if lookupClass
	 cannot be found among the anObject's superclasses.
	 Primitive. Essential for the debugger."

	<primitive: 100 error: error>
	(selector isSymbol) ifFalse:
		[^self error: 'selector argument must be a Symbol'].
	(argArray isMemberOf: Array) ifFalse:
		[^self error: 'argArray must be an Array'].
	(selector numArgs = argArray size)
		ifFalse: [^self error: 'incorrect number of arguments'].
	((self objectClass: anObject) == lookupClass
	 or: [(self objectClass: anObject) inheritsFrom: lookupClass]) ifFalse:
		[^self error: 'lookupClass is not in anObject''s inheritance chain'].
	self primitiveFailed
]

{ #category : #'mirror primitives' }
Context >> objectClass: anObject [
	"Answer the class of the argument anObject without sending it a message.
	 This mimics the action of the VM when it fetches an object's class.  Used to
	 simulate the execution machinery by, for example, the debugger.
	 Primitive.  See Object documentation whatIsAPrimitive."

	<primitive: 111>
	self primitiveFailed
]

{ #category : #'mirror primitives' }
Context >> objectSize: anObject [
	"Answer the number of indexable variables in the argument anObject without sending
	 it a message. This mimics the action of the VM when it fetches an object's variable size.
	 Used to simulate the execution machinery by, for example, the debugger.
	 Primitive.  See Object documentation whatIsAPrimitive."

	<primitive: 62>
	"The number of indexable fields of fixed-length objects is 0"
	^0
]

{ #category : #accessing }
Context >> outerContext [
	"Answer the context within which the receiver is nested."

	^closureOrNil ifNotNil:
		[closureOrNil outerContext]
]

{ #category : #accessing }
Context >> pc [
	"Answer the index of the next bytecode to be executed."

	^pc
]

{ #category : #controlling }
Context >> pop [
	"Answer the top of the receiver's stack and remove the top of the stack."
	| val |
	val := self at: stackp.
	self stackp: stackp - 1.
	^ val
]

{ #category : #'instruction decoding' }
Context >> popIntoLiteralVariable: value [ 
	"Simulate the action of bytecode that removes the top of the stack and 
	 stores it into a literal variable of my method. If the receiver is read-only
	 this will provoke a send of #attemptToAssign:withIndex:"

	| top result |
	top := self pop.
	result := self simulatedObject: value instVarAt: ValueIndex put: top.
	^(self object: result eqeq: top)
		ifTrue: [self]
		ifFalse: [result]
]

{ #category : #'instruction decoding' }
Context >> popIntoReceiverVariable: offset [ 
	"Simulate the action of bytecode that removes the top of the stack and 
	 stores it into an instance variable of my receiver. If the receiver is read-only
	 this will provoke a send of #attemptToAssign:withIndex:"

	| top result |
	top := self pop.
	result := self simulatedObject: self receiver instVarAt: offset + 1 put: top.
	^(self object: result eqeq: top)
		ifTrue: [self]
		ifFalse: [result]
]

{ #category : #'instruction decoding' }
Context >> popIntoRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex [
	"Simulate the action of bytecode that removes the top of the stack and  stores
	 it into an offset in one of my local variables being used as a remote temp vector."

	self object: (self at: tempVectorIndex + 1) basicAt: remoteTempIndex + 1 put: self pop
]

{ #category : #'instruction decoding' }
Context >> popIntoTemporaryVariable: offset [ 
	"Simulate the action of bytecode that removes the top of the stack and 
	stores it into one of my temporary variables."

	self at: offset + 1 put: self pop
]

{ #category : #printing }
Context >> printDetails: strm [
	"Put my class>>selector and instance variables and arguments and temporaries on the stream.  Protect against errors during printing."

	| pe str pos |
	self printOn: strm.
	strm cr.
	strm tab; nextPutAll: 'Receiver: '.
	pe := '<<error during printing>>'.
	strm nextPutAll: ([receiver printStringLimitedTo: 90] ifError: [:err :rcvr | pe]).

	strm cr; tab; nextPutAll: 'Arguments and temporary variables: '; cr.
	str := [(self tempsAndValuesLimitedTo: 80 indent: 2) 
				padded: #right to: 1 with: $x] ifError: [:err :rcvr | pe].
	strm nextPutAll: (str allButLast).

	strm cr; tab; nextPutAll: 'Receiver''s instance variables: '; cr.
	pos := strm position.
	[receiver longPrintOn: strm limitedTo: 80 indent: 2] ifError: [:err :rcvr | 
				strm nextPutAll: pe].
	pos = strm position ifTrue: ["normal printString for an Array (it has no inst vars)"
		strm nextPutAll: ([receiver printStringLimitedTo: 90] ifError: [:err :rcvr | pe])].
	strm peekLast == Character cr ifFalse: [strm cr].
]

{ #category : #printing }
Context >> printOn: aStream [
	| class mclass selector |
	method ifNil:
		[^super printOn: aStream].

	closureOrNil ifNotNil:
		[aStream nextPutAll: '[] in '.
		 closureOrNil outerContext ifNotNil:
			[:outer|
			 outer printOn: aStream.
			 ^self]].

	class := self objectClass: self receiver.
	mclass := method methodClass.
	selector := method selector ifNil: [method defaultSelector].

	aStream nextPutAll: class name.
	mclass ~~ class ifTrue:
		[aStream nextPut: $(; nextPutAll: mclass name; nextPut: $)].
	aStream nextPutAll: '>>'; nextPutAll: selector.

	(selector == #doesNotUnderstand:
	 and: [(self objectClass: (self tempAt: 1)) == Message]) ifTrue:
		[aStream space.
		(self tempAt: 1) selector printOn: aStream]
]

{ #category : #printing }
Context >> printString [
	"Answer an emphasized string in case of a breakpoint method"

	^(self method notNil and: [self method hasBreakpoint])
		ifTrue:[(super printString , ' [break]') asText allBold]
		ifFalse:[super printString]
]

{ #category : #'initialize-release' }
Context >> privRefresh [
	"Reinitialize the receiver so that it is in the state it was at its creation."

	closureOrNil
		ifNotNil:
			[closureOrNil isFullBlock
				ifTrue:
					[pc := method initialPC.
					 self stackp: method numTemps.
					 closureOrNil numArgs + closureOrNil numCopiedValues + 1 to: method numTemps do:
						[:i | self tempAt: i put: nil]]
				ifFalse: "In non-full blocks temps are established by push btecodes"
					[pc := closureOrNil startpc.
					 self stackp: closureOrNil numArgs + closureOrNil numCopiedValues].
			 1 to: closureOrNil numCopiedValues do:
				[:i | self tempAt: closureOrNil numArgs + i put: (closureOrNil at: i)]]
		ifNil:
			[pc := method initialPC.
			 self stackp: method numTemps.
			 method numArgs + 1 to: method numTemps do:
				[:i | self tempAt: i put: nil]]
]

{ #category : #'initialize-release' }
Context >> privRefreshWith: aCompiledMethod [ 
	"Reinitialize the receiver as though it had been for a different method. 
	 Used by a Debugger when one of the methods to which it refers is 
	 recompiled."

	aCompiledMethod isCompiledMethod ifFalse:
		[self error: 'method can only be set to aCompiledMethod'].
	method := aCompiledMethod.
	self assert: closureOrNil == nil.
	"was: receiverMap := nil."
	self privRefresh
]

{ #category : #private }
Context >> privSender: aContext [ 

	sender := aContext
]

{ #category : #controlling }
Context >> push: val [ 
	"Push val on the receiver's stack."

	self stackp: stackp + 1.
	self at: stackp put: val
]

{ #category : #private }
Context >> push: numObjects fromIndexable: anIndexableCollection [
	"Push the elements of anIndexableCollection onto the receiver's stack.
	 Do not call directly.  Called indirectly by {1. 2. 3} constructs."

	1 to: numObjects do:
		[:i | self push: (anIndexableCollection at: i)]
]

{ #category : #'instruction decoding' }
Context >> pushActiveContext [
	"Simulate the action of bytecode that pushes the the active context on the 
	top of its own stack."

	self push: self
]

{ #category : #'system simulation' }
Context >> pushArgs: args "<Array>" from: sendr [ "<Context>" 
	"Helps simulate action of the value primitive for closures.
	 This is used by ContextPart>>runSimulated:contextAtEachStep:"

	closureOrNil
		ifNil: [self error: 'context needs a closure!']
		ifNotNil:
			["See BlockClosure>>asContextWithSender:"
			 stackp ~= (closureOrNil numArgs + closureOrNil numCopiedValues) ifTrue:
				[self error: 'stack pointer is incorrect!'].].

	1 to: closureOrNil numArgs do:
		[:i| self at: i put: (args at: i)].
	sender := sendr
]

{ #category : #'instruction decoding' }
Context >> pushClosureCopyNumCopiedValues: numCopied numArgs: numArgs blockSize: blockSize [
	"Simulate the action of a 'closure copy' bytecode whose result is the
	 new BlockClosure for the following code"
	| copiedValues |
	numCopied > 0
		ifTrue:
			[copiedValues := Array new: numCopied.
			 numCopied to: 1 by: -1 do:
				[:i|
				copiedValues at: i put: self pop]]
		ifFalse:
			[copiedValues := nil].
	self push: ((BlockClosure new: numCopied)
				outerContext: self
				startpc: pc
				numArgs: numArgs
				copiedValues: copiedValues).
	self jump: blockSize
]

{ #category : #'instruction decoding' }
Context >> pushConsArrayWithElements: numElements [ 
	| array |
	array := Array new: numElements.
	numElements to: 1 by: -1 do:
		[:i|
		array at: i put: self pop].
	self push: array
]

{ #category : #'instruction decoding' }
Context >> pushConstant: value [ 
	"Simulate the action of bytecode that pushes the constant, value, on the 
	top of the stack."

	self push: value
]

{ #category : #'instruction decoding' }
Context >> pushFullClosure: aCompiledBlock numCopied: numCopied [
	"Simulate the action of a 'closure copy' bytecode whose result is the
	 new FullBlockClosure for the supplied compiled block."
	| copiedValues |
	numCopied > 0
		ifTrue:
			[copiedValues := Array new: numCopied.
			 numCopied to: 1 by: -1 do:
				[:i|
				copiedValues at: i put: self pop]]
		ifFalse:
			[copiedValues := nil].
	self push: ((FullBlockClosure new: numCopied)
				receiver: receiver
				outerContext: self
				method: aCompiledBlock
				copiedValues: copiedValues)
]

{ #category : #'instruction decoding' }
Context >> pushLiteralVariable: value [ 
	"Simulate the action of bytecode that pushes the contents of the literal 
	variable whose index is the argument, index, on the top of the stack."

	self push: (self object: value instVarAt: ValueIndex)
]

{ #category : #'instruction decoding' }
Context >> pushNewArrayOfSize: arraySize [ 
	self push: (Array new: arraySize)
]

{ #category : #'instruction decoding' }
Context >> pushReceiver [
	"Simulate the action of bytecode that pushes the active context's receiver 
	on the top of the stack."

	self push: self receiver
]

{ #category : #'instruction decoding' }
Context >> pushReceiverVariable: offset [ 
	"Simulate the action of bytecode that pushes the contents of the receiver's 
	instance variable whose index is the argument, index, on the top of the 
	stack."

	self push: (self object: self receiver instVarAt: offset + 1)
]

{ #category : #'instruction decoding' }
Context >> pushRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex [
	"Simulate the action of bytecode that pushes the value at remoteTempIndex
	 in one of my local variables being used as a remote temp vector."
	self push: (self object: (self at: tempVectorIndex + 1) basicAt: remoteTempIndex + 1)
]

{ #category : #'instruction decoding' }
Context >> pushTemporaryVariable: offset [ 
	"Simulate the action of bytecode that pushes the contents of the 
	temporary variable whose index is the argument, index, on the top of 
	the stack."

	self push: (self at: offset + 1)
]

{ #category : #controlling }
Context >> quickSend: selector to: rcvr with: arguments lookupIn: lookupClass [
	"Send the given selector with arguments in an environment which closely resembles
	 the non-simulating environment, with an interjected unwind-protected block to catch
	 nonlocal returns.  Attention: don't get lost!  This beautiful method is originally due to
	 Hans-Martin Mosner."
	| oldSender contextToReturnTo result |
	contextToReturnTo := self.
	[oldSender := thisContext sender swapSender: self.
	 result := self object: rcvr perform: selector withArguments: arguments inClass: lookupClass.
	 thisContext sender swapSender: oldSender] ifCurtailed:
		[contextToReturnTo := thisContext sender receiver.	"The block context returning nonlocally"
		contextToReturnTo pc: contextToReturnTo previousPc.	"skip to front of return bytecode causing this unwind"
		contextToReturnTo willReturnTopFromMethod ifTrue:
			"If it was a returnTop, push the value to be returned.
			Otherwise the value is implicit in the bytecode"
			[contextToReturnTo push: (thisContext sender tempAt: 1)].
		thisContext swapSender: thisContext home sender.	"Make this block return to the method's sender"
		contextToReturnTo].
	contextToReturnTo push: result.
	^contextToReturnTo
]

{ #category : #'system simulation' }
Context >> quickStep [
	"If the next instruction is a send, just perform it.
	Otherwise, do a normal step."

	self willReallySend ifTrue: [QuickStep := self].
	^self step
]

{ #category : #'objects from disk' }
Context >> readDataFrom: aDataStream size: varsOnDisk [
	"Fill in the fields of self based on the contents of aDataStream.  Answer self.
	 Read in the instance-variables written by Object>>storeDataOn:.
	 NOTE: This method must send beginReference: before reading any objects from aDataStream that might reference it.
	 Allow aDataStream to have fewer inst vars.  See SmartRefStream.
	 Override to not store nil stack contents beyond stack pointer."
	| cntInstVars cntIndexedVars |

	cntInstVars := self class instSize.
	cntIndexedVars := varsOnDisk - cntInstVars.
	cntIndexedVars < 0 ifTrue:
		[self error: 'Class has changed too much.  Define a convertxxx method'].

	aDataStream beginReference: self.
	1 to: cntInstVars do:
		[:i | self instVarAt: i put: aDataStream next].
	1 to: stackp do:
		[:i | self basicAt: i put: aDataStream next].
	stackp + 1 to: cntIndexedVars do:
		[:i | aDataStream next ~~ nil ifTrue:
			[self error: 'Reading a Context''s contents expects only nil beyond top of stack']].
	"Total number read MUST be equal to varsOnDisk!"
	^self	"If we ever answer something other than self, fix calls 
			on (super readDataFrom: aDataStream size: anInteger)"
]

{ #category : #'private-exceptions' }
Context >> rearmHandlerDuring: aBlock [
	"Sent to handler (on:do:) contexts only. Makes me re-entrant for the duration of aBlock. Only works in a closure-enabled image"

	^ [self tempAt: 3 put: true. aBlock value]
		ensure: [self tempAt: 3 put: false]
]

{ #category : #accessing }
Context >> receiver [
	"Answer the receiver of the message that created this context."

	^receiver
]

{ #category : #'private-exceptions' }
Context >> receiver: r [

	receiver := r
]

{ #category : #private }
Context >> receiver: receiver tryPrimitive: primIndex withArgs: argumentArray [
	"Invoke the primitive with number primIndex, with the receiver and arguments
	 supplied, answering its result, or, if the primiitve fails, the error code."

	<primitive: 118 error: errorCode>
	^self class primitiveFailTokenFor: errorCode
]

{ #category : #'debugger access' }
Context >> release [
	"Remove information from the receiver and all of the contexts on its 
	sender chain in order to break circularities."

	self releaseTo: nil
]

{ #category : #'debugger access' }
Context >> releaseTo: caller [ 
	"Remove information from the receiver and the contexts on its sender 
	chain up to caller in order to break circularities."

	| c s |
	c := self.
	[c == nil or: [c == caller]]
		whileFalse: 
			[s := c sender.
			c singleRelease.
			c := s]
]

{ #category : #accessing }
Context >> removeSelf [
	"Nil the receiver pointer and answer its former value."

	| tempSelf |
	tempSelf := receiver.
	receiver := nil.
	^tempSelf
]

{ #category : #controlling }
Context >> restart [
	"Unwind thisContext to self and resume from beginning.  Execute unwind blocks when unwinding.  ASSUMES self is a sender of thisContext"

	| ctxt unwindBlock |
	self isDead ifTrue: [self cannotReturn: nil to: self].
	self privRefresh.
	ctxt := thisContext.
	[	ctxt := ctxt findNextUnwindContextUpTo: self.
		ctxt isNil
	] whileFalse: [
		(ctxt tempAt: 2) ifNil:[
			ctxt tempAt: 2 put: true.
			unwindBlock := ctxt tempAt: 1.
			thisContext terminateTo: ctxt.
			unwindBlock value].
	].
	thisContext terminateTo: self.
	self jump.

]

{ #category : #'private-exceptions' }
Context >> restartWithNewReceiver: obj [

	self
		swapReceiver: obj;
		restart
]

{ #category : #controlling }
Context >> resume [
	"Roll back thisContext to self and resume.  Execute unwind blocks when rolling back.  ASSUMES self is a sender of thisContext"

	self resume: nil
]

{ #category : #controlling }
Context >> resume: value [
	"Unwind thisContext to self and resume with value as result of last send.  Execute unwind blocks when unwinding.  ASSUMES self is a sender of thisContext"

	| ctxt unwindBlock |
	self isDead ifTrue: [self cannotReturn: value to: self].
	ctxt := thisContext.
	[	ctxt := ctxt findNextUnwindContextUpTo: self.
		ctxt isNil
	] whileFalse: [
		(ctxt tempAt: 2) ifNil:[
			ctxt tempAt: 2 put: true.
			unwindBlock := ctxt tempAt: 1.
			thisContext terminateTo: ctxt.
			unwindBlock value].
	].
	thisContext terminateTo: self.
	^ value

]

{ #category : #controlling }
Context >> resume: value through: firstUnwindCtxt [
	"Unwind thisContext to self and resume with value as result of last send.
	 Execute any unwind blocks while unwinding.
	 ASSUMES self is a sender of thisContext."

	| ctxt unwindBlock |
	self isDead ifTrue: [self cannotReturn: value to: self].
	ctxt := firstUnwindCtxt.
	[ctxt isNil] whileFalse:
		[(ctxt tempAt: 2) ifNil:
			[ctxt tempAt: 2 put: true.
			 unwindBlock := ctxt tempAt: 1.
			 thisContext terminateTo: ctxt.
			 unwindBlock value].
		 ctxt := ctxt findNextUnwindContextUpTo: self].
	thisContext terminateTo: self.
	^value

]

{ #category : #controlling }
Context >> return [
	"Unwind until my sender is on top"

	self return: self receiver
]

{ #category : #controlling }
Context >> return: value [
	"Unwind thisContext to self and return value to self's sender.  Execute any unwind blocks while unwinding.  ASSUMES self is a sender of thisContext"

	sender ifNil: [self cannotReturn: value to: sender].
	sender resume: value
]

{ #category : #'instruction decoding' }
Context >> return: value from: aSender [ 
	"For simulation.  Roll back self to aSender and return value from it.  Execute any unwind blocks on the way.  ASSUMES aSender is a sender of self"

	| newTop |
	aSender isDead ifTrue:
		[^self send: #cannotReturn: to: self with: {value}].
	newTop := aSender sender.
	(self findNextUnwindContextUpTo: newTop) ifNotNil:
		[:unwindProtectCtxt|
		 ^self send: #aboutToReturn:through: to: self with: {value. unwindProtectCtxt}].
	self releaseTo: newTop.
	newTop ifNotNil: [newTop push: value].
	^newTop
]

{ #category : #controlling }
Context >> return: value through: firstUnwindContext [
	"Unwind thisContext to self and return value to self's sender.
	 Execute any unwind blocks while unwinding.
	 ASSUMES self is a sender of thisContext."

	sender ifNil: [self cannotReturn: value to: sender].
	sender resume: value through: firstUnwindContext
]

{ #category : #controlling }
Context >> return: value to: sendr [ 
	"Simulate the return of value to sendr."

	self releaseTo: sendr.
	sendr ifNil: [^ nil].
	^ sendr push: value
]

{ #category : #'system simulation' }
Context >> runSimulated: aBlock contextAtEachStep: block2 [
	"Simulate the execution of the argument, aBlock, until it ends. aBlock 
	MUST NOT contain an '^'. Evaluate block2 with the current context 
	prior to each instruction executed. Answer the simulated value of aBlock."
	| current |
	aBlock hasMethodReturn
		ifTrue: [self error: 'simulation of blocks with ^ can run loose'].
	current := aBlock asContext.
	current pushArgs: Array new from: self.
	[current == self]
		whileFalse:
			[block2 value: current.
			current := current step].
	^self pop
]

{ #category : #controlling }
Context >> runUntilErrorOrReturnFrom: aSender [ 
	"ASSUMES aSender is a sender of self.  Execute self's stack until aSender returns or an unhandled exception is raised.  Return a pair containing the new top context and a possibly nil exception.  The exception is not nil if it was raised before aSender returned and it was not handled.  The exception is returned rather than openning the debugger, giving the caller the choice of how to handle it."
	"Self is run by jumping directly to it (the active process abandons thisContext and executes self).  However, before jumping to self we insert an ensure block under aSender that jumps back to thisContext when evaluated.  We also insert an exception handler under aSender that jumps back to thisContext when an unhandled exception is raised.  In either case, the inserted ensure and exception handler are removed once control jumps back to thisContext."

	| error ctxt here topContext |
	here := thisContext.

	"Insert ensure and exception handler contexts under aSender"
	error := nil.
	ctxt := aSender insertSender: (Context
		contextOn: UnhandledError do: [:ex |
			error ifNil: [
				error := ex exception.
				topContext := thisContext.
				ex resumeUnchecked: here jump]
			ifNotNil: [ex pass]
		]).
	ctxt := ctxt insertSender: (Context
		contextEnsure: [error ifNil: [
				topContext := thisContext.
				here jump]
		]).
	self jump.  "Control jumps to self"

	"Control resumes here once above ensure block or exception handler is executed"
	^ error ifNil: [
		"No error was raised, remove ensure context by stepping until popped"
		[ctxt isDead] whileFalse: [topContext := topContext stepToCallee].
		{topContext. nil}

	] ifNotNil: [
		"Error was raised, remove inserted above contexts then return signaler context"
		aSender terminateTo: ctxt sender.  "remove above ensure and handler contexts"
		{topContext. error}
	]
]

{ #category : #query }
Context >> secondFromBottom [
	"Return the second from bottom of my sender chain"

	self sender ifNil: [^ nil].
	^ self findContextSuchThat: [:c | c sender sender isNil]
]

{ #category : #accessing }
Context >> selector [
	"Answer the selector of the method that created the receiver."

	^self method selector ifNil: [self method defaultSelector].
]

{ #category : #accessing }
Context >> selectorCategory [
	"Answer the category to which this message belongs (relative to the receiver).
	 If no superclass categorises this message, use the default."
	| rcvrClass organizers |
	rcvrClass := self objectClass: self receiver.
	organizers := rcvrClass withAllSuperclasses collect: [:ea | ea organization].
	organizers addFirst: rcvrClass organization.
	^(organizers collect: [ :org | org categoryOfElement: self selector])
			detect: [:ea | ea ~= ClassOrganizer default and: [ea ~= nil]]
			ifNone: [ClassOrganizer default]
]

{ #category : #'instruction decoding' }
Context >> send: selector super: superFlag numArgs: numArgs [
	"Simulate the action of bytecodes that send a message with selector, 
	 selector. The argument, superFlag, tells whether the receiver of the 
	 message was specified with 'super' in the source method. The arguments 
	 of the message are found in the top numArgs locations on the stack and 
	 the receiver just below them."

	| thisReceiver arguments lookupClass |
	arguments := Array new: numArgs.
	numArgs to: 1 by: -1 do: [ :i | arguments at: i put: self pop].
	thisReceiver := self pop.
	lookupClass := superFlag
					ifTrue: [method methodClassAssociation value superclass]
					ifFalse: [self objectClass: thisReceiver].
	QuickStep == self ifTrue:
		[QuickStep := nil.
		^self quickSend: selector to: thisReceiver with: arguments lookupIn: lookupClass].
	^self send: selector to: thisReceiver with: arguments lookupIn: lookupClass
]

{ #category : #controlling }
Context >> send: selector to: rcvr with: arguments [
	"Simulate the action of sending a message with selector arguments to rcvr."

	^self send: selector to: rcvr with: arguments lookupIn: (self objectClass: rcvr)
]

{ #category : #controlling }
Context >> send: selector to: rcvr with: arguments lookupIn: lookupClass [
	"Simulate the action of sending a message with selector and arguments
	 to rcvr. The argument, lookupClass, is the class in which to lookup the
	 message.  This is the receiver's class for normal messages, but for super
	 messages it will be some specific class related to the source method."

	| meth primIndex val ctxt |
	(meth := lookupClass lookupSelector: selector) ifNil:
		[^self send: #doesNotUnderstand:
				to: rcvr
				with: {(Message selector: selector arguments: arguments) lookupClass: lookupClass}
				lookupIn: lookupClass].
	meth numArgs ~= arguments size ifTrue:
		[^self error: 'Wrong number of arguments in simulated message ', selector printString].
	(primIndex := meth primitive) > 0 ifTrue:
		[val := self doPrimitive: primIndex method: meth receiver: rcvr args: arguments.
		 (self isPrimFailToken: val) ifFalse:
			[^val]].
	(selector == #doesNotUnderstand: and: [lookupClass == ProtoObject]) ifTrue:
		[^self error: 'Simulated message ', arguments first selector, ' not understood'].
	ctxt := Context sender: self receiver: rcvr method: meth arguments: arguments.
	primIndex > 0 ifTrue:
		[ctxt failPrimitiveWith: val].
	^ctxt
]

{ #category : #accessing }
Context >> sender [
	"Answer the context that sent the message that created the receiver."

	^sender
]

{ #category : #private }
Context >> setSender: s receiver: r method: m arguments: args [ 
	"Create the receiver's initial state."

	sender := s.
	receiver := r.
	method := m.
	closureOrNil := nil.
	pc := method initialPC.
	self stackp: method numTemps.
	1 to: args size do: [:i | self at: i put: (args at: i)]
]

{ #category : #private }
Context >> setSender: s receiver: r method: m closure: c startpc: startpc [
	"Create the receiver's initial state."

	sender := s.
	receiver := r.
	method := m.
	closureOrNil := c.
	pc := startpc.
	stackp := 0
]

{ #category : #'debugger access' }
Context >> shortStack [
	"Answer a String showing the top ten contexts on my sender chain."

	^ String streamContents:
		[:strm |
		(self stackOfSize: 10)
			do: [:item | strm print: item; cr]]
]

{ #category : #'read-only objects' }
Context >> simulatedObject: anObject instVarAt: anIndex put: aValue [ 
	"Primitive. Store a value into a fixed variable in the argument anObject.
	 The numbering of the variables corresponds to the named instance
	 variables.  Fail if the index is not an Integer or is not the index of a
	 fixed variable, or if anObject is read-only. This version correctly simulates
	 assigning to a read-only object. Answer the value stored as the result.
	 Using this message violates the  principle that each object has sovereign
	 control over the storing of values into its instance variables. Essential for
	 the debugger. See Object documentation whatIsAPrimitive."

	<primitive: 174 error: ec>
	ec == #'no modification' ifTrue:
		[^self send: #attemptToAssign:to:withIndex: to: self with: {aValue. anObject. anIndex} lookupIn: self class].
	self primitiveFailed
]

{ #category : #'debugger access' }
Context >> singleRelease [
	"Remove information from the receiver in order to break circularities."

	stackp == nil ifFalse: [1 to: stackp do: [:i | self at: i put: nil]].
	sender := nil.
	pc := nil.

]

{ #category : #accessing }
Context >> size [
	"Primitive. Answer the number of indexable variables in the receiver. 
	This value is the same as the largest legal subscript. Essential. See Object 
	documentation whatIsAPrimitive.  Override the default primitive to give latitude to
	 the VM in context management."

	<primitive: 212>
	"The number of indexable fields of fixed-length objects is 0"
	^self primitiveFailed
]

{ #category : #accessing }
Context >> sourceCode [
	^self method getSource.
	
	"Note: The above is a bit safer than
		^ methodClass sourceCodeAt: selector
	which may fail if the receiver's method has been changed in
	the debugger (e.g., the method is no longer in the methodDict
	and thus the above selector is something like #Doit:with:with:with:)
	but the source code is still available."
]

{ #category : #'debugger access' }
Context >> stack [ 
	"Answer an Array of the contexts on the receiver's sender chain."

	^self stackOfSize: 9999
]

{ #category : #'debugger access' }
Context >> stackOfSize: limit [ 
	"Answer an OrderedCollection of the top 'limit' contexts
	 on the receiver's sender chain."

	| stack ctxt |
	stack := OrderedCollection new.
	stack addLast: (ctxt := self).
	[(ctxt := ctxt sender) ~~ nil
	 and: [stack size < limit]] whileTrue:
		[stack addLast: ctxt].
	^stack
]

{ #category : #private }
Context >> stackPtr [  "For use only by the SystemTracer and the Debugger, Inspectors etc"
	^ stackp
]

{ #category : #private }
Context >> stackp: newStackp [
	"Storing into the stack pointer is a potentially dangerous thing.
	This primitive stores nil into any cells that become accessible as a result,
	and it performs the entire operation atomically."
	"Once this primitive is implemented, failure code should cause an error"

	<primitive: 76>
	self error: 'stackp store failure'.
"
	stackp == nil ifTrue: [stackp := 0].
	newStackp > stackp  'effectively checks that it is a number'
		ifTrue: [oldStackp := stackp.
				stackp := newStackp.
				'Nil any newly accessible cells'
				oldStackp + 1 to: stackp do: [:i | self at: i put: nil]]
		ifFalse: [stackp := newStackp]
"
]

{ #category : #private }
Context >> startpc [
	^closureOrNil
		ifNil:	[self method initialPC]
		ifNotNil: [closureOrNil startpc]
]

{ #category : #'system simulation' }
Context >> step [
	"Simulate the execution of the receiver's next bytecode. Answer the 
	context that would be the active context after this bytecode."

	^self interpretNextInstructionFor: self
]

{ #category : #'system simulation' }
Context >> stepToCallee [
	"Step to callee or sender"

	| ctxt |
	ctxt := self.
	[(ctxt := ctxt step) == self] whileTrue.
	^ ctxt
]

{ #category : #'system simulation' }
Context >> stepToSendOrReturn [
	"Simulate the execution of bytecodes until either sending a message or 
	 returning a value to the receiver (that is, until switching contexts)."

	| ctxt |
	[self willReallySend or: [self willReturn or: [self willReallyStore]]] whileFalse:
		[ctxt := self step.
		 ctxt == self ifFalse:
			[self halt. 
			 "Caused by mustBeBoolean handling"
			 ^ctxt]]
]

{ #category : #'objects from disk' }
Context >> storeDataOn: aDataStream [
	"Contexts are not always allowed go to out in DataStreams.  They must be included inside an ImageSegment,
	 or be being saved for a closure."
	| cntInstVars cntIndexedVars |

	(aDataStream insideASegment
	 or: [(Notification new tag: self; signal) == self]) ifFalse: "or perhaps ImageSegments were not used at all"
		[self error: 'This Context was not included in the ImageSegment'].

	cntInstVars := self class instSize.
	cntIndexedVars := self method frameSize.
	aDataStream
		beginInstance: self class
		size: cntInstVars + cntIndexedVars.
	 1 to: cntInstVars do:
		[:i | aDataStream nextPut: (self instVarAt: i)].
	1 to: stackp do:
		[:i | aDataStream nextPut: (self basicAt: i)].
	stackp + 1 to: cntIndexedVars do:
		[:i | aDataStream nextPut: nil]
]

{ #category : #'instruction decoding' }
Context >> storeIntoLiteralVariable: value [ 
	"Simulate the action of bytecode that stores the top of the stack into a 
	literal variable of my method. If the receiver is read-only
	 this will provoke a send of #attemptToAssign:withIndex:"

	| top result |
	top := self top.
	result := self simulatedObject: value instVarAt: ValueIndex put: top.
	^(self object: result eqeq: top)
		ifTrue: [self]
		ifFalse: [result]
]

{ #category : #'instruction decoding' }
Context >> storeIntoReceiverVariable: offset [ 
	"Simulate the action of bytecode that stores the top of the stack into an 
	instance variable of my receiver. If the receiver is read-only
	 this will provoke a send of #attemptToAssign:withIndex:"

	| top result |
	top := self top.
	result := self simulatedObject: self receiver instVarAt: offset + 1 put: top.
	^(self object: result eqeq: top)
		ifTrue: [self]
		ifFalse: [result]
]

{ #category : #'instruction decoding' }
Context >> storeIntoRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex [
	"Simulate the action of bytecode that stores the top of the stack at
	 an offset in one of my local variables being used as a remote temp vector."

	self object: (self at: tempVectorIndex + 1) basicAt: remoteTempIndex + 1 put: self top
]

{ #category : #'instruction decoding' }
Context >> storeIntoTemporaryVariable: offset [ 
	"Simulate the action of bytecode that stores the top of the stack into one 
	of my temporary variables."

	self at: offset + 1 put: self top
]

{ #category : #'private-exceptions' }
Context >> swapReceiver: r [

	receiver := r
]

{ #category : #'debugger access' }
Context >> swapSender: coroutine [ 
	"Replace the receiver's sender with coroutine and answer the receiver's 
	previous sender. For use in coroutining."

	| oldSender |
	oldSender := sender.
	sender := coroutine.
	^oldSender
]

{ #category : #accessing }
Context >> tempAt: index [ 
	"Answer the value of the temporary variable whose index is the 
	 argument, index.  Primitive. Assumes receiver is indexable. Answer the
	 value of an indexable element in the receiver. Fail if the argument index
	 is not an Integer or is out of bounds. Essential. See Object documentation
	 whatIsAPrimitive.  Override the default at: primitive to give latitude to the
	 VM in context management."

	<primitive: 210>
	^self at: index
]

{ #category : #accessing }
Context >> tempAt: index put: value [ 
	"Store the argument, value, as the temporary variable whose index is the 
	 argument, index.  Primitive. Assumes receiver is indexable. Answer the
	 value of an indexable element in the receiver. Fail if the argument index
	 is not an Integer or is out of bounds. Essential. See Object documentation
	 whatIsAPrimitive.  Override the default at:put: primitive to give latitude to
	 the VM in context management."

	<primitive: 211>
	^self at: index put: value
]

{ #category : #controlling }
Context >> terminate [
	"Make myself unresumable."

	sender := nil.
	pc := nil.

]

{ #category : #controlling }
Context >> terminateTo: previousContext [
	"Terminate all the Contexts between me and previousContext, if previousContext is on my Context stack. Make previousContext my sender."

	| currentContext sendingContext |
	<primitive: 196>
	(self hasSender: previousContext) ifTrue: [
		currentContext := sender.
		[currentContext == previousContext] whileFalse: [
			sendingContext := currentContext sender.
			currentContext terminate.
			currentContext := sendingContext]].
	sender := previousContext
]

{ #category : #controlling }
Context >> top [
	"Answer the top of the receiver's stack."

	^self at: stackp
]

{ #category : #private }
Context >> tryNamedPrimitiveIn: aCompiledMethod for: aReceiver withArgs: arguments [
	"Invoke the named primitive for aCompiledMethod, answering its result, or,
	 if the primiitve fails, answering the error code."
	<primitive: 218 error: ec>
	ec ifNotNil:
		["If ec is an integer other than -1 there was a problem with primitive 218,
		  not with the external primitive itself.  -1 indicates a generic failure (where
		  ec should be nil) but ec = nil means primitive 218 is not implemented.  So
		  interpret -1 to mean the external primitive failed with a nil error code."
		 ec isInteger ifTrue:
			[ec = -1
				ifTrue: [ec := nil]
				ifFalse: [self primitiveFailed]]].
	^self class primitiveFailTokenFor: ec
]

{ #category : #private }
Context >> tryPrimitiveFor: method receiver: receiver args: arguments [ 
	"If this method has a primitive index, then run the primitive and return its result.
	Otherwise (and also if the primitive fails) return PrimitiveFailToken,
	as an indication that the method should be activated and run as bytecodes."
	| primIndex |
	(primIndex := method primitive) = 0 ifTrue: [^{PrimitiveFailToken. nil}].
	^ self doPrimitive: primIndex method: method receiver: receiver args: arguments
]

{ #category : #'private-exceptions' }
Context >> unwindTo: aContext [

	| ctx unwindBlock |
	ctx := self.
	[(ctx := ctx findNextUnwindContextUpTo: aContext) isNil] whileFalse: [
		(ctx tempAt: 2) ifNil:[
			ctx tempAt: 2 put: true.
			unwindBlock := ctx tempAt: 1.
			unwindBlock value]
	].

]
