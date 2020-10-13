"
Compile-time transformation of #future and #future: messages.  Use is best described through examples:

	receiver future doSomething: arg1 withArgs: arg2.
	(receiver future: 2000) doSomethingElse

The first means to immediately schedule #doSomething:withArgs: for asyncronous evaluation.  The second means to wait 2000 milliseconds before scheduling #doSomethingElse for asynchronous evaluation.

These are transformed into either #futureDo:at:args: or #futureSend:at:args:, depending on whether the result is used.  Let's look at a few examples.

	[receiver future foo. 2+2] value.
	true ifTrue: [^receiver future foo].
	arraySize := receiver future getArray wait size.
	
In the first case, the result is never used, so the message #futureDo:at:args: is generated.  In the second case, the result is answered from the current method.  Since we don't do any cross-method analysis, we have to assume that the result is needed for a later computation.  The result is provided in the form of a Promise, which will resolve to a value when the asynchronous evaluation has completed.  Creating and resolving this Promise is the responsibility of #futureSend:at:args:, which is generated instead of #futureDo:at:args: when code-analysis indicates that the result of the message might be used.  The third example is another one where #futureSend:at:args: is generated.

See the default implementations of #futureDo:at:args: and #futureSend:at:args: in Object.  Subclasses are free to override the default implementations to achieve specific effects.  For example, this functionality originated in the Croquet class TFarRef.  If you have a TFarRef to a replicated object, then sending 'aTFarRef future foo' results in a message being sent over the network to each replica of the object referenced by aTFarRef.  We might also use far-refs, for example, to send a message to an object in another Hydra object-memory.
"
Class {
	#name : #FutureNode,
	#superclass : #ParseNode,
	#instVars : [
		'receiver',
		'originalSelector',
		'futureSelector',
		'futureDelta',
		'futureArgs',
		'effectNode',
		'valueNode'
	],
	#category : #'Compiler-ParseNodes'
}

{ #category : #visiting }
FutureNode >> accept: aVisitor [
	^aVisitor visitFutureNode: self
]

{ #category : #'closure analysis' }
FutureNode >> analyseTempsWithin: scopeBlock "<BlockNode>" rootNode: rootNode "<MethodNode>" assignmentPools: assignmentPools [ "<Dictionary>"
	{ receiver. futureDelta }, (futureArgs ifNil: [#()]) do:
		[:node|
		node == nil ifFalse:
			[node analyseTempsWithin: scopeBlock rootNode: rootNode assignmentPools: assignmentPools]]
]

{ #category : #'code generation' }
FutureNode >> emitCodeForBlockValue: stack encoder: encoder [
	"Generate code for evaluating the last statement in a block."
	^effectNode emitCodeForValue: stack encoder: encoder
]

{ #category : #'code generation' }
FutureNode >> emitCodeForEffect: stack encoder: encoder [
	^effectNode emitCodeForEffect: stack encoder: encoder
]

{ #category : #'code generation' }
FutureNode >> emitCodeForValue: stack encoder: encoder [
	^valueNode emitCodeForValue: stack encoder: encoder
]

{ #category : #'initialize-release' }
FutureNode >> futureMessage: selName arguments: args  from: encoder sourceRange: range [
	futureSelector := selName.
	futureArgs := args.
	^self
]

{ #category : #accessing }
FutureNode >> futureSelector [
	^futureSelector
]

{ #category : #testing }
FutureNode >> isFutureNode [
	^true
]

{ #category : #accessing }
FutureNode >> originalSelector [
	^originalSelector
]

{ #category : #accessing }
FutureNode >> receiver [
	^receiver
]

{ #category : #'initialize-release' }
FutureNode >> receiver: rcvr selector: selector arguments: args precedence: p from: encoder sourceRange: range [
	receiver := rcvr.
	originalSelector := selector.
	originalSelector == #future: ifTrue:[futureDelta := args first].
	encoder noteSourceRange: range forNode: self.
]

{ #category : #'code generation' }
FutureNode >> sizeCodeForBlockValue: encoder [
	receiver == NodeSuper ifTrue: [^self error: 'Futures cannot send to future'].
	(futureArgs isNil or: [futureSelector isNil]) ifTrue:
		[^self error: 'Futures must be sent messages'].
	encoder sharableLitIndex: originalSelector. "to find its senders"
	futureDelta ifNil:[futureDelta := encoder encodeLiteral: 0].
	effectNode := MessageNode new
		receiver: receiver
		selector: #futureDo:at:args:
		arguments: (Array 
			with: (encoder encodeLiteral: futureSelector) 
			with: futureDelta
			with: (BraceNode new elements: futureArgs))
		precedence: 3 
		from: encoder.
	^effectNode sizeCodeForValue: encoder
]

{ #category : #'code generation' }
FutureNode >> sizeCodeForEffect: encoder [
	receiver == NodeSuper ifTrue: [^self error: 'Futures cannot send to future'].
	(futureArgs isNil or: [futureSelector isNil]) ifTrue:
		[^self error: 'Futures must be sent messages'].
	encoder sharableLitIndex: originalSelector. "to find its senders"
	futureDelta ifNil:[futureDelta := encoder encodeLiteral: 0].
	effectNode := MessageNode new
		receiver: receiver
		selector: #futureDo:at:args:
		arguments: (Array 
			with: (encoder encodeLiteral: futureSelector) 
			with: futureDelta
			with: (BraceNode new elements: futureArgs))
		precedence: 3 
		from: encoder.
	^effectNode sizeCodeForEffect: encoder
]

{ #category : #'code generation' }
FutureNode >> sizeCodeForValue: encoder [
	receiver == NodeSuper ifTrue: [^self error: 'Futures cannot send to future'].
	(futureArgs isNil or: [futureSelector isNil]) ifTrue:
		[^self error: 'Futures must be sent messages'].
	encoder sharableLitIndex: originalSelector. "to find its senders"
	futureDelta ifNil:[futureDelta := encoder encodeLiteral: 0].
	valueNode := MessageNode new
		receiver: receiver
		selector: #futureSend:at:args:
		arguments: (Array 
			with: (encoder encodeLiteral: futureSelector) 
			with: futureDelta
			with: (BraceNode new elements: futureArgs))
		precedence: 3 
		from: encoder.
	^valueNode sizeCodeForValue: encoder
]
