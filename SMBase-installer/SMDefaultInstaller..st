"
An installer takes care of installing SqueakMap packages represented by SMCards.
This installer handles packages that consist of classical fileins (single changesets and .st-files) and optional gzip-decompression of those. Deciding if a package is installable and instantiating the correct installer class is done on the class side in SMInstaller, to see how this installer gets chosen - see SMDefaultInstaller class>>canInstall:.


"
Class {
	#name : #SMDefaultInstaller,
	#superclass : #SMSimpleInstaller,
	#category : #'SMBase-installer'
}

{ #category : #testing }
SMDefaultInstaller class >> canInstall: aPackage [
	"Answer if this class can install/upgrade the package.
	This installer handles .st, .cs, .mst, .mcs (Squeak 3.9+)
	with or without .gz suffix."

	| fileName |
	fileName := aPackage downloadFileName.
	fileName ifNil: [^false].
	fileName := fileName asLowercase.
	^self sourceFileSuffixes anySatisfy: [:each | 
			(fileName endsWith: (FileDirectory dot, each)) or: [
				fileName endsWith: (FileDirectory dot, each, '.gz')]]
]

{ #category : #private }
SMDefaultInstaller class >> multiSuffixes [
	"Unfortunately we can not tell which suffixes use multibyte encoding.
	So we guess that they begin with $m."

	^self sourceFileSuffixes select: [:suff | suff first = $m]
]

{ #category : #private }
SMDefaultInstaller class >> nonMultiSuffixes [
	"Unfortunately we can not tell which suffixes use multibyte encoding.
	So we guess that they begin with $m."

	^self sourceFileSuffixes reject: [:suff | suff first = $m]
]

{ #category : #private }
SMDefaultInstaller class >> sourceFileSuffixes [
	"Trying to play nice with all Squeak versions."

	^(FileStream respondsTo: #sourceFileSuffixes)
			ifTrue: [FileStream sourceFileSuffixes]
			ifFalse: [#(cs st)].
]

{ #category : #private }
SMDefaultInstaller >> fileIn [
	"Installing in the standard installer is simply filing in.
	Both .st and .cs files will file into a ChangeSet of their own.
	We let the user confirm filing into an existing ChangeSet
	or specify another ChangeSet name if
	the name derived from the filename already exists."
	
	| fileStream |
	(self class nonMultiSuffixes anySatisfy: [:each | unpackedFileName endsWith: (FileDirectory dot, each)])
		ifTrue:[
			fileStream := dir readOnlyFileNamed: unpackedFileName.
			(fileStream respondsTo: #setConverterForCode) ifTrue: [fileStream setConverterForCode].
			self fileIntoChangeSetNamed: (fileStream localName sansPeriodSuffix) fromStream: fileStream.
			^self].
	(self class multiSuffixes anySatisfy: [:each | unpackedFileName endsWith: (FileDirectory dot, each)])
		ifTrue:[
			fileStream := dir readOnlyFileNamed: unpackedFileName.
			"Only images with converters should have multi suffixes"
			fileStream converter: (Smalltalk at: #UTF8TextConverter) new.
			self fileIntoChangeSetNamed: (fileStream localName sansPeriodSuffix) fromStream: fileStream.
			^self].
	self error: 'Filename should end with a proper extension'.

]

{ #category : #services }
SMDefaultInstaller >> install [
	"This service should bring the package to the client,
	unpack it if necessary and install it into the image.
	The package is notified of the installation."

	self cache; unpack; fileIn.
	packageRelease noteInstalled

]
