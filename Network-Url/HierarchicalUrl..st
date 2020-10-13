"
A URL which has a hierarchical encoding.  For instance, http and ftp URLs are hierarchical.
"
Class {
	#name : #HierarchicalUrl,
	#superclass : #Url,
	#instVars : [
		'schemeName',
		'authority',
		'path',
		'query',
		'port',
		'username',
		'password'
	],
	#category : #'Network-Url'
}

{ #category : #'instance creation' }
HierarchicalUrl class >> schemeName: schemeName  authority: authority  path: path  query: query [
	^self new schemeName: schemeName  authority: authority  path: path  query: query
]

{ #category : #access }
HierarchicalUrl >> authority [
	^authority
]

{ #category : #access }
HierarchicalUrl >> directoryUrl [
	"The path always has at least one element so this works."

	^self copy path: (path copyFrom: 1 to: path size - 1)
]

{ #category : #access }
HierarchicalUrl >> fileName [
	"Return the last part of the path,
	most often a filename but does not need to be."

	^self path last
]

{ #category : #printing }
HierarchicalUrl >> fullPath [
	| ans |
	ans := WriteStream on: String new.
	path do: [ :pathElem |
		ans nextPut: $/.
		ans nextPutAll: pathElem encodeForHTTP. ].
	self query isNil ifFalse: [ 
		ans nextPut: $?.
		ans nextPutAll: self query. ].
	self fragment isNil ifFalse: [
		ans nextPut: $#.
		ans nextPutAll: self fragment encodeForHTTP. ].
	
	^ans contents
]

{ #category : #downloading }
HierarchicalUrl >> hasContents [
	"most of these do...."
	^true
]

{ #category : #access }
HierarchicalUrl >> isAbsolute [
	
	path size > 0 ifFalse: [^ false].
	(path at: 1) size > 0 ifFalse: [^ false].
	^ ((path at: 1) at: 1) ~~ $.
]

{ #category : #access }
HierarchicalUrl >> password [
	"http://user:pword@foo.com' asUrl password"
	^password
]

{ #category : #access }
HierarchicalUrl >> path [
	"return a collection of the decoded path elements, as strings"
	^path
]

{ #category : #access }
HierarchicalUrl >> path: aCollection [
	"Set the collection of path elements."

	path := aCollection
]

{ #category : #access }
HierarchicalUrl >> port [
	^port
]

{ #category : #copying }
HierarchicalUrl >> postCopy [
	"Be sure not to share the path with the original"

	super postCopy.
	path := path copy
]

{ #category : #printing }
HierarchicalUrl >> printOn: aStream [

	aStream nextPutAll: self schemeName.
	aStream nextPutAll: '://'.
	self username ifNotNil: [
		aStream nextPutAll: self username encodeForHTTP.
		self password ifNotNil: [
			aStream nextPutAll: ':'.
			aStream nextPutAll: self password encodeForHTTP].
		aStream nextPutAll: '@' ].
	aStream nextPutAll: self authority.
	port ifNotNil: [aStream nextPut: $:; print: port].
	path do: [ :pathElem |
		aStream nextPut: $/.
		aStream nextPutAll: pathElem encodeForHTTP. ].
	self query isNil ifFalse: [ 
		aStream nextPut: $?.
		aStream nextPutAll: self query. ].
	self fragment isNil ifFalse: [
		aStream nextPut: $#.
		aStream nextPutAll: self fragment encodeForHTTP. ].
]

{ #category : #parsing }
HierarchicalUrl >> privateInitializeFromText: aString [ 
	| remainder ind specifiedSchemeName |
	remainder := aString.
	schemeName ifNil: 
			[specifiedSchemeName := Url schemeNameForString: remainder.
			specifiedSchemeName ifNotNil: 
					[schemeName := specifiedSchemeName.
					remainder := remainder copyFrom: schemeName size + 2 to: remainder size].
			schemeName ifNil: 
					["assume HTTP"

					schemeName := 'http']].

	"remove leading // if it's there"
	(remainder beginsWith: '//') 
		ifTrue: [remainder := remainder copyFrom: 3 to: remainder size].


	"get the query"
	ind := remainder indexOf: $?.
	ind > 0 
		ifTrue: 
			[query := remainder copyFrom: ind + 1 to: remainder size.
			remainder := remainder copyFrom: 1 to: ind - 1].

	"get the authority"
	ind := remainder indexOf: $/.
	ind > 0 
		ifTrue: 
			[ind = 1 
				ifTrue: [authority := '']
				ifFalse: 
					[authority := remainder copyFrom: 1 to: ind - 1.
					remainder := remainder copyFrom: ind + 1 to: remainder size]]
		ifFalse: 
			[authority := remainder.
			remainder := ''].

	"extract the username+password"
	(authority includes: $@) 
		ifTrue: 
			[username := authority copyUpTo: $@.
			authority := authority copyFrom: (authority indexOf: $@) + 1
						to: authority size.
			(username includes: $:) 
				ifTrue: 
					[password := (username copyFrom: (username indexOf: $:) + 1 to: username size) unescapePercents.
					username := username copyUpTo: $:].
			username := username unescapePercents].

	"Extract the port"
	(authority includes: $:) 
		ifTrue: 
			[| lastColonIndex portString |
			lastColonIndex := authority findLast: [:c | c = $:].
			portString := authority copyFrom: lastColonIndex + 1 to: authority size.
			portString isAllDigits 
				ifTrue: 
					[port := Integer readFromString: portString.
					(port > 65535) ifTrue: [self error: 'Invalid port number'].
					 authority := authority copyFrom: 1 to: lastColonIndex - 1]
				ifFalse:[self error: 'Invalid port number']].

	"get the path"
	path := self privateParsePath: remainder relativeTo: #() .
]

{ #category : #parsing }
HierarchicalUrl >> privateInitializeFromText: aString relativeTo: aUrl [ 
	| remainder ind basePath |
	remainder := aString.
	"set the scheme"
	schemeName := aUrl schemeName.

	"a leading // means the authority is specified, meaning it is absolute"
	(remainder beginsWith: '//')
		ifTrue: [^ self privateInitializeFromText: aString].

	"otherwise, use the same authority"
	authority := aUrl authority.
	port := aUrl port.
	username := aUrl username.
	password := aUrl password.

	"get the query"
	ind := remainder indexOf: $?.
	ind > 0
		ifTrue: [query := remainder copyFrom: ind + 1 to: remainder size.
			remainder := remainder copyFrom: 1 to: ind - 1].

	"get the path"
	(remainder beginsWith: '/')
		ifTrue: [ basePath := #() ]
		ifFalse: [ basePath := aUrl path ].
	path := self privateParsePath: remainder  relativeTo: basePath.


]

{ #category : #parsing }
HierarchicalUrl >> privateParsePath: remainder relativeTo: basePath [ 
	| nextTok s parsedPath |
	s := ReadStream on: remainder.

	parsedPath := OrderedCollection new.
	parsedPath addAll: basePath.
	parsedPath isEmpty ifFalse: [ parsedPath removeLast ].
	
	[s peek = $/ ifTrue: [s next].
	nextTok := WriteStream on: String new.
	[s atEnd or: [s peek = $/]] whileFalse: [nextTok nextPut: s next].
	nextTok := nextTok contents unescapePercents.
	nextTok = '..' 
		ifTrue: [parsedPath size > 0 ifTrue: [parsedPath removeLast]]
		ifFalse: [nextTok ~= '.' ifTrue: [parsedPath add: nextTok]].
	s atEnd] 
			whileFalse.
	parsedPath isEmpty ifTrue: [parsedPath add: ''].

	^parsedPath
]

{ #category : #access }
HierarchicalUrl >> query [
	"return the query, the part after any ?.  Any %XY's have already been decoded.  If there wasno query part, nil is returned (it is possible to also have an empty query"
	^query 
]

{ #category : #classification }
HierarchicalUrl >> scheme [
	^ self schemeName.
]

{ #category : #access }
HierarchicalUrl >> schemeName [
	^schemeName
]

{ #category : #private }
HierarchicalUrl >> schemeName: schemeName0  authority: authority0  path: path0  query: query0 [
	"initialize a new instance"
	schemeName := schemeName0.
	authority := authority0.
	path := path0.
	query := query0.

]

{ #category : #access }
HierarchicalUrl >> username [
	"http://user:pword@foo.com' asUrl username"
	^username
]
