"
Query the WordNet lexicon at Princeton Univ.  At http://www.cogsci.princeton.edu/cgi-bin/webwn/   To get the definition of a word, select any word in any text pane, and choose ""definition of word"" from the shift menu.  WordNet is also used for the ""verify spelling of word"" menu item.
	Subclasses are interfaces to other dictionaries.  The ""choose language"" item on the shift-menu lets you select a language (and its server).  (Preferences setPreference: #myLanguage toValue: #Portuguese).

WordNet openScamperOn: 'balloon'.


DD _ WordNet new.
DD definition: 'balloon'.
DD parts ""of speech"".
	 OrderedCollection ('noun' 'verb' )
DD sensesFor: 'noun'.
	 2
DD def: 1 for: 'noun'.
	 '(large tough non-rigid bag filled with gas or hot air)'
After the initial response, keep a separate stream for the definition of each part of speech.  Caller may later query them for information.

"
Class {
	#name : #WordNet,
	#superclass : #Object,
	#instVars : [
		'form',
		'url',
		'args',
		'word',
		'replyHTML',
		'parts',
		'partStreams',
		'rwStream',
		'replyParsed'
	],
	#classVars : [
		'CanTranslateFrom',
		'Languages'
	],
	#category : #'Etoys-Squeakland-Network-TelNet WordNet'
}

{ #category : #miscellaneous }
WordNet class >> canTranslateFrom [

	Languages ifNil: [Languages := #(English Portuguese).
		CanTranslateFrom := #(French German Spanish English Portuguese 
			Italian Norwegian)].		"see www.freetranslation.com/"
	^ CanTranslateFrom 
]

