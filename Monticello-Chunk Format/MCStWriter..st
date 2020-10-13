Class {
	#name : #MCStWriter,
	#superclass : #MCWriter,
	#instVars : [
		'initStream'
	],
	#category : #'Monticello-Chunk Format'
}

{ #category : #accessing }
MCStWriter class >> readerClass [
	^ MCStReader
]

{ #category : #writing }
MCStWriter >> chunkContents: aBlock [
	stream cr; nextChunkPut: (String streamContents: aBlock); cr
]

{ #category : #visiting }
MCStWriter >> visitClassDefinition: definition [
	self writeClassDefinition: definition.
	definition hasClassInstanceVariables ifTrue: [self writeMetaclassDefinition: definition].
	definition hasComment ifTrue: [self writeClassComment: definition].
]

{ #category : #visiting }
MCStWriter >> visitClassTraitDefinition: definition [
	self chunkContents: [:s | s
		nextPutAll: definition baseTrait;
		nextPutAll: ' classTrait';
		cr; tab;
		nextPutAll: 'uses: ';
		nextPutAll: (definition classTraitComposition ifNil: ['{}'])]

]

{ #category : #visiting }
MCStWriter >> visitMetaclassDefinition: definition [
	self writeMetaclassDefinition: definition
]

{ #category : #visiting }
MCStWriter >> visitMethodDefinition: definition [
	self writeMethodPreamble: definition.
	self writeMethodSource: definition.
	self writeMethodPostscript.
	self writeMethodInitializer: definition.
]

{ #category : #visiting }
MCStWriter >> visitOrganizationDefinition: defintion [
	defintion categories do: [:cat | self writeCategory: cat].

]

{ #category : #visiting }
MCStWriter >> visitScriptDefinition: definition [
	self writeScriptDefinition: definition

]

{ #category : #visiting }
MCStWriter >> visitTraitDefinition: definition [
	self writeClassDefinition: definition.
	definition hasComment ifTrue: [self writeClassComment: definition].
]

{ #category : #writing }
MCStWriter >> writeCategory: categoryName [
	stream
		nextChunkPut: 'SystemOrganization addCategory: ', categoryName printString;
		cr
]

{ #category : #writing }
MCStWriter >> writeClassComment: definition [
	stream
		cr;
		nextPut: $!;
		nextPutAll: definition className;
		nextPutAll: ' commentStamp: ';
		store: definition commentStamp;
		nextPutAll: ' prior: 0!';
		cr;
		nextChunkPut: definition comment;
		cr.
]

{ #category : #writing }
MCStWriter >> writeClassDefinition: definition [
	self chunkContents: [:s | definition printDefinitionOn: stream]
]

{ #category : #writing }
MCStWriter >> writeDefinitions: aCollection [
	"initStream is an ugly hack until we have proper init defs"
	initStream := String new writeStream.

	(MCDependencySorter sortItems: aCollection)
		do: [:ea | ea accept: self]
		displayingProgress: 'Writing definitions...'.
	
	stream nextPutAll: initStream contents.
]

{ #category : #writing }
MCStWriter >> writeMetaclassDefinition: definition [
	self chunkContents: [:str |
		str	nextPutAll: definition className;
			nextPutAll: ' class';
			cr; tab.
			definition hasClassTraitComposition ifTrue: [
				str	nextPutAll: 'uses: ';
					nextPutAll: definition classTraitCompositionString;
					cr; tab].
			str	nextPutAll: 'instanceVariableNames: ''';
				nextPutAll: definition classInstanceVariablesString;
				nextPut: $']
]

{ #category : #writing }
MCStWriter >> writeMethodInitializer: aMethodDefinition [
	aMethodDefinition isInitializer ifTrue:
		[initStream nextChunkPut: aMethodDefinition className, ' initialize'; cr]
]

{ #category : #writing }
MCStWriter >> writeMethodPostscript [
	stream
		space;
		nextPut: $!;
		cr
]

{ #category : #writing }
MCStWriter >> writeMethodPreamble: definition [
	stream
		cr;
		nextPut: $!;
		nextPutAll: definition fullClassName;
		nextPutAll: ' methodsFor: ';
		nextPutAll: definition category asString printString;
		nextPutAll: ' stamp: ';
		nextPutAll: definition timeStamp asString printString;
		nextPutAll: '!';
		cr
]

{ #category : #writing }
MCStWriter >> writeMethodSource: definition [
	stream nextChunkPut: definition source
]

{ #category : #writing }
MCStWriter >> writeScriptDefinition: definition [
	stream nextChunkPut: (
		'(PackageInfo named: {1}) {2}: {3}'
		format: {
			"{1}" definition packageName printString.
			"{2}" definition scriptSelector. 
			"{3}" definition script printString
		}); cr
]

{ #category : #writing }
MCStWriter >> writeSnapshot: aSnapshot [
	self writeDefinitions: aSnapshot definitions
]
