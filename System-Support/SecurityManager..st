Class {
	#name : #SecurityManager,
	#superclass : #Object,
	#instVars : [
		'privateKeyPair',
		'trustedKeys',
		'keysFileName'
	],
	#classVars : [
		'Default'
	],
	#category : #'System-Support'
}

{ #category : #accessing }
SecurityManager class >> default [
	^Default ifNil: [Default := self new]
]

{ #category : #'class initialization' }
SecurityManager class >> initialize [
	"SecurityManager initialize"

	"Order: ExternalSettings, SecurityManager, AutoStart"

	Default := self new.
	Smalltalk addToStartUpList: self after: ExternalSettings.
	Smalltalk addToShutDownList: self
]

{ #category : #'class initialization' }
SecurityManager class >> shutDown [
	self default shutDown.
]

{ #category : #'class initialization' }
SecurityManager class >> startUp [
	self default startUp.
]

{ #category : #accessing }
SecurityManager >> addTrustedKey: aPublicKey [
	"Add a public key to the list of trusted keys"
	trustedKeys := (trustedKeys copyWithout: aPublicKey) copyWith: aPublicKey.
]

{ #category : #testing }
SecurityManager >> canWriteImage [
	"SecurityManager default canWriteImage"
	"Primitive. Return true if the right to write an image hasn't been revoked."
	<primitive: 'primitiveCanWriteImage' module: 'SecurityPlugin'>
	^true "assume so unless otherwise proven"
]

{ #category : #'security operations' }
SecurityManager >> disableFileAccess [
	"SecurityManager default disableFileAccess"
	"Primitive. Disable unlimited access to files.
	Cannot be revoked from the image."
	<primitive: 'primitiveDisableFileAccess' module: 'FilePlugin'>
	^self primitiveFailed
]

{ #category : #'security operations' }
SecurityManager >> disableImageWrite [
	"SecurityManager default disableImageWrite"
	"Primitive. Disable writing to an image file.
	Cannot be revoked from the image."
	<primitive: 'primitiveDisableImageWrite' module: 'SecurityPlugin'>
	^self primitiveFailed
]

{ #category : #'security operations' }
SecurityManager >> disableSocketAccess [
	"SecurityManage default disableSocketAccess"
	"Primitive. Disable access to sockets.
	Cannot be revoked from the image."
	<primitive: 'primitiveDisableSocketAccess' module: 'SocketPlugin'>
	^self primitiveFailed
]

{ #category : #'security operations' }
SecurityManager >> enterRestrictedMode [
	"Some insecure contents was encountered. Close all doors and proceed."
	self isInRestrictedMode ifTrue:[^true].
	Preferences securityChecksEnabled ifFalse:[^true]. "it's been your choice..."
	Preferences warnAboutInsecureContent ifTrue:[
		( UIManager default chooseFrom: #('Load it anyways' 'Do not load it')
			title: 
'You are about to load some insecure content.
If you continue, access to files as well as
some other capabilities will be limited.')
			 = 1 ifFalse:[
				"user doesn't really want it"
				^false.
			].
	].
	"here goes the actual restriction"
	self flushSecurityKeys.
	self disableFileAccess.
	self disableImageWrite.
	"self disableSocketAccess."
	FileDirectory setDefaultDirectory: self untrustedUserDirectory.
	^true

]

{ #category : #'security operations' }
SecurityManager >> fileInObjectAndCode: aStream [
	| trusted |
	trusted := self positionToSecureContentsOf: aStream.
	trusted ifFalse:[self enterRestrictedMode ifFalse:[
		aStream close.
		^nil]].
	^aStream fileInObjectAndCode
]

{ #category : #'initialize-release' }
SecurityManager >> flushSecurityKey: aKey [
	"Flush a security key"
	| n |
	n := aKey first.
	1 to: n basicSize do:[:i| n basicAt: i put: 0].
	n := aKey second.
	1 to: n basicSize do:[:i| n basicAt: i put: 0].

]

{ #category : #'initialize-release' }
SecurityManager >> flushSecurityKeys [
	"Flush all keys"
	privateKeyPair ifNotNil:[
		self flushSecurityKey: privateKeyPair first.
		self flushSecurityKey: privateKeyPair last.
	].
	privateKeyPair := nil.
	trustedKeys do:[:key| self flushSecurityKey: key].
	trustedKeys := #().
]

{ #category : #private }
SecurityManager >> generateKeyPairInBackground [
	"SecurityManager default generateKeyPairInBackground"
	"Silently generate a key set on the local machine while running in the background."
	| guesstimate startTime |
	guesstimate := [10 benchmark] timeToRun * 150.
	startTime := Time millisecondClockValue.
	privateKeyPair := nil.
	[self generateLocalKeyPair] fork.
	UIManager default informUserDuring:[:bar|
		[privateKeyPair == nil] whileTrue:[
			bar value:'Initializing Squeak security system (', (Time millisecondClockValue - startTime * 100 // guesstimate) printString,'%)'.
			(Delay forSeconds: 1) wait.
		].
	].

]

{ #category : #private }
SecurityManager >> generateLocalKeyPair [
	"SecurityManager default generateLocalKeyPair"
	"Generate a key set on the local machine."
	| dsa |
	dsa := DigitalSignatureAlgorithm new.
	dsa initRandomFromString: 
		Time millisecondClockValue printString, 
		Date today printString, 
		Smalltalk platformName printString.
	privateKeyPair := dsa generateKeySet.
	self storeSecurityKeys.
]

{ #category : #testing }
SecurityManager >> hasFileAccess [
	"SecurityManager default hasFileAccess"
	"Return true if the right to access arbitrary files hasn't been revoked"
	<primitive: 'primitiveHasFileAccess' module: 'FilePlugin'>
	^true "assume so unless otherwise proven"
]

{ #category : #testing }
SecurityManager >> hasSocketAccess [
	"SecurityManager default hasSocketAccess"
	"Return true if the right to access sockets hasn't been revoked"
	<primitive: 'primitiveHasSocketAccess' module: 'SocketPlugin'>
	^true "assume so unless otherwise proven"
]

{ #category : #'initialize-release' }
SecurityManager >> initialize [
	privateKeyPair := nil.
	trustedKeys := #().
	keysFileName := 'Squeak.keys'.
]

{ #category : #testing }
SecurityManager >> isInRestrictedMode [
	"Return true if we're in restricted mode"
	^(self canWriteImage 
		or:[self hasFileAccess 
		"or:[self hasSocketAccess]"]) not
]

{ #category : #accessing }
SecurityManager >> keysFileName [
	^keysFileName
]

{ #category : #accessing }
SecurityManager >> keysFileName: aFileName [
	keysFileName := aFileName
]

{ #category : #'fileIn\/out' }
SecurityManager >> loadSecurityKeys [
	"SecurityManager default loadSecurityKeys"
	"Load the keys file for the current user"
	| fd loc file keys |
	self isInRestrictedMode ifTrue:[^self]. "no point in even trying"
	loc := self secureUserDirectory. "where to get it from"
	loc last = FileDirectory pathNameDelimiter ifFalse:[
		loc := loc copyWith: FileDirectory pathNameDelimiter.
	].
	fd := FileDirectory on: loc.
	file := [fd readOnlyFileNamed: keysFileName] 
			on: FileDoesNotExistException do:[:ex| nil].
	file ifNil:[^self]. "no keys file"
	keys := (Object readFrom: file) veryDeepCopy. "Use #veryDeepCopy to make the non-writable literal objects created by the Compiler writable."
	privateKeyPair := keys first.
	trustedKeys := keys last.
	file close.
]

{ #category : #'security operations' }
SecurityManager >> positionToSecureContentsOf: aStream [
	| bytes trusted part1 part2 sig hash dsa okay pos |
	aStream binary.
	pos := aStream position.
	bytes := aStream next: 4.
	bytes = 'SPRJ' asByteArray ifFalse:[
		"was not signed"
		aStream position: pos.
		^false].
	part1 := (aStream nextInto: (LargePositiveInteger basicNew: 20)) normalize.
	part2 := (aStream nextInto: (LargePositiveInteger basicNew: 20)) normalize.
	sig := Array with: part1 with: part2.
	hash := SecureHashAlgorithm new hashStream: aStream.
	dsa := DigitalSignatureAlgorithm new.
	trusted := self trustedKeys.
	okay := trusted anySatisfy: [:key| dsa verifySignature: sig ofMessageHash: hash publicKey: key].
	aStream position: pos+44.
	^okay
]

{ #category : #accessing }
SecurityManager >> primSecureUserDirectory [
	<primitive: 'primitiveGetSecureUserDirectory' module: 'SecurityPlugin'>
	^ nil
]

{ #category : #private }
SecurityManager >> primUntrustedUserDirectory [
	"Primitive. Return the untrusted user directory that is the root directory for files that are visible even in restricted mode."
	<primitive: 'primitiveGetUntrustedUserDirectory' module: 'SecurityPlugin'>
	^ nil
]

{ #category : #private }
SecurityManager >> printStateOn: stream [
	"Print the current state of myself onto stream.
	Used to gather information in the debug log."

	stream
		nextPutAll: 'SecurityManager state:'; cr;
		nextPutAll: 'Restricted: '; nextPutAll: self isInRestrictedMode asString; cr;
		nextPutAll: 'FileAccess: '; nextPutAll: self hasFileAccess asString; cr;
		nextPutAll: 'SocketAccess: '; nextPutAll: self hasSocketAccess asString; cr;
		nextPutAll: 'Working Dir '; nextPutAll: FileDirectory default pathName asString; cr;
		nextPutAll: 'Trusted Dir '; nextPutAll: self secureUserDirectory asString; cr;
		nextPutAll: 'Untrusted Dir '; nextPutAll: self untrustedUserDirectory asString; cr;
		cr
]

{ #category : #accessing }
SecurityManager >> secureUserDirectory [
	"SecurityManager default secureUserDirectory"
	| dir |
	dir := self primSecureUserDirectory.
	^ dir
		ifNil: [FileDirectory default pathName]
		ifNotNil: [dir vmPathToSqueakPath]
]

{ #category : #'initialize-release' }
SecurityManager >> shutDown [
	"Flush existing keys"
	self flushSecurityKeys.
]

{ #category : #'security operations' }
SecurityManager >> signFile: fileName directory: fileDirectory [
	"Sign the given project in the directory"
	| bytes file dsa hash sig key |
	Preferences signProjectFiles ifFalse:[^self]. "signing turned off"
	key := self signingKey.
	key ifNil:[^self].
	file := FileStream readOnlyFileNamed: (fileDirectory fullNameFor: fileName).
	bytes := file binary; contentsOfEntireFile.
	fileDirectory deleteFileNamed: fileName ifAbsent:[].
	dsa := DigitalSignatureAlgorithm new.
	dsa initRandom: Time millisecondClockValue + Date today julianDayNumber.
	hash := SecureHashAlgorithm new hashStream: (ReadStream on: bytes).
	sig := dsa computeSignatureForMessageHash: hash privateKey: key.
	file := FileStream newFileNamed: (fileDirectory fullNameFor: fileName).
	file binary.
	"store a header identifying the signed file first"
	file nextPutAll: 'SPRJ' asByteArray.
	"now the signature"
	file 
		nextPutAll: (sig first withAtLeastNDigits: 20); 
		nextPutAll: (sig last withAtLeastNDigits: 20).
	"now the contents"
	file nextPutAll: bytes.
	file close.
]

{ #category : #accessing }
SecurityManager >> signingKey [
	"Return the key used for signing projects"
	^privateKeyPair ifNotNil:[privateKeyPair first]
]

{ #category : #'initialize-release' }
SecurityManager >> startUp [
	"Attempt to load existing keys"
	self loadSecurityKeys.
	(privateKeyPair == nil 
		and:[self isInRestrictedMode not
		and:[Preferences automaticKeyGeneration]]) ifTrue:[
			self generateKeyPairInBackground.
	].
]

{ #category : #'fileIn\/out' }
SecurityManager >> storeSecurityKeys [
	"SecurityManager default storeSecurityKeys"
	"Store the keys file for the current user"
	| fd loc file |
	self isInRestrictedMode ifTrue:[^self]. "no point in even trying"
	loc := self secureUserDirectory. "where to put it"
	loc last = FileDirectory pathNameDelimiter ifFalse:[
		loc := loc copyWith: FileDirectory pathNameDelimiter.
	].
	fd := FileDirectory on: loc.
	fd assureExistence.
	fd deleteFileNamed: self keysFileName ifAbsent:[].
	file := fd newFileNamed: self keysFileName.
	{privateKeyPair. trustedKeys} storeOn: file.
	file close.
]

{ #category : #accessing }
SecurityManager >> trustedKeys [
	"Return an array of trusted public keys for verifying some project"
	privateKeyPair ifNil:[^trustedKeys].
	^{privateKeyPair second}, trustedKeys
]

{ #category : #accessing }
SecurityManager >> untrustedUserDirectory [
	"SecurityManager default untrustedUserDirectory"
	| dir |
	dir := self primUntrustedUserDirectory.
	^ dir
		ifNil: [FileDirectory default pathName]
		ifNotNil: [dir vmPathToSqueakPath]
]
