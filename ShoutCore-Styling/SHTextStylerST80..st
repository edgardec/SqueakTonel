"
I style Smalltalk methods and expressions.

My 'styleTable' class instance var holds an array ofArrays which control how each token is styled/coloured. See my defaultStyleTable class method for its structure.
My styleTable can be changed by either modifying the defaultStyleTable class method and then executing SHTextStylerST80 initialize ; or by giving me a new styleTable through my #styleTable: class method.

My 'textAttributesByPixelSize' class instance var contains a dictionary of dictionaries.
	The key is a pixelSize and the value a Dictionary from token type Symbol to TextAttribute array.
	It is created/maintained automatically.
	
I also install these 3 preferences when my class initialize method is executed....
	#syntaxHighlightingAsYouType  - controls whether methods are styled in browsers
	#syntaxHighlightingAsYouTypeAnsiAssignment - controls whether assignments are formatted to be :=
	#syntaxHighlightingAsYouTypeLeftArrowAssignment - controls whether assignments are formatted to be _

I reimplement #unstyledTextFrom: so that TextActions are preserved in the unstyled text 
	
	
	
	
	 
	

"
Class {
	#name : #SHTextStylerST80,
	#superclass : #SHTextStyler,
	#instVars : [
		'classOrMetaClass',
		'workspace',
		'font',
		'parser',
		'formatAssignments',
		'environment',
		'sourceMap',
		'processedSourceMap',
		'pixelHeight',
		'attributesByPixelHeight',
		'parseAMethod',
		'context'
	],
	#classVars : [
		'SyntaxHighlightingAsYouType',
		'SyntaxHighlightingAsYouTypeAnsiAssignment',
		'SyntaxHighlightingAsYouTypeLeftArrowAssignment',
		'TextAttributesByPixelHeight'
	],
	#category : #'ShoutCore-Styling'
}

