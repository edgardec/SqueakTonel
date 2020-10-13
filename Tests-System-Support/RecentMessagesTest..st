Class {
	#name : #RecentMessagesTest,
	#superclass : #TestCase,
	#instVars : [
		'rm',
		'env'
	],
	#category : #'Tests-System-Support'
}

{ #category : #private }
RecentMessagesTest >> createClass: aSymbol [
	| builder |
	builder := ClassBuilder new.
	builder
		name: aSymbol
		inEnvironment: env
		subclassOf: Object
		type: #normal
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: 'Test'.
	^ env at: aSymbol.
]

{ #category : #private }
RecentMessagesTest >> performTest [

	Utilities
		useAuthorInitials: self className
		during: [ super performTest ]
]

{ #category : #running }
RecentMessagesTest >> setUp [
	rm := RecentMessages new.
	env := Environment withName: 'EnvironmentForRecentMessagesTest'.
	env at: #FakeObjectOut put: FakeObjectOut new.
]

{ #category : #running }
RecentMessagesTest >> tearDown [
	env destroy.
	env := nil
]

{ #category : #tests }
RecentMessagesTest >> testIsEmpty [
	self assert: rm isEmpty description: 'Initially, must be empty'.
	rm recordSelector: #foo forClass: Utilities inEnvironment: Smalltalk globals.
	self deny: rm isEmpty description: 'After submission, must not be empty'.
]

{ #category : #tests }
RecentMessagesTest >> testMaximumSubmissionCountCanReduceNumberOfReferences [
	rm maximumSubmissionCount: 2.
	rm recordSelector: #foo forClass: Utilities inEnvironment: Smalltalk globals.
	rm recordSelector: #bar forClass: Utilities inEnvironment: Smalltalk globals.
	rm maximumSubmissionCount: 1.
	self assert: 1 equals: rm size.
]

{ #category : #tests }
RecentMessagesTest >> testMaximumSubmissionCountCapsReferenceCount [
	rm maximumSubmissionCount: 2.
	rm recordSelector: #foo forClass: Utilities inEnvironment: Smalltalk globals.
	rm recordSelector: #bar forClass: Utilities inEnvironment: Smalltalk globals.
	rm recordSelector: #baz forClass: Utilities inEnvironment: Smalltalk globals.
	self assert: #bar equals: rm leastRecent selector.
]

{ #category : #tests }
RecentMessagesTest >> testMaximumSubmissionCountDefaultsToTen [
	self assert: 30 equals: rm maximumSubmissionCount.
]

{ #category : #tests }
RecentMessagesTest >> testMaximumSubmissionCountReturnsMaximumNumberOfRecordedMethodSubmissions [
	rm maximumSubmissionCount: 0.
	self assert: 0 equals: rm maximumSubmissionCount.
	rm maximumSubmissionCount: 1.
	self assert: 1 equals: rm maximumSubmissionCount.
]

{ #category : #tests }
RecentMessagesTest >> testMethodReferencesReturnsAllSubmissions [
	| expected |
	expected := {
		MethodReference class: Utilities selector: #bar environment: env.
		MethodReference class: Utilities selector: #foo environment: env }.
	rm recordSelector: #foo forClass: Utilities inEnvironment: env.
	rm recordSelector: #bar forClass: Utilities inEnvironment: env.
	self assert: expected equals: rm methodReferences
]

{ #category : #tests }
RecentMessagesTest >> testMethodReferencesReturnsaCopy [
	| expected original |
	rm recordSelector: #foo forClass: Utilities inEnvironment: env.
	original := rm methodReferences.
	expected := original copy.
	rm recordSelector: #bar forClass: Utilities inEnvironment: env.
	self assert: expected equals: original.
]

{ #category : #tests }
RecentMessagesTest >> testMostRecentReturnsLastAddedReference [
	| victim |
	victim := self createClass: #Victim.
	victim compile: 'foo ^ 1'.
	victim compile: 'bar ^ 1'.
	rm recordSelector: #foo forClass: victim inEnvironment: env.
	self assert: #foo equals: rm mostRecent selector.
	rm recordSelector: #bar forClass: victim inEnvironment: env.
	self assert: #bar equals: rm mostRecent selector.
]

{ #category : #tests }
RecentMessagesTest >> testMostRecentReturnsRemovedReference [
	| victim |
	victim := self createClass: #Victim.
	victim compile: 'foo ^ 1'.
	victim compile: 'bar ^ 1'.
	rm recordSelector: #foo forClass: victim inEnvironment: env.
	rm recordSelector: #bar forClass: victim inEnvironment: env.
	victim removeSelector: #bar.
	self assert: #bar equals: rm mostRecent selector.
]

{ #category : #tests }
RecentMessagesTest >> testOldestReturnsOldestSubmission [
	self assert: nil equals: rm leastRecent description: 'Return nil if no submissions yet'.
	rm recordSelector: #foo forClass: Utilities inEnvironment: Smalltalk globals.
	self assert: #foo equals: rm leastRecent selector.
	rm recordSelector: #baz forClass: Utilities inEnvironment: Smalltalk globals.
	self assert: #foo equals: rm leastRecent selector.
]

{ #category : #tests }
RecentMessagesTest >> testPurgeMissingMethodsKeepsComments [
	rm recordSelector: #Comment forClass: Utilities inEnvironment: Smalltalk globals.
	self deny: rm isEmpty.
]

{ #category : #tests }
RecentMessagesTest >> testReferencesAreUnique [
	rm recordSelector: #foo forClass: Utilities inEnvironment: Smalltalk globals.
	rm recordSelector: #foo forClass: Utilities inEnvironment: Smalltalk globals.
	self assert: 1 equals: rm size description: 'After duplicate'.
]

{ #category : #tests }
RecentMessagesTest >> testRevertMostRecentRemovesLatestVersion [
	| victim |
	victim := self createClass: #Victim.
	victim compile: 'foo ^ 1'.
	victim compile: 'foo ^ 2'.
	rm recordSelector: #foo forClass: victim inEnvironment: env.
	rm revertMostRecent.
	self assert: 1 equals: victim new foo description: 'Version not removed'.
]

{ #category : #tests }
RecentMessagesTest >> testRevertMostRecentRemovesNewMethod [
	| victim |
	victim := self createClass: #Victim.
	victim compile: 'foo ^ 1'.
	rm recordSelector: #foo forClass: victim inEnvironment: env.
	rm revertMostRecent.
	self deny: (victim includesSelector: #foo) description: 'Method not removed'.
]

{ #category : #tests }
RecentMessagesTest >> testSizeReturnsNumberOfRecordedMethodSubmissions [
	self assert: 0 equals: rm size description: 'Initial state'.
	rm recordSelector: #foo forClass: Utilities inEnvironment: Smalltalk globals.
	self assert: 1 equals: rm size description: 'After 1 submission'.
	rm recordSelector: #bar forClass: Utilities inEnvironment: Smalltalk globals.
	self assert: 2 equals: rm size description: 'After 2 submissions'.
]

{ #category : #tests }
RecentMessagesTest >> testSubmissionClassControlsLogging [
	WantsChangeSetLogging yes.
	rm recordSelector: #foo forClass: WantsChangeSetLogging inEnvironment: Smalltalk globals.
	WantsChangeSetLogging no.
	rm recordSelector: #bar forClass: WantsChangeSetLogging inEnvironment: Smalltalk globals.
	self assert: 1 equals: rm size description: 'Class asked for logging not to happen'.
]
