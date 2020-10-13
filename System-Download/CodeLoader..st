"
CodeLoader provides a simple facility for loading code from the network.

CodeLoader has a very specific purpose, primarily for loading Etoys projects. It is not meant to be used for anything else. Use Installer for general purposes.

Examples:
	| loader |
	loader := CodeLoader new.
	loader baseURL:'http://isgwww.cs.uni-magdeburg.de/~raab/test/'.
	loader localCache: #('.cache' 'source').
	""Sources and segments can be loaded in parallel""
	loader loadSourceFiles: #('file1.st' 'file2.st.gz').
	loader localCache: #('.cache' 'segments').
	loader loadSegments: #('is1.extseg' 'is2.extseg.gz').
	""Install sources first - will wait until the files are actually loaded""
	loader installSourceFiles.
	""And then the segments""
	loader installSegments.
"
Class {
	#name : #CodeLoader,
	#superclass : #Object,
	#instVars : [
		'baseURL',
		'sourceFiles',
		'segments',
		'publicKey'
	],
	#classVars : [
		'DefaultBaseURL',
		'DefaultKey'
	],
	#category : #'System-Download'
}

{ #category : #utilities }
CodeLoader class >> compressFileNamed: aFileName [
	self compressFileNamed: aFileName in: FileDirectory default
]

{ #category : #utilities }
CodeLoader class >> compressFileNamed: aFileName in: aDirectory [
	"Compress the currently selected file"
	| zipped buffer unzipped zipFileName |
	unzipped := aDirectory readOnlyFileNamed: (aDirectory fullNameFor: aFileName).
	unzipped binary.
	zipFileName := aFileName copyUpToLast: $. .
	zipped := aDirectory newFileNamed: (zipFileName, FileDirectory dot, ImageSegment compressedFileExtension).
	zipped binary.
	zipped := GZipWriteStream on: zipped.
	buffer := ByteArray new: 50000.
	'Compressing ', zipFileName
		displayProgressFrom: 0 to: unzipped size
		during:[:bar|
			[unzipped atEnd] whileFalse:[
				bar value: unzipped position.
				zipped nextPutAll: (unzipped nextInto: buffer)].
			zipped close.
			unzipped close].

]

{ #category : #accessing }
CodeLoader class >> defaultBaseURL [
	^DefaultBaseURL ifNil: ['']
]

{ #category : #accessing }
CodeLoader class >> defaultBaseURL: aURLString [
	DefaultBaseURL := aURLString
]

{ #category : #accessing }
CodeLoader class >> defaultKey [
	"Return the default key used for verifying signatures of loaded code"
	^DefaultKey
]

{ #category : #accessing }
CodeLoader class >> defaultKey: aPublicKey [
	"Store the default key used for verifying signatures of loaded code"
	DefaultKey := aPublicKey
	"CodeLoader defaultKey: DOLPublicKey"
	"CodeLoader defaultKey: (DigitalSignatureAlgorithm testKeySet at: 2)"
]

{ #category : #utilities }
CodeLoader class >> exportCategories: catList to: aFileName [
	"CodeLoader exportCategories: #( 'Game-Animation' 'Game-Framework' ) to: 'Game-Framework'"

	| classList |
	classList := OrderedCollection new.
	catList do: [:catName |
		| list |
		list := SystemOrganization listAtCategoryNamed: catName asSymbol.
		list do: [:nm | classList add: (Smalltalk at: nm); add: (Smalltalk at: nm) class]].
	self exportCodeSegment: aFileName classes: classList keepSource: true
]

{ #category : #utilities }
CodeLoader class >> exportCategoryNamed: catName [
	"CodeLoader exportCategoryNamed: 'OceanicPanic' "

	| list |
	list := SystemOrganization listAtCategoryNamed: catName asSymbol.
	self exportClassesNamed: list to: catName
]

{ #category : #utilities }
CodeLoader class >> exportClassesNamed: classNameList to: aFileName [

	| classList |
	classList := OrderedCollection new.
	classNameList do: [:nm | classList add: (Smalltalk at: nm); add: (Smalltalk at: nm) class].
	self exportCodeSegment: aFileName classes: classList keepSource: true
]

{ #category : #utilities }
CodeLoader class >> exportCodeSegment: exportName classes: aClassList keepSource: keepSources [

	"Code for writing out a specific category of classes as an external image segment.  Perhaps this should be a method."

	| is oldMethods newMethods classList symbolHolder fileName |
	keepSources
		ifTrue: [
			self confirm: 'We are going to abandon sources.
Quit without saving after this has run.' orCancel: [^self]].

	classList := aClassList asArray.

	"Strong pointers to symbols"
	symbolHolder := Symbol allSymbols.

	oldMethods := OrderedCollection new: classList size * 150.
	newMethods := OrderedCollection new: classList size * 150.
	keepSources
		ifTrue: [
			classList do: [:cl |
				cl selectorsAndMethodsDo:
					[:selector :m |
					| oldCodeString methodNode |
					m fileIndex > 0 ifTrue:
						[oldCodeString := cl sourceCodeAt: selector.
						methodNode := cl newCompiler
											parse: oldCodeString in: cl notifying: nil.
						oldMethods addLast: m.
						newMethods addLast: (m copyWithTempsFromMethodNode: methodNode)]]]].
	oldMethods asArray elementsExchangeIdentityWith: newMethods asArray.
	oldMethods := newMethods := nil.

	Smalltalk garbageCollect.
	is := ImageSegment copyFromRootsForExport: classList.	"Classes and MetaClasses"

	fileName := FileDirectory fileName: exportName extension: ImageSegment fileExtension.
	is writeForExport: fileName.
	self compressFileNamed: fileName


]

{ #category : #utilities }
CodeLoader class >> loadCode: codeSegmentName from: baseURL ifClassNotLoaded: testClass [

	CodeLoader defaultBaseURL: baseURL.
	(Smalltalk includesKey: testClass)
		ifFalse: [CodeLoader loadCodeSegment: codeSegmentName].

]

{ #category : #utilities }
CodeLoader class >> loadCodeSegment: segmentName [
	| loader |
	loader := self new.
	loader loadSegments: (Array with: segmentName). 
	loader installSegments.
]

{ #category : #utilities }
CodeLoader class >> signFile: fileName renameAs: destFile key: privateKey dsa: dsa [
	"Sign the given file using the private key."
	| in out |
	in := FileStream readOnlyFileNamed: fileName.	in binary.
	out := FileStream newFileNamed: destFile.			out binary.
	[in atEnd] whileFalse:[out nextPutAll: (in next: 4096)].
	in close.	out close.
	FileDirectory activeDirectoryClass splitName: destFile to:[:path :file|
		SecurityManager default signFile: file directory: (FileDirectory on: path).
	].

]

{ #category : #utilities }
CodeLoader class >> signFiles: fileNames in: dirName key: privateKey [
	"Sign the files in the current directory and put them into a folder signed."

	|  newNames oldNames |
	oldNames := fileNames collect:[:fileName | dirName , FileDirectory slash, fileName].
	newNames := fileNames collect:[:fileName | dirName , FileDirectory slash, 'signed', FileDirectory slash, fileName].
	CodeLoader
		signFilesFrom: oldNames
		to: newNames
		key: privateKey
]

{ #category : #utilities }
CodeLoader class >> signFiles: fileNames key: privateKey [
	"Sign the files in the current directory and put them into a folder signed."

	|  newNames |
	newNames := fileNames collect:[:fileName | 'signed', FileDirectory slash, fileName].
	CodeLoader
		signFilesFrom: fileNames
		to: newNames
		key: privateKey
]

{ #category : #utilities }
CodeLoader class >> signFilesFrom: sourceNames to: destNames key: privateKey [
	"Sign all the given files using the private key.
	This will add an 's' to the extension of the file."
	"| fd oldNames newNames |
	fd := FileDirectory default directoryNamed:'unsigned'.
	oldNames := fd fileNames.
	newNames := oldNames collect:[:name| 'signed', FileDirectory slash, name].
	oldNames := oldNames collect:[:name| 'unsigned', FileDirectory slash, name].
	CodeLoader
		signFilesFrom: oldNames
		to: newNames
		key: DOLPrivateKey."
	| dsa |
	dsa := DigitalSignatureAlgorithm new.
	dsa initRandomNonInteractively.
	'Signing files...' 
		displayProgressFrom: 1 to: sourceNames size during:[:bar|
			1 to: sourceNames size do:[:i|
				bar value: i.
				self signFile: (sourceNames at: i) renameAs: (destNames at: i) key: privateKey dsa: dsa]].

]

{ #category : #utilities }
CodeLoader class >> verifySignedFileNamed: aFileName [
	"CodeLoader verifySignedFileNamed: 'signed\dummy1.dsq' "

	| secured signedFileStream |
	signedFileStream := FileStream fileNamed: aFileName.
	secured := SecurityManager default positionToSecureContentsOf: signedFileStream.
	signedFileStream close.
	Transcript show: aFileName , ' verified: '; show: secured printString; cr.


]

{ #category : #private }
CodeLoader >> allButShebangLine: contentsString [
	"If contentsString begins with '#!' then assume that it contains a Unix
	shebang line should be skipped prior to evaluating the contents."
	
	(contentsString beginsWith: '#!')
		ifTrue: [contentsString lineIndicesDo: [:line :end :endOfLine |
			^ contentsString allButFirst: endOfLine ]]
		ifFalse: [^ contentsString]

	" CodeLoader new allButShebangLine:
'#!/usr/llocal/bin/squeak --
Transcript cr; show: ''Hello world!''
' "
]

{ #category : #accessing }
CodeLoader >> baseURL [
	^baseURL
]

{ #category : #accessing }
CodeLoader >> baseURL: aString [
	baseURL := aString.
]

{ #category : #private }
CodeLoader >> createRequestFor: name in: aLoader [
	"Create a URL request for the given string, which can be cached locally."
	| request |
	request := HTTPLoader httpRequestClass for: self baseURL , name in: aLoader.
	aLoader addRequest: request. "fetch from URL"
	^request
]

{ #category : #private }
CodeLoader >> httpRequestClass [
	^HTTPDownloadRequest
]

{ #category : #'initialize-release' }
CodeLoader >> initialize [
	publicKey := DefaultKey.
	baseURL := self class defaultBaseURL
]

{ #category : #installing }
CodeLoader >> installProject [
	"Assume that we're loading a single file and it's a project"
	| aStream |
	aStream := sourceFiles first contentStream.
	aStream ifNil:[^self error:'Project was not loaded'].
	ProjectLoading openOn: aStream
]

{ #category : #installing }
CodeLoader >> installSegment: reqEntry [
	"Install the previously loaded segment"
	| contentStream contents trusted |
	contentStream := reqEntry value contentStream.
	contentStream ifNil:[^self error:'No content to install: ', reqEntry key printString].
	trusted := SecurityManager default positionToSecureContentsOf: contentStream.
	trusted ifFalse:[(SecurityManager default enterRestrictedMode) ifFalse:[
		contentStream close.
		^self error:'Insecure content encountered: ', reqEntry key printString]].
	contents := contentStream upToEnd unzipped asString.
	(contentStream respondsTo: #close) ifTrue:[contentStream close].
	^(RWBinaryOrTextStream with: contents) reset fileInObjectAndCode install.
]

{ #category : #installing }
CodeLoader >> installSegments [
	"Install the previously loaded segments"
	segments == nil ifTrue:[^self].
	segments do:[:req| self installSegment: req].
	segments := nil.
]

{ #category : #installing }
CodeLoader >> installSourceFile: aStream [
	"Install the previously loaded source file"
	| contents trusted |
	aStream ifNil:[^self error:'No content to install'].
	trusted := SecurityManager default positionToSecureContentsOf: aStream.
	trusted ifFalse:[(SecurityManager default enterRestrictedMode) 
					ifFalse:[ aStream close.
							^ self error:'Insecure content encountered']].
	contents := self allButShebangLine: aStream upToEnd unzipped asString.
	(aStream respondsTo: #close) ifTrue:[aStream close].
	^contents readStream fileIn
]

{ #category : #installing }
CodeLoader >> installSourceFiles [
	"Install the previously loaded source files"
	sourceFiles == nil ifTrue:[^self].
	sourceFiles do:[:req| self installSourceFile: req contentStream].
	sourceFiles := nil.
]

{ #category : #loading }
CodeLoader >> loadSegments: anArray [
	"Load all the source files in the given array."
	| loader |
	loader := HTTPLoader default.
	segments := anArray collect:[:name |
		| reqName request |
		reqName := (FileDirectory extensionFor: name) isEmpty
			ifTrue: [FileDirectory fileName: name extension: ImageSegment compressedFileExtension]
			ifFalse: [name].
		request := self createRequestFor: reqName in: loader.
		name->request].

]

{ #category : #loading }
CodeLoader >> loadSourceFiles: anArray [
	"Load all the source files in the given array."
	| loader |
	loader := HTTPLoader default.
	sourceFiles := anArray collect: [:name |
		self createRequestFor: name in: loader]
]

{ #category : #accessing }
CodeLoader >> publicKey [
	^publicKey
]

{ #category : #accessing }
CodeLoader >> publicKey: aPublicKey [
	publicKey := aPublicKey
]
