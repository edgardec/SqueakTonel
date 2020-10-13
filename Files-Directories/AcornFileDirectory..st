Class {
	#name : #AcornFileDirectory,
	#superclass : #FileDirectory,
	#classVars : [
		'LegalCharMap'
	],
	#category : #'Files-Directories'
}

{ #category : #'platform specific' }
AcornFileDirectory class >> currentDirectoryNickname [
	"Answer the nick-name for the current directory (e.g. '.' on Unix and Windows).
	 Who knows what this is on Acorn?"
	^nil
]

{ #category : #'class initialization' }
AcornFileDirectory class >> initialize [
"Set up the legal chars map for filenames. May need extending for unicode etc.
Basic rule is that any char legal for use in filenames will have a non-nil entry in this array; except for space, this is the same character. Space is transcoded to a char 160 to be a 'hard space' "
"AcornFileDirectory initialize"
	LegalCharMap := Array new: 256.
	Character alphabet do:[:c|
		| aVal |
		LegalCharMap at: c asciiValue +1  put: c.
		LegalCharMap at: (aVal := c asUppercase) asciiValue +1 put: aVal].
	'`!()-_=+[{]};~,./1234567890' do:[:c|
			LegalCharMap at: c asciiValue + 1 put: c].
	LegalCharMap at: Character space asciiValue +1 put: (Character value:160 "hardspace").
	LegalCharMap at: 161 put: (Character value:160 "hardspace")."secondary mapping to keep it in strings"
]

{ #category : #'platform specific' }
AcornFileDirectory class >> isActiveDirectoryClass [
	"Does this class claim to be that properly active subclass of FileDirectory  
	for the current platform? On Acorn, the test is whether platformName 
	is 'RiscOS' (on newer VMs) or if the primPathNameDelimiter is $. (on
	older ones), which is what we would like to use for a dirsep if only it
	would work out. See pathNameDelimiter for more woeful details - then
	just get on and enjoy Squeak"

	^ Smalltalk platformName = 'RiscOS'
		or: [self primPathNameDelimiter = $.]
]

{ #category : #'platform specific' }
AcornFileDirectory class >> isCaseSensitive [
	"Risc OS ignores the case of file names"
	^ false
]

{ #category : #'platform specific' }
AcornFileDirectory class >> maxFileNameLength [

	^ 255

]

{ #category : #'platform specific' }
AcornFileDirectory class >> parentDirectoryNickname [
	"Answer the nick-name for the parent directory (e.g. '..' on Unix and Windows).
	 Acorn chose to use the much more sensible ^; after all it points upwards..."
	^$^
]

{ #category : #'platform specific' }
AcornFileDirectory class >> pathNameDelimiter [
"Acorn RiscOS uses a dot as the directory separator and has no real concept of filename extensions. We tried to make code handle this, but there are just too many uses of dot as a filename extension - so fake it out by pretending to use a slash. The file prims do conversions instead.
Sad, but pragmatic"
	^ $/

]

{ #category : #'file name utilities' }
AcornFileDirectory >> checkName: aFileName fixErrors: fixing [
	"Check if the file name contains any invalid characters"
	| fName hasBadChars correctedName |
	fName := super checkName: aFileName fixErrors: fixing.
	correctedName := String streamContents:[:s|
								fName do:[:c|
									| newChar |
									(newChar := LegalCharMap at: c asciiValue +1) ifNotNil:[s nextPut: newChar]]]. 
	hasBadChars := fName ~= correctedName.
	(hasBadChars and:[fixing not]) ifTrue:[^self error:'Invalid file name'].
	hasBadChars ifFalse:[^ fName].
	^ correctedName
]

{ #category : #private }
AcornFileDirectory >> directoryContentsFor: fullPath do: aBlock [
	"Evaluate aBlock with the directory entries for the files and directories in 
	the directory with the given path. See primLookupEntryIn:index: for 
	further details."
	"FileDirectory default directoryContentsFor: '' do: [ :each | Transcript show: each; cr ]"

	| extraPath extraPathFullName needsExtraPath |
	fullPath isNullPath ifFalse: [ ^super directoryContentsFor: fullPath do: aBlock ].

	"For Acorn we also make sure that at least the parent of the current dir 
	is added - sometimes this is in a filing system that has not been (or 
	cannot be) polled for disc root names"
	extraPath := self class default containingDirectory.
	extraPathFullName := extraPath fullName.
	needsExtraPath := true.
	super directoryContentsFor: fullPath do: [ :entry |
		needsExtraPath := needsExtraPath and: [ (extraPathFullName beginsWith: entry name) not ].
		aBlock value: entry ].

	needsExtraPath ifFalse: [ ^self ].
	"Only add the extra path if we haven't already got the root of the current dir in the list"
	aBlock value: (
		DirectoryEntryDirectory
			directory: self
			name: extraPathFullName
			creationTime: 0
			modificationTime: 0
			fileSize: 0)
]

{ #category : #testing }
AcornFileDirectory >> directoryExists: filenameOrPath [
"if the path is a root,we have to treat it carefully"
	(filenameOrPath endsWith: '$') ifTrue:[^(FileDirectory on: filenameOrPath) exists].
	^(self directoryNamed: filenameOrPath ) exists
]

{ #category : #'file name utilities' }
AcornFileDirectory >> fullPathFor: path [
	"if the arg is an empty string, just return my path name converted via the language stuff. 
If the arg seems to be a  rooted path, return it raw, assuming it is already ok.
Otherwise cons up a path"
	path isEmpty ifTrue:[^pathName asSqueakPathName].
	((path includes: $$ ) or:[path includes: $:]) ifTrue:[^path].
	^pathName asSqueakPathName, self slash, path
]

{ #category : #'path access' }
AcornFileDirectory >> pathParts [
	"Return the path from the root of the file system to this directory as an 
	array of directory names.
	This version tries to cope with the RISC OS' strange filename formatting; 
	filesystem::discname/$/path/to/file
	where the $ needs to be considered part of the filingsystem-discname atom."
	| pathList |
	pathList := super pathParts.
	(pathList indexOf: '$') = 2
		ifTrue: ["if the second atom is root ($) then stick $ on the first atom 
				and drop the second. Yuck"
			^ pathList species
				streamContents: [:a | 
					a nextPut: (pathList at: 1), '/$'.
					3 to: pathList size do: [:i | a
								nextPut: (pathList at: i)]]].
	^ pathList
]
