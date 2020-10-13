"
A NarrowerVariableScopeFinder is used to find a smaller scope for an already declared variable.
"
Class {
	#name : #NarrowerVariableScopeFinder,
	#superclass : #VariableScopeFinder,
	#category : #'Compiler-Support'
}

{ #category : #visiting }
NarrowerVariableScopeFinder >> visitTempVariableNode: aVariableNode [
	^theVariable = aVariableNode ifTrue: [theVariable]
]

{ #category : #visiting }
NarrowerVariableScopeFinder >> visitUndeclaredVariableNode: aVariableNode [
	^nil
]
