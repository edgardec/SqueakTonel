"
I am model that can be used to navigate the host file system. By omitting the volume list, file list, and template panes from the view, I can also be used as the model for an editor on an individual file.

The FileList now provides a registration mechanism to which any tools the filelist uses ***MUST*** register.  This way it is possible to dynamically load or unload a new tool and have the FileList automatically updated.  This change supports a decomposition of Squeak and removes a problem with dead reference to classes after a major shrink.

Tools should implement the following methods (look for implementors in the image):

#fileReaderServicesForFile:suffix: (appropriate services for given file, takes a file name and a lowercased suffix)

#services (all provided services, to be displayed in full list)

These methods both return a collection of SimpleServiceEntry instances.  These contain a class, a menu label and a method selector having one argument.  They may also provide separate button labels and description.

The argument to the specified method will be a string representing the full name of a file when one is selected or the file list itself when there is no selected file.

Tools must register with the FileList calling the class method #registerFileReader: when they load. They also must call #unregisterFileReader: when they unload.

There is a testSuite called FileListTest that presents some examples. 

Stef (I do not like really this distinction passing always a file list could be better)


Old Comments: 


FileLists can now see FTP servers anywhere on the net.  In the volume list menu: 
fill in server info...		Gives you a form to register a new ftp server you want to use.
open server...		Choose a server to connect to.
local disk			Go back to looking at your local volume.


Still undone (you can contribute code):
[ ] Using a Proxy server to get out through a firewall.  What is the convention for proxy servers with FTP?
[ ] Fill in the date and size info in the list of remote files.  Allow sorting by it.  New smarts needed in (ServerDirectory fileNameFormattedFrom:sizePad:sortMode:).
[ ] Currently the FileList has no way to delete a directory.  Since you can't select a directory without going into it, it would have to be deleting the current directory.  Which would usually be empty.
"
Class {
	#name : #FileList,
	#superclass : #StringHolder,
	#instVars : [
		'fileName',
		'directory',
		'volList',
		'volListIndex',
		'list',
		'listIndex',
		'pattern',
		'sortMode',
		'brevityState',
		'directoryCache',
		'lastGraphicsExtent'
	],
	#classVars : [
		'FileReaderRegistry',
		'RecentDirs'
	],
	#category : #'Tools-FileList'
}

