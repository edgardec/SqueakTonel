Class {
	#name : #MCSMReleaseRepository,
	#superclass : #MCWriteOnlyRepository,
	#instVars : [
		'packageName',
		'user',
		'password'
	],
	#category : #'Monticello-Repositories'
}

{ #category : #configuring }
MCSMReleaseRepository class >> creationTemplate [
	^
'MCSMReleaseRepository
	package: ''mypackage''
	user: ''squeak''
	password: ''squeak'''
	
]

{ #category : #configuring }
MCSMReleaseRepository class >> description [
	^ 'SqueakMap Release'
]

{ #category : #configuring }
MCSMReleaseRepository class >> fillInTheBlankRequest [
	^  'SqueakMap Release Repository:'
		
]

{ #category : #configuring }
MCSMReleaseRepository class >> morphicConfigure [
	^ self fillInTheBlankConfigure
]

{ #category : #'instance creation' }
MCSMReleaseRepository class >> package: packageString user: userString password: passString [
	^ self basicNew initializeWithPackage: packageString user: userString password: passString
]

{ #category : #private }
MCSMReleaseRepository >> basicStoreVersion: aVersion [
	| url |
	url := self uploadVersion: aVersion.
	self releaseVersion: aVersion url: url
]

{ #category : #private }
MCSMReleaseRepository >> checkResult: resultString [
(#( 'HTTP/1.1 201 ' 'HTTP/1.1 200 ' 'HTTP/1.0 201 ' 'HTTP/1.0 200 ')
		anySatisfy: [:code | resultString beginsWith: code ])
			ifFalse: [self error: resultString].

]

{ #category : #'user interface' }
MCSMReleaseRepository >> description [
	^ 'sm://', packageName
]

{ #category : #private }
MCSMReleaseRepository >> initializeWithPackage: packageString user: userString password: passString [
	packageName := packageString.
	user := userString.
	password := passString.

]

{ #category : #private }
MCSMReleaseRepository >> releaseVersion: aVersion url: urlString [
	| result |
	result := HTTPSocket
		httpPost: self squeakMapUrl, '/packagebyname/', packageName, '/newrelease'
		args: {'version' -> {(aVersion info versionNumber)}.
			   'note' -> {aVersion info message}.
			   'downloadURL' -> {urlString}}
		user: user
		passwd: password.
	result contents size > 4 ifTrue: [self error: result contents]

]

{ #category : #constants }
MCSMReleaseRepository >> squeakMapUrl [ 
	^ 'http://localhost:9070/sm'

]

{ #category : #private }
MCSMReleaseRepository >> stringForVersion: aVersion [
	| stream |
	stream := RWBinaryOrTextStream on: String new.
	aVersion fileOutOn: stream.
	^ stream contents
]

{ #category : #private }
MCSMReleaseRepository >> uploadVersion: aVersion [
	| result stream |
	result := HTTPSocket
		httpPut: (self stringForVersion: aVersion)
		to: self squeakMapUrl, '/upload/', aVersion fileName
		user: user
		passwd: password.
	self checkResult: result.
	stream := result readStream.
	stream upToAll: 'http://'.
	^ 'http://', stream upToEnd
]
