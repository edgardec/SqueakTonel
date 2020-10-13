Class {
	#name : #ClassFactoryForTestCaseTest,
	#superclass : #TestCase,
	#instVars : [
		'factory'
	],
	#category : #'SUnit-Tests'
}

{ #category : #history }
ClassFactoryForTestCaseTest class >> lastStoredRun [
	^ ((Dictionary new) add: (#passed->((Set new) add: #testDefaultCategoryCleanUp; add: #testPackageCleanUp; add: #testSingleClassCreation; add: #testClassCreationInDifferentCategories; add: #testClassFastCreationInDifferentCategories; add: #testMultipleClassCreation; add: #testSingleClassFastCreation; yourself)); add: (#timeStamp->'22 November 2008 10:11:35 pm'); add: (#failures->((Set new))); add: (#errors->((Set new))); yourself)
]

{ #category : #running }
ClassFactoryForTestCaseTest >> setUp [
	super setUp.
	factory := ClassFactoryForTestCase new
]

{ #category : #running }
ClassFactoryForTestCaseTest >> tearDown [
	super tearDown.
	factory cleanUp
]

{ #category : #tests }
ClassFactoryForTestCaseTest >> testClassCreationInDifferentCategories [
	| firstThreeClasses lastTwoClasses |
	3 timesRepeat: [
		factory newSubclassOf: Object instanceVariableNames: '' classVariableNames: '' category: #One].
	firstThreeClasses := factory createdClasses copy.
	2 timesRepeat: [
		factory newSubclassOf: Object instanceVariableNames: '' classVariableNames: '' category: #Two].
	lastTwoClasses := factory createdClasses copyWithoutAll: firstThreeClasses.
	self assert: (firstThreeClasses allSatisfy: [:class| class category = (factory packageName, '-', #One) asSymbol]).
	self assert: (lastTwoClasses allSatisfy: [:class| class category = (factory packageName, '-', #Two) asSymbol]).
]

{ #category : #tests }
ClassFactoryForTestCaseTest >> testClassFastCreationInDifferentCategories [
	| firstThreeClasses lastTwoClasses |
	3 timesRepeat: [
		factory newClassInCategory: #One].
	firstThreeClasses := factory createdClasses copy.
	2 timesRepeat: [
		factory newClassInCategory: #Two].
	lastTwoClasses := factory createdClasses copyWithoutAll: firstThreeClasses.
	self assert: (firstThreeClasses allSatisfy: [:class| class category = (factory packageName, '-', #One) asSymbol]).
	self assert: (lastTwoClasses allSatisfy: [:class| class category = (factory packageName, '-', #Two) asSymbol]).
]

{ #category : #tests }
ClassFactoryForTestCaseTest >> testDefaultCategoryCleanUp [
	| createdClassNames allClasses |
	3 timesRepeat: [
		factory newClass].
	createdClassNames := factory createdClassNames.
	factory cleanUp.	
	self assert: (factory createdClasses allSatisfy: [:class| class isObsolete]). 
	allClasses := SystemNavigation new allClasses.
	self assert: (factory createdClasses noneSatisfy: [:class| allClasses includes: class]).
	self deny: (SystemOrganization categories includes: factory defaultCategory). 
	self deny: (ChangeSet current changedClassNames includesAnyOf: createdClassNames)

]

{ #category : #tests }
ClassFactoryForTestCaseTest >> testMultipleClassCreation [
	5 timesRepeat: [
		factory newClass].
	self assert: (SystemNavigation new allClasses includesAllOf: factory createdClasses).
	self assert: factory createdClassNames asSet size = 5.
	self assert: (SystemOrganization listAtCategoryNamed: factory defaultCategory) asSet = factory createdClassNames asSet
]

{ #category : #tests }
ClassFactoryForTestCaseTest >> testPackageCleanUp [
	| createdClassNames allClasses |
	3 timesRepeat: [
		factory newClassInCategory: #One].
	2 timesRepeat: [
		factory newClassInCategory: #Two].
	createdClassNames := factory createdClassNames.
	factory cleanUp.	
	self assert: (factory createdClasses allSatisfy: [:class| class isObsolete]). 
	allClasses := SystemNavigation new allClasses.
	self assert: (factory createdClasses noneSatisfy: [:class| allClasses includes: class]).
	self assert: (SystemOrganization categoriesMatching: factory packageName, '*') isEmpty. 
	self deny: (ChangeSet current changedClassNames includesAnyOf: createdClassNames)

]

{ #category : #tests }
ClassFactoryForTestCaseTest >> testSingleClassCreation [
	|class elementsInCategoryForTest |
	class := factory 
		newSubclassOf: Object 
		instanceVariableNames: 'a b c' 
		classVariableNames: 'X Y'.
	self assert: (SystemNavigation new allClasses includes: class).
	elementsInCategoryForTest := SystemOrganization listAtCategoryNamed: factory defaultCategory. 
	self assert: elementsInCategoryForTest = {class name}.
	self assert: class instVarNames = #(a b c).
	self assert: class classPool keys asSet = #(X Y) asSet
]

{ #category : #tests }
ClassFactoryForTestCaseTest >> testSingleClassFastCreation [
	|class elementsInCategoryForTest |
	class := factory newClass.
	self assert: (SystemNavigation new allClasses includes: class).
	elementsInCategoryForTest := SystemOrganization listAtCategoryNamed: factory defaultCategory. 
	self assert: elementsInCategoryForTest = {class name}.
	self assert: class instVarNames isEmpty.
	self assert: class classPool isEmpty
]
