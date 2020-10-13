Class {
	#name : #FileDoesNotExistException,
	#superclass : #FileStreamException,
	#instVars : [
		'readOnly'
	],
	#category : #'Files-Exceptions'
}

{ #category : #examples }
FileDoesNotExistException class >> example [
	"FileDoesNotExistException example"

	| result |
	result := [(StandardFileStream readOnlyFileNamed: 'error42.log') contentsOfEntireFile]
		on: FileDoesNotExistException
		do: [:ex | 'No error log'].
	Transcript show: result; cr
]

{ #category : #accessing }
FileDoesNotExistException >> readOnly [
	^readOnly == true
]

{ #category : #accessing }
FileDoesNotExistException >> readOnly: aBoolean [
	readOnly := aBoolean
]
