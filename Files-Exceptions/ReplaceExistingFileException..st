Class {
	#name : #ReplaceExistingFileException,
	#superclass : #FileStreamException,
	#instVars : [
		'fileClass'
	],
	#category : #'Files-Exceptions'
}

{ #category : #exceptionDescription }
ReplaceExistingFileException >> messageText [
	^ fileName , ' already exists'.
]
