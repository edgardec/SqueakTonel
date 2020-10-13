"
FileServices is a registry of classes that provide file reading services - defined in the current implementation as classes implementing (directly, not inheriting) #fileReaderServicesForFile:suffix: on their class side.
Registered classes can provide services to read a file (specified by file name and suffix) or directory (specified by path name). 
Mostly these services are used in file browser scenarios but see also ExternalDropHandler class>>#lookupServiceBasedHandler: for a different pattern
"
Class {
	#name : #FileServices,
	#superclass : #Object,
	#classVars : [
		'FileReaderRegistry'
	],
	#category : #'System-FileRegistry'
}

{ #category : #accessing }
FileServices class >> allRegisteredServices [
	"self allRegisteredServices"

	| col |
	col := OrderedCollection new.
	self registeredFileReaderClasses do: [:each | col addAll: (each services)].
	^ col
]

{ #category : #'class initialization' }
FileServices class >> cleanUp [
	"Remove obsolete services"

	self removeObsolete
]

{ #category : #accessing }
FileServices class >> initialize [
	"FileServices initialize"
	FileReaderRegistry := nil.
	Smalltalk allClassesDo:[:aClass|
		(aClass class includesSelector: #fileReaderServicesForFile:suffix:)
			ifTrue:[self registerFileReader: aClass]].
]

{ #category : #accessing }
FileServices class >> isReaderNamedRegistered: aSymbol [
	"return if a given reader class has been registered. Note that this is on purpose that the argument is a symbol and not a class"

	 ^ (self registeredFileReaderClasses collect: [:each | each name]) includes: aSymbol

]

{ #category : #accessing }
FileServices class >> itemsForDirectory: aFileDirectory [
	"Answer a list of services appropriate when no file is selected."

	| services |
	services := OrderedCollection new.
	self registeredFileReaderClasses do: [:reader |
		reader ifNotNil: [services addAll: (reader fileReaderServicesForDirectory: aFileDirectory) ]].
	^ services
]

{ #category : #accessing }
FileServices class >> itemsForFile: fullName [
	"Answer a list of services appropriate for a file of the given full name"

	| services suffix |
	suffix := self suffixOf: fullName.
	services := OrderedCollection new.
	self registeredFileReaderClasses do: [:reader |
		reader ifNotNil: [services addAll: (reader fileReaderServicesForFile: fullName suffix: suffix)]].
	^ services
]

{ #category : #accessing }
FileServices class >> registerFileReader: aProviderClass [
	"register the given class as providing services for reading files"

	| registeredReaders |
	registeredReaders := self registeredFileReaderClasses.
	(registeredReaders includes: aProviderClass) 
			ifFalse: [ registeredReaders addLast: aProviderClass ]
]

{ #category : #accessing }
FileServices class >> registeredFileReaderClasses [
	FileReaderRegistry ifNil: [FileReaderRegistry := OrderedCollection new].
	^ FileReaderRegistry
]

{ #category : #accessing }
FileServices class >> removeObsolete [
	"FileServices removeObsolete"
	self registeredFileReaderClasses copy 
		do:[:cls| cls isObsolete ifTrue:[self unregisterFileReader: cls]]
]

{ #category : #accessing }
FileServices class >> suffixOf: aName [
	"Answer the file extension of the given file, or an empty string should the file name be nil"
	^ aName
		ifNil:
			['']
		ifNotNil:
			[(FileDirectory extensionFor: aName) asLowercase]
]

{ #category : #accessing }
FileServices class >> unregisterFileReader: aProviderClass [
	"unregister the given class as providing services for reading files"

	self registeredFileReaderClasses remove: aProviderClass ifAbsent: [nil]
]
