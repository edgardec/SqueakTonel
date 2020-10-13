Class {
	#name : #MCMcdWriter,
	#superclass : #MCMczWriter,
	#category : #'Monticello-Storing'
}

{ #category : #accessing }
MCMcdWriter class >> readerClass [
	^ MCMcdReader
]

{ #category : #visiting }
MCMcdWriter >> writeBaseInfo: aVersionInfo [
	| string |
	string := self serializeVersionInfo: aVersionInfo.
	self addString: string at: 'base' encodedTo: 'utf8'.

]

{ #category : #visiting }
MCMcdWriter >> writeDefinitions: aVersion [
	self writeBaseInfo: aVersion baseInfo.
	self writePatch: aVersion patch.
]

{ #category : #visiting }
MCMcdWriter >> writeNewDefinitions: aCollection [
	self addString: (self serializeDefinitions: aCollection) at: 'new/source.', self snapshotWriterClass extension encodedTo: 'utf8'.
]

{ #category : #visiting }
MCMcdWriter >> writeOldDefinitions: aCollection [
	self addString: (self serializeDefinitions: aCollection) at: 'old/source.', self snapshotWriterClass extension encodedTo: 'utf8'.
]

{ #category : #visiting }
MCMcdWriter >> writePatch: aPatch [ 
	| old new |
	old := OrderedCollection new.
	new := OrderedCollection new.
	aPatch operations do:
		[ : ea | ea isRemoval ifTrue: [ old add: ea definition ].
		ea isAddition ifTrue: [ new add: ea definition ].
		ea isModification ifTrue:
			[ old add: ea baseDefinition.
			new add: ea definition ] ].
	(old isEmpty and: [ new isEmpty ]) ifTrue: [ MCEmptyDiffyVersion signal ].
	self
		 writeOldDefinitions: old ;
		 writeNewDefinitions: new ;
		
		addString: (self serializeInBinary: aPatch)
		at: 'patch.bin'
]
