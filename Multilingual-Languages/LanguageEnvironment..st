"
The name multilingualized Squeak suggests that you can use multiple language at one time.  This is true, of course, but the system still how to manage the primary language; that provides the interpretation of data going out or coming in from outside world. It also provides how to render strings, as there rendering rule could be different in one language to another, even if the code points in a string is the same.

  Originally, LanguageEnvironment and its subclasses only has class side methods.  After merged with Diego's Babel work, it now has instance side methods.  Since this historical reason, the class side and instance side are not related well.

  When we talk about the interface with the outside of the Squeak world, there are three different ""channels""; the keyboard input, clipboard output and input, and filename.  On a not-to-uncommon system such as a Unix system localized to Japan, all of these three can have (and does have) different encodings.  So we need to manage them separately.  Note that the encoding in a file can be anything.  While it is nice to provide a suggested guess for this 'default system file content encoding', it is not critical.

  Rendering support is limited basic L-to-R rendering so far.  But you can provide different line-wrap rule, at least.

"
Class {
	#name : #LanguageEnvironment,
	#superclass : #Object,
	#instVars : [
		'id'
	],
	#classVars : [
		'ClipboardInterpreterClass',
		'FileNameConverterClass',
		'InputInterpreterClass',
		'KnownEnvironments',
		'SystemConverterClass'
	],
	#category : #'Multilingual-Languages'
}

