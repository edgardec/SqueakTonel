"
I am a Monticello repository that reflects the caching of SqueakMap v2.

I refer write attempts to the default MCCacheRepository.
"
Class {
	#name : #MCSMCacheRepository,
	#superclass : #MCFileBasedRepository,
	#instVars : [
		'smCache'
	],
	#category : #'Monticello-Repositories'
}

{ #category : #'instance creation' }
MCSMCacheRepository class >> description [
	^ 'SqueakMap Cache'
]

{ #category : #'instance creation' }
MCSMCacheRepository class >> morphicConfigure [
	^self new
]

{ #category : #accessing }
MCSMCacheRepository >> allFullFileNames [
	| cachedPackages |
	cachedPackages := smCache map installedPackages select: [ :ea | ea isCached ].
	^Array streamContents: [ :s |
		cachedPackages do: [ :ea | | d |
			d := ea cacheDirectory.
			(d fileNamesMatching: '*.mcz') do: [ :fn | s nextPut: (d fullNameFor: fn) ]]]
]

{ #category : #'user interface' }
MCSMCacheRepository >> description [
	^ smCache directory pathName
]

{ #category : #accessing }
MCSMCacheRepository >> directory [
	^ smCache directory
]

{ #category : #accessing }
MCSMCacheRepository >> directory: aDirectory [

]

{ #category : #accessing }
MCSMCacheRepository >> fullNameFor: aFileName [
	^self allFullFileNames detect: [ :ffn | (self directory localNameFor: ffn) = aFileName ] ifNone: []
]

{ #category : #comparing }
MCSMCacheRepository >> hash [
	^ smCache hash
]

{ #category : #'initialize-release' }
MCSMCacheRepository >> initialize [
	super initialize.
	Smalltalk at: #SMSqueakMap ifPresent:[:aClass|
		smCache := aClass default cache.
	].
]

{ #category : #testing }
MCSMCacheRepository >> isValid [
	^smCache notNil and: [ self directory exists ]
]

{ #category : #'file streaming' }
MCSMCacheRepository >> readStreamForFileNamed: aString do: aBlock [
	| file fileName |
	fileName := self fullNameFor: aString.
	fileName ifNil: [
		"assume that this will come from the cache."
		^MCCacheRepository default readStreamForFileNamed: aString do: aBlock ].
	file := FileStream readOnlyFileNamed: fileName.
	^[ aBlock value: file ] ensure: [ file close ].

]

{ #category : #accessing }
MCSMCacheRepository >> smCache [
	^smCache
]

{ #category : #accessing }
MCSMCacheRepository >> smCache: aSMFileCache [
	| |
	smCache := aSMFileCache.
	self directory: aSMFileCache directory.

]

{ #category : #'file streaming' }
MCSMCacheRepository >> writeStreamForFileNamed: aString replace: aBoolean do: aBlock [
	"Can't write into the SM cache, so..."
	^MCCacheRepository default writeStreamForFileNamed: aString replace: aBoolean do: aBlock
]
