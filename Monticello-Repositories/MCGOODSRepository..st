"
A MCGOODSRepository simply stores a Dictionary of aVersionInfo-> aMCVersion.
"
Class {
	#name : #MCGOODSRepository,
	#superclass : #MCRepository,
	#instVars : [
		'hostname',
		'port',
		'connection'
	],
	#category : #'Monticello-Repositories'
}

{ #category : #configuring }
MCGOODSRepository class >> creationTemplate [
	^
'MCGOODSRepository
	host: ''localhost''
	port: 6100'
]

{ #category : #configuring }
MCGOODSRepository class >> description [
	^ 'GOODS'
]

{ #category : #configuring }
MCGOODSRepository class >> fillInTheBlankRequest [
	^ 'GOODS Repository:'
]

{ #category : #'instance creation' }
MCGOODSRepository class >> host: hostname port: portNumber [
	^ self new
		host: hostname;
		port: portNumber
]

{ #category : #configuring }
MCGOODSRepository class >> morphicConfigure [
	^ self fillInTheBlankConfigure
]

{ #category : #packages }
MCGOODSRepository >> allPackageNames [
	^ self root collect:
		[ : ea | ea package name ]
]

{ #category : #private }
MCGOODSRepository >> basicStoreVersion: aVersion [
	self root at: aVersion info put: aVersion.
	self db commit.
]

{ #category : #private }
MCGOODSRepository >> db [
	(connection isNil or: [connection isConnected not]) ifTrue: [
		connection := Smalltalk at: #KKDatabase ifPresent: [:cl | 
			cl  onHost:hostname port: port
		]
	].
	^ connection
]

{ #category : #'user interface' }
MCGOODSRepository >> description [
	^ 'goods://', hostname asString, ':', port asString
]

{ #category : #accessing }
MCGOODSRepository >> host: aString [
	hostname := aString
]

{ #category : #versions }
MCGOODSRepository >> includesVersionNamed: aString [ 
	^ (self versionNamed: aString) notNil
]

{ #category : #accessing }
MCGOODSRepository >> port: aNumber [
	port := aNumber
]

{ #category : #accessing }
MCGOODSRepository >> root [
	self db root ifNil: [self db root: Dictionary new].
	^ self db root
]

{ #category : #versions }
MCGOODSRepository >> versionNamed: aString [ 
	| versionName |
	versionName := aString asMCVersionName.
	self root keysDo:
		[ : each | each versionName = versionName ifTrue: [ ^ each ] ].
	^ nil
]

{ #category : #versions }
MCGOODSRepository >> versionNamesForPackageNamed: aString [ 
	^ Array streamContents:
		[ : stream | self root keysDo:
			[ : each | each versionName packageName = aString ifTrue: [ stream nextPut: each ] ] ]
]

{ #category : #versions }
MCGOODSRepository >> versionWithInfo: aVersionInfo ifAbsent: errorBlock [
	^ self root at: aVersionInfo ifAbsent: errorBlock
]
