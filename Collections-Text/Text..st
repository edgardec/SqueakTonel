"
I represent a character string that has been marked with abstract changes in character appearance. Actual display is performed in the presence of a TextStyle which indicates, for each abstract code, an actual font to be used.  A Text associates a set of TextAttributes with each character in its character string.  These attributes may be font numbers, emphases such as bold or italic, or hyperling actions.  Font numbers are interpreted relative to whatever textStyle appears, along with the text, in a Paragraph.  Since most characters have the same attributes as their neighbors, the attributes are stored in a RunArray for efficiency.  Each of my instances has
	string		a String
	runs		a RunArray
"
Class {
	#name : #Text,
	#superclass : #ArrayedCollection,
	#instVars : [
		'string',
		'runs'
	],
	#classVars : [
		'IgnoreStyleIfOnlyBold'
	],
	#pools : [
		'TextConstants'
	],
	#category : #'Collections-Text'
}

{ #category : #'filler text' }
Text class >> THEQUICKBROWNFOX [

	^ self fromString: 'THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG.'
]

{ #category : #private }
Text class >> addAttribute: att toArray: others [ 
	"Add a new text attribute to an existing set"
	"NOTE: The use of reset and set in this code is a specific
	hack for merging TextKerns."
	att reset.
	^ Array streamContents:
		[:strm | others do:
			[:other | (att dominates: other) ifFalse: [strm nextPut: other]].
		att set ifTrue: [strm nextPut: att]]
]

{ #category : #'filler text' }
Text class >> allDigits [

	^ self fromString: '0123456789'
]

{ #category : #'instance creation' }
Text class >> fromString: aString [ 
	"Answer an instance of me whose characters are those of the argument, aString."

	^ self string: aString attributes:  #()
]

{ #category : #'filler text' }
Text class >> hamburgefonstiv [

	^ self fromString: 'Hamburgefonstiv'
]

{ #category : #preferences }
Text class >> ignoreStyleIfOnlyBold [
		<preference: 'Ignore style if only bold' category: 'browsing' description: 'If true, then any method submission in which the only style change is for bolding will be treated as a method with no style specifications.' type: #Boolean>
		^ IgnoreStyleIfOnlyBold ifNil: [true].
]

{ #category : #preferences }
Text class >> ignoreStyleIfOnlyBold: aBoolean [
	IgnoreStyleIfOnlyBold := aBoolean.
]

{ #category : #'class initialization' }
Text class >> initTextConstants [ 
	"Initialize constants shared by classes associated with text display, e.g., 
	Space, Tab, Cr, Bs, ESC."
		"1/24/96 sw: in exasperation and confusion, changed cmd-g mapping from 231 to 232 to see if I could gain any relief?!"


	| letter varAndValue tempArray width |
	"CtrlA..CtrlZ, Ctrla..Ctrlz"
	letter := $A.
 	#(		212 230 228 196 194 226 241 243 214 229 200 217 246 
			245 216 202 210 239 211 240 197 198 209 215 242 231
	 		1 166 228 132 130 12 232 179 150 165 136 153 182 
			14 15 138 17 18 19 11 21 134 145 151 178 167 ) do:
		[:kbd |
		TextConstants at: ('Ctrl', letter asSymbol) asSymbol put: kbd asCharacter.
		letter := letter == $Z ifTrue: [$a] ifFalse: [(letter asciiValue + 1) asCharacter]].

	varAndValue := #(
		Space	32
		Tab		9
		CR		13
		Enter	3
		BS		8
		BS2		158
		ESC		160
		Clear 	173
	).

	varAndValue size odd ifTrue: [self error: 'unpaired text constant'].
	(2 to: varAndValue size by: 2) do:
		[:i | TextConstants at: (varAndValue at: i - 1) put: (varAndValue at: i) asCharacter].

	varAndValue := #(
		CtrlDigits 			(159 144 143 128 127 129 131 180 149 135)
		CtrlOpenBrackets	(201 7 218 249 219 15)
			"lparen gottn by ctrl-:= = 201; should be 213 but can't type that on Mac"

			"values for alignment"
		LeftFlush	0
		RightFlush	1
		Centered	2
		Justified	3

			"subscripts for a marginTabsArray tuple"
		LeftMarginTab	1
		RightMarginTab	2

			"font faces"
		Basal	0
		Bold	1
		Italic	2

			"in case font doesn't have a width for space character"
			"some plausible numbers-- are they the right ones?"
		DefaultSpace			4
		DefaultTab				24
		DefaultLineGrid			16
		DefaultBaseline			12
		DefaultFontFamilySize	3	"basal, bold, italic"
	).

	varAndValue size odd ifTrue: [self error: 'unpaired text constant'].
	(2 to: varAndValue size by: 2) do:
		[:i | TextConstants at: (varAndValue at: i - 1) put: (varAndValue at: i)].

	TextConstants at: #DefaultRule	put: Form over.
	TextConstants at: #DefaultMask	put: Color black.

	width := Display width max: 720.
	tempArray := Array new: width // DefaultTab.
	1 to: tempArray size do:
		[:i | tempArray at: i put: DefaultTab * i].
	TextConstants at: #DefaultTabsArray put: tempArray.
	tempArray := Array new: (width // DefaultTab) // 2.
	1 to: tempArray size do:
		[:i | tempArray at: i put: (Array with: (DefaultTab*i) with: (DefaultTab*i))].
	TextConstants at: #DefaultMarginTabsArray put: tempArray.

"Text initTextConstants "
]

{ #category : #'class initialization' }
Text class >> initialize [	"Text initialize"
	"Initialize constants shared by classes associated with text display."

	TextConstants at: #CaretForm put:
				(Form extent: 16@5
					fromArray: #(2r001100e26 2r001100e26 2r011110e26 2r111111e26 2r110011e26)
					offset: -3@0).
	self initTextConstants
]

{ #category : #'filler text' }
Text class >> loremIpsum [

	^ self fromString: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, 
sed do eiusmod tempor incididunt ut labore et dolore 
magna aliqua. Ut enim ad minim veniam, quis nostrud 
exercitation ullamco laboris nisi ut aliquip ex ea commodo 
consequat. Duis aute irure dolor in reprehenderit in voluptate 
velit esse cillum dolore eu fugiat nulla pariatur. Excepteur 
sint occaecat cupidatat non proident, sunt in culpa qui 
officia deserunt mollit anim id est laborum.'
]

{ #category : #'instance creation' }
Text class >> new: stringSize [

	^self fromString: (String new: stringSize)
]

{ #category : #'instance creation' }
Text class >> new: newSize streamContents: blockWithArg [

	| stream |
	stream := TextStream on: (self new: newSize).
	blockWithArg value: stream.
	^ stream contents
]

{ #category : #'instance creation' }
Text class >> streamContents: blockWithArg [ 
	| stream |
	stream := TextStream on: (self new: 400).
	blockWithArg value: stream.
	^ stream contents
]

{ #category : #'instance creation' }
Text class >> string: aString attribute: att [
	"Answer an instance of me whose characters are aString.
	att is a TextAttribute."

	^self string: aString attributes: (Array with: att)
]

{ #category : #'instance creation' }
Text class >> string: aString attributes: atts [
	"Answer an instance of me whose characters are those of aString.
	atts is an array of TextAttributes."

	^self string: aString runs: (RunArray new: aString size withAll: atts)
]

{ #category : #'instance creation' }
Text class >> string: aString emphasis: emphasis [
	"This is an old method that is mainly used by old applications"

	emphasis isNumber ifTrue:
		[self halt: 'Numeric emphasis is not supported in Squeak'.
		"But if you proceed, we will do our best to give you what you want..."
		^ self string: aString runs: (RunArray new: aString size withAll: 
			(Array with: (TextFontChange new fontNumber: emphasis)))].
	^ self string: aString attributes: emphasis
]

{ #category : #private }
Text class >> string: aString runs: anArray [
 
	^self basicNew setString: aString setRunsChecking: anArray
]

{ #category : #'filler text' }
Text class >> symbolSample [

	^ self streamContents: [:stream | | lineLength character|
		lineLength := 0.
		33 to: 255 do:[ :index |
			character := stream nextPut: (Character value: index).
			lineLength := lineLength + 1.
			(('@Z`z' includes: character) or: [lineLength >= 30]) 
				ifTrue: [
					lineLength :=0.
					stream cr]]]
]

{ #category : #'filler text' }
Text class >> textSample [

	^ self streamContents: [:stream |
		stream 
			nextPutAll: self hamburgefonstiv; cr;
			nextPutAll: self theQuickBrownFox; cr;
			nextPutAll: self THEQUICKBROWNFOX; cr; cr;
			nextPutAll: self allDigits; cr; cr;
			nextPutAll: self loremIpsum]
]

{ #category : #'filler text' }
Text class >> theQuickBrownFox [

	^ self fromString: 'the quick brown fox jumps over the lazy dog'
]

{ #category : #sorting }
Text >> <=> aCharacterArray [
	"Return a collation order of -1, 0, or 1, indicating whether I should be collated before the receiver, am equal, or after.
	See also:  http://en.wikipedia.org/wiki/Spaceship_operator"

	aCharacterArray isString ifTrue: [ ^string <=> aCharacterArray ].
	^string <=> aCharacterArray asString
]

{ #category : #comparing }
Text >> = other [
	"Am I equal to the other Text or String?  
	***** Warning ***** Two Texts are considered equal if they have the same characters in them.  They might have completely different emphasis, fonts, sizes, text actions, or embedded morphs.  If you need to find out if one is a true copy of the other, you must do (text1 = text2 and: [text1 runs = text2 runs])."

	other isText ifTrue:	[ ^string = other string ].
	other isString ifTrue: [ ^string = other ].
	^false
]

{ #category : #emphasis }
Text >> addAllAttributes: attributes [

	attributes do: [:attribute |
		self addAttribute: attribute].
]

{ #category : #emphasis }
Text >> addAllAttributes: attributes from: start to: stop [

	attributes do: [:attribute |
		self addAttribute: attribute from: start to: stop].
]

{ #category : #emphasis }
Text >> addAttribute: att [ 
	^ self addAttribute: att from: 1 to: self size
]

{ #category : #emphasis }
Text >> addAttribute: att from: start to: stop [ 
	"Set the attribute for characters in the interval start to stop."
	runs :=  runs copyReplaceFrom: start to: stop
			with: ((runs copyFrom: start to: stop)
				mapValues:
				[:attributes | Text addAttribute: att toArray: attributes])

]

{ #category : #emphasis }
Text >> alignmentAt: characterIndex ifAbsent: aBlock [
	| attributes emph |
	self size = 0 ifTrue: [^aBlock value].
	emph := nil.
	attributes := runs atPin: characterIndex.
	attributes do:[:att | (att isKindOf: TextAlignment) ifTrue:[emph := att]].
	emph ifNil: [ ^aBlock value ].
	^emph alignment
]

{ #category : #emphasis }
Text >> allBold [ 
	"Force this whole text to be bold."
	string size = 0 ifTrue: [^self].
	self makeBoldFrom: 1 to: string size
]

{ #category : #accessing }
Text >> append: stringOrText [

	self replaceFrom: string size + 1
				to: string size with: stringOrText
]

{ #category : #converting }
Text >> asDisplayText [
	"Answer a DisplayText whose text is the receiver."

	^DisplayText text: self
]

{ #category : #converting }
Text >> asNumber [
	"Answer the number created by interpreting the receiver as the textual 
	representation of a number."

	^string asNumber
]

{ #category : #converting }
Text >> asOctetStringText [

	string class == WideString ifTrue: [
		^ self class string: string asOctetString runs: self runs copy.
	].
	^self.

]

{ #category : #converting }
Text >> asString [
	"Answer a String representation of the textual receiver."

	^string
]

{ #category : #converting }
Text >> asStringOrText [	
	"Answer the receiver itself."

	^self
]

{ #category : #converting }
Text >> asStringToHtml [
	"Inverse to String >> #asTextFromHtml"
	
	^ self printHtmlString
]

{ #category : #converting }
Text >> asSymbol [

	^ self asString asSymbol

]

{ #category : #converting }
Text >> asText [	
	"Answer the receiver itself."

	^self
]

{ #category : #accessing }
Text >> at: index [

	^string at: index
]

{ #category : #accessing }
Text >> at: index put: character [

	^string at: index put: character
]

{ #category : #emphasis }
Text >> attributesAt: characterIndex [ 
	"Answer the code for characters in the run beginning at characterIndex."
	"NB: no senders any more (supplanted by #attributesAt:forStyle: but retained for the moment in order not to break user code that may exist somewhere that still calls this"
	| attributes |
	self size = 0
		ifTrue: [^ Array with: (TextFontChange new fontNumber: 1)].  "null text tolerates access"
	attributes := runs atPin: characterIndex.
	^ attributes
]

{ #category : #emphasis }
Text >> attributesAt: characterIndex do: aBlock [
	"Answer the code for characters in the run beginning at characterIndex."
	"NB: no senders any more (supplanted by #attributesAt:forStyle: but retained for the moment in order not to break user code that may exist somewhere that still calls this"
	self size = 0 ifTrue:[^self].
	(runs atPin: characterIndex) do: aBlock
]

{ #category : #emphasis }
Text >> attributesAt: characterIndex forStyle: aTextStyle [
	"Answer the code for characters in the run beginning at characterIndex."
	| attributes |
	self size = 0
		ifTrue: [^ Array with: (TextFontChange new fontNumber: aTextStyle defaultFontIndex)].  "null text tolerates access"
	attributes := runs atPin: characterIndex.
	^ attributes
]

{ #category : #emphasis }
Text >> colorAt: characterIndex [ 

	^ self colorAt: characterIndex ifNone: [Color black]
]

{ #category : #emphasis }
Text >> colorAt: characterIndex ifNone: block [

	self size = 0 ifTrue: [^ block value]. "null text tolerates access."

	^ (runs atPin: characterIndex)
		detect: [:attr | attr class == TextColor]
		ifFound: [:attr | attr color]
		ifNone: block
]

{ #category : #copying }
Text >> copyFrom: start to: stop [ 
	"Answer a copied subrange of the receiver."

	| realStart realStop |
	stop > self size
		ifTrue: [realStop := self size]		"handle selection at end of string"
		ifFalse: [realStop := stop].
	start < 1
		ifTrue: [realStart := 1]			"handle selection before start of string"
		ifFalse: [realStart := start].
	^self class 
		string: (string copyFrom: realStart to: realStop)
		runs: (runs copyFrom: realStart to: realStop)
]

{ #category : #copying }
Text >> copyReplaceFrom: start to: stop with: aTextOrString [

	| txt |
	txt := aTextOrString asText.	"might be a string"
	^self class 
             string: (string copyReplaceFrom: start to: stop with: txt string)
             runs: (runs copyReplaceFrom: start to: stop with: txt runs)

]

{ #category : #copying }
Text >> copyReplaceTokens: oldSubstring with: newSubstring [ 
	"Replace all occurrences of oldSubstring that are surrounded
	by non-alphanumeric characters"
	^ self copyReplaceAll: oldSubstring with: newSubstring asTokens: true
	"'File asFile Files File''s File' copyReplaceTokens: 'File' with: 'Snick'"
]

{ #category : #attributes }
Text >> couldDeriveFromPrettyPrinting [
	"Return true if the receiver has any TextAttributes that are functional rather than simply appearance-related"
	runs values do:
		[:emphArray | emphArray do:
			[:emph | emph couldDeriveFromPrettyPrinting ifFalse: [^ false]]].
	^ true
]

{ #category : #copying }
Text >> deepCopy [

	^ self copy "Both string and runs are assumed to be read-only"
]

{ #category : #emphasis }
Text >> emphasisAt: characterIndex [
	"Answer the fontfor characters in the run beginning at characterIndex."
	| attributes |
	self size = 0 ifTrue: [^ 0].	"null text tolerates access"
	attributes := runs atPin: characterIndex.
	^attributes inject: 0 into: 
		[:emph :att | emph bitOr: att emphasisCode].
	
]

{ #category : #emphasis }
Text >> find: attribute [
	"Return the first interval over which this attribute applies"
	| begin end |
	begin := 0.
	runs withStartStopAndValueDo:
		[:start :stop :attributes |
		(attributes includes: attribute)
			ifTrue: [begin = 0 ifTrue: [begin := start].
					end := stop]
			ifFalse: [begin > 0 ifTrue: [^ begin to: end]]].
	begin > 0 ifTrue: [^ begin to: end].
	^ nil
]

{ #category : #accessing }
Text >> findString: aString startingAt: start [ 
	"Answer the index of subString within the receiver, starting at index 
	start. If the receiver does not contain subString, answer 0."

	^string findString: aString asString startingAt: start
]

{ #category : #accessing }
Text >> findString: aString startingAt: start caseSensitive: caseSensitive [
	"Answer the index of subString within the receiver, starting at index 
	start. If the receiver does not contain subString, answer 0."

	^string findString: aString asString startingAt: start caseSensitive: caseSensitive
]

{ #category : #emphasis }
Text >> fontAt: characterIndex withStyle: aTextStyle [
	"Answer the fontfor characters in the run beginning at characterIndex."
	| attributes font |
	self size = 0 ifTrue: [^ aTextStyle defaultFont].	"null text tolerates access"
	attributes := runs atPin: characterIndex.
	font := aTextStyle defaultFont.  "default"
	attributes do: 
		[:att | att forFontInStyle: aTextStyle do: [:f | font := f]].
	^ font
]

{ #category : #emphasis }
Text >> fontNumberAt: characterIndex [ 
	"Answer the fontNumber for characters in the run beginning at characterIndex."
	| attributes fontNumber |
	self size = 0 ifTrue: [^1].	"null text tolerates access"
	attributes := runs atPin: characterIndex.
	fontNumber := 1.
	attributes do: [:att | (att isMemberOf: TextFontChange) ifTrue: [fontNumber := att fontNumber]].
	^ fontNumber
	
]

{ #category : #formatting }
Text >> format: arguments [ 
	"format the receiver with arguments, respecting the format both of receiver and collection elements"
	
	^self class new: self size * 11 // 10 streamContents: [ :output |
		| nextIndex |
		nextIndex := 1.
		[ nextIndex <= self size ] whileTrue: [
			(self at: nextIndex) caseOf: {
				[$\] -> [
					nextIndex := nextIndex + 1.
					output withAttributes: (runs at: nextIndex) do: [
						output nextPut: (self at: nextIndex) ] ].
				[${] -> [
					"Parse the index - a positive integer in base 10."
					| character collectionIndex attributes |
					collectionIndex := 0.
					attributes := Set new.
					[ (character := string at: (nextIndex := nextIndex + 1)) isDigit ] whileTrue: [
						collectionIndex := collectionIndex * 10 + character digitValue.
						attributes addAll: (runs at: nextIndex) ].
					character = $} ifFalse: [ self error: '$} expected' ].
					output withAttributes: attributes do: [
						output nextPutAll: (arguments at: collectionIndex) asStringOrText ] ] }
				otherwise: [
					output withAttributes: (runs at: nextIndex) do: [
						output nextPut: (self at: nextIndex) ] ].
			nextIndex := nextIndex + 1 ] ]
]

{ #category : #testing }
Text >> hasClickableAttribute [

	^ self runs anySatisfy: [:attrs | attrs anySatisfy: [:attr |
			attr respondsTo: #mayActOnClick]]
]

{ #category : #testing }
Text >> hasColorAttribute [

	^ self runs anySatisfy: [:attrs | attrs anySatisfy: [:attr |
			attr respondsTo: #color]]
]

{ #category : #testing }
Text >> hasFontAttribute [

	^ self runs anySatisfy: [:attrs | attrs anySatisfy: [:attr |
			(attr respondsTo: #fontNumber) or: [attr respondsTo: #font]]]
]

{ #category : #comparing }
Text >> hash [
	"#hash is implemented, because #= is implemented.  We are now equal to a string with the same characters.  Hash must reflect that."

	^ string hash
]

{ #category : #comparing }
Text >> hashWithInitialHash: initialHash [ 
	"Implemented to be polymorphic with String"
	^ self string hashWithInitialHash: initialHash

]

{ #category : #comparing }
Text >> howManyMatch: aString [

	^ self string howManyMatch: aString
]

{ #category : #attributes }
Text >> indentationAmountAt: anInterval [ 
	anInterval do:
		[ : position | self
			attributesAt: position
			do: [ : attr | attr isTextIndent ifTrue: [ ^ attr amount ] ] ].
	^ 0
]

{ #category : #testing }
Text >> isText [
	^ true
]

{ #category : #converting }
Text >> isoToSqueak [
	^self "no longer needed"
]

{ #category : #accessing }
Text >> lineCount [

	^ string lineCount
]

{ #category : #converting }
Text >> macToSqueak [
	"Convert the receiver from MacRoman to Squeak encoding"
	^ self class new setString: string macToSqueak setRuns: runs copy
]

{ #category : #emphasis }
Text >> makeBoldFrom: start to: stop [

	^ self addAttribute: TextEmphasis bold from: start to: stop
]

{ #category : #emphasis }
Text >> makeSelectorBold [
	"For formatting Smalltalk source code, set the emphasis of that portion of 
	the receiver's string that parses as a message selector to be bold."

	| parser i |
	string size = 0 ifTrue: [^ self].
	i := 0.
	[(string at: (i := i + 1)) isSeparator] whileTrue.
	(string at: i) = $[ ifTrue: [^ self].  "block, no selector"
	[(parser := Compiler newParser) parseSelector: string] on: Error do: [^ self].
	self makeBoldFrom: 1 to: (parser endOfLastToken min: string size)
]

{ #category : #emphasis }
Text >> makeSelectorBoldIn: aClass [
	"For formatting Smalltalk source code, set the emphasis of that portion of 
	the receiver's string that parses as a message selector to be bold."

	| parser |
	string size = 0 ifTrue: [^self].
	(parser := aClass newParser) parseSelector: string.
	self makeBoldFrom: 1 to: (parser endOfLastToken min: string size)
]

{ #category : #copying }
Text >> postCopy [
	super postCopy.
	string := string copy.
	runs := runs copy
]

{ #category : #accessing }
Text >> prepend: stringOrText [

	self replaceFrom: 1 to: 0 with: stringOrText
]

{ #category : #html }
Text >> printHtmlOn: aStream [ 
	
	(HtmlReadWriter on: aStream)
		nextPutText: self.
]

{ #category : #html }
Text >> printHtmlString [
	"answer a string whose characters are the html representation 
	of the receiver"
	
	^ String streamContents: [:stream |
		self printHtmlOn: stream]
]

{ #category : #printing }
Text >> printOn: aStream [
	self printNameOn: aStream.
	aStream nextPutAll: ' for '; print: string
]

{ #category : #accessing }
Text >> rangeOf: attribute startingAt: index [
"Answer an interval that gives the range of attribute at index position  index. An empty interval with start value index is returned when the attribute is not present at position index.  "
   ^string size = 0
      ifTrue: [index to: index - 1]
	 ifFalse: [runs rangeOf: attribute startingAt: index]
]

{ #category : #emphasis }
Text >> removeAttribute: att from: start to: stop [ 
	"Remove the attribute over the interval start to stop."
	runs :=  runs copyReplaceFrom: start to: stop
			with: ((runs copyFrom: start to: stop)
				mapValues:
				[:attributes | attributes copyWithout: att])

]

{ #category : #converting }
Text >> removeAttributesThat: removalBlock [
	"Enumerate all attributes in the receiver. Remove those passing removalBlock."
	
	self
		removeAttributesThat: removalBlock
		replaceAttributesThat: [:att | false]
		by: nil.
]

{ #category : #converting }
Text >> removeAttributesThat: removalBlock replaceAttributesThat: replaceBlock by: convertBlock [
	"Enumerate all attributes in the receiver. Remove those passing removalBlock and replace those passing replaceBlock after converting it through convertBlock"
	| added removed |
	"Deliberately optimized for the no-op default."
	added := removed := nil.
	runs withStartStopAndValueDo: [ :start :stop :attribs | 
		attribs do: [ :attrib | | new |
			(removalBlock value: attrib) ifTrue:[
				removed ifNil:[removed := WriteStream on: #()].
				removed nextPut: {start. stop. attrib}.
			] ifFalse:[
				(replaceBlock value: attrib) ifTrue:[
					removed ifNil:[removed := WriteStream on: #()].
					removed nextPut: {start. stop. attrib}.
					new := convertBlock value: attrib.
					added ifNil:[added := WriteStream on: #()].
					added nextPut: {start. stop. new}.
				].
			].
		].
	].
	(added == nil and:[removed == nil]) ifTrue:[^self].
	"otherwise do the real work"
	removed ifNotNil:[removed contents do:[:spec|
		self removeAttribute: spec last from: spec first to: spec second]].
	added ifNotNil:[added contents do:[:spec|
		self addAttribute: spec last from: spec first to: spec second]].
]

{ #category : #converting }
Text >> replaceAttributesThat: replaceBlock by: convertBlock [
	"Enumerate all attributes in the receiver. Replace those passing replaceBlock after converting it through convertBlock."

	self
		removeAttributesThat: [:att | false]
		replaceAttributesThat: replaceBlock
		by: convertBlock.
]

{ #category : #accessing }
Text >> replaceFrom: start to: stop with: aText [

	| txt |
	txt := aText asText.	"might be a string"
	string := string copyReplaceFrom: start to: stop with: txt string.
	runs := runs copyReplaceFrom: start to: stop with: txt runs
]

{ #category : #converting }
Text >> replaceFrom: start to: stop with: replacement startingAt: repStart [ 
	"This destructively replaces elements from start to stop in the receiver starting at index, repStart, in replacementCollection. Do it to both the string and the runs."

	| rep newRepRuns |
	rep := replacement asText.	"might be a string"
	string replaceFrom: start to: stop with: rep string startingAt: repStart.
	newRepRuns := rep runs copyFrom: repStart to: repStart + stop - start.
	runs := runs copyReplaceFrom: start to: stop with: newRepRuns
]

{ #category : #converting }
Text >> reversed [

	"Answer a copy of the receiver with element order reversed."

	^ self class string: string reversed runs: runs reversed.

  "  It is assumed that  self size = runs size  holds. "
]

{ #category : #emphasis }
Text >> runLengthFor: characterIndex [ 
	"Answer the count of characters remaining in run beginning with 
	characterIndex."
	self size = 0 ifTrue:[^0]. "null tolerates access"
	^runs runLengthAt: characterIndex
]

{ #category : #private }
Text >> runs [

	^runs
]

{ #category : #accessing }
Text >> runs: anArray [

	runs := anArray
]

{ #category : #private }
Text >> setString: aString setRuns: anArray [

	string := aString.
	runs := anArray
]

{ #category : #private }
Text >> setString: aString setRunsChecking: aRunArray [
	| stringSize runsSize |
	string := aString.
	aRunArray ifNil: [^ aString asText].
	
	"Check runs and do the best you can to make them fit..."
	aRunArray runs size = aRunArray values size ifFalse: [^ aString asText]. "raise error here?"
	runsSize := aRunArray size.
	stringSize := string size.
	runs := stringSize = runsSize
				ifTrue: [aRunArray]
				ifFalse: [ stringSize > runsSize
						ifTrue: [aRunArray  add: {} withOccurrences: stringSize - runsSize]
						ifFalse: [aRunArray copyFrom: 1 to: stringSize]].
]

{ #category : #accessing }
Text >> size [

	^string size
]

{ #category : #converting }
Text >> squeakToIso [
	^self "no longer needed"
]

{ #category : #converting }
Text >> squeakToMac [
	"Convert the receiver from Squeak to MacRoman encoding"
	^ self class new setString: string squeakToMac setRuns: runs copy
]

{ #category : #printing }
Text >> storeOn: aStream [

	aStream nextPutAll: '(Text string: ';
		store: string;
		nextPutAll: ' runs: ';
		store: runs;
		nextPut: $)
]

{ #category : #accessing }
Text >> string [
	"Answer the string representation of the receiver."

	^string
]

{ #category : #testing }
Text >> unembellished [ 
	"Return true if the only emphases are the default font and bold"
	| font1 bold |
	font1 := TextFontChange defaultFontChange.
	bold := TextEmphasis bold.
	Text ignoreStyleIfOnlyBold ifFalse:
		["Ignore font1 only or font1-bold followed by font1-plain"
		^ (runs values = (Array with: (Array with: font1)))
		or: [runs values = (Array with: (Array with: font1 with: bold)
 								with: (Array with: font1))]].

	"If preference is set, then ignore any combo of font1 and bold"
	runs withStartStopAndValueDo:
		[:start :stop :emphArray |
		emphArray do:
			[:emph | (font1 = emph or: [bold = emph]) ifFalse: [^ false]]].
	^ true
]

{ #category : #converting }
Text >> withBlanksTrimmed [
	"Return a copy of the receiver from which leading and trailing blanks have been trimmed."

	| first last |
	first := string indexOfAnyOf: CharacterSet nonSeparators startingAt: 1.
	first = 0 ifTrue: [ ^'' ].  "no non-separator character"
	last := string lastIndexOfAnyOf: CharacterSet nonSeparators startingAt: self size ifAbsent: [self size].
	(first = 1 and: [ last = self size ]) ifTrue: [ ^self copy ].
	^self
		copyFrom: first
		to: last

]

{ #category : #converting }
Text >> withSqueakLineEndings [
	"Answer a copy of myself in which all sequences of <CR><LF> or <LF> have been changed to <CR>"
	| newText |
	(string includes: Character lf) ifFalse: [ ^self copy ].
	newText := self copyReplaceAll: String crlf with: String cr asTokens: false.
	(newText asString includes: Character lf) ifFalse: [ ^newText ].
	^newText copyReplaceAll: String lf with: String cr asTokens: false.
]

{ #category : #converting }
Text >> withoutLeadingBlanks [
	"Return a copy of the receiver from which leading blanks have been trimmed."

	| first |
	first := string indexOfAnyOf: CharacterSet nonSeparators startingAt: 1.
	first = 0 ifTrue: [ ^'' ].  "no non-separator character"
	first = 1 ifTrue: [ ^self copy ].
	^self
		copyFrom: first
		to: self size

]
