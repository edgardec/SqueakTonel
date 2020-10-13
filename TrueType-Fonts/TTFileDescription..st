"
Contrary to TTFontDescritption, this class leaves true type files on disk and only reads the required portions when constructing glyphs. This avoids the need of reading the entire font into memory at the cost of having to hit disk whenever a glyph is requested.
"
Class {
	#name : #TTFileDescription,
	#superclass : #Object,
	#instVars : [
		'fileName',
		'fileOffset',
		'familyName',
		'subfamilyName',
		'copyright',
		'ascender',
		'descender',
		'lineGap',
		'unitsPerEm',
		'numGlyphs',
		'indexToLocOffset',
		'indexToLocFormat',
		'glyphTableOffset',
		'cmapType',
		'cmapOffset',
		'numHMetrics',
		'hmtxTableOffset',
		'sTypoAscender',
		'sTypoDescender',
		'sTypoLineGap'
	],
	#classVars : [
		'AllFontsAndFiles',
		'FontPaths',
		'OfferNonPortableFonts'
	],
	#category : #'TrueType-Fonts'
}

{ #category : #'font paths' }
TTFileDescription class >> allFamilyNamesAndFiles [
	"Answer a dictionary of all known family names and their corresponding file names."
	
	AllFontsAndFiles ifNil:[
		AllFontsAndFiles := Dictionary new.
		Cursor wait showWhile:[self allFontsDo:[:font|
			| names |
			names := AllFontsAndFiles at: font familyName 
					ifAbsentPut:[OrderedCollection new].
			names add: font fileName]]].
	^AllFontsAndFiles 
]

{ #category : #'font paths' }
TTFileDescription class >> allFontsAndFiles [
	"Answer a dictionary of all known family names and their corresponding file names."
	
	AllFontsAndFiles ifNil:[
		AllFontsAndFiles := Dictionary new.
		Cursor wait showWhile:[self allFontsDo:[:font|
			| names |
			names := AllFontsAndFiles at: font familyName 
					ifAbsentPut:[OrderedCollection new].
			names add: font fileName]]].
	^AllFontsAndFiles 
]

{ #category : #'font paths' }
TTFileDescription class >> allFontsDo: aBlock [
	"Evaluate aBlock with all the fonts we can find. Use sparingly."
	self fontPathsDo:[:path|
		self fontFilesIn: path do:[:font|
			font familyName 
				ifNotNil:[aBlock value: font]]]
]

{ #category : #'font paths' }
TTFileDescription class >> findFontFile: fontFileName [
	"Find the path containing the font with the given name.
	If it can't be found, return nil."
	
	self fontPathsDo:[:path|
		| fd |
		fd := FileDirectory on: path.
		([fd fileExists: fontFileName] on: Error do:[false]) 
			ifTrue:[^fd fullNameFor: fontFileName].
	].
	^nil
]

{ #category : #'font paths' }
TTFileDescription class >> fontFilesIn: path do: aBlock [
	"TTFileDescription loadAllFilesIn: 'C:\Windows\Fonts'"
	"Load all the TTF files we can find in the given path"
	| fd |
	fd := FileDirectory on: path.
	(fd fileNamesMatching: '*.ttf;*.ttc') do:[:fn|
		(self readFontsFrom: fn) do: aBlock ]
]

{ #category : #'user interaction' }
TTFileDescription class >> fontFromUser [
	"TTFileDescription fontFromUser"
	^self fontFromUser: TextStyle defaultFont
]

{ #category : #'user interaction' }
TTFileDescription class >> fontFromUser: priorFont [
	^self fontFromUser: priorFont allowKeyboard: true
]

{ #category : #'user interaction' }
TTFileDescription class >> fontFromUser: priorFont allowKeyboard: aBoolean [
	"TTFileDescription fontFromUser"
	| fontMenu fontNames builder resultBlock style font widget result |
	builder := ToolBuilder default.
	fontNames := self allFontsAndFiles keys asArray sort.
	fontMenu := builder pluggableMenuSpec new.
	fontMenu label: 'Non-portable fonts'.
	resultBlock := [:value| result := value].
	fontNames do: [:fontName | | active ptMenu item |
		active := priorFont familyName sameAs: fontName.
		ptMenu := builder pluggableMenuSpec new.
		TTCFont pointSizes do: [:pt | | label |
			label := pt printString, ' pt'.
			item := ptMenu add: label 
				target: resultBlock
				selector: #value:
				argumentList: {{fontName. pt}}.
			item checked: (active and:[pt = priorFont pointSize]).
		].
		item := fontMenu add: fontName action: nil.
		item subMenu: ptMenu.
		item checked: active.
	].
	widget := builder open: fontMenu.
	builder runModal: widget.
	result ifNil:[^nil].
	style := (TextStyle named: result first) ifNil:[self installFamilyNamed: result first].
	style ifNil: [^ self].
	font := style fonts detect: [:any | any pointSize = result last] ifNone: [nil].
	^ font

]

{ #category : #'instance creation' }
TTFileDescription class >> fontOffsetsInFile: file [
	"Answer a collection of font offsets in the given file"
	| tag version nFonts |
	file position: 0.
	tag := file next: 4.
	tag caseOf: {
		['true' asByteArray] -> ["Version 1.0 TTF file"
			"http://developer.apple.com/textfonts/TTRefMan/RM06/Chap6.html
			The values 'true' (0x74727565) and 0x00010000 are recognized by the Mac OS 
			as referring to TrueType fonts."
			^Array with: 0 "only one font"
		].
		[#[0 1 0 0]] -> ["Version 1.0 TTF file"
			^Array with: 0 "only one font"
		].
		['ttcf' asByteArray]	-> ["TTC file"
			version := file next: 4.
			(version = #[0 1 0 0] or: [version = #[0 2 0 0]]) ifFalse: [^self error: 'Unsupported TTC version'].
			nFonts := file nextNumber: 4.
			^(1 to: nFonts) collect: [:i | file nextNumber: 4].
		].
	} otherwise:[
		self error: 'This is not a valid Truetype file'.
	].
]

{ #category : #'font paths' }
TTFileDescription class >> fontPathsDo: aBlock [
	"Evaluate aBlock with all of the font paths that should be searched on the current platform"

	"Start with the current directory"
	aBlock value: FileDirectory default pathName.

	"Then subdirectory 'fonts'"
	aBlock value: (FileDirectory default directoryNamed: 'fonts') pathName.

	"Platform specific directories"
	Smalltalk platformName caseOf:{
		['Win32']	->	[
			"Standard Windows fonts directory"
			aBlock value: 'C:\Windows\Fonts'.
		].
		['Mac OS']	->	[
			"Standard system fonts directories"
			#('/System/Library/Fonts' '/Library/Fonts') do: [:fontDir |
				aBlock value: fontDir].
		].
		['unix']		->	[ | base |
			"Standard fonts are in /usr/share/fonts/*"
			base := '/usr/share/fonts'.
			(FileDirectory on: base) directoryTreeDo: [ :path |
				path last isDirectory ifTrue: [
					aBlock value: path last fullName ] ].
		].
	} otherwise:[].
	
]

{ #category : #'class initialization' }
TTFileDescription class >> initialize [
	"TTFileDescription initialize"
	Smalltalk addToShutDownList: self.
	FontPaths := Dictionary new.
	AllFontsAndFiles := nil.
]

{ #category : #'instance creation' }
TTFileDescription class >> installFamilyNamed: familyName [
	"Install all the corresponding fonts for this family"
	"
		TTFileDescription installFamilyNamed: 'Arial'.
		TTFileDescription installFamilyNamed: 'Batang'.
	"
	| fontFiles |
	fontFiles := self allFontsAndFiles at: familyName ifAbsent:[#()].
	fontFiles do:[:fileName| | ttDesc |
		ttDesc := (self readFontsFrom: fileName) detect:[:fnt| fnt familyName = familyName].
		TTCFont newTextStyleFromTT: ttDesc.
	].
	^TextStyle named: familyName
]

{ #category : #examples }
TTFileDescription class >> loadAllFontFiles [
	"Load all the TTF files we can find in all font paths"
	"
		TTFileDescription loadAllFontFiles.
	"
	self fontPathsDo:[:path| | fd |
		fd := FileDirectory on: path.
		(fd fileNamesMatching: '*.ttf;*.ttc') do:[:fn|
			(self readFontsFrom: fn) do:[:font|
				(1 to: font numGlyphs) 
					do:[:i| font readGlyphAt: i-1] 
					displayingProgress: 'Reading ', font name].
		] displayingProgress: 'Scanning ', path.
	].
]

{ #category : #'user interaction' }
TTFileDescription class >> offerNonPortableFonts [
	"Should native fonts be offered when displaying font menus?"
	<preference: 'Offer Native Fonts'
		category: 'Morphic'
		description: 'When true, an additional menu is offered for choosing non-portable fonts'
		type: #Boolean>
	^OfferNonPortableFonts ifNil:[true]
]

{ #category : #'user interaction' }
TTFileDescription class >> offerNonPortableFonts: aBool [
	"Should native fonts be offered when displaying font menus?"
	OfferNonPortableFonts := aBool.
]

{ #category : #'instance creation' }
TTFileDescription class >> openFontFile: fontFileName do: aBlock [
	"Open the font with the given font file name"
	| fontFilePath file |
	fontFilePath := FontPaths at: fontFileName 
		ifAbsentPut:[self findFontFile: fontFileName].
	fontFilePath ifNil:[^nil].
	file := [FileStream readOnlyFileNamed: fontFilePath] on: Error do:[:ex|
		"We lost the font; someone might have moved it away"
		fontFilePath removeKey: fontFileName ifAbsent:[].
		^nil
	].
	^[aBlock value: file binary] ensure:[file close].
]

{ #category : #'instance creation' }
TTFileDescription class >> readFontsFrom: aFilename [
	"Reads and returns all the fonts in the given file"
	"
		TTFileDescription readFontsFrom: 'batang.ttc'.
	"
	^self openFontFile: aFilename do:[:file|
		(self fontOffsetsInFile: file)
			collect:[:offset| self new on: aFilename offset: offset]
			thenSelect:[:font| font notNil]].
	
]

{ #category : #'class initialization' }
TTFileDescription class >> shutDown [
	"Flush my caches"
	FontPaths := Dictionary new.
	AllFontsAndFiles := nil.
]

{ #category : #accessing }
TTFileDescription >> ascender [
	"Ascender of the font. Relative to unitsPerEm.
	Easily confused with the typographic ascender."
	^ascender
]

{ #category : #accessing }
TTFileDescription >> at: charOrCode [
	"Compatibility with TTFontDescription"
	^self glyphAt: charOrCode
]

{ #category : #glyphs }
TTFileDescription >> childGlyphAt: glyphIndex in: glyphCache fromFile: fontFile [
	"Get the glyph with the given glyph index. Look in cache first, then read from file.
	Ensure file is positioned at point where it was when it came here."
	^glyphCache at: glyphIndex ifAbsentPut:[ | glyph filePos |
		filePos := fontFile position.
		glyph := self readGlyphAt: glyphIndex fromFile: fontFile.
		fontFile position: filePos.
		glyph].
]

{ #category : #accessing }
TTFileDescription >> copyright [

	^ copyright
]

{ #category : #accessing }
TTFileDescription >> descender [
	"Descender of the font. Relative to unitsPerEm.
	Easily confused with the typographic descender."
	^descender
]

{ #category : #private }
TTFileDescription >> displayAll [
	"Read all the glyphs and display them"
	| glyph form scale points x y |
	points := 24.
	scale := points asFloat / unitsPerEm.
	x := y := 0.
	Display deferUpdates: true.
	1 to: numGlyphs do:[:i|
		glyph := self readGlyphAt: i-1.
		form := glyph asFormWithScale: scale
			ascender: ascender
			descender: descender.
		Display fillWhite: (x@y extent: form extent).
		form displayOn: Display at: x@y rule: 34.
		Display forceToScreen: (x@y extent: form extent).
		x := x + form width.
		x > Display width ifTrue:[y := y + form height. x := 0].
		y > Display height ifTrue:[y := 0].
		Sensor anyButtonPressed ifTrue:[^Display restore].
	].
]

{ #category : #glyphs }
TTFileDescription >> fallbackGlyph [
	"Answer the fallback glyph, the first in the loca table "
	| glyph |
	self withFileDo:[:fontFile| 
		glyph := self readGlyphAt: 0 fromFile: fontFile.
		self updateGlyphMetrics: glyph fromFile: fontFile.
	].
	^glyph
]

{ #category : #accessing }
TTFileDescription >> familyName [
	"The family name for the font"
	^familyName
]

{ #category : #accessing }
TTFileDescription >> fileName [
	"The name of the Truetype file"
	^fileName
]

{ #category : #'ttf tables' }
TTFileDescription >> findTable: tag in: fontFile [
	"Position the fontFile at the beginning of the table with the given tag.
	Answer true if we found the table, false otherwise."
	| maxTables chksum offset length table |
	fontFile position: fileOffset.
	fontFile skip: 4. "version"
	maxTables := fontFile nextNumber: 2.
	fontFile skip: 6.
	1 to: maxTables do:[:i|
		table := (fontFile next: 4) asString.
		chksum := fontFile nextNumber: 4.
		offset := fontFile nextNumber: 4.
		length := fontFile nextNumber: 4.
		table = tag ifTrue:[
			fontFile position: offset.
			^true].
	].
	chksum. length. "fake usage"
	^false
]

{ #category : #accessing }
TTFileDescription >> fontHeight [
	^ascender - descender
]

{ #category : #glyphs }
TTFileDescription >> getGlyphFlagsFrom: fontFile size: nPts [
	"Read in the flags for this glyph.  The outer loop gathers the flags that
	are actually contained in the table.  If the repeat bit is set in a flag
	then the next byte is read from the table; this is the number of times
	to repeat the last flag.  The inner loop does this, incrementing the
	outer loops index each time."
	| flags index repCount flagBits |
	flags := ByteArray new: nPts.
	index := 1.
	[index <= nPts] whileTrue:[
		flagBits := fontFile next.
		flags at: index put: flagBits.
		(flagBits bitAnd: 8) = 8 ifTrue:[
			repCount := fontFile next.
			repCount timesRepeat:[
				index := index + 1.
				flags at: index put: flagBits]].
		index := index + 1].
	^flags
]

{ #category : #glyphs }
TTFileDescription >> glyphAt: charOrCode [
	"Answer the glyph with the given code point"
	| codePoint glyph |
	codePoint := charOrCode asCharacter charCode.
	self withFileDo:[:fontFile| | glyphIndex |
		glyphIndex := self readCmapTableAt: codePoint fromFile: fontFile.
		glyph := self readGlyphAt: glyphIndex fromFile: fontFile.
		self updateGlyphMetrics: glyph fromFile: fontFile.
	].
	^glyph
]

{ #category : #testing }
TTFileDescription >> isRegular [
	"Answer true if I am a Regular/Roman font (i.e. not bold, etc.)"
	^ (TTCFont indexOfSubfamilyName: (self subfamilyName)) = 0.

]

{ #category : #accessing }
TTFileDescription >> lineGap [
	"Leading of the font. Relative to unitsPerEm.
	Easily confused with the typographic linegap."
	^lineGap
]

{ #category : #accessing }
TTFileDescription >> name [
	"For compatibility with TTFontDescription"
	^familyName
]

{ #category : #accessing }
TTFileDescription >> numGlyphs [
	"The number of glyphs represented in this font"
	^numGlyphs
]

{ #category : #initialize }
TTFileDescription >> on: aFileName [
	"Initialize the receiver from a file name"
	fileName := aFileName.
	self withFileDo:[:fontFile|
		(self findTable: 'head' in: fontFile) 
			ifFalse:[^self error: 'File does not have a header table'].
		self processFontHeaderTable: fontFile.
		(self findTable: 'maxp' in: fontFile) 
			ifFalse:[^self error: 'File does not have a profile table'].
		self processMaximumProfileTable: fontFile.
		(self findTable: 'name' in: fontFile) 
			ifFalse:[^self error: 'File does not have a naming table'].
		self processNamingTable: fontFile.
		(self findTable: 'hhea' in: fontFile) 
			ifFalse:[^self error: 'File does not have a horizontal header table'].
		self processHorizontalHeaderTable: fontFile.
		(self findTable: 'hmtx' in: fontFile) 
			ifFalse:[^self error: 'File does not have a horizontal header table'].
		hmtxTableOffset := fontFile position.
		(self findTable: 'loca' in: fontFile) 
			ifFalse:[^self error: 'File does not have a naming table'].
		indexToLocOffset := fontFile position.
		(self findTable: 'glyf' in: fontFile) 
			ifFalse:[^self error: 'File does not have a naming table'].
		glyphTableOffset := fontFile position.
		(self findTable: 'cmap' in: fontFile) 
			ifFalse:[^self error: 'File does not have a header table'].
		self processCharacterMappingTable: fontFile.
	].
]

{ #category : #initialize }
TTFileDescription >> on: aFileName offset: fontOffset [
	"Initialize the receiver from a file name"
	fileName := aFileName.
	fileOffset := fontOffset.
	self withFileDo:[:fontFile|
		"Some TTC fonts may actually be collection of PostScript-Based OpenType fonts"
		(self findTable: 'CFF ' in: fontFile)
			ifTrue: [^ nil]
			ifFalse: [fontFile position: fileOffset "reset"].			
		"Some bitmap fonts are called .ttf; skip anything that doesn't have a header"
		(self findTable: 'head' in: fontFile) ifFalse:[^nil].
		self processFontHeaderTable: fontFile.
		(self findTable: 'maxp' in: fontFile) 
			ifFalse:[^self error: 'File does not have a profile table'].
		self processMaximumProfileTable: fontFile.
		(self findTable: 'name' in: fontFile) 
			ifFalse:[^self error: 'File does not have a naming table'].
		self processNamingTable: fontFile.
		(self findTable: 'hhea' in: fontFile) 
			ifFalse:[^self error: 'File does not have a horizontal header table'].
		self processHorizontalHeaderTable: fontFile.
		(self findTable: 'OS/2' in: fontFile)
			ifTrue:[self processOS2Table: fontFile].
		(self findTable: 'hmtx' in: fontFile) 
			ifFalse:[^self error: 'File does not have a horizontal header table'].
		hmtxTableOffset := fontFile position.
		(self findTable: 'loca' in: fontFile) 
			ifFalse:[^self error: 'File does not have a naming table'].
		indexToLocOffset := fontFile position.
		(self findTable: 'glyf' in: fontFile) 
			ifFalse:[^self error: 'File does not have a naming table'].
		glyphTableOffset := fontFile position.
		(self findTable: 'cmap' in: fontFile) 
			ifFalse:[^self error: 'File does not have a header table'].
		self processCharacterMappingTable: fontFile.
	].
]

{ #category : #printing }
TTFileDescription >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: '('; print: fileName; nextPutAll: ')'.
]

{ #category : #'ttf tables' }
TTFileDescription >> processCharacterMappingTable: fontFile [
	"Read the font's character to glyph index mapping table."
	| initialOffset nSubTables pID sID offset |
	initialOffset := fontFile position.
	fontFile skip: 2. "Skip table version"
	nSubTables := fontFile nextNumber: 2.
	1 to: nSubTables do:[:i|
		pID := fontFile nextNumber: 2.
		sID := fontFile nextNumber: 2.
		offset := fontFile nextNumber: 4.
		"Check if this is either a Unicode (0), Macintosh (1),
		or a Windows (3) encoded table"
		(#(0 1 3) includes: pID) ifTrue:[
			cmapType := pID.
			cmapOffset := initialOffset + offset.
			cmapType = 0 ifTrue:[^self]. "found Unicode table; use it"
		].
	].
]

{ #category : #glyphs }
TTFileDescription >> processCompositeGlyph: glyph contours: nContours from: fontFile [
	"Read a composite glyph from the font data. The glyph passed into this method contains some state variables that must be copied into the resulting composite glyph."
	| flags glyphIndex hasInstr ofsX ofsY iLen a11 a12 a21 a22 m glyphCache |
	glyphCache := Dictionary new.
	a11 := a22 := 16r4000.	"1.0 in F2Dot14"
	a21 := a12 := 0.			"0.0 in F2Dot14"
	"Copy state"
	hasInstr := false.
	[ flags := fontFile nextNumber: 2.
	glyphIndex := fontFile nextNumber: 2.
	(flags bitAnd: 1) = 1 ifTrue:[
		ofsX := self short: (fontFile nextNumber: 2).
		ofsY := self short: (fontFile nextNumber: 2).
	] ifFalse:[
		(ofsX := fontFile next) > 127 ifTrue:[ofsX := ofsX - 256].
		(ofsY := fontFile next) > 127 ifTrue:[ofsY := ofsY - 256].
	].
	((flags bitAnd: 2) = 2) ifFalse:[
		| i1 i2 p1 p2 |
		(flags bitAnd: 1) = 1 ifTrue: [
			i1 := ofsX + 65536 \\ 65536.
			i2 := ofsY + 65536 \\ 65536]
		 ifFalse: [
			i1 := ofsX + 256 \\ 256.
			i2 := ofsY + 256 \\ 256].
		p1 := glyph referenceVertexAt: i1+1.
		p2 := (self childGlyphAt: glyphIndex in: glyphCache fromFile: fontFile) referenceVertexAt: i2+1.
		ofsX := p1 x - p2 x.
		ofsY := p1 y - p2 y.
	].
	(flags bitAnd: 8) = 8 ifTrue:[
		a11 := a22 := self short: (fontFile nextNumber: 2)].
	(flags bitAnd: 64) = 64 ifTrue:[
		a11 := self short: (fontFile nextNumber: 2).
		a22 := self short: (fontFile nextNumber: 2).
	].
	(flags bitAnd: 128) = 128 ifTrue:[
		"2x2 transformation"
		a11 := self short: (fontFile nextNumber: 2).
		a21 := self short: (fontFile nextNumber: 2).
		a12 := self short: (fontFile nextNumber: 2).
		a22 := self short: (fontFile nextNumber: 2).
	].
	m := MatrixTransform2x3 new.
	"Convert entries from F2Dot14 to float"
	m a11: (a11 asFloat / 16r4000).
	m a12: (a12 asFloat / 16r4000).
	m a21: (a21 asFloat / 16r4000).
	m a22: (a22 asFloat / 16r4000).
	m a13: ofsX.
	m a23: ofsY.
	glyph addGlyph: (self childGlyphAt: glyphIndex in: glyphCache fromFile: fontFile) transformation: m.
	hasInstr := hasInstr or:[ (flags bitAnd: 256) = 256].
	"Continue as long as the MORE:=COMPONENTS bit is set"
	(flags bitAnd: 32) = 32] whileTrue.
	hasInstr ifTrue:[
		iLen := fontFile nextNumber: 2.
		fontFile skip: iLen].
]

{ #category : #'ttf tables' }
TTFileDescription >> processFontHeaderTable: fontFile [
"Value				Data Type    Description
unitsPerEm			USHORT      Granularity of the font's em square.
xMax				USHORT      Maximum X-coordinate for the entire font.
xMin				USHORT      Minimum X-coordinate for the entire font.
yMax				USHORT      Maximum Y-coordinate for the entire font.
yMin				USHORT      Minimum Y-coordinate for the entire font.
indexToLocFormat	SHORT       Used when processing the Index To Loc Table."

	fontFile skip: 4. "Skip table version number"
	fontFile skip: 4. "Skip font revision number"
	fontFile skip: 4. "Skip check sum adjustment"
	fontFile skip: 4. "Skip magic number"
	fontFile skip: 2. "Skip flags"

	unitsPerEm := fontFile nextNumber: 2.

	fontFile skip: 8. "Skip creation date"
	fontFile skip: 8. "Skip modification date"

	"Skip min/max values of all glyphs"
	fontFile skip: 2.
	fontFile skip: 2.
	fontFile skip: 2.
	fontFile skip: 2.

	fontFile skip: 2. "Skip mac style"
	fontFile skip: 2. "Skip lowest rec PPEM"
	fontFile skip: 2. "Skip font direction hint"

	indexToLocFormat := fontFile nextNumber: 2.

]

{ #category : #'ttf tables' }
TTFileDescription >> processHorizontalHeaderTable: fontFile [
"
ascender           SHORT          Typographic ascent.
descender          SHORT          Typographic descent.
lineGap            SHORT          Typographic lineGap.
numberOfHMetrics   USHORT         Number hMetric entries in the HTMX
                                               Table; may be smaller than the total
                                             number of glyphs.
"
	fontFile skip: 4. "Skip table version"
	ascender := self short: (fontFile nextNumber: 2).
	descender := self short: (fontFile nextNumber: 2).
	lineGap := self short: (fontFile nextNumber: 2).
	fontFile skip: 2. "Skip advanceWidthMax"
	fontFile skip: 2. "Skip minLeftSideBearing"
	fontFile skip: 2. "Skip minRightSideBearing"
	fontFile skip: 2. "Skip xMaxExtent"
	fontFile skip: 2. "Skip caretSlopeRise"
	fontFile skip: 2. "Skip caretSlopeRun"
	fontFile skip: 10. "Skip 5 reserved shorts"
	fontFile skip: 2. "Skip metricDataFormat"

	numHMetrics := fontFile nextNumber: 2.

	^numHMetrics
]

{ #category : #'ttf tables' }
TTFileDescription >> processMaximumProfileTable: fontFile [
"
numGlyphs         USHORT      The number of glyphs in the font.
"
	fontFile skip: 4. "Skip Table version number"
	numGlyphs := fontFile nextNumber: 2.
]

{ #category : #'ttf tables' }
TTFileDescription >> processNamingTable: fontFile [
"copyright         CHARPTR     The font's copyright notice.
familyName        CHARPTR     The font's family name.
subfamilyName     CHARPTR     The font's subfamily name.
uniqueName        CHARPTR     A unique identifier for this font.
fullName          CHARPTR     The font's full name (a combination of
                                          familyName and subfamilyName).
versionName       CHARPTR     The font's version string.
"
	| nRecords initialOffset storageOffset format |
	initialOffset := fontFile position.
	format := fontFile nextNumber: 2.
	format = 0 ifFalse: [self error: 'Cannot handle format 1 naming tables'].
	"Get the number of name records"
	nRecords := fontFile nextNumber: 2.
	"Offset from the beginning of this table"
	storageOffset := (fontFile nextNumber: 2) + initialOffset.
	1 to: nRecords do:[:i| |  pID sID lID nID length offset string |
		fontFile position: initialOffset + 6 + ((i-1) * 12).
		pID := fontFile nextNumber: 2.
		sID := fontFile nextNumber: 2.
		lID := fontFile nextNumber: 2.
		nID := fontFile nextNumber: 2.
		length := fontFile nextNumber: 2.
		offset := fontFile nextNumber: 2.
		"Read only Macintosh or Microsoft strings"
		(pID = 1 or:[pID = 3 and:[sID = 1]]) ifTrue:[
			"MS uses Unicode all others single byte"
			"multiBytes := pID = 3."
			fontFile position: storageOffset+offset.
			string := (fontFile next: length) asString.
			pID = 3 ifTrue:[ | keep |
				keep := true.
				string := string select:[:ch| keep := keep not].
			].
			"Select only English names, prefer Macintosh"
			((pID = 1 and: [lID = 0]) or: [pID = 3 and: [lID = 16r0409]]) ifTrue: [
				nID caseOf: {
					[0] -> [(pID = 1 or:[copyright == nil]) ifTrue:[copyright := string]].
					[1] -> [(pID = 1 or:[familyName == nil]) ifTrue:[familyName := string]].
					[2] -> [(pID = 1 or:[subfamilyName == nil]) ifTrue:[subfamilyName := string]].
					"[3] -> [(pID = 1 or:[uniqueName == nil]) ifTrue:[uniqueName := string]]."
					"[4] -> [(pID = 1 or:[fullName == nil]) ifTrue:[fullName := string]]."
					"[5] -> [(pID = 1 or:[versionName == nil]) ifTrue:[versionName := string]]."
					"[6] -> [(pID = 1 or:[postscriptName == ni]) ifTrue:[postscriptName := string]]."
					"[7] -> [(pID = 1 or:[trademark == nil]) ifTrue:[trademark := string]]."
				} otherwise:["ignore"].
			]
		].
	].

]

{ #category : #'ttf tables' }
TTFileDescription >> processOS2Table: fontFile [
"
	USHORT  	 version   	0x0004
	SHORT 	xAvgCharWidth 	 
	USHORT 	usWeightClass 	 
	USHORT 	usWidthClass 	 
	USHORT 	fsType 	 
	SHORT 	ySubscriptXSize 	 
	SHORT 	ySubscriptYSize 	 
	SHORT 	ySubscriptXOffset 	 
	SHORT 	ySubscriptYOffset 	 
	SHORT 	ySuperscriptXSize 	 
	SHORT 	ySuperscriptYSize 	 
	SHORT 	ySuperscriptXOffset 	 
	SHORT 	ySuperscriptYOffset 	 
	SHORT 	yStrikeoutSize 	 
	SHORT 	yStrikeoutPosition 	 
	SHORT 	sFamilyClass 	 
	BYTE 	panose[10] 	 
	ULONG 	ulUnicodeRange1 	Bits 0-31
	ULONG 	ulUnicodeRange2 	Bits 32-63
	ULONG 	ulUnicodeRange3 	Bits 64-95
	ULONG 	ulUnicodeRange4 	Bits 96-127
	CHAR 	achVendID[4] 	 
	USHORT 	fsSelection 	 
	USHORT 	usFirstCharIndex 	 
	USHORT 	usLastCharIndex 	 
	SHORT 	sTypoAscender 	 
	SHORT 	sTypoDescender 	 
	SHORT 	sTypoLineGap 	 
	USHORT 	usWinAscent 	 
	USHORT 	usWinDescent 	 
	ULONG 	ulCodePageRange1 	Bits 0-31
	ULONG 	ulCodePageRange2 	Bits 32-63
	SHORT 	sxHeight 	 
	SHORT 	sCapHeight 	 
	USHORT 	usDefaultChar 	 
	USHORT 	usBreakChar 	 
	USHORT 	usMaxContext 	 "
	| version fsSelection minAscii maxAscii |
	version := self short: (fontFile nextNumber: 2). "table version"
	version = 0 ifTrue:[^self].
	fontFile skip: 60.
	fsSelection := fontFile nextNumber: 2.
	minAscii := fontFile nextNumber: 2.
	maxAscii := fontFile nextNumber: 2.
	sTypoAscender := self short: (fontFile nextNumber: 2).
	sTypoDescender := self short: (fontFile nextNumber: 2).
	sTypoLineGap := self short: (fontFile nextNumber: 2).

]

{ #category : #glyphs }
TTFileDescription >> processSimpleGlyph: glyph contours: nContours from: fontFile [
	"Construct a simple glyph frm the font file"
	| endPts  nPts iLength flags |
	endPts := Array new: nContours.
	1 to: nContours do:[:i| endPts at: i put: (fontFile nextNumber: 2)].
	glyph initializeContours: nContours with: endPts.
	nContours = 0 ifTrue:[^self].
	nPts := endPts last + 1.
	iLength := fontFile nextNumber: 2. "instruction length"
	fontFile skip: iLength.
	flags := self getGlyphFlagsFrom: fontFile size: nPts.
	self readGlyphXCoords: fontFile glyph: glyph nContours: nContours flags: flags endPoints: endPts.
	self readGlyphYCoords: fontFile glyph: glyph nContours: nContours flags: flags endPoints: endPts.
]

{ #category : #glyphs }
TTFileDescription >> readCmapTableAt: codePoint fromFile: fontFile [
	| cmapFmt length firstCode entryCount segCount segIndex startCode idDelta idRangeOffset offset |
	fontFile position: cmapOffset.
	cmapFmt := fontFile nextNumber: 2.
	length := fontFile nextNumber: 2.
	fontFile skip: 2. "skip version"

	cmapFmt = 0 ifTrue:["byte encoded table"
		codePoint > 255 ifTrue:[^0].
		length := length - 6. 		"should be always 256"
		length <= 0 ifTrue: [^0].	"but sometimes, this table is empty"
		fontFile skip: codePoint.		"move to correct byte offset in table"
		^fontFile next].

	cmapFmt = 4 ifTrue:[ "segment mapping to deltavalues"
		codePoint > 16rFFFF ifTrue:[^0].
		segCount := (fontFile nextNumber: 2) // 2.
		fontFile skip: 6. "skip searchRange, entrySelector, rangeShift"
		segIndex := (0 to: segCount-1) 
			detect:[:i| | endCode | (endCode := (fontFile nextNumber: 2)) >= codePoint].
		fontFile position: cmapOffset + 16 + (segCount*2) + (segIndex*2).
		startCode := fontFile nextNumber: 2.
		startCode <= codePoint ifFalse:[^0]. "not in segment range"
		fontFile position: cmapOffset + 16 + (segCount*4) + (segIndex*2).
		idDelta := fontFile nextNumber: 2.
		fontFile position: cmapOffset + 16 + (segCount*6) + (segIndex*2).
		idRangeOffset := fontFile nextNumber: 2.
		idRangeOffset = 0 ifTrue:[^(idDelta + codePoint) bitAnd: 16rFFFF].
		offset := (fontFile position - 2) + idRangeOffset + ((codePoint - startCode) * 2).
		fontFile position: offset.
		^fontFile nextNumber: 2.
	].

	cmapFmt = 6 ifTrue:[ "trimmed table"
		firstCode := fontFile nextNumber: 2.
		entryCount := fontFile nextNumber: 2.
		(codePoint between: firstCode and: firstCode+entryCount) ifFalse:[^0].
		fontFile skip: (codePoint-firstCode) * 2.
		^fontFile nextNumber: 2].

	^0
]

{ #category : #glyphs }
TTFileDescription >> readGlyphAt: glyphIndex [
	| glyph |
	self withFileDo:[:fontFile|
		glyph := self readGlyphAt: glyphIndex fromFile: fontFile.
		self updateGlyphMetrics: glyph fromFile: fontFile.
	].
	^glyph
]

{ #category : #glyphs }
TTFileDescription >> readGlyphAt: glyphIndex fromFile: fontFile [
	"Answer the glyph with the given glyph index"
	| glyphOffset nextOffset glyphLength glyph nContours left top right bottom |
	indexToLocFormat = 0 ifTrue:["Format0: offset/2 is stored"
		fontFile position: indexToLocOffset+(glyphIndex * 2).
		glyphOffset := (fontFile nextNumber: 2) * 2.
		nextOffset := (fontFile nextNumber: 2) * 2.
	] ifFalse:["Format1: store actual offset"
		fontFile position: indexToLocOffset+(glyphIndex * 4).
		glyphOffset := fontFile nextNumber: 4.
		nextOffset := fontFile nextNumber: 4.
	].
	glyphLength := nextOffset - glyphOffset.
	glyphLength = 0 ifTrue:[^TTGlyph new glyphIndex: glyphIndex].

	fontFile position: glyphTableOffset+glyphOffset.
	nContours := self short: (fontFile nextNumber: 2).
	left := self short: (fontFile nextNumber: 2).
	top := self short: (fontFile nextNumber: 2).
	right := self short: (fontFile nextNumber: 2).
	bottom := self short: (fontFile nextNumber: 2).
	nContours >= 0 ifTrue:[
		glyph := TTGlyph new glyphIndex: glyphIndex.
		self processSimpleGlyph: glyph contours: nContours from: fontFile.
	] ifFalse:[
		glyph := TTCompositeGlyph new glyphIndex: glyphIndex.
		self processCompositeGlyph: glyph contours: nContours from: fontFile.
	].
	glyph buildAllContours.
	glyph bounds: (left@top corner: right@bottom).
	^glyph

]

{ #category : #glyphs }
TTFileDescription >> readGlyphXCoords: fontFile glyph: glyph nContours: nContours flags: flags endPoints: endPts [
	"Read the x coordinates for the given glyph from the font file."
	| startPoint endPoint flagBits xValue contour ttPoint |
	startPoint := 1.
	1 to: nContours do:[:i|
		contour := glyph contours at: i.
		"Get the end point"
		endPoint := (endPts at: i) + 1.
		"Store number of points"
		startPoint to: endPoint do:[:j|
			ttPoint := contour points at: (j - startPoint + 1).
			flagBits := flags at: j.
			"If bit zero in the flag is set then this point is an on-curve
			point, if not, then it is an off-curve point."
			(flagBits bitAnd: 1) = 1 
				ifTrue:[ ttPoint type: #OnCurve]
				ifFalse:[ttPoint type: #OffCurve].
			"First we check to see if bit one is set.  This would indicate that
			the corresponding coordinate data in the table is 1 byte long.
			If the bit is not set, then the coordinate data is 2 bytes long."
			(flagBits bitAnd: 2) = 2 ifTrue:[ "one byte"
				xValue := fontFile next.
				xValue := (flagBits bitAnd: 16)=16 ifTrue:[xValue] ifFalse:[xValue negated].
				ttPoint x: xValue.
			] ifFalse:[ "two byte"
				"If bit four is set, then this coordinate is the same as the
				last one, so the relative offset (of zero) is stored.  If bit
				is not set, then read in two bytes and store it as a signed value."
				(flagBits bitAnd: 16) = 16 ifTrue:[ ttPoint x: 0 ]
				ifFalse:[
					xValue := self short: (fontFile nextNumber: 2).
					ttPoint x: xValue]]].
		startPoint := endPoint + 1]
]

{ #category : #glyphs }
TTFileDescription >> readGlyphYCoords: fontFile glyph: glyph nContours: nContours flags: flags endPoints: endPts [
	"Read the y coordinates for the given glyph from the font file."
	| startPoint endPoint flagBits yValue contour ttPoint |
	startPoint := 1.
	1 to: nContours do:[:i|
		contour := glyph contours at: i.
		"Get the end point"
		endPoint := (endPts at: i) + 1.
		"Store number of points"
		startPoint to: endPoint do:[:j|
			ttPoint := contour points at: (j - startPoint + 1).
			flagBits := flags at: j.
			"Check if this value one or two byte encoded"
			(flagBits bitAnd: 4) = 4 ifTrue:[ "one byte"
				yValue := fontFile next.
				yValue := (flagBits bitAnd: 32)=32 ifTrue:[yValue] ifFalse:[yValue negated].
				ttPoint y: yValue.
			] ifFalse:[ "two byte"
				(flagBits bitAnd: 32) = 32 ifTrue:[ ttPoint y: 0 ]
				ifFalse:[
					yValue := self short: (fontFile nextNumber: 2).
					ttPoint y: yValue]]].
		startPoint := endPoint + 1]
]

{ #category : #rendering }
TTFileDescription >> renderFallbackGlyphOfHeight: height fgColor: fgColor bgColor: bgColor depth: depth [
	"Render the glyph with the given code point at the specified pixel height."
	^ self fallbackGlyph
		asFormWithScale: height asFloat / (ascender - descender) 
			ascender: ascender 
			descender: descender 
			fgColor: fgColor bgColor: bgColor depth: depth
]

{ #category : #rendering }
TTFileDescription >> renderGlyph: code height: height fgColor: fgColor bgColor: bgColor depth: depth [
	"Render the glyph with the given code point at the specified pixel height."
	^(self at: code) 
		asFormWithScale: height asFloat / (ascender - descender) 
			ascender: ascender 
			descender: descender 
			fgColor: fgColor bgColor: bgColor depth: depth
]

{ #category : #private }
TTFileDescription >> short: aNumber [
	(aNumber bitAnd: 16r8000) = 0
		ifTrue: [^aNumber]
		ifFalse: [^-1 - (aNumber bitXor: 16rFFFF)]
]

{ #category : #accessing }
TTFileDescription >> size [
	"Compatibility with TTFontDescription"
	^16rFFFF
]

{ #category : #accessing }
TTFileDescription >> subfamilyName [
	"The subfamily name for the font"
	^subfamilyName
]

{ #category : #accessing }
TTFileDescription >> typographicAscender [
	"Microsoft defines this as the 'true typographic metrics' of the font."
	^sTypoAscender ifNil:[ascender]
]

{ #category : #accessing }
TTFileDescription >> typographicDescender [
	"Microsoft defines this as the 'true typographic metrics' of the font."
	^sTypoDescender ifNil:[descender]
]

{ #category : #accessing }
TTFileDescription >> typographicFontHeight [
	"cope for the fact that typographicAscender and 
	typographicDescender may not be available and 
	0-height fonts are a bit useless"
	| tfh |
	tfh := self typographicAscender - self typographicDescender.
	^ tfh = 0 ifTrue: [self fontHeight] ifFalse: [tfh]
]

{ #category : #accessing }
TTFileDescription >> typographicLineGap [
	"Microsoft defines this as the 'true typographic metrics' of the font."
	^sTypoLineGap ifNil:[lineGap]
]

{ #category : #glyphs }
TTFileDescription >> updateGlyphMetrics: glyph fromFile: fontFile [
	"Update the horizontal metrics for the given glyph"
	| glyphIndex |
	glyphIndex := glyph glyphIndex.
	glyphIndex <= numHMetrics ifTrue:[
		fontFile position: hmtxTableOffset + (glyphIndex*4).
		glyph advanceWidth: (fontFile nextNumber: 2).
		glyph leftSideBearing: (self short: (fontFile nextNumber: 2)).
	] ifFalse:[
		fontFile position: hmtxTableOffset + ((numHMetrics-1) *4).
		glyph advanceWidth: (fontFile nextNumber: 2).
		fontFile position: hmtxTableOffset + (numHMetrics * 4) + ((glyphIndex-numHMetrics)*2).
		glyph leftSideBearing: (self short: (fontFile nextNumber: 2)).
	].
	glyph updateRightSideBearing.
]

{ #category : #initialize }
TTFileDescription >> withFileDo: aBlock [
	"Open the font file for the duration of aBlock"
	^self class openFontFile: fileName do: aBlock.
]
