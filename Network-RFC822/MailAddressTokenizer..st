"
Divides an address into tokens, as specified in RFC 822.  Used by MailAddressParser.
"
Class {
	#name : #MailAddressTokenizer,
	#superclass : #Stream,
	#instVars : [
		'cachedToken',
		'text',
		'pos'
	],
	#classVars : [
		'CSNonAtom',
		'CSParens',
		'CSSpecials'
	],
	#category : #'Network-RFC822'
}

{ #category : #'class initialization' }
MailAddressTokenizer class >> cleanUp: aggressive [

	CSParens := CSSpecials := CSNonAtom := nil
]

{ #category : #'instance creation' }
MailAddressTokenizer class >> forString: aString [
	^super basicNew initialize: aString
]

{ #category : #'class initialization' }
MailAddressTokenizer class >> nonAtomSet [
	"Create a ByteCharacterSet to ensure quick parsing of the email address string, which must be a ByteString (UTF-8 encoded)"

	^CSNonAtom ifNil: [
		CSNonAtom := CharacterSet new
			"Atom characters as defined in RFC 2822 3.2.4"
			addAll: ($A to: $Z);
			addAll: ($a to: $z);
			addAll: ($0 to: $9);
			addAll: '!#$%&''*+-/=?^_`{|}~';
			"RFC 6531 allows characters with value > 127 encoded as UTF-8, which means values between 128 and 255 may appear as part of atoms."
			addAll: ((Character value: 128) to: (Character value: 255));
			byteComplement ]
]

{ #category : #'class initialization' }
MailAddressTokenizer class >> parenthesesSet [

	^CSParens ifNil: [ CSParens:= CharacterSet newFrom: '()' ]
]

{ #category : #'class initialization' }
MailAddressTokenizer class >> specialsSet [

	^CSSpecials ifNil: [ CSSpecials := CharacterSet newFrom: '()<>@,;:\".[]' ]
]

{ #category : #'instance creation' }
MailAddressTokenizer class >> tokensIn: aString [
	"return a collection of the tokens in aString"
	^(self forString: aString) upToEnd
]

{ #category : #'stream protocol' }
MailAddressTokenizer >> atEnd [
	^self peek == nil
]

{ #category : #tokenizing }
MailAddressTokenizer >> atEndOfChars [
	^pos > text size
]

{ #category : #initialization }
MailAddressTokenizer >> initialize: aString [
	text := aString.
	pos := 1.
]

{ #category : #'stream protocol' }
MailAddressTokenizer >> next [
	| ans |
	cachedToken ifNil: [ ^self nextToken ].
	ans := cachedToken.
	cachedToken := nil.
	^ans
]

{ #category : #tokenizing }
MailAddressTokenizer >> nextAtom [
	| start end |
	start := pos.
	pos := text indexOfAnyOf: self class nonAtomSet startingAt: start ifAbsent: [ text size + 1].
	end := pos - 1.
	^MailAddressToken
		type: #Atom
		text: (text copyFrom: start to: end)
]

{ #category : #tokenizing }
MailAddressTokenizer >> nextChar [
	self atEndOfChars ifTrue: [ ^nil ].
	pos := pos + 1.
	^text at: (pos-1)
]

{ #category : #tokenizing }
MailAddressTokenizer >> nextComment [
	| start nestLevel paren |
	start := pos.
	pos := pos + 1.
	nestLevel := 1.

	[ nestLevel > 0 ] whileTrue: [
		pos := text indexOfAnyOf: self class parenthesesSet startingAt: pos.
		pos = 0 ifTrue: [ 
			self error: 'unterminated comment.  ie, more (''s than )''s' ].

		paren := self nextChar.
		paren = $( ifTrue: [ nestLevel := nestLevel + 1 ] ifFalse: [ nestLevel := nestLevel - 1 ]].
	^ MailAddressToken type: #Comment
		text: (text copyFrom: start to: pos - 1)
]

{ #category : #tokenizing }
MailAddressTokenizer >> nextDomainLiteral [
	| start end |
	start := pos.
	end := text indexOf: $] startingAt: start.
	end = 0 ifTrue: [
		"not specified"
		self error: 'saw [ without a matching ]' ].

	pos := end+1.

	^MailAddressToken
		type: #DomainLiteral
		text: (text copyFrom: start to: end)
]

{ #category : #tokenizing }
MailAddressTokenizer >> nextQuotedString [
	| res c |
	res := WriteStream on: String new.
	res nextPut: self nextChar.   "record the starting quote"
	[ self atEndOfChars ] whileFalse: [
		c := self nextChar.
		c = $\ ifTrue: [
			res nextPut: c.
			res nextPut: self nextChar ]
		ifFalse: [
			c = $" ifTrue: [
				res nextPut: c.
				^MailAddressToken type: #QuotedString  text: res contents ]
			ifFalse: [
				res nextPut: c ] ] ].

	"hmm, never saw the final quote mark"
	^MailAddressToken type: #QuotedString  text: (res contents, '"')
]

{ #category : #tokenizing }
MailAddressTokenizer >> nextSpecial [
	| c |
	c := self nextChar.
	^MailAddressToken type: c  text: c asString.
]

{ #category : #tokenizing }
MailAddressTokenizer >> nextToken [
	| c |
	self skipSeparators.
	c := self peekChar.
	c ifNil: [ ^nil ].
	c = $( ifTrue: [ ^self nextComment ].
	c = $" ifTrue: [ ^self nextQuotedString ].
	c = $[ ifTrue: [ ^self nextDomainLiteral ].
	(self class specialsSet includes: c) ifTrue: [ ^self nextSpecial ].
	^self nextAtom
]

{ #category : #'stream protocol' }
MailAddressTokenizer >> peek [
	cachedToken ifNil: [ cachedToken := self nextToken. ].
	
	^cachedToken	
]

{ #category : #tokenizing }
MailAddressTokenizer >> peekChar [
	^text at: pos ifAbsent: [ nil ]
]

{ #category : #tokenizing }
MailAddressTokenizer >> skipSeparators [
	pos := text indexOfAnyOf: CharacterSet nonSeparators  startingAt: pos  ifAbsent: [ text size + 1 ].
]
