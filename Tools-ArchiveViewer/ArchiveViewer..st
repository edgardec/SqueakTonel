"
This is a viewer window that allows editing and viewing of Zip archives.
"
Class {
	#name : #ArchiveViewer,
	#superclass : #SystemWindow,
	#instVars : [
		'archive',
		'fileName',
		'memberIndex',
		'viewAllContents'
	],
	#category : #'Tools-ArchiveViewer'
}

{ #category : #'instance creation' }
ArchiveViewer class >> addFileToNewZip: fullName [

	"Add the currently selected file to a new zip"
	| zip |
	zip := (ZipArchive new) 
			addFile: fullName 
			as: (FileDirectory localNameFor: fullName); yourself.
	(self open) archive: zip

]

{ #category : #'class initialization' }
ArchiveViewer class >> deleteTemporaryDirectory [
	"
	ArchiveViewer deleteTemporaryDirectory
	"

	| dir |
	(dir := self temporaryDirectory) exists ifTrue: [ dir recursiveDelete ].
]

{ #category : #'parts bin' }
ArchiveViewer class >> descriptionForPartsBin [

	^ self partName: 'Zip Tool' translatedNoop
		categories: {'Tools' translated}
		documentation: 'A viewer and editor for Zip archive files' translatedNoop

]

{ #category : #'file list services' }
ArchiveViewer class >> extractAllFrom: aFileName [
	(self new) fileName: aFileName; extractAll
]

{ #category : #'fileIn\/Out' }
ArchiveViewer class >> fileReaderServicesForFile: fullName suffix: suffix [ 

	|  services |
	services := OrderedCollection new.
	services add: self serviceAddToNewZip.
	({'zip'.'sar'.'pr'. 'mcz'. '*'} includes: suffix)
		ifTrue: [services add: self serviceOpenInZipViewer.
				services add: self serviceExtractAll].
	^ services
]

{ #category : #'class initialization' }
ArchiveViewer class >> initialize [
	"ArchiveViewer initialize"

	FileServices registerFileReader: self.
	Smalltalk addToShutDownList: self.
]

{ #category : #'instance creation' }
ArchiveViewer class >> open [
	^(self new) createWindow; openInWorld.
]

{ #category : #'instance creation' }
ArchiveViewer class >> openOn: aFileName [
	| newMe |
	newMe := self new.
	newMe createWindow; fileName: aFileName; openInWorld.
	^newMe
]

{ #category : #'file list services' }
ArchiveViewer class >> serviceAddToNewZip [
	"Answer a service for adding the file to a new zip"

	^ FileModifyingSimpleServiceEntry 
		provider: self
		label: 'add file to new zip' translatedNoop
		selector: #addFileToNewZip:
		description: 'add file to new zip' translatedNoop
		buttonLabel: 'to new zip' translatedNoop
]

{ #category : #'file list services' }
ArchiveViewer class >> serviceExtractAll [
	"Answer a service for opening in a zip viewer"

	^ FileModifyingSimpleServiceEntry 
		provider: self
		label: 'extract all to...' translatedNoop
		selector: #extractAllFrom: 
		description: 'extract all files to a user-specified directory' translatedNoop
		buttonLabel: 'extract all' translatedNoop
]

{ #category : #'class initialization' }
ArchiveViewer class >> serviceOpenInZipViewer [
	"Answer a service for opening in a zip viewer"

	^ SimpleServiceEntry
		provider: self
		label: 'open in zip viewer' translatedNoop
		selector: #openOn: 
		description: 'open in zip viewer' translatedNoop
		buttonLabel: 'open zip' translatedNoop
]

{ #category : #'fileIn\/Out' }
ArchiveViewer class >> services [
	
	^ Array 
		with: self serviceAddToNewZip
		with: self serviceOpenInZipViewer
		
					
			
]

{ #category : #'class initialization' }
ArchiveViewer class >> shutDown: quitting [
	quitting ifTrue: [ self deleteTemporaryDirectory ].
]

{ #category : #'fileIn\/Out' }
ArchiveViewer class >> temporaryDirectory [
	"Answer a directory to use for unpacking files for the file list services."
	^FileDirectory default directoryNamed: '.archiveViewerTemp'
]

{ #category : #'initialize-release' }
ArchiveViewer class >> unload [

	FileServices unregisterFileReader: self 
]

{ #category : #'member operations' }
ArchiveViewer >> addDirectory [
	|  directory |
	self canAddMember ifFalse: [ ^self ].
	directory := UIManager default chooseDirectory.
	directory
		ifNil: [^ self].

	archive addTree: directory removingFirstCharacters: directory pathName size + 1.
	self memberIndex: 0.
	self changed: #memberList.
]

{ #category : #'member operations' }
ArchiveViewer >> addMember [
	| local fName |
	self canAddMember ifFalse: [ ^self ].
	fName := UIManager default chooseFileMatching: '*' .
	fName ifNil: [ ^self ].
	
	local := FileDirectory localNameFor: fName.
	(archive addFile: fName as: local)
		desiredCompressionMethod: ZipArchive compressionDeflated.
	self memberIndex: self members size.
	self changed: #memberList.
]

{ #category : #'member operations' }
ArchiveViewer >> addMemberFromClipboard [
	| string newName |
	self canAddMember ifFalse: [ ^self ].
	string := Clipboard clipboardText asString.
	newName := UIManager default
		request: 'New name for member:'
		initialAnswer: 'clipboardText'.
	newName notEmpty ifTrue: [
		(archive addString: string as: newName) desiredCompressionMethod: ZipArchive compressionDeflated.
		self memberIndex: self members size.
		self changed: #memberList.
	]

]

{ #category : #accessing }
ArchiveViewer >> archive [
	^archive
]

{ #category : #initialization }
ArchiveViewer >> archive: aZipArchive [
	archive := aZipArchive.
	self model: aZipArchive.
	self setLabel: 'New Zip Archive'.
	self memberIndex: 0.
	self changed: #memberList
]

{ #category : #initialization }
ArchiveViewer >> briefContents [
	"Trim to 5000 characters. If the member is longer, then point out that it is trimmed.
	Also warn if the member has a corrupt CRC-32."

	| stream subContents errorMessage |
	self selectedMember ifNil: [^ ''].
	errorMessage := ''.
	stream := WriteStream on: (String new: (self selectedMember uncompressedSize min: 5500)).

	[ self selectedMember uncompressedSize > 5000
		ifTrue: [ |  lastLineEndingIndex tempIndex |
			subContents := self selectedMember contentsFrom: 1 to: 5000.
			lastLineEndingIndex := subContents lastIndexOf: Character cr.
			tempIndex := subContents lastIndexOf: Character lf.
			tempIndex > lastLineEndingIndex ifTrue: [lastLineEndingIndex := tempIndex].
			lastLineEndingIndex = 0
				ifFalse: [subContents := subContents copyFrom: 1 to: lastLineEndingIndex]]
		ifFalse: [ subContents := self selectedMember contents ]]
			on: CRCError do: [ :ex |
				errorMessage := String streamContents: [ :s |
					s nextPutAll: '[ ';
						nextPutAll: (ex messageText copyUpToLast: $( );
						nextPutAll: ' ]' ].
				ex proceed ].

		(errorMessage isEmpty not or: [ self selectedMember isCorrupt ]) ifTrue: [
			stream nextPutAll: '********** WARNING! Member is corrupt! ';
					nextPutAll: errorMessage;
					nextPutAll: ' **********'; cr ].

	self selectedMember uncompressedSize > 5000
		ifTrue: [
			stream nextPutAll: 'File ';
				print: self selectedMember fileName;
				nextPutAll: ' is ';
				print: self selectedMember uncompressedSize;
				nextPutAll: ' bytes long.'; cr;
				nextPutAll: 'Click the ''View All Contents'' button above to see the entire file.'; cr; cr;
				nextPutAll: 'Here are the first ';
				print: subContents size;
				nextPutAll: ' characters...'; cr;
				next: 40 put: $-; cr;
				nextPutAll: subContents;
				next: 40 put: $-; cr;
				nextPutAll: '... end of the first ';
				print: subContents size;
				nextPutAll: ' characters.' ]
		ifFalse: [ stream nextPutAll: self selectedMember contents ].
		
		^stream contents

]

{ #category : #menu }
ArchiveViewer >> buildWindowMenu [
	| menu |
	menu := super buildWindowMenu.
	menu addLine.
	menu add: 'inspect archive' target: archive action: #inspect.
	menu add: 'write prepending file...' target: self action: #writePrependingFile.
	^menu.
]

{ #category : #initialization }
ArchiveViewer >> buttonColor [
	^self defaultBackgroundColor darker
]

{ #category : #initialization }
ArchiveViewer >> buttonOffColor [
	^self defaultBackgroundColor darker
]

{ #category : #initialization }
ArchiveViewer >> buttonOnColor [
	^self defaultBackgroundColor
]

{ #category : #'member operations' }
ArchiveViewer >> canAddMember [
	^archive notNil
]

{ #category : #'archive operations' }
ArchiveViewer >> canCreateNewArchive [
	^true
]

{ #category : #'member operations' }
ArchiveViewer >> canDeleteMember [
	^memberIndex > 0
]

{ #category : #'archive operations' }
ArchiveViewer >> canExtractAll [
	^self members notEmpty
]

{ #category : #'member operations' }
ArchiveViewer >> canExtractMember [
	^memberIndex > 0
]

{ #category : #'archive operations' }
ArchiveViewer >> canOpenNewArchive [
	^true
]

{ #category : #'member operations' }
ArchiveViewer >> canRenameMember [
	^memberIndex > 0
]

{ #category : #'archive operations' }
ArchiveViewer >> canSaveArchive [
	^archive notNil
]

{ #category : #'member operations' }
ArchiveViewer >> canViewAllContents [
	^memberIndex > 0 and: [ viewAllContents not ]
]

{ #category : #'member operations' }
ArchiveViewer >> changeViewAllContents [

	(viewAllContents not and: [ self selectedMember notNil and: [ self selectedMember uncompressedSize > 50000 ]])
		ifTrue: [ (self confirm: 'This member''s size is ',
			(self selectedMember uncompressedSize asString),
			'; do you really want to see all that data?')
				ifFalse: [ ^self ]
		].

	viewAllContents := viewAllContents not.
	self changed: #contents
]

{ #category : #'archive operations' }
ArchiveViewer >> commentArchive [
	| newName |
	archive ifNil: [ ^self ].
	newName := UIManager default
			request: 'New comment for archive:'
			initialAnswer: archive zipFileComment.
	archive zipFileComment: newName.
]

{ #category : #'member operations' }
ArchiveViewer >> commentMember [
	| newName |
	newName := UIManager default
			request: 'New comment for member:'
			initialAnswer: self selectedMember fileComment.
	self selectedMember fileComment: newName.
]

{ #category : #initialization }
ArchiveViewer >> contents [
	| contents errorMessage |
	self selectedMember ifNil: [^ ''].
	viewAllContents ifFalse: [^ self briefContents].

 	[ contents := self selectedMember contents ]
		on: CRCError
		do: [ :ex | errorMessage := String streamContents: [ :stream |
			stream nextPutAll: '********** WARNING! Member is corrupt! [ ';
			nextPutAll: (ex messageText copyUpToLast: $( );
			nextPutAll: '] **********'; cr ].
			ex proceed ].

	^self selectedMember isCorrupt
		ifFalse: [ contents ]
		ifTrue: [ errorMessage, contents ]
]

{ #category : #initialization }
ArchiveViewer >> contents: aText [
	self shouldNotImplement.
]

{ #category : #initialization }
ArchiveViewer >> createButtonBar [
	| bar |
	
	bar := AlignmentMorph newRow.
	bar
		color: self defaultBackgroundColor;
		rubberBandCells: false;
		vResizing: #shrinkWrap;
		cellGap: 6 @ 0.
	#(#('new archive' #canCreateNewArchive #createNewArchive 'Create a new, empty archive and discard this one') #('load archive' #canOpenNewArchive #openNewArchive 'Open another archive and discard this one') #('save archive' #canSaveArchive #saveArchive 'Save this archive under a new name') #('extract all' #canExtractAll #extractAll 'Extract all this archive''s members into a directory') #('add file' #canAddMember #addMember 'Add a file to this archive') #('add clipboard' #canAddMember #addMemberFromClipboard 'Add the contents of the clipboard as a new file') #('add dir ' #canAddMember #addDirectory 'Add the entire contents of a directory, with all of its subdirectories') #('extract member' #canExtractMember #extractMember 'Extract the selected member to a file') #('delete member' #canDeleteMember #deleteMember 'Remove the selected member from this archive') #('rename member' #canRenameMember #renameMember 'Rename the selected member') #('view all' #canViewAllContents #changeViewAllContents 'Toggle the view of all the selected member''s contents')) 
		do: 
			[:arr | 
			| button |
			(button := PluggableButtonMorph 
						on: self
						getState: arr second
						action: arr third)
				vResizing: #spaceFill;
				hResizing: #spaceFill;
				onColor: self buttonOnColor offColor: self buttonOffColor;
				label: arr first withCRs;
				setBalloonText: arr fourth.
			bar addMorphBack: button].
	^bar
]

{ #category : #initialization }
ArchiveViewer >> createListHeadingUsingFont: font [
	| sm |
	sm := StringMorph contents: ' order  uncomp   comp   CRC-32       date     time     file name'.
	font ifNotNil: [ sm font: font ].
	^(AlignmentMorph newColumn)
		color: self defaultBackgroundColor;
		addMorph: sm;
		yourself.
]

{ #category : #'archive operations' }
ArchiveViewer >> createNewArchive [
	self setLabel: '(new archive)'.
	archive := ZipArchive new.
	self memberIndex: 0.
	self changed: #memberList.
]

{ #category : #initialization }
ArchiveViewer >> createWindow [
	| list heading font text buttonBar |

	font := (TextStyle named: #DefaultFixedTextStyle)
		ifNotNil: [ :ts | ts fontArray first].

	buttonBar := self createButtonBar.
	self addMorph: buttonBar
		fullFrame: (LayoutFrame fractions: (0@0 corner: 1.0@0.0) offsets: (0@0 corner: 0@34)).

	self minimumExtent: (buttonBar fullBounds width + 20) @ 230.
	self extent: self minimumExtent.

	heading := self createListHeadingUsingFont: font.
	self addMorph: heading
		fullFrame: (LayoutFrame fractions: (0@0 corner: 1.0@0.0) offsets: (0@34 corner: 0@44)).

	(list := PluggableListMorph new)
		on: self list: #memberList
		selected: #memberIndex changeSelected: #memberIndex:
		menu: #memberMenu:shifted: keystroke: nil.
	list color: self defaultBackgroundColor.

	font ifNotNil: [list font: font].
	self addMorph: list
		fullFrame: (LayoutFrame fractions: (0@0 corner: 1.0@0.8) offsets: (0@50 corner: 0@0)).

	text := PluggableTextMorph on: self 
			text: #contents accept: nil
			readSelection: nil menu: nil.
	self addMorph: text
		frame: (0@0.8 corner: 1.0@1.0).
	text lock.

	self setLabel: 'Ned''s Zip Viewer'
]

{ #category : #accessing }
ArchiveViewer >> defaultBackgroundColor [

	^ Color veryVeryLightGray
]

{ #category : #accessing }
ArchiveViewer >> defaultColor [

	^ Color veryVeryLightGray
]

{ #category : #'member operations' }
ArchiveViewer >> deleteMember [
	self canDeleteMember ifFalse: [ ^self ].
	archive removeMember: self selectedMember.
	self memberIndex:  0.
	self changed: #memberList.

]

{ #category : #accessing }
ArchiveViewer >> directory [
	"For compatibility with file list."
	^self error: 'should use readOnlyStream instead!'
]

{ #category : #'member list' }
ArchiveViewer >> displayLineFor: aMember [
	| stream dateTime index |
	index := self archive members indexOf: aMember.
	stream := WriteStream on: (String new: 60).
	dateTime := Time dateAndTimeFromSeconds: aMember lastModTime. 
	stream
	nextPutAll: (index printString padded: #left to: 4 with: $  );
	space;
		nextPutAll: (aMember uncompressedSize printString padded: #left to: 8 with: $  );
		space; space;
		nextPutAll: (aMember compressedSize printString padded: #left to: 8 with: $  );
		space; space;
		nextPutAll: (aMember crc32String );
		space; space.
	dateTime first printOn: stream format: #(3 2 1 $- 2 1 2).
	stream space; space.
	dateTime second print24: true showSeconds: false on: stream.
	stream space; space;
		nextPutAll: (aMember fileName ).
	^stream contents
]

{ #category : #'member order' }
ArchiveViewer >> downMember [
| temp |
	temp := (self archive members) at: memberIndex.
	self archive members at: memberIndex put: (self archive members at: memberIndex  + 1).
	self archive members at: (memberIndex  +1) put: temp.
	self memberIndex:  0.
	self changed: #memberList.
]

{ #category : #'archive operations' }
ArchiveViewer >> extractAll [
	| directory |

	self canExtractAll ifFalse: [^ self].
	directory := UIManager default chooseDirectory.
	directory
		ifNil: [^ self].

	UIManager default informUserDuring: [:bar| archive extractAllTo: directory informing: bar].
	


]

{ #category : #'archive operations' }
ArchiveViewer >> extractAllPossibleInDirectory: directory [
	"Answer true if I can extract all the files in the given directory safely.
	Inform the user as to problems."
	| conflicts |
	self canExtractAll ifFalse: [ ^false ].
	conflicts := Set new.
	self members do: [ :ea | | fullName |
		fullName := directory fullNameFor: ea localFileName.
		(ea usesFileNamed: fullName) ifTrue: [ conflicts add: fullName ].
	].
	conflicts notEmpty ifTrue: [ | str |
		str := WriteStream on: (String new: 200).
		str nextPutAll: 'The following file(s) are needed by archive members and cannot be overwritten:';
			cr.
		conflicts do: [ :ea | str nextPutAll: ea ] separatedBy: [ str cr ].
		self inform: str contents.
		^false.
	].
	conflicts := Set new.
	self members do: [ :ea | | fullName  |
		fullName := directory relativeNameFor: ea localFileName.
		(directory fileExists: fullName)
			ifTrue: [ conflicts add: fullName ].
	].
	conflicts notEmpty ifTrue: [ | str |
		str := WriteStream on: (String new: 200).
		str nextPutAll: 'The following file(s) will be overwritten:'; cr.
		conflicts do: [ :ea | str nextPutAll: ea ] separatedBy: [ str cr ].
		str cr; nextPutAll: 'Is this OK?'.
		^self confirm: str contents.
	].
	^true.

]

{ #category : #'archive operations' }
ArchiveViewer >> extractDirectoriesIntoDirectory: directory [ 
	(self members select: [:ea | ea isDirectory]) 
		do: [:ea | ea extractInDirectory: directory]
]

{ #category : #'archive operations' }
ArchiveViewer >> extractFilesIntoDirectory: directory [ 
	(self members reject: [:ea | ea isDirectory]) 
		do: [:ea | ea extractInDirectory: directory]
]

{ #category : #'member operations' }
ArchiveViewer >> extractMember [
	"Extract the member after prompting for a filename.
	Answer the filename, or nil if error."

	| name |
	self canExtractMember ifFalse: [ ^nil ].
	name := FileSaverDialog openOn: FileDirectory default.
	name ifNil: [ ^nil ].
	(archive canWriteToFileNamed: name)
		ifFalse: [ self inform: name, ' is used by one or more members
in your archive, and cannot be overwritten.
Try extracting to another file name'.
			^nil ].
	self selectedMember extractToFileNamed: name.
	^name
]

{ #category : #accessing }
ArchiveViewer >> fileName [
	^fileName
]

{ #category : #initialization }
ArchiveViewer >> fileName: aString [
	archive := ZipArchive new readFrom: aString.
	self setLabel: aString.
	self memberIndex:  0.
	self changed: #memberList
]

{ #category : #accessing }
ArchiveViewer >> fullName [
	"For compatibility with FileList services.
	If this is called, it means that a service that requires a real filename has been requested.
	So extract the selected member to a temporary file and return that name."

	| fullName dir |
	self canExtractMember ifFalse: [ ^nil ].
	dir := FileDirectory default directoryNamed: '.archiveViewerTemp'.
	fullName := dir fullNameFor: self selectedMember localFileName.
	self selectedMember extractInDirectory: dir.
	^fullName
]

{ #category : #'member list' }
ArchiveViewer >> highlightMemberList: list with: morphList [
	(morphList at: self memberIndex) color: Color red
]

{ #category : #initialization }
ArchiveViewer >> initialize [
	super initialize.
	memberIndex := 0.
	viewAllContents := false.

]

{ #category : #'parts bin' }
ArchiveViewer >> initializeToStandAlone [
	self initialize createWindow.
]

{ #category : #'member operations' }
ArchiveViewer >> inspectMember [
	self selectedMember inspect
]

{ #category : #'member list' }
ArchiveViewer >> memberIndex [
	^memberIndex
]

{ #category : #'member list' }
ArchiveViewer >> memberIndex: n [
	memberIndex := n.
	viewAllContents := false.
	self changed: #memberIndex.
	self changed: #contents.
]

{ #category : #'member list' }
ArchiveViewer >> memberList [
	^ self members collect: [ :ea | self displayLineFor: ea ]
]

{ #category : #'member list' }
ArchiveViewer >> memberMenu: menu shifted: shifted [
	| services |

	menu
		add: 'Comment archive' target: self selector: #commentArchive;
		balloonTextForLastItem: 'Add a comment for the entire archive'.

	self selectedMember ifNotNil: [ :member |
		menu
			addLine;
			add: 'Inspect member' target: self selector: #inspectMember;
			balloonTextForLastItem: 'Inspect the selected member';
			add: 'Comment member' target: self selector: #commentMember;
			balloonTextForLastItem: 'Add a comment for the selected member';
			addLine;
			add: 'member go up in order ' target: self selector: #upMember;
			add: 'member go down in order ' target: self selector: #downMember;
			add: 'select member order ' target: self selector: #toIndexPlace;
			addLine.
		services := FileServices itemsForFile: member fileName.
		menu addServices2: services for: self extraLines: #().
	].


	^menu
]

{ #category : #accessing }
ArchiveViewer >> members [
	^archive ifNil: [ #() asOrderedCollection ]
		ifNotNil: [ archive members asOrderedCollection ]
]

{ #category : #'archive operations' }
ArchiveViewer >> openNewArchive [
	|  result |
	result := UIManager default chooseFileMatching: '*' .
	result ifNil: [ ^self ].
	self fileName: result

]

{ #category : #'message handling' }
ArchiveViewer >> perform: selector orSendTo: otherTarget [
	^ self perform: selector
]

{ #category : #accessing }
ArchiveViewer >> readOnlyStream [
	"Answer a read-only stream on the selected member.
	For the various stream-reading services."

	^self selectedMember ifNotNil: [ :mem | mem contentStream ascii ]
]

{ #category : #'member operations' }
ArchiveViewer >> renameMember [
	| newName |
	self canRenameMember ifFalse: [ ^self ].
	newName := UIManager default
		request: 'New name for member:'
		initialAnswer: self selectedMember fileName.
	newName notEmpty ifTrue: [
		self selectedMember fileName: newName.
		self changed: #memberList
	]
]

{ #category : #'archive operations' }
ArchiveViewer >> saveArchive [
	| result name |
	
	name := FileDirectory  localNameFor: labelString .
	self canSaveArchive ifFalse: [ ^self ].
	result := UIManager default
		saveFilenameRequest: 'Save this zip to'
		initialAnswer:  name.
	result ifNil: [ ^self ].
	
	(archive canWriteToFileNamed: result)
		ifFalse: [ self inform: name, ' is used by one or more members
in your archive, and cannot be overwritten.
Try writing to another file name'.
			^self ].
	[ archive writeToFileNamed: result ] on: Error do: [ :ex | self inform: ex description. ].
	self setLabel: name asString.
	self changed: #memberList	"in case CRC's and compressed sizes got set"
]

{ #category : #accessing }
ArchiveViewer >> selectedMember [
	^memberIndex
		ifNil: [ nil ]
		ifNotNil: [ self members at: memberIndex ifAbsent: [ ] ]
]

{ #category : #initialization }
ArchiveViewer >> stream: aStream [
	archive := ZipArchive new readFrom: aStream.
	self setLabel: aStream fullName.
	self memberIndex:  0.
	self changed: #memberList
]

{ #category : #'member order' }
ArchiveViewer >> toIndexPlace [
| index max temp |
max := self archive members size.
index :=0.
[index := (UIManager default
		request: 'To which index '
		initialAnswer:  '1') asInteger.
		index between: 1 and: max] whileFalse.
	temp := (self archive members) at: memberIndex.
	self archive members at: memberIndex put: (self archive members at: index).
	self archive members at: index put: temp.
	self memberIndex:  0.
	self changed: #memberList.
]

{ #category : #'member order' }
ArchiveViewer >> upMember [
| temp |
	temp := (self archive members) at: memberIndex.
	self archive members at: memberIndex put: (self archive members at: memberIndex  -1).
	self archive members at: (memberIndex  -1) put: temp.
	self memberIndex:  0.
	self changed: #memberList.
]

{ #category : #initialization }
ArchiveViewer >> windowIsClosing [
	archive ifNotNil: [ archive close ].
]

{ #category : #'archive operations' }
ArchiveViewer >> writePrependingFile [
	| result name prependedName |
	self canSaveArchive ifFalse: [ ^self ].
	name := FileSaverDialog openOn: FileDirectory default initialFilename: 'archive.zip' label: 'Choose location to save archive' translated.
	name ifNil: [ ^self ].
	(archive canWriteToFileNamed: name)
		ifFalse: [ self inform: name, ' is used by one or more members
in your archive, and cannot be overwritten.
Try writing to another file name' translated.
			^self ].
	result := FileSaverDialog openOn: FileDirectory default initialFilename: 'archive.zip' label: 'Prepended File:' translated.
	result ifNil: [ ^self ].
	prependedName := result directory fullNameFor: result name.
	[ archive writeToFileNamed: name prependingFileNamed: prependedName ]
		on: Error
		do: [ :ex | self inform: ex description. ].
	self changed: #memberList	"in case CRC's and compressed sizes got set"
]