{ #category : #'class initialization' }
FileList class >> initialize [
	"FileList initialize"

	RecentDirs := OrderedCollection new
]

{ #category : #'instance creation' }
FileList class >> new [
	^self newOn: FileDirectory default
]

{ #category : #'instance creation' }
FileList class >> newOn: aDirectory [

	^super new directory: aDirectory
]

{ #category : #'instance creation' }
FileList class >> open [
	"Open a view of an instance of me on the default directory."
	^ToolBuilder open: self
]

{ #category : #'instance creation' }
FileList class >> openEditorOn: aFileStream editString: editString [
	"Open an editor on the given FileStream."
	| fileModel topView builder |
	fileModel := FileList new setFileStream: aFileStream.	"closes the stream"
	builder := ToolBuilder default.
	topView := fileModel buildEditorWith: builder.
	^builder open: topView.
]

{ #category : #'instance creation' }
FileList class >> openFileDirectly [

	(FileChooserDialog openOn: FileDirectory default) ifNotNil:
		[:fileName | self openEditorOn: (FileStream readOnlyFileNamed: fileName) editString: nil]
]

{ #category : #'instance creation' }
FileList class >> openOn: directory [

	^ToolBuilder open: (self newOn: directory)
]

{ #category : #'instance creation' }
FileList class >> prototypicalToolWindow [
	"Answer an example of myself seen in a tool window, for the benefit of parts-launching tools"
	^ ToolBuilder build: self new
]

{ #category : #'class initialization' }
FileList class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry"
	self environment
		at: #Flaps
		ifPresent: [:cl | cl registerQuad: {#FileList	. #prototypicalToolWindow, 'File List' translatedNoop.		'A File List is a tool for browsing folders and files on disks and on ftp types.' translatedNoop} 
						forFlapNamed: 'Tools']
]

{ #category : #'class initialization' }
FileList class >> removeObsolete [
	"FileList removeObsolete"
	FileServices removeObsolete
	
]

{ #category : #'class initialization' }
FileList class >> unload [
	"Unload the receiver from global registries"

	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self] 
]

{ #category : #'file menu action' }
FileList >> addNew: aString byEvaluating: aBlock [
	"A parameterization of earlier versions of #addNewDirectory and
	#addNewFile.  Fixes the bug in each that pushing the cancel button
	in the FillInTheBlank dialog gave a walkback."

	| response newName index ending |
	self okToChange ifFalse: [^ self].
	(response := UIManager default
						request: ('New {1} Name?' translated format: {aString translated})
						initialAnswer: ('{1}Name' translated format: {aString translated}))
		isEmpty ifTrue: [^ self].
	newName := response asFileName.
	Cursor wait showWhile: [
		aBlock value: newName].
	self updateFileList.
	index := list indexOf: newName.
	index = 0 ifTrue: [ending := ') ',newName.
		index := list findFirst: [:line | line endsWith: ending]].
	self fileListIndex: index.

]

{ #category : #'file menu action' }
FileList >> addNewDirectory [
	self 
		addNew: 'Directory'
		byEvaluating: [:newName | directory createDirectory: newName]

]

{ #category : #'file menu action' }
FileList >> addNewFile [
	self 
		addNew: 'File'
		byEvaluating: [:newName | (directory newFileNamed: newName) close]

]

{ #category : #private }
FileList >> addPath: aString [
	"Add the given string to the list of recently visited directories."

	| full |
	aString ifNil: [^self].
	full := String streamContents: 
		[ :strm | 2 to: volList size do: 
			[ :i | strm nextPutAll: (volList at: i) withBlanksTrimmed.
			strm nextPut: FileDirectory pathNameDelimiter]].
	full := full, aString.
"Remove and super-directories of aString from the collection."
	RecentDirs removeAllSuchThat: [ :aDir | ((aDir, '*') match: full)].

"If a sub-directory is in the list, do nothing."
	(RecentDirs anySatisfy: [ :aDir | ((full, '*') match: aDir)])
		ifTrue: [^self].

	[RecentDirs size >= 10]
		whileTrue: [RecentDirs removeFirst].
	RecentDirs addLast: full
]

{ #category : #'server list' }
FileList >> askServerInfo [
	"Get the user to create a ServerDirectory for a new server.  Fill in and say Accept."
	| template |
	template := '"Please fill in the following info, then select all text and choose DoIt."

	| aa | 
	self flag: #ViolateNonReferenceToOtherClasses.
	aa := ServerDirectory new.
	aa server: ''st.cs.uiuc.edu''.    "host"
	aa user: ''anonymous''.
	aa password: ''yourEmail@school.edu''.
	aa directory: ''/Smalltalk/Squeak/Goodies''.
	aa url: ''''.    "<- this is optional.  Only used when *writing* update files."
	ServerDirectory addServer: aa named: ''UIUCArchive''.  "<- known by this name in Squeak"'.

	(StringHolder new contents: template) openLabel: 'FTP Server Form'
	
]

{ #category : #private }
FileList >> availableGraphicsExtent [

	^ self codeTextMorph ifNotNil: [:m | m innerBounds extent - (6@22)]

]

{ #category : #toolbuilder }
FileList >> buildButtonPaneWith: builder [
	| panelSpec |
	panelSpec := builder pluggablePanelSpec new.
	panelSpec 
		model: self;
		children: #getButtonRow;
		layout: #horizontal.
	^panelSpec

]

{ #category : #toolbuilder }
FileList >> buildCodePaneWith: builder [
	| textSpec |
	textSpec := builder pluggableTextSpec new.
	textSpec 
		model: self;
		getText: #contents; 
		setText: #put:; 
		selection: #contentsSelection; 
		menu: #fileContentsMenu:shifted:.
	^textSpec
]

{ #category : #toolbuilder }
FileList >> buildContentPaneWith: builder [
	| textSpec |
	textSpec := builder pluggableTextSpec new.
	textSpec 
		model: self;
		getText: #contents; 
		setText: #put:; 
		selection: #contentsSelection; 
		menu: #fileContentsMenu:shifted:.
	^textSpec

]

{ #category : #toolbuilder }
FileList >> buildDirectoryTreeWith: builder [ 
	| treeSpec |
	treeSpec := builder pluggableTreeSpec new.
	treeSpec
		 model: self ;
		 roots: #rootDirectoryList ;
		 hasChildren: #hasMoreDirectories: ;
		 getChildren: #subDirectoriesOf: ;
		 getSelectedPath: #selectedPath ;
		 setSelected: #setDirectoryTo: ;
		 getSelected: #directory;
		 label: #directoryNameOf: ;
		 menu: #volumeMenu: ;
		 autoDeselect: false.
	SystemBrowser browseWithDragNDrop ifTrue:
		[ treeSpec
			dragItem: #dragFromDirectoryList: ;
			dropItem: #drop:ontoDirectory:shouldCopy: ;
			dropAccept: #wantsDraggedObject: ].
	^ treeSpec
]

{ #category : #toolbuilder }
FileList >> buildEditorWith: builder [
	^super buildWith: builder
]

{ #category : #toolbuilder }
FileList >> buildFileListWith: builder [ 
	| buttons listSpec top |
	top := builder pluggablePanelSpec new.
	top children: OrderedCollection new.
	buttons := self buildButtonPaneWith: builder.
	buttons frame:
		(self
			topConstantHeightFrame: self buttonHeight
			fromLeft: 0
			width: 1).
	top children add: buttons.
	listSpec := builder pluggableListSpec new.
	listSpec
		 model: self ;
		 list: #fileList ;
		 getIndex: #fileListIndex ;
		 setIndex: #fileListIndex: ;
		 menu: #fileListMenu: ;
		 keyPress: nil ;
		 frame:
		(self
			frameOffsetFromTop: self buttonHeight * 1.1
			fromLeft: 0
			width: 1
			bottomFraction: 1) .
	SystemBrowser browseWithDragNDrop ifTrue: [ listSpec dragItem: #dragFromFileList: ].
	top children add: listSpec.
	^ top
]

{ #category : #toolbuilder }
FileList >> buildPatternInputWith: builder [
	| textSpec |
	textSpec := builder pluggableInputFieldSpec new.
	textSpec 
		model: self;
		font: self pathAndPatternFont;
		getText: #pathAndPattern; 
		setText: #pathAndPattern:.
	^textSpec

]

{ #category : #toolbuilder }
FileList >> buildWith: builder [
	"FileList open"
	| windowSpec window |
	windowSpec := self buildWindowWith: builder specs: {
		(self topConstantHeightFrame: self pathAndPatternHeight
			fromLeft: 0
			width: 1) -> [self buildPatternInputWith: builder].
		(self frameOffsetFromTop: self pathAndPatternHeight
			fromLeft: 0.25
			width: 0.75
			bottomFraction: 0.5) -> [self buildFileListWith: builder].
		(self frameOffsetFromTop: self pathAndPatternHeight
			fromLeft: 0
			width: 0.25
			bottomFraction: 1) -> [self buildDirectoryTreeWith: builder].
		(0.25@0.5 corner: 1@1) -> [self buildContentPaneWith: builder].
	}.
	window := builder build: windowSpec.
	self changed: #selectedPath.
	^window
]

{ #category : #toolbuilder }
FileList >> buttonHeight [
	^ Preferences standardButtonFont height * 2
]

{ #category : #initialization }
FileList >> buttonSelectorsToSuppress [
	"Answer a list of action selectors whose corresponding services we would prefer *not* to have appear in the filelist's button pane; this can be hand-jimmied to suit personal taste."

	^ #(removeLineFeeds: addFileToNewZip: compressFile: putUpdate:)
]

{ #category : #'file menu action' }
FileList >> compressFile [
	"Compress the currently selected file"

	| f |
	f := StandardFileStream
				readOnlyFileNamed: (directory fullNameFor: self fullName).
	f compressFile.
	self updateFileList
]

{ #category : #private }
FileList >> contents [
	"Answer the contents of the file, reading it first if needed."
	"Possible brevityState values:
		FileList,
		fullFile, briefFile, needToGetFull, needToGetBrief,
		fullHex, briefHex, needToGetFullHex, needToGetBriefHex"

	(listIndex = 0) | (brevityState == #FileList) ifTrue: [^ self defaultContents].  "no file selected"
	brevityState == #fullFile ifTrue: [^ contents].
	brevityState == #fullHex ifTrue: [^ contents].
	brevityState == #briefFile ifTrue: [^ contents].
	brevityState == #briefHex ifTrue: [^ contents].
	brevityState == #graphic ifTrue: [^ contents].

	brevityState == #needToGetGraphic ifTrue: [^self readGraphicContents].
	
	brevityState == #needToGetFullHex ifTrue: [^ self readContentsHex: false].
	brevityState == #needToGetBriefHex ifTrue: [^ self readContentsHex: true].

	brevityState == #needToGetFull ifTrue: [^ self readContentsBrief: false].
	brevityState == #needToGetBrief ifTrue: [^ self readContentsBrief: true].  "default"

	(TextConverter allEncodingNames includes: brevityState) 
		ifTrue: [ ^self readContentsAsEncoding: brevityState].

	self halt: 'unknown state ' , brevityState printString
]

{ #category : #'menu messages' }
FileList >> copyName [

	listIndex = 0 ifTrue: [^ self].
	Clipboard clipboardText: self fullName asText.

]

{ #category : #private }
FileList >> defaultContents [
	contents := list == nil
		ifTrue: [String new]
		ifFalse: [String streamContents:
					[:s | s nextPutAll: 'NO FILE SELECTED' translated; cr.
					s nextPutAll: '  -- Folder Summary --' translated; cr.
					list do: [:item | s nextPutAll: item; cr]]].
	brevityState := #FileList.
	^ contents
]

{ #category : #private }
FileList >> defaultEncoderFor: aFileName [

	"This method just illustrates the stupidest possible implementation of encoder selection."
	| l |
	l := aFileName asLowercase.
"	((l endsWith: FileStream multiCs) or: [
		l endsWith: FileStream multiSt]) ifTrue: [
		^ UTF8TextConverter new.
	].
"
	((l endsWith: FileStream cs) or: [
		l endsWith: FileStream st]) ifTrue: [
		^ MacRomanTextConverter new.
	].

	^ Latin1TextConverter new.

	
]

{ #category : #'user interface' }
FileList >> defaultWindowColor [
	^ (Color r: 0.65 g: 0.65 b: 0.65)
]

{ #category : #'volume list and pattern' }
FileList >> deleteDirectory [
	"Remove the currently selected directory"
	| localDirName |
	directory hasEntries ifTrue:[^self inform:'Directory must be empty' translated].
	localDirName := directory localName.
	(self confirm: ('Really delete {1}?' translated format: {localDirName})) ifFalse: [^ self].
	self volumeListIndex: self volumeListIndex-1.
	directory deleteDirectory: localDirName.
	self updateFileList.
]

{ #category : #'file menu action' }
FileList >> deleteFile [
	"Delete the currently selected file"
	listIndex = 0 ifTrue: [^ self].
	(self confirm: ('Really delete {1}?' translated format:{fileName})) ifFalse: [^ self].
	directory deleteFileNamed: fileName.
	self updateFileList.
	brevityState := #FileList.
	self get
]

{ #category : #'file list menu' }
FileList >> dirAndFileName [

	^{directory. fileName}
]

{ #category : #'volume list and pattern' }
FileList >> directory [

	^ directory
]

{ #category : #initialization }
FileList >> directory: aFileDirectory [ 
	"Set the path of the volume to be displayed."
	self okToChange ifFalse: [ ^ self ].
	self modelSleep.
	directory := aFileDirectory.
	self modelWakeUp.
	sortMode == nil ifTrue: [ sortMode := #date ].
	volList := (Array with: '[]') , directory pathParts withIndexCollect:
		[ : each : i | (String
			new: i - 1
			withAll: Character space) , each ].
	volListIndex := volList size.
	self changed: #relabel.
	self changed: #volumeList.
	self changed: #directory.
	self pattern: pattern
]

{ #category : #'directory tree' }
FileList >> directoryNameOf: aDirectory [
	"Attempt to find the name of ServerDirectories when used."

	^(aDirectory isRemoteDirectory and:[aDirectory isKindOf: ServerDirectory])
		ifTrue:[ServerDirectory servers keyAtIdentityValue: aDirectory ifAbsent:[aDirectory localName]]
		ifFalse:[aDirectory localName]
]

{ #category : #'file list' }
FileList >> dragFromDirectoryList: anIndex [
	^ self directory
]

{ #category : #'file list' }
FileList >> dragFromFileList: anIndex [ 
	^ self directory entryAt: (self fileNameFromFormattedItem: (self fileList at: self fileListIndex))
]

{ #category : #'drag\'n\'drop' }
FileList >> dragPassengerFor: item inMorph: dragSource [
	^self directory fullNameFor: ((self fileNameFromFormattedItem: item contents copy)
		copyReplaceAll: self folderString with: '').

]

{ #category : #toolbuilder }
FileList >> drop: aDirectoryEntryFile ontoDirectory: aFileDirectory shouldCopy: aBoolean [ 
	aDirectoryEntryFile containingDirectory = aFileDirectory ifTrue: [ ^ self ].
	aBoolean
		ifTrue: [ aFileDirectory copyHere: aDirectoryEntryFile ]
		ifFalse:
			[ directory
				rename: aDirectoryEntryFile fullName
				toBe: (aFileDirectory fullNameFor: aDirectoryEntryFile name).
			self setDirectoryTo: directory ]
]

{ #category : #initialization }
FileList >> dynamicButtonServices [
	"Answer services for buttons that may come and go in the button pane, depending on selection"

	^ fileName isEmptyOrNil
		ifTrue:
			[#()]
		ifFalse:
			[ | toReject |
				toReject := self buttonSelectorsToSuppress.
				(self itemsForFile: self fullName) reject:
					[:svc | toReject includes: svc selector]]
]

{ #category : #private }
FileList >> entriesMatching: patternString [
	"Answer a list of directory entries which match the patternString.
	The patternString may consist of multiple patterns separated by ';'.
	Each pattern can include a '*' or '#' as wildcards - see String>>match:"

	| entries patterns |
	entries := directory entries reject:[:e| Smalltalk isMorphic and: [e isDirectory]].
	patterns := patternString findTokens: ';'.
	(patterns anySatisfy: [:each | each = '*'])
		ifTrue: [^ entries].
	^ entries select: [:entry | patterns anySatisfy: [:each | each match: entry name]]
]

{ #category : #toolbuilder }
FileList >> executeService: aService [
	aService performServiceFor: self.
]

{ #category : #'file list menu' }
FileList >> fileContentsMenu: aMenu shifted: shifted [
	"Construct aMenu to have items appropriate for the file browser's code pane, given the shift state provided"
	^ self menu: aMenu for: #(fileContentsMenu fileContentsMenuShifted:) shifted: shifted
]

{ #category : #'file list' }
FileList >> fileList [
	"Answer the list of files in the current volume."

	^ list
]

{ #category : #'file list' }
FileList >> fileListIndex [
	"Answer the index of the currently selected file."

	^ listIndex
]

{ #category : #'file list' }
FileList >> fileListIndex: anInteger [
	"Select the file name having the given index, and display its contents."

	| item name |
	self okToChange ifFalse: [^ self].
	listIndex := anInteger.
	listIndex = 0 
		ifTrue: [fileName := nil]
		ifFalse:
			[item := self fileNameFromFormattedItem: (list at: anInteger).
			(item endsWith: self folderString)
				ifTrue:
					["remove [...] folder string and open the folder"
					name := item copyFrom: 1 to: item size - self folderString size.
					listIndex := 0.
					brevityState := #FileList.
					self addPath: name.
					name first = $^
						ifTrue: [self directory: (ServerDirectory serverNamed: name allButFirst)]
						ifFalse: [volListIndex = 1 ifTrue: [name := name, directory slash].
							self directory: (directory directoryNamed: name)]]
				ifFalse: [fileName := item]].  "open the file selected"

	brevityState := self isGraphicsFileSelected
		ifTrue: [#needToGetGraphic]
		ifFalse: [#needToGetBrief]..
	self 
		changed: #fileListIndex ;
		changed: #contents ;
		changed: #labelString.
	self updateButtonRow
]

{ #category : #'file list menu' }
FileList >> fileListMenu: aMenu [
	^ self menu: aMenu for: #(fileListMenu fileListMenuShifted:)

]

{ #category : #'file list' }
FileList >> fileName [

	^ fileName
]

{ #category : #'volume list and pattern' }
FileList >> fileNameFormattedFrom: entry sizePad: sizePad [
	"entry is a 5-element array of the form:
		(name creationTime modificationTime dirFlag fileSize)"
	| sizeStr nameStr dateStr |
	nameStr := entry isDirectory
		ifTrue: [entry name , self folderString]
		ifFalse: [entry name].
	dateStr := ((Date fromSeconds: entry modificationTime )
					printFormat: #(3 2 1 $. 1 1 2)) , ' ' ,
				(String streamContents: [:s |
					(Time fromSeconds: entry modificationTime \\ 86400)
						print24: true on: s]).
	sizeStr := entry fileSize asStringWithCommas.
	sortMode = #name ifTrue:
		[^ nameStr , '    (' , dateStr , ' ' , sizeStr , ')'].
	sortMode = #date ifTrue:
		[^ '(' , dateStr , ' ' , sizeStr , ') ' , nameStr].
	sortMode = #size ifTrue:
		[^ '(' , (String new: sizePad - sizeStr size withAll: Character space) , sizeStr , ' ' , dateStr , ') ' , nameStr].

]

{ #category : #private }
FileList >> fileNameFromFormattedItem: item [
	"Extract fileName and folderString from a formatted fileList item string"

	| from to |
	self sortingByName
		ifTrue: [
			from := item lastIndexOf: $(.
			to := item lastIndexOf: $)]
		ifFalse: [
			from := item indexOf: $(.
			to := item indexOf: $)].
	^ (from * to = 0
		ifTrue: [item]
		ifFalse: [item copyReplaceFrom: from to: to with: '']) withBlanksTrimmed
]

{ #category : #'file list menu' }
FileList >> fileSelectedMenu: aMenu [

	| firstItems secondItems thirdItems n1 n2 n3 services |
	firstItems := self itemsForFile: self fullName.
	secondItems := self itemsForAnyFile.
	thirdItems := self itemsForNoFile.
	n1 := firstItems size.
	n2 := n1 + secondItems size.
	n3 := n2 + thirdItems size.
	services := firstItems, secondItems, thirdItems, self serviceAllFileOptions.
	services do: [ :svc | svc addDependent: self ].
	^ aMenu 
		addServices2: services 
		for: self
		extraLines: (Array with: n1 with: n2 with: n3)

]

{ #category : #private }
FileList >> folderString [
	^ ' [...]'
]

{ #category : #toolbuilder }
FileList >> frameOffsetFromTop: height fromLeft: leftFraction width: rightFraction bottomFraction: bottomFraction [
	^LayoutFrame new
		topFraction: 0 offset: height;
		leftFraction: leftFraction offset: 0;
		rightFraction: (leftFraction + rightFraction) offset: 0;
		bottomFraction: bottomFraction offset: 0;
		yourself.
]

{ #category : #'file list menu' }
FileList >> fullFileListMenu: aMenu shifted: aBoolean [
	"Fill the menu with all possible items for the file list pane, regardless of selection."

	| lastProvider |
	aMenu title: 'all possible file operations' translated.
	aMenu addStayUpItemSpecial.

	lastProvider := nil.
	(self itemsForFile: self fullName) do: [ :svc |
		(lastProvider notNil and: [svc provider ~~ lastProvider])
			ifTrue: [ aMenu addLine ].
		svc addServiceFor: self toMenu: aMenu.
		Smalltalk isMorphic ifTrue: [aMenu submorphs last setBalloonText: svc description].
		lastProvider := svc provider.
		svc addDependent: self.
	].

	^aMenu
]

{ #category : #private }
FileList >> fullName [
	"Answer the full name for the currently selected file; answer nil if no file is selected."

	^ fileName ifNotNil: [directory
		ifNil:
			[FileDirectory default fullNameFor: fileName]
		ifNotNil:
			[directory fullNameFor: fileName]]

]

{ #category : #'file menu action' }
FileList >> get [
	"Get contents of file again, it may have changed. Do this by making the cancel string be the contents, and doing a cancel."

	Cursor read showWhile: [
		self okToChange ifFalse: [^ nil].
		brevityState == #briefHex
			ifTrue: [brevityState := #needToGetFullHex]
			ifFalse: [brevityState := #needToGetFull].
		self changed: #contents].

]

{ #category : #toolbuilder }
FileList >> getButtonRow [
	"Answer the dynamic button row to use for the currently selected item."
	| builder svc |
	builder := ToolBuilder default.
	svc := self universalButtonServices.
	self fileListIndex = 0 ifFalse:[svc := svc, self dynamicButtonServices].
	^svc collect:[:service| service buildWith: builder in: self].
]

{ #category : #'file menu action' }
FileList >> getEncodedText [

	Cursor read showWhile: [
		self selectEncoding.
		self changed: #contents].

]

{ #category : #'file menu action' }
FileList >> getHex [
	"Get contents of file again, and display in Hex. Do this by making the cancel string be the contents, and doing a cancel."

	Cursor read showWhile: [
		brevityState := #needToGetBriefHex.
		self changed: #contents].

]

{ #category : #'directory tree' }
FileList >> getSelectedPath [
	self halt.
]

{ #category : #'directory tree' }
FileList >> hasMoreDirectories: aDirectory [
	(aDirectory isKindOf: FileDirectory) ifFalse:[^true]. "server directory; don't ask"
	^directoryCache at: aDirectory ifAbsentPut:[
		[aDirectory directoryNames notEmpty] on: Error do:[:ex| true].
	].
]

{ #category : #initialization }
FileList >> initialize [
	super initialize.
	directoryCache := WeakIdentityKeyDictionary new.
]

{ #category : #private }
FileList >> isFileSelected [
	"return if a file is currently selected"

	^ fileName notNil
]

{ #category : #private }
FileList >> isGraphicsFileSelected [
	^fileName notNil
		and: [(self itemsForFile: self fullName) anySatisfy: [:each | each provider == Form and: [each selector == #importImage:]]]
]

{ #category : #'file list menu' }
FileList >> itemsForAnyFile [
	"Answer a list of universal services that could apply to any file"
	
	| services |
	services := OrderedCollection new: 4.
	services add: self serviceCopyName. 
	services add: self serviceRenameFile. 
	services add: self serviceDeleteFile.
	services add: self serviceViewContentsInWorkspace.
	^ services
]

{ #category : #'file list menu' }
FileList >> itemsForDirectory: dir [ 
	| services |
	services := OrderedCollection new.
	dir ifNotNil: [
		services
			addAll: (FileServices itemsForDirectory: dir).
		services last useLineAfter: true. ].
	services add: self serviceAddNewFile.
	services add: self serviceAddNewDirectory.
	^ services
]

{ #category : #'file list menu' }
FileList >> itemsForFile: fullName [
	"Answer a list of services appropriate for a file of the given full name"
	^ (FileServices itemsForFile: fullName) , (self myServicesForFile: fullName suffix: (FileServices suffixOf: fullName))
]

{ #category : #'file list menu' }
FileList >> itemsForNoFile [

	| services |
	services := OrderedCollection new.
	services add: self serviceSortByName.
	services add: self serviceSortBySize.
	services add: (self serviceSortByDate useLineAfter: true).
	services addAll: (self itemsForDirectory: (self isFileSelected ifFalse: [ self directory ] ifTrue: [])).
	^ services

		
]

{ #category : #initialization }
FileList >> labelString [
	^ directory
		ifNil: [ 'File List' ]
		ifNotNil:
			[ fileName
				ifNil: [ directory fullName ]
				ifNotNil: [ directory fullNameFor: fileName ] ]
]

{ #category : #'volume list and pattern' }
FileList >> listForPattern: pat [
	"Make the list be those file names which match the pattern."

	| sizePad newList |
	newList := (self entriesMatching: pat) asArray sort: self sortBlock.
	sizePad := (newList inject: 0 into: [:mx :entry | mx max: (entry at: 5)])
					asStringWithCommas size - 1.
	newList := newList collect: [ :e | self fileNameFormattedFrom: e sizePad: sizePad ].

	volList size = 1 ifTrue:
		["Include known servers along with other desktop volumes" 
		^ newList ,
		(ServerDirectory serverNames collect: [:n | '^' , n , self folderString])].
	^ newList
]

{ #category : #private }
FileList >> listForPatterns: anArray [
	"Make the list be those file names which match the pattern."

	| sizePad newList |
	newList := Set new.
	anArray do: [ :pat | newList addAll: (self entriesMatching: pat) ].
	newList := newList asArray sort: self sortBlock.
	sizePad := (newList inject: 0 into: [:mx :entry | mx max: entry fileSize])
					asStringWithCommas size.
	newList := newList collect: [ :e | self fileNameFormattedFrom: e sizePad: sizePad ].

	volList size = 1 ifTrue:
		["Include known servers along with other desktop volumes" 
		^ newList  ,
			(ServerDirectory serverNames collect: [:n | '^' , n , self folderString])].
	^ newList
]

{ #category : #'file list menu' }
FileList >> mainFileContentsMenu: aMenu [
	"Construct aMenu to have items appropriate for the file browser's code pane, for the unshifted state"
	<fileContentsMenuShifted: false>
	^ aMenu addTranslatedList: #(
			('find... (f)' 				find)
			('find again (g)' 			findAgain)
			('find and replace... '		findReplace)
			('do/replace again (j)' 	again)
			-
			('undo (z)' 				undo)
			('redo (Z)' 				redo)
			-
			('copy (c)' 				copySelection)
			('cut (x)' 				cut)
			('paste (v)' 				paste)
			('paste...' 				pasteRecent)
			-
			('do it (d)' 				doIt)
			('print it (p)' 			printIt)
			('inspect it (i)' 			inspectIt)
			('fileIn selection (G)'	fileItIn)
			-
			('accept (s)' 			accept)
			('cancel (l)' 				cancel)
			-
			('more...' 				shiftedYellowButtonActivity));
		yourself

]

{ #category : #'file list menu' }
FileList >> mainFileListMenu: aMenu [
	<fileListMenu>
	fileName
		ifNil: [^ self noFileSelectedMenu: aMenu]
		ifNotNil: [^ self fileSelectedMenu: aMenu].

]

{ #category : #'volume menu' }
FileList >> mainVolumeMenu: aMenu [
	<volumeMenu>
	^ aMenu addTranslatedList: #(
			('recent...'				recentDirs)
			-
			('add server...'			askServerInfo)
			('remove server...'		removeServer)
			-
			('delete directory...'		deleteDirectory)
			-);
		yourself
]

{ #category : #initialization }
FileList >> modelSleep [
	"User has exited or collapsed the window -- close any remote connection."

	directory ifNotNil: [directory sleep]
]

{ #category : #initialization }
FileList >> modelWakeUp [
	"User has entered or expanded the window -- reopen any remote connection."

	(directory notNil and:[directory isRemoteDirectory])
		ifTrue: [[directory wakeUp] on: TelnetProtocolError do: [ :ex | self inform: ex printString ]] "It would be good to implement a null method wakeUp on the root of directory"
]

{ #category : #'file list menu' }
FileList >> myServicesForFile: fullName suffix: suffix [

	^(FileStream isSourceFileSuffix: suffix)
		ifTrue: [ {self serviceBroadcastUpdate} ]
		ifFalse: [ #() ]
]

{ #category : #'file list menu' }
FileList >> noFileSelectedMenu: aMenu [

	^ aMenu
		addServices: self itemsForNoFile 
		for: self
		extraLines: #()
		

]

{ #category : #'file list menu' }
FileList >> offerAllFileOptions [
	"Put up a menu offering all possible file options, whatever the suffix of the current selection may be.  Specially useful if you're wanting to keep the menu up"

	self offerMenuFrom: #fullFileListMenu:shifted: shifted: true
]

{ #category : #initialization }
FileList >> optionalButtonHeight [

	^ 15
]

{ #category : #initialization }
FileList >> optionalButtonSpecs [
	"Answer a list of services underlying the optional buttons in their initial inception."

	^ {self serviceSortByName. self serviceSortByDate. self serviceSortBySize}
]

{ #category : #'volume list and pattern' }
FileList >> pathAndPattern [
	"Answers both path and pattern"
	^directory fullName, directory slash, pattern
]

{ #category : #'volume list and pattern' }
FileList >> pathAndPattern: stringOrText [
	"Answers both path and pattern"
	| base pat aString |
	aString := stringOrText asString.
	base := aString copyUpToLast: directory pathNameDelimiter.
	pat := aString copyAfterLast: directory pathNameDelimiter.
	self changed: #pathAndPattern. "avoid asking if it's okToChange"
	pattern := pat.
	self directory: (FileDirectory on: base).
	self changed: #pathAndPattern.
	self changed: #selectedPath.
]

{ #category : #toolbuilder }
FileList >> pathAndPatternFont [

	^ Preferences standardDefaultTextFont
]

{ #category : #toolbuilder }
FileList >> pathAndPatternHeight [
	" Take a whole font line and 50 % for space "
	^ (self pathAndPatternFont height * 1.5) ceiling
]

{ #category : #'volume list and pattern' }
FileList >> pattern [

	^ pattern ifNil: ['*']

]

{ #category : #'volume list and pattern' }
FileList >> pattern: textOrStringOrNil [

	textOrStringOrNil
		ifNil: [pattern := '*']
		ifNotNil: [pattern := textOrStringOrNil asString].
	pattern isEmpty ifTrue: [pattern := '*'].
	self updateFileList.
	^ true

]

{ #category : #'menu messages' }
FileList >> perform: selector orSendTo: otherTarget [ 
	"Selector was just chosen from a menu by a user.
	If it's one of the three sort-by items, handle it specially.
	If I can respond myself, then perform it on myself. 
	If not, send it to otherTarget, presumably the editPane from which the menu was invoked."

	^ (#(sortByDate sortBySize sortByName) includes: selector)
		ifTrue:
			[self resort: selector]
		ifFalse:
			[(#(get getHex copyName openImageInWindow importImage renameFile deleteFile addNewFile) includes: selector)
				ifTrue: [self perform: selector]
				ifFalse: [super perform: selector orSendTo: otherTarget]]
]

{ #category : #private }
FileList >> put: aText [
	"Private - put the supplied text onto the file"

	| ff type newName |
	brevityState == #fullFile ifTrue:
		[ff := directory newFileNamed: self fullName.
		Cursor write showWhile: [ff nextPutAll: aText asString; close].
		(directory = ff directory and: [fileName = ff localName])
			ifTrue: [contents := aText asString]
			ifFalse: 		"user changed the directory and/or renamed the file"
				[self clearUserEditFlag.
				directory ~= ff directory ifTrue: 
					[self directory: ff directory.
					self changed: #rootDirectoryList; changed: #selectedPath].
				self updateFileList.
				contents := aText asString.
				newName := ff localName.
				listIndex := list findFirst: [:item | (self fileNameFromFormattedItem: item) = newName].
				listIndex > 0 ifTrue: [fileName := newName].
				brevityState := #needToGetBrief.
				self changed: #fileListIndex].
		self changed: #relabel.
		^ true  "accepted"].

	listIndex = 0 ifTrue:
		[self inform: 'No fileName is selected' translated.
		^ false  "failed"].
	type := 'These'.
	brevityState = #briefFile ifTrue: [type := 'Abbreviated'].
	brevityState = #briefHex ifTrue: [type := 'Abbreviated'].
	brevityState = #fullHex ifTrue: [type := 'Hexadecimal'].
	brevityState = #FileList ifTrue: [type := 'Directory'].
	self inform: ('{1} contents cannot
meaningfully be saved at present.' translated format:{type translated}).
	^ false  "failed"

]

{ #category : #private }
FileList >> readContentsAsEncoding: encodingName [
	| f writeStream converter c |
	f := directory oldFileOrNoneNamed: self fullName.
	f ifNil: [^ 'For some reason, this file cannot be read'].
	writeStream := WriteStream on: String new.
	converter := TextConverter defaultConverterClassForEncoding: encodingName.
	converter ifNil: [^ 'This encoding is not supported'].
	f converter: converter new.
	f wantsLineEndConversion: true.
	[f atEnd or: [(c := f next) isNil]]
		whileFalse: [writeStream nextPut: c].
	f close.
	^ writeStream contents
]

{ #category : #private }
FileList >> readContentsBrief: brevityFlag [
	"Read the contents of the receiver's selected file, unless it is too long, in which case show just the first 5000 characters. Don't create a file if it doesn't already exist."
	| f fileSize first5000 |

	brevityFlag ifTrue: [
		directory isRemoteDirectory ifTrue: [^ self readServerBrief]].
	f := directory oldFileOrNoneNamed: self fullName.
	f ifNil: [^ 'For some reason, this file cannot be read' translated].
	f converter: (self defaultEncoderFor: self fullName).
	(brevityFlag not or: [(fileSize := f size) <= 100000]) ifTrue:
		[contents := f contentsOfEntireFile.
		brevityState := #fullFile.   "don't change till actually read"
		^ contents].

	"if brevityFlag is true, don't display long files when first selected"
	first5000 := f next: 5000.
	f close.
	contents := 'File ''{1}'' is {2} bytes long.
You may use the ''get'' command to read the entire file.

Here are the first 5000 characters...
------------------------------------------
{3}
------------------------------------------
... end of the first 5000 characters.' translated format: {fileName. fileSize. first5000}.
	brevityState := #briefFile.   "don't change till actually read"
	^ contents.

]

{ #category : #private }
FileList >> readContentsCNGB [
	| f writeStream |
	f := directory oldFileOrNoneNamed: self fullName.
	f ifNil: [^ 'For some reason, this file cannot be read'].
	writeStream := WriteStream on: String new.
	f converter: CNGBTextConverter new.
	[f atEnd]
		whileFalse: [writeStream nextPut: f next].
	f close.
	^ writeStream contents
]

{ #category : #private }
FileList >> readContentsEUCJP [
	| f writeStream |
	f := directory oldFileOrNoneNamed: self fullName.
	f ifNil: [^ 'For some reason, this file cannot be read'].
	writeStream := WriteStream on: String new.
	f converter: EUCJPTextConverter new.
	[f atEnd]
		whileFalse: [writeStream nextPut: f next].
	f close.
	^ writeStream contents
]

{ #category : #private }
FileList >> readContentsEUCKR [
	| f writeStream |
	f := directory oldFileOrNoneNamed: self fullName.
	f ifNil: [^ 'For some reason, this file cannot be read'].
	writeStream := WriteStream on: String new.
	f converter: EUCKRTextConverter new.
	[f atEnd]
		whileFalse: [writeStream nextPut: f next].
	f close.
	^ writeStream contents
]

{ #category : #private }
FileList >> readContentsHex: brevity [
	"retrieve the contents from the external file unless it is too long.
	  Don't create a file here.  Check if exists."
	| f size data hexData s |

	f := directory oldFileOrNoneNamed: self fullName. 
	f == nil ifTrue: [^ 'For some reason, this file cannot be read' translated].
	f binary.
	((size := f size)) > 5000 & brevity
		ifTrue: [data := f next: 10000. f close. brevityState := #briefHex]
		ifFalse: [data := f contentsOfEntireFile. brevityState := #fullHex].

	s := WriteStream on: (String new: data size*4).
	0 to: data size-1 by: 16 do:
		[:loc | s nextPutAll: loc printStringHex; space;
			nextPut: $(; print: loc; nextPut: $); space; tab.
		loc+1 to: (loc+16 min: data size) do: [:i | s nextPutAll: (data at: i) printStringHex; space].
		s cr].
	hexData := s contents.

	^ contents := ((size > 5000) & brevity
		ifTrue: ['File ''{1}'' is {2} bytes long.
You may use the ''get'' command to read the entire file.

Here are the first 5000 characters...
------------------------------------------
{3}
------------------------------------------
... end of the first 5000 characters.' translated format: {fileName. size. hexData}]
		ifFalse: [hexData]).

]

{ #category : #private }
FileList >> readContentsShiftJIS [
	| f writeStream |
	f := directory oldFileOrNoneNamed: self fullName.
	f ifNil: [^ 'For some reason, this file cannot be read'].
	writeStream := WriteStream on: String new.
	f converter: ShiftJISTextConverter new.
	[f atEnd]
		whileFalse: [writeStream nextPut: f next].
	f close.
	^ writeStream contents
]

{ #category : #private }
FileList >> readContentsUTF8 [
	| f writeStream |
	f := directory oldFileOrNoneNamed: self fullName.
	f ifNil: [^ 'For some reason, this file cannot be read'].
	writeStream := WriteStream on: String new.
	f converter: UTF8TextConverter new.
	[f atEnd]
		whileFalse: [writeStream nextPut: f next].
	f close.
	^ writeStream contents
]

{ #category : #private }
FileList >> readGraphicContents [
	| form maxExtent ext |
	form := (Form fromFileNamed: self fullName) asFormOfDepth: Display depth.
	maxExtent := lastGraphicsExtent := self availableGraphicsExtent.
	ext := form extent.
	(maxExtent notNil and: [form extent <= maxExtent]) ifFalse: [
		form := form magnify: form boundingBox by: (maxExtent x / form width min: maxExtent y / form height) asPoint smoothing: 3].
	contents :=  ('Image extent: ', ext printString) asText,
				(String with: Character cr),
				(Text string: ' '
					attribute: (TextFontReference toFont: 
						(FormSetFont new
							fromFormArray: (Array with: form)
							asciiStart: Character space asInteger
							ascent: form height))).
	brevityState := #graphic.
	^contents
]

{ #category : #'file list' }
FileList >> readOnlyStream [
	"Answer a read-only stream on the selected file. For the various stream-reading services."

	^self directory ifNotNil: [ :dir | dir readOnlyFileNamed: self fileName ]
]

{ #category : #private }
FileList >> readServerBrief [
	| lString sizeStr fsize ff first5000 parts |
	"If file on server is known to be long, just read the beginning.  Cheat badly by reading the fileList string."

	listIndex = 0 ifTrue: [^ self].
	"Get size from file list entry"
	lString := list at: listIndex.
	parts := lString findTokens: '()'.
	sortMode = #name ifTrue: [sizeStr := (parts second findTokens: ' ') third].
	sortMode = #date ifTrue: [sizeStr := (parts first findTokens: ' ') third].
	sortMode = #size ifTrue: [sizeStr := (parts first findTokens: ' ') first].
	fsize := (sizeStr copyWithout: $,) asNumber.

	fsize <= 50000 ifTrue:
		[ff := directory oldFileOrNoneNamed: self fullName.
		ff ifNil: [^ 'For some reason, this file cannot be read' translated].
		contents := ff contentsOfEntireFile.
		brevityState := #fullFile.   "don't change till actually read"
		^ contents].

	"if brevityFlag is true, don't display long files when first selected"
	first5000 := directory getOnly: 3500 from: fileName.
	contents := 'File ''{1}'' is {2} bytes long.
You may use the ''get'' command to read the entire file.

Here are the first 3500 characters...
------------------------------------------
{3}
------------------------------------------
... end of the first 3500 characters.' translated format: {fileName. sizeStr. first5000}.
	brevityState := #briefFile.   "don't change till actually read"
	^ contents.


]

{ #category : #private }
FileList >> recentDirs [
	"Put up a menu and let the user select from the list of recently visited directories."

	| dirName |
	RecentDirs isEmpty ifTrue: [^self].
	dirName := UIManager default chooseFrom: RecentDirs values: RecentDirs.
	dirName == nil ifTrue: [^self].
	self directory: (FileDirectory on: dirName)
]

{ #category : #private }
FileList >> registeredFileReaderClasses [
	"return the list of classes that provide file reader services"

	^ FileServices registeredFileReaderClasses
]

{ #category : #initialization }
FileList >> release [

	self modelSleep
]

{ #category : #'server list' }
FileList >> removeServer [

	| choice names |
	self flag: #ViolateNonReferenceToOtherClasses.
	names := ServerDirectory serverNames.
	choice := UIManager default chooseFrom: names values: names.
	choice == nil ifTrue: [^ self].
	ServerDirectory removeServerNamed: choice
]

{ #category : #'file menu action' }
FileList >> renameFile [
	"Rename the currently selected file"
	| newName response |
	listIndex = 0 ifTrue: [^ self].
	self okToChange ifFalse: [^ self].
	(response := UIManager default request: 'NewFileName?' translated
 					initialAnswer: fileName)
		isEmpty ifTrue: [^ self].
	newName := response asFileName.
	newName = fileName ifTrue: [^ self].
	directory rename: fileName toBe: newName.
	self updateFileList.
	listIndex := list findFirst: [:item | (self fileNameFromFormattedItem: item) = newName].
	listIndex > 0 ifTrue: [fileName := newName].
	self changed: #fileListIndex.

]

{ #category : #private }
FileList >> resort: newMode [ 
	"Re-sort the list of files."
	| name |
	listIndex > 0 ifTrue: [ name := self fileNameFromFormattedItem: (list at: listIndex) ].
	sortMode := newMode.
	self pattern: pattern.
	name ifNotNil:
		[ fileName := name.
		listIndex := list findFirst:
			[ : item | (self fileNameFromFormattedItem: item) = name ].
		self
			 changed: #fileListIndex ;
			 changed: #labelString ].
	listIndex = 0 ifTrue: [ self changed: #contents ].
	self updateButtonRow
]

{ #category : #'directory tree' }
FileList >> rootDirectoryList [
	| dirList dir servers |
	dir := FileDirectory on: ''.
	dirList := dir directoryNames collect:[:each| dir directoryNamed: each]..
	dirList isEmpty ifTrue:[dirList := Array with: FileDirectory default].
	servers := ServerDirectory serverNames collect: [ :n | ServerDirectory serverNamed: n].
	"This is so FileListPlus will work on ancient Squeak versions."
	servers := servers select:[:each| each respondsTo: #localName].
	^dirList, servers
]

{ #category : #private }
FileList >> selectEncoding [

	| encodingItems |
	encodingItems := OrderedCollection new.
	TextConverter allSubclasses do: [:each | | names |
		names := each encodingNames.
		names notEmpty ifTrue: [ | label |
			label := '' writeStream.
			names do: [:eachName | label nextPutAll: eachName ] separatedBy: [ label nextPutAll: ', '].
			encodingItems add: {label contents. names first asSymbol}.
		].
	].
	brevityState := UIManager default
		chooseFrom: (encodingItems collect: [:spec| spec first])
		values: (encodingItems collect: [:spec| spec last]).
	brevityState ifNil: [brevityState := #needToGetBrief].

]

{ #category : #'directory tree' }
FileList >> selectedPath [
	| top here |
	top := FileDirectory root.
	here := directory.
	^(Array streamContents:[:s| | next |
		s nextPut: here.
		[next := here containingDirectory.
		top pathName = next pathName] whileFalse:[
			s nextPut: next.
			here := next.
		]]) reversed.
]

{ #category : #'own services' }
FileList >> serviceAddNewDirectory [
	"Answer a service entry characterizing the 'add new directory' command"

	^ SimpleServiceEntry 
		provider: self 
		label: 'add new directory' translatedNoop
		selector: #addNewDirectory
		description: 'adds a new, empty directory (folder)'  translatedNoop
]

{ #category : #'own services' }
FileList >> serviceAddNewFile [
	"Answer a service entry characterizing the 'add new file' command"

	^ SimpleServiceEntry 
			provider: self 
			label: 'add new file' translatedNoop
			selector: #addNewFile 
			description: 'create a new,. empty file, and add it to the current directory.' translatedNoop
]

{ #category : #'own services' }
FileList >> serviceAllFileOptions [

	^ {SimpleServiceEntry 
			provider: self 
			label: 'more...' translatedNoop
			selector: #offerAllFileOptions 
			description: 'show all the options available' translatedNoop}
]

{ #category : #'own services' }
FileList >> serviceCompressFile [
	"Answer a service for compressing a file"

	^ SimpleServiceEntry 
		provider: self 
		label: 'compress' translatedNoop
		selector: #compressFile 
		description: 'compress file' translatedNoop
		buttonLabel: 'compress' translatedNoop
]

{ #category : #'own services' }
FileList >> serviceCopyName [

	^ (SimpleServiceEntry 
		provider: self 
		label: 'copy name to clipboard' translatedNoop
		selector: #copyName 
		description:'copy name to clipboard' translatedNoop )
]

{ #category : #'own services' }
FileList >> serviceDeleteFile [

	^ (SimpleServiceEntry 
			provider: self 
			label: 'delete' translatedNoop
			selector: #deleteFile)
			description: 'delete the seleted item' translatedNoop
]

{ #category : #'own services' }
FileList >> serviceGet [
	"Answer a service for getting the entire file"

	^  (SimpleServiceEntry 
			provider: self 
			label: 'get entire file' translatedNoop
			selector: #get
			description: 'if the file has only been partially read in, because it is very large, read the entire file in at this time.' translatedNoop)
]

{ #category : #'own services' }
FileList >> serviceGetEncodedText [

	^  (SimpleServiceEntry 
			provider: self 
			label: 'view as encoded text' translatedNoop
			selector: #getEncodedText
			description: 'view as encoded text' translatedNoop)


]

{ #category : #'own services' }
FileList >> serviceGetHex [

	^  (SimpleServiceEntry 
			provider: self 
			label: 'view as hex' translatedNoop
			selector: #getHex
			description: 'view as hex' translatedNoop)
			

]

{ #category : #'own services' }
FileList >> serviceRenameFile [

	^ (SimpleServiceEntry 
			provider: self 
			label: 'rename' translatedNoop
			selector: #renameFile 
			description: 'rename file' translatedNoop)
]

{ #category : #'own services' }
FileList >> serviceSortByDate [
	"Answer a service for sorting by date"

	^  (SimpleServiceEntry new
			provider: self 
			label: 'by date' translatedNoop 
			selector: #sortByDate 
			description: 'sort entries by date' translatedNoop)
		extraSelector: #sortingByDate;
		buttonLabel: 'date' translatedNoop
]

{ #category : #'own services' }
FileList >> serviceSortByName [
	"Answer a service for soring by name"

	^ (SimpleServiceEntry new
		provider: self label: 'by name' translatedNoop
		selector: #sortByName 
		description: 'sort entries by name' translatedNoop)
		extraSelector: #sortingByName;
		buttonLabel: 'name' translatedNoop
]

{ #category : #'own services' }
FileList >> serviceSortBySize [
	"Answer a service for sorting by size"

	^  (SimpleServiceEntry 
			provider: self 
			label: 'by size' translatedNoop
			selector: #sortBySize
			description: 'sort entries by size' translatedNoop)
				extraSelector: #sortingBySize;
				buttonLabel: 'size' translatedNoop
]

{ #category : #'own services' }
FileList >> serviceViewContentsInWorkspace [
	"Answer a service for viewing the contents of a file in a workspace"
	
	^ (SimpleServiceEntry provider: self label: 'workspace with contents' translatedNoop
			selector: #viewContentsInWorkspace)
			description: 'open a new Workspace whose contents are set to the contents of this file' translatedNoop
]

{ #category : #'file list menu' }
FileList >> servicesFileContentsMenu: aMenu [
	"Construct aMenu to have items appropriate for the file browser's code pane, for the unshifted state"
	<fileContentsMenuShifted: false>
	
	fileName ifNotNil: [| services maybeLine extraLines | 
		services := OrderedCollection new.
		(#(briefHex briefFile needToGetBriefHex needToGetBrief) includes: brevityState) ifTrue:
			[services add: self serviceGet].
		(#(fullHex briefHex needToGetFullHex needToGetBriefHex) includes: brevityState) ifFalse:
			[services add: self serviceGetHex].
		(#(needToGetShiftJIS needToGetEUCJP needToGetCNGB needToGetEUCKR needToGetUTF8) includes: brevityState) ifFalse:
			[services add: self serviceGetEncodedText].
		maybeLine := services size.
		(FileStream sourceFileSuffixes includes: self suffixOfSelectedFile) ifTrue:
			[services addAll:
				(self servicesFromSelectorSpecs:
					#(fileIntoNewChangeSet: fileIn: browseChangesFile: browseFile:))].

		extraLines := OrderedCollection new.
		maybeLine > 0 ifTrue: [extraLines add: maybeLine].
		services size > maybeLine ifTrue: [extraLines add: services size].
		aMenu 
			addServices: services
			for: self
			extraLines: extraLines].
	^ aMenu

]

{ #category : #'own services' }
FileList >> servicesFromSelectorSpecs: symbolArray [
	"Answer an array of services represented by the incoming symbols, eliminating any that do not have a currently-registered service.  Pass the symbol #- along unchanged to serve as a separator between services"

	"FileList new servicesFromSelectorSpecs: #(fileIn: fileIntoNewChangeSet: browseChangesFile:)"

	| services col | 
	col := OrderedCollection new.
	services := FileServices allRegisteredServices, (self myServicesForFile: #dummy suffix: '*').
	symbolArray do: 
		[:sel | | res | 
			sel == #-
				ifTrue:
					[col add: sel]
				ifFalse:
					[res := services
							detect: [:each | each selector = sel] ifNone: [nil].
					res notNil
							ifTrue: [col add: res]]].
	^ col
]

{ #category : #'volume menu' }
FileList >> servicesVolumeMenu: aMenu [
	<volumeMenu>
	aMenu
		addServices: (self itemsForDirectory: self directory)
		for: self
		extraLines: #().
	^aMenu.
]

{ #category : #'directory tree' }
FileList >> setDirectoryTo: dir [
	"Set the current directory shown in the FileList. 
	Does not allow setting the directory to nil since this blows up in various places."
	dir ifNil:[^self].
	self directory: dir.
	brevityState := #FileList.
	self changed: #fileList.
	self changed: #contents.
	self changed: #pathAndPattern.
]

{ #category : #initialization }
FileList >> setFileStream: aStream [
	"Used to initialize a spawned file editor.  Sets directory too."
	self directory: aStream directory.
	fileName := aStream localName.
	pattern := '*'.
	listIndex := 1.  "pretend a file is selected"
	aStream close.
	brevityState := #needToGetBrief.
	self 
		changed: #contents ; 
		changed: #labelString
]

{ #category : #'file list menu' }
FileList >> shiftedFileContentsMenu: aMenu [
	"Delegate the shifted menu to the default shifted menu"
	<fileContentsMenuShifted: true>
	^ aMenu addList: self class shiftedYellowButtonMenuItems; yourself

]

{ #category : #private }
FileList >> sortBlock [
	"Answer block to decide what order to display the directory entries."

	^ [ :x :y |
			(x isDirectory = y isDirectory) 
				ifTrue: [  
					"sort by user-specified criterion"
					sortMode = #name 
						ifTrue: [(x name compare: y name) <= 2]
						ifFalse: [ sortMode = #date
							ifTrue: [ x modificationTime = y modificationTime
									ifTrue: [ (x name compare: y name) <= 2 ]
									ifFalse: [ x modificationTime > y modificationTime ] ]
							ifFalse: [ "size"
								x fileSize = y fileSize 
									ifTrue: [ (x name compare: y name) <= 2 ]
									ifFalse: [ x fileSize > y fileSize ] ] ] ]
				ifFalse: [
					"directories always precede files"
					x isDirectory ] ]
]

{ #category : #'file menu action' }
FileList >> sortByDate [
	self resort: #date
]

{ #category : #'file menu action' }
FileList >> sortByName [
	self resort: #name
]

{ #category : #'file menu action' }
FileList >> sortBySize [
	self resort: #size
]

{ #category : #private }
FileList >> sortingByDate [
	^ sortMode == #date
]

{ #category : #private }
FileList >> sortingByName [
	^ sortMode == #name
]

{ #category : #private }
FileList >> sortingBySize [
	^ sortMode == #size
]

{ #category : #'file menu action' }
FileList >> spawn: code [
	"Open a simple Edit window"

	listIndex = 0 ifTrue: [^ self].
	self class openEditorOn: (directory readOnlyFileNamed: fileName)
				"read only just for initial look"
			editString: code
]

{ #category : #private }
FileList >> step [
	| ext |
	brevityState = #graphic ifTrue: [
		ext := self availableGraphicsExtent.
		ext = lastGraphicsExtent ifFalse: [
			lastGraphicsExtent := ext.
			brevityState := #needToGetGraphic.
			self changed: #contents]]
]

{ #category : #private }
FileList >> stepTimeIn: aWindow [
	^500
]

{ #category : #'directory tree' }
FileList >> subDirectoriesOf: aDirectory [
	"provide a list of subdirectory names sorted alphnum-no-case"

	^(aDirectory directoryNames sorted: [:a :b| (a compare: b) <= 2]) collect:[:each| aDirectory directoryNamed: each].
]

{ #category : #'file list menu' }
FileList >> suffixOfSelectedFile [
	"Answer the file extension of the receiver's selected file"
	^ FileServices suffixOf: self fullName.
]

{ #category : #toolbuilder }
FileList >> topConstantHeightFrame: height fromLeft: leftFraction width: rightFraction [
	^LayoutFrame new
		topFraction: 0 offset: 0;
		leftFraction: leftFraction offset: 0;
		rightFraction: (leftFraction + rightFraction) offset: 0;
		bottomFraction: 0 offset: height;
		yourself.
]

{ #category : #initialization }
FileList >> universalButtonServices [
	"Answer a list of services underlying the universal buttons in their initial inception.  For the moment, only the sorting buttons are shown."

	^ {self serviceSortByName. self serviceSortByDate. self serviceSortBySize}
]

{ #category : #updating }
FileList >> update: aParameter [
	"Receive a change notice from an object of whom the receiver is a dependent"

	(aParameter == #fileListChanged) ifTrue: [self updateFileList].
	super update: aParameter
]

{ #category : #initialization }
FileList >> updateButtonRow [
	"Dynamically update the contents of the button row, if any."
	self changed: #getButtonRow.
]

{ #category : #private }
FileList >> updateFileList [
	"Update my files list with file names in the current directory  
	that match the pattern.
	The pattern string may have embedded newlines or semicolons; these separate different patterns."
	| patterns |
	patterns := OrderedCollection new.
	Cursor wait showWhile: [
	(pattern findTokens: (String with: Character cr with: Character lf with: $;))
		do: [ :each |
			(each includes: $*) | (each includes: $#)
					ifTrue: [ patterns add: each]
					ifFalse: [each isEmpty
										ifTrue: [ patterns add: '*']
										ifFalse: [ patterns add: '*' , each , '*']]].

	list := self listForPatterns: patterns.
	listIndex := 0.
	volListIndex := volList size.
	fileName := nil.
	contents := ''.
	self changed: #volumeListIndex.
	self changed: #fileList.
	self updateButtonRow]
]

{ #category : #'volume list and pattern' }
FileList >> veryDeepFixupWith: deepCopier [
	super veryDeepFixupWith: deepCopier.
	volListIndex := 1.
	self directory: FileDirectory default.
	self updateFileList
]

{ #category : #'own services' }
FileList >> viewContentsInWorkspace [
	"View the contents of my selected file in a new workspace"
	
	| aString aFileStream aName |
	aString := (aFileStream := directory readOnlyFileNamed: self fullName) setConverterForCode contentsOfEntireFile.
	aName := aFileStream localName.
	aFileStream close.
	UIManager default edit: aString withSqueakLineEndings label: 'Workspace from ', aName
]

{ #category : #'volume list and pattern' }
FileList >> volumeList [
	"Answer the current list of volumes."

	^ volList

]

{ #category : #'volume list and pattern' }
FileList >> volumeListIndex [
	"Answer the index of the currently selected volume."

	^ volListIndex

]

{ #category : #'volume list and pattern' }
FileList >> volumeListIndex: index [
	"Select the volume name having the given index."

	| delim path |
	volListIndex := index.
	index = 1 
		ifTrue: [self directory: (FileDirectory on: '')]
		ifFalse: [delim := directory pathNameDelimiter.
				path := String streamContents: [:strm |
					2 to: index do: [:i |
						strm nextPutAll: (volList at: i) withBlanksTrimmed.
						i < index ifTrue: [strm nextPut: delim]]].
				self directory: (directory on: path)].
	brevityState := #FileList.
	self addPath: path.
	self changed: #fileList.
	self changed: #contents.
	self updateButtonRow.
]

{ #category : #'volume menu' }
FileList >> volumeMenu: aMenu [
	^ self menu: aMenu for: #(volumeMenu volumeMenuShifted:)

]

{ #category : #'drag\'n\'drop' }
FileList >> wantsDraggedObject: anObject [

	^ anObject class == DirectoryEntryFile
]

{ #category : #private }
FileList >> wantsSteps [
	^true
]
