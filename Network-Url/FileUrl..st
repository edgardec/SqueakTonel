"
This class models a file URL according to (somewhat) RFC1738, see http://www.w3.org/Addressing/rfc1738.txt

Here is the relevant part of the RFC:

3.10 FILES

   The file URL scheme is used to designate files accessible on a
   particular host computer. This scheme, unlike most other URL schemes,
   does not designate a resource that is universally accessible over the
   Internet.

   A file URL takes the form:

       file://<host>/<path>

   where <host> is the fully qualified domain name of the system on
   which the <path> is accessible, and <path> is a hierarchical
   directory path of the form <directory>/<directory>/.../<name>.

   For example, a VMS file

     DISK$USER:[MY.NOTES]NOTE123456.TXT

   might become

     <URL:file://vms.host.edu/disk$user/my/notes/note12345.txt>

   As a special case, <host> can be the string ""localhost"" or the empty
   string; this is interpreted as `the machine from which the URL is
   being interpreted'.

   The file URL scheme is unusual in that it does not specify an
   Internet protocol or access method for such files; as such, its
   utility in network protocols between hosts is limited.

From the above we can conclude that the RFC says that the <path> part never starts or ends with a slash and is always absolute. If the last name can be a directory instead of a file is not specified clearly.

The path is stored as a SequenceableCollection of path parts.

Notes regarding non RFC features in this class:

- If the last path part is the empty string, then the FileUrl is referring to a directory. This is also shown with a trailing slash when converted to a String.

- The FileUrl has an attribute isAbsolute which signals if the path should be considered absolute or relative to the current directory. This distinction is not visible in the String representation of FileUrl, since the RFC does not have that.

- Fragment is supported (kept for historical reasons)


"
Class {
	#name : #FileUrl,
	#superclass : #Url,
	#instVars : [
		'host',
		'path',
		'isAbsolute'
	],
	#category : #'Network-Url'
}

{ #category : #'instance creation' }
FileUrl class >> absoluteFromText: aString [
	"Method that can be called explicitly to create a FileUrl."

	^self new privateInitializeFromText: aString
]

{ #category : #'instance creation' }
FileUrl class >> host: aHost pathParts: aCollectionOfPathParts isAbsolute: aBoolean [
	"Create a FileUrl."

	^self new host: aHost pathParts: aCollectionOfPathParts isAbsolute: aBoolean
]

{ #category : #'instance creation' }
FileUrl class >> pathParts: aCollectionOfPathParts [
	"Create a FileUrl."

	^self host: nil pathParts: aCollectionOfPathParts isAbsolute: true
]

{ #category : #'instance creation' }
FileUrl class >> pathParts: aCollectionOfPathParts isAbsolute: aBoolean [
	"Create a FileUrl."

	^self host: nil pathParts: aCollectionOfPathParts isAbsolute: aBoolean
]

{ #category : #constants }
FileUrl class >> schemeName [
	^'file'
]

{ #category : #downloading }
FileUrl >> default [
	"Use the default local Squeak file directory."
	
	| local |
	local := self class pathParts: (FileDirectory default pathParts), #('') isAbsolute: true.
	self privateInitializeFromText: self pathString relativeTo: local.
		"sets absolute also"
]

{ #category : #access }
FileUrl >> directoryUrl [
	"The path always has at least one element so this works."

	^self copy path: (path copyFrom: 1 to: path size - 1)
]

{ #category : #access }
FileUrl >> fileName [
	"Return the last part of the path,
	most often a filename but can also be a directory."

	^self path last
]

{ #category : #testing }
FileUrl >> firstPartIsDriveLetter [
	"Return true if the first part of the path is a letter
	followed by a $: like 'C:' "
	
	| firstPart |
	path isEmpty ifTrue: [^false].
	firstPart := path first.
	^firstPart size = 2 and: [
		firstPart first isLetter
			and: [firstPart last = $:]]
]

{ #category : #downloading }
FileUrl >> hasContents [
	^true
]

{ #category : #accessing }
FileUrl >> host [
	"Return the host name, either 'localhost', '', or a fully qualified domain name."
	
	^host ifNil: ['']
]

{ #category : #accessing }
FileUrl >> host: hostName [
	"Set the host name, either 'localhost', '', or a fully qualified domain name."
	
	host := hostName
]

{ #category : #'private-initialization' }
FileUrl >> host: aHostString pathParts: aCollection isAbsolute: aBoolean [

	host := aHostString.
	path := aCollection.
	isAbsolute := aBoolean
]

{ #category : #'private-initialization' }
FileUrl >> initializeFromPathString: aPathString [
	"<aPathString> is a file path as a String.
	We construct a path collection using various heuristics."

	| pathString hasDriveLetter |
	pathString := aPathString.
	pathString isEmpty ifTrue: [pathString := '/'].
	path := (pathString findTokens: '/') collect: [:token | token unescapePercents].

	"A path like 'C:' refers in practice to 'c:/'"
	((pathString endsWith: '/') or:
		[(hasDriveLetter := self firstPartIsDriveLetter) and: [path size = 1]])
			ifTrue: [path add: ''].

	"Decide if we are absolute by checking for leading $/ or
	beginning with drive letter. Smarts for other OSes?"
	self isAbsolute: ((pathString beginsWith: '/')
						or: [hasDriveLetter ifNil: [self firstPartIsDriveLetter]])
]

{ #category : #accessing }
FileUrl >> isAbsolute [
	"Should the path be considered absolute to
	the filesystem instead of relative to the default directory?"
 
	^isAbsolute
]

{ #category : #accessing }
FileUrl >> isAbsolute: aBoolean [
	"Set if the path should be considered absolute to
	the filesystem instead of relative to the default directory."

	isAbsolute := aBoolean
]

{ #category : #accessing }
FileUrl >> path [
	"Return an ordered collection of the path elements."
	
	^path
]

{ #category : #accessing }
FileUrl >> path: aCollection [
	"Set the collection of path elements."

	path := aCollection
]

{ #category : #paths }
FileUrl >> pathDirString [
	"Path to directory as url, using slash as delimiter.
	Filename is left out."

	^String streamContents: [ :s |
		isAbsolute ifTrue: [ s nextPut: $/ ].
		1 to: self path size - 1 do: [ :ii |
			s nextPutAll: (path at: ii); nextPut: $/]]
]

{ #category : #paths }
FileUrl >> pathForDirectory [
	"Path using local file system's pathname delimiter.
	DOS paths with drive letters should not
	be prepended with a delimiter even though
	they are absolute. Filename is left out."

	| delimiter |
	delimiter :=  FileDirectory default pathNameDelimiter.
	^String streamContents: [ :s |
		(self isAbsolute and: [self firstPartIsDriveLetter not])
			ifTrue: [ s nextPut: delimiter ].
		1 to: self path size - 1 do: [ :ii |
			s nextPutAll: (path at: ii); nextPut: delimiter]]
]

{ #category : #access }
FileUrl >> pathForFile [
	"Path using local file system's delimiter.  $\ or $:"
	^FileDirectory default pathFromUrl: self
]

{ #category : #'private-initialization' }
FileUrl >> pathParts: aCollection isAbsolute: aBoolean [

	^self host: nil pathParts: aCollection isAbsolute: aBoolean
]

{ #category : #paths }
FileUrl >> pathString [
	"Path as it appears in a URL with $/ as delimiter."
	
	^String streamContents: [ :s |
		"isAbsolute ifTrue:[ s nextPut: $/ ]."
		self path
			do: [ :p | s nextPutAll: p encodeForHTTP ]
			separatedBy: [ s nextPut: $/]]
]

{ #category : #copying }
FileUrl >> postCopy [
	"Be sure not to share the path with the copy."

	super postCopy.
	path := path copy
]

{ #category : #printing }
FileUrl >> printOn: aStream [
	"Return the FileUrl according to RFC1738 plus supporting fragments:
		'file://<host>/<path>#<fragment>'
	Note that <host> being '' is equivalent to 'localhost'.
	Note: The pathString can not start with a leading $/
	to indicate an 'absolute' file path.
	This is not according to RFC1738 where the path should have
	no leading or trailing slashes, and always
	be considered absolute relative to the filesystem."

	aStream nextPutAll: self schemeName, '://'.

	host ifNotNil: [aStream nextPutAll: host].

	aStream
		nextPut: $/;
		nextPutAll: self pathString.

	fragment ifNotNil:
		[aStream
			nextPut: $#;
			nextPutAll: fragment encodeForHTTP].
]

{ #category : #'private-initialization' }
FileUrl >> privateInitializeFromText: aString [
	"Calculate host and path from a file URL in String format.
	Some malformed formats are allowed and interpreted by guessing."

	| schemeName pathString bare hasDriveLetter stream char i |
	bare := aString withBlanksTrimmed.
	schemeName := Url schemeNameForString: bare.
	(schemeName isNil or: [schemeName ~= self schemeName])
		ifTrue: [
			host := ''.
			pathString := bare]
		ifFalse: [
			"First remove schemeName and colon"
			bare := bare copyFrom: (schemeName size + 2) to: bare size.
			"A proper file URL then has two slashes before host,
			A malformed URL is interpreted as using syntax file:<path>."
			(bare beginsWith: '//')
				ifTrue: [i := bare indexOf: $/ startingAt: 3.
						i=0 ifTrue: [
								host := bare copyFrom: 3 to: bare size.
								pathString := '']
							ifFalse: [
								host := bare copyFrom: 3 to: i-1.
								pathString := bare copyFrom: host size + 3 to: bare size]]
				ifFalse: [host := ''.
						pathString := bare]].
	self initializeFromPathString: pathString

]

{ #category : #'private-initialization' }
FileUrl >> privateInitializeFromText: pathString relativeTo: aUrl [
	"<pathString> should be a filesystem path.
	This url is adjusted to be aUrl + the path."

	| bare newPath |
	self host: aUrl host.
	self initializeFromPathString: pathString.
	self isAbsolute: aUrl isAbsolute.

	newPath := aUrl path copy.
	newPath removeLast.	"empty string that says its a directory"
	path do: [ :token |
		((token ~= '..') and: [token ~= '.']) ifTrue: [ 
			newPath addLast: token unescapePercents ].
		token = '..' ifTrue: [ 
			newPath isEmpty ifFalse: [ 
				newPath last = '..' ifFalse: [ newPath removeLast ] ] ].
		"token = '.' do nothing" ].
	path := newPath

	
]

{ #category : #downloading }
FileUrl >> retrieveContents [
	| file pathString s type entries |
	pathString := self pathForFile.
	file := [FileStream readOnlyFileNamed: pathString] 
			on: FileDoesNotExistException do:[:ex| ex return: nil].
	file ifNotNil: [
		type := file mimeTypes.
		type ifNotNil:[type := type first].
		type ifNil:[type := MIMEDocument guessTypeFromName: self path last].
		^MIMELocalFileDocument 
			contentType: type
			contentStream: file].

	"see if it's a directory..."
	entries := [(FileDirectory on: pathString) entries] 
				on: InvalidDirectoryError do:[:ex| ex return: nil].
	entries ifNil:[^nil].

	s := WriteStream on: String new.
	(pathString endsWith: '/') ifFalse: [ pathString := pathString, '/' ].
	s nextPutAll: '<title>Directory Listing for ', pathString, '</title>'.
	s nextPutAll: '<h1>Directory Listing for ', pathString, '</h1>'.
	s nextPutAll: '<ul>'.
	s cr.
	entries do: [ :entry |
		s nextPutAll: '<li><a href="'.
		s nextPutAll: entry name.
		s nextPutAll: '">'.
		s nextPutAll: entry name.
		s nextPutAll: '</a>'.
		s cr. ].
	s nextPutAll: '</ul>'.
	^MIMEDocument  contentType: 'text/html'  content: s contents  url: ('file://', pathString)
]

{ #category : #classification }
FileUrl >> scheme [
	^self class schemeName
]

{ #category : #classification }
FileUrl >> schemeName [
	^self class schemeName
]
