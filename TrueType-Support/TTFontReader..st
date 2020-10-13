"
TTFontReader constructs a TTFontDescription from a TrueType font (.ttf).
"
Class {
	#name : #TTFontReader,
	#superclass : #Object,
	#instVars : [
		'charMap',
		'glyphs',
		'nGlyphs',
		'kernPairs',
		'infoBar',
		'fontDescription'
	],
	#category : #'TrueType-Support'
}

{ #category : #'class initialization' }
TTFontReader class >> fileReaderServicesForFile: fullName suffix: suffix [


	^(suffix = 'fnt')  | (suffix = '*') 
		ifTrue: [ self services]
		ifFalse: [#()]

]

{ #category : #'class initialization' }
TTFontReader class >> initialize [
	"self initialize"

	FileServices registerFileReader: self
]

{ #category : #'instance creation' }
TTFontReader class >> installTTF: ttfFileName asTextStyle: textStyleName sizes: sizeArray [
	"Sizes are in pixels."
	"TTFontReader
		installTTF: 'F:\fonts\amazon__.TTF' 
		asTextStyle: #Amazon
		sizes: #(24 60)"

	| ttf fontArray |
	ttf := self parseFileNamed: ttfFileName.
	fontArray := sizeArray collect:
		[:each |
		(ttf asStrikeFontScale: each / ttf unitsPerEm)
			name: textStyleName;
			pixelSize: each].
	TextConstants at: textStyleName asSymbol put: (TextStyle fontArray: fontArray)
]

{ #category : #'class initialization' }
TTFontReader class >> openTTFFile: fullName [ 

	(TTFontReader parseFileNamed: fullName) asMorph open
]

{ #category : #'instance creation' }
TTFontReader class >> parseFileNamed: aString [
	"TTFontReader parseFileNamed:'c:\windows\fonts\arial.ttf'"
	"TTFontReader parseFileNamed:'c:\windows\times.ttf'"
	| contents |
	contents := (FileStream readOnlyFileNamed: aString) binary contentsOfEntireFile.
	^self readFrom: (ReadStream on: contents)
]

{ #category : #'instance creation' }
TTFontReader class >> readFrom: aStream [

	^self new readFrom: aStream
]

{ #category : #'instance creation' }
TTFontReader class >> readTTFFrom: aStream [

	^self new readTTFFrom: aStream
]

{ #category : #'class initialization' }
TTFontReader class >> serviceOpenTrueTypeFont [

	^ SimpleServiceEntry 
				provider: self 
				label: 'open true type font' translatedNoop
				selector: #openTTFFile:
				description: 'open true type font' translatedNoop
]

{ #category : #'class initialization' }
TTFontReader class >> services [

	^ Array with: self serviceOpenTrueTypeFont

]

{ #category : #'class initialization' }
TTFontReader class >> unload [

	FileServices unregisterFileReader: self 
]

{ #category : #private }
TTFontReader >> decodeCmapFmtTable: entry [
	| cmapFmt length entryCount segCount segments offset cmap firstCode |
	cmapFmt := entry nextUShort.
	length := entry nextUShort.
	entry skip: 2. "skip version"

	cmapFmt = 0 ifTrue: "byte encoded table"
		[length := length - 6. 		"should be always 256"
		length <= 0 ifTrue: [^ nil].	"but sometimes, this table is empty"
		cmap := Array new: length.
		entry nextBytes: length into: cmap startingAt: entry offset.
		^ cmap].

	cmapFmt = 4 ifTrue: "segment mapping to deltavalues"
		[segCount := entry nextUShort // 2.
		entry skip: 6. "skip searchRange, entrySelector, rangeShift"
		segments := Array new: segCount.
		segments := (1 to: segCount) collect: [:e | Array new: 4].
		1 to: segCount do: [:i | (segments at: i) at: 2 put: entry nextUShort]. "endCount"
		entry skip: 2. "skip reservedPad"
		1 to: segCount do: [:i | (segments at: i) at: 1 put: entry nextUShort]. "startCount"
		1 to: segCount do: [:i | (segments at: i) at: 3 put: entry nextShort]. "idDelta"
		offset := entry offset.
		1 to: segCount do: [:i | (segments at: i) at: 4 put: entry nextUShort]. "idRangeOffset"
		entryCount := segments inject: 0 into: [:max :seg | max max: seg second].
		cmap := Array new: entryCount+1 withAll: 0..
		segments withIndexDo:
			[:seg :si | | code |
			seg first to: seg second do:
				[:i |
					seg last > 0 ifTrue:
						["offset to glypthIdArray - this is really C-magic!"
						entry offset: i - seg first - 1 * 2 + seg last + si + si + offset. 
						code := entry nextUShort.
						code > 0 ifTrue: [code := code + seg third]]
					ifFalse:
						["simple offset"
						code := i + seg third].
					cmap at: i + 1 put: code]].
		^ cmap].

	cmapFmt = 6 ifTrue: "trimmed table"
		[firstCode := entry nextUShort.
		entryCount := entry nextUShort.
		cmap := Array new: entryCount + firstCode withAll: 0.
		entryCount timesRepeat:
			[cmap at: (firstCode := firstCode + 1) put: entry nextUShort].
		^ cmap].
	^ nil
]

{ #category : #private }
TTFontReader >> getGlyphFlagsFrom: entry size: nPts [
	"Read in the flags for this glyph.  The outer loop gathers the flags that
	are actually contained in the table.  If the repeat bit is set in a flag
	then the next byte is read from the table; this is the number of times
	to repeat the last flag.  The inner loop does this, incrementing the
	outer loops index each time."
	| flags index repCount flagBits |
	flags := ByteArray new: nPts.
	index := 1.
	[index <= nPts] whileTrue:[
		flagBits := entry nextByte.
		flags at: index put: flagBits.
		(flagBits bitAnd: 8) = 8 ifTrue:[
			repCount := entry nextByte.
			repCount timesRepeat:[
				index := index + 1.
				flags at: index put: flagBits]].
		index := index + 1].
	^flags
]

{ #category : #private }
TTFontReader >> getTableDirEntry: tagString from: fontData [
	"Find the table named tagString in fontData and return a table directory entry for it."
	| nTables pos currentTag tag |
	nTables := fontData shortAt: 5 bigEndian: true.
	tag := ByteArray new: 4.
	1 to: 4 do:[:i| tag byteAt: i put: (tagString at: i) asInteger].
	tag := tag longAt: 1 bigEndian: true.
	pos := 13.
	1 to: nTables do:[:i|
		currentTag := fontData longAt: pos bigEndian: true.
		currentTag = tag ifTrue:[^TTFontTableDirEntry on: fontData at: pos].
		pos := pos+16].
	^nil
]

{ #category : #private }
TTFontReader >> macToWin: index [
	^ (index - 1) asCharacter macToSqueak asciiValue + 1
]

{ #category : #processing }
TTFontReader >> processCharMap: assoc [
	"Process the given character map"

	| charTable glyph cmap |
	cmap := assoc value.

	assoc key = 0 ifTrue: "Unicode table"
		[charTable := SparseLargeTable new: cmap size
			chunkSize: 256 arrayClass: Array base: 1
			defaultValue: glyphs first.
		1 to: charTable size do:
			[:i |
			glyph := glyphs at: (cmap at: i) + 1 ifAbsent: [glyphs first].
			charTable at: i put: glyph].
		charTable zapDefaultOnlyEntries.
		^charTable].

	charTable := Array new: 256 withAll: glyphs first. "Initialize with default glyph"

	assoc key = 1 ifTrue: "Mac encoded table"
		[1 to: (cmap size min: charTable size) do:
			[:i |
			glyph := glyphs at: (cmap at: i) + 1.
			charTable at: (self macToWin: i) put: glyph]].

	assoc key = 3 ifTrue: "Win encoded table"
		[1 to: (cmap size min: charTable size) do:
			[:i |
			glyph := glyphs at: (cmap at: i) + 1.
			charTable at: i put: glyph]].

	^ charTable
]

{ #category : #processing }
TTFontReader >> processCharacterMappingTable: entry [
	"Read the font's character to glyph index mapping table.
	If an appropriate mapping can be found then return an association
	with the format identifier and the contents of the table"
	| copy initialOffset nSubTables pID sID offset cmap assoc |
	initialOffset := entry offset.
	entry skip: 2. "Skip table version"
	nSubTables := entry nextUShort.
	1 to: nSubTables do:[:i|
		pID := entry nextUShort.
		sID := entry nextUShort.
		offset := entry nextULong.
		"Check if this is either a Macintosh encoded table
		or a Windows encoded table"
		(#(0 1 3) includes: pID) ifTrue: [
			(assoc notNil and: [assoc key = pID]) ifFalse: [
				"Go to the beginning of the table"
				copy := entry copy.
				copy offset: initialOffset + offset.
				cmap := self decodeCmapFmtTable: copy.
				(pID = 0 and: [cmap notNil]) "Prefer Unicode encoding over everything else"
					ifTrue: [^ pID -> cmap].
				"(pID = 1 and: [cmap notNil])" "Prefer Macintosh encoding over everything else"
					"ifTrue: [pID -> cmap]."
				assoc := pID -> cmap. "Keep it in case we don't find a better table"
			].
		].
	].
	^assoc
]

{ #category : #processing }
TTFontReader >> processCompositeGlyph: glyph contours: nContours from: entry [
	"Read a composite glyph from the font data. The glyph passed into this method contains some state variables that must be copied into the resulting composite glyph."
	| flags glyphIndex hasInstr cGlyph ofsX ofsY iLen a11 a12 a21 a22 m |
	cGlyph := TTCompositeGlyph new.
	a11 := a22 := 16r4000.	"1.0 in F2Dot14"
	a21 := a12 := 0.		"0.0 in F2Dot14"
	"Copy state"
	cGlyph bounds: glyph bounds; glyphIndex: glyph glyphIndex.
	hasInstr := false.
	[ flags := entry nextUShort.
	glyphIndex := entry nextUShort + 1.
	(flags bitAnd: 1) = 1 ifTrue:[
		ofsX := entry nextShort.
		ofsY := entry nextShort.
	] ifFalse:[
		(ofsX := entry nextByte) > 127 ifTrue:[ofsX := ofsX - 256].
		(ofsY := entry nextByte) > 127 ifTrue:[ofsY := ofsY - 256]].
	((flags bitAnd: 2) = 2) ifFalse:[self halt].
	(flags bitAnd: 8) = 8 ifTrue:[
		a11 := a22 := entry nextShort].
	(flags bitAnd: 64) = 64 ifTrue:[
		a11 := entry nextShort.
		a22 := entry nextShort].
	(flags bitAnd: 128) = 128 ifTrue:[
		"2x2 transformation"
		a11 := entry nextShort.
		a21 := entry nextShort.
		a12 := entry nextShort.
		a22 := entry nextShort].
	m := MatrixTransform2x3 new.
	"Convert entries from F2Dot14 to float"
	m a11: (a11 asFloat / 16r4000).
	m a12: (a12 asFloat / 16r4000).
	m a21: (a21 asFloat / 16r4000).
	m a22: (a22 asFloat / 16r4000).
	m a13: ofsX.
	m a23: ofsY.
	cGlyph addGlyph: (glyphs at: glyphIndex) transformation: m.
	hasInstr := hasInstr or:[ (flags bitAnd: 256) = 256].
	"Continue as long as the MORE_COMPONENTS bit is set"
	(flags bitAnd: 32) = 32] whileTrue.
	hasInstr ifTrue:[
		iLen := entry nextUShort.
		entry skip: iLen].
	^cGlyph
]

{ #category : #processing }
TTFontReader >> processFontHeaderTable: entry [
"Value				Data Type    Description
unitsPerEm			USHORT      Granularity of the font's em square.
xMax				USHORT      Maximum X-coordinate for the entire font.
xMin				USHORT      Minimum X-coordinate for the entire font.
yMax				USHORT      Maximum Y-coordinate for the entire font.
yMin				USHORT      Minimum Y-coordinate for the entire font.
indexToLocFormat	SHORT       Used when processing the Index To Loc Table."
	| origin corner units indexToLocFormat |
	entry skip: 4. "Skip table version number"
	entry skip: 4. "Skip font revision number"
	entry skip: 4. "Skip check sum adjustment"
	entry skip: 4. "Skip magic number"
	entry skip: 2. "Skip flags"

	units := entry nextUShort.

	entry skip: 8. "Skip creation date"
	entry skip: 8. "Skip modification date"

	"Get min/max values of all glyphs"
	origin := entry nextShort @ entry nextShort.
	corner := entry nextShort @ entry nextShort.

	entry skip: 2. "Skip mac style"
	entry skip: 2. "Skip lowest rec PPEM"
	entry skip: 2. "Skip font direction hint"
	indexToLocFormat := entry nextShort.

	fontDescription setBounds: (origin corner: corner) unitsPerEm: units.
	^indexToLocFormat
]

{ #category : #processing }
TTFontReader >> processGlyphDataTable: entry offsets: offsetArray [
	"Read the actual glyph data from the font.
	offsetArray contains the start offsets in the data for each glyph."
	| initialOffset |
	initialOffset := entry offset.
	glyphs := Array new: nGlyphs.
	1 to: nGlyphs do:[:i | 
		glyphs at: i put: (TTGlyph new glyphIndex: i-1)].
	'Reading glyph data' 
		displayProgressFrom: 1 
		to: nGlyphs 
		during:[:bar| | nContours glyphOffset origin corner glyphLength glyph nextOffset |

	1 to: nGlyphs do:[:glyphIndex |
		bar value: glyphIndex.
		glyph := glyphs at: glyphIndex.
		glyphOffset := offsetArray at: glyphIndex.
		nextOffset := offsetArray at: glyphIndex+1.
		glyphLength := nextOffset - glyphOffset.
		glyphLength = 0 ifFalse:[
			entry offset: initialOffset + glyphOffset.
			nContours := entry nextShort.
			origin := entry nextShort @ entry nextShort.
			corner := entry nextShort @ entry nextShort.
			glyph bounds: (origin corner: corner).
			nContours >= 0 ifTrue:[
				self processSimpleGlyph: glyph contours: nContours from: entry
			] ifFalse:[
				glyph := self processCompositeGlyph: glyph contours: nContours from: entry.
				glyphs at: glyphIndex put: glyph]]]
	].
]

{ #category : #processing }
TTFontReader >> processHorizontalHeaderTable: entry [
"
ascender           SHORT          Typographic ascent.
descender          SHORT          Typographic descent.
lineGap            SHORT          Typographic lineGap.
numberOfHMetrics   USHORT         Number hMetric entries in the HTMX
                                               Table; may be smaller than the total
                                             number of glyphs.
"
	| asc desc lGap numHMetrics |
	entry skip: 4. "Skip table version"
	asc := entry nextShort.
	desc := entry nextShort.
	lGap := entry nextShort.
	entry skip: 2. "Skip advanceWidthMax"
	entry skip: 2. "Skip minLeftSideBearing"
	entry skip: 2. "Skip minRightSideBearing"
	entry skip: 2. "Skip xMaxExtent"
	entry skip: 2. "Skip caretSlopeRise"
	entry skip: 2. "Skip caretSlopeRun"
	entry skip: 10. "Skip 5 reserved shorts"
	entry skip: 2. "Skip metricDataFormat"

	numHMetrics := entry nextUShort.

	fontDescription setAscender: asc descender: desc lineGap: lGap.
	^numHMetrics
]

{ #category : #processing }
TTFontReader >> processHorizontalMetricsTable: entry length: numHMetrics [
	"Extract the advance width, left side bearing, and right
	side bearing for each glyph from the Horizontal Metrics Table."
	|  index lastAW glyph |
	index := 1.
	[index <= numHMetrics] whileTrue:[
		glyph := glyphs at: index.
		glyph advanceWidth: entry nextUShort.
		glyph leftSideBearing: entry nextShort.
		glyph updateRightSideBearing.
		index := index + 1].
	index = (nGlyphs +1) ifTrue:[^true].
	lastAW := (glyphs at: index-1) advanceWidth.

	[index <= nGlyphs] whileTrue:[
		glyph := glyphs at: index.
		glyph advanceWidth: lastAW.
		glyph leftSideBearing: entry nextShort.
		glyph updateRightSideBearing.
		index := index + 1].
]

{ #category : #processing }
TTFontReader >> processIndexToLocationTable: entry format: indexToLocFormat [
"glyphOffset    ULONG[numGlyphs]   An array that contains each glyph's
                                 offset into the Glyph Data Table.
"	| glyphOffset offset|
	glyphOffset := Array new: nGlyphs+1.
	1 to: nGlyphs+1 do:[:i|
		(indexToLocFormat = 0) ifTrue:[ "Format0: offset/2 is stored"
			offset := entry nextUShort * 2.
		] ifFalse:["Format1: store actual offset"
			offset := entry nextULong].
		glyphOffset at: i put: offset].
	^glyphOffset
]

{ #category : #processing }
TTFontReader >> processKerningSubTableType0: entry [

	| kp nKernPairs |
	nKernPairs := entry nextUShort.
	entry skip: 2. "Skip search range"
	entry skip: 2. "Skip entry selector"
	entry skip: 2. "Skip range shift"
	kernPairs := Array new: nKernPairs.
	1 to: nKernPairs do:[:i|
		kp := TTKernPair new.
		kp left: entry nextUShort.
		kp right: entry nextUShort.
		kp value: entry nextShort.
		kernPairs at: i put: kp].
	^true

]

{ #category : #processing }
TTFontReader >> processKerningTable: entry [
	"Extract the kerning information for pairs of glyphs."
	| version  nTables covLow covHigh |
	version := entry nextUShort. "Skip table version"
	nTables := entry nextUShort. "Skip number of sub tables -- we're using the first one only"
	nTables = 0 ifTrue: [" This detection is hacky "
		entry skip: -4. "rewind"
		^ self processOSXKerningTable: entry].
	entry skip: 2. "Skip current subtable number"
	entry skip: 2. "Skip length of subtable"
	covHigh := entry nextByte.
	covLow := entry nextByte.

	"Make sure the format is right (kerning table and format type 0)"
	((covLow bitAnd: 2) = 2 or:[ covHigh ~= 0]) ifTrue:[^false].
	"Subtable"
	^ self processKerningSubTableType0: entry.

]

{ #category : #processing }
TTFontReader >> processMaximumProfileTable: entry [
"
numGlyphs         USHORT      The number of glyphs in the font.
"
	entry skip: 4. "Skip Table version number"
	nGlyphs := entry nextUShort.
]

{ #category : #processing }
TTFontReader >> processNamingTable: entry [
"copyright         CHARPTR     The font's copyright notice.
familyName        CHARPTR     The font's family name.
subfamilyName     CHARPTR     The font's subfamily name.
uniqueName        CHARPTR     A unique identifier for this font.
fullName          CHARPTR     The font's full name (a combination of
                                          familyName and subfamilyName).
versionName       CHARPTR     The font's version string.
"	| nRecords initialOffset format storageOffset  strings |
	strings := Array new: 8.
	strings atAllPut:''.
	initialOffset := entry offset.
	format := entry nextUShort.
	format = 0 ifFalse: [self error: 'Cannot handle format 1 naming tables'].
	"Get the number of name records"
	nRecords := entry nextUShort.
	"Offset from the beginning of this table"
	storageOffset := entry nextUShort + initialOffset.
	1 to: nRecords do:[:i| | pID sID lID nID length offset multiBytes string |
		pID := entry nextUShort.
		sID := entry nextUShort.
		lID := entry nextUShort.
		nID := entry nextUShort.
		length := entry nextUShort.
		offset := entry nextUShort.
		"Read only Macintosh or Microsoft strings"
		(pID = 1 or:[pID = 3 and:[sID = 1]]) ifTrue:[
			"MS uses Unicode all others single byte"
			multiBytes := pID = 3.
			string := entry stringAt: storageOffset + offset length: length multiByte: multiBytes.

			"Select only English names.
			Note: We prefer Macintosh strings about everything."
			((pID = 1 and: [lID = 0]) or: [pID = 3 and: [lID = 16r0409]]) ifTrue: [
				"Put the name at the right location."
				nID < strings size ifTrue:[
					(pID = 1 or:[(strings at: nID+1) = ''])
						ifTrue:[strings at: nID+1 put: string].
				].
			].
		].
	].
	fontDescription setStrings: strings.
]

{ #category : #processing }
TTFontReader >> processOS2Table: entry [
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
	| version fsSelection minAscii maxAscii asc desc lGap |
	version := entry nextShort. "table version"
	version = 0 ifTrue:[^self].
	entry skip: 60.
	fsSelection := entry nextUShort.
	minAscii := entry nextUShort.
	maxAscii := entry nextUShort.
	asc := entry nextShort.
	desc := entry nextShort.
	lGap := entry nextShort.
	fontDescription setTypographicAscender: asc descender: desc lineGap: lGap.
]

{ #category : #processing }
TTFontReader >> processOSXKerningTable: entry [
	"From Apple's TrueType reference:
	
	Previous versions of the 'kern' table defined both the version and nTables fields in the header as UInt16 values and not UInt32 values. Use of the older format on OS X is discouraged (although AAT can sense an old kerning table and still make correct use of it). Microsoft Windows still uses the older format for the 'kern' table and will not recognize the newer one. Fonts targeted for OS X only should use the new format; fonts targeted for both OS X and Windows should use the old format.
	"
	"Extract the kerning information for pairs of glyphs."
	| version  nTables length coverage tupleIndex |
	version := entry nextULong. "Skip table version"
	nTables := entry nextULong. "Skip number of sub tables -- we're using the first one only"

	length := entry nextULong. "Skip length of subtable"
	coverage := entry nextUShort.
	tupleIndex := entry nextUShort. "Skip tuple index".
	"Make sure the format is right (kerning table and format type 0)"
	coverage = 0 ifFalse: [^false].
	
	"Subtable"
	^ self processKerningSubTableType0: entry.

]

{ #category : #processing }
TTFontReader >> processSimpleGlyph: glyph contours: nContours from: entry [

	| endPts  nPts iLength flags |
	endPts := Array new: nContours.
	1 to: nContours do:[:i| endPts at: i put: entry nextUShort].
	glyph initializeContours: nContours with: endPts.
	nContours = 0 ifTrue: [^ self].
	nPts := endPts last + 1.
	iLength := entry nextUShort. "instruction length"
	entry skip: iLength.
	flags := self getGlyphFlagsFrom: entry size: nPts.
	self readGlyphXCoords: entry glyph: glyph nContours: nContours flags: flags endPoints: endPts.
	self readGlyphYCoords: entry glyph: glyph nContours: nContours flags: flags endPoints: endPts.
	glyph buildContours.
]

{ #category : #public }
TTFontReader >> readFrom: aStream [

	| fontData headerEntry maxProfileEntry nameEntry indexLocEntry charMapEntry glyphEntry horzHeaderEntry horzMetricsEntry kerningEntry glyphOffset cmap numHMetrics indexToLocFormat |

	"Read the raw font byte data"
	aStream binary.
	fontData := aStream contents asByteArray.
	fontDescription := TTFontDescription new.

	"Search the tables required to build the font"
	(headerEntry := self getTableDirEntry: 'head' from: fontData) == nil ifTrue:[
		^self error:'This font does not have a header table'].
	(maxProfileEntry := self getTableDirEntry: 'maxp' from: fontData) == nil ifTrue:[
		^self error:'This font does not have a maximum profile table'].
	(nameEntry := self getTableDirEntry: 'name' from: fontData) == nil ifTrue:[
		^self error:'This font does not have a name table'].
	(indexLocEntry := self getTableDirEntry: 'loca' from: fontData) == nil ifTrue:[
		^self error:'This font does not have a relocation table'].
	(charMapEntry := self getTableDirEntry: 'cmap' from: fontData) == nil ifTrue:[
		^self error:'This font does not have a character map table'].
	(glyphEntry := self getTableDirEntry: 'glyf' from: fontData) == nil ifTrue:[
		^self error:'This font does not have a glyph table'].
	(horzHeaderEntry := self getTableDirEntry: 'hhea' from: fontData) == nil ifTrue:[
		^self error:'This font does not have a horizontal header table'].
	(horzMetricsEntry := self getTableDirEntry: 'hmtx' from: fontData) == nil ifTrue:[
		^self error:'This font does not have a horizontal metrics table'].
	(kerningEntry := self getTableDirEntry: 'kern' from: fontData) == nil ifTrue:[
		Transcript cr; show:'This font does not have a kerning table';endEntry].


	"Process the data"
	indexToLocFormat := self processFontHeaderTable: headerEntry.
	self processMaximumProfileTable: maxProfileEntry.
	self processNamingTable: nameEntry.
	glyphOffset := self processIndexToLocationTable: indexLocEntry format: indexToLocFormat.
	cmap := self processCharacterMappingTable: charMapEntry.
	(cmap == nil or:[cmap value == nil])
		ifTrue:[^self error:'This font has no suitable character mappings'].
	self processGlyphDataTable: glyphEntry offsets: glyphOffset.
	numHMetrics := self processHorizontalHeaderTable: horzHeaderEntry.
	self processHorizontalMetricsTable: horzMetricsEntry length: numHMetrics.
	kerningEntry isNil 
		ifTrue:[kernPairs := #()]
		ifFalse:[self processKerningTable: kerningEntry].
	charMap := self processCharMap: cmap.
	fontDescription setGlyphs: glyphs mapping: charMap.
	fontDescription setKernPairs: kernPairs.
	^fontDescription
]

{ #category : #private }
TTFontReader >> readGlyphXCoords:entry glyph: glyph nContours: nContours flags: flags endPoints: endPts [
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
				xValue := entry nextByte.
				xValue := (flagBits bitAnd: 16)=16 ifTrue:[xValue] ifFalse:[xValue negated].
				ttPoint x: xValue.
			] ifFalse:[ "two byte"
				"If bit four is set, then this coordinate is the same as the
				last one, so the relative offset (of zero) is stored.  If bit
				is not set, then read in two bytes and store it as a signed value."
				(flagBits bitAnd: 16) = 16 ifTrue:[ ttPoint x: 0 ]
				ifFalse:[
					xValue := entry nextShort.
					ttPoint x: xValue]]].
		startPoint := endPoint + 1]
]

{ #category : #private }
TTFontReader >> readGlyphYCoords:entry glyph: glyph nContours: nContours flags: flags endPoints: endPts [
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
				yValue := entry nextByte.
				yValue := (flagBits bitAnd: 32)=32 ifTrue:[yValue] ifFalse:[yValue negated].
				ttPoint y: yValue.
			] ifFalse:[ "two byte"
				(flagBits bitAnd: 32) = 32 ifTrue:[ ttPoint y: 0 ]
				ifFalse:[
					yValue := entry nextShort.
					ttPoint y: yValue]]].
		startPoint := endPoint + 1]
]

{ #category : #private }
TTFontReader >> warn: aString [
	Transcript cr; show: aString; endEntry.
]

{ #category : #private }
TTFontReader >> winToMac: index [
	^ (index - 1) asCharacter squeakToMac asciiValue + 1
]
