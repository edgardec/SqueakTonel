"
I provide an inert model of a Class, used by FileContentsBrowser to manipulate filedout code. Instead of a method dictionary or selectors onto CompiledMethods, I have a dictionary (""source"") of selectors onto ChangeRecords, which were, in the case of FileContentsBrowser, parsed from a source or change set file.
"
Class {
	#name : #PseudoClass,
	#superclass : #Object,
	#instVars : [
		'name',
		'definition',
		'organization',
		'source',
		'metaClass'
	],
	#category : #'System-FilePackage'
}

{ #category : #methods }
PseudoClass >> addMethodChange: aChangeRecord [
	| selector |
	selector := self newParser parseSelector: aChangeRecord string.
	self organization classify: selector under: aChangeRecord category.
	self sourceCodeAt: selector put: aChangeRecord
]

{ #category : #accessing }
PseudoClass >> allCallsOn [
	^ (self realClass ifNil: [ ^#() ]) allCallsOn
]

{ #category : #accessing }
PseudoClass >> allInstVarNames [

	self realClass ifNotNil: [ :realClass | ^realClass allInstVarNames ].
	^#()
]

{ #category : #private }
PseudoClass >> allSubclassesWithLevelDo: classAndLevelBlock startingLevel: level [
	^ (self realClass ifNil: [ ^self ])  allSubclassesWithLevelDo: classAndLevelBlock startingLevel: level
]

{ #category : #accessing }
PseudoClass >> allSuperclasses [
	^ (self realClass ifNil: [ ^#() ]) allSuperclasses
]

{ #category : #'testing method dictionary' }
PseudoClass >> bindingOf: varName [
	self exists ifTrue:[
		(self realClass bindingOf: varName) ifNotNil:[:binding| ^binding].
	].
	^Smalltalk bindingOf: varName asSymbol
]

{ #category : #class }
PseudoClass >> classComment: aChangeRecord [
	self organization classComment: aChangeRecord
]

{ #category : #accessing }
PseudoClass >> classInstVarNames [

	self realClass ifNotNil: [ :realClass | ^realClass instVarNames ].
	^#()
]

{ #category : #errors }
PseudoClass >> classNotDefined [
	^self inform: self name,' is not defined in the system.
You have to define this class first.'.
]

{ #category : #class }
PseudoClass >> classPool [ 
	self exists ifFalse: [^ nil].
	^ self realClass classPool
]

{ #category : #accessing }
PseudoClass >> classVarNames [

	self realClass ifNotNil: [ :realClass | ^realClass classVarNames ].
	^#()
]

{ #category : #class }
PseudoClass >> comment [
	^self organization commentRemoteStr
		ifNil: [ self name,' has not been commented in this file']
		ifNotNil: [:rStr | rStr string]
]

{ #category : #class }
PseudoClass >> comment: aString [
	self commentString: aString.
]

{ #category : #class }
PseudoClass >> commentString [
	^self comment asString
]

{ #category : #class }
PseudoClass >> commentString: aString [
	self classComment: aString asText. "Just wrap it"
]

{ #category : #accessing }
PseudoClass >> compilerClass [

	^self realClass
		ifNil: [ Compiler ]
		ifNotNil: [ :realClass | realClass compilerClass ]
]

{ #category : #private }
PseudoClass >> confirmRemovalOf: aString [
	^self confirm:'Remove ',aString,' ?'
]

{ #category : #class }
PseudoClass >> definition [
	| link linkText defText |
	^definition ifNil:
		[defText := Text fromString: 'There is no class definition for '.
		link := TextLink new.
		linkText := link analyze: self name with: 'Definition'.
		linkText := Text string: (linkText ifNil: ['']) attribute: link.
		defText append: linkText; append: ' in this file'].
]

{ #category : #class }
PseudoClass >> definition: aString [
	definition := aString
]

{ #category : #private }
PseudoClass >> evaluate: aString [
	^Compiler evaluate: aString for: nil logged: true
]

{ #category : #testing }
PseudoClass >> exists [
	^(Smalltalk at: self name asSymbol ifAbsent:[^false]) isKindOf: Behavior
]

{ #category : #'fileIn\/fileOut' }
PseudoClass >> fileIn [
	"FileIn the receiver"
	self hasDefinition ifTrue:[self fileInDefinition].
	self fileInMethods: self selectors.
	metaClass ifNotNil:[metaClass fileIn].
	self needsInitialize ifTrue:[
		self evaluate: self name,' initialize'.
	].
]

{ #category : #'fileIn\/fileOut' }
PseudoClass >> fileInCategory: aCategory [
	^self fileInMethods: (self organization listAtCategoryNamed: aCategory)
]

{ #category : #'fileIn\/fileOut' }
PseudoClass >> fileInDefinition [
	self hasDefinition ifFalse:[^self].
	(self makeSureSuperClassExists: (definition copyUpTo: Character space)) ifFalse:[^self].
	self hasDefinition ifTrue:[
		Transcript cr; show:'Defining ', self name.
		self evaluate: self definition].
	self exists ifFalse:[^self].
	self hasComment ifTrue:[self realClass classComment: self comment].
]

{ #category : #'fileIn\/fileOut' }
PseudoClass >> fileInMethod: selector [
	^self fileInMethods: (Array with: selector)
]

{ #category : #'fileIn\/fileOut' }
PseudoClass >> fileInMethods [
	^self fileInMethods: self selectors
]

{ #category : #'fileIn\/fileOut' }
PseudoClass >> fileInMethods: aCollection [
	"FileIn all methods with selectors taken from aCollection"
	| theClass |
	self exists ifFalse:[^self classNotDefined].
	theClass := self realClass.
	aCollection do:[:sel|
		| cat |
		cat := self organization categoryOfElement: sel.
		cat = self removedCategoryName ifFalse:[
			theClass 
				compile: (self sourceCodeAt: sel) 
				classified: cat
				withStamp: (self stampAt: sel)
				notifying: nil.
		].
	].
]

{ #category : #'fileIn\/fileOut' }
PseudoClass >> fileOut [
	| internalStream |
	internalStream := WriteStream on: (String new: 1000).
	self fileOutOn: internalStream.
	self needsInitialize ifTrue:[
		internalStream cr; nextChunkPut: self name,' initialize'.
	].

	FileStream writeSourceCodeFrom: internalStream baseName: self name isSt: true useHtml: false.

]

{ #category : #'fileIn\/fileOut' }
PseudoClass >> fileOutCategory: categoryName [

	| internalStream |
	internalStream := WriteStream on: (String new: 1000).
	self fileOutMethods: (self organization listAtCategoryNamed: categoryName)
			on: internalStream.
	FileStream writeSourceCodeFrom: internalStream baseName: (self name, '-', categoryName) isSt: true useHtml: false.

]

{ #category : #'fileIn\/fileOut' }
PseudoClass >> fileOutDefinitionOn: aStream [
	self hasDefinition ifFalse:[^self].
	aStream nextChunkPut: self definition; cr.
	self hasComment
		ifTrue:
			[aStream cr.
			self organization commentRemoteStr fileOutOn:
aStream]
]

{ #category : #'fileIn\/fileOut' }
PseudoClass >> fileOutMethod: selector [
	| internalStream |

	internalStream := WriteStream on: (String new: 1000).

	self fileOutMethods: (Array with: selector) on: internalStream.

	FileStream writeSourceCodeFrom: internalStream baseName: (self name , '-' , (selector copyReplaceAll: ':' with: '')) isSt: true useHtml: false.

]

{ #category : #'fileIn\/fileOut' }
PseudoClass >> fileOutMethods: aCollection on: aStream [
	"FileOut all methods with selectors taken from aCollection"
	| categories |
	categories := Dictionary new.
	aCollection do:[:sel|
		| cat |
		cat := self organization categoryOfElement: sel.
		cat = self removedCategoryName ifFalse:[
			(categories includesKey: cat) 
				ifFalse:[categories at: cat put: Set new].
			(categories at: cat) add: sel].
	].
	categories associationsDo:[:assoc|
		assoc value do:[:sel|
			aStream cr.
			(self sourceCode at: sel) fileOutOn: aStream.
		].
	].
]

{ #category : #'fileIn\/fileOut' }
PseudoClass >> fileOutMethodsOn: aStream [
	^self fileOutMethods: self selectors on: aStream.
]

{ #category : #'fileIn\/fileOut' }
PseudoClass >> fileOutOn: aStream [
	"FileOut the receiver"
	self fileOutDefinitionOn: aStream.
	metaClass ifNotNil:[metaClass fileOutDefinitionOn: aStream].
	self fileOutMethods: self selectors on: aStream.
	metaClass ifNotNil:[metaClass fileOutMethods: metaClass selectors on: aStream].
]

{ #category : #accessing }
PseudoClass >> fullName [
	^self name
]

{ #category : #testing }
PseudoClass >> hasChanges [

	self sourceCode isEmpty ifFalse:[^true].
	self organization hasNoComment ifFalse:[^true].
	definition ifNotNil: [ ^true].
	metaClass ifNotNil: [ ^metaClass hasChanges].
	^false
]

{ #category : #testing }
PseudoClass >> hasComment [
	^self organization commentRemoteStr notNil
]

{ #category : #testing }
PseudoClass >> hasDefinition [
	^definition notNil
]

{ #category : #testing }
PseudoClass >> hasMetaclass [
	^metaClass notNil
]

{ #category : #'testing method dictionary' }
PseudoClass >> includesSelector: aSymbol [ 
	self exists
		ifTrue: [^self realClass includesSelector: aSymbol]
		ifFalse: [
			"Not sure what the answer should be in this case (I'm unfamiliar with this class),
			 so I want to force an error rather than answer something nonsensical.  This is
			 no worse than the old behavior, when this method didn't even exist, resulting
			 in a MessageNotUnderstood error."
			self error: 'real class does not exist'
		]
]

{ #category : #accessing }
PseudoClass >> instVarNames [

	self realClass ifNotNil: [ :realClass | ^realClass instVarNames ].
	^#()
]

{ #category : #testing }
PseudoClass >> isTrait [
	^false
]

{ #category : #printing }
PseudoClass >> literalScannedAs: scannedLiteral environment: anEnvironment notifying: requestor [ 
	^ scannedLiteral
]

{ #category : #private }
PseudoClass >> makeSureClassExists: aString [
	| theClass |
	theClass := Smalltalk at: (aString asSymbol) ifAbsent:[nil].
	theClass ifNotNil:[^true].
	^self confirm: aString,' does not exist in the system. Use nil instead?'.
]

{ #category : #private }
PseudoClass >> makeSureSuperClassExists: aString [
	| theClass |
	theClass := Smalltalk at: (aString asSymbol) ifAbsent:[nil].
	theClass ifNotNil:[^true].
	^self confirm: 'The super class ',aString,' does not exist in the system. Use nil instead?'.
]

{ #category : #class }
PseudoClass >> metaClass [
	^metaClass ifNil:[metaClass := PseudoMetaclass new name: (self name)].
]

{ #category : #methods }
PseudoClass >> methodChange: aChangeRecord [
	aChangeRecord isMetaClassChange ifTrue:[
		^self metaClass addMethodChange: aChangeRecord.
	] ifFalse:[
		^self addMethodChange: aChangeRecord.
	].

]

{ #category : #accessing }
PseudoClass >> name [
	^name
]

{ #category : #accessing }
PseudoClass >> name: anObject [
	name := anObject
]

{ #category : #testing }
PseudoClass >> nameExists [
	^Smalltalk globals includesKey: self name asSymbol
]

{ #category : #testing }
PseudoClass >> needsInitialize [
	^self hasMetaclass and:[
		self metaClass includesSelector: #initialize]
]

{ #category : #accessing }
PseudoClass >> newCompiler [
	"Answer a Compiler suitable for compiling this Behavior"
	^self compilerClass new parser: self newParser
]

{ #category : #accessing }
PseudoClass >> newParser [
	"Answer a Parser suitable for parsing source code in this Behavior"
	^self parserClass new
]

{ #category : #accessing }
PseudoClass >> organization [
	organization ifNil: [organization := PseudoClassOrganizer defaultList: SortedCollection new].

	"Making sure that subject is set correctly. It should not be necessary."
	organization setSubject: self.
	^ organization
]

{ #category : #private }
PseudoClass >> parserClass [

	^self compilerClass parserClass
]

{ #category : #accessing }
PseudoClass >> prettyPrinterClass [
	^self class prettyPrinterClass
]

{ #category : #printing }
PseudoClass >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut:$(; print: name; nextPut:$)
]

{ #category : #accessing }
PseudoClass >> realClass [

	^Smalltalk globals classNamed: self name
]

{ #category : #removing }
PseudoClass >> removeAllUnmodified [
	| stClass |
	self exists ifFalse:[^self].
	self removeUnmodifiedMethods: self selectors.
	stClass := self realClass.
	(self hasDefinition and:[stClass definition = self definition]) ifTrue:[definition := nil].
	(self hasComment and:[stClass comment asString = self commentString]) ifTrue:[ self classComment: nil].
	metaClass ifNotNil: [ metaClass removeAllUnmodified]
]

{ #category : #categories }
PseudoClass >> removeCategory: selector [
	(self organization listAtCategoryNamed: selector) do:[:sel|
		self organization removeElement: sel.
		self sourceCode removeKey: sel.
	].
	self organization removeCategory: selector.
]

{ #category : #methods }
PseudoClass >> removeMethod: selector [
	self organization removeElement: selector.
	self sourceCode removeKey: selector.

]

{ #category : #methods }
PseudoClass >> removeSelector: aSelector [
	| catName |
	catName := self removedCategoryName.
	self organization addCategory: catName before: self organization categories first.
	self organization classify: aSelector under: catName.
	self sourceCodeAt: aSelector put:'methodWasRemoved' asText.
]

{ #category : #removing }
PseudoClass >> removeUnmodifiedMethods: aCollection [
	| stClass |
	self exists ifFalse:[^self].
	stClass := self realClass.
	aCollection do:[:sel|
		(self sourceCodeAt: sel) = (stClass sourceCodeAt: sel ifAbsent:['']) asString ifTrue:[
			self removeMethod: sel.
		].
	].
	self organization removeEmptyCategories.
]

{ #category : #categories }
PseudoClass >> removedCategoryName [
	^#'*** removed methods ***'
]

{ #category : #class }
PseudoClass >> renameTo: aString [

	self hasDefinition ifTrue:[
		self isMeta ifTrue:[
			self definition: (self definition
				copyReplaceAll: name,' class'
				with: aString, ' class').
		] ifFalse:[
			self definition: (self definition 
					copyReplaceAll:'ubclass: #',name
					with:'ubclass: #', aString)]].
	name := aString.
	metaClass ifNotNil:[metaClass renameTo: aString].
]

{ #category : #methods }
PseudoClass >> selectors [
	^self sourceCode keys
]

{ #category : #methods }
PseudoClass >> selectorsDo: aBlock [

	^self sourceCode keysDo: aBlock
]

{ #category : #class }
PseudoClass >> sharedPools [ 
	self exists ifFalse: [^ nil].
	^ self realClass sharedPools
]

{ #category : #methods }
PseudoClass >> sourceCode [
	^source ifNil:[source := Dictionary new]
]

{ #category : #methods }
PseudoClass >> sourceCodeAt: sel [
	^(self sourceCode at: sel) string
]

{ #category : #methods }
PseudoClass >> sourceCodeAt: sel ifAbsent: block [
	^ self sourceCode
		at: sel
		ifPresent: [:src | src string]
		ifAbsent: block
]

{ #category : #methods }
PseudoClass >> sourceCodeAt: sel put: object [
	self sourceCode at: sel put: object
]

{ #category : #methods }
PseudoClass >> sourceCodeTemplate [
	^''
]

{ #category : #methods }
PseudoClass >> stampAt: selector [
	"Answer the authoring time-stamp of the change"

	| code |
	^ ((code := self sourceCode at: selector) isKindOf: ChangeRecord)
		ifTrue:
			[code stamp]
		ifFalse:
			[code string]
]

{ #category : #accessing }
PseudoClass >> theMetaClass [
	^ self metaClass
]

{ #category : #accessing }
PseudoClass >> theNonMetaClass [
	"Sent to a class or metaclass, always return the class"

	^self
]

{ #category : #categories }
PseudoClass >> whichCategoryIncludesSelector: aSelector [ 
	"Answer the category of the argument, aSelector, in the organization of 
	the receiver, or answer nil if the receiver does not inlcude this selector."

	^ self organization categoryOfElement: aSelector
]

{ #category : #enumerating }
PseudoClass >> withAllSubAndSuperclassesDo: aBlock [

	self realClass ifNotNil: [ :realClass | ^realClass withAllSubAndSuperclassesDo: aBlock ].
	^aBlock value: self
]

{ #category : #enumerating }
PseudoClass >> withAllSuperclassesDo: aBlock [

	self realClass ifNotNil: [ :realClass | ^realClass withAllSuperclassesDo: aBlock ].
	^aBlock value: self
]
