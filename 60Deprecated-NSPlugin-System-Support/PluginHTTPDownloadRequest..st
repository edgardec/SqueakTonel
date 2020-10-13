"
HTTPBrowserRequest attempts to fetch the contents through a Webbrowser. This works transparently if Squeak is not running in the browser.
"
Class {
	#name : #PluginHTTPDownloadRequest,
	#superclass : #HTTPDownloadRequest,
	#instVars : [
		'fileStream'
	],
	#category : #'60Deprecated-NSPlugin-System-Support'
}

{ #category : #accessing }
PluginHTTPDownloadRequest >> contentStream [
	semaphore wait.
	fileStream
		ifNotNil: [^ fileStream].
	^ content
		ifNotNil: [content isString
				ifTrue: [self error: 'Error loading ' , self url printString]
				ifFalse: [content contentStream]]
]

{ #category : #accessing }
PluginHTTPDownloadRequest >> contents [
	| |
	semaphore wait.
	(content isNil and:[fileStream notNil]) ifTrue:[
"		pos := fileStream position."
		fileStream position: 0.
		content := MIMEDocument content: fileStream upToEnd.
		fileStream close.
	].
	^content
]

{ #category : #accessing }
PluginHTTPDownloadRequest >> maxAttempts [
	"Return the number of attempts to retry before giving up"
	^3
]

{ #category : #accessing }
PluginHTTPDownloadRequest >> signalAbort [
	fileStream ifNotNil: [
		fileStream close].
	fileStream := nil.
	super signalAbort.
]

{ #category : #accessing }
PluginHTTPDownloadRequest >> startRetrieval [
	| attempts |
	attempts := self maxAttempts.
	"Note: Only the first request may fail due to not running in a browser"
	url first = $/
		ifTrue: [url := url copyFrom: 2 to: url size].
	fileStream := FileStream requestURLStream: url ifError:[^super startRetrieval].
	[fileStream == nil] whileTrue:[
		attempts := attempts - 1.
		attempts = 0 ifTrue:[^self content:'Error downloading file'].
		fileStream := FileStream requestURLStream: url].
	semaphore signal.
]
