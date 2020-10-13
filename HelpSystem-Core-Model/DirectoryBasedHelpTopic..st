Class {
	#name : #DirectoryBasedHelpTopic,
	#superclass : #AbstractHelpTopic,
	#instVars : [
		'directoryEntry',
		'title',
		'filter',
		'sortBlock',
		'subtopics'
	],
	#category : #'HelpSystem-Core-Model'
}

{ #category : #comparing }
DirectoryBasedHelpTopic >> <= anotherTopic [

	^ anotherTopic class == FileBasedHelpTopic
		ifTrue: [true]
		ifFalse: [super <= anotherTopic]
]

{ #category : #editing }
DirectoryBasedHelpTopic >> accept: newContents for: subtopic [

	FileStream forceNewFileNamed: subtopic fileEntry fullName do: [:strm |
		strm nextChunkPutWithStyle: newContents].
	
	
]

{ #category : #accessing }
DirectoryBasedHelpTopic >> contents [

	^ self directoryEntry
		ifNil: ['This directory-based help topic has no valid directory entry set.' translated]
		ifNotNil: ['This is a directory-based help topic. It''s contents are in ', self directoryEntry fullName]
]

{ #category : #accessing }
DirectoryBasedHelpTopic >> directoryEntry [
	^ directoryEntry
]

{ #category : #accessing }
DirectoryBasedHelpTopic >> directoryEntry: aDirectoryEntry [
	directoryEntry := aDirectoryEntry.
]

{ #category : #accessing }
DirectoryBasedHelpTopic >> filter [

	^ filter ifNil: [filter := '*.*']
]

{ #category : #accessing }
DirectoryBasedHelpTopic >> filter: aFilterPattern [

	filter := aFilterPattern.
]

{ #category : #testing }
DirectoryBasedHelpTopic >> isEditable [
	^ true
]

{ #category : #updating }
DirectoryBasedHelpTopic >> refresh [

	subtopics := nil.
	self changed: #subtopicsUpdated.
]

{ #category : #accessing }
DirectoryBasedHelpTopic >> sortBlock [
	^ sortBlock ifNil: [ sortBlock := [:a :b | true] ]
]

{ #category : #accessing }
DirectoryBasedHelpTopic >> sortBlock: aBlock [
	sortBlock := aBlock.
]

{ #category : #accessing }
DirectoryBasedHelpTopic >> subtopics [

	| directory |
	subtopics ifNotNil: [^ subtopics].
	self directoryEntry ifNil: [^ #()].
	
	directory := self directoryEntry asFileDirectory.
	^ subtopics := (directory entries
		select: [:ea | ea isDirectory]
		thenCollect: [:ea | DirectoryBasedHelpTopic new directoryEntry: ea]),
	
	((directory fileNamesMatching: self filter)
		collect: [:fileName | FileBasedHelpTopic new
			fileEntry: (directory entryAt: fileName);
			sortBlock: self sortBlock])
]

{ #category : #accessing }
DirectoryBasedHelpTopic >> title [
	^ title ifNil: [self directoryEntry ifNil: ['(invalid)'] ifNotNil: [:d | d name]]
]

{ #category : #accessing }
DirectoryBasedHelpTopic >> title: aString [
	title := aString.
]
