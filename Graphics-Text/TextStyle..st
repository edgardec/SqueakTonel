"
A textStyle comprises the formatting information for composing and displaying a unit (usually a paragraph) of text.  Typically one makes a copy of a master textStyle (such as TextStyle default), and then that copy may get altered in the process of editing.  Bad things can happen if you do not copy first.

Each of my instances consists of...
	fontArray		An array of StrikeFonts
	fontFamilySize	unused
	lineGrid			An integer; default line spacing for paragraphs
	baseline			An integer; default baseline (dist from line top to bottom of an 'a')
	alignment		An integer; text alignment, see TextStyle alignment:
	firstIndent		An integer; indent of first line in pixels
	restIndent		An integer; indent of remaining lines in pixels
	rightIndent		An integer; indent of right margin rel to section
	tabsArray		An array of integers giving tab offsets in pixels
	marginTabsArray	An array of margin tabs
	leading			An integer giving default vertical line separation

For a concrete example, look at TextStyle default copy inspect
"
Class {
	#name : #TextStyle,
	#superclass : #Object,
	#instVars : [
		'fontArray',
		'fontFamilySize',
		'lineGrid',
		'baseline',
		'alignment',
		'firstIndent',
		'restIndent',
		'rightIndent',
		'tabsArray',
		'marginTabsArray',
		'leading',
		'defaultFontIndex'
	],
	#pools : [
		'TextConstants'
	],
	#category : #'Graphics-Text'
}

