"
Holds all the information needed to read or write on a directory of an internet server.  I am used for FTP and HTTP (and STMP?  NNTP?).  The password policy is: unless it is a public password (like annomyous), clear all passwords before any snapshot.  There is a way to store passwords on the disk.

server 		'www.disney.com'  or '123.34.56.08' or the ServerDirectory above me 
			(if I am a subdirectory sharing the info in a master directory)
directory 	'ftp/pubs/'  name of my directory within the server or superdirectory.
			(for file://, directory is converted to local delimiters.)
type 		#ftp	what you can do in this directory
user 		'Jones45'
password 	an instance of Password.  
group 		an Association ('group name' -> an array of ServerDirectorys)
			If this first one is down, try the next one.  Store on all of them.  I am in the list.
moniker 	'Main Squeak Directory'  Description of this directory.
altURL		When a FTP server holds some web pages, the altURL of those pages is often
			different from the FTP directory.  Put the altURL here.  If the directory is 
			'public_html/Squeak/', the altURL might be 'www.webPage.com/~kaehler2/
			Squeak/'.
urlObject	An instance of a subclass of Url.  It is very good at parsing complex urls.
			Relative references.  file:// uses this.  Use this in the future instead of 
			server and directory inst vars.
socket		nil or an FTPSocket.  Only non-nil if the connection is being kept open
			for multiple stores or retrievals.  
loaderUrl	a partial url that is ised to invoke squeak in a browser and load a project.

A normal call on some command like (aServer getFileNamed: 'foo') does not set 'socket'.  Socket being nil tells it to close the connection and destroy the socket after this one transcation.  If the caller stores into 'socket', then the same command does NOT close the 
connection.  
	Call 'openKeepFTP' or 'openGroup' to store into socket and keep the connection open.  It is up to the user to call 'quit' or 'closeGroup' later.

DD openKeepFTP.
Transcript cr; show: ((DD getFileNamed: '1198misc-tkKG.cs') next: 100).
Transcript cr; show: ((DD getFileNamed: '1192multFinder-tkKF.cs') next: 100).
DD quit.
"
Class {
	#name : #ServerDirectory,
	#superclass : #Object,
	#instVars : [
		'server',
		'directory',
		'type',
		'user',
		'passwordHolder',
		'group',
		'moniker',
		'altURL',
		'urlObject',
		'client',
		'loaderUrl',
		'eToyUserListUrl',
		'eToyUserList',
		'keepAlive',
		'encodingName'
	],
	#classVars : [
		'LocalEToyBaseFolderSpecs',
		'LocalEToyUserListUrls',
		'LocalProjectDirectories',
		'Servers'
	],
	#category : #'Network-RemoteDirectory'
}

