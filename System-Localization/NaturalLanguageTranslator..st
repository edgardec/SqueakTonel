"
abstract class of natural language translator.
Class side manages and holds loaded instances of concrete classes.
"
Class {
	#name : #NaturalLanguageTranslator,
	#superclass : #Object,
	#instVars : [
		'id'
	],
	#classVars : [
		'Translators'
	],
	#category : #'System-Localization'
}

{ #category : #accessing }
NaturalLanguageTranslator class >> availableForLocaleID: localeID [ 
	"Answer available locale ID.
	If translator is not found for correct locale ID, then isoLanguage is
	attempted for the key."
	^ self translators
		at: localeID
		ifAbsentPut: [localeID hasParent
				ifTrue: [self translators
						at: localeID parent
						ifAbsent: [self default]]
				ifFalse: [self default]]
]

{ #category : #accessing }
NaturalLanguageTranslator class >> availableLanguageLocaleIDs [
	"Return the locale ids for the currently available languages.  
	Meaning those which either internally or externally have  
	translations available."
	"NaturalLanguageTranslator availableLanguageLocaleIDs"
	^ self translators values collect:[:each | each localeID]
]

{ #category : #accessing }
NaturalLanguageTranslator class >> current [
	^ self availableForLocaleID: LocaleID current
]

{ #category : #accessing }
NaturalLanguageTranslator class >> default [
	"Answer translator for backstop"
	"self default translate: 'test'"
	^ (self == NaturalLanguageTranslator ifTrue: [InternalTranslator] ifFalse: [self]) new
		localeID: (LocaleID isoLanguage: 'en')
]

{ #category : #accessing }
NaturalLanguageTranslator class >> domainRegistered: aDomainName [
	"notify that new TextDomain is registered"
	self translators do: [:each | each domainRegistered: aDomainName]
]

{ #category : #accessing }
NaturalLanguageTranslator class >> domainUnregistered: aDomainName [
	"notify that new TextDomain is unregistered"
	self translators do: [:each | each domainUnregistered: aDomainName]
]

{ #category : #'file-services' }
NaturalLanguageTranslator class >> fileReaderServicesForFile: fullName suffix: suffix [ 
	"Answer the file services associated with given file"
	^ (suffix = self translationSuffix) | (suffix = '*')
		ifTrue: [{self serviceMergeLanguageTranslations}]
		ifFalse: [#()]
]

{ #category : #'class initialization' }
NaturalLanguageTranslator class >> initialize [
	Smalltalk addToStartUpList: NaturalLanguageTranslator after: FileDirectory.

]

{ #category : #accessing }
NaturalLanguageTranslator class >> isoLanguage: isoLanguage [
	"Return the generic language translator as there is no information about the country code"

	^self isoLanguage: isoLanguage isoCountry: nil
]

{ #category : #accessing }
NaturalLanguageTranslator class >> isoLanguage: isoLanguage isoCountry: isoCountry [
	^self localeID: (LocaleID  isoLanguage: isoLanguage isoCountry: isoCountry)
]

{ #category : #'file-services' }
NaturalLanguageTranslator class >> loadForLocaleIsoString: localeString fromGzippedMimeLiteral: mimeString [ 
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

{ #category : #accessing }
NaturalLanguageTranslator class >> localeChanged [
	"notify some project starts to use this locale.
	 this facility may use the event to load translation data dynamically" 
	self current setCurrent

]

{ #category : #accessing }
NaturalLanguageTranslator class >> localeID: localeID [ 
	^ self cachedTranslations
		at: localeID
		ifAbsentPut: [self new localeID: localeID]
]

{ #category : #'file-services' }
NaturalLanguageTranslator class >> mergeTranslationFileNamed: fileFullNameString [ 
	"merge the translation in the file named fileFullNameString"

	FileStream readOnlyFileNamed: fileFullNameString do: [:stream |
		| localeID translator |
		localeID := LocaleID isoString: stream localName sansPeriodSuffix.
		translator := self localeID: localeID.
		translator loadFromStream: stream].
	LanguageEnvironment resetKnownEnvironments.


]

{ #category : #'class initialization' }
NaturalLanguageTranslator class >> privateStartUp [
	self resetCaches.
	GetTextTranslator privateStartUp.
	InternalTranslator privateStartUp.
	self localeChanged.
]

{ #category : #accessing }
NaturalLanguageTranslator class >> removeLocaleID: localeID [ 
	"self removeLocaleID: (LocaleID isoString: 'ja-kids')"
	^ self translators
		removeKey: localeID
		ifAbsent: []
]

{ #category : #'class initialization' }
NaturalLanguageTranslator class >> resetCaches [
	Translators := nil.
]

{ #category : #'file-services' }
NaturalLanguageTranslator class >> serviceMergeLanguageTranslations [
	"Answer a service for merging of translation files"
	^ SimpleServiceEntry
		provider: self
		label: 'merge the translation file'
		selector: #mergeTranslationFileNamed:
		description: 'merge the translation file into the language named like the file'
		buttonLabel: 'merge'
]

{ #category : #'file-services' }
NaturalLanguageTranslator class >> services [
	"Answer potential file services associated with this class"
	^ {self serviceMergeLanguageTranslations}
]

{ #category : #'class initialization' }
NaturalLanguageTranslator class >> startUp: resuming [ 
	resuming
		ifFalse: [^ self].
	self privateStartUp.
]

{ #category : #translation }
NaturalLanguageTranslator class >> translate: aString toLocaleID: localeID [
	"translate for default domain"
	^ (self availableForLocaleID: localeID)
		translate: aString
]

{ #category : #translation }
NaturalLanguageTranslator class >> translate: aString toLocaleID: localeID inDomain: aDomainName [
	^ (self availableForLocaleID: localeID)
		translate: aString inDomain: aDomainName
]

{ #category : #translation }
NaturalLanguageTranslator class >> translateWithoutLoading: aString toLocaleID: localeID [
	"translate for default domain"
	^self translateWithoutLoading: aString toLocaleID: localeID inDomain: TextDomainManager defaultDomain.

]

{ #category : #translation }
NaturalLanguageTranslator class >> translateWithoutLoading: aString toLocaleID: localeID inDomain: aDomainName [
	"try to translate with small footprint:
		if GetTextTranslator hasn't loaded MO, try to use InternalTranslator.
		if InternalTranslator isn't available, then actually load MO and use it"
	| translator |
	translator := self availableForLocaleID: localeID.
	(translator isDomainLoaded: aDomainName) ifFalse: [
		(InternalTranslator availableLanguageLocaleIDs includes: localeID)
			ifTrue:  [translator := InternalTranslator localeID: localeID].
	].
	^translator translate: aString inDomain: aDomainName
]

{ #category : #accessing }
NaturalLanguageTranslator class >> translationSuffix [

	^'translation'
]

{ #category : #accessing }
NaturalLanguageTranslator class >> translators [
	^ Translators ifNil: [Translators := Dictionary new]	
]

{ #category : #accessing }
NaturalLanguageTranslator >> atRandom [

	self subclassResponsibility.

]

{ #category : #translation }
NaturalLanguageTranslator >> checkPhrase: phrase translation: translation [
]

{ #category : #'user interface' }
NaturalLanguageTranslator >> defaultBackgroundColor [
	"answer the receiver's defaultBackgroundColor for views"
	^ Color cyan
]

{ #category : #accessing }
NaturalLanguageTranslator >> displayLanguage [
	^ id displayLanguage
]

{ #category : #accessing }
NaturalLanguageTranslator >> displayName [
	^ id displayName
]

{ #category : #accessing }
NaturalLanguageTranslator >> domainRegistered: aDomainName [
	"notify that new TextDomain is registered.  Concrete subclass can responds to this event if needed"
]

{ #category : #accessing }
NaturalLanguageTranslator >> domainUnregistered: aDomainName [
	"notify that new TextDomain is unregistered.  Concrete subclass can responds to this event if needed"
]

{ #category : #'fileIn\/fileOut' }
NaturalLanguageTranslator >> fileOutHeader [
	^ '''Translation dictionary'''
]

{ #category : #'fileIn\/fileOut' }
NaturalLanguageTranslator >> fileOutHeaderOn: aStream [ 
	aStream nextChunkPut: self fileOutHeader;
		 cr.
	aStream timeStamp; cr.
	aStream nextPut: $!.
	aStream nextChunkPut: '(' , self class name , ' localeID: ' , id storeString , ')'.
	aStream cr
]

{ #category : #'fileIn\/fileOut' }
NaturalLanguageTranslator >> fileOutOn: aStream [ 
	"self current fileOutOn: Transcript. Transcript endEntry"
	self fileOutHeaderOn: aStream.
	self fileOutOn: aStream keys: nil
]

{ #category : #accessing }
NaturalLanguageTranslator >> isDomainLoaded: aDomainName [
	"ask if translation dictionary for the domain has been loaded and available now for use"
	self subclassResponsibility.
]

{ #category : #accessing }
NaturalLanguageTranslator >> isoCountry [
	^self localeID isoCountry
]

{ #category : #accessing }
NaturalLanguageTranslator >> isoLanguage [
	^self localeID isoLanguage
]

{ #category : #accessing }
NaturalLanguageTranslator >> localeID [
	^id
]

{ #category : #'initialize-release' }
NaturalLanguageTranslator >> localeID: anID [
	id := anID
]

{ #category : #'fileIn\/fileOut' }
NaturalLanguageTranslator >> nextChunkPut: anObject on: aStream [ 
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
NaturalLanguageTranslator >> phrase: phraseString translation: translationString [ 
	self generics at: phraseString put: translationString asString.
	self changed: #translations.
	self changed: #untranslated.
]

{ #category : #printing }
NaturalLanguageTranslator >> printOn: aStream [
	aStream nextPutAll: self class name; nextPut: $(; print: self localeID; nextPut: $)
]

{ #category : #translation }
NaturalLanguageTranslator >> rawPhrase: phraseString translation: translationString [ 
	self generics at: phraseString put: translationString asString.

]

{ #category : #translation }
NaturalLanguageTranslator >> rawRemoveUntranslated: untranslated [

	self class allKnownPhrases removeKey: untranslated ifAbsent: [].
	self changed: #untranslated.
]

{ #category : #translation }
NaturalLanguageTranslator >> removeTranslationFor: phraseString [
	self generics removeKey: phraseString ifAbsent: [].
	self changed: #translations.
	self changed: #untranslated.
]

{ #category : #translation }
NaturalLanguageTranslator >> removeUntranslated: untranslated [

	self class allKnownPhrases removeKey: untranslated ifAbsent: [].

]

{ #category : #'fileIn\/fileOut' }
NaturalLanguageTranslator >> scanFrom: aStream [ 
	^ self scanFrom: aStream environment: Environment current
]

{ #category : #'fileIn\/fileOut' }
NaturalLanguageTranslator >> scanFrom: aStream environment: anEnvironment [
	"Read a definition of dictionary.  
	Make sure current locale corresponds my locale id"
	| newTranslations currentPlatform |
	newTranslations := Dictionary new.
	currentPlatform := Locale currentPlatform.
	[| aString assoc |
	Locale currentPlatform: (Locale localeID: id).
	[aString := aStream nextChunk withSqueakLineEndings.
	aString size > 0] whileTrue: 
		[assoc := Compiler evaluate: aString environment: anEnvironment.
		assoc value = ''
			ifTrue: [self class registerPhrase: assoc key]
			ifFalse: [newTranslations add: assoc]]]
		ensure: [Locale currentPlatform: currentPlatform].
	self mergeTranslations: newTranslations
]

{ #category : #'language switching' }
NaturalLanguageTranslator >> setCurrent [
	"notify locale of the translator become current"

]

{ #category : #translation }
NaturalLanguageTranslator >> translate: aString [
	^self translate: aString 
		inDomain: TextDomainManager defaultDomain
]

{ #category : #translation }
NaturalLanguageTranslator >> translate: aString in: aContext [
]

{ #category : #translation }
NaturalLanguageTranslator >> translate: aString inDomain: aDomainName [
	^ aString
]

{ #category : #translation }
NaturalLanguageTranslator >> translationFor: aString [
	^self translate: aString
]

{ #category : #accessing }
NaturalLanguageTranslator >> translations [
	^self generics
]

{ #category : #accessing }
NaturalLanguageTranslator >> untranslated [
	| translations |
	translations := self translations.
	^self class allKnownPhrases reject: [:each | translations includesKey: each]
]

{ #category : #'fileIn\/fileOut' }
NaturalLanguageTranslator >> writeAsMimeString [

	| fileName fileStream tmpStream |
	tmpStream := MultiByteBinaryOrTextStream on: ''.
	tmpStream converter: UTF8TextConverter new.
	self fileOutOn: tmpStream.

	fileName := id isoString, '.translation.gz.mime'.
	fileStream := FileStream newFileNamed: fileName.
	fileStream nextPutAll: tmpStream contents asByteArray zipped base64Encoded.
	fileStream close.

]
