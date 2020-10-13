"
A MCDirectoryRepository that looks in subdirectories too.
"
Class {
	#name : #MCSubDirectoryRepository,
	#superclass : #MCDirectoryRepository,
	#category : #'Monticello-Repositories'
}

{ #category : #'user interface' }
MCSubDirectoryRepository class >> description [
	^ 'directory with subdirectories'
]

{ #category : #enumerating }
MCSubDirectoryRepository >> allDirectories [
	| remaining dir dirs |
	remaining := OrderedCollection new.
	dirs := OrderedCollection new.
	remaining addLast: directory.
	[remaining isEmpty]
		whileFalse: [dir := remaining removeFirst.
			dirs add: dir.
			dir entries
				do: [:ent | ent isDirectory
						ifTrue: [remaining
								addLast: (dir directoryNamed: ent name)]]].
	^ dirs
]

{ #category : #enumerating }
MCSubDirectoryRepository >> allFileNames [
	"sorting {entry. dirName. name}"

	| result |
	result := OrderedCollection new.
	self allDirectories
		do: [:dir | dir entries
				do: [:ent | ent isDirectory
						ifFalse: [result addLast: {ent. dir fullName. ent name}]]].
	^result
		sort: [:a :b | a first modificationTime >= b first modificationTime ];
		replace: [:ea | ea third asMCVersionName]
]

{ #category : #'user interface' }
MCSubDirectoryRepository >> description [
	^ directory pathName, FileDirectory slash, '*'
]

{ #category : #private }
MCSubDirectoryRepository >> findFullNameForReading: aBaseName [
	"Answer the latest version of aBaseName"
	| possible |
	possible := OrderedCollection new.
	self allDirectories
		do: [:dir | dir entries
				do: [:ent | ent isDirectory
						ifFalse: [
							(ent name = aBaseName) ifTrue: [ possible addLast: {ent. dir fullNameFor: ent name}]]]].
	possible isEmpty ifTrue: [ ^nil ].
	^(possible detectMin: [ :each | each first modificationTime ]) second
]

{ #category : #private }
MCSubDirectoryRepository >> findFullNameForWriting: aBaseName [

	| possible split prefix fpattern now |
	split := directory splitNameVersionExtensionFor: aBaseName.
	fpattern := split first, '*'.
	possible := OrderedCollection new.
	now := Time totalSeconds.
	prefix := directory pathParts size.
	self allDirectories do: [:dir | | parts dirScore fileScore |
		parts := dir pathParts allButFirst: prefix.
		dirScore := (parts select: [ :part | fpattern match: part ]) size.
		fileScore := (dir entries collect: [ :ent |
			(ent isDirectory not and: [ fpattern match: ent name ])
				ifFalse: [ SmallInteger maxVal ]
				ifTrue: [ now - ent modificationTime ]]).	"minimum age"
		fileScore := fileScore isEmpty ifTrue: [ SmallInteger maxVal  ]
			ifFalse: [ fileScore min ].
		possible add: { dirScore. fileScore. dir } ].
	possible
		sort: [ :a :b |
			a first = b first
				ifTrue: [ a second = b second
						ifFalse: [ a second < b second ]
						ifTrue: [ a third fullName size < b third fullName size ]]
				ifFalse: [ a first > b first ] ].
	^(possible first third) fullNameFor: aBaseName
]

{ #category : #private }
MCSubDirectoryRepository >> readStreamForFileNamed: aString do: aBlock [
	| file val |
	file := FileStream readOnlyFileNamed: (self findFullNameForReading: aString).
	val := aBlock value: file.
	file close.
	^ val
]

{ #category : #private }
MCSubDirectoryRepository >> writeStreamForFileNamed: aString replace: aBoolean do: aBlock [ 
	| file |
	file := aBoolean
				ifTrue: [FileStream
						forceNewFileNamed: (self findFullNameForReading: aString)]
				ifFalse: [FileStream
						newFileNamed: (self findFullNameForWriting: aString)].
	aBlock value: file.
	file close
]
