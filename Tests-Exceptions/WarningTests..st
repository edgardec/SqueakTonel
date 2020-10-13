Class {
	#name : #WarningTests,
	#superclass : #TestCase,
	#category : #'Tests-Exceptions'
}

{ #category : #running }
WarningTests >> tearDown [

	Warning resetAllWarnings.
	super tearDown.
]

{ #category : #tests }
WarningTests >> test01Signal [

	self should: [Warning signal] raise: Warning.
]

{ #category : #tests }
WarningTests >> test02Resume [

	self
		assert: 42
		equals: ([Warning signal] on: Warning do: [:w | w resume: 42]).
]

{ #category : #tests }
WarningTests >> test03MessageText [

	self
		assert: 'Hello, World!'
		equals: ([Warning signal: 'Hello, World!'] on: Warning do: [:w | w messageText]).
]

{ #category : #tests }
WarningTests >> test04SuppressWarnings [

	self should: [Warning signal] raise: Warning.
	Warning suppressWarnings.
	self shouldnt: [Warning signal] raise: Warning.
]

{ #category : #tests }
WarningTests >> test05SuppressAndResetOnStartUp [

	self should: [Warning signal] raise: Warning.
	Warning suppressAndResetOnStartUp.
	self shouldnt: [Warning signal] raise: Warning.
	Warning startUp: true.
	self should: [Warning signal] raise: Warning.
]

{ #category : #tests }
WarningTests >> test06SuppressDeprecations [

	self should: [self deprecated] raise: Deprecation.
	Deprecation suppressWarnings.
	self shouldnt: [self deprecated] raise: Deprecation.
]
