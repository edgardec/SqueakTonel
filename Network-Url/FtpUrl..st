"
a reference to a file which may be downloaded by anonymous ftp .



TODO: use the username and password, if specified

"
Class {
	#name : #FtpUrl,
	#superclass : #HierarchicalUrl,
	#category : #'Network-Url'
}

{ #category : #downloading }
FtpUrl >> downloadUrl [
	"Returns a http download url for the location defined by this url."
	| ans |
	ans := WriteStream on: String new.
	ans nextPutAll: self schemeName.
	ans nextPutAll: '://'.
	ans nextPutAll: self authority.
	port ifNotNil: [ans nextPut: $:; print: port].
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

{ #category : #testing }
FtpUrl >> hasRemoteContents [
	"Return true if the receiver describes some remotely accessible content.
	Typically, this should only return if we could retrieve the contents
	on an arbitrary place in the outside world using a standard browser.
	In other words: If you can get to it from the next Internet Cafe, 
	return true, else return false."
	^true
]

{ #category : #access }
FtpUrl >> pathString [
	self path isEmpty ifTrue: [ ^'/' copy ].

	^String streamContents: [ :s |
		self path do: [ :p |
		 	s nextPut: $/.
			s nextPutAll: p ] ]
]

{ #category : #downloading }
FtpUrl >> retrieveContents [
	"currently assumes directories end in /, and things that don't end in / are files.  Also, doesn't handle errors real well...."
	| server contents pathString listing auth idx fileName serverName userName password |
	pathString := self pathString.
	pathString := pathString copyFrom: 2 to: pathString size. "remove the leading /"
	pathString last = $/ ifTrue:["directory?!"
		fileName := nil.
	] ifFalse:[
		fileName := pathString copyFrom: (pathString lastIndexOf: $/)+1 to: pathString size.
		pathString := pathString copyFrom: 1 to: (pathString lastIndexOf: $/) - 1.
	].
	auth := self authority.
	idx := auth indexOf: $@.
	idx > 0 ifTrue:[
		serverName := (auth copyFrom: idx+1 to: auth size).
		userName := (auth copyFrom: 1 to: idx-1).
		password := nil.
	] ifFalse:[
		serverName := auth.
		userName := 'anonymous'.
		password := 'SqueakUser'.
	].
	server := ServerDirectory servers 
		detect:[:s| s isTypeFTP and:[s server asLowercase = serverName asLowercase]]
		ifNone:[nil].
	server ifNil:[
		server := ServerDirectory new.
		server server: serverName.
	] ifNotNil:[server := server copy reset].
	server user: userName.
	password ifNotNil:[server password: password].
	server directory: pathString.

	fileName == nil ifFalse:[
		"a file"
		contents := (server getFileNamed: fileName).
		server sleep.
		^MIMEDocument contentType: (MIMEDocument guessTypeFromName: self path last) content: contents].

	"a directory?"
	listing := String streamContents: [ :stream |
		stream nextPutAll: '<title>', self pathString, '</title>'; cr.
		stream nextPutAll: '<h1>Listing for ', self pathString, '</h1>'; cr.
		stream nextPutAll: '<ul>'; cr.
		server entries do: [ :entry |
			stream nextPutAll: '<li>';
				nextPutAll: '<a href="', entry name encodeForHTTP.
			entry isDirectory ifTrue: [ stream nextPut: $/ ].
			stream nextPutAll: '">';
				nextPutAll: entry name;
				nextPutAll: '</a>';
				cr ] ].
	server sleep.
	^MIMEDocument contentType: 'text/html' content: listing
]
