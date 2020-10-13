Class {
	#name : #ExternalDropHandler,
	#superclass : #Object,
	#instVars : [
		'action',
		'type',
		'extension'
	],
	#classVars : [
		'DefaultHandler',
		'RegisteredHandlers'
	],
	#category : #'System-Support'
}

{ #category : #private }
ExternalDropHandler class >> chooseServiceFrom: aCollection [
	"private - choose a service from aCollection asking the user if  needed"
	^aCollection size = 1 
		ifTrue: [aCollection anyOne]
		ifFalse:[UIManager default 
			chooseFrom: (aCollection collect:[:each| each label])
			values: aCollection
			title: 'You dropped a file. Please choose a service:' translated withCRs].
]

{ #category : #'class initialization' }
ExternalDropHandler class >> cleanUp [
	"Reset and reinstall the drop handlers"

	self initialize.
]

{ #category : #private }
ExternalDropHandler class >> defaultGZipHandler [
	^ExternalDropHandler
		type: nil
		extension: 'gz'
		action: [:stream :pasteUp :event | | contents |
			contents := Cursor wait showWhile: [stream viewGZipContents].
				UIManager default
					edit: contents
					label: 'Decompressed contents of: ', stream localName].
]

{ #category : #accessing }
ExternalDropHandler class >> defaultHandler [
	DefaultHandler ifNil: [DefaultHandler := ExternalDropHandler type: nil extension: nil action: [:dropStream | dropStream edit]].
	^DefaultHandler
]

{ #category : #accessing }
ExternalDropHandler class >> defaultHandler: externalDropHandler [
	DefaultHandler := externalDropHandler
]

{ #category : #private }
ExternalDropHandler class >> defaultImageHandler [
	^ExternalDropHandler
		type: 'image/'
		extension: nil
		action: [:stream :pasteUp :event |
			| image sketch |
			stream binary.
			image := Form fromBinaryStream: stream contents asByteArray readStream.
			Project current resourceManager 
				addResource: image 
				url: (FileDirectory urlForFileNamed: stream name) asString.
			sketch := Project current world drawingClass withForm: image.
			pasteUp addMorph: sketch centeredNear: event position.
			image := sketch := nil]
]

{ #category : #private }
ExternalDropHandler class >> defaultProjectHandler [
	^ ExternalDropHandler
		type: nil
		extension: 'pr'
		action: [:stream | ProjectLoading openOn: stream]
]

{ #category : #'class initialization' }
ExternalDropHandler class >> initialize [
	"ExternalDropHandler initialize"

	self resetRegisteredHandlers.
	self
		"registerHandler: self defaultImageHandler;" "we have file services for images"
		registerHandler: self defaultGZipHandler;
		registerHandler: self defaultProjectHandler
]

{ #category : #accessing }
ExternalDropHandler class >> lookupExternalDropHandler: stream [

	| types extension serviceHandler |
	types := stream mimeTypes.

	types ifNotNil: [
		self registeredHandlers do: [:handler | 
			(handler matchesTypes: types)
				ifTrue: [^handler]]].

	extension := FileDirectory extensionFor: stream name.
	self registeredHandlers do: [:handler | 
		(handler matchesExtension: extension)
				ifTrue: [^handler]].
	serviceHandler := self lookupServiceBasedHandler: stream.
	^serviceHandler
		ifNil: [self defaultHandler]
]

{ #category : #accessing }
ExternalDropHandler class >> lookupServiceBasedHandler: dropStream [
	"The file was just dropped; let's do our job"
	| fileName services theOne |
	fileName := dropStream name.

	services := (FileServices itemsForFile: fileName)
		reject: [:svc | self unwantedSelectors includes: svc selector].

	"no service, default behavior"
	services isEmpty
		ifTrue: [^nil].

	theOne := self chooseServiceFrom: services.
	^theOne
		ifNotNil: [ExternalDropHandler type: nil extension: nil action: [:stream | theOne performServiceFor: stream]]
]

{ #category : #accessing }
ExternalDropHandler class >> registerHandler: aHandler [
	self registeredHandlers add: aHandler
]

{ #category : #private }
ExternalDropHandler class >> registeredHandlers [
	RegisteredHandlers ifNil: [RegisteredHandlers := OrderedCollection new].
	^RegisteredHandlers
]

{ #category : #private }
ExternalDropHandler class >> resetRegisteredHandlers [
	RegisteredHandlers := nil
]

{ #category : #'instance creation' }
ExternalDropHandler class >> type: aType extension: anExtension action: anAction [ 
	^self new type: aType extension: anExtension action: anAction 
]

{ #category : #private }
ExternalDropHandler class >> unwantedSelectors [
	"private - answer a collection well known unwanted selectors "
	^ #(#removeLineFeeds: #addFileToNewZip: #compressFile: #putUpdate: )
]

{ #category : #accessing }
ExternalDropHandler >> extension [
	^extension
]

{ #category : #accessing }
ExternalDropHandler >> handle: dropStream in: pasteUp dropEvent: anEvent [
	| numArgs |
	numArgs := action numArgs.
	numArgs = 1
		ifTrue: [^action value: dropStream].
	numArgs = 2
		ifTrue: [^action value: dropStream value: pasteUp].
	numArgs = 3
		ifTrue: [^action value: dropStream value: pasteUp value: anEvent].
	self error: 'Wrong number of args for dop action.'
]

{ #category : #testing }
ExternalDropHandler >> matchesExtension: aExtension [
	(self extension isNil or: [aExtension isNil])
		ifTrue: [^false].
	FileDirectory activeDirectoryClass isCaseSensitive
		ifTrue: [^extension = aExtension]
		ifFalse: [^extension sameAs: aExtension]
]

{ #category : #testing }
ExternalDropHandler >> matchesTypes: types [
	(self type isNil or: [types isNil])
		ifTrue: [^false].
	^types anySatisfy: [:mimeType | mimeType beginsWith: self type]
]

{ #category : #accessing }
ExternalDropHandler >> type [
	^type
]

{ #category : #initialize }
ExternalDropHandler >> type: aType extension: anExtension action: anAction [ 
	action := anAction.
	type := aType.
	extension := anExtension
]
