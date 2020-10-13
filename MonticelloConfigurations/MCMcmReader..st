"
A MCMcmReader creates an MCConfiguration by reading an array specification from a stream.


"
Class {
	#name : #MCMcmReader,
	#superclass : #MCVersionReader,
	#instVars : [
		'fileName',
		'configuration'
	],
	#category : #MonticelloConfigurations
}

{ #category : #accessing }
MCMcmReader class >> extension [
	^ 'mcm'
]

{ #category : #'instance creation' }
MCMcmReader class >> loadVersionFile: fileName [
	| version |
	version := self versionFromFile: fileName.
	version load.

]

{ #category : #'instance creation' }
MCMcmReader class >> on: aStream fileName: aFileName [
	| reader |
	reader := self on: aStream.
	reader fileName: aFileName.
	^reader
]

{ #category : #accessing }
MCMcmReader >> configuration [
	configuration ifNil: [self loadConfiguration].
	"browser modifies configuration, but the reader might get cached"
	^configuration copy
]

{ #category : #accessing }
MCMcmReader >> fileName: aString [
	fileName := aString
]

{ #category : #accessing }
MCMcmReader >> loadConfiguration [
	stream reset.
	configuration := MCConfiguration fromArray: (MCScanner scan: stream).
	configuration name ifNil: [ configuration name: self parseNameFromFilename ]
]

{ #category : #accessing }
MCMcmReader >> loadVersionInfo [
	info := self configuration
]

{ #category : #accessing }
MCMcmReader >> parseNameFromFilename [
	^fileName ifNotNil: [(fileName findTokens: '/\:') last copyUpToLast: $.]
]

{ #category : #accessing }
MCMcmReader >> version [
	^self configuration
]
