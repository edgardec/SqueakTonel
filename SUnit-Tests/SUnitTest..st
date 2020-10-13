"
This is both an example of writing tests and a self test for the SUnit. The tests 
here are pretty strange, since you want to make sure things blow up. You should 
not generally have to write tests this complicated in structure, although they 
will be far more complicated in terms of your own objects- more assertions, more 
complicated setup. Kent says: ""Never forget, however, that if the tests are hard 
to write, something is probably wrong with the design"".
"
Class {
	#name : #SUnitTest,
	#superclass : #TestCase,
	#instVars : [
		'hasRun',
		'hasSetup',
		'hasRanOnce'
	],
	#category : #'SUnit-Tests'
}

{ #category : #history }
SUnitTest class >> lastStoredRun [
	^ ((Dictionary new) add: (#passed->((Set new) add: #testWithExceptionDo; add: #testRan; add: #testAssert; add: #testRanOnlyOnce; add: #testDialectLocalizedException; add: #testFail; add: #testDefects; add: #testIsNotRerunOnDebug; add: #testResult; add: #testRunning; add: #testError; add: #testException; add: #testShould; add: #testSuite; yourself)); add: (#timeStamp->'22 November 2008 10:11:35 pm'); add: (#failures->((Set new))); add: (#errors->((Set new))); yourself)
]

{ #category : #private }
SUnitTest >> assertForTestResult: aResult runCount: aRunCount passed: aPassedCount failed: aFailureCount errors: anErrorCount [

	self
		assert: aResult runCount = aRunCount;
		assert: aResult passedCount = aPassedCount;
		assert: aResult failureCount = aFailureCount;
		assert: aResult errorCount = anErrorCount
			
]

{ #category : #private }
SUnitTest >> error [
	3 zork
			
]

{ #category : #tests }
SUnitTest >> errorShouldntRaise [
	self 
		shouldnt: [self someMessageThatIsntUnderstood] 
		raise: Notification new
			
]

{ #category : #private }
SUnitTest >> fail [
	self assert: false
			
]

{ #category : #accessing }
SUnitTest >> hasRun [
	^hasRun
			
]

{ #category : #accessing }
SUnitTest >> hasSetup [
	^hasSetup
			
]

{ #category : #private }
SUnitTest >> noop [
			
]

{ #category : #private }
SUnitTest >> setRun [
	hasRun := true
			
]

{ #category : #running }
SUnitTest >> setUp [
	hasSetup := true
			
]

{ #category : #tests }
SUnitTest >> testAssert [
	self assert: true.
	self deny: false
			
]

{ #category : #tests }
SUnitTest >> testAssertIdentical [
	| a b |
	a := 'foo'.
	b := 'bar'.
	self should: [self assert: a identical: b] raise: TestFailure.
	[self assert: a identical: b] on: TestFailure do: [:e | |error|
		error := e messageText.
		self assert: (error includesSubstring: a) description: 'Error message doesn''t include the expected value'.
		self assert: (error includesSubstring: b) description: 'Error message doesn''t include the expected value'].
]

{ #category : #tests }
SUnitTest >> testAssertIdenticalDescription [
	| a b |
	a := 'foo'.
	b := a copy.
	self should: [self assert: a identical: b description: 'A desciption'] raise: TestFailure.
	[self assert: a identical: b description: 'A desciption'] on: TestFailure do: [:e | |error|
		error := e messageText.
		self assert: (error includesSubstring: 'A desciption') description: 'Error message doesn''t give you the description'].
]

{ #category : #tests }
SUnitTest >> testAssertIdenticalWithEqualObjects [
	| a b |
	a := 'foo'.
	b := a copy.
	self should: [self assert: a identical: b] raise: TestFailure.
	[self assert: a identical: b] on: TestFailure do: [:e | |error|
		error := e messageText.
		self assert: (error includesSubstring: 'not identical') description: 'Error message doesn''t say the two things aren''t identical'].
]

{ #category : #tests }
SUnitTest >> testDefects [
	| result suite error failure |
	suite := TestSuite new.
	suite addTest: (error := self class selector: #error).
	suite addTest: (failure := self class selector: #fail).
	result := suite run.
	self assert: result defects asArray = (Array with: error with: failure).
	self
		assertForTestResult: result
		runCount: 2
		passed: 0
		failed: 1
		errors: 1
			
]

{ #category : #tests }
SUnitTest >> testDialectLocalizedException [

	self
		should: [TestResult signalFailureWith: 'Foo']
		raise: TestResult failure.
	self
		should: [TestResult signalErrorWith: 'Foo']
		raise: TestResult error.

			
]

{ #category : #tests }
SUnitTest >> testError [

	| case result |

	case := self class selector: #error.
	result := case run.
	self
		assertForTestResult: result
		runCount: 1
		passed: 0
		failed: 0
		errors: 1.

	case := self class selector: #errorShouldntRaise.
	result := case run.
	self 
		assertForTestResult: result
		runCount: 1
		passed: 0
		failed: 0
		errors: 1
			
]

{ #category : #tests }
SUnitTest >> testException [

	self
		should: [self error: 'foo']
		raise: TestResult error
			
]

{ #category : #tests }
SUnitTest >> testFail [

	| case result |

	case := self class selector: #fail.
	result := case run.

	self
		assertForTestResult: result
		runCount: 1
		passed: 0
		failed: 1
		errors: 0
			
]

{ #category : #tests }
SUnitTest >> testRan [

	| case |

	case := self class selector: #setRun.
	case run.
	self assert: case hasSetup.
	self assert: case hasRun
			
]

{ #category : #tests }
SUnitTest >> testRanOnlyOnce [

	self assert: hasRanOnce ~= true.
	hasRanOnce := true
			
]

{ #category : #tests }
SUnitTest >> testResult [

	| case result |

	case := self class selector: #noop.
	result := case run.

	self
		assertForTestResult: result
		runCount: 1
		passed: 1
		failed: 0
		errors: 0
			
]

{ #category : #tests }
SUnitTest >> testRunning [

	(Delay forSeconds: 2) wait
			
]

{ #category : #tests }
SUnitTest >> testSelectorWithArg: anObject [
	"should not result in error"
]

{ #category : #tests }
SUnitTest >> testShould [

	self
		should: [true];
		shouldnt: [false]
			
]

{ #category : #tests }
SUnitTest >> testSuite [

	| suite result |

	suite := TestSuite new.
	suite 
		addTest: (self class selector: #noop);
		addTest: (self class selector: #fail);
		addTest: (self class selector: #error).

	result := suite run.

	self
		assertForTestResult: result
		runCount: 3
		passed: 1
		failed: 1
		errors: 1
			
]

{ #category : #tests }
SUnitTest >> testTestTimeout [
	self should:[(Delay forSeconds: (self timeoutForTest + 1)) wait] raise: TestFailure.

]

{ #category : #tests }
SUnitTest >> testTestTimeoutLoop [
	<timeout: 1>
	self should:[[] repeat] raise: TestFailure.

]

{ #category : #tests }
SUnitTest >> testTestTimeoutTag [
	<timeout: 1>
	self should:[(Delay forSeconds: 3) wait] raise: TestFailure.

]

{ #category : #tests }
SUnitTest >> testWithExceptionDo [

	self
		should: [self error: 'foo']
		raise: TestResult error
		withExceptionDo: [:exception |
			self assert: (exception description includesSubstring: 'foo')
		]
			
]
