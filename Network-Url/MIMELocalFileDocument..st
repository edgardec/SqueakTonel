"
For local files, we do not read the entire contents unless we absolutely have to.
"
Class {
	#name : #MIMELocalFileDocument,
	#superclass : #MIMEDocument,
	#instVars : [
		'contentStream'
	],
	#category : #'Network-Url'
}

{ #category : #'instance creation' }
MIMELocalFileDocument class >> contentType: aString contentStream: aStream [
	^(self contentType: aString content: nil) contentStream: aStream
]

{ #category : #accessing }
MIMELocalFileDocument >> content [
	^content ifNil:[content := contentStream contentsOfEntireFile].
]

{ #category : #accessing }
MIMELocalFileDocument >> contentStream [
	^contentStream ifNil:[super contentStream]
]

{ #category : #accessing }
MIMELocalFileDocument >> contentStream: aFileStream [
	contentStream := aFileStream.
	content := nil.
]
