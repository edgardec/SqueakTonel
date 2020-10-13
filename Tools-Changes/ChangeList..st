"
A ChangeList represents a list of changed methods that reside on a file in fileOut format.  The classes and methods in my list are not necessarily in this image!  Used as the model for both Version Lists and Changed Methods (in Screen Menu, Changes...).  Note that the two kinds of window have different controller classes!!

It holds three lists:
	changeList - a list of ChangeRecords
	list - a list of one-line printable headers
	listSelections - a list of Booleans (true = selected, false = not selected) multiple OK.
	listIndex 
Items that are removed (removeDoits, remove an item) are removed from all three lists.
Most recently clicked item is the one showing in the bottom pane.
"
Class {
	#name : #ChangeList,
	#superclass : #CodeHolder,
	#instVars : [
		'changeList',
		'list',
		'listIndex',
		'listSelections',
		'file',
		'lostMethodPointer',
		'showsVersions'
	],
	#category : #'Tools-Changes'
}

{ #category : #'fileIn\/Out' }
ChangeList class >> browseChangesFile: fullName [
	"Browse the selected file in fileIn format."

	fullName
		ifNotNil:
			[ChangeList browseStream: (FileStream readOnlyFileNamed:  fullName)]
		ifNil:
			[Beeper beep]
]

{ #category : #'fileIn\/Out' }
ChangeList class >> browseCompressedChangesFile: fullName [ 
	"Browse the selected file in fileIn format."

	| unzipped stream |
	fullName ifNil: [^Beeper beep].
	stream := FileStream readOnlyFileNamed: fullName.
	[ | zipped |stream converter: Latin1TextConverter new.
	zipped := GZipReadStream on: stream.
	unzipped := zipped contents asString]
		ensure: [stream close].
	stream := (MultiByteBinaryOrTextStream with: unzipped) reset.
	ChangeList browseStream: stream
]

{ #category : #'public access' }
ChangeList class >> browseFile: fileName [    "ChangeList browseFile: 'AutoDeclareFix.st'"
	"Opens a changeList on the file named fileName"

	^ self browseStream: (FileStream readOnlyFileNamed: fileName)
]

{ #category : #'public access' }
ChangeList class >> browseMethodVersions [
	
	| changeList end changesFile filteredRecords |
	changesFile := (SourceFiles at: 2) readOnlyCopy.
	changesFile setConverterForCode.
	end := changesFile size.
	changeList := self new.
	Cursor read showWhile: [
		[changeList scanFile: changesFile from: 0 to: end]
			on: InvalidUTF8 do: [:err | err resume: '']].
	changesFile close.
	
	filteredRecords := Dictionary new.
	changeList changeList
		do: [:changeRecord |
			changeRecord methodSelector ifNotNil: [:selector |
				| class |
				class := changeRecord methodClass.
				"Only collect records that point to not-installed methods."
				(class isNil or: [(class includesSelector: selector) not]) ifTrue: [				
					(filteredRecords at: selector ifAbsentPut: [OrderedCollection new])
						add: changeRecord]]]
		displayingProgress: [:changeRecord | 'Parsing source code at {1}...' format: {changeRecord position}]. 	
	filteredRecords explore. "Open explorer to allow user to repeat the following step manually."
	self browseMethodVersions: filteredRecords.
]

{ #category : #'public access' }
ChangeList class >> browseMethodVersions: filteredRecords [
	
	| changeList sortedKeys choice |
	sortedKeys := filteredRecords keys sorted.
	choice := Project uiManager chooseFrom: sortedKeys values: sortedKeys title: 'Recover method versions'.
	choice ifNil: [^ self].
	
	"Only ChangeList can handle the mix of (maybe non-existing) class references in records. For example, VersionsBrowser is not supported."
	changeList := ChangeList new. 
	
	(filteredRecords at: choice) do: [:changeRecord |
		changeList
			addItem: changeRecord
			text: ('{1} {2}{3}{4} \{{5}\}' format: {
				changeRecord stamp.
				changeRecord methodClassName.
				changeRecord isMetaClassChange
					ifTrue: [' class '] ifFalse: [' '].
				choice.
				changeRecord category})].
	changeList resetListSelections.

	self 
		open: changeList
		name: 'All local versions for ', choice storeString
		multiSelect: false
]

{ #category : #'public access' }
ChangeList class >> browseRecent: charCount [ 
	"ChangeList browseRecent: 5000"
	"Opens a changeList on the end of the changes log file"
	^ self browseRecent: charCount on: (SourceFiles at: 2) 
]

{ #category : #'public access' }
ChangeList class >> browseRecent: charCount on: origChangesFile [ 
	"Opens a changeList on the end of the specified changes log file"
	| changeList end changesFile |
	changesFile := origChangesFile readOnlyCopy.
	changesFile setConverterForCode.
	end := changesFile size.
	changeList := Cursor read
		showWhile: [self new
						scanFile: changesFile
						from: (0 max: end - charCount)
						to: end].
	changesFile close.
	self
		open: changeList
		name: 'Recent changes'
		multiSelect: true
]

{ #category : #'public access' }
ChangeList class >> browseRecentLog [
	"ChangeList browseRecentLog"
	"Prompt with a menu of how far back to go to browse the current image's changes log file"
	^ self
		browseRecentLogOn: (SourceFiles at: 2)
		startingFrom: Smalltalk lastQuitLogPosition
]

{ #category : #'public access' }
ChangeList class >> browseRecentLogOn: origChangesFile [ 
	"figure out where the last snapshot or quit was, then browse the recent entries."

	| end done block pos chunk changesFile position prevBlock |
	changesFile := origChangesFile readOnlyCopy.
	position := nil.
	end := changesFile size.
	prevBlock := end.
	block := end - 1024 max: 0.
	done := false.
	[done
		or: [position notNil]]
		whileFalse: [changesFile position: block.
			"ignore first fragment"
			changesFile nextChunk.
			[changesFile position < prevBlock]
				whileTrue: [pos := changesFile position.
					chunk := changesFile nextChunk.
					((chunk indexOfSubCollection: '----' startingAt: 1) = 1) ifTrue: [
						(#('----QUIT' '----SNAPSHOT') anySatisfy: [ :str |
							chunk beginsWith: str ])
								ifTrue: [position := pos]]].
			block = 0
				ifTrue: [done := true]
				ifFalse: [prevBlock := block.
					block := block - 1024 max: 0]].
	changesFile close.
	position 
		ifNil: [self inform: 'File ' , changesFile name , ' does not appear to be a changes file']
		ifNotNil: [self browseRecentLogOn: origChangesFile startingFrom: position]
]

{ #category : #'public access' }
ChangeList class >> browseRecentLogOn: origChangesFile startingFrom: initialPos [ 
	"Prompt with a menu of how far back to go when browsing a changes file."

	| end banners positions pos chunk i changesFile |
	changesFile := origChangesFile readOnlyCopy.
	banners := OrderedCollection new.
	positions := OrderedCollection new.
	end := changesFile size.
	changesFile setConverterForCode.
	pos := initialPos.
	[pos = 0
		or: [banners size > 500]]
		whileFalse: [changesFile position: pos.
			chunk := changesFile nextChunk.
			i := chunk indexOfSubCollection: 'priorSource: ' startingAt: 1.
			i > 0
				ifTrue: [positions addLast: pos.
					banners
						addLast: (chunk copyFrom: 5 to: i - 2).
					pos := Number
								readFrom: (chunk copyFrom: i + 13 to: chunk size)]
				ifFalse: [pos := 0]].
	changesFile close.
	banners size = 0 ifTrue: [^ self inform: 
'this image has never been saved
since changes were compressed' translated].
	pos := UIManager default chooseFrom:  banners values: positions title: 'Browse as far back as...' translated.
	pos ifNil: [^ self].
	self browseRecent: end - pos on: origChangesFile
]

{ #category : #'public access' }
ChangeList class >> browseRecentLogOnPath: fullName [ 
	"figure out where the last snapshot or quit was, then browse the recent  entries."

	fullName
		ifNotNil:
			[self browseRecentLogOn: (FileStream readOnlyFileNamed: fullName)]
		ifNil:
			[Beeper beep]
	
]

{ #category : #'public access' }
ChangeList class >> browseStream: changesFile [
	"Opens a changeList on a fileStream"
	| changeList charCount |
	changesFile readOnly.
	changesFile setConverterForCode.
	charCount := changesFile size.
	charCount > 1000000 ifTrue:
		[(self confirm: 'The file ', changesFile name , '
is really long (' , charCount printString , ' characters).
Would you prefer to view only the last million characters?')
			ifTrue: [charCount := 1000000]].
	"changesFile setEncoderForSourceCodeNamed: changesFile name."
	changeList := Cursor read showWhile:
		[self new
			scanFile: changesFile from: changesFile size-charCount to: changesFile size].
	changesFile close.
	self open: changeList name: changesFile localName , ' log' multiSelect: true
]

{ #category : #'fileIn\/Out' }
ChangeList class >> fileReaderServicesForFile: fullName suffix: suffix [
	| services |
	services := OrderedCollection new.
	(FileStream isSourceFileSuffix: suffix) | (suffix = '*')
		ifTrue: [ services add: self serviceBrowseChangeFile ].
	(suffix = 'changes') | (suffix = '*')
		ifTrue: [ services add: self serviceBrowseDotChangesFile ].
	(fullName asLowercase endsWith: '.cs.gz') | (suffix = '*')
		ifTrue: [ services add: self serviceBrowseCompressedChangeFile ].
	^services
]

{ #category : #'public access' }
ChangeList class >> getRecentLocatorWithPrompt: aPrompt [
	"Prompt with a menu of how far back to go.  Return nil if user backs out.  Otherwise return the number of characters back from the end of the .changes file the user wishes to include"
	 "ChangeList getRecentPosition"
	| end changesFile banners positions pos chunk i |
	changesFile := (SourceFiles at: 2) readOnlyCopy.
	banners := OrderedCollection new.
	positions := OrderedCollection new.
	end := changesFile size.
	pos := Smalltalk lastQuitLogPosition.
	[pos = 0 or: [banners size > 20]] whileFalse:
		[changesFile position: pos.
		chunk := changesFile nextChunk.
		i := chunk indexOfSubCollection: 'priorSource: ' startingAt: 1.
		i > 0 ifTrue: [positions addLast: pos.
					banners addLast: (chunk copyFrom: 5 to: i-2).
					pos := Number readFrom: (chunk copyFrom: i+13 to: chunk size)]
			ifFalse: [pos := 0]].
	changesFile close.
	pos := UIManager default chooseFrom: banners values: positions title: aPrompt.
	pos == nil ifTrue: [^ nil].
	^ end - pos
]

{ #category : #'initialize-release' }
ChangeList class >> initialize [

	FileServices registerFileReader: self
]

{ #category : #'instance creation' }
ChangeList class >> open: aChangeList name: aString multiSelect: multiSelect [
	"Create a standard system view for the messageSet, whose label is aString.
	The listView may be either single or multiple selection type"
	^ToolBuilder default open: aChangeList label: aString
]

{ #category : #'fileIn\/Out' }
ChangeList class >> serviceBrowseChangeFile [
	"Answer a service for opening a changelist browser on a file"

	^ (SimpleServiceEntry 
		provider: self 
		label: 'changelist browser' translatedNoop
		selector: #browseStream:
		description: 'open a changelist tool on this file' translatedNoop
		buttonLabel: 'changes' translatedNoop)
		argumentGetter: [ :fileList | fileList readOnlyStream ]
]

{ #category : #'fileIn\/Out' }
ChangeList class >> serviceBrowseCompressedChangeFile [
	"Answer a service for opening a changelist browser on a file"

	^ SimpleServiceEntry 
		provider: self 
		label: 'changelist browser' translatedNoop
		selector: #browseCompressedChangesFile:
		description: 'open a changelist tool on this file' translatedNoop
		buttonLabel: 'changes' translatedNoop
]

{ #category : #'fileIn\/Out' }
ChangeList class >> serviceBrowseDotChangesFile [
	"Answer a service for opening a changelist browser on the tail end of a .changes file"

	^ SimpleServiceEntry 
		provider: self 
		label: 'recent changes in file' translatedNoop
		selector: #browseRecentLogOnPath:
		description: 'open a changelist tool on recent changes in file' translatedNoop
		buttonLabel: 'recent changes' translatedNoop
]

{ #category : #'fileIn\/Out' }
ChangeList class >> services [
	"Answer potential file services associated with this class"

	^ { self serviceBrowseChangeFile. 
		self serviceBrowseDotChangesFile.
		self serviceBrowseCompressedChangeFile }
]

{ #category : #'class initialization' }
ChangeList class >> unload [

	FileServices unregisterFileReader: self 
]

{ #category : #'menu actions' }
ChangeList >> acceptFrom: aView [

	aView controller text = aView controller initialText ifFalse: [
		aView flash.
		^ self inform: 'You can only accept this version as-is.
If you want to edit, copy the text to a browser'].
	(aView setText: aView controller text from: self) ifTrue:
		[aView ifNotNil: [aView controller accept]].	"initialText"

]

{ #category : #'initialization-release' }
ChangeList >> addItem: item text: text [
	| cr |
	cr := Character cr.
	changeList addLast: item.
	list addLast: (text collect: [:x | x = cr ifTrue: [$/] ifFalse: [x]])
]

{ #category : #'viewing access' }
ChangeList >> annotation [
	"Answer the string to be shown in an annotation pane.  Make plain that the annotation is associated with the current in-image version of the code, not of the selected disk-based version, and if the corresponding method is missing from the in-image version, mention that fact."

	| annot aChange aClass |

	annot := super annotation.
	annot asString = '------' ifTrue: [^ annot].

	^ ((aChange := self currentChange) notNil and: [aChange methodSelector notNil])
		ifFalse:
			[annot]
		ifTrue:
			[((aClass := aChange methodClass) isNil or: [(aClass includesSelector: aChange methodSelector) not])
				ifTrue:
					[aChange methodClassName, ' >> ', aChange methodSelector, ' is not present in the current image.']
				ifFalse:
					['current version: ', annot]]
]

{ #category : #'menu actions' }
ChangeList >> browseAllVersionsOfSelections [
	"Opens a Versions browser on all the currently selected methods, showing each alongside all of their historical versions."
	|  oldSelection aList |
	oldSelection := self listIndex.
	aList := OrderedCollection new.
	Cursor read showWhile: [
		1 to: changeList size do: [:i |
			(listSelections at: i) ifTrue: [
				listIndex := i.
				self browseVersions.
				aList add: i.
				]]].
	listIndex := oldSelection.

	aList size = 0 ifTrue: [^ self inform: 'no selected methods have in-memory counterparts'].

]

{ #category : #'menu actions' }
ChangeList >> browseCurrentVersionsOfSelections [
	"Opens a message-list browser on the current in-memory versions of all methods that are currently seleted"
	| aList |
	aList := OrderedCollection new.
	Cursor read showWhile: [
		1 to: changeList size do: [:i |
			(listSelections at: i) ifTrue: [
				| aClass aChange |
				aChange := changeList at: i.
				(aChange type = #method
					and: [(aClass := aChange methodClass) notNil
					and: [aClass includesSelector: aChange methodSelector]])
						ifTrue: [
							aList add: (
								MethodReference class: aClass  
									selector: aChange methodSelector
							)
						]]]].

	aList size = 0 ifTrue: [^ self inform: 'no selected methods have in-memory counterparts'].
	ToolSet
		browseMessageSet: aList
		name: 'Current versions of selected methods in ', file localName
		autoSelect: nil
]

{ #category : #'menu actions' }
ChangeList >> browseVersions [
	| change class browser |
	listIndex = 0
		ifTrue: [^ nil ].
	change := changeList at: listIndex.
	((class := change methodClass) notNil
			and: [class includesSelector: change methodSelector])
		ifFalse: [ ^nil ].
	browser := super browseVersions.
	browser ifNotNil: [ browser addedChangeRecord: change ].
	^browser
]

{ #category : #toolbuilder }
ChangeList >> buildChangeListWith: builder multiSelect: multiSelect [

	| listSpec |
	multiSelect ifTrue:[
		listSpec := builder pluggableMultiSelectionListSpec new.
		listSpec getSelectionList: #listSelectionAt:.
		listSpec setSelectionList: #listSelectionAt:put:.
	] ifFalse:[
		listSpec := builder pluggableListSpec new.
	].

	listSpec 
		model: self;
		list: #list; 
		getIndex: #listIndex; 
		setIndex: #toggleListIndex:; 
		menu: (self showsVersions ifTrue: [#versionsMenu:] ifFalse: [#changeListMenu:]); 
		keyPress: #changeListKey:from:.

	^listSpec
]

{ #category : #'menu actions' }
ChangeList >> buildMorphicCodePaneWith: editString [

	| codePane |

	codePane := AcceptableCleanTextMorph
		on: self
		text: #contents 
		accept: #contents:
		readSelection: #contentsSelection 
		menu: #codePaneMenu:shifted:.
	codePane font: Preferences standardCodeFont.
	editString ifNotNil: [
		codePane editString: editString.
		codePane hasUnacceptedEdits: true
	].
	^codePane

]

{ #category : #toolbuilder }
ChangeList >> buildWith: builder [
	^self buildWith: builder multiSelect: self showsVersions not
]

{ #category : #toolbuilder }
ChangeList >> buildWith: builder multiSelect: multiSelect [ 
	"Open a morphic view for the messageSet, whose label is labelString. 
	The listView may be either single or multiple selection type"
	| windowSpec max |
	max := self wantsOptionalButtons ifTrue:[0.33] ifFalse:[0.4].
	windowSpec := self buildWindowWith: builder specs: {
		(0@0 corner: 1@max) -> [self buildChangeListWith: builder multiSelect: multiSelect].
		(0@max corner: 1@1) -> [self buildCodePaneWith: builder].
	}.
	^builder build: windowSpec
]

{ #category : #accessing }
ChangeList >> changeList [
	^ changeList
]

{ #category : #'initialization-release' }
ChangeList >> changeListButtonSpecs [

	^#(
		('select all' 			selectAll				'select all entries')
		('deselect all'		deselectAll			'deselect all entries')
		('select conflicts'	selectAllConflicts	'select all methods that occur in any change set')
		('file in selections' 	fileInSelections		'file in all selected entries')
		)
]

{ #category : #'menu actions' }
ChangeList >> changeListKey: aChar from: view [
	"Respond to a Command key in the list pane."

	aChar == $D ifTrue: [^ self toggleDiffing].
	aChar == $a ifTrue: [^ self selectAll].

	^ self arrowKey: aChar from: view
]

{ #category : #'menu actions' }
ChangeList >> changeListMenu: aMenu [
	^ self menu: aMenu for: #(changeListMenu changeListMenuShifted)

]

{ #category : #accessing }
ChangeList >> changes: changeRecords file: aFile [
	file := aFile.
	changeList := OrderedCollection new.
	list := OrderedCollection new.
	listIndex := 0.
	changeRecords do: [:each |
		(each respondsTo: #methodClass)
			ifFalse: [self addItem: ChangeRecord new text: each asString]
			ifTrue:
				[self addItem: each text: ('method: ' , each methodClass name , (each isMetaClassChange ifTrue: [' class '] ifFalse: [' '])
					, each methodSelector
					, '; ' , each stamp)]].
	listSelections := Array new: list size withAll: false
]

{ #category : #'menu actions' }
ChangeList >> compareToCurrentSource: currentSource [
	"If the current selection corresponds to a method in the system, then spawn a window showing the diffs as text"

	| change selectedSource |
	change := changeList at: listIndex ifAbsent: [^ self].
	selectedSource := change string.
	currentSource = selectedSource
		ifTrue: [^ self inform: 'Exact Match'].
	(StringHolder new
		textContents: (TextDiffBuilder
			buildDisplayPatchFrom: selectedSource
			to: currentSource
			inClass: change methodClass
			prettyDiffs: self showingPrettyDiffs))
		openLabel: 'Comparison to Current Version'.
]

{ #category : #'menu actions' }
ChangeList >> compareToCurrentVersion [
	"If the current selection corresponds to a method in the system, then spawn a window showing the diffs as text"

	| change class |
	change := changeList at: listIndex ifAbsent: [^ self].
	class := change methodClass.
	(class notNil and: [(class includesSelector: change methodSelector)])
		ifFalse: [^ self flash].
	^ self compareToCurrentSource: (class sourceCodeAt: change methodSelector) asString
]

{ #category : #'viewing access' }
ChangeList >> contents [
	"Answer the contents string, obeying diffing directives if needed"

	^ self showingAnyKindOfDiffs
		ifFalse:
			[self undiffedContents]
		ifTrue:
			[self showsVersions
				ifTrue:
					[self diffedVersionContents]
				ifFalse:
					[self contentsDiffedFromCurrent]]
]

{ #category : #'viewing access' }
ChangeList >> contents: aString [
	listIndex = 0 ifTrue: [self changed: #flash. ^ false].
	lostMethodPointer ifNotNil: [^ self restoreDeletedMethod].
	self okToChange "means not dirty" ifFalse: ["is dirty"
		self inform: 'This is a view of a method on a file.\Please cancel your changes.  You may\accept, but only when the method is untouched.' withCRs.  ^ false].
		"Can't accept changes here.  Method text must be unchanged!"
	(changeList at: listIndex) fileIn.
	^ true
]

{ #category : #'viewing access' }
ChangeList >> contentsDiffedFromCurrent [
	"Answer the contents diffed forward from current (in-memory) method version"

	| aChange aClass |
	listIndex = 0
		ifTrue: [^ ''].
	aChange := changeList at: listIndex.
	 (aChange type == #method
	 and: [(aClass := aChange methodClass) notNil
	 and: [aClass includesSelector: aChange methodSelector]]) ifTrue:
		[^self
			methodDiffFor: aChange text
			class: aClass
			selector: aChange methodSelector
			prettyDiffs: self showingPrettyDiffs].

	aChange type == #doIt ifTrue:
		[| tokens |
		 tokens := Scanner new scanTokens: aChange string.
		 ((tokens select:
				[:substr| #(subclass: variableByteSubclass: variableWordSubclass:
							instanceVariableNames: classVariableNames: ) includes: substr])
					asSet size >= 3
		  and: [(aClass := Smalltalk at: tokens third ifAbsent: []) notNil
		  and: [aClass isBehavior]]) ifTrue:
			[^ClassDiffBuilder buildDisplayPatchFrom: aClass definition to: aChange string].

		(tokens size = 4
		 and: [tokens second == #class
		 and: [tokens third == #instanceVariableNames:
		 and: [(aClass := Smalltalk at: tokens first ifAbsent: []) notNil
		 and: [aClass isBehavior]]]]) ifTrue:
			[^ClassDiffBuilder buildDisplayPatchFrom: aClass class definition to: aChange string]].

	(aChange type == #classComment
	and: [(aClass := aChange commentClass) notNil]) ifTrue:
		[^ClassDiffBuilder buildDisplayPatchFrom: aClass comment asString to: aChange string].

	^(changeList at: listIndex) text
]

{ #category : #'viewing access' }
ChangeList >> contentsSymbolQuints [
	"Answer a list of quintuplets representing information on the alternative views available in the code pane"

	^ self sourceAndDiffsQuintsOnly
]

{ #category : #accessing }
ChangeList >> currentChange [
	"return the current change being viewed, or nil if none"
	listIndex = 0 ifTrue: [ ^nil ].
	^changeList at: listIndex
]

{ #category : #'user interface' }
ChangeList >> defaultWindowColor [
	^ (Color r: 0.719 g: 0.9 b: 0.9)
]

{ #category : #'menu actions' }
ChangeList >> deselectAll [ 
	"Deselect all items in the list pane, and clear the code pane"

	listIndex := 0.
	listSelections atAllPut: false.
	self changed: #allSelections.
	self contentsChanged
]

{ #category : #'menu actions' }
ChangeList >> destroyCurrentCodeOfSelections [
	"Actually remove from the system any in-memory methods with class and selector identical to items current selected.  This may seem rather arcane but believe me it has its great uses, when trying to split out code.  To use effectively, first file out a change set that you wish to split off.  Then open a ChangeList browser on that fileout.  Now look through the methods, and select any of them which you want to remove completely from the system, then issue this command.  For those methods where you have made changes to pre-existing versions, of course, you won't want to remove them from the system, so use this mechanism with care!"

	|  aClass aChange aList |
	aList := OrderedCollection new.
	1 to: changeList size do:
		[:index |
			(listSelections at: index) ifTrue:
				[aChange := changeList at: index.
				(aChange type = #method
					and: [(aClass := aChange methodClass) notNil
					and: [aClass includesSelector: aChange methodSelector]])
						ifTrue:
							[aList add: {aClass. aChange methodSelector}]]].

	aList size > 0 ifTrue:
		[(self confirm: 'Warning! This will actually remove ', aList size printString,  ' method(s) from the system!') ifFalse: [^ self]].
	aList do:
		[:aPair | Transcript cr; show: 'Removed: ', aPair first printString, '.', aPair second.
			aPair first removeSelector: aPair second]
]

{ #category : #'viewing access' }
ChangeList >> diffedVersionContents [
	"Answer diffed version contents, maybe pretty maybe not"

	| change class earlier later |
	(listIndex = 0
			or: [changeList size < listIndex])
		ifTrue: [^ ''].
	change := changeList at: listIndex.
	later := change text.
	class := change methodClass: self environment.
	(listIndex == changeList size or: [class == nil])
		ifTrue: [^ (self showingPrettyDiffs and: [class notNil])
			ifTrue: [class prettyPrinterClass format: later in: class notifying: nil]
			ifFalse: [later]].

	earlier := (changeList at: listIndex + 1) text.

	^ TextDiffBuilder buildDisplayPatchFrom: earlier to: later inClass: class prettyDiffs: self showingPrettyDiffs
]

{ #category : #accessing }
ChangeList >> file [
	^file
]

{ #category : #'menu actions' }
ChangeList >> fileInSelections [ 
	| any |
	any := false.
	self selectedClass environment beCurrentDuring: [
		listSelections with: changeList do: 
			[:selected :item | selected ifTrue: [any := true. item fileIn]]].
	any ifFalse:
		[self inform: 'nothing selected, so nothing done']
]

{ #category : #'menu actions' }
ChangeList >> fileOutSelections [ 
	| fileName internalStream |
	fileName := UIManager default request: 'Enter the base of file name' initialAnswer: 'Filename'.
	internalStream := WriteStream on: (String new: 1000).
	internalStream header; timeStamp.
	listSelections with: changeList do: 
		[:selected :item | selected ifTrue: [item fileOutOn: internalStream]].

	FileStream writeSourceCodeFrom: internalStream baseName: fileName isSt: true useHtml: false.

]

{ #category : #'initialization-release' }
ChangeList >> initialize [
	"Initialize a blank ChangeList.  Set the contentsSymbol to reflect whether diffs will initally be shown or not"

	contentsSymbol := Preferences diffsInChangeList
		ifTrue:
			[self defaultDiffsSymbol]
		ifFalse:
			[#source].
	changeList := OrderedCollection new.
	list := OrderedCollection new.
	listIndex := 0.
	super initialize
]

{ #category : #'menu actions' }
ChangeList >> invertSelections [
	"Invert the selectedness of each item in the changelist"

	listSelections := listSelections collect: [ :ea | ea not].
	listIndex := 0.
	self changed: #allSelections.
	self contentsChanged
]

{ #category : #'viewing access' }
ChangeList >> list [
	^ list
]

{ #category : #accessing }
ChangeList >> listHasSingleEntry [
	"does the list of changes have only a single item?"
	^list size = 1
]

{ #category : #'viewing access' }
ChangeList >> listIndex [
	^ listIndex
]

{ #category : #'viewing access' }
ChangeList >> listSelectionAt: index [
	^ listSelections at: index
]

{ #category : #'viewing access' }
ChangeList >> listSelectionAt: index put: value [

	listSelections at: index put: value.
	self
		changed: #listSelectionAt:;
		changed: #listIndex.
	^ value
]

{ #category : #accessing }
ChangeList >> listSelections [
	listSelections ifNil: [
		list ifNotNil: [
			listSelections := Array new: list size withAll: false]].
	^ listSelections
]

{ #category : #'menu actions' }
ChangeList >> mainChangeListMenu: aMenu [
	"Fill aMenu up so that it comprises the primary changelist-browser menu"
	<changeListMenu>

	aMenu addTitle: 'change list'.
	aMenu addStayUpItemSpecial.

	aMenu addList: #(

	('fileIn selections'							fileInSelections						'import the selected items into the image')
	('fileOut selections...'						fileOutSelections						'create a new file containing the selected items')
	-
	('compare to current'						compareToCurrentVersion			'open a separate window which shows the text differences between the on-file version and the in-image version.' )
	('toggle diffing (D)'							toggleDiffing						'start or stop showing diffs in the code pane.')
	-
	('select conflicts with any changeset'		selectAllConflicts					'select methods in the file which also occur in any change-set in the system')
	('select conflicts with current changeset'	selectConflicts						'select methods in the file which also occur in the current change-set')
	('select conflicts with...'						selectConflictsWith					'allows you to designate a file or change-set against which to check for code conflicts.')
	-
	('select unchanged definitions'				selectUnchangedDefinitions			'select class definitions, class comments and methods in the file whose in-image versions are the same as their in-file counterparts' )
	('select unchanged methods'					selectUnchangedMethods				'select methods in the file whose in-image versions are the same as their in-file counterparts' )
	('select new methods'						selectNewMethods					'select methods in the file that do not current occur in the image')
	('select methods for this class'				selectMethodsForThisClass			'select all methods in the file that belong to the currently-selected class')
	('select methods for extant classes'			selectMethodsForExtantClasses		'select all methods in the file that belong to a class that exists in the image')
	('select changes with contents matching'		selectContentsMatching				'select all changes in the file whose text includes a pattern')

	-
	('select all (a)'								selectAll								'select all the items in the list')
	('deselect all'								deselectAll							'deselect all the items in the list')
	('invert selections'							invertSelections						'select every item that is not currently selected, and deselect every item that *is* currently selected')
	('select all before'							selectAllBefore							'select every item before the current selection')
	-
	('browse all versions of single selection'			browseVersions		'open a version browser showing the versions of the currently selected method')
	('browse all versions of selections'			browseAllVersionsOfSelections		'open a version browser showing all the versions of all the selected methods')
	('browse current versions of selections'		browseCurrentVersionsOfSelections	'open a message-list browser showing the current (in-image) counterparts of the selected methods')
	('destroy current methods of selections'		destroyCurrentCodeOfSelections		'remove (*destroy*) the in-image counterparts of all selected methods')
	-
	('remove doIts'								removeDoIts							'remove all items that are doIts rather than methods')
	('remove older versions'						removeOlderMethodVersions			'remove all but the most recent versions of methods in the list')
	('remove up-to-date versions'				removeExistingMethodVersions		'remove all items whose code is the same as the counterpart in-image code')
	('remove selected items'						removeSelections					'remove the selected items from the change-list')
	('remove unselected items'					removeNonSelections					'remove all the items not currently selected from the change-list')).

	^ aMenu


]

{ #category : #'viewing access' }
ChangeList >> methodDiffFor: aString class: aClass selector: aSelector prettyDiffs: prettyDiffBoolean [
	"Return a string comprising a source-code diff between an existing method and the source-code in aString.  DO prettyDiff if prettyDiffBoolean is true."

	^ (aClass notNil and: [aClass includesSelector: aSelector])
		ifTrue:
			[TextDiffBuilder
				buildDisplayPatchFrom: (aClass sourceCodeAt: aSelector)
				to: aString
				inClass: aClass
				prettyDiffs: prettyDiffBoolean]
		ifFalse:
			[aString copy]
]

{ #category : #'initialization-release' }
ChangeList >> optionalButtonHeight [

	^ 15
]

{ #category : #'menu actions' }
ChangeList >> perform: selector orSendTo: otherTarget [
	"Selector was just chosen from a menu by a user.  If I can respond, then perform it on myself.  If not, send it to otherTarget, presumably the editPane from which the menu was invoked." 

	(#accept == selector) ifTrue:
		[otherTarget isMorph ifFalse: [^ self acceptFrom: otherTarget view]].
			"weird special case just for mvc changlist"

	^ super perform: selector orSendTo: otherTarget
]

{ #category : #'menu actions' }
ChangeList >> removeDoIts [
	"Remove doits from the receiver, other than initializes. 1/26/96 sw"

	| newChangeList newList |

	newChangeList := OrderedCollection new.
	newList := OrderedCollection new.

	changeList with: list do:
		[:chRec :str |
			(chRec type ~~ #doIt or:
				[str endsWith: 'initialize'])
					ifTrue:
						[newChangeList add: chRec.
						newList add: str]].
	newChangeList size < changeList size
		ifTrue:
			[changeList := newChangeList.
			list := newList.
			listIndex := 0.
			listSelections := Array new: list size withAll: false].
	self changed: #list.

	
]

{ #category : #'menu actions' }
ChangeList >> removeExistingMethodVersions [
	"Remove all up to date version of entries from the receiver"
	| newChangeList newList |
	newChangeList := OrderedCollection new.
	newList := OrderedCollection new.

	changeList with: list do:[:chRec :strNstamp | 
			| str keep cls sel |
			keep := true.
			(cls := chRec methodClass) ifNotNil:[
				str := chRec string.
				sel := cls newParser parseSelector: str.
				keep := (cls sourceCodeAt: sel ifAbsent:['']) asString ~= str.
			].
			keep ifTrue:[
					newChangeList add: chRec.
					newList add: strNstamp]].
	newChangeList size < changeList size
		ifTrue:
			[changeList := newChangeList.
			list := newList.
			listIndex := 0.
			listSelections := Array new: list size withAll: false].
	self changed: #list
]

{ #category : #'menu actions' }
ChangeList >> removeNonSelections [
	"Remove the unselected items from the receiver."

	| newChangeList newList |

	newChangeList := OrderedCollection new.
	newList := OrderedCollection new.

	1 to: changeList size do:
		[:i | (listSelections at: i) ifTrue:
			[newChangeList add: (changeList at: i).
			newList add: (list at: i)]].
	newChangeList size = 0 ifTrue:
		[^ self inform: 'That would remove everything.
Why would you want to do that?'].

	newChangeList size < changeList size
		ifTrue:
			[changeList := newChangeList.
			list := newList.
			listIndex := 0.
			listSelections := Array new: list size withAll: false].
	self changed: #list

	
]

{ #category : #'menu actions' }
ChangeList >> removeOlderMethodVersions [
	"Remove older versions of entries from the receiver."
	| newChangeList newList found |
	newChangeList := OrderedCollection new.
	newList := OrderedCollection new.
	found := OrderedCollection new.

	changeList reverseWith: list do:
		[:chRec :strNstamp | | str | str := strNstamp copyUpTo: $;.
			(found includes: str)
				ifFalse:
					[found add: str.
					newChangeList add: chRec.
					newList add: strNstamp]].
	newChangeList size < changeList size
		ifTrue:
			[changeList := newChangeList reversed.
			list := newList reversed.
			listIndex := 0.
			listSelections := Array new: list size withAll: false].
	self changed: #list
]

{ #category : #'menu actions' }
ChangeList >> removeSelections [
	"Remove the selected items from the receiver.  9/18/96 sw"

	| newChangeList newList |

	newChangeList := OrderedCollection new.
	newList := OrderedCollection new.

	1 to: changeList size do:
		[:i | (listSelections at: i) ifFalse:
			[newChangeList add: (changeList at: i).
			newList add: (list at: i)]].
	newChangeList size < changeList size
		ifTrue:
			[changeList := newChangeList.
			list := newList.
			listIndex := 0.
			listSelections := Array new: list size withAll: false].
	self changed: #list

	
]

{ #category : #'initialization-release' }
ChangeList >> resetListSelections [

	listSelections := Array new: list size withAll: false.
]

{ #category : #'viewing access' }
ChangeList >> restoreDeletedMethod [
	"If lostMethodPointer is not nil, then this is a version browser for a method that has been removed.  In this case we want to establish a sourceCode link to prior versions.  We do this by installing a dummy method with the correct source code pointer prior to installing this version."
	| dummyMethod class selector |
	dummyMethod := CompiledMethod toReturnSelfTrailerBytes: 
		(CompiledMethodTrailer new sourcePointer: lostMethodPointer).
	class := (changeList at: listIndex) methodClass.
	selector := (changeList at: listIndex) methodSelector.
	class addSelectorSilently: selector withMethod: dummyMethod.
	(changeList at: listIndex) fileIn.
	"IF for some reason, the dummy remains, remove it, but (N.B.!) we might not get control back if the compile (fileIn above) fails."
	(class compiledMethodAt: selector) == dummyMethod
		ifTrue: [class basicRemoveSelector: selector].
	^ true
]

{ #category : #scanning }
ChangeList >> scanCategory [  
	"Scan anything that involves more than one chunk; method name is historical only"

	| itemPosition item tokens stamp anIndex class meta |
	itemPosition := file position.
	item := file nextChunk.

	((item includesSubstring: 'commentStamp:')
	or: [(item includesSubstring: 'methodsFor:')
	or: [(item includesSubstring: 'classDefinition:')
	or: [item endsWith: 'reorganize']]]) ifFalse:
		["Maybe a preamble, but not one we recognize; bail out with the preamble trick"
		^ self addItem: (ChangeRecord new file: file position: itemPosition type: #preamble)
				 text: ('preamble: ' , item contractTo: 50)].

	tokens := Scanner new scanTokens: item.
	tokens size >= 3 ifTrue:
		[stamp := ''.
		anIndex := tokens indexOf: #stamp: ifAbsent: [nil].
		anIndex ifNotNil: [stamp := tokens at: (anIndex + 1)].

		tokens second == #methodsFor:
			ifTrue: [^ self scanCategory: tokens third class: tokens first
							meta: false stamp: stamp].
		tokens third == #methodsFor:
			ifTrue: [^ self scanCategory: tokens fourth class: tokens first
							meta: true stamp: stamp]].

	tokens second == #commentStamp:
		ifTrue:
			[stamp := tokens third.
			self addItem:
					(ChangeRecord new file: file position: file position type: #classComment
									class: tokens first category: nil meta: false stamp: stamp)
					text: 'class comment for ' , tokens first, 
						  (stamp isEmpty ifTrue: [''] ifFalse: ['; ' , stamp]).
			file nextChunk.
			^ file skipStyleChunk].
		
	tokens first == #classDefinition:
		ifTrue:
			[class := tokens second.
			meta := tokens size >= 3 and: [tokens third = 'class'].
			stamp := ''.
			self addItem:
					(ChangeRecord new file: file position: file position type: #classDefinition
									class: class category: nil meta: meta stamp: stamp)
					text: 'class definition for ' , class, 
						  (stamp isEmpty ifTrue: [''] ifFalse: ['; ' , stamp]).
			file nextChunk.
			^ file skipStyleChunk].

	self assert: tokens last == #reorganize.
	self addItem:
		(ChangeRecord new
			file: file position: file position type: #reorganize
			class: tokens first category: nil meta: false stamp: stamp)
		text: 'organization for ' , tokens first, (tokens second == #class ifTrue: [' class'] ifFalse: ['']).
	file nextChunk
]

{ #category : #scanning }
ChangeList >> scanCategory: category class: class meta: meta stamp: stamp [
	| itemPosition method selector |
	[itemPosition := file position.
	method := file nextChunk.
	file skipStyleChunk.
	method size > 0]						"done when double terminators"
		whileTrue:
		[self addItem: (ChangeRecord new file: file position: itemPosition type: #method
							class: class category: category meta: meta stamp: stamp)
			text: 'method: ' , class , (meta ifTrue: [' class '] ifFalse: [' '])
				, ((selector := ((Smalltalk classNamed: class) ifNil: [Object]) newParser parseSelector: method) isNil
					ifTrue: ['unparsableSelector']
					ifFalse: [selector])
				, (stamp isEmpty ifTrue: [''] ifFalse: ['; ' , stamp])]
]

{ #category : #scanning }
ChangeList >> scanFile: aFile from: startPosition to: stopPosition [
	
	file := aFile.
	changeList := OrderedCollection new.
	list := OrderedCollection new.
	listIndex := 0.
	file position: startPosition.
'Scanning ', aFile localName, '...'
	displayProgressFrom: startPosition to: stopPosition
	during: [:bar | | prevChar itemPosition item |
	[file position < stopPosition]
		whileTrue:
		[bar value: file position.
		[file atEnd not and: [file peek isSeparator]]
				whileTrue: [prevChar := file next].
		(file peekFor: $!)
		ifTrue:
			[(prevChar = Character cr or: [prevChar = Character lf])
				ifTrue: [self scanCategory]]
		ifFalse:
			[itemPosition := file position.
			item := file nextChunk.
			file skipStyleChunk.
			item size > 0 ifTrue:
				[(item beginsWith: '----')
					ifTrue:
						[self addItem: (ChangeRecord new
								file: file position: itemPosition type: #misc)
								text: 'misc: ' , (item contractTo: 50)]
					ifFalse:
						[self addItem: (ChangeRecord new
								file: file position: itemPosition type: #doIt)
								text: 'do it: ' , (item contractTo: 50)]]]]].
	self resetListSelections.
]

{ #category : #'menu actions' }
ChangeList >> selectAll [
	listIndex := 0.
	listSelections atAllPut: true.
	self changed: #allSelections
]

{ #category : #'menu actions' }
ChangeList >> selectAllBefore [
	listIndex <= 1 ifTrue:
		[Project current beep.
		 ^self changed: #flash].
	listSelections atAll: (1 to: listIndex - 1) put: true.
	self changed: #allSelections
]

{ #category : #'menu actions' }
ChangeList >> selectAllConflicts [
	"Selects all method definitions in the receiver which are also in any existing change set in the system.  This makes no statement about whether the content of the methods differ, only whether there is a change represented."
	Cursor read showWhile: 
		[ | aClass aChange |
		1 to: changeList size do:
			[:i | aChange := changeList at: i.
			listSelections at: i put:
				(aChange type = #method
				and: [(aClass := aChange methodClass) notNil
				and: [ChangesOrganizer doesAnyChangeSetHaveClass: aClass andSelector:  aChange methodSelector]])]].
	self changed: #allSelections
]

{ #category : #'menu actions' }
ChangeList >> selectConflicts [
	"Selects all method definitions for which there is ALSO an entry in changes"
	Cursor read showWhile: 
	[ | change class |
	1 to: changeList size do:
		[:i | change := changeList at: i.
		listSelections at: i put:
			(change type = #method
			and: [(class := change methodClass) notNil
			and: [(ChangeSet current atSelector: change methodSelector
						class: class) ~~ #none]])]].
	self changed: #allSelections
]

{ #category : #'menu actions' }
ChangeList >> selectConflicts: changeSetOrList [
	"Selects all method definitions for which there is ALSO an entry in the specified changeSet or changList"
	Cursor read showWhile: 
	[ | change class |
	(changeSetOrList isKindOf: ChangeSet) ifTrue: [
	1 to: changeList size do:
		[:i | change := changeList at: i.
		listSelections at: i put:
			(change type = #method
			and: [(class := change methodClass) notNil
			and: [(changeSetOrList atSelector: change methodSelector
						class: class) ~~ #none]])]]
	ifFalse: ["a ChangeList"
	1 to: changeList size do:
		[:i | change := changeList at: i.
		listSelections at: i put:
			(change type = #method
			and: [(class := change methodClass) notNil
			and: [changeSetOrList list includes: (list at: i)]])]]
	].
	self changed: #allSelections
]

{ #category : #'menu actions' }
ChangeList >> selectConflictsWith [
	"Selects all method definitions for which there is ALSO an entry in the specified changeSet or changList chosen by the user. 4/11/96 tk"
	| aStream all index |
	aStream := WriteStream on: (String new: 200).
	(all := ChangesOrganizer allChangeSets copy) do:
		[:sel | aStream nextPutAll: (sel name contractTo: 40); cr].
	ChangeList allSubInstancesDo:
		[:sel | aStream nextPutAll: (sel file name); cr.
			all addLast: sel].
	aStream skip: -1.
	index := (UIManager default chooseFrom: (aStream contents substrings)).
	index > 0 ifTrue: [
		self selectConflicts: (all at: index)].

]

{ #category : #'menu actions' }
ChangeList >> selectContentsMatching [
	| pattern |
	pattern := UIManager default request: 'pattern to match'.
	pattern isEmpty ifTrue: [^self].
	^Cursor execute showWhile:
		[self selectSuchThat: ((pattern includesAnyOf: '?*')
								ifTrue: [[ :change | pattern match: change string]]
								ifFalse: [[ :change | change string includesSubstring: pattern]])]
]

{ #category : #'menu actions' }
ChangeList >> selectMethodsForExtantClasses [
	^self selectSuchThat:
		[ :change |
		Smalltalk hasClassNamed: change methodClassName]
]

{ #category : #'menu actions' }
ChangeList >> selectMethodsForThisClass [
	self currentChange ifNil: [ ^self ].
	self currentChange methodClassName ifNotNil:
		[:name|
		self selectSuchThat:
			(Sensor leftShiftDown
				ifTrue: [[:change :index| (listSelections at: index) or: [change methodClassName = name]]]
				ifFalse: [[:change| change methodClassName = name]])]
]

{ #category : #'menu actions' }
ChangeList >> selectNewMethods [
	"Selects all method definitions for which there is no counterpart method in the current image"
	Cursor read showWhile: 
		[ | change class |
		1 to: changeList size do:
			[:i | change := changeList at: i.
			listSelections at: i put:
				((change type = #method and:
					[((class := change methodClass) isNil) or:
						[(class includesSelector: change methodSelector) not]]))]].
	self changed: #allSelections
]

{ #category : #'menu actions' }
ChangeList >> selectSuchThat [
	"query the user for a selection criterio.  By Lex Spoon.  NB: the UI for invoking this from a changelist browser is currently commented out; to reenfranchise it, you'll need to mild editing to ChangeList method #changeListMenu:"
	| code block |
	code := UIManager default request: 'selection criteria for a change named aChangeRecord?\For instance, ''aChangeRecord category = ''System-Network''''' withCRs.

	code isEmpty ifTrue: [^ self ].

	block := Compiler evaluate: '[:aChangeRecord | ', code, ']'.

	self selectSuchThat: block
]

{ #category : #'menu actions' }
ChangeList >> selectSuchThat: aBlock [
	"select all changes for which block returns true"
	listSelections := aBlock numArgs = 2
						ifTrue: [changeList withIndexCollect: aBlock]
						ifFalse: [changeList collect: aBlock].
	self changed: #allSelections
]

{ #category : #'menu actions' }
ChangeList >> selectUnchangedDefinitions [
	"Selects all recognizable definitions for which there is already a definition in the current image, whose source is exactly the same."
	| change class tokens |
	Cursor read showWhile: 
	[1 to: changeList size do:
		[:i | change := changeList at: i.
		listSelections at: i put: false.

		(change type = #method
		 and: [(class := change methodClass) notNil
		 and: [class includesSelector: change methodSelector]]) ifTrue:
			[listSelections
				at: i
				put: change string withBlanksCondensed
					= (class sourceCodeAt: change methodSelector) asString withBlanksCondensed].

		(change type == #classComment
		and: [(class := change commentClass) notNil]) ifTrue:
			[listSelections at: i put: change string = class comment asString].

		change type == #doIt ifTrue:
			[tokens := Scanner new scanTokens: change string.

			 ((tokens select:
				[:substr| #(subclass: variableSubclass: variableByteSubclass: variableWordSubclass:
							instanceVariableNames: classVariableNames: ) includes: substr])
					asSet size >= 3
			 and: [(class := Smalltalk at: tokens third ifAbsent: []) notNil
			 and: [class isBehavior]]) ifTrue:
				[listSelections
					at: i
					put: change string withBlanksCondensed
						= class definition withBlanksCondensed].

			(tokens size = 4
			 and: [tokens second == #class
			 and: [tokens third == #instanceVariableNames:
			 and: [(class := Smalltalk at: tokens first ifAbsent: []) notNil
			 and: [class isBehavior]]]]) ifTrue:
				[listSelections
					at: i
					put: change string withBlanksCondensed
						= class class definition withBlanksCondensed].

			(tokens size = 3
			 and: [tokens second == #removeSelector:
			 and: [(class := Smalltalk at: tokens first ifAbsent: []) isNil
			 	or: [class isBehavior and: [(class includesSelector: tokens third) not]]]]) ifTrue:
				[listSelections at: i put: true].

			(tokens size = 4
			 and: [tokens second == #class
			 and: [tokens third == #removeSelector:
			 and: [(class := Smalltalk at: tokens first ifAbsent: []) isNil
			 	or: [class isBehavior and: [(class class includesSelector: tokens fourth) not]]]]]) ifTrue:
				[listSelections at: i put: true]]]].

	self changed: #allSelections
]

{ #category : #'menu actions' }
ChangeList >> selectUnchangedMethods [
	"Selects all method definitions for which there is already a method in the current image, whose source is exactly the same.  9/18/96 sw"
	Cursor read showWhile: 
	[ | class change |
	1 to: changeList size do:
		[:i | change := changeList at: i.
		listSelections at: i put:
			((change type = #method and:
				[(class := change methodClass) notNil]) and:
					[(class includesSelector: change methodSelector) and:
						[change string withBlanksCondensed = (class sourceCodeAt: change methodSelector) asString withBlanksCondensed ]])]].
	self changed: #allSelections
]

{ #category : #'viewing access' }
ChangeList >> selectedClass [
	^(self selectedClassOrMetaClass ifNil: [ ^nil ]) theNonMetaClass 
]

{ #category : #'viewing access' }
ChangeList >> selectedClassOrMetaClass [
	| c |
	^ (c := self currentChange) ifNotNil: [c methodClass]
]

{ #category : #'viewing access' }
ChangeList >> selectedMessageName [
	| c |
	^ (c := self currentChange) ifNotNil: [c methodSelector]
]

{ #category : #accessing }
ChangeList >> setLostMethodPointer: sourcePointer [
	lostMethodPointer := sourcePointer
]

{ #category : #accessing }
ChangeList >> showsVersions [
	^ false
]

{ #category : #'viewing access' }
ChangeList >> toggleListIndex: newListIndex [

	listIndex = newListIndex ifTrue: [^ self].
	listIndex := newListIndex.

	self changed: #listIndex.
	self contentsChanged
]

{ #category : #'viewing access' }
ChangeList >> undiffedContents [
	^ listIndex = 0
		ifTrue: ['']
		ifFalse: [(changeList at: listIndex) text]
]

{ #category : #'initialization-release' }
ChangeList >> wantsPrettyDiffOption [
	"Answer whether pretty-diffs are meaningful for this tool"

	^ true
]
