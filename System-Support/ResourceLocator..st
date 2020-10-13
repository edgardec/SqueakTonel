"
Describes where a resource can be found.

Instance variables:
	urlString	<String> 	The URL of the resource
	fileSize		<Integer>	The size of the resource
	localFileName	<String>	When non-nil, the place where this resource was/is stored.
"
Class {
	#name : #ResourceLocator,
	#superclass : #Object,
	#instVars : [
		'urlString',
		'fileSize',
		'localFileName'
	],
	#category : #'System-Support'
}

{ #category : #utilities }
ResourceLocator class >> make: newURLString relativeTo: oldURLString [ 
	"Local file refs are not handled well, so work around here"
	^((oldURLString includesSubstring: '://') not
		and: [(newURLString includesSubstring: '://') not])
		ifTrue: [oldURLString , (UnixFileDirectory localNameFor: newURLString)]
		ifFalse: [(newURLString asUrlRelativeTo: oldURLString asUrl) asString]
]

{ #category : #comparing }
ResourceLocator >> = aLocator [

	^ self species == aLocator species and: [self urlString = aLocator urlString]

]

{ #category : #accessing }
ResourceLocator >> adjustToDownloadUrl: downloadUrl [
	"Adjust to the fully qualified URL for this resource."
	self urlString: (ResourceLocator make: self urlString relativeTo: downloadUrl) unescapePercents
]

{ #category : #accessing }
ResourceLocator >> adjustToRename: newName from: oldName [
	"Adjust to the fully qualified URL for this resource."
	self urlString: (self urlString copyReplaceAll: oldName with: newName)
]

{ #category : #testing }
ResourceLocator >> hasRemoteContents [
	"Return true if we describe a resource which is non-local, e.g., on some remote server."
	(urlString indexOf: $:) = 0 ifTrue:[^false]. "no scheme"
	^urlString asUrl hasRemoteContents
]

{ #category : #comparing }
ResourceLocator >> hash [
	^urlString hash
]

{ #category : #accessing }
ResourceLocator >> localFileName [
	^localFileName
]

{ #category : #accessing }
ResourceLocator >> localFileName: aString [
	localFileName := aString
]

{ #category : #printing }
ResourceLocator >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(;
		print: urlString;
		nextPut: $)
]

{ #category : #accessing }
ResourceLocator >> resourceFileSize [
	^fileSize
]

{ #category : #accessing }
ResourceLocator >> resourceFileSize: aNumber [
	fileSize := aNumber
]

{ #category : #comparing }
ResourceLocator >> species [
	^ResourceLocator
]

{ #category : #accessing }
ResourceLocator >> urlString [
	^urlString
]

{ #category : #accessing }
ResourceLocator >> urlString: aString [
	urlString := aString.
]
