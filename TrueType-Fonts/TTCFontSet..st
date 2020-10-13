Class {
	#name : #TTCFontSet,
	#superclass : #AbstractFont,
	#instVars : [
		'name',
		'fontArray',
		'foregroundColor',
		'derivatives'
	],
	#category : #'TrueType-Fonts'
}

{ #category : #private }
TTCFontSet class >> discardDefault [
"
	self discardDefault
"
	| ttc |
	ttc := TTCFontDescription default.
	ttc ifNotNil: [
		TextConstants removeKey: ttc name asSymbol ifAbsent: [].
	].
]

{ #category : #'instance creation' }
TTCFontSet class >> familyName: n pointSize: s [

	"(self familyName: 'MSGothic' pointSize: 14) pointSize"
	| t ret index |
	t := self registry at: n asSymbol ifAbsent: [#()].
	t isEmpty ifTrue: [
		t := (TextConstants at: #DefaultTextStyle) fontArray.
		ret := t first.
		ret pointSize >= s ifTrue: [^ ret].
		index := 2.
		[index <= t size and: [(t at: index) pointSize <= s]] whileTrue: [
			ret := t at: index.
			index := index + 1.
		].
		^ ret.
	].
	^ (TextStyle named: n) addNewFontSize: s.
]

{ #category : #'instance creation' }
TTCFontSet class >> familyName: n pointSize: s emphasized: code [


	| t ret index |
	t := self registry at: n asSymbol ifAbsent: [#()].
	t isEmpty ifTrue: [
		t := (TextConstants at: #DefaultTextStyle) fontArray.
		ret := t first.
		ret pointSize >= s ifTrue: [^ ret].
		index := 2.
		[index <= t size and: [(t at: index) pointSize <= s]] whileTrue: [
			ret := t at: index.
			index := index + 1.
		].
		^ ret emphasis: code
	].
	^ ((TextStyle named: n) addNewFontSize: s) emphasis: code.
]

{ #category : #private }
TTCFontSet class >> getExistings: fontArray [

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

{ #category : #'class initialization' }
TTCFontSet class >> initialize [
"
	self initialize
"

	| tt |
	tt := TTCFontDescription default.
	tt ifNotNil: [self newTextStyleFromTT: {tt}].

]

{ #category : #private }
TTCFontSet class >> newFontArray: anArray [
 
	^super new initializeWithFontArray: anArray

]

{ #category : #'file out\/in' }
TTCFontSet class >> newTextStyleFromTT: descriptionArray [

	| array f arrayOfArray |

	arrayOfArray := self pointSizes collect: [:pt |
		descriptionArray collect: [:ttc |
			ttc ifNil: [nil] ifNotNil: [
				f := (ttc size > 256)
					ifTrue: [MultiTTCFont new]
					ifFalse: [TTCFont new].
				f ttcDescription: ttc.
				f pointSize: pt.
			].
		].
	].

	array := arrayOfArray collect: [:fonts |
		self newFontArray: fonts.
	].

	^TTCFont reorganizeForNewFontArray: array name: array first familyName asSymbol.
"
	styleName := (array at: 1) familyName asSymbol.
	textStyle := TextStyle fontArray: array.
	TextConstants at: styleName put: textStyle.

	self register: array at: styleName.

	^ TextConstants at: styleName.
"
]

{ #category : #'file out\/in' }
TTCFontSet class >> newTextStyleFromTTFile: fileName [
"
	TTCFontReader encodingTag: JapaneseEnvironment leadingChar.
	self newTextStyleFromTTFile: 'C:\WINDOWS\Fonts\msmincho.TTC'

	TTCFontReader encodingTag: 0.
	self newTextStyleFromTTFile: 'C:\WINDOWS\Fonts\symbol.ttf'
"

	| description |
	description := TTCFontDescription addFromTTFile: fileName.
	^ self newTextStyleFromTT: description.

]

{ #category : #'file out\/in' }
TTCFontSet class >> newTextStyleFromTTFile: fileName encodingTag: encodingTag ranges: ranges [

	| description |
	description := TTFontDescription addSetFromTTFile: fileName encodingTag: encodingTag ranges: ranges.
	self newTextStyleFromTT: description.
	^ description.

]

{ #category : #accessing }
TTCFontSet class >> pointSizes [

	^ TTCFont pointSizes.

]

{ #category : #registry }
TTCFontSet class >> register: anObject at: symbolName [

	self registry at: symbolName put: anObject.

]

{ #category : #registry }
TTCFontSet class >> registry [

	^ TTCFont registry.

]

{ #category : #registry }
TTCFontSet class >> removeStyleName: aString [

	| style symName |
	symName := aString asSymbol.
	style := TextConstants removeKey: symName ifAbsent: [].
	style ifNotNil: [self unregister: symName].
	TTCFontDescription removeDescriptionNamed: aString asString.

]

{ #category : #private }
TTCFontSet class >> setDefault [
"
	self setDefault
"
	| tt |
	tt := TTCFontDescription default.
	tt ifNil: [TTCFontDescription setDefault].
	tt := TTCFontDescription default.
	tt ifNotNil: [self newTextStyleFromTT: tt].

]

{ #category : #registry }
TTCFontSet class >> unregister: symbolName [

	self registry removeKey: symbolName ifAbsent: [].

]

{ #category : #derivatives }
TTCFontSet >> addLined: aTTCFont [
	| l |
	l := LinedTTCFont fromTTCFont: aTTCFont emphasis: 4.
	self derivativeFont: l at: l emphasis.

	l := LinedTTCFont fromTTCFont: aTTCFont emphasis: 16.
	self derivativeFont: l at: l emphasis.

	l := LinedTTCFont fromTTCFont: aTTCFont emphasis: 20.
	self derivativeFont: l at: l emphasis.

]

{ #category : #accessing }
TTCFontSet >> ascent [

	^ (fontArray at: 1) ascent.

]

{ #category : #accessing }
TTCFontSet >> ascentOf: aCharacter [

	^ fontArray first ascentOf: aCharacter.

]

{ #category : #accessing }
TTCFontSet >> baseKern [

	^ 0.

]

{ #category : #private }
TTCFontSet >> basicHasGlyphOf: aCharacter [
	"see TTCFont>>hasGlyphOf:"
	^ fontArray first basicHasGlyphOf: aCharacter
]

{ #category : #accessing }
TTCFontSet >> depth [

	^ (fontArray at: 1) depth.

]

{ #category : #derivatives }
TTCFontSet >> derivativeFont: aTTCFont [

	| index |
	index := TTCFont indexOfSubfamilyName: (aTTCFont subfamilyName).
	index < 1 ifTrue: [
		^ self "inform: 'unknown sub family name.  This font will be skipped'".
	].

	self derivativeFont: aTTCFont at: index.

	"self addLined: aTTCFont."

]

{ #category : #derivatives }
TTCFontSet >> derivativeFont: aTTCFontSet at: index [

	| newDeriv |
	aTTCFontSet ifNil: [derivatives := nil. ^ self].
	derivatives ifNil: [derivatives := Array new: 32].
	derivatives size < 32 ifTrue: [
		newDeriv := Array new: 32.
		newDeriv replaceFrom: 1 to: derivatives size with: derivatives.
		derivatives := newDeriv.
	].
	derivatives at: index put: aTTCFontSet

]

{ #category : #derivatives }
TTCFontSet >> derivativeFonts [

	derivatives ifNil: [^ #()].
	^derivatives copyWithout: nil
]

{ #category : #accessing }
TTCFontSet >> descent [

	^ (fontArray at: 1) descent.

]

{ #category : #accessing }
TTCFontSet >> descentKern [

	^ 0.

]

{ #category : #accessing }
TTCFontSet >> descentOf: aChar [

	^ fontArray first descentOf: aChar

]

{ #category : #displaying }
TTCFontSet >> displayString: aString on: aBitBlt from: startIndex to: stopIndex at: aPoint kern: kernDelta [

	^ self displayString: aString on: aBitBlt from: startIndex to: stopIndex at: aPoint kern: kernDelta baselineY: aPoint y + self ascent.

]

{ #category : #displaying }
TTCFontSet >> displayString: aString on: aBitBlt from: startIndex to: stopIndex at: aPoint kern: kernDelta baselineY: baselineY [

	| destPoint font form encoding glyphInfo char charCode destY |
	destPoint := aPoint.
	glyphInfo := Array new: 5.
	startIndex to: stopIndex do: [:charIndex |
		char := aString at: charIndex.
		encoding := char leadingChar + 1.
		charCode := char charCode.
		font := fontArray at: encoding.
		((charCode between: font minAscii and: font maxAscii) not) ifTrue: [
			charCode := font maxAscii].
		self glyphInfoOf: char into: glyphInfo.
		form := glyphInfo first.
		(glyphInfo fifth ~= aBitBlt lastFont) ifTrue: [
			glyphInfo fifth installOn: aBitBlt.
		].
		destY := baselineY - glyphInfo fourth. 
		aBitBlt
			sourceForm: form;
			destX: destPoint x;
			destY: destY;
			sourceOrigin: 0 @ 0;
			width: form width;
			height: form height;
			copyBits.
		destPoint := destPoint x + (form width + kernDelta) @ destPoint y.
	].
	^ destPoint.

]

{ #category : #displaying }
TTCFontSet >> displayStringR2L: aString on: aBitBlt from: startIndex to: stopIndex at: aPoint kern: kernDelta [ 

	| destPoint font form encoding char charCode glyphInfo |
	destPoint := aPoint.
	glyphInfo := Array new: 5.
	startIndex to: stopIndex do: [:charIndex |
		char := aString at: charIndex.
		encoding := char leadingChar + 1.
		charCode := char charCode.
		font := fontArray at: encoding.
		((charCode between: font minAscii and: font maxAscii) not) ifTrue: [
			charCode := font maxAscii].
		self glyphInfoOf: char into: glyphInfo.
		form := glyphInfo first.
			(glyphInfo size > 4 and: [glyphInfo fifth notNil and: [glyphInfo fifth ~= aBitBlt lastFont]]) ifTrue: [
				glyphInfo fifth installOn: aBitBlt.
			].
		aBitBlt
			sourceForm: form;
			destX: destPoint x - form width;
			destY: destPoint y;
			sourceOrigin: 0 @ 0;
			width: form width;
			height: form height;
			copyBits.
		destPoint := destPoint x - (form width + kernDelta) @ destPoint y.
	].

]

{ #category : #accessing }
TTCFontSet >> emphasis [
	^ fontArray first emphasis
]

{ #category : #derivatives }
TTCFontSet >> emphasis: code [

	code > 3 ifTrue: [^ self].
	code = 0 ifTrue: [^ self].
	derivatives isNil ifTrue: [^ self].
	^ (derivatives at: code) ifNil: [self].

]

{ #category : #accessing }
TTCFontSet >> emphasized: code [

	code = 0 ifTrue: [^ self].
	derivatives ifNil: [^ self].
	(((code bitAnd: 20) ~= 0) and: [
		derivatives size < code or: [(derivatives at: code) isNil]]) ifTrue: [
		self addLined.
	].
	^ (derivatives at: code) ifNil: [self].

]

{ #category : #accessing }
TTCFontSet >> familyName [

	^ (fontArray at: 1) familyName.

]

{ #category : #accessing }
TTCFontSet >> familySizeFace [

	^ Array
		with: fontArray first name
		with: self height
		with: 0.

]

{ #category : #accessing }
TTCFontSet >> fontArray [

	^ fontArray

]

{ #category : #private }
TTCFontSet >> glyphInfoOf: aCharacter into: glyphInfoArray [
"return glyph info for the character; it can get complicated."
	| index f code |
	"the leadingChar gives us an encoding. if that is outside the range of fonts in my fontArray, just return the default glyphInfo for a question-mark"
	index := aCharacter leadingChar + 1.
	fontArray size < index ifTrue: [^ self questionGlyphInfoInto: glyphInfoArray].
	(f := fontArray at: index) ifNil: [^ self questionGlyphInfoInto: glyphInfoArray].

	"if the actual character is not in the range supported by the chosen font, return that default question-mark info "
	code := aCharacter charCode.
	((code between: f minAscii and: f maxAscii) not) ifTrue: [
		^ self questionGlyphInfoInto: glyphInfoArray.
	].
	"finally, we have an ok font and character to return glyph info about - note that the font may have other ideas. "
	f glyphInfoOf: aCharacter into: glyphInfoArray.
	glyphInfoArray at: 5 put: self.
	^ glyphInfoArray.

]

{ #category : #private }
TTCFontSet >> hasGlyphOf: aCharacter [
	"see TTCFont>>hasGlyphOf:"
	^ fontArray first hasGlyphOf: aCharacter
]

{ #category : #accessing }
TTCFontSet >> hasGlyphWithFallbackOf: aCharacter [

	| index f |
	index := aCharacter leadingChar +1.
	fontArray size < index ifTrue: [^ false].
	(f := fontArray at: index) ifNil: [^ false].

	^ f hasGlyphWithFallbackOf: aCharacter.

]

{ #category : #accessing }
TTCFontSet >> height [

	^fontArray first pixelSize.

]

{ #category : #initialization }
TTCFontSet >> initializeWithFontArray: anArray [

	fontArray := anArray.
	"name := anArray first name."

]

{ #category : #'displaying private' }
TTCFontSet >> installOn: aDisplayContext [

	^aDisplayContext installTTCFont: self.

]

{ #category : #'displaying private' }
TTCFontSet >> installOn: aDisplayContext foregroundColor: fgColor backgroundColor: bgColor [

	foregroundColor := fgColor.
	fontArray do: [:s | s ifNotNil: [s installOn: aDisplayContext foregroundColor: fgColor backgroundColor: bgColor]].

]

{ #category : #testing }
TTCFontSet >> isFontSet [

	^ true.

]

{ #category : #testing }
TTCFontSet >> isRegular [
	"Answer true if I am a Regular/Roman font (i.e. not bold, etc.)"
	^ (TTCFont indexOfSubfamilyName: (self subfamilyName)) = 0.

]

{ #category : #testing }
TTCFontSet >> isTTCFont [
	^true
]

{ #category : #accessing }
TTCFontSet >> lineGrid [

	^ fontArray first lineGrid.

]

{ #category : #accessing }
TTCFontSet >> maxAsciiFor: encoding [

	| f |
	f := (fontArray at: encoding+1).
	f ifNotNil: [^ f maxAscii].
	^ 0.

]

{ #category : #'objects from disk' }
TTCFontSet >> objectForDataStream: refStrm [
	| dp |
	"I am about to be written on an object file.  Write a
reference to a known FontSet in the other system instead."

	"a path to me"
	dp := DiskProxy global: #TTCFontSet selector: #familyName:pointSize:
			args: {self familyName. self pointSize}.
	refStrm replace: self with: dp.
	^ dp.

]

{ #category : #accessing }
TTCFontSet >> pointSize [

	^ fontArray first pointSize

]

{ #category : #derivatives }
TTCFontSet >> pointSize: aNumber [

	self privatePointSize: aNumber.
	derivatives ifNotNil: [ derivatives do: [ :f | f ifNotNil: [ f privatePointSize: aNumber ]]].

]

{ #category : #accessing }
TTCFontSet >> pointSizes [

	^ self class pointSizes.

]

{ #category : #derivatives }
TTCFontSet >> privatePointSize: aNumber [
	fontArray do: [:f |
		f privatePointSize: aNumber
	].

]

{ #category : #private }
TTCFontSet >> questionGlyphInfoInto: glyphInfoArray [
"return glyph info for the question mark character in the first font of the fontArray -sort of a default set of info"
	| f form |
	f := fontArray at: 1.
	form := f formOf: $?.
	glyphInfoArray at: 1 put: form;
		at: 2 put: 0;
		at: 3 put: form width;
		at: 4 put: (self ascentOf: $?);
		at: 5 put: self.
	^ glyphInfoArray.

]

{ #category : #accessing }
TTCFontSet >> subfamilyName [

	^ fontArray first ttcDescription subfamilyName.

]

{ #category : #accessing }
TTCFontSet >> textStyle [

	^ TextStyle actualTextStyles
		detect: [:aStyle | (aStyle fontArray collect: [:s | s name]) includes: self name]
		ifNone: [].

]

{ #category : #accessing }
TTCFontSet >> ttcDescription [
	^ fontArray first ttcDescription
]

{ #category : #measuring }
TTCFontSet >> widthOf: aCharacter [

	| encoding font |
	encoding := aCharacter leadingChar.
	encoding >= fontArray size ifFalse: [
		font := (fontArray at: encoding + 1).
		font ifNotNil: [^ font widthOf: aCharacter].
	].
	^ (fontArray at: 1) widthOf: aCharacter.

]
