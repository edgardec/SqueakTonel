"
Some variations on FileList that
- use a hierarchical pane to show folder structure
- use different pane combinations, button layouts and prefiltering for specific uses

FileList2 morphicView openInWorld				""an alternative to the standard FileList""
FileList2 morphicViewNoFile openInWorld			""useful for selecting, but not viewing""
FileList2 morphicViewProjectLoader openInWorld	""useful for finding and loading projects""
FileList2 modalFolderSelector						""allows the user to select a folder""




"
Class {
	#name : #FileList2,
	#superclass : #FileList,
	#instVars : [
		'showDirsInFileList',
		'currentDirectorySelected',
		'fileSelectionBlock',
		'dirSelectionBlock',
		'optionalButtonSpecs',
		'modalView',
		'directoryChangeBlock',
		'ok'
	],
	#classInstVars : [
		'lastSelDir'
	],
	#category : #'Tools-FileList'
}

{ #category : #utility }
FileList2 class >> addFullPanesTo: window from: aCollection [

	

	aCollection do: [ :each | | frame |
		frame := LayoutFrame 
			fractions: each second 
			offsets: each third.
		window addMorph: each first fullFrame: frame.
	]
]

{ #category : #'blue ui' }
FileList2 class >> blueButtonText: aString textColor: textColor color: aColor inWindow: window [ 
	| result |
	result := window
				fancyText: aString translated
				font: Preferences standardEToysFont
				color: textColor.
	result setProperty: #buttonText toValue: aString;
		 hResizing: #rigid;
		 extent: 100 @ 20;
		 layoutInset: 4;
		 borderWidth: 1;
		 useRoundedCorners.
	aColor isNil
		ifFalse: [""result color: aColor. result borderColor: aColor muchDarker].
	^ result
]

{ #category : #'blue ui' }
FileList2 class >> blueButtonText: aString textColor: textColor color: aColor inWindow: window balloonText: balloonText selector: sel recipient: recip [ 
	| result |
	result := window
				fancyText: aString translated
				font: Preferences standardEToysFont
				color: textColor.
	result setProperty: #buttonText toValue: aString;
		 hResizing: #rigid;
		 extent: 100 @ 20;
		 layoutInset: 4;
		 borderWidth: 1;
		 useRoundedCorners;
		 setBalloonText: balloonText.
	result
		on: #mouseUp
		send: sel
		to: recip.
	aColor isNil
		ifFalse: [""
			result color: aColor.
			result borderColor: aColor muchDarker].
	^ result
]

{ #category : #'blue ui' }
FileList2 class >> blueButtonText: aString textColor: textColor inWindow: window [ 
	^ self
		blueButtonText: aString
		textColor: textColor
		color: nil
		inWindow: window
]

{ #category : #'blue ui' }
FileList2 class >> blueButtonText: aString textColor: textColor inWindow: window balloonText: balloonText selector: sel recipient: recip [ 
	^ self
		blueButtonText: aString
		textColor: textColor
		color: nil
		inWindow: window
		balloonText: balloonText
		selector: sel
		recipient: recip 
]

{ #category : #'blue ui' }
FileList2 class >> enableTypeButtons: typeButtons info: fileTypeInfo forDir: aDirectory [

	| foundSuffixes firstEnabled |

	firstEnabled := nil.
	foundSuffixes := (aDirectory ifNil: [ #()] ifNotNil: [ aDirectory fileNames]) collect: [ :each | (each findTokens: '.') last asLowercase].
	foundSuffixes := foundSuffixes asSet.
	fileTypeInfo with: typeButtons do: [ :info :button | | enableIt fileSuffixes |
		fileSuffixes := info second.
		enableIt := fileSuffixes anySatisfy: [ :patt | foundSuffixes includes: patt].
		button 
			setProperty: #enabled 
			toValue: enableIt.
		enableIt ifTrue: [firstEnabled ifNil: [firstEnabled := button]].
	].
	firstEnabled ifNotNil: [^firstEnabled mouseUp: nil].
	typeButtons do: [ :each | each color: Color gray].


]

{ #category : #'blue ui' }
FileList2 class >> endingSpecs [
	"Answer a collection of specs to build the selective 'find anything' tool called by the Navigator. This version uses the services registry to do so."
	"FileList2 morphicViewGeneralLoaderInWorld: Project current world"
	| specs rejects |
	rejects := #(addFileToNewZip: compressFile: openInZipViewer: extractAllFrom: openOn:).
	specs := OrderedCollection new.
	self fileExtensionsByCategory keysAndValuesDo: [:category :extensions |
		| services okExtensions |
		services := Dictionary new.
		okExtensions := Set new.
		
		extensions do: [:ext |
			(FileServices itemsForFile: (FileDirectory default fullPathFor: 'fred.' , ext))
				reject: [:service | rejects includes: service selector]
				thenDo: [:service |
					services at: service label put: service.
					okExtensions add: ext]].
		services isEmpty ifFalse: [ 
			specs add: {
				category.
				okExtensions.
				services values }]].
	^ specs
]

{ #category : #'blue ui' }
FileList2 class >> fileExtensionsByCategory [

	^ OrderedDictionary new
		at: 'Art' put: ImageReadWriter allTypicalFileExtensions;
		at: 'Morphs' put: #('morph' 'morphs' 'sp');
		at: 'Projects' put: #('extseg' 'project' 'pr');
		at: 'MIDI' put: #('mid' 'midi');
		at: 'Music' put: #('mp3');
		at: 'Movies' put: #('movie' 'mpg' 'mpeg' 'qt' 'mov');
		at: 'Flash' put: #('swf');
		"at: 'Books' put: #('bo');
		at: 'Code' put: #('st' 'cs');
		at: 'TrueType' put: #('ttf');
		at: '3ds' put: #('3ds');
		at: 'Tape' put: #('tape');
		at: 'Wonderland' put: #('wrl');
		at: 'HTML' put: #('htm' 'html');"
		yourself
]

{ #category : #blocks }
FileList2 class >> hideSqueakletDirectoryBlock [
	^[:dirName| (dirName sameAs: 'Squeaklets') not]
]

{ #category : #accessing }
FileList2 class >> lastSelDir [
	"Return the last selected directory or the default directory if no directory was selected so far."

	^lastSelDir ifNil: [ lastSelDir := FileDirectory default ]
]

{ #category : #accessing }
FileList2 class >> lastSelDir: aFileDirectory [
	"Store the last selected directory. This will be selected as default in newly opened file or folder selectors"
	
	^lastSelDir := aFileDirectory
]

{ #category : #'modal dialogs' }
FileList2 class >> modalFileSelector [

	| window |

	window := self morphicViewFileSelector.
	window openCenteredInWorld.
	UserInterfaceTheme current applyTo: window allMorphs.
	self modalLoopOn: window.
	^(window valueOfProperty: #fileListModel) getSelectedFile
]

{ #category : #'modal dialogs' }
FileList2 class >> modalFileSelectorForSuffixes: aList [

	| window aFileList |

	window := self morphicViewFileSelectorForSuffixes: aList.
	aFileList := window valueOfProperty: #fileListModel.
	aFileList resort: #name.
	window openCenteredInWorld.
	UserInterfaceTheme current applyTo: window allMorphs.
	self modalLoopOn: window.
	^aFileList getSelectedFile
]

{ #category : #'modal dialogs' }
FileList2 class >> modalFileSelectorForSuffixes: aList directory: aDirectory [

	| window aFileList |

	window := self morphicViewFileSelectorForSuffixes: aList directory: aDirectory.
	aFileList := window valueOfProperty: #fileListModel.
	window openCenteredInWorld.
	UserInterfaceTheme current applyTo: window allMorphs.
	self modalLoopOn: window.
	^aFileList getSelectedFile
]

{ #category : #'modal dialogs' }
FileList2 class >> modalFolderSelector [

	^self modalFolderSelector: self lastSelDir
	
]

{ #category : #'modal dialogs' }
FileList2 class >> modalFolderSelector: aDir [

	| window fileModel |
	window := self morphicViewFolderSelector: aDir.
	fileModel := window model.
	window openInWorld: self currentWorld extent: 300@400.
	UserInterfaceTheme current applyTo: window allMorphs.
	self modalLoopOn: window.
	^fileModel getSelectedDirectory withoutListWrapper
]

{ #category : #'modal dialogs' }
FileList2 class >> modalFolderSelectorForProject: aProject [
"
FileList2 modalFolderSelectorForProject: Project current
"
	"Not currently being converted to FileSaverDialog etc because it implements the decidedly outre looking 'blue ui' Project dialog. "
	| window fileModel w |

	window := FileList2 morphicViewProjectSaverFor: aProject.
	fileModel := window valueOfProperty: #FileList.
	w := self currentWorld.
	window position: w topLeft + (w extent - window extent // 2).
	w addMorphInLayer: window.
	w startSteppingSubmorphsOf: window.
	UserInterfaceTheme current applyTo: window allMorphs.
	self modalLoopOn: window.
	^fileModel getSelectedDirectory withoutListWrapper
]

{ #category : #'modal dialogs' }
FileList2 class >> modalFolderSelectorForProjectLoad [

	| window fileModel w |

	window := self morphicViewProjectLoader2InWorld: self currentWorld reallyLoad: false.
	fileModel := window valueOfProperty: #FileList.
	w := self currentWorld.
	window position: w topLeft + (w extent - window extent // 2).
	window openInWorld: w.
	UserInterfaceTheme current applyTo: window allMorphs.
	self modalLoopOn: window.
	^fileModel getSelectedDirectory withoutListWrapper
]

{ #category : #utility }
FileList2 class >> modalLoopOn: aMorph [
	[aMorph world notNil] whileTrue: [
		aMorph outermostWorldMorph doOneCycle.
	].
]

{ #category : #'morphic ui' }
FileList2 class >> morphicView [
	^ self morphicViewOnDirectory: FileDirectory default
]

{ #category : #'morphic ui' }
FileList2 class >> morphicViewFileSelector [

	^self morphicViewFileSelectorForSuffixes: nil

]

{ #category : #'morphic ui' }
FileList2 class >> morphicViewFileSelectorForSuffixes: aList [ 
	"Answer a morphic file-selector tool for the given suffix list."
	
	^self morphicViewFileSelectorForSuffixes: aList directory: self lastSelDir
]

{ #category : #'morphic ui' }
FileList2 class >> morphicViewFileSelectorForSuffixes: aList directory: dir [
	"Answer a morphic file-selector tool for the given suffix list and the given directory."

	| aFileList window fixedSize midLine gap |
	aFileList := self new directory: dir.
	aFileList optionalButtonSpecs: aFileList okayAndCancelServices.
	aList ifNotNil:
		[aFileList fileSelectionBlock: [:entry :myPattern |
			entry isDirectory
				ifTrue:
					[false]
				ifFalse:
					[aList includes: (FileDirectory extensionFor: entry name asLowercase)]]].
	window := BorderedMorph new
		layoutPolicy: ProportionalLayout new;
		color: Color lightBlue;
		borderColor: Color blue;
		borderWidth: 4;
		layoutInset: 4;
		extent: 600@400;
		useRoundedCorners.
	window setProperty: #fileListModel toValue: aFileList.
	aFileList modalView: window.
	midLine := 0.4.
	fixedSize := 25.
	gap := 5.
	self addFullPanesTo: window from: {
		{self textRow: 'Please select a file'. 0 @ 0 corner: 1 @ 0. 0@0 corner: 0@fixedSize}.
		{aFileList optionalButtonRow. 0 @ 0 corner: 1 @ 0. 0@fixedSize corner: 0@(fixedSize * 2)}.
		{aFileList morphicDirectoryTreePane. 0@0 corner: midLine@1. 
					gap @(fixedSize * 2) corner: gap negated@0}.
		{aFileList morphicFileListPane. midLine @ 0 corner: 1@1. 
					gap@(fixedSize * 2) corner: gap negated@0}.
	}.

	aFileList postOpen.

	^ window 
]

{ #category : #'morphic ui' }
FileList2 class >> morphicViewFolderSelector [

	^self morphicViewFolderSelector: FileDirectory default
]

{ #category : #'morphic ui' }
FileList2 class >> morphicViewFolderSelector: aDir [
	"Answer a tool that allows the user to select a folder"

	| aFileList window fixedSize |
	aFileList := self new directory: aDir.
	aFileList optionalButtonSpecs: aFileList servicesForFolderSelector.
	window := (SystemWindow labelled: aDir pathName) model: aFileList.
	aFileList modalView: window.

	fixedSize := 25.
	self addFullPanesTo: window from: {
		{self textRow: 'Please select a folder'. 0 @ 0 corner: 1 @ 0. 
				0@0 corner: 0@fixedSize}.
		{aFileList optionalButtonRow. 0 @ 0 corner: 1 @ 0. 
				0@fixedSize corner: 0@(fixedSize * 2)}.
		{aFileList morphicDirectoryTreePane. 0@0 corner: 1@1.
				0@(fixedSize * 2) corner: 0@0}.
	}.
	aFileList postOpen.
	^ window 
]

{ #category : #'blue ui' }
FileList2 class >> morphicViewGeneralLoaderInWorld: aWorld [
"
FileList2 morphicViewGeneralLoaderInWorld: self currentWorld
"
	| window aFileList buttons treePane textColor1 fileListPane pane2a pane2b fileTypeInfo fileTypeButtons fileTypeRow actionRow |

	fileTypeInfo := self endingSpecs.
	window := AlignmentMorphBob1 newColumn.
	window hResizing: #shrinkWrap; vResizing: #shrinkWrap.
	textColor1 := Color r: 0.742 g: 0.839 b: 1.0.
	aFileList := self new directory: FileDirectory default.
	aFileList 
		fileSelectionBlock: self projectOnlySelectionBlock;
		modalView: window.
	window
		setProperty: #FileList toValue: aFileList;
		wrapCentering: #center; cellPositioning: #topCenter;
		borderWidth: 1;
		borderColor: (Color r: 0.9 g: 0.801 b: 0.2);
		useRoundedCorners.

	fileTypeButtons := fileTypeInfo collect: [ :each |
		(self blueButtonText: each first textColor: Color gray inWindow: window)
			setProperty: #enabled toValue: true;
			hResizing: #shrinkWrap;
			useSquareCorners
	].
	buttons := {{'OK'. Color lightGreen}. {'Cancel'. Color lightRed}} collect: [ :each |
		self blueButtonText: each first textColor: textColor1 color: each second inWindow: window
	].

	treePane := aFileList morphicDirectoryTreePane 
		extent: 250@300; 
		retractable: false;
		borderWidth: 0.
	fileListPane := aFileList morphicFileListPane 
		extent: 350@300; 
		retractable: false;
		borderWidth: 0.
	window addARow: {window fancyText: 'Find...' translated font: Preferences standardEToysTitleFont color: textColor1}.
	fileTypeRow := window addARowCentered: fileTypeButtons cellInset: 2.
	actionRow := window addARowCentered: {
		buttons first. 
		(Morph new extent: 30@5) color: Color transparent. 
		buttons second
	} cellInset: 2.
	window
		addARow: {
				(window inAColumn: {(pane2a := window inARow: {window inAColumn: {treePane}}) 
					useRoundedCorners;
					layoutInset: 0;
					borderWidth: 1;
					borderColor: (Color r: 0.6 g: 0.7 b: 1)
				}) layoutInset: 10.
				(window inAColumn: {(pane2b := window inARow: {window inAColumn: {fileListPane}}) 
					useRoundedCorners;
					layoutInset: 0;
					borderWidth: 1;
					borderColor: (Color r: 0.6 g: 0.7 b: 1)
				}) layoutInset: 10.
		}.
	window fullBounds.
	window fillWithRamp: (Color r: 1 g: 0.85 b: 0.975) oriented: 0.65.
	pane2a fillWithRamp: (Color r: 0.85 g: 0.9 b: 1) oriented: (0.7 @ 0.35).
	pane2b fillWithRamp: (Color r: 0.85 g: 0.9 b: 1) oriented: (0.7 @ 0.35).
"
	buttons do: [ :each |
		each fillWithRamp: ColorTheme current dialogButtonsRampOrColor oriented: (0.75 @ 0).
	].
"
	fileTypeButtons do: [ :each | 
		each 
			on: #mouseUp 
			send: #value:value: 
			to: [ :evt :morph | 
				self update: actionRow in: window fileTypeRow: fileTypeRow morphUp: morph.
			]
	].
	buttons first on: #mouseUp send: #okHit to: aFileList.
	buttons second on: #mouseUp send: #cancelHit to: aFileList.
	aFileList postOpen.
	window position: aWorld topLeft + (aWorld extent - window extent // 2).
	aFileList directoryChangeBlock: [ :newDir |
		self update: actionRow in: window fileTypeRow: fileTypeRow morphUp: nil.
		self enableTypeButtons: fileTypeButtons info: fileTypeInfo forDir: newDir.
	].
	aFileList directory: aFileList directory.
	window adoptPaneColor: (Color r: 0.548 g: 0.677 b: 1.0).
	^ window openInWorld: aWorld.
]

{ #category : #'morphic ui' }
FileList2 class >> morphicViewImageViewer [

	| dir aFileList window midLine fixedSize |

	dir := FileDirectory default.
	aFileList := self new directory: dir.
	aFileList optionalButtonSpecs: aFileList specsForImageViewer.
	aFileList fileSelectionBlock: [ :entry :myPattern |
		entry isDirectory ifTrue: [
			false
		] ifFalse: [
			#('bmp' 'gif' 'jpg' 'form' 'png') includes: 
					 (FileDirectory extensionFor: entry name asLowercase)
		]
	].
	window := (SystemWindow labelled: dir pathName) model: aFileList.

	fixedSize := 25.
	midLine := 0.4.
	self addFullPanesTo: window from: {
		{aFileList optionalButtonRow. 0 @ 0 corner: 1 @ 0.
				0@0 corner: 0@fixedSize}.
		{aFileList morphicDirectoryTreePane. 0@0 corner: midLine@1.
				0@fixedSize corner: 0@0}.
		{aFileList morphicFileListPane. midLine @ 0 corner: 1@1.
				0@fixedSize corner: 0@0}.
	}.
	aFileList postOpen.
	^ window 
]

{ #category : #'morphic ui' }
FileList2 class >> morphicViewNoFile [

	| dir aFileList window midLine fixedSize |

	dir := FileDirectory default.
	aFileList := self new directory: dir.
	window := (SystemWindow labelled: dir pathName) model: aFileList.

	fixedSize := 25.
	midLine := 0.4.
	self addFullPanesTo: window from: {
		{aFileList morphicPatternPane. 0@0 corner: 0.3@0. 0@0 corner: 0@fixedSize}.
		{aFileList optionalButtonRow. 0.3 @ 0 corner: 1@0. 0@0 corner: 0@fixedSize}.
		{aFileList morphicDirectoryTreePane. 0@0 corner: midLine@1. 0@fixedSize corner: 0@0}.
		{aFileList morphicFileListPane. midLine @ 0 corner: 1@1. 0@fixedSize corner: 0@0}.
	}.
	aFileList postOpen.
	^ window 
]

{ #category : #'morphic ui' }
FileList2 class >> morphicViewProjectLoader [

	| dir aFileList window midLine fixedSize |

	dir := FileDirectory default.
	aFileList := self new directory: dir.
	aFileList optionalButtonSpecs: aFileList servicesForProjectLoader.
	aFileList fileSelectionBlock: self projectOnlySelectionBlock.
	window := (SystemWindow labelled: dir pathName) model: aFileList.

	fixedSize := 25.
	midLine := 0.4.
	self addFullPanesTo: window from: {
		{aFileList optionalButtonRow. 0 @ 0 corner: 1 @ 0. 0@0 corner: 0@fixedSize}.
		{aFileList morphicDirectoryTreePane. 0@0 corner: midLine@1. 0@fixedSize corner: 0@0}.
		{aFileList morphicFileListPane. midLine @ 0 corner: 1@1. 0@fixedSize corner: 0@0}.
	}.
	aFileList postOpen.
	^ window 
]

{ #category : #'blue ui' }
FileList2 class >> morphicViewProjectLoader2InWorld: aWorld [

	^self morphicViewProjectLoader2InWorld: aWorld reallyLoad: true
]

{ #category : #'blue ui' }
FileList2 class >> morphicViewProjectLoader2InWorld: aWorld reallyLoad: aBoolean [

	^self 
		morphicViewProjectLoader2InWorld: aWorld 
		reallyLoad: aBoolean
		dirFilterType: #initialDirectoryList

]

{ #category : #'blue ui' }
FileList2 class >> morphicViewProjectLoader2InWorld: aWorld reallyLoad: aBoolean dirFilterType: aSymbol [

	| window aFileList buttons treePane textColor1 fileListPane pane2a pane2b treeExtent filesExtent |

	window := AlignmentMorphBob1 newColumn.
	window hResizing: #shrinkWrap; vResizing: #shrinkWrap.
	textColor1 := Color r: 0.742 g: 0.839 b: 1.0.
	aFileList := self new.
	aFileList 
		optionalButtonSpecs: aFileList servicesForProjectLoader;
		fileSelectionBlock: (
			aSymbol == #limitedSuperSwikiDirectoryList ifTrue: [
				MessageSend receiver: Project current selector: #latestProjectVersionsFromFileEntries: 
			] ifFalse: [
				self projectOnlySelectionBlock
			]
		);
		"dirSelectionBlock: self hideSqueakletDirectoryBlock;"
		modalView: window.
	aFileList directory: FileDirectory default.
	window
		setProperty: #FileList toValue: aFileList;
		wrapCentering: #center; cellPositioning: #topCenter;
		borderWidth: 1;
		borderColor: (Color r: 0.9 g: 0.801 b: 0.2);
		useRoundedCorners.
	buttons := {{'OK'. Color lightGreen}. {'Cancel'. Color lightRed}} collect: [ :each |
		self blueButtonText: each first textColor: textColor1 color: each second inWindow: window
	].

	aWorld width < 800 ifTrue: [
		treeExtent := 150@300.
		filesExtent := 350@300.
	] ifFalse: [
		treeExtent := 350@500.
		filesExtent := 550@500.
	].
	(treePane := aFileList morphicDirectoryTreePaneFiltered: aSymbol)
		extent: treeExtent; 
		retractable: false;
		borderWidth: 0.
	fileListPane := aFileList morphicFileListPane 
		extent: filesExtent; 
		retractable: false;
		borderWidth: 0.
	window
		addARow: {
			window fancyText: 'Load A Project' translated font: Preferences standardEToysTitleFont color: textColor1
		};
		addARowCentered: {
			buttons first. 
			(Morph new extent: 30@5) color: Color transparent. 
			buttons second
		};
		addARow: {
			window fancyText: 'Please select a project' translated  font: Preferences standardEToysFont color: textColor1
		};
		addARow: {
				(window inAColumn: {(pane2a := window inARow: {window inAColumn: {treePane}}) 
					useRoundedCorners;
					layoutInset: 0;
					borderWidth: 1;
					borderColor: (Color r: 0.6 g: 0.7 b: 1)
				}) layoutInset: 10.
				(window inAColumn: {(pane2b := window inARow: {window inAColumn: {fileListPane}}) 
					useRoundedCorners;
					layoutInset: 0;
					borderWidth: 1;
					borderColor: (Color r: 0.6 g: 0.7 b: 1)
				}) layoutInset: 10.
		}.
	window fullBounds.
	window fillWithRamp: (Color r: 1 g: 0.85 b: 0.975) oriented: 0.65.
	pane2a fillWithRamp: (Color r: 0.85 g: 0.9 b: 1) oriented: (0.7 @ 0.35).
	pane2b fillWithRamp: (Color r: 0.85 g: 0.9 b: 1) oriented: (0.7 @ 0.35).
"
	buttons do: [ :each |
		each fillWithRamp: ColorTheme current dialogButtonsRampOrColor oriented: (0.75 @ 0).
	].
"
	buttons first 
		on: #mouseUp 
		send: (aBoolean ifTrue: [#okHitForProjectLoader] ifFalse: [#okHit])
		to: aFileList.
	buttons second on: #mouseUp send: #cancelHit to: aFileList.
	aFileList postOpen.
	window position: aWorld topLeft + (aWorld extent - window extent // 2).
	window adoptPaneColor: (Color r: 0.548 g: 0.677 b: 1.0).
	^ window openInWorld: aWorld.
]

{ #category : #'blue ui' }
FileList2 class >> morphicViewProjectSaverFor: aProject [
"
(FileList2 morphicViewProjectSaverFor: Project current) openInWorld
"
	| window aFileList buttons treePane pane2 textColor1 option treeExtent buttonData buttonRow |

	textColor1 := Color r: 0.742 g: 0.839 b: 1.0.
	aFileList := self new directory: ServerDirectory projectDefaultDirectory.
	aFileList dirSelectionBlock: self hideSqueakletDirectoryBlock.
	window := AlignmentMorphBob1 newColumn.
	window hResizing: #shrinkWrap; vResizing: #shrinkWrap.
	aFileList modalView: window.
	window
		setProperty: #FileList toValue: aFileList;
		wrapCentering: #center; cellPositioning: #topCenter;
		borderWidth: 1;
		borderColor: (Color r: 0.9 g: 0.801 b: 0.2);
		useRoundedCorners.

	buttonData := Preferences enableLocalSave
				ifTrue: [{
							{'Save'. #okHit. 'Save in the place specified below, and in the Squeaklets folder on your local disk'. Color lightGreen}.
							{'Save on local disk only'. #saveLocalOnlyHit. 'saves in the Squeaklets folder'. Color lightGreen}.
							{'Cancel'. #cancelHit. 'return without saving'. Color lightRed}
						}]
				ifFalse: [{
							{'Save'. #okHit. 'Save in the place specified below, and in the Squeaklets folder on your local disk'. Color lightGreen}.
							{'Cancel'. #cancelHit. 'return without saving'. Color lightRed}
						}].
	buttons := buttonData collect: [ :each |
		(self blueButtonText: each first textColor: textColor1 color: each fourth inWindow: window)
			setBalloonText: each third translated;
			hResizing: #shrinkWrap;
			on: #mouseUp send: each second to: aFileList
	].

	option := aProject world 
		valueOfProperty: #SuperSwikiPublishOptions 
		ifAbsent: [#initialDirectoryList].
	aProject world removeProperty: #SuperSwikiPublishOptions.

	treeExtent := Project current world height < 500
						ifTrue: [ 350@150 ]
						ifFalse: [ 350@300 ].

	(treePane := aFileList morphicDirectoryTreePaneFiltered: option) 
		extent: treeExtent; 
		retractable: false;
		borderWidth: 0.
	window
		addARowCentered: {
			window fancyText: 'Publish This Project' translated font: Preferences standardEToysTitleFont color: textColor1
		}.
	buttonRow := OrderedCollection new.
	buttons do: [:button | buttonRow add: button] separatedBy: [buttonRow add: ((Morph new extent: 30@5) color: Color transparent)].

"	addARowCentered: {
			buttons first. 
			(Morph new extent: 30@5) color: Color transparent. 
			buttons second.
			(Morph new extent: 30@5) color: Color transparent. 
			buttons third
		};"
	window
		addARowCentered: buttonRow;
		addARowCentered: { (window inAColumn: {(ProjectViewMorph on: aProject) lock}) layoutInset: 4};
		addARowCentered: {
			window fancyText: 'Please select a folder' translated font: Preferences standardEToysFont color: textColor1
		};
		addARow: {
			(
				window inAColumn: {
					(pane2 := window inARow: {window inAColumn: {treePane}}) 
						useRoundedCorners;
						layoutInset: 0;
						borderWidth: 1;
						borderColor: (Color r: 0.6 g: 0.7 b: 1)
				}
			) layoutInset: 10
		}.
	window fullBounds.
	window fillWithRamp: (Color r: 1 g: 0.85 b: 0.975) oriented: 0.65.
	pane2 fillWithRamp: (Color r: 0.85 g: 0.9 b: 1) oriented: (0.7 @ 0.35).
"
	buttons do: [ :each |
		each fillWithRamp: ColorTheme current dialogButtonsRampOrColor oriented: (0.75 @ 0).
	].
"
	window setProperty: #morphicLayerNumber toValue: 11.
	aFileList postOpen.
	window adoptPaneColor: (Color r: 0.548 g: 0.677 b: 1.0).
	^ window 
]

{ #category : #'instance creation' }
FileList2 class >> openMorphicViewInWorld [
	"FileList2 openMorphicViewInWorld"
	^self morphicView openInWorld
]

{ #category : #blocks }
FileList2 class >> projectOnlySelectionBlock [

	^[ :entry :myPattern |
		entry isDirectory ifTrue: [
			false
		] ifFalse: [
			#('*.pr' '*.pr.gz' '*.project') anySatisfy: [ :each | each match: entry name]
		]
	]
]

{ #category : #'instance creation' }
FileList2 class >> prototypicalToolWindow [
	"Answer an example of myself seen in a tool window, for the benefit of parts-launching tools"

	^ self morphicView applyModelExtent
]

{ #category : #blocks }
FileList2 class >> selectionBlockForSuffixes: anArray [

	^[ :entry :myPattern |
		entry isDirectory ifTrue: [
			false
		] ifFalse: [
			anArray anySatisfy: [ :each | each match: entry name]
		]
	]
]

{ #category : #utility }
FileList2 class >> textRow: aString [ 

	^AlignmentMorph newRow 
		wrapCentering: #center; cellPositioning: #leftCenter;
		color: Color transparent;
		layoutInset: 0;
		addMorph: (
			AlignmentMorph newColumn
			wrapCentering: #center; cellPositioning: #topCenter;
			color: Color transparent;
			vResizing: #shrinkWrap;
			layoutInset: 0;
			addMorph: (
				AlignmentMorph newRow
				wrapCentering: #center; cellPositioning: #leftCenter;
				color: Color transparent;
				hResizing: #shrinkWrap;
				vResizing: #shrinkWrap;
				layoutInset: 0;
				addMorph: ((StringMorph contents: aString) color: ((UserInterfaceTheme current get: #textColor for: #PluggableTextMorph) ifNil: [Color black])) asMorph
			)
		)
]

{ #category : #'morphic ui' }
FileList2 class >> update: actionRow in: window fileTypeRow: fileTypeRow morphUp: morph [

	| fileTypeInfo info2 buttons textColor1 fileSuffixes fileActions aFileList fileTypeString |
	(morph notNil and: [(morph valueOfProperty: #enabled) not]) ifTrue: [^ self].
	
	fileTypeRow submorphsDo: [:sub |
		sub color: (
			sub == morph 
				ifTrue: [Color white] 
				ifFalse: [(sub valueOfProperty: #enabled) 
					ifTrue: [Color transparent]
					ifFalse: [Color gray]])].
	fileTypeString := morph isNil
		ifTrue: ['xxxx']
		ifFalse: [morph valueOfProperty: #buttonText].
	
	aFileList := window valueOfProperty: #FileList.
	textColor1 := Color r: 0.742 g: 0.839 b: 1.0.
	actionRow removeAllMorphs.
	fileTypeInfo := self endingSpecs.
	info2 := fileTypeInfo
		detect: [:each | each first = fileTypeString]
		ifNone: [nil].
	info2
		ifNil: [
			buttons := OrderedCollection new]
		ifNotNil: [
			fileSuffixes := info2 second.
			fileActions := info2 third.
			buttons := fileActions
				collect: [ :each | aFileList blueButtonForService: each textColor: textColor1 inWindow: window ]
				as: OrderedCollection.
			buttons do: [ :each |
				each fillWithRamp: Color lightGreen oriented: (0.75 @ 0)]].
	buttons addLast: (self
		blueButtonText: 'Cancel'
		textColor: textColor1
		color: Color lightRed
		inWindow: window
		balloonText: 'Cancel this search'
		selector: #cancelHit
		recipient: aFileList).
	buttons do: [:each | actionRow addMorphBack: each].
	window fullBounds.
	fileSuffixes ifNotNil: [
		aFileList fileSelectionBlock: (
			self selectionBlockForSuffixes: (fileSuffixes collect: [ :each | '*.',each]))].
	aFileList updateFileList.
]

{ #category : #'own services' }
FileList2 >> addNewDirectory [
	super addNewDirectory.
	self updateDirectory.
]

{ #category : #'user interface' }
FileList2 >> blueButtonForService: aService textColor: textColor inWindow: window [ 
	| block result |
	block := [self fullName isNil
				ifTrue: [self inform: 'Please select a file' translated]
				ifFalse: [aService performServiceFor: self]].
	result := window
				fancyText: aService buttonLabel capitalized translated
				font: Preferences standardEToysFont
				color: textColor.
	result setProperty: #buttonText toValue: aService buttonLabel capitalized;
		 hResizing: #rigid;
		 extent: 100 @ 20;
		 layoutInset: 4;
		 borderWidth: 1;
		 useRoundedCorners;
		 setBalloonText: aService label.
	result
		on: #mouseUp
		send: #value
		to: block.
	^ result
]

{ #category : #private }
FileList2 >> cancelHit [

	modalView delete.
	directory := fileName := currentDirectorySelected := nil.
]

{ #category : #'volume list and pattern' }
FileList2 >> changeDirectoryTo: aFileDirectory [
	"Change directory as requested."

	self directory: aFileDirectory.
	self updateDirectory
]

{ #category : #private }
FileList2 >> currentDirectorySelected [
	^ currentDirectorySelected

]

{ #category : #'own services' }
FileList2 >> deleteDirectory [
	super deleteDirectory.
	self updateDirectory.
]

{ #category : #initialization }
FileList2 >> dirSelectionBlock: aBlock [
	dirSelectionBlock := aBlock
]

{ #category : #'volume list and pattern' }
FileList2 >> directory [

	^directory
]

{ #category : #initialization }
FileList2 >> directory: dir [
	"Set the path of the volume to be displayed."

	self okToChange ifFalse: [^ self].

	self modelSleep.
	directory := dir.
	self modelWakeUp.

	sortMode == nil ifTrue: [sortMode := #date].
	volList := Array with: '[]'.
	directory ifNotNil: [
		volList := volList, directory pathParts.  "Nesting suggestion from RvL"
	].
	volList := volList withIndexCollect: [:each :i | ( String new: i-1 withAll: $ ), each].
	self changed: #relabel.
	self changed: #volumeList.
	self pattern: pattern.
	directoryChangeBlock ifNotNil: [directoryChangeBlock value: directory].
]

{ #category : #initialization }
FileList2 >> directoryChangeBlock: aBlockOrNil [

	directoryChangeBlock := aBlockOrNil.
]

{ #category : #private }
FileList2 >> directoryNamesFor: item [
	"item may be file directory or server directory"
	| entries |
	entries := item directoryNames.
	dirSelectionBlock ifNotNil:[entries := entries select: dirSelectionBlock].
	^entries
]

{ #category : #initialization }
FileList2 >> fileSelectionBlock: aBlock [

	fileSelectionBlock := aBlock
]

{ #category : #private }
FileList2 >> getSelectedDirectory [
	ok == true ifFalse: [^ nil].
	^ currentDirectorySelected

]

{ #category : #private }
FileList2 >> getSelectedFile [
	"Answer a filestream on the selected file.  If it cannot be opened for read/write, try read-only before giving up; answer nil if unsuccessful"

	ok == true ifFalse: [^ nil].
	directory ifNil: [^ nil].
	fileName ifNil: [^ nil].
	^ (directory oldFileNamed: fileName) ifNil:
		[directory readOnlyFileNamed: fileName]
]

{ #category : #'own services' }
FileList2 >> importImage [
	"Import the given image file and store the resulting Form in the default Imports"

	| fname image |
	fname := fileName sansPeriodSuffix.
	image := Form fromFileNamed: self fullName.
	Imports default importImage: image named: fname.

]

{ #category : #initialization }
FileList2 >> initialDirectoryList [

	| dirList |
	dirList := (FileDirectory on: '') directoryNames collect: [ :each |
		FileDirectoryWrapper with: (FileDirectory on: each) name: each model: self].
	dirList isEmpty ifTrue:[
		dirList := Array with: (FileDirectoryWrapper 
			with: FileDirectory default 
			name: FileDirectory default localName 
			model: self)].
	dirList := dirList,(
		ServerDirectory serverNames collect: [ :n | | nameToShow dir | 
			dir := ServerDirectory serverNamed: n.
			nameToShow := n.
			(dir directoryWrapperClass with: dir name: nameToShow model: self)
				balloonText: dir realUrl
		]
	).
	^dirList
]

{ #category : #'initialize-release' }
FileList2 >> initialize [

	super initialize.
	showDirsInFileList := false.
	fileSelectionBlock := [ :entry :myPattern |
		entry isDirectory ifTrue: [
			showDirsInFileList
		] ifFalse: [
			myPattern = '*' or: [myPattern match: entry name]
		]
	].
	dirSelectionBlock := [ :dirName | true].
]

{ #category : #'drag\'n\'drop' }
FileList2 >> isDirectoryList: aMorph [
	^aMorph isKindOf: SimpleHierarchicalListMorph
]

{ #category : #initialization }
FileList2 >> labelString [
	^ (directory ifNil: [^'[]']) pathName contractTo: 50
]

{ #category : #initialization }
FileList2 >> limitedSuperSwikiDirectoryList [

	| dirList localDirName localDir |

	dirList := OrderedCollection new.
	ServerDirectory serverNames do: [ :n | | dir nameToShow | 
		dir := ServerDirectory serverNamed: n.
		dir isProjectSwiki ifTrue: [
			nameToShow := n.
			dirList add: ((dir directoryWrapperClass with: dir name: nameToShow model: self)
				balloonText: dir realUrl)
		].
	].
	ServerDirectory localProjectDirectories do: [ :each |
		dirList add: (FileDirectoryWrapper with: each name: each localName model: self)
	].
	"Make sure the following are always shown, but not twice"
	localDirName := SecurityManager default untrustedUserDirectory.
	localDir := FileDirectory on: localDirName.
	((ServerDirectory localProjectDirectories collect: [:each | each pathName]) includes: localDirName)
			ifFalse: [dirList add: (FileDirectoryWrapper with: localDir name: localDir localName model: self)].
	FileDirectory default pathName = localDirName
			ifFalse: [dirList add: (FileDirectoryWrapper with: FileDirectory default name: FileDirectory default localName model: self)].
	(dirList anySatisfy: [:each | each withoutListWrapper acceptsUploads])
		ifFalse: [dirList add: (FileDirectoryWrapper with: FileDirectory default name: FileDirectory default localName model: self)].
	^dirList
]

{ #category : #initialization }
FileList2 >> limitedSuperSwikiPublishDirectoryList [

	| dirList localDirName localDir |

	dirList := self publishingServers.
	ServerDirectory localProjectDirectories do: [ :each |
		dirList add: (FileDirectoryWrapper with: each name: each localName model: self)].

	"Make sure the following are always shown, but not twice"
	localDirName := SecurityManager default untrustedUserDirectory.
	localDir := FileDirectory on: localDirName.
	((ServerDirectory localProjectDirectories collect: [:each | each pathName]) includes: localDirName)
			ifFalse: [dirList add: (FileDirectoryWrapper with: localDir name: localDir localName model: self)].
	FileDirectory default pathName = localDirName
			ifFalse: [dirList add: (FileDirectoryWrapper with: FileDirectory default name: FileDirectory default localName model: self)].
	^dirList
]

{ #category : #'volume list and pattern' }
FileList2 >> listForPattern: pat [
	"Make the list be those file names which match the pattern."

	| sizePad newList entries |
	directory ifNil: [^#()].
	entries := (Preferences eToyLoginEnabled
		and: [Utilities authorNamePerSe notNil])
		ifTrue: [directory matchingEntries: {'submittedBy: ' , Utilities authorName.} ]
		ifFalse: [directory entries].
	(fileSelectionBlock isKindOf: MessageSend) ifTrue: [
		fileSelectionBlock arguments: {entries}.
		newList := fileSelectionBlock value.
		fileSelectionBlock arguments: #().
	] ifFalse: [
		newList := entries select: [:entry | fileSelectionBlock value: entry value: pat].
	].
	newList := newList asArray sort: self sortBlock.
	sizePad := (newList inject: 0 into: [:mx :entry | mx max: entry fileSize])
					asStringWithCommas size - 1.
	^newList collect: [ :e | self fileNameFormattedFrom: e sizePad: sizePad ]
]

{ #category : #'volume list and pattern' }
FileList2 >> listForPatterns: anArray [
	"Make the list be those file names which match the patterns."

	| sizePad newList |
	directory ifNil: [^#()].
	(fileSelectionBlock isKindOf: MessageSend) ifTrue: [
		fileSelectionBlock arguments: {directory entries}.
		newList := fileSelectionBlock value.
		fileSelectionBlock arguments: #().
	] ifFalse: [
		newList := Set new.
		anArray do: [ :pat |
			newList addAll: (directory entries select: [:entry | fileSelectionBlock value: entry value: pat]) ].
	].
	newList := newList asArray sort: self sortBlock.
	sizePad := (newList inject: 0 into: [:mx :entry | mx max: entry fileSize])
					asStringWithCommas size.
	^newList collect: [ :e | self fileNameFormattedFrom: e sizePad: sizePad ]
]

{ #category : #private }
FileList2 >> modalView: aSystemWindowOrSuch [

	modalView := aSystemWindowOrSuch
]

{ #category : #'user interface' }
FileList2 >> morphicDirectoryTreePane [

	^self morphicDirectoryTreePaneFiltered: #initialDirectoryList

]

{ #category : #'user interface' }
FileList2 >> morphicDirectoryTreePaneFiltered: aSymbol [
	^(SimpleHierarchicalListMorph 
		on: self
		list: aSymbol
		selected: #currentDirectorySelected
		changeSelected: #setSelectedDirectoryTo:
		menu: #volumeMenu:
		keystroke: nil)
			autoDeselect: false;
			enableDrag: false;
			enableDrop: true;
			yourself
		

]

{ #category : #'user interface' }
FileList2 >> morphicFileContentsPane [

	^PluggableTextMorph 
		on: self 
		text: #contents 
		accept: #put:
		readSelection: #contentsSelection 
		menu: #fileContentsMenu:shifted:

]

{ #category : #'user interface' }
FileList2 >> morphicFileListPane [

	^(PluggableListMorph 
		on: self 
		list: #fileList 
		selected: #fileListIndex
		changeSelected: #fileListIndex: 
		menu: #fileListMenu:)
			enableDrag: true;
			enableDrop: false;
			yourself


]

{ #category : #'user interface' }
FileList2 >> morphicPatternPane [
   | pane |
    pane := PluggableTextMorph 
		on: self 
		text: #pattern 
		accept: #pattern:.
    pane acceptOnCR: true.
   ^pane
		

]

{ #category : #private }
FileList2 >> okHit [

	ok := true.
	currentDirectorySelected
		ifNil: [ Beeper beep ]
		ifNotNil: [
			self class lastSelDir: directory.
			modalView delete ]
]

{ #category : #private }
FileList2 >> okHitForProjectLoader [

	| areaOfProgress |
	fileName ifNil: [^ self].
	ok := true.
	areaOfProgress := modalView firstSubmorph.
	[
		areaOfProgress setProperty: #deleteOnProgressCompletion toValue: modalView.
		self openProjectFromFile.
		modalView delete.	"probably won't get here"
	]
		on: ProgressTargetRequestNotification
		do: [ :ex | ex resume: areaOfProgress].



]

{ #category : #'own services' }
FileList2 >> okayAndCancelServices [
	"Answer ok and cancel services"

	^ {self serviceOkay. self serviceCancel}
]

{ #category : #'own services' }
FileList2 >> openImageInWindow [
	"Handle five file formats: GIF, JPG, PNG, Form stoteOn: (run coded), and BMP.
	Fail if file format is not recognized."

	| image myStream |
	myStream := (directory readOnlyFileNamed: fileName) binary.
	[image := Form fromBinaryStream: myStream.
	Project current openImage: image name: fileName saveResource: false]
		ensure: [myStream close]

]

{ #category : #'own services' }
FileList2 >> openProjectFromFile [
	"Reconstitute a Morph from the selected file, presumed to be represent
	a Morph saved via the SmartRefStream mechanism, and open it in an
	appropriate Morphic world."

	Project canWeLoadAProjectNow ifFalse: [^ self].
	ProjectViewMorph 
		openFromDirectory: directory 
		andFileName: fileName

]

{ #category : #initialization }
FileList2 >> optionalButtonRow [
	"Answer the button row associated with a file list"

	| aRow |
	aRow := AlignmentMorph newRow beSticky.
	aRow color: Color transparent.
	aRow clipSubmorphs: true.
	aRow layoutInset: 5@1; cellGap: 6.
	self universalButtonServices do:  "just the three sort-by items"
			[:service |
				aRow addMorphBack: (service buttonToTriggerIn: self).
				(service selector  == #sortBySize)
					ifTrue:
						[aRow addTransparentSpacerOfSize: (4@0)]].
	aRow setNameTo: 'buttons'.
	aRow setProperty: #buttonRow toValue: true.  "Used for dynamic retrieval later on"
	^ aRow
]

{ #category : #initialization }
FileList2 >> optionalButtonSpecs [

	^optionalButtonSpecs ifNil: [super optionalButtonSpecs]
]

{ #category : #initialization }
FileList2 >> optionalButtonSpecs: anArray [

	optionalButtonSpecs := anArray
]

{ #category : #private }
FileList2 >> postOpen [

	directory ifNotNil: [
		self changed: #(openPath) , directory pathParts. 
	].

]

{ #category : #initialization }
FileList2 >> publishingServers [

	| dirList |

	dirList := OrderedCollection new.
	ServerDirectory serverNames do: [ :n | | dir nameToShow | 
		dir := ServerDirectory serverNamed: n.
		(dir isProjectSwiki and: [dir acceptsUploads])
			 ifTrue: [
				nameToShow := n.
				dirList add: ((dir directoryWrapperClass with: dir name: nameToShow model: self)
					balloonText: dir realUrl)]].
	^dirList
]

{ #category : #'own services' }
FileList2 >> removeLinefeeds [
	"Remove any line feeds by converting to CRs instead.  This is a temporary implementation for 3.6 only... should be removed during 3.7alpha."
	| fileContents |
	fileContents := ((FileStream readOnlyFileNamed: self fullName) wantsLineEndConversion: true) contentsOfEntireFile.
	(FileStream newFileNamed: self fullName) 
		nextPutAll: fileContents;
		close.
]

{ #category : #private }
FileList2 >> saveLocalOnlyHit [
	ok := true.
	modalView delete.
	directory := fileName := nil.
	currentDirectorySelected := #localOnly.
]

{ #category : #'own services' }
FileList2 >> serviceCancel [
	"Answer a service for hitting the cancel button"

	^ (SimpleServiceEntry new
		provider: self 
		label: 'cancel' translatedNoop
		selector: #cancelHit 
		description: 'hit here to cancel ' translatedNoop)
		buttonLabel: 'cancel' translatedNoop
]

{ #category : #'own services' }
FileList2 >> serviceOkay [
	"Answer a service for hitting the okay button"

	^ (SimpleServiceEntry new
		provider: self 
		label: 'okay' translatedNoop
		selector: #okHit 
		description: 'hit here to accept the current selection' translatedNoop)
		buttonLabel: 'ok' translatedNoop
]

{ #category : #'own services' }
FileList2 >> serviceOpenProjectFromFile [
	"Answer a service for opening a .pr project file"

	^ SimpleServiceEntry 
		provider: self 
		label: 'load as project' translatedNoop
		selector: #openProjectFromFile
		description: 'open project from file' translatedNoop
		buttonLabel: 'load' translatedNoop
]

{ #category : #'own services' }
FileList2 >> servicesForFolderSelector [
	"Answer the ok and cancel servies for the folder selector"

	^ self okayAndCancelServices
]

{ #category : #'own services' }
FileList2 >> servicesForProjectLoader [
	"Answer the services to show in the button pane for the project loader"

	^ {self serviceSortByName. self serviceSortByDate. self serviceSortBySize. self serviceOpenProjectFromFile}
]

{ #category : #private }
FileList2 >> setSelectedDirectoryTo: aFileDirectoryWrapper [
	currentDirectorySelected := aFileDirectoryWrapper.
	self directory: aFileDirectoryWrapper withoutListWrapper.
	brevityState := #FileList.
	"self addPath: path."
	self changed: #fileList.
	self changed: #contents.
	self changed: #currentDirectorySelected.
]

{ #category : #'user interface' }
FileList2 >> specsForImageViewer [

	 ^{self serviceSortByName. self serviceSortByDate. self serviceSortBySize }
]

{ #category : #initialization }
FileList2 >> universalButtonServices [
	"Answer the services to be reflected in the receiver's buttons"

	^ self optionalButtonSpecs
]

{ #category : #initialization }
FileList2 >> updateDirectory [
	"directory has been changed externally, by calling directory:.
	Now change the view to reflect the change."
	self changed: #currentDirectorySelected.
	self postOpen.
]
