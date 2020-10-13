"
I'm a monticello writer for tonel format, writing
 - a package per directory
 - a class per file
 - a set of extensions to a single class per file (for example, all extensions of a package to String will be in a single file)

I'm created on a file reference to a directory where the package will be written.

[[[
TonelWriter on: ('someDirectory' asFileReference ensureCreateDirectory)
]]]

My main methods are
- ==#writeVersion:== that receives as argument a monticello version to write, from where I'll extract the corresponding monticello snapshot.
- ==#writeSnapshot:== that receives as argument a monticello snapshot to write, from where I'll write all the contained definitions.

I also provide a way to easily export a single class in the Tonel format to a stream. 

[[[
	TonelWriter sourceCodeOf: self.
	
	(FileSystem memory / 'test.st') writeStreamDo: [ :s | TonelWriter exportClass: self on: s ]; yourself.
]]]

! Implementation details

Notice that while writing, if the written package/snapshot already exists in the directory I'll overwrite it (i.e., remove it and recreate it).
"
Class {
	#name : #TonelWriter,
	#superclass : #MCWriter,
	#instVars : [
		'snapshot',
		'packageDir',
		'directoryReference'
	],
	#category : #'MonticelloTonel-Core'
}

{ #category : #accessing }
TonelWriter class >> classLabel [
	^ 'Class'
]

{ #category : #'writing - class' }
TonelWriter class >> exportClass: aClass on: aStream [
	"I take a class and a stream as parameter and export the class in Tonel format into the stream."
	
	^ self new exportClass: aClass on: aStream
]

{ #category : #accessing }
TonelWriter class >> extensionLabel [
	^ 'Extension'
]

{ #category : #writing }
TonelWriter class >> fileOut: aVersion on: aStream [
	(self on: aStream) writeVersion: aVersion
	

]

{ #category : #'instance creation' }
TonelWriter class >> on: directoryReference [
	^ self new
		directoryReference: directoryReference;
		yourself
]

{ #category : #accessing }
TonelWriter class >> readerClass [
	^ TonelReader
]

{ #category : #'writing - class' }
TonelWriter class >> sourceCodeOf: aClass [
	"I take as a parameter a class and I return it's tonel export as a String."
	
	^ String streamContents: [ :aStream | self new exportClass: aClass on: aStream ]
]

{ #category : #accessing }
TonelWriter class >> traitLabel [
	^ 'Trait'
]

{ #category : #private }
TonelWriter >> classNameFor: aMethodDefinition parent: aClassDefinition [
	aClassDefinition ifNil: [ ^ aMethodDefinition fullClassName ].
	^ aMethodDefinition classIsMeta
		ifFalse: [ aMethodDefinition className ]
		ifTrue: [ 
			aClassDefinition isTraitDefinition
				ifFalse: [aMethodDefinition className, ' class']
				ifTrue: [aMethodDefinition className, ' classSide'] ]
]

{ #category : #'private definitions' }
TonelWriter >> commentOf: aClassDefinition [
	^ (aClassDefinition comment 
		copyReplaceAll: '"' 
		with: '""')
		withLineEndings: self newLine
]

{ #category : #private }
TonelWriter >> createDefaultOrganizationFrom: aMCClassDefinition [ 
	^ MCOrganizationDefinition categories: { aMCClassDefinition category }
]

{ #category : #accessing }
TonelWriter >> directoryReference [
	^ directoryReference
]

{ #category : #accessing }
TonelWriter >> directoryReference: aFileReference [
	directoryReference := aFileReference
]

{ #category : #writing }
TonelWriter >> exportClass: aClass on: aStream [
	snapshot := (MCVersion package: (MCPackage named:  aClass category)) snapshot.
	self writeClass: aClass asClassDefinition on: aStream.
	^ aStream
]

{ #category : #private }
TonelWriter >> fileNameFor: aClassDefinition [
	^ String streamContents: [ :stream | 
		stream 
			<< aClassDefinition className
			<< '.' << (self typeOf: aClassDefinition) asLowercase
			<< '.st'  ]
]

{ #category : #accessing }
TonelWriter >> fileUtils [
	^ TonelFileUtils current
]

{ #category : #'private testing' }
TonelWriter >> isClass: aClassDefinition [
	^ aClassDefinition class = MCClassDefinition
]

{ #category : #'private testing' }
TonelWriter >> isTrait: aClassDefinition [
	^ aClassDefinition class = MCTraitDefinition 
]

{ #category : #'private definitions' }
TonelWriter >> methodDefinitionOf: aMethodDefinition [
	^ self toSTON: (OrderedDictionary new 
		at: #category put: aMethodDefinition category; 
		yourself)	
	
]

{ #category : #private }
TonelWriter >> newLine [
	 ^ Smalltalk os platformName caseOf:
		{['Win32'] -> [String crlf]}
		otherwise: [String lf]
]

{ #category : #private }
TonelWriter >> obtainPackageDir: aDefinition [
	"I'm assuming first category is actually the package"
	
	^ aDefinition categories first
]

{ #category : #accessing }
TonelWriter >> packageDir [
	^ packageDir 
		ifNotNil: [ self fileUtils directoryFromPath: packageDir relativeTo: self directoryReference ]
		ifNil: [ self directoryReference  ]
]

{ #category : #accessing }
TonelWriter >> packageName: aString [
	packageDir := aString.
]

{ #category : #private }
TonelWriter >> packageOf: aClass [
	^ aClass category
]

{ #category : #private }
TonelWriter >> selectorIsComplete: keywords in: aString [
	keywords inject: 1 into: [ :start :key | | startOfKey | 
		startOfKey := aString 
			findString: key 
			startingAt: start 
			caseSensitive: true.
		startOfKey = 0 ifTrue: [ ^ false ].
		startOfKey + key size ].
	^ true
]

{ #category : #private }
TonelWriter >> skipComment: aStream [
	"I assume I'm on top of the begining of a comment"
	aStream skip: 1.
	[ aStream atEnd not 
		and: [ aStream next ~= $" or: [ aStream peek = $" ] ] ]
	whileTrue.	
]

{ #category : #private }
TonelWriter >> skipSeparators: aStream [
	[ aStream peek isSeparator ]
	whileTrue: [ aStream skip: 1 ]. 

]

{ #category : #accessing }
TonelWriter >> snapshot: anObject [
	snapshot := anObject
]

{ #category : #private }
TonelWriter >> splitMethodSource: aMethodDefinition into: aBlock [
	| keywords source declaration |
	
	keywords := aMethodDefinition selector keywords.
	source := aMethodDefinition source readStream.
	"Skip spaces"
	(source peek isSeparator) ifTrue: [ self skipSeparators: source ].
	"Skip comments"
	(source peek = $") ifTrue: [ self skipComment: source ]. 
	"Parse declaration"
	declaration := String new writeStream.
	[ (self selectorIsComplete: keywords in: declaration originalContents) not 
		or: [ ':+-/\*~<>=@,%|&?!' includes: declaration contents withoutTrailingBlanks last ] ]
	whileTrue: [ 
		"stop infinite loop if no match was found"
		source atEnd ifTrue: [ TonelWriteError signal: 'Cannot find selector in source for ', aMethodDefinition asString ].
		"get separators"
		[ source atEnd not and: [ source peek isSeparator ] ]
			whileTrue: [ declaration nextPut: source next ].
		"take next word"
		[ source atEnd not and: [ source peek isSeparator not ] ]
			whileTrue: [ declaration nextPut: source next ] ].
	aBlock 
		value: (declaration contents withoutLeadingBlanks withLineEndings: self newLine)
		value: (source upToEnd withLineEndings: self newLine)
]

{ #category : #private }
TonelWriter >> toSTON: anObject [
	^ String streamContents: [ :outStream | 
		(TonelSTONWriter on: outStream) 
			newLine: self newLine;
			nextPut: anObject ]
]

{ #category : #'private definitions' }
TonelWriter >> typeClassDefinitionOf: aClassDefinition [
	| definition |
	
	definition := OrderedDictionary new 
		at: #name put: aClassDefinition className; 
		at: #superclass put: aClassDefinition superclassName;
		yourself.

	aClassDefinition type = #normal ifFalse: [ 
		definition at: #type put: aClassDefinition type ].
	
	aClassDefinition hasTraitComposition ifTrue: [ 
		definition at: #traits put: aClassDefinition traitCompositionString ].
	
	aClassDefinition hasClassTraitComposition ifTrue: [ 
		definition at: #classTraits put: aClassDefinition classTraitCompositionString ].
	
	(aClassDefinition variables select: #isInstanceVariable thenCollect: #name)
		ifNotEmpty: [ :vars | definition at: #instVars put: vars asArray ].

	(aClassDefinition variables select: #isClassVariable thenCollect: #name)
		ifNotEmpty: [ :vars | definition at: #classVars put: vars asArray ].
		
	(aClassDefinition variables select: #isPoolImport thenCollect: #name)
		ifNotEmpty: [ :vars | definition at: #pools put: vars asArray ].
		
	(aClassDefinition variables select: #isClassInstanceVariable thenCollect: #name)
		ifNotEmpty: [ :vars | definition at: #classInstVars put: vars asArray ].

	definition 		
		at: #category put: aClassDefinition category.
	
	^ self toSTON: definition
]

{ #category : #'private definitions' }
TonelWriter >> typeDefinitionOf: aClassDefinition [
	(self isTrait: aClassDefinition) 
		ifTrue: [ ^ self typeTraitDefinitionOf: aClassDefinition ].
	^ self typeClassDefinitionOf: aClassDefinition
]

{ #category : #private }
TonelWriter >> typeOf: aClassDefinition [
	(self isClass: aClassDefinition) ifTrue: [ ^ self class classLabel ].
	(self isTrait: aClassDefinition) ifTrue: [ ^ self class traitLabel ].

	TonelShouldIgnore signal
]

{ #category : #'private definitions' }
TonelWriter >> typeTraitDefinitionOf: aClassDefinition [
	| definition |
	
	definition := OrderedDictionary new 
		at: #name put: aClassDefinition className; 
		yourself.

	aClassDefinition variables isEmptyOrNil ifFalse: [ 
		(aClassDefinition variables select: #isInstanceVariable thenCollect: #name)
			ifNotEmpty: [ :vars | definition at: #instVars put: vars asArray ].
		(aClassDefinition variables select: #isClassInstanceVariable thenCollect: #name)
			ifNotEmpty: [ :vars | definition at: #classInstVars put: vars asArray ] ].

	aClassDefinition hasTraitComposition ifTrue: [ 
		definition		
			at: #traits 
			put: aClassDefinition traitCompositionString ].
		
	aClassDefinition hasClassTraitComposition ifTrue: [ 
		definition		
			at: #classTraits 
			put: aClassDefinition classTraitCompositionString ].
	
	definition at: #category put: aClassDefinition category.
		
	^ self toSTON: definition
]

{ #category : #writing }
TonelWriter >> writeClass: aClassDefinition [
	[ self fileUtils writeStreamFor: (self fileNameFor: aClassDefinition) in: self packageDir do: [ :aStream | self writeClass: aClassDefinition on: aStream ] ]
		on: TonelShouldIgnore
		do: [ :e | self logCr: 'ignoring: ' , aClassDefinition asString ]
]

{ #category : #writing }
TonelWriter >> writeClass: aClassDefinition on: aStream [
	[ self writeClassDefinition: aClassDefinition on: aStream.
	self writeClassSideMethodDefinitions: aClassDefinition on: aStream.
	self writeInstanceSideMethodDefinitions: aClassDefinition on: aStream ]
		on: TonelShouldIgnore
		do: [ :e | self logCr: 'ignoring: ' , aClassDefinition asString ]
]

{ #category : #'private writing' }
TonelWriter >> writeClassDefinition: aClassDefinition on: aStream [
	| nl |
	nl := self newLine.
	
	aClassDefinition hasComment 
		ifTrue: [ 
			aStream 
				nextPutAll: '"'; nextPutAll: nl;
				nextPutAll: (self commentOf: aClassDefinition); nextPutAll: nl;
				nextPutAll: '"'; nextPutAll: nl ].
	aStream
		nextPutAll: (self typeOf: aClassDefinition);
		nextPutAll: ' '; nextPutAll: (self typeDefinitionOf: aClassDefinition ); nextPutAll: nl
]

{ #category : #'private writing' }
TonelWriter >> writeClassSideMethodDefinitions: aClassDefinition on: aStream [
	((snapshot definitions 
		select: [ :each | 
			each isMethodDefinition 
			and: [ each className = aClassDefinition className
			and: [ each classIsMeta ] ] ])
		sorted: [ :a :b | a selector < b selector ])
		do: [ :each | 
			self writeMethodDefinition: each parent: aClassDefinition on: aStream ]
]

{ #category : #writing }
TonelWriter >> writeExtensionMethods: methods className: className [
	| nl |
	nl := self newLine.
	self fileUtils 
		writeStreamFor: (className, '.extension.st') 
		in: self packageDir 
		do: [ :s |
			s nextPutAll: 'Extension '; nextPutAll: (self toSTON: ({ #name -> className } as: Dictionary)); nextPutAll: nl.
			(methods sorted: [ :a :b | a selector < b selector ])
				do: [ :each | self writeMethodDefinition: each on: s ] ]
]

{ #category : #'private writing' }
TonelWriter >> writeInstanceSideMethodDefinitions: aClassDefinition on: aStream [
	((snapshot definitions 
		select: [ :each | 
			each isMethodDefinition 
			and: [ each className = aClassDefinition className
			and: [ each classIsMeta not ] ] ])
		sorted: [ :a :b | a selector < b selector ])
		do: [ :each | 
			self writeMethodDefinition: each parent: aClassDefinition on: aStream ]

	
	
]

{ #category : #'private writing' }
TonelWriter >> writeMethodDefinition: aMethodDefinition on: aStream [
	^ self 
		writeMethodDefinition: aMethodDefinition 
		parent: nil 
		on: aStream
]

{ #category : #'private writing' }
TonelWriter >> writeMethodDefinition: aMethodDefinition parent: aClassDefinition on: aStream [
	| nl |
	
	nl := self newLine.
	self 
		splitMethodSource: aMethodDefinition 
		into: [ :methodDeclaration :methodBody | | fullClassName |
			fullClassName := self classNameFor: aMethodDefinition parent: aClassDefinition.
			aStream 
				nextPutAll: nl;
				nextPutAll: (self methodDefinitionOf: aMethodDefinition); nextPutAll: nl;
				nextPutAll: fullClassName; nextPutAll: ' >> '; nextPutAll: methodDeclaration;
				nextPutAll: ' ['; nextPutAll: methodBody; nextPutAll: nl; nextPutAll: ']'; nextPutAll: nl]
]

{ #category : #writing }
TonelWriter >> writeMethodExtensions [
	| classesAndMethods |
	classesAndMethods := Dictionary new.
	snapshot definitions 
		select: [ :each | each isMethodDefinition and: [ each isExtensionMethod ] ]
		thenDo: [ :each | 
			(classesAndMethods 
				at: each className
				ifAbsentPut: [ Set new ])
				add: each ].
	classesAndMethods keysAndValuesDo: [ :className :methods | 
		self 
			writeExtensionMethods: methods 
			className: className ]
		
	
]

{ #category : #writing }
TonelWriter >> writePackage: aDefinition [

	packageDir ifNil: [packageDir := self obtainPackageDir: aDefinition].
	self flag: #todo. "this is lame... removing and rewriting full package needs to be rethink :)"
	(self fileUtils directoryExists: self packageDir) ifTrue: [ 
		self fileUtils deleteAll: self packageDir ].  
	self fileUtils ensureDirectoryExists: self packageDir.
	self fileUtils 
		writeStreamFor: 'package.st' 
		in: self packageDir 
		do: [ :s | 
			s 
				nextPutAll: 'Package ';
				nextPutAll: (self toSTON: ({ #name ->  packageDir asSymbol } as: Dictionary));
				nextPutAll: self newLine ]
]

{ #category : #writing }
TonelWriter >> writeSnapshot: aSnapshot [
	snapshot := aSnapshot.
	
	"ensure package dirs exists. 
	 It has to be just one but well..."
	self writePackage: (snapshot definitions 
		detect: #isOrganizationDefinition
		ifFound: [ :each | each ]
		ifNone: [ self createDefaultOrganizationFrom: (snapshot definitions detect: #isClassDefinition) ]).
	"now export classes"
	(snapshot definitions 
		select: #isClassDefinition)
		do: [ :each | self writeClass: each ].
	"... and method extensions"
	self writeMethodExtensions
]

{ #category : #writing }
TonelWriter >> writeVersion: aVersion [
	packageDir := aVersion package name.
	self writeSnapshot: aVersion snapshot
]
