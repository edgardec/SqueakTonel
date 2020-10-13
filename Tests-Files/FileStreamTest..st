Class {
	#name : #FileStreamTest,
	#superclass : #ClassTestCase,
	#category : #'Tests-Files'
}

{ #category : #tests }
FileStreamTest >> testCachingNextChunkPut [
	"Ensure that nextChunkPut:/nextChunk works properly on a caching file"
	| file text read |
	[file := FileStream forceNewFileNamed: 'testCachingNextChunkPut'.
	text := 'this is a chunkful of text'.
	file nextChunkPut: text.
	read := [file position: 0; nextChunkText] valueWithin: 1 seconds onTimeout:[''].
	self assert: read = text.
	] ensure:[file close. FileDirectory default deleteFileNamed: file name ifAbsent:[]].
]

{ #category : #tests }
FileStreamTest >> testDetectFileDo [
	"Mantis #1838"
	
	| filename |
	filename := 'filestream.tst'.
	
	[(FileDirectory default forceNewFileNamed: filename)
		nextPutAll: '42';
		close.
		
	FileStream 
		detectFile: [FileDirectory default oldFileNamed: filename]
		do: [:file |
			self assert: file notNil.
			self deny: file closed.
			self assert: file contentsOfEntireFile = '42']]
	
		ensure: [FileDirectory default deleteFileNamed: filename ifAbsent: [] ]
]

{ #category : #tests }
FileStreamTest >> testFileTruncation [
	"Ensure that nextChunkPut:/nextChunk works properly on a caching file"
	| file |
	file := nil.
	[	
		file := FileDirectory default forceNewFileNamed: 'TruncationTest.txt'.
		file nextPutAll: '1234567890'.
	] ensure: [file close].
	[
		file := FileDirectory default oldFileNamed: 'TruncationTest.txt'.
		self should: [file contents = '1234567890'].
		file truncate: 4.
	] ensure: [file close].
	[
		file := FileDirectory default readOnlyFileNamed: 'TruncationTest.txt'.
		self should: [file contents = '1234'].
	] ensure: [
		file close.
		FileDirectory default deleteFileNamed: file name ifAbsent:[]
	].

]

{ #category : #tests }
FileStreamTest >> testNextChunkOutOfBounds [
	"Ensure that nextChunkPut:/nextChunk works properly on a caching file"
	| file text read |
	[file := FileStream forceNewFileNamed: 'testNextChunkOutOfBounds'.
	text := 'this is a chunkful of text'.
	file nextChunkPut: text.
	read := [file position: 999999; nextChunkText] valueWithin: 1 seconds onTimeout:[nil].
	self assert: read = ''.
	] ensure:[file close. FileDirectory default deleteFileNamed: file name ifAbsent:[]].
]

{ #category : #tests }
FileStreamTest >> testNextLine [
	| filename lines text |
	filename := 'filestream.tst'.
	lines := #('line 1' ' and line 2' '' 'fourth').
	text := lines first , String cr , lines second , String crlf , lines third , String lf , lines fourth.
	
	[ | file |
	(StandardFileStream forceNewFileNamed: filename)
		nextPutAll: text;
		close.
		
	file := StandardFileStream readOnlyFileNamed: filename.
	lines do: [:e |
		self assert: file nextLine = e].
	self assert: file nextLine = nil.
	file close]
		ensure: [FileDirectory default deleteFileNamed: filename ifAbsent: [] ]
]

{ #category : #tests }
FileStreamTest >> testPositionPastEndIsAtEnd [
	"Tests that a file positioned after its end responds true to #atEnd"

	| filename file |
	filename := 'filestream.tst'.
	file := StandardFileStream forceNewFileNamed: filename.
	[
		file position: 1000.
		self assert: file atEnd.
	] ensure:[
		file close.
		FileDirectory default deleteFileNamed: filename ifAbsent:[].
	].
]

{ #category : #tests }
FileStreamTest >> testReadIntoStartingAtCount [
	| filename file |
	filename := 'filestream.tst'.
	[ | writeBuffer readBuffer bytesRead |
	writeBuffer := (ByteArray new: 2500)
		 atAllPut: 1 ;
		 yourself.
	(StandardFileStream forceNewFileNamed: filename)
		 binary ;
		 nextPutAll: writeBuffer ;
		 close.
	file := StandardFileStream readOnlyFileNamed: filename.
	readBuffer := ByteArray new: 400.
	bytesRead := file
		readInto: readBuffer
		startingAt: 10
		count: 100.
	self assert: bytesRead = 100.
	"quick test"
	self assert: (readBuffer occurrencesOf: 1) = 100.
	"compare test"
	1 to: readBuffer size do:
		[ : n | self assert:
			(readBuffer at: n) = ((n between: 10 	and: 10 + 100 - 1)
				ifTrue: [ writeBuffer at: n ]
				ifFalse: [ 0 ]) ] ]
	ensure:
		[ file ifNotNil: [ file close ].
		FileDirectory default
			deleteFileNamed: filename
			ifAbsent: [ "ok" ] ]
]
