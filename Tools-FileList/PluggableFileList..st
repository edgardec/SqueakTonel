"
I am a model for a modal dialog akin to ""Standard File Services"" on various modern GUI operating systems.  My protocol includes some methods to maintain upward compatibility with StandardFileMenu, which I hope to replace.

Sample doIts:

	""StandardFileDialog getFolder""-- ask user to select folder, answer corresponding FileDirectory
	""StandardFileDialog getFile""	-- ask user to select file, answer corresponding FileStream
	""StandardFileDialog putFile""	-- ask user to create new file, answer FileStream

  In addition to the instance variables inhereted from FileList, of which I am a subclass, I am pluggable via the following instance variables:

prompt			<String>
	Display a prompt between the buttons.

resultBlock		<BlockClosure>
	Passed a file directory and a file name, answer the result to be answered by the dialog.	

canAcceptBlock	<BlockClosure>	
	Answer whether the accept button should be ""active""

fileFilterBlock	<BlockClosure>	
	Passed a file directory entry, answer whether the entry should be added to the list.  The list can be further filtered (but not expanded) by the user through the pattern.

validateBlock	<BlockClosure>
	Passed a file directory entry, a file name and a collection of newly created files, answer whether the dialog selection is valid.  validateBlock is checked after the user has pressed accept, for example to ask if the user really meant to delete a file.

newFiles		<OrderedCollection>

	newFiles is an OrderedCollection of fileNames of files added by the user to the current directory since the user last entered same
"
Class {
	#name : #PluggableFileList,
	#superclass : #FileList,
	#instVars : [
		'accepted',
		'fileFilterBlock',
		'canAcceptBlock',
		'validateBlock',
		'newFiles',
		'prompt',
		'resultBlock'
	],
	#category : #'Tools-FileList'
}

