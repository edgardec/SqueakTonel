Class {
	#name : #MCFtpRepository,
	#superclass : #MCFileBasedRepository,
	#instVars : [
		'host',
		'directory',
		'user',
		'password',
		'connection'
	],
	#category : #'Monticello-Repositories'
}

{ #category : #configuring }
MCFtpRepository class >> creationTemplate [
	^
'MCFtpRepository
	host: ''modules.squeakfoundation.org''
	directory: ''mc''
	user: ''squeak''
	password: ''squeak'''
	
]

{ #category : #configuring }
MCFtpRepository class >> description [
	^ 'FTP'
]

{ #category : #configuring }
MCFtpRepository class >> fillInTheBlankRequest [
	^ 'FTP Repository:'

	
]

{ #category : #'instance creation' }
MCFtpRepository class >> host: host directory: directory user: user password: password [
	^ self new
		host: host;
		directory: directory;
		user: user;
		password: password
]

{ #category : #configuring }
MCFtpRepository class >> morphicConfigure [
	^ self fillInTheBlankConfigure
]

{ #category : #constants }
MCFtpRepository class >> templateCreationSelector [
	^ #host:directory:user:password: 
]

{ #category : #required }
MCFtpRepository >> allFileNames [
	^ self clientDo:
		[:client |
		self parseDirectoryListing: client getDirectory]
]

{ #category : #private }
MCFtpRepository >> clientDo: aBlock [
	| client |
	client := FTPClient openOnHostNamed: host.
	client loginUser: user password: password.
	directory isEmpty ifFalse: [client changeDirectoryTo: directory].
	^ [aBlock value: client] ensure: [client close]
]

{ #category : #required }
MCFtpRepository >> description [
	^ 'ftp://', user, '@', host, '/', directory
]

{ #category : #accessing }
MCFtpRepository >> directory: dirPath [
	directory := dirPath
]

{ #category : #accessing }
MCFtpRepository >> host: hostname [
	host := hostname
]

{ #category : #'protocol handling' }
MCFtpRepository >> parseDirectoryListing: aString [
	| stream files line tokens |
	stream := aString readStream.
	files := OrderedCollection new.
	[stream atEnd] whileFalse:
		[line := stream nextLine.
		tokens := line findTokens: ' '.
		tokens size > 2 ifTrue: [files add: tokens last asMCVersionName]].
	^ files
]

{ #category : #accessing }
MCFtpRepository >> password: passwordString [
	password := passwordString
]

{ #category : #required }
MCFtpRepository >> readStreamForFileNamed: aString do: aBlock [
	
	^ self clientDo:
		[:client | | stream |
		client binary.
		stream := RWBinaryOrTextStream on: String new.
		stream nextPutAll: (client getFileNamed: aString).
		aBlock value: stream reset]
]

{ #category : #accessing }
MCFtpRepository >> user: userString [
	user := userString
]

{ #category : #required }
MCFtpRepository >> writeStreamForFileNamed: aString replace: ignoreBoolean do: aBlock [
	| stream |
	stream := RWBinaryOrTextStream on: String new.
	aBlock value: stream.
	self clientDo:
		[:client |
		client binary.
		client putFileStreamContents: stream reset as: aString]
]
