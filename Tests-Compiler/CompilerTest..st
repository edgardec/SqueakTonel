"
CompilerTest is a holder for SUnit test of Compiler
"
Class {
	#name : #CompilerTest,
	#superclass : #TestCase,
	#category : #'Tests-Compiler'
}

{ #category : #'private - test support' }
CompilerTest class >> compileMethodToUseFullBlocks: selector [
	| method encoderClass |
	method := self >> selector.
	encoderClass := {CompiledCode primaryBytecodeSetEncoderClass. CompiledCode secondaryBytecodeSetEncoderClass} select:
							[:class| class supportsFullBlocks].
	self compileCue: ((CompilationCue
							source: method getSource
							class: self
							environment: self environment
							requestor: nil)
						encoderClass: EncoderForSistaV1;
						methodTrailer: method trailer;
						yourself)
		environment: self environment
		classified: (self whichCategoryIncludesSelector: selector)
		withStamp: method timeStamp
		notifying: nil
		logSource: false

	"self compileMethodToUseFullBlocks: #foo"
]

{ #category : #private }
CompilerTest >> foo [
	^[{thisContext method method. thisContext home method}] value

	"CompilerTest compile: (CompilerTest sourceCodeAt: #foo) classified: #private"
	"self new foo first == self new foo second"
]

{ #category : #private }
CompilerTest >> fubar [
	^[[[[{thisContext method method. thisContext home method}] value ] value ] value ] value

	"CompilerTest compile: (CompilerTest sourceCodeAt: #fubar) classified: #private"
	"self new fubar first == self new fubar second"
]

{ #category : #private }
CompilerTest >> runTestAllNodePCsAreForBytecodesInMethod: aMethod [
	"Before 1/3/2019 14:10 the bytecode compiler would ascribe the wrong pcs for long conditional branches
	 at the head of ifTrue:ifFalse: et al.  This test checks that all nodes with a pc map to a real bytecode."
	| class methodAndNode bytecodes |
	class := aMethod methodClass.
	methodAndNode := CompiledMethod
							noCheckSetPreferredBytecodeSetTo: aMethod encoderClass
							while:
								[class
									compile:(class sourceCodeAt: aMethod selector)
									environment: class environment
									notifying: nil
									trailer: aMethod trailer 
									ifFail: [^nil]].
	bytecodes := self validPCsForMethod: methodAndNode method.
	bytecodes add: methodAndNode node pc.
	methodAndNode node nodesDo:
		[:node|
		node pc ifNotNil:
			[:pc|
			self assert: (bytecodes includes: pc)]]
]

{ #category : #private }
CompilerTest >> runTestAllNodePCsAreForBytecodesInPackage: packageName [
	"Before 1/3/2019 14:10 the bytecode compiler would ascribe the wrong pcs for long conditional branches
	 at the head of ifTrue:ifFalse: et al.  This slow test checks that all nodes with a pc in any method map to a
	 real bytecode."
	(PackageInfo named: packageName) actualMethodsDo:
		[:method| self runTestAllNodePCsAreForBytecodesInMethod: method]
]

{ #category : #'tests - debugging' }
CompilerTest >> testAllNodePCsAreForBytecodesInCollections [
	<timeout: 30> "Approximately 2 seconds on 2018 2.9GHz Core i9 MacBook Pro running 64-bit Squeak Cog VM"
	self runTestAllNodePCsAreForBytecodesInPackage: #Collections
]

{ #category : #'tests - debugging' }
CompilerTest >> testAllNodePCsAreForBytecodesInKernel [
	<timeout: 30> "Approximately 3 seconds on 2018 2.9GHz Core i9 MacBook Pro running 64-bit Squeak Cog VM"
	self runTestAllNodePCsAreForBytecodesInPackage: #Kernel
]

{ #category : #'tests - debugging' }
CompilerTest >> testAllNodePCsAreForBytecodesInMorphic [
	<timeout: 30> "Approximately 6 seconds on 2018 2.9GHz Core i9 MacBook Pro running 64-bit Squeak Cog VM"
	self runTestAllNodePCsAreForBytecodesInPackage: #Morphic
]

{ #category : #'tests - syntax' }
CompilerTest >> testBinarySelectorWithBar [
	"Acknowledge the fact that $| is now allowed at any place in a binary selector"
	
	#(#'||' #'|||' #'|||++' #'<|>') do: [:selector | | source tree |
		source := ('1 ' , selector , ' 2') readStream.
		tree := (Compiler new)
			compileNoPattern: source in: Object notifying: nil ifFail: [nil].
		self assert: tree notNil.
	
		"Hem, this test is really ugly..."
		self assert: tree block statements first expr selector key = selector].
]

{ #category : #'tests - syntax' }
CompilerTest >> testBinarySelectorWithMinus [
	"Acknowledge the fact that $- is now allowed at any place in a binary selector"
	
	| source tree |
	source := '1 @- 2' readStream.
	tree := (Compiler new)
			compileNoPattern: source in: Object notifying: nil ifFail: [nil].
	self assert: tree notNil.
	
	"Hem, this test is really ugly..."
	self assert: tree block statements first expr selector key = #'@-'.
]

{ #category : #'tests - syntax' }
CompilerTest >> testEmptyTemporaries [
	self assert: (Compiler evaluate: '||') isNil
]

{ #category : #'tests - code generation' }
CompilerTest >> testEvaluationOfInlinedToDo [
	"Whether inlined or not, #to:do: should return the same value"
	| inlinedResult notInlinedResult |
	inlinedResult := Compiler new
				evaluate: '1+1 to: 0 do: [:i | ]'
				in: nil
				to: nil
				notifying: nil 
				ifFail: [^ #failedDoit].
	notInlinedResult := Compiler new
				evaluate: '| aBlock | aBlock := [:i | ]. 1+1 to: 0 do: aBlock'
				in: nil
				to: nil
				notifying: nil 
				ifFail: [^ #failedDoit].
	self assert: inlinedResult = notInlinedResult.
	inlinedResult := Compiler new
						evaluate: '| stream results | 
									stream := ReadStream on: #(2 1).
									results := OrderedCollection new.
									stream next to: stream next do: [ :i | results add: i ].
									results'
						in: nil
						to: nil
						notifying: nil 
						ifFail: [^ #failedDoit].
	self assert: inlinedResult isEmpty.
	inlinedResult := Compiler new
						evaluate: '| stream results | 
									stream := ReadStream on: #(1 2).
									results := OrderedCollection new.
									stream next to: stream next do: [ :i | results add: i ].
									results'
						in: nil
						to: nil
						notifying: nil 
						ifFail: [^ #failedDoit].
	self assert: inlinedResult asArray = #(1 2)
]

{ #category : #'tests - syntax' }
CompilerTest >> testInvalidVerticalBarSelector [
	self should: [Compiler evaluate: '1 | | 2'] raise: SyntaxErrorNotification.
	self should: [Compiler evaluate: '1 | - 2'] raise: SyntaxErrorNotification.
]

{ #category : #'tests - syntax' }
CompilerTest >> testLocalTemporariesInABlock [
	self assert: ((Compiler evaluate: '[:x|| tmp | tmp := x]') value: 2) = 2
]

{ #category : #'tests - limits' }
CompilerTest >> testMaxLiterals [
	"Document the maximum number of literals in a compiled method"

	| maxLiterals stringThatCanBeCompiled stringWithOneTooManyLiterals |
	"Why 6?  It's rather implementation dependent.  But the {... construct is compiled as
		(Array braceStream: size)
			nextPut: expr;
			...;
			braceArray
	 where nextPut: is a special selector.  So one each for Array binding, #braceStream, #braceArray and the size,
	 one for the selector and one for the methodClass makes 6."
	maxLiterals := CompiledCode preferredBytecodeSetEncoderClass new maxNumLiterals - 6.
	stringThatCanBeCompiled := '{ ', (String streamContents: [:strm |
					1 to: maxLiterals do: [:e | strm nextPutAll: '''', e asString, '''', ' . ']]), '}'.
	stringWithOneTooManyLiterals := '{ ', (String streamContents: [:strm |
					1 to: maxLiterals + 1 do: [:e | strm nextPutAll: '''', e asString, '''', ' . ']]), '}'.
	self assert: ((1 to: maxLiterals) collect: #printString) equals: (Compiler evaluate: stringThatCanBeCompiled).
	
	"If the following test fails, it means that the limit has been raised or eliminated,
	and this test should be updated to reflect the improvement."
	self should: [Compiler evaluate: stringWithOneTooManyLiterals] raise: Error.

]

{ #category : #limits }
CompilerTest >> testMaxLiteralsWithClassReferenceInClosure [
	"Document the maximum number of literals in a compiled method. A class
	reference in a closure reduces the maximum literals."

	| bytecodeSetEncoder maxLiterals stringThatCanBeCompiled stringWithOneTooManyLiterals |
	bytecodeSetEncoder := CompiledMethod preferredBytecodeSetEncoderClass new.
	maxLiterals := bytecodeSetEncoder maxNumLiterals
					- 2 "for selector & methodClass"
					- (bytecodeSetEncoder supportsFullBlocks ifTrue: [1] ifFalse: [5 "For this example. See below"])
					- 4 "for the implicit stream processing into which the brace construct is compiled: (Array braceStream: size) braceArray".
	stringThatCanBeCompiled := '[ DateAndTime now. Date today. Time ]. { ',
			(String streamContents: [:strm |
					1 to: maxLiterals do: [:e | strm nextPutAll: '''', e asString, '''', ' . ']]), '}'.
	stringWithOneTooManyLiterals := '[ DateAndTime now. Date today. Time ]. { ',
			(String streamContents: [:strm |
					1 to: maxLiterals + 1 do: [:e | strm nextPutAll: '''', e asString, '''', ' . ']]), '}'.
	self assert: maxLiterals equals: (Compiler evaluate: stringThatCanBeCompiled) size.
	
	"If the following test fails, it means that the limit has been raised or eliminated,
	and this test should be updated to reflect the improvement."
	self should: [Compiler evaluate: stringWithOneTooManyLiterals] raise: Error.

]

{ #category : #'tests - syntax' }
CompilerTest >> testNegativeNumbers [
	"Acknowledge the fact that (-  2) which was accepted up to Squeak 3.10 is not valid anymore"
	
	self assert: (Compiler evaluate: '-2') = 2 negated.
	self should: [Compiler evaluate: '-  2'] raise: SyntaxErrorNotification description: 'A negative number literal shall not include any separator'
]

{ #category : #'tests - literals' }
CompilerTest >> testNegativeZero [
	self assert: (Compiler evaluate: '-0.0') hex = Float negativeZero hex.
]

{ #category : #'tests - literals' }
CompilerTest >> testScaledDecimalLiterals [
	"Equal ScaledDecimal with different scales should use different slots
	This is related to http://bugs.squeak.org/view.php?id=6797"
	
	"This correctly works when evaluated separately"
	self deny: (Compiler evaluate: '0.5s1') scale = (Compiler evaluate: '0.5s2') scale.
	
	"But not when evaluated together if literal reduction is too agressive"
	self deny: (Compiler evaluate: '0.5s1 scale =  0.5s2 scale').
]

{ #category : #'tests - code generation' }
CompilerTest >> testToDoModifiesTheLimit [
	"This is a non regression test for http://bugs.squeak.org/view.php?id=7093.
	When blocks writes into to:do: loop limit, optimization shall be carried with care."
	
	self
		assert: 4
		equals:
			[ | n |
			n := 2.
			1 to: n do: [:i | (n := n+1)>10 ifTrue: [self error: 'Should not get here']].
			n] value.
	self
		assert: 4
		equals:
			[ | n |
			n := 2.
			1 to: n by: 1 do: [:i | (n := n+1)>10 ifTrue: [self error: 'Should not get here']].
			n] value.
	self
		assert: 4
		equals:
			[ | n inc |
			n := 2.
			inc := 1.
			1 to: n by: inc do: [:i | (n := n+1)>10 ifTrue: [self error: 'Should not get here']].
			n] value.
]

{ #category : #'tests - code generation' }
CompilerTest >> testValidFullBlockMethod [
	"Check that the full block system creates properly connected methods
	 whose constituent blocks refer back to the correct method."
	#(foo fubar) do:
		[:selector| | fooMethod |
		fooMethod := self class >> selector.
		fooMethod encoderClass supportsFullBlocks ifFalse:
			[self class compileMethodToUseFullBlocks: selector.
			 fooMethod := self class >> selector].
		self assert: fooMethod encoderClass supportsFullBlocks.
		self assert: ((fooMethod literalAt: 1) isCompiledCode and: [(fooMethod literalAt: 1) isCompiledBlock]).
		self assert: (fooMethod literalAt: 1) method == fooMethod.
		"And if it looks safe to do so, actually run foo and check its result"
		(CompiledCode primaryBytecodeSetEncoderClass supportsFullBlocks
		or: [CompiledCode secondaryBytecodeSetEncoderClass supportsFullBlocks]) ifTrue:
			[self assert: {fooMethod. fooMethod } equals: (self perform: selector)]]
]

{ #category : #private }
CompilerTest >> validPCsForMethod: aMethod [
	"Answer a set of pcs (either integer pc for the method and embedded blocks,
	 or CompiledBlock -> integer pc for nested full blocks."
	| validPCs is |
	validPCs := Set new: aMethod size - aMethod initialPC.
	(is := InstructionStream on: aMethod) scanFor:
		[:b| validPCs add: is pc. false].
	aMethod nestedBlockMethods do:
		[:bm|
		 (is := InstructionStream on: bm) scanFor:
			[:b| validPCs add: bm -> is pc. false]].
	^validPCs
]
