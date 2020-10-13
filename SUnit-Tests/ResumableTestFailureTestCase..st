Class {
	#name : #ResumableTestFailureTestCase,
	#superclass : #TestCase,
	#category : #'SUnit-Tests'
}

{ #category : #history }
ResumableTestFailureTestCase class >> lastStoredRun [
	^ ((Dictionary new) add: (#passed->((Set new) add: #testResumable; yourself)); add: (#timeStamp->'22 November 2008 10:11:35 pm'); add: (#failures->((Set new))); add: (#errors->((Set new))); yourself)
]

{ #category : #data }
ResumableTestFailureTestCase >> errorTest [
	1 zork
			
]

{ #category : #data }
ResumableTestFailureTestCase >> failureTest [
	self
		assert: false description: 'You should see me' resumable: true; 
		assert: false description: 'You should see me too' resumable: true; 
		assert: false description: 'You should see me last' resumable: false; 
		assert: false description: 'You should not see me' resumable: true
			
]

{ #category : #data }
ResumableTestFailureTestCase >> okTest [
	self assert: true
			
]

{ #category : #data }
ResumableTestFailureTestCase >> regularTestFailureTest [
	self assert: false description: 'You should see me'
			
]

{ #category : #data }
ResumableTestFailureTestCase >> resumableTestFailureTest [
	self
		assert: false description: 'You should see me' resumable: true; 
		assert: false description: 'You should see me too' resumable: true; 
		assert: false description: 'You should see me last' resumable: false; 
		assert: false description: 'You should not see me' resumable: true
			
]

{ #category : #tests }
ResumableTestFailureTestCase >> testResumable [
	| result suite |
	suite := TestSuite new.
	suite addTest: (self class selector: #errorTest).
	suite addTest: (self class selector: #regularTestFailureTest).
	suite addTest: (self class selector: #resumableTestFailureTest).
	suite addTest: (self class selector: #okTest).
	result := suite run.
	self assert: result failures size = 2;
		assert: result errors size = 1
			
]
