"
I am an SUnit Test of BlockClosure and some of Context's simulation machinery'.  See also MethodContextTest.

My fixtures are:
aBlockClosure			- just some trivial block, i.e., [100@100 corner: 200@200].
homeOfABlockClosure	- the home context of the block

NOTES ABOUT AUTOMATING USER INPUTS

When executing non-interactive programs you will inevitably run into programs (like SqueakMap or Monticello installation packages -- and other programs, to be fair) that require user input during their execution and these sort of problems shoot the whole non-interactiveness of your enclosing program.

BlockClosure helper methods have been made available and tests of these helpers are provided in this class to demonstrate that it can intercept PopUpMenu and FillInTheBlankMorph requests for user interaction.  Of course, PopUpMenu and FillInTheBlankMorph were modified to first signal a ProvideAnswerNotification and if someone handles that (e.g. the enclosing block) then the user interaction will be circumvented and the provided answer of the enclosing block will be used.  The basic syntax looks like:

	[self confirm: 'Install spyware?'] valueSupplyingAnswer: #('Install spyware?' false)

There a few variants on this theme making it easy to provide a literal list of answers for the block so that you can handle a bunch of questions in a block with appropriate answers.

Additionally, it is possible to suppress Object>>inform: modal dialog boxes as these get in the way of automating anything.  After applying this changeset you should be able to tryout the following code snippets to see the variants on this theme that are available.

Examples:

