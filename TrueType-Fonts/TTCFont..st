"
I represent a font that uses TrueType derived glyph.  Upon a request for glyph for a character through a call to #formOf: (or #widthOf:), I first search corresponding glyph in the cache.  If there is not, it creates a 32bit depth form with the glyph.

  The cache is weakly held.  The entries are zapped at full GC.

Structure:
 ttcDescription	TTFontDescription -- The Squeak data structure for a TrueType font data file.
 pointSize		Number -- Nominal Em size in points. Conversion to pixel sizes depends on the definition of TextStyle class>>pixelsPerInch.
 foregroundColor	Color -- So far, this font need to know the glyph color in cache.
 cache			WeakArray of <Color -> <Array(256) of glyph>>
 derivatives		Array -- stores the fonts in the same family but different emphasis.

"
Class {
	#name : #TTCFont,
	#superclass : #AbstractFont,
	#instVars : [
		'ttcDescription',
		'pointSize',
		'foregroundColor',
		'cache',
		'derivatives',
		'fallbackFont',
		'height',
		'ascent',
		'descent',
		'maxAscii',
		'colorToCacheMap'
	],
	#classVars : [
		'GlyphCacheData',
		'GlyphCacheIndex',
		'GlyphCacheReady',
		'GlyphCacheSize',
		'NamesToIndexes',
		'Registry',
		'Scale',
		'ShutdownList'
	],
	#category : #'TrueType-Fonts'
}

