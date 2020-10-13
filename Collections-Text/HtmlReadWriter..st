"
A HtmlReadWriter is used to read a Text object from a string containing HTML or writing a Text object to a string with HTML tags representing the text attributes.

It does two things currently:
1) Setting text attributes on the beginning of tags, e.g. setting a bold text attribute when seeing a <b> tag.
2) Changing the resulting string, e.g. replacing a <br> with a Character cr.

The implementation works by pushing attributes on a stack on every opening tag. On the corresponding closing tag, the attribute is poped from the stack and stored in an array of attribute runs. From this array the final string is constructed.

## Notes on the implementation
- The final run array is completely constructed while parsing so it has to be correct with regard to the length of the runs. There is no consolidation except for merging neighboring runs which include the same attributes.
- The *count* variable is the position in the source string, the *offset* is the number of skipped characters, for example ones that denote a tag.
- The stack contains elements which are of the form: {text attributes. current start index. original start}
"
Class {
	#name : #HtmlReadWriter,
	#superclass : #TextReadWriter,
	#instVars : [
		'count',
		'offset',
		'runStack',
		'runArray',
		'string',
		'breakLines'
	],
	#category : #'Collections-Text'
}

{ #category : #private }
HtmlReadWriter >> activateAttributesEnding: ending starting: starting [ 

	starting
		select: [:attribute | attribute shouldFormBlocks]
		thenDo: [: attribute |
			(ending includes: attribute) ifFalse: [self writeStartTagFor: attribute]];
		reject: [:attribute | attribute shouldFormBlocks]
		thenDo: [: attribute | self writeStartTagFor: attribute].
]

{ #category : #private }
HtmlReadWriter >> addCharacter: aCharacter [

	string add: aCharacter.
	count := count + 1.
]

{ #category : #private }
HtmlReadWriter >> addString: aString [

	string addAll: aString.
	count := count + aString size.
]

{ #category : #accessing }
HtmlReadWriter >> breakLines [

	^ breakLines
]

{ #category : #accessing }
HtmlReadWriter >> breakLines: aBoolean [

	breakLines := aBoolean
]

{ #category : #'stream emulation' }
HtmlReadWriter >> cr [

	self breakLines ifTrue: [stream nextPutAll: '<br>'].
	^ stream cr
]

{ #category : #private }
HtmlReadWriter >> deactivateAttributesEnding: ending starting: starting [
	
	ending reversed
		reject: [:attribute | attribute shouldFormBlocks]
		thenDo: [: attribute | self writeEndTagFor: attribute];
		select: [:attribute | attribute shouldFormBlocks]
		thenDo: [: attribute |
			(starting includes: attribute) ifFalse: [self writeEndTagFor: attribute]].
]

{ #category : #private }
HtmlReadWriter >> httpGetImage: url [
	"To not add a direct dependency to WebClient, provide this hook for getting am image from an HTTP url. Maybe we can have this via an AppRegistry at some point. Maybe extend WebBrowser."
	
	(url beginsWith: 'code://') ifTrue: [
		"Same support for Smalltalk expressions as in TextURL >> #actOnClickFor:."
		^ ([Compiler evaluate: (url allButFirst: 7)] ifError: [nil])
			ifNotNil: [:object | object isForm ifTrue: [object] ifFalse: [nil]]].
	
	^ (Smalltalk classNamed: 'WebClient') ifNotNil: [:client |
		([client httpGet: url] ifError: [nil]) ifNotNil: [:response |
			response code = 200 ifFalse: [nil] ifTrue: [
				[Form fromBinaryStream: response content asByteArray readStream]
					ifError: [nil]]]]
]

{ #category : #accessing }
HtmlReadWriter >> ignoredTags [
	"Because we cannot process all of them."

	^ #(body script table tr td ul ol li form select option input)
]

{ #category : #'initialize-release' }
HtmlReadWriter >> initialize [

	super initialize.
	self breakLines: true.
]

{ #category : #testing }
HtmlReadWriter >> isTagIgnored: aTag [

	| space t |
	t := aTag copyWithoutAll: '</>'.
	space := t indexOf: Character space.
	t := space > 0
		ifTrue: [t copyFrom: 1 to: space - 1]
		ifFalse: [t].
	^ self ignoredTags includes: t
]

{ #category : #mapping }
HtmlReadWriter >> mapATag: aTag [

	| result startIndex stopIndex attribute |
	result := OrderedCollection new.
	
	"<a href=""http://google.de"">"
	attribute := 'href'.
	startIndex := aTag findString: attribute.
	startIndex > 0 ifTrue: [
		startIndex := aTag findString: '"' startingAt: startIndex+attribute size.
		startIndex > 0
			ifTrue: [stopIndex := aTag findString: '"' startingAt: startIndex+1]
			ifFalse: [
				"URLs without quotes..."
				startIndex := aTag findString: '=' startingAt: startIndex+attribute size.
				stopIndex := aTag findString: '>' startingAt: startIndex+1].		
		result add: (TextURL new url: (aTag copyFrom: startIndex+1 to: stopIndex-1))].
	
	^ result
]

{ #category : #mapping }
HtmlReadWriter >> mapAlignmentTag: aTag [

	| attributeStart |
	" special html case ".
	aTag = '<center>' ifTrue: [^ {TextAlignment centered}].
	
	"<div align=justify> or <div align=""right"">"
	attributeStart := aTag findString: 'align='.
	attributeStart > 0 ifTrue: [
		| attributeRest |
		attributeRest := aTag copyAfter: $=.
		attributeRest first = $" ifTrue: [attributeRest := attributeRest allButFirst].  " quoted case "
		^ self mapAlignmentValue: (attributeRest findTokens: ' ">') first].
	^ #()
]

{ #category : #mapping }
HtmlReadWriter >> mapAlignmentValue: aString [

	(aString = 'center' or: [aString = 'middle']) ifTrue: [^ {TextAlignment centered}].
	aString = 'left' ifTrue: [^ {TextAlignment leftFlush}].
	aString = 'right' ifTrue: [^ {TextAlignment rightFlush}].
	aString = 'justify'  ifTrue: [^ {TextAlignment justified}].
	^ #()
]

{ #category : #mapping }
HtmlReadWriter >> mapCloseCodeTag [

	| theDoIt |
	theDoIt := runStack top first
		detect: [:attribute | attribute isKindOf: TextDoIt]
		ifNone: [^ self "nothing found, ignore"].
	theDoIt evalString: (String withAll: (string copyFrom: runStack top third to: string size)).
]

{ #category : #mapping }
HtmlReadWriter >> mapCodeTag [

	^ {TextDoIt new} "yet uninitialized"
]

{ #category : #mapping }
HtmlReadWriter >> mapContainerTag: aTag [

	| result styleStart styleEnd styleAttributes |
	result := OrderedCollection new.
	styleStart := (aTag findString: 'style="' ) + 7.
	styleStart <= 7 ifTrue: [^#()].
	styleEnd := (aTag findString: '"' startingAt: styleStart) - 1.
	styleAttributes := (aTag copyFrom: styleStart to: styleEnd) subStrings: ';'.
	styleAttributes do: [:ea | |keyValue key value|
		keyValue := (ea subStrings: ':') collect: [:s | s withBlanksTrimmed].
		key := keyValue first asLowercase.
		value := keyValue second.
		keyValue size = 2 ifTrue: [
			key = 'color' ifTrue: [result add: (TextColor color: (Color fromString: value))].
			(key beginsWith: 'font') ifTrue: [
				(value includesSubstring: 'bold')
					ifTrue: [result add: TextEmphasis bold].
				(value includesSubstring: 'italic')
					ifTrue: [result add: TextEmphasis italic]]]].
	^ result
]

{ #category : #mapping }
HtmlReadWriter >> mapFontTag: aTag [

	| result colorStartIndex colorStopIndex attribute |
	result := OrderedCollection new.
	
	"<font color=""#00FFCC""> or <font color=""green"">"
	attribute := 'color'.
	colorStartIndex := aTag findString: attribute.
	colorStartIndex > 0 ifTrue: [
		colorStartIndex := aTag findString: '"' startingAt: colorStartIndex+attribute size.		
		colorStopIndex := aTag findString: '"' startingAt: colorStartIndex+1.
		result add: (TextColor color:
			(Color fromString: (aTag copyFrom: colorStartIndex+1 to: colorStopIndex-1)))].

	^ result
]

{ #category : #mapping }
HtmlReadWriter >> mapImgTag: aTag [

	| result startIndex stopIndex attribute src form scaleFactor |
	result := OrderedCollection new.

	"<img src=""https://squeak.org/img/downloads/image.png"">"
	attribute := 'src'.
	startIndex := aTag findString: attribute.
	startIndex > 0 ifTrue: [
		startIndex := aTag findString: '"' startingAt: startIndex+attribute size.
		startIndex > 0
			ifTrue: [stopIndex := aTag findString: '"' startingAt: startIndex+1]
			ifFalse: [
				"URLs without quotes..."
				startIndex := aTag findString: '=' startingAt: startIndex+attribute size.
				stopIndex := aTag findString: '>' startingAt: startIndex+1].
		src := aTag copyFrom: startIndex+1 to: stopIndex-1.
		form := (self httpGetImage: src) ifNil: [(Form dotOfSize: 12 color: Color veryLightGray)].
		(scaleFactor := RealEstateAgent scaleFactor) = 1.0
			ifFalse: [form := form scaledToSize: form extent * scaleFactor].
		result
			add: form asTextAnchor;
			add: (TextColor color: Color transparent)].
	^ result
]

{ #category : #mapping }
HtmlReadWriter >> mapTagToAttribute: aTag [

	aTag = '<b>' ifTrue: [^ {TextEmphasis bold}].
	aTag = '<i>' ifTrue: [^ {TextEmphasis italic}].
	aTag = '<u>' ifTrue: [^ {TextEmphasis underlined}].
	aTag = '<s>' ifTrue: [^ {TextEmphasis struckOut}].
	aTag = '<code>' ifTrue: [^ self mapCodeTag].
	aTag = '<pre>' ifTrue: [self breakLines: false. ^ {}].
	(#('<div' '<span' '<center>' ) anySatisfy: [:ea | aTag beginsWith: ea])
		ifTrue: [^(self mapAlignmentTag: aTag) union: (self mapContainerTag: aTag)].
	(aTag beginsWith: '<font') ifTrue: [^ self mapFontTag: aTag].
	(aTag beginsWith: '<a') ifTrue: [^ self mapATag: aTag].
	(aTag beginsWith: '<img') ifTrue: [^ self mapImgTag: aTag].

	"h1, h2, h3, ..."
	(aTag second = $h and: [aTag third isDigit])
		ifTrue: [^ {TextEmphasis bold}].

	^ {}
]

{ #category : #'stream emulation' }
HtmlReadWriter >> nextPut: aCharacter [

	^ stream nextPut: aCharacter
]

{ #category : #'stream emulation' }
HtmlReadWriter >> nextPutAll: aCollection [

	^ stream nextPutAll: aCollection
]

{ #category : #private }
HtmlReadWriter >> nextPutText: aText [

	| previous |
	previous := #().
	self activateAttributesEnding: #() starting: previous. "for consistency"
	aText runs
		withStartStopAndValueDo: [:start :stop :attributes | 
			self
				deactivateAttributesEnding: previous starting: attributes;
				activateAttributesEnding: previous starting: attributes;
				writeContent: (aText string copyFrom: start to: stop).
			previous := attributes].
	self deactivateAttributesEnding: previous starting: #().
]

{ #category : #private }
HtmlReadWriter >> nextText [

	count := 0.
	offset := 0. "To ignore characters in the input string that are used by tags."
	
	runStack := Stack new.
	
	runArray := RunArray new.
	string := OrderedCollection new.
	
	"{text attributes. current start index. original start}"
	runStack push: {OrderedCollection new. 1. 1}.

	[stream atEnd] whileFalse: [self processNextTag].
	self processRunStackTop. "Add last run."

	string := String withAll: string.
	runArray coalesce.
	
	^ Text
		string: string
		runs: runArray
]

{ #category : #reading }
HtmlReadWriter >> processComment: aComment [

]

{ #category : #reading }
HtmlReadWriter >> processEmptyTag: aTag [

	(aTag beginsWith: '<br') ifTrue: [
		self addCharacter: Character cr.
		^ self].
	
	(aTag beginsWith: '<img') ifTrue:[
		^ self processStartTag: aTag].
	
	(self isTagIgnored: aTag)
		ifTrue: [^ self].
		
	"TODO... what?"
]

{ #category : #reading }
HtmlReadWriter >> processEndTag: aTag [

	| index tagName |
	index := count - offset.
	tagName := aTag copyFrom: 3 to: aTag size - 1.

	(self isTagIgnored: tagName) ifTrue: [^ self].
	
	tagName = 'code' ifTrue: [self mapCloseCodeTag].
	tagName = 'pre' ifTrue: [self breakLines: true].
		
	self processRunStackTop.

	runStack pop.
	runStack top at: 2 put: index + 1.
]

{ #category : #reading }
HtmlReadWriter >> processEndTagEagerly: aTag [
	"Not all tags need an end tag. Simulate that here."
	
	(aTag beginsWith: '<img')
		ifTrue: [^ self processEndTag: '</img>'].
]

{ #category : #reading }
HtmlReadWriter >> processHtmlEscape: aString [
	| escapeSequence |
	escapeSequence := aString copyFrom: 2 to: aString size - 1.
	escapeSequence first = $# ifTrue: [^ self processHtmlEscapeNumber: escapeSequence allButFirst].
	(String htmlEntities at: (aString copyFrom: 2 to: aString size - 1) ifAbsent: [])
		ifNotNil: [:char | 
			self addCharacter: char].
]

{ #category : #private }
HtmlReadWriter >> processHtmlEscapeNumber: aString [
	| number |
	number := aString first = $x
		ifTrue: [ '16r', aString allButFirst ]
		ifFalse: [ aString ].
	self addCharacter: number asNumber asCharacter.
	
]

{ #category : #reading }
HtmlReadWriter >> processNextTag [

	| tag htmlEscape lookForNewTag lookForHtmlEscape tagFound valid inComment inTagString |
	lookForNewTag := true.
	lookForHtmlEscape := false.
	tagFound := false.
	tag := OrderedCollection new.
	htmlEscape := OrderedCollection new.
	inComment := false.
	inTagString := false.
	
	[stream atEnd not and: [tagFound not]] whileTrue: [
		| character |
		character := stream next.
		valid := (#(10 13) includes: character asciiValue) not.
		count := count + 1.
	
		character = $< ifTrue: [lookForNewTag := false].
		character = $& ifTrue: [inComment ifFalse: [lookForHtmlEscape := true]].
		
		lookForNewTag
			ifTrue: [
				lookForHtmlEscape
					ifFalse: [
						(valid or: [self breakLines not])
							ifTrue: [string add: character]
							ifFalse: [offset := offset + 1]]
					ifTrue: [valid ifTrue: [htmlEscape add: character]. offset := offset + 1]]
			ifFalse: [valid ifTrue: [tag add: character]. offset := offset + 1].

		"Toggle within tag string/text."
		(character = $" and: [lookForNewTag not])
			ifTrue: [inTagString := inTagString not].
		
		inComment := ((lookForNewTag not and: [tag size >= 4])
			and: [tag beginsWith: '<!--'])
			and: [(tag endsWith: '-->') not].

		(((character = $> and: [inComment not]) and: [lookForNewTag not]) and: [inTagString not]) ifTrue: [
			lookForNewTag := true.
			(tag beginsWith: '<!--')
				ifTrue: [self processComment: (String withAll: tag)]
				ifFalse: [tag second ~= $/
					ifTrue: [
						(tag atLast: 2) == $/
							ifTrue: [self processEmptyTag: (String withAll: tag)]
							ifFalse: [self processStartTag: (String withAll: tag)]]
					ifFalse: [self processEndTag: (String withAll: tag)]].			
			tagFound := true].

		(((character = $; and: [lookForNewTag])
			and: [htmlEscape notEmpty]) and: [htmlEscape first = $&]) ifTrue: [
				lookForHtmlEscape := false.
				self processHtmlEscape: (String withAll: htmlEscape).
				htmlEscape := OrderedCollection new]].

]

{ #category : #reading }
HtmlReadWriter >> processRunStackTop [
	"Write accumulated attributes to run array."
	
	| currentIndex start attrs |
	currentIndex := count - offset.
	start := runStack top second.
	attrs := runStack top first.
	runArray
		add: attrs asArray
		withOccurrences: currentIndex - start + 1.
]

{ #category : #reading }
HtmlReadWriter >> processStartTag: aTag [

	| index |
	(self isTagIgnored: aTag) ifTrue: [^ self].

	index := count - offset.

	aTag = '<br>' ifTrue: [
		self addCharacter: Character cr.
		^ self].

	(aTag beginsWith: '<img') ifTrue: [
		self addString: Character startOfHeader asString.
		offset := offset + 1.
		index := index - 1].
	
	self processRunStackTop. "To add all attributes before the next tag adds some."

	"Copy attr list and add new attr."
	runStack push: ({runStack top first copy addAll: (self mapTagToAttribute: aTag); yourself. index + 1 . index + 1}).

	"For tags such as <img>, we should simulate the closing tag because there won't be any."
	self processEndTagEagerly: aTag.
]

{ #category : #writing }
HtmlReadWriter >> writeContent: aString [

	aString do: [:char |
		(#(10 13) includes: char asciiValue)
			ifTrue: [self cr]
			ifFalse: [char = Character tab
				ifTrue: [self nextPutAll: '&nbsp;&nbsp;&nbsp;&nbsp;']
				ifFalse: [(String htmlEntities keyAtValue: char ifAbsent: [])
					ifNil: [self nextPut: char]
					ifNotNil: [:escapeSequence |
						self
							nextPut: $&;
							nextPutAll: escapeSequence;
							nextPut: $;]]]].
]

{ #category : #writing }
HtmlReadWriter >> writeEndTagFor: aTextAttribute [

	[aTextAttribute closeHtmlOn: self]
		on: MessageNotUnderstood do: []
]

{ #category : #writing }
HtmlReadWriter >> writeStartTagFor: aTextAttribute [

	[aTextAttribute openHtmlOn: self]
		on: MessageNotUnderstood do: [].
]
