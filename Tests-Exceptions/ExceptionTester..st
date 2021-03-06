Class {
	#name : #ExceptionTester,
	#superclass : #Object,
	#instVars : [
		'log',
		'suiteLog',
		'iterationsBeforeTimeout'
	],
	#category : #'Tests-Exceptions'
}

{ #category : #accessing }
ExceptionTester >> basicANSISignaledExceptionTestSelectors [

	^#( simpleIsNestedTest simpleOuterTest doubleOuterTest doubleOuterPassTest doublePassOuterTest simplePassTest simpleResignalAsTest simpleResumeTest simpleRetryTest simpleRetryUsingTest simpleReturnTest)
]

{ #category : #accessing }
ExceptionTester >> basicTestSelectors [
	^ #(#simpleEnsureTest #simpleEnsureTestWithNotification #simpleEnsureTestWithUparrow #simpleEnsureTestWithError #signalFromHandlerActionTest #resumableFallOffTheEndHandler #nonResumableFallOffTheEndHandler #doubleResumeTest #simpleTimeoutWithZeroDurationTest #simpleTimeoutTest simpleNoTimeoutTest)
]

{ #category : #logging }
ExceptionTester >> clearLog [

	log := nil
]

{ #category : #logging }
ExceptionTester >> contents [

	^( self log
		inject: (WriteStream on: (String new: 80))
		into: 
			[:result :item |
			result 
				cr; 
				nextPutAll: item;
				yourself] ) contents
]

{ #category : #'pseudo actions' }
ExceptionTester >> doSomething [

	self log: self doSomethingString
]

{ #category : #'pseudo actions' }
ExceptionTester >> doSomethingElse [

	self log: self doSomethingElseString
]

{ #category : #accessing }
ExceptionTester >> doSomethingElseString [

	^'Do something else.'
]

{ #category : #'pseudo actions' }
ExceptionTester >> doSomethingExceptional [

	self log: self doSomethingExceptionalString
]

{ #category : #accessing }
ExceptionTester >> doSomethingExceptionalString [

	^'Do something exceptional.'
]

{ #category : #accessing }
ExceptionTester >> doSomethingString [

	^'Do something.'
]

{ #category : #'pseudo actions' }
ExceptionTester >> doYetAnotherThing [

	self log: self doYetAnotherThingString
]

{ #category : #accessing }
ExceptionTester >> doYetAnotherThingString [

	^'Do yet another thing.'
]

{ #category : #'signaledException tests' }
ExceptionTester >> doubleOuterPassTest [
	"uses #resume"

	[[[self doSomething.
	MyTestNotification signal.
	self doSomethingExceptional]
		on: MyTestNotification
		do: [:ex | ex outer.
			self doSomethingElse]]
			on: MyTestNotification
			do: [:ex | ex pass.
				self doSomethingExceptional]]
				on: MyTestNotification
				do: [:ex | self doYetAnotherThing. ex resume]
]

{ #category : #'signaledException results' }
ExceptionTester >> doubleOuterPassTestResults [

	^OrderedCollection new
		add: self doSomethingString;
		add: self doYetAnotherThingString;
		add: self doSomethingElseString;
		yourself
]

{ #category : #'signaledException tests' }
ExceptionTester >> doubleOuterTest [
	"uses #resume"

	[[[self doSomething.
	MyTestNotification signal.
	self doSomethingExceptional]
		on: MyTestNotification
		do: [:ex | ex outer.
			self doSomethingExceptional]]
			on: MyTestNotification
			do: [:ex | ex outer.
				self doSomethingElse]]
				on: MyTestNotification
				do: [:ex | self doYetAnotherThing. ex resume]
]

{ #category : #'signaledException tests' }
ExceptionTester >> doublePassOuterTest [
	"uses #resume"

	[[[self doSomething.
	MyTestNotification signal.
	self doSomethingExceptional]
		on: MyTestNotification
		do: [:ex | ex pass.
			self doSomethingExceptional]]
			on: MyTestNotification
			do: [:ex | ex outer.
				self doSomethingElse]]
				on: MyTestNotification
				do: [:ex | self doYetAnotherThing. ex resume]
]

{ #category : #'signaledException results' }
ExceptionTester >> doublePassOuterTestResults [

	^OrderedCollection new
		add: self doSomethingString;
		add: self doYetAnotherThingString;
		add: self doSomethingElseString;
		yourself
]

{ #category : #tests }
ExceptionTester >> doubleResumeTest [

       [self doSomething.
       MyResumableTestError signal.
       self doSomethingElse.
       MyResumableTestError signal.
       self doYetAnotherThing]
               on: MyResumableTestError
               do: [:ex | ex resume].
]

{ #category : #results }
ExceptionTester >> doubleResumeTestResults [

       ^OrderedCollection new
               add: self doSomethingString;
               add: self doSomethingElseString;
               add: self doYetAnotherThingString;
               yourself
]

{ #category : #accessing }
ExceptionTester >> iterationsBeforeTimeout [

	^ iterationsBeforeTimeout
]

{ #category : #accessing }
ExceptionTester >> iterationsBeforeTimeout: anInteger [

	iterationsBeforeTimeout := anInteger
]

{ #category : #accessing }
ExceptionTester >> log [

	log == nil
		ifTrue: [log := OrderedCollection new].
	^log
]

{ #category : #logging }
ExceptionTester >> log: aString [

	self log add: aString
]

{ #category : #logging }
ExceptionTester >> logTest: aSelector [

	self suiteLog add: aSelector
]

{ #category : #logging }
ExceptionTester >> logTestResult: aString [

	| index |
	index := self suiteLog size.
	self suiteLog 
		at: index
		put: ((self suiteLog at: index), ' ', aString)
]

{ #category : #'pseudo actions' }
ExceptionTester >> methodWithError [

	MyTestError signal: self testString
]

{ #category : #'pseudo actions' }
ExceptionTester >> methodWithNotification [

	MyTestNotification signal: self testString
]

{ #category : #tests }
ExceptionTester >> nonResumableFallOffTheEndHandler [
	
	[self doSomething.
	MyTestError signal.
	self doSomethingElse]
		on: MyTestError
		do: [:ex | self doSomethingExceptional].
	self doYetAnotherThing
]

{ #category : #results }
ExceptionTester >> nonResumableFallOffTheEndHandlerResults [

	^OrderedCollection new
		add: self doSomethingString;
		add: self doSomethingExceptionalString;
		add: self doYetAnotherThingString;
		yourself
]

{ #category : #tests }
ExceptionTester >> resumableFallOffTheEndHandler [

	[self doSomething.
	MyTestNotification signal.
	self doSomethingElse]
		on: MyTestNotification
		do: [:ex | self doSomethingExceptional].
	self doYetAnotherThing
]

{ #category : #results }
ExceptionTester >> resumableFallOffTheEndHandlerResults [

	^OrderedCollection new
		add: self doSomethingString;
		add: self doSomethingExceptionalString;
		add: self doYetAnotherThingString;
		yourself
]

{ #category : #suites }
ExceptionTester >> runAllTests [
	"ExceptionTester new runAllTests"

	self
		runBasicTests;
		runBasicANSISignaledExceptionTests
]

{ #category : #suites }
ExceptionTester >> runBasicANSISignaledExceptionTests [

	self basicANSISignaledExceptionTestSelectors
		do:
			[:eachTestSelector |
			self runTest: eachTestSelector]
]

{ #category : #suites }
ExceptionTester >> runBasicTests [

	self basicTestSelectors
		do:
			[:eachTestSelector |
			self runTest: eachTestSelector]
]

{ #category : #testing }
ExceptionTester >> runTest: aSelector [

	| actualResult expectedResult |
	[ self 
		logTest: aSelector;
		clearLog;
		perform: aSelector ]
			on: MyTestError do: 
				[ :ex | self log: 'Unhandled Exception'.
					ex return: nil ].

	actualResult	:= self log.
	expectedResult := self perform: (aSelector, #Results) asSymbol.

	actualResult = expectedResult
		ifTrue: [self logTestResult: 'succeeded']
		ifFalse: [self logTestResult: 'failed' ].

]

{ #category : #tests }
ExceptionTester >> signalFromHandlerActionTest [

	[self doSomething.
	MyTestError signal.
	self doSomethingElse]
		on: MyTestError
		do:
			[self doYetAnotherThing.
			MyTestError signal]
]

{ #category : #results }
ExceptionTester >> signalFromHandlerActionTestResults [

	^OrderedCollection new
		add: self doSomethingString;
		add: self doYetAnotherThingString;
		add: 'Unhandled Exception';
		yourself
]

{ #category : #tests }
ExceptionTester >> simpleEnsureTest [

	[self doSomething.
	self doSomethingElse]
		ensure:
			[self doYetAnotherThing].
	
]

{ #category : #results }
ExceptionTester >> simpleEnsureTestResults [

	^OrderedCollection new
		add: self doSomethingString;
		add: self doSomethingElseString;
		add: self doYetAnotherThingString;
		yourself
]

{ #category : #tests }
ExceptionTester >> simpleEnsureTestWithError [

	[self doSomething.
	MyTestError signal.
	self doSomethingElse]
		ensure:
			[self doYetAnotherThing].
	
]

{ #category : #results }
ExceptionTester >> simpleEnsureTestWithErrorResults [

	^OrderedCollection new
		add: self doSomethingString;
		add: 'Unhandled Exception';
		add: self doYetAnotherThingString;
		yourself
]

{ #category : #tests }
ExceptionTester >> simpleEnsureTestWithNotification [

	[self doSomething.
	self methodWithNotification.
	self doSomethingElse]
		ensure:
			[self doYetAnotherThing].
	
]

{ #category : #results }
ExceptionTester >> simpleEnsureTestWithNotificationResults [

	^OrderedCollection new
		add: self doSomethingString;
		add: self doSomethingElseString;
		add: self doYetAnotherThingString;
		yourself
]

{ #category : #tests }
ExceptionTester >> simpleEnsureTestWithUparrow [

	[self doSomething.
	true ifTrue: [^nil].
	self doSomethingElse]
		ensure:
			[self doYetAnotherThing].
	
]

{ #category : #results }
ExceptionTester >> simpleEnsureTestWithUparrowResults [

	^OrderedCollection new
		add: self doSomethingString;
"		add: self doSomethingElseString;"
		add: self doYetAnotherThingString;
		yourself
]

{ #category : #'signaledException tests' }
ExceptionTester >> simpleIsNestedTest [
	"uses resignalAs:"

	[self doSomething.
	MyTestError signal.
	self doSomethingElse]
		on: MyTestError
		do:
			[:ex |
			ex isNested "expecting to detect handler in #runTest:"
				ifTrue:
					[self doYetAnotherThing.
					ex resignalAs: MyTestNotification new]]
]

{ #category : #'signaledException results' }
ExceptionTester >> simpleIsNestedTestResults [

	^OrderedCollection new
		add: self doSomethingString;
		add: self doYetAnotherThingString;
		add: self doSomethingElseString;
		yourself
]

{ #category : #tests }
ExceptionTester >> simpleNoTimeoutTest [

	[ self doSomething ]
		valueWithin: 1 day onTimeout:
			[ self doSomethingElse ].
	
]

{ #category : #results }
ExceptionTester >> simpleNoTimeoutTestResults [

	^OrderedCollection new
		add: self doSomethingString;
		yourself
]

{ #category : #'signaledException tests' }
ExceptionTester >> simpleOuterTest [
	"uses #resume"

	[[self doSomething.
	MyTestNotification signal.
	"self doSomethingElse"
	self doSomethingExceptional]
		on: MyTestNotification
		do: [:ex | ex outer. self doSomethingElse]]
				on: MyTestNotification
				do: [:ex | self doYetAnotherThing. ex resume]
]

{ #category : #'signaledException results' }
ExceptionTester >> simpleOuterTestResults [

	^OrderedCollection new
		add: self doSomethingString;
		add: self doYetAnotherThingString;
		add: self doSomethingElseString;
		yourself
]

{ #category : #'signaledException tests' }
ExceptionTester >> simplePassTest [

	[self doSomething.
	MyTestError signal.
	self doSomethingElse]
		on: MyTestError
		do:
			[:ex |
			self doYetAnotherThing.
			ex pass "expecting handler in #runTest:"]
]

{ #category : #'signaledException results' }
ExceptionTester >> simplePassTestResults [

	^OrderedCollection new
		add: self doSomethingString;
		add: self doYetAnotherThingString;
		add: 'Unhandled Exception';
		yourself
]

{ #category : #'signaledException tests' }
ExceptionTester >> simpleResignalAsTest [
	"ExceptionTester new simpleResignalAsTest"

	[self doSomething.
	MyTestNotification signal.
	self doSomethingElse]
		on: MyTestNotification
		do:
			[:ex | ex resignalAs: MyTestError new]
]

{ #category : #'signaledException results' }
ExceptionTester >> simpleResignalAsTestResults [

	^OrderedCollection new
		add: self doSomethingString;
		add: 'Unhandled Exception';
		yourself
]

{ #category : #'signaledException tests' }
ExceptionTester >> simpleResumeTest [
	"see if we can resume twice"
	
	[ | it |
	self doSomething.
	it := MyResumableTestError signal.
	it = 3 ifTrue: [self doSomethingElse].
	it := MyResumableTestError signal.
	it = 3 ifTrue: [self doSomethingElse].
	]
		on: MyResumableTestError
		do:
			[:ex |
			self doYetAnotherThing.
			ex resume: 3]
]

{ #category : #'signaledException results' }
ExceptionTester >> simpleResumeTestResults [

	"see if we can resume twice"

	^OrderedCollection new
			add: self doSomethingString;
			add: self doYetAnotherThingString;
			add: self doSomethingElseString;
			add: self doYetAnotherThingString;
			add: self doSomethingElseString;
			yourself
]

{ #category : #'signaledException tests' }
ExceptionTester >> simpleRetryTest [

	| theMeaningOfLife |
	theMeaningOfLife := nil.
	[self doSomething.
	theMeaningOfLife == nil
		ifTrue: [MyTestError signal]
		ifFalse: [self doSomethingElse]]
			on: MyTestError
			do:
				[:ex |
				theMeaningOfLife := 42.
				self doYetAnotherThing.
				ex retry]
]

{ #category : #'signaledException results' }
ExceptionTester >> simpleRetryTestResults [

	^OrderedCollection new
			add: self doSomethingString;
			add: self doYetAnotherThingString;
			add: self doSomethingString;
			add: self doSomethingElseString;
			yourself
]

{ #category : #'signaledException tests' }
ExceptionTester >> simpleRetryUsingTest [

	[self doSomething.
	MyTestError signal.
	self doSomethingElse]
		on: MyTestError
		do:
			[:ex | ex retryUsing: [self doYetAnotherThing]]
]

{ #category : #'signaledException results' }
ExceptionTester >> simpleRetryUsingTestResults [

	^OrderedCollection new
			add: self doSomethingString;
			add: self doYetAnotherThingString;
			yourself
]

{ #category : #'signaledException tests' }
ExceptionTester >> simpleReturnTest [

	| it |
	it :=
		[self doSomething.
		MyTestError signal.
		self doSomethingElse]
			on: MyTestError
			do: [:ex | ex return: 3].
	it = 3 ifTrue: [self doYetAnotherThing]
]

{ #category : #'signaledException results' }
ExceptionTester >> simpleReturnTestResults [

	^OrderedCollection new
		add: self doSomethingString;
		add: self doYetAnotherThingString;
		yourself
]

{ #category : #tests }
ExceptionTester >> simpleTimeoutTest [

	| n |
	[1 to: 1000000 do: [ :i | n := i. self doSomething ] ]
		valueWithin: 50 milliSeconds onTimeout:
			[ self iterationsBeforeTimeout: n.
			self doSomethingElse ]
]

{ #category : #results }
ExceptionTester >> simpleTimeoutTestResults [

	| things |
	things := OrderedCollection new: self iterationsBeforeTimeout.

	self iterationsBeforeTimeout timesRepeat: [ things add: self  doSomethingString ].
	things add: self doSomethingElseString.

	^ things
]

{ #category : #tests }
ExceptionTester >> simpleTimeoutWithZeroDurationTest [

	[ self doSomething ]
		valueWithin: 0 seconds onTimeout:
			[ self doSomethingElse ].
	
]

{ #category : #results }
ExceptionTester >> simpleTimeoutWithZeroDurationTestResults [

	^OrderedCollection new
		add: self doSomethingElseString;
		yourself
]

{ #category : #accessing }
ExceptionTester >> suiteLog [

	suiteLog == nil
		ifTrue: [suiteLog := OrderedCollection new].
	^suiteLog
]

{ #category : #accessing }
ExceptionTester >> testString [

	^'This is only a test.'
]

{ #category : #tests }
ExceptionTester >> warningTest [

	self log: 'About to signal warning.'.
	Warning signal: 'Ouch'.
	self log: 'Warning signal handled and resumed.'
]
