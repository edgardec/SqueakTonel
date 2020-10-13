Class {
	#name : #DosFileDirectoryTests,
	#superclass : #TestCase,
	#category : #'Tests-Files'
}

{ #category : #tests }
DosFileDirectoryTests >> testFileDirectoryContainingDirectory [
	"Hoping that you have 'C:' of course..."
	| fd |
	FileDirectory activeDirectoryClass == DosFileDirectory ifFalse:[^self].
	fd := FileDirectory on: 'C:'.
	self assert: fd containingDirectory pathName = ''.

]

{ #category : #tests }
DosFileDirectoryTests >> testFileDirectoryContainingDirectoryExistence [
	"Hoping that you have 'C:' of course..."
	| fd |
	FileDirectory activeDirectoryClass == DosFileDirectory ifFalse:[^self].
	fd := FileDirectory on: 'C:'.
	self assert: (fd containingDirectory fileOrDirectoryExists: 'C:').
]

{ #category : #tests }
DosFileDirectoryTests >> testFileDirectoryContainingEntry [
	"Hoping that you have 'C:' of course..."
	| fd |
	FileDirectory activeDirectoryClass == DosFileDirectory ifFalse:[^self].
	fd := FileDirectory on: 'C:'.
	self assert: (fd containingDirectory entryAt: fd localName) notNil.

]

{ #category : #tests }
DosFileDirectoryTests >> testFileDirectoryDirectoryEntry [
	"Hoping that you have 'C:' of course..."
	| fd |
	FileDirectory activeDirectoryClass == DosFileDirectory ifFalse:[^self].
	fd := FileDirectory on: 'C:'.
	self assert: fd directoryEntry notNil.
]

{ #category : #tests }
DosFileDirectoryTests >> testFileDirectoryEntryFor [
	"Hoping that you have 'C:' of course..."
	| fd |
	FileDirectory activeDirectoryClass == DosFileDirectory ifFalse:[^self].
	fd := FileDirectory root directoryEntryFor: 'C:'.
	self assert: (fd name sameAs: 'C:').
]

{ #category : #tests }
DosFileDirectoryTests >> testFileDirectoryExists [
	"Hoping that you have 'C:' of course..."
	FileDirectory activeDirectoryClass == DosFileDirectory ifFalse:[^self].
	self assert: (FileDirectory root directoryExists: 'C:').
]

{ #category : #tests }
DosFileDirectoryTests >> testFileDirectoryLocalName [
	"Hoping that you have 'C:' of course..."
	| fd |
	FileDirectory activeDirectoryClass == DosFileDirectory ifFalse:[^self].
	fd := FileDirectory on: 'C:'.
	self assert: fd localName = 'C:'.

]

{ #category : #tests }
DosFileDirectoryTests >> testFileDirectoryNamed [
	"Hoping that you have 'C:' of course..."
	| fd |
	FileDirectory activeDirectoryClass == DosFileDirectory ifFalse:[^self].
	fd := FileDirectory root directoryNamed: 'C:'.
	self assert: fd pathName = 'C:'.
]

{ #category : #tests }
DosFileDirectoryTests >> testFileDirectoryNonExistence [

	| inexistentFileName |
	
	"Hoping that you have 'C:' of course..."
	FileDirectory activeDirectoryClass == DosFileDirectory ifFalse:[^self].
	
	inexistentFileName := DosFileDirectory default nextNameFor: 'DosFileDirectoryTest' extension: 'temp'.
	
	"This test can fail if another process creates a file with the same name as inexistentFileName
	(the probability of that is very very remote)"

	self deny: (DosFileDirectory default fileOrDirectoryExists: inexistentFileName)
]

{ #category : #tests }
DosFileDirectoryTests >> testFileDirectoryRootExistence [
	"Hoping that you have 'C:' of course..."
	FileDirectory activeDirectoryClass == DosFileDirectory ifFalse:[^self].
	self assert: (FileDirectory root fileOrDirectoryExists: 'C:').
]

{ #category : #tests }
DosFileDirectoryTests >> testFullNameFor [
	"Hoping that you have 'C:' of course..."
	FileDirectory activeDirectoryClass == DosFileDirectory ifFalse:[^self].
	self assert: (FileDirectory default fullNameFor: 'C:') = 'C:'.
	self assert: (FileDirectory default fullNameFor: 'C:\test') = 'C:\test'.
	self assert: (FileDirectory default fullNameFor: '\\share') = '\\share'.
	self assert: (FileDirectory default fullNameFor: '\\share\test') = '\\share\test'.
	self assert: (FileDirectory default fullNameFor: '\test') = (FileDirectory default pathParts first, '\test').

]

{ #category : #tests }
DosFileDirectoryTests >> testIsDriveForDrive [
	self assert: (DosFileDirectory isDrive: 'C:').
	self deny: (DosFileDirectory isDrive: 'C:\').
	self deny: (DosFileDirectory isDrive: 'C:\foo').
	self deny: (DosFileDirectory isDrive: 'C:foo').
]

{ #category : #tests }
DosFileDirectoryTests >> testIsDriveForShare [
	self assert: (DosFileDirectory isDrive: '\\server').
	self deny: (DosFileDirectory isDrive: '\\server\').
	self deny: (DosFileDirectory isDrive: '\\server\foo').

]
