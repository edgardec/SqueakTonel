Class {
	#name : #UndefinedVariable,
	#superclass : #ParserNotification,
	#category : #'Compiler-Exceptions'
}

{ #category : #'as yet unclassified' }
UndefinedVariable >> openMenuIn: aBlock [

	^ self resume: (UIManager default
		confirm: name asText allBold, ' appears to be undefined at this point.\Proceed anyway?' withCRs
		title: 'Undefined Variable').
]