{ #category : #preferences }
SHTextStylerST80 class >> ansiAssignmentPreferenceChanged [
	"the user has changed the syntaxHighlightingAsYouTypeAnsiAssignment setting.
	If they have turned it on then force syntaxHighlightingAsYouTypeLeftArrowAssignment
	to be turned off"
	self syntaxHighlightingAsYouTypeAnsiAssignment 
		ifTrue: [self syntaxHighlightingAsYouTypeLeftArrowAssignment: false]
]

{ #category : #preferences }
SHTextStylerST80 class >> applyUserInterfaceTheme [

	self resetTextAttributesByPixelHeight.
]

{ #category : #preferences }
SHTextStylerST80 class >> leftArrowAssignmentPreferenceChanged [
	"the user has changed the syntaxHighlightingAsYouTypeLeftArrowAssignment setting.
	If they have turned it on then force syntaxHighlightingAsYouTypeAnsiAssignment
	to be turned off"
	self syntaxHighlightingAsYouTypeLeftArrowAssignment 
		ifTrue: [self syntaxHighlightingAsYouTypeAnsiAssignment: false]
]

{ #category : #'style table' }
SHTextStylerST80 class >> resetTextAttributesByPixelHeight [

	TextAttributesByPixelHeight := nil.
]

{ #category : #preferences }
SHTextStylerST80 class >> syntaxHighlightingAsYouType [
	<preference: 'syntaxHighlightingAsYouType'
		category: 'browsing'
		description: 'Enable, or disable, Shout - Syntax Highlighting As You Type. When enabled, code in Browsers and Workspaces is styled to reveal its syntactic structure. When the code is changed (by typing some characters, for example), the styling is changed so that it remains in sync with the modified code.'
		type: #Boolean>
	^SyntaxHighlightingAsYouType ifNil: [true]
]

{ #category : #preferences }
SHTextStylerST80 class >> syntaxHighlightingAsYouType: aBoolean [
	SyntaxHighlightingAsYouType := aBoolean.
]

{ #category : #preferences }
SHTextStylerST80 class >> syntaxHighlightingAsYouTypeAnsiAssignment [
	<preference: 'syntaxHighlightingAsYouTypeAnsiAssignment'
		category: 'browsing'
		description: 'If true, and syntaxHighlightingAsYouType is enabled,  all left arrow assignments ( _ ) will be converted to the ANSI format ( := ) when a method is selected in a Browser. Whilst editing a method, this setting has no effect - both the left arrow and the ansi format may be used.'
		type: #Boolean>
	^SyntaxHighlightingAsYouTypeAnsiAssignment ifNil: [true]
]

{ #category : #preferences }
SHTextStylerST80 class >> syntaxHighlightingAsYouTypeAnsiAssignment: aBoolean [
	SyntaxHighlightingAsYouTypeAnsiAssignment := aBoolean.
]

{ #category : #preferences }
SHTextStylerST80 class >> syntaxHighlightingAsYouTypeLeftArrowAssignment [
	<preference: 'syntaxHighlightingAsYouTypeLeftArrowAssignment'
		category: 'browsing'
		description: 'If true, and syntaxHighlightingAsYouType is enabled,  all ANSI format assignments ( := ) will be converted to left arrows ( _ ) when a method is selected in a Browser. Whilst editing a method, this setting has no effect - both the left arrow and the ansi format may be used.'
		type: #Boolean>
	^SyntaxHighlightingAsYouTypeLeftArrowAssignment ifNil: [true]
]

{ #category : #preferences }
SHTextStylerST80 class >> syntaxHighlightingAsYouTypeLeftArrowAssignment: aBoolean [
	SyntaxHighlightingAsYouTypeLeftArrowAssignment := aBoolean.
]

{ #category : #'style table' }
SHTextStylerST80 class >> textAttributesByPixelHeight [
	"A cache for text attributes used by all instances of text styler."
	^ TextAttributesByPixelHeight ifNil: [ TextAttributesByPixelHeight := Dictionary new ]
]

{ #category : #'style table' }
SHTextStylerST80 class >> textAttributesByPixelHeightAt: aNumber put: someTextAttributes [
	"Thread-safety first."
	
	TextAttributesByPixelHeight := self textAttributesByPixelHeight copy
		at: aNumber put: someTextAttributes;
		yourself.
	^ someTextAttributes
]

{ #category : #preferences }
SHTextStylerST80 class >> themeProperties [

	^ {
		{ #default. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #invalid. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #excessCode. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #comment. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #unfinishedComment. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #'$'. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #character. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #integer. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #number. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #-. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #symbol. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #stringSymbol. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #literalArray. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #string. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #unfinishedString. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #assignment. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #ansiAssignment. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #literal. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #keyword. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #binary. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #unary. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #incompleteKeyword. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #incompleteBinary. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #incompleteUnary. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #undefinedKeyword. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #undefinedBinary. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #undefinedUnary. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #patternKeyword. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #patternBinary. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #patternUnary. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #self. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #super. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #true. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #false. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #nil. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #thisContext. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #return. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #patternArg. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #methodArg. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #blockPatternArg. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #blockArg. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #argument. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #blockArgColon. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #leftParenthesis. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #rightParenthesis. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #leftParenthesis1. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #rightParenthesis1. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #leftParenthesis2. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #rightParenthesis2. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #leftParenthesis3. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #rightParenthesis3. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #leftParenthesis4. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #rightParenthesis4. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #leftParenthesis5. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #rightParenthesis5. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #leftParenthesis6. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #rightParenthesis6. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #leftParenthesis7. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #rightParenthesis7. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #blockStart. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #blockEnd. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #blockStart1. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #blockEnd1. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #blockStart2. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #blockEnd2. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #blockStart3. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #blockEnd3. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #blockStart4. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #blockEnd4. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #blockStart5. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #blockEnd5. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #blockStart6. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #blockEnd6. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #blockStart7. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #blockEnd7. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #arrayStart. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #arrayEnd. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #arrayStart1. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #arrayEnd1. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #byteArrayStart. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #byteArrayEnd. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #byteArrayStart1. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #byteArrayEnd1. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #leftBrace. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #rightBrace. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #cascadeSeparator. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #statementSeparator. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #externalCallType. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #externalCallTypePointerIndicator. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #primitiveOrExternalCallStart. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #primitiveOrExternalCallEnd. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #methodTempBar. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #blockTempBar. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #blockArgsBar. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #primitive. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #pragmaKeyword. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #pragmaUnary. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #pragmaBinary. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #externalFunctionCallingConvention. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #module. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #blockTempVar. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #blockPatternTempVar. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #instVar. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #workspaceVar. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #undefinedIdentifier. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #incompleteIdentifier. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #tempVar. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #patternTempVar. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #poolConstant. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #classVar. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.
		{ #globalVar. 'Styling'. 'Specify color, emphasis, and font in a triple.' }.	
	}
]

{ #category : #updating }
SHTextStylerST80 >> applyUserInterfaceTheme [
	"My dependents should take care of invalidating my caches and then ask me to style again. It is of no use to invalidate my caches right now because I have no idea when my dependents will ask me to style again."
]

{ #category : #'style table' }
SHTextStylerST80 >> attributesByPixelHeight [

	^ attributesByPixelHeight ifNil: [
		attributesByPixelHeight := self attributesByPixelHeight: self pixelHeight]
]

{ #category : #'style table' }
SHTextStylerST80 >> attributesByPixelHeight: aNumber [

	^ self class textAttributesByPixelHeight
		at: aNumber 
		ifAbsent: [
			self class
				textAttributesByPixelHeightAt: aNumber
				put: (self createTextAttributesForPixelHeight: aNumber)]
]

{ #category : #'style table' }
SHTextStylerST80 >> attributesFor: aSymbol [

	^ self attributesByPixelHeight at: aSymbol ifAbsent: nil
]

{ #category : #updating }
SHTextStylerST80 >> canApplyUserInterfaceTheme [

	^ false
]

{ #category : #accessing }
SHTextStylerST80 >> classOrMetaClass: aBehavior [
	classOrMetaClass := aBehavior
]

{ #category : #accessing }
SHTextStylerST80 >> context: aContext [
	context := aContext
]

{ #category : #private }
SHTextStylerST80 >> convertAssignmentsToAnsi: aText [
	"If the Preference is to show ansiAssignments then answer a copy of  <aText> where each  left arrow assignment is replaced with a ':=' ansi assignment. A parser is used so that each left arrow is only replaced if it occurs within an assigment statement"

	^self replaceStringForRangesWithType: #assignment with: ':=' in: aText
]

{ #category : #private }
SHTextStylerST80 >> convertAssignmentsToLeftArrow: aText [
	"If the Preference is to show leftArrowAssignments then answer a copy of  <aText> where each ansi assignment (:=) is replaced with a left arrow. A parser is used so that each ':=' is only replaced if it actually occurs within an assigment statement"

	^self replaceStringForRangesWithType: #ansiAssignment with: '_' in: aText
]

{ #category : #'style table' }
SHTextStylerST80 >> createAttributeArrayForColor: aColorOrNil emphasis: anEmphasisOrArrayorNil font: aFontOrNil [
	"Answer a new Array containing any non nil TextAttributes specified"

	| answer emphArray |
	answer := Array new.
	aColorOrNil ifNotNil: [answer := answer, {TextColor color: aColorOrNil}].
	anEmphasisOrArrayorNil ifNotNil: [
		emphArray := anEmphasisOrArrayorNil isArray 
			ifFalse: [{anEmphasisOrArrayorNil}] 
			ifTrue: [anEmphasisOrArrayorNil].
		answer := answer, emphArray].
	aFontOrNil ifNotNil: [
		answer := answer, {TextFontReference toFont: aFontOrNil}].
	^answer
]

{ #category : #'style table' }
SHTextStylerST80 >> createTextAttributesForPixelHeight: aNumber [

	| result |	 
	result := IdentityDictionary new.
	result at: #default put: {}. "Required as fall-back for non-existing attributes."
	
	self class themeProperties do: [:each |
		| spec element emphasis font color |
		element := each first.
		spec := self userInterfaceTheme perform: element.
		spec isArray ifFalse: [spec := {spec}]. "Support color-only hints."
		
		color := spec first ifNotNil: [:colorSpec | Color colorFrom: colorSpec].
		emphasis := spec at: 2 ifAbsent:[nil].
		font := spec at: 3 ifAbsent: [nil].
		
		"Support for named text styles."
		font isString ifTrue: [
			| textStyle |
			textStyle := TextStyle named: font.
			font := textStyle ifNotNil: [textStyle fontOfSize: aNumber]].

		(self createAttributeArrayForColor: color emphasis: emphasis font: font)
			ifNotEmpty: [:attrArray | result at: element put: attrArray]].
	^ result
	
]

{ #category : #accessing }
SHTextStylerST80 >> environment: anObject [
	environment := anObject
]

{ #category : #accessing }
SHTextStylerST80 >> font: aFont [
	font := aFont
]

{ #category : #accessing }
SHTextStylerST80 >> formatAssignments: aBoolean [
	"determines whether assignments are reformatted according to the Preferences,
	or left as they are"
	formatAssignments := aBoolean
]

{ #category : #'initialize-release' }
SHTextStylerST80 >> initialize [
	super initialize.
	formatAssignments := true
]

{ #category : #accessing }
SHTextStylerST80 >> parseAMethod: aBoolean [

	parseAMethod := aBoolean
]

{ #category : #private }
SHTextStylerST80 >> parseableSourceCodeTemplate [

	^'messageSelectorAndArgumentNames
	"comment stating purpose of message"

	| temporary variable names |
	statements'
]

{ #category : #private }
SHTextStylerST80 >> pixelHeight [
	"In Morphic the receiver will have been given a code font, in MVC the font will be nil. So when the font is nil, answer the pixelHeight of the MVC Browsers' code font, i.e. TextStyle defaultFont pixelHeight"
	^pixelHeight 
		ifNil:[pixelHeight := (font 
				ifNil:[TextStyle defaultFont]) pixelSize]
]

{ #category : #private }
SHTextStylerST80 >> privateFormat: aText [
	"Perform any formatting of aText necessary and answer either aText, or a formatted copy of aText"

	aText asString = Object sourceCodeTemplate
		ifTrue:[
			"the original source code template does not parse,
			replace it with one that does"
			^self parseableSourceCodeTemplate asText].
	formatAssignments
		ifTrue:[
			self class syntaxHighlightingAsYouTypeAnsiAssignment 
				ifTrue:[^self convertAssignmentsToAnsi: aText].
			self class syntaxHighlightingAsYouTypeLeftArrowAssignment 
				ifTrue:[^self convertAssignmentsToLeftArrow: aText]].		
	^aText
]

{ #category : #private }
SHTextStylerST80 >> privateStyle: aText [

	| ranges |
	ranges := self rangesIn: aText setWorkspace: true.
	ranges ifNotNil: [self setAttributesIn: aText fromRanges: ranges]
]

{ #category : #private }
SHTextStylerST80 >> rangesIn: aText setWorkspace: aBoolean [
	"Answer a collection of SHRanges by parsing aText.
	When formatting it is not necessary to set the workspace, and this can make the parse take less time, so aBoolean specifies whether the parser should be given the workspace"

	| shoutParserClass |
	"Switch parsers if we have to"
	shoutParserClass := (classOrMetaClass ifNil:[Object]) shoutParserClass.
	parser class == shoutParserClass ifFalse:[parser := shoutParserClass new].
	parser parseAMethod: parseAMethod.
	^parser 
		rangesIn: aText asString 
		classOrMetaClass: classOrMetaClass 
		workspace: (aBoolean ifTrue:[workspace])  
		environment: environment
		context: context
]

{ #category : #private }
SHTextStylerST80 >> replaceStringForRangesWithType: aSymbol with: aString in: aText [ 
	"Answer aText if no replacements, or a copy of aText with 
	each range with a type of aSymbol replaced by aString"

	| answer rangesToReplace adjustSourceMap increaseInLength stringSize |	
	rangesToReplace := self rangesIn: aText setWorkspace: false.
	rangesToReplace removeAllSuchThat: [ :range | range type ~~ aSymbol ].
	rangesToReplace isEmpty ifTrue: [^aText].
	answer := aText copy.
	increaseInLength := 0.
	adjustSourceMap := sourceMap notNil and:[sourceMap ~~ processedSourceMap].
	(rangesToReplace isSortedBy: [ :a :b | a start <= b start ]) ifFalse: [
		"Can this ever happen?"
		rangesToReplace sort: [ :a :b | a start <= b start ] ].
	stringSize := aString size.
	rangesToReplace do: [ :range |
		| end start thisIncrease | 
		start := range start + increaseInLength.
		end := range end + increaseInLength.
		answer 	replaceFrom: start to: end with: aString.
		thisIncrease := stringSize - range length.
		increaseInLength := increaseInLength + thisIncrease.
		adjustSourceMap ifTrue: [
			sourceMap do: [ :association |
				| first newFirst last newLast |
				first := newFirst := association value first.
				last := newLast := association value last.
				first > start ifTrue: [ newFirst := first + thisIncrease ].
				last > start ifTrue: [ newLast := last + thisIncrease ].
				(first ~= newFirst or: [ last ~= newLast ])
					ifTrue:[ association value: (newFirst to: newLast) ] ] ] ].
	adjustSourceMap ifTrue:[processedSourceMap := sourceMap]. 
	^answer
]

{ #category : #'initialize-release' }
SHTextStylerST80 >> reset [

	attributesByPixelHeight := nil.
]

{ #category : #private }
SHTextStylerST80 >> setAttributesIn: aText fromRanges: ranges [

	| defaultAttributes newRuns newValues lastAttributes oldRuns nextIndex lastCount | 		
	oldRuns := aText runs.
	defaultAttributes := self attributesFor: #default.
	newRuns := OrderedCollection new: ranges size * 2 + 1.
	newValues := OrderedCollection new: ranges size * 2 + 1.
	lastAttributes := nil.
	nextIndex := 1.
	lastCount := 0.
	ranges do: [ :range |
		| attributes |
		nextIndex < range start ifTrue: [ 
			lastAttributes == defaultAttributes 
				ifTrue: [
					lastCount := lastCount + range start - nextIndex.
					newRuns at: newRuns size put: lastCount ]
				ifFalse: [
					lastCount := range start - nextIndex.
					newRuns addLast: lastCount. 
					lastAttributes := defaultAttributes.
					newValues addLast: lastAttributes ].
			nextIndex := range start ].
		attributes := (self attributesFor: range type) ifNil: [ defaultAttributes ].
		lastAttributes == attributes
			ifTrue: [ 
				lastCount := lastCount + range end - nextIndex + 1.
				newRuns at: newRuns size put: lastCount ]
			ifFalse: [
				lastCount := range end - nextIndex + 1.
				newRuns addLast: lastCount.
				lastAttributes := attributes.
				newValues addLast: lastAttributes ].
		nextIndex := range end + 1 ].
	nextIndex <= aText size ifTrue: [
		lastAttributes == defaultAttributes 
				ifTrue: [
					lastCount := lastCount + aText size - nextIndex + 1.
					newRuns at: newRuns size put: lastCount ]
				ifFalse: [
					lastCount := aText size - nextIndex + 1.
					newRuns addLast: lastCount.
					lastAttributes := defaultAttributes.
					newValues addLast: lastAttributes ] ].
	aText runs: (RunArray runs: newRuns values: newValues).
	oldRuns withStartStopAndValueDo: [ :start :stop :attribs |
		(attribs anySatisfy: [ :each | each shoutShouldPreserve ]) ifTrue: [
			attribs do: [ :each | aText addAttribute: each from: start to: stop ] ] ].
	
]

{ #category : #accessing }
SHTextStylerST80 >> sourceMap: aSortedCollection [
	"set the receiver's sourceMap to aSortedCollection.
	The sourceMap is used by a Debugger to select the appropriate
	ranges within its text. These ranges need to be adjusted if, and when, the receiver
	reformats the text that is displayed"

	sourceMap := aSortedCollection
]

{ #category : #converting }
SHTextStylerST80 >> unstyledTextFrom: aText [
	"Re-implemented so that TextActions are not removed from aText"
	| answer |	
	answer := super unstyledTextFrom: aText.
	aText runs withStartStopAndValueDo: [:start :stop :attribs |
		(attribs anySatisfy: [:each | each shoutShouldPreserve])
			ifTrue: [
				attribs do: [:eachAttrib | answer addAttribute: eachAttrib from: start to: stop]]].
	^answer
]

{ #category : #copying }
SHTextStylerST80 >> veryDeepInner: aDeepCopier [ 
	super veryDeepInner: aDeepCopier.
	classOrMetaClass := classOrMetaClass veryDeepCopyWith: aDeepCopier.
	workspace := workspace veryDeepCopyWith: aDeepCopier.
	"share the font?"
	parser := parser veryDeepCopyWith: aDeepCopier.
	sourceMap := sourceMap veryDeepCopyWith: aDeepCopier.
	processedSourceMap := processedSourceMap veryDeepCopyWith: aDeepCopier
]

{ #category : #accessing }
SHTextStylerST80 >> workspace: aWorkspace [
	workspace := aWorkspace
]
