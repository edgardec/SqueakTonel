"
Editor for Babel's languages.

Open it from

	World Menu >> open... >> Language Editor			(to open on default language)
	World Menu >> open... >> Language Editor for...	(to choose the language)

Or click:

	LanguageEditor openOnDefault.
	LanguageEditor open.

See http://swiki.agro.uba.ar/small_land/191 for documentation

"
Class {
	#name : #LanguageEditor,
	#superclass : #SystemWindow,
	#instVars : [
		'translator',
		'translations',
		'untranslated',
		'selectedTranslation',
		'selectedTranslations',
		'selectedUntranslated',
		'translationsList',
		'untranslatedList',
		'translationText',
		'translationsFilter',
		'untranslatedFilter',
		'newerKeys'
	],
	#classVars : [
		'CheckMethods'
	],
	#category : #'GetText-Editor'
}

{ #category : #private }
LanguageEditor class >> checkMethods [
	^CheckMethods ifNil: [CheckMethods := self initCheckMethods]
]

{ #category : #private }
LanguageEditor class >> ensureVisibilityOfWindow: aWindow [ 
	"private - activate the window"
	| world |
	world := Project current world.
	aWindow expand.
	aWindow comeToFront.
	""
	aWindow
		right: (aWindow right min: world right).
	aWindow
		bottom: (aWindow bottom min: world bottom).
	aWindow
		left: (aWindow left max: world left).
	aWindow
		top: (aWindow top max: world top).
	""
	aWindow flash; flash
]

{ #category : #'initialize-release' }
LanguageEditor class >> initCheckMethods [
	"LanguageEditor initCheckMethods"

	| registry |
	registry := Dictionary new.
	registry
		at: 'es' put: #checkSpanishPhrase:translation:;
		yourself.
	^registry
]

{ #category : #'initialize-release' }
LanguageEditor class >> initialize [
	"initialize the receiver"
	"(TheWorldMenu respondsTo: #registerOpenCommand:)
		ifTrue: [
			TheWorldMenu registerOpenCommand: {'Language Editor' translated. {self. #openOnDefault}}.
			TheWorldMenu registerOpenCommand: {'Language Editor for...' translated. {self. #open}}]"
]

{ #category : #'instance creation' }
LanguageEditor class >> on: localeID [ 
	"answer an instance of the receiver on aLanguage"
	^ self new
		initializeOn: (InternalTranslator cachedTranslations
				at: localeID
				ifAbsent: [self
						inform: ('Translator for {1} is not found' translated format: {localeID}). ^nil])
]

{ #category : #opening }
LanguageEditor class >> open [
	"open the receiver on any language"
	" 
	LanguageEditor open. 
	"
	| menu availableLanguages |
	menu := MenuMorph new defaultTarget: self.
	menu addTitle: 'Language Editor for...' translated.
	""
	availableLanguages := InternalTranslator availableLanguageLocaleIDs sorted: [:x :y | x asString <= y asString].
	availableLanguages ifEmpty:[^self inform:'InternalTranslator not initialized'].
	availableLanguages
		do: [:eachLanguage | ""
			menu
				add: eachLanguage name
				target: self
				selector: #openOn:
				argument: eachLanguage].
	""
	menu popUpInWorld
]

{ #category : #'instance creation' }
LanguageEditor class >> openOn: aLanguage [ 
	"open an instance on aLanguage"
	| editor |
	Project current world submorphs
		do: [:each | ""
			((each isKindOf: LanguageEditor)
					and: [each translator == aLanguage])
				ifTrue: [""
					self ensureVisibilityOfWindow: each.
					^ self]].
	""
	 editor := self on: aLanguage.
	 editor ifNotNil:[^editor openInWorld]
]

{ #category : #opening }
LanguageEditor class >> openOnDefault [
	"open the receiver on the default language"
	self openOn: LocaleID current
]

{ #category : #'initialize-release' }
LanguageEditor class >> unload [
	"the receiver is being unloaded"
	(TheWorldMenu respondsTo: #registerOpenCommand:)
		ifTrue: [""
			TheWorldMenu unregisterOpenCommand: 'Language Editor'.
			TheWorldMenu unregisterOpenCommand: 'Language Editor for...'] 
]

{ #category : #'gui methods' }
LanguageEditor >> addTranslation [
	"translate a phrase"
	| phrase |
	phrase := UIManager default
				request: 'enter the original:' translated
				initialAnswer: ''.

	(phrase isNil
			or: [phrase = ''])
		ifTrue: [
			self beep.
			^ self].

	self translatePhrase: phrase
]

{ #category : #'gui methods' }
LanguageEditor >> applyTranslations [
	"private - try to apply the translations as much as possible all  
	over the image"
	Project current updateLocaleDependents
]

{ #category : #reporting }
LanguageEditor >> asHtml: aString [ 
	| stream |
	stream := String new writeStream.

	aString
		do: [:each | 
			each caseOf: {
				[Character cr] -> [stream nextPutAll: '<br>'].
				[$&] -> [stream nextPutAll: '&amp;'].
				[$<] -> [stream nextPutAll: '&lt;'].
				[$>] -> [stream nextPutAll: '&gt;'].
				[$*] -> [stream nextPutAll: '&star;'].
				[$@] -> [stream nextPutAll: '&at;']}
				 otherwise: [stream nextPut: each]].

	^ stream contents
]

{ #category : #'gui methods' }
LanguageEditor >> browseMethodsWithTranslation [
	| translation |
	self selectedTranslation isZero
		ifTrue: [""
			self beep.
			self inform: 'select the translation to look for' translated.
			^ self].
	""
	translation := self translations at: self selectedTranslation.
	self systemNavigation browseMethodsWithLiteral: translation
]

{ #category : #'gui methods' }
LanguageEditor >> browseMethodsWithUntranslated [
	| untrans |
	self selectedUntranslated isZero
		ifTrue: [""
			self beep.
			self inform: 'select the untrans phrase to look for' translated.
			^ self].
	""
	untrans := self untranslated at: self selectedUntranslated.
	SystemNavigation default browseMethodsWithLiteral: untrans.

]

{ #category : #private }
LanguageEditor >> check [
	"check the translations and answer a collection with the results"
	| results counter phrasesCount checkMethod |
	results := OrderedCollection new.
	untranslated := self untranslated.
	phrasesCount := self translations size + self untranslated size.
	counter := 0.
	checkMethod := self class checkMethods at: self translator localeID printString ifAbsent: [^results].
	
	self translations
		keysAndValuesDo: [:phrase :translation | 
			| result | 
			result := self perform: checkMethod with: phrase with: translation.
			(result notNil
					and: [result notEmpty])
				ifTrue: [results add: {phrase. translation. result}].
		
			counter := counter + 1.
			(counter isDivisibleBy: 50)
				ifTrue: [| percent | 
					percent := counter / phrasesCount * 100 printShowingMaxDecimalPlaces: 2.
					Transcript
						show: ('- checked {1} phrases of {2} ({3}%)...' translated format: {counter. phrasesCount. percent});
						 cr]].

	self untranslated
		do: [:phrase | 
			| result | 
			result := self checkUntranslatedPhrase: phrase.
			(result notNil
					and: [result notEmpty])
				ifTrue: [results add: {phrase. nil. result}].
		
			counter := counter + 1.
			(counter isDivisibleBy: 50)
				ifTrue: [| percent | 
					percent := counter / phrasesCount * 100 printShowingMaxDecimalPlaces: 2.
					Transcript
						show: ('- checked {1} phrases of {2} ({3}%)...' translated format: {counter. phrasesCount. percent});
						 cr]].

	^ results
]

{ #category : #private }
LanguageEditor >> checkPhrase: phraseString translation: translationString [
	^nil
]

{ #category : #private }
LanguageEditor >> checkSpanishPhrase: phraseString translation: translationString [ 
	"check the translation and aswer a string with a comment or a 
	nil meaning no-comments"
	| superResult |
	superResult := self checkPhrase: phraseString translation: translationString.
	superResult isNil
		ifFalse: [^ superResult].
	"For some reason, MCInstaller couldn't read Spanish character. "
	"((translationString includes: $?)
	and: [(translationString includes: $ø) not]) 
		ifTrue: [^ 'øOlvidÛ el signo de pregunta?'].
	((translationString includes: $!)
	and: [(translationString includes: $°) not])
		ifTrue: [^ 'øOlvidÛ el signo de admiraciÛn?'].
	"
	^ nil

]

{ #category : #private }
LanguageEditor >> checkUntranslatedPhrase: phraseString [ 
	"check the phrase an aswer a string with a comment or a nil  
	meaning no-comments"

	(self translations includes: phraseString)
		ifTrue: [^ 'possible double-translation' translated].

	^ nil
]

{ #category : #'gui methods' }
LanguageEditor >> codeSelectedTranslation [
	| keys code |
	keys := selectedTranslations
				collect: [:key | self translations at: key].
	code := String
				streamContents: [:aStream | self translator fileOutOn: aStream keys: keys withBOM: false].
	(StringHolder new contents: code)
		openLabel: 'exported codes' translated
]

{ #category : #'gui methods' }
LanguageEditor >> codeSelectedTranslationAsMimeString [
	| keys code cont |
	keys := selectedTranslations
				collect: [:key | self translations at: key].
	code := String
				streamContents: [:aStream | self translator fileOutOn: aStream keys: keys withBOM: false].

	cont := String streamContents: [:strm |
		strm nextPutAll: '"UTF8+Gzip+Base64 encoded translation for;'; cr.
		strm nextPutAll: '#('.
		keys do: [:each | strm  nextPutAll: '''', each, ''' '.].
		strm nextPutAll: ')"'; cr; cr.
		strm nextPutAll: 'NaturalLanguageTranslator loadForLocaleIsoString: '.
		strm nextPut: $'.
		strm nextPutAll: translator localeID isoString.
		strm nextPut: $'.
		strm nextPutAll: ' fromGzippedMimeLiteral: '.
		strm nextPut: $'.
		strm nextPutAll: code squeakToUtf8 asByteArray zipped base64Encoded.
		strm nextPutAll: '''.'.
		strm cr.
	].
	
	(StringHolder new contents: cont)
		openLabel: 'exported codes in UTF8+Gzip+Base64 encoding' translated
]

{ #category : #'initialization - toolbar' }
LanguageEditor >> createButtonLabel: aString action: actionSelector help: helpString [ 
	"create a toolbar for the receiver"
	| button |
	button := SimpleButtonMorph new target: self;
				 label: aString translated "font: Preferences standardButtonFont";
				 actionSelector: actionSelector;
				 setBalloonText: helpString translated;
				 color: translator defaultBackgroundColor twiceDarker;
				 borderStyle: (BorderStyle raised width: 2).
	""
	^ button
]

{ #category : #'initialization - toolbar' }
LanguageEditor >> createMainToolbar [
	"create a toolbar for the receiver"
	| toolbar |
	toolbar := self createRow.
	""
"	toolbar
		addMorphBack: (self
				createUpdatingButtonWording: #debugWording
				action: #switchDebug
				help: 'Switch the debug flag')."
	toolbar addTransparentSpacerOfSize: 5 @ 0.
	""
	toolbar
		addMorphBack: (self
				createButtonLabel: 'new'
				action: #newTranslations
				help: 'Create translations for new language.').
	toolbar
		addMorphBack: (self
				createButtonLabel: 'save'
				action: #saveToFile
				help: 'Save the translations to a file').
	toolbar
		addMorphBack: (self
				createButtonLabel: 'load'
				action: #loadFromFile
				help: 'Load the translations from a file').
	toolbar
		addMorphBack: (self
				createButtonLabel: 'merge'
				action: #mergeFromFile
				help: 'Merge the current translations with the translations in a file').
	""
	toolbar addTransparentSpacerOfSize: 5 @ 0.
	toolbar
		addMorphBack: (self
				createButtonLabel: 'apply'
				action: #applyTranslations
				help: 'Apply the translations as much as possible.').
	""
	toolbar addTransparentSpacerOfSize: 5 @ 0.
	toolbar
		addMorphBack: (self
				createButtonLabel: 'check translations'
				action: #check
				help: 'Check the translations and report the results.').
	toolbar
		addMorphBack: (self
				createButtonLabel: 'report'
				action: #report
				help: 'Create a report.').
	toolbar
		addMorphBack: (self
				createButtonLabel: 'gettext'
				action: #getText
				help: 'Interface with gettext.').
	""
	^ toolbar
]

{ #category : #'initialization - toolbar' }
LanguageEditor >> createRow [
	"create a row"
	| row |
	row := AlignmentMorph newRow.
	row layoutInset: 3;
		 wrapCentering: #center;
		 cellPositioning: #leftCenter.
	""
	^ row
]

{ #category : #'initialization - statusbar' }
LanguageEditor >> createStatusbar [
	"create the statusbar for the receiver"
	| statusbar |
	statusbar := self createRow.
	statusbar addMorph: ((UpdatingStringMorph on: self selector: #status) growable: true;
			 useStringFormat;
			 hResizing: #spaceFill;
			 stepTime: 2000).
	^ statusbar
]

{ #category : #'initialization - toolbar' }
LanguageEditor >> createTranslationsToolbar [
	"create a toolbar for the receiver"
	| toolbar |
	toolbar := self createRow.
	""
	toolbar
		addMorphBack: (self
				createUpdatingButtonWording: #translationsFilterWording
				action: #filterTranslations
				help: 'Filter the translations list.').
	toolbar addTransparentSpacerOfSize: 5 @ 0.
	""
	toolbar
		addMorphBack: (self
				createButtonLabel: 'search'
				action: #searchTranslation
				help: 'Search for a translation containing...').
	toolbar addTransparentSpacerOfSize: 5 @ 0.
	toolbar
		addMorphBack: (self
				createButtonLabel: 'remove'
				action: #removeTranslation
				help: 'Remove the selected translation.  If none is selected, ask for the one to remove.').
	""
	toolbar addTransparentSpacerOfSize: 5 @ 0.
	toolbar
		addMorphBack: (self
				createButtonLabel: 'where'
				action: #browseMethodsWithTranslation
				help: 'Launch a browser on all methods that contain the phrase as a substring of any literal String.').
	toolbar addTransparentSpacerOfSize: 5 @ 0.
	toolbar
		addMorphBack: (self
				createButtonLabel: 'r-unused'
				action: #removeTranslatedButUnusedStrings
				help: 'Remove all the strings that are not used by the system').
	toolbar addTransparentSpacerOfSize: 5 @ 0.
	toolbar
		addMorphBack: (self
				createButtonLabel: 'add '
				action: #addTranslation
				help: 'Add a new phrase').

	^ toolbar
]

{ #category : #'initialization - toolbar' }
LanguageEditor >> createUntranslatedToolbar [
	"create a toolbar for the receiver"
	| toolbar |
	toolbar := self createRow.
	""
	toolbar
		addMorphBack: (self
				createUpdatingButtonWording: #untranslatedFilterWording
				action: #filterUntranslated
				help: 'Filter the untranslated list.').
	toolbar addTransparentSpacerOfSize: 5 @ 0.
	""
	toolbar
		addMorphBack: (self
				createButtonLabel: 'search'
				action: #searchUntranslated
				help: 'Search for a untranslated phrase containing...').
	toolbar addTransparentSpacerOfSize: 5 @ 0.
	toolbar
		addMorphBack: (self
				createButtonLabel: 'remove'
				action: #removeUntranslated
				help: 'Remove the selected untranslated phrease.  If none is selected, ask for the one to remove.').
	""
	toolbar addTransparentSpacerOfSize: 5 @ 0.
	toolbar
		addMorphBack: (self
				createButtonLabel: 'translate'
				action: #translate
				help: 'Translate the selected untranslated phrase or a new phrase').
	""
	toolbar addTransparentSpacerOfSize: 5 @ 0.
	toolbar
		addMorphBack: (self
				createButtonLabel: 'where'
				action: #browseMethodsWithUntranslated
				help: 'Launch a browser on all methods that contain the phrase as a substring of any literal String.').
	toolbar addTransparentSpacerOfSize: 5 @ 0.
	toolbar
		addMorphBack: (self
				createButtonLabel: 'r-unused'
				action: #removeUntranslatedButUnusedStrings
				help: 'Remove all the strings that are not used by the system').
	^ toolbar
]

{ #category : #'initialization - toolbar' }
LanguageEditor >> createUpdatingButtonWording: wordingSelector action: actionSelector help: helpString [ 
	"create a toolbar for the receiver"
	| button |
	button := (UpdatingSimpleButtonMorph newWithLabel: '-') target: self;
				 wordingSelector: wordingSelector;
				 actionSelector: actionSelector;
				 setBalloonText: helpString translated;
				 color: translator defaultBackgroundColor twiceDarker;
				 borderStyle: (BorderStyle raised width: 1);
				 cornerStyle: #square.
	""
	^ button
]

{ #category : #'open\/close' }
LanguageEditor >> delete [
	"Remove the receiver as a submorph of its owner"
	self model: nil.
	super delete 
]

{ #category : #'gui methods' }
LanguageEditor >> deselectAllTranslation [
	selectedTranslations := IdentitySet new.
	self changed: #allSelections
]

{ #category : #'gui methods' }
LanguageEditor >> filterTranslations [
	| filter |
	filter := UIManager default
		request: 'filter with
(empty string means no-filtering)' translated
		initialAnswer: self translationsFilter.

	self filterTranslations: filter
]

{ #category : #'gui methods' }
LanguageEditor >> filterTranslations: aString [ 
| filter |
filter := aString ifNil:[''].
""
	translationsFilter := filter.
	self refreshTranslations.

]

{ #category : #'gui methods' }
LanguageEditor >> filterUntranslated [
	| filter |
	filter := UIManager default
		request: 'filter with
(empty string means no-filtering)' translated
		initialAnswer: self untranslatedFilter.

	self filterUntranslated: filter
]

{ #category : #'gui methods' }
LanguageEditor >> filterUntranslated: aString [ 
	| filter |
	filter := aString
				ifNil: [''].
	""
	untranslatedFilter := filter.
	self refreshUntranslated
]

{ #category : #'gui methods' }
LanguageEditor >> getText [
	| menu |
	menu := MenuMorph new defaultTarget: self.
	""
	menu
		add: 'gettext template' translated
		target: self
		selector: #getTextExportTemplate.
	menu lastItem setBalloonText: 'exports the translations to gettext separated format.' translated.
	menu
		add: 'gettext export' translated
		target: self
		selector: #getTextExport.
	menu lastItem setBalloonText: 'Exports the translations to GetText format.' translated.

	""
	menu
		add: 'gettext import' translated
		target: self
		selector: #getTextImport.
	menu lastItem setBalloonText: 'Imports the translations from GetText format.' translated.
	""
	menu popUpInWorld
]

{ #category : #'gui methods' }
LanguageEditor >> getTextExport [
	Cursor wait
		showWhile: [GetTextExporter new exportTranslator: self model]
]

{ #category : #'gui methods' }
LanguageEditor >> getTextExportTemplate [
	Cursor wait
		showWhile: [GetTextExporter new exportTemplate] 
]

{ #category : #'gui methods' }
LanguageEditor >> getTextImport [
	| menu |
	menu := MenuMorph new defaultTarget: self.
	menu addTitle: 'Choose translation file' translated.
	menu add: 'All *.po files' translated action: #getTextImportAll.
	menu add: 'Choose a file' translated action: #getTextImportAFile.
	menu popUpInWorld
]

{ #category : #'gui methods' }
LanguageEditor >> getTextImportAFile [
	| fileName |
	fileName := FileChooserDialog openOnSuffixList: { 'po' } label: 'Select a File:' translated.
	fileName ifNil: [^self]. 

	self
		withUnboundModelDo: [:trans | Cursor wait
				showWhile: [GetTextImporter new
						import: trans
						fileNamed: fileName]]
]

{ #category : #'gui methods' }
LanguageEditor >> getTextImportAll [
	self
		withUnboundModelDo: [:trans | Cursor wait
				showWhile: [GetTextImporter import: trans allDirectory: FileDirectory default]].
	self refreshBoth
]

{ #category : #stef }
LanguageEditor >> identifyUnusedStrings [
	"self new identifyUnusedStrings"
	translationsList getList
		do: [:each | 
			Transcript show: each.
			Transcript show: (Smalltalk
					allSelect: [:method | method
							hasLiteralSuchThat: [:lit | lit isString
									and: [lit includesSubstring: each caseSensitive: true]]]) size printString; cr]
]

{ #category : #initialization }
LanguageEditor >> initializeNewerKeys [

	newerKeys := Set new.

]

{ #category : #initialization }
LanguageEditor >> initializeOn: aLanguage [ 
	"initialize the receiver on aLanguage"
	""
	selectedTranslation := 0.
	selectedUntranslated := 0.
	selectedTranslations := IdentitySet new.
	""
	translator := aLanguage.
	""
	self model: aLanguage.
	self setLabel: 'Language editor for: ' translated , self translator name.
	""
	self initializeToolbars.
	self initializePanels.
	self initializeStatusbar.
	self initializeNewerKeys.

]

{ #category : #initialization }
LanguageEditor >> initializePanels [
	"initialize the receiver's panels"
	translationsList := PluggableListMorphOfMany
				on: self
				list: #translations
				primarySelection: #selectedTranslation
				changePrimarySelection: #selectedTranslation:
				listSelection: #selectedTranslationsAt:
				changeListSelection: #selectedTranslationsAt:put:
				menu: #translationsMenu:
				keystroke: #translationsKeystroke:.
	translationsList setBalloonText: 'List of all the translated phrases.' translated.
	""
	untranslatedList := PluggableListMorph
				on: self
				list: #untranslated
				selected: #selectedUntranslated
				changeSelected: #selectedUntranslated:
				menu: #untranslatedMenu:
				keystroke: #untranslatedKeystroke:.
	untranslatedList setBalloonText: 'List of all the untranslated phrases.' translated.
	""
	translationText := PluggableTextMorph
				on: self
				text: #translation
				accept: #translation:
				readSelection: nil
				menu: nil.
	translationText setBalloonText: 'Translation for the selected phrase in the upper list.' translated.
	""
	self
		addMorph: translationsList
		frame: (0 @ 0.18 corner: 0.5 @ 0.66).
	self
		addMorph: untranslatedList
		frame: (0.5 @ 0.18 corner: 1 @ 0.93).
	self
		addMorph: translationText
		frame: (0 @ 0.66 corner: 0.5 @ 0.93).
	self hResizing: #shrinkWrap
]

{ #category : #'initialization - statusbar' }
LanguageEditor >> initializeStatusbar [
	"initialize the receiver's statusbar"
	self
		addMorph: self createStatusbar
		frame: (0 @ 0.93 corner: 1 @ 1)
]

{ #category : #'initialization - toolbar' }
LanguageEditor >> initializeToolbars [
	"initialize the receiver's toolbar"
	self
		addMorph: self createMainToolbar
		frame: (0 @ 0 corner: 1 @ 0.09).
	""
	self
		addMorph: self createTranslationsToolbar
		frame: (0 @ 0.09 corner: 0.5 @ 0.18).
	self
		addMorph: self createUntranslatedToolbar
		frame: (0.5 @ 0.09 corner: 1 @ 0.18)
]

{ #category : #'gui methods' }
LanguageEditor >> loadFromFile [
	| fileName |
	fileName := self selectTranslationFileName.
	fileName isNil
		ifTrue: [""
			self beep.
			^ self].
	""
	Cursor wait
		showWhile: [
			self translator loadFromFileNamed: fileName.
			self refreshBoth]
]

{ #category : #'gui methods' }
LanguageEditor >> mergeFromFile [
	| fileName |
	fileName := self selectTranslationFileName.
	fileName isNil
		ifTrue: [""
			self beep.
			^ self].
	""
	Cursor wait
		showWhile: [
			self translator loadFromFileNamed: fileName.
			self refreshBoth]
]

{ #category : #'gui methods' }
LanguageEditor >> newTranslations [
	"private - try to apply the translations as much as possible all 
	over the image"
	| result newID |
	result := UIManager default request: 'New locale ID string?' translated initialAnswer: Locale current determineLocaleID isoString.
	result isEmpty
		ifTrue: ["Do nothing"
			^ self].
	newID := LocaleID isoString: result.
	InternalTranslator
		newLocaleID: (LocaleID isoString: result).
	self class openOn: newID
]

{ #category : #stef }
LanguageEditor >> numberOfTimesStringIsUsed: aString [

	^ (self systemNavigation allSelect: [:method | method
							hasLiteralSuchThat: [:lit | lit isString
									and: [lit includesSubstring: aString caseSensitive: true]]]) size
]

{ #category : #updating }
LanguageEditor >> okToChange [
	"Allows a controller to ask this of any model"
	self selectedTranslation isZero
		ifTrue: [^ true].
	""
	translationText hasUnacceptedEdits
		ifFalse: [^ true].
	^ (CustomMenu confirm: 'Discard the changes to currently selected translated phrase?' translated)
		and: [""
			translationText hasUnacceptedEdits: false.
			true]
]

{ #category : #'message handling' }
LanguageEditor >> perform: selector orSendTo: otherTarget [ 
	"I wish to intercept and handle selector myself"
	^ self perform: selector
]

{ #category : #'gui methods' }
LanguageEditor >> phrase: phraseString translation: translationString [ 
	"set the models's translation for phraseString"
	self translator phrase: phraseString translation: translationString.
	self refreshBoth.

	newerKeys add: phraseString.

]

{ #category : #'gui methods' }
LanguageEditor >> phraseToTranslate [
	"answer a phrase to translate.  use the selected untranslated phrase or ask for a new one"
	^ self selectedUntranslated isZero
		ifTrue: [UIManager default
				multiLineRequest: 'new phrase to translate' translated
				centerAt: Sensor cursorPoint
				initialAnswer: ''
				answerHeight: 200]
		ifFalse: [self untranslated at: self selectedUntranslated]
]

{ #category : #reporting }
LanguageEditor >> printHeaderReportOn: aStream [ 
	"append to aStream a header report of the receiver with swiki  
	format"
	aStream nextPutAll: '!!';
		
		nextPutAll: ('Language: {1}' translated format: {self translator localeID isoString});
		 cr.

	aStream nextPutAll: '- ';
		
		nextPutAll: ('{1} translated phrases' translated format: {self translator translations size});
		 cr.

	aStream nextPutAll: '- ';
		
		nextPutAll: ('{1} untranslated phrases' translated format: {self translator untranslated size});
		 cr.

	aStream cr; cr
]

{ #category : #reporting }
LanguageEditor >> printReportOn: aStream [ 
	"append to aStream a report of the receiver with swiki format"
	self printHeaderReportOn: aStream.
	self printUntranslatedReportOn: aStream.
	self printTranslationsReportOn: aStream
]

{ #category : #reporting }
LanguageEditor >> printTranslationsReportOn: aStream [ 
	"append to aStream a report of the receiver's translations"
	| originalPhrases |
	aStream nextPutAll: '!';
		 nextPutAll: 'translations' translated;
		 cr.

	originalPhrases := self translator translations keys sorted.

	originalPhrases
		do: [:each | 
			aStream
				nextPutAll: ('|{1}|{2}|' format: {self asHtml: each. self
							asHtml: (self translator translate: each)});
				 cr].

	aStream cr; cr
]

{ #category : #reporting }
LanguageEditor >> printUntranslatedReportOn: aStream [ 
	"append to aStream a report of the receiver's translations"
	aStream nextPutAll: '!';
		 nextPutAll: 'not translated' translated;
		 cr.

	self untranslated sorted
		do: [:each | 
			aStream
				nextPutAll: ('|{1}|' format: {self asHtml: each});
				 cr].

	aStream cr; cr
]

{ #category : #updating }
LanguageEditor >> refreshBoth [
	self refreshUntranslated

]

{ #category : #updating }
LanguageEditor >> refreshTranslations [
	"refresh the translations panel"
	self selectedTranslation: 0.
	translations := nil.
	self changed: #translations.

]

{ #category : #updating }
LanguageEditor >> refreshUntranslated [
"refresh the untranslated panel"
	self refreshTranslations.
	self selectedUntranslated: 0.
	untranslated := nil.
	self changed: #untranslated.

]

{ #category : #stef }
LanguageEditor >> removeTranslatedButUnusedStrings [
	(self confirm: 'Are you sure that you want to remove unused strings?' translated)
		ifFalse: [^ self].
	translationsList getList
		do: [:each | 
			| timesUsed | 
			timesUsed := self numberOfTimesStringIsUsed: each.
			Transcript show: each.
			Transcript show: timesUsed printString;
				 cr.
			timesUsed isZero
				ifTrue: [self translator removeTranslationFor: each]]
]

{ #category : #'gui methods' }
LanguageEditor >> removeTranslation [
	"remove the selected translation"
	| translation |
	self selectedTranslation isZero
		ifTrue: [""
			self beep.
			self inform: 'select the translation to remove' translated.
			^ self].
	""
	translation := self translations at: self selectedTranslation.
""
	(self
			confirm: ('Removing "{1}".
Are you sure you want to do this?' translated format: {translation}))
		ifFalse: [^ self].
""
	self translator removeTranslationFor: translation.
	self refreshBoth
]

{ #category : #'gui methods' }
LanguageEditor >> removeUntranslated [
	"remove the selected untranslated phrase"
	| untrans |
	self selectedUntranslated isZero
		ifTrue: [""
			self beep.
			self inform: 'select the untranslated phrase to remove' translated.
			^ self].
	""
	untrans := self untranslated at: self selectedUntranslated.
	""
	(self
			confirm: ('Removing "{1}".
Are you sure you want to do this?' translated format: {untrans}))
		ifFalse: [^ self].
	""
	self translator removeUntranslated: untrans
]

{ #category : #stef }
LanguageEditor >> removeUntranslatedButUnusedStrings [
	(self confirm: 'Are you sure that you want to remove unused strings?' translated)
		ifFalse: [^ self].
	untranslatedList getList
		do: [:each | 
			| timesUsed | 
			timesUsed := self numberOfTimesStringIsUsed: each.
			Transcript show: each.
			Transcript show: timesUsed printString;
				 cr.
			timesUsed isZero 
				ifTrue: [self translator removeUntranslated: each]].

	self refreshUntranslated.

]

{ #category : #'gui methods' }
LanguageEditor >> report [

	UIManager default
		edit: self reportString
		label: 'report' translated.
]

{ #category : #reporting }
LanguageEditor >> reportString [
	"answer a string with a report of the receiver"
	| stream |
	stream := String new writeStream.
	self printReportOn: stream.
	^ stream contents
]

{ #category : #'gui methods' }
LanguageEditor >> resetNewerKeys [

	self initializeNewerKeys.

]

{ #category : #'gui methods' }
LanguageEditor >> saveToFile [
	"save the translator to a file"
	| fileName |
	fileName := UIManager default saveFilenameRequest: 'file name' translated initialAnswer: translator localeID isoString , '.translation'.
	fileName
		ifNil: [self beep.
			^ self].
	Cursor wait
		showWhile: [self translator saveToFileNamed: fileName]
]

{ #category : #'gui methods' }
LanguageEditor >> searchTranslation [
	| search |
	search := UIManager default request: 'search for' translated initialAnswer: ''.
	(search isNil
			or: [search isEmpty])
		ifTrue: [
			self beep.
			^ self].

self searchTranslation: search
]

{ #category : #'gui methods' }
LanguageEditor >> searchTranslation: aString [ 
	| results index |
	results := self translations
				select: [:each | ""
					('*' , aString , '*' match: each)
						or: ['*' , aString , '*' match: (self translator translate: each)]].
	""
	results isEmpty
		ifTrue: [""
			self inform: 'no matches for' translated , ' ''' , aString , ''''.
			^ self].
	""
	results size = 1
		ifTrue: [""
			self selectTranslationPhrase: results first.
			^ self].
	""
	index := (PopUpMenu
				labelArray: (results
						collect: [:each | ""
							(each copy replaceAll: Character cr with: $\)
								, ' -> '
								, ((self translator translate: each) copy replaceAll: Character cr with: $\)]))
				startUpWithCaption: 'select the translation...' translated.
	""
	index isZero
		ifTrue: [""
			self beep.
			^ self].
	""
	self
		selectTranslationPhrase: (results at: index)
]

{ #category : #'gui methods' }
LanguageEditor >> searchUntranslated [
	| search |
	search := UIManager default request: 'search for' translated initialAnswer: ''.
	(search isNil
			or: [search isEmpty])
		ifTrue: [
			self beep.
			^ self].

	self searchUntranslated: search
]

{ #category : #'gui methods' }
LanguageEditor >> searchUntranslated: aString [ 
	| untranslateds results index |
	untranslateds := self untranslated.
	results := untranslateds
				select: [:each | '*' , aString , '*' match: each].
	""
	results isEmpty
		ifTrue: [""
			self inform: 'no matches for' translated , ' ''' , aString , ''''.
			^ self].
	""
	results size = 1
		ifTrue: [""
			self selectUntranslatedPhrase: results first.
			^ self].
	""
	index := (PopUpMenu
				labelArray: (results
						collect: [:each | each copy replaceAll: Character cr with: $\]))
				startUpWithCaption: 'select the untranslated phrase...' translated.
	""
	index isZero
		ifTrue: [""
			self beep.
			^ self].
	""
	self
		selectUntranslatedPhrase: (results at: index)
]

{ #category : #'gui methods' }
LanguageEditor >> selectAllTranslation [
	selectedTranslations := (1 to: self translations size) asIdentitySet.
	self changed: #allSelections
]

{ #category : #'gui methods' }
LanguageEditor >> selectNewerKeys [

	self deselectAllTranslation.
	newerKeys do: [ :k |
		| index |
		(index := self translations indexOf: k) > 0 ifTrue: [
			self selectedTranslationsAt: index put: true ] ]

]

{ #category : #'gui methods' }
LanguageEditor >> selectTranslationFileName [
	"answer a file with a translation"
	
	^ FileChooserDialog openOnSuffixList: { 'translation'  } label:  'Select the file...' translated.

]

{ #category : #'gui methods' }
LanguageEditor >> selectTranslationPhrase: phraseString [ 
	self selectedTranslation: (self translations indexOf: phraseString)
]

{ #category : #'gui methods' }
LanguageEditor >> selectUntranslatedPhrase: phraseString [ 
	self
		selectedUntranslated: (self untranslated indexOf: phraseString)
]

{ #category : #accessing }
LanguageEditor >> selectedTranslation [
	"answer the selectedTranslation"
	^ selectedTranslation
]

{ #category : #accessing }
LanguageEditor >> selectedTranslation: anInteger [ 
	"change the receiver's selectedTranslation"
	selectedTranslation := anInteger.
	""
	self changed: #selectedTranslation.
	self changed: #translation
]

{ #category : #accessing }
LanguageEditor >> selectedTranslationsAt: index [
	^ selectedTranslations includes: index
]

{ #category : #accessing }
LanguageEditor >> selectedTranslationsAt: index put: value [ 
	value = true
		ifTrue: [selectedTranslations add: index]
		ifFalse: [selectedTranslations
				remove: index
				ifAbsent: []]
]

{ #category : #accessing }
LanguageEditor >> selectedUntranslated [
	"answer the selectedUntranslated"
	^ selectedUntranslated
]

{ #category : #accessing }
LanguageEditor >> selectedUntranslated: anInteger [ 
	"change the selectedUntranslated"
	selectedUntranslated := anInteger.
	""
	self changed: #selectedUntranslated
]

{ #category : #'gui methods' }
LanguageEditor >> status [
	"answer a status string"
	| translationsSize untranslatedSize |
	translationsSize := self translator translations size.
	untranslatedSize := self translator untranslated size.
	^ '| {1} phrases | {2} translated | {3} untranslated |' translated format: {translationsSize + untranslatedSize. translationsSize. untranslatedSize}
]

{ #category : #'gui methods' }
LanguageEditor >> translate [
	"translate a phrase"
	| phrase |
	phrase := self phraseToTranslate.
	""
	(phrase isNil
			or: [phrase = ''])
		ifTrue: [""
			self beep.
			^ self].
	""
	self translatePhrase: phrase.
	self refreshBoth
]

{ #category : #'gui methods' }
LanguageEditor >> translatePhrase: aString [ 
	"translate aString"
	| translation |
	translation := UIManager default
				multiLineRequest: 'translation for: ' translated , '''' , aString , ''''
				centerAt: Sensor cursorPoint
				initialAnswer: aString
				answerHeight: 200.

	(translation isNil
			or: [translation = ''])
		ifTrue: [""
			self beep.
			^ self].

	self phrase: aString translation: translation
]

{ #category : #accessing }
LanguageEditor >> translation [
	"answer the translation for the selected phrase"
	self selectedTranslation isZero
		ifTrue: [^ '<select a phrase from the upper list>' translated].
	""
	^ self translator
		translate: (self translations at: self selectedTranslation)
]

{ #category : #accessing }
LanguageEditor >> translation: aStringOrText [ 
	"change the translation for the selected phrase"
	| phrase |
	self selectedTranslation isZero
		ifTrue: [^ self].
	phrase := self translations at: self selectedTranslation.
	translator
		phrase: phrase
		translation: aStringOrText asString.
	newerKeys add: phrase.
	^ true
]

{ #category : #accessing }
LanguageEditor >> translations [
	"answet the translator's translations"
	| allTranslations filterString |
	translations ifNotNil: [^translations].
	allTranslations := self translator translations keys.
	""
	filterString := self translationsFilter.
	""
	filterString isEmpty
		ifFalse: [allTranslations := allTranslations
						select: [:each | ""
							('*' , filterString , '*' match: each)
								or: ['*' , filterString , '*'
										match: (self translator translate: each)]]].
""
	^ translations := allTranslations sorted
]

{ #category : #accessing }
LanguageEditor >> translationsFilter [
^translationsFilter ifNil:['']
]

{ #category : #'gui methods' }
LanguageEditor >> translationsFilterWording [
	^ (self translationsFilter isEmpty
		ifTrue: ['filter' translated]
		ifFalse: ['filtering: {1}' translated format:{self translationsFilter}]) 
]

{ #category : #'gui methods' }
LanguageEditor >> translationsKeystroke: aChar [ 
	"Respond to a Command key in the translations list."
	aChar == $x
		ifTrue: [^ self removeTranslation].
	aChar == $E
		ifTrue: [^ self browseMethodsWithTranslation]
]

{ #category : #'gui methods' }
LanguageEditor >> translationsMenu: aMenu [ 
	^ aMenu add: 'remove (x)' translated action: #removeTranslation;
		 add: 'where (E)' translated action: #browseMethodsWithTranslation;
		 add: 'select all' translated action: #selectAllTranslation;
		 add: 'deselect all' translated action: #deselectAllTranslation;
		 add: 'select changed keys' translated action: #selectNewerKeys;
		 add: 'export selection' translated action: #codeSelectedTranslation;
		 add: 'export selection in do-it form' translated action: #codeSelectedTranslationAsMimeString;
		 add: 'reset changed keys' translated action: #resetNewerKeys;
		 yourself
]

{ #category : #private }
LanguageEditor >> translator [
	^translator
]

{ #category : #accessing }
LanguageEditor >> untranslated [
	"answer the translator's untranslated phrases"
	

	| all filterString |
	untranslated ifNotNil: [^ untranslated].
	all := self translator untranslated.
	""
	filterString := self untranslatedFilter.
	""
	filterString isEmpty
		ifFalse: [all := all
						select: [:each | ""
							('*' , filterString , '*' match: each)
								or: ['*' , filterString , '*'
										match: (self translator translate: each)]]].
	""
	^ untranslated := all sorted
]

{ #category : #accessing }
LanguageEditor >> untranslatedFilter [
	^ untranslatedFilter
		ifNil: ['']
]

{ #category : #'gui methods' }
LanguageEditor >> untranslatedFilterWording [
	^ self untranslatedFilter isEmpty
		ifTrue: ['filter' translated]
		ifFalse: ['filtering: {1}' translated format: {self untranslatedFilter}]
]

{ #category : #'gui methods' }
LanguageEditor >> untranslatedKeystroke: aChar [ 
	"Respond to a Command key in the translations list."
	aChar == $t
		ifTrue: [^ self translate].
	aChar == $E
		ifTrue: [^ self browseMethodsWithUntranslated]
]

{ #category : #'gui methods' }
LanguageEditor >> untranslatedMenu: aMenu [ 
	^ aMenu add: 'remove' translated action: #removeUntranslated;
		 add: 'translate (t)' translated action: #translate;
		 add: 'where (E)' translated action: #browseMethodsWithUntranslated;
		 yourself
]

{ #category : #updating }
LanguageEditor >> update: aSymbol [ 
	"Receive a change notice from an object of whom the receiver  
	is a dependent."
	super update: aSymbol.
	""
	aSymbol == #untranslated
		ifTrue: [self refreshUntranslated].
	aSymbol == #translations
		ifTrue: [self refreshTranslations]
]

{ #category : #private }
LanguageEditor >> withUnboundModelDo: aBlock [ 
	"Private - Evaluate aBlock with the receiver temporary  
	unbound from the model.  
	 
	Useful to perform a batch of modifications to the model  
	without updating the view."
	| formerModel |
	formerModel := self model.
	self model: nil.
	[aBlock value: formerModel]
		ensure: [self model: formerModel]
]