So you don't need any introduction here -- this one works like usual.
[self inform: 'hello'. #done] value.

Now let's suppress all inform: messages.
[self inform: 'hello'; inform: 'there'. #done] valueSuppressingAllMessages.

Here we can just suppress a single inform: message.
[self inform: 'hi'; inform: 'there'. #done] valueSuppressingMessages: #('there')

Here you see how you can suppress a list of messages.
[self inform: 'hi'; inform: 'there'; inform: 'bill'. #done] valueSuppressingMessages: #('hi' 'there')

Enough about inform:, let's look at confirm:. As you see this one works as expected.
[self confirm: 'You like Squeak?'] value

Let's supply answers to one of the questions -- check out the return value.
[{self confirm: 'You like Smalltalk?'. self confirm: 'You like Squeak?'}]
	valueSupplyingAnswer: #('You like Smalltalk?' true)

Here we supply answers using only substrings of the questions (for simplicity).
[{self confirm: 'You like Squeak?'. self confirm: 'You like MVC?'}]
	valueSupplyingAnswers: #( ('Squeak' true) ('MVC' false) )

This time let's answer all questions exactly the same way.
[{self confirm: 'You like Squeak?'. self confirm: 'You like Morphic?'}]
	valueSupplyingAnswer: true
	
And, of course, we can answer FillInTheBlank questions in the same manner.
[FillInTheBlank request: 'What day is it?']
	valueSupplyingAnswer: 'the first day of the rest of your life'
	
We can also return whatever the initialAnswer of the FillInTheBlank was by using the #default answer.
[FillInTheBlank request: 'What day is it?' initialAnswer: DateAndTime now dayOfWeekName]
	valueSupplyingAnswer: #default
	
Finally, you can also do regex matches on any of the question text (or inform text) (should you have VB-Regex enhancements in your image).
[FillInTheBlank request: 'What day is it?']
	valueSupplyingAnswers: { {'What day.*\?'. DateAndTime now dayOfWeekName} }

[Comment taken from BlockClosureTest last written by jrp 10/17/2004 12:22]
"
Class {
	#name : #BlockClosureTest,
	#superclass : #TestCase,
	#instVars : [
		'aBlockClosure',
		'homeOfABlockClosure'
	],
	#category : #'KernelTests-Methods'
}

{ #category : #'support methods' }
BlockClosureTest class >> onceMethod [
	^[Object new] once
]

{ #category : #running }
BlockClosureTest >> setUp [
	super setUp.
	aBlockClosure := [100@100 corner: 200@200].
	homeOfABlockClosure := thisContext
]

{ #category : #'tests - evaluating' }
BlockClosureTest >> testCull [
	self assert: nil equals: ([ ] cull: 1).
	self assert: nil equals: ([ :x | ] cull: 1).
	self assert: 1 equals: ([ :x | x ] cull: 1).
	self should: [ [ :x :y | ] cull: 1 ] raise: Error.
	self should: [ [ :x :y :z | ] cull: 1 ] raise: Error.
	self should: [ [ :x :y :z :a | ] cull: 1 ] raise: Error.
	self should: [ [ :x :y :z :a :b | ] cull: 1 ] raise: Error.
	self assert: ([ 0 ] cull: 1) = 0.
	self assert: ([ :x | x ] cull: 1) = 1	
]

{ #category : #'tests - evaluating' }
BlockClosureTest >> testCullCull [
	self assert: nil equals: ([ ] cull: 1 cull: 2).

	self assert: nil equals: ([ :x | ] cull: 1 cull: 2).
	self assert: 1 equals: ([ :x | x ] cull: 1 cull: 2).

	self assert: nil equals: ([ :x :y | ] cull: 1 cull: 2).
	self assert: 1 equals: ([ :x :y | x ] cull: 1 cull: 2).
	self assert: 2 equals: ([ :x :y | y ] cull: 1 cull: 2).

	self should: [ [ :x :y :z | ] cull: 1 cull: 2 ] raise: Error.
	self should: [ [ :x :y :z :a | ] cull: 1 cull: 2 ] raise: Error.
	self should: [ [ :x :y :z :a :b | ] cull: 1 cull: 2 ] raise: Error.
	self assert: ([ 0 ] cull: 1 cull: 2) = 0.
	self assert: ([ :x | x ] cull: 1 cull: 2) = 1.
	self assert: ([ :x :y | y ] cull: 1 cull: 2) = 2.	
]

{ #category : #'tests - evaluating' }
BlockClosureTest >> testCullCullCull [
	self assert: nil equals: ([ ] cull: 1 cull: 2 cull: 3).

	self assert: nil equals: ([ :x | ] cull: 1 cull: 2 cull: 3).
	self assert: 1 equals: ([ :x | x ] cull: 1 cull: 2 cull: 3).

	self assert: nil equals: ([ :x :y | ] cull: 1 cull: 2 cull: 3).
	self assert: 1 equals: ([ :x :y | x ] cull: 1 cull: 2 cull: 3).
	self assert: 2 equals: ([ :x :y | y ] cull: 1 cull: 2 cull: 3).

	self assert: nil equals: ([ :x :y :z | ] cull: 1 cull: 2 cull: 3).
	self assert: 1 equals: ([ :x :y :z | x ] cull: 1 cull: 2 cull: 3).
	self assert: 2 equals: ([ :x :y :z | y ] cull: 1 cull: 2 cull: 3).
	self assert: 3 equals: ([ :x :y :z | z ] cull: 1 cull: 2 cull: 3).

	self should: [ [ :x :y :z :a | ] cull: 1 cull: 2 cull: 3 ] raise: Error.
	self should: [ [ :x :y :z :a :b | ] cull: 1 cull: 2 cull: 3 ] raise: Error.
	self assert: ([ 0 ] cull: 1 cull: 2 cull: 3) = 0.
	self assert: ([ :x | x ] cull: 1 cull: 2 cull: 3) = 1.
	self assert: ([ :x :y | y ] cull: 1 cull: 2 cull: 3) = 2.
	self assert: ([ :x :y :z | z ] cull: 1 cull: 2 cull: 3) = 3.	
]

{ #category : #'tests - evaluating' }
BlockClosureTest >> testCullCullCullCull [
	self assert: nil equals: ([ ] cull: 1 cull: 2 cull: 3 cull: 4).

	self assert: nil equals: ([ :x | ] cull: 1 cull: 2 cull: 3 cull: 4).
	self assert: 1 equals: ([ :x | x ] cull: 1 cull: 2 cull: 3 cull: 4).

	self assert: nil equals: ([ :x :y | ] cull: 1 cull: 2 cull: 3 cull: 4).
	self assert: 1 equals: ([ :x :y | x ] cull: 1 cull: 2 cull: 3 cull: 4).
	self assert: 2 equals: ([ :x :y | y ] cull: 1 cull: 2 cull: 3 cull: 4).

	self assert: nil equals: ([ :x :y :z | ] cull: 1 cull: 2 cull: 3 cull: 4).
	self assert: 1 equals: ([ :x :y :z | x ] cull: 1 cull: 2 cull: 3 cull: 4).
	self assert: 2 equals: ([ :x :y :z | y ] cull: 1 cull: 2 cull: 3 cull: 4).
	self assert: 3 equals: ([ :x :y :z | z ] cull: 1 cull: 2 cull: 3 cull: 4).

	self assert: nil equals: ([ :x :y :z :a | ] cull: 1 cull: 2 cull: 3 cull: 4).
	self assert: 1 equals: ([ :x :y :z :a | x ] cull: 1 cull: 2 cull: 3 cull: 4).
	self assert: 2 equals: ([ :x :y :z :a | y ] cull: 1 cull: 2 cull: 3 cull: 4).
	self assert: 3 equals: ([ :x :y :z :a | z ] cull: 1 cull: 2 cull: 3 cull: 4).
	self assert: 4 equals: ([ :x :y :z :a | a ] cull: 1 cull: 2 cull: 3 cull: 4).

	self should: [ [ :x :y :z :a :b | ] cull: 1 cull: 2 cull: 3 cull: 4 ] raise: Error.
	self assert: ([ 0 ] cull: 1 cull: 2 cull: 3 cull: 4) = 0.
	self assert: ([ :x | x ] cull: 1 cull: 2 cull: 3 cull: 4) = 1.
	self assert: ([ :x :y | y ] cull: 1 cull: 2 cull: 3 cull: 4) = 2.
	self assert: ([ :x :y :z | z ] cull: 1 cull: 2 cull: 3 cull: 4) = 3.
	self assert: ([ :x :y :z :a | a ] cull: 1 cull: 2 cull: 3 cull: 4) = 4.
]

{ #category : #'tests - printing' }
BlockClosureTest >> testDecompile [
	self assert: ([3 + 4] decompile printString = '{[3 + 4]}')
]

{ #category : #'tests - evaluating' }
BlockClosureTest >> testEmptyBlocksAnswerNil [
	"In the olden days ([:a :b|] value: #first value: #last) == #last..."
	{[]. [:a|]. [:a :b|]. [:a :b :c|]} do:
		[:block|
		self assert: (block cull: 1 cull: 2 cull: 3) equals: nil]
]

{ #category : #'tests - evaluating' }
BlockClosureTest >> testMoreThanOnce [
	"Make sure that we can use once more than once"
	| moreThanOnce |
	moreThanOnce := (1 to: 3) collect: [:e | [String new] once -> [Array new] once].
	self assert: (moreThanOnce allSatisfy: [:each | each key isString]).
	self assert: (moreThanOnce allSatisfy: [:each | each value isArray]).
	self assert: (moreThanOnce allSatisfy: [:each | each key == moreThanOnce first key]).
	self assert: (moreThanOnce allSatisfy: [:each | each value == moreThanOnce first value]).
]

{ #category : #'tests - evaluating' }
BlockClosureTest >> testMoreThanOnceForEqualBlocks [
	"Make sure that we can use once more than once"
	| moreThanOnce |
	moreThanOnce := (1 to: 3) collect: [:e | [Object new] once -> [Object new] once].
	self assert: (moreThanOnce allSatisfy: [:each | each key == moreThanOnce first key]).
	self assert: (moreThanOnce allSatisfy: [:each | each value == moreThanOnce first value]).
	self assert: (moreThanOnce noneSatisfy: [:each | each key == each value]).
]

{ #category : #tests }
BlockClosureTest >> testNew [
	self should: [Context new: 5] raise: Error.
	[Context new: 5]
		on: Error do: [:e|
			self assert: (e messageText includesSubstring: 'newForMethod:') description: 'Error doesn''t tell you what you did wrong by calling #new:'].

	self should: [Context new] raise: Error.
	[Context new]
		on: Error do: [:e|
			self assert: (e messageText includesSubstring: 'newForMethod:') description: 'Error doesn''t tell you what you did wrong by calling #new']
]

{ #category : #tests }
BlockClosureTest >> testNoArguments [
	[10
		timesRepeat: [:arg | 1 + 2]]
		ifError: [:err :rcvr | self deny: err = 'This block requires 1 arguments.'].
	[10
		timesRepeat: [:arg1 :arg2 | 1 + 2]]
		ifError: [:err :rcvr | self deny: err = 'This block requires 2 arguments.']
]

{ #category : #'tests - evaluating' }
BlockClosureTest >> testOnce [
	| objs result |
	objs := (1 to: 10) collect: [:ign| [Object new] once].
	self assert: (objs allSatisfy: [:obj| obj == objs first]).
	result := self class onceMethod.
	1 to: 10 do:
		[:ign|
		self assert: result == self class onceMethod]
]

{ #category : #tests }
BlockClosureTest >> testOneArgument [
	| c |
	c := OrderedCollection new.
	c add: 'hello'.
	[c
		do: [1 + 2]]
		ifError: [:err :rcvr | self deny: err = 'This block requires 0 arguments.'].
	[c
		do: [:arg1 :arg2 | 1 + 2]]
		ifError: [:err :rcvr | self deny: err = 'This block requires 2 arguments.']
]

{ #category : #tests }
BlockClosureTest >> testRunSimulated [
	self assert: Rectangle equals: (Context runSimulated: aBlockClosure asContext) class
]

{ #category : #tests }
BlockClosureTest >> testSetUp [
	"Note: In addition to verifying that the setUp worked the way it was expected to, testSetUp is used to illustrate the meaning of the simple access methods, methods that are not normally otherwise 'tested'"
	self deny: aBlockClosure isContext.
	self assert: aBlockClosure isClosure.
	self assert: aBlockClosure home = homeOfABlockClosure.
	self assert: aBlockClosure receiver = self.
	self assert: ((aBlockClosure isMemberOf: FullBlockClosure)
		ifTrue: [aBlockClosure method isCompiledBlock]
		ifFalse: [aBlockClosure method isCompiledMethod])
]

{ #category : #'tests - printing' }
BlockClosureTest >> testSourceString [
	self assert: [] sourceString equals: '[]'.
	self assert: (#((#'[' #':arg' #| nil #']') (#'[' #':arg' #| #']')) includes: (Scanner new scanTokens: [:arg|] sourceString)).
	self assert: (Scanner new scanTokens: [ : stream | self printSourceOn: stream ] sourceString)
		equals:  #(#'[' #':stream' #| #self #printSourceOn: #stream #']')
]

{ #category : #'tests - supply answer' }
BlockClosureTest >> testSupplyAnswerOfFillInTheBlank [

	UIManager subclassesDo: [:managerClass | 
		self should: ['blue' = ([managerClass new request: 'Your favorite color?'] 
			valueSupplyingAnswer: #('Your favorite color?' 'blue'))]]
]

{ #category : #'tests - supply answer' }
BlockClosureTest >> testSupplyAnswerOfFillInTheBlankUsingDefaultAnswer [

	UIManager subclassesDo: [:managerClass | 
		self should: ['red' = ([managerClass new request: 'Your favorite color?' initialAnswer: 'red'] 
			valueSupplyingAnswer: #('Your favorite color?' #default))]]
]

{ #category : #'tests - supply answer' }
BlockClosureTest >> testSupplyAnswerUsingOnlySubstringOfQuestion [

	UIManager subclassesDo: [:managerClass | 
		self should: [false = ([managerClass new confirm: 'You like Smalltalk?'] 
			valueSupplyingAnswer: #('like' false))]]
]

{ #category : #'tests - supply answer' }
BlockClosureTest >> testSupplyAnswerUsingRegexMatchOfQuestion [

	(String includesSelector: #matchesRegex:) ifFalse: [^ self].
	
	UIManager subclassesDo: [:managerClass | 
		self should: [true = ([managerClass new confirm: 'You like Smalltalk?'] 
			valueSupplyingAnswer: #('.*Smalltalk\?' true))]]
]

{ #category : #'tests - supply answer' }
BlockClosureTest >> testSupplySpecificAnswerToQuestion [

	UIManager subclassesDo: [:managerClass | 
		self should: [false = ([managerClass new confirm: 'You like Smalltalk?'] 
			valueSupplyingAnswer: #('You like Smalltalk?' false))]]
]

{ #category : #'tests - supply answer' }
BlockClosureTest >> testSupplySpecificAnswerToSelection [

	| windowTitle |
	windowTitle := 'What is your favorite letter?'.
	UIManager subclassesDo: [:managerClass | 
		self should: [#b = ([managerClass new chooseFrom: #(a b c) values: #(a b c) title: windowTitle] 
			valueSupplyingAnswer: {windowTitle . #b})]].
	
	UIManager subclassesDo: [:managerClass | 
		self should: [#b = ([managerClass new chooseFrom: #(a b c) values: #(a b c) title: windowTitle] 
			valueSupplyingAnswer: {windowTitle . 2})]]
]

{ #category : #'tests - supply answer' }
BlockClosureTest >> testSuppressInform [
	
	UIManager subclassesDo: [:managerClass | | manager |
		manager := managerClass new.
		self should: [[manager inform: 'Should not see this message or this test failed!'] 
			valueSuppressingAllMessages]]
]

{ #category : #'tests - supply answer' }
BlockClosureTest >> testSuppressInformUsingStringMatchOptions [

	UIManager subclassesDo: [:managerClass | | manager |
		manager := managerClass new.
		#("message" "pattern"
			'Should not see this message or this test failed!' 'Should not see this message or this test failed!'
		 	'Should not see this message or this test failed!' 'not see this message'
			'Should not see this message or this test failed!' '*message*failed#')
				pairsDo: [:message :pattern |
					self assert: ([manager inform: message] valueSuppressingMessages: {pattern})]]
]

{ #category : #tests }
BlockClosureTest >> testTallyInstructions [
	self assert: ((aBlockClosure isMemberOf: FullBlockClosure)
			ifTrue: [14]
			ifFalse: [15])
		equals: (Context tallyInstructions: aBlockClosure asContext) size
]

{ #category : #'tests - evaluating' }
BlockClosureTest >> testValue [

	"#value"
	self
		assert: nil equals: [ ] value;
		assert: 1 equals: [ 1 ] value;
		should: [ [ :a | ] value ] raise: Error.
	
	"#value:"
	self
		assert: nil equals: ([ :a | ] value: 1);
		assert: 1 equals: ([ :a | a ] value: 1);
		should: [ [ ] value: 1 ] raise: Error;
		should: [ [ :a :b | ] value: 1 ] raise: Error
]

{ #category : #'tests - evaluating' }
BlockClosureTest >> testValueValue [

	self
		assert: nil equals: ([ :a :b | ] value: 1 value: 2);
		assert: 1 equals: ([ :a :b | a ] value: 1 value: 2);
		assert: 2 equals: ([ :a :b | b ] value: 1 value: 2);
		should: [ [ ] value: 1 value: 2 ] raise: Error;
		should: [ [ :a | ] value: 1 value: 2 ] raise: Error;
		should: [ [ :a :b :c | ] value: 1 value: 2 ] raise: Error
]

{ #category : #'tests - evaluating' }
BlockClosureTest >> testValueValueValue [

	self
		assert: nil equals: ([ :a :b :c | ] value: 1 value: 2 value: 3);
		assert: 1 equals: ([ :a :b :c | a ] value: 1 value: 2 value: 3);
		assert: 2 equals: ([ :a :b :c | b ] value: 1 value: 2 value: 3);
		assert: 3 equals: ([ :a :b :c | c ] value: 1 value: 2 value: 3);
		should: [ [ ] value: 1 value: 2 value: 3 ] raise: Error;
		should: [ [ :a | ] value: 1 value: 2 value: 3 ] raise: Error;
		should: [ [ :a :b | ] value: 1 value: 2 value: 3 ] raise: Error;
		should: [ [ :a :b :c :d | ] value: 1 value: 2 value: 3 ] raise: Error
]

{ #category : #'tests - evaluating' }
BlockClosureTest >> testValueValueValueValue [

	self
		assert: nil equals: ([ :a :b :c :d | ] value: 1 value: 2 value: 3 value: 4);
		assert: 1 equals: ([ :a :b :c :d | a ] value: 1 value: 2 value: 3 value: 4);
		assert: 2 equals: ([ :a :b :c :d | b ] value: 1 value: 2 value: 3 value: 4);
		assert: 3 equals: ([ :a :b :c :d | c ] value: 1 value: 2 value: 3 value: 4);
		assert: 4 equals: ([ :a :b :c :d | d ] value: 1 value: 2 value: 3 value: 4);
		should: [ [ ] value: 1 value: 2 value: 3 value: 4 ] raise: Error;
		should: [ [ :a | ] value: 1 value: 2 value: 3 value: 4 ] raise: Error;
		should: [ [ :a :b | ] value: 1 value: 2 value: 3 value: 4 ] raise: Error;
		should: [ [ :a :b :c | ] value: 1 value: 2 value: 3 value: 4 ] raise: Error;
		should: [ [ :a :b :c :d :e | ] value: 1 value: 2 value: 3 value: 4 ] raise: Error
]

{ #category : #'tests - evaluating' }
BlockClosureTest >> testValueValueValueValueValue [

	self
		assert: nil equals: ([ :a :b :c :d :e | ] value: 1 value: 2 value: 3 value: 4 value: 5);
		assert: 1 equals: ([ :a :b :c :d :e | a ] value: 1 value: 2 value: 3 value: 4 value: 5);
		assert: 2 equals: ([ :a :b :c :d :e | b ] value: 1 value: 2 value: 3 value: 4 value: 5);
		assert: 3 equals: ([ :a :b :c :d :e | c ] value: 1 value: 2 value: 3 value: 4 value: 5);
		assert: 4 equals: ([ :a :b :c :d :e | d ] value: 1 value: 2 value: 3 value: 4 value: 5);
		assert: 5 equals: ([ :a :b :c :d :e | e ] value: 1 value: 2 value: 3 value: 4 value: 5);
		should: [ [ ] value: 1 value: 2 value: 3 value: 4 value: 5 ] raise: Error;
		should: [ [ :a | ] value: 1 value: 2 value: 3 value: 4 value: 5 ] raise: Error;
		should: [ [ :a :b | ] value: 1 value: 2 value: 3 value: 4 value: 5 ] raise: Error;
		should: [ [ :a :b :c | ] value: 1 value: 2 value: 3 value: 4 value: 5 ] raise: Error;
		should: [ [ :a :b :c :d | ] value: 1 value: 2 value: 3 value: 4 value: 5 ] raise: Error;
		should: [ [ :a :b :c :d :e :f | ] value: 1 value: 2 value: 3 value: 4 value: 5 ] raise: Error
]

{ #category : #'tests - evaluating' }
BlockClosureTest >> testValueWithPossibleArgs [
	| block  blockWithArg blockWith2Arg |

	block := [1].
	blockWithArg  := [:arg | arg].
	blockWith2Arg := [:arg1 :arg2 | {arg1. arg2}].

	self assert: (block valueWithPossibleArgs: #()) = 1.
	self assert: (block valueWithPossibleArgs: #(1)) = 1.
	
	self assert: (blockWithArg valueWithPossibleArgs: #()) = nil.
	self assert: (blockWithArg valueWithPossibleArgs: #(1)) = 1.
	self assert: (blockWithArg valueWithPossibleArgs: #(1 2)) = 1.

	self assert: (blockWith2Arg valueWithPossibleArgs: #()) = {nil .nil}.
	self assert: (blockWith2Arg valueWithPossibleArgs: #(1)) =  {1 . nil}.
	self assert: (blockWith2Arg valueWithPossibleArgs: #(1 2)) =  #(1 2).
	self assert: (blockWith2Arg valueWithPossibleArgs: #(1 2 3)) = #(1 2)
]

{ #category : #'tests - evaluating' }
BlockClosureTest >> testValueWithPossibleArgument [
	| block  blockWithArg blockWith2Arg |

	block := [1].
	blockWithArg  := [:arg | arg].
	blockWith2Arg := [:arg1 :arg2 | {arg1. arg2}].

	self assert: (block valueWithPossibleArgument: 1) = 1.
	
	self assert: (blockWithArg valueWithPossibleArgument: 1) = 1.
	
	self assert: (blockWith2Arg valueWithPossibleArgument: 1) = {1 . nil}
]