{ #category : #'available servers' }
ServerDirectory class >> addLocalProjectDirectory: aFileDirectory [
	self localProjectDirectories add: aFileDirectory

]

{ #category : #'available servers' }
ServerDirectory class >> addServer: server named: nameString [
	self servers at: nameString put: server
]

{ #category : #'class initialization' }
ServerDirectory class >> cleanUp: aggressive [
	"Clean out servers when doing aggressive cleanup"

	aggressive ifTrue:[self  resetServers].
]

{ #category : #misc }
ServerDirectory class >> defaultStemUrl [
	"For writing on an FTP directory.  Users should insert their own server url here."
"ftp://jumbo.rd.wdi.disney.com/raid1/people/dani/Books/Grp/Grp"
"	ServerDirectory defaultStemUrl	"

| rand dir |
rand := String new: 4.
1 to: rand size do: [:ii |
	rand at: ii put: ('bdfghklmnpqrstvwz' at: 17 atRandom)].
dir := self serverNamed: 'DaniOnJumbo'.
^ 'ftp://', dir server, dir slashDirectory, '/BK', rand
]

{ #category : #'server prefs' }
ServerDirectory class >> determineLocalServerDirectory: directoryName [
	"This is part of a workaround for Mac file name oddities regarding relative file names.
	The real fix should be in fullNameFor: but that seems to break other parts of the system."

	| dirName |
	dirName := directoryName.
	(Smalltalk platformName = 'Mac OS'
		and: [directoryName beginsWith: ':'])
			ifTrue: [
				dirName := (FileDirectory default pathName endsWith: directoryName)
					ifTrue: [FileDirectory default pathName]
					ifFalse: [(FileDirectory default pathName , directoryName) replaceAll: '::' with: ':']].
	^FileDirectory default directoryNamed: dirName
]

{ #category : #'server prefs' }
ServerDirectory class >> fetchExternalSettingsIn: aDirectory [
	"Scan for server configuration files"
	"ServerDirectory fetchExternalSettingsIn: (FileDirectory default directoryNamed: 'prefs')"

	| serverConfDir |
	(aDirectory directoryExists: self serverConfDirectoryName)
		ifFalse: [^self].
	self resetLocalProjectDirectories.
	serverConfDir := aDirectory directoryNamed: self serverConfDirectoryName.
	serverConfDir fileNames do: [:fileName | | stream |
		stream := serverConfDir readOnlyFileNamed: fileName.
		stream
			ifNotNil: [
				[self parseServerEntryFrom: stream] ifError: [:err :rcvr | ].
				stream close]]
]

{ #category : #'class initialization' }
ServerDirectory class >> initialize [
	"ServerDirectory initialize"
	"ServerDirectory resetLocalProjectDirectories.
	Servers := Dictionary new."

	ExternalSettings registerClient: self
]

{ #category : #'available servers' }
ServerDirectory class >> localProjectDirectories [
	LocalProjectDirectories ifNil: [LocalProjectDirectories := OrderedCollection new].
	^LocalProjectDirectories
]

{ #category : #'available servers' }
ServerDirectory class >> nameForServer: aServer [
	^self servers keyAtValue: aServer
]

{ #category : #misc }
ServerDirectory class >> newFrom: aSimilarObject [
	"Must copy the urlObject, so they won't be shared"

	| inst |
	inst := super newFrom: aSimilarObject.
	inst urlObject: aSimilarObject urlObject copy.
	^ inst
]

{ #category : #misc }
ServerDirectory class >> on: pathString [

	^self new on: pathString
]

{ #category : #misc }
ServerDirectory class >> parseFTPEntry: ftpEntry [
	| tokens longy dateInSeconds thisYear thisMonth |
	thisYear := Date today year.
	thisMonth := Date today monthIndex.
	tokens := ftpEntry findTokens: ' '.
	tokens size = 8 ifTrue:
		[((tokens at: 6) size ~= 3 and: [(tokens at: 5) size = 3]) ifTrue:
			["Fix for case that group is blank (relies on month being 3 chars)"
			tokens := tokens copyReplaceFrom: 4 to: 3 with: {'blank'}]].
	tokens size >= 9 ifFalse:[^nil].

	((tokens at: 6) size ~= 3 and: [(tokens at: 5) size = 3]) ifTrue:
		["Fix for case that group is blank (relies on month being 3 chars)"
		tokens := tokens copyReplaceFrom: 4 to: 3 with: {'blank'}].

	tokens size > 9 ifTrue:
		[ "cmm:  this approach fails for filenames containing two spaces in a row."
		longy := tokens at: 9.
		10 to: tokens size do: [:i | longy := longy , ' ' , (tokens at: i)].
		tokens at: 9 put: longy].
	dateInSeconds := self
		secondsForDay: (tokens at: 7) 
		month: (tokens at: 6) 
		yearOrTime: (tokens at: 8) 
		thisMonth: thisMonth 
		thisYear: thisYear.
	^DirectoryEntry name: (tokens at: 9)  "file name"
		creationTime: dateInSeconds "creation date"
		modificationTime: dateInSeconds "modification time"
		isDirectory: ((tokens first first) = $d or: [tokens first first =$l]) "is-a-directory flag"
		fileSize: tokens fifth asNumber "file size"

]

{ #category : #'server prefs' }
ServerDirectory class >> parseServerEntryFrom: stream [
	
	| server type directory entries serverName |

	entries := ExternalSettings parseServerEntryArgsFrom: stream.

	serverName := entries at: 'name' ifAbsent: [^nil].
	directory := entries at: 'directory' ifAbsent: [^nil].
	type := entries at: 'type' ifAbsent: [^nil].
	type = 'file'
		ifTrue: [
			server := self determineLocalServerDirectory: directory.
			entries at: 'userListUrl' ifPresent:[:value | server eToyUserListUrl: value].
			entries at: 'baseFolderSpec' ifPresent:[:value | server eToyBaseFolderSpec: value].
			^self addLocalProjectDirectory: server].
	type = 'bss'
		ifTrue: [server := SuperSwikiServer new type: #http].
	type = 'http'
		ifTrue: [server := HTTPServerDirectory new type: #ftp].
	type = 'ftp'
		ifTrue: [server := ServerDirectory new type: #ftp].

	server directory: directory.
	entries at: 'server' ifPresent: [:value | server server: value].
	entries at: 'user' ifPresent: [:value | server user: value].
	entries at: 'group' ifPresent: [:value | server groupName: value].
	entries at: 'passwdseq' ifPresent: [:value | server passwordSequence: value asNumber].
	entries at: 'url' ifPresent: [:value | server altUrl: value].
	entries at: 'loaderUrl' ifPresent: [:value | server loaderUrl: value].
	entries at: 'acceptsUploads' ifPresent: [:value | server acceptsUploads: value asLowercase = 'true'].
	entries at: 'userListUrl' ifPresent:[:value | server eToyUserListUrl: value].
	entries at: 'encodingName' ifPresent:[:value | server encodingName: value].
	ServerDirectory addServer: server named: serverName.

]

{ #category : #'school support' }
ServerDirectory class >> projectDefaultDirectory [
	^Preferences eToyLoginEnabled
		ifTrue: [
			(ServerDirectory localProjectDirectories, ServerDirectory servers values)
						detect:[:any| any hasEToyUserList]
						ifNone:[FileDirectory default]]
		ifFalse: [FileDirectory default]
]

{ #category : #'available servers' }
ServerDirectory class >> projectServers [
	"ServerDirectory projectServers"

	| projectServers |
	projectServers := OrderedCollection new.
	self serverNames do: [ :n | | projectServer | 
		projectServer := ServerDirectory serverNamed: n.
		(projectServer isProjectSwiki and: [projectServer isSearchable])
			ifTrue: [projectServers add: projectServer]].
	^projectServers
]

{ #category : #'server prefs' }
ServerDirectory class >> releaseExternalSettings [
	"Release for server configurations"
	"ServerDirectory releaseExternalSettings"

	(Preferences valueOfFlag: #externalServerDefsOnly)
		ifTrue: [
			self resetLocalProjectDirectories.
			Servers := Dictionary new]
]

{ #category : #'available servers' }
ServerDirectory class >> removeServerNamed: nameString [
	self
		removeServerNamed: nameString
		ifAbsent: [self error: 'Server "' , nameString asString , '" not found']
]

{ #category : #'available servers' }
ServerDirectory class >> removeServerNamed: nameString ifAbsent: aBlock [

	self servers removeKey: nameString ifAbsent: aBlock
]

{ #category : #'available servers' }
ServerDirectory class >> resetLocalProjectDirectories [
	LocalProjectDirectories := nil.
	LocalEToyUserListUrls := nil.
	LocalEToyBaseFolderSpecs := nil.

]

{ #category : #'available servers' }
ServerDirectory class >> resetServers [
	Servers := nil
]

{ #category : #misc }
ServerDirectory class >> secondsForDay: dayToken month: monthToken yearOrTime: ytToken 
thisMonth: thisMonth thisYear: thisYear [

	| ftpDay ftpMonth pickAYear jDateToday trialJulianDate |

	ftpDay := dayToken asNumber.
	ftpMonth := Date indexOfMonth: monthToken.
	(ytToken includes: $:) ifFalse: [
		^(Date newDay: ftpDay month: ftpMonth year: ytToken asNumber) asSeconds
	].
	jDateToday := Date today dayOfYear.
	trialJulianDate := (Date newDay: ftpDay month: ftpMonth year: thisYear) dayOfYear.
	
	"Date has no year if within six months (do we need to check the day, too?)"

	"Well it appear to be pickier than that... it isn't just 6 months or 6 months and the day of the month, put perhaps the julian date AND the time as well. I don't know what the precise standard is, but this seems to produce better results"

	pickAYear := (jDateToday - trialJulianDate) > 182 ifTrue: [
		thisYear + 1	"his clock could be ahead of ours??"
	] ifFalse: [
		pickAYear := (trialJulianDate - jDateToday) > 182 ifTrue: [
			thisYear - 1
		] ifFalse: [
			thisYear
		].
	].
	^(Date newDay: ftpDay month: ftpMonth year: pickAYear) asSeconds +
		(Time readFrom: (ReadStream on: ytToken)) asSeconds


]

{ #category : #'server prefs' }
ServerDirectory class >> serverConfDirectoryName [
	^'knownServers'
]

{ #category : #'available servers' }
ServerDirectory class >> serverForURL: aURLString [
	| serversForURL server urlPath serverPath relPath |
	serversForURL := self servers values select: [:each |
		(aURLString beginsWith: each downloadUrl)
		or: [(aURLString beginsWith: each realUrl)
		or: [aURLString , '/' beginsWith: each downloadUrl]]].
	serversForURL isEmpty
		ifTrue: [^nil].
	server := serversForURL first.
	urlPath := aURLString asUrl path.
	(urlPath isEmpty not
		and: [urlPath last isEmpty])
		ifTrue: [urlPath removeLast].
	serverPath := server downloadUrl asUrl path.
	(serverPath isEmpty not
		and: [serverPath last isEmpty])
		ifTrue: [serverPath removeLast].
	urlPath size < serverPath size
		ifTrue: [^nil].
	relPath := String new.
	serverPath size +1 to: urlPath size do: [:i | relPath := relPath , '/' , (urlPath at: i)].
	^relPath isEmpty
		ifTrue: [server]
		ifFalse: [server directoryNamed: (relPath copyFrom: 2 to: relPath size)]
]

{ #category : #'available servers' }
ServerDirectory class >> serverNamed: nameString [
	^self serverNamed: nameString ifAbsent: [self error: 'Server name not found']
]

{ #category : #'available servers' }
ServerDirectory class >> serverNamed: nameString ifAbsent: aBlock [

	^self servers at: nameString asString ifAbsent: aBlock
]

{ #category : #'available servers' }
ServerDirectory class >> serverNames [
	^self servers keys asArray sort
]

{ #category : #'available servers' }
ServerDirectory class >> servers [
	Servers ifNil: [Servers := Dictionary new].
	^Servers
]

{ #category : #'server prefs' }
ServerDirectory class >> storeCurrentServersIn: aDirectory [

	self servers do: [:each |
		| file |
		file := aDirectory fileNamed: (ServerDirectory nameForServer: each).
		each storeServerEntryOn: file.
		file close].
	self localProjectDirectories do: [:each |
		| file |
		file := aDirectory fileNamed: each localName.
		each storeServerEntryOn: file.
		file close].

]

{ #category : #'server prefs' }
ServerDirectory class >> transferServerDefinitionsToExternal [
	"ServerDirectory transferServerDefinitionsToExternal"

	| serverDir |
	serverDir := ExternalSettings preferenceDirectory directoryNamed: self serverConfDirectoryName.
	serverDir assureExistence.
	ServerDirectory storeCurrentServersIn: serverDir
]

{ #category : #testing }
ServerDirectory >> acceptsUploads [
	^true
]

{ #category : #accessing }
ServerDirectory >> acceptsUploads: aBoolean [
	"Do nothing yet"
]

{ #category : #accessing }
ServerDirectory >> altUrl [
	"When a ftp server also has http access, use this to store the http url"
	^ altURL
]

{ #category : #accessing }
ServerDirectory >> altUrl: aString [
	altURL := aString
]

{ #category : #'file directory' }
ServerDirectory >> asServerFileNamed: aName [

	| rFile |
	rFile := self as: ServerFile.
	(aName includes: self pathNameDelimiter)
		ifTrue: [rFile fullPath: aName]
			"sets server, directory(path), fileName.  If relative, merge with self."
		ifFalse: [rFile fileName: aName].	"JUST a single NAME, already have the rest"
			"Mac files that include / in name, must encode it as %2F "
	^rFile

]

{ #category : #'file directory' }
ServerDirectory >> assureExistence [
	"Make sure the current directory exists. If necessary, create all parts inbetween"
	
	self exists ifFalse: [
		self isRoot ifFalse: [
			self containingDirectory assureExistenceOfPath: self localName]]
]

{ #category : #'file directory' }
ServerDirectory >> assureExistenceOfPath: localPath [
	"Make sure the local directory exists. If necessary, create all parts inbetween"

	localPath = (String with: self pathNameDelimiter) ifTrue: [^self].
	self assureExistence.
	(self localPathExists: localPath) ifFalse: [
		self createDirectory: localPath].
]

{ #category : #accessing }
ServerDirectory >> bareDirectory [

	^ directory first == $/ 
		ifTrue: [directory copyFrom: 2 to: directory size]
		ifFalse: [directory]
]

{ #category : #'file directory' }
ServerDirectory >> containingDirectory [

	self splitName: directory to: [:parentPath :localName |
		^self copy directory: parentPath]
]

{ #category : #'file directory' }
ServerDirectory >> createDirectory: localName [
	"Create a new sub directory within the current one"

	self isTypeFile ifTrue: [
		^FileDirectory createDirectory: localName
	].

	client := self openFTPClient.
	self switchDirectory.
	[client makeDirectory: localName]
		ensure: [self quit].

]

{ #category : #'file directory' }
ServerDirectory >> deleteDirectory: localName [
	"Delete the sub directory within the current one.  Call needs to ask user to confirm."

	self isTypeFile ifTrue: [
		^FileDirectory deleteFileNamed: localName
	].
		"Is this the right command???"

	client := self openFTPClient.
	[ self switchDirectory.
	client deleteDirectory: localName]
		ensure: [self quit].

]

{ #category : #'file directory' }
ServerDirectory >> deleteFileNamed: fullName [
	"Detete a remote file.  fullName is directory path, and does include name of the server.  Or it can just be a fileName."
	| file |
	file := self asServerFileNamed: fullName.
	file isTypeFile ifTrue: [
		^ (FileDirectory forFileName: (file fileNameRelativeTo: self)) 
			deleteFileNamed: file fileName
	].
	
	client := self openFTPClient.
	[ self switchDirectory.
	client deleteFileNamed: fullName]
		ensure: [self quit].

]

{ #category : #'file directory' }
ServerDirectory >> deleteLocalFiles [
	"Delete the local files in this directory."
	self switchDirectory.
	self fileNames do:[:fn| self deleteFileNamed: fn ifAbsent: [(CannotDeleteFileException new
			messageText: 'Could not delete the old version of file ' , (self fullNameFor: fn)) signal]]
]

{ #category : #accessing }
ServerDirectory >> directory [
	"String of part of url that is the directory. Has slashes as separators"

	urlObject ifNotNil: [^ urlObject pathDirString].
	^ directory
]

{ #category : #accessing }
ServerDirectory >> directory: anObject [
	directory := anObject
]

{ #category : #'file directory' }
ServerDirectory >> directoryNamed: localFileName [ 
	"Return a copy of me pointing at this directory below me"
	| new newPath newAltUrl |
	new := self copy.
	urlObject
		ifNotNil: [new urlObject path: new urlObject path copy.
			new urlObject path removeLast; addLast: localFileName; addLast: ''.
			^ new].
	"sbw.  When working from an FTP server, the first time we access
	a subdirectory the <directory> variable is empty.  In that case we
	cannot begin with a leading path delimiter since that leads us to
	the wrong place."
	newPath := directory isEmpty
				ifTrue: [localFileName]
				ifFalse: [directory , self pathNameDelimiter asString , localFileName].
	self altUrl ifNotNil: [
		newAltUrl := self altUrl, self pathNameDelimiter asString , localFileName].
	new directory: newPath; altUrl: newAltUrl.
	^ new
]

{ #category : #'file directory' }
ServerDirectory >> directoryNames [
	"Return a collection of names for the subdirectories of this directory."
	"(ServerDirectory serverNamed: 'UIUCArchive') directoryNames"

	^ (self entries select: [:entry | entry isDirectory and: [entry name ~= '.' and:[entry name ~= '..']]])
		collect: [:entry | entry name]

]

{ #category : #accessing }
ServerDirectory >> directoryObject [

	^self
]

{ #category : #squeaklets }
ServerDirectory >> directoryWrapperClass [

	^FileDirectoryWrapper
]

{ #category : #accessing }
ServerDirectory >> downloadUrl [
	"The url under which files will be accessible."
	^(self altUrl
		ifNil: [self realUrl]
		ifNotNil: [self altUrl]) , '/'
]

{ #category : #accessing }
ServerDirectory >> encodingName [
	^encodingName.
]

{ #category : #accessing }
ServerDirectory >> encodingName: aName [
	encodingName := aName
]

{ #category : #'file directory' }
ServerDirectory >> entries [ 
	"Return a collection of directory entries for the files and directories in this directory. Each entry is a five-element array: (<name> <creationTime> <modificationTime> <dirFlag> <fileSize>)."
	| dir ftpEntries |
	"We start with ftp directory entries of the form...
d---------   1 owner    group               0 Apr 27 22:01 blasttest
----------   1 owner    group           93812 Jul 21  1997 COMMAND.COM
    1        2   3           4                 5    6  7    8       9   -- token index"
	self isTypeFile ifTrue: [
		urlObject isAbsolute ifFalse: [urlObject default].
		^ (FileDirectory on: urlObject pathForDirectory) entries
	].

	dir := self getDirectory.
	(dir respondsTo: #contentsOfEntireFile) ifFalse: [^ #()].
	ftpEntries := dir contentsOfEntireFile lines.
	^ ftpEntries 
		collect:[:ftpEntry | self class parseFTPEntry: ftpEntry]
		thenSelect: [:entry | entry notNil]
]

{ #category : #'file directory' }
ServerDirectory >> entryAt: fileName [ 
	"find the entry with local name fileName"
	^ self 
		entryAt: fileName
		ifAbsent: [ self error: 'file not in directory: ' , fileName ]
]

{ #category : #'file directory' }
ServerDirectory >> entryAt: fileName ifAbsent: aBlock [ 
	"Find the entry with local name fileName and answer it.
	If not found, answer the result of evaluating aBlock."
	^ self entries 
		detect: [ : entry | entry name = fileName ]
		ifNone: aBlock
]

{ #category : #'file directory' }
ServerDirectory >> exists [
	"It is difficult to tell if a directory exists.  This is ugly, but it works for writable directories.  http: will fall back on ftp for this"

	| probe |
	self isTypeFile ifTrue: [
		self entries size > 0 ifTrue: [^ true].
		probe := self newFileNamed: 'withNoName23'. 
		probe ifNotNil: [
			probe close.
			probe directory deleteFileNamed: probe localName].
		^probe notNil].
	^
	[client := self openFTPClient.
	[self switchDirectory]
		ensure: [self quit].
	true]
		on: Error
		do: [:ex | false]
]

{ #category : #'file directory' }
ServerDirectory >> fileAndDirectoryNames [
	"FileDirectory default fileAndDirectoryNames"

	^ self entries collect: [:entry | entry name]

]

{ #category : #'file directory' }
ServerDirectory >> fileEntries [
	"Return a collection of names for the files (but not directories) in this directory."
	"(ServerDirectory serverNamed: 'UIUCArchive') fileEntries"

	^ self entries select: [:entry | entry isDirectory not]
]

{ #category : #'up\/download' }
ServerDirectory >> fileExists: fileName [
	"Does the file exist on this server directory?  fileName must be simple with no / or references to other directories."

	| stream |
	self isTypeFile ifTrue: [^ self fileNames includes: fileName].
	self isTypeHTTP ifTrue: [
		stream := self readOnlyFileNamed: fileName.
		^stream contents notEmpty].
	"ftp"
	^ self entries anySatisfy: [:entry | entry name = fileName]
]

{ #category : #'file directory' }
ServerDirectory >> fileNamed: fullName [
	"Create a RemoteFileStream for writing.  If the file exists, do not complain.  fullName is directory path, and does include name of the server.  Or it can just be a fileName.  Only write the data upon close."

	| file remoteStrm |
	file := self asServerFileNamed: fullName.
	file readWrite.
	file isTypeFile ifTrue: [
		^ FileStream fileNamed: (file fileNameRelativeTo: self)
	].

	remoteStrm := RemoteFileStream on: (String new: 2000).
	remoteStrm remoteFile: file.
	^ remoteStrm	"no actual writing till close"

]

{ #category : #'file directory' }
ServerDirectory >> fileNames [
	"Return a collection of names for the files (but not directories) in this directory."
	"(ServerDirectory serverNamed: 'UIUCArchive') fileNames"

	^ self entries select: [:entry | entry isDirectory not]
		thenCollect: [:entry | entry name]

]

{ #category : #initialize }
ServerDirectory >> fromUser [
	"Ask the user for all data on a new server.  Save it in a named server."  
]

{ #category : #accessing }
ServerDirectory >> fullName [
	^server
]

{ #category : #'file directory' }
ServerDirectory >> fullNameFor: aFileName [
	"Convention: 
	If it is an absolute path, directory stored with a leading slash, and url has no user@.
	If relative path, directory stored with no leading slash, and url begins user@.
	Should we include ftp:// on the front?"

	urlObject ifNotNil: [^ urlObject pathString, aFileName].
	(aFileName includes: self pathNameDelimiter)
		ifTrue: [^ aFileName].
	self isTypeHTTP ifTrue: [
		^ self downloadUrl, aFileName].
	directory isEmpty ifTrue: [^ server, 
		self pathNameDelimiter asString, aFileName].
	^ (directory first == $/ ifTrue: [''] ifFalse: [user,'@']), 
		server, self slashDirectory, 
		self pathNameDelimiter asString, aFileName
]

{ #category : #accessing }
ServerDirectory >> fullPath: serverAndDirectory [
	"Parse and save a full path.  Convention:  if ftp://user@server/dir, then dir is relative to user's directory.  dir has no slash at beginning.  If ftp://server/dir, then dir is absolute to top of machine, give dir a slash at the beginning."

	| start bare sz userAndServer both slash score best |
	bare := serverAndDirectory.
	sz := serverAndDirectory size.
	bare size > 0 ifTrue: [ 
		start := (bare copyFrom: 1 to: (8 min: sz)) asLowercase.
		((start beginsWith: 'ftp:') or: [start beginsWith: 'nil:']) "fix bad urls"
			ifTrue: [type := #ftp.
				bare := bare copyFrom: (7 min: sz) to: bare size].
		(start beginsWith: 'http:') 
			ifTrue: [type := #http.
				bare := bare copyFrom: (8 min: sz) to: serverAndDirectory size].
		((start beginsWith: 'file:') or: [type == #file])
			ifTrue: [type := #file.
				urlObject := FileUrl absoluteFromText: serverAndDirectory.
				^ self]].
	userAndServer := bare copyUpTo: self pathNameDelimiter.
	both := userAndServer findTokens: '@'.
	slash := both size.	"absolute = 1, relative = 2"
	server := both last.
	both size > 1 ifTrue: [user := both at: 1].
	bare size > (userAndServer size + 1) 
		ifTrue: [directory := bare copyFrom: userAndServer size + slash to: bare size]
		ifFalse: [directory := ''].

	"If this server is already known, copy in its userName and password"
	type == #ftp ifFalse: [^ self].
	score := -1.
	ServerDirectory serverNames do: [:name | | match sd |
		sd := ServerDirectory serverNamed: name.
		server = sd server ifTrue: [
			match := directory asLowercase charactersExactlyMatching: sd directory asLowercase.
			match > score ifTrue: [score := match.  best := sd]]].
	best ifNil: [
		self fromUser
	] ifNotNil: [
		user := best user.
		altURL := best altUrl.
		loaderUrl := best loaderUrl.
		self password: best password
	].

]

{ #category : #'up\/download' }
ServerDirectory >> getDirectory [
	"Return a stream with a listing of the current server directory.  (Later -- Use a proxy server if one has been registered.)"

	| listing |
	client := self openFTPClient.
	listing := 
		[ self switchDirectory.
		client getDirectory]
			ensure: [self quit].
	^ReadStream on: listing
]

{ #category : #'up\/download' }
ServerDirectory >> getFileList [
	"Return a stream with a list of files in the current server directory.  (Later -- Use a proxy server if one has been registered.)"

	| listing |
	client := self openFTPClient.
	listing := [client getFileList]
		ensure: [self quit].
	^ReadStream on: listing
]

{ #category : #'up\/download' }
ServerDirectory >> getFileNamed: fileNameOnServer [
	"Just FTP a file from a server.  Return contents.
	(Later -- Use a proxy server if one has been registered.)"

	| result |
	client := self openFTPClient.
	result := [client getFileNamed: fileNameOnServer]
		ensure: [self quit].
	^result
]

{ #category : #'up\/download' }
ServerDirectory >> getFileNamed: fileNameOnServer into: dataStream [
	
	^self getFileNamed: fileNameOnServer into: dataStream 
		httpRequest: 'Pragma: no-cache', String crlf
]

{ #category : #'up\/download' }
ServerDirectory >> getFileNamed: fileNameOnServer into: dataStream httpRequest: requestString [
	"Just FTP a file from a server.  Return a stream.  (Later -- Use a proxy server if one has been registered.)"

	| resp |
	self isTypeFile ifTrue: [
		dataStream nextPutAll: 
			(resp := FileStream oldFileNamed: server,(self serverDelimiter asString), 
				self bareDirectory, (self serverDelimiter asString),
				fileNameOnServer) contentsOfEntireFile.
		dataStream dataIsValid.
		^ resp].
	self isTypeHTTP ifTrue: [
		resp := HTTPSocket httpGet: (self fullNameFor: fileNameOnServer) 
				args: nil accept: 'application/octet-stream' request: requestString.
		resp isString ifTrue: [^ dataStream].	"error, no data"
		dataStream copyFrom: resp.
		dataStream dataIsValid.
		^ dataStream].

	client := self openFTPClient.	"Open passive.  Do everything up to RETR or STOR"
	[self switchDirectory.
	client getFileNamed: fileNameOnServer into: dataStream]
		ensure: [self quit].

	dataStream dataIsValid.

]

{ #category : #'file directory' }
ServerDirectory >> getOnly: nnn from: fileNameOnServer [
	| file ff resp |
	"Use FTP to just capture the first nnn characters of the file.  Break the connection after that.  Goes faster for long files.  Return the contents, not a stream."

	self isTypeFile ifTrue: [
		file := self as: ServerFile.
		file fileName: fileNameOnServer.
		ff := FileStream oldFileOrNoneNamed: (file fileNameRelativeTo: self).
		^ ff next: nnn].
	self isTypeHTTP ifTrue: [
		resp := HTTPSocket httpGet: (self fullNameFor: fileNameOnServer) 
				accept: 'application/octet-stream'.
			"For now, get the whole file.  This branch not used often."
		^ resp truncateTo: nnn].
	
	^ self getOnlyBuffer: (String new: nnn) from: fileNameOnServer
]

{ #category : #'up\/download' }
ServerDirectory >> getOnlyBuffer: buffer from: fileNameOnServer [
	"Open ftp, fill the buffer, and close the connection.  Only first part of a very long file."

	| dataStream |
	client := self openFTPClient.
	dataStream := WriteStream on: buffer.
	[client getPartial: buffer size fileNamed: fileNameOnServer into: dataStream]
		ensure: [self quit].
	^buffer
]

{ #category : #'server groups' }
ServerDirectory >> groupName [

	^group
		ifNil: [self moniker]
		ifNotNil: [
			(group isString)
				ifTrue: [group]
				ifFalse: [group key]]
]

{ #category : #'server groups' }
ServerDirectory >> groupName: groupName [
	group := groupName
]

{ #category : #testing }
ServerDirectory >> hasFiles [
	"Return true if we find an entry that is a file, false otherwise"
	"(ServerDirectory serverNamed: 'UIUCArchive') hasFiles"

	^ self entries anySatisfy: [:entry | entry isDirectory not]
]

{ #category : #testing }
ServerDirectory >> hasSubDirectories [
	"Return true if we find an entry that is a directory, false otherwise"
	"(ServerDirectory serverNamed: 'UIUCArchive') hasSubDirectories"

	^ self entries anySatisfy: [:entry | entry isDirectory]
]

{ #category : #'file directory' }
ServerDirectory >> includesKey: localName [
	"Answer true if this directory includes a file or directory of the given name. Note that the name should be a local file name, in contrast with fileExists:, which takes either local or full-qualified file names."

	^ self fileAndDirectoryNames includes: localName

]

{ #category : #testing }
ServerDirectory >> isProjectSwiki [
	^false
]

{ #category : #testing }
ServerDirectory >> isRemoteDirectory [
	"answer whatever the receiver is a remote directory"
	^ true
]

{ #category : #testing }
ServerDirectory >> isRoot [
	^ directory = '/'
]

{ #category : #testing }
ServerDirectory >> isSearchable [
	^false
]

{ #category : #accessing }
ServerDirectory >> isTypeFTP [

	^self typeWithDefault == #ftp
]

{ #category : #accessing }
ServerDirectory >> isTypeFile [

	^self typeWithDefault == #file
]

{ #category : #accessing }
ServerDirectory >> isTypeHTTP [

	^self typeWithDefault == #http
]

{ #category : #testing }
ServerDirectory >> keepAlive [
	keepAlive ifNil: [keepAlive := false].
	^keepAlive
]

{ #category : #accessing }
ServerDirectory >> keepAlive: aBoolean [
	keepAlive := aBoolean
]

{ #category : #accessing }
ServerDirectory >> loaderUrl [

	^loaderUrl
]

{ #category : #accessing }
ServerDirectory >> loaderUrl: aString [

	loaderUrl := aString
]

{ #category : #'file directory' }
ServerDirectory >> localName [

	^ServerDirectory servers keyAtIdentityValue: self ifAbsent:[
		directory isEmpty ifTrue: [self error: 'no directory'].
		self localNameFor: directory]
]

{ #category : #'file directory' }
ServerDirectory >> localNameFor: fullName [
	"Return the local part the given name."

	self
		splitName: fullName
		to: [:dirPath :localName | ^ localName]

]

{ #category : #'file directory' }
ServerDirectory >> localPathExists: localPath [

	^self directoryNames includes: localPath
]

{ #category : #'file directory' }
ServerDirectory >> matchingEntries: criteria [
	"Ignore the filter criteria for now"
	^self entries
]

{ #category : #accessing }
ServerDirectory >> moniker [
	"a plain language name for this directory"

	moniker ifNotNil: [^ moniker].
	directory ifNotNil: [^ self server].
	urlObject ifNotNil: [^ urlObject asString].
	^ ''
]

{ #category : #accessing }
ServerDirectory >> moniker: nickName [
	"a plain language name for this directory"

	moniker := nickName
]

{ #category : #squeaklets }
ServerDirectory >> moveAllButYoungest: young in: versions to: repository [
	| all |
	"Specialized to files with names of the form 'aName_vvv.ext'.  Where vvv is a mime-encoded base 64 version number.  Versions is an array of file names tokenized into three parts (aName vvv ext).  Move the files by renaming them on the server."

	versions size <= young ifTrue: [^ self].
	all := (versions as: Array)
		replace: [ :each | { each. Base64MimeConverter decodeInteger: each second unescapePercents } ];
		sort: [ :a :b | a second < b second ];
		replace: [ :each | each first ].
	
	all from: 1 to: all size - young do: [:vv | | fName |
		fName := vv first, '_', vv second, '.', vv third.
		repository rename: self fullName,fName toBe: fName].

]

{ #category : #'file directory' }
ServerDirectory >> newFileNamed: fullName [
	"Create a RemoteFileStream.  If the file exists, and complain.  fullName is directory path, and does include name of the server.  Or it can just be a fileName.  Only write the data upon close."

	| file remoteStrm selection |

	file := self asServerFileNamed: fullName.
	file readWrite.
	file isTypeFile ifTrue: [
		^ FileStream newFileNamed: (file fileNameRelativeTo: self)].
	file exists 
		ifTrue: [
			selection := UIManager default 
				chooseFrom: #('overwrite that file' 'choose another name' 'cancel')
				title: (file fullNameFor: file fileName) , '
already exists.']
		ifFalse: [selection := 1].

	selection = 1 ifTrue:
		[remoteStrm := RemoteFileStream on: (String new: 2000).
		remoteStrm remoteFile: file.
		remoteStrm dataIsValid.	"empty stream is the real contents!"
		^ remoteStrm].	"no actual writing till close"
	selection = 2 ifTrue: [
		^ self newFileNamed:
			(UIManager default request: 'Enter a new file name'
				initialAnswer: file fileName)].
	^ nil	"cancel"
]

{ #category : #'file directory' }
ServerDirectory >> oldFileNamed: aName [
	"If the file exists, answer a read-only RemoteFileStream on it.  aName is directory path, and does include name of the server.  Or it can just be a fileName.  For now, pre-read the file."

	| rFile |

	rFile := self asServerFileNamed: aName.
	rFile readOnly.
	rFile isTypeFile ifTrue: [
		^ FileStream oldFileNamed: (rFile fileNameRelativeTo: self)].

	^self streamOnBeginningOf: rFile

]

{ #category : #'file directory' }
ServerDirectory >> oldFileOrNoneNamed: fullName [
	"If the file exists, answer a read-only RemoteFileStream on it. If it doesn't, answer nil.  fullName is directory path, and does include name of the server.  Or just a simple fileName.  Do prefetch the data."
 
	
	^ Cursor wait showWhile:
		[ | file |
		file := self asServerFileNamed: fullName.
		file readOnly.
		"file exists ifFalse: [^ nil]."		"on the server"
		file isTypeFile
			ifTrue: [FileStream oldFileOrNoneNamed: (file fileNameRelativeTo: self)]
			ifFalse: [self streamOnBeginningOf: file]]
]

{ #category : #'file directory' }
ServerDirectory >> on: fullName [
	"Answer another ServerDirectory on the partial path name.  fullName is directory path, and does include the name of the server."

	| new |
	new := self copy.
	new fullPath: fullName.		"sets server, directory(path)"
	^ new
]

{ #category : #'dis\/connect' }
ServerDirectory >> openFTPClient [

	| loginSuccessful |
	client
		ifNotNil: [client isConnected
			ifTrue: [^client]
			ifFalse: [client := nil]].
	client := FTPClient openOnHostNamed: server.
	client ifNil: [^nil].
	loginSuccessful := false.
	[loginSuccessful]
		whileFalse: [
			[loginSuccessful := true.
			client loginUser: self user password: self password]
				on: LoginFailedException
				do: [:ex | 
					| what |
					passwordHolder := nil.
					what := UIManager default 
						chooseFrom: #('enter password' 'give up') 
						title: 'Would you like to try another password?'.
					what = 1 ifFalse: [ ^nil].
					loginSuccessful := false]].
	client changeDirectoryTo: directory.
	^client
]

{ #category : #accessing }
ServerDirectory >> password [

	passwordHolder ifNil: [passwordHolder := ServerPassword new].
	^ passwordHolder passwordFor: self	"may ask the user"
]

{ #category : #accessing }
ServerDirectory >> password: pp [

	passwordHolder := ServerPassword new.
	pp isString 
		ifTrue: [passwordHolder cache: pp. ^ self].
	pp isInteger 
		ifTrue: [passwordHolder sequence: pp]
		ifFalse: [passwordHolder := pp].
]

{ #category : #accessing }
ServerDirectory >> passwordSequence [

	^passwordHolder
		ifNotNil: [passwordHolder sequence]
]

{ #category : #accessing }
ServerDirectory >> passwordSequence: aNumber [

	passwordHolder ifNil: [passwordHolder := ServerPassword new].
	passwordHolder sequence: aNumber
]

{ #category : #'file directory' }
ServerDirectory >> pathName [
	"Path name as used in reading the file.  with slashes for ftp, with local file delimiter (:) for a file: url"

	urlObject ifNotNil: [^ urlObject pathForFile].
	directory size = 0 ifTrue: [^ server].
	^ (directory at: 1) = self pathNameDelimiter
		ifTrue: [server, directory]
		ifFalse: [user, '@', server, self pathNameDelimiter asString, directory]
]

{ #category : #'file directory' }
ServerDirectory >> pathNameDelimiter [
	"the separator that is used in URLs"

	^ $/
]

{ #category : #'file directory' }
ServerDirectory >> pathParts [
	"Return the path from the root of the file system to this directory as an array of directory names.  On a remote server."

	urlObject ifNotNil: [^ (urlObject path copy) removeLast; yourself].
	^ (OrderedCollection with: server) addAll: 
		(directory findTokens: self pathNameDelimiter asString);
			yourself.

]

{ #category : #copying }
ServerDirectory >> postCopy [
	super postCopy.
	self urlObject: urlObject copy
]

{ #category : #accessing }
ServerDirectory >> printOn: aStrm [
	aStrm nextPutAll: self class name; nextPut: $<.
	aStrm nextPutAll: self moniker.
	aStrm nextPut: $>.

]

{ #category : #'up\/download' }
ServerDirectory >> putFile: fileStream named: fileNameOnServer [
	"Just FTP a local fileStream to the server.  (Later -- Use a proxy server if one has been registered.)"

	client := self openFTPClient.
	client binary.
	[self switchDirectory.
	client putFileStreamContents: fileStream as: fileNameOnServer]
		ensure: [self quit]
]

{ #category : #'up\/download' }
ServerDirectory >> putFile: fileStream named: fileNameOnServer retry: aBool [
	"ar 11/24/1998 Do the usual putFile:named: operation but retry if some error occurs and aBool is set. Added due to having severe transmission problems on shell.webpage.com."
	| resp |
	self isTypeFile ifTrue: [
		^ (FileDirectory on: urlObject pathForDirectory)
			putFile: fileStream named: fileNameOnServer].

	[resp := [self putFile: fileStream named: fileNameOnServer] 
		ifError:[:err :rcvr| '5xx ',err]. "Report as error"
	aBool and:[((resp isString) and: [resp size > 0]) and:[resp first ~= $2]]] whileTrue:[
		(self confirm:('Error storing ',fileNameOnServer,' on the server.\(',resp,',)\Retry operation?') withCRs) ifFalse:[^resp].
	].
	^resp
]

{ #category : #'up\/download' }
ServerDirectory >> putFileSavingOldVersion: fileStream named: fileNameOnServer [

	| tempName oldName |
	"Put a copy of this file out after saving the prior version.
	Nothing happens to the old version until the new vers is successfully stored."
 	tempName := fileNameOnServer , '.beingWritten'.
	oldName := fileNameOnServer , '.prior'.
	self putFile: fileStream named: tempName retry: true.
	(self includesKey: oldName) ifTrue: [self deleteFileNamed: oldName].
	self rename: fileNameOnServer toBe: oldName.
	self rename: tempName toBe: fileNameOnServer.

]

{ #category : #'dis\/connect' }
ServerDirectory >> quit [
	"break the connection"

	self keepAlive
		ifFalse: [self quitClient]
]

{ #category : #'dis\/connect' }
ServerDirectory >> quitClient [
	"break the connection"

	client ifNotNil: [client quit].
	client := nil
]

{ #category : #'file directory' }
ServerDirectory >> readOnlyFileNamed: aName [
	"If the file exists, answer a read-only RemoteFileStream on it.  aName is directory path, and does include name of the server.  Or it can just be a fileName.  For now, pre-read the file."

	| rFile |

	rFile := self asServerFileNamed: aName.
	rFile readOnly.
	rFile isTypeFile ifTrue: [
		^ FileStream oldFileNamed: (rFile fileNameRelativeTo: self)].

	^self streamOnBeginningOf: rFile
]

{ #category : #accessing }
ServerDirectory >> realUrl [
	"a fully expanded version of the url we represent.  Prefix the path with http: or ftp: or file:"

	self isTypeFile ifTrue: [
		self fileNameRelativeTo: self.
		^ urlObject asString
	].
	^ self typeWithDefault asString, '://', self pathName
	
]

{ #category : #'file-operations' }
ServerDirectory >> recursiveDelete [
	"Delete the this directory, recursing down its tree."
	self directoryNames
		do: [:dn | (self directoryNamed: dn) recursiveDelete].
	self deleteLocalFiles.
	"should really be some exception handling for directory deletion, but no 
	support for it yet"
	self containingDirectory deleteDirectory: self localName
]

{ #category : #'file directory' }
ServerDirectory >> rename: fullName toBe: newName [
	"Rename a remote file.  fullName is just be a fileName, or can be directory path that includes name of the server.  newName is just a fileName"
	| file |

	file := self asServerFileNamed: fullName.
	file isTypeFile ifTrue: [
		(FileDirectory forFileName: (file fileNameRelativeTo: self)) 
			rename: file fileName toBe: newName
	].
	
	client := self openFTPClient.
	[client renameFileNamed: fullName to: newName]
		ensure: [self quit].
	
]

{ #category : #'multi-action sessions' }
ServerDirectory >> reset [
	
]

{ #category : #accessing }
ServerDirectory >> server [
	^ server
]

{ #category : #accessing }
ServerDirectory >> server: anObject [
	server := anObject
]

{ #category : #'file directory' }
ServerDirectory >> serverDelimiter [
	"the separator that is used in the place where the file actually is.  ftp server or local disk."

	^ self isTypeFile 
		ifTrue: [FileDirectory default pathNameDelimiter]
		ifFalse: [$/]	"for ftp, http"
]

{ #category : #accessing }
ServerDirectory >> slash [
	^'/'
]

{ #category : #accessing }
ServerDirectory >> slashDirectory [

	^ directory first == $/ 
		ifTrue: [directory]
		ifFalse: ['/', directory]
]

{ #category : #'multi-action sessions' }
ServerDirectory >> sleep [
	"If still connected, break the connection"

	self quitClient.
	self keepAlive: false
]

{ #category : #'file directory' }
ServerDirectory >> splitName: fullName to: pathAndNameBlock [
	"Take the file name and convert it to the path name of a directory and a local file name within that directory. FileName must be of the form: <dirPath><delimiter><localName>, where <dirPath><delimiter> is optional. The <dirPath> part may contain delimiters."

	| delimiter i dirName localName |
	delimiter := self pathNameDelimiter.
	(i := fullName findLast: [:c | c = delimiter]) = 0
		ifTrue:
			[dirName := String new.
			localName := fullName]
		ifFalse:
			[dirName := fullName copyFrom: 1 to: (i - 1 max: 1).
			localName := fullName copyFrom: i + 1 to: fullName size].

	^ pathAndNameBlock value: dirName value: localName
]

{ #category : #'file-in\/out' }
ServerDirectory >> storeServerEntryOn: stream [
	
	stream
		nextPutAll: 'name:'; tab; nextPutAll: (ServerDirectory nameForServer: self); cr;
		nextPutAll: 'directory:'; tab; nextPutAll: self directory; cr;
		nextPutAll: 'type:'; tab; nextPutAll: self typeForPrefs; cr;
		nextPutAll: 'server:'; tab; nextPutAll: self server; cr.
	group
		ifNotNil: [stream nextPutAll: 'group:'; tab; nextPutAll: self groupName; cr].
	self user
		ifNotNil: [stream nextPutAll: 'user:'; tab; nextPutAll: self user; cr].
	self passwordSequence
		ifNotNil: [stream nextPutAll: 'passwdseq:'; tab; nextPutAll: self passwordSequence asString; cr].
	self altUrl
		ifNotNil: [stream nextPutAll: 'url:'; tab; nextPutAll: self altUrl; cr].
	self loaderUrl
		ifNotNil: [stream nextPutAll: 'loaderUrl:'; tab; nextPutAll: self loaderUrl; cr].
	self acceptsUploads
		ifTrue: [stream nextPutAll: 'acceptsUploads:'; tab; nextPutAll: 'true'; cr].
	self encodingName
		ifNotNil: [stream nextPutAll: 'encodingName:'; tab; nextPutAll: self encodingName; cr].
]

{ #category : #'file directory' }
ServerDirectory >> streamOnBeginningOf: serverFile [

	| remoteStrm |
	remoteStrm := RemoteFileStream on: (String new: 2000).
	remoteStrm remoteFile: serverFile.
	serverFile getFileNamed: serverFile fileName into: remoteStrm.	"prefetch data"
	^ remoteStrm
]

{ #category : #initialize }
ServerDirectory >> switchDirectory [
	client changeDirectoryTo: directory
]

{ #category : #accessing }
ServerDirectory >> type: aSymbol [
	type := aSymbol
]

{ #category : #accessing }
ServerDirectory >> typeForPrefs [

	^self typeWithDefault
]

{ #category : #accessing }
ServerDirectory >> typeWithDefault [

	^ type ifNil: [type := #ftp]
]

{ #category : #squeaklets }
ServerDirectory >> upLoadProject: projectName members: archiveMembers retry: aBool [
	| dir m dirName |
	m := archiveMembers detect:[:any| any fileName includes: $/] ifNone:[nil].
	m == nil ifFalse:[
		dirName := m fileName copyUpTo: $/.
		self createDirectory: dirName.
		dir := self directoryNamed: dirName].
	archiveMembers do:[:entry| | okay idx |
		ProgressNotification signal: '4:uploadingFile'
			extra: ('(uploading {1}...)' translated format: {entry fileName}).
		idx := entry fileName indexOf: $/.
		okay := (idx > 0
			ifTrue:[
				dir putFile: entry contentStream 
					named: (entry fileName copyFrom: idx+1 to: entry fileName size) 
					retry: aBool]
			ifFalse:[
				self putFile: entry contentStream
					named: entry fileName
					retry: aBool]).
		(okay == false
			or: [okay isString])
			ifTrue: [
				self inform: ('Upload for {1} did not succeed ({2}).' translated format: {entry fileName printString. okay}).
				^false].
	].
	ProgressNotification signal: '4:uploadingFile' extra:''.
	^true
]

{ #category : #squeaklets }
ServerDirectory >> upLoadProject: projectFile named: fileNameOnServer resourceUrl: resUrl retry: aBool [
	"Upload the given project file. If it's an archive, upload only the files that are local to the project."
	| archive members prefix |
	self isTypeFile ifTrue:[
 		^(FileDirectory on: urlObject pathForDirectory)
			upLoadProject: projectFile named: fileNameOnServer resourceUrl: resUrl retry: aBool].
	projectFile isZipArchive
		ifFalse:[^self putFile: projectFile named: fileNameOnServer retry: aBool].
	projectFile binary.
	archive := ZipArchive new readFrom: projectFile.
	resUrl last = $/ 
		ifTrue:[prefix := resUrl copyFrom: 1 to: resUrl size-1] "remove last slash"
		ifFalse:[prefix := resUrl].
	prefix := prefix copyFrom: 1 to: (prefix lastIndexOf: $/).
	members := archive members select:[:entry| | upload |
		"figure out where it's coming from"
		upload := false.
		(entry fileName indexOf: $:) = 0 ifTrue:[
			upload := true. "one of the core files, e.g., project itself, resource map, meta info"
		] ifFalse:[
			(entry fileName asLowercase beginsWith: resUrl asLowercase) ifTrue:[
				upload := true.
				entry fileName: (entry fileName copyFrom: prefix size+1 to: entry fileName size).
			].
		].
		upload].
	members := members asArray sort:[:m1 :m2| m1 compressedSize < m2 compressedSize].
	^self upLoadProject: fileNameOnServer members: members retry: aBool.
]

{ #category : #squeaklets }
ServerDirectory >> updateProjectInfoFor: aProject [

	"only swiki servers for now"
]

{ #category : #accessing }
ServerDirectory >> url: aString [
	altURL := aString
]

{ #category : #accessing }
ServerDirectory >> urlObject [
	^ urlObject
]

{ #category : #accessing }
ServerDirectory >> urlObject: aUrl [

	urlObject := aUrl
]

{ #category : #accessing }
ServerDirectory >> user [
	^ user
]

{ #category : #accessing }
ServerDirectory >> user: anObject [
	user := anObject
]

{ #category : #'multi-action sessions' }
ServerDirectory >> wakeUp [
	"Start a multi-action session: Open for FTP and keep the connection open"

	self isTypeFTP
		ifTrue: [client := self openFTPClient].
	self keepAlive: true

]

{ #category : #squeaklets }
ServerDirectory >> writeProject: aProject inFileNamed: fileNameString fromDirectory: localDirectory [ 
	"write aProject (a file version can be found in the file named fileNameString in localDirectory)"
	aProject
		writeFileNamed: fileNameString
		fromDirectory: localDirectory
		toServer: self
]
