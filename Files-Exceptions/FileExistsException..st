Class {
	#name : #FileExistsException,
	#superclass : #FileStreamException,
	#instVars : [
		'fileClass'
	],
	#category : #'Files-Exceptions'
}

{ #category : #exceptionInstantiator }
FileExistsException class >> fileName: aFileName fileClass: aClass [ 
	^ self new
		fileName: aFileName;
		fileClass: aClass
]

{ #category : #accessing }
FileExistsException >> fileClass [
	^ fileClass ifNil: [StandardFileStream]
]

{ #category : #accessing }
FileExistsException >> fileClass: aClass [
	fileClass := aClass
]
