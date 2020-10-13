"
AbstractFont defines the generic interface that all fonts need to implement.
"
Class {
	#name : #AbstractFont,
	#superclass : #Object,
	#classVars : [
		'ForceNonSubPixelCount'
	],
	#category : #'Graphics-Fonts'
}

{ #category : #utilities }
AbstractFont class >> emphasisStringFor: emphasisCode [
	"Answer a translated string that represents the attributes given in emphasisCode."

	| emphases |
	emphasisCode = 0 ifTrue: [ ^'Normal' translated ].

	emphases := #('Bold' 'Italic' 'Underlined' 'Narrow' 'StruckOut').

	^String streamContents: [ :s |
		1 to: emphases size do: [ :i |
			(emphasisCode bitAt: i) isZero ifFalse: [ s nextPutAll: (emphases at: i) translated; space ] ].
		s position isZero ifFalse: [ s skip: -1 ] ]
]

{ #category : #utilities }
AbstractFont class >> forceNonSubPixelCount [
	"Answer the force non-subpixel count"
	^ForceNonSubPixelCount ifNil:[ForceNonSubPixelCount := 0]
]

{ #category : #utilities }
AbstractFont class >> forceNonSubPixelDuring: aBlock [
	"Forces all font rendering to suppress subpixel anti-aliasing during the execution of aBlock"
	ForceNonSubPixelCount ifNil:[ForceNonSubPixelCount := 0].
	ForceNonSubPixelCount := ForceNonSubPixelCount + 1.
	aBlock ensure:[ForceNonSubPixelCount := ForceNonSubPixelCount - 1]
]

{ #category : #measuring }
AbstractFont >> approxWidthOfText: aText [
"Return the width of aText -- quickly, and a little bit dirty. Used by lists morphs containing Text objects to get a quick, fairly accurate measure of the width of a list item."

    | w |
    
    (aText isNil or: [aText size = 0 ])
        ifTrue:[^0].
       
    w := self
        widthOfString: aText asString.

     "If the text has no emphasis, just return the string size.  If it is empasized, 
    just approximate the width by adding about 20% to the width"   
    (((aText runLengthFor: 1) = aText size)
        and: [(aText emphasisAt: 1) = 0 ])
            ifTrue:[^w]
            ifFalse:[ ^w * 6 // 5 ]. 
]

{ #category : #accessing }
AbstractFont >> ascent [

	self subclassResponsibility.

]

{ #category : #accessing }
AbstractFont >> ascentOf: aCharacter [

	^ self ascent.

]

{ #category : #accessing }
AbstractFont >> baseKern [
	^0
]

{ #category : #accessing }
AbstractFont >> basicAscentOf: aCharacter [

	^ self ascent.

]

{ #category : #accessing }
AbstractFont >> basicDescentOf: aCharacter [

	^ self descent.

]

{ #category : #testing }
AbstractFont >> basicHasGlyphOf: aCharacter [

	self subclassResponsibility
]

{ #category : #accessing }
AbstractFont >> characterToGlyphMap [
	"Return the character to glyph mapping table. If the table is not provided the character scanner will query the font directly for the width of each individual character."
	^nil
]

{ #category : #accessing }
AbstractFont >> depth [
	"Returns the glyphs' color depth."
	
	self subclassResponsibility.
]

{ #category : #accessing }
AbstractFont >> derivativeFonts [
	^#()
]

{ #category : #accessing }
AbstractFont >> descent [

	self subclassResponsibility.

]

{ #category : #accessing }
AbstractFont >> descentOf: aCharacter [

	^ self descent.

]

{ #category : #displaying }
AbstractFont >> displayStrikeoutOn: aDisplayContext from: baselineStartPoint to: baselineEndPoint [
	"display the strikeout if appropriate for the receiver"
]

{ #category : #displaying }
AbstractFont >> displayString: aString on: aDisplayContext from: startIndex to: stopIndex at: aPoint kern: kernDelta [
	"Draw the given string from startIndex to stopIndex 
	at aPoint on the (already prepared) display context."
	^self subclassResponsibility
]

{ #category : #displaying }
AbstractFont >> displayString: aString on: aDisplayContext from: startIndex to: stopIndex at: aPoint kern: kernDelta baselineY: baselineY [
	"Draw the given string from startIndex to stopIndex 
	at aPoint on the (already prepared) display context."
	^self subclassResponsibility
]

{ #category : #displaying }
AbstractFont >> displayUnderlineOn: aDisplayContext from: baselineStartPoint to: baselineEndPoint [
	"display the underline if appropriate for the receiver"
]

{ #category : #accessing }
AbstractFont >> emphasisString [
	"Answer a translated string that represents the receiver's emphasis."
	
	^self emphasisStringFor: self emphasis
]

{ #category : #accessing }
AbstractFont >> emphasisStringFor: emphasisCode [
	"Answer a translated string that represents the attributes given in emphasisCode."
	
	^self class emphasisStringFor: emphasisCode
]

{ #category : #accessing }
AbstractFont >> familyName [
	"Answer the name to be used as a key in the TextConstants dictionary."
	^self subclassResponsibility
]

{ #category : #testing }
AbstractFont >> hasDistinctGlyphsForAll: asciiString [
	"Answer true if the receiver has glyphs for all the characters
	in asciiString and no single glyph is shared by more than one character, false otherwise.
	The default behaviour is to answer true, but subclasses may reimplement"
	
	^true
]

{ #category : #testing }
AbstractFont >> hasGlyphOf: aCharacter [

	^ self basicHasGlyphOf: aCharacter
]

{ #category : #testing }
AbstractFont >> hasGlyphsForAll: asciiString [
	"Answer true if the receiver has glyphs for all the characters
	in asciiString, false otherwise.
	The default behaviour is to answer true, but subclasses may reimplement"
	
	^true
]

{ #category : #accessing }
AbstractFont >> height [
	"Answer the height of the receiver, total of maximum extents of 
	characters above and below the baseline."

	^self subclassResponsibility
]

{ #category : #displaying }
AbstractFont >> installOn: aDisplayContext foregroundColor: foregroundColor backgroundColor: backgroundColor [
	"Install the receiver on the given DisplayContext (either BitBlt or Canvas) for further drawing operations."
	^self subclassResponsibility
]

{ #category : #testing }
AbstractFont >> isFontSet [

	^ false.

]

{ #category : #testing }
AbstractFont >> isPairKerningCapable [
"a hopefully temporary test method; better factoring of scan/measure/display should remove the need for it.
Only FreeType fonts would currently add this to return true"
	^false
]

{ #category : #testing }
AbstractFont >> isRegular [
	^false
]

{ #category : #testing }
AbstractFont >> isSubPixelPositioned [
	"Answer true if the receiver is currently using subpixel positioned
	glyphs, false otherwise. This affects how padded space sizes are calculated
	when composing text. 
	Currently, only FreeTypeFonts are subPixelPositioned, and only when not
	Hinted"
	
	^false 
]

{ #category : #testing }
AbstractFont >> isSymbolFont [
	"Answer true if the receiver is a Symbol font, false otherwise.
	The default is to answer false, subclasses can reimplement"
	
	^false
]

{ #category : #testing }
AbstractFont >> isTTCFont [
	^false
]

{ #category : #kerning }
AbstractFont >> kerningLeft: leftChar right: rightChar [
	^0
]

{ #category : #accessing }
AbstractFont >> lineGrid [
	"Answer the relative space between lines"

	^self subclassResponsibility
]

{ #category : #measuring }
AbstractFont >> linearWidthOf: aCharacter [
	"This is the scaled, unrounded advance width."
	^self widthOf: aCharacter
]

{ #category : #accessing }
AbstractFont >> pixelSize [
	"Make sure that we don't return a Fraction"
	^ TextStyle pointsToPixels: self pointSize
]

{ #category : #notifications }
AbstractFont >> pixelsPerInchChanged [
	"The definition of TextStyle class>>pixelsPerInch has changed. Do whatever is necessary."
]

{ #category : #accessing }
AbstractFont >> pointSize [
	self subclassResponsibility.
]

{ #category : #printing }
AbstractFont >> printShortDescriptionOn: aStream [
	aStream space; nextPutAll: self familyName
]

{ #category : #caching }
AbstractFont >> releaseCachedState [
	
]

{ #category : #example }
AbstractFont >> sampleText [

	| text |
	text := (self isSymbolFont or: [(self basicHasGlyphOf: $a) not])
		ifTrue: [Text symbolSample]
		ifFalse: [Text textSample].
	text addAttribute: (TextFontReference toFont: self).
	^ text
]

{ #category : #'character scanning' }
AbstractFont >> scanByteCharactersFrom: startIndex to: stopIndex in: aByteString with: aCharacterScanner rightX: rightX [
	"scan a single byte character string"
	^aCharacterScanner scanByteCharactersFrom: startIndex to: stopIndex in: aByteString rightX: rightX
]

{ #category : #'character scanning' }
AbstractFont >> scanMultibyteCharactersFrom: startIndex to: stopIndex in: aWideString with: aCharacterScanner rightX: rightX [
	"scan a multibyte character string"
	^aCharacterScanner scanMultibyteCharactersFrom: startIndex to: stopIndex in: aWideString rightX: rightX 
]

{ #category : #'character scanning' }
AbstractFont >> scanMultibyteJapaneseCharactersFrom: startIndex to: stopIndex in: aWideString with: aCharacterScanner rightX: rightX [
	"scan a multibyte Japanese character string"
	^aCharacterScanner scanJapaneseCharactersFrom: startIndex to: stopIndex in: aWideString rightX: rightX 

]

{ #category : #accessing }
AbstractFont >> textStyle [
	^ TextStyle actualTextStyles detect:
		[:aStyle | aStyle fontArray includes: self] ifNone: [ TextStyle fontArray: { self } ]
]

{ #category : #accessing }
AbstractFont >> textStyleName [
	"Answer the name to be used as a key in the TextConstants dictionary."
	^self familyName
]

{ #category : #kerning }
AbstractFont >> widthAndKernedWidthOfLeft: leftCharacter right: rightCharacterOrNil into: aTwoElementArray [
	"Set the first element of aTwoElementArray to the width of leftCharacter and 
	the second element to the width of left character when kerned with
	rightCharacterOrNil. Answer aTwoElementArray"
	"Actually, nearly all users of this actually want just the widthOf the leftCharacter, so we will default to that for speed. See other implementations for more complex cases"

	| w |
	w := self widthOf: leftCharacter.
	aTwoElementArray at: 1 put: w.
	aTwoElementArray at: 2 put: w

"	The old code, and what fonts which have pair-kerning would use - 
	w := self widthOf: leftCharacter.
	rightCharacterOrNil isNil
		ifTrue:[
			aTwoElementArray 
				at: 1 put: w; 
				at: 2 put: w]
		ifFalse:[
			k := self kerningLeft: leftCharacter right: rightCharacterOrNil.
			aTwoElementArray 
				at: 1 put: w; 
				at: 2 put: w+k].
	^aTwoElementArray
"	
]

{ #category : #measuring }
AbstractFont >> widthOf: aCharacter [
	"Return the width of the given character"
	^self subclassResponsibility
]

{ #category : #measuring }
AbstractFont >> widthOfString: aString [
	aString ifNil:[^0].
	^self widthOfString: aString from: 1 to: aString size.
"
	TextStyle default defaultFont widthOfString: 'zort' 21
"
]

{ #category : #measuring }
AbstractFont >> widthOfString: aString from: startIndex to: stopIndex [
	"Measure the length of the given string between start and stop index"
	| resultX |
	resultX := 0.
	startIndex to: stopIndex do: [:i | 
		resultX := resultX + (self widthOf: (aString at: i))].
	^resultX
]

{ #category : #measuring }
AbstractFont >> widthOfStringOrText: aStringOrText [
    aStringOrText ifNil:[^0].
    ^aStringOrText isText
        ifTrue:[self approxWidthOfText: aStringOrText ]
        ifFalse:[self widthOfString: aStringOrText ] 
]

{ #category : #accessing }
AbstractFont >> xTable [
	"Return the xTable for the font. The xTable defines the left x-value for each individual glyph in the receiver. If such a table is not provided, the character scanner will ask the font directly for the appropriate width of each individual character."
	^nil
]
