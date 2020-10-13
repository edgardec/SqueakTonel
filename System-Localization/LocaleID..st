Class {
	#name : #LocaleID,
	#superclass : #Object,
	#instVars : [
		'isoLanguage',
		'isoCountry'
	],
	#category : #'System-Localization'
}

{ #category : #accessing }
LocaleID class >> countryFor: iso6391Code [
	"http://www.loc.gov/standards/iso639-2/php/code_list.php"
	^ iso6391Code
		caseOf:
			{ ['af'] -> ['Afrikaans'].
			['ca'] -> ['Catalan'].
			['cs'] -> [ 'Czech'].
			['da'] -> [ 'Danish'].
			['de'] -> [ 'German'].
			['el'] -> [ 'Greek Modern'].
			['en'] -> [ 'English'].
			['es'] -> [ 'Spanish'].
			['eu'] -> [ 'Basque'].
			['fi'] -> [ 'Finnish'].
			['fo'] -> [ 'Faroese'].
			['fr'] -> [ 'French'].
			['ga'] -> [ 'Irish'].
			['gd'] -> [ 'Gaelic'].
			['hr'] -> [ 'Croatian'].
			['hu'] -> [ 'Hungarian'].
			['is'] -> [ 'Icelandic'].
			['it'] -> [ 'Italian'].
			['ja'] -> [ 'Japanese'].
			['ja-etoys'] -> [ 'Japanese'].
			['ko'] -> [ 'Korean'].
			['nl'] -> [ 'Dutch'].
			['no'] -> [ 'Norwegian'].
			['pt'] -> [ 'Portuguese'].
			['rm'] -> [ 'Romansh'].
			['ro'] -> [ 'Romainian'].
			['sk'] -> [ 'Slovak'].
			['sl'] -> [ 'Slovenian'].
			['sq'] -> [ 'Albanian'].
			['sv'] -> [ 'Swedish'].
			['sw'] -> [ 'Swahili'].
			['zh'] -> [ 'Chinese'] }
		otherwise:
			[ 'other' ]
]

{ #category : #accessing }
LocaleID class >> current [
	^Locale current localeID
]

{ #category : #'instance creation' }
LocaleID class >> isoLanguage: langString [
	^self isoLanguage: langString isoCountry: nil
]

{ #category : #'instance creation' }
LocaleID class >> isoLanguage: langString isoCountry: countryStringOrNil [
	^self new isoLanguage: langString isoCountry: countryStringOrNil
]

{ #category : #'instance creation' }
LocaleID class >> isoString: isoString [
	"Parse the isoString (<language>-<country>) into its components and return the matching LocaleID"
	"LocaleID isoString: 'en' "
	"LocaleID isoString: 'en-us' "

	| parts language country |
	parts := isoString findTokens: #($- ).
	language := parts first.
	parts size > 1
		ifTrue: [country := parts second].
	^self isoLanguage: language isoCountry: country
]

{ #category : #'instance creation' }
LocaleID class >> posixName: aString [ 
	^ self
		isoString: (aString copyReplaceAll: '_' with: '-')
]

{ #category : #accessing }
LocaleID class >> previous [
	^Locale previous localeID
]

{ #category : #comparing }
LocaleID >> = anotherObject [
	self class == anotherObject class
		ifFalse: [^false].
	^self isoLanguage = anotherObject isoLanguage
		and: [self isoCountry = anotherObject isoCountry]
]

{ #category : #accessing }
LocaleID >> displayCountry [
	^(ISOLanguageDefinition iso2Countries at: self isoCountry asUppercase ifAbsent: [ self isoCountry ]) 
]

{ #category : #accessing }
LocaleID >> displayLanguage [
	| language |
	language := (ISOLanguageDefinition iso2LanguageTable
				at: self isoLanguage
				ifAbsent: [^ self isoLanguage]) language.
	^ self isoCountry
		ifNil: [language]
		ifNotNil: [language , ' (' , self displayCountry , ')']
]

{ #category : #accessing }
LocaleID >> displayName [
	"Answer a proper name to represent the receiver in GUI. 
	 
	The wording is provided by translations of the magic value 
	'<language display name>'. 
	 
	'English' -> 'English'  
	'German' -> 'Deutsch'  
	"
	| magicPhrase translatedMagicPhrase |
	magicPhrase := '<language display name>'.
	translatedMagicPhrase := NaturalLanguageTranslator translateWithoutLoading: magicPhrase toLocaleID: self.
	^ translatedMagicPhrase = magicPhrase
		ifTrue: [self displayLanguage]
		ifFalse: [translatedMagicPhrase]
]

{ #category : #testing }
LocaleID >> hasParent [
	^self isoCountry notNil
]

{ #category : #comparing }
LocaleID >> hash [
	^self isoLanguage hash bitXor: self isoCountry hash
]

{ #category : #accessing }
LocaleID >> isoCountry [
	^isoCountry
]

{ #category : #accessing }
LocaleID >> isoCountry: aValue [

	isoCountry := aValue
]

{ #category : #accessing }
LocaleID >> isoLanguage [
	^isoLanguage
]

{ #category : #initialize }
LocaleID >> isoLanguage: langString isoCountry: countryStringOrNil [ 
	isoLanguage := langString.
	isoCountry := countryStringOrNil ifNil: (self class countryFor: langString)
]

{ #category : #accessing }
LocaleID >> isoString [
	^self asString
]

{ #category : #accessing }
LocaleID >> parent [
	^ (self class
			isoLanguage: self isoLanguage)
			isoCountry: nil;
			yourself
]

{ #category : #printing }
LocaleID >> posixName [
	"(LocaleID isoString: 'es-MX') posixName"
	"(LocaleID isoString: 'es') posixName"
	"language[_territory]"
	^ self isoCountry
		ifNil: [self isoLanguage]
		ifNotNil: [self isoLanguage , '_' , self isoCountry]
]

{ #category : #printing }
LocaleID >> printOn: stream [
	"<language>-<country>"
	stream nextPutAll: self isoLanguage.
	self isoCountry
		ifNotNil: [stream nextPut: $-; nextPutAll: self isoCountry]
]

{ #category : #printing }
LocaleID >> storeOn: aStream [ 
	aStream nextPut: $(.
	aStream nextPutAll: self class name.
	aStream nextPutAll: ' isoString: '.
	aStream nextPutAll: '''' , self printString , ''''.
	aStream nextPut: $).

]

{ #category : #accessing }
LocaleID >> translator [
	^ InternalTranslator localeID: self 
]
