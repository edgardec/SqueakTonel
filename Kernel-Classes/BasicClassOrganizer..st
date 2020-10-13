Class {
	#name : #BasicClassOrganizer,
	#superclass : #Categorizer,
	#instVars : [
		'subject',
		'classComment',
		'commentStamp'
	],
	#category : #'Kernel-Classes'
}

{ #category : #constants }
BasicClassOrganizer class >> ambiguous [
	^ #ambiguous
]

{ #category : #'instance creation' }
BasicClassOrganizer class >> class: aClassDescription [
	^ self new setSubject: aClassDescription
]

{ #category : #'instance creation' }
BasicClassOrganizer class >> class: aClassDescription defaultList: aSortedCollection [
	| inst |
	inst := self defaultList: aSortedCollection.
	inst setSubject: aClassDescription.
	^ inst
]

{ #category : #accessing }
BasicClassOrganizer >> classComment [
	classComment
		ifNil: [^ ''].
	^ classComment text ifNil: ['']
]

{ #category : #accessing }
BasicClassOrganizer >> classComment: aString [ 
	"Store the comment, aString, associated with the object that refers to the 
	receiver."

	(aString isKindOf: RemoteString) 
		ifTrue: [classComment := aString]
		ifFalse: [(aString == nil or: [aString size = 0])
			ifTrue: [classComment := nil]
			ifFalse: [
				self error: 'use aClass classComment:'.
				classComment := RemoteString newString: aString onFileNumber: 2]]
				"Later add priorSource and date and initials?"
]

{ #category : #accessing }
BasicClassOrganizer >> classComment: aString  stamp: aStamp [
	"Store the comment, aString, associated with the object that refers to the receiver."

	self commentStamp: aStamp.
	(aString isKindOf: RemoteString) 
		ifTrue: [classComment := aString]
		ifFalse: [(aString == nil or: [aString size = 0])
			ifTrue: [classComment := nil]
			ifFalse:
				[self error: 'use aClass classComment:'.
				classComment := RemoteString newString: aString onFileNumber: 2]]
				"Later add priorSource and date and initials?"
]

{ #category : #accessing }
BasicClassOrganizer >> commentRemoteStr [
	^ classComment
]

{ #category : #accessing }
BasicClassOrganizer >> commentStamp [
	"Answer the comment stamp for the class"

	^ commentStamp
]

{ #category : #accessing }
BasicClassOrganizer >> commentStamp: aStamp [
	commentStamp := aStamp
]

{ #category : #accessing }
BasicClassOrganizer >> dateCommentLastSubmitted [
	"Answer a Date object indicating when my class comment was last submitted.  If there is no date stamp, or one of the old-time <historical>  guys, return nil"
	"RecentMessageSet organization dateCommentLastSubmitted"

	| aStamp tokens |
	(aStamp := self commentStamp) isEmptyOrNil ifTrue: [^ nil].
	tokens := aStamp findBetweenSubStrs: ' 
'.  "space is expected delimiter, but cr is sometimes seen, though of mysterious provenance"
	^ tokens size > 1
		ifTrue:
			[[tokens second asDate] ifError: [nil]]
		ifFalse:
			[nil]
]

{ #category : #'fileIn\/Out' }
BasicClassOrganizer >> fileOutCommentOn: aFileStream moveSource: moveSource toFile: fileIndex [
	"Copy the class comment to aFileStream.  If moveSource is true (as in compressChanges or compressSources, then update classComment to point to the new file."
	| fileComment |
	classComment ifNotNil: 
			[aFileStream cr.
			fileComment := RemoteString newString: classComment text
							onFileNumber: fileIndex toFile: aFileStream.
			moveSource ifTrue: [classComment := fileComment]]
]

{ #category : #testing }
BasicClassOrganizer >> hasNoComment [
	"Answer whether the class classified by the receiver has a comment."

	^classComment == nil
]

{ #category : #testing }
BasicClassOrganizer >> hasSubject [
	^ self subject notNil
]

{ #category : #'fileIn\/Out' }
BasicClassOrganizer >> moveChangedCommentToFile: aFileStream numbered: fileIndex [ 
	"If the comment is in the changes file, then move it to a new file."

	(classComment ~~ nil and: [classComment sourceFileNumber > 1]) ifTrue: 
		[self fileOutCommentOn: aFileStream moveSource: true toFile: fileIndex]
]

{ #category : #'fileIn\/Out' }
BasicClassOrganizer >> objectForDataStream: refStrm [
	| dp |
	"I am about to be written on an object file.  Write a path to me in the other system instead."

	self hasSubject ifTrue: [
		(refStrm insideASegment and: [self subject isSystemDefined not]) ifTrue: [
			^ self].	"do trace me"
		(self subject isKindOf: Class) ifTrue: [
			dp := DiskProxy global: self subject name selector: #organization args: #().
			refStrm replace: self with: dp.
			^ dp]].
	^ self	"in desparation"

]

{ #category : #'fileIn\/Out' }
BasicClassOrganizer >> putCommentOnFile: aFileStream numbered: sourceIndex moveSource: moveSource forClass: aClass [
	"Store the comment about the class onto file, aFileStream."
	| header |
	classComment ifNotNil:
		[aFileStream cr; nextPut: $!.
		header := String streamContents: [:strm | 
				strm nextPutAll: aClass name;
				nextPutAll: ' commentStamp: '.
				commentStamp ifNil: [commentStamp := '<historical>'].
				commentStamp storeOn: strm.
				strm nextPutAll: ' prior: '; nextPutAll: '0'].
		aFileStream nextChunkPut: header.
		aClass organization fileOutCommentOn: aFileStream
				moveSource: moveSource toFile: sourceIndex.
		aFileStream cr]
]

{ #category : #private }
BasicClassOrganizer >> setSubject: aClassDescription [
	subject := aClassDescription
]

{ #category : #accessing }
BasicClassOrganizer >> subject [
	^ subject.
]
