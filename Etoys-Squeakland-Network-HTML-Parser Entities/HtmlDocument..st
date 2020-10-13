"
an entire HTML document.  It should have exactly two sub-entities when completed: a HEAD and a BODY
"
Class {
	#name : #HtmlDocument,
	#superclass : #HtmlEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #'instance creation' }
HtmlDocument class >> emptyDocument [
	"return an empty document"
	^super new add: HtmlHead new; add: HtmlBody new
]

{ #category : #access }
HtmlDocument >> addToBody: anObject [
	"add an object to the Body entity of the receiver"
	self body add: anObject
]

{ #category : #access }
HtmlDocument >> addToHead: anObject [
	"add an object to the head entity of the receiver"
	self head add: anObject
]

{ #category : #access }
HtmlDocument >> body [
	^self contents at: 2
]

{ #category : #formatting }
HtmlDocument >> formattedText [
	"return a version of this document as a formatted Text"
	| formatter |
	formatter := HtmlFormatter preferredFormatterClass new.
	self addToFormatter: formatter.
	^formatter text 
]

{ #category : #formatting }
HtmlDocument >> formattedTextForBrowser: browser  defaultBaseUrl: defaultBaseUrl [
	"return a version of this document as a formatted Text (which includes links and such)"
	| formatter text |

	"set up the formatter"
	formatter := HtmlFormatter preferredFormatterClass new.
	formatter browser: browser.
	formatter baseUrl: defaultBaseUrl.  "should check if the document specifies something else"

	"do the formatting"
	self addToFormatter: formatter.

	"get and return the result"
	text := formatter text.
	^text
]

{ #category : #formatting }
HtmlDocument >> formattedTextMorph [
	"return a version of this document as a formatted TextMorph (which includes links and such)"
	| formatter text textMorph |
	formatter := HtmlFormatter preferredFormatterClass new.
	self addToFormatter: formatter.
	text := formatter text .

	textMorph := TextMorph new initialize.
	textMorph contentsWrapped: text.

	^textMorph
]

{ #category : #formatting }
HtmlDocument >> formattedTextMorphForBrowser: browser  defaultBaseUrl: defaultBaseUrl [
	"return a version of this document as a formatted TextMorph (which includes links and such)"
	| formatter textMorph |

	"set up the formatter"
	formatter := HtmlFormatter preferredFormatterClass new.
	formatter browser: browser.
	formatter baseUrl: defaultBaseUrl.  "should check if the document specifies something else"

	"do the formatting"
	self addToFormatter: formatter.

	"get and return the result"
	textMorph := formatter textMorph .
	^textMorph
]

{ #category : #access }
HtmlDocument >> head [
	^self contents at: 1
]

{ #category : #testing }
HtmlDocument >> mayContain: anElement [
	^true 	"not strictly true, but it makes the parser simpler"
]

{ #category : #testing }
HtmlDocument >> tagName [
	^'html'
]
