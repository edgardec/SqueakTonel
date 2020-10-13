Class {
	#name : #MCDictionaryRepository,
	#superclass : #MCRepository,
	#instVars : [
		'description',
		'dict'
	],
	#category : #'Monticello-Repositories'
}

{ #category : #testing }
MCDictionaryRepository >> = other [
	^ self == other
]

{ #category : #accessing }
MCDictionaryRepository >> allVersionInfos [
	^ dict values collect: [:ea | ea info]
]

{ #category : #versions }
MCDictionaryRepository >> allVersionNames [
	"Answers all the version names in this repository"

	^ dict values collect: [:ea | ea info name]
	
]

{ #category : #private }
MCDictionaryRepository >> basicStoreVersion: aVersion [
	dict at: aVersion info put: aVersion
]

{ #category : #accessing }
MCDictionaryRepository >> closestAncestorVersionFor: anAncestry ifNone: errorBlock [
	| info |
	info := anAncestry breadthFirstAncestors
			detect: [:ea | self includesVersionWithInfo: ea]
			ifNone: [^ errorBlock value].
	^ self versionWithInfo: info
]

{ #category : #accessing }
MCDictionaryRepository >> description [

	^ description ifNil: ['cache']
]

{ #category : #accessing }
MCDictionaryRepository >> description: aString [

	description := aString 
]

{ #category : #accessing }
MCDictionaryRepository >> dictionary [

	^ dict
]

{ #category : #accessing }
MCDictionaryRepository >> dictionary: aDictionary [

	dict := aDictionary
]

{ #category : #versions }
MCDictionaryRepository >> includesVersionNamed: aString [ 
	| mcVersionName |
	mcVersionName := aString asMCVersionName.
	^ dict anySatisfy:
		[ : ea | ea info versionName = mcVersionName ]
]

{ #category : #testing }
MCDictionaryRepository >> includesVersionWithInfo: aVersionInfo [
	^ dict includesKey: aVersionInfo
]

{ #category : #'initialize-release' }
MCDictionaryRepository >> initialize [

	dict := Dictionary new.

]

{ #category : #'user interface' }
MCDictionaryRepository >> morphicOpen: aWorkingCopy [
	| names index infos |
	infos := self sortedVersionInfos.
	infos isEmpty ifTrue: [^ self inform: 'No versions'].
	names := infos collect: [:ea | ea name].
	index := UIManager default chooseFrom: names title: 'Open version:'.
	index = 0 ifFalse: [(self versionWithInfo: (infos at: index)) open]
]

{ #category : #accessing }
MCDictionaryRepository >> sortedVersionInfos [
	| sorter |
	sorter := MCVersionSorter new.
	self allVersionInfos do: [:ea | sorter addVersionInfo: ea].
	^ sorter sortedVersionInfos

]

{ #category : #versions }
MCDictionaryRepository >> versionWithInfo: aVersionInfo ifAbsent: errorBlock [
	^ dict at: aVersionInfo ifAbsent: errorBlock
]
