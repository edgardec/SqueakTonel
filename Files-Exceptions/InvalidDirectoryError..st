Class {
	#name : #InvalidDirectoryError,
	#superclass : #Error,
	#instVars : [
		'pathName'
	],
	#category : #'Files-Exceptions'
}

{ #category : #exceptionInstantiator }
InvalidDirectoryError class >> pathName: badPathName [
	^self new pathName: badPathName
]

{ #category : #handling }
InvalidDirectoryError >> defaultAction [
	"Return an empty list as the default action of signaling the occurance of an invalid directory."
	^#()
]

{ #category : #accessing }
InvalidDirectoryError >> pathName [
	^pathName
]

{ #category : #accessing }
InvalidDirectoryError >> pathName: badPathName [
	pathName := badPathName
]
