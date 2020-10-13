"
Signaled in case of a failed test (failure). The test framework distinguishes between failures and errors. A failure is anticipated and checked for with assertions. Errors are unanticipated problems like a division by 0 or an index out of bounds ...
"
Class {
	#name : #TestFailure,
	#superclass : #Exception,
	#category : #'SUnit-Kernel'
}

{ #category : #'camp smalltalk' }
TestFailure >> defaultAction [

	Processor activeProcess
		debug: self signalerContext
		title: self description
]

{ #category : #'camp smalltalk' }
TestFailure >> isResumable [
	
	^ false
]
