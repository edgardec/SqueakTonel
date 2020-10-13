"
Represents the non-data part of a file on a server on the internet.  I am owned by a RemoteFileStream, who has the data.

Since FileStream is a Stream and I am not, use this to always get a stream:
	xxx isStream ifFalse: [^ xxx asStream].


"
Class {
	#name : #ServerFile,
	#superclass : #ServerDirectory,
	#instVars : [
		'fileName',
		'rwmode'
	],
	#category : #'Network-RemoteDirectory'
}

{ #category : #converting }
ServerFile >> asStream [
	"Return a RemoteFileStream (subclass of RWBinaryOrTextStream) on the contents of the remote file I represent.  For reading only.  This method is probably misnamed.  Maybe call it makeStream"

	^ self readOnlyFileNamed: self fileName
]

{ #category : #accessing }
ServerFile >> directoryUrl [
	| ru |
	"A url to the directory this file is in"

	ru := self realUrl.
	^ ru copyFrom: 1 to: (ru size - fileName size)
]

{ #category : #'file directory' }
ServerFile >> exists [
	"Return true if the file exists on the server already"

	^ self fileExists: fileName
]

{ #category : #accessing }
ServerFile >> fileName [
	"should this be local or as in a url?"

	urlObject ifNotNil: [^ urlObject path last].	"path last encodeForHTTP ?"
	^ fileName
]

{ #category : #accessing }
ServerFile >> fileName: aString [

	urlObject ~~ nil  "type == #file" 
		ifTrue: [urlObject path at: urlObject path size put: aString]
		ifFalse: [fileName := aString]
]

{ #category : #accessing }
ServerFile >> fileNameRelativeTo: aServerDir [
	"Produce an absolute fileName from me and an absolute directory"
	urlObject isAbsolute ifFalse: [
		(aServerDir urlObject ~~ nil and: [aServerDir urlObject isAbsolute]) 
			ifTrue: [urlObject 
				privateInitializeFromText: urlObject pathString 
				relativeTo: aServerDir urlObject]
			ifFalse: [urlObject default]].	"relative to Squeak directory"
	^ urlObject pathForDirectory, self fileName
]

{ #category : #accessing }
ServerFile >> fullPath: serverAndDirectory [
	"Parse and save a full path.  Separate out fileName at the end."

	| delim ii |
	super fullPath: serverAndDirectory.		"set server and directory"
	self isTypeFile ifTrue: [
		fileName :=  ''.
		^ self
	].
	delim := self pathNameDelimiter.
	ii := directory findLast: [:c | c = delim].
	ii = 0
		ifTrue: [self error: 'expecting directory and fileName']
		ifFalse: [fileName := directory copyFrom: ii+1 to: directory size.
			directory := (directory copyFrom: 1 to: directory size - fileName size - 1)].
]

{ #category : #'file directory' }
ServerFile >> localName [

	^ self fileName
]

{ #category : #'file modes' }
ServerFile >> readOnly [
	"Set the receiver to be read-only"

	rwmode := false
]

{ #category : #'file modes' }
ServerFile >> readWrite [
	"Set the receiver to be writable"

	rwmode := true
]

{ #category : #accessing }
ServerFile >> realUrl [
	"a fully expanded version of the url we represent.  Prefix the path with http: or ftp: or file:"

	self isTypeFile ifTrue: [
		self fileNameRelativeTo: self.
		^ urlObject asString
	].
	^ self typeWithDefault asString, '://', self pathName, '/', fileName	"note difference!"
	
]

{ #category : #'file modes' }
ServerFile >> writable [
	^ rwmode
]
