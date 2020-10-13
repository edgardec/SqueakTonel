"
This is a Composite of Tests, either TestCases or other TestSuites. The common protocol is #run: aTestResult and the dependencies protocol
"
Class {
	#name : #TestSuite,
	#superclass : #Object,
	#instVars : [
		'tests',
		'resources',
		'name'
	],
	#category : #'SUnit-Kernel'
}

{ #category : #'instance creation' }
TestSuite class >> named: aString [

	^self new
		name: aString;
		yourself
			
]

{ #category : #dependencies }
TestSuite >> addDependentToHierachy: anObject [
	self addDependent: anObject.
	self tests do: [ :each | each addDependentToHierachy: anObject]
			
]

{ #category : #accessing }
TestSuite >> addTest: aTest [
	self tests add: aTest
			
]

{ #category : #accessing }
TestSuite >> addTests: aCollection [ 
	aCollection do: [:eachTest | self addTest: eachTest]
			
]

{ #category : #running }
TestSuite >> debug [
	self tests do:
		[ : each | self changed: each.
		each debug ]
]

{ #category : #accessing }
TestSuite >> defaultResources [
	^self tests 
		inject: Set new
		into: [:coll :testCase | 
			coll
				addAll: testCase resources;
				yourself]
			
]

{ #category : #accessing }
TestSuite >> name [

	^name
			
]

{ #category : #accessing }
TestSuite >> name: aString [

	name := aString
			
]

{ #category : #dependencies }
TestSuite >> removeDependentFromHierachy: anObject [
	self removeDependent: anObject.
	self tests do: [ :each | each removeDependentFromHierachy: anObject]
			
]

{ #category : #accessing }
TestSuite >> resources [
	^ resources ifNil: [resources := self defaultResources]
			
]

{ #category : #accessing }
TestSuite >> resources: anObject [
	resources := anObject
			
]

{ #category : #private }
TestSuite >> resultClass [

	^ TestResult.
]

{ #category : #running }
TestSuite >> run [
	| result |
 	result := self resultClass new.
	self resources do: [ :res |
		res isAvailable ifFalse: [^res signalInitializationError]].
	[self run: result] ensure: [self resources do: [:each | each reset]].
	^result
			
]

{ #category : #running }
TestSuite >> run: aResult [ 
	self tests do: [:each | 
		self changed: each.
		each run: aResult].
			
]

{ #category : #accessing }
TestSuite >> tests [
	^ tests ifNil: [tests := OrderedCollection new]
			
]
