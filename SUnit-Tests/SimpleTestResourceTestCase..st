Class {
	#name : #SimpleTestResourceTestCase,
	#superclass : #TestCase,
	#instVars : [
		'resource'
	],
	#category : #'SUnit-Tests'
}

{ #category : #history }
SimpleTestResourceTestCase class >> lastStoredRun [
	^ ((Dictionary new) add: (#passed->((Set new) add: #testResourceInitRelease; add: #testResourcesCollection; add: #testRan; yourself)); add: (#timeStamp->'22 November 2008 10:11:35 pm'); add: (#failures->((Set new))); add: (#errors->((Set new))); yourself)
]

{ #category : #'not categorized' }
SimpleTestResourceTestCase class >> resources [
	^Set new add: SimpleTestResource; yourself
			
]

{ #category : #private }
SimpleTestResourceTestCase >> dummy [
	self assert: true
			
]

{ #category : #extensions }
SimpleTestResourceTestCase >> error [
	'foo' odd
			
]

{ #category : #extensions }
SimpleTestResourceTestCase >> fail [
	self assert: false
			
]

{ #category : #extensions }
SimpleTestResourceTestCase >> setRun [
	resource setRun
			
]

{ #category : #running }
SimpleTestResourceTestCase >> setUp [
	resource := SimpleTestResource current
			
]

{ #category : #tests }
SimpleTestResourceTestCase >> testRan [
	| case |

	case := self class selector: #setRun.
	case run.
	self assert: resource hasSetup.
	self assert: resource hasRun
			
]

{ #category : #tests }
SimpleTestResourceTestCase >> testResourceInitRelease [
	| result suite error failure |
	suite := TestSuite new.
	suite addTest: (error := self class selector: #error).
	suite addTest: (failure := self class selector: #fail).
	suite addTest: (self class selector: #dummy).
	result := suite run.
	self assert: resource hasSetup
			
]

{ #category : #tests }
SimpleTestResourceTestCase >> testResourcesCollection [
	| collection |
	collection := self resources.
	self assert: collection size = 1
			
]
