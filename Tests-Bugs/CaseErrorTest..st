Class {
	#name : #CaseErrorTest,
	#superclass : #TestCase,
	#category : #'Tests-Bugs'
}

{ #category : #tests }
CaseErrorTest >> testCaseError [
	self
		should:
			[2 caseOf:
				{ [1] -> ['option 1'] }]
		raise: Error
]

{ #category : #tests }
CaseErrorTest >> testCaseErrorInPrintOn [
	self should: [ CaseErrorTestObject new printString ] raise: Error
]

{ #category : #tests }
CaseErrorTest >> testCaseErrorMessage [
	"Check whether the error message actually includes the printString of the object where #caseOf: is sent to. As of April 17, 2020, the error message actually uses the printString of the outer-contxt receiver, which is wrong. Take a look at Object >> #caseOf:. There is no indication of 'self' not being the receiver of #caseOf:."

	['my message' caseOf: { [1] -> ['option 1'] }]
		on: Error
		do: [:error | self assert: (error messageText includesSubstring: 'my message' printString)].
]
