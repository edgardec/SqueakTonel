Class {
	#name : #HierarchicalURI,
	#superclass : #URI,
	#instVars : [
		'authority',
		'query'
	],
	#category : #'Network-URI'
}

{ #category : #private }
HierarchicalURI >> absoluteFromString: aString scheme: schemeName [
	| remainder |
	super absoluteFromString: aString scheme: schemeName.

	"We now have the interesting part in schemeSpecficPart and can parse it further"

	"This check is somewhat redundant, just in case somebody calls this directly."
	remainder := schemeSpecificPart.
	(remainder isEmpty
		or: [remainder first ~~ $/])
		ifTrue: [(IllegalURIException new uriString: remainder) signal: 'Invalid absolute URI'].

	(aString beginsWith: '//')
		ifTrue: [remainder := self extractAuthority: (remainder copyFrom: 3 to: remainder size)].

	self extractSchemeSpecificPartAndFragment: remainder
]

{ #category : #accessing }
HierarchicalURI >> absolutePath [
	^self schemeSpecificPart isEmpty
		ifTrue: ['/']
		ifFalse: [self schemeSpecificPart]
]

{ #category : #printing }
HierarchicalURI >> allButScheme [
	"Answer the entire url except its scheme"

	^String streamContents:[:s|
		authority ifNotNil:[self authority printOn: s].
		s nextPutAll: super allButScheme.
		query ifNotNil:[s nextPutAll: query].
	].
]

{ #category : #'directory operations' }
HierarchicalURI >> assureExistance [
	
]

{ #category : #accessing }
HierarchicalURI >> authority [
	^authority
]

{ #category : #accessing }
HierarchicalURI >> baseName [
	"returns the last component stripped of its extension"

	| baseName i |
	baseName := self pathComponents last.
	i := baseName findLast: [:c | c = $.].
	^i = 0
		ifTrue: [baseName]
		ifFalse: [baseName copyFrom: 1 to: i-1].

]

{ #category : #private }
HierarchicalURI >> buildAbsolutePath: pathComponents [
	^String streamContents: [:stream |
		stream nextPut: $/.
		pathComponents
			do: [:pathPart | stream nextPutAll: pathPart]
			separatedBy: [stream nextPut: $/]]
]

{ #category : #accessing }
HierarchicalURI >> extension [
	"This method assumes a $. as extension delimiter"

	| i leafName |
	leafName := self pathComponents last.
	i := leafName findLast: [:c | c = $.].
	^i = 0
		ifTrue: ['']
		ifFalse: [leafName copyFrom: i + 1 to: leafName size].

]

{ #category : #private }
HierarchicalURI >> extractAuthority: aString [
	| endAuthorityIndex authorityString |
	endAuthorityIndex := (aString indexOf: $/ ) - 1.
	endAuthorityIndex < 0
		ifTrue: [endAuthorityIndex := aString size].
	authorityString := aString copyFrom: 1 to: endAuthorityIndex.
	authority := URIAuthority fromString: authorityString.
	^aString copyFrom: endAuthorityIndex+1 to: aString size
]

{ #category : #private }
HierarchicalURI >> extractQuery: remainder [
	| queryIndex |
	queryIndex := remainder indexOf: $?.
	queryIndex > 0
		ifFalse: [^remainder].
	query := remainder copyFrom: queryIndex to: remainder size.
	^remainder copyFrom: 1 to: queryIndex-1
]

{ #category : #private }
HierarchicalURI >> extractSchemeSpecificPartAndFragment: remainder [
	super extractSchemeSpecificPartAndFragment: remainder.
	schemeSpecificPart := self extractQuery: schemeSpecificPart
]

{ #category : #accessing }
HierarchicalURI >> host [
	^self authority host
]

{ #category : #accessing }
HierarchicalURI >> path [
"	^self schemeSpecificPart isEmpty
		ifTrue: ['/']
		ifFalse: [self schemeSpecificPart]"
	^self schemeSpecificPart
]

{ #category : #accessing }
HierarchicalURI >> pathComponents [
	^self path findTokens: $/
]

{ #category : #accessing }
HierarchicalURI >> port [
	^self authority port
]

{ #category : #printing }
HierarchicalURI >> printSchemeSpecificPartOn: stream [
	self isAbsolute
		ifTrue: [stream nextPutAll: '//'].
	authority
		ifNotNil: [self authority printOn: stream].
	super printSchemeSpecificPartOn: stream.
	query
		ifNotNil: [stream nextPutAll: query]
]

{ #category : #accessing }
HierarchicalURI >> query [
	^query
]

{ #category : #private }
HierarchicalURI >> relativeFromString: aString [
	| remainder authorityEnd |
	remainder := (aString beginsWith: '//')
		ifTrue: [
			authorityEnd := aString indexOf: $/ startingAt: 3.
			authorityEnd = 0
				ifTrue: [authorityEnd := aString size+1].
			self extractAuthority: (aString copyFrom: 3 to: authorityEnd-1)]
		ifFalse: [aString].
	self extractSchemeSpecificPartAndFragment: remainder
]

{ #category : #private }
HierarchicalURI >> removeComponentDotDotPairs: pathComponents [
	| dotDotIndex |
	dotDotIndex := pathComponents indexOf: '..'.
	[dotDotIndex > 1]
		whileTrue: [
			pathComponents
				removeAt: dotDotIndex;
				removeAt: dotDotIndex-1.
			dotDotIndex := pathComponents indexOf: '..']
]

{ #category : #accessing }
HierarchicalURI >> resolveRelativeURI: aURI [
	| relativeURI newAuthority newPath pathComponents newURI relComps |
	relativeURI := aURI asURI.

	relativeURI isAbsolute
		ifTrue: [^relativeURI].

	relativeURI authority
		ifNil: [
			newAuthority := self authority.
			(relativeURI path beginsWith: '/')
				ifTrue: [newPath := relativeURI path]
				ifFalse: [
					pathComponents := (self path copyUpToLast: $/) findTokens: $/.
					relComps := relativeURI pathComponents.
					relComps removeAllSuchThat: [:each | each = '.'].
					pathComponents addAll: relComps.
					pathComponents removeAllSuchThat: [:each | each = '.'].
					self removeComponentDotDotPairs: pathComponents.
					newPath := self buildAbsolutePath: pathComponents.
					((relComps isEmpty
						or: [relativeURI path last == $/ 
						or: [(relativeURI path endsWith: '/..')
						or: [relativeURI path = '..'
						or: [relativeURI path endsWith: '/.' ]]]])
						and: [newPath size > 1])
						ifTrue: [newPath := newPath , '/']]]
		ifNotNil: [
			newAuthority := relativeURI authority.
			newPath := relativeURI path].

	newURI := String streamContents: [:stream |
		stream nextPutAll: self scheme.
		stream nextPut: $: .
		newAuthority notNil
			ifTrue: [
				stream nextPutAll: '//'.
				newAuthority printOn: stream].
		newPath notNil
			ifTrue: [stream nextPutAll: newPath].
		relativeURI query notNil
			ifTrue: [stream nextPutAll: relativeURI query].
		relativeURI fragment notNil
			ifTrue: [
				stream nextPut: $# .
				stream nextPutAll: relativeURI fragment]].
	^newURI asURI
]

{ #category : #accessing }
HierarchicalURI >> userInfo [
	^self authority userInfo
]
