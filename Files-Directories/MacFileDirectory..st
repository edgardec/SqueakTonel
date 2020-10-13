"
I represent a Macintosh FileDirectory.

"
Class {
	#name : #MacFileDirectory,
	#superclass : #FileDirectory,
	#classVars : [
		'TypeToMimeMappings'
	],
	#category : #'Files-Directories'
}

{ #category : #'class initialization' }
MacFileDirectory class >> initializeTypeToMimeMappings [
	"MacFileDirectory initializeTypeToMimeMappings"
	TypeToMimeMappings := Dictionary new.
	#(
		"format"
		"(abcd		('image/gif'))"
	) do:[:spec|
		TypeToMimeMappings at: spec first asString put: spec last.
	].

]

{ #category : #'class initialization' }
MacFileDirectory class >> isAbsolute: fileName [
	"Return true if the given fileName is absolute. The rules are:

If a path begins with a colon, it is relative.
Otherwise,
  If it contains a colon anywhere, it is absolute and the first component is the volume name.
  Otherwise,
    It is relative."

	^fileName first ~= $:
		and: [ fileName includes: $: ]
]

{ #category : #'platform specific' }
MacFileDirectory class >> isActiveDirectoryClass [
	^ super isActiveDirectoryClass
		and: [(Smalltalk getSystemAttribute: 1201) isNil
				or: [(Smalltalk getSystemAttribute: 1201) asNumber <= 31]]
]

{ #category : #'platform specific' }
MacFileDirectory class >> isCaseSensitive [
	"Mac OS ignores the case of file names"
	^ false
]

{ #category : #'platform specific' }
MacFileDirectory class >> makeAbsolute: path [
	"Ensure that path looks like an absolute path"
	| absolutePath |
	(self isAbsolute: path)
		ifTrue: [ ^path ].
	"If a path begins with a colon, it is relative."
	absolutePath := (path first = $:)
		ifTrue: [ path copyWithoutFirst ]
		ifFalse: [ path ].
	(self isAbsolute: absolutePath)
		ifTrue: [ ^absolutePath ].
	"Otherwise, if it contains a colon anywhere, it is absolute and the first component is the volume name."
	^absolutePath, ':'
]

{ #category : #'platform specific' }
MacFileDirectory class >> makeRelative: path [
	"Ensure that path looks like an relative path"
	^path first = $:
		ifTrue: [ path ]
		ifFalse: [ ':', path ]
]

{ #category : #'platform specific' }
MacFileDirectory class >> maxFileNameLength [

	^31
]

{ #category : #'platform specific' }
MacFileDirectory class >> pathNameDelimiter [

	^ $:

]

{ #category : #'file name utilities' }
MacFileDirectory >> fullNameFor: fileName [
	"Return a corrected, fully-qualified name for the given file name. If the given name is already a full path (i.e., it contains a delimiter character), assume it is already a fully-qualified name. Otherwise, prefix it with the path to this directory. In either case, correct the local part of the file name."
	"Details: Note that path relative to a directory, such as '../../foo' are disallowed by this algorithm.  Also note that this method is tolerent of a nil argument -- is simply returns nil in this case."
	"Fix by hmm: for a file in the root directory of a volume on MacOS, the filePath (name of the directory) is not  recognizable as an absolute path anymore (it has no delimiters). Therefore, the original fileName is tested for absoluteness, and the filePath is only made absolute if the original fileName was not absolute"

	| correctedLocalName prefix |
	fileName isEmptyOrNil ifTrue: [^ fileName].
	DirectoryClass splitName: fileName to:
		[:filePath :localName |
			correctedLocalName := localName isEmpty 
				ifFalse: [self checkName: localName fixErrors: true]
				ifTrue: [localName].
			prefix := (DirectoryClass isAbsolute: fileName)
						ifTrue: [filePath]
						ifFalse: [self fullPathFor: filePath]].
	prefix isEmpty
		ifTrue: [^correctedLocalName].
	prefix last = self pathNameDelimiter
		ifTrue:[^ prefix, correctedLocalName]
		ifFalse:[^ prefix, self slash, correctedLocalName]
]

{ #category : #'file operations' }
MacFileDirectory >> fullPathFor: path [
	"Return the fully-qualified path name for the given file."
	path isEmptyOrNil ifTrue: [^ pathName asSqueakPathName].
	(self class isAbsolute: path) ifTrue: [^ path].
	pathName asSqueakPathName = ''			"Root dir?"
		ifTrue: [ ^path].
	^(path first = $:)
		ifTrue: [ pathName asSqueakPathName, path ]
		ifFalse: [pathName asSqueakPathName, ':' , path]
]

{ #category : #'file operations' }
MacFileDirectory >> mimeTypesFor: fileName [
	"Return a list of MIME types applicable to the receiver. This default implementation uses the file name extension to figure out what we're looking at but specific subclasses may use other means of figuring out what the type of some file is. Some systems like the macintosh use meta data on the file to indicate data type"
	| typeCreator type | 
	typeCreator := self getMacFileTypeAndCreator: ((self fullNameFor: fileName)).
	type := (typeCreator at: 1) asLowercase.
	^TypeToMimeMappings at: type ifAbsent:[super mimeTypesFor: fileName]
]
