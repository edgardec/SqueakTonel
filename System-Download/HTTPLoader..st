Class {
	#name : #HTTPLoader,
	#superclass : #Object,
	#instVars : [
		'requests',
		'downloads'
	],
	#classVars : [
		'DefaultLoader',
		'MaxNrOfConnections'
	],
	#category : #'System-Download'
}

{ #category : #accessing }
HTTPLoader class >> default [
	DefaultLoader ifNil: [
		DefaultLoader := HTTPLoader new].
	^DefaultLoader
]

{ #category : #accessing }
HTTPLoader class >> httpRequestClass [
	^HTTPDownloadRequest
]

{ #category : #'class initialization' }
HTTPLoader class >> initialize [
	"HTTPLoader initialize"

	MaxNrOfConnections := 4.
	DefaultLoader ifNotNil: [
		DefaultLoader release.
		DefaultLoader := nil]
]

{ #category : #requests }
HTTPLoader >> abort [
	| oldRequests |
	"Abort all requests"
	oldRequests := requests.
	requests := SharedQueue new.
	[oldRequests isEmpty] whileFalse: [
		oldRequests next signalAbort].
	downloads do: [:each | each ifNotNil: [each terminate]].
	downloads := OrderedCollection new

]

{ #category : #private }
HTTPLoader >> addRequest: aHTTPRequest [
	requests nextPut: aHTTPRequest.
	self startDownload
]

{ #category : #'initialize\/release' }
HTTPLoader >> initialize [
	requests := SharedQueue new.
	downloads := OrderedCollection new
]

{ #category : #private }
HTTPLoader >> maxNrOfConnections [
	^MaxNrOfConnections
]

{ #category : #private }
HTTPLoader >> nextRequest [
	^requests next
]

{ #category : #'initialize\/release' }
HTTPLoader >> release [
	self abort.
	downloads := nil.
	requests := nil
]

{ #category : #private }
HTTPLoader >> removeProcess: downloadProcess [
	downloads remove: downloadProcess ifAbsent: []
]

{ #category : #private }
HTTPLoader >> removeRequest: request [
	requests remove: request
]

{ #category : #requests }
HTTPLoader >> retrieveContentsFor: url [
	| request |
	request := self class httpRequestClass for: url in: self.
	self addRequest: request.
	^request contents
]

{ #category : #requests }
HTTPLoader >> retrieveObjectsFor: aURL [
	"Load a remote image segment and extract the root objects.
	Check if the remote file is a zip archive."
	"'http://bradley.online.disney.com/games/subgame/squeak-test/assetInfo.extSeg' 
		asUrl loadRemoteObjects" 
	"'http://bradley.online.disney.com/games/subgame/squeak-test/assetInfo.zip' 
		asUrl loadRemoteObjects" 

	| stream info data |
 	data := self retrieveContentsFor: aURL.
	(data isString)
		ifTrue: [^self error: data]
		ifFalse: [data := data content].
	(data beginsWith: 'error')
		ifTrue: [^self error: data].
	data := data unzipped.
	stream := RWBinaryOrTextStream on: data.
	stream reset.
	info := stream fileInObjectAndCode.
	stream close.
	^info originalRoots
]

{ #category : #private }
HTTPLoader >> startDownload [
	| newDownloadProcess |
	
	downloads size >= self maxNrOfConnections ifTrue: [^self].
	requests size <= 0 ifTrue: [^self].

	newDownloadProcess := [
		[
			self nextRequest startRetrieval
		] on: FTPConnectionException do: [ :ex | 
			Cursor normal show.
			self removeProcess: Processor activeProcess.
			self startDownload
		].
		self removeProcess: Processor activeProcess.
		self startDownload
	] newProcess.
	downloads add: newDownloadProcess.
	newDownloadProcess resume
]