{ #category : #fileFilterBlocks }
PluggableFileList class >> allFilesAndFoldersFileFilter [

	^[:each | true]
]

{ #category : #fileFilterBlocks }
PluggableFileList class >> allFoldersFileFilter [

	^[:each | each isDirectory]
]

{ #category : #canAcceptBlocks }
PluggableFileList class >> alwaysAcceptBlock [

	^[:theDirectory :theFileName | true]
]

{ #category : #validateBlocks }
PluggableFileList class >> alwaysValidateBlock [

	^[:theDirectory :theFileName :theNewFiles | true].
]

{ #category : #validateBlocks }
PluggableFileList class >> checkExistingFileValidateBlock [

	^[:theDirectory :theFileName :theNewFiles | 
		(theNewFiles includes: theFileName) or:
			[(PluggableFileList okToOverwrite: theFileName)]].
]

{ #category : #resultBlocks }
PluggableFileList class >> directoryResultBlock [

	^[:theDirectory :theFileName | theDirectory]
]

{ #category : #validateBlocks }
PluggableFileList class >> existingFileValidateBlock [

	^[:theDirectory :theFileName :theNewFiles | 
		(theNewFiles includes: theFileName) or:
			[(PluggableFileList okToOverwrite: theFileName)]].
]

{ #category : #resultBlocks }
PluggableFileList class >> fileNameResultBlock [

	^[:theDirectory :theFileName | theFileName]
]

{ #category : #canAcceptBlocks }
PluggableFileList class >> fileNameSelectedAcceptBlock [

	^[:theDirectory :theFileName | theFileName notNil]
]

{ #category : #'standard dialog operations' }
PluggableFileList class >> getFile [
	| result |

	self flag: #unused.
	result := self getFilePathName.
	^result ifNotNil: [FileStream oldFileNamed: result]
]

{ #category : #'standard dialog operations' }
PluggableFileList class >> getFilePathName [

	^self getFilePathNameDialog open
]

{ #category : #'instance creation' }
PluggableFileList class >> getFilePathNameDialog [

	^(self new)
		validateBlock: PluggableFileList alwaysValidateBlock;
		yourself
]

{ #category : #'instance creation' }
PluggableFileList class >> getFilePathNameDialogWithExistenceCheck [

	^(self new)
		prompt: 'Select New File:';
		validateBlock: PluggableFileList checkExistingFileValidateBlock;
		yourself
]

{ #category : #'standard dialog operations' }
PluggableFileList class >> getFilePathNameWithExistenceCheck [

	^self getFilePathNameDialogWithExistenceCheck open
]

{ #category : #'standard dialog operations' }
PluggableFileList class >> getFolder [

	^self getFolderDialog open
]

{ #category : #'instance creation' }
PluggableFileList class >> getFolderDialog [

	^(self new)
		prompt: 'Select a Folder';
		fileFilterBlock: PluggableFileList allFoldersFileFilter;
		canAcceptBlock: PluggableFileList alwaysAcceptBlock;
		resultBlock: PluggableFileList directoryResultBlock;
		validateBlock: PluggableFileList alwaysValidateBlock;
		yourself
]

{ #category : #validateBlocks }
PluggableFileList class >> okToOpen: aFileNameString without: aSuffixString [

	"Answer whether user confirms that it is ok to overwrite the file named in aString"
	^ 1 = (UIManager default 
				chooseFrom: #('overwrite that file' 'select another file')
				title:  aFileNameString, ' already exists.').

]

{ #category : #validateBlocks }
PluggableFileList class >> okToOverwrite: aString [

	"Answer whether user confirms that it is ok to overwrite the file named in aString"
	^ 1 = (UIManager default chooseFrom: #('overwrite that file' 'select another file')
			title:  aString, ' already exists.')

]

{ #category : #'instance creation' }
PluggableFileList class >> open [

	^self new open
]

{ #category : #resultBlocks }
PluggableFileList class >> pathNameResultBlock [

	^[:theDirectory :theFileName | 
		theFileName 
			ifNil: [theDirectory pathName]
			ifNotNil: [theDirectory fullNameFor: theFileName]].

]

{ #category : #'standard dialog operations' }
PluggableFileList class >> putFile [

	| result |
	result := self getFilePathNameWithExistenceCheck.
	^result ifNotNil: 
		[FileDirectory deleteFilePath: result.
		 FileStream newFileNamed: result]
]

{ #category : #'file list menu' }
PluggableFileList >> addNew: aString byEvaluating: aBlock [
	"A parameterization of earlier versions of #addNewDirectory and
	#addNewFile.  Fixes the bug in each that pushing the cancel button
	in the FillInTheBlank dialog gave a walkback."

	| response newName index ending |
	self okToChange ifFalse: [^ self].
	(response := UIManager default request: 'New ',aString,' Name?'
 					initialAnswer: aString,'Name')
		isEmpty ifTrue: [^ self].
	newName := response asFileName.
	Cursor wait showWhile: [
		aBlock value: newName].
	self updateFileList.
	index := list indexOf: newName.
	index = 0 ifTrue: [ending := ') ',newName.
		index := list findFirst: [:line | line endsWith: ending]].
	self fileListIndex: index.
	newFiles add: newName

]

{ #category : #accessing }
PluggableFileList >> beAccepted [

	^accepted := true
]

{ #category : #accessing }
PluggableFileList >> canAccept [

	^canAcceptBlock value: directory value: fileName
]

{ #category : #accessing }
PluggableFileList >> canAcceptBlock: aBlock [

	^canAcceptBlock := aBlock
]

{ #category : #'user interface' }
PluggableFileList >> defaultWindowColor [
	^ Color lightYellow
]

{ #category : #accessing }
PluggableFileList >> fileFilterBlock: aBlock [

	^fileFilterBlock := aBlock
]

{ #category : #accessing }
PluggableFileList >> fileListIndex [

	self changed: #fileString.
	^super fileListIndex
]

{ #category : #'file list menu' }
PluggableFileList >> fileSelectedMenu: aMenu [
	| firstItems secondItems thirdItems n1 n2 n3 services |
	firstItems := self itemsForFile: self fullName asLowercase.
	secondItems := self itemsForAnyFile.
	thirdItems := self itemsForNoFile.
	n1 := firstItems size.
	n2 := n1 + secondItems size.
	n3 := n2 + thirdItems size.
	services := firstItems, secondItems, thirdItems, 
			(OrderedCollection with: (SimpleServiceEntry provider: self label: 'more...' selector: #offerAllFileOptions)).
	^ aMenu 
		addServices2: services 
		for: self
		extraLines: (Array with: n1 with: n2 with: n3)

]

{ #category : #'file string' }
PluggableFileList >> fileString [

	fileName ifNil: [^directory pathName].
	^directory fullNameFor: fileName
]

{ #category : #'file string' }
PluggableFileList >> fileString: aString [

	"| textName index ending |
	textName := aString asString.
	(FileDirectory default fileExists: textName) ifTrue:
		[self directory: (FileDirectory forFileName: textName).
		 index := list indexOf: (FileDirectory localNameFor: textName).
		 index = 0 ifTrue: 
			[ending := ') ', (FileDirectory localNameFor: textName).
		  	 index := list findFirst: [:line | line endsWith: ending]].
		 self fileListIndex: index].
	(FileDirectory default directoryExists: textName) ifTrue:
		[self directory: (FileDirectory on: textName)]."
	self changed: #fileString.
	self changed: #contents.
	^true
]

{ #category : #accessing }
PluggableFileList >> fileVolumeIndex [

	self changed: #fileString.
	^super fileVolumeIndex
]

{ #category : #'initialize-release' }
PluggableFileList >> initialize [

	super initialize.
	prompt := 'Select File'.
	directory := FileDirectory default.
	newFiles := OrderedCollection new.
	fileFilterBlock := PluggableFileList allFilesAndFoldersFileFilter.
	canAcceptBlock := PluggableFileList fileNameSelectedAcceptBlock.
	resultBlock := PluggableFileList pathNameResultBlock.
	validateBlock := PluggableFileList checkExistingFileValidateBlock.

]

{ #category : #'accepting\/cancelling' }
PluggableFileList >> leftButtonPressed [

	accepted := false.
	self changed: #close.

]

{ #category : #'accepting\/cancelling' }
PluggableFileList >> leftButtonState [

	^true
]

{ #category : #'file list menu' }
PluggableFileList >> listForPattern: pat [
	"Make the list be those file names which match the pattern."
	| entries sizePad newList allFiles |
	entries := directory entries select: fileFilterBlock.
	sizePad := (entries inject: 0 into: [:mx :entry | mx max: entry fileSize])
					asStringWithCommas size - 1.

	newList := OrderedCollection new: entries size.

	allFiles := pat = '*'.
	entries do:
		[:entry | "<dirflag><name><creationTime><modificationTime><fileSize>"
		(allFiles or: [entry isDirectory or: [pat match: entry name]]) ifTrue:
			[newList add: entry]].
	newList := newList asArray sort: self sortBlock.
	newList := newList collect: [ :e | self fileNameFormattedFrom: e sizePad: sizePad ].

	volList size = 1 ifTrue:
		["Include known servers along with other desktop volumes" 
		^newList ,
			(ServerDirectory serverNames collect: [:n | '^' , n , self folderString])].
	newFiles := OrderedCollection new.
	^ newList
]

{ #category : #'initialize-release' }
PluggableFileList >> open [
	self deprecated: 'PluggableFileList is being deprecated'. "This can go away soon"
	
	^ Project uiManager openPluggableFileList: self label: prompt in: self currentWorld
]

{ #category : #accessing }
PluggableFileList >> prompt: aString [

	 prompt := aString
]

{ #category : #'accepting\/cancelling' }
PluggableFileList >> result [

	accepted ifFalse: [^nil].
	^resultBlock value: directory value: fileName
]

{ #category : #accessing }
PluggableFileList >> resultBlock: aBlock [

	^resultBlock := aBlock
]

{ #category : #'accepting\/cancelling' }
PluggableFileList >> rightButtonPressed [

	(canAcceptBlock value: directory value: fileName) ifFalse: [^nil].
	(validateBlock value: directory value: fileName value: newFiles) ifFalse: [^nil].
	accepted := true.
	self changed: #close
]

{ #category : #'accepting\/cancelling' }
PluggableFileList >> rightButtonState [

	^self canAccept
]

{ #category : #StandardFileMenu }
PluggableFileList >> startUpWithCaption: captionOrNil [
	"Display the menu, slightly offset from the cursor, so that a slight tweak is required to confirm any action."

	^ self
		startUpWithCaption: captionOrNil
		at: (self currentHand ifNil: [Sensor]) cursorPoint
]

{ #category : #StandardFileMenu }
PluggableFileList >> startUpWithCaption: aString at: location [

	self prompt: aString.
	^self open
]

{ #category : #accessing }
PluggableFileList >> validate [

	^validateBlock value: directory value: fileName value: newFiles
]

{ #category : #accessing }
PluggableFileList >> validateBlock: aBlock [

	^validateBlock := aBlock
]
