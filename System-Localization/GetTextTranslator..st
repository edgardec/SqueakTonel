"
emulation of gettext runtime
Known limitation:  
     currently doesn't support plural forms.

"
Class {
	#name : #GetTextTranslator,
	#superclass : #NaturalLanguageTranslator,
	#instVars : [
		'moFiles'
	],
	#classVars : [
		'LocaleDirsForDomain',
		'SystemDefaultLocaleDirs',
		'UserDefaultLocaleDirs'
	],
	#category : #'System-Localization'
}

{ #category : #'translation data layout' }
GetTextTranslator class >> addSystemDefaultLocaleDir: dir [
	"new dir will be put as first"
 	self systemDefaultLocaleDirs addFirst: dir
]

{ #category : #accessing }
GetTextTranslator class >> availableLanguageLocaleIDs [
	"GetTextTranslator availableLanguageLocaleIDs"
	| ids dirs localeDirForLang directoryNames |
	ids := Set new.
	dirs := Set new.
	dirs addAll: LocaleDirsForDomain values.
	dirs addAll: self defaultLocaleDirs.
	dirs do: [:dir |
		| localesDir |
		localesDir := FileDirectory on: dir. 
		directoryNames := [localesDir directoryNames] on: InvalidDirectoryError do: [:e | #()].
		directoryNames
				do: [:langDirName | 
					| localeID  |
					localeID := LocaleID posixName: langDirName.
					localeDirForLang := localesDir directoryNamed: (self langDirNameForLocaleID: localeID).
					localeDirForLang ifNotNil: [
						(localeDirForLang fileNamesMatching: '*.mo') ifNotEmpty: [ids add: localeID]].
					localeID hasParent ifTrue: [
						localeDirForLang := localesDir directoryNamed: (self langDirNameForLocaleID: localeID parent).
						localeDirForLang ifNotNil: [
							(localeDirForLang fileNamesMatching: '*.mo') ifNotEmpty: [ids add: localeID parent]]].
				].
	].
	^ids
]

{ #category : #'translation data layout' }
GetTextTranslator class >> defaultLocaleDirs [
	| dirs |
	dirs := OrderedCollection new.
	UserDefaultLocaleDirs ifNotNil: [dirs addAll: UserDefaultLocaleDirs].
	dirs addAll: self systemDefaultLocaleDirs.
	^dirs

]

{ #category : #private }
GetTextTranslator class >> findMOForLocaleID: id domain: aDomainName [
	| sepa langSubDir path |
	sepa := FileDirectory slash.
	langSubDir := self langDirNameForLocaleID: id.
	(self localeDirsForDomain: aDomainName)
		do: [:each |
			path := each , sepa , langSubDir, sepa , (self moNameForDomain: aDomainName).
			[(FileDirectory default fileExists: path)
				 ifTrue: [^path]] on: InvalidDirectoryError do: [:e | ^nil]].
	^nil.
]

{ #category : #'class initialization' }
GetTextTranslator class >> initialize [
	SystemDefaultLocaleDirs := OrderedCollection new.
	UserDefaultLocaleDirs := OrderedCollection new.
	LocaleDirsForDomain := Dictionary new.
]

{ #category : #private }
GetTextTranslator class >> langDirNameForLocaleID: id [
	"returns relative path from locale directory to actual directory containing MOs"
	^(id posixName) , (FileDirectory slash)  , 'LC_MESSAGES'
]

{ #category : #'translation data layout' }
GetTextTranslator class >> localeDirForDomain: aDomainName [
	"returns registered localeDirectory for the textdomain. returns nil if not registered"
	^LocaleDirsForDomain at: aDomainName ifAbsent: [nil]
]

{ #category : #private }
GetTextTranslator class >> localeDirsForDomain [
	^LocaleDirsForDomain ifNil: [LocaleDirsForDomain := Dictionary new]
]

{ #category : #'translation data layout' }
GetTextTranslator class >> localeDirsForDomain: aDomainName [
	"returns collection of locale directories for text domain.  
	This includes user defined one for the domain, user defaults and system defaults" 
	| dirs dir |
	dirs := OrderedCollection new.
	dir := self localeDirForDomain: aDomainName.
	dir ifNotNil: [dirs add: dir].
	dirs addAll:  self defaultLocaleDirs.
	^dirs
]

{ #category : #private }
GetTextTranslator class >> moNameForDomain: domainName [
	^domainName , '.mo'
]

{ #category : #'instance creation' }
GetTextTranslator class >> newForLocaleID: id [
	^self new localeID: id
]

{ #category : #'class initialization' }
GetTextTranslator class >> privateStartUp [
	self setupLocaleDirs.
	self availableLanguageLocaleIDs do: [ :localeID |
		NaturalLanguageTranslator translators 
				at: localeID 
				put: (self newForLocaleID: localeID).
	]
]

{ #category : #'translation data layout' }
GetTextTranslator class >> setLocaleDir: path forDoamin: aDomainName [
	self LocaleDirsForDomain
		at: aDomainName
		put: path.
]

{ #category : #'translation data layout' }
GetTextTranslator class >> setupLocaleDirs [
	| dirs sepa localesDirName |
	sepa := FileDirectory slash.
	SystemDefaultLocaleDirs := nil.
	dirs := self systemDefaultLocaleDirs.
	localesDirName := 'locale'.
	dirs add:  (Smalltalk imagePath) , sepa , localesDirName.
	dirs add:  (Smalltalk vmPath) , sepa , localesDirName.
	^dirs
]

{ #category : #'translation data layout' }
GetTextTranslator class >> systemDefaultLocaleDirs [
	^SystemDefaultLocaleDirs ifNil: [SystemDefaultLocaleDirs := OrderedCollection new]

]

{ #category : #'translation data layout' }
GetTextTranslator class >> userDefaultLocaleDirs [
	^UserDefaultLocaleDirs ifNil: [UserDefaultLocaleDirs := OrderedCollection new]

]

{ #category : #accessing }
GetTextTranslator >> atRandom [

	| v |
	moFiles ifEmpty: [^ ''].
	(v := moFiles atRandom value) ifNil: [^ ''].
	^ v atRandom.

]

{ #category : #accessing }
GetTextTranslator >> domainRegistered: aDomainName [
	"only current translator actually load the MO, to minimize loading time.
	 other translator will load anyway when it goes current"
	(self class current == self) 
		ifTrue: [self moFileForDomain: aDomainName].
	
]

{ #category : #accessing }
GetTextTranslator >> domainUnregistered: aDomainName [
	moFiles removeKey: aDomainName ifAbsent: [^self]
	
]

{ #category : #'initialize-release' }
GetTextTranslator >> initialize [
	moFiles := Dictionary new.
]

{ #category : #accessing }
GetTextTranslator >> isDomainLoaded: aDomainName [
	| mo |
	mo := moFiles at: aDomainName ifAbsent: [nil].
	^mo isNil not.

]

{ #category : #private }
GetTextTranslator >> loadMOFileForDomain: aDomainName [
	| moName |
	moName := self class findMOForLocaleID: self localeID 
								domain: aDomainName.
	moName notNil
			 ifTrue: [^MOFile new load: moName
								localeID: self localeID]
			ifFalse: [^nil]

]

{ #category : #accessing }
GetTextTranslator >> loadMOFiles [
	TextDomainManager allKnownDomains 
		do: [:domainName |
			self moFileForDomain: domainName
		].
]

{ #category : #private }
GetTextTranslator >> moFileForDomain: domainName [
	^moFiles at: domainName ifAbsentPut: [self loadMOFileForDomain: domainName]
]

{ #category : #private }
GetTextTranslator >> moFiles [

	^ moFiles
]

{ #category : #accessing }
GetTextTranslator >> reloadMOFiles [
	moFiles := Dictionary new.
	self loadMOFiles.
]

{ #category : #'language switching' }
GetTextTranslator >> setCurrent [
	"ensure actual contents of MOs is loaded on switching language"
	self loadMOFiles
]

{ #category : #translation }
GetTextTranslator >> translate: aString inDomain: aDomainName [
	| mo |
	mo := self moFileForDomain: aDomainName.
	^mo isNil 
		ifTrue: [aString] 
		ifFalse: [mo translationFor: aString]

]