{ #category : #'TextConstants access' }
TextStyle class >> actualTextStyles [
	| aDict |
	"TextStyle actualTextStyles"

	"Answer dictionary whose keys are the names of styles in the system and whose values are the actual styles"

	aDict := TextConstants select: [:thang | thang isKindOf: self ].
	self defaultFamilyNames do: [ :sym | aDict removeKey: sym ].
	^ aDict
]

{ #category : #'instance creation' }
TextStyle class >> changeDefaultFontSizeBy: delta [      "TextStyle changeDefaultFontSizeBy: 1"
	"This sample method recreates the default textStyle, with font 1 being a size
	larger than the smallest.  It then initializes most references in the system
	as well, although most windows will have to beclosed and reopened to get the effect."
	| allFonts |
	allFonts := TextStyle default fontArray sorted: [:a :b | a height < b height].
	TextConstants at: #DefaultTextStyle put:
		(TextStyle fontArray: ((1 to: allFonts size) collect: [:i | allFonts atWrap: i+delta])).
	#(ListParagraph PopUpMenu StandardSystemView) do:[:className|
		Smalltalk at: className ifPresent:[:aClass| aClass initialize].
	].
]

{ #category : #'mime file in\/out' }
TextStyle class >> collectionFromCompressedMIMEString: aString [
	"aString holds a compressed, Base64 representation of a SmartRefStream storage of a TextStyle.
	Install the TextStyle."

	| this newName style data |
	data := (Base64MimeConverter mimeDecode: aString as: String) unzipped.
	(RWBinaryOrTextStream with: data) reset; fileIn.
	this := SmartRefStream scannedObject.

	"now install it"

	newName := this fontArray first familyName.
	this fontArray do: [:aFont | aFont familyName = newName ifFalse: [
		self error: 'All must be same family']].
	style := TextConstants at: newName asSymbol ifAbsent: [
		^ TextConstants at: newName asSymbol put: this].		"new family"
	this fontArray do: [:aFont | | heights | "add new fonts"
		heights := style fontArray collect: [:bFont | bFont height].
		(heights includes: aFont height) ifFalse: [
			style fontAt: style fontArray size + 1 put: aFont]].

]

{ #category : #utilities }
TextStyle class >> decodeStyleName: styleName [ 
	"Given a string styleName, return a collection with: 
	 
	* [1] the probable Squeak emphasis code, which is a bit combination of: 
	1	bold 
	2	italic 
	4	underlined 
	8	narrow 
	16	strikeout 
	 
	* [2] the base style name without the modifiers (can be empty)
	* [3] the modifiers in the order they were found 
	* [4] the codes for those modifiers, in the same order
	"
	| decoder keys modifiers modifierCodes baseName styleCode matchedKey |

	decoder := self styleDecoder.

	modifiers := OrderedCollection new.
	modifierCodes := OrderedCollection new.
	keys := decoder keys asArray
				sort: [:a :b | a size > b size].
	styleCode := 0.
	baseName := styleName asString.
	[matchedKey := keys
				detect: [:k | baseName endsWith: k]
				ifNone: [].
	matchedKey notNil]
		whileTrue: [| last code | 
			last := baseName size - matchedKey size.
			last > 0
				ifTrue: [('- ' includes: (baseName at: last))
						ifTrue: [last := last - 1]].
			baseName := baseName copyFrom: 1 to: last.
			code := decoder at: matchedKey.
			styleCode := styleCode + code.
			modifiers addFirst: matchedKey.
			modifierCodes addFirst: code.
	].
	^ {styleCode. baseName. modifiers. modifierCodes }
]

{ #category : #constants }
TextStyle class >> default [
	"Answer the system default text style."

	^DefaultTextStyle
]

{ #category : #'TextConstants access' }
TextStyle class >> defaultFamilyNames [
	^#(DefaultTextStyle DefaultFixedTextStyle DefaultMultiStyle)
]

{ #category : #constants }
TextStyle class >> defaultFixed [

	^DefaultFixedTextStyle
]

{ #category : #constants }
TextStyle class >> defaultFixedFont [

	^ DefaultFixedTextStyle defaultFont
]

{ #category : #constants }
TextStyle class >> defaultFont [
	"Answer the default system font"

	^ DefaultTextStyle defaultFont
]

{ #category : #'instance creation' }
TextStyle class >> fontArray: anArray [ 
	"Answer an instance of me with fonts those in the argument, anArray."

	^self new newFontArray: anArray
]

{ #category : #'TextConstants access' }
TextStyle class >> fontArrayForStyle: aName [
	"Answer the fonts in the style named aName,
	or an empty Array if no such named style."

	"TextStyle fontArrayForStyle: #Atlanta"
	"TextStyle fontPointSizesFor: 'NewYork'"

	^ ((self named: aName) ifNil: [ ^#() ]) fontArray

]

{ #category : #'TextConstants access' }
TextStyle class >> fontPointSizesFor: aName [
	"Answer the point sizes for all the fonts in the given text style"

	"TextStyle fontPointSizesFor: 'Arial'"
	"TextStyle fontPointSizesFor: 'NewYork'"

	^ (self fontArrayForStyle: aName) collect: [:f | f pointSize]

]

{ #category : #utilities }
TextStyle class >> fontSizeSummary [
	"Open a text window with a simple summary of the available sizes in each of the fonts in the system."

	"TextStyle fontSizeSummary"

	(StringHolder new contents: self fontSizeSummaryContents)
		openLabel: 'Font styles and sizes' translated
]

{ #category : #utilities }
TextStyle class >> fontSizeSummaryContents [

	^ Text streamContents:
		[:aStream |
			self knownTextStyles do: [:aStyleName |
				aStream nextPutAll:
					(aStyleName  asText addAttribute: (TextFontReference toFont: (TextStyle named: aStyleName) defaultFont)), '  ',
					(self fontPointSizesFor: aStyleName) asArray storeString.
				aStream cr]].
]

{ #category : #'TextConstants access' }
TextStyle class >> fontSizesFor: aName [
	"Answer the pixel sizes for all the fonts in the given text style"

	"TextStyle fontSizesFor: 'Arial'"
	"TextStyle fontSizesFor: 'NewYork'"

	^ (self fontArrayForStyle: aName) collect: [:f | f height ]

]

{ #category : #'TextConstants access' }
TextStyle class >> fontWidthsFor: aName [
	"Answer the widths for all the fonts in the given text style"

	"TextStyle fontWidthsFor: 'ComicPlain'"
	^ (self fontArrayForStyle: aName) collect: [:f | f maxWidth]

]

{ #category : #'user interface' }
TextStyle class >> importFontsFromStyleFiles [
	"Import any and all of the fonts found in the default directory in files named ComicBold.style, ComicPlain.style, NewYork.style, Palatino.style, Courier.style"

	
	#('ComicBold' 'ComicPlain' 'NewYork' 'Palatino' 'Courier') do:
		[:frag | | aName |
			(TextStyle knownTextStyles includes: frag) ifFalse:
				[(FileDirectory default fileExists: (aName := frag, '.style'))
						ifTrue:
							[TextStyle default collectionFromFileNamed: aName]]].
]

{ #category : #'instance creation' }
TextStyle class >> initDefaultFontsAndStyle [
	"This provides the system with 10 and 12-pt basal fonts.
	Bold and italic versions will be automatically generated as needed"
	| fontArray |	
	fontArray := Array new: 2.
	fontArray at: 1 put: (StrikeFont new readFromStrike2: 'NewYork10.sf2').
	fontArray at: 2 put: (StrikeFont new readFromStrike2: 'NewYork12.sf2').
	TextConstants at: #DefaultTextStyle put:
		(TextStyle fontArray: fontArray).

	"TextStyle initDefaultFontsAndStyle."
]

{ #category : #'class initialization' }
TextStyle class >> initialize [
	self initializeStyleDecoder.
]

{ #category : #'class initialization' }
TextStyle class >> initializeStyleDecoder [
	TextConstants at: #StyleDecoder put: nil.
	self styleDecoder.
]

{ #category : #'TextConstants access' }
TextStyle class >> knownTextStyles [
	"Answer the names of the known text styles, sorted in alphabetical order"

	"TextStyle knownTextStyles"
	^ (TextConstants select: [:thang | thang isKindOf: TextStyle]) keys asArray sort


]

{ #category : #'TextConstants access' }
TextStyle class >> knownTextStylesWithoutDefault [
	"Answer the names of the known text styles, sorted in alphabetical order without default"

	"TextStyle knownTextStylesWithoutDefault"
	| result |
	result := self knownTextStyles asOrderedCollection.
	^ result copyWithoutAll: self defaultFamilyNames


]

{ #category : #'mime file in\/out' }
TextStyle class >> looseFontsFromFamily: familyName [
	"
	TextStyle looseFontsFromFamily: 'Accuny'
	TextStyle looseFontsFromFamily: 'Accujen'
	TextStyle actualTextStyles keys collect: [ :k | TextStyle looseFontsFromFamily: k ]
	"

	| looseFonts realStyle classes |
	realStyle := TextStyle named: familyName.
	classes := ((realStyle fontArray copyWithout: nil) collect: [ :f | f class ]) asSet.
	classes do: [ :cls | cls allSubInstancesDo: [ :f | f releaseCachedState ]].
	Smalltalk garbageCollect.
	looseFonts := IdentitySet new.
	classes do: [ :cls |
		looseFonts addAll: ((cls allSubInstances select: [ :ea | ea familyName = familyName ])
			reject: [ :f | realStyle fontArray anySatisfy: [ :fn | fn == f or: [ fn derivativeFonts includes: f ] ]]) ].
	^looseFonts
]

{ #category : #constants }
TextStyle class >> named: familyName [
	"Answer the TextStyle with the given name, or nil."
	"TextStyle named: 'NewYork'"
	| textStyle |
	textStyle := TextConstants at: familyName ifAbsent: [ ^nil ].
	(textStyle isKindOf: self) ifFalse: [ ^nil ].
	^textStyle
]

{ #category : #'instance creation' }
TextStyle class >> new [
	^ super new leading: 2
]

{ #category : #utilities }
TextStyle class >> pixelsPerInch [
	"Answer the nominal resolution of the screen."

	^TextConstants at: #pixelsPerInch ifAbsentPut: [ 96.0 ].
]

{ #category : #utilities }
TextStyle class >> pixelsPerInch: aNumber [
	"Set the nominal number of pixels per inch to aNumber."
	TextConstants at: #pixelsPerInch put: aNumber asFloat.
	AbstractFont allSubInstancesDo: [ :font | font pixelsPerInchChanged ].
	Display restore.
]

{ #category : #utilities }
TextStyle class >> pixelsToPoints: pixels [
	^pixels * 72.0 / self pixelsPerInch
]

{ #category : #'TextConstants access' }
TextStyle class >> pointSizesFor: aName [
	"Answer all the point sizes for the given text style name"

	"TextStyle pointSizesFor: 'NewYork'"
	^ (self fontArrayForStyle: aName) collect: [:f | f pointSize]

]

{ #category : #utilities }
TextStyle class >> pointsToPixels: points [
	^points * self pixelsPerInch / 72.0
]

{ #category : #'mime file in\/out' }
TextStyle class >> replaceFontsIn: oldFontArray with: newStyle [
	"
	TextStyle replaceFontsIn: (TextStyle looseFontsFromFamily: #Accuny) with: (TextStyle named: #Accuny)
	"
	"Try to find corresponding fonts in newStyle and substitute them for the fonts in oldFontArray"

	newStyle fontArray do: [ :newFont | newFont releaseCachedState ].

	oldFontArray do: [ :oldFont | | newFont |
		oldFont reset.
		newFont := (newStyle fontOfPointSize: oldFont pointSize) emphasis: oldFont emphasis.
		oldFont becomeForward: newFont ].

	Smalltalk at: #StringMorph ifPresent:[:cls| cls allSubInstancesDo: [ :s | s layoutChanged]].
	Smalltalk at: #TextMorph ifPresent:[:cls| cls allSubInstancesDo: [ :s | s layoutChanged]].
	Smalltalk at: #SystemWindow ifPresent:[:cls| 
		cls allInstancesDo: [ :w | [ w update: #relabel ] on: Error do: [ :ex | ] ]].
	Project current world ifNotNil: [ :w | w changed ].
]

{ #category : #'mime file in\/out' }
TextStyle class >> replaceStyle: oldStyle with: newStyle [
	"
	TextStyle replaceStyle: (TextStyle named: #AccunyOLD) with: (TextStyle named: #Accuny)
	"
	"Try to find corresponding fonts in newStyle and substitute the fonts in oldStyle for them."
	| oldKeys |
	oldKeys := Set new.
	TextConstants keysAndValuesDo: [ :k :v | v = oldStyle ifTrue: [ oldKeys add: k ]].
	oldKeys removeAllFoundIn: self defaultFamilyNames.

	self replaceFontsIn: oldStyle fontArray with: newStyle.

	oldStyle becomeForward: newStyle.
	oldKeys do: [ :k | TextConstants removeKey: k ].

]

{ #category : #constants }
TextStyle class >> setDefault: aTextStyle [
	"Answer the system default text style."

	DefaultTextStyle := aTextStyle.
]

{ #category : #constants }
TextStyle class >> setDefaultFixed: aTextStyle [

	DefaultFixedTextStyle := aTextStyle.
]

{ #category : #'class initialization' }
TextStyle class >> styleDecoder [
	TextConstants at: #StyleDecoder ifPresent: [ :dict | dict ifNotNil: [ ^dict ]].
	^TextConstants at: #StyleDecoder put: (
		Dictionary new at: 'Regular' put: 0;
				 at: 'Roman' put: 0;
				 at: 'Medium' put: 0;
				 at: 'Light' put: 0;
				 at: 'Normal' put: 0;
				 at: 'Plain' put: 0;
				 at: 'Book' put: 0;
				 at: 'Demi' put: 0;
				 at: 'Demibold' put: 0;
				 at: 'Semibold' put: 0;
				 at: 'SemiBold' put: 0;
				 at: 'ExtraBold' put: 1;
				 at: 'SuperBold' put: 1;
				 at: 'Negreta' put: 1;
				 at: 'B' put: 1;
				 at: 'I' put: 2;
				 at: 'U' put: 4;
				 at: 'X' put: 16;
				 at: 'N' put: 8;
				 at: 'Bold' put: 1;
				 at: 'Italic' put: 2;
				 at: 'Oblique' put: 2;
				 at: 'Narrow' put: 8;
				 at: 'Condensed' put: 8;
				 at: 'Underlined' put: 4;
				 yourself )
]

{ #category : #comparing }
TextStyle >> = other [

	self species == other species ifFalse: [^ false].
	1 to: self class instSize do:
		[:i | (self instVarAt: i) == (other instVarAt: i) ifFalse: [^ false]].
	^ true
]

{ #category : #accessing }
TextStyle >> alignment [
	"Answer the code for the current setting of the alignment."

	^alignment
]

{ #category : #accessing }
TextStyle >> alignment: anInteger [ 
	"Set the current setting of the alignment to be anInteger:
	0=left flush, 1=right flush, 2=centered, 3=justified."

	alignment := anInteger \\ (Justified + 1)
]

{ #category : #accessing }
TextStyle >> alignmentSymbol [
	"Answer the symbol for the current setting of the alignment."
	alignment = LeftFlush ifTrue:[^#leftFlush].
	alignment = Centered ifTrue:[^#centered].
	alignment = RightFlush ifTrue:[^#rightFlush].
	alignment = Justified ifTrue:[^#justified].
	^#leftFlush
]

{ #category : #converting }
TextStyle >> asStringOrText [
	"be fancy"
	^ self defaultFont familyName asText
		addAttribute: (TextFontReference toFont: self defaultFont);
		yourself
]

{ #category : #accessing }
TextStyle >> baseline [
	"Answer the distance from the top of the line to the bottom of most of the 
	characters (by convention, bottom of the letter 'A')."

	^baseline
]

{ #category : #accessing }
TextStyle >> baseline: anInteger [ 
	"Set the distance from the top of the line to the bottom of most of the 
	characters."

	baseline := anInteger
]

{ #category : #accessing }
TextStyle >> centered [
	alignment := 2
]

{ #category : #'tabs and margins' }
TextStyle >> clearIndents [
	"Reset all the margin (index) settings to be 0."

	self firstIndent: 0.
	self restIndent: 0.
	self rightIndent: 0
]

{ #category : #'fonts and font indexes' }
TextStyle >> collectionFromFileNamed: fileName [
	"Read the file.  It is an TextStyle whose StrikeFonts are to be added to the system.  (Written by fooling SmartRefStream, so it won't write a DiskProxy!)  These fonts will be added to the master TextSytle for this font family.  
	To write out fonts: 
		| ff | ff := ReferenceStream fileNamed: 'new fonts'.
		TextConstants at: #forceFontWriting put: true.
		ff nextPut: (TextConstants at: #AFontName).
			'do not mix font families in the TextStyle written out'.
		TextConstants at: #forceFontWriting put: false.
		ff close.

	To read: (TextStyle default collectionFromFileNamed: 'new fonts')
*** Do not remove this method *** "

	| ff this newName style |
	ff := ReferenceStream fileNamed: fileName.
	this := ff nextAndClose.	"Only works if file created by special code above"
	newName := this fontArray first familyName.
	this fontArray do: [:aFont | aFont familyName = newName ifFalse: [
		self error: 'All must be same family']].
	style := TextConstants at: newName asSymbol ifAbsent: [
		^ TextConstants at: newName asSymbol put: this].		"new family"
	this fontArray do: [:aFont | | heights | "add new fonts"
		heights := style fontArray collect: [:bFont | bFont height].
		(heights includes: aFont height) ifFalse: [
			style fontAt: style fontArray size + 1 put: aFont]].

]

{ #category : #'mime file in\/out' }
TextStyle >> compressedMIMEEncoded [
	"Answer a String with my compressed, stored representation as Base64"

	| s ff |
	self fontArray do: [:f | f releaseCachedState].
	s := RWBinaryOrTextStream on: ''.
	ff := SmartRefStream on: s reset.
	TextConstants at: #forceFontWriting put: true.
	[ff nextPut: self] 
		ensure: [TextConstants at: #forceFontWriting put: false].
	^s contents asByteArray zipped base64Encoded
]

{ #category : #'fonts and font indexes' }
TextStyle >> consistOnlyOf: aFont [
	fontArray := Array with: aFont.
	defaultFontIndex := 1
]

{ #category : #private }
TextStyle >> consolidate [
	"If this style includes any fonts that are also in the default style,
	then replace them with references to the default ones."
"
	TextStyle allInstancesDo: [:s | s == TextStyle default ifFalse: [s consolidate]]
"
	| defFonts font |
	defFonts := TextStyle default fontArray.
	1 to: fontArray size do:
		[:i | font := fontArray at: i.
		1 to: defFonts size do:
			[:j | (font name asUppercase copyWithout: $ )
			= ((defFonts at: j) name asUppercase copyWithout: $ )
			ifTrue: [fontArray at: i put: (defFonts at: j)]]]
]

{ #category : #accessing }
TextStyle >> defaultFont [
	^ fontArray at: self defaultFontIndex
]

{ #category : #'default font' }
TextStyle >> defaultFontIndex [
	^ defaultFontIndex ifNil: [defaultFontIndex := 1]
]

{ #category : #'default font' }
TextStyle >> defaultFontIndex: anIndex [
	defaultFontIndex := anIndex
]

{ #category : #accessing }
TextStyle >> firstIndent [
	"Answer the horizontal indenting of the first line of a paragraph in the 
	style of the receiver."

	^firstIndent
]

{ #category : #accessing }
TextStyle >> firstIndent: anInteger [ 
	"Set the horizontal indenting of the first line of a paragraph in the style 
	of the receiver to be the argument, anInteger."

	firstIndent := anInteger
]

{ #category : #'fonts and font indexes' }
TextStyle >> flushFonts [
	"Clean out the fonts, an aid when snapshotting claims too many are 
	holding onto Display."

	(self confirm: 
'flushFonts is very dangerous.
Are you foolish or clever enough to proceed?')
		ifTrue: [1 to: fontArray size do: [:index | fontArray at: index put: nil]]
		ifFalse: [Transcript cr; show: 'flushFonts cancelled']

	"TextStyle default flushFonts"
]

{ #category : #private }
TextStyle >> fontArray [
	"Only for writing out fonts, etc.  8/16/96 tk"
	^ fontArray
]

{ #category : #private }
TextStyle >> fontAt: index [ 
	"This is private because no object outside TextStyle should depend on the 
	representation of the font family in fontArray."

	^ fontArray atPin: index
]

{ #category : #private }
TextStyle >> fontAt: index put: font [
	"Automatically grow the array.  8/20/96 tk"
	index > fontArray size ifTrue: [
		fontArray := fontArray, (Array new: index - fontArray size)].
	fontArray at: index put: font
]

{ #category : #'fonts and font indexes' }
TextStyle >> fontIndexOf: aFont [
	^ fontArray indexOf: aFont ifAbsent: [nil]
]

{ #category : #'fonts and font indexes' }
TextStyle >> fontIndexOfPointSize: desiredPointSize [
	"Returns an index in fontArray of the font with pointSize <= desiredPointSize"
	"Leading is not inluded in the comparison"
	| bestMatch bestIndex d |
	bestMatch := 9999.  bestIndex := 1.
	1 to: fontArray size do:
		[:i | d := desiredPointSize - (fontArray at: i) pointSize.
		d = 0 ifTrue: [^ i].
		(d > 0 and: [d < bestMatch]) ifTrue: [bestIndex := i. bestMatch := d]].
	^ bestIndex
]

{ #category : #'fonts and font indexes' }
TextStyle >> fontIndexOfSize: desiredHeight [
	"Returns an index in fontArray of the font with height <= desiredHeight"
	"Leading is not inluded in the comparison"
	| bestMatch bestIndex d |
	bestMatch := 9999.  bestIndex := 1.
	1 to: fontArray size do:
		[:i | d := desiredHeight - (fontArray at: i) height.
		d = 0 ifTrue: [^ i].
		(d > 0 and: [d < bestMatch]) ifTrue: [bestIndex := i. bestMatch := d]].
	^ bestIndex
]

{ #category : #accessing }
TextStyle >> fontNamed: fontName [  "TextStyle default fontNamed: 'TimesRoman10'"
	^ fontArray detect: [:x | x name sameAs: fontName]
]

{ #category : #accessing }
TextStyle >> fontNames [  "TextStyle default fontNames"
	^ fontArray collect: [:x | x name]
]

{ #category : #accessing }
TextStyle >> fontNamesAndSizes [  "TextStyle default fontNames"
	^ fontArray collect: [:x | x name, ' ', x height printString]
]

{ #category : #accessing }
TextStyle >> fontNamesWithPointSizes [
	^ fontArray collect:
		[:x | x fontNameWithPointSize]

  "TextStyle default fontNamesWithPointSizes"
]

{ #category : #'fonts and font indexes' }
TextStyle >> fontOfPointSize: aPointSize [
	^ fontArray at: (self fontIndexOfPointSize: aPointSize)
]

{ #category : #'fonts and font indexes' }
TextStyle >> fontOfSize: aHeight [
	"See fontIndexOfSize.
	Returns the actual font.  Leading not considered."

	^ fontArray at: (self fontIndexOfSize: aHeight)
]

{ #category : #accessing }
TextStyle >> fonts [
	"Return a collection of fonts contained in this text style"
	^fontArray
]

{ #category : #private }
TextStyle >> gridForFont: fontIndex withLead: leadInteger [ 
	"Force whole style to suit one of its fonts. Assumes only one font referred
	to by runs."
	| font |
	font := self fontAt: fontIndex.
	self lineGrid: font height + leadInteger.
	self baseline: font ascent.
	self leading: leadInteger
]

{ #category : #comparing }
TextStyle >> hash [
	"#hash is re-implemented because #= is re-implemented"
	^fontArray hash

]

{ #category : #accessing }
TextStyle >> isTTCStyle [

	^ fontArray first isTTCFont.

]

{ #category : #accessing }
TextStyle >> justified [
	alignment := 3
]

{ #category : #accessing }
TextStyle >> leading [
	"Leading (from typographers historical use of extra lead (type metal))
	is the extra spacing above and beyond that needed just to accomodate
	the various font heights in the set."
	^ leading
]

{ #category : #accessing }
TextStyle >> leading: yDelta [

	leading := yDelta
]

{ #category : #accessing }
TextStyle >> leftFlush [
	alignment := 0
]

{ #category : #'tabs and margins' }
TextStyle >> leftMarginTabAt: marginIndex [ 
	"Set the 'nesting' level of left margin indents of the paragraph in the 
	style of the receiver to be the argument, marginIndex."

	(marginIndex > 0 and: [marginIndex < marginTabsArray size])
		ifTrue: [^(marginTabsArray at: marginIndex) at: 1]
		ifFalse: [^0]	
	"The marginTabsArray is an Array of tuples.  The Array is indexed according 
	to the marginIndex, the 'nesting' level of the requestor."

]

{ #category : #accessing }
TextStyle >> lineGrid [
	"Answer the relative space between lines of a paragraph in the style of 
	the receiver."

	^lineGrid
]

{ #category : #accessing }
TextStyle >> lineGrid: anInteger [ 
	"Set the relative space between lines of a paragraph in the style of the 
	receiver to be the argument, anInteger."

	lineGrid := anInteger
]

{ #category : #'make arrows' }
TextStyle >> makeArrows [
"
TextStyle default makeArrows.
"
	fontArray do: [ :font |
		(font isKindOf: StrikeFont) ifTrue:[ 
			font 
				makeAssignArrow; 
				makeReturnArrow.
		]
	].

]

{ #category : #private }
TextStyle >> marginTabAt: marginIndex side: sideIndex [ 
	"The marginTabsArray is an Array of tuples.  The Array is indexed
	according to the marginIndex, the 'nesting' level of the requestor.
	sideIndex is 1 for left, 2 for right."

	(marginIndex > 0 and: [marginIndex < marginTabsArray size])
		ifTrue: [^(marginTabsArray at: marginIndex) at: sideIndex]
		ifFalse: [^0]
]

{ #category : #accessing }
TextStyle >> maxDepth [

	^ (self fonts collect: [:font | font depth]) max
]

{ #category : #private }
TextStyle >> newFontArray: anArray [
	"Currently there is no supporting protocol for changing these arrays. If an editor wishes to implement margin setting, then a copy of the default should be stored with these instance variables.  
	, Make size depend on first font."

	fontArray := anArray.
	lineGrid := (fontArray at: 1) height + leading.	"For whole family"
	baseline := (fontArray at: 1) ascent + leading.
	alignment := 0.
	firstIndent := 0.
	restIndent := 0.
	rightIndent := 0.
	tabsArray := DefaultTabsArray.
	marginTabsArray := DefaultMarginTabsArray
"
TextStyle allInstancesDo: [:ts | ts newFontArray: TextStyle default fontArray].
"
]

{ #category : #'tabs and margins' }
TextStyle >> nextTabXFrom: anX leftMargin: leftMargin rightMargin: rightMargin [ 
	"Tab stops are distances from the left margin. Set the distance into the 
	argument, anX, normalized for the paragraph's left margin."

	| normalizedX tabX |
	normalizedX := anX - leftMargin.
	1 to: tabsArray size do: 
		[:i | (tabX := tabsArray at: i) > normalizedX 
				ifTrue: [^leftMargin + tabX min: rightMargin]].
	^rightMargin
]

{ #category : #accessing }
TextStyle >> pointSizes [
	^ fontArray collect:
		[:x | x pointSize]

  "TextStyle default fontNamesWithPointSizes"
]

{ #category : #printing }
TextStyle >> printOn: aStream [

	super printOn: aStream.
	self defaultFont printShortDescriptionOn: aStream

]

{ #category : #accessing }
TextStyle >> restIndent [
	"Answer the indent for all but the first line of a paragraph in the style 
	of the receiver."

	^restIndent
]

{ #category : #accessing }
TextStyle >> restIndent: anInteger [ 
	"Set the indent for all but the first line of a paragraph in the style of the 
	receiver to be the argument, anInteger."

	restIndent := anInteger
]

{ #category : #accessing }
TextStyle >> rightFlush [
	alignment := 1
]

{ #category : #accessing }
TextStyle >> rightIndent [
	"Answer the right margin indent for the lines of a paragraph in the style 
	of the receiver."

	^rightIndent
]

{ #category : #accessing }
TextStyle >> rightIndent: anInteger [ 
	"Answer the right margin indent for the lines of a paragraph in the style 
	of the receiver to be the argument, anInteger."

	rightIndent := anInteger
]

{ #category : #'tabs and margins' }
TextStyle >> rightMarginTabAt: marginIndex [ 
	"Set the 'nesting' level of right margin indents of the paragraph in the 
	style of the receiver to be marginIndex."

	(marginIndex > 0 and: [marginIndex < marginTabsArray size])
		ifTrue: [^(marginTabsArray at: marginIndex) at: 2]
		ifFalse: [^0]
	"The marginTabsArray is an Array of tuples.  The Array is indexed according 
	to the marginIndex, the 'nesting' level of the requestor."

]

{ #category : #comparing }
TextStyle >> species [

	^TextStyle
]

{ #category : #'object from disk' }
TextStyle >> storeDataOn: aDataStream [
	"The shared arrays in tabsArray and marginTabsArray are the globals DefaultTabsArray and DefaultMarginTabsArray.  DiskProxies will be substituted for these in (Array objectForDataStream:)."

	^ super storeDataOn: aDataStream
]

{ #category : #'tabs and margins' }
TextStyle >> tabWidth [
	"Answer the width of a tab."

	^DefaultTab
]

{ #category : #copying }
TextStyle >> veryDeepCopyWith: deepCopier [
	"All inst vars are meant to be shared"

	self == #veryDeepCopyWith:.	"to satisfy checkVariables"
	^ deepCopier references at: self ifAbsentPut: [self shallowCopy].	"remember"
]
