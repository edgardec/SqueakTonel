Class {
	#name : #LongTestCaseTest,
	#superclass : #TestCase,
	#instVars : [
		'preferenceValue'
	],
	#category : #'SUnit-Extensions'
}

{ #category : #running }
LongTestCaseTest >> setUp [

	preferenceValue := LongTestCase shouldRun
]

{ #category : #running }
LongTestCaseTest >> tearDown [

	LongTestCase shouldRun: preferenceValue
]

{ #category : #tests }
LongTestCaseTest >> testLongTestCaseDoNotRun [
	"self debug: #testLongTestCaseDoNotRun"
	"self run: #testLongTestCaseDoNotRun"

	LongTestCase doNotRunLongTestCases.
	LongTestCaseTestUnderTest markAsNotRun.
	self deny: LongTestCaseTestUnderTest hasRun.
	LongTestCaseTestUnderTest suite run.
	self deny: LongTestCaseTestUnderTest hasRun.


	
]

{ #category : #tests }
LongTestCaseTest >> testLongTestCaseRun [
	"self debug: #testLongTestCaseRun"
	"self run: #testLongTestCaseRun"

	LongTestCase runLongTestCases.
	LongTestCaseTestUnderTest markAsNotRun.
	self deny: LongTestCaseTestUnderTest hasRun.
	LongTestCaseTestUnderTest suite run.
	self assert: LongTestCaseTestUnderTest hasRun.
	LongTestCase doNotRunLongTestCases.

	
]
