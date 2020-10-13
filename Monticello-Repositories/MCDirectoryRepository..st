Class {
	#name : #MCDirectoryRepository,
	#superclass : #MCFileBasedRepository,
	#instVars : [
		'directory'
	],
	#category : #'Monticello-Repositories'
}

{ #category : #configuring }
MCDirectoryRepository class >> creationTemplateLocation: location [ 
	^ self name , ' path: {1}' format: {location printString}
]

{ #category : #configuring }
MCDirectoryRepository class >> description [
	^ 'directory'
]

{ #category : #'instance creation' }
MCDirectoryRepository class >> directory: aFileDirectory [ 
	^ self new
		 directory: aFileDirectory ;
		 yourself
]

{ #category : #configuring }
MCDirectoryRepository class >> fillInTheBlankRequest [
	^ 'Directory Location:'
]

{ #category : #configuring }
MCDirectoryRepository class >> morphicConfigure [
	^ UIManager default chooseDirectory
		 ifNotNil: [:directory | self new directory: directory]
]

{ #category : #'instance creation' }
MCDirectoryRepository class >> path: fullyQualifiedName [ 
	^ self directory: (FileDirectory on: fullyQualifiedName)
]

{ #category : #accessing }
MCDirectoryRepository >> allFileNames [

	^directory entries 
		sort: [ :a :b | a modificationTime >= b modificationTime ];
		replace: [ :ea | ea name asMCVersionName ]
]

{ #category : #accessing }
MCDirectoryRepository >> creationTemplate [
	^ super creationTemplate
		ifNil:
			[ self creationTemplate: (self class creationTemplateLocation: self directory pathName).
			creationTemplate ]
]

{ #category : #'user interface' }
MCDirectoryRepository >> description [
	^ directory pathName
]

{ #category : #accessing }
MCDirectoryRepository >> directory [
	^ directory
]

{ #category : #accessing }
MCDirectoryRepository >> directory: aDirectory [
	directory := aDirectory
]

{ #category : #comparing }
MCDirectoryRepository >> hash [
	^ directory pathName hash
]

{ #category : #versions }
MCDirectoryRepository >> includesVersionNamed: aString [ 

	| comparable |
	comparable := ((aString endsWith: '.mcz') and: [ aString size > 4 ])
		ifTrue: [ aString allButLast: 4 ]
		ifFalse: [ aString ].
	allVersionNamesCache ifNil: [
		"Instead of reading the contents of the entire directory in #allVersionNames, look up a single .mcz file.
		 This is just an optimization. If the file does not exist, the version may still be there as an mcd."
		(directory fileExists: comparable, '.mcz') ifTrue: [ ^true ] ].
	^ self allVersionNames includes: comparable
]

{ #category : #'initialize-release' }
MCDirectoryRepository >> initialize [
	directory := FileDirectory default
]

{ #category : #testing }
MCDirectoryRepository >> isValid [
	^directory exists
]

{ #category : #private }
MCDirectoryRepository >> readStreamForFileNamed: aString do: aBlock [
	| file val |
	file := FileStream readOnlyFileNamed: (directory fullNameFor: aString).
	val := aBlock value: file.
	file close.
	^ val
]

{ #category : #private }
MCDirectoryRepository >> writeStreamForFileNamed: aString replace: aBoolean do: aBlock [
	| file sel |
	sel := aBoolean ifTrue: [#forceNewFileNamed:] ifFalse: [#newFileNamed:].
	file := FileStream perform: sel with: (directory fullNameFor: aString).
	aBlock value: file.
	file close.
]
