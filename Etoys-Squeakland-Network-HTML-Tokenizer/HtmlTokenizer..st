"
This class takes a text stream and produces a sequence of HTML tokens.

It requires its source stream to support #peek.
"
Class {
	#name : #HtmlTokenizer,
	#superclass : #Stream,
	#instVars : [
		'inputStream',
		'text',
		'pos',
		'inTextArea',
		'textAreaLevel'
	],
	#classVars : [
		'CSAttributeEnders',
		'CSNameEnders',
		'CSNonSeparators'
	],
	#category : #'Etoys-Squeakland-Network-HTML-Tokenizer'
}

{ #category : #initialization }
HtmlTokenizer class >> initialize [
	"HtmlTokenizer initialize"

	CSAttributeEnders := CharacterSet empty.
	CSAttributeEnders addAll: Character separators.
	CSAttributeEnders add: $>.
	
	CSNameEnders := CharacterSet empty.
	CSNameEnders addAll: '=>'.
	CSNameEnders addAll: Character separators.

	CSNonSeparators := CharacterSet separators complement.
]

{ #category : #'instance creation' }
HtmlTokenizer class >> on: aStream [
	^super basicNew initialize: aStream contents
]

{ #category : #'stream protocol' }
HtmlTokenizer >> atEnd [
	"are there any more tokens?  This is equivalent to whether there is any more input"
	^(pos > text size)
]

{ #category : #'private-initialization' }
HtmlTokenizer >> initialize: s [
	text := s withSqueakLineEndings.
	pos := 1.
	textAreaLevel := 0.
]

{ #category : #tokenizing }
HtmlTokenizer >> next [ 
	"return the next HtmlToken, or nil if there are no more"
	|token|

	"branch, depending on what the first character is"
	self atEnd ifTrue: [ ^nil ].
	self peekChar = $< 
		ifTrue: [ token := self nextTagOrComment ]
		ifFalse: [ token := self nextText ].


	"return the token, modulo modifications inside of textarea's"
	textAreaLevel > 0 ifTrue: [
		(token isTag and: [ token name = 'textarea' ]) ifTrue: [
			"textarea tag--change textAreaLevel accordingly"

			token isNegated
				ifTrue: [ textAreaLevel := textAreaLevel - 1 ]
				ifFalse: [ textAreaLevel := textAreaLevel -2 ].

			textAreaLevel > 0
				ifTrue: [ 
					"still inside a <textarea>, so convert this tag to text"
					^HtmlText forSource: token source ]
				ifFalse: [ "end of the textarea; return the tag"  ^token ] ].
			"end of the textarea"

		"inside the text area--return the token as text"
		^HtmlText forSource: token source ].

	(token isTag and: [ token isNegated not and: [ token name = 'textarea' ]]) ifTrue: [
		"beginning of a textarea"
		inTextArea := true.
		^token ].
		

	^token
]

{ #category : #'private-tokenizing' }
HtmlTokenizer >> nextAttributeValue [
	"return the next sequence of alphanumeric characters; used to read in the value part of a tag's attribute, ie <tagname  attribname=attribvalue>"
	"because of the plethora of sloppy web pages, this is EXTREMELY tolerant"
	| c start end |

	"make sure there are at least two characters left"
	pos >= text size ifTrue: [ ^self nextChar asString ].

	"okay, peek at the first character"
	start := pos.
	c := text at: start.

	"check whether it's either kind of quote mark"
	(c = $" or: [ c = $' ]) ifTrue: [
		"yes--so find the matching quote mark"
		end := text indexOf: c startingAt: start+1 ifAbsent: [ text size + 1 ].
		pos := end+1.
		^text copyFrom: start to: end ].


	"no--go until a space or a $> is seen"
	end := text indexOfAnyOf: CSAttributeEnders startingAt: start ifAbsent: [ text size + 1 ].
	end := end - 1.
	pos := end + 1.
	^text copyFrom: start to: end.
]

{ #category : #private }
HtmlTokenizer >> nextChar [
	| c |
	self atEnd ifTrue: [ ^nil ].
	c := text at: pos.
	pos := pos + 1.
	^c
]

{ #category : #'private-tokenizing' }
HtmlTokenizer >> nextComment [
	"we've seen < and the next is a !.  read until the whole comment is done"
	"this isn't perfectly correct--for instance <!--> is considered a proper comment--but it should do for now.  It also picks up <!DOCTYPE...> tags"
	| source c hyphens |
	
	self nextChar.   "swallow the $!"
	source := WriteStream on: String new.
	source nextPutAll: '<!'.
	
	self peekChar = $- ifFalse: [ 
		"this case is wierd.  go until we find a > at all and pray it's the correct end-of-'comment'"
		[	self atEnd or: [ self peekChar = $> ] 
		] whileFalse: [
			c := self nextChar.
			source nextPut: c 
		].
		self atEnd ifFalse: [ source nextPut: self nextChar ].
		^HtmlComment forSource: source contents ].
	
	hyphens := 0.

	[ 	c := self nextChar.
		c = nil or: [
			source nextPut: c.
			(hyphens >=2 and: [ c = $> ])]
	] whileFalse: [
		c = $- ifTrue: [ hyphens := hyphens + 1 ] ifFalse: [ hyphens := 0 ]
	].
		
	^HtmlComment forSource: source contents.

]

{ #category : #'private-tokenizing' }
HtmlTokenizer >> nextName [
	"return the next sequence of alphanumeric characters"
	"because of the plethora of sloppy web pages, this also accepts most non-space characters"
	| start end |

	start := pos.
	end := text indexOfAnyOf: CSNameEnders startingAt: start ifAbsent: [ text size + 1].
	end := end - 1.


	pos := end+1.
	^text copyFrom: start to: end
]

{ #category : #'private-tokenizing' }
HtmlTokenizer >> nextSpaces [
	"read in as many consecutive space characters as possible"
	| start end |

	"short cut for a common case"
	self peekChar isSeparator not ifTrue: [ ^'' ].

	"find the start and end of the sequence of spaces"
	start := pos.
	end := text indexOfAnyOf: CSNonSeparators startingAt: start ifAbsent: [ text size + 1 ].
	end := end - 1.

	"update pos and return the sequence"
	pos := end + 1.
	^text copyFrom: start to: end
]

{ #category : #'private-tokenizing' }
HtmlTokenizer >> nextTag [
	"we've seen a < and peek-ed something other than a !.  Parse and return a tag"
	| source negated name attribs attribName attribValue sourceStart sourceEnd c |
	
	sourceStart := pos-1.
	attribs := Dictionary new.

	"determine if its negated"
	self peekChar = $/
		ifTrue: [ negated := true.  self nextChar. ]
		ifFalse: [ negated := false ].

	"read in the name"
	self skipSpaces.
	name := self nextName.
	name := name asLowercase.

	"read in any attributes"
	[ 	self skipSpaces.
		c := self peekChar.
		c = nil or: [c isLetter not ]
	] whileFalse: [
		attribName := self nextName.
		attribName := attribName asLowercase.
		self skipSpaces.
		self peekChar = $=
			ifTrue: [
				self nextChar.
				self skipSpaces.
				attribValue := self nextAttributeValue withoutQuoting  ]
			ifFalse: [ attribValue := '' ].
		attribs at: attribName  put: attribValue ].

	self skipSpaces.
	"determine if the tag is of the form <foo/>"
	self peekChar = $/ ifTrue: [ self nextChar. ].
	self skipSpaces.
	self peekChar = $> ifTrue: [ self nextChar ].

	sourceEnd := pos-1.
	source := text copyFrom: sourceStart to: sourceEnd.

	^HtmlTag source: source name: name asLowercase negated: negated attribs: attribs
]

{ #category : #'private-tokenizing' }
HtmlTokenizer >> nextTagOrComment [
	"next character is a $<.  So read either a tag or a token"
	self nextChar.  "skip the $<"

	^self peekChar = $! 
		ifTrue: [ self nextComment ]
		ifFalse: [ self nextTag ]


]

{ #category : #'private-tokenizing' }
HtmlTokenizer >> nextText [
	"returns the next textual segment"
	|start end|

	start := pos.
	end := (text indexOf: $< startingAt: start ifAbsent: [ text size + 1 ]) - 1.

	pos := end+1.
	^HtmlText forSource: (text copyFrom: start to: end)
]

{ #category : #private }
HtmlTokenizer >> peekChar [
	self atEnd ifTrue: [ ^nil ].
	^text at: pos
]

{ #category : #'private-tokenizing' }
HtmlTokenizer >> skipSpaces [
	"skip as many consecutive space characters as possible"
	pos := text indexOfAnyOf: CSNonSeparators startingAt: pos ifAbsent: [ text size + 1 ].
]
