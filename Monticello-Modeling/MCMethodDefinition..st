Class {
	#name : #MCMethodDefinition,
	#superclass : #MCDefinition,
	#instVars : [
		'classIsMeta',
		'source',
		'category',
		'selector',
		'className',
		'timeStamp'
	],
	#classInstVars : [
		'definitions'
	],
	#category : #'Monticello-Modeling'
}

{ #category : #accessing }
MCMethodDefinition class >> cachedDefinitions [
	
	^definitions ifNil: [ definitions := WeakIdentityKeyDictionary new ]
]

{ #category : #create }
MCMethodDefinition class >> className: classString
classIsMeta: metaBoolean
selector: selectorString
category: catString
timeStamp: timeString
source: sourceString [
	^ self instanceLike:
		(self new initializeWithClassName: classString
					classIsMeta: metaBoolean
					selector: selectorString
					category: catString
					timeStamp: timeString
					source: sourceString)
]

{ #category : #create }
MCMethodDefinition class >> className: classString
selector: selectorString
category: catString
timeStamp: timeString
source: sourceString [
	^ self	className: classString
			classIsMeta: false
			selector: selectorString
			category: catString
			timeStamp: timeString
			source: sourceString
]

{ #category : #'class initialization' }
MCMethodDefinition class >> cleanUp [
	"Flush caches"

	self shutDown.
]

{ #category : #create }
MCMethodDefinition class >> forMethodReference: aMethodReference [
	| definition |
	definition := self cachedDefinitions at: aMethodReference compiledMethod ifAbsent: [].
	(definition isNil
		or: [definition selector ~= aMethodReference methodSymbol
		or: [definition className ~= aMethodReference classSymbol
		or: [definition classIsMeta ~= aMethodReference classIsMeta
		or: [definition category ~= aMethodReference category]]]])
			ifTrue: [definition := self 
						className: aMethodReference classSymbol
						classIsMeta: aMethodReference classIsMeta
						selector: aMethodReference methodSymbol
						category: aMethodReference category
						timeStamp: aMethodReference timeStamp
						source: aMethodReference source.
					self cachedDefinitions at: aMethodReference compiledMethod put: definition].
	^ definition
	
]

{ #category : #'class initialization' }
MCMethodDefinition class >> initialize [
	Smalltalk addToShutDownList: self
]

{ #category : #'class initialization' }
MCMethodDefinition class >> shutDown [
	
	definitions := nil.
]

{ #category : #comparing }
MCMethodDefinition >> = aDefinition [
	^(super = aDefinition)
		and: [aDefinition source = self source
		and: [aDefinition category = self category
		and: [aDefinition timeStamp = self timeStamp]]]
]

{ #category : #visiting }
MCMethodDefinition >> accept: aVisitor [
	^ aVisitor visitMethodDefinition: self
]

{ #category : #accessing }
MCMethodDefinition >> actualClass [
	^ self actualClassIn: Environment current
]

{ #category : #accessing }
MCMethodDefinition >> actualClassIn: anEnvironment [
	^ (anEnvironment at: className ifAbsent: [anEnvironment valueOf: className])
		ifNotNil: [:class |
			class isBehavior ifTrue: [classIsMeta ifTrue: [class classSide] ifFalse: [class]]]
]

{ #category : #installing }
MCMethodDefinition >> addMethodAdditionTo: aCollection [ 
	aCollection
		 add: self asMethodAddition createCompiledMethod ;
		 yourself
]

{ #category : #converting }
MCMethodDefinition >> asMethodAddition [
	^MethodAddition new
		compile: source
		classified: category
		withStamp: timeStamp
		notifying: nil
		logSource: SystemChangeNotifier uniqueInstance isBroadcasting
		inClass: self actualClass.
]

{ #category : #converting }
MCMethodDefinition >> asMethodReference [
	^ MethodReference
		class: self actualClass
		selector: self selector
]

{ #category : #accessing }
MCMethodDefinition >> category [
	^ category
]

{ #category : #accessing }
MCMethodDefinition >> classIsMeta [
	^ classIsMeta
]

{ #category : #accessing }
MCMethodDefinition >> className [
	^className
]

{ #category : #printing }
MCMethodDefinition >> description [
	
	^{ className. selector. classIsMeta }
]

{ #category : #printing }
MCMethodDefinition >> fullClassName [
	"Using #class selector for classes for backwards compatibility"

	^ self classIsMeta
		ifFalse: [self className]
		ifTrue: [
			(self actualClass notNil and: [ self actualClass isTrait ])
				ifFalse: [self className, ' class']
				ifTrue: [self className, ' classSide']]
]

{ #category : #accessing }
MCMethodDefinition >> fullTimeStamp [
	^TimeStamp fromMethodTimeStamp: timeStamp
]

{ #category : #renaming }
MCMethodDefinition >> handlePackageRename: oldPackageName to: newPackageName [ 
	"If I'm an extension or override method, rename the category to be prefixed with newPackageName."
	((self isExtensionMethod or: [ self isOverrideMethod ]) and: [ (self category allButFirst beginsWith: newPackageName asLowercase) not ]) ifTrue:
		[ self actualClass organization
			renameCategory: self category
			toBe:
				'*' ,
					(self
						newCategoryNameFor: self category allButFirst
						givenRenameFrom: oldPackageName
						to: newPackageName) asLowercase ]
]

{ #category : #comparing }
MCMethodDefinition >> hash [
	| hash |
	hash := classIsMeta asString hashWithInitialHash: 0.
	hash := source hashWithInitialHash: hash.
	hash := category hashWithInitialHash: hash.
	hash := className hashWithInitialHash: hash.
	^ hash
]

{ #category : #serializing }
MCMethodDefinition >> initializeWithClassName: classString
classIsMeta: metaBoolean
selector: selectorString
category: catString
timeStamp: timeString
source: sourceString [
	className := classString asSymbol.
	selector := selectorString asSymbol.
	category := catString ifNil: [Categorizer default] ifNotNil: [catString asSymbol].
	timeStamp := timeString.
	classIsMeta := metaBoolean.
	source := sourceString withSqueakLineEndings
]

{ #category : #testing }
MCMethodDefinition >> isCodeDefinition [
	^ true
]

{ #category : #installing }
MCMethodDefinition >> isExtensionMethod [
	^ category beginsWith: '*'
]

{ #category : #testing }
MCMethodDefinition >> isExternalStructureFieldDefinition [
	^ selector = #fields
		and: [classIsMeta
			and: [
				(Smalltalk at: #ExternalStructure ifPresent: [:externalStructure |
					self actualClass theNonMetaClass inheritsFrom: externalStructure]) == true]]
			
	
]

{ #category : #testing }
MCMethodDefinition >> isInitializer [
	^ selector = #initialize and: [classIsMeta]
	
]

{ #category : #testing }
MCMethodDefinition >> isMethodDefinition [
	^true
]

{ #category : #installing }
MCMethodDefinition >> isOverrideMethod [
	"this oughta check the package"
	^ self isExtensionMethod and: [category endsWith: '-override']
]

{ #category : #accessing }
MCMethodDefinition >> load [
	| class |
	class := self actualClass.
	class
		compile: source
		classified: category
		withStamp: timeStamp
		notifying: nil
		logSource: (SystemChangeNotifier uniqueInstance isBroadcasting and: [class acceptsLoggingOfCompilation])
]

{ #category : #installing }
MCMethodDefinition >> postload [
	self isInitializer
		ifTrue: [self actualClass theNonMetaClass initialize].
	self isExternalStructureFieldDefinition
		ifTrue: [[self actualClass theNonMetaClass compileFields]
			ifError: [:msg | Transcript showln: '[FFI] ', msg]].
]

{ #category : #annotations }
MCMethodDefinition >> printAnnotations: requests on: aStream [
	"Add a string for an annotation pane, trying to fulfill the annotation requests.
	These might include anything that
		Preferences defaultAnnotationRequests 
	might return. Which includes anything in
		Preferences annotationInfo
	To edit these, use:"
	"Preferences editAnnotations"

	requests do: [ :aRequest |
		aRequest == #timeStamp ifTrue: [ aStream nextPutAll: self timeStamp ].
		aRequest == #messageCategory ifTrue: [ aStream nextPutAll: self category ].
		aRequest == #requirements ifTrue: [
			self requirements do: [ :req |
				aStream nextPutAll: req ] separatedBy: [ aStream space ]].
	] separatedBy: [ aStream space ].
]

{ #category : #accessing }
MCMethodDefinition >> protocol [
	"Answer in which protocol (conceptual groups of methods) the receiver is grouped into."
	^category
]

{ #category : #installing }
MCMethodDefinition >> removeSelector: aSelector fromClass: aClass [
	"Safely remove the given selector from the target class.
	Be careful not to remove the selector when it has wondered
	to another package."
	| newCategory |
	newCategory := aClass organization categoryOfElement: aSelector.
	newCategory ifNotNil:[
		"If moved to and fro extension, ignore removal"
		(category beginsWith: '*') = (newCategory beginsWith: '*') ifFalse:[^self].
		"Check if moved between different extension categories"
		((category beginsWith: '*') and:[category ~= newCategory]) ifTrue:[^self]].
	aClass removeSelector: aSelector.

]

{ #category : #comparing }
MCMethodDefinition >> requirements [
	^{ className }
]

{ #category : #installing }
MCMethodDefinition >> scanForPreviousVersions [
	"Answer change records for other versions of this method, i.e. other overrides and the original version"
	| versions |
	versions := OrderedCollection new.
	PackageInfo default changeRecordsForMethod: self asMethodReference do: [:record |
		record category = category ifFalse: [versions add: record]].
	^versions

]

{ #category : #accessing }
MCMethodDefinition >> selector [
	^selector
]

{ #category : #comparing }
MCMethodDefinition >> sortKey [
	^ self className, '.', (self classIsMeta ifTrue: ['meta'] ifFalse: ['nonmeta']), '.', self selector
]

{ #category : #accessing }
MCMethodDefinition >> source [
	^ source
]

{ #category : #printing }
MCMethodDefinition >> summary [
	^ self fullClassName , '>>' , selector
]

{ #category : #printing }
MCMethodDefinition >> summaryAndRevision [
	^String streamContents:
		[:s | s nextPutAll: self timeStamp;
			space; nextPutAll: self summary;
			nextPutAll: ' {'; nextPutAll: self category;
			nextPut: $}]
]

{ #category : #printing }
MCMethodDefinition >> summarySuffixOver: previousDefinition [
	| sourceChanged categoryChanged timeStampChanged |
	sourceChanged := self source ~= previousDefinition source.
	timeStampChanged := self timeStamp ~= previousDefinition timeStamp.
	categoryChanged := self category ~= previousDefinition category.
	sourceChanged | timeStampChanged | categoryChanged
		ifFalse: [ ^super summarySuffixOver: previousDefinition ].
	sourceChanged ifTrue: [
		^categoryChanged
			ifTrue: [ ' (changed and recategorized)' ]
			ifFalse: [ ' (changed)' ] ].
	timeStampChanged & categoryChanged
		ifTrue: [^ ' (recategorized and different time stamp)' ].
	^categoryChanged
		ifTrue: [ ' (only recategorized)' ]
		ifFalse: [ ' (only different time stamp)' ]

]

{ #category : #accessing }
MCMethodDefinition >> timeStamp [
	^ timeStamp ifNil: ['']
]

{ #category : #installing }
MCMethodDefinition >> unload [
	| previousVersions |
	self isOverrideMethod ifTrue: [
		previousVersions := self scanForPreviousVersions].
	previousVersions isEmptyOrNil 
		ifTrue: [self actualClass ifNotNil: [:class |
			self removeSelector: selector fromClass: class]]
		ifFalse: [
			"remove our override from history, even if buried below other overrides"
			previousVersions reverseDo: [:version | version fileIn]] 
]

{ #category : #accessing }
MCMethodDefinition >> workingCopy [
	"Answer the working copy of which this object is defined."
	^ self asMethodReference workingCopy
]
