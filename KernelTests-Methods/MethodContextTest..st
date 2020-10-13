"
I am an SUnit Test of Context. See also BlockClosureTest.
See pages 430-437 of A. Goldberg and D. Robson's Smalltalk-80 The Language (aka the purple book), which deal with Contexts. My fixtures are from their example. To see how blocks are implemented in this version of Squeak see http://www.mirandabanda.org/cogblog/2008/06/07/closures-part-i/ and http://www.mirandabanda.org/cogblog/2008/07/22/closures-part-ii-the-bytecodes/.  (The Squeak V3 byte codes are not quite the same as Smalltalk-80, and the SistaV1 byetcodes are quite different.)
My fixtures are:
aReceiver         - just some arbitrary object, ""Rectangle origin: 100@100 corner: 200@200""
aSender           - just some arbitrary object, thisContext
aCompiledMethod - just some arbitrary method, ""Rectangle rightCenter"".
aMethodContext   - just some arbitray context ...  


"
Class {
	#name : #MethodContextTest,
	#superclass : #TestCase,
	#instVars : [
		'aCompiledMethod',
		'aReceiver',
		'aMethodContext',
		'aSender'
	],
	#category : #'KernelTests-Methods'
}

{ #category : #private }
MethodContextTest >> privRestartTest [
	"This tests may loop endlessly if incorrect, so call it from another method testing it does not time out"
	|a firstTimeThrough |
	firstTimeThrough := true.
	a := 10.
	
	self assert: 30 equals: [|b| 
		self assert: 10 = a .
		self assert: nil == b.
		b := a + 20. 
		firstTimeThrough ifTrue: [
			firstTimeThrough := false.
			thisContext restart.].
		b] value

]

{ #category : #running }
MethodContextTest >> setUp [
	super setUp.
	aCompiledMethod := Rectangle methodDict at: #rightCenter.
	aReceiver := 100@100 corner: 200@200.
	aSender := thisContext.
	aMethodContext := Context sender: aSender receiver: aReceiver method: aCompiledMethod arguments: #(). 
]

{ #category : #tests }
MethodContextTest >> testActivateReturnValue [
	self assert:  (aSender activateReturn: aMethodContext value: #()) isContext.
	self assert:  ((aSender activateReturn: aMethodContext value: #()) receiver = aMethodContext).
]

{ #category : #tests }
MethodContextTest >> testCopyStack [
	self assert: aMethodContext copyStack printString = aMethodContext printString.
]

{ #category : #tests }
MethodContextTest >> testCopyTo [

	| context depth targetSender |
	context := thisContext.
	depth := 1.
	targetSender := context.
	[ (targetSender := targetSender sender) isNil ] whileFalse: [
		| original copy |
		original := context.
		copy := context copyTo: targetSender.
		1 to: depth do: [ :index |
			index = 1 ifFalse: [ 
				"Since we're copying thisContext, the pc and stackPtr may be different for the current frame."
				self
					assert: original pc equals: copy pc;
					assert: original stackPtr equals: copy stackPtr ].
			self
				deny: original == copy;
				assert: original method equals: copy method;
				assert: original closure equals: copy closure;
				assert: original receiver equals: copy receiver.
			original := original sender.
			copy := copy sender ].
		self
			assert: copy isNil;
			assert: original == targetSender.
		depth := depth + 1 ]
]

{ #category : #tests }
MethodContextTest >> testFindContextSuchThat [
	self assert: (aMethodContext findContextSuchThat: [:each| true]) printString = aMethodContext printString.
	self assert: (aMethodContext hasContext: aMethodContext). 
]

{ #category : #tests }
MethodContextTest >> testMethodContext [
	self assert: aMethodContext home notNil.
	self assert: aMethodContext receiver notNil.
	self assert: aMethodContext method isCompiledMethod.
]

{ #category : #tests }
MethodContextTest >> testMethodIsBottomContext [
	self assert: aMethodContext bottomContext = aSender.
	self assert: aMethodContext secondFromBottom = aMethodContext.
]

{ #category : #tests }
MethodContextTest >> testRestart [
	self should: [self privRestartTest] notTakeMoreThan: 0.1 second
]

{ #category : #tests }
MethodContextTest >> testReturn [
	"Why am I overriding setUp? Because sender must be thisContext, i.e, testReturn, not setUp."
	aMethodContext := Context sender: thisContext receiver: aReceiver method: aCompiledMethod arguments: #(). 
	self assert: (aMethodContext return: 5) = 5
]

{ #category : #tests }
MethodContextTest >> testSetUp [
	"Note: In addition to verifying that the setUp worked the way it was expected to, testSetUp is used to illustrate the meaning of the simple access methods, methods that are not normally otherwise 'tested'"
	self assert: aMethodContext isContext.
	self deny: aMethodContext isExecutingBlock.
	self deny: aMethodContext isClosure.
	self deny: aMethodContext isDead.
	"self assert: aMethodContext home = aReceiver."
	"self assert: aMethodContext blockHome = aReceiver."
	self assert: aMethodContext receiver = aReceiver.
	self assert: aMethodContext method isCompiledMethod.
	self assert: aMethodContext method = aCompiledMethod.
	self assert: aMethodContext methodNode selector = #rightCenter.
	self assert: (aMethodContext methodNodeFormattedAndDecorated: true) selector = #rightCenter.
	self assert: aMethodContext client printString = 'MethodContextTest>>#testSetUp'.

]