{ #category : #'objects from disk' }
TTCFont class >> classVersion [
	"Version 0 had pixelSize; version 1 changed it to pointSize"
	^1
]

{ #category : #'instance creation' }
TTCFont class >> family: f size: s [

	^ self allInstances detect: [:a | a familyName = f and: [a pointSize = s]] ifNone: [nil].

]

{ #category : #'instance creation' }
TTCFont class >> familyName: n pointSize: s emphasis: code [

	"(TTCFont familyName: 'BitstreamVeraSans' pointSize: 12 emphasis: 0)"
	| t ret index |
	t := self registry at: n asSymbol ifAbsent: [#()].
	t isEmpty ifTrue: [
		t := (TextConstants at: #DefaultTextStyle) fontArray.
		ret := t first.
		ret pointSize >= s ifTrue: [^ ret emphasis: code].
		index := 2.
		[index <= t size and: [(t at: index) pointSize <= s]] whileTrue: [
			ret := t at: index.
			index := index + 1.
		].
		^ ret emphasis: code.
	].
	^ ((TextStyle named: n) addNewFontSize: s) emphasis: code.

]

{ #category : #'file list services' }
TTCFont class >> fileReaderServicesForFile: fullName suffix: suffix [ 
	^(suffix = 'ttf')  | (suffix = '*') 
		ifTrue: [ self services ]
		ifFalse: [ #() ]
]

{ #category : #'instance creation' }
TTCFont class >> getExistings: fontArray [

	| result em |
	result := OrderedCollection new.
	result add: fontArray.
	1 to: 3 do: [:i |
		em := (fontArray collect: [:f | f emphasized: i]).
		(em at: 1) ~= (fontArray at: 1) ifTrue: [
			result add: em.
		].
	].
	^ result asArray.

]

{ #category : #other }
TTCFont class >> indexOfSubfamilyName: aName [
	| decoded |

	"decodeStyleName will consume all the modifiers and leave nothing if everything was recognized."
	decoded := TextStyle decodeStyleName: aName.
	decoded second isEmpty ifTrue: [ ^decoded first ].

	"If you get a halt here - please add the missing synonym to the lookup table in TextStyle>>decodeStyleName: ."
	
	self error: 'please add the missing synonym ', aName, ' to the lookup table in TextStyle>>decodeStyleName:'.

	^0.
]

{ #category : #'class initialization' }
TTCFont class >> initialize [
"
	self initialize
"

	| tt |
	self allSubInstancesDo:[:fnt| fnt flushCache].
	GlyphCacheSize := 512.
	GlyphCacheData := Array new: GlyphCacheSize.
	GlyphCacheIndex := 0.
	GlyphCacheReady := true.
	
	tt := TTFontDescription default.
	tt ifNotNil: [self newTextStyleFromTT: tt].
	FileServices registerFileReader: self.

	Smalltalk addToShutDownList: self.
]

{ #category : #other }
TTCFont class >> isCacheAllNil [
"
	self cacheAllNil
"
	self allInstances do: [:inst |
		inst cache do: [:e |
			e ifNotNil: [^ false].
		].
	].

	^ true.

]

{ #category : #'instance creation' }
TTCFont class >> newTextStyleFromTT: description [ 
	"Create a new TextStyle from specified TTFontDescription instance."

	| array |
	array := self pointSizes collect: 
					[:pt | | f | 
					f := self new.
					f ttcDescription: description.
					f pointSize: pt].
	^self reorganizeForNewFontArray: array name: array first name asSymbol
]

{ #category : #'instance creation' }
TTCFont class >> newTextStyleFromTTFile: fileName [
	"Create a new TextStyle from specified file name.  On certain versions of Windows, you can evaluate following to get Arial font into the image.  On other platforms, wait and see someone implements the support code for FontPlugin then we can start relying on the generic font lookup mechanism.
	TTCFontReader encodingTag: 0.
	self newTextStyleFromTTFile: 'C:\WINDOWS\Fonts\symbol.TTF'.
	"

	| description |
	description := TTFontDescription addFromTTFile: fileName.
	^ self newTextStyleFromTT: description.

]

{ #category : #'instance creation' }
TTCFont class >> newTextStyleFromTTStream: readStream [
"
"

	| description |
	description := TTFontDescription addFromTTStream: readStream.
	^ self newTextStyleFromTT: description.

]

{ #category : #other }
TTCFont class >> pointSizes [

	"The default sizes that are created when a TextStyle is created.  You can add new sizes by the new-size feature."
	^ #(9 12 15 24 36).

]

{ #category : #other }
TTCFont class >> recreateCache [
"
	self recreateCache.
"
	self allSubInstances do: [:inst | inst flushCache].
	Smalltalk garbageCollect.

]

{ #category : #other }
TTCFont class >> register: anObject at: symbolName [

	self registry at: symbolName put: anObject.

]

{ #category : #other }
TTCFont class >> registerAll [
"
	TTCFont registerAll
"

	TextStyle allInstancesDo: [:e |
		(e fontArray first isMemberOf: TTCFont) ifTrue: [
			self register: e fontArray at: e fontArray first familyName asSymbol.
		].
	].

]

{ #category : #other }
TTCFont class >> registry [
	^ Registry
		ifNil: [Registry := IdentityDictionary new]

]

{ #category : #other }
TTCFont class >> removeAllDerivatives [
"
	self removeAllDerivatives
"

	self allInstances do: [:s |
		s textStyle ifNotNil: [
			s textStyle fontArray do: [:f |
				f derivativeFont: nil at: 0.
			].
		].
	].

]

{ #category : #other }
TTCFont class >> removeStyleName: aString [

	TextConstants removeKey: aString asSymbol ifAbsent: [].
	TTFontDescription removeDescriptionNamed: aString asString.

]

{ #category : #'instance creation' }
TTCFont class >> reorganizeForNewFontArray: array name: styleName [

	| style existings regular altName |
	(TextConstants includesKey: styleName) ifFalse: [
		TextConstants at: styleName put: (TextStyle fontArray: array).
		^ TextConstants at: styleName.
	].
 
	"There is a text style with the name I want to use.  See if it is a TTC font..."
	style := TextConstants at: styleName.
	style isTTCStyle ifFalse: [
		altName := ((array at: 1) name, 'TT') asSymbol.
		^ self reorganizeForNewFontArray: array name: altName.
	].

	existings := (self getExistings: style fontArray), (Array with: array).
	regular := existings detect: [:e | (e at: 1) isRegular] ifNone: [existings at: 1].

	regular do: [:r |
		r addLined: r.
	].

	"The existing array may be different in size than the new one."
	existings do: [:e |
		(e at: 1) isRegular ifFalse: [
			regular do: [ :r | | f |
				f := e detect: [ :ea | ea pointSize = r pointSize ] ifNone: [ ].
				f ifNotNil: [ r derivativeFont: f ].
			].
		].
	].

	style newFontArray: regular.
	self register: regular at: styleName.
	self recreateCache.	
	^ style.

]

{ #category : #other }
TTCFont class >> repairDerivativeFonts [
	"Fix the cases where the derivatives are a different size than the originals."

	"
	TTCFont repairDerivativeFonts.
	"
	self allInstancesDo: [ :font | font pointSize: font pointSize ].
	Preferences refreshFontSettings.
]

{ #category : #'file list services' }
TTCFont class >> serviceInstallTrueTypeFontStyle [
	"Return a service to install a true type font as a text style"

	^ SimpleServiceEntry
		provider: self
		label: 'install ttf style'
		selector: #newTextStyleFromTTFile: 
		description: 'install a true type font as a text style'
		buttonLabel: 'install ttf'
]

{ #category : #'file list services' }
TTCFont class >> services [
	"Return a set of services for use in FileList"

	^ Array with: self serviceInstallTrueTypeFontStyle
]

{ #category : #'class initialization' }
TTCFont class >> shutDown [
	"Flush the glyph cache"
	GlyphCacheData atAllPut: nil.
	GlyphCacheIndex := 0.
	ShutdownList ifNotNil:[ShutdownList do:[:fnt| fnt flushCache]].
	ShutdownList := WeakSet new.

]

{ #category : #'class initialization' }
TTCFont class >> unload [

	FileServices unregisterFileReader: self
]

{ #category : #other }
TTCFont class >> unregister: symbolName [

	self registry removeKey: symbolName ifAbsent: [].

]

{ #category : #other }
TTCFont class >> version [

	^ '6.0'.

]

{ #category : #private }
TTCFont >> addLined [

	self addLined: self.
	self derivativeFonts do: [:e |
		e ifNotNil: [self addLined: e].
	].

]

{ #category : #private }
TTCFont >> addLined: aTTCFont [

	| l |
	l := LinedTTCFont fromTTCFont: aTTCFont emphasis: 4.
	self derivativeFont: l at: l emphasis.

	l := LinedTTCFont fromTTCFont: aTTCFont emphasis: 16.
	self derivativeFont: l at: l emphasis.

	l := LinedTTCFont fromTTCFont: aTTCFont emphasis: 20.
	self derivativeFont: l at: l emphasis.

]

{ #category : #accessing }
TTCFont >> ascent [
	^ascent ifNil:[ascent := (ttcDescription typographicAscender * self pixelScale) truncated].
]

{ #category : #accessing }
TTCFont >> ascentOf: aCharacter [

"	(self hasGlyphFor: aCharacter) ifFalse: [
		fallbackFont ifNotNil: [
			^ fallbackFont ascentOf: aCharacter.
		].
	].
"
	^ self ascent.

]

{ #category : #private }
TTCFont >> at: char put: form [
	| assoc |
	assoc := foregroundColor -> form.
	GlyphCacheData at: (GlyphCacheIndex := GlyphCacheIndex \\ GlyphCacheSize + 1) put: assoc.
	cache at: (char asInteger + 1) put: assoc.
	^form
]

{ #category : #private }
TTCFont >> basicHasGlyphOf: aCharacter [
	"Answer whether this font includes a glyph for the given character"
	^ aCharacter charCode <= self maxAscii
		and:[
			aCharacter = Character null
				ifTrue: [(self formOf: aCharacter) notNil]
				ifFalse: [
					"this should also be
						 (self formOf: aCharacter) notNil
					but it does not work, the fallback glyph -- if present -- is always found instead.
					So we fake. if aCharacter is the same form as Character null aka 0, we assume absence."
					(self characterFormAt: aCharacter) bits ~= self fallbackForm bits]]
]

{ #category : #friend }
TTCFont >> cache [
	^cache
]

{ #category : #'character shapes' }
TTCFont >> characterFormAt: character [ 
	"Answer a Form copied out of the glyphs for the argument,  
	character. Use a cached copy if possible."

	^self formOf: character
]

{ #category : #html }
TTCFont >> closeHtmlOn: aStream [ 
	"put on the given stream the tag to close the html  
	representation of the receiver"
	self htmlSize isZero
		ifFalse: [aStream nextPutAll: '</font>']
]

{ #category : #private }
TTCFont >> computeForm: char [
	"Compute the glyph form for the given character"
	^ttcDescription renderGlyph: char height: self height fgColor: foregroundColor bgColor: Color transparent depth: self depth
]

{ #category : #'objects from disk' }
TTCFont >> convertToCurrentVersion: varDict refStream: smartRefStrm [
	"If we're reading in an old version with a pixelSize instance variable, convert it to a point size."

	"Deal with the change from pixelSize to pointSize, assuming the current monitor dpi."
	varDict at: 'pixelSize' ifPresent: [ :x | 
		pointSize := (TextStyle pixelsToPoints: x) rounded.
	].
	self releaseCachedState.
	^super convertToCurrentVersion: varDict refStream: smartRefStrm.
]

{ #category : #copying }
TTCFont >> copy [

	^ self.

]

{ #category : #copying }
TTCFont >> deepCopy [

	^ self.

]

{ #category : #public }
TTCFont >> depth [

	^ 32.

]

{ #category : #friend }
TTCFont >> derivativeFont: aTTCFont [

	| index |
	index := self indexOfSubfamilyName: (aTTCFont subfamilyName).
	index < 1 ifTrue: [
		^ self "inform: 'unknown sub family name.  This font will be skipped'".
	].

	self derivativeFont: aTTCFont at: index.

	self addLined: aTTCFont.

]

{ #category : #friend }
TTCFont >> derivativeFont: aTTCFont at: index [

	| newDeriv |
	aTTCFont ifNil: [derivatives := nil. ^ self].
	derivatives ifNil: [derivatives := Array new: 32].
	derivatives size < 32 ifTrue: [
		newDeriv := Array new: 32.
		newDeriv replaceFrom: 1 to: derivatives size with: derivatives.
		derivatives := newDeriv.
	].
	derivatives at: index put: aTTCFont.

]

{ #category : #initialize }
TTCFont >> derivativeFont: aNewlyCreatedDerivativeFont mainFont: aMainFont [

	self derivativeFont: aNewlyCreatedDerivativeFont at: aMainFont emphasis.
	aNewlyCreatedDerivativeFont emphasis: aMainFont emphasis.
	aNewlyCreatedDerivativeFont lineGlyph: (aMainFont ttcDescription at: $_).
]

{ #category : #friend }
TTCFont >> derivativeFontArray [

	^ derivatives.

]

{ #category : #friend }
TTCFont >> derivativeFonts [

	derivatives ifNil: [^ #()].
	^derivatives copyWithout: nil
]

{ #category : #accessing }
TTCFont >> descent [
	"One is added to make sure the gap between lines is filled.  If we don't add, multi line selection in a text pane look ugly."
	^descent ifNil:[descent := self height - self ascent].

]

{ #category : #accessing }
TTCFont >> descentKern [

	^ 0.

]

{ #category : #accessing }
TTCFont >> descentOf: aCharacter [

"	(self hasGlyphFor: aCharacter) ifFalse: [
		fallbackFont ifNotNil: [
			^ fallbackFont descentOf: aCharacter.
		].
	]."
	^ self descent.

]

{ #category : #friend }
TTCFont >> displayString: aString on: aBitBlt from: startIndex to: stopIndex at: aPoint kern: kernDelta [ 

	^ self displayString: aString on: aBitBlt from: startIndex to: stopIndex at: aPoint kern: kernDelta baselineY: aPoint y + self ascent.

]

{ #category : #friend }
TTCFont >> displayString: aString on: aBitBlt from: startIndex to: stopIndex at: aPoint kern: kernDelta baselineY: baselineY [

	| form glyphInfo destX destY hereX nextX actualFont |
	destX := aPoint x.
	glyphInfo := Array new: 5.
	startIndex to: stopIndex do: [:charIndex |
		self glyphInfoOf: (aString at: charIndex) into: glyphInfo.
		form := glyphInfo at: 1.
		hereX := glyphInfo at: 2.
		nextX := glyphInfo at: 3.
		(actualFont := glyphInfo at: 5) ==  aBitBlt lastFont
			ifFalse: [actualFont installOn: aBitBlt].
		destY := baselineY - (glyphInfo at: 4). 
		aBitBlt sourceForm: form.
		aBitBlt destX: destX.
		aBitBlt destY: destY.
		aBitBlt sourceX: hereX; sourceY: 0.
		aBitBlt width: nextX - hereX.
		aBitBlt height: form height.
		aBitBlt copyBits.
		destX := destX + (nextX - hereX) + kernDelta.
	].
	^ destX @ destY

]

{ #category : #accessing }
TTCFont >> emphasis [
	"Answer the emphasis code (0 to 3) corresponding to my subfamily name"
	^self indexOfSubfamilyName: self subfamilyName


]

{ #category : #accessing }
TTCFont >> emphasis: code [

	code > 3 ifTrue: [^ self].
	code = 0 ifTrue: [^ self].
	derivatives ifNil: [^ self].
	^ (derivatives at: code) ifNil: [self].

]

{ #category : #accessing }
TTCFont >> emphasized: code [

	code = 0 ifTrue: [^ self].
	derivatives ifNil: [^ self].
	(((code bitAnd: 20) ~= 0) and: [
		derivatives size < code or: [(derivatives at: code) isNil]]) ifTrue: [
		self addLined.
	].
	^ (derivatives at: code) ifNil: [self].

]

{ #category : #accessing }
TTCFont >> fallbackFont [
	"Answers the fallbackFont for the receiver. The fallback font must be some derivative of the receiver since it will not be asked to install itself properly on the target BitBlt so rendering a completely different font here is simply not possible. The default implementation uses a synthetic font that maps all characters to question marks."
	^ fallbackFont
		ifNil: [fallbackFont := FixedFaceFont new errorFont baseFont: self]
]

{ #category : #accessing }
TTCFont >> fallbackFont: aFontSetOrNil [

	aFontSetOrNil == self
		ifTrue:[^ self error: 'Invalid fallback font'].

	fallbackFont := aFontSetOrNil.

]

{ #category : #private }
TTCFont >> fallbackForm [
	"Compute the glyph form for the fallback glyph"
	^ttcDescription renderFallbackGlyphOfHeight: self height fgColor: foregroundColor bgColor: Color transparent depth: self depth
]

{ #category : #accessing }
TTCFont >> familyName [

	^ ttcDescription name.

]

{ #category : #accessing }
TTCFont >> familySizeFace [

	^ Array
		with: self familyName
		with: self height
		with: 0.

]

{ #category : #initialize }
TTCFont >> flushCache [
	"Flush the cache of this font"
	cache := foregroundColor := colorToCacheMap := nil.
	
	"Flush all values computed from ttcDescription and cached for speed"
	height := ascent := descent := nil.
]

{ #category : #accessing }
TTCFont >> fontNameWithPointSize [
	^ self name withoutTrailingDigits , ' ' , self pointSize printString
]

{ #category : #public }
TTCFont >> foregroundColor [

	^ foregroundColor.

]

{ #category : #initialize }
TTCFont >> foregroundColor: fgColor [
	"Install the given foreground color"
	foregroundColor = fgColor ifFalse:[
		foregroundColor := fgColor.
		colorToCacheMap ifNil:[colorToCacheMap := Dictionary new].
		cache := colorToCacheMap at: fgColor ifAbsentPut:[WeakArray new: self maxAscii+1].
		ShutdownList ifNotNil:[ShutdownList add: self].
	].

]

{ #category : #private }
TTCFont >> formOf: char [

	| code form |
	char charCode > self maxAscii
		ifTrue: [^ self fallbackFont formOf: char].

	cache ifNil:[self foregroundColor: Color black]. "make sure we have a cache"

	code := char charCode.
	form := cache at: (code + 1).
	form class == Association ifTrue:[^self computeForm: code]. "in midst of loading"
	form ifNil:[
		form := self computeForm: code.
		form ifNil:[^nil].
		cache at: code+1 put: form.
		GlyphCacheData at: (GlyphCacheIndex := GlyphCacheIndex \\ GlyphCacheSize + 1) put: form.
	].
	^form

]

{ #category : #private }
TTCFont >> glyphInfoOf: aCharacter into: glyphInfoArray [
	"return the glyph info for aCharacter; if I don't have such a character, try my fallback font"

	| form |
	(self hasGlyphOf: aCharacter) ifFalse: [
		^ self fallbackFont glyphInfoOf: aCharacter into: glyphInfoArray.
	].
	form := self formOf: aCharacter.
	glyphInfoArray at: 1 put: form;
		at: 2 put: 0;
		at: 3 put: form width;
		at: 4 put: ascent "(self ascentOf: aCharacter)";
		at: 5 put: self.
	^ glyphInfoArray.

]

{ #category : #private }
TTCFont >> hasGlyphOf: aCharacter [
	"Answer whether this font includes a glyph for the given character (or a fallback)"
	self flag: #topa. "formOf: never actually returns nil for ttcfonts..."
	^ aCharacter charCode <= self maxAscii
		and:[(self formOf: aCharacter) notNil]
]

{ #category : #accessing }
TTCFont >> height [
	"Answer my height in pixels. This will answer a Float."
	^height ifNil:[height := self pixelSize + self lineGap]
]

{ #category : #html }
TTCFont >> htmlSize [
"private - answer the size in html form, assumes 12 as default size"
	^ (self pointSize - 12 / 3) rounded
]

{ #category : #private }
TTCFont >> indexOfSubfamilyName: aName [
	
	^ self class indexOfSubfamilyName: aName
]

{ #category : #friend }
TTCFont >> initialize [

	foregroundColor := Color black.

]

{ #category : #initialize }
TTCFont >> initialize: aFont [

	self initialize.
	self ttcDescription: aFont ttcDescription.

]

{ #category : #friend }
TTCFont >> installOn: aDisplayContext [

	^aDisplayContext installTTCFont: self.

]

{ #category : #friend }
TTCFont >> installOn: aDisplayContext foregroundColor: fgColor backgroundColor: bgColor [
	self foregroundColor: fgColor. "install color"
	(self fallbackFont notNil and: [ self fallbackFont class = TTCFontSet ]) ifTrue: [
		self fallbackFont fontArray do: [:font |
			font ifNotNil: [ font foregroundColor: fgColor ]
		]
	].  "install color for fallbackFont"
	aDisplayContext installTTCFont: self foregroundColor: foregroundColor backgroundColor: bgColor

]

{ #category : #testing }
TTCFont >> isRegular [
	"Answer true if I am a Regular/Roman font (i.e. not bold, etc.)"
	^ (self indexOfSubfamilyName: (self subfamilyName)) = 0.

]

{ #category : #testing }
TTCFont >> isTTCFont [
	^true
]

{ #category : #accessing }
TTCFont >> lineGap [
	"Answer the line gap from the ttf description"
	^self pixelSize * ttcDescription typographicLineGap // ttcDescription typographicFontHeight
]

{ #category : #initialize }
TTCFont >> lineGlyph: ignore [
	^self
]

{ #category : #accessing }
TTCFont >> lineGrid [
	"Answer the relative space between lines"
	^ self ascent + self descent
]

{ #category : #accessing }
TTCFont >> maxAscii [
	"Answer the max. code point in this font. The name of this method is historical."
	^maxAscii ifNil:[ttcDescription size].
]

{ #category : #accessing }
TTCFont >> minAscii [
	"Answer the min. code point in this font. The name of this method is historical."
	^ 0.

]

{ #category : #accessing }
TTCFont >> name [

	^ ttcDescription name.

]

{ #category : #'objects from disk' }
TTCFont >> objectForDataStream: refStrm [
	| dp |
	"I am about to be written on an object file.  Write a
reference to a known FontSet in the other system instead."

	"a path to me"
	dp := DiskProxy global: #TTCFont selector: #familyName:pointSize:emphasis:
			args: {self familyName. self pointSize. self emphasis}.
	refStrm replace: self with: dp.
	^ dp.

]

{ #category : #html }
TTCFont >> openHtmlOn: aStream [ 
	"put on the given stream the tag to open the html  
	representation of the receiver"
	| size |
	size := self htmlSize.
	size isZero
		ifFalse: [aStream nextPutAll: '<font size="' , size asString , '">']
]

{ #category : #accessing }
TTCFont >> pixelScale [
	"Answer the scale factor to convert from the truetype's units into the receiver's pixel size. The scale for a font is computed by *excluding* the linegap (leading) in the font. Consequently, the height of the font (including linegap/leading) will be larger than the pixel size."
	^self pixelSize asFloat / 
		(ttcDescription typographicAscender - 
			ttcDescription typographicLineGap - 
			ttcDescription typographicDescender)
]

{ #category : #accessing }
TTCFont >> pixelSize [
	"Make sure that we don't return a Fraction"
	^(TextStyle pointsToPixels: pointSize) truncated
]

{ #category : #accessing }
TTCFont >> pixelSize: aNumber [
	"Make sure that we don't return a Fraction"
	self pointSize: (TextStyle pixelsToPoints: aNumber) rounded.

]

{ #category : #notifications }
TTCFont >> pixelsPerInchChanged [
	"The definition of TextStyle class>>pixelsPerInch has changed. Do whatever is necessary."
	self flushCache
]

{ #category : #accessing }
TTCFont >> pointSize [

	^ pointSize.

]

{ #category : #accessing }
TTCFont >> pointSize: aNumber [

	self privatePointSize: aNumber.
	derivatives ifNotNil: [ derivatives do: [ :f | f ifNotNil: [ f privatePointSize: aNumber ]]].

]

{ #category : #printing }
TTCFont >> printOn: aStream [
	aStream nextPutAll: 'TTCFont(';
		nextPutAll: self familyName; space;
		print: self pointSize; space;
		nextPutAll: self subfamilyName;
		nextPut: $)
]

{ #category : #accessing }
TTCFont >> privatePointSize: aNumber [ 
	pointSize = aNumber
		ifFalse: [pointSize := aNumber.
			self flushCache]
]

{ #category : #friend }
TTCFont >> recreateCache [

	cache := WeakArray new: 256.
]

{ #category : #caching }
TTCFont >> releaseCachedState [
	self flushCache.
]

{ #category : #caching }
TTCFont >> reset [

]

{ #category : #private }
TTCFont >> scale [

	^ self pixelSize / ttcDescription unitsPerEm

]

{ #category : #emphasis }
TTCFont >> setupDefaultFallbackFont [

	| fonts f |
	fonts := TextStyle default fontArray.
	f := fonts first.
	1 to: fonts size do: [:i |
		self height > (fonts at: i) height ifTrue: [f := fonts at: i].
	].
	(f == self)
		ifFalse:[ self fallbackFont: f ].
	self reset.

]

{ #category : #friend }
TTCFont >> setupDefaultFallbackFontTo: aTextStyleOrNil [
"
	TTCFont allInstances do: [:i | i setupDefaultFallbackFontTo: (TextStyle named: 'MultiMSMincho')].
"

	| fonts f |
	aTextStyleOrNil ifNil: [
		self fallbackFont: nil.
		^ self.
	].
	fonts := aTextStyleOrNil fontArray.
	(aTextStyleOrNil defaultFont familyName endsWith: self familyName) ifTrue: [fallbackFont := nil. ^ self].

	f := fonts first.
	1 to: fonts size do: [:i |
		self height >= (fonts at: i) height ifTrue: [f := fonts at: i].
	].
	self fallbackFont: f.
	self reset.


]

{ #category : #public }
TTCFont >> size [

	^ ttcDescription size.

]

{ #category : #private }
TTCFont >> subfamilyName [

	^ ttcDescription subfamilyName.

]

{ #category : #accessing }
TTCFont >> textStyle [

	| styles |
	styles := TextStyle actualTextStyles.
	
	^ (styles includesKey: self name)
		ifTrue: [styles at: self name]
		ifFalse: [
			"Fallback: Maybe this font is in a text style with another name?"
			styles
				detect: [:aStyle | aStyle fontArray anySatisfy: [:font | font name = self name]]
				ifNone: [nil]]
]

{ #category : #friend }
TTCFont >> ttcDescription [

	^ ttcDescription.

]

{ #category : #friend }
TTCFont >> ttcDescription: aTTCDescription [

	ttcDescription := aTTCDescription.
	self flushCache.

]

{ #category : #copying }
TTCFont >> veryDeepCopyWith: deepCopier [

	self flushCache.
	^ self.

]

{ #category : #public }
TTCFont >> widthOf: aCharacter [
	"This method cannot use #formOf: because formOf: discriminates the color and causes unnecessary bitmap creation."
	(self hasGlyphOf: aCharacter) ifFalse: [
		(fallbackFont notNil and: [fallbackFont hasGlyphOf: aCharacter]) ifTrue:
			[^ fallbackFont widthOf: aCharacter].
		^ 1
	].
	^(self formOf: aCharacter) width
]
