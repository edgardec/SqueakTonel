"
This is a Collecting Parameter for the running of a bunch of tests. TestResult is an interesting object to subclass or substitute. #runCase: is the external protocol you need to reproduce. Kent has seen TestResults that recorded coverage information and that sent email when they were done.
"
Class {
	#name : #TestResult,
	#superclass : #Object,
	#instVars : [
		'timeStamp',
		'failures',
		'errors',
		'passed',
		'durations'
	],
	#category : #'SUnit-Kernel'
}

{ #category : #exceptions }
TestResult class >> error [
	^self exError
			
]

{ #category : #exceptions }
TestResult class >> exError [
	^Error
			
]

{ #category : #exceptions }
TestResult class >> failure [
	^TestFailure
			
]

{ #category : #history }
TestResult class >> historyAt: aTestCaseClass [
"I will return the last test dictionary for aTestCaseClass. If none found, I will create a new empty one and link it in the history."

	^ aTestCaseClass history 
]

{ #category : #history }
TestResult class >> historyAt: aTestCaseClass put: aDictionary [
	aTestCaseClass history: aDictionary
	"^ self history at: aTestCaseClass put: aDictionary "
]

{ #category : #history }
TestResult class >> historyFor: aTestCaseClass [
	"I return the last test dictionary for aTestCaseClass. 
	If none found, I return an empty dictionary but will not link it to the class in the history."
	
	| history |
	history := aTestCaseClass history.
	history ifNil: [ ^ self newTestDictionary ].
	^ history
	
"	^ self history at: aTestCaseClass ifAbsent: [ self newTestDictionary ]"
]

{ #category : #history }
TestResult class >> newTestDictionary [

	^ Dictionary new at: #timeStamp put: TimeStamp now;
		at: #passed put: Set new;
		at: #failures put: Set new;
		at: #errors put: Set new;
		yourself
		
]

{ #category : #history }
TestResult class >> removeFromTestHistory: aSelector in: aTestCaseClass [
	| lastRun |
	
	lastRun := self historyFor: aTestCaseClass.
	#(#passed #failures #errors) do:
		[ :set | (lastRun at: set) remove: aSelector ifAbsent: []].

]

{ #category : #exceptions }
TestResult class >> resumableFailure [
	^ResumableTestFailure
			
]

{ #category : #exceptions }
TestResult class >> signalErrorWith: aString [ 
	self error signal: aString
			
]

{ #category : #exceptions }
TestResult class >> signalFailureWith: aString [ 
	self failure signal: aString
			
]

{ #category : #history }
TestResult class >> updateTestHistoryFor: aTestCase status: aSymbol [
	| cls sel |
	
	cls := aTestCase class.
	sel := aTestCase selector.
	self removeFromTestHistory: sel in: cls.
	((self historyAt: cls) at: aSymbol ) add: sel
]

{ #category : #accessing }
TestResult >> classesTested [
	^ (self tests collect: [ :testCase | testCase class ]) asSet
]

{ #category : #accessing }
TestResult >> correctCount [
	"depreciated - use #passedCount"

	^self passedCount
			
]

{ #category : #accessing }
TestResult >> defects [
	^OrderedCollection new
		addAll: self errors;
		addAll: self failures; yourself
			
]

{ #category : #diff }
TestResult >> diff: aTestResult [
	"Return a collection that contains differences"
	| passed1Selectors failed1Selectors errors1Selectors passed2Selectors failed2Selectors errors2Selectors |
	passed1Selectors := self passed collect: [:testCase | testCase selector].
	failed1Selectors := self failures collect: [:testCase | testCase selector].
	errors1Selectors := self errors collect: [:testCase | testCase selector].

	passed2Selectors := aTestResult passed collect: [:testCase | testCase selector].
	failed2Selectors := aTestResult failures collect: [:testCase | testCase selector].
	errors2Selectors := aTestResult errors collect: [:testCase | testCase selector].
	
	^ {passed1Selectors copyWithoutAll: passed2Selectors .
		failed1Selectors copyWithoutAll: failed2Selectors .
		errors1Selectors copyWithoutAll: errors2Selectors}
]

{ #category : #history }
TestResult >> dispatchResultsIntoHistory [ 

	self classesTested do: 
		[ :testClass | 
		self class
			historyAt: testClass
			put: (self selectResultsForTestCase: testClass) ].

]

{ #category : #accessing }
TestResult >> duration [

	^ self durations inject: 0 into: [:sum :each | sum + (each ifNil: [0])]
]

{ #category : #accessing }
TestResult >> durations [
	^ durations
]

{ #category : #accessing }
TestResult >> errorCount [

	^self errors size
			
]

{ #category : #compatibility }
TestResult >> errors [
	^ self unexpectedErrors
]

{ #category : #accessing }
TestResult >> expectedDefectCount [
	^ self expectedDefects size
]

{ #category : #accessing }
TestResult >> expectedDefects [
	^ (errors, failures asOrderedCollection) select: [:each | each shouldPass not] 
]

{ #category : #accessing }
TestResult >> expectedPassCount [
	^ self expectedPasses size
]

{ #category : #accessing }
TestResult >> expectedPasses [
	^ passed select: [:each | each shouldPass] 
]

{ #category : #accessing }
TestResult >> failureCount [

	^self failures size
			
]

{ #category : #compatibility }
TestResult >> failures [
	^ self unexpectedFailures, self unexpectedPasses 
]

{ #category : #testing }
TestResult >> hasErrors [

	^self errors size > 0
			
]

{ #category : #testing }
TestResult >> hasFailures [

	^self failures size > 0
			
]

{ #category : #testing }
TestResult >> hasPassed [
	^ self hasErrors not and: [ self hasFailures not ]
]

{ #category : #initialization }
TestResult >> initialize [
	super initialize.
	passed := OrderedCollection new.
	failures := Set new.
	errors := OrderedCollection new.
	timeStamp := TimeStamp now.
	durations := Dictionary new.
]

{ #category : #testing }
TestResult >> isError: aTestCase [

	^self errors includes: aTestCase
			
]

{ #category : #querying }
TestResult >> isErrorFor: class selector: selector [
	^ self errors anySatisfy: [:testCase | testCase class == class and: [testCase selector == selector]]
]

{ #category : #testing }
TestResult >> isFailure: aTestCase [
	^self failures includes: aTestCase
			
]

{ #category : #querying }
TestResult >> isFailureFor: class selector: selector [
	^ self failures anySatisfy: [:testCase | testCase class == class and: [testCase selector == selector]]
]

{ #category : #testing }
TestResult >> isPassed: aTestCase [

	^self passed includes: aTestCase
			
]

{ #category : #querying }
TestResult >> isPassedFor: class selector: selector [
	^ self passed anySatisfy: [:testCase | testCase class == class and: [testCase selector == selector]]
]

{ #category : #compatibility }
TestResult >> passed [
	^ self expectedPasses, self expectedDefects
]

{ #category : #accessing }
TestResult >> passedCount [

	^self passed size
			
]

{ #category : #printing }
TestResult >> printOn: aStream [
	aStream
		nextPutAll: self runCount printString;
		nextPutAll: ' run in ';
		nextPutAll: (Duration milliSeconds: self duration) printString;
		nextPutAll: ', ';
		nextPutAll: self expectedPassCount printString;
		nextPutAll: ' passes, ';
		nextPutAll: self expectedDefectCount printString;
		nextPutAll:' expected failures, ';
		nextPutAll: self unexpectedFailureCount printString;
		nextPutAll: ' failures, ';
		nextPutAll: self unexpectedErrorCount printString;
		nextPutAll:' errors, ';
		nextPutAll: self unexpectedPassCount printString;
		nextPutAll:' unexpected passes'.
]

{ #category : #initialization }
TestResult >> resetErrors [
	"clear the errors list ready to re-run those tests"

	errors := OrderedCollection new
]

{ #category : #initialization }
TestResult >> resetFailures [
	"clear the failures list ready to re-run those tests"

	failures := Set new
]

{ #category : #running }
TestResult >> runCase: aTestCase [
	
	| testCasePassed timeToRun |
	testCasePassed := true.

	[timeToRun := [aTestCase runCase] timeToRunWithoutGC] 
		on: self class failure
		do: [:signal | 
				failures add: aTestCase.
				testCasePassed := false.
				signal return: false]
		on: self class error
		do: [:signal |
				errors add: aTestCase.
				testCasePassed := false.
				signal return: false].
			
	testCasePassed ifTrue: [passed add: aTestCase].
	self durations at: aTestCase put: timeToRun.
]

{ #category : #accessing }
TestResult >> runCount [
	^ passed size + failures size + errors size
]

{ #category : #history }
TestResult >> selectResultsForTestCase: aTestCaseClass [
	| passedSelectors errorsSelectors failuresSelectors testCaseDurations |
	
	passedSelectors := self passed
						select: [:testCase | testCase class == aTestCaseClass ] thenCollect: [:testCase | testCase selector].
	errorsSelectors := self errors 
						select: [:testCase | testCase class == aTestCaseClass ] thenCollect:  [:testCase | testCase selector].
	failuresSelectors := self failures 
						select: [:testCase | testCase class == aTestCaseClass ] thenCollect:  [:testCase | testCase selector].

	testCaseDurations := Dictionary new.
	self durations keysAndValuesDo: [:testCase :milliseconds |
		testCase class == aTestCaseClass ifTrue: [testCaseDurations at: testCase selector put: milliseconds]].		

	^ self class newTestDictionary
		at: #timeStamp put: self timeStamp; "Keep this result's time stamp."
		at: #passed put: passedSelectors asSet;
		at: #failures put: failuresSelectors asSet;
		at: #errors put: errorsSelectors asSet;
		at: #durations put: testCaseDurations;
		at: #duration put: (testCaseDurations inject: 0 into: [:sum :each | sum + (each ifNil: [0])]);
		yourself
		
]

{ #category : #accessing }
TestResult >> tests [
	^(OrderedCollection new: self runCount)
		addAll: passed;
		addAll: failures;
		addAll: errors;
		yourself
]

{ #category : #accessing }
TestResult >> timeStamp [
	^ timeStamp
]

{ #category : #accessing }
TestResult >> timeStamp: anObject [
	timeStamp := anObject
]

{ #category : #accessing }
TestResult >> unexpectedErrorCount [
	^ self unexpectedErrors size
]

{ #category : #accessing }
TestResult >> unexpectedErrors [
	^ errors select: [:each | each shouldPass] 
]

{ #category : #accessing }
TestResult >> unexpectedFailureCount [
	^ self unexpectedFailures size
]

{ #category : #accessing }
TestResult >> unexpectedFailures [
	^ failures select: [:each | each shouldPass] 
]

{ #category : #accessing }
TestResult >> unexpectedPassCount [
	^ self unexpectedPasses size
]

{ #category : #accessing }
TestResult >> unexpectedPasses [
	^ passed select: [:each | each shouldPass not] 
]

{ #category : #history }
TestResult >> updateResultsInHistory [
	
	#(#passed #failures #errors) do: [ :status | 
		(self perform: status) do: [ :testCase | 
			self class updateTestHistoryFor: testCase status: status ] ]
]
