Class {
	#name : #FileBasedHelpTopic,
	#superclass : #AbstractHelpTopic,
	#instVars : [
		'contents',
		'fileEntry',
		'sortBlock'
	],
	#category : #'HelpSystem-Core-Model'
}

{ #category : #comparing }
FileBasedHelpTopic >> <= anotherTopic [

	^ self class == anotherTopic class
		ifTrue: [self sortBlock value: self value: anotherTopic]
		ifFalse: [super <= anotherTopic]
]

{ #category : #editing }
FileBasedHelpTopic >> accept: newContents for: subtopic [

	FileStream forceNewFileNamed: self fileEntry fullName do: [:strm |
		strm nextChunkPutWithStyle: newContents].
	
	
]

{ #category : #accessing }
FileBasedHelpTopic >> contents [

	^ contents ifNil: [
		[contents := fileEntry readStream nextChunkText withSqueakLineEndings]
			on: InvalidUTF8
			do: [:err | ('Invalid UTF8 contents! Please check ', self fileEntry fullName) asText addAttribute: TextColor red]]
]

{ #category : #accessing }
FileBasedHelpTopic >> fileEntry [
	^ fileEntry
]

{ #category : #accessing }
FileBasedHelpTopic >> fileEntry: aFileEntry [
	fileEntry := aFileEntry.
	contents := nil.
]

{ #category : #testing }
FileBasedHelpTopic >> isEditable [

	^ true
]

{ #category : #accessing }
FileBasedHelpTopic >> key [

	^ self fileEntry fullName
]

{ #category : #updating }
FileBasedHelpTopic >> refresh [

	contents := nil.
	self changed: #contents.
]

{ #category : #accessing }
FileBasedHelpTopic >> sortBlock [
	^ sortBlock ifNil: [sortBlock := [:a :b | true]]
]

{ #category : #accessing }
FileBasedHelpTopic >> sortBlock: aBlock [
	sortBlock := aBlock.
]

{ #category : #accessing }
FileBasedHelpTopic >> title [

	^ self fileEntry name
]
