Class {
	#name : #TTCFontReader,
	#superclass : #TTFontReader,
	#instVars : [
		'fonts'
	],
	#classVars : [
		'EncodingTag'
	],
	#category : #'TrueType-Fonts'
}

{ #category : #accessing }
TTCFontReader class >> encodingTag: aNumber [
"
	TTCFontReader encodingTag: 6
"

	EncodingTag := aNumber.

]

{ #category : #private }
TTCFontReader >> getTableDirEntry: tagString from: fontData offset: offset [
	"Find the table named tagString in fontData and return a table directory entry for it."

	| nTables pos currentTag tag |
	nTables := fontData shortAt: 5 + offset bigEndian: true.
	tag := ByteArray new: 4.
	1 to: 4 do:[:i| tag byteAt: i put: (tagString at: i) asInteger].
	tag := tag longAt: 1 bigEndian: true.
	pos := 13 + offset.
	1 to: nTables do:[:i|
		currentTag := fontData longAt: pos bigEndian: true.
		currentTag = tag ifTrue:[^TTFontTableDirEntry on: fontData at: pos].
		pos := pos+16].
	^nil
]

{ #category : #private }
TTCFontReader >> parseTTCHeaderFrom: fontData [

	| pos nTables |
	nTables := fontData longAt: 9 bigEndian: true.
	fonts := Array new: nTables.
	pos := 13.
	1 to: nTables do: [:i |
		fonts at: i put: (fontData longAt: pos bigEndian: true).
		pos := pos + 4.
	].

	^ fonts

]

{ #category : #processing }
TTCFontReader >> processCharMap: assoc [
	"Process the given character map"

	| glyph cmap encode0 encode1 char value null |
	cmap := assoc value.
	null := (glyphs at: (cmap at: Character space asUnicode + 1) + 1) copy.
	null contours: #().

	encode0 := Array new: 256 withAll: glyphs first.
	encode1 := Array new: 65536 withAll: glyphs first.

	0 to: 255 do: [:i |
		char := Character value: i.
		glyph := glyphs at: (cmap at: char asUnicode + 1) + 1.
		encode0 at: i+1 put: glyph.
	].
	Character separators do: [:c |
		encode0 at: (c asciiValue + 1) put: null.
	].
	0 to: 65536 - 1 do: [:i |
		value := cmap at: i+1.
		value = 65535 ifFalse: [ "???"
			| g |
			g := glyphs at: value+1 ifAbsent: [ null. ].
			(g isKindOf: TTCompositeGlyph) ifFalse: [
				encode1 at: i+1 put: g.
			] ifTrue: [
				g basicGlyphs: (((glyphs at: value+1) basicGlyphs) collect: [:t | t key->(glyphs at: (t value glyphIndex+1))]).
				encode1 at: i+1 put: g
			].
		]
	].

	^ {encode0. encode1}.

]

{ #category : #public }
TTCFontReader >> readFrom: aStream [

	"Read the raw font byte data"
	| fontData |
	(aStream respondsTo: #binary) ifTrue:[aStream binary].
	fontData := aStream contents asByteArray.

	fonts := self parseTTCHeaderFrom: fontData.
	^ fonts gather: [:offset |
		fontDescription := TTCFontDescription new.
		self readFrom: fontData fromOffset: offset at: EncodingTag]
]

{ #category : #private }
TTCFontReader >> readFrom: fontData fromOffset: offset at: encodingTag [

	| headerEntry maxProfileEntry nameEntry indexLocEntry charMapEntry glyphEntry horzHeaderEntry horzMetricsEntry kerningEntry glyphOffset cmap numHMetrics indexToLocFormat fontDescription0 fontDescription1 array result |

	"Search the tables required to build the font"
	(headerEntry := self getTableDirEntry: 'head' from: fontData offset: offset) == nil ifTrue:[
		^self error:'This font does not have a header table'].
	(maxProfileEntry := self getTableDirEntry: 'maxp' from: fontData offset: offset) == nil ifTrue:[
		^self error:'This font does not have a maximum profile table'].
	(nameEntry := self getTableDirEntry: 'name' from: fontData offset: offset) == nil ifTrue:[
		^self error:'This font does not have a name table'].
	(indexLocEntry := self getTableDirEntry: 'loca' from: fontData offset: offset) == nil ifTrue:[
		^self error:'This font does not have a relocation table'].
	(charMapEntry := self getTableDirEntry: 'cmap' from: fontData offset: offset) == nil ifTrue:[
		^self error:'This font does not have a character map table'].
	(glyphEntry := self getTableDirEntry: 'glyf' from: fontData  offset: offset) == nil ifTrue:[
		^self error:'This font does not have a glyph table'].
	(horzHeaderEntry := self getTableDirEntry: 'hhea' from: fontData offset: offset) == nil ifTrue:[
		^self error:'This font does not have a horizontal header table'].
	(horzMetricsEntry := self getTableDirEntry: 'hmtx' from: fontData offset: offset) == nil ifTrue:[
		^self error:'This font does not have a horizontal metrics table'].
	(kerningEntry := self getTableDirEntry: 'kern' from: fontData offset: offset) == nil ifTrue:[
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
	array := self processCharMap: cmap.
	fontDescription0 := fontDescription shallowCopy.
	fontDescription1 := fontDescription shallowCopy.
	fontDescription0 setGlyphs: (array at: 1) mapping: (array at: 1)..
	fontDescription1 setGlyphs: (array at: 2) mapping: (array at: 2)..
	fontDescription0 setKernPairs: kernPairs.
	fontDescription1 setKernPairs: kernPairs.
	result := OrderedCollection new.
	(encodingTag = nil or: [encodingTag = 0]) ifTrue: [^ Array with: fontDescription1].
	result add: fontDescription0.
	encodingTag -1 timesRepeat: [result add: nil].
	result add: fontDescription1.
	^ result asArray.


]

{ #category : #reading }
TTCFontReader >> readTTFFrom: aStream [

	"Read the raw font byte data"
	| fontData |
	(aStream respondsTo: #binary) ifTrue:[aStream binary].
	fontData := aStream contents asByteArray.
	fontDescription := TTCFontDescription new.

	^ self readFrom: fontData fromOffset: 0 at: EncodingTag.

]
