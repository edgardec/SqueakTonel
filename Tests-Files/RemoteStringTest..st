Class {
	#name : #RemoteStringTest,
	#superclass : #TestCase,
	#category : #'Tests-Files'
}

{ #category : #tests }
RemoteStringTest >> testMultipleStringWritesAndReadUsingDifferentFiles [

	| changesFileIndex sourceFile readOnlySourceFile stringsToWrite writtenRemoteStrings |
	changesFileIndex := 2.
	sourceFile := SourceFiles at: changesFileIndex.
	"Ensure that CurrentReadOnlySourceFile is opened."
	readOnlySourceFile := CurrentReadOnlySourceFiles at: changesFileIndex.
	"Write a new string."
	stringsToWrite := (1 to: 5) collect: [ :each |
		Time utcMicrosecondClock asString, '_', each asString ].
	writtenRemoteStrings := stringsToWrite collect: [ :each |
		RemoteString 
			newString: each
			onFileNumber: changesFileIndex
			toFile: sourceFile ].
	"Read the new chunk from CurrentReadOnlySourceFile."
	writtenRemoteStrings size to: 1 by: -1 do: [ :index |
		| writtenRemoteString readOnlyRemoteString |
		writtenRemoteString := writtenRemoteStrings at: index.
		readOnlyRemoteString := RemoteString
			newFileNumber: changesFileIndex
			position: writtenRemoteString position.
		self assert: (stringsToWrite at: index) equals: readOnlyRemoteString text asString ]
]

{ #category : #tests }
RemoteStringTest >> testStringWriteAndReadUsingDifferentFiles [

	| changesFileIndex sourceFile readOnlySourceFile stringToWrite writtenRemoteString readOnlyRemoteString |
	changesFileIndex := 2.
	sourceFile := SourceFiles at: changesFileIndex.
	"Ensure that CurrentReadOnlySourceFile is opened."
	readOnlySourceFile := CurrentReadOnlySourceFiles at: changesFileIndex.
	"Write a new string."
	stringToWrite := Time utcMicrosecondClock asString.
	writtenRemoteString := RemoteString 
		newString: stringToWrite
		onFileNumber: changesFileIndex
		toFile: sourceFile.
	"Read the new chunk from CurrentReadOnlySourceFile."
	readOnlyRemoteString := RemoteString
		newFileNumber: changesFileIndex
		position: writtenRemoteString position.
	self assert: stringToWrite equals: readOnlyRemoteString text asString
]
