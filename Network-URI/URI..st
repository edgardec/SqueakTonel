"
This class is deprecated. Consider using one of the Url classes instead.

A Uniform Resource Identifier (URI) is a compact string of characters for identifying an abstract or physical resource.
This implementation is based on http://www.ietf.org/rfc/rfc2396.txt.


"
Class {
	#name : #URI,
	#superclass : #Object,
	#instVars : [
		'fragment',
		'scheme',
		'schemeSpecificPart'
	],
	#classVars : [
		'ClientClasses'
	],
	#category : #'Network-URI'
}

{ #category : #'instance creation' }
URI class >> absoluteFromString: aString scheme: scheme [
	| remainder |
	remainder := aString copyFrom: scheme size+2 to: aString size.
	remainder isEmpty
		ifTrue: [(IllegalURIException new uriString: aString) signal: 'Invalid absolute URI'].
	^(remainder first = $/
		ifTrue: [HierarchicalURI]
		ifFalse: [OpaqueURI]) new absoluteFromString: remainder scheme: scheme
]

{ #category : #'instance creation' }
URI class >> extractSchemeFrom: aString [
	| colonIndex slashIndex |
	colonIndex := aString indexOf: $: .
	^colonIndex > 0
		ifTrue: [
			slashIndex := aString indexOf: $/ .
			(slashIndex = 0
				or: [colonIndex < slashIndex])
				ifTrue: [aString copyFrom: 1 to: colonIndex-1]
				ifFalse: [nil]]
		ifFalse: [nil]
]

{ #category : #'instance creation' }
URI class >> fromString: aString [
	| parseString scheme |
	parseString := aString withBlanksTrimmed.
	scheme := self extractSchemeFrom: parseString.
	^scheme
		ifNil: [HierarchicalURI new relativeFromString: aString]
		ifNotNil: [self absoluteFromString: aString scheme: scheme]

]

{ #category : #'class initialization' }
URI class >> initialize [
	"URI initialize"

	ClientClasses := Dictionary new.
	ClientClasses
		at: 'http' put: #HTTPClient;
		at: 'ftp' put: #FTPClient;
		at: 'file' put: #FileDirectory

]

{ #category : #testing }
URI >> = otherURI [
	^ self class = otherURI class
		and: [self asString = otherURI asString]
]

{ #category : #private }
URI >> absoluteFromString: remainder scheme: schemeName [
	scheme := schemeName.
	self extractSchemeSpecificPartAndFragment: remainder
]

{ #category : #printing }
URI >> allButScheme [
	"Answer the entire url except its scheme"

	^String streamContents:[:s|
		s nextPutAll: schemeSpecificPart.
		fragment ifNotNil: [
			s nextPut: $# .
			s nextPutAll: self fragment]
	].
]

{ #category : #converting }
URI >> asText [
	^self asString asText
]

{ #category : #converting }
URI >> asURI [
	^self
]

{ #category : #converting }
URI >> asUrl [

	^self asString asUrl
]

{ #category : #private }
URI >> clientClass [
	^Smalltalk at: (ClientClasses at: self scheme ifAbsent: [ClientClasses at: 'file'])
]

{ #category : #retrieval }
URI >> contentStream [
	^self clientClass contentStreamForURI: self
]

{ #category : #converting }
URI >> downloadUrl [
	self halt
]

{ #category : #private }
URI >> extractSchemeSpecificPartAndFragment: remainder [
	| fragmentIndex |
	fragmentIndex := remainder indexOf: $# .
	fragmentIndex > 0
		ifTrue: [
			schemeSpecificPart := remainder copyFrom: 1 to: fragmentIndex-1.
			fragment := remainder copyFrom: fragmentIndex+1 to: remainder size]
		ifFalse: [schemeSpecificPart := remainder]
]

{ #category : #accessing }
URI >> fragment [
	^fragment
]

{ #category : #testing }
URI >> hasRemoteContents [
	self halt
]

{ #category : #testing }
URI >> hash [
	^ self asString hash
]

{ #category : #testing }
URI >> isAbsolute [
	^self scheme notNil
]

{ #category : #testing }
URI >> isOpaque [
	^false
]

{ #category : #testing }
URI >> isRelative [
	^self isAbsolute not
]

{ #category : #printing }
URI >> printOn: stream [
	self isAbsolute
		ifTrue: [
			stream nextPutAll: self scheme.
			stream nextPut: $: ].
	self printSchemeSpecificPartOn: stream.
	fragment
		ifNotNil: [
			stream nextPut: $# .
			stream nextPutAll: self fragment]

]

{ #category : #printing }
URI >> printSchemeSpecificPartOn: stream [
	stream nextPutAll: self schemeSpecificPart
]

{ #category : #accessing }
URI >> resolveRelativeURI: relativeURI [
	self shouldNotImplement
]

{ #category : #retrieval }
URI >> retrieveContentStream [
	^self retrieveMIMEDocument contentStream
]

{ #category : #retrieval }
URI >> retrieveContents [
	^self retrieveMIMEDocument contents
]

{ #category : #retrieval }
URI >> retrieveMIMEDocument [
	^self clientClass retrieveMIMEDocument: self
]

{ #category : #accessing }
URI >> scheme [
	^scheme
]

{ #category : #private }
URI >> schemeSpecificPart [
	^schemeSpecificPart
]
