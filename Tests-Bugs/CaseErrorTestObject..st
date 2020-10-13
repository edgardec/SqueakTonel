Class {
	#name : #CaseErrorTestObject,
	#superclass : #Object,
	#category : #'Tests-Bugs'
}

{ #category : #printing }
CaseErrorTestObject >> printOn: aStream [
	3 caseOf: 
		{ [1] -> [aStream nextPutAll: 'option 1'].
		[2] -> [aStream nextPutAll: 'option 2'] }
	"caseError in printOn:"
]
