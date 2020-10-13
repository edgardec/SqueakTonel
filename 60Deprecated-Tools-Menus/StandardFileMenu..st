"
Deprecated: please don't use this class. It provides a really unpleasant UI (after all it was based on java 'swing') that can be better done by using one of the concrete subclasses of FileAbstractSelectionDialog.

Obsoloete comment:
I represent a SelectionMenu which operates like a modal dialog for selecting files, somewhat similar to the StandardFile dialogs in MacOS and Java Swing.

Try for example, the following:

	StandardFileMenu oldFile inspect

	StandardFileMenu oldFileStream inspect

	StandardFileMenu newFile inspect

	StandardFileMenu newFileStream inspect
	
	(StandardFileMenu oldFileMenu: FileDirectory default withPattern: '*') startUpWithCaption: 'Select a file:'
	
	(StandardFileMenu oldFileMenu: (FileDirectory default) withPatternList: {'*.txt'. '*.changes'}) startUpWithCaption: 'Select a file:'

"
Class {
	#name : #StandardFileMenu,
	#superclass : #SelectionMenu,
	#instVars : [
		'canTypeFileName',
		'pattern'
	],
	#category : #'60Deprecated-Tools-Menus'
}

{ #category : #'standard file operations' }
StandardFileMenu class >> newFile [

	^self newFileFrom: (FileDirectory default)
]

{ #category : #'standard file operations' }
StandardFileMenu class >> newFileFrom: aDirectory [

	^(self newFileMenu: aDirectory)
		startUpWithCaption: 'Select a File:' translated
]

{ #category : #'instance creation' }
StandardFileMenu class >> newFileMenu: aDirectory [
	Smalltalk isMorphic ifFalse: [^ PluggableFileList newFileMenu: aDirectory].
	^ super new newFileFrom: aDirectory
]

{ #category : #'instance creation' }
StandardFileMenu class >> newFileMenu: aDirectory withPattern: aPattern [
	Smalltalk isMorphic ifFalse: [^ PluggableFileList newFileMenu: aDirectory].
	^ super new newFileFrom: aDirectory withPattern: aPattern
]

{ #category : #'instance creation' }
StandardFileMenu class >> newFileMenu: aDirectory withPatternList: aPatternList [
	Smalltalk isMorphic ifFalse: [^ PluggableFileList newFileMenu: aDirectory].
	^ super new newFileFrom: aDirectory withPatternList: aPatternList
]

{ #category : #'standard file operations' }
StandardFileMenu class >> newFileStream [

	^self newFileStreamFrom: (FileDirectory default)
]

{ #category : #'standard file operations' }
StandardFileMenu class >> newFileStreamFrom: aDirectory [

	| sfmResult fileStream |
	sfmResult := self newFileFrom: aDirectory.
	sfmResult ifNil: [^nil].
	fileStream := sfmResult directory newFileNamed: sfmResult name.
	[fileStream isNil] whileTrue:
		[sfmResult := self newFileFrom: aDirectory.
		sfmResult ifNil: [^nil].
		fileStream := sfmResult directory newFileNamed: sfmResult name].
	^fileStream

]

{ #category : #'standard file operations' }
StandardFileMenu class >> oldFile [

	^self oldFileFrom: (FileDirectory default)
]

{ #category : #'standard file operations' }
StandardFileMenu class >> oldFileFrom: aDirectory [

	^(self oldFileMenu: aDirectory)
		startUpWithCaption: 'Select a File:' translated
]

{ #category : #'standard file operations' }
StandardFileMenu class >> oldFileFrom: aDirectory withPattern: aPattern [
"
Select an existing file from a selection conforming to aPattern.
"
	^(self oldFileMenu: aDirectory withPattern: aPattern)
		startUpWithCaption: 'Select a File:' translated
]

{ #category : #'instance creation' }
StandardFileMenu class >> oldFileMenu: aDirectory [
	Smalltalk isMorphic ifFalse: [^ PluggableFileList oldFileMenu: aDirectory].
	^ super new oldFileFrom: aDirectory
]

{ #category : #'instance creation' }
StandardFileMenu class >> oldFileMenu: aDirectory withPattern: aPattern [

	Smalltalk isMorphic ifFalse: [^PluggableFileList oldFileMenu: aDirectory].
	^super new oldFileFrom: aDirectory withPattern: aPattern
]

{ #category : #'instance creation' }
StandardFileMenu class >> oldFileMenu: aDirectory withPatternList: aPatternList [

	Smalltalk isMorphic ifFalse: [^PluggableFileList oldFileMenu: aDirectory].
	^super new oldFileFrom: aDirectory withPatternList: aPatternList
]

{ #category : #'standard file operations' }
StandardFileMenu class >> oldFileStream [

	^self oldFileStreamFrom: (FileDirectory default)

]

{ #category : #'standard file operations' }
StandardFileMenu class >> oldFileStreamFrom: aDirectory [

	| sfmResult fileStream |
	sfmResult := self oldFileFrom: aDirectory.
	sfmResult ifNil: [^nil].
	fileStream := sfmResult directory oldFileNamed: sfmResult name.
	[fileStream isNil] whileTrue:
		[sfmResult := self oldFileFrom: aDirectory.
		sfmResult ifNil: [^nil].
		fileStream := sfmResult directory oldFileNamed: sfmResult name].
	^fileStream

]

{ #category : #private }
StandardFileMenu >> advance: anInteger containingDirectoriesFrom: aDirectory [

	| theDirectory |
	theDirectory := aDirectory.
	1 to: anInteger do: [:i | theDirectory := theDirectory containingDirectory].
	^theDirectory
]

{ #category : #'basic control sequences' }
StandardFileMenu >> confirmExistingFiles: aResult [

	|choice|
	(aResult directory fileExists: aResult name) ifFalse: [^aResult].
	
	choice := (UIManager default chooseFrom: #('overwrite that file' 'choose another name'
 'cancel')
		title: aResult name, '
already exists.').

	choice = 1 ifTrue: [
		aResult directory 
			deleteFileNamed: aResult name
			ifAbsent: 
				[^self startUpWithCaption: 
'Can''t delete ', aResult name, '
Select another file'].
		^aResult].
	choice = 2 ifTrue: [^self startUpWithCaption: 'Select Another File'].
	^nil
 
]

{ #category : #'menu building' }
StandardFileMenu >> directoryNamesString: aDirectory [
"Answer a string concatenating the directory name strings in aDirectory, each string followed by a '[...]' indicator, and followed by a cr."

	^ String streamContents:
		[:s | aDirectory directoryNames do: 
				[:dn | s nextPutAll: dn withBlanksTrimmed , ' [...]'; cr]]


]

{ #category : #'menu building' }
StandardFileMenu >> fileNamesString: aDirectory [
"Answer a string concatenating the file name strings in aDirectory, each string followed by a cr."

	^String streamContents:
		[:s | 
			aDirectory fileNames do: 
				[:fn |
					pattern do:[:each | (each match: fn) ifTrue: [
						s nextPutAll: fn withBlanksTrimmed; cr]]]]
		
]

{ #category : #'basic control sequences' }
StandardFileMenu >> getTypedFileName: aResult [

	| name |
	name := UIManager default 
		request: 'Enter a new file name' 
		initialAnswer: ''.
	name = '' ifTrue: [^self startUpWithCaption: 'Select a File:' translated].
	name := aResult directory fullNameFor: name.
	^ StandardFileMenuResult
			directory: (FileDirectory forFileName: name)
			name: (FileDirectory localNameFor: name)

]

{ #category : #'menu building' }
StandardFileMenu >> makeFileMenuFor: aDirectory [
"Initialize an instance of me to operate on aDirectory"

	| theMenu |
	pattern ifNil: [pattern := {'*'}].
	Cursor wait showWhile: 
		[self 
			labels: 	(self menuLabelsString: aDirectory)
			font: 	Preferences standardMenuFont 
			lines: 	(self menuLinesArray: aDirectory).
		theMenu := self selections: (self menuSelectionsArray: aDirectory)].
	^theMenu
]

{ #category : #'menu building' }
StandardFileMenu >> menuLabelsString: aDirectory [
"Answer a menu labels object corresponding to aDirectory"

	^ String streamContents: 
		[:s | 
			canTypeFileName ifTrue: 
				[s nextPutAll: 'Enter File Name...'; cr].
			s nextPutAll: (self pathPartsString: aDirectory).
			s nextPutAll: (self directoryNamesString: aDirectory).
			s nextPutAll: (self fileNamesString: aDirectory).
			s skip: -1]
]

{ #category : #'menu building' }
StandardFileMenu >> menuLinesArray: aDirectory [
"Answer a menu lines object corresponding to aDirectory"

	| typeCount nameCnt dirDepth|
	typeCount := canTypeFileName 
		ifTrue: [1] 
		ifFalse: [0].
	nameCnt := aDirectory directoryNames size.
	dirDepth := aDirectory pathParts size.
	^Array streamContents: [:s |
		canTypeFileName ifTrue: [s nextPut: 1].
		s nextPut: dirDepth + typeCount + 1.
		s nextPut: dirDepth + nameCnt + typeCount + 1]
]

{ #category : #'menu building' }
StandardFileMenu >> menuSelectionsArray: aDirectory [
"Answer a menu selections object corresponding to aDirectory.  The object is an array corresponding to each item, each element itself constituting a two-element array, the first element of which contains a selector to operate on and the second element of which contains the parameters for that selector."

	|dirSize|
	dirSize := aDirectory pathParts size.
	^Array streamContents: [:s |
		canTypeFileName ifTrue:
			[s nextPut: (StandardFileMenuResult
				directory: aDirectory
				name: nil)].
		s nextPut: (StandardFileMenuResult
			directory: (FileDirectory root)
			name: '').
		aDirectory pathParts doWithIndex: 
			[:d :i | s nextPut: (StandardFileMenuResult
					directory: (self 
						advance: dirSize - i
						containingDirectoriesFrom: aDirectory)
					name: '')].
		aDirectory directoryNames do: 
			[:dn |  s nextPut: (StandardFileMenuResult
						directory: (FileDirectory on: (aDirectory fullNameFor: dn))
						name: '')].
		aDirectory fileNames do: 
			[:fn | pattern do: [:pat | (pat match: fn) ifTrue: [
					s nextPut: (StandardFileMenuResult
						directory: aDirectory
						name: fn)]]]]
]

{ #category : #private }
StandardFileMenu >> newFileFrom: aDirectory [

	canTypeFileName := true.
	^self makeFileMenuFor: aDirectory
]

{ #category : #private }
StandardFileMenu >> newFileFrom: aDirectory withPattern: aPattern [

	canTypeFileName := true.
	pattern := {aPattern}.
	^self makeFileMenuFor: aDirectory
]

{ #category : #private }
StandardFileMenu >> newFileFrom: aDirectory withPatternList: aPatternList [

	canTypeFileName := true.
	pattern := aPatternList.
	^self makeFileMenuFor: aDirectory
]

{ #category : #private }
StandardFileMenu >> oldFileFrom: aDirectory [

	canTypeFileName := false.
	^self makeFileMenuFor: aDirectory
]

{ #category : #private }
StandardFileMenu >> oldFileFrom: aDirectory withPattern: aPattern [

	canTypeFileName := false.
	pattern := {aPattern}.
	^self makeFileMenuFor: aDirectory
]

{ #category : #private }
StandardFileMenu >> oldFileFrom: aDirectory withPatternList: aPatternList [

	canTypeFileName := false.
	pattern := aPatternList.
	^self makeFileMenuFor: aDirectory
]

{ #category : #'menu building' }
StandardFileMenu >> pathPartsString: aDirectory [
"Answer a string concatenating the path parts strings in aDirectory, each string followed by a cr."

	^String streamContents:
		[:s | 
			s nextPutAll: '[]'; cr.
			aDirectory pathParts asArray doWithIndex: 
				[:part :i |
					s next: i put: $ .
					s nextPutAll: part withBlanksTrimmed; cr]]
]

{ #category : #private }
StandardFileMenu >> pattern: aPattern [
	" * for all files, or '*.cs' for changeSets, etc.  Just like fileLists"

	pattern := {aPattern}
]

{ #category : #private }
StandardFileMenu >> patternList: aPatternList [

	pattern := aPatternList
]

{ #category : #'basic control sequences' }
StandardFileMenu >> startUpWithCaption: aString at: location [

	|result|
	result := super startUpWithCaption: aString at: location.
	result ifNil: [^nil].
	result isDirectory ifTrue:
		[self makeFileMenuFor: result directory.
		 self computeForm.
		 ^self startUpWithCaption: aString at: location].
	result isCommand ifTrue: 
		[result := self getTypedFileName: result.
		result ifNil: [^nil]].
	canTypeFileName ifTrue: [^self confirmExistingFiles: result].
	^result
	
]
