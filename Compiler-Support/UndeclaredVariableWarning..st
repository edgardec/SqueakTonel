Class {
	#name : #UndeclaredVariableWarning,
	#superclass : #Warning,
	#instVars : [
		'name',
		'selector',
		'class'
	],
	#category : #'Compiler-Support'
}

{ #category : #exceptionDescription }
UndeclaredVariableWarning >> defaultAction [
	"The user should be notified of the occurrence of an exceptional occurrence and
	 given an option of continuing or aborting the computation. The description of the
	 occurrence should include any text specified as the argument of the #signal: message."
	
	selector ifNotNil: [Transcript cr; nextPutAll: class name, '>>', selector, ' ']
			ifNil: [Transcript cr ].
	Transcript show: '(' , name , ' is Undeclared) '.
	^true
]

{ #category : #'initialize-release' }
UndeclaredVariableWarning >> defaultResumeValue [
	"Answer the value that by default should be returned if the exception is resumed"
	^true
]

{ #category : #'initialize-release' }
UndeclaredVariableWarning >> name: aString selector: aSymbolOrNil class: aBehavior [
	name := aString.
	selector := aSymbolOrNil.
	class := aBehavior
]
