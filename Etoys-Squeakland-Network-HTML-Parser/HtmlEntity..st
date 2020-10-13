"
<html>When HtmlParser runs, it generates a tree whose nodes are in HtmlEntity's subclasses.  There is a separate class for most of the available elements in HTML, though some are grouped together under generic classes like HtmlBoldEntity.

Methods of particular interest when modifying or adding subclasses are:
<ul>
<li>initialize:
<li>mayContain:
<li>addToFormatter:
</ul>

"
Class {
	#name : #HtmlEntity,
	#superclass : #Object,
	#instVars : [
		'contents',
		'attribs'
	],
	#classVars : [
		'ReverseCharacterEntities'
	],
	#category : #'Etoys-Squeakland-Network-HTML-Parser'
}

{ #category : #'character entities' }
HtmlEntity class >> convertToNumber: aString [
	"HtmlEntity convertToNumber: '25'"
	"HtmlEntity convertToNumber: 'xb7'"
	"HtmlEntity convertToNumber: 'o10'"
	| str ch |
	str := ReadStream on: aString asUppercase.
	ch := str peek.
	ch = $X ifTrue: [ str next. ^Number readFrom: str base: 16 ].
	ch = $O ifTrue: [ str next. ^Number readFrom: str base: 8 ].
	ch = $B ifTrue: [ str next. ^Number readFrom: str base: 2 ].
	^Number readFrom: str
]

{ #category : #'instance creation' }
HtmlEntity class >> forTag: aTag [
	"create a new entity based on the given tag"
	^self new initialize: aTag
]

{ #category : #'class initialization' }
HtmlEntity class >> initialize [
	"HtmlEntity initialize"

	ReverseCharacterEntities := Dictionary new: 128.
	#('quot' $" 'lt' $< 'amp' $& 'gt' $> 'rsquo' $' 'lsquo' $` 'rdquo' $" 'ldquo' $" ) pairsDo:
		[:s :c | ReverseCharacterEntities at: s put: c asciiValue].
	#('nbsp' 'iexcl' 'cent' 'pound' 'curren' 'yen' 'brvbar' 'sect' 'uml' 'copy' 'ordf' 'laquo' 'not' 'shy' 'reg' 'hibar' 'deg' 'plusmn' 'sup2' 'sup3' 'acute' 'micro' 'para' 'middot' 'cedil' 'sup1' 'ordm' 'raquo' 'frac14' 'frac12' 'frac34' 'iquest' 'Agrave' 'Aacute' 'Acirc' 'Atilde' 'Auml' 'Aring' 'AElig' 'Ccedil' 'Egrave' 'Eacute' 'Ecirc' 'Euml' 'Igrave' 'Iacute' 'Icirc' 'Iuml' 'ETH' 'Ntilde' 'Ograve' 'Oacute' 'Ocirc' 'Otilde' 'Ouml' 'times' 'Oslash' 'Ugrave' 'Uacute' 'Ucirc' 'Uuml' 'Yacute' 'THORN' 'szlig' 'agrave' 'aacute' 'acirc' 'atilde' 'auml' 'aring' 'aelig' 'ccedil' 'egrave' 'eacute' 'ecirc' 'euml' 'igrave' 'iacute' 'icirc' 'iuml' 'eth' 'ntilde' 'ograve' 'oacute' 'ocirc' 'otilde' 'ouml' 'divide' 'oslash' 'ugrave' 'uacute' 'ucirc' 'uuml' 'yacute' 'thorn' 'yuml' ) withIndexDo:
		[:s :i | ReverseCharacterEntities at: s put: i - 1 + 160].
]

{ #category : #'instance creation' }
HtmlEntity class >> new [
	^super new initialize
]

{ #category : #'character entities' }
HtmlEntity class >> valueOfHtmlEntity: specialEntity [
	"Return the character equivalent to the HTML entity."

	| value |
	(specialEntity beginsWith: '#')		"Handle numeric entities"
		ifTrue: [
			"NB: We can display only simple numeric special entities in the"
			"range [9..255] (HTML 3.2).  HTML 4.01 allows the specification of 16 bit"
			"characters, so we do a little fiddling to handle a few special cases"

			value := self convertToNumber: (specialEntity copyFrom: 2 to: specialEntity size).

			"Replace rounded left & right double quotes (HTML 4.01) with simple double quote"
			(value = 8220 or: [value = 8221]) ifTrue: [ value := $" asInteger ].

			"Replace rounded left & right single quotes (HTML 4.01) with simple single quote"
			(value = 8216 or: [value = 8217]) ifTrue: [ value := $' asInteger ].

			"Replace with a space if outside the normal range (arbitrary choice)"
			(value < 9 or: [value > 255]) ifTrue: [ value := 32 ].
			]
		ifFalse: [
			"Otherwise this is most likely a named character entity"
			value := ReverseCharacterEntities at: specialEntity ifAbsent: [^nil].
			].

	 ^Character value: value.
]

{ #category : #accessing }
HtmlEntity >> add: anObject [
	"add an object to the receiver"
	(anObject isKindOf: String)
		ifTrue: [contents add: (HtmlTextEntity new text: anObject)]
		ifFalse: [contents add: anObject]
]

{ #category : #contents }
HtmlEntity >> addEntity: anEntity [
	"add an entity to the receiver"
	contents add: anEntity
]

{ #category : #formatting }
HtmlEntity >> addToFormatter: aFormatter [
	"by default, just format our childer"
	contents do: [ :e | e addToFormatter: aFormatter ]
]

{ #category : #enumeration }
HtmlEntity >> allSubentitiesDo: aBlock [
	"perform the block recursively on all sub-entities"
	contents do: [ :e | 
		aBlock value: e .
		e allSubentitiesDo: aBlock.
	].
	
]

{ #category : #converting }
HtmlEntity >> asHtml [
	| aStream |
	aStream := WriteStream on: ''.
	self printHtmlOn: aStream.
	^aStream contents.
]

{ #category : #accessing }
HtmlEntity >> at: key put: anObject [
	self attributes ifNil: [self attributes: (HtmlAttributes new)].
	(self attributes) at: key put: anObject
]

{ #category : #accessing }
HtmlEntity >> attributes [
	^attribs ifNil: [attribs := HtmlAttributes new]
]

{ #category : #attributes }
HtmlEntity >> attributes: newAttributes [
	"set all of the attributes at once.  newAttributes should not be modified after passing it in"
	^attribs := newAttributes
]

{ #category : #contents }
HtmlEntity >> contents [
	"return an ordered collection of this entity's contents"
	^contents
]

{ #category : #attributes }
HtmlEntity >> doesNotUnderstand: aMessage [
	"treat the message as an attribute name"
	| selector |
	selector := aMessage selector.

	selector asLowercase = selector ifFalse: [
		"attribute accesses must be in all lowercase.  This should cut down on some false doesNotUnderstand: traps"
		^super doesNotUnderstand: aMessage ].

	selector numArgs == 0 ifTrue: [
		"return the named attribute"
		^self getAttribute: selector asString default: nil ].


	selector numArgs == 1 ifTrue: [
		"set the named attribute"
		self setAttribute: (selector asString copyFrom: 1 to: (selector size-1)) to: aMessage argument.
		^self ].

	^super doesNotUnderstand: aMessage
]

{ #category : #downloading }
HtmlEntity >> downloadState: baseUrl [
	"download any state needed for full rendering.  eg, images need this"
	
]

{ #category : #attributes }
HtmlEntity >> getAttribute: name [
	^self getAttribute: name  default: nil
]

{ #category : #attributes }
HtmlEntity >> getAttribute: name  default: anObject [
	^self getAttribute: name  ifAbsent: [anObject]
]

{ #category : #attributes }
HtmlEntity >> getAttribute: name  ifAbsent: aBlock [
	^attribs at: name ifAbsent: aBlock
]

{ #category : #'private-initialization' }
HtmlEntity >> initialize [
	contents := OrderedCollection new.
	attribs := HtmlAttributes new.
]

{ #category : #'private-initialization' }
HtmlEntity >> initialize: aTag [
	self initialize.
	attribs := HtmlAttributes newFrom: aTag attribs.
]

{ #category : #'user interface' }
HtmlEntity >> inspectorClass [

	^ HtmlEntityInspector
]

{ #category : #testing }
HtmlEntity >> isArea [
	^false
]

{ #category : #testing }
HtmlEntity >> isBlockEntity [
	^false
]

{ #category : #testing }
HtmlEntity >> isComment [
	^false
]

{ #category : #testing }
HtmlEntity >> isDefinitionListElement [
	"whether receiver can appear in a DefinitionList"
	^false
]

{ #category : #testing }
HtmlEntity >> isFormEntity [
	^false
]

{ #category : #categorization }
HtmlEntity >> isFrame [
	^false
]

{ #category : #categorization }
HtmlEntity >> isFrameSet [
	^false
]

{ #category : #testing }
HtmlEntity >> isHeadElement [
	"whether this can appear in a header"
	^false
]

{ #category : #testing }
HtmlEntity >> isHeader [
	^false
]

{ #category : #testing }
HtmlEntity >> isListElement [
	"is this an HtmlListElement, ie can it appear in a (non-definition) list?"
	^false
]

{ #category : #testing }
HtmlEntity >> isListItem [
	"is this an HtmlListItem, ie can it appear in a (non-definition) list?"
	^false
]

{ #category : #testing }
HtmlEntity >> isOption [
	"whether this is an <option> entity"
	^false
]

{ #category : #testing }
HtmlEntity >> isParagraph [
	^false
]

{ #category : #testing }
HtmlEntity >> isTableDataItem [
	^false
]

{ #category : #testing }
HtmlEntity >> isTableItem [
	^false
]

{ #category : #testing }
HtmlEntity >> isTableRow [
	^false
]

{ #category : #testing }
HtmlEntity >> isTextualEntity [
	"is receiver either text, or some low-level text-like entity such as <b> or <em>"
	^false
]

{ #category : #testing }
HtmlEntity >> lint [
	^String streamContents: [ :s | self lint: s ]
]

{ #category : #testing }
HtmlEntity >> lint: aStream [
	"do a lint check, reporting to aStream"
	self lintAttributes: aStream.

	contents do: [ :c |
		(c isComment not   and:  [ (self shouldContain: c) not ]) ifTrue: [ 
			aStream nextPutAll: '<', self tagName, '> should not contain <', c tagName, '>'.
			aStream cr. ] ].

	contents do: [ :c  | c lint: aStream ]
]

{ #category : #testing }
HtmlEntity >> lintAttributes: aStream [
	"check that our attributes are okay.  Print any anomalies to aStream"
	
]

{ #category : #testing }
HtmlEntity >> mayContain: anEntity [
	"whether we can contain the given entity"
	^self subclassResponsibility
]

{ #category : #testing }
HtmlEntity >> mayContainEntity: anEntity [
	"whether we can contain the given entity"
	^self subclassResponsibility
]

{ #category : #attributes }
HtmlEntity >> name [
	^self getAttribute: 'name' default: nil
]

{ #category : #formatting }
HtmlEntity >> parsingFinished [
	"some entities need to make a final pass *after* parsing has finished and all the contents of each entity have been established; here is a place to do that"
	contents do: [ :e | e parsingFinished ].
]

{ #category : #printing }
HtmlEntity >> printHtmlOn: aStream [
	^self printHtmlOn: aStream  indent: 0
]

{ #category : #printing }
HtmlEntity >> printHtmlOn: aStream indent: indent [ 
	aStream next: indent put: $ ;
	 nextPutAll: '<';
	 nextPutAll: self tagName.
	self attributes associationsDo: [:assoc | aStream space; nextPutAll: assoc key; nextPutAll: '="'; nextPutAll: assoc value; nextPutAll: '"'].
	aStream nextPut: $>;
	 cr.
	contents do: [:entity | entity printHtmlOn: aStream indent: indent + 1].
	aStream nextPutAll: '</'; nextPutAll: self tagName; nextPutAll: '>'.
]

{ #category : #printing }
HtmlEntity >> printOn: aStream [
	^self printOn: aStream  indent: 0
]

{ #category : #printing }
HtmlEntity >> printOn: aStream  indent: indent [
	aStream
		next: indent put: $ ;
		nextPut: $<;
		print: self tagName.

	self attributes associationsDo: [ :assoc |
		aStream
			space;
			nextPutAll: assoc key;
			nextPutAll: '=';
			nextPutAll: assoc value ].

	aStream
		nextPut: $>;
		cr.
	contents do: [ :entity | entity printOn: aStream indent: indent+1 ].
]

{ #category : #contents }
HtmlEntity >> removeEntity: anEntity [ 
	"remove the specified entity"
	contents remove: anEntity
]

{ #category : #attributes }
HtmlEntity >> setAttribute: name  to: value [
	"set the given attribute to the given value"
	attribs at: name asLowercase  put: value
]

{ #category : #testing }
HtmlEntity >> shouldContain: anEntity [
	"whether, according to the HTML DTD, this element should actually contain anEntity.  Used for checking the quality of a pages HTML"
	^self mayContain: anEntity
]

{ #category : #contents }
HtmlEntity >> subEntities [
	"return an ordered collection of this entity's contents"
	^ contents
]

{ #category : #testing }
HtmlEntity >> tagName [
	"tag name for ourself"
	^self subclassResponsibility
]

{ #category : #contents }
HtmlEntity >> textualContents [
	"return a string with the concatenated contents of all textual sub-entities"
	^String streamContents: [ :s |
		contents do: [ :e | s nextPutAll: e textualContents ] ]
]
