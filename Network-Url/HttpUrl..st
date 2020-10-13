"
A URL that can be accessed via the Hypertext Transfer Protocol (HTTP), ie, a standard Web URL

realm = the name of the security realm that has been discovered for this URL.   Look it up in Passwords.

Passwords = a Dictionary of (realm -> encoded user&password)


TODO: use the username and password, if specified

"
Class {
	#name : #HttpUrl,
	#superclass : #HierarchicalUrl,
	#instVars : [
		'realm'
	],
	#classVars : [
		'Passwords'
	],
	#category : #'Network-Url'
}

{ #category : #'system startup' }
HttpUrl class >> shutDown [
	"Forget all cached passwords, so they won't stay in the image"

	Passwords := nil.
]

{ #category : #downloading }
HttpUrl >> askNamePassword [
	"Authorization is required by the host site.  Ask the user for a userName and password.  Encode them and store under this realm.  Return false if the user wants to give up."

	| user pass |
	(self confirm: 'Host ', self asString, '
wants a different user and password.  Type them now?' orCancel: [false])
		ifFalse: [^ false].
	user := UIManager default request: 'User account name?' initialAnswer: ''.
	pass := UIManager default requestPassword: 'Password?'.
	Passwords at: realm put: (Authorizer new encode: user password: pass).
	^ true
]

{ #category : #downloading }
HttpUrl >> checkAuthorization: webDocument retry: retryBlock [
	"authorization failed if webDocument is a String"
	| oldRealm i end encoded |
	((webDocument isString)
		and: [(webDocument beginsWith: 'HTTP/1.0 401')
			or: [webDocument beginsWith: 'HTTP/1.1 401']])
	ifFalse: [^self].

	oldRealm := realm.
	i := webDocument findString: 'realm="'.
	i = 0 ifTrue: [^self].
	end := webDocument indexOf: $" startingAt: i.
	realm := webDocument copyFrom: i+7 to: end.
	"realm := (webDocument findTokens: '""') at: 2."
	Passwords ifNil: [Passwords := Dictionary new].
	encoded := Passwords at: realm ifAbsent: [nil].
	(oldRealm ~= realm) & (encoded ~~ nil) 
		ifTrue: [^ retryBlock value]
		ifFalse: ["ask the user"
			self askNamePassword ifTrue: [^ retryBlock value]]
]

{ #category : #testing }
HttpUrl >> hasRemoteContents [
	"Return true if the receiver describes some remotely accessible content.
	Typically, this should only return if we could retrieve the contents
	on an arbitrary place in the outside world using a standard browser.
	In other words: If you can get to it from the next Internet Cafe, 
	return true, else return false."
	^true
]

{ #category : #downloading }
HttpUrl >> loadRemoteObjects [
	"Load a remote image segment and extract the root objects.
	Check if the remote file is a zip archive."
	"'http://bradley.online.disney.com/games/subgame/squeak-test/assetInfo.extSeg' 
		asUrl loadRemoteObjects" 
	"'http://bradley.online.disney.com/games/subgame/squeak-test/assetInfo.zip' 
		asUrl loadRemoteObjects" 

	| stream info data extension |
 	data := self retrieveContents content.
	extension := (FileDirectory extensionFor: self path last) asLowercase.
	(#('zip' 'gzip') includes: extension)
		ifTrue: [data := (GZipReadStream on: data) upToEnd].
"	stream := StreamWrapper streamOver: (ReadStream on: data)."
	stream := RWBinaryOrTextStream on: data.
	stream reset.
	info := stream fileInObjectAndCode.
	stream close.
	^info arrayOfRoots
]

{ #category : #downloading }
HttpUrl >> normalizeContents: webDocument [
	(webDocument isString) ifTrue: [
		^MIMEDocument
			contentType: 'text/plain'
			content: 'error occured retrieving ', self asString, ': ', webDocument
			url: (Url absoluteFromText: '')].
	webDocument contentType = MIMEDocument defaultContentType ifTrue: [
		^MIMEDocument contentType: (MIMEDocument guessTypeFromName: self path last) 
			content: webDocument content url: webDocument url ].

	^webDocument
]

{ #category : #downloading }
HttpUrl >> postFormArgs: args [
	| contents request |
	request := realm ifNotNil: [Passwords at: realm ifAbsent: ['']]
		ifNil: [''].
	request = '' ifFalse: [request := 'Authorization: Basic ', request, String crlf].
		"Why doesn't Netscape send the name of the realm instead of Basic?"
	contents := (HTTPSocket httpPostDocument: self asString args: args
				accept: 'application/octet-stream' request: request).

	self checkAuthorization: contents retry: [^ self postFormArgs: args].

	^self normalizeContents: contents
]

{ #category : #downloading }
HttpUrl >> postMultipartFormArgs: args [
	| contents request |
	request := realm ifNotNil: [Passwords at: realm ifAbsent: ['']]
		ifNil: [''].
	request = '' ifFalse: [request := 'Authorization: Basic ', request, String crlf].
		"Why doesn't Netscape send the name of the realm instead of Basic?"
	contents := (HTTPSocket httpPostMultipart: self asString args: args
				accept: 'application/octet-stream' request: request).

	self checkAuthorization: contents retry: [^ self postMultipartFormArgs: args].

	^self normalizeContents: contents
]

{ #category : #downloading }
HttpUrl >> privateInitializeFromText: aString relativeTo: aUrl [

	super privateInitializeFromText: aString relativeTo: aUrl.
	realm := aUrl realm.
]

{ #category : #downloading }
HttpUrl >> realm [
	^ realm
]

{ #category : #downloading }
HttpUrl >> retrieveContents [
	^ self retrieveContentsArgs: nil
]

{ #category : #downloading }
HttpUrl >> retrieveContentsAccept: mimeType [
	^ self retrieveContentsArgs: nil accept: mimeType
]

{ #category : #downloading }
HttpUrl >> retrieveContentsArgs: args [
	^self retrieveContentsArgs: args accept: '*/*; q=1'
]

{ #category : #downloading }
HttpUrl >> retrieveContentsArgs: args accept: mimeType [
	| contents request |
	request := realm ifNotNil: [Passwords at: realm ifAbsent: ['']] ifNil: [''].
	request = '' ifFalse: [request := 'Authorization: Basic ' , request , String crlf].
		"Why doesn't Netscape send the name of the realm instead of Basic?"

	contents := (HTTPSocket
		httpGetDocument: self withoutFragment asString
		args: args
		accept: mimeType
		request: request).

	self checkAuthorization: contents retry: [^ self retrieveContentsArgs: args].

	^ self normalizeContents: contents
]
