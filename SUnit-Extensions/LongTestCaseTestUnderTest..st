Class {
	#name : #LongTestCaseTestUnderTest,
	#superclass : #LongTestCase,
	#classVars : [
		'RunStatus'
	],
	#category : #'SUnit-Extensions'
}

{ #category : #accessing }
LongTestCaseTestUnderTest class >> hasRun [

	^ RunStatus
]

{ #category : #accessing }
LongTestCaseTestUnderTest class >> markAsNotRun [

	^ RunStatus := false
]

{ #category : #tests }
LongTestCaseTestUnderTest >> testWhenRunMarkTestedToTrue [


	RunStatus := true.
]