{ #category : #accessing }
LanguageEnvironment class >> canBeGlobalVarInitial: char [

	^ Unicode canBeGlobalVarInitial: char.

]

{ #category : #accessing }
LanguageEnvironment class >> canBeNonGlobalVarInitial: char [

	^ Unicode canBeNonGlobalVarInitial: char.

]

{ #category : #accessing }
LanguageEnvironment class >> charsetClass [
	^Unicode
]

{ #category : #'class initialization' }
LanguageEnvironment class >> clearDefault [

	ClipboardInterpreterClass := nil.
	InputInterpreterClass := nil.
	SystemConverterClass := nil.
	FileNameConverterClass := nil.

]

{ #category : #'subclass responsibilities' }
LanguageEnvironment class >> clipboardInterpreterClass [

	self subclassResponsibility.
	^ NoConversionClipboardInterpreter.

]

{ #category : #accessing }
LanguageEnvironment class >> currentPlatform [

	^ Locale currentPlatform languageEnvironment.

]

{ #category : #'public query' }
LanguageEnvironment class >> defaultClipboardInterpreter [
	ClipboardInterpreterClass ifNil: [ClipboardInterpreterClass := self currentPlatform class clipboardInterpreterClass].
	^ ClipboardInterpreterClass new.


]

{ #category : #'public query' }
LanguageEnvironment class >> defaultEncodingName [

	^ 'mac-roman'.

]

{ #category : #'public query' }
LanguageEnvironment class >> defaultFileNameConverter [
	Smalltalk platformName = 'Win32' ifTrue:[^UTF8TextConverter new].
	FileNameConverterClass
		ifNil: [FileNameConverterClass := self currentPlatform class fileNameConverterClass].
	^ FileNameConverterClass new
]

{ #category : #'public query' }
LanguageEnvironment class >> defaultInputInterpreter [

	InputInterpreterClass ifNil: [InputInterpreterClass := self inputInterpreterClass].
	^ InputInterpreterClass new.

]

{ #category : #'public query' }
LanguageEnvironment class >> defaultSystemConverter [

	SystemConverterClass ifNil: [SystemConverterClass := self currentPlatform class systemConverterClass].
	^ SystemConverterClass new.

]

{ #category : #accessing }
LanguageEnvironment class >> digitValueOf: char [
	"Answer 0-9 if the receiver is $0-$9, 10-35 if it is $A-$Z, and < 0 
	otherwise. This is used to parse literal numbers of radix 2-36."

	^ self charsetClass digitValueOf: char.

]

{ #category : #'subclass responsibilities' }
LanguageEnvironment class >> fileNameConverterClass [

	self subclassResponsibility.
	^ ISO88591TextConverter.

]

{ #category : #'rendering support' }
LanguageEnvironment class >> flapTabTextFor: aString [

	"self subclassResponsibility."
	^ aString.


]

{ #category : #'rendering support' }
LanguageEnvironment class >> flapTabTextFor: aString in: aFlapTab [

	"self subclassResponsibility."
	^ aString.

]

{ #category : #private }
LanguageEnvironment class >> initKnownEnvironments [
	"LanguageEnvironment initKnownEnvironments"

	| known |
	known := Dictionary new.
	self allSubclassesDo: [:subClass | 
		subClass supportedLanguages do: [:language | | id env | 
			env := subClass new.
			id := LocaleID isoString: language.
			env localeID: id.
			known at: id put: env]].
	^known
]

{ #category : #'class initialization' }
LanguageEnvironment class >> initialize [
	"LanguageEnvironment initialize"

	Smalltalk addToStartUpList: LanguageEnvironment after: FileDirectory.
	Smalltalk addToStartUpList: FileDirectory after: LanguageEnvironment.

]

{ #category : #'subclass responsibilities' }
LanguageEnvironment class >> inputInterpreterClass [

	self subclassResponsibility.
	^ MacRomanInputInterpreter.

]

{ #category : #accessing }
LanguageEnvironment class >> isAlphaNumeric: char [

	^ self charsetClass isAlphaNumeric: char.

]

{ #category : #'rendering support' }
LanguageEnvironment class >> isBreakableAt: index in: text [
	^ false.

]

{ #category : #accessing }
LanguageEnvironment class >> isDigit: char [

	^ self charsetClass isDigit: char.

]

{ #category : #accessing }
LanguageEnvironment class >> isLetter: char [

	^ self charsetClass isLetter: char.

]

{ #category : #accessing }
LanguageEnvironment class >> isLowercase: char [

	^ self charsetClass isLowercase: char.

]

{ #category : #accessing }
LanguageEnvironment class >> isUppercase: char [

	^ self charsetClass isUppercase: char.

]

{ #category : #private }
LanguageEnvironment class >> knownEnvironments [
	"LanguageEnvironment knownEnvironments"
	"KnownEnvironments := nil"

	^KnownEnvironments ifNil: [KnownEnvironments := self initKnownEnvironments]
]

{ #category : #'subclass responsibilities' }
LanguageEnvironment class >> leadingChar [
	"The default for most environment is to use unicode without leadingChar.
	However, environment for east asian language (CJKV) shall refine this default in order to handle han-unification properly."
	^ 0
]

{ #category : #'class initialization' }
LanguageEnvironment class >> localeChanged [

	(self currentPlatform class == self)
		ifTrue: [self startUp].
]

{ #category : #accessing }
LanguageEnvironment class >> localeID: localeID [ 
	"LanguageEnvironment localeID: (LocaleID isoString: 'ja-kid')"
	"LanguageEnvironment localeID: (LocaleID isoString: 'xx')"
	^ self knownEnvironments
		at: localeID
		ifAbsent: [localeID hasParent
				ifTrue: [self knownEnvironments
						at: localeID parent
						ifAbsent: [self
								localeID: (LocaleID isoLanguage: 'en')]]
				ifFalse: [self
						localeID: (LocaleID isoLanguage: 'en')]]
]

{ #category : #'class initialization' }
LanguageEnvironment class >> resetKnownEnvironments [
	"LanguageEnvironment resetKnownEnvironments"

	KnownEnvironments := nil
]

{ #category : #'language methods' }
LanguageEnvironment class >> scanMultibyteCharactersFrom: startIndex to: stopIndex in: aWideString with: aCharacterScanner rightX: rightX font: aFont [
	"the default for scanning multibyte characters- other more specific encodings may do something else"
	^aFont scanMultibyteCharactersFrom: startIndex to: stopIndex in: aWideString with: aCharacterScanner rightX: rightX
]

{ #category : #'class initialization' }
LanguageEnvironment class >> startUp [
	self clearDefault.
	self environment at: #HandMorph ifPresent: [:hm| hm startUp].
	self environment at: #Clipboard ifPresent: [:cp| cp startUp].

]

{ #category : #'subclass responsibilities' }
LanguageEnvironment class >> supportedLanguages [
	"Return the languages that this class supports. 
	Any translations for those languages will use this class as their environment."
	self subclassResponsibility
]

{ #category : #'subclass responsibilities' }
LanguageEnvironment class >> systemConverterClass [

	self subclassResponsibility.
	^ ISO88591TextConverter.

]

{ #category : #casing }
LanguageEnvironment class >> toCasefold: aWideString [
	^self charsetClass toCasefold: aWideString
]

{ #category : #casing }
LanguageEnvironment class >> toLowercase: aWideString [
	^self charsetClass toLowercase: aWideString
]

{ #category : #casing }
LanguageEnvironment class >> toLowercaseCode: integerValue [
	^self charsetClass toLowercaseCode: integerValue
]

{ #category : #casing }
LanguageEnvironment class >> toUppercase: aWideString [
	^self charsetClass toUppercase: aWideString
]

{ #category : #casing }
LanguageEnvironment class >> toUppercaseCode: integerValue [
	^self charsetClass toUppercaseCode: integerValue
]

{ #category : #private }
LanguageEnvironment class >> win32VMUsesUnicode [
	| buildDate ind date vmHead |
	vmHead := Smalltalk vmVersion.
	vmHead ifNil: [^ false].
	(vmHead beginsWith: 'Open Smalltalk')
		ifTrue: [ ^ true ].
	buildDate := Smalltalk buildDate.
	buildDate ifNil: [^ false].
	ind := buildDate indexOfSubCollection: 'on'.
	date := Date readFromString: (buildDate copyFrom: ind+3 to: buildDate size).
	(vmHead beginsWith: 'Croquet') ifTrue: [
		^ date >= (Date readFromString: '1 Feb 2007')
	].
	(vmHead beginsWith: 'Squeak') ifTrue: [
		^ date >= (Date readFromString: '5 June 2007')
	].
	^ false.

"LanguageEnvironment win32VMUsesUnicode"
]

{ #category : #utilities }
LanguageEnvironment >> checkPhrase: phrase translation: translation [
	"check the translation.
	Answer a string with a comment or meaning no-comments"
	^nil
]

{ #category : #'fonts support' }
LanguageEnvironment >> fontDownload [
	"(Locale isoLanguage: 'ja') languageEnvironment fontDownload"
	
	(FileDirectory default fileExists: self fontFullName)
		ifTrue: [^ self].
	Cursor read
		showWhile: [self fontDownloadUrls
				do: [:each | [ | contents f |
					contents := (each , '/' , self fontFileName) asUrl retrieveContents contents.
					(contents first: 2)
							= 'PK'
						ifTrue: [f := FileStream newFileNamed: self fontFullName.
							f binary.
							[f nextPutAll: contents]
								ensure: [f close].
							^ self]]
						on: NameLookupFailure
						do: [:e | e]]].
	self error: 'Fonts does not found (' , self fontFullName , ')'
]

{ #category : #'fonts support' }
LanguageEnvironment >> fontDownloadUrls [
	^ #('http://metatoys.org/pub/' )
]

{ #category : #accessing }
LanguageEnvironment >> fontEncodingName [
	^ #Font , self class name
]

{ #category : #'fonts support' }
LanguageEnvironment >> fontFileName [
	"(Locale isoLanguage: 'ja') languageEnvironment fontFileName"
	^ self fontEncodingName , '.sar'
]

{ #category : #'fonts support' }
LanguageEnvironment >> fontFullName [
	"(Locale isoLanguage: 'ja') languageEnvironment fontFullName"
	^ FileDirectory default fullNameFor: self fontFileName
]

{ #category : #'fonts support' }
LanguageEnvironment >> installFont [
	"(Locale isoLanguage: 'ja') languageEnvironment installFont"
	self fontDownload.
	SARInstaller installSAR: self fontFullName
]

{ #category : #'fonts support' }
LanguageEnvironment >> isFontAvailable [
	| encoding f |
	encoding := self leadingChar + 1.
	f := TextStyle defaultFont.
	f isFontSet ifTrue: [
		f fontArray
			at: encoding
			ifAbsent: [^ false].
		^ true
	].
	encoding = 1 ifTrue: [^ true].
	f fallbackFont isFontSet ifFalse: [^false].
	f fallbackFont fontArray
		at: encoding
		ifAbsent: [^ false].
	^ true

]

{ #category : #accessing }
LanguageEnvironment >> isoCountry [
	^self localeID isoCountry
]

{ #category : #accessing }
LanguageEnvironment >> isoLanguage [
	^self localeID isoLanguage
]

{ #category : #accessing }
LanguageEnvironment >> leadingChar [
	^self class leadingChar
]

{ #category : #accessing }
LanguageEnvironment >> localeID [
	^id
]

{ #category : #'initialize-release' }
LanguageEnvironment >> localeID: anID [
	id := anID
]

{ #category : #'fonts support' }
LanguageEnvironment >> removeFonts [
	"(Locale isoLanguage: 'ja') languageEnvironment removeFonts"
	StrikeFontSet removeFontsForEncoding: self leadingChar encodingName: self fontEncodingName
]
