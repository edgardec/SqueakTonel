"
An in-memory stream that can be used to fileIn code from the network.  Knows its ServerFile, and thus its name, path, etc.

localDataValid -- false when have never read the file from the server.  Set to true after reading, when my contents has the true data.  When creating a remote file, set localDataValid to true so it will write to server.
"
Class {
	#name : #RemoteFileStream,
	#superclass : #RWBinaryOrTextStream,
	#instVars : [
		'remoteFile',
		'localDataValid'
	],
	#category : #'Network-RemoteDirectory'
}

{ #category : #'file status' }
RemoteFileStream >> close [
	"Write if we have data to write.  FTP files are always binary to preserve the data exactly.  The binary/text (ascii) flag is just for tell how the bits are delivered from a read."

	remoteFile writable ifTrue: [
			remoteFile putFile: (self as: RWBinaryOrTextStream) reset named: remoteFile fileName]
]

{ #category : #accessing }
RemoteFileStream >> contentsOfEntireFile [
	"Fetch the data off the server and store it in me.  But not if I already have it."

	readLimit := readLimit max: position.
	localDataValid ifTrue: [^ super contentsOfEntireFile].
	collection size = 0 ifTrue: [self on: (String new: 2000)].
	remoteFile getFileNamed: remoteFile fileName into: self.	"sets localDataValid := true"
	^ super contentsOfEntireFile
]

{ #category : #accessing }
RemoteFileStream >> dataIsValid [

	localDataValid := true.
]

{ #category : #accessing }
RemoteFileStream >> directory [
	^ remoteFile
]

{ #category : #accessing }
RemoteFileStream >> directoryUrl [
	^ remoteFile directoryUrl
]

{ #category : #accessing }
RemoteFileStream >> localName [
	^ remoteFile fileName
]

{ #category : #accessing }
RemoteFileStream >> openReadOnly [
	"If we have data, don't reread."

	self readOnly.
	readLimit := readLimit max: position.
	localDataValid ifFalse: [remoteFile getFileNamed: remoteFile fileName into: self].
		"sets localDataValid := true"
]

{ #category : #'as yet unclassified' }
RemoteFileStream >> padToEndWith: aChar [
	"On the Mac, files do not truncate, so pad it with a harmless character.  But Remote FTP files always replace, so no need to pad."

	self atEnd ifFalse: [self inform: 'Why is this stream not at its end?'].
]

{ #category : #accessing }
RemoteFileStream >> readOnly [
	^ remoteFile readOnly
]

{ #category : #accessing }
RemoteFileStream >> remoteFile [
	^ remoteFile
]

{ #category : #accessing }
RemoteFileStream >> remoteFile: aServerFile [
	remoteFile := aServerFile.
	localDataValid := false.	"need to read from the server"
]

{ #category : #'file directory' }
RemoteFileStream >> sleep [
	"If we are done, then let the server know"

	self close.
	remoteFile sleep.
]
