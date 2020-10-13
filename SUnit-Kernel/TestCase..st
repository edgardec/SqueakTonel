"
A TestCase is a Command representing the future running of a test case. Create one with the class method #selector: aSymbol, passing the name of the method to be run when the test case runs.

When you discover a new fixture, subclass TestCase, declare instance variables for the objects in the fixture, override #setUp to initialize the variables, and possibly override# tearDown to deallocate any external resources allocated in #setUp.

When you are writing a test case method, send #assert: aBoolean when you want to check for an expected value. For example, you might say ""self assert: socket isOpen"" to test whether or not a socket is open at a point in a test.
"
Class {
	#name : #TestCase,
	#superclass : #Object,
	#instVars : [
		'testSelector',
		'timeout'
	],
	#classInstVars : [
		'history'
	],
	#category : #'SUnit-Kernel'
}

{ #category : #'building suites' }
TestCase class >> addTestsFor: classNameString toSuite: suite [

	| cls  |
	cls := Smalltalk at: classNameString ifAbsent: [ ^suite ].
	^cls isAbstract 
		ifTrue:  [
			cls allSubclasses do: [ :each |
				each isAbstract ifFalse: [
					each addToSuiteFromSelectors: suite ] ].
			suite]
		ifFalse: [ cls addToSuiteFromSelectors: suite ]

]

{ #category : #'building suites' }
TestCase class >> addToSuite: suite fromMethods: testMethods [ 
	testMethods do:  [ :selector | 
			suite addTest: (self selector: selector) ].
	^suite
]

{ #category : #'building suites' }
TestCase class >> addToSuiteFromSelectors: suite [
	^self addToSuite: suite fromMethods: (self shouldInheritSelectors
		ifTrue: [ self allTestSelectors ]
		ifFalse: [self testSelectors ])
]

{ #category : #accessing }
TestCase class >> allTestSelectors [

	^(self allSelectors asArray select: [ :each | 
		each isTestSelector and: [ each numArgs isZero ] ]) sort
			
]

{ #category : #'building suites' }
TestCase class >> buildSuite [
	| suite |
	suite := self suiteClass new.
	^ self isAbstract
		ifTrue: [
			suite name: self name asString.
			self allSubclasses
				do: [:each | each isAbstract
						ifFalse: [each addToSuiteFromSelectors: suite]].
			suite]
		ifFalse: [self addToSuiteFromSelectors: suite]
]

{ #category : #'building suites' }
TestCase class >> buildSuiteFromAllSelectors [

	^self buildSuiteFromMethods: self allTestSelectors
			
]

{ #category : #'building suites' }
TestCase class >> buildSuiteFromLocalSelectors [

	^self buildSuiteFromMethods: self testSelectors
			
]

{ #category : #'building suites' }
TestCase class >> buildSuiteFromMethods: testMethods [ 
	| suite |
	suite := (self suiteClass new)
				name: self name asString;
				yourself.
	^self addToSuite: suite fromMethods: testMethods
]

{ #category : #'building suites' }
TestCase class >> buildSuiteFromSelectors [

	^self shouldInheritSelectors
		ifTrue: [self buildSuiteFromAllSelectors]
		ifFalse: [self buildSuiteFromLocalSelectors]
			
]

{ #category : #'initialize-release' }
TestCase class >> cleanUp: aggressive [

	aggressive ifTrue: [
		self withAllSubclassesDo: [:testCaseClass |
			testCaseClass resetHistory]].
]

{ #category : #coverage }
TestCase class >> coverage [
	"returns the coverage determined by a simple static analysis of test coverage 
	made by the receiver on a class that is identified by the name of the receiver.
	We assume that SetTest test Set."
	
	| cls className |
	(self name endsWith: 'Test') ifFalse: [self error: 'Please, use #coverageForClass: instead'].

	className := self name copyFrom: 1 to: (self name size - 'Test' size).
	cls := Smalltalk at: className asSymbol ifAbsent: [self error: 'Please, use #coverageForClass: instead'].
	
	"May happen with Transcript"
	cls isBehavior ifFalse: [cls := cls class].
	
	^ self coverageForClass: cls
]

{ #category : #coverage }
TestCase class >> coverageAsString [
	| cov className |
	cov := self coverage first asInteger. 
	"coverage already checks that the name is ends with 'Test' and if the class tested exists"
	
	className := self name copyFrom: 1 to: (self name size - 'Test' size).
	^ self name asString, ' covers ', cov asString, '% of ', className.
]

{ #category : #coverage }
TestCase class >> coverageForClass: cls [
	"returns the test coverage of all the methods included inherited ones"
	^ self coverageForClass: cls until: ProtoObject
]

{ #category : #coverage }
TestCase class >> coverageForClass: cls until: aRootClass [
	"returns the test coverage of all the methods included inherited ones but stopping at aRootClass included"
	
	| definedMethods testedMethods untestedMethods |
	definedMethods := cls allSelectorsAboveUntil: aRootClass.
	definedMethods size = 0
		ifTrue: [^ {0. Set new}].
	testedMethods := 
		self methodDictionary inject: Set new into: 
							[:sums :cm | sums union: cm messages].
	testedMethods := testedMethods reject: [:sel | (definedMethods includes: sel) not].
	untestedMethods := definedMethods select: [:selector | (testedMethods includes: selector) not].
	^ { (testedMethods size * 100 / definedMethods size) asFloat . untestedMethods}

]

{ #category : #coverage }
TestCase class >> coveragePercentage [
	^ self coverage first
]

{ #category : #'instance creation' }
TestCase class >> debug: aSymbol [

	^(self selector: aSymbol) debug
			
]

{ #category : #history }
TestCase class >> generateLastStoredRunMethod [

	self shouldGenerateLastStoredRunMethod ifTrue: [
		self class
			compile: (self lastRunMethodNamed: #lastStoredRun)
			classified: 'history' ]
]

{ #category : #testing }
TestCase class >> hasMethodBeenRun: aSelector [
	^ ((self lastRun at: #errors),
		(self lastRun at: #failures),
		(self lastRun at: #passed))
			includes: aSelector
]

{ #category : #history }
TestCase class >> history [
	^ history ifNil: [ history := self newTestDictionary ]
]

{ #category : #history }
TestCase class >> history: aDictionary [
	history := aDictionary
]

{ #category : #'initialize - event' }
TestCase class >> initialize [
     super initialize.
	SystemChangeNotifier uniqueInstance notify: self ofSystemChangesOfItem: #method using: #methodChanged:.
]

{ #category : #testing }
TestCase class >> isAbstract [
	"Override to true if a TestCase subclass is Abstract and should not have
	TestCase instances built from it"

	^self name = #TestCase
			
]

{ #category : #testing }
TestCase class >> isTestClass [
	^ true
]

{ #category : #history }
TestCase class >> lastRun [
	^ TestResult historyFor: self
]

{ #category : #history }
TestCase class >> lastRunMethodNamed: aSelector [
	
	^ String streamContents: [:str |
		str nextPutAll: aSelector asString ;cr.
		str tab; nextPutAll: '^ ', (self lastRun) storeString]

]

{ #category : #history }
TestCase class >> lastStoredRun [
	^ ((Dictionary new) add: (#failures->#()); add: (#passed->#()); add: (#errors->#()); yourself)
]

{ #category : #coverage }
TestCase class >> localCoverage [
	"returns the coverage determined by a simple static analysis of test coverage 
	made by the receiver on a class that is identified by the name of the receiver.
	We assume that SetTest test Set. The computation of the coverage takes only into
	account the methods defined locally in the tested class. See coverage for a more global 
	coverage"
	
	| cls className |
	(self name endsWith: 'Test') ifFalse: [self error: 'Please, use #localCoverageForClass: instead'].
	className := self name copyFrom: 1 to: (self name size - 'Test' size).
	cls := Smalltalk at: className asSymbol ifAbsent: [self error: 'Please, use #localCoverageForClass: instead'].
	cls isBehavior ifFalse: [cls := cls class].
	^ self localCoverageForClass: cls
]

{ #category : #coverage }
TestCase class >> localCoverageAsString [
	| cov className |
	cov := self localCoverage first asInteger. 
	"coverage already checks that the name is ends with 'Test' and if the class tested exists"
	
	className := self name copyFrom: 1 to: (self name size - 'Test' size).
	^ self name asString, ' covers ', cov asString, '% of ', className.
]

{ #category : #coverage }
TestCase class >> localCoverageForClass: cls [
	
	| definedMethods testedMethods untestedMethods |
	definedMethods := cls selectors asSet.
	"It happens for IdentityBag / IdentityBagTest"
	definedMethods size = 0
		ifTrue: [^ {0. Set new}].

	testedMethods := 
		self methodDictionary inject: Set new into: 
							[:sums :cm | sums union: cm messages].
					
	"testedMethods contains all the methods send in test methods, which probably contains methods that have nothign to do with collection"
	testedMethods := testedMethods reject: [:sel | (definedMethods includes: sel) not].

	untestedMethods := definedMethods select: [:selector | (testedMethods includes: selector) not].

	^ { (testedMethods size * 100 / definedMethods size) asFloat . untestedMethods}

]

{ #category : #coverage }
TestCase class >> localCoveragePercentage [
	^ self localCoverage first
]

{ #category : #'initialize - event' }
TestCase class >> methodChanged: anEvent [
	"Remove the changed method from the known test results."
	
	| cls sel |
	anEvent item isCompiledMethod ifFalse: [ ^ self ].
	cls := anEvent item methodClass.
	(cls inheritsFrom: TestCase)
		ifFalse: [^ self].
	sel := anEvent item selector.
	(sel beginsWith: 'test')
		ifFalse: [^ self].
	TestResult removeFromTestHistory: sel in: cls.

]

{ #category : #testing }
TestCase class >> methodFailed: aSelector [
	^ (self lastRun at: #failures) includes: aSelector
]

{ #category : #testing }
TestCase class >> methodPassed: aSelector [
	^ (self lastRun at: #passed) includes: aSelector
]

{ #category : #testing }
TestCase class >> methodProgressed: aSelector [
	^ ((self storedMethodRaisedError: aSelector) or: [self storedMethodFailed: aSelector])
		and: [self methodPassed: aSelector]
		
]

{ #category : #testing }
TestCase class >> methodRaisedError: aSelector [
	^ (self lastRun at: #errors) includes: aSelector
]

{ #category : #testing }
TestCase class >> methodRegressed: aSelector [
	^ (self storedMethodPassed: aSelector) and: [(self methodFailed: aSelector) or: [self methodRaisedError: aSelector]]
]

{ #category : #history }
TestCase class >> newTestDictionary [

	^ Dictionary new at: #timeStamp put: TimeStamp now;
		at: #passed put: Set new;
		at: #failures put: Set new;
		at: #errors put: Set new;
		yourself
		
]

{ #category : #history }
TestCase class >> resetHistory [
	history := nil
]

{ #category : #accessing }
TestCase class >> resources [

	^#()
			
]

{ #category : #'instance creation' }
TestCase class >> run: aSymbol [

	^(self selector: aSymbol) run
			
]

{ #category : #'instance creation' }
TestCase class >> selector: aSymbol [

	^self new setTestSelector: aSymbol
			
]

{ #category : #history }
TestCase class >> shouldGenerateLastStoredRunMethod [
	| sameRun |
	
	(self class methodDictionary includesKey: #lastStoredRun)
		ifFalse: [^ true].
	sameRun := #(#passed #failures #errors) inject: true into: 
		[ :ok :set | ok and: [(self lastRun at: set) = (self lastStoredRun at: set) ]].
	^ sameRun not

]

{ #category : #testing }
TestCase class >> shouldInheritSelectors [
	"I should inherit from an Abstract superclass but not from a concrete one by default, unless I have no testSelectors in which case I must be expecting to inherit them from my superclass.  If a test case with selectors wants to inherit selectors from a concrete superclass, override this to true in that subclass."

	^self superclass isAbstract
		or: [self testSelectors isEmpty]

"$QA Ignore:Sends system method(superclass)$"
			
]

{ #category : #testing }
TestCase class >> storedMethodFailed: aSelector [
	^ (self lastStoredRun at: #failures) includes: aSelector
]

{ #category : #testing }
TestCase class >> storedMethodPassed: aSelector [
	^ (self lastStoredRun at: #passed) includes: aSelector
]

{ #category : #testing }
TestCase class >> storedMethodRaisedError: aSelector [
	^ (self lastStoredRun at: #errors) includes: aSelector
]

{ #category : #'instance creation' }
TestCase class >> suite [

	^self buildSuite
			
]

{ #category : #'building suites' }
TestCase class >> suiteClass [
	^TestSuite
			
]

{ #category : #accessing }
TestCase class >> sunitVersion [
	^'3.1'
			
]

{ #category : #accessing }
TestCase class >> testSelectors [

	^(self selectors asArray select: [ :each | 
		(each beginsWith: 'test') and: [ each numArgs isZero ] ]) sort
]

{ #category : #dependencies }
TestCase >> addDependentToHierachy: anObject [ 
	"an empty method. for Composite compability with TestSuite"


			
]

{ #category : #asserting }
TestCase >> assert: aBooleanOrBlock [

	aBooleanOrBlock value ifFalse: [self signalFailure: 'Assertion failed']
			
]

{ #category : #asserting }
TestCase >> assert: aBooleanOrBlock description: aStringOrBlock [

	aBooleanOrBlock value ifFalse: [
		| description |
		description := aStringOrBlock value.
		self logFailure: description.
		TestResult failure signal: description ]
			
]

{ #category : #asserting }
TestCase >> assert: aBooleanOrBlock description: aString resumable: resumableBoolean [ 
	| exception |
	aBooleanOrBlock value
		ifFalse: 
			[self logFailure: aString.
			exception := resumableBoolean
						ifTrue: [TestResult resumableFailure]
						ifFalse: [TestResult failure].
			exception signal: aString]
			
]

{ #category : #asserting }
TestCase >> assert: expected equals: actual [

	^self
		assert: expected = actual
		description: [ self comparingStringBetween: expected and: actual ]

]

{ #category : #asserting }
TestCase >> assert: expected equals: actual description: aString [

	^self
		assert: expected = actual
		description: [ aString , ': ', (self comparingStringBetween: expected and: actual) ]
]

{ #category : #asserting }
TestCase >> assert: expected identical: actual [

	^self
		assert: expected == actual
		description: [ self comparingStringBetweenIdentical: expected and: actual ]

]

{ #category : #asserting }
TestCase >> assert: expected identical: actual description: aString [

	^self
		assert: expected == actual
		description: [ aString , ': ', (self comparingStringBetweenIdentical: expected and: actual) ]
]

{ #category : #private }
TestCase >> comparingStringBetween: expected and: actual [
	^ String streamContents: [:stream |
		stream
			nextPutAll: 'Expected ';
			nextPutAll: (expected printStringLimitedTo: 10);
			nextPutAll: ' but was ';
			nextPutAll: (actual printStringLimitedTo: 10);
			nextPutAll: '.'
		]
]

{ #category : #private }
TestCase >> comparingStringBetweenIdentical: expected and: actual [
	^ 'Expected {1} and actual {2} are not identical.' format: {
		expected printStringLimitedTo: 10.
		actual printStringLimitedTo: 10.
	}
]

{ #category : #running }
TestCase >> debug [
	self resources do:
		[ : res | res isAvailable ifFalse: [ ^ res signalInitializationError ] ].
	[ self runCase ] ensure:
		[ self resources do:
			[ : each | each reset ] ]
]

{ #category : #running }
TestCase >> debugAsFailure [
	| semaphore |
	semaphore := Semaphore new.
	self resources do: [:res | 
		res isAvailable ifFalse: [^res signalInitializationError]].
	[semaphore wait. self resources do: [:each | each reset]] fork.
	(self class selector: testSelector) runCaseAsFailure: semaphore.
]

{ #category : #'running - timeout' }
TestCase >> defaultTimeout [
	"Answer the default timeout to use for tests in this test case.
	The timeout is a value in seconds."

	^Smalltalk isLowerPerformance ifTrue:[ 25] ifFalse: [5] "seconds"
]

{ #category : #asserting }
TestCase >> deny: aBooleanOrBlock [

	self assert: aBooleanOrBlock value not
			
]

{ #category : #asserting }
TestCase >> deny: aBooleanOrBlock description: aString [
	self assert: aBooleanOrBlock value not description: aString
			
]

{ #category : #asserting }
TestCase >> deny: aBooleanOrBlock description: aString resumable: resumableBoolean [ 
	self
		assert: aBooleanOrBlock value not
		description: aString
		resumable: resumableBoolean
			
]

{ #category : #asserting }
TestCase >> deny: unexpected equals: actual [

	^self
		deny: unexpected = actual
		description: 'Actual equals unexpected'

]

{ #category : #'asserting - extensions' }
TestCase >> ensureInternetConnection [

	^ self ensureInternetConnectionTo: 'http://www.google.com'
]

{ #category : #'asserting - extensions' }
TestCase >> ensureInternetConnectionTo: url [ 

	"(Smalltalk classNamed: 'WebClient') httpGet: 'http://www.google.com'"
	((Smalltalk classNamed: 'WebClient') httpGet: url) isSuccess
		ifFalse: [Error signal: 'No internet connection available, but test requires one']
		
]

{ #category : #'asserting - extensions' }
TestCase >> ensureSecureInternetConnection [

	^ self ensureInternetConnectionTo: 'https://www.google.com'
]

{ #category : #private }
TestCase >> executeShould: aBlock inScopeOf: anExceptionalEvent [ 
	^[aBlock value.
 	false] on: anExceptionalEvent
		do: [:ex | ex return: true]
			
]

{ #category : #private }
TestCase >> executeShould: aBlock inScopeOf: anExceptionalEvent withDescriptionContaining: aString [
	^[aBlock value.
 	false] on: anExceptionalEvent
		do: [:ex | ex return: (ex description includesSubstring: aString) ]
			
]

{ #category : #private }
TestCase >> executeShould: aBlock inScopeOf: anExceptionalEvent withDescriptionNotContaining: aString [
	^[aBlock value.
 	false] on: anExceptionalEvent
		do: [:ex | ex return: (ex description includesSubstring: aString) not ]
			
]

{ #category : #'asserting - extensions' }
TestCase >> executeShould: aBlock inScopeOf: anException withExceptionDo: anotherBlock [

	^[aBlock value.
 	false] 
		on: anException
		do: [:exception | 
			anotherBlock value: exception.
			exception return: true]
]

{ #category : #failures }
TestCase >> expectedFailures [
	^ Array new
]

{ #category : #'asserting - extensions' }
TestCase >> fail [

	^self assert: false
]

{ #category : #'asserting - extensions' }
TestCase >> fail: aString [

	^self assert: false description: aString.
]

{ #category : #running }
TestCase >> failureLog [	
	^Transcript

			
]

{ #category : #running }
TestCase >> isLogging [
	"By default, we're not logging failures. If you override this in 
	a subclass, make sure that you override #failureLog"
	^false
			
]

{ #category : #running }
TestCase >> logFailure: aString [
	self isLogging ifTrue: [
		self failureLog 
			cr; 
			nextPutAll: aString; 
			flush]
			
]

{ #category : #running }
TestCase >> openDebuggerOnFailingTestMethod [
	"SUnit has halted one step in front of the failing test method. Step over the 'self halt' and 
	 send into 'self perform: testSelector' to see the failure from the beginning"

	self
		halt;
		performTest
]

{ #category : #private }
TestCase >> performTest [

	self perform: testSelector asSymbol
			
]

{ #category : #printing }
TestCase >> printOn: aStream [

	testSelector
		ifNil: [super printOn: aStream]
		ifNotNil:
			[aStream
				nextPutAll: self class printString;
				nextPutAll: '>>#';
				nextPutAll: testSelector]	
]

{ #category : #dependencies }
TestCase >> removeDependentFromHierachy: anObject [ 
	"an empty method. for Composite compability with TestSuite"


			
]

{ #category : #accessing }
TestCase >> resources [
	| allResources resourceQueue |
	allResources := Set new.
	resourceQueue := OrderedCollection new.
	resourceQueue addAll: self class resources.
	[resourceQueue isEmpty] whileFalse: [
		| next |
		next := resourceQueue removeFirst.
		allResources add: next.
		resourceQueue addAll: next resources].
	^allResources
			
]

{ #category : #running }
TestCase >> run [
	| result |
	result := TestResult new.
	self run: result.
	^result
			
]

{ #category : #running }
TestCase >> run: aResult [ 
	aResult runCase: self.

]

{ #category : #running }
TestCase >> runCase [
	"Run this TestCase. Time out if the test takes too long."

	[self timeout: [self setUp]
		after: self timeoutForSetUp.
	self timeout: [self performTest]
		after: self timeoutForTest]
		ensure: [self tearDown]
]

{ #category : #running }
TestCase >> runCaseAsFailure: aSemaphore [
	[self setUp.
	self openDebuggerOnFailingTestMethod] ensure: [
		self tearDown.
		aSemaphore signal]
]

{ #category : #accessing }
TestCase >> selector [
	^testSelector
			
]

{ #category : #private }
TestCase >> setTestSelector: aSymbol [
	testSelector := aSymbol
			
]

{ #category : #running }
TestCase >> setUp [
]

{ #category : #asserting }
TestCase >> should: aBlock [
	self assert: aBlock value
			
]

{ #category : #asserting }
TestCase >> should: aBlock description: aString [
	self assert: aBlock value description: aString
			
]

{ #category : #'asserting - extensions' }
TestCase >> should: aBlock notTakeMoreThan: aDuration [
    "Evaluate aBlock in a forked process and if it takes more than anInteger milliseconds
    to run we terminate the process and report a test failure.  It'' important to
    use the active process for the test failure so that the failure reporting works correctly
    in the context of the exception handlers."

    | evaluated evaluationProcess result delay testProcess |

    evaluated := false.
    delay := Delay forDuration: aDuration.
    testProcess := Processor activeProcess.
    "Create a new process to evaluate aBlock"
    evaluationProcess := [
        result := aBlock value.
        evaluated := true.
        delay unschedule.
        testProcess resume ] forkNamed: 'Process to evaluate should: notTakeMoreThanMilliseconds:'.

    "Wait the milliseconds they asked me to"
    delay wait.
    "After this point either aBlock was evaluated or not..."
    evaluated ifFalse: [
        evaluationProcess terminate.
        self assert: false description: ('Block evaluation took more than the expected <1p>' expandMacrosWith: aDuration)].
   
    ^result
]

{ #category : #'asserting - extensions' }
TestCase >> should: aBlock notTakeMoreThanMilliseconds: anInteger [
    "For compatibility with other Smalltalks"

   self should: aBlock notTakeMoreThan: (Duration milliSeconds: anInteger).
]

{ #category : #asserting }
TestCase >> should: aBlock raise: anExceptionalEvent [ 
	^self assert: (self executeShould: aBlock inScopeOf: anExceptionalEvent)
			
]

{ #category : #asserting }
TestCase >> should: aBlock raise: anExceptionalEvent description: aString [ 
	^self assert: (self executeShould: aBlock inScopeOf: anExceptionalEvent)
		description: aString
			
]

{ #category : #asserting }
TestCase >> should: aBlock raise: anExceptionalEvent whoseDescriptionDoesNotInclude: subString description: aString [ 
	^self assert: (self executeShould: aBlock inScopeOf: anExceptionalEvent withDescriptionNotContaining: subString)
		description: aString

]

{ #category : #asserting }
TestCase >> should: aBlock raise: anExceptionalEvent whoseDescriptionIncludes: subString description: aString [ 
	^self assert: (self executeShould: aBlock inScopeOf: anExceptionalEvent withDescriptionContaining: subString)
		description: aString

]

{ #category : #'asserting - extensions' }
TestCase >> should: aBlock raise: anException withExceptionDo: anotherBlock [ 

	^self assert: (self executeShould: aBlock inScopeOf: anException withExceptionDo: anotherBlock)
]

{ #category : #'asserting - extensions' }
TestCase >> shouldFix: aBlock [ 

	^self should: aBlock raise: Exception
]

{ #category : #testing }
TestCase >> shouldPass [
	"Unless the selector is in the list we get from #expectedFailures, we expect it to pass"
	^ (self expectedFailures includes: testSelector) not
]

{ #category : #asserting }
TestCase >> shouldnt: aBlock [
	self deny: aBlock value
			
]

{ #category : #asserting }
TestCase >> shouldnt: aBlock description: aString [
	self deny: aBlock value description: aString
			
]

{ #category : #asserting }
TestCase >> shouldnt: aBlock raise: anExceptionalEvent [ 
	^ [ aBlock value ]
		on: anExceptionalEvent
		do: [:e | self fail: 'Block raised ', e className, ': ', e messageText].
]

{ #category : #asserting }
TestCase >> shouldnt: aBlock raise: anExceptionalEvent description: aString [ 
	^self assert: (self executeShould: aBlock inScopeOf: anExceptionalEvent) not 		description: aString
			
]

{ #category : #asserting }
TestCase >> shouldnt: aBlock raise: anExceptionalEvent whoseDescriptionDoesNotInclude: subString description: aString [ 
	^self assert: (self executeShould: aBlock inScopeOf: anExceptionalEvent withDescriptionNotContaining: subString) not
		description: aString

]

{ #category : #asserting }
TestCase >> shouldnt: aBlock raise: anExceptionalEvent whoseDescriptionIncludes: subString description: aString [ 
	^self assert: (self executeShould: aBlock inScopeOf: anExceptionalEvent withDescriptionContaining: subString) not
		description: aString

]

{ #category : #private }
TestCase >> signalFailure: aString [
	TestResult failure signal: aString
]

{ #category : #running }
TestCase >> tearDown [
]

{ #category : #'running - timeout' }
TestCase >> timeout: seconds [
	"The timeout for a test should normally be set with a method annotation.
	However, for tests that are expected to run in images that do not support
	method annotations, the value may be set by setting the value from the
	#setUp method (i.e. prior to running the test method)."

	timeout := seconds
]

{ #category : #private }
TestCase >> timeout: aBlock after: seconds [
	"Evaluate the argument block. Time out if the evaluation is not
	complete after the given number of seconds. Handle the situation
	that a timeout may occur after a failure (during debug)"

	| theProcess delay watchdog |

	"the block will be executed in the current process"
	theProcess := Processor activeProcess.
	delay := Delay forSeconds: seconds.

	"make a watchdog process"
	watchdog := [
		delay wait. 	"wait for timeout or completion"
		theProcess ifNotNil:[ theProcess signalException: 
			(TestFailure new messageText: 'Test timed out') ] 
	] newProcess.

	"Watchdog needs to run at high priority to do its job (but not at timing priority)"
	watchdog priority: Processor timingPriority-1.

	"catch the timeout signal"
	watchdog resume.				"start up the watchdog"
	^[aBlock on: TestFailure, Error, Halt do:[:ex|
		theProcess := nil.
		ex pass.
	]] ensure:[							"evaluate the receiver"
		theProcess := nil.				"it has completed, so ..."
		delay delaySemaphore signal.	"arrange for the watchdog to exit"
	]
]

{ #category : #'running - timeout' }
TestCase >> timeoutForSetUp [
	"Answer the timeout to use for setUp"

	| method |
	method := self class lookupSelector: testSelector asSymbol.
	(method pragmaAt: #timeout:) ifNotNil:[:tag| ^tag arguments first].
	^self defaultTimeout
]

{ #category : #'running - timeout' }
TestCase >> timeoutForTest [
	"Answer the timeout to use for this test"

	| method |
	method := self class lookupSelector: testSelector asSymbol.
	(method pragmaAt: #timeout:) ifNotNil:[:tag| ^tag arguments first].
	^timeout ifNil: [self defaultTimeout]
]