{ #category : #services }
WordNet class >> definitionsFor: aWord [
	| aDef parts item |
	aDef := self new.
	(aDef definition: aWord) ifNil:
		[self inform: 'Sorry, cannot reach the WordNet
web site; task abandoned.'.
		^ nil].
	parts := aDef parts.
	parts size = 0 ifTrue:
		[self inform: 'Sorry, ', aWord, ' not found.'.
		^ nil].

	^ String streamContents:
		[:defStream |
			defStream nextPutAll: aWord; cr.
			parts do:
				[:aPart |
					defStream cr.
					1 to: (aDef sensesFor: aPart) do:
						[:senseNumber |
							defStream nextPutAll: aPart.
							item := aDef def: senseNumber for: aPart.
							defStream nextPutAll: (' (', senseNumber printString, ') ', (item copyFrom: 2 to: item size - 1)).
							defStream cr]]]

"WordNet definitionsFor: 'balloon'"

]

{ #category : #miscellaneous }
WordNet class >> languagePrefs [
	"Set preference of which natural language is primary. Look up definitions in it, and correct speaLanguageing in it.  Also, let user set languages to translate from and to."

	| ch aLanguage |
	self canTranslateFrom.		"sets defaults"
	ch := PopUpMenu withCaption: 'Choose the natural language to use for:'
			chooseFrom: 'word definition and spelling verification (', 
					(Preferences parameterAt: #myLanguage ifAbsentPut: [#English]) asString ,')...\',
				'language to translate FROM   (now ',
					(Preferences parameterAt: #languageTranslateFrom ifAbsentPut: [#English]) asString ,')...\',
				'language to translate TO   (now ',
					(Preferences parameterAt: #languageTranslateTo ifAbsentPut: [#German]) asString ,')...\'.
	ch = 1 ifTrue: [
		aLanguage := PopUpMenu withCaption: 'The language for word definitions and speaLanguageing verification:'
			chooseFrom: Languages.
		aLanguage > 0 ifTrue:
			[^ Preferences setParameter: #myLanguage to: (Languages at: aLanguage) asSymbol]].
	ch = 2 ifTrue:
		[aLanguage := PopUpMenu withCaption: 'The language to translate from:'
			chooseFrom: CanTranslateFrom.
		aLanguage > 0 ifTrue:
			[^ Preferences setParameter: #languageTranslateFrom to: (CanTranslateFrom at: aLanguage) asSymbol]].
	ch = 3 ifTrue:
		[aLanguage := PopUpMenu withCaption: 'The language to translate to'
			chooseFrom: CanTranslateFrom.
		aLanguage > 0 ifTrue:
			[^ Preferences setParameter: #languageTranslateTo to: (CanTranslateFrom at: aLanguage) asSymbol]].

	"Maybe let the user add another language if he knows the server can take it."
"	ch := (PopUpMenu labelArray: Languages, {'other...'.
			'Choose language to translate from...'})
		startUpWithCaption: 'Choose the language of dictionary for word definitions.'.
	ch = 0 ifTrue: [^ Preferences setParameter: #myLanguage to: #English].
	(ch <= Languages size) ifTrue: [aLanguage := Languages at: ch].
	ch = (Languages size + 1) ifTrue: [
		aLanguage := FillInTheBlank request: 'Name of the primary language'].
	aLanguage ifNotNil: [^ Preferences setParameter: #myLanguage to: aLanguage asSymbol].
"
]

{ #category : #miscellaneous }
WordNet class >> lexiconServer [
	"Look in Preferences to see what language the user wants, and what class knows about it."

	| nl |
	nl := Preferences parameterAt: #myLanguage ifAbsentPut: [#English].
	nl == #English ifTrue: [^ self].		"English, WordNet server"
	nl == #Portuguese ifTrue: [^ PortugueseLexiconServer].	"www.priberam.pt"

"	nl == #Deutsch ifTrue: [^ DeutschServerClass]. "	"class that knows about a server"

	self inform: 'Sorry, no known online dictionary in that language.'.
	^ self languagePrefs
]

{ #category : #miscellaneous }
WordNet class >> openScamperOn: aWord [
	| aUrl scamperWindow |
	"Open a Scamper web browser on the WordNet entry for this word.  If Scamper is already pointing at WordNet, use the same browser."

	aUrl := 'http://www.cogsci.princeton.edu/cgi-bin/webwn/', 
		'?stage=1&word=', aWord.
	scamperWindow := (WebBrowser default ifNil: [^self]) newOrExistingOn: aUrl.
	scamperWindow model jumpToUrl: aUrl asUrl.
	scamperWindow activate.

]

{ #category : #services }
WordNet class >> verify: aWord [
	"See if this spelling is in the WordNet lexicon.  Return a string of success, no-such-word, or can't reach the server."

	| aDef nl |
	aDef := self new.
	(aDef definition: aWord) ifNil:
		[^ 'Sorry, cannot reach that web site.  Task abandoned.
(Make sure you have an internet connection.)'].
	nl := Preferences parameterAt: #myLanguage ifAbsentPut: [#English].

	(aDef parts) size = 0 
		ifTrue: [^ 'Sorry, ', aWord, ' not found. (', nl, ' lexicon)']
		ifFalse: [^ aWord, ' is spelled correctly.']
]

{ #category : #'as yet unclassified' }
WordNet >> def: nth for: partOfSpeech [

	| ii strm |
	parts ifNil: [self parts].
	(ii := parts indexOf: partOfSpeech) = 0 ifTrue: [^ nil].
	strm := partStreams at: ii.
	strm reset.
	1 to: nth do: [:nn | 
		strm match: '<BR>',(String with: Character lf),nn printString, '.  '.
		strm match: ' -- '].
	^ strm upToAll: '<BR>'
]

{ #category : #'as yet unclassified' }
WordNet >> definition: theWord [
	"look this word up in the basic way.  Return nil if there is trouble accessing the web site."
	| doc |
	word := theWord.
	Cursor wait showWhile: [
		doc := HTTPSocket 
			httpGetDocument: 'http://www.cogsci.princeton.edu/cgi-bin/webwn/' 
			args: 'stage=1&word=', word].
	replyHTML := (doc isKindOf: MIMEDocument)
		ifTrue:
			[doc content]
		ifFalse:
			[nil].
	"self parseReply."

	^ replyHTML
]

{ #category : #'as yet unclassified' }
WordNet >> partOfSpeech [

	rwStream ifNil: [self stream].
	rwStream reset.
	rwStream match: '<BR>The <B>'.
	^ rwStream upToAll: '</B>'
]

{ #category : #'as yet unclassified' }
WordNet >> partOfSpeechIn: aStrm [

	aStrm reset.
	aStrm match: '<BR>The <B>'.
	^ aStrm upToAll: '</B>'
]

{ #category : #'as yet unclassified' }
WordNet >> parts [
	"return the parts of speech this word can be.  Keep the streams for each"
	parts := OrderedCollection new.
	partStreams := OrderedCollection new.
	rwStream ifNil: [self stream].
	rwStream reset.
	rwStream match: '<HR>'.
	[rwStream atEnd] whileFalse: [
		partStreams add: (ReadStream on: (rwStream upToAll: '<HR>'))].
	partStreams do: [:pp |
		parts add: (self partOfSpeechIn: pp)].
	parts size = 0 ifTrue: [^ parts].
	parts last = '' ifTrue: [parts removeLast.  partStreams removeLast].
	^ parts 
]

{ #category : #'as yet unclassified' }
WordNet >> senses [

	| ww |
	ww := '"', word, '"'.
	rwStream ifNil: [self stream].
	rwStream reset.
	rwStream match: ww.
	rwStream match: ww.
	rwStream match: ' has '.
	^ (rwStream upTo: Character lf) asNumber
]

{ #category : #'as yet unclassified' }
WordNet >> sensesFor: partOfSpeech [

	| ii strm |
	parts ifNil: [self parts].
	(ii := parts indexOf: partOfSpeech) = 0 ifTrue: [^ nil].
	strm := partStreams at: ii.
	strm reset.
	strm match: '"', word, '"'.
	strm match: ' has '.
	^ (strm upTo: Character lf) asNumber
]

{ #category : #'as yet unclassified' }
WordNet >> stream [

	rwStream :=  RWBinaryOrTextStream on: (String new: 1000).
	rwStream nextPutAll: replyHTML; reset.
	^ rwStream
]
