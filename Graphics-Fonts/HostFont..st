Class {
	#name : #HostFont,
	#superclass : #StrikeFont,
	#instVars : [
		'fullWidth',
		'kernPairs',
		'ranges'
	],
	#classVars : [
		'IsoToSqueakMap'
	],
	#pools : [
		'TextConstants'
	],
	#category : #'Graphics-Fonts'
}

{ #category : #accessing }
HostFont class >> defaultRanges [

	^ Array with: (Array with: 0 with: 16r2AFF).

]

{ #category : #'instance creation' }
HostFont class >> fontName: fontName size: ptSize emphasis: emphasisCode [
	"
		^HostFont fontName: (HostFont fontNameFromUser) size: 12 emphasis: 0.
	"
	^self new fontName: fontName size: ptSize emphasis: emphasisCode
]

{ #category : #'instance creation' }
HostFont class >> fontName: fontName size: ptSize emphasis: emphasisCode rangesArray: ranges [
	"
		^HostFont fontName: (HostFont fontNameFromUser) size: 12 emphasis: 0.
	"
	^self new fontName: fontName size: ptSize emphasis: emphasisCode rangesArray: ranges
]

{ #category : #accessing }
HostFont class >> fontNameFromUser [
	"HostFont fontNameFromUser"
	| fontNames index labels |
	fontNames := self listFontNames sort.
	labels := WriteStream on: (String new: 100).
	fontNames do:[:fn| labels nextPutAll: fn] separatedBy:[labels cr].
	index := (UIManager default chooseFrom: (labels contents substrings) title: 'Choose your font').
	index = 0 ifTrue:[^nil].
	^fontNames at: index
]

{ #category : #'system defaults' }
HostFont class >> initWin32 [
	"HostFont initWin32"
	#(
			"Basic fonts"
			('Arial'				"menu/text serifless"
				(10 11 12 13 14 16 18 20 22 24 26 28 30 36 48 60 72 90))
			('Times New Roman'	"menu/text serifs"
				(10 11 12 13 14 16 18 20 22 24 26 28 30 36 48 60 72 90))
			('Courier New'			"menu/text fixed"
				(10 11 12 13 14 16 18 20 22 24 26 28 30 36 48 60 72 90))
			('Wingdings'			"deco"
				(10 11 12 13 14 16 18 20 22 24 26 28 30 36 48 60 72 90))
			('Symbol'				"deco"
				(10 11 12 13 14 16 18 20 22 24 26 28 30 36 48 60 72 90))

			"Nice fonts"
			('Verdana'			"menu/text serifless"
				(10 11 12 13 14 16 18 20 22 24 26 28 30 36 48 60 72 90))

			('Tahoma'			"menu/text serifless"
				(10 11 12 13 14 16 18 20 22 24 26 28 30 36 48 60 72 90))

			('Garamond'			"menu/text serifs"
				(10 11 12 13 14 16 18 20 22 24 26 28 30 36 48 60 72 90))
			('Georgia'			"menu/text serifs"
				(10 11 12 13 14 16 18 20 22 24 26 28 30 36 48 60 72 90))

			('Comic Sans MS'	"eToy"
				(10 11 12 13 14 16 18 20 22 24 26 28 30 36 48 60 72 90))

			"Optional fonts"
			('Impact'			"flaps"
				(10 11 12 13 14 16 18 20 22 24 26 28 30 36 48 60 72 90))

			('Webdings'			"deco"
				(10 11 12 13 14 16 18 20 22 24 26 28 30 36 48 60 72 90))

			('System'		"12pt only"
				(12))
			('Fixedsys'		"12pt only"
				(12))
		) do:[:spec| HostFont textStyleFrom: spec first sizes: spec last].

	TextConstants removeKey: #Atlanta ifAbsent: [].
	TextConstants removeKey: #ComicPlain ifAbsent: [].
	TextConstants removeKey: #ComicBold ifAbsent: [].
	TextConstants removeKey: #Courier ifAbsent: [].
	TextConstants removeKey: #Palatino ifAbsent: [].

	TextConstants at: #DefaultFixedTextStyle put: (TextConstants at: #'Courier New').
	TextConstants at: #Helvetica put:  (TextConstants at: #'Arial').


]

{ #category : #accessing }
HostFont class >> listFontName: index [
	<primitive:'primitiveListFont' module:'FontPlugin'>
	^nil
]

{ #category : #accessing }
HostFont class >> listFontNames [
	"HostFont listFontNames"
	"List all the OS font names"
	| font fontNames index |
	fontNames := WriteStream on: Array new.
	index := 0.
	[font := self listFontName: index.
	font == nil] whileFalse:[
		fontNames nextPut: font.
		index := index + 1].
	^fontNames contents
]

{ #category : #accessing }
HostFont class >> rangesForJapanese [

	| basics etc |
	basics := {
		Array with: 0 with: 255
	}.
	etc := {
		Array with: 16r370 with: 16r3FF. "greek"
		Array with: 16r400 with: 16r52F. "cyrillic"
		Array with: 16r1D00 with: 16r1D7F. "phonetic"
		Array with: 16r1E00 with: 16r1EFF. "latin extended additional"
		Array with: 16r2000 with: 16r206F. "general punctuation"
		Array with: 16r20A0 with: 16r20CF. "currency symbols"
		Array with: 16r2100 with: 16r214F. "letterlike"
		Array with: 16r2150 with: 16r218F. "number form"
		Array with: 16r2190 with: 16r21FF. "arrows"
		Array with: 16r2200 with: 16r22FF. "math operators"
		Array with: 16r2300 with: 16r23FF. "misc tech"
		Array with: 16r2460 with: 16r24FF. "enclosed alnum"
		Array with: 16r2500 with: 16r257F. "box drawing"
		Array with: 16r2580 with: 16r259F. "box elem"
		Array with: 16r25A0 with: 16r25FF. "geometric shapes"
		Array with: 16r2600 with: 16r26FF. "misc symbols"
		Array with: 16r2700 with: 16r27BF. "dingbats"
		Array with: 16r27C0 with: 16r27EF. "misc math A"
		Array with: 16r27F0 with: 16r27FF. "supplimental arrow A"
		Array with: 16r2900 with: 16r297F. "supplimental arrow B"
		Array with: 16r2980 with: 16r29FF. "misc math B"
		Array with: 16r2A00 with: 16r2AFF. "supplimental math op"
		Array with: 16r2900 with: 16r297F. "supplimental arrow B"
		Array with: 16r2E80 with: 16r2EFF. "cjk radicals suppliment"
		Array with: 16r2F00 with: 16r2FDF. "kangxi radicals"
		Array with: 16r3000 with: 16r303F. "cjk symbols"
		Array with: 16r3040 with: 16r309F. "hiragana"
		Array with: 16r30A0 with: 16r30FF. "katakana"
		Array with: 16r3190 with: 16r319F. "kanbun"
		Array with: 16r31F0 with: 16r31FF. "katakana extension"
		Array with: 16r3200 with: 16r32FF. "enclosed CJK"
		Array with: 16r3300 with: 16r33FF. "CJK compatibility"
		Array with: 16r3400 with: 16r4DBF. "CJK unified extension A"
		Array with: 16r4E00 with: 16r9FAF. "CJK ideograph"
		Array with: 16rF900 with: 16rFAFF. "CJK compatiblity ideograph"
		Array with: 16rFE30 with: 16rFE4F. "CJK compatiblity forms"
		Array with: 16rFF00 with: 16rFFEF. "half and full"
	}.

	^ basics, etc.

]

{ #category : #accessing }
HostFont class >> textStyleFrom: fontName [
	"HostFont textStyleFromUser"
	| styleName fonts |
	styleName := fontName asSymbol.
	"(TextConstants includesKey: styleName)
		ifTrue:[(self confirm: 
styleName , ' is already defined in TextConstants.
Do you want to replace that definition?')
			ifFalse: [^ self]]."
	fonts := #(10 11 12 13 14 16 18 20 22 24 26 28 30 36 48 60 72 90).
	('Rendering ', styleName) displayProgressFrom: 1 to: fonts size during:[:bar|
			fonts := fonts
				collect:[:ptSize| bar value: (fonts indexOf: ptSize).
							   self fontName: styleName 
									size: ptSize
									emphasis: 0]
				thenSelect:[:font| font notNil]]. "reject those that failed"
	fonts size = 0 ifTrue:[^self error:'Could not create font style', styleName].
	TextConstants
		at: styleName
		put: (TextStyle fontArray: fonts).
]

{ #category : #accessing }
HostFont class >> textStyleFrom: fontName sizes: ptSizes [
	| styleName fonts |
	styleName := fontName asSymbol.
	(TextConstants includesKey: styleName)
		ifTrue:[(self confirm: 
styleName , ' is already defined in TextConstants.
Do you want to replace that definition?')
			ifFalse: [^ self]].
	('Rendering ', styleName) displayProgressFrom: 1 to: ptSizes size during:[:bar|
			fonts := ptSizes
				collect:[:ptSize| bar value: (ptSizes indexOf: ptSize).
							   self fontName: styleName 
									size: ptSize
									emphasis: 0]
				thenSelect:[:font| font notNil]]. "reject those that failed"
	fonts size = 0 ifTrue:[^self error:'Could not create font style', styleName].
	TextConstants
		at: styleName
		put: (TextStyle fontArray: fonts).
]

{ #category : #accessing }
HostFont class >> textStyleFrom: fontName sizes: ptSizes ranges: ranges [
	| styleName fonts |
	styleName := fontName asSymbol.
	(TextConstants includesKey: styleName)
		ifTrue:[(self confirm: 
styleName , ' is already defined in TextConstants.
Do you want to replace that definition?')
			ifFalse: [^ self]].
	('Rendering ', styleName) displayProgressFrom: 1 to: ptSizes size during:[:bar|
			fonts := ptSizes
				collect:[:ptSize| bar value: (ptSizes indexOf: ptSize).
							   self fontName: styleName 
									size: ptSize
									emphasis: 0 rangesArray: ranges
				]
				thenSelect:[:font| font notNil]]. "reject those that failed"
	fonts size = 0 ifTrue:[^self error:'Could not create font style', styleName].
	TextConstants
		at: styleName
		put: (TextStyle fontArray: fonts).
]

{ #category : #accessing }
HostFont class >> textStyleFromUser [
	"HostFont textStyleFromUser"
	| styleName fonts |
	styleName := self fontNameFromUser ifNil:[^self].
	styleName := styleName asSymbol.
	(TextConstants includesKey: styleName)
		ifTrue:[(self confirm: 
styleName , ' is already defined in TextConstants.
Do you want to replace that definition?')
			ifFalse: [^ self]].
	fonts := #(10 12 14 16 18 20 22 24 26 28 30 36 48 60 72 90).
	('Rendering ', styleName) displayProgressFrom: 1 to: fonts size during:[:bar|
			fonts := fonts
				collect:[:ptSize| bar value: (fonts indexOf: ptSize).
							   self fontName: styleName 
									size: ptSize
									emphasis: 0]
				thenSelect:[:font| font notNil]]. "reject those that failed"
	fonts size = 0 ifTrue:[^self error:'Could not create font style', styleName].
	TextConstants
		at: styleName
		put: (TextStyle fontArray: fonts).
]

{ #category : #accessing }
HostFont >> baseKern [
	^0
]

{ #category : #accessing }
HostFont >> createCharacterToGlyphMap [

	^ IdentityGlyphMap new.

]

{ #category : #accessing }
HostFont >> descentKern [
	^0
]

{ #category : #accessing }
HostFont >> displayString: aString on: aBitBlt from: startIndex to: stopIndex at: aPoint kern: kernDelta [ 

	^ self displayString: aString on: aBitBlt from: startIndex to: stopIndex at: aPoint kern: kernDelta baselineY: aPoint y + self ascent.

]

{ #category : #accessing }
HostFont >> displayString: aString on: aBitBlt from: startIndex to: stopIndex at: aPoint kern: kernDelta baselineY: baselineY [

 	^ super displayMultiString: aString on: aBitBlt from: startIndex to: stopIndex at: aPoint kern: kernDelta baselineY: baselineY.

]

{ #category : #emphasis }
HostFont >> emphasized: code [
	| derivative addedEmphasis base safeCode |
	code = 0 ifTrue: [^ self].
	derivativeFonts == nil ifTrue:[derivativeFonts := Array new: 32].
	derivative := derivativeFonts at: (safeCode := code min: derivativeFonts size).
	derivative == nil ifFalse: [^ derivative].  "Already have this style"

	"Dont have it -- derive from another with one with less emphasis"
	addedEmphasis := 1 bitShift: safeCode highBit - 1.
	base := self emphasized: safeCode - addedEmphasis.  "Order is Bold, Ital, Under, Narrow"
	addedEmphasis = 1 ifTrue:   "Compute synthetic bold version of the font"
		[derivative := (base copy name: base name) makeBoldGlyphs].
	addedEmphasis = 2 ifTrue:   "Compute synthetic italic version of the font"
		[ derivative := (base copy name: base name) makeItalicGlyphs].
	addedEmphasis = 4 ifTrue:   "Compute underlined version of the font"
		[derivative := (base copy name: base name) makeUnderlinedGlyphs].
	addedEmphasis = 8 ifTrue:   "Compute narrow version of the font"
		[derivative := (base copy name: base name) makeCondensedGlyphs].
	addedEmphasis = 16 ifTrue:   "Compute struck-out version of the font"
		[derivative := (base copy name: base name) makeStruckOutGlyphs].
	derivative emphasis: safeCode.
	derivativeFonts at: safeCode put: derivative.
	^ derivative
]

{ #category : #'private-creation' }
HostFont >> fontName: fontName size: ptSize emphasis: emphasisCode [

	^ self fontName: fontName size: ptSize emphasis: emphasisCode rangesArray: (Array with: (Array with: 0 with: 255)).

]

{ #category : #'private-creation' }
HostFont >> fontName: fontName size: ptSize emphasis: emphasisCode rangesArray: rangesArray [
	"
		^HostFont fontName: ('MS UI Gothic') size: 12 emphasis: 0 rangesArray: EFontBDFFontReaderForRanges basicNew rangesForJapanese.
	"
	| fontHandle xStart w glyphForm fontHeight fw enc rangesStream currentRange |
	fontHandle := self primitiveCreateFont: fontName size: ptSize emphasis: emphasisCode.
	fontHandle ifNil:[^nil].
	ranges := rangesArray.
	ranges ifNil: [ranges := Array with: (Array with: 0 with: 255)].
	pointSize := ptSize.
	name := fontName.
	emphasis := emphasisCode.
	minAscii := 0.
	maxAscii := ranges last last.
	ascent := self primitiveFontAscent: fontHandle.
	descent := self primitiveFontDescent: fontHandle.
	kernPairs := Array new: (self primitiveFontNumKernPairs: fontHandle).
	1 to: kernPairs size do:[:i|
		kernPairs at: i put: (self primitiveFont: fontHandle getKernPair: i)].
	fontHeight := ascent + descent.
	xTable := Array new: maxAscii + 3.
	fullWidth := Array new: maxAscii + 1.
	xStart := maxWidth := 0.
	rangesStream := ReadStream on: (ranges collect: [:e | (e first to: e second)]).
	currentRange := rangesStream next.
	0 to: maxAscii do:[:i|
		xTable at: i+1 put: xStart.
		i > currentRange last ifTrue: [
			[rangesStream atEnd not and: [currentRange := rangesStream next. currentRange last < i]] whileTrue.
			rangesStream atEnd ifTrue: [].
		].
		(currentRange includes: i) ifTrue: [
			xTable at: i+1 put: xStart.
			fw := self primitiveFont: fontHandle fullWidthOfChar: i.
			(#(	1 "anchored morph"
				9 "tab"
				10 "LF"
				13 "CR"
			) includes: i) ifTrue:[fw := {0. 0. 0}].
			fullWidth at: i+1 put: fw.
			w := fw at: 2.
			(fw at: 1) > 0 ifTrue:[w := w + (fw at: 1)].
			(fw at: 3) > 0 ifTrue:[w := w + (fw at: 3)].
			w > maxWidth ifTrue:[maxWidth := w].
			xStart := xStart + w].
		].
	xStart = 0 ifTrue:[^nil].
	strikeLength := xStart.
	xTable at: maxAscii+1 put: xStart.
	xTable at: maxAscii+2 put: xStart.
	xTable at: maxAscii+3 put: xStart.
	glyphs := Form extent: xTable last @ fontHeight depth: 1.
	glyphForm := Form extent: maxWidth @ fontHeight depth: 1.
	0 to: maxAscii do:[:i|
		glyphForm fillWhite.
		self primitiveFont: fontHandle glyphOfChar: i into: glyphForm.
		xStart := xTable at: i+1.
		glyphForm displayOn: glyphs at: xStart@0.
		"glyphForm displayOn: Display at: xStart@0."
	].
	enc := self primitiveFontEncoding: fontHandle.
	enc = 1 ifTrue:[characterToGlyphMap := self isoToSqueakMap].
	self primitiveDestroyFont: fontHandle.
	^self
]

{ #category : #accessing }
HostFont >> getFontData [
	| fontHandle bufSize buffer |
	fontHandle := self primitiveCreateFont: name size: pointSize emphasis: emphasis.
	fontHandle ifNil:[^nil].
	bufSize := self primitiveFontDataSize: fontHandle.
	buffer := ByteArray new: bufSize.
	self primitiveFont: fontHandle getData: buffer.
	^buffer
]

{ #category : #'private-creation' }
HostFont >> isoToSqueakMap [
	^nil

]

{ #category : #emphasis }
HostFont >> makeBoldGlyphs [
	"First check if we can use some OS support for this"
	(self class listFontNames includes: name) ifFalse:[^super makeBoldGlyphs].
	"Now attempt a direct creation through the appropriate primitives"
	(self fontName: name size: pointSize emphasis: (emphasis bitOr: 1) rangesArray: ranges) 
		ifNil:[^super makeBoldGlyphs]. "nil means we failed"
]

{ #category : #emphasis }
HostFont >> makeItalicGlyphs [
	"First check if we can use some OS support for this"
	(self class listFontNames includes: name) ifFalse:[^super makeItalicGlyphs].
	"Now attempt a direct creation through the appropriate primitives"
	(self fontName: name size: pointSize emphasis: (emphasis bitOr: 2) rangesArray: ranges)
		ifNil:[^super makeItalicGlyphs]. "nil means we failed"
]

{ #category : #emphasis }
HostFont >> makeStruckOutGlyphs [
	"First check if we can use some OS support for this"
	(self class listFontNames includes: name) ifFalse:[^super makeStruckOutGlyphs].
	"Now attempt a direct creation through the appropriate primitives"
	(self fontName: name size: pointSize emphasis: (emphasis bitOr: 8) rangesArray: ranges)
		ifNil:[^super makeStruckOutGlyphs]. "nil means we failed"
]

{ #category : #emphasis }
HostFont >> makeUnderlinedGlyphs [
	"First check if we can use some OS support for this"
	(self class listFontNames includes: name) ifFalse:[^super makeUnderlinedGlyphs].
	"Now attempt a direct creation through the appropriate primitives"
	(self fontName: name size: pointSize emphasis: (emphasis bitOr: 4) rangesArray: ranges)
		ifNil:[^super makeUnderlinedGlyphs]. "nil means we failed"
]

{ #category : #primitives }
HostFont >> primitiveCreateFont: fontName size: fontSize emphasis: fontFlags [
	<primitive:'primitiveCreateFont' module:'FontPlugin'>
	^nil
]

{ #category : #primitives }
HostFont >> primitiveDestroyFont: fontHandle [
	<primitive:'primitiveDestroyFont' module:'FontPlugin'>
	^self primitiveFailed
]

{ #category : #primitives }
HostFont >> primitiveFont: fontHandle fullWidthOfChar: aCharIndex [ 
	<primitive:'primitiveFontFullWidthOfChar' module:'FontPlugin'>
	^Array 
		with: 0
		with: (self primitiveFont: fontHandle widthOfChar: aCharIndex)
		with: 0
]

{ #category : #primitives }
HostFont >> primitiveFont: fontHandle getData: buffer [
	<primitive:'primitiveGetFontData' module:'FontPlugin'>
	^self primitiveFailed
]

{ #category : #primitives }
HostFont >> primitiveFont: fontHandle getKernPair: kernIndex [
	<primitive:'primitiveFontGetKernPair' module:'FontPlugin'>
	^0
]

{ #category : #primitives }
HostFont >> primitiveFont: fontHandle glyphOfChar: aCharIndex into: glyphForm [ 
	<primitive:'primitiveFontGlyphOfChar' module:'FontPlugin'>
	^self primitiveFailed
]

{ #category : #primitives }
HostFont >> primitiveFont: fontHandle widthOfChar: aCharIndex [ 
	<primitive:'primitiveFontWidthOfChar' module:'FontPlugin'>
	^self primitiveFailed
]

{ #category : #primitives }
HostFont >> primitiveFontAscent: fontHandle [
	<primitive:'primitiveFontAscent' module:'FontPlugin'>
	^self primitiveFailed
]

{ #category : #primitives }
HostFont >> primitiveFontDataSize: fontHandle [
	<primitive:'primitiveFontDataSize' module:'FontPlugin'>
	^self primitiveFailed
]

{ #category : #primitives }
HostFont >> primitiveFontDescent: fontHandle [
	<primitive:'primitiveFontDescent' module:'FontPlugin'>
	^self primitiveFailed
]

{ #category : #primitives }
HostFont >> primitiveFontEmbeddingFlags: fontHandle [
	<primitive:'primitiveFontEmbeddingFlags' module:'FontPlugin'>
	^self primitiveFailed
]

{ #category : #primitives }
HostFont >> primitiveFontEncoding: fontHandle [
	<primitive:'primitiveFontEncoding' module:'FontPlugin'>
	^self primitiveFailed
]

{ #category : #primitives }
HostFont >> primitiveFontNumKernPairs: fontHandle [
	<primitive:'primitiveFontNumKernPairs' module:'FontPlugin'>
	^0
]

{ #category : #accessing }
HostFont >> testEmbeddingFlags [
	"HostFont basicNew testEmbeddingFlags"
	| list |
	list := self class listFontNames.
	list do:[:fName| | fontHandle |
		fontHandle := self primitiveCreateFont: fName size: 12 emphasis: 0.
		fontHandle ifNotNil:[
			type := self primitiveFontEmbeddingFlags: fontHandle.
			Transcript cr; show: fName,': ', type printString.
			self primitiveDestroyFont: fontHandle.
		].
	].
]
