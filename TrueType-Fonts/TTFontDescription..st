"
Holds a TrueType font in memory.  Is used by TTSampleStringMorph as its font.  

Class owns a default example.  
"
Class {
	#name : #TTFontDescription,
	#superclass : #Object,
	#instVars : [
		'glyphTable',
		'glyphs',
		'kernPairs',
		'copyright',
		'familyName',
		'fullName',
		'subfamilyName',
		'uniqueName',
		'versionName',
		'postscriptName',
		'trademark',
		'bounds',
		'unitsPerEm',
		'ascender',
		'descender',
		'lineGap',
		'sTypoAscender',
		'sTypoDescender',
		'sTypoLineGap'
	],
	#classVars : [
		'Default',
		'Descriptions'
	],
	#category : #'TrueType-Fonts'
}

{ #category : #'instance creation' }
TTFontDescription class >> addFromSmartRefStream: ref [

	| tts |
	tts := ref nextAndClose.

	^ tts collect: [:tt |
		self addToDescription: tt.
	].

]

{ #category : #'instance creation' }
TTFontDescription class >> addFromTTFile: fileName [
"
	self addFromTTFile: 'C:\WINDOWS\Fonts\ARIALN.TTF'
"
	^self addFromTTStream: (FileStream readOnlyFileNamed: fileName).

]

{ #category : #'instance creation' }
TTFontDescription class >> addFromTTStream: readStream [
"
	self addFromTTFile: 'C:\WINDOWS\Fonts\ARIALN.TTF'
"

	| tt |
	tt := TTFontReader readFrom: readStream.
	tt := self addToDescription: tt.
	tt blankGlyphForSeparators.
	^ tt.

]

{ #category : #'instance creation' }
TTFontDescription class >> addSetFromTTFile: fileName encodingTag: encodingTag ranges: ranges [

	| tt |
	(fileName asLowercase endsWith: 'ttf') ifTrue: [
		tt := TTCFontReader readTTFFrom: (FileStream readOnlyFileNamed: fileName).
	] ifFalse: [
		tt := TTCFontReader readFrom: (FileStream readOnlyFileNamed: fileName).
	].

	(tt at: encodingTag + 1) compactForRanges: ranges.
	^ self addToDescription: tt.

]

{ #category : #'instance creation' }
TTFontDescription class >> addToDescription: tt [

	| old new |
	old := Descriptions detect: [:f | f first fullName = tt first fullName] ifNone: [nil].
	^ old ifNotNil: [
		new := old, (Array new: ((tt size - old size) max: 0)).
		1 to: tt size do: [:ind |
			(tt at: ind) ifNotNil: [
				new at: ind put: (tt at: ind)
			].
		].
		Descriptions remove: old.
		Descriptions add: new.
		new.
	] ifNil: [
		Descriptions add: tt.
		tt.
	]

]

{ #category : #'instance creation' }
TTFontDescription class >> clearDefault [
"
	self clearDefault
"

	Default := nil.

]

{ #category : #'instance creation' }
TTFontDescription class >> clearDescriptions [
"
	self clearDescriptions
"

	Descriptions := Set new.
	Default ifNotNil: [Descriptions add: Default].

]

{ #category : #'instance creation' }
TTFontDescription class >> default [
	^ Default
]

{ #category : #'instance creation' }
TTFontDescription class >> descriptionFullNamed: descriptionFullName [ 
	^ Descriptions
		detect: [:f | f first fullName = descriptionFullName]
		ifNone: [Default]
]

{ #category : #'instance creation' }
TTFontDescription class >> descriptionFullNamed: descriptionFullName at: index [
	| ans |
	ans := Descriptions
		detect: [:f | f first fullName = descriptionFullName]
		ifNone: [Default].
	index > 0 ifTrue: [^ ans at: index].
	^ ans.

]

{ #category : #'instance creation' }
TTFontDescription class >> descriptionNamed: descriptionName [

	^ Descriptions detect: [:f | f first name = descriptionName] ifNone: [Default].

]

{ #category : #'instance creation' }
TTFontDescription class >> foo [
]

{ #category : #'class initialization' }
TTFontDescription class >> initialize [
"
	self initialize
"

	self clearDescriptions.

]

{ #category : #'instance creation' }
TTFontDescription class >> removeDescriptionNamed: descriptionName [

	| tt |
	Descriptions ifNil: [^ self].
	[(tt :=  Descriptions detect: [:f | f first name = descriptionName] ifNone: [nil]) notNil] whileTrue:[
		 Descriptions remove: tt
	].

]

{ #category : #'instance creations' }
TTFontDescription class >> removeDescriptionNamed: descriptionName subfamilyName: subfamilyName [

	| tts |
	Descriptions ifNil: [^ self].
	tts := Descriptions select: [:f | f first name = descriptionName and: [f first subfamilyName = subfamilyName]].
	tts do: [:f | Descriptions remove: f].

]

{ #category : #'instance creation' }
TTFontDescription class >> setDefault [

	Default := Descriptions detect: [:ea | ea isRegular] ifNone: [Descriptions anyOne].
]

{ #category : #converting }
TTFontDescription >> asStrikeFontScale: scale [
	"Generate a StrikeFont (actually a FormSetFont) for this TTF font at a given scale."

	| forms |
	forms := (0 to: 255) collect:
		[:i |
		(self at: i)
			asFormWithScale: scale
			ascender: ascender
			descender: descender].
	^ FormSetFont new
		fromFormArray: forms
		asciiStart: 0
		ascent: (ascender * scale) rounded
]

{ #category : #properties }
TTFontDescription >> ascender [
	"Ascender of the font. Relative to unitsPerEm.
	Easily confused with the typographic ascender."
	^ascender
]

{ #category : #accessing }
TTFontDescription >> at: aCharOrInteger [
	^glyphTable at: (aCharOrInteger isCharacter ifTrue: [aCharOrInteger charCode] ifFalse: [aCharOrInteger])+1
]

{ #category : #accessing }
TTFontDescription >> at: index put: value [
	^self shouldNotImplement
]

{ #category : #migration }
TTFontDescription >> blankGlyphForSeparators [

	| space |
	space := (self at: Character space charCode) copy.
	space contours: #().
	Character separators do: [:s | 
		glyphTable at: s charCode +1 put: space.
	].

]

{ #category : #properties }
TTFontDescription >> bounds [
	^bounds
]

{ #category : #migration }
TTFontDescription >> compactForRanges: rangesArray [

	| newGlyphTable noMapping |
	noMapping := glyphs == glyphTable.
	newGlyphTable :=  SparseLargeTable new: rangesArray last last chunkSize: 32 arrayClass: Array base: 0 + 1 defaultValue: (glyphs at: 1).
	rangesArray do: [:pair |
		pair first to: pair second do: [:i |
			newGlyphTable at: i put: (glyphs at: i)
		]
	].
	glyphTable := newGlyphTable.
	noMapping ifTrue: [glyphs := glyphTable].

]

{ #category : #information }
TTFontDescription >> copyright [
	^copyright
]

{ #category : #copying }
TTFontDescription >> deepCopy [

	"Since it shouldn't be copied for transmitting or any reason, it returns self."
	^ self.

]

{ #category : #properties }
TTFontDescription >> descender [
	"Descender of the font. Relative to unitsPerEm.
	Easily confused with the typographic descender."
	^descender
]

{ #category : #accessing }
TTFontDescription >> fallbackGlyph [
	"Answer the fallback glyph, the first in the loca table "
	^ glyphs at: 1
]

{ #category : #information }
TTFontDescription >> familyName [
	^familyName
]

{ #category : #accessing }
TTFontDescription >> first [

	^ self.

]

{ #category : #'private-initialization' }
TTFontDescription >> flipAroundY [
	bounds := (bounds origin x @ bounds corner y negated) corner:
				(bounds corner x @ bounds origin y negated).
	glyphs do:[:glyph| glyph flipAroundY]
]

{ #category : #accessing }
TTFontDescription >> fontHeight [
	^ascender - descender
]

{ #category : #information }
TTFontDescription >> fullName [
	^fullName
]

{ #category : #testing }
TTFontDescription >> isRegular [
	"Answer true if I am a Regular/Roman font (i.e. not bold, etc.)"
	^ (TTCFont indexOfSubfamilyName: (self subfamilyName)) = 0.

]

{ #category : #properties }
TTFontDescription >> lineGap [
	"Leading of the font. Relative to unitsPerEm.
	Easily confused with the typographic linegap."
	^lineGap
]

{ #category : #accessing }
TTFontDescription >> name [

	^ self familyName copyWithout: Character space.

]

{ #category : #copying }
TTFontDescription >> objectForDataStream: refStrm [
	| dp isCollection |
	"I am about to be written on an object file.  Write a reference to a known Font in the other system instead.  "

	"A path to me"
	(TextConstants at: #forceFontWriting ifAbsent: [false]) ifTrue: [^ self].
		"special case for saving the default fonts on the disk.  See collectionFromFileNamed:"

	isCollection := (Descriptions detect: [:e | e == self]) isCollection.

	dp := DiskProxy global: #TTFontDescription selector: #descriptionFullNamed:at:
			args: {self fullName. (isCollection ifTrue: [(TTFontDescription descriptionFullNamed: self fullName) indexOf: self] ifFalse: [0])}.
	refStrm replace: self with: dp.
	^ dp.

]

{ #category : #information }
TTFontDescription >> postscriptName [
	^postscriptName
]

{ #category : #printing }
TTFontDescription >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	familyName printOn: aStream.
	aStream nextPut: $-.
	subfamilyName printOn: aStream.
	aStream nextPut:$).
]

{ #category : #rendering }
TTFontDescription >> renderFallbackGlyphOfHeight: height fgColor: fgColor bgColor: bgColor depth: depth [
	"Render the glyph with the given code point at the specified pixel height."
	^ self fallbackGlyph
		asFormWithScale: height asFloat / (ascender - descender) 
			ascender: ascender 
			descender: descender 
			fgColor: fgColor bgColor: bgColor depth: depth
]

{ #category : #rendering }
TTFontDescription >> renderGlyph: code height: fontHeight fgColor: fgColor bgColor: bgColor depth: depth [
	"Render the glyph with the given code point at the specified pixel height."
	^(self at: code) 
		asFormWithScale: fontHeight asFloat / (ascender - descender) 
			ascender: ascender 
			descender: descender 
			fgColor: fgColor bgColor: bgColor depth: depth
]

{ #category : #'private-initialization' }
TTFontDescription >> setAscender: asc descender: desc lineGap: lgap [
	ascender := asc.
	descender := desc.
	lineGap := lgap
]

{ #category : #'private-initialization' }
TTFontDescription >> setBounds: aRect unitsPerEm: aNumber [
	bounds := aRect.
	unitsPerEm := aNumber.
]

{ #category : #'private-initialization' }
TTFontDescription >> setGlyphs: glyphArray mapping: mappingTable [
	glyphs := glyphArray.
	glyphTable := mappingTable.
]

{ #category : #'private-initialization' }
TTFontDescription >> setKernPairs: array [
	kernPairs := array
]

{ #category : #'private-initialization' }
TTFontDescription >> setStrings: anArray [
	copyright := anArray at: 1.
	familyName := anArray at: 2.
	subfamilyName := anArray at: 3.
	uniqueName := anArray at: 4.
	fullName := anArray at: 5.
	versionName := anArray at: 6.
	postscriptName := anArray at: 7.
	trademark := anArray at: 8.

]

{ #category : #'private-initialization' }
TTFontDescription >> setTypographicAscender: asc descender: desc lineGap: lGap [
	sTypoAscender := asc.
	sTypoDescender := desc.
	sTypoLineGap := lGap.

]

{ #category : #accessing }
TTFontDescription >> size [

	^ glyphTable size.

]

{ #category : #information }
TTFontDescription >> subfamilyName [
	^subfamilyName
]

{ #category : #information }
TTFontDescription >> trademark [
	^trademark
]

{ #category : #accessing }
TTFontDescription >> typographicAscender [
	"Microsoft defines this as the 'true typographic metrics' of the font."
	^sTypoAscender ifNil:[ascender]
]

{ #category : #accessing }
TTFontDescription >> typographicDescender [
	"Microsoft defines this as the 'true typographic metrics' of the font."
	^sTypoDescender ifNil:[descender]
]

{ #category : #accessing }
TTFontDescription >> typographicFontHeight [
	"cope for the fact that typographicAscender and 
	typographicDescender may not be available and 
	0-height fonts are a bit useless"
	| tfh |
	tfh := self typographicAscender - self typographicDescender.
	^ tfh = 0 ifTrue: [self fontHeight] ifFalse: [tfh]
]

{ #category : #accessing }
TTFontDescription >> typographicLineGap [
	"Microsoft defines this as the 'true typographic metrics' of the font."
	^sTypoLineGap ifNil:[lineGap]
]

{ #category : #information }
TTFontDescription >> uniqueName [
	^uniqueName
]

{ #category : #properties }
TTFontDescription >> unitsPerEm [
	^unitsPerEm
]

{ #category : #information }
TTFontDescription >> versionName [
	^versionName
]

{ #category : #copying }
TTFontDescription >> veryDeepCopyWith: deepCopier [
	"Return self.  I am shared.  Do not record me."

]
