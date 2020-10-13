"
I represent imported resources such as images, sounds, and other kind of files. 
For now I only store images in a simple way. 

To access my default instance use: Imports default. However I'm not a strict singleton
and clients may create several of me using new. 
"
Class {
	#name : #Imports,
	#superclass : #Object,
	#instVars : [
		'imports'
	],
	#classInstVars : [
		'default'
	],
	#category : #'System-Support'
}

{ #category : #'instance creation' }
Imports class >> default [
	"Answer my default instance, creating one if necessary."
	"Imports default"
	^default ifNil: [ default := self new ]
]

{ #category : #'instance creation' }
Imports class >> default: anImports [
	"Set my default instance. Returns the old value if any."
	| old |
	old := default.
	default := anImports.
	^old
]

{ #category : #images }
Imports >> images [
	"returns all the imported images"

	^ imports values

	
]

{ #category : #images }
Imports >> importImage: anImage named: aName [ 
	imports
		at: (Utilities
				keyLike: aName
				satisfying: [:ea | (imports includesKey: ea) not])
		put: anImage
]

{ #category : #icons }
Imports >> importImageDirectory: directoryOrName [ 
	| dir extensions forms |
	dir := directoryOrName isString
		ifFalse: [ directoryOrName ]
		ifTrue: [ FileDirectory default directoryNamed: directoryOrName ].
	dir exists
		ifFalse: [self error: dir fullName , ' does not exist'. ^ #()].
	extensions := (ImageReadWriter allTypicalFileExtensions add: 'form';
				 yourself)
				collect: [:ex | '.' , ex].
	forms := OrderedCollection new.
	dir fileNames
		do: [:fileName | | fullName | (fileName endsWithAnyOf: extensions)
				ifTrue: [fullName := dir fullNameFor: fileName.
					(self importImageFromFileNamed: fullName)
						ifNotNil: [:form | forms add: form]]].
	^ forms
]

{ #category : #icons }
Imports >> importImageDirectoryWithSubdirectories: directoryOrName [ 
	| dir forms |
	dir := directoryOrName isString
		ifFalse: [ directoryOrName ]
		ifTrue: [ FileDirectory default directoryNamed: directoryOrName ].
	dir exists
		ifFalse: [self error: dir fullName , ' does not exist'. ^ #()].
	forms := OrderedCollection new.
	dir withAllSubdirectoriesCollect: [ :subdir | forms addAll: (self importImageDirectory: dir) ].
	^ forms
]

{ #category : #icons }
Imports >> importImageFromFileNamed: fullName [ 
	| localName pathParts form imageName |
	FileDirectory
		splitName: fullName
		to: [:dirPath :lname | 
			localName := lname.
			pathParts := dirPath findTokens: FileDirectory slash].
	form := [Form fromFileNamed: fullName]
				on: Error
				do: [:ex | ex return: nil].
	form
		ifNil: [^ nil].
	imageName := FileDirectory baseNameFor: localName.
	[imports includesKey: imageName]
		whileTrue: [imageName := pathParts isEmpty
						ifTrue: [Utilities
								keyLike: imageName
								satisfying: [:ea | (imports includesKey: ea) not]]
						ifFalse: [pathParts removeLast , '-' , imageName]].
	imports at: imageName put: form.
	^ form
]

{ #category : #images }
Imports >> imports [

	^ imports

]

{ #category : #initialize }
Imports >> initialize [

	imports := Dictionary new.
]

{ #category : #images }
Imports >> namesAndImagesDo: aBlock [
	"iterate over all the names and image"

	^ imports keysAndValuesDo: aBlock

	
]

{ #category : #images }
Imports >> viewImages [
	"Open up a special Form inspector on the dictionary of graphical imports."
	"Imports default viewImages"

	imports size isZero ifTrue:
		[^ self inform: 
'The ImageImports repository is currently empty,
so there is nothing to view at this time.  You can
use a file list to import graphics from external files
into Imports, and once you have done that,
you will find this command more interesting.'].
	
	Project current formViewClass openOn:  imports withLabel: 'Graphical Imports'


]
