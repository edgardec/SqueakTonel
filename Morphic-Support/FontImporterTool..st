"
A tool to import platform (native) fonts into the image
"
Class {
	#name : #FontImporterTool,
	#superclass : #Model,
	#instVars : [
		'title',
		'allFonts',
		'emphasis',
		'currentSelection',
		'currentParent',
		'warningSeen'
	],
	#category : #'Morphic-Support'
}

{ #category : #'class initialization' }
FontImporterTool class >> initialize [

	self registerInOpenMenu.
]

{ #category : #opening }
FontImporterTool class >> open [
	"
		FontImporterTool open.
	"
	^self new open
]

{ #category : #'class initialization' }
FontImporterTool class >> registerInOpenMenu [
	(TheWorldMenu respondsTo: #registerOpenCommand:) ifTrue: [
		TheWorldMenu unregisterOpenCommand: 'Font Importer'.
		TheWorldMenu registerOpenCommand: {'Font Importer'. {self. #open}}].
		
]

{ #category : #'class initialization' }
FontImporterTool class >> unload [

	self unregisterFromOpenMenu.
]

{ #category : #'class initialization' }
FontImporterTool class >> unregisterFromOpenMenu [
	 (TheWorldMenu respondsTo: #registerOpenCommand:)
		ifTrue: [TheWorldMenu unregisterOpenCommand: 'Font Importer'].

]

{ #category : #accessing }
FontImporterTool >> allFonts [
	^ allFonts ifNil: [ | fonts |
		fonts := Dictionary new.
		Cursor wait showWhile: [
			TTFileDescription fontPathsDo:[:path |
				TTFileDescription fontFilesIn: path do:[:font| | fontDesc filename fname |
					filename := path, FileDirectory slash, font fileName.
					fname := self textForFamily: font familyName subfamily: nil.
					fontDesc := fonts 
						at: font familyName
						ifAbsentPut: (FontImporterFontDescription new fontname: fname; yourself).
					font subfamilyName
						ifNil: [fontDesc filename: filename]
						ifNotNil: [ |subfontDesc sname | 
							sname := self textForFamily: font familyName subfamily: font subfamilyName.
							subfontDesc := FontImporterFontDescription new fontname: sname; yourself.
							subfontDesc
								parent: fontDesc;
								filename: filename.
							fontDesc addChild: subfontDesc]]]].
		allFonts := fonts values sorted.
		allFonts do: [:fontDesc | fontDesc normalize].
		allFonts].

		
]

{ #category : #accessing }
FontImporterTool >> allFonts: anObject [

	allFonts := anObject.
	self changed: #allFonts.
]

{ #category : #toolbuilder }
FontImporterTool >> buildButtonBarWith: builder [
	"Build the button bar"
	| panelSpec buttonSpec |
	panelSpec := builder pluggablePanelSpec new.
	panelSpec
		layout: #horizontal;
		children: OrderedCollection new.

	buttonSpec := builder pluggableButtonSpec new
			model: self;
			label: 'Import' translated; 
			help: 'Include the font data in the image and provide a TextStyle for the font';
			action: #import;
			yourself.
	panelSpec children addLast: buttonSpec.


	buttonSpec := builder pluggableButtonSpec new
			model: self;
			label: 'Close' translated; 
			action: #close;
			yourself.
	panelSpec children addLast: buttonSpec.


	^panelSpec
]

{ #category : #toolbuilder }
FontImporterTool >> buildFontListWith: builder [
	"Build the font choosers list of font names"
	
	^ builder pluggableTreeSpec new
		model: self;
		roots: #allFonts; 
		label: #labelOf: ;
		getChildren: #childrenOf: ;
		getSelected: #currentSelection;
		setSelected: #currentSelection:;
		setSelectedParent: #currentParent:;
		menu: #fontListMenu:;
		autoDeselect: false;
		yourself

]

{ #category : #toolbuilder }
FontImporterTool >> buildPreviewPaneWith: builder [
	"Build the preview panel"
	
	^ builder pluggablePanelSpec new
		wantsResizeHandles: true;
		children: {
			builder pluggableInputFieldSpec new
				model: self;
				getText: #filename;
				readOnly: true;
				indicateUnacceptedChanges: false;
				font: self filenameFont;
				frame: (LayoutFrame 
					fractions: (0@0 corner: 1@0)
					offsets: (0@0 corner: 0@ self filenameHeight));
				yourself.

			builder pluggableTextSpec new
				model: self;
				getText: #previewText;
				askBeforeDiscardingEdits: false;
				indicateUnacceptedChanges: false;
				softLineWrap: false;
				frame: (LayoutFrame 
					fractions: (0@0 corner: 1@0.75)
					offsets: (0@ self filenameHeight corner: 0@0));
				yourself.
				
			builder pluggableTextSpec new
				model: self;
				getText: #copyright;
				readOnly: true;
				indicateUnacceptedChanges: false;
				frame: (LayoutFrame 
					fractions: (0@0.75 corner: 1@1));
				yourself
			
		};
		yourself
]

{ #category : #toolbuilder }
FontImporterTool >> buildWith: builder [
	"Create the ui for the browser"
	"ToolBuilder open: self"
	
	| windowSpec |
	windowSpec := self buildWindowWith: builder specs: {
		(self fontListFrame) -> [self buildFontListWith: builder].
		(self previewFrame) -> [self buildPreviewPaneWith: builder].
		(self buttonsFrame) -> [self buildButtonBarWith: builder].
	}.
	^ builder build: windowSpec
]

{ #category : #layout }
FontImporterTool >> buttonHeight [
	^ Preferences standardButtonFont height * 3
]

{ #category : #layout }
FontImporterTool >> buttonsFrame [

	^ LayoutFrame
		fractions: (0@1 corner: 1@1)
		offsets: (0@ self buttonHeight negated corner: 0@0)

]

{ #category : #accessing }
FontImporterTool >> childrenOf: aFontDescription [

	^ aFontDescription children
]

{ #category : #actions }
FontImporterTool >> close [
	self changed: #close.
]

{ #category : #'model access' }
FontImporterTool >> copyright [
	| f |
	f := self selectedFont ifNil:[^ ''].
	^ f isTTCFont
		ifTrue: [f ttcDescription copyright ifNil: ['']]
		ifFalse: ['']
]

{ #category : #accessing }
FontImporterTool >> currentParent [

	^ currentParent
]

{ #category : #accessing }
FontImporterTool >> currentParent: anObject [

	anObject = currentParent ifTrue: [^ self].
	currentParent := anObject.
	self changed: #currentParent.

]

{ #category : #accessing }
FontImporterTool >> currentSelection [

	^ currentSelection
]

{ #category : #accessing }
FontImporterTool >> currentSelection: anObject [

	anObject = currentSelection ifTrue: [^ self].
	currentSelection := anObject.
	self changed: #currentSelection.
	self changed: #previewText.
	self changed: #filename.
	self changed: #copyright.
]

{ #category : #accessing }
FontImporterTool >> emphasis [

	^ emphasis
]

{ #category : #accessing }
FontImporterTool >> emphasis: anObject [

	emphasis := anObject
]

{ #category : #'model access' }
FontImporterTool >> filename [

	^ self currentSelection
		ifNil: ['']
		ifNotNil: [:sel |
			String streamContents: [:stream |
				sel allFilenames
					do: [:filename | stream nextPutAll: filename]
					separatedBy: [stream nextPut: $,;nextPut: $ ]]]
]

{ #category : #toolbuilder }
FontImporterTool >> filenameFont [
	^ Preferences standardDefaultTextFont
]

{ #category : #layout }
FontImporterTool >> filenameHeight [
	^ self filenameFont height * 2
]

{ #category : #helper }
FontImporterTool >> font: f hasGlyphOf: aCharacter [

	| font |
	font := f isFontSet ifTrue: [f fontArray first] ifFalse: [f].
	^ font isTTCFont
		ifFalse: [font hasGlyphOf: aCharacter]
		ifTrue: [
			" [(f hasGlyphOf: aCharacter) not] does not work, the fallback glyph is always found instead.
			So we fake. if aCharacter is the same form as Character null aka 0, we assume absence."
			(font characterFormAt: aCharacter) bits ~= font fallbackForm bits]

]

{ #category : #helper }
FontImporterTool >> fontFromFamily: aFamily [

	| readFonts | 
	aFamily ifNil: [^ TextStyle default fonts first].
	readFonts := TTFileDescription readFontsFrom: aFamily allFilenames anyOne.
	^ (readFonts size > 1
		ifTrue: [ 
			| ftArray |
			" see TTCFontSet>>newTextStyleFromTT: "
			ftArray := readFonts collect: [:ttc | |f|
				ttc ifNil: [nil] ifNotNil: [
					f := TTCFont new.
					f ttcDescription: ttc.
					f pointSize: 11.0 .
					f]].
			TTCFontSet newFontArray: ftArray]
		ifFalse: [ |f|
			f := TTCFont new.
			f ttcDescription: readFonts anyOne.
			f pointSize: 11.0 .	
			f])
]

{ #category : #layout }
FontImporterTool >> fontListFrame [

	^ LayoutFrame
		fractions: (0@0 corner: 0.4@1)
		offsets: (0@0 corner: 0@ self buttonHeight negated)
]

{ #category : #'font list' }
FontImporterTool >> fontListMenu: aMenu [

	^ aMenu addTranslatedList: #(
		('Import Font'	import	'Include the font data in the image and provide a TextStyle for the font')
		('Link Font'		link  'Install the font as a link to its file and provide a TextStyle for the referenced font'))
	yourself
]

{ #category : #actions }
FontImporterTool >> import [
	| megaSize filenames fonts |
	fonts := self currentSelection.
	filenames := fonts allFilenames.
	megaSize := ((filenames inject: 0 into: [ :sum :fn |
		sum + (FileStream readOnlyFileNamed: fn do: [:file | file size])]) / (1024 * 1024)) asFloat.
	(UIManager default confirm: (
'About to import {1}{2}.\\This is at least {3} MB of space required in the image.\
Please respect the copyright and embedding restrictions of the font.\
Proceed?' 
		withCRs format: {
			self currentParent 
				ifNotNil: [:p| p fontname, ' ', self currentSelection fontname]
				ifNil: [self currentSelection fontname].
			filenames size > 1 ifTrue: [' (', filenames size, ' font files)'] ifFalse: [''].
			megaSize printShowingDecimalPlaces: 2}))
		ifTrue: [ 
			filenames do: [:filename | | readFonts |
				readFonts := TTCFontDescription addFromTTFile: filename.
				readFonts isCollection
					ifFalse: [TTCFont newTextStyleFromTT: readFonts]
					ifTrue: [self importFontFamily: readFonts]]].
	self allFonts: nil. "force redraw"

]

{ #category : #helper }
FontImporterTool >> importFontFamily: readFonts [

	|r rest array |
	r := readFonts detect: [:f | 
		[f isRegular] on: Error do: [false] "hack for unknown emphases"
	] ifNone: [^ TTCFont newTextStyleFromTT: readFonts first].
	rest := readFonts copyWithout: r.
	array :=TTCFont pointSizes collect: [:pt | | f | 
		f := TTCFont new ttcDescription: r; pointSize: pt; yourself.
		rest do: [:rf |
			(self isStyleNameSupported: rf subfamilyName)
				ifTrue: [f derivativeFont: (TTCFont new ttcDescription: rf; pointSize: pt; yourself)]
				ifFalse: [
					Transcript show: 'Cannot import unknown style ', rf subfamilyName, ' from Font family ', f name]]. 
		f].
	^ TTCFont reorganizeForNewFontArray: array name: array first name asSymbol.
]

{ #category : #initialize }
FontImporterTool >> initialExtent [

	^ 600@400.
]

{ #category : #initialize }
FontImporterTool >> initialize [

	super initialize.
	emphasis := 0.

]

{ #category : #helper }
FontImporterTool >> isStyleNameSupported: subfamilyName [

	^ (TextStyle decodeStyleName: subfamilyName) second isEmpty
]

{ #category : #'model access' }
FontImporterTool >> labelOf: aFontDescription [

	^ aFontDescription fontname

	
]

{ #category : #actions }
FontImporterTool >> link [
	| filenames fonts |
	fonts := self currentSelection.
	self warningSeen ifFalse: [
		(UIManager default confirm: (
'Note that linking a font instead of importing may make the
image un-portable, since the linked font must be present on
the system the next time the image is run.

This warning is only shown once per session.' ) trueChoice: 'Proceed' falseChoice: 'Cancel')
		ifFalse: [^ self].
		self warningSeen: true]..
	filenames := fonts allFilenames.
	filenames do: [:filename | | readFonts |
		readFonts := TTFileDescription readFontsFrom: filename.
		readFonts isCollection
					ifFalse: [TTCFont newTextStyleFromTT: readFonts]
					ifTrue: [self importFontFamily: readFonts]].
	self allFonts: nil. "force redraw"
]

{ #category : #initialize }
FontImporterTool >> open [
	^ToolBuilder open: self
]

{ #category : #layout }
FontImporterTool >> previewFrame [

	^ LayoutFrame
		fractions: (0.4@0 corner: 1@1)
		offsets: (0@0 corner: 0@ self buttonHeight negated)
]

{ #category : #'model access' }
FontImporterTool >> previewText [

	^ self selectedFont
		ifNil: [Text new]
		ifNotNil: [:font | font sampleText]
]

{ #category : #'font list' }
FontImporterTool >> selectedFont [
	| fontDesc font |
	fontDesc := self currentSelection.
	font := self fontFromFamily: fontDesc.
	font isFontSet ifTrue: [
		font := (self currentParent isNil or: [self currentParent = self currentSelection])
			ifTrue: [font fontArray anyOne]
			ifFalse: [ "we have selected a leaf  "
				font fontArray
					detect: [:subfont | subfont subfamilyName = fontDesc fontname]
					ifNone: [font]]].
	^font emphasized: emphasis
]

{ #category : #helper }
FontImporterTool >> textForFamily: familyName subfamily: subfamilyName [

	subfamilyName ifNil: [
		^ (TextStyle named: familyName)
			ifNil: [familyName]
			ifNotNil: [:style | style isTTCStyle
				ifTrue: ["we are already present "
					Text string: familyName attribute: TextEmphasis underlined]
				ifFalse: [familyName]]].
		
	" frome here on it is only about subfamilies"
	
	(self isStyleNameSupported: subfamilyName)
		ifFalse: [^ Text string: subfamilyName attribute: TextColor gray].

	^ (TextStyle named: familyName)
		ifNil: ["importable" subfamilyName]
		ifNotNil: [:style |
			(style isTTCStyle and: [ | regular emph |
					regular  := style fonts anyOne.
					emph := TTCFont indexOfSubfamilyName: subfamilyName.
					" detect if this style is already imported "
					regular emphasis = emph or: [(regular emphasis: emph) ~= regular]])
				ifFalse: ["again importable" subfamilyName]
				ifTrue: [Text string: subfamilyName attribute: TextEmphasis underlined]]
]

{ #category : #accessing }
FontImporterTool >> warningSeen [

	^ warningSeen ifNil: [false]
]

{ #category : #accessing }
FontImporterTool >> warningSeen: anObject [

	warningSeen := anObject
]

{ #category : #toolbuilder }
FontImporterTool >> windowTitle [

	^'Choose a Font to import' translated
]
