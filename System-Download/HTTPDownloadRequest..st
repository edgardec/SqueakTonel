Class {
	#name : #HTTPDownloadRequest,
	#superclass : #Object,
	#instVars : [
		'semaphore',
		'url',
		'content',
		'loader',
		'process'
	],
	#category : #'System-Download'
}

{ #category : #'instance creation' }
HTTPDownloadRequest class >> for: aUrl in: aLoader [
	^self new for: aUrl in: aLoader
]

{ #category : #accessing }
HTTPDownloadRequest >> content: retrievedContent [
	content := retrievedContent.
	semaphore signal
]

{ #category : #accessing }
HTTPDownloadRequest >> contentStream [
	"Return a stream on the content of a previously completed HTTP request"
	semaphore wait.
	^content ifNotNil:[content contentStream]
]

{ #category : #accessing }
HTTPDownloadRequest >> contents [
	semaphore wait.
	^content
]

{ #category : #initialize }
HTTPDownloadRequest >> for: aUrl in: aLoader [
	url := aUrl.
	loader := aLoader.
	semaphore := Semaphore new.
]

{ #category : #private }
HTTPDownloadRequest >> httpEncodeSafely: aUrl [
	"Encode the url but skip $/ and $:."

	| unescaped |
	unescaped := aUrl unescapePercents.

	^ unescaped encodeForHTTPWithTextEncoding: 'utf-8'
		conditionBlock: [:c | c isSafeForHTTP or: [c = $/ or: [c = $:]]].

]

{ #category : #testing }
HTTPDownloadRequest >> isSemaphoreSignaled [
	"Return true if the associated semaphore is currently signaled. This information can be used to determine whether the download has finished given that there is no other process waiting on the semaphore."
	^semaphore isSignaled
]

{ #category : #accessing }
HTTPDownloadRequest >> process: aProcess [
	process := aProcess
]

{ #category : #accessing }
HTTPDownloadRequest >> signalAbort [
	loader removeProcess: process.
	self content: 'Retrieval aborted'.
	process ifNotNil: [process terminate]
]

{ #category : #accessing }
HTTPDownloadRequest >> startRetrieval [
	self content: url asUrl retrieveContents
]
