"
I represent a DOS or Windows FileDirectory.

"
Class {
	#name : #DosFileDirectory,
	#superclass : #FileDirectory,
	#category : #'Files-Directories'
}

{ #category : #'platform specific' }
DosFileDirectory class >> isCaseSensitive [
	"Return true if file names are treated case sensitive"
	^false
]

{ #category : #'platform specific' }
DosFileDirectory class >> isDrive: fullName [
	"Answer whether the given full name describes a 'drive', e.g., one of the root directories of a Win32 file system. We allow two forms here - the classic one where a drive is specified by a letter followed by a colon, e.g., 'C:', 'D:' etc. and the network share form starting with double-backslashes e.g., '\\server'."
	^ (fullName size = 2 and: [fullName first isLetter and: [fullName last = $:]])
		or: [(fullName beginsWith: '\\') and: [(fullName occurrencesOf: $\) = 2]]
]

{ #category : #'platform specific' }
DosFileDirectory class >> maxFileNameLength [

	^ 255

]

{ #category : #'platform specific' }
DosFileDirectory class >> pathNameDelimiter [

	^ $\

]

{ #category : #'platform specific' }
DosFileDirectory class >> splitName: fullName to: pathAndNameBlock [
	"Take the file name and convert it to the path name of a directory and a local file name within that directory. 
	IMPORTANT NOTE: For 'drives', e.g., roots of the file system on Windows we treat the full name of that 'drive' as the local name rather than the path. This is because conceptually, all of these 'drives' hang off the virtual root of the entire Squeak file system, specified by FileDirectory root. In order to be consistent with, e.g., 

		DosFileDirectory localNameFor: 'C:\Windows' -> 'Windows'
		DosFileDirectory dirPathFor: 'C:\Windows' -> 'C:'

	we expect the following to be true:

		DosFileDirectory localNameFor: 'C:' -> 'C:'
		DosFileDirectory dirPathFor: 'C:'. -> ''
		DosFileDirectory localNameFor: '\\server' -> '\\server'.
		DosFileDirectory dirPathFor: '\\server' -> ''.

	so that in turn the following relations hold:

		| fd |
		fd := DosFileDirectory on: 'C:\Windows'.
		fd containingDirectory includes: fd localName.
		fd := DosFileDirectory on: 'C:'.
		fd containingDirectory includes: fd localName.
		fd := DosFileDirectory on: '\\server'.
		fd containingDirectory includes: fd localName.
	"
	(self isDrive: fullName)
		ifTrue: [^ pathAndNameBlock value:''  value: fullName].
	^ super splitName: fullName to: pathAndNameBlock
]

{ #category : #'file name utilities' }
DosFileDirectory >> checkName: aFileName fixErrors: fixing [
	"Check if the file name contains any invalid characters"
	| fName badChars hasBadChars |
	fName := super checkName: aFileName fixErrors: fixing.
	badChars := #( $: $< $> $| $/ $\ $? $* $") asSet.
	hasBadChars := fName includesAnyOf: badChars.
	(hasBadChars and:[fixing not]) ifTrue:[^self error:'Invalid file name'].
	hasBadChars ifFalse:[^ fName].
	^ fName collect:
		[:char | (badChars includes: char) 
				ifTrue:[$#] 
				ifFalse:[char]]
]

{ #category : #'path access' }
DosFileDirectory >> driveName [

   "return a possible drive letter and colon at the start of a Path name, empty string otherwise"

   | firstTwoChars |

   ( pathName asSqueakPathName size >= 2 ) ifTrue: [
      firstTwoChars := (pathName asSqueakPathName copyFrom: 1 to: 2).
      (self class isDrive: firstTwoChars) ifTrue: [^firstTwoChars]
   ].
   ^''
]

{ #category : #'path access' }
DosFileDirectory >> fullNameFor: fileName [
	"Return a corrected, fully-qualified name for the given file name. If the given name is already a full path (i.e., it contains a delimiter character), assume it is already a fully-qualified name. Otherwise, prefix it with the path to this directory. In either case, correct the local part of the file name."
	fileName ifNil:[^fileName].
	"Check for fully qualified names"
	((fileName size >= 2 and: [fileName first isLetter and: [fileName second = $:]])
		or: [(fileName beginsWith: '\\') and: [(fileName occurrencesOf: $\) >= 2]])
			ifTrue:[^fileName].
	^super fullNameFor: fileName
]

{ #category : #'path access' }
DosFileDirectory >> fullPathFor: path [
	"Return the fully-qualified path name for the given file."
	path isEmpty ifTrue:[^pathName asSqueakPathName].
	(path at: 1) = $\ ifTrue:[
		(path size >= 2 and:[(path at: 2) = $\]) ifTrue:[^path]. "e.g., \\pipe\"
		^self driveName , path "e.g., \windows\"].
	(path size >= 2 and:[(path at: 2) = $: and:[path first isLetter]])
		ifTrue:[^path]. "e.g., c:"
	^pathName asSqueakPathName, self slash, path
]

{ #category : #'path access' }
DosFileDirectory >> relativeNameFor: path [
	"Return the full name for path, assuming that path is a name relative to me."
	path isEmpty ifTrue:[^pathName asSqueakPathName].
	(path at: 1) = $\ ifTrue:[
		(path size >= 2 and:[(path at: 2) = $\]) ifTrue:[^super relativeNameFor: path allButFirst ]. "e.g., \\pipe\"
		^super relativeNameFor: path "e.g., \windows\"].
	(path size >= 2 and:[(path at: 2) = $: and:[path first isLetter]])
		ifTrue:[^super relativeNameFor: (path copyFrom: 3 to: path size) ]. "e.g., c:"
	^pathName asSqueakPathName, self slash, path
]

{ #category : #'path access' }
DosFileDirectory >> relativeNameIfAbsoluteFor: aFileName [
	"Answer either the relative name for aFileName, if aFileName names a file in me or
	 subdirectories, or aFileName's absolute path if it isn't in me or subdirectories.
	 P.S. Ths is what I'd expect relativeNameFor: to do, but it is taken and means
	 exactly the opposite, i.e. the absolute path for a relative name."
	| fullNameSize fullName fileNameSize |
	(aFileName isEmpty or: [aFileName first ~= self driveName first]) ifTrue:
		[self error: 'this method expects an absolute filename'].
	fullNameSize := (fullName := self fullName) size.
	fileNameSize := aFileName size.
	^(aFileName beginsWith: fullName)
		ifTrue: [(fileNameSize = fullNameSize
				or: [fileNameSize - 1 = fullNameSize
					and: [(aFileName at: fileNameSize) = self pathNameDelimiter]])
					ifTrue: [self class currentDirectoryNickname]
					ifFalse: [aFileName copyFrom: fullNameSize + 2 to: fileNameSize]]
		ifFalse: [aFileName]

	"SourceFiles asArray collect: [:sf| FileDirectory default relativeNameIfAbsoluteFor: sf fullName]"
	"FileDirectory default relativeNameIfAbsoluteFor: FileDirectory default fullName" "should be dot"
	"FileDirectory default relativeNameIfAbsoluteFor: FileDirectory default fullName, FileDirectory default slash" "should also be dot"
]

{ #category : #private }
DosFileDirectory >> setPathName: pathString [
	"Ensure pathString is absolute - relative directories aren't supported on all platforms."

	(pathString isEmpty
		or: [pathString first = $\
			or: [pathString size >= 2 and: [pathString second = $: and: [pathString first isLetter]]]])
				ifTrue: [^ super setPathName: pathString].

	self error: 'Fully qualified path expected'
]
