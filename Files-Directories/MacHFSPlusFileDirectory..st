Class {
	#name : #MacHFSPlusFileDirectory,
	#superclass : #MacFileDirectory,
	#category : #'Files-Directories'
}

{ #category : #'platform specific' }
MacHFSPlusFileDirectory class >> isActiveDirectoryClass [
	"Ok, lets see if we support HFS Plus file names, the long ones"

	^ (self pathNameDelimiter = self primPathNameDelimiter) and: [(Smalltalk  getSystemAttribute: 1201) notNil and: [(Smalltalk getSystemAttribute: 1201) asNumber > 31]]
]

{ #category : #'platform specific' }
MacHFSPlusFileDirectory class >> maxFileNameLength [

	^ 255
]
