"
Export translations to gettext format divided into categories.

""Export gettext template files""
GetTextExporter new exportTemplate.

""Export translation files for current locale""
GetTextExporter new exportTranslator: (NaturalLanguageTranslator current).

""Export all gettext template and po files.""
GetTextExporter exportAll.


"
Class {
	#name : #GetTextExporter,
	#superclass : #Object,
	#instVars : [
		'stream'
	],
	#category : #'GetText-Editor'
}

{ #category : #utilities }
GetTextExporter class >> coverageStatus [
	"self coverageStatus"
	| keys diff |
	keys := self keys.
	diff := InternalTranslator allKnownPhrases keys difference: keys.
	Transcript cr; show: 'Detected keywords by GetTextExporter2: ' , keys size printString.
	Transcript cr; show: 'All known phrases in InternalTranslator: ' , InternalTranslator allKnownPhrases size printString.
	Transcript cr; show: 'Coverage: ' , (keys size / InternalTranslator allKnownPhrases size * 100.0) printString , '%'.
	diff inspect
]

{ #category : #utilities }
GetTextExporter class >> exportAll [
	"GetTextExporter2 exportAll"
	self new exportTemplate.
	InternalTranslator availableLanguageLocaleIDs
		do: [:each | self new exportTranslator: each translator]
]

{ #category : #utilities }
GetTextExporter class >> exportTemplate [
	"GetTextExporter2 exportTemplate"
	self new exportTemplate.
]

{ #category : #utilities }
GetTextExporter class >> keys [
	| categories |
	categories := Dictionary new.
	self new appendTranslations: categories.
	^ categories values
		inject: Set new
		into: [:set :next | set addAll: next keys;
				 yourself]
]

{ #category : #utilities }
GetTextExporter class >> listAllHelp [
	"self listAllHelp"
	| spec specs oCatalog flap flapSelectors allKeys oCatalogHelp flapHelp |
	oCatalog := Dictionary new.
	Morph withAllSubclasses
		do: [:aClass | (aClass class includesSelector: #descriptionForPartsBin)
				ifTrue: [spec := aClass descriptionForPartsBin.
					oCatalog at: spec formalName put: spec documentation]].
	Morph withAllSubclasses
		do: [:aClass | (aClass class includesSelector: #supplementaryPartsDescriptions)
				ifTrue: [specs := aClass supplementaryPartsDescriptions.
					specs
						do: [:each | oCatalog at: each formalName put: each documentation]]].
	flap := Dictionary new.
	flapSelectors := #(#defaultsQuadsDefiningPlugInSuppliesFlap #defaultsQuadsDefiningStackToolsFlap #defaultsQuadsDefiningSuppliesFlap #defaultsQuadsDefiningToolsFlap #defaultsQuadsDefiningWidgetsFlap #defaultsQuadsDefiningScriptingFlap ).
	flapSelectors
		do: [:selector | 
			specs := Flaps perform: selector.
			specs
				do: [:each | flap at: each third put: each fourth]].
	allKeys := oCatalog keys intersection: flap keys.
	allKeys asArray sort
		do: [:each | 
			oCatalogHelp := oCatalog
						at: each
						ifAbsent: [''].
			flapHelp := flap
						at: each
						ifAbsent: [''].
			oCatalogHelp = flapHelp
				ifFalse: [Transcript cr; show: 'Name: ' , each.
					Transcript cr; show: 'O: ' , oCatalogHelp.
					Transcript cr; show: 'F: ' , flapHelp.
					Transcript cr.

]]
]

{ #category : #utilities }
GetTextExporter class >> verifyExport [
	"Same as #verifyMsgID: but it writes / reads .po files actually"
	"GetTextExporter2 verifyExport"
	"InternalTranslator removeLocaleID: (LocaleID isoString: 'test-US')"
	| src dst localeID |
	localeID := LocaleID isoString: 'test-US'.
	self verifyMsgID: localeID.
	src := localeID translator.
	self new exportTranslator: src.
	InternalTranslator removeLocaleID: localeID.
	dst := localeID translator.
	GetTextImporter import: dst allDirectory: FileDirectory default
]

{ #category : #utilities }
GetTextExporter class >> verifyMsgID: localeID [ 
	"GetTextExporter2 verifyMsgID: (LocaleID isoString: 'test-US')"
	"InternalTranslator removeLocaleID: (LocaleID isoString: 'test-US')"
	"Test gettext keyword extract function without file I/O.
	A language named <langName> will be made. And
	all possible translated words are shown with extra X charactor like
	'XwordX' in the language."
	| src |
	InternalTranslator removeLocaleID: localeID.
	src := localeID translator.
	self keys
		do: [:key | src generics at: key put: 'X' , key , 'X']
]

{ #category : #private }
GetTextExporter >> appendStringReceivers: aSymbol into: domains [
	| literals references domainName methodReference keywords found |
	
	found := TranslatedReceiverFinder new stringReceiversWithContext: aSymbol.
	found do: [ :assoc |
		methodReference := assoc key.
		keywords := assoc value.
		domainName := (PackageOrganizer default packageOfMethod: methodReference ifNone: [nil]).
		domainName := domainName isNil ifTrue: [TextDomainManager defaultDomain] ifFalse: [domainName name].
		literals := domains at: domainName ifAbsentPut: [Dictionary new].
		keywords do: [ :literal |
			references := literals at: literal ifAbsentPut: [OrderedCollection new].
			references add: methodReference.
		].
	]. 


]

{ #category : #exporting }
GetTextExporter >> appendTranslations: domains [ 
	self appendStringReceivers: #translated into: domains.
	self appendStringReceivers: #translatedNoop into: domains.
	self appendVocabularies: domains.

]

{ #category : #exporting }
GetTextExporter >> appendTranslationsAlreadyIn: translator to: domains [
	| d |
	translator moFiles keysAndValuesDo: [:domain :mo |
		mo ifNotNil: [
			d := domains at: domain ifAbsentPut: [Dictionary new].
			mo translations keysAndValuesDo: [:key :translation |
				d at: key asString ifAbsentPut: [{MethodReference class: Object selector: #yourself}]]]]
]

{ #category : #private }
GetTextExporter >> appendVocabularies: domains [
	| literalsForDomain references domainName methodReference |
	
	EToyVocabulary allPhrasesWithContextToTranslate do: [ :r |
		methodReference :=  (MethodReference class: (r second) selector: (r third)).
		"domainName := self getTextDomainForPackage: (PackageOrganizer default packageOfMethod: methodReference)".
		domainName := 'Etoys-Tiles'.
		literalsForDomain := domains at: domainName ifAbsentPut: [Dictionary new].
		r fourth do: [ :literal |
			references := literalsForDomain at: literal ifAbsentPut: [OrderedCollection new].
			references add: methodReference.
		].
	]. 
	
]

{ #category : #private }
GetTextExporter >> createExtraInformation [
	| extras |
	extras := OrderedCollection new.
	#(
		'ATTENTION TRANSLATORS! This should be the name of your language as you would like it to appear in the Languages menu, e.g. "Español" or "English"' 'Language-Name'
		'ATTENTION TRANSLATORS! Put in the directionality of your language, that is "LTR" for left-to-right or "RTL" for right-to-left' 'Language-Direction'
		) pairsDo: [:first :second |
			extras add: (Array with: '' with: first with: second).
	].
	^ extras
]

{ #category : #'private-headers' }
GetTextExporter >> createHeaders [
	| headers |
	headers := OrderedCollection new.
	headers add: 'Project-Id-Version' -> 'eToys'.
	headers add: 'POT-Creation-Date' -> self currentDateAndTime.
	headers add: 'PO-Revision-Date' -> self currentDateAndTime.
	headers add: 'Last-Translator' -> ''.
	headers add: 'Language-Team' -> ''.
	headers add: 'MIME-Version' -> '1.0'.
	headers add: 'Content-Type' -> ('text/plain; charset=', stream converter class encodingNames first).
	headers add: 'Content-Transfer-Encoding' -> '8bit'.
	^ headers
]

{ #category : #private }
GetTextExporter >> currentDateAndTime [
	^ String
		streamContents: [:aStream | 
			aStream nextPutAll: Date today yyyymmdd;
				space.
			Time now
				print24: true
				showSeconds: false
				on: aStream.
			aStream nextPutAll: '-0000']
]

{ #category : #exporting }
GetTextExporter >> dirNameCategory: category translator: translator [ 
	"Answer a file name for the category. Make one if it is not exist yet.
	Make template file name if translator is nil"
	"self new dirNameCategory: 'Morphic-Scripting Support' translator:
	NaturalLanguageTranslator current"
	"self new dirNameCategory: 'Morphic-Scripting Support' translator: nil"
	| safeCategory fileName dirName pathName |
	safeCategory := category copyReplaceAll: ' ' with: '_'.
	fileName := translator
				ifNil: [safeCategory , '.pot']
				ifNotNil: [translator localeID posixName , '.po'].
	dirName := (safeCategory findTokens: '-')
				inject: 'po'
				into: [:aString :next | aString , FileDirectory slash , next].
	pathName := dirName , FileDirectory slash , fileName.
	(FileDirectory default directoryNamed: dirName) assureExistence.
	^ pathName
]

{ #category : #exporting }
GetTextExporter >> dirNameDomain: domain translator: translator [ 
	"Answer a file name for the domain. Make one if it is not exist yet.
	Make template file name if translator is nil"
	"self new dirNameDomain: 'etoys' translator:
	NaturalLanguageTranslator current"
	"self new dirNameDomain: 'etoys' translator: nil"
	| fileName dirName pathName |
	"safeCategory := category copyReplaceAll: ' ' with: ':='."
	fileName := domain, 
						(translator
							ifNil: ['.pot']
							ifNotNil: ['.po']).
	dirName := 'po', FileDirectory slash, 
								(translator 
										ifNil: ['templates'] 
										ifNotNil: [translator localeID posixName]). 
	pathName := dirName , FileDirectory slash , fileName.
	(FileDirectory default directoryNamed: dirName) assureExistence.
	^ pathName
]

{ #category : #private }
GetTextExporter >> export: literals translator: translator domain: domainName [ 
	| fileName |
	"Export a gettext file in a category. literals is a dictionary of keyword -> #(MethodReference...) in the textDomain."
	fileName := self dirNameDomain: domainName translator: translator.
	[stream := FileStream forceNewFileNamed: fileName.
	stream lineEndConvention: #lf.
	stream converter: UTF8TextConverter new.
	self exportHeader: domainName.
	domainName = TextDomainManager defaultDomain
	ifTrue: [self exportInformation: self createExtraInformation].
	self exportBody: literals translator: translator]
		ensure: [stream close]
]

{ #category : #'file out' }
GetTextExporter >> exportBody: literals translator: translator [ 
	"Export a gettext file body. literals is a dictionary of keyword ->
	#(MethodReference...) in the textDomain."
	"Build {sortKey. comment. msgid } to optimize sorting (getting category is
	too slow).
	If there are two or more methods for a mgsid, only first method
	(alphabetical) is used for sorting."
	| sorted msgid sortedMethods category sortKey comment triplets commentUnderLined |
	triplets := literals associations
				collect: [:assoc | 
					msgid := assoc key.
					sortedMethods := assoc value asArray sort.
					category := (Smalltalk at: sortedMethods first classSymbol) category asString.
					sortKey := category , ',' , sortedMethods first printString , ',' , msgid.
					comment := (sortedMethods
								collect: [:each | each actualClass asString , '>>' , each methodSymbol asString])
								inject: category
								into: [:result :methodName | result , ',' , methodName].
					"Replace white spaces to _ because gettext tool might
					replace a space to a new line some times, and it makes
					difficult to take a diff."
					commentUnderLined := comment copyReplaceAll: ' ' with: '_'.
					Array
						with: sortKey
						with: commentUnderLined
						with: msgid].
	"Sort and output the words"
	sorted := triplets
				sort: [:a :b | a first <= b first].
	sorted
		do: [:triplet | 
			comment := triplet second.
			msgid := triplet third.
			self exportRecordHeader: comment.
			self
				exportPhrase: msgid
				translation: (self translationFor: msgid in: translator)]
]

{ #category : #'private-headers' }
GetTextExporter >> exportHeader [
	self exportTag: 'msgid' msg: ''.
	self exportTag: 'msgstr' msg: ''.
	self createHeaders
		do: [:each | self exportHeaderLineKey: each key value: each value].
	stream cr; cr
]

{ #category : #private }
GetTextExporter >> exportHeader: domainName [
	| headers |
	self exportTag: 'msgid' msg: ''.
	self exportTag: 'msgstr' msg: ''.
	headers := self createHeaders.
	headers add: 'X-Etoys-Domain' -> domainName.
	headers do: [:each | self exportHeaderLineKey: each key value: each value].
	stream cr; cr
]

{ #category : #private }
GetTextExporter >> exportHeaderLineKey: keyString value: valueString [ 
	stream nextPut: $";
		 nextPutAll: keyString;
		 nextPut: $:;
		 space;
		 nextPutAll: valueString;
		 nextPutAll: '\n';
		 nextPut: $";
		 cr.
]

{ #category : #private }
GetTextExporter >> exportInformation: anOrderedCollection [
	anOrderedCollection do: [:each |
		self exportRecordHeader: each second.
		self exportPhrase: each third translation: ''].
	stream cr.
]

{ #category : #private }
GetTextExporter >> exportPhrase: phraseString translation: translationString [ 
	| normalizedTrans tmp transStartsWithCR transEndsWithCR|
	phraseString isEmpty
		ifTrue: [^ self].
	self exportTag: 'msgid' msg: phraseString.
	translationString size = 0 ifTrue: [
		normalizedTrans := ''
	] ifFalse: [
		transEndsWithCR := translationString last = (Character cr).
		phraseString last = (Character cr) ifTrue: [
			transEndsWithCR ifTrue: [
				normalizedTrans := translationString
			] ifFalse: [
				normalizedTrans :=  translationString , String cr
			]
		] ifFalse: [
			transEndsWithCR ifTrue: [
				normalizedTrans := translationString allButLast
			] ifFalse: [
				normalizedTrans := translationString
			]
		].
		transStartsWithCR := normalizedTrans first = (Character cr).
		phraseString first = (Character cr) ifTrue: [
			transStartsWithCR ifFalse: [
				tmp := (Character cr asString) , normalizedTrans.
				normalizedTrans := tmp.
			]
		] ifFalse: [
			transStartsWithCR ifTrue: [
				normalizedTrans := normalizedTrans allButFirst
			]
		]
	].
	self exportTag: 'msgstr' msg: normalizedTrans.
	stream cr
]

{ #category : #private }
GetTextExporter >> exportRecordHeader: context [
	stream 
		nextPutAll: '#: ';
		nextPutAll: context;
		cr.
]

{ #category : #private }
GetTextExporter >> exportTag: tag msg: aString [ 
	stream nextPutAll: tag.
	stream space.
	aString ifEmpty: [stream nextPutAll: '""'; cr. ^ self].
	aString lineIndicesDo: [:start :endWithoutDelimiters :end |
		| line |
		line := (end = endWithoutDelimiters)
			ifTrue: [aString copyFrom: start to: endWithoutDelimiters]
			ifFalse: [(aString at: endWithoutDelimiters + 1) = Character cr
				ifTrue: [aString copyFrom: start to: endWithoutDelimiters + 1]
				ifFalse: [(aString copyFrom: start to: endWithoutDelimiters) copyWith: Character cr]].
		stream
			nextPut: $";
			nextPutAll: (self formatString: line);
			nextPut: $";
			cr].
]

{ #category : #exporting }
GetTextExporter >> exportTemplate [
	"GetTextExporter2 new exportTemplate"
	self exportTranslator: nil
]

{ #category : #exporting }
GetTextExporter >> exportTranslator: translator [ 
	"Export translation files. the file extention is 'po', or 'pot' if translator is nil "
	"GetTextExporter2 new exportTranslator: NaturalLanguageTranslator current "
	| domains |
	domains := Dictionary new.
	self appendTranslations: domains.
	self appendTranslationsAlreadyIn: translator to: domains.
	domains
		keysAndValuesDo: [:domainName :value |
			self
				export: value
				translator: translator
				domain: domainName]
]

{ #category : #private }
GetTextExporter >> formatReplacements [
	| replacements |
	replacements := OrderedCollection new.
	replacements add: '\' -> '\\'.
	replacements add: String cr -> '\n'.
	replacements add: String tab -> '\t'.
	replacements add: '"' -> '\"'.
	^ replacements
]

{ #category : #private }
GetTextExporter >> formatString: aString [ 
	| result |
	result := aString.
	self formatReplacements
		do: [:each | result := result copyReplaceAll: each key with: each value].
	^ result
]

{ #category : #'as yet unclassified' }
GetTextExporter >> getTextDomainForPackage: aPackageInfo [ 
	^TextDomainManager domainForPackage: aPackageInfo
]

{ #category : #accessing }
GetTextExporter >> stream [
	^ stream
]

{ #category : #accessing }
GetTextExporter >> stream: aStream [
	stream := aStream
]

{ #category : #private }
GetTextExporter >> translationFor: aKey in: translator [
	| translation |
	translator ifNil: [^ ''].
	TextDomainManager allKnownDomains do: [:domain |
		translation := translator translate: aKey inDomain: domain.
		aKey = translation ifFalse: [^translation]
	].
	^ ''
]
