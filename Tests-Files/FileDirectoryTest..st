Class {
	#name : #FileDirectoryTest,
	#superclass : #ClassTestCase,
	#category : #'Tests-Files'
}

{ #category : #running }
FileDirectoryTest >> deleteDirectory [
	
	(self myDirectory exists) ifTrue:	[self myDirectory recursiveDelete]
]

{ #category : #resources }
FileDirectoryTest >> myAssuredDirectory [

	^self myDirectory assureExistence
]

{ #category : #resources }
FileDirectoryTest >> myDirectory [

	^FileDirectory default directoryNamed: self myLocalDirectoryName
]

{ #category : #resources }
FileDirectoryTest >> myLocalDirectoryName [

	^'zTestDir'
]

{ #category : #running }
FileDirectoryTest >> tearDown [

	[ self deleteDirectory ] on: Error do: [ :ex | ]
]

{ #category : #'tests - existence' }
FileDirectoryTest >> testAttemptExistenceCheckWhenFile [
	"How should a FileDirectory instance respond with an existent file name?"
	
	| directory filename |
	
	filename := 'aTestFile'.
	FileDirectory default forceNewFileNamed: filename.
	directory := FileDirectory default directoryNamed: filename.
	self shouldnt: [directory exists] description: 'Files are not directories.'.
	
	"clean up disk"
	FileDirectory default deleteFileNamed: filename ifAbsent: [ ]
]

{ #category : #'tests - create\/delete' }
FileDirectoryTest >> testDeleteDirectory [
	"Test deletion of a directory"
	
	| aContainingDirectory preTestItems |
	aContainingDirectory := self myDirectory containingDirectory.
	preTestItems := aContainingDirectory fileAndDirectoryNames.
	self myAssuredDirectory.
	
	aContainingDirectory deleteDirectory: self myLocalDirectoryName.

	self 
		shouldnt: [aContainingDirectory directoryNames includes: self myLocalDirectoryName ]
		description: 'Should successfully delete directory.'.
	self 
		should: [preTestItems = aContainingDirectory fileAndDirectoryNames]
		description: 'Should only delete the indicated directory.'.

	
	
]

{ #category : #'tests - existence' }
FileDirectoryTest >> testDirectoryExists [

	self assert: self myAssuredDirectory exists.
	self should: [self myDirectory containingDirectory 
					directoryExists: self myLocalDirectoryName].

	self myDirectory containingDirectory deleteDirectory: self myLocalDirectoryName.
	self shouldnt: [self myDirectory containingDirectory 
						directoryExists: self myLocalDirectoryName]
]

{ #category : #'tests - existence' }
FileDirectoryTest >> testDirectoryExistsWhenLikeNamedFileExists [

[ | testFileName |
testFileName := self myAssuredDirectory fullNameFor: 'zDirExistsTest.testing'.
(FileStream newFileNamed: testFileName) close.

self should: [FileStream isAFileNamed: testFileName].
self shouldnt: [(FileDirectory on: testFileName) exists]]
ensure: [self myAssuredDirectory deleteFileNamed: 'zDirExistsTest.testing']


]

{ #category : #'tests - existence' }
FileDirectoryTest >> testDirectoryNamed [

	self should: [(self myDirectory containingDirectory 
					directoryNamed: self myLocalDirectoryName) pathName 
						= self myDirectory pathName]
]

{ #category : #'tests - existence' }
FileDirectoryTest >> testDirectoryNicknames [

	| defaultDirectory |
	defaultDirectory := FileDirectory default.
	#('/.' '/../../.' '/././.') 
		collect: [ :each | each copyReplaceAll: '/' with: FileDirectory slash ]
		thenDo: [:each |
			self assert: (defaultDirectory directoryExists: defaultDirectory fullName, each) description: 'Nickname of "', each, '"'. ]
]

{ #category : #tests }
FileDirectoryTest >> testEquality [

	self assert: FileDirectory default = FileDirectory default.
	self deny: FileDirectory default = FileDirectory default containingDirectory.
	self deny: FileDirectory default = nil
]

{ #category : #'tests - existence' }
FileDirectoryTest >> testExists [

	self should: [FileDirectory default exists]
		description: 'Should know default directory exists.'.
	self should: [self myAssuredDirectory exists]
		description: 'Should know created directory exists.'.

	self myDirectory containingDirectory deleteDirectory: self myLocalDirectoryName.
	self shouldnt: [(self myDirectory containingDirectory directoryNamed: self myLocalDirectoryName) exists]
		description: 'Should know that recently deleted directory no longer exists.'.
]

{ #category : #tests }
FileDirectoryTest >> testListEntries [

	self myAssuredDirectory createDirectory: 'foobar'.
	self myAssuredDirectory createDirectory: 'b'.
	self myAssuredDirectory fileNamed: 'test.file' do: [:str | 
		str << 'test content'].
	self 
		assert: 3 equals: self myAssuredDirectory entries size
		description: '#entries should list all contained directory entries'
]

{ #category : #'tests - existence' }
FileDirectoryTest >> testNonExistentDirectory [

	| directory parentDirectory |
	directory :=FileDirectory default
				directoryNamed: 'nonExistentFolder'.
	self shouldnt: [directory exists] 
		description: 'A FileDirectory instance should know if it points to a non-existent directory.'.

	parentDirectory :=FileDirectory default.
	self shouldnt: [parentDirectory directoryExists: 'nonExistentFolder'] 
		description: 'A FileDirectory instance should know when a directory of the given name doesn''t exist'.

]

{ #category : #'tests - existence' }
FileDirectoryTest >> testOldFileOrNoneNamed [

	| file |
	file := self myAssuredDirectory oldFileOrNoneNamed: 'test.txt'.
	[self assert: file isNil.
	
	"Reproduction of Mantis #1049"
	(self myAssuredDirectory fileNamed: 'test.txt')
		nextPutAll: 'foo';
		close.
		
	file := self myAssuredDirectory oldFileOrNoneNamed: 'test.txt'.
	self assert: file notNil]
		ensure: [
			file ifNotNil: [file close].
			self myAssuredDirectory deleteFileNamed: 'test.txt' ifAbsent: nil]
	

]

{ #category : #tests }
FileDirectoryTest >> testRelativeNameIfAbsoluteFor [
	| cwd notcwd |
	cwd := FileDirectory default.
	self assert: (cwd relativeNameIfAbsoluteFor: cwd fullName) = cwd class currentDirectoryNickname. 
	self assert: (cwd relativeNameIfAbsoluteFor: cwd fullName, cwd slash) = cwd class currentDirectoryNickname. 
	self assert: (cwd relativeNameIfAbsoluteFor: cwd fullName, cwd slash, 'foo', cwd slash, 'bar') = ('foo', cwd slash, 'bar').
	notcwd := cwd fullName copy. "Argh!!!"
	notcwd at: notcwd size put: (($a to: $z) detect: [:i| notcwd last ~= i]).
	self assert: (cwd relativeNameIfAbsoluteFor: notcwd) = notcwd
]

{ #category : #tests }
FileDirectoryTest >> testRelativePaths [
	| myDirViaContainer |
	self assert: (FileDirectory default on: self myLocalDirectoryName) fullName = self myDirectory fullName.
	self assert: (FileDirectory default on: self myLocalDirectoryName) = self myDirectory.
	myDirViaContainer := FileDirectory default localName, FileDirectory default slash, self myLocalDirectoryName.
	self assert: (FileDirectory default containingDirectory on: myDirViaContainer) fullName = self myDirectory fullName.
	self assert: (FileDirectory default containingDirectory on: myDirViaContainer) = self myDirectory
]
