Class {
	#name : #ExceptionTests,
	#superclass : #TestCase,
	#category : #'Tests-Exceptions'
}

{ #category : #private }
ExceptionTests >> assertSuccess: anExceptionTester [
	self should: [ ( anExceptionTester suiteLog first) endsWith:  'succeeded'].
]

{ #category : #failures }
ExceptionTests >> expectedFailures [
	"This test is a feature request. For more information on this issue visit:
	http://forum.world.st/The-Inbox-Tests-TestRunner-156-mcz-tc4643910.html#a4643987
	http://forum.world.st/ExceptionTests-Wrong-error-handler-tc4848699.html
	http://forum.world.st/ExceptionTests-gt-testHandlerFromAction-fails-tc4872828.html#a4872958"
	
	^ #(testHandlerFromAction).
]

{ #category : #'tests - ExceptionTester' }
ExceptionTests >> testDoubleOuterPass [
	self assertSuccess: (ExceptionTester new runTest: #doubleOuterPassTest ) 
]

{ #category : #'tests - ExceptionTester' }
ExceptionTests >> testDoublePassOuter [
	self assertSuccess: (ExceptionTester new runTest: #doublePassOuterTest ) 
]

{ #category : #'tests - ExceptionTester' }
ExceptionTests >> testDoubleResume [
	self assertSuccess: (ExceptionTester new runTest: #doubleResumeTest ) 
]

{ #category : #'tests - outer' }
ExceptionTests >> testHandlerFromAction [
	"A test ensuring that nested exceptions work as expected."

	| result |
	result := [
		[
			[self error: 'trigger error'] on: ZeroDivide do: [ :ex | 'inner' ]
		] on: Error do: [ :ex | 3 / 0 ]
	] on: ZeroDivide do: [ :ex | 'outer' ].
	self assert: 'outer' equals: result description: 'Incorrect handler'.

]

{ #category : #tests }
ExceptionTests >> testHandlerReentrancy [

	| callingOrder |
	"Handlers are not re-entrant by default, so inner is not activated twice"
	callingOrder := String streamContents: [:stream |
		[[stream nextPut: $s. Notification signal]
		
			"Inner handler"
			on: Notification do: [:ex |
				stream nextPut: $i.
				ex pass]]
		
			"outer handler"
			on: Notification do: [:ex |
				stream nextPut: $o.
				Notification signal]].
		
	self assert: callingOrder = 'sio'.

	"Now make inner re-entrant"
	callingOrder := String streamContents: [:stream |
		[[stream nextPut: $s. Notification signal]
		
			"Inner handler"
			on: Notification do: [:ex |
				stream nextPut: $i.
				ex rearmHandlerDuring: [ex pass]]]
		
			"outer handler"
			on: Notification do: [:ex |
				stream nextPut: $o.
				Notification signal]].
		
	self assert: callingOrder = 'sioi'.
]

{ #category : #tests }
ExceptionTests >> testNoTimeout [
	self assertSuccess: (ExceptionTester new runTest: #simpleNoTimeoutTest ) 
]

{ #category : #'tests - ExceptionTester' }
ExceptionTests >> testNonResumableFallOffTheEndHandler [
	self assertSuccess: (ExceptionTester new runTest: #nonResumableFallOffTheEndHandler ) 
]

{ #category : #'tests - outer' }
ExceptionTests >> testNonResumableOuter [

	self should: [
		[Error signal. 4] 
			on: Error 
			do: [:ex | ex outer. ex return: 5]
		] raise: Error

]

{ #category : #'tests - outer' }
ExceptionTests >> testNonResumablePass [

	self should: [
		[Error signal. 4] 
			on: Error 
			do: [:ex | ex pass. ex return: 5]
		] raise: Error

]

{ #category : #'tests - outer' }
ExceptionTests >> testOuter [
	| result |
	result := [[Notification signal. #signal]
					on: Notification
					do: [:ex| ex outer. #inner]]
				on: Notification
				do: [:ex| #outer].
	self assert: result = #outer
]

{ #category : #'tests - ExceptionTester' }
ExceptionTests >> testResumableFallOffTheEndHandler [
	self assertSuccess: (ExceptionTester new runTest: #resumableFallOffTheEndHandler ) 
]

{ #category : #'tests - outer' }
ExceptionTests >> testResumableOuter [

	| result |
	result := [Notification signal. 4] 
		on: Notification 
		do: [:ex | ex outer. ex return: 5].
	self assert: result = 5

]

{ #category : #'tests - outer' }
ExceptionTests >> testResumablePass [

	| result |
	result := [Notification signal. 4] 
		on: Notification 
		do: [:ex | ex pass. ex return: 5].
	self assert: result = 4

]

{ #category : #'tests - ExceptionTester' }
ExceptionTests >> testSignalFromHandlerActionTest [
	self assertSuccess: (ExceptionTester new runTest: #signalFromHandlerActionTest ) 
]

{ #category : #'tests - ExceptionTester' }
ExceptionTests >> testSimpleEnsure [
	self assertSuccess: (ExceptionTester new runTest: #simpleEnsureTest ) 
]

{ #category : #'tests - ExceptionTester' }
ExceptionTests >> testSimpleEnsureTestWithError [
	self assertSuccess: (ExceptionTester new runTest: #simpleEnsureTestWithError ) 
]

{ #category : #'tests - ExceptionTester' }
ExceptionTests >> testSimpleEnsureTestWithNotification [
	self assertSuccess: (ExceptionTester new runTest: #simpleEnsureTestWithNotification ) 
]

{ #category : #'tests - ExceptionTester' }
ExceptionTests >> testSimpleEnsureTestWithUparrow [
	self assertSuccess: (ExceptionTester new runTest: #simpleEnsureTestWithUparrow ) 
]

{ #category : #'tests - ExceptionTester' }
ExceptionTests >> testSimpleIsNested [
	self assertSuccess: (ExceptionTester new runTest: #simpleIsNestedTest ) 
]

{ #category : #'tests - ExceptionTester' }
ExceptionTests >> testSimpleOuter [
	self assertSuccess: (ExceptionTester new runTest: #simpleOuterTest ) 
]

{ #category : #'tests - ExceptionTester' }
ExceptionTests >> testSimplePass [
	self assertSuccess: (ExceptionTester new runTest: #simplePassTest ) 
]

{ #category : #'tests - ExceptionTester' }
ExceptionTests >> testSimpleResignalAs [
	self assertSuccess: (ExceptionTester new runTest: #simpleResignalAsTest ) 
]

{ #category : #'tests - ExceptionTester' }
ExceptionTests >> testSimpleResume [
	self assertSuccess: (ExceptionTester new runTest: #simpleResumeTest ) 
]

{ #category : #'tests - ExceptionTester' }
ExceptionTests >> testSimpleRetry [
	self assertSuccess: (ExceptionTester new runTest: #simpleRetryTest ) 
]

{ #category : #'tests - ExceptionTester' }
ExceptionTests >> testSimpleRetryUsing [
	self assertSuccess: (ExceptionTester new runTest: #simpleRetryUsingTest ) 
]

{ #category : #'tests - ExceptionTester' }
ExceptionTests >> testSimpleReturn [
	self assertSuccess: (ExceptionTester new runTest: #simpleReturnTest ) 
]

{ #category : #tests }
ExceptionTests >> testTimeoutWithZeroDuration [
	self assertSuccess: (ExceptionTester new runTest: #simpleTimeoutWithZeroDurationTest ) 
]
