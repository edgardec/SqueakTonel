"
Main comment stating the purpose of this class and relevant relationship to other classes.



	http://www.w3.org/WAI/ER/IG/ert/iso639.htm
	http://www.oasis-open.org/cover/iso639a.html
	See also
	http://oss.software.ibm.com/cvs/icu/~checkout~/icuhtml/design/language_code_issues.html
	http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.10
	
ISO 3166
http://mitglied.lycos.de/buran/knowhow/codes/locales/

"
Class {
	#name : #Locale,
	#superclass : #Object,
	#instVars : [
		'id',
		'shortDate',
		'longDate',
		'time',
		'decimalSymbol',
		'digitGrouping',
		'currencySymbol',
		'currencyNotation',
		'measurement',
		'offsetLocalToUTC',
		'offsetVMToUTC',
		'dstActive'
	],
	#classVars : [
		'Current',
		'CurrentPlatform',
		'KnownLocales',
		'LanguageSymbols',
		'LocaleChangeListeners',
		'PlatformEncodings',
		'Previous'
	],
	#category : #'System-Localization'
}

{ #category : #notification }
Locale class >> addLocalChangedListener: anObjectOrClass [
	self localeChangedListeners add: anObjectOrClass
]

{ #category : #accessing }
Locale class >> clipboadInterpreter [
	^NoConversionClipboardInterpreter new
]

{ #category : #accessing }
Locale class >> current [
	"Current := nil"
	Current ifNil: [
		Current := self determineCurrentLocale.
		"Transcript show: 'Current locale: ' , Current localeID asString; cr"].
	^Current
]

{ #category : #accessing }
Locale class >> currentPlatform [
	"CurrentPlatform := nil"
	CurrentPlatform ifNil: [CurrentPlatform := self determineCurrentLocale].
	^CurrentPlatform
]

{ #category : #accessing }
Locale class >> currentPlatform: locale [
	CurrentPlatform := locale.
	LanguageEnvironment startUp.

]

{ #category : #accessing }
Locale class >> currentPlatform: locale during: aBlock [ 
	"Alter current language platform during a block"
	| backupPlatform |
	backupPlatform := self currentPlatform.
	[self currentPlatform: locale.
	aBlock value]
		ensure: [self currentPlatform: backupPlatform]
]

{ #category : #'platform specific' }
Locale class >> defaultEncodingName: languageSymbol [ 
	| encodings platformName osVersion |
	platformName := Smalltalk platformName.
	osVersion := Smalltalk getSystemAttribute: 1002.
	encodings := self platformEncodings at: languageSymbol
				ifAbsent: [self platformEncodings at: #default].
	encodings at: platformName ifPresent: [:encoding | ^encoding].
	encodings at: platformName , ' ' , osVersion
		ifPresent: [:encoding | ^encoding].
	^encodings at: #default
]

{ #category : #'platform specific' }
Locale class >> defaultInputInterpreter [
	| platformName |
	platformName := Smalltalk platformName.
	platformName = 'Win32' ifTrue: [^UTF32InputInterpreter new].
	^NoInputInterpreter new
]

{ #category : #private }
Locale class >> determineCurrentLocale [
	"For now just return the default locale.
	A smarter way would be to determine the current platforms default locale."
	"Locale determineCurrentLocale"

	^self new determineLocale
]

{ #category : #private }
Locale class >> initKnownLocales [
	| locales |
	locales := Dictionary new.

	"Init the locales for which we have translations"
	InternalTranslator availableLanguageLocaleIDs do: [:id |
		locales at: id put: (Locale new localeID: id)].
	^locales
]

{ #category : #'class initialization' }
Locale class >> initialize [
	"Locale initialize"
	Smalltalk addToStartUpList: Locale.
	Preferences
		addPreference: #useLocale
		categories: #('general' )
		default: false
		balloonHelp: 'Use the system locale to set the system language, etc., at startup.  For time-zone handling, see automaticTimezone.'
]

{ #category : #'class initialization' }
Locale class >> initializePlatformEncodings [
	"Locale initializePlatformEncodings"

	| platform |
	PlatformEncodings isNil ifTrue: [ PlatformEncodings := Dictionary new ].

	platform := PlatformEncodings at: 'default' ifAbsentPut: Dictionary new.
	platform
		at: 'default' put: 'iso8859-1';
		at: 'Win32 CE' put: 'utf-8';
		yourself.

	platform := PlatformEncodings at: 'ja' ifAbsentPut: Dictionary new.
	platform
		at: 'default' put: 'shift-jis';
		at: 'unix' put: 'euc-jp';
		at: 'Win32 CE' put: 'utf-8';
		yourself.

	platform := PlatformEncodings at: 'ko' ifAbsentPut: Dictionary new.
	platform
		at: 'default' put: 'euc-kr';
		at: 'Win32 CE' put: 'utf-8';
		yourself.

	platform := PlatformEncodings at: 'zh' ifAbsentPut: Dictionary new.
	platform
		at: 'default' put: 'gb2312';
		at: 'unix' put: 'euc-cn';
		at: 'Win32 CE' put: 'utf-8';
		yourself.

]

{ #category : #accessing }
Locale class >> isoLanguage: isoLanguage [
	^self isoLanguage: isoLanguage isoCountry: nil
]

{ #category : #accessing }
Locale class >> isoLanguage: isoLanguage isoCountry: isoCountry [
	^self localeID: (LocaleID  isoLanguage: isoLanguage isoCountry: isoCountry)
]

{ #category : #accessing }
Locale class >> isoLocale: aString [
	
]

{ #category : #private }
Locale class >> knownLocales [
	"KnownLocales := nil"
	^KnownLocales ifNil: [KnownLocales := self initKnownLocales]
]

{ #category : #accessing }
Locale class >> languageSymbol: languageSymbol [
	"Locale languageSymbol: #Deutsch"

	^self isoLanguage: (LanguageSymbols at: languageSymbol)
]

{ #category : #notification }
Locale class >> localeChanged [
	SystemNavigation default allBehaviorsDo: [:b |
		b == self ifFalse: [b localeChanged]].
]

{ #category : #notification }
Locale class >> localeChangedGently [
	SystemNavigation default allBehaviorsDo: [:b | b == self ifFalse: [b localeChangedGently]].
]

{ #category : #notification }
Locale class >> localeChangedListeners [
	^LocaleChangeListeners ifNil: [LocaleChangeListeners := OrderedCollection new]
]

{ #category : #accessing }
Locale class >> localeID: id [
	^self knownLocales at: id ifAbsentPut: [Locale new localeID: id]
]

{ #category : #'class initialization' }
Locale class >> platformEncodings [
	PlatformEncodings isEmptyOrNil ifTrue: [ self initializePlatformEncodings ].
	^PlatformEncodings

]

{ #category : #accessing }
Locale class >> previous [

	^ Previous

]

{ #category : #private }
Locale class >> resetKnownLocales [

	KnownLocales := nil

]

{ #category : #'system startUp' }
Locale class >> startUp: resuming [
	resuming ifFalse: [^self].
	(Preferences valueOfFlag: #useLocale)
		ifTrue: [
			| newID |
			newID := self current determineLocaleID.
			newID ~= LocaleID current
				ifTrue: [self switchAndInstallFontToID: newID gently: true]]
]

{ #category : #accessing }
Locale class >> stringForLanguageNameIs: localeID [ 
	"Answer a string for a menu determining whether the given  
	symbol is the project's natural language"
	^ (self current localeID = localeID
		ifTrue: ['<yes>']
		ifFalse: ['<no>'])
		, localeID displayName
]

{ #category : #accessing }
Locale class >> switchAndInstallFontToID: localeID [ 
	"Locale switchAndInstallFontToID: (LocaleID isoLanguage: 'de')"
	| locale |
	locale := Locale localeID: localeID.
	locale languageEnvironment isFontAvailable
		ifFalse: [(self confirm: 'This language needs additional fonts.
Do you want to install the fonts?' translated)
				ifTrue: [locale languageEnvironment installFont]
				ifFalse: [^ self]].
	self
		switchTo: locale
]

{ #category : #accessing }
Locale class >> switchAndInstallFontToID: localeID gently: gentlyFlag [
	| locale result env envFound ret fontInImage menu |
	"Logic:
		- not in Rainbow, 
			- if the font is in the image, use the font.
			- if the font is not in the image,
				- ask to choose:
					- load font
					- try to enable pango, if pango is available
					- or cancel.
			- if the previous step fails, notify the user that you cannot switch to the language.
	Details:
		- how to check non-pango font is available:
			- if the language environment for the locale doesn't exist, the font is not available.
			- if font loading fails, it is not available.
		- how to check if the language environment doesn't exist:
			- if the locales languageEnvironment is Latin1 but the locale isn't it is not available.
	"	
	locale := Locale localeID: localeID.
	env := locale languageEnvironment.
	result := true.
	envFound := (Latin1Environment supportedLanguages includes: locale isoLanguage) or: [(env isMemberOf: Latin1Environment) not].
	fontInImage := envFound and: [env isFontAvailable].
	fontInImage ifFalse: [
		menu := MenuMorph new.
		menu defaultTarget: menu.
		envFound ifTrue: [menu add: 'load font' translated selector: #modalSelection: argument: #loadFont].
		menu add:  'cancel' translated selector: #modalSelection: argument: #cancel.
		menu addTitle: 'This language needs additional fonts.
Do you want to install the fonts?' translated.
		ret := menu invokeModal.
		ret = #loadFont ifTrue: [result := env installFont. result ifTrue: [StrikeFont setupDefaultFallbackTextStyle]].
		(ret ~~ #loadFont and: [ret ~~ #enablePango]) ifTrue: [result := false]].
	result ifFalse: [self inform: 'Cannot load additional fonts' translated] ifTrue: [self switchTo: locale gently: gentlyFlag].

]

{ #category : #accessing }
Locale class >> switchTo: locale [
	self switchTo: locale gently: false.

]

{ #category : #accessing }
Locale class >> switchTo: locale gently: gentlyFlag [
	"Locale switchTo: (Locale isoLanguage: 'de')"
	| availableID |
	availableID := (NaturalLanguageTranslator availableForLocaleID: locale localeID) localeID.
	Current localeID = availableID
		ifFalse: [Previous := Current.
				CurrentPlatform := Current := Locale localeID: availableID.
				NaturalLanguageTranslator localeChanged.
				gentlyFlag ifTrue: [self localeChangedGently] ifFalse: [self localeChanged]]
]

{ #category : #accessing }
Locale class >> switchToID: localeID [
	"Locale switchToID: (LocaleID isoLanguage: 'de') "

	self switchTo: (Locale localeID: localeID)
]

{ #category : #accessing }
Locale >> determineLocale [
	self localeID: self determineLocaleID
]

{ #category : #accessing }
Locale >> determineLocaleID [
	"Locale current determineLocaleID"
	| isoLang isoCountry |
	isoLang := self fetchISO2Language
				ifNil: [^ self localeID].
	isoCountry := self fetchISOCountry
				ifNil: [^ LocaleID isoLanguage: isoLang].
	^ LocaleID isoLanguage: isoLang isoCountry: isoCountry
]

{ #category : #private }
Locale >> fetchISO2Language [
	"Locale current fetchISO2Language"
	| lang isoLang |
	lang := self primLanguage.
	lang ifNil: [^nil].
	lang := lang copyUpTo: 0 asCharacter.
	lang size == 2
		ifTrue: [^lang].
	isoLang := ISOLanguageDefinition iso3LanguageDefinition: lang.
	^isoLang
		ifNil: [nil]
		ifNotNil: [isoLang iso2]
]

{ #category : #private }
Locale >> fetchISOCountry [
	"Locale current fetchISOCountry"
	| countryCode |
	countryCode := self primCountry
				ifNil: [^ nil].
	^ countryCode copyUpTo: 0 asCharacter
]

{ #category : #accessing }
Locale >> iconForNativeLanguage [

	^ (NaturalLanguageFormTranslator localeID: self localeID) translate: 'LanguageNameInNativeLanguage'.

]

{ #category : #accessing }
Locale >> isoCountry [
	^self localeID isoCountry
]

{ #category : #accessing }
Locale >> isoLanguage [
	^self localeID isoLanguage
]

{ #category : #accessing }
Locale >> isoLocale [
	"<language>-<country>"
	^self isoCountry
		ifNil: [self isoLanguage]
		ifNotNil: [self isoLanguage , '-' , self isoCountry]
]

{ #category : #accessing }
Locale >> languageEnvironment [
	^LanguageEnvironment localeID: self localeID
]

{ #category : #accessing }
Locale >> localeID [
	^id
]

{ #category : #accessing }
Locale >> localeID: anID [
	id := anID
]

{ #category : #accessing }
Locale >> offsetLocalToUTC [
	^self primTimezone
]

{ #category : #'system primitives' }
Locale >> primCountry [
	"Returns string with country tag according to ISO 639"
	<primitive: 'primitiveCountry' module: 'LocalePlugin'>
	^'US'
]

{ #category : #'system primitives' }
Locale >> primCurrencyNotation [
	"Returns boolean if symbol is pre- (true) or post-fix (false)"
	<primitive: 'primitiveCurrencyNotation' module: 'LocalePlugin'>
	^true
]

{ #category : #'system primitives' }
Locale >> primCurrencySymbol [
	"Returns string with currency symbol"
	<primitive: 'primitiveCurrencySymbol' module:'LocalePlugin'>
	^'$'
]

{ #category : #'system primitives' }
Locale >> primDST [
	"Returns boolean if DST  (daylight saving time) is active or not"
	<primitive:'primitiveDaylightSavings' module: 'LocalePlugin'>
	^false
]

{ #category : #'system primitives' }
Locale >> primDecimalSymbol [
	"Returns string with e.g. '.' or ','"
	<primitive:'primitiveDecimalSymbol' module: 'LocalePlugin'>
	^'.'
]

{ #category : #'system primitives' }
Locale >> primDigitGrouping [
	"Returns string with e.g. '.' or ',' (thousands etc)"
	<primitive:'primitiveDigitGroupingSymbol' module: 'LocalePlugin'>
	^','
]

{ #category : #'system primitives' }
Locale >> primLanguage [
	"returns string with language tag according to ISO 639"
	<primitive:'primitiveLanguage' module: 'LocalePlugin'>
	^'en'


]

{ #category : #'system primitives' }
Locale >> primLongDateFormat [
	"Returns the long date format
	d day, m month, y year,
	double symbol is null padded, single not padded (m=6, mm=06)
	dddd weekday
	mmmm month name"
	<primitive:'primitiveLongDateFormat' module: 'LocalePlugin'>
	^'dddd, mmmm d, yyyy'
]

{ #category : #'system primitives' }
Locale >> primMeasurement [
	"Returns boolean denoting metric(true) or imperial(false)."
	<primitive:'primitiveMeasurementMetric' module: 'LocalePlugin'>
	^true

]

{ #category : #'system primitives' }
Locale >> primShortDateFormat [
	"Returns the short date format
	d day, m month, y year,
	double symbol is null padded, single not padded (m=6, mm=06)
	dddd weekday
	mmmm month name"
	<primitive:'primitiveShortDateFormat' module: 'LocalePlugin'>
	^'m/d/yy'
]

{ #category : #'system primitives' }
Locale >> primTimeFormat [
	"Returns string time format
	Format is made up of 
	h hour (h 12, H 24), m minute, s seconds, x (am/pm String)
	double symbol is null padded, single not padded (h=6, hh=06)"
	<primitive:'primitiveTimeFormat' module: 'LocalePlugin'>
	^'h:mmx'
]

{ #category : #'system primitives' }
Locale >> primTimezone [
	"The offset from UTC in minutes, with positive offsets being towards the east.
	(San Francisco is in UTC -07*60 and Paris is in UTC +02*60 when daylight savings is in effect)."
	<primitive:'primitiveTimezoneOffset' module: 'LocalePlugin'>
	^0
]

{ #category : #'system primitives' }
Locale >> primVMOffsetToUTC [
	"Returns the offset in minutes between the VM and UTC.
	If the VM does not support UTC times, this is 0.
	Also gives us backward compatibility with old VMs as the primitive will fail and we then can return 0."
	<primitive:'primitiveVMOffsetToUTC' module: 'LocalePlugin'>
	^0
]

{ #category : #accessing }
Locale >> printOn: aStream [ 
	super printOn: aStream.
	aStream nextPutAll: '(' , id printString , ')'
]
