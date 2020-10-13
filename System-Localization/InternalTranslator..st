"
An InternalTranslator is used a translation dictionary in a image.
You can use it without any external translation file.

Structure:
 generics		Dictionary -- msgid -> msgstr

"
Class {
	#name : #InternalTranslator,
	#superclass : #NaturalLanguageTranslator,
	#instVars : [
		'generics'
	],
	#classVars : [
		'AllKnownPhrases',
		'CachedTranslations'
	],
	#category : #'System-Localization'
}

{ #category : #private }
InternalTranslator class >> allKnownPhrases [
	^AllKnownPhrases ifNil: [AllKnownPhrases := Dictionary new: 2051]
]

{ #category : #accessing }
InternalTranslator class >> availableLanguageLocaleIDs [
	"Return locale ids for the internal translation dictionary."
	"InternalTranslator availableLanguageLocaleIDs"
	^ self cachedTranslations values collect:[:each | each localeID]
]

{ #category : #private }
InternalTranslator class >> cachedTranslations [
	"CachedTranslations := nil" 
	^CachedTranslations ifNil: [CachedTranslations := Dictionary new]
]

{ #category : #'private loading' }
InternalTranslator class >> directoryForLanguage: isoLanguage country: isoCountry create: createDir [
	"Try to locate the <prefs>/locale/<language>{/<country>} folder.
	If createDir is set, create the path down to country or language, depending on wether it's specified..
	Return the directory for country or language depending on specification.
	If neither exists, nil"

	"NaturalLanguageTranslator directoryForLanguage: 'es' country: nil create: true"
	"NaturalLanguageTranslator directoryForLanguage: 'de' country: 'DE' create: true"
	"NaturalLanguageTranslator directoryForLanguage: 'en' country: 'US' create: false"
	"NaturalLanguageTranslator directoryForLanguage: 'en' country: nil create: true"

	"If this fails, there is nothing we can do about it here"
	| localeDir  countryDir languageDir |
	localeDir := self localeDirCreate: createDir.
	localeDir ifNil: [^nil].

	isoCountry ifNil: [
		languageDir := localeDir directoryNamed: isoLanguage.
		createDir
			ifTrue: [languageDir assureExistence].
		^languageDir exists
			ifTrue: [languageDir]
			ifFalse: [nil]].

	countryDir := languageDir directoryNamed: isoCountry.
	createDir
		ifTrue: [countryDir assureExistence].

	^countryDir exists
		ifTrue: [countryDir]
		ifFalse: [nil]
]

{ #category : #'private loading' }
InternalTranslator class >> directoryForLocaleID: localeID create: createDir [
	"Try to locate the <prefs>/locale/<language>{/<country>} folder.
	If createDir is set, create the path down to country or language, depending on locale.
	Return the directory for country or language depending on locale.
	If neither exists, nil"

	"NaturalLanguageTranslator directoryForLanguage: 'de' country: nil readOnly: true"
	"NaturalLanguageTranslator directoryForLanguage: 'de' country: 'DE' readOnly: true"
	"NaturalLanguageTranslator directoryForLanguage: 'en' country: 'US' readOnly: false"
	"NaturalLanguageTranslator directoryForLanguage: 'en' country: nil readOnly: true"

	^self directoryForLanguage: localeID isoLanguage country: localeID isoCountry create: createDir
]

{ #category : #'class initialization' }
InternalTranslator class >> discardAllTranslations [
	AllKnownPhrases := nil.
	self resetCaches.
]

{ #category : #'file-services' }
InternalTranslator class >> fileReaderServicesForFile: fullName suffix: suffix [ 
	"Answer the file services associated with given file"
	^ (suffix = self translationSuffix) | (suffix = '*')
		ifTrue: [{self serviceMergeLanguageTranslations}]
		ifFalse: [#()]
]

{ #category : #'private loading' }
InternalTranslator class >> loadAvailableExternalLocales [
	"private - register locales IDs based on the content of the <prefs>/locale/ directory"
	| localeDir |
	localeDir := self localeDirCreate: false.
	localeDir ifNil: [^ #()].

	localeDir directoryNames
		do: [:langDirName | 
			| langDir | 
			langDir := localeDir directoryNamed: langDirName.

			(langDir fileNamesMatching: '*.' , self translationSuffix)
				ifNotEmpty: [self loadTranslatorForIsoLanguage: langDirName isoCountry: nil].

			langDir directoryNames
				do: [:countryDirName | 
					| countryDir | 
					countryDir := langDir directoryNamed: countryDirName.
					(countryDir fileNamesMatching: '*.' , self translationSuffix)
						ifNotEmpty: [self loadTranslatorForIsoLanguage: langDirName isoCountry: countryDirName]
			]
		].

]

{ #category : #'private loading' }
InternalTranslator class >> loadExternalTranslationsFor: translator [
	"Try to load translations from external external files.
	The files are located in the <prefs>/locale/<language>{/<country>} folder.
	There can be more than one file for each location, so applications can install their own partial translation tables. All files in the specific folder are loaded."

	| translationDir |
	translationDir := self directoryForLocaleID: translator localeID create: false.
	translationDir ifNil: [ ^nil ]. 
	(translationDir fileNamesMatching: '*.' , self translationSuffix)
		do: [:fileName | translator loadFromFileNamed: (translationDir fullNameFor: fileName)]
]

{ #category : #'file-services' }
InternalTranslator class >> loadForLocaleIsoString: localeString fromGzippedMimeLiteral: mimeString [ 
	"merge the translation from the mime literal."
	| stream localeID translator gs rbStream s currentPlatform |
	s := Base64MimeConverter mimeDecodeToBytes: mimeString readStream.
	gs := GZipReadStream on: s.
	rbStream := MultiByteBinaryOrTextStream with: gs contents asString.
	rbStream converter: UTF8TextConverter new.
	rbStream reset.
	localeID := LocaleID isoString: localeString.
	currentPlatform := Locale currentPlatform.
	[Locale
		currentPlatform: (Locale localeID: localeID).
	stream := ReadStream on: rbStream contents]
		ensure: [Locale currentPlatform: currentPlatform].
	translator := self localeID: localeID.
	translator loadFromStream: stream.
	LanguageEnvironment resetKnownEnvironments
]

{ #category : #'private loading' }
InternalTranslator class >> loadTranslatorForIsoLanguage: isoLanguage isoCountry: isoCountry [ 
	"private - load the translations from <prefs>/locale/ directory  
	the procedure is to assure the existence of a translator for the  
	given language/country and then load the external translations for this translator"

	| translator |
	translator := self newLocaleID: (LocaleID isoLanguage: isoLanguage isoCountry: isoCountry).

	self loadExternalTranslationsFor: translator
]

{ #category : #'private loading' }
InternalTranslator class >> localeDirCreate: createDir [
	"Try to locate the <prefs>/locale/ folder.
	If createDir is set, try to create the path.
	If it doesn't exist, return nil"

	"If this fails, there is nothing we can do about it here"
	| prefDir  localeDir |
	(createDir not
			and: [ExternalSettings preferenceDirectory isNil])
		ifTrue: [^ nil].

	prefDir := ExternalSettings assuredPreferenceDirectory.
	prefDir exists
		ifFalse: [^nil].


	localeDir := prefDir directoryNamed: 'locale'.
	createDir
		ifTrue: [localeDir assureExistence].
	^localeDir exists
		ifTrue: [localeDir]
		ifFalse: [nil]
]

{ #category : #accessing }
InternalTranslator class >> localeID: localeID [ 
	"For backward compatibility, see NaturalLanguageTranslator >> fileOutHeaderOn:."
	^ self newLocaleID: localeID
]

{ #category : #accessing }
InternalTranslator class >> mergeLegacyTranslators [
	self availableLanguageLocaleIDs
		do: [:localeID | (NaturalLanguageTranslator translators includesKey: localeID)
				ifFalse: [NaturalLanguageTranslator translators
						at: localeID
						put: (self newLocaleID: localeID)]]
]

{ #category : #'file-services' }
InternalTranslator class >> mergeTranslationFileNamed: fileFullNameString [ 
	"merge the translation in the file named fileFullNameString"

	| stream localeID translator |
	stream := FileStream readOnlyFileNamed: fileFullNameString.
	[localeID := LocaleID isoString: stream localName sansPeriodSuffix.
	translator := self localeID: localeID.
	translator loadFromStream: stream]
		ensure: [stream close].
	LanguageEnvironment resetKnownEnvironments.


]

{ #category : #accessing }
InternalTranslator class >> newLocaleID: localeID [ 
	^ self cachedTranslations
		at: localeID
		ifAbsentPut: [self new localeID: localeID]
]

{ #category : #'class initialization' }
InternalTranslator class >> privateStartUp [
	self loadAvailableExternalLocales.
	self mergeLegacyTranslators.

]

{ #category : #private }
InternalTranslator class >> registerPhrase: phrase [
	"Using a Dictionary so we can lookup existing string instead of creating needless copies when loading a translation."
	self allKnownPhrases at: phrase put: phrase
]

{ #category : #private }
InternalTranslator class >> registeredPhraseFor: phrase [
	"Using a Dictionary so we can lookup existing string instead of creating needless copies when loading a translation."
	^self allKnownPhrases at: phrase ifAbsentPut: [phrase]
]

{ #category : #accessing }
InternalTranslator class >> removeLocaleID: localeID [ 
	"self removeLocaleID: (LocaleID isoString: 'ja-kids')"
	self cachedTranslations
		removeKey: localeID
		ifAbsent: [].
	NaturalLanguageTranslator privateStartUp
]

{ #category : #'class initialization' }
InternalTranslator class >> resetCaches [
	CachedTranslations := nil.

]

{ #category : #'file-services' }
InternalTranslator class >> serviceMergeLanguageTranslations [
	"Answer a service for merging of translation files"
	^ SimpleServiceEntry
		provider: self
		label: 'merge the translation file' translatedNoop
		selector: #mergeTranslationFileNamed:
		description: 'merge the translation file into the language named like the file' translatedNoop
		buttonLabel: 'merge' translatedNoop
]

{ #category : #'file-services' }
InternalTranslator class >> services [
	"Answer potential file services associated with this class"
	^ {self serviceMergeLanguageTranslations}
]

{ #category : #private }
InternalTranslator class >> translationSuffix [
	^'translation'
]

{ #category : #accessing }
InternalTranslator >> atRandom [

	^ generics atRandom value.

]

{ #category : #translation }
InternalTranslator >> checkPhrase: phrase translation: translation [
]

{ #category : #'user interface' }
InternalTranslator >> defaultBackgroundColor [
	"answer the receiver's defaultBackgroundColor for views"
	^ Color cyan
]

{ #category : #'fileIn\/fileOut' }
InternalTranslator >> fileOutHeader [
	^ '''Translation dictionary'''
]

{ #category : #'user interface' }
InternalTranslator >> fileOutHeaderOn: aStream [ 
	aStream binary.
	UTF8TextConverter writeBOMOn: aStream.
	aStream text.
	aStream nextChunkPut: self fileOutHeader;
		 cr.
	aStream timeStamp; cr.
	aStream nextPut: $!.
	aStream nextChunkPut: '(' , self class name , ' localeID: ' , id storeString , ')'.
	aStream cr
]

{ #category : #'user interface' }
InternalTranslator >> fileOutHeaderOn: aStream withBOM: bomFlag [
	bomFlag ifTrue: [
		aStream binary.
		UTF8TextConverter writeBOMOn: aStream.
		aStream text.
	].
	aStream nextChunkPut: self fileOutHeader;
		 cr.
	aStream timeStamp; cr.
	aStream nextPut: $!.
	aStream nextChunkPut: '(' , self class name , ' localeID: ' , id storeString , ')'.
	aStream cr
]

{ #category : #'fileIn\/fileOut' }
InternalTranslator >> fileOutOn: aStream [ 
	"self current fileOutOn: Transcript. Transcript endEntry"
	self fileOutOn: aStream keys: nil withBOM: true.

]

{ #category : #'fileIn\/fileOut' }
InternalTranslator >> fileOutOn: aStream keys: keys withBOM: bomFlag [
	"self current fileOutOn: Transcript. Transcript endEntry"
	self fileOutHeaderOn: aStream withBOM: bomFlag.
	(keys
		ifNil: [generics keys sort])
		do: [:key | self
				nextChunkPut: (generics associationAt: key)
				on: aStream].
	keys
		ifNil: [self untranslated
				do: [:each | self nextChunkPut: each -> '' on: aStream]].
	aStream nextPut: $!;
		 cr
]

{ #category : #private }
InternalTranslator >> generics [
	^generics ifNil: [generics := Dictionary new]
]

{ #category : #accessing }
InternalTranslator >> isDomainLoaded: aDomainName [
	^true

]

{ #category : #'private store-retrieve' }
InternalTranslator >> loadFromFileNamed: fileNameString [ 
	"Load translations from an external file"

	| stream |
	[stream := FileStream readOnlyFileNamed: fileNameString.
	self loadFromStream: stream]
		ensure: [stream close].
	self changed: #translations.
	self changed: #untranslated.

]

{ #category : #'private store-retrieve' }
InternalTranslator >> loadFromRefStream: stream [ 
	"Load translations from an external file"
	| loadedArray refStream |
	refStream := ReferenceStream on: stream.
	[loadedArray := refStream next]
		ensure: [refStream close].
	self processExternalObject: loadedArray 
]

{ #category : #'private store-retrieve' }
InternalTranslator >> loadFromStream: stream [ 
	"Load translations from an external file"
	| header isFileIn |
	header := '''Translation dictionary'''.
	isFileIn := (stream next: header size)
				= header.
	stream reset.
	isFileIn
		ifTrue: [stream fileInAnnouncing: 'Loading ' translated, stream localName]
		ifFalse: [self loadFromRefStream: stream]
]

{ #category : #'private store-retrieve' }
InternalTranslator >> mergeTranslations: newTranslations [
	"Merge a new set of translations into the exiting table.
	Overwrites existing entries."

	newTranslations keysAndValuesDo: [:key :value |
		self rawPhrase: (self class registeredPhraseFor: key) translation: value].
	self changed: #translations.
	self changed: #untranslated.
]

{ #category : #'fileIn\/fileOut' }
InternalTranslator >> nextChunkPut: anObject on: aStream [ 
	| i remainder terminator |
	terminator := $!.
	remainder := anObject storeString.
	[(i := remainder indexOf: terminator) = 0]
		whileFalse: [aStream
				nextPutAll: (remainder copyFrom: 1 to: i).
			aStream nextPut: terminator.
			"double imbedded terminators"
			remainder := remainder copyFrom: i + 1 to: remainder size].
	aStream nextPutAll: remainder.
	aStream nextPut: terminator; cr.
]

{ #category : #translation }
InternalTranslator >> phrase: phraseString translation: translationString [ 
	self generics at: phraseString put: translationString asString.
	self changed: #translations.
	self changed: #untranslated.
]

{ #category : #'private store-retrieve' }
InternalTranslator >> processExternalObject: anArray [ 
	"pivate - process the external object"

	"new format -> {translations. untranslated}"

	anArray second do: [:each | self class registerPhrase: each].

	self mergeTranslations: anArray first
]

{ #category : #translation }
InternalTranslator >> rawPhrase: phraseString translation: translationString [ 
	self generics at: phraseString put: translationString asString.

]

{ #category : #translation }
InternalTranslator >> rawRemoveUntranslated: untranslated [

	self class allKnownPhrases removeKey: untranslated ifAbsent: [].
	self changed: #untranslated.
]

{ #category : #translation }
InternalTranslator >> removeTranslationFor: phraseString [
	self generics removeKey: phraseString ifAbsent: [].
	self changed: #translations.
	self changed: #untranslated.
]

{ #category : #translation }
InternalTranslator >> removeUntranslated: untranslated [

	self class allKnownPhrases removeKey: untranslated ifAbsent: [].

]

{ #category : #'private store-retrieve' }
InternalTranslator >> saveToFileNamed: fileNameString [ 
	"save the receiver's translations to a file named fileNameString"
	| stream |
	"Set true if you need to save as binary"
	false
		ifTrue: [stream := ReferenceStream fileNamed: fileNameString.
			stream nextPut: {self translations. self untranslated}.
			stream close.
			^ self].
	stream := FileStream fileNamed: fileNameString.
	[self fileOutOn: stream]
		ensure: [stream close]
]

{ #category : #'fileIn\/fileOut' }
InternalTranslator >> scanFrom: aStream [ 
	^ self scanFrom: aStream environment: Environment current
]

{ #category : #'fileIn\/fileOut' }
InternalTranslator >> scanFrom: aStream environment: anEnvironment [
	"Read a definition of dictionary.  
	Make sure current locale corresponds my locale id"
	| aString newTranslations assoc currentPlatform |
	newTranslations := Dictionary new.
	currentPlatform := Locale currentPlatform.
	[Locale
		currentPlatform: (Locale localeID: id).
	[aString := aStream nextChunk withSqueakLineEndings.
	aString size > 0] whileTrue: 
		[assoc := Compiler evaluate: aString environment: anEnvironment.
		assoc value = ''
			ifTrue: [self class registerPhrase: assoc key]
			ifFalse: [newTranslations add: assoc]]]
		ensure: [Locale currentPlatform: currentPlatform].
	self mergeTranslations: newTranslations
]

{ #category : #translation }
InternalTranslator >> translate: aString inDomain: aDomainName [ 
	| translator |
	^ self generics
		at: aString
		ifAbsent: [self localeID hasParent
				ifTrue: [translator := self class cachedTranslations
								at: self localeID parent
								ifAbsent: [^ aString].
					translator translate: aString inDomain: aDomainName]
				ifFalse: [aString]]
]

{ #category : #accessing }
InternalTranslator >> translations [
	^self generics
]

{ #category : #accessing }
InternalTranslator >> untranslated [
	| translations |
	translations := self translations.
	^self class allKnownPhrases reject: [:each | translations includesKey: each]
]
