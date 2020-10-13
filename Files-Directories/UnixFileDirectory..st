"
I represent a Unix FileDirectory.

It is worth noting that the various enumeration methods do *not* include the parent and local directory pseudo-names '.' and '..'. They are filtered out in the primitive that reads the directory entries.

"
Class {
	#name : #UnixFileDirectory,
	#superclass : #FileDirectory,
	#category : #'Files-Directories'
}

{ #category : #'platform specific' }
UnixFileDirectory class >> maxFileNameLength [

	^ 255
]

{ #category : #'platform specific' }
UnixFileDirectory class >> pathNameDelimiter [

	^ $/

]

{ #category : #'file names' }
UnixFileDirectory >> checkName: aFileName fixErrors: fixing [
	"Check if the file name contains any invalid characters"
	| fName |
	fName := super checkName: aFileName fixErrors: fixing.
	(fName includes: self class pathNameDelimiter) ifFalse:
		[^fName].
	^fixing
		ifTrue: [fName copyReplaceAll: (String with: self class pathNameDelimiter) with: '#']
		ifFalse: [self error:'Invalid file name']
]

{ #category : #testing }
UnixFileDirectory >> directoryExists: filenameOrPath [
	"Answers true if the directory exists.  Overrides to handle the root directory /
	 and relative paths."
	| fName dir |

	filenameOrPath = '/' ifTrue:
		[^true].

	DirectoryClass
		splitName: filenameOrPath
		to: [:filePath :name |
			fName := name.
			dir := filePath isEmpty
					ifTrue: [self]
					ifFalse:
						[FileDirectory on: (filePath first = $/
											ifTrue: [filePath]
											ifFalse: [self fullName, '/', filePath])]].

	^dir exists
	  and: [(dir directoryEntryForName: fName)
			ifNotNil: [:e| e isDirectory]
			ifNil: [false]]
]

{ #category : #testing }
UnixFileDirectory >> fileOrDirectoryExists: filenameOrPath [
	"Answer true if either a file or a directory file of the given name exists. The given name
	 may be either a full path name or a local name within this directory. Overrides to handle
	 the root directory / and relative paths."
	| fName dir |

	filenameOrPath = '/' ifTrue:
		[^true].

	DirectoryClass
		splitName: filenameOrPath
		to: [:filePath :name |
			fName := name.
			dir := filePath isEmpty
					ifTrue: [self]
					ifFalse:
						[FileDirectory on: (filePath first = $/
											ifTrue: [filePath]
											ifFalse: [self fullName, '/', filePath])]].

	^dir exists
	  and: [(dir includesKey: fName) or: [fName isEmpty and: [dir entries size > 1]]]
]

{ #category : #'file names' }
UnixFileDirectory >> fullPathFor: path [
	"Return the fully-qualified path name for the given file."
	path isEmpty ifTrue: [^ pathName asSqueakPathName].
	path first = $/ ifTrue: [^ path].
	^ pathName asSqueakPathName = '/'			"Only root dir ends with a slash"
		ifTrue: ['/' , path]
		ifFalse: [pathName asSqueakPathName , '/' , path]
]

{ #category : #'file names' }
UnixFileDirectory >> pathFromUrl: aFileUrl [
	^'/', (super pathFromUrl: aFileUrl)
]

{ #category : #private }
UnixFileDirectory >> setPathName: pathString [
	"Unix path names start with a leading delimiter character."

	(pathString isEmpty or: [pathString first ~= self pathNameDelimiter])
		ifTrue: [pathName := FilePath pathName: (self pathNameDelimiter asString, pathString)]
		ifFalse: [pathName := FilePath pathName: pathString].

]
