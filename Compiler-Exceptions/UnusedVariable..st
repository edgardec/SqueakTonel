Class {
	#name : #UnusedVariable,
	#superclass : #ParserNotification,
	#category : #'Compiler-Exceptions'
}

{ #category : #handling }
UnusedVariable >> openMenuIn: aBlock [
	
	self resume: (UIManager default
		confirm: ('{1} appears to be unused in this method.\Remove it from the code?' withCRs translated
			format: {name asText allBold})
		orCancel: [nil]
		title: 'Unused Variable' translated).
]
