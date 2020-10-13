Class {
	#name : #MCHttpRepository,
	#superclass : #MCFileBasedRepository,
	#instVars : [
		'location',
		'user',
		'password',
		'readerCache',
		'indexed',
		'webClient'
	],
	#classVars : [
		'URLRewriteRules',
		'UseSharedWebClientInstance'
	],
	#category : #'Monticello-Repositories'
}

{ #category : #'class initialization' }
MCHttpRepository class >> cleanUp: aggressive [
	
	aggressive ifTrue: [ self clearCredentials ]
]

{ #category : #'class initialization' }
MCHttpRepository class >> clearCredentials [
	self allSubInstancesDo: [ : each | each clearCredentials ]
]

{ #category : #'ui-support' }
MCHttpRepository class >> creationTemplate [
	^self creationTemplateLocation: 'https://www.squeaksource.com/ProjectName'
		user: 'squeak'
		password: 'squeak'

]

{ #category : #'ui-support' }
MCHttpRepository class >> creationTemplateLocation: location user: user password: password [
	^
'MCHttpRepository
	location: {1}
	user: {2}
	password: {3}' format: {location printString. user printString. password printString}
]

{ #category : #'ui-support' }
MCHttpRepository class >> description [
	^ 'HTTP'
]

{ #category : #'ui-support' }
MCHttpRepository class >> fillInTheBlankRequest [
	^ 'HTTP Repository:'
			
]

{ #category : #'well-known repositories' }
MCHttpRepository class >> inbox [
	^ MCRepositoryGroup default repositories
		detect:
			[ : each | each isInbox ]
		ifNone:
			[ MCHttpRepository
				location: MCHttpRepository inboxUrlString
				user: 'squeak'
				password: 'squeak' ]
]

{ #category : #accessing }
MCHttpRepository class >> inboxUrlString [
	^ 'http://source.squeak.org/inbox'
]

{ #category : #'class initialization' }
MCHttpRepository class >> initialize [
	self unload.
	(ServiceRegistry current serviceWithId: #browserMethodMenu) services add: self browseMethodRevisionsService.
	(ServiceRegistry current serviceWithId: #browserClassMenu) services add: self browseClassRevisionsService
]

{ #category : #'ui-support' }
MCHttpRepository class >> location: location user: user password: password [
	^ self new
		location: location;
		user: user;
		password: password
]

{ #category : #'ui-support' }
MCHttpRepository class >> morphicConfigure [
	^ self fillInTheBlankConfigure
]

{ #category : #'url rewrite' }
MCHttpRepository class >> rewriteUrl: aString forDownload: forDownload [

	| result |
	result := aString.
	self urlRewriteRules groupsDo: [ :regexString :replacement :downloadOnly |
		(forDownload or: [ downloadOnly not ])	ifTrue: [
			result := result copyWithRegex: regexString matchesReplacedWith: replacement ] ].
	^result
	
"
self assert:  'https://squeaksource.com/foo/bar?baz=1' = (self rewriteUrl: 'http://squeaksource.com/foo/bar?baz=1' forDownload: true).
self assert:  'https://squeaksource.com/foo/bar?baz=1' = (self rewriteUrl: 'https://squeaksource.com/foo/bar?baz=1' forDownload: true).
self assert:  'https://source.squeak.org/foo/bar?baz=1' = (self rewriteUrl: 'http://source.squeak.org/foo/bar?baz=1' forDownload: true).
self assert:  'https://source.squeak.org/foo/bar?baz=1' = (self rewriteUrl: 'https://source.squeak.org/foo/bar?baz=1' forDownload: true).
self assert:  'http://static.smalltalkhub.com/foo/bar?baz=1' = (self rewriteUrl: 'http://smalltalkhub.com/foo/bar?baz=1' forDownload: true).
self assert:  'http://smalltalkhub.com/foo/bar?baz=1' = (self rewriteUrl: 'http://smalltalkhub.com/foo/bar?baz=1' forDownload: false).
"
]

{ #category : #'well-known repositories' }
MCHttpRepository class >> treated [
	^ MCRepositoryGroup default repositories
		detect:
			[ : each | each isTreated ]
		ifNone:
			[ MCHttpRepository
				location: MCHttpRepository treatedUrlString
				user: 'squeak'
				password: 'squeak' ]
]

{ #category : #accessing }
MCHttpRepository class >> treatedUrlString [
	^ 'http://source.squeak.org/treated'
]

{ #category : #'well-known repositories' }
MCHttpRepository class >> trunk [
	^ MCRepositoryGroup default repositories
		detect:
			[ : each | each isTrunk ]
		ifNone:
			[ MCHttpRepository
				location: MCHttpRepository trunkUrlString
				user: 'squeak'
				password: 'squeak' ]
]

{ #category : #accessing }
MCHttpRepository class >> trunkUrlString [
	^ 'http://source.squeak.org/trunk'
]

{ #category : #'class initialization' }
MCHttpRepository class >> unload [
	| methodMenuServiceCategory classMenuServiceCategory |
	methodMenuServiceCategory := ServiceRegistry current serviceWithId: #browserMethodMenu.
	methodMenuServiceCategory services copy do:
		[ : each | (#(#browseMcMethodRevisions #browseMcMethodOrigin ) includes: each id) ifTrue: [ methodMenuServiceCategory services remove: each ] ].
	classMenuServiceCategory := ServiceRegistry current serviceWithId: #browserClassMenu.
	classMenuServiceCategory services copy do:
		[ : each | (#(#browseMcClassRevisions #browseMcClassOrigin ) includes: each id) ifTrue: [ classMenuServiceCategory services remove: each ] ]
]

{ #category : #'url rewrite' }
MCHttpRepository class >> urlRewriteRules [

	^URLRewriteRules ifNil: [
		URLRewriteRules := #(
			"Regex to be replaced"	"static replacement string"	"download only"
			'^http\://source\.squeak\.org/' 'https://source.squeak.org/' false
			'^http\://squeaksource\.com/' 'https://squeaksource.com/' false
			'^http\://www.squeaksource\.com/' 'https://www.squeaksource.com/' false
			'^http\://smalltalkhub.com/' 'http://static.smalltalkhub.com/' true	
		)  asOrderedCollection ]
]

{ #category : #preferences }
MCHttpRepository class >> useSharedWebClientInstance [
	
	<preference: 'Use shared WebClient instance'
		category: 'Monticello'
		description: 'When true, use a shared WebClient instance to speed up downloads from MCHttpRepositories. Requires WebClient to be present.'
		type: #Boolean>
	^UseSharedWebClientInstance ifNil: [
		"There is some issue on Windows and Macos, so don't use it there by default. See http://lists.squeakfoundation.org/pipermail/squeak-dev/2019-September/thread.html#203921 for details."
		Smalltalk os platformName ~= 'Win32' and: [Smalltalk os platformName ~= 'Mac OS']]
]

{ #category : #preferences }
MCHttpRepository class >> useSharedWebClientInstance: aBoolean [
	
	UseSharedWebClientInstance := aBoolean
]

{ #category : #'private-files' }
MCHttpRepository >> allFileNames [

	| index |
	index := self displayProgress: 'Updating ', self description during: [
		self httpGet: self locationWithTrailingSlash, '?C=M;O=D' arguments: nil ].
	^index ifNotNil: [ self parseFileNamesFromStream: index ]
]

{ #category : #accessing }
MCHttpRepository >> asCreationTemplate [
	^self class creationTemplateLocation: location user: user password: password
]

{ #category : #accessing }
MCHttpRepository >> clearCredentials [
	user beWritableObject.
	user ifNotNil: [user atAllPut: $x].
	password beWritableObject.
	password ifNotNil: [password atAllPut: $x].
	user := password := String empty
]

{ #category : #accessing }
MCHttpRepository >> creationTemplate [
	^ self asCreationTemplate
]

{ #category : #accessing }
MCHttpRepository >> creationTemplate: aString [
	creationTemplate := nil.
]

{ #category : #'user interface' }
MCHttpRepository >> description [
	^ location
]

{ #category : #private }
MCHttpRepository >> displayProgress: label during: workBlock [
	| nextUpdateTime |
	nextUpdateTime := 0.
	^label displayProgressFrom: 0.0 to: 1.0 during:[:bar|
		bar value: 0.0.
		workBlock on: HTTPProgress do:[:ex|
			(ex total == nil or:[ex amount == nil]) ifFalse:[
				(nextUpdateTime < Time millisecondClockValue 
					or:[ex total = ex amount]) ifTrue:[
						bar value: ex amount asFloat / ex total asFloat.
						nextUpdateTime := Time millisecondClockValue + 100.
				].
			].
			ex resume.
		]
	].

]

{ #category : #private }
MCHttpRepository >> flushCache [
	super flushCache.
	readerCache := nil.
]

{ #category : #private }
MCHttpRepository >> httpGet: url arguments: arguments [

	| urlString |
	urlString := arguments
		ifNil: [ url ]
		ifNotNil: [ 
			| queryString |
			queryString := WebUtils encodeUrlEncodedForm: arguments.
			(url includes: $?)
				ifTrue: [ url, '&', queryString ]
				ifFalse: [ url, '?', queryString ] ].
	urlString := self class rewriteUrl: urlString forDownload: true.
	^self webClientDo: [ :client | 
		client
			username: self user;
			password: self password;
			httpGet: urlString do: [ :request |
				request
					headerAt: 'Authorization' put: 'Basic ', (self user, ':', self password) base64Encoded;
					headerAt: 'Connection' put: 'Keep-Alive';
					headerAt: 'Accept' put: '*/*' ] ]
]

{ #category : #private }
MCHttpRepository >> httpGet: actionString for: aMCDefinition [
	^ HTTPSocket
		httpGet: self locationWithTrailingSlash
		args: 
			{ 'action'->{actionString}.
			'mc-definition'-> {self serializeForRequest: aMCDefinition}}
		user: self user
		passwd: self password
]

{ #category : #testing }
MCHttpRepository >> isInbox [
	^ location = self class inboxUrlString
]

{ #category : #private }
MCHttpRepository >> isIndexed [
	^ indexed ifNil:
		[indexed := [(HTTPSocket
			httpGet: self locationWithTrailingSlash
			args: {'query' -> {'isHistorySupported'}}
			user: self user
			passwd: self password) contents = 'true']
			on: Error
			do:
				[:err | false]]
]

{ #category : #testing }
MCHttpRepository >> isTreated [
	^ location = self class treatedUrlString
]

{ #category : #testing }
MCHttpRepository >> isTrunk [
	^ location = self class trunkUrlString
]

{ #category : #accessing }
MCHttpRepository >> location: aUrlString [
	location := aUrlString
]

{ #category : #accessing }
MCHttpRepository >> locationWithTrailingSlash [
	^ (location endsWith: '/')
		ifTrue: [location]
		ifFalse: [location, '/']
]

{ #category : #accessing }
MCHttpRepository >> originOf: aMCDefinition [ 
	| reply |
	reply := self
		httpGet: 'origin'
		for: aMCDefinition.
	^ reply isString
		ifTrue:
			[ Warning signal: 'Origin request failed.  Server ''reply'' in debugger.'.
			Array empty ]
		ifFalse: [ (ReferenceStream on: reply) next ]
]

{ #category : #private }
MCHttpRepository >> parseFileNamesFromStream: aStream [
	| names fullName |
	names := OrderedCollection new.
	[aStream atEnd] whileFalse:
		[[aStream upTo: $<. {$a. $A. nil} includes: aStream next] whileFalse.
		aStream upTo: $".
		aStream atEnd ifFalse: [
			fullName := aStream upTo: $".
			names add: fullName unescapePercents asMCVersionName ]].
	^ names
]

{ #category : #accessing }
MCHttpRepository >> password [
	self userAndPasswordFromSettingsDo: [:usr :pwd | ^pwd].

	self user isEmpty ifTrue: [^password ifNil: ['']].

	password isEmptyOrNil ifTrue: [
		| answer |
		"Give the user a chance to change the login"
		answer := UIManager default request: 'User name for ', String cr, location
			initialAnswer: self user.
		answer isEmpty
			ifTrue: [^password]
			ifFalse: [self user: answer].
		
		password := UIManager default requestPassword: 'Password for "', self user, '" at ', String cr, location.
	].

	^ password
]

{ #category : #accessing }
MCHttpRepository >> password: passwordString [
	password := passwordString
]

{ #category : #private }
MCHttpRepository >> readStreamForFileNamed: aString do: aBlock [

	| contents attempts|
	attempts := 0.
	self displayProgress: 'Downloading ', aString during: [
		[attempts := attempts + 1.
		contents := self httpGet: (self urlForFileNamed: aString) arguments: nil] on: NetworkError do: [:ex| 
		attempts >= 3 ifTrue:[ex pass].
		ex retry ]].
	^contents ifNotNil: [ aBlock value: contents ]
]

{ #category : #accessing }
MCHttpRepository >> refresh [
	super refresh.
	indexed := nil
]

{ #category : #accessing }
MCHttpRepository >> revisionsOf: aMCDefinition [ 
	| reply |
	reply := self
		httpGet: 'history'
		for: aMCDefinition.
	^ reply isString
		ifTrue:
			[ Warning signal: 'Revisions request failed.  Server ''reply'' in debugger.'.
			Array empty ]
		ifFalse: [ (ReferenceStream on: reply) next ]
]

{ #category : #private }
MCHttpRepository >> serializeForRequest: aMCDefinition [ 
	^ ((ReferenceStream on: (RWBinaryOrTextStream on: ByteArray new))
		 nextPut: aMCDefinition ;
		 yourself) contents asString encodeForHTTP
]

{ #category : #accessing }
MCHttpRepository >> urlForFileNamed: aString [
	^ self locationWithTrailingSlash, aString encodeForHTTP
]

{ #category : #accessing }
MCHttpRepository >> user [
	self userAndPasswordFromSettingsDo: [:usr :pwd | ^usr].
	"not in settings"
	^user ifNil: ['']
]

{ #category : #accessing }
MCHttpRepository >> user: userString [
	user := userString
]

{ #category : #private }
MCHttpRepository >> userAndPasswordFromSettingsDo: aBlock [
	"The mcSettings file in ExternalSettings preferenceDirectory should contain entries for each account:
	
		account1: *myhost.mydomain* user:password
		account2: *otherhost.mydomain/somerep* dXNlcjpwYXNzd29yZA==

	That is it must start with 'account', followed by anything to distinguish accounts, and a colon. Then comes a match expression for the repository url, and after a space the user:password string.
	
	To not have the clear text password on your disc, you can base64 encode it:
			(Base64MimeConverter mimeEncode: 'user:password' readStream) contents
	"

	
	Settings ifNotNil: [
		Settings keysAndValuesDo: [:key :value | | userAndPassword entry |
			(key asLowercase beginsWith: 'account') ifTrue: [
				entry := value findTokens: '	 '.
				(entry first match: location) ifTrue: [
					userAndPassword := entry second.
					(userAndPassword includes: $:) ifFalse: [
						userAndPassword := (Base64MimeConverter mimeDecodeToChars: userAndPassword readStream) contents].
					userAndPassword := userAndPassword findTokens: $:.
					^aBlock value: userAndPassword first 
						value: userAndPassword second 
					]
			]
		]
	].
	^nil
]

{ #category : #accessing }
MCHttpRepository >> versionReaderForFileNamed: aString [
	readerCache ifNil: [readerCache := Dictionary new].
	^ readerCache at: aString ifAbsent:
		[self resizeCache: readerCache.
		super versionReaderForFileNamed: aString do:
			[:r |
			r ifNotNil: [readerCache at: aString put: r]]]
	
]

{ #category : #accessing }
MCHttpRepository >> versionReaderForFileNamed: aString do: aBlock [
	^ (self versionReaderForFileNamed: aString) ifNotNil: aBlock
]

{ #category : #private }
MCHttpRepository >> webClientDo: aBlock [

	| client attemptsLeft response result |
	self class useSharedWebClientInstance ifTrue: [
		"Acquire webClient by atomically storing it in the client variable and setting its value to nil."
		client := webClient.
		webClient := nil ].
	
	client 
		ifNil: [ client := WebClient new ]
		ifNotNil: [ 
			"Attempt to avoid an error by recreating the underlying stream."
			client isConnected ifFalse: [ client close ] ].
		
	attemptsLeft := 3.
	response := nil.
	[ response isNil and: [ attemptsLeft > 0 ] ] whileTrue: [
		response := [ aBlock value: client ]
			on: NetworkError
			do: [ :error |
				attemptsLeft = 0 ifTrue: [ error pass ].
				(3 - attemptsLeft) seconds asDelay wait.
				attemptsLeft := attemptsLeft - 1.
				nil "The response" ] ].	
	
	result := (response code between: 200 and: 299) 
		ifFalse: [
			response content. "Make sure content is read."
			nil ]
		ifTrue: [ 
			(RWBinaryOrTextStream with: (
				response contentWithProgress:  [ :total :amount |
					HTTPProgress new 
						total: total;
						amount: amount;
						signal ])) reset ].

	self class useSharedWebClientInstance
		ifTrue: [
			"Save the WebClient instance for reuse, but only if there is no client cached."
			webClient  
				ifNil: [ webClient := client ]
				ifNotNil: [ client close ] ]
		ifFalse: [ client close ].

	result ifNil: [ NetworkError signal: 'Could not access ', location ].
	^result
]

{ #category : #private }
MCHttpRepository >> writeStreamForFileNamed: aString replace: ignoreBoolean do: aBlock [

	| stream urlString |
	stream := RWBinaryOrTextStream on: String new.
	aBlock value: stream.
	urlString := self urlForFileNamed: aString.
	urlString := self class rewriteUrl: urlString forDownload: false.
	^self displayProgress: 'Uploading ', aString during: [
		self webClientDo: [ :client |
			client
				username: self user;
				password: self password;
				httpPut: urlString
					content: stream contents
					type: nil
					do: [ :request |
						request
							headerAt: 'Authorization' put: 'Basic ', (self user, ':', self password) base64Encoded;
							headerAt: 'Connection' put: 'Keep-Alive';
							headerAt: 'Accept' put: '*/*'  ] ] ]
]
