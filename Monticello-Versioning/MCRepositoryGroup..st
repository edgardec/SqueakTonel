"
A singleton class, holds the list of repositories. Can look for a requested VersionInfo among its repositories.
"
Class {
	#name : #MCRepositoryGroup,
	#superclass : #Object,
	#instVars : [
		'repositories'
	],
	#classInstVars : [
		'default'
	],
	#category : #'Monticello-Versioning'
}

{ #category : #accessing }
MCRepositoryGroup class >> default [
	^ default ifNil: [default := self new]
]

{ #category : #actions }
MCRepositoryGroup class >> flushAllCaches [
	self default flushCache
]

{ #category : #actions }
MCRepositoryGroup class >> reset [
	default := nil
]

{ #category : #'instance creation' }
MCRepositoryGroup class >> with: aMCRepository [ 
	^ self new
		 addRepository: aMCRepository ;
		 yourself
]

{ #category : #update }
MCRepositoryGroup >> addRepository: aRepository [
	((repositories includes: aRepository) or: [aRepository == MCCacheRepository default])
		ifFalse: [repositories add: aRepository.
				self class default addRepository: aRepository].
	self changed: #repositories
]

{ #category : #'repository-api' }
MCRepositoryGroup >> allPackageNames [
	^ repositories
		inject: Set new
		into:
			[ : set : each | set
				 addAll: each allPackageNames ;
				 yourself ]
]

{ #category : #'repository-api' }
MCRepositoryGroup >> basicStoreVersion: aVersion [
	"RepositoryGroup is used for reading, not writing."
	self shouldNotImplement
]

{ #category : #private }
MCRepositoryGroup >> cacheAllFilenames [
	repositories do: [ : each | each cacheAllFilenames ]
]

{ #category : #accessing }
MCRepositoryGroup >> closestAncestorVersionFor: anAncestry ifNone: errorBlock [
	anAncestry breadthFirstAncestorsDo:
		[:ancestorInfo |
		(self versionWithInfo: ancestorInfo) ifNotNil: [:v | ^ v]].
	^ errorBlock value
]

{ #category : #update }
MCRepositoryGroup >> demoteRepository: aMCRepository [ 
	"If aMCRepository is part of this Group, demote it to the bottom of the list so that other repositories will be checked first."
	| removed |
	removed := repositories
		remove: aMCRepository
		ifAbsent: [  ].
	removed ifNotNil:
		[ repositories addLast: aMCRepository.
		self changed: #repositories ]
]

{ #category : #'repository-api' }
MCRepositoryGroup >> description [
	^ String streamContents:
		[ : stream | stream nextPutAll: '{ '.
		repositories
			do: [ : each | stream nextPut: $';  nextPutAll: each description; nextPut: $' ]
			separatedBy: [ stream nextPutAll: '. ' ].
		stream nextPutAll: ' }' ]
]

{ #category : #private }
MCRepositoryGroup >> flushAllFilenames [
	self repositories do: [ : each | each flushAllFilenames ]
]

{ #category : #'repository-api' }
MCRepositoryGroup >> flushCache [
	self repositoriesDo: [ : each | each flushCache ]
]

{ #category : #testing }
MCRepositoryGroup >> includes: aRepository [
	^ self repositories includes: aRepository
]

{ #category : #'repository-api' }
MCRepositoryGroup >> includesVersionNamed: aString [ 
	^ repositories anySatisfy: [ : each | [each includesVersionNamed: aString] on: Error do: [false]]
]

{ #category : #'initialize-release' }
MCRepositoryGroup >> initialize [
	super initialize.
	repositories := OrderedCollection new
]

{ #category : #testing }
MCRepositoryGroup >> isTrunk [
	^ false
]

{ #category : #ui }
MCRepositoryGroup >> morphicOpen: aWorkingCopy [ 
	^ self repositories do: [:repo | repo morphicOpen: aWorkingCopy].
]

{ #category : #accessing }
MCRepositoryGroup >> normalizedRepositories [
	"Find an existing instance of any active repository so that we use whatever name and password the user usually uses. If not found, answer a copy"
	^ repositories collect: [ : each | each normalized ]
]

{ #category : #update }
MCRepositoryGroup >> removeRepository: aRepository [
	| removed |
	removed := repositories remove: aRepository ifAbsent: [].
	removed ifNotNil: [ removed wasRemoved ].
	self changed: #repositories
]

{ #category : #accessing }
MCRepositoryGroup >> repositories [
	^{ MCCacheRepository default }, repositories select: [ :ea | ea isValid ]
]

{ #category : #accessing }
MCRepositoryGroup >> repositoriesDo: aBlock [
	self repositories do: [:ea | [aBlock value: ea] on: Error do: []]
]

{ #category : #'repository-api' }
MCRepositoryGroup >> versionNamed: aMCVersionName [ 
	repositories do:
		[ : each | (each versionNamed: aMCVersionName) ifNotNil: [ : ver | ^ ver ] ].
	^ nil
]

{ #category : #'repository-api' }
MCRepositoryGroup >> versionNamesForPackageNamed: aString [ 
	^ repositories
		inject: Set new
		into:
			[ : set : each | set
				 addAll:
					([ each versionNamesForPackageNamed: aString ]
						on: NetworkError
						do: [ : err | Array empty ]) ;
				 yourself ]
]

{ #category : #accessing }
MCRepositoryGroup >> versionWithInfo: aVersionInfo [
	^self versionWithInfo: aVersionInfo ifNone: [ nil ]

]

{ #category : #'repository-api' }
MCRepositoryGroup >> versionWithInfo: aVersionInfo ifAbsent: aBlock [ 
	self repositories do:
		[ : each | ([each
			versionWithInfo: aVersionInfo
			ifAbsent: [ nil ]] on: NetworkError do: [ : err | nil ]) ifNotNil:
			[ : ver | ^ ver ] ].
	^ aBlock value
]

{ #category : #accessing }
MCRepositoryGroup >> versionWithInfo: aVersionInfo ifNone: aBlock [
	self repositoriesDo: [:ea | (ea versionWithInfo: aVersionInfo) ifNotNil: [:v | ^ v]].
	^aBlock value
]

{ #category : #accessing }
MCRepositoryGroup >> withCache [
	^ self
]
