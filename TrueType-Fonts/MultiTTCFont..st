Class {
	#name : #MultiTTCFont,
	#superclass : #TTCFont,
	#instVars : [
		'map',
		'cacheIndex'
	],
	#category : #'TrueType-Fonts'
}

{ #category : #'system maintenance' }
MultiTTCFont class >> cacheAllNil [
"
	self cacheAllNil
"
	self allInstances do: [:inst |
		inst cache do: [:e |
			e third ifNotNil: [^ false].
		].
	].

	^ true.

]

{ #category : #'as yet unclassified' }
MultiTTCFont >> access: char at: index [

	| wcache entry |
	wcache := self cache.
	entry := wcache at: index.
	wcache replaceFrom: index to: wcache size - 1 with: wcache startingAt: index + 1.
	wcache at: wcache size put: entry.

]

{ #category : #private }
MultiTTCFont >> at: char put: form [

	| ind triplet |
	triplet := Array with: char asciiValue with: foregroundColor with: form.
	GlyphCacheData at: (GlyphCacheIndex := GlyphCacheIndex \\ GlyphCacheSize + 1) put: triplet.

	ind := self indexFor: char.
	map at: char asciiValue put: ind.
	self cache at: ind put: triplet.

]

{ #category : #friend }
MultiTTCFont >> cache [
	(cache isNil or: [cache size ~= 512]) ifTrue: [self recreateCache]. "old weak-array caching"
	^cache
]

{ #category : #initialize }
MultiTTCFont >> flushCache [

	super flushCache.
	map := IdentityDictionary new: 512.

]

{ #category : #initialize }
MultiTTCFont >> foregroundColor: fgColor [
	"Install the given foreground color"
	foregroundColor := fgColor.
]

{ #category : #private }
MultiTTCFont >> formOf: char [

	| newForm |
	cache ifNil: [ self recreateCache ].
	foregroundColor ifNil: [ self foregroundColor: Color black ].

	self hasCached: char ifTrue: [:form |
		^ form.
	].

	newForm := self computeForm: char.
	self at: char put: newForm.
	^ newForm.

]

{ #category : #private }
MultiTTCFont >> glyphInfoOf: char into: glyphInfoArray [

	| newForm |
	self hasCached: char ifTrue: [:form |
		glyphInfoArray at: 1 put: form;
			at: 2 put: 0;
			at: 3 put: form width;
			at: 4 put: (self ascentOf: char);
			at: 5 put: self.
		^ glyphInfoArray.
	].

	newForm := self computeForm: char.
	self at: char put: newForm.

	glyphInfoArray at: 1 put: newForm;
		at: 2 put: 0;
		at: 3 put: newForm width;
		at: 4 put: (self ascentOf: char);
		at: 5 put: self.
	^ glyphInfoArray.

]

{ #category : #private }
MultiTTCFont >> hasCached: char ifTrue: aBlock [

	| value triplet |
	value := char asciiValue.
	triplet := cache at: (map at: value ifAbsent: [^ false]).
	triplet ifNil: [^ false].
	(triplet at: 1) ~= value ifTrue: [^ false].
	(triplet at: 2) ~= foregroundColor ifTrue: [^ false].
	^ aBlock value: (triplet at: 3).

]

{ #category : #private }
MultiTTCFont >> indexFor: char [

	| triplet |
	map size > 511 ifTrue: [
		cacheIndex := 512 atRandom.
		triplet := self cache at: cacheIndex.
		triplet ifNotNil: [map removeKey: (triplet at: 1) ifAbsent: []].
		^ cacheIndex
	].
	^ (cacheIndex := cacheIndex + 1 \\ 512) + 1.

]

{ #category : #friend }
MultiTTCFont >> initialize [

	super initialize.
	cacheIndex := 511.

]

{ #category : #friend }
MultiTTCFont >> recreateCache [

	cache := WeakArray new: 512.
	map := IdentityDictionary new: 512.

]

{ #category : #public }
MultiTTCFont >> widthOf: char [

	^ (self formOf: char) width.

]
