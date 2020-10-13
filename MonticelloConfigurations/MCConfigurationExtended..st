"
A MCConfigurationExtended is a configuration with author initials, timestamp, comment, and a list of prior versions. Its external storage format is organized for compatibility with MCConfiguration, such that an image wtih support for only MCConfiguration can use configurations saved from a MCConfigurationExtended. The intended use is to enable documentation of configuration maps, and to allow modifications to a configuration map without loss of version history.
"
Class {
	#name : #MCConfigurationExtended,
	#superclass : #MCConfiguration,
	#instVars : [
		'mcmVersion',
		'id',
		'authorInitials',
		'timeStamp',
		'comment',
		'priorVersions'
	],
	#classVars : [
		'HistoryLimit'
	],
	#category : #MonticelloConfigurations
}

{ #category : #'class initialization' }
MCConfigurationExtended class >> initialize [

	"Limit the number of prior versions in the history list to prevent MCM files from
	becoming unnecessarily large over time. Versions are idenitified by a UUID
	identifier, which should be sufficient for building a full version history if needed."
	HistoryLimit := 10.
]

{ #category : #comparing }
MCConfigurationExtended >> = configuration [
	^ (((super = configuration
		and: [configuration authorInitials = authorInitials])
			and: [configuration timeStamp = timeStamp])
				and: [configuration id = id])
					and: [configuration comment = comment].

]

{ #category : #initialize }
MCConfigurationExtended >> addPriorVersion: mcConfig [
	priorVersions add: mcConfig
]

{ #category : #accessing }
MCConfigurationExtended >> authorInitials [
	^ authorInitials

]

{ #category : #accessing }
MCConfigurationExtended >> authorInitials: initials [
	authorInitials := initials

]

{ #category : #accessing }
MCConfigurationExtended >> comment [
	^ comment

]

{ #category : #accessing }
MCConfigurationExtended >> comment: aString [
	comment := aString

]

{ #category : #printing }
MCConfigurationExtended >> contentsOn: aStream keyPrefix: prefix [

	super contentsOn: aStream keyPrefix: prefix.

	mcmVersion ifNotNil: [:ver |
		aStream cr.
		aStream nextPutAll: prefix,'mcmVersion '. 
		aStream print: ver].

	id ifNotNil: [:uuid |
		aStream cr.
		aStream nextPutAll: prefix,'id '.
		aStream print: uuid].

	authorInitials ifNotNil: [:initials |
		aStream cr.
		aStream nextPutAll: prefix,'authorInitials '. 
		aStream print: initials].

	timeStamp ifNotNil: [:ts |
		aStream cr.
		aStream nextPutAll: prefix,'timeStamp '. 
		aStream print: ts].

	comment ifNotNil: [:c |
		aStream cr.
		aStream nextPutAll: prefix,'comment '. 
		aStream print: c].

	"Keys in the prior versions have a prefix to prevent them being parsed
	into a MCConfiguration when an image that does not contain support for the
	newer MCConfigurationExtended format. This allows older images to read
	an MCM file with extended format and version history, treating it as if it
	were data for the original MCConfiguration. See #copyWithoutKeyPrefix:
	for removal of the prefix during parsing."
	priorVersions do: [:e | e copyWithoutHistory contentsOn: aStream keyPrefix: 'X'].

]

{ #category : #copying }
MCConfigurationExtended >> copyForEdit [
	"Preparing to edit a configuration. Answer a new copy with the original
	instance saved in version history, and with no author initials or timestamp.
	The initials and timestamp are to be set immediately prior to saving an edited
	version."
	| config |
	config := super copyForEdit.
	config priorVersions: priorVersions copy.
	config priorVersions addFirst: self.
	config authorInitials: nil.
	config timeStamp: nil.
	config comment: self comment copy.
	config trimVersionList.
	^ config
]

{ #category : #copying }
MCConfigurationExtended >> copyWithoutHistory [
	"When a configuration is part of a version history, do not repeatedly
	export its history."

	| config |
	config := self copy.
	config priorVersions: OrderedCollection new.
	^ config
]

{ #category : #comparing }
MCConfigurationExtended >> hash [
	^ (super hash bitOr: timeStamp hash) bitXor: id.

]

{ #category : #accessing }
MCConfigurationExtended >> id [
	^ id
]

{ #category : #accessing }
MCConfigurationExtended >> id: uuid [
	id := uuid
]

{ #category : #initialize }
MCConfigurationExtended >> initialize [
	super initialize.
	mcmVersion := '2'.
	priorVersions := OrderedCollection new.
]

{ #category : #initialize }
MCConfigurationExtended >> initializeFromKey: key value: value [
	super initializeFromKey: key value: value.
	key = #mcmVersion
		ifTrue: [mcmVersion := value].
	key = #id
		ifTrue: [id := value].
	key = #authorInitials
		ifTrue: [authorInitials := value].
	key = #timeStamp
		ifTrue: [timeStamp := value].
	key = #comment
		ifTrue: [comment := value].


]

{ #category : #accessing }
MCConfigurationExtended >> mcmVersion [
	^ mcmVersion

]

{ #category : #printing }
MCConfigurationExtended >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: ' ', name asString, ' ', timeStamp asString, ' (', id asString, ')'.
]

{ #category : #accessing }
MCConfigurationExtended >> priorVersions [
	^ priorVersions

]

{ #category : #accessing }
MCConfigurationExtended >> priorVersions: collection [
	priorVersions := collection

]

{ #category : #accessing }
MCConfigurationExtended >> timeStamp [
	^ timeStamp

]

{ #category : #accessing }
MCConfigurationExtended >> timeStamp: aString [
	timeStamp := aString

]

{ #category : #initialize }
MCConfigurationExtended >> trimVersionList [
	[priorVersions size > HistoryLimit]
		whileTrue: [priorVersions removeLast].

]

{ #category : #initialize }
MCConfigurationExtended >> versions [
	"myself with all prior versions"
	^ { self } , priorVersions.

]
