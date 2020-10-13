"
This class is intended for unit tests of individual classes and their metaclasses.

It provides methods to determine the coverage of the unit tests.

Subclasses are expected to re-implement #classesToBeTested and #selectorsToBeIgnored.

They should also implement to confirm that all methods have been tested.

#testCoverage

	super testCoverage.


"
Class {
	#name : #ClassTestCase,
	#superclass : #TestCase,
	#category : #'SUnit-Extensions'
}

{ #category : #Testing }
ClassTestCase class >> isAbstract [
	"Override to true if a TestCase subclass is Abstract and should not have
	TestCase instances built from it"

	^self name = #ClassTestCase
			
]

{ #category : #Testing }
ClassTestCase class >> mustTestCoverage [

	^ false
]

{ #category : #private }
ClassTestCase >> categoriesForClass: aClass [

 ^ aClass organization allMethodSelectors collect: 
			[:each |  aClass organization categoryOfElement: each].

]

{ #category : #coverage }
ClassTestCase >> classToBeTested [
	
	self subclassResponsibility
]

{ #category : #coverage }
ClassTestCase >> selectorsNotTested [

	^ self selectorsToBeTested difference: self selectorsTested.

]

{ #category : #coverage }
ClassTestCase >> selectorsTested [
	| literals |
	literals := Set new.
	self class
		selectorsAndMethodsDo: [ :s :m | (s beginsWith: 'test')
			ifTrue: [ literals addAll: (m messages)] ].
	^ literals sorted
]

{ #category : #coverage }
ClassTestCase >> selectorsToBeIgnored [
	^ #(#DoIt #DoItIn:)
]

{ #category : #coverage }
ClassTestCase >> selectorsToBeTested [

	^ ( { self classToBeTested. self classToBeTested class } gather: [:c | c selectors]) 
			difference: self selectorsToBeIgnored
]

{ #category : #private }
ClassTestCase >> targetClass [
  |className|

  className := self class name asText copyFrom: 0 to: self class name size - 4.
  ^ self class environment valueOf: (className asString asSymbol).

]

{ #category : #tests }
ClassTestCase >> testClassComment [
	self shouldnt: [self targetClass organization hasNoComment].
]

{ #category : #tests }
ClassTestCase >> testCoverage [

	| untested | 
	self class mustTestCoverage ifTrue:
		[ untested := self selectorsNotTested.
		self assert: untested isEmpty 
		description: untested size asString, ' selectors are not covered' ]
]

{ #category : #tests }
ClassTestCase >> testNew [
	"This should not throw an exception."
	self targetClass new.
]

{ #category : #tests }
ClassTestCase >> testUnCategorizedMethods [
	| categories slips uncategorisedMethods |
	categories := self categoriesForClass: self targetClass.
	slips := categories select: [:each | each = #'as yet unclassified'].
	
	uncategorisedMethods := self targetClass organization listAtCategoryNamed: #'as yet unclassified'.
	
	self assert: slips isEmpty description: ('{1} has uncategorised methods: {2}' format: {self targetClass. (uncategorisedMethods collect: #printString) asCommaString}).
]
