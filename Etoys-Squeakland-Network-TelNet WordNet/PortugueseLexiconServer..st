"
Provide a standard interface for the Portuguese language dictionary at http://www.priberam.pt/.
The ""choose language"" item on the shift-menu lets you select a language (and its server).  (Preferences setPreference: #myLanguage toValue: #Portuguese).  To get the definition of a word, select any word in any text pane, and choose ""definition of word"" from the shift menu.  Also used for the ""verify spelling of word"" menu item.

PortugueseLexiconServer openScamperOn: 'palavra'.

See class WordNet.
Converts an input string from Apple character encoding to the encoding used on this server.
  'particípio' -> 'particÌpio'

Not yet completed:
** Better parse of the definition page, so it can be used by a program.
"
Class {
	#name : #PortugueseLexiconServer,
	#superclass : #WordNet,
	#category : #'Etoys-Squeakland-Network-TelNet WordNet'
}

{ #category : #'as yet unclassified' }
PortugueseLexiconServer class >> decodeAccents: appleLikeString [
	"change characters like í, to the form used in Portuguese"
	| encodedStream rem |
	encodedStream := WriteStream on: (String new).
	
	appleLikeString do: [ :c |
		rem := encodedStream position.
		c == $í ifTrue: [encodedStream nextPut: (Character value: 237)].
		c == $á ifTrue: [encodedStream nextPut: (Character value: 225)].
		c == $é ifTrue: [encodedStream nextPut: (Character value: 233)].
		c == $ç ifTrue: [encodedStream nextPut: (Character value: 231)].
		c == $ã ifTrue: [encodedStream nextPut: (Character value: 227)].
		c == $ó ifTrue: [encodedStream nextPut: (Character value: 243)].
		c == $ê ifTrue: [encodedStream nextPut: (Character value: 234)].
		"and more, such as e with a backwards accent"

		rem = encodedStream position ifTrue: [
			encodedStream nextPut: c].
		].
	^encodedStream contents. 
]

{ #category : #'as yet unclassified' }
PortugueseLexiconServer class >> openScamperOn: aWord [
	| aUrl scamperWindow |
	"Open a Scamper web browser on the web dictionary entry for this word.  If Scamper is already pointing at it, use the same browser.  Special code for this server."

	aUrl := 'http://www.priberam.pt/scripts/dlpouniv.dll', 
		'?search_value=', (self decodeAccents: aWord).
	scamperWindow := (WebBrowser default ifNil: [^self]) newOrExistingOn: aUrl.
	scamperWindow model jumpToUrl: aUrl asUrl.
	scamperWindow activate.

]

{ #category : #'as yet unclassified' }
PortugueseLexiconServer >> definition: theWord [
	"look this word up in the basic way.  Return nil if there is trouble accessing the web site."
	| doc |

	word := theWord.
	doc := HTTPSocket 
		httpGetDocument: 'http://www.priberam.pt/scripts/dlpouniv.dll' 
		args: 'search_value=', (self class decodeAccents: word).
	replyHTML := (doc isKindOf: MIMEDocument)
		ifTrue: [doc content]
		ifFalse: [nil].
	"self parseReply."

	^ replyHTML
]

{ #category : #'as yet unclassified' }
PortugueseLexiconServer >> parts [
	| divider |
	"return the parts of speech this word can be.  Keep the streams for each"
	parts := OrderedCollection new.
	partStreams := OrderedCollection new.
	rwStream ifNil: [self stream].
	rwStream reset.
	rwStream match: 'Palavra desconhecida pelo Dicionário.'.
	rwStream atEnd ifFalse: [^ #()].	"not in dictionary"

	rwStream reset.
	rwStream match: (divider := '<li>').	"stemming a complex word"
	rwStream atEnd ifTrue: [rwStream reset.
		rwStream match: (divider := '<dd>')].	"base word in dict"
	[rwStream atEnd] whileFalse: [
		partStreams add: (ReadStream on: (rwStream upToAll: divider))].
	partStreams do: [:pp |
		parts add: (pp upToAll: '</b>')].
	parts size = 0 ifTrue: [^ parts].
	parts last = '' ifTrue: [parts removeLast.  partStreams removeLast].
		"May want to remove all after </dl>"
	^ parts 
]
