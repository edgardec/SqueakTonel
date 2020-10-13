Class {
	#name : #StrikeFontSet,
	#superclass : #AbstractFont,
	#instVars : [
		'fontArray',
		'emphasis',
		'derivativeFonts',
		'name'
	],
	#category : #'Multilingual-Display'
}

{ #category : #'fileIn\/Out' }
StrikeFontSet class >> createExternalFontFileForLatin2: fileName [
"
	StrikeFontSet createExternalFontFileForLatin2: 'latin2.out'.
"

	| file array f installDirectory |
	file := FileStream newFileNamed: fileName.
	installDirectory := Smalltalk at: #M17nInstallDirectory ifAbsent: [].
	installDirectory := installDirectory
		ifNil: [String new]
		ifNotNil: [installDirectory , FileDirectory pathNameDelimiter asString].
	array := Array
				with: (StrikeFont newFromEFontBDFFile: installDirectory , 'b10.bdf' name: 'LatinTwo9' ranges: EFontBDFFontReaderForRanges rangesForLatin2)
				with: (StrikeFont newFromEFontBDFFile: installDirectory , 'b12.bdf' name: 'LatinTwo10' ranges: EFontBDFFontReaderForRanges rangesForLatin2)
				with: (StrikeFont newFromEFontBDFFile: installDirectory , 'b14.bdf' name: 'LatinTwo12' ranges: EFontBDFFontReaderForRanges rangesForLatin2)
				with: (StrikeFont newFromEFontBDFFile: installDirectory , 'b16.bdf' name: 'LatingTwo14' ranges: EFontBDFFontReaderForRanges rangesForLatin2)
				with: (StrikeFont newFromEFontBDFFile: installDirectory , 'b24.bdf' name: 'LatinTwo20' ranges: EFontBDFFontReaderForRanges rangesForLatin2).
	TextConstants at: #forceFontWriting put: true.
	f := ReferenceStream on: file.
	f nextPut: array.
	file close.
	TextConstants removeKey: #forceFontWriting.

]

{ #category : #'fileIn\/Out' }
StrikeFontSet class >> createExternalFontFileForUnicodeJapanese: fileName [
"
	StrikeFontSet createExternalFontFileForUnicodeJapanese: 'uJapaneseFont.out'.
"

	| file array f installDirectory |
	file := FileStream newFileNamed: fileName.
	installDirectory := Smalltalk at: #M17nInstallDirectory ifAbsent: [].
	installDirectory := installDirectory
		ifNil: [String new]
		ifNotNil: [installDirectory , FileDirectory pathNameDelimiter asString].
	array := Array
				with: (StrikeFont newForJapaneseFromEFontBDFFile: installDirectory , 'b12.bdf' name: 'Japanese10' overrideWith: 'shnmk12.bdf')
				with: ((StrikeFont newForJapaneseFromEFontBDFFile: installDirectory , 'b14.bdf' name: 'Japanese12' overrideWith: 'shnmk14.bdf') "fixAscent: 14 andDescent: 1 head: 1")
				with: ((StrikeFont newForJapaneseFromEFontBDFFile: 'b16.bdf' name: 'Japanese14' overrideWith: 'shnmk16.bdf') "fixAscent: 16 andDescent: 4 head: 4")
				with: (StrikeFont newForJapaneseFromEFontBDFFile: installDirectory , 'b24.bdf' name: 'Japanese18' overrideWith: 'kanji24.bdf').
	TextConstants at: #forceFontWriting put: true.
	f := ReferenceStream on: file.
	f nextPut: array.
	file close.
	TextConstants removeKey: #forceFontWriting.

]

{ #category : #'fileIn\/Out' }
StrikeFontSet class >> createExternalFontFileForUnicodeKorean: fileName [
"
	Smalltalk garbageCollect.
	StrikeFontSet createExternalFontFileForUnicodeKorean: 'uKoreanFont.out'.
"

	| file array f installDirectory |
	file := FileStream newFileNamed: fileName.
	installDirectory := Smalltalk at: #M17nInstallDirectory ifAbsent: [].
	installDirectory := installDirectory
		ifNil: [String new]
		ifNotNil: [installDirectory , FileDirectory pathNameDelimiter asString].
	array := Array
				with: (StrikeFont newForKoreanFromEFontBDFFile: installDirectory , 'b12.bdf' name: 'Japanese10' overrideWith: 'shnmk12.bdf')
				with: ((StrikeFont newForKoreanFromEFontBDFFile: installDirectory , 'b14.bdf' name: 'Japanese12' overrideWith: 'shnmk14.bdf') "fixAscent: 14 andDescent: 1 head: 1")
				with: ((StrikeFont newForKoreanFromEFontBDFFile: installDirectory , 'b16.bdf' name: 'Japanese14' overrideWith: 'hanglg16.bdf') fixAscent: 16 andDescent: 4 head: 4)
				with: (StrikeFont newForKoreanFromEFontBDFFile: installDirectory , 'b24.bdf' name: 'Japanese18' overrideWith: 'hanglm24.bdf').
	TextConstants at: #forceFontWriting put: true.
	f := ReferenceStream on: file.
	f nextPut: array.
	file close.
	TextConstants removeKey: #forceFontWriting.

]

{ #category : #'instance creation' }
StrikeFontSet class >> decodedFromRemoteCanvas: aString [

	| array |
	array := aString findTokens: #($ ).
	^ self familyName: (array at: 1) size: (array at: 2) asNumber emphasized: (array at: 3) asNumber.

]

{ #category : #'system maintenance' }
StrikeFontSet class >> duplicateArrayElementsForLeadingCharShift [
"
	self duplicateArrayElementsForLeadingCharShift
"
	self allInstances do: [:s |
		| array font |
		s emphasis = 0 ifTrue: [
			array := s fontArray.
			2 to: (4 min: array size) do: [:i |
				font := array at: i.
				s addNewFont: font at: ((i - 1) << 2) + 1.
			].
		] ifFalse: [
			s reset
		].
	].

]

{ #category : #'instance creation' }
StrikeFontSet class >> familyName: aName size: aSize [
	"Answer a font (or the default font if the name is unknown) in the specified size."

	| collection |
	collection :=  self allInstances select: [:inst | (inst name beginsWith: aName) and: [inst emphasis = 0]].
	collection isEmpty ifTrue: [
		(aName = 'DefaultMultiStyle') ifTrue: [
			collection := (TextConstants at: #DefaultMultiStyle) fontArray.
		] ifFalse: [
			^ TextStyle defaultFont
		]
	].
	collection sort: [:a :b | a pointSize <= b pointSize].
	collection do: [:s | (s pointSize >= aSize) ifTrue: [^ s]].
	^ TextStyle defaultFont.

]

{ #category : #'instance creation' }
StrikeFontSet class >> familyName: aName size: aSize emphasized: emphasisCode [
	"Create the font with this emphasis"

	^ (self familyName: aName size: aSize) emphasized: emphasisCode

]

{ #category : #utilities }
StrikeFontSet class >> findMaximumLessThan: f in: array [

	array size to: 1 by: -1 do: [:i |
		f height >= (array at: i) height ifTrue: [^ array at: i].
	].
	^ array first.

]

{ #category : #'class initialization' }
StrikeFontSet class >> initialize [
	Smalltalk addToShutDownList: self after: StrikeFont
]

{ #category : #'fileIn\/Out' }
StrikeFontSet class >> installExternalFontFileName6: fileName encoding: encoding encodingName: aString textStyleName: styleName [

	^ self installExternalFontFileName6: fileName inDir: FileDirectory default encoding: encoding encodingName: aString textStyleName: styleName.

"
StrikeFontSet createExternalFontFileForCyrillic: 'cyrillicFont.out'.

StrikeFontSet installExternalFontFileName6: 'latin2.out' encoding: Latin2Environment leadingChar encodingName: #Latin2 textStyleName: #DefaultMultiStyle.
StrikeFontSet installExternalFontFileName6: 'uJapaneseFont.out' encoding: JapaneseEnvironment leadingChar encodingName: #Japanese textStyleName: #DefaultMultiStyle.

StrikeFontSet installExternalFontFileName6: 'uKoreanFont.out' encoding: UnicodeKorean leadingChar encodingName: #Korean textStyleName: #DefaultMultiStyle.

StrikeFontSet removeFontsForEncoding: 2 encodingName: #Gb2312.
self halt.
StrikeFontSet removeFontsForEncoding: 3 encodingName: #KsX1001.
"

]

{ #category : #'fileIn\/Out' }
StrikeFontSet class >> installExternalFontFileName6: fileName inDir: dir encoding: encoding encodingName: aString textStyleName: styleName [ 
	| aStream |
	aStream := dir readOnlyFileNamed: fileName.
	[self
		installExternalFontOn: aStream
		encoding: encoding
		encodingName: aString
		textStyleName: styleName]
		ensure: [aStream close]
]

{ #category : #'fileIn\/Out' }
StrikeFontSet class >> installExternalFontFileName: fileName encoding: encoding encodingName: aString textStyleName: styleName [

	^ self installExternalFontFileName: fileName inDir: FileDirectory default encoding: encoding encodingName: aString textStyleName: styleName.

"
StrikeFontSet createExternalFontFileForCyrillic: 'cyrillicFont.out'.

StrikeFontSet installExternalFontFileName: 'chineseFont.out' encoding: 2 encodingName: #Gb2312 textStyleName: #DefaultMultiStyle.
StrikeFontSet installExternalFontFileName: 'japaneseFont.out' encoding: 1 encodingName: #JisX0208 textStyleName: #DefaultMultiStyle.
StrikeFontSet installExternalFontFileName: 'defaultFont.out' encoding: 0 encodingName: #Latin1 textStyleName: #DefaultMultiStyle.
StrikeFontSet installExternalFontFileName: 'cyrillicFont.out' encoding: UnicodeCyrillic leadingChar encodingName: #Cyrillic textStyleName: #DefaultMultiStyle.
StrikeFontSet installExternalFontFileName: 'extendedLatinFont.out' encoding: UnicodeLatinExtendedAB leadingChar encodingName: #ExtendedLatin textStyleName: #DefaultMultiStyle.
StrikeFontSet installExternalFontFileName: 'ipaExtensionsFont.out' encoding: UnicodeIPA leadingChar encodingName: #IPAExtensions textStyleName: #DefaultMultiStyle.
StrikeFontSet installExternalFontFileName: 'armenianFont.out' encoding: UnicodeArmenian leadingChar encodingName: #Armenian textStyleName: #DefaultMultiStyle.
StrikeFontSet installExternalFontFileName: 'greekFont.out' encoding: UnicodeGreek leadingChar encodingName: #Greek textStyleName: #DefaultMultiStyle.

StrikeFontSet installExternalFontFileName: 'arrowFont.out' encoding: UnicodeArrows leadingChar encodingName: #Arrow textStyleName: #DefaultMultiStyle.

StrikeFontSet installExternalFontFileName: 'uJapaneseFont.out' indir: FileDirectory default encoding: JapaneseEnvironment leadingChar encodingName: #Japanese textStyleName: #DefaultMultiStyle.

StrikeFontSet installExternalFontFileName: 'uKoreanFont.out' encoding: UnicodeKorean leadingChar encodingName: #Korean textStyleName: #DefaultMultiStyle.

StrikeFontSet removeFontsForEncoding: 2 encodingName: #Gb2312.
self halt.
StrikeFontSet removeFontsForEncoding: 3 encodingName: #KsX1001.
"

]

{ #category : #'fileIn\/Out' }
StrikeFontSet class >> installExternalFontFileName: fileName inDir: dir encoding: encoding encodingName: aString textStyleName: styleName [

	| array arrayFour oldStyle arrayOfFS |
	array := (ReferenceStream on: (dir readOnlyFileNamed: fileName)) next.

	arrayFour := Array new: 4 withAll: array last.
	arrayFour replaceFrom: 1 to: array size with: array startingAt: 1.
	TextConstants at: aString asSymbol put: arrayFour.

	oldStyle := TextConstants at: styleName asSymbol.
	arrayOfFS := oldStyle fontArray.
	arrayOfFS := (1 to: 4) collect: [:i |
		| fs fonts newFonts |
		fs := arrayOfFS at: i.
		fonts := fs fontArray.
		encoding + 1 > fonts size ifTrue: [
			newFonts := Array new: encoding + 1.
			newFonts replaceFrom: 1 to: fonts size with: fonts startingAt: 1.
			newFonts at: encoding + 1 put: (arrayFour at: i).
			fs initializeWithFontArray: newFonts.
		] ifFalse: [
			fonts at: encoding + 1 put: (arrayFour at: i).
		].
		fs.
	].

	TextConstants at: styleName asSymbol put: (TextStyle fontArray: arrayOfFS).
	oldStyle becomeForward: (TextConstants at: styleName asSymbol).


]

{ #category : #'fileIn\/Out' }
StrikeFontSet class >> installExternalFontOn: aStream encoding: encoding encodingName: aString textStyleName: styleName [

	| array encodingIndex textStyle |

	array := aStream
		untilEndWithFork: [(ReferenceStream on: aStream) next]
		displayingProgress: 'Font reading...'. 
	
	TextConstants at: aString asSymbol put: array.

	textStyle := TextConstants at: styleName asSymbol.
	encodingIndex := encoding + 1.
	textStyle fontArray do: [:fs |
		| fonts |
		fonts := fs fontArray.
		encodingIndex > fonts size
			ifTrue: [fonts :=  (Array new: encodingIndex)
				replaceFrom: 1 to: fonts size with: fonts startingAt: 1].
		fonts at: encodingIndex put: (self findMaximumLessThan: fs fontArray first in: array).
		fs initializeWithFontArray: fonts.
	].

]

{ #category : #'fileIn\/Out' }
StrikeFontSet class >> installExternalFontOn: aStream forLocale: locale [ 
	self
		installExternalFontOn: aStream
		encoding: locale languageEnvironment leadingChar
		encodingName: locale languageEnvironment fontEncodingName
		textStyleName: #DefaultMultiStyle
]

{ #category : #'fileIn\/Out' }
StrikeFontSet class >> installNewFontAtIndex: newIndex fromOld: oldIndex [
	self allInstances do: [:set |
		| fontArray newArray |
		fontArray := set fontArray.
		newIndex + 1 > fontArray size ifTrue: [
			newArray := Array new: newIndex + 1.
			newArray replaceFrom: 1 to: fontArray size with: fontArray startingAt: 1.
			newArray at: newIndex + 1 put: (fontArray at: oldIndex + 1).
			set initializeWithFontArray: newArray.
		] ifFalse: [
			fontArray at: newIndex + 1 put: (fontArray at: oldIndex + 1).
		].
	].

"
StrikeFontSet installNewFontAtIndex: UnicodeSimplifiedChinese leadingChar fromOld: UnicodeJapanese leadingChar
StrikeFontSet installNewFontAtIndex: UnicodeKorean leadingChar fromOld: UnicodeJapanese leadingChar
"

]

{ #category : #'instance creation' }
StrikeFontSet class >> newFontArray: anArray [
 
	^super new initializeWithFontArray: anArray

]

{ #category : #'fileIn\/Out' }
StrikeFontSet class >> removeFontsForEncoding: leadingChar encodingName: encodingSymbol [

	| insts |
	leadingChar = 0 ifTrue: [^ self error: 'you cannot delete the intrinsic fonts'].
	insts := self allInstances.
	insts do: [:inst |
		| fonts newFonts index |
		fonts := inst fontArray.
		fonts size >= (leadingChar + 1) ifTrue: [
			leadingChar + 1 = fonts size ifTrue: [
				newFonts := fonts copyFrom: 1 to: fonts size - 1.
				index := newFonts indexOf: nil.
				index > 0 ifTrue: [newFonts := newFonts copyFrom: 1 to: index - 1].
				inst initializeWithFontArray: newFonts.
			] ifFalse: [
				fonts at: leadingChar + 1 put: nil.
			].
		].
	].

	TextConstants removeKey: encodingSymbol asSymbol ifAbsent: [].

]

{ #category : #'class initialization' }
StrikeFontSet class >> shutDown [  "StrikeFontSet shutDown"
	"Deallocate synthetically derived copies of base fonts to save space"
	StrikeFontSet allSubInstancesDo: [:sf | sf reset].
]

{ #category : #'class initialization' }
StrikeFontSet class >> unload [
	Smalltalk removeFromShutDownList: self
]

{ #category : #private }
StrikeFontSet >> addNewFont: aFont at: encodingIndex [

	| newArray |
	encodingIndex > fontArray size ifTrue: [
		newArray := Array new: encodingIndex.
		newArray replaceFrom: 1 to: fontArray size with: fontArray startingAt: 1.
	] ifFalse: [
		newArray := fontArray.
	].

	newArray at: encodingIndex put: aFont.

	self initializeWithFontArray: newArray.

]

{ #category : #accessing }
StrikeFontSet >> ascent [

	^ fontArray first ascent.

]

{ #category : #accessing }
StrikeFontSet >> ascentKern [

	^ fontArray first ascentKern.

]

{ #category : #accessing }
StrikeFontSet >> ascentOf: aCharacter [
	^(self fontOf: aCharacter) ascent
]

{ #category : #accessing }
StrikeFontSet >> baseKern [

	^ fontArray first baseKern.

]

{ #category : #private }
StrikeFontSet >> basicHasGlyphOf: aCharacter [

	| actualFont |
	actualFont := self fontOf: aCharacter ifAbsent: [^ false].
	^ actualFont basicHasGlyphOf: aCharacter
]

{ #category : #private }
StrikeFontSet >> bonk: glyphForm with: bonkForm at: j [
	"Bonking means to run through the glyphs clearing out black pixels
	between characters to prevent them from straying into an adjacent
	character as a result of, eg, bolding or italicizing"
	"Uses the bonkForm to erase at every character boundary in glyphs."

	| bb offset font x |
	font := (fontArray at: j).
	offset := bonkForm offset x.
	bb := BitBlt toForm: glyphForm.
	bb sourceForm: bonkForm; sourceRect: bonkForm boundingBox;
		combinationRule: Form erase; destY: 0.
	x := font xTable.
	(x isMemberOf: SparseLargeTable) ifTrue: [
		x base to: x size-1 do: [:i | bb destX: (x at: i) + offset; copyBits].
	] ifFalse: [
		1 to: x size-1 do: [:i | bb destX: (x at: i) + offset; copyBits].
	].

]

{ #category : #'character shapes' }
StrikeFontSet >> characterFormAt: character [ 

	| encoding ascii xTable leftX rightX |
	encoding := character leadingChar + 1.
	ascii := character charCode.
	(ascii < (fontArray at: encoding) minAscii or: [ascii > (fontArray at: encoding) maxAscii])
		ifTrue: [ascii := (fontArray at: encoding) maxAscii].
	xTable := (fontArray at: encoding) xTable.
	leftX := xTable at: ascii + 1.
	rightX := xTable at: ascii + 2.
	^ (fontArray at: encoding) glyphs copy: (leftX @ 0 corner: rightX @ self height).

]

{ #category : #'character shapes' }
StrikeFontSet >> characterFormAt: character put: characterForm [ 

	| ascii leftX rightX widthDif newGlyphs encoding xTable glyphs |
	encoding := character leadingChar + 1.
	ascii := character charCode.
	ascii < (fontArray at: encoding) minAscii ifTrue: [
		^ self error: 'Cant store characters below min ascii'
	].
	ascii > (fontArray at: encoding) maxAscii ifTrue: [
		^ self error: 'No change made'
	].
	xTable := (fontArray at: encoding) xTable.
	leftX := xTable at: ascii + 1.
	rightX := xTable at: ascii + 2.
	glyphs := (fontArray at: encoding) glyphs.
	widthDif := characterForm width - (rightX - leftX).
	widthDif ~= 0 ifTrue: [
		newGlyphs := Form extent: glyphs width + widthDif @ glyphs height.
		newGlyphs copy: (0 @ 0 corner: leftX @ glyphs height) from: 0 @ 0
			in: glyphs rule: Form over.
		newGlyphs
				copy: (rightX + widthDif @ 0 corner: newGlyphs width @ glyphs height)
				from: rightX @ 0 in: glyphs rule: Form over.
		glyphs := newGlyphs.
		"adjust further entries on xTable"
		xTable := xTable copy.
		ascii + 2 to: xTable size do: [:i |
			xTable at: i put: (xTable at: i) + widthDif]].
	glyphs copy: (leftX @ 0 extent: characterForm extent) from: 0 @ 0 in: characterForm rule: Form over.

]

{ #category : #accessing }
StrikeFontSet >> characterToGlyphMap [
	"return the mapping for my first font; this follows the general form of all the other accessing methods but since we can't specifically find a font for a particualr character her we devolve to the first font in the fontArray - just like the other non-character-specific messages (#ascent etc).
	This is only sent by the BitBlt>primDisplayString:from:to:map:xTable: method (other than internally by StrikeFont)"
	^fontArray first characterToGlyphMap
]

{ #category : #displaying }
StrikeFontSet >> characters: anInterval in: sourceString displayAt: aPoint clippedBy: clippingRectangle rule: ruleInteger fillColor: aForm kernDelta: kernDelta on: aBitBlt [
	"Simple, slow, primitive method for displaying a line of characters.
	No wrap-around is provided."

	^anInterval inject: aPoint into: 
		[:destPoint :i |
		| f xTable leftX noFont sourceRect encoding ascii rightX |
		encoding := (sourceString at: i) leadingChar + 1.
		noFont := false.
		f := [fontArray at: encoding]
			on: Exception do: [:ex | nil].
		f ifNil: [noFont := true. f := fontArray at: 1].
		ascii := (noFont ifTrue: [$?] ifFalse: [sourceString at: i]) charCode.
		(ascii < f minAscii
			or: [ascii > f maxAscii])
			ifTrue: [ascii := f maxAscii].
		xTable := f xTable.
		leftX := xTable at: ascii + 1.
		rightX := xTable at: ascii + 2.
		sourceRect := leftX @ 0 extent: (rightX - leftX) @ self height.
		aBitBlt copyFrom: sourceRect in: f glyphs to: destPoint.
		destPoint x + (rightX - leftX + kernDelta) @ destPoint y.
	].

]

{ #category : #accessing }
StrikeFontSet >> depth [

	^ self glyphs depth
]

{ #category : #accessing }
StrikeFontSet >> derivativeFonts [
	^derivativeFonts copyWithout: nil
]

{ #category : #accessing }
StrikeFontSet >> descent [

	^ fontArray first descent.

]

{ #category : #accessing }
StrikeFontSet >> descentKern [

	^ fontArray first descentKern.

]

{ #category : #accessing }
StrikeFontSet >> descentOf: aCharacter [
	^(self fontOf: aCharacter) descent
]

{ #category : #displaying }
StrikeFontSet >> displayLine: aString at: aPoint [ 
	"Display the characters in aString, starting at position aPoint."

	self characters: (1 to: aString size)
		in: aString
		displayAt: aPoint
		clippedBy: Display boundingBox
		rule: Form over
		fillColor: nil
		kernDelta: 0
		on: (BitBlt toForm: Display).

]

{ #category : #displaying }
StrikeFontSet >> displayMultiString: aString on: aBitBlt from: startIndex to: stopIndex at: aPoint kern: kernDelta baselineY: baselineY [
"display a multi-byte characterset string; each character may require swapping to a new strikefont as discovered by glyphInfoOf:"
	| destPoint leftX rightX glyphInfo g destY |
	destPoint := aPoint.
	glyphInfo := Array new: 5.
	startIndex to: stopIndex do: [:charIndex |
		self glyphInfoOf: (aString at: charIndex) into: glyphInfo.
		g := glyphInfo at:1.
		leftX := glyphInfo at:2.
		rightX := glyphInfo at:3.
		((glyphInfo at:5) ~= aBitBlt lastFont) ifTrue: [
			(glyphInfo at:5) installOn: aBitBlt.
		].
		aBitBlt sourceForm: g.
		destY := baselineY - (glyphInfo at:4).
		aBitBlt destX: (destPoint x) destY: destY width: (rightX - leftX) height: (self height).
		aBitBlt sourceOrigin: leftX @ 0.
		aBitBlt copyBits.
		destPoint := destPoint x + (rightX - leftX + kernDelta) @ destPoint y.
	].
	^ destPoint.
]

{ #category : #displaying }
StrikeFontSet >> displayString: aString on: aBitBlt from: startIndex to: stopIndex at: aPoint kern: kernDelta [ 

	^ self displayString: aString on: aBitBlt from: startIndex to: stopIndex at: aPoint kern: kernDelta baselineY: aPoint y + self ascent.

]

{ #category : #displaying }
StrikeFontSet >> displayString: aString on: aBitBlt from: startIndex to: stopIndex at: aPoint kern: kernDelta baselineY: baselineY [
	"Draw the given string (handles a Text as well) from startIndex to stopIndex at aPoint on the (already prepared) BitBlt."
	
	"Assume this is a wide string"
	| isMulti |
	isMulti := true.

	"Look for an excuse to use the fast primitive. This is a terrible way to do this but at least it now avoids use of *three* isKindOf: in one method"
 	(aString isByteString) 
		ifTrue:[ isMulti := false]
		ifFalse:[ (aString isText) 
			ifTrue:[ (aString string isByteString) 
				ifTrue:[ isMulti := false ] 
	]].

	isMulti ifTrue:[^ self displayMultiString: aString on: aBitBlt from: startIndex to: stopIndex at: aPoint kern: kernDelta baselineY: baselineY].

	^ aBitBlt displayString: aString 
			from: startIndex 
			to: stopIndex 
			at: aPoint 
			strikeFont: self
			kern: kernDelta
]

{ #category : #displaying }
StrikeFontSet >> displayString: aString on: aBitBlt from: startIndex to: stopIndex at: aPoint kern: kernDelta from: fromFont baselineY: baselineY [

	| destPoint leftX rightX glyphInfo g tag char destY rIndex |
	destPoint := aPoint.
	rIndex := startIndex.
	tag := (aString at: rIndex) leadingChar.
	glyphInfo := Array new: 5.
	[rIndex <= stopIndex] whileTrue: [
		char := aString at: rIndex.
		((fromFont hasGlyphOf: char) or: [char leadingChar ~= tag]) ifTrue: [^destPoint].
		self glyphInfoOf: char into: glyphInfo.
		g := glyphInfo first.
		leftX := glyphInfo second.
		rightX := glyphInfo third.
		(glyphInfo fifth ~= aBitBlt lastFont) ifTrue: [
			glyphInfo fifth installOn: aBitBlt.
		].
		destY := baselineY - glyphInfo fourth. 
		aBitBlt
			sourceForm: g;
			destX: destPoint x;
			destY: destY;
			sourceOrigin: leftX @ 0;
			width: rightX - leftX;
			height: self height;
			copyBits.
		destPoint := destPoint x + (rightX - leftX + kernDelta) @ destPoint y.
		rIndex := rIndex + 1.
	].
	^destPoint.

]

{ #category : #displaying }
StrikeFontSet >> displayStringR2L: aString on: aBitBlt from: startIndex to: stopIndex at: aPoint kern: kernDelta [ 

	| destPoint font |
	destPoint := aPoint.
	startIndex to: stopIndex do: [:charIndex | 
		| encoding ascii xTable leftX rightX | 
		encoding := (aString at: charIndex) leadingChar + 1.
		ascii := (aString at: charIndex) charCode.
		font := fontArray at: encoding.
		((ascii between: font minAscii and: font maxAscii) not) ifTrue: [
			ascii := font maxAscii].
		xTable := font xTable.
		leftX := xTable at: ascii + 1.
		rightX := xTable at: ascii + 2.
		aBitBlt
			sourceForm: font glyphs;
			destX: destPoint x - (rightX - leftX);
			destY: destPoint y;
			sourceOrigin: leftX @ 0;
			width: rightX - leftX;
			height: self height;
			copyBits.
		destPoint := destPoint x - (rightX - leftX + kernDelta) @ destPoint y.
	].

]

{ #category : #accessing }
StrikeFontSet >> emphasis [
	"Answer the integer code for synthetic bold, italic, underline, and 
	strike-out."

	^ emphasis.

]

{ #category : #accessing }
StrikeFontSet >> emphasis: code [ 
	"Set the integer code for synthetic bold, itallic, underline, and strike-out, 
	where bold=1, italic=2, underlined=4, and struck out=8."

	emphasis := code.

]

{ #category : #accessing }
StrikeFontSet >> emphasized: code [ 

	"Answer a copy of the receiver with emphasis set to include code."
	| derivative addedEmphasis base safeCode |
	code = 0 ifTrue: [^ self].
	(derivativeFonts == nil or: [derivativeFonts size = 0]) ifTrue: [^ self].
	derivative := derivativeFonts at: (safeCode := code min: derivativeFonts size).
	derivative == nil ifFalse: [^ derivative].  "Already have this style"

	"Dont have it -- derive from another with one with less emphasis"
	addedEmphasis := 1 bitShift: safeCode highBit - 1.
	base := self emphasized: safeCode - addedEmphasis.  "Order is Bold, Ital, Under, Narrow"
	addedEmphasis = 1 ifTrue:   "Compute synthetic bold version of the font"
		[derivative := (base copy name: base name , 'B') makeBoldGlyphs].
	addedEmphasis = 2 ifTrue:   "Compute synthetic italic version of the font"
		[ derivative := (base copy name: base name , 'I') makeItalicGlyphs].
	addedEmphasis = 4 ifTrue:   "Compute underlined version of the font"
		[derivative := (base copy name: base name , 'U') makeUnderlinedGlyphs].
	addedEmphasis = 8 ifTrue:   "Compute narrow version of the font"
		[derivative := (base copy name: base name , 'N') makeCondensedGlyphs].
	addedEmphasis = 16 ifTrue:   "Compute struck-out version of the font"
		[derivative := (base copy name: base name , 'X') makeStruckOutGlyphs].
	derivative emphasis: safeCode.
	derivativeFonts at: safeCode put: derivative.
	^ derivative

]

{ #category : #accessing }
StrikeFontSet >> familyName [

	^ fontArray first familyName.

]

{ #category : #accessing }
StrikeFontSet >> familySizeFace [

	^ Array
		with: fontArray first name
		with: self height
		with: fontArray first emphasis

]

{ #category : #accessing }
StrikeFontSet >> fontArray [

	^ fontArray

]

{ #category : #accessing }
StrikeFontSet >> fontArray: anArray [

	fontArray := anArray.

]

{ #category : #displaying }
StrikeFontSet >> fontDisplay [
	"TextStyle default defaultFont fontDisplay."

	Display restoreAfter:
		[(Form extent: 440@400) displayAt: 90@90.
		 0 to: 15 do:
			[:i |
			i storeStringHex displayAt: 100 @ (20 * i + 100).
			0 to: 15 do:
				[:j |
				((16*i+j) between: 1 and: (self xTable size - 2)) ifTrue:
					[(self characterFormAt: (16 * i + j) asCharacter)
						displayAt: (20 * j + 150) @ (20 * i + 100)]]].
			'Click to continue...' asDisplayText displayAt: 100@450]
]

{ #category : #accessing }
StrikeFontSet >> fontNameWithPointSize [

	^ fontArray first fontNameWithPointSize.

]

{ #category : #accessing }
StrikeFontSet >> fontOf: aCharacter [
	"Answer the actual font to use for aCharacter"
	^self fontOf: aCharacter ifAbsent:[fontArray at: 1]
]

{ #category : #accessing }
StrikeFontSet >> fontOf: aCharacter ifAbsent: aBlock [
	"Answer the actual font to use for aCharacter"
	| encoding font |
	encoding := aCharacter leadingChar + 1.
	encoding <= fontArray size 
		ifTrue:[font := fontArray at: encoding].
	font ifNil:[^aBlock value].
	^font

]

{ #category : #private }
StrikeFontSet >> glyphInfoOf: aCharacter into: glyphInfoArray [
"return glyph info for the character; it can get complicated."
	| index f code leftX |
	"the leadingChar gives us an encoding. if that is outside the range of fonts in my fontArray, just return the default glyphInfo for a question-mark"
	index := aCharacter leadingChar + 1.
	fontArray size < index ifTrue: [^ self questionGlyphInfoInto: glyphInfoArray].
	(f := fontArray at: index) ifNil: [^ self questionGlyphInfoInto: glyphInfoArray].

	"if the actual character is not in the range supported by the chosen font, return that default question-mark info "
	code := aCharacter charCode.
	((code between: f minAscii and: f maxAscii) not) ifTrue: [
		^ self questionGlyphInfoInto: glyphInfoArray.
	].

	"if the xTable doesn't like the character, return that question-mark default info"
	leftX := f xTable at: code + 1.
	leftX < 0 ifTrue: [
		^ self questionGlyphInfoInto: glyphInfoArray.
	].

	"finally, we have an ok font and character to return glyph info about"
	glyphInfoArray at: 1 put: f glyphs;
		at: 2 put: leftX;
		at: 3 put: (f xTable at: code + 2);
		at: 4 put: (f ascentOf: aCharacter);
		at: 5 put: self.
	^ glyphInfoArray.

]

{ #category : #accessing }
StrikeFontSet >> glyphs [

	^ fontArray first glyphs

]

{ #category : #accessing }
StrikeFontSet >> glyphsEncoding: anInteger [

	^ (fontArray at: (anInteger+1)) glyphs.

]

{ #category : #accessing }
StrikeFontSet >> height [

	^ fontArray first height.

]

{ #category : #accessing }
StrikeFontSet >> heightOf: aCharacter [
	^(self fontOf: aCharacter) height
]

{ #category : #'initialize-release' }
StrikeFontSet >> initializeWithFontArray: anArray [ 
	"Initialize with given font array, the ascent of primary font is modified 
	if another font has higher size"
	| primaryFont maxHeight newFont |
	fontArray := anArray.
	primaryFont := anArray first.
	emphasis := 0.
	name := primaryFont name.
	maxHeight := anArray
				inject: 0
				into: [:theHeight :font | (font notNil
							and: [theHeight < font height])
						ifTrue: [font height]
						ifFalse: [theHeight]].
	primaryFont height < maxHeight
		ifTrue: [newFont := primaryFont copy
						fixAscent: primaryFont ascent + (maxHeight - primaryFont height)
						andDescent: primaryFont descent
						head: 0.
			fontArray at: 1 put: newFont].
	self reset
]

{ #category : #displaying }
StrikeFontSet >> installOn: aDisplayContext [

	^ aDisplayContext installStrikeFont: self.

]

{ #category : #displaying }
StrikeFontSet >> installOn: aDisplayContext foregroundColor: foregroundColor backgroundColor: backgroundColor [ 

	^ aDisplayContext
		installStrikeFont: self
		foregroundColor: foregroundColor
		backgroundColor: backgroundColor.

]

{ #category : #testing }
StrikeFontSet >> isFontSet [

	^ true.

]

{ #category : #accessing }
StrikeFontSet >> latin1 [
	"Answer primary font"
	^ fontArray at: 1
]

{ #category : #accessing }
StrikeFontSet >> lineGrid [

	| f |
	f := fontArray first.
	^ f ascent + f descent.

]

{ #category : #emphasis }
StrikeFontSet >> makeBoldGlyphs [
	"Make a bold set of glyphs with same widths by ORing 1 bit to the right
		(requires at least 1 pixel of intercharacter space)"

	| g bonkForm font |
	1 to: fontArray size do: [:i |
		font := fontArray at: i.
		font ifNotNil: [
			g := font glyphs deepCopy.
			bonkForm := (Form extent: 1@16) fillBlack offset: -1@0.
			self bonk: g with: bonkForm at: i.
			g copyBits: g boundingBox from: g at: (1@0)
				clippingBox: g boundingBox rule: Form under fillColor: nil.
			(fontArray at: i) setGlyphs: g.
		].
	].

]

{ #category : #emphasis }
StrikeFontSet >> makeItalicGlyphs [
	"Make an italic set of glyphs with same widths by skewing left and right
		(may require more intercharacter space)"

	| g bonkForm bc font |
	1 to: fontArray size do: [:j |
		font := (fontArray at: j).
		font ifNotNil: [
			g := font glyphs deepCopy.
			"BonkForm will have bits where slanted characters overlap their neighbors."
			bonkForm := Form extent: (self height//4+2) @ self height.
			bc := font descent//4 + 1.  "Bonker x-coord corresponding to char boundary."
			bonkForm fill: (0 @ 0 corner: (bc+1) @ font ascent) fillColor: Color black.
			4 to: font ascent-1 by: 4 do:
				[:y | 		"Slide ascenders right..."
				g copy: (1@0 extent: g width @ (font ascent - y))
					from: 0@0 in: g rule: Form over.
				bonkForm copy: (1@0 extent: bonkForm width @ (font ascent - y))
					from: 0@0 in: bonkForm rule: Form over].
			bonkForm fill: (0 @ 0 corner: (bc+1) @ font ascent) fillColor: Color white.
			bonkForm fill: (bc @ font ascent corner: bonkForm extent) fillColor: Color black.
			font ascent to: font height-1 by: 4 do:
				[:y | 		"Slide descenders left..."
				g copy: (0@y extent: g width @ g height)
					from: 1@y in: g rule: Form over.
				bonkForm copy: (0@0 extent: bonkForm width @ bonkForm height)
					from: 1@0 in: bonkForm rule: Form over].
			bonkForm fill: (bc @ font ascent corner: bonkForm extent) fillColor: Color white.
			"Now use bonkForm to erase at every character boundary in glyphs."
			bonkForm offset: (0-bc) @ 0.
			font bonk: g with: bonkForm.
			font setGlyphs: g
		].
	].

]

{ #category : #emphasis }
StrikeFontSet >> makeStruckOutGlyphs [
	"Make a struck-out set of glyphs with same widths"

	| g font |
	1 to: fontArray size do: [:i |
		font := (fontArray at: i).
		font ifNotNil: [
			g := font glyphs deepCopy.
			g fillBlack: (0 @ (font ascent - (font ascent//3)) extent: g width @ 1).
			font setGlyphs: g
		].
	].

]

{ #category : #emphasis }
StrikeFontSet >> makeUnderlinedGlyphs [
	"Make an underlined set of glyphs with same widths"

	| g font |
	1 to: fontArray size do: [:i |
		font := (fontArray at: i).
		font ifNotNil: [
			g := font glyphs deepCopy.
			g fillBlack: (0 @ (font ascent+1) extent: g width @ 1).
			font setGlyphs: g
		].
	].

]

{ #category : #accessing }
StrikeFontSet >> maxAsciiFor: encoding [

	| f |
	f := (fontArray at: encoding+1).
	f ifNotNil: [^ f maxAscii].
	^ 0.

]

{ #category : #accessing }
StrikeFontSet >> maxEncoding [

	^ fontArray size.

]

{ #category : #accessing }
StrikeFontSet >> maxWidth [

	^ (fontArray at: 1) maxWidth.

]

{ #category : #testing }
StrikeFontSet >> name [

	^ name

]

{ #category : #accessing }
StrikeFontSet >> name: aString [

	name := aString

]

{ #category : #'objects from disk' }
StrikeFontSet >> objectForDataStream: refStrm [
	| dp |
	"I am about to be written on an object file.  Write a reference to a known Font in the other system instead.  "

	"A path to me"
	(TextConstants at: #forceFontWriting ifAbsent: [false]) ifTrue: [^ self].
		"special case for saving the default fonts on the disk.  See collectionFromFileNamed:"

	dp := DiskProxy global: #StrikeFontSet selector: #familyName:size:emphasized:
			args: (Array with: self familyName with: self pointSize
					with: self emphasis).
	refStrm replace: self with: dp.
	^ dp.

]

{ #category : #accessing }
StrikeFontSet >> pointSize [

	^ fontArray first pointSize.

]

{ #category : #copying }
StrikeFontSet >> postCopy [
	super postCopy.
	self reset.
	fontArray := fontArray collect: #copy

]

{ #category : #printing }
StrikeFontSet >> printOn: aStream [

	super printOn: aStream.
	aStream nextPutAll: '(' , self name.
	aStream space.
	self height printOn: aStream.
	aStream nextPut: $).

]

{ #category : #printing }
StrikeFontSet >> printShortDescriptionOn: aStream [
	super printShortDescriptionOn: aStream.
	aStream nextPutAll: '(FontSet)'
]

{ #category : #private }
StrikeFontSet >> questionGlyphInfoInto: glyphInfoArray [
"return glyph info for the question mark character in the first font of the fontArray -sort of a default set of info"
	| f ascii |
	f := fontArray at: 1.
	ascii := $? asciiValue.
	glyphInfoArray at: 1 put: f glyphs;
		at: 2 put: (f xTable at: ascii + 1);
		at: 3 put: (f xTable at: ascii + 2);
		at: 4 put: (self ascentOf: $?);
		at: 5 put: self.
	^ glyphInfoArray.

]

{ #category : #emphasis }
StrikeFontSet >> reset [
	"Reset the cache of derivative emphasized fonts"

	derivativeFonts := Array new: 32.

]

{ #category : #accessing }
StrikeFontSet >> subscript [

	^ fontArray first subscript

]

{ #category : #accessing }
StrikeFontSet >> superscript [

	^ fontArray first superscript

]

{ #category : #accessing }
StrikeFontSet >> textStyle [

	^ TextStyle actualTextStyles detect: [:aStyle | (aStyle fontArray collect: [:s | s name]) includes: self name]
		ifNone: [].

]

{ #category : #accessing }
StrikeFontSet >> widthOf: aCharacter [ 
	"Answer the width of the argument as a character in the receiver."
	^(self fontOf: aCharacter) widthOf: aCharacter
]

{ #category : #measuring }
StrikeFontSet >> widthOfString: aString [

	aString ifNil:[^0].
	"Optimizing"
	(aString isByteString) ifTrue: [
		^ self fontArray first widthOfString: aString from: 1 to: aString size].
	^ self widthOfString: aString from: 1 to: aString size.
"
	TextStyle default defaultFont widthOfString: 'zort' 21
"

]

{ #category : #accessing }
StrikeFontSet >> xTable [
	"Answer an Array of the left x-coordinate of characters in glyphs."

	^ fontArray first xTable.

]

{ #category : #accessing }
StrikeFontSet >> xTableEncoding: anInteger [
	"Answer an Array of the left x-coordinate of characters in glyphs."

	^(fontArray at: anInteger + 1) xTable.

]
