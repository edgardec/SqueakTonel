"
The Authorizer does user authorization checking. Each instance of authorizer keeps track of the realm that it is authorizing for, and the table of authorized users. An authorizer can be asked to return the user name/symbol associated with a userID (which concatenates the username and password from the HTTP request) with the user: method.

"
Class {
	#name : #Authorizer,
	#superclass : #Object,
	#instVars : [
		'users',
		'realm'
	],
	#category : #'Network-Url'
}

{ #category : #utilities }
Authorizer class >> unauthorizedFor: realm [
	^'HTTP/1.0 401 Unauthorized', self crlf, 'WWW-Authenticate: Basic realm="Squeak/',realm,'"',
	String crlfcrlf, '<html><title>Unauthorized</title><body><h2>Unauthorized for ',realm, '</h2></body></html>'


]

{ #category : #authentication }
Authorizer >> encode: nameString password: pwdString [
	"Encode per RFC1421 of the username:password combination."

	^(nameString, ':', pwdString) base64Encoded
]

{ #category : #authentication }
Authorizer >> mapFrom: aKey to: aPerson [
	"Establish a mapping from a RFC 1421 key to a user."

	users isNil ifTrue: [ users := Dictionary new ].
	aPerson
	 isNil ifTrue: [ users removeKey: aKey ]
	 ifFalse: [
		users removeKey: (users keyAtValue: aPerson ifAbsent: []) ifAbsent: [].
		users at: aKey put: aPerson ]

]

{ #category : #authentication }
Authorizer >> mapName: nameString password: pwdString to: aPerson [
	"Insert/remove the encoding per RFC1421 of the username:password combination into/from the UserMap.  DO NOT call this directly, use mapName:password:to: in your ServerAction class.  Only it knows how to record the change on the disk!"

	self mapFrom: (self encode: nameString password: pwdString) to: aPerson

]

{ #category : #realms }
Authorizer >> realm [
	^realm
]

{ #category : #realms }
Authorizer >> realm: aString [
	realm := aString

]

{ #category : #authentication }
Authorizer >> user: userId [
	"Return the requesting user."
	^users at: userId ifAbsent: [ self error: (self class unauthorizedFor: realm) ]
]
