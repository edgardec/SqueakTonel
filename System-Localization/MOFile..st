"
Wrapper for MO file of gettext.
Known limitation:  
	currently don't support prural form.
	translation strings have to be encoded in utf-8.

Implementation notes:
	Testing on XO showed emulation of hash search without plugin + on demand loading is slow.
	The test also showed conversion of utf8 string to Squeak's String is really slow (especially for non-latin language).
	so in this version, all of original/translated strings are loaded on initiaization,
	but ""translated strings"" is left as ByteString on loading time, to reduce loading time.
	After that the translated string is converted on demand. 

"
Class {
	#name : #MOFile,
	#superclass : #Object,
	#instVars : [
		'localeID',
		'fileName',
		'isLittleEndian',
		'magic',
		'revision',
		'nStrings',
		'originalTableOffset',
		'translatedTableOffset',
		'hashTableSize',
		'hashTableOffset',
		'hashTable',
		'originalStrings',
		'translatedStrings',
		'translations'
	],
	#classVars : [
		'Cr',
		'Lf'
	],
	#category : #'System-Localization'
}

{ #category : #'instance creation' }
MOFile class >> fileName: path localeID: id [
	^self new 
			load:path localeID: id
]

{ #category : #'class initialization' }
MOFile class >> initialize [
	Cr := Character cr.
	Lf := Character lf.

]

{ #category : #public }
MOFile >> atRandom [

	^ self translatedString:nStrings atRandom.

]

{ #category : #public }
MOFile >> fileName [
	^fileName
]

{ #category : #public }
MOFile >> fileName: path [
	fileName := path
]

{ #category : #experimental }
MOFile >> hashPjw: aString [
	"So called `hashpjw' function by P.J. Weinberger
   	[see Aho/Sethi/Ullman, COMPILERS: Principles, Techniques and Tools,
   	1986, 1987 Bell Telephone Laboratories, Inc.] "
	| stringSize hash g |
	stringSize := aString size.
	hash := 0.
	1 to: stringSize do: [:pos |
		hash := hash bitShift: 4.
		hash := hash + ((aString at: pos) asInteger).
		g := hash bitAnd: 16rF0000000.
		g = 0 ifFalse: [
			hash := hash  bitXor: (g bitShift: -24).
			hash := hash bitXor: g.
		]
	].
	^hash.

]

{ #category : #experimental }
MOFile >> load1: aFileName localeID: id [
	"CASE1: 
		all of strings are loaded. 
		translation strings are converted to Squeak format on load time.
		original-string/index pairs are registerd to Dictionary on load time.
		hash search can't be used"
	| strm originalTable translatedTable |
	localeID := id.
	strm := FileStream readOnlyFileNamed: aFileName.
	fileName := aFileName.
	[
		self loadHeader: strm.
		originalTable := self loadStringPointers: strm 
								offset: originalTableOffset.

		originalStrings := self loadStrings: strm 
								pointers: originalTable.

		translatedTable := self loadStringPointers: strm 
								offset: translatedTableOffset.

		translatedStrings := self loadStrings: strm 
								pointers: translatedTable
								encoding: 'utf8'
								languageEnvironment: (Locale localeID: localeID) languageEnvironment .

		translations := Dictionary new.
		1 to: nStrings do: [:index |
			| key |
			key := originalStrings at: index.
			translations at: key put: index.
		].
		originalTable := nil.
	] ensure: [strm close].
]

{ #category : #experimental }
MOFile >> load4: aFileName localeID: id [
	"CASE4: 
		all of strings are loaded. 
		loading and conversion of translation strings to Squeak format is executed on initialization time.
		only hash search can be used"
	| strm originalTable translatedTable |
	localeID := id.
	strm := FileStream readOnlyFileNamed: aFileName.
	fileName := aFileName.
	[
		self loadHeader: strm.
		self loadHashTable: strm.
		originalTable := self loadStringPointers: strm 
								offset: originalTableOffset.

		originalStrings := self loadStrings: strm 
								pointers: originalTable.

		translatedTable := self loadStringPointers: strm 
								offset: translatedTableOffset.

		translatedStrings := self loadStrings: strm 
								pointers: translatedTable
								encoding: 'utf-8'
								languageEnvironment: (Locale localeID: localeID) languageEnvironment .
	] ensure: [strm close].
]

{ #category : #public }
MOFile >> load: aFileName localeID: id [
	"all of original/translated strings are loaded. 
		but conversion of translation string (in utf-8 bytestring) to Squeak format will be defered.
		original-string/index pairs are registerd to Dictionary on load time.
		hash search can't be used"
	| strm originalTable translatedTable |
	localeID := id.
	strm := FileStream readOnlyFileNamed: aFileName.
	fileName := aFileName.
	[
		self loadHeader: strm.
		originalTable := self loadStringPointers: strm 
								offset: originalTableOffset.

		originalStrings := self loadStrings: strm 
								pointers: originalTable.

		translatedTable := self loadStringPointers: strm 
								offset: translatedTableOffset.

		translatedStrings := self loadStrings: strm 
								pointers: translatedTable.

		translations := Dictionary new: nStrings * 2.  "make too enough room to avoid #grow"
		1 to: nStrings do: [:index |
			| key |
			key := originalStrings at: index.
			translations at: key put: index.
		].
		originalStrings := nil.
	] ensure: [strm close].
]

{ #category : #experimental }
MOFile >> loadHashTable: strm [
	| entry |
	hashTable := IntegerArray  ofSize: hashTableSize.
	strm binary.
	strm position: hashTableOffset.
	1 to: hashTableSize do: [:index |
		entry := self nextInt32From: strm.
		hashTable at:  index put: entry.
	]
]

{ #category : #private }
MOFile >> loadHeader: strm [
	strm binary.
	magic :=  strm uint32.
	magic = 16rDE120495 
		ifTrue: [isLittleEndian := true]
		ifFalse: [
			magic = 16r950412DE 
				ifTrue: [isLittleEndian := false]
				ifFalse: [ self error: 'invalid MO']
		].
	revision := self nextInt32From: strm.
	nStrings := self nextInt32From: strm.
	originalTableOffset := self nextInt32From: strm.
	translatedTableOffset := self nextInt32From: strm.
	hashTableSize := self nextInt32From: strm.
	hashTableOffset := self nextInt32From: strm.

]

{ #category : #private }
MOFile >> loadString: strm pointer: top  length: len [
	| str |
	str := ByteString new: len.
	strm position:  top.
	strm nextInto: str.
	^str replaceAll: Lf with: Cr.

]

{ #category : #private }
MOFile >> loadStringPointers: strm offset: tableOffset [
	"returns tupple {arrayOfOffsetToString  arrayOfLengthOfString}"
	| offsetTable lenTable len offset tupple |
	offsetTable := IntegerArray new: nStrings.
	lenTable := IntegerArray new: nStrings.
	strm binary.
	strm position: tableOffset.
	1 to: nStrings do: [:index |
		len := self nextInt32From: strm.
		offset := self nextInt32From: strm.
		offsetTable at: index put: offset.
		lenTable at: index put: len.
	].
	tupple := Array new: 2.
	tupple at: 1 put: offsetTable.
	tupple at: 2 put:  lenTable.
	^tupple

]

{ #category : #private }
MOFile >> loadStrings: strm pointers: table [
	^self loadStrings: strm pointers: table encoding: nil languageEnvironment: nil

]

{ #category : #private }
MOFile >> loadStrings: strm pointers: tupple encoding: encodingName languageEnvironment: env [
	| strings rawStr str offsetTable lenTable |
	offsetTable :=  tupple first.
	lenTable := tupple second.
	strings := Array new: nStrings.
	1 to: nStrings do: [:index |
		rawStr := self loadString: strm 
					pointer:  (offsetTable at: index)
					length: (lenTable at: index).
		str := encodingName isNil ifTrue: [rawStr] 
						ifFalse: [ encodingName = 'utf8' 
									ifTrue: [rawStr utf8ToSqueak applyLanguageInformation: env]
									ifFalse: [self error: 'this encoding isn''t supported']
						].
		strings at: index put: str.
	].
	^strings.
]

{ #category : #private }
MOFile >> nextInt32From: strm [
	^isLittleEndian 
			ifTrue: [^strm nextLittleEndianNumber: 4]
			ifFalse: [^strm nextInt32]
]

{ #category : #private }
MOFile >> originalString: index [
	^originalStrings at: index.

]

{ #category : #public }
MOFile >> searchByDictionary: aString [
	| index |
	index := translations at: aString ifAbsentPut: [nil].
	index ifNil: [^ nil].
	^self translatedString: index
]

{ #category : #experimental }
MOFile >> searchByHash: aString [
	| hashValue nstr index incr key |
	hashValue :=  self hashPjw: aString.
	incr := 1 + (hashValue \\ (hashTableSize -2)).
	index := (hashValue \\ hashTableSize) .
	[ 	nstr := (hashTable at: index +1 ).
		nstr = 0 ifTrue: [^nil].
		key := self originalString: nstr.
		key = aString ifTrue: [^self translatedString: nstr].
		index >= (hashTableSize - incr) 
				ifTrue: [index := index - (hashTableSize - incr)  ]
				ifFalse:[index := index + incr].	
	] repeat
]

{ #category : #experimental }
MOFile >> testSearchByDictionary [
	InternalTranslator allKnownPhrases 
		do: [:each |
			self searchByDictionary: each
		].
	
]

{ #category : #experimental }
MOFile >> testSearchByHash [
	InternalTranslator allKnownPhrases 
		do: [:each |
			self searchByHash: each
		].
	
]

{ #category : #experimental }
MOFile >> translateByHash: aString [
	| trans |
	trans := self searchByHash: aString.
	trans isNil ifTrue: [^aString]
			ifFalse: [^trans].

]

{ #category : #private }
MOFile >> translatedString: index [
	"KNOWN PROBLEM: conversion is executed everytimes this method called"
	| str |
	str := translatedStrings at: index.

	^str utf8ToSqueak applyLanguageInformation: (Locale localeID: localeID) languageEnvironment.

]

{ #category : #public }
MOFile >> translationFor: aString [ 
	| |
	aString size = 0 ifTrue: [^ '']. "Gettext header"
	^ (self searchByDictionary: aString) ifNil: [aString]

]

{ #category : #private }
MOFile >> translations [

	^ translations
]
