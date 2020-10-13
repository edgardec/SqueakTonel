"
This is a base class that you can subclass if your package format can be downloaded using
a single file url and possibly also be decompressed using gzip.
"
Class {
	#name : #SMSimpleInstaller,
	#superclass : #SMInstaller,
	#instVars : [
		'fileName',
		'dir',
		'unpackedFileName'
	],
	#category : #'SMBase-installer'
}

{ #category : #testing }
SMSimpleInstaller class >> canInstall: aPackage [
	"Answer if this class can install the package.
	This class is abstract so we return false."

	^false
]

{ #category : #services }
SMSimpleInstaller >> cache [
	"Download object into cache if needed.
	Set the directory and fileName for subsequent unpacking and install."

	packageRelease ensureInCache ifTrue: [
		fileName := packageRelease downloadFileName.
		dir := packageRelease cacheDirectory]
]

{ #category : #accessing }
SMSimpleInstaller >> directory [
	^dir
]

{ #category : #services }
SMSimpleInstaller >> download [
	"This service downloads the last release of the package
	even if it is in the cache already."

	packageRelease download ifTrue: [
		fileName := packageRelease downloadFileName.
		dir := packageRelease cacheDirectory]
]

{ #category : #services }
SMSimpleInstaller >> fileIntoChangeSetNamed: aString fromStream: stream [
	"We let the user confirm filing into an existing ChangeSet
	or specify another ChangeSet name if
	the name derived from the filename already exists."
	
	| changeSet newName oldChanges global |
	newName := aString.
	changeSet := SMInstaller changeSetNamed: newName.
	changeSet ifNotNil: [
		newName := self silent ifNil: [UIManager default
									request: 'ChangeSet already present, just confirm to overwrite or enter a new name:' 
									initialAnswer: newName]
						ifNotNil: [newName].
		newName isEmpty ifTrue:[self error: 'Cancelled by user'].
		changeSet := SMInstaller changeSetNamed: newName].
		changeSet ifNil:[changeSet := SMInstaller basicNewChangeSet: newName].
		changeSet ifNil:[self error: 'User did not specify a valid ChangeSet name'].
		oldChanges := (SystemVersion current highestUpdate < 5302)
						ifFalse: [global := ChangeSet. ChangeSet current]
						ifTrue: [global := Smalltalk. Smalltalk changes].
 		[global newChanges: changeSet.
		stream fileInAnnouncing: 'Loading ', newName, ' into change set ''', newName, ''''.
		stream close] ensure: [global newChanges: oldChanges]
]

{ #category : #accessing }
SMSimpleInstaller >> fileName [
	^fileName
]

{ #category : #accessing }
SMSimpleInstaller >> fileName: aFileName [
	fileName := aFileName
]

{ #category : #accessing }
SMSimpleInstaller >> fullFileName [ 
	^ self directory fullNameFor: self fileName
]

{ #category : #services }
SMSimpleInstaller >> unpack [
	"This basic installer simply checks the file extension of
	the downloaded file to choose suitable method for unpacking.
	Currently it only supports .gz decompression.
	If a file exists with the same name it is first deleted.
	The unpacked filename is set on succesfull decompression or
	if the file was not recognized as a compressed file."

	| unzipped zipped buffer |
	(fileName endsWith: '.gz')
		ifTrue:[
			unpackedFileName := fileName copyUpToLast: FileDirectory extensionDelimiter.
			(dir fileExists: unpackedFileName) ifTrue:[ dir deleteFileNamed: unpackedFileName ].
			unzipped := dir newFileNamed: unpackedFileName.
			unzipped binary.
			zipped := GZipReadStream on: ((dir readOnlyFileNamed: fileName) binary; yourself).
			buffer := ByteArray new: 50000.
			'Extracting ' , fileName
				displayProgressFrom: 0
				to: zipped sourceStream size
				during: [:bar | 
					[zipped atEnd]
						whileFalse: 
							[bar value: zipped sourceStream position.
							unzipped nextPutAll: (zipped nextInto: buffer)].
					zipped close.
					unzipped close]]
		ifFalse:[unpackedFileName := fileName]
]

{ #category : #accessing }
SMSimpleInstaller >> unpackedFileName [
	^unpackedFileName
]
