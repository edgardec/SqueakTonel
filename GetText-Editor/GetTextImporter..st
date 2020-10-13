"
GetTextImporter load gettext po file into a InternalTranslator.

GetTextImporter new importID: (LocaleID isoString: 'lang-name') fileNamed: 'lang.po'

"
Class {
	#name : #GetTextImporter,
	#superclass : #GetTextInterchange,
	#instVars : [
		'msgId',
		'msgStr',
		'state'
	],
	#category : #'GetText-Editor'
}

{ #category : #utilities }
GetTextImporter class >> cleanUpUnnecessaryPhrases [
	| keys refuse replaceBlock reader writer char result |
	"GetTextImporter cleanUpUnnecessaryPhrases"
	""
	"Collect wrong phrases"
	keys := InternalTranslator allKnownPhrases copy keys.
	refuse := Set new.
	"replaceBlock value: 'te\\nst'."
	replaceBlock := [:aString | 
			reader := aString readStream.
			writer := '' writeStream.
			[reader atEnd]
				whileFalse: [char := reader next.
					(char = $\
							and: [reader peek = $\])
						ifFalse: [writer nextPut: char]].
			writer contents].
	keys
		do: [:each | 
			result := replaceBlock value: each.
			(result ~= each
					and: [keys includes: result])
				ifTrue: [refuse add: each].
			result := GetTextImporter new formatString: each.
			(result ~= each
					and: [keys includes: result])
				ifTrue: [refuse add: each]].
	""
	"Remove from translated"
	InternalTranslator cachedTranslations
		do: [:each | refuse
				do: [:key | each translations
						removeKey: key
						ifAbsent: []]].
	""
	"Remove from untranslated"
	refuse
		do: [:key | InternalTranslator allKnownPhrases
				removeKey: key
				ifAbsent: []]
]

{ #category : #utilities }
GetTextImporter class >> import: translator allDirectory: aFileDirectory [ 
	"self import: NaturalLanguageTranslator current allDirectory:
	FileDirectory default"
	| fileName targetFile |
	fileName := translator localeID posixName , '.po'.
	(FileDirectory default directoryNamed: 'po')
		withAllSubdirectoriesCollect: [:each | (each fileExists: fileName)
				ifTrue: [targetFile := each fullNameFor: fileName.
					self new import: translator fileNamed: targetFile]]
]

{ #category : #utilities }
GetTextImporter class >> importAll [
	"GetTextImporter importAll"
	"Import all gettext files on po/. Only registered language is imported"
	InternalTranslator cachedTranslations
		do: [:translator | self import: translator allDirectory: FileDirectory default]
]

{ #category : #parsing }
GetTextImporter >> appendId: aString [ 
	msgId := msgId , aString
]

{ #category : #parsing }
GetTextImporter >> appendStr: aString [ 
	msgStr := msgStr , aString
]

{ #category : #private }
GetTextImporter >> formatString: aString [ 
"
	self assert: (GetTextImporter new formatString: 'test') = 'test'.
	self assert: (GetTextImporter new formatString: 'te\nst') = ('te', String cr, 'st').
	self assert: (GetTextImporter new formatString: 'te\\nst') = ('te\nst').
	self assert: (GetTextImporter new formatString: 'te\\st') = ('te\st').
	self assert: (GetTextImporter new formatString: 'te\st') = ('te\st').
"
	| reader writer char |
	reader := aString readStream.
	writer := '' writeStream.
	[reader atEnd]
		whileFalse: [char := reader next.
			(char = $\
					and: [reader atEnd not])
				ifTrue: [char := reader next.
					char caseOf: {
						[$n] -> [writer nextPut: Character cr].
						[$t] -> [writer nextPut: Character tab].
						[$"] -> [writer nextPut: $"].
						[$\] -> [writer nextPut: $\]}
						 otherwise: [writer nextPutAll: {$\. char}]]
				ifFalse: [writer nextPut: char]].
	^ writer contents
]

{ #category : #importing }
GetTextImporter >> import: aLanguage [ 
	^ self import: aLanguage fileNamed:  aLanguage localeID posixName , '.po'
]

{ #category : #importing }
GetTextImporter >> import: aLanguage fileNamed: fileName [
	self importID: aLanguage localeID fileNamed: fileName
]

{ #category : #importing }
GetTextImporter >> importID: localeID fileNamed: fileName [
	| currentPlatform |
	language := InternalTranslator newLocaleID: localeID.
	currentPlatform := Locale currentPlatform.
	[Locale
		currentPlatform: (Locale localeID: localeID).
	[stream := FileStream readOnlyFileNamed: fileName.
	stream text.
	self parse]
		ensure: [stream notNil
				ifTrue: [stream close]]]
		ensure: [Locale currentPlatform: currentPlatform].
	NaturalLanguageTranslator privateStartUp "Actually it is not private no more...".
]

{ #category : #'initialize-release' }
GetTextImporter >> initialize [
	msgId := ''.
	msgStr := ''.
	state := nil
]

{ #category : #parsing }
GetTextImporter >> parse [
	| size |
	size := (stream isKindOf: FileStream)
				ifTrue: [stream size]
				ifFalse: [1].
	ProgressInitiationException
		display: 'Importing phrases from a gettext file.'
		during: [:bar | [stream atEnd]
				whileFalse: [| line | 
					line := stream upTo: Character linefeed.
					self
						parseLine: ((line endsWith: String cr)
								ifTrue: [line allButLast]
								ifFalse: [line]).
					bar value: stream position / size]].
	self storeTranslation
]

{ #category : #parsing }
GetTextImporter >> parseLine: lineString [ 
	(lineString beginsWith: '"Content-Type:')
		ifTrue: [self setContentType: lineString.
			^ self].
	(lineString beginsWith: '#')
		ifTrue: ["do nothing"
			^ self].
	lineString = ''
		ifTrue: [^ self storeTranslation].
	(lineString beginsWith: 'msgid')
		ifTrue: [state := #appendId:.
			self parseMsg: lineString.
			^ self].
	(lineString beginsWith: 'msgstr')
		ifTrue: [state := #appendStr:.
			self parseMsg: lineString.
			^ self].
	self parseMsg: lineString
]

{ #category : #parsing }
GetTextImporter >> parseMsg: lineString [ 
	| begin end msg |
	begin := lineString indexOf: $".
	end := lineString lastIndexOf: $".
	msg := begin + 1 <= (end - 1)
				ifTrue: [lineString copyFrom: begin + 1 to: end - 1]
				ifFalse: [''].
	state
		ifNotNil: [self perform: state with: msg].
	^ msg
]

{ #category : #parsing }
GetTextImporter >> setContentType: lineString [ 
	"self new setContentType: 'Content-Type: text/plain; charset=utf-8'"
	| reader charSet |
	reader := lineString readStream.
	reader upTo: $=.
	charSet := reader upTo: $\.
	stream
		converter: (TextConverter newForEncoding: charSet)
]

{ #category : #parsing }
GetTextImporter >> storeTranslation [
	| key |
	key := self formatString: msgId.
	msgId isEmpty
		ifFalse: [InternalTranslator registerPhrase: key.
			msgStr isEmpty
				ifFalse: [language
						rawPhrase: key
						translation: (self formatString: msgStr)]].
	self initialize
]
