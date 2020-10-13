"
This is the unit test for the class CompiledMethod. Unit tests are a good way to exercise the functionality of your system in a repeatable and automatic manner. They are therefore recommended if you plan to release anything. For more information, see: 
	- http://www.c2.com/cgi/wiki?UnitTest
	- http://minnow.cc.gatech.edu/squeak/1547
	- the sunit class category
"
Class {
	#name : #CompiledMethodTest,
	#superclass : #ClassTestCase,
	#category : #'KernelTests-Methods'
}

{ #category : #'tests - performing' }
CompiledMethodTest >> a1: a1 a2: a2 a3: a3 a4: a4 a5: a5 a6: a6 a7: a7 a8: a8 a9: a9 a10: a10 a11: a11 a12: a12 a13: a13 a14: a14 a15: a15 [
	"I'm a method with the maximum size of arguments that can be executed via normal send but crash on perform :)"
	
	^ a1 + a2 - a2
]

{ #category : #failures }
CompiledMethodTest >> expectedFailures [

	Smalltalk isRunningCog ifTrue: [ ^super expectedFailures ].
	^#(
		"Not supported by the interpreter VM. See method comments for details"
		testPerformInSuperclassCanExecutelongMethodWithTemps
	)
]

{ #category : #private }
CompiledMethodTest >> performTest [

	Utilities
		useAuthorInitials: self className
		during: [ super performTest ]
]

{ #category : #examples }
CompiledMethodTest >> returnPlusOne: anInteger [
	^anInteger + 1. 
]

{ #category : #examples }
CompiledMethodTest >> returnTrue [
	^true  
]

{ #category : #'tests - closures' }
CompiledMethodTest >> testClosureCompiled [
	self
		assert: (self class >> #withClosure) isClosureCompiled;
		assert: (self class >> #withClosureNoNLR) isClosureCompiled
]

{ #category : #'tests - closures' }
CompiledMethodTest >> testClosureNLRs [
	self
		assert:
			((self class >> #withClosure) embeddedBlockClosures at: 1)
				hasMethodReturn;
		assert:
			((self class >> #withClosureNoNLR) embeddedBlockClosures at: 1) 
				hasMethodReturn not
]

{ #category : #'tests - closures' }
CompiledMethodTest >> testClosureSize [
	| compiledMethod expectedSize |
	compiledMethod := (self class >> #withClosure).
	expectedSize := compiledMethod bytecodeSetName
		caseOf: {
			['SistaV1'] -> [3].
			['V3PlusClosures'] -> [2]}.
	self assert: expectedSize equals: (compiledMethod embeddedBlockClosures at: 1) size.
	compiledMethod := (self class >> #withClosureNoNLR).
	expectedSize := compiledMethod bytecodeSetName
		caseOf: {
			['SistaV1'] -> [3].
			['V3PlusClosures'] -> [2]}.
	self assert: expectedSize equals: (compiledMethod embeddedBlockClosures at: 1) size.
]

{ #category : #'tests - copying' }
CompiledMethodTest >> testCopy [
	<pragma: #pragma>
	| method copy |
	method := thisContext method.
	self assert: method pragmas notEmpty.
	copy := method copy.
	self assert: (method equivalentTo: copy).
	self assert: method = copy.
	self assert: method ~~ copy.
	method pragmas do:
		[:p|
		self assert: p method == method].
	copy pragmas do:
		[:p|
		self assert: p method == copy]
]

{ #category : #'tests - copying' }
CompiledMethodTest >> testCopyWithTrailerBytes [
	<pragma: #pragma>
	| method copy |
	method := thisContext method.
	self assert: method pragmas notEmpty.
	copy := method copyWithTempNames: #('m' 'c').
	self assert: (method equivalentTo: copy).
	self deny: method = copy. "copyWithTempNames: changes the length of a method so these are no longer equal."
	self assert: method symbolic = copy symbolic. "but their bytecode should be the same"
	self assert: method ~~ copy.
	method pragmas do:
		[:p|
		self assert: p method == method].
	copy pragmas do:
		[:p|
		self assert: p method == copy]
]

{ #category : #'tests - decompiling' }
CompiledMethodTest >> testDecompile [
	"self debug: #testDecompileTree"
	| method  cls stream |

	Smalltalk removeClassNamed: #TUTU.

	cls := Object subclass: #TUTU
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: 'KernelTests-Methods'.
	cls compileSilently: 'foo ^ 10'.
	method := cls >> #foo.
	Smalltalk removeClassNamed: #TUTU.
	stream := String new writeStream.
	method decompile printOn: stream.
	self assert: stream contents = 'foo
	^ 10'
	
	
	
]

{ #category : #'tests - closures' }
CompiledMethodTest >> testHasClosure [
	self
		assert: (self class >> #withClosure) containsBlockClosures;
		assert: (self class >> #withClosureNoNLR) containsBlockClosures;
		assert: (self class >> #withoutClosure) containsBlockClosures not
]

{ #category : #'tests - testing' }
CompiledMethodTest >> testIsInstalled [
|  method cls |

	method := (self class)>>#returnTrue.
	self assert: method isInstalled.

	"now make an orphaned method by just deleting the class."

	Smalltalk removeClassNamed: #TUTU.

	cls := Object subclass: #TUTU
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: 'KernelTests-Methods'.
	cls compile: 'foo ^ 10'.
	method := cls >> #foo.
	Smalltalk removeClassNamed: #TUTU.

	self deny: method isInstalled. 
]

{ #category : #'tests - testing' }
CompiledMethodTest >> testIsQuick [
	| method  |

	method := self class compiledMethodAt: #returnTrue.
	self assert: (method isQuick).

	method := self class compiledMethodAt: #returnPlusOne:.
	self deny: (method isQuick).

	
]

{ #category : #'tests - accessing' }
CompiledMethodTest >> testMethodClass [
	| method cls binding |
	method := self class >> #returnTrue.
	self assert: #returnTrue equals: method selector.
	"now make an orphaned method by just deleting the class.
		old: #unknown
		pre-environment semantics: return Obsolete class
		environment semantics: return binding's value, which will be nil"
	(Smalltalk classNamed: #TUTU) ifNotNil:
		[Smalltalk removeClassNamed: #TUTU].
	cls := Object
				subclass: #TUTU
				instanceVariableNames: ''
				classVariableNames: ''
				poolDictionaries: ''
				category: 'KernelTests-Methods'.
	cls compile: 'foo ^ 10'.
	method := cls >> #foo.
	binding := cls binding.
	self assert: binding value equals: (Smalltalk classNamed: #TUTU) description: 'binding before class removal'.
	self assert: (Smalltalk classNamed: #TUTU) equals: method methodClass description: 'methodClass before class removal'.
	Smalltalk removeClassNamed: #TUTU.
	self assert: binding value equals: method methodClass description: 'methodClass after class removal'.
]

{ #category : #tests }
CompiledMethodTest >> testNew [
	"This /should/ throw an exception."
	self should: [self targetClass new] raise: Error
]

{ #category : #'tests - performing' }
CompiledMethodTest >> testPerformCanExecutelongMethodWithTemps [
	"self debug: #testPerformCanExecutelongMethodWithTemps"
	"the perform: primitive reuses the context of the method calling it. The primitive adds performed selector arguments to the context variables list. So this means that you can execute some methods but not performed them if the calling methods defined too many temps "
	
	| temp1 temp2 temp3 |
	temp1 := 33.
	temp2 := 666.
	temp3 := 42. 
	self assert: (self perform: #a1:a2:a3:a4:a5:a6:a7:a8:a9:a10:a11:a12:a13:a14:a15: withArguments: #(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15)) = 1.
	self assert: (self class>>#testPerformCanExecutelongMethodWithTemps) frameSize = CompiledMethod smallFrameSize.
	self assert: (self class>>#a1:a2:a3:a4:a5:a6:a7:a8:a9:a10:a11:a12:a13:a14:a15:) frameSize = CompiledMethod fullFrameSize.
]

{ #category : #'tests - performing' }
CompiledMethodTest >> testPerformInSuperclassCanExecutelongMethodWithTemps [
	"This test documents a limitation of the standard Squeak VM that has
	been addressed in the Cog family of VMs. The test will pass on Cog, but
	is expected to fail on an interpreter VM. The test fails on an interpreter VM
	because the perform: primitive reuses the context of the method calling it.
	The primitive adds performed selector arguments to the context variables
	list. So this means that you can execute some methods but not performed
	them if the calling methods defined too many temps."

	"self debug: #testPerformInSuperclassCanExecutelongMethodWithTemps"
	
	| temp1 temp2 temp3 |
	temp1 := 33.
	temp2 := 666.
	temp3 := 42. 
	self assert: (self perform: #a1:a2:a3:a4:a5:a6:a7:a8:a9:a10:a11:a12:a13:a14:a15: withArguments: #(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15) inSuperclass: self class) = 1
]

{ #category : #'tests - accessing' }
CompiledMethodTest >> testSearchForClass [
	|  method cls |

	method := (self class)>>#returnTrue.
	self assert: (method searchForClass = self class).
	
	"now make an orphaned method. we want to get nil as the class"	
	
	Smalltalk removeClassNamed: #TUTU.

	cls := Object subclass: #TUTU
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: 'KernelTests-Methods'.
	cls compile: 'foo ^ 10'.
	method := cls >> #foo.
	Smalltalk removeClassNamed: #TUTU.
	
	self assert: method searchForClass = nil. 

]

{ #category : #'tests - accessing' }
CompiledMethodTest >> testSearchForSelector [
	|  method cls |

	method := (self class)>>#returnTrue.
	self assert: (method searchForSelector = #returnTrue).

	"now make an orphaned method. we want to get nil as the selector"	
	
	Smalltalk removeClassNamed: #TUTU.

	cls := Object subclass: #TUTU
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: 'KernelTests-Methods'.
	cls compile: 'foo ^ 10'.
	method := cls >> #foo.
	Smalltalk removeClassNamed: #TUTU.
	
	self assert: method searchForSelector = nil. 

]

{ #category : #'tests - accessing' }
CompiledMethodTest >> testSelector [
	|  method cls |

	method := (self class)>>#returnTrue.
	self assert: (method selector = #returnTrue).

	"now make an orphaned method. new semantics: return corrent name"	
	
	Smalltalk removeClassNamed: #TUTU.

	cls := Object subclass: #TUTU
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: 'KernelTests-Methods'.
	cls compile: 'foo ^ 10'.
	method := cls >> #foo.
	Smalltalk removeClassNamed: #TUTU.

	self assert: method selector = #foo. 

]

{ #category : #'tests - evaluating' }
CompiledMethodTest >> testValueWithReceiverArguments [
	
	| method value |

	method := self class compiledMethodAt: #returnTrue.

	value := method valueWithReceiver: nil arguments: #().
	self assert: (value = true).

	method := self class compiledMethodAt: #returnPlusOne:.
	value := method valueWithReceiver: nil arguments: #(1).
	self assert: (value = 2).	
]

{ #category : #examples }
CompiledMethodTest >> withClosure [
	[ ^ 23 ] value
]

{ #category : #examples }
CompiledMethodTest >> withClosureNoNLR [
	^ [ 23 ] value
]

{ #category : #examples }
CompiledMethodTest >> withoutClosure [
	^ 23 + 42
]
