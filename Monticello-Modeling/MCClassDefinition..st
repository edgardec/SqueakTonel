Class {
	#name : #MCClassDefinition,
	#superclass : #MCDefinition,
	#instVars : [
		'name',
		'superclassName',
		'variables',
		'category',
		'type',
		'comment',
		'commentStamp',
		'traitComposition',
		'classTraitComposition'
	],
	#category : #'Monticello-Modeling'
}

{ #category : #obsolete }
MCClassDefinition class >> name: nameString
superclassName: superclassString
category: categoryString 
instVarNames: ivarArray
classVarNames: cvarArray
poolDictionaryNames: poolArray
classInstVarNames: civarArray
comment: commentString [
	^ self	name: nameString
			superclassName: superclassString
			category: categoryString 
			instVarNames: ivarArray
			classVarNames: cvarArray
			poolDictionaryNames: poolArray
			classInstVarNames: civarArray
			type: #normal
			comment: commentString

]

{ #category : #obsolete }
MCClassDefinition class >> name: nameString
superclassName: superclassString
category: categoryString 
instVarNames: ivarArray
classVarNames: cvarArray
poolDictionaryNames: poolArray
classInstVarNames: civarArray
type: typeSymbol
comment: commentString [
	^ self 
		name: nameString
		superclassName: superclassString
		category: categoryString 
		instVarNames: ivarArray
		classVarNames: cvarArray
		poolDictionaryNames: poolArray
		classInstVarNames: civarArray
		type: typeSymbol
		comment: commentString
		commentStamp: nil
]

{ #category : #'instance creation' }
MCClassDefinition class >> name: nameString
superclassName: superclassString
category: categoryString 
instVarNames: ivarArray
classVarNames: cvarArray
poolDictionaryNames: poolArray
classInstVarNames: civarArray
type: typeSymbol
comment: commentString
commentStamp: stampString [
	^ self instanceLike:
		(self new initializeWithName: nameString
					superclassName: superclassString
					traitComposition: '{}'
					classTraitComposition: '{}'
					category: categoryString 
					instVarNames: ivarArray
					classVarNames: cvarArray
					poolDictionaryNames: poolArray
					classInstVarNames: civarArray
					type: typeSymbol
					comment: commentString
					commentStamp: stampString)
]

{ #category : #obsolete }
MCClassDefinition class >> name: nameString
superclassName: superclassString
category: categoryString 
instVarNames: ivarArray
comment: commentString [
	^ self	name: nameString
			superclassName: superclassString
			category: categoryString 
			instVarNames: ivarArray
			classVarNames: #()
			poolDictionaryNames: #()
			classInstVarNames: #()
			comment: commentString

]

{ #category : #'instance creation' }
MCClassDefinition class >> name: nameString
superclassName: superclassString
traitComposition: traitCompositionString
classTraitComposition: classTraitCompositionString
category: categoryString 
instVarNames: ivarArray
classVarNames: cvarArray
poolDictionaryNames: poolArray
classInstVarNames: civarArray
type: typeSymbol
comment: commentString
commentStamp: stampString [
	
	^ self instanceLike:
		(self new initializeWithName: nameString
					superclassName: superclassString
					traitComposition: traitCompositionString
					classTraitComposition: classTraitCompositionString
					category: categoryString 
					instVarNames: ivarArray
					classVarNames: cvarArray
					poolDictionaryNames: poolArray
					classInstVarNames: civarArray
					type: typeSymbol
					comment: commentString
					commentStamp: stampString)
]

{ #category : #visiting }
MCClassDefinition >> = aDefinition [
	^(super = aDefinition)
		and: [superclassName = aDefinition superclassName
		and: [self traitCompositionString = aDefinition traitCompositionString
		and: [self classTraitCompositionString = aDefinition classTraitCompositionString
		and: [category = aDefinition category
		and: [type = aDefinition type
		and: [self sortedVariables = aDefinition sortedVariables
		and: [comment = aDefinition comment]]]]]]]
]

{ #category : #visiting }
MCClassDefinition >> accept: aVisitor [
	aVisitor visitClassDefinition: self.
	(self hasClassInstanceVariables or: [self hasClassTraitComposition])
		ifTrue: [aVisitor visitMetaclassDefinition: self].

]

{ #category : #accessing }
MCClassDefinition >> actualClass [
	^ self actualClassIn: Environment current
]

{ #category : #accessing }
MCClassDefinition >> actualClassIn: anEnvironment [
	^anEnvironment classNamed: self className
]

{ #category : #initializing }
MCClassDefinition >> addVariables: aCollection ofType: aClass [

	aCollection do: [ :variable |
		variables add: (aClass name: variable asString ) ]
]

{ #category : #accessing }
MCClassDefinition >> category [
	^ category
]

{ #category : #accessing }
MCClassDefinition >> classInstVarNames [
	^ self selectVariables: #isClassInstanceVariable
]

{ #category : #printing }
MCClassDefinition >> classInstanceVariablesString [
	^ self stringForVariablesOfType: #isClassInstanceVariable
]

{ #category : #accessing }
MCClassDefinition >> className [
	^ name
]

{ #category : #accessing }
MCClassDefinition >> classTraitComposition [
	^classTraitComposition
]

{ #category : #accessing }
MCClassDefinition >> classTraitCompositionString [
	^self classTraitComposition ifNil: ['{}'].
]

{ #category : #accessing }
MCClassDefinition >> classVarNames [
	^(self selectVariables: #isClassVariable) asArray sort
]

{ #category : #printing }
MCClassDefinition >> classVariablesString [
	^ self stringForVariablesOfType: #isClassVariable
]

{ #category : #accessing }
MCClassDefinition >> comment [
	^ comment
]

{ #category : #accessing }
MCClassDefinition >> commentStamp [
	^ commentStamp
]

{ #category : #installing }
MCClassDefinition >> createClass [
	| environment superClass class composition |
	environment := Environment current.
	superClass := superclassName == #nil ifFalse:
					[environment valueOf: superclassName
						ifAbsent: [(KeyNotFound key: superclassName) signal]].
	[class := (ClassBuilder new)
			name: name 
			inEnvironment: environment
			subclassOf: superClass
			type: type 
			instanceVariableNames: self instanceVariablesString 
			classVariableNames: self classVariablesString 
			poolDictionaries: self sharedPoolsString
			category: category.
	] on: Warning, DuplicateVariableError do:[:ex| ex resume].

	"The following is written to support traits unloading"
	composition := self traitComposition ifNil: [Array empty] ifNotNil: [:traitComposition | Compiler evaluate: traitComposition].
	(composition isCollection and:[composition isEmpty and:[class traitComposition isEmpty]]) ifFalse:[
		class setTraitComposition: composition asTraitComposition.
	].

	composition := self classTraitComposition ifNil: [Array new] ifNotNil: [:traitComposition | Compiler evaluate: traitComposition].
	(composition isCollection and:[composition isEmpty and:[class class traitComposition isEmpty]]) ifFalse:[
		class class setTraitComposition: composition asTraitComposition.
	].

	^class
]

{ #category : #initializing }
MCClassDefinition >> defaultCommentStamp [
	^ String new

	"The version below avoids stomping on stamps already in the image

	^ (Smalltalk at: name ifPresent: [:c | c organization commentStamp])
		ifNil: ['']
	"

]

{ #category : #printing }
MCClassDefinition >> definitionAndCommentString [
	^ String streamContents: [:stream |
		self printDefinitionOn: stream.
		stream cr; cr.
		self printClassSideDefinitionOn: stream.    
		stream cr; cr.
		self printCommentOn: stream]
]

{ #category : #printing }
MCClassDefinition >> definitionString [
	^ String streamContents: [:stream | self printDefinitionOn: stream]
]

{ #category : #accessing }
MCClassDefinition >> description [
	^{ name }

]

{ #category : #renaming }
MCClassDefinition >> handlePackageRename: oldPackageName to: newPackageName [ 
	(self actualClass category beginsWith: newPackageName) ifFalse:
		[ self actualClass category:
			(self
				newCategoryNameFor: self actualClass category
				givenRenameFrom: oldPackageName
				to: newPackageName) ]
]

{ #category : #testing }
MCClassDefinition >> hasClassInstanceVariables [
	^ (self selectVariables: #isClassInstanceVariable) isEmpty not
]

{ #category : #testing }
MCClassDefinition >> hasClassTraitComposition [
	^self classTraitCompositionString ~= '{}'
]

{ #category : #testing }
MCClassDefinition >> hasComment [
	^ comment isEmptyOrNil not
]

{ #category : #testing }
MCClassDefinition >> hasTraitComposition [
	^self traitCompositionString ~= '{}'
]

{ #category : #comparing }
MCClassDefinition >> hash [

	| hash |
	hash := name hashWithInitialHash: 0.
	hash := superclassName hashWithInitialHash: hash.
	hash := self traitCompositionString hashWithInitialHash: hash.
	hash := self classTraitComposition asString hashWithInitialHash: hash.
	hash := (category ifNil: ['']) hashWithInitialHash: hash.
	hash := type hashWithInitialHash: hash.
	variables do: [ :v |
		hash := v name hashWithInitialHash: hash ].
	^hash
]

{ #category : #initializing }
MCClassDefinition >> initializeWithName: nameString
superclassName: superclassString
category: categoryString 
instVarNames: ivarArray
classVarNames: cvarArray
poolDictionaryNames: poolArray
classInstVarNames: civarArray
type: typeSymbol
comment: commentString
commentStamp: stampStringOrNil [
	name := nameString asSymbol.
	superclassName := superclassString ifNil: ['nil'] ifNotNil: [superclassString asSymbol].
	category := categoryString.
	type := typeSymbol.
	comment := commentString withSqueakLineEndings.
	commentStamp := stampStringOrNil ifNil: [self defaultCommentStamp].
	variables := OrderedCollection  new.
	self addVariables: ivarArray ofType: MCInstanceVariableDefinition.
	self addVariables: cvarArray sorted ofType: MCClassVariableDefinition.
	self addVariables: poolArray sorted ofType: MCPoolImportDefinition.
	self addVariables: civarArray ofType: MCClassInstanceVariableDefinition
]

{ #category : #initializing }
MCClassDefinition >> initializeWithName: nameString
superclassName: superclassString
traitComposition: traitCompositionString
classTraitComposition: classTraitCompositionString
category: categoryString 
instVarNames: ivarArray
classVarNames: cvarArray
poolDictionaryNames: poolArray
classInstVarNames: civarArray
type: typeSymbol
comment: commentString
commentStamp: stampStringOrNil [
	name := nameString asSymbol.
	superclassName := superclassString ifNil: ['nil'] ifNotNil: [superclassString asSymbol].
	traitComposition := traitCompositionString.
	classTraitComposition := classTraitCompositionString.
	category := categoryString.
	type := typeSymbol.
	comment := commentString withSqueakLineEndings.
	commentStamp := stampStringOrNil ifNil: [self defaultCommentStamp].
	variables := OrderedCollection  new.
	self addVariables: ivarArray ofType: MCInstanceVariableDefinition.
	self addVariables: cvarArray sorted ofType: MCClassVariableDefinition.
	self addVariables: poolArray sorted ofType: MCPoolImportDefinition.
	self addVariables: civarArray ofType: MCClassInstanceVariableDefinition
]

{ #category : #accessing }
MCClassDefinition >> instVarNames [
	^ self selectVariables: #isInstanceVariable
]

{ #category : #printing }
MCClassDefinition >> instanceVariablesString [
	^ self stringForVariablesOfType: #isInstanceVariable
]

{ #category : #testing }
MCClassDefinition >> isClassDefinition [
	^ true
]

{ #category : #testing }
MCClassDefinition >> isCodeDefinition [
	^ true
]

{ #category : #testing }
MCClassDefinition >> isTraitDefinition [
^false
]

{ #category : #printing }
MCClassDefinition >> kindOfSubclass [
	type = #normal ifTrue: [^' subclass: '].
	type = #variable ifTrue: [^' variableSubclass: '].
	type = #bytes ifTrue: [^' variableByteSubclass: '].
	type = #compiledMethod ifTrue: [^' variableByteSubclass: ' ].
	type = #shorts ifTrue: [^' variableDoubleByteSubclass: '].
	type = #words ifTrue: [^' variableWordSubclass: '].
	type = #longs ifTrue: [^' variableDoubleWordSubclass: '].
	type = #weak ifTrue: [^' weakSubclass: ' ].
	type = #ephemeron ifTrue: [^' ephemeronSubclass: ' ].
	type = #immediate ifTrue: [^' immediateSubclass: ' ].
	self error: 'Unrecognized class type'

]

{ #category : #installing }
MCClassDefinition >> load [
	 self createClass ifNotNil:
		[:class |
		class class instanceVariableNames: self classInstanceVariablesString.
		self hasComment ifTrue: [class classComment: comment stamp: commentStamp]]
]

{ #category : #accessing }
MCClassDefinition >> poolDictionaries [
	^ self selectVariables: #isPoolImport
]

{ #category : #annotations }
MCClassDefinition >> printAnnotations: requests on: aStream [
	"Add a string for an annotation pane, trying to fulfill the annotation requests.
	These might include anything that
		Preferences defaultAnnotationRequests 
	might return. Which includes anything in
		Preferences annotationInfo
	To edit these, use:"
	"Preferences editAnnotations"

	requests do: [ :aRequest |
		aRequest == #requirements ifTrue: [
			self requirements do: [ :req | aStream nextPutAll: req ] separatedBy: [ aStream space ]]
	] separatedBy: [ aStream space ].
]

{ #category : #printing }
MCClassDefinition >> printClassSideDefinitionOn: stream [
	
	stream
		nextPutAll: self className;
		nextPutAll: ' class ';
		cr; tab.
	self hasClassTraitComposition ifTrue: [
		stream 
			nextPutAll: 'uses: ';
	 		nextPutAll: self classTraitCompositionString;
			cr; tab ].
	stream
		nextPutAll: 'instanceVariableNames: ';
		store: self classInstanceVariablesString
]

{ #category : #printing }
MCClassDefinition >> printCommentOn: stream [
	stream
		nextPut: $";
		nextPutAll: self comment asString;
		nextPut: $"

]

{ #category : #printing }
MCClassDefinition >> printDefinitionOn: stream [
		stream 
			nextPutAll: self superclassName;
			nextPutAll: self kindOfSubclass;
			nextPut: $# ;
			nextPutAll: self className;
			cr; tab.
		self hasTraitComposition ifTrue: [
			stream 
				nextPutAll: 'uses: ';
		 		nextPutAll: self traitCompositionString;
				cr; tab ].
		stream
			nextPutAll: 'instanceVariableNames: ';
			store: self instanceVariablesString;
			cr; tab;
			nextPutAll: 'classVariableNames: ';
			store: self classVariablesString;
			cr; tab;
			nextPutAll: 'poolDictionaries: ';
			store: self sharedPoolsString;
			cr; tab;
			nextPutAll: 'category: ';
			store: self category asString
]

{ #category : #comparing }
MCClassDefinition >> provisions [
	^{ name }
]

{ #category : #comparing }
MCClassDefinition >> requirements [
	^superclassName == #nil
		ifTrue: [self poolDictionaries]
		ifFalse: [{ superclassName }, self poolDictionaries,
			(self hasTraitComposition
				ifTrue: [(Scanner new scanTokens: self traitComposition) flattened select: [:each | each first isUppercase]]
				ifFalse: [#()])].
]

{ #category : #accessing }
MCClassDefinition >> selectVariables: aSelector [
	^ variables select: [:v | v perform: aSelector] thenCollect: [:v | v name]
]

{ #category : #printing }
MCClassDefinition >> sharedPoolsString [
	^ self stringForVariablesOfType: #isPoolImport
]

{ #category : #accessing }
MCClassDefinition >> sortKey [
	^ self className
]

{ #category : #accessing }
MCClassDefinition >> sortedVariables [
	"sort variables for comparison purposes"

	| orderDependents toSort |
	orderDependents := OrderedCollection new: variables size.
	toSort := OrderedCollection new.
	variables do: [ :variable |
		variable isOrderDependend
			ifTrue: [ orderDependents addLast: variable ]
			ifFalse: [ toSort addLast: variable ] ].
	toSort sort: [ :a :b | a name <= b name ].
	^orderDependents
		addAllLast: toSort;
		yourself
]

{ #category : #printing }
MCClassDefinition >> source [
	^ self definitionAndCommentString
]

{ #category : #serializing }
MCClassDefinition >> storeDataOn: aDataStream [
	| instVarSize |
	instVarSize := (self hasTraitComposition or: [ self hasClassTraitComposition ])
		ifTrue: [ self class instSize ]
		ifFalse: [ self class instSize - 2 ].
	aDataStream
		beginInstance: self class
		size: instVarSize.
	1 to: instVarSize do: [ :index |
		aDataStream nextPut: (self instVarAt: index) ].
]

{ #category : #installing }
MCClassDefinition >> stringForVariablesOfType: aSymbol [
	^ String streamContents:
		[:stream |
		(self selectVariables: aSymbol) 
			do: [:ea | stream nextPutAll: ea]
			separatedBy: [stream space]]
]

{ #category : #printing }
MCClassDefinition >> summary [
	^ name
]

{ #category : #accessing }
MCClassDefinition >> superclassName [
	^ superclassName
]

{ #category : #accessing }
MCClassDefinition >> traitComposition [
	^traitComposition
]

{ #category : #accessing }
MCClassDefinition >> traitCompositionString [
	^self traitComposition ifNil: ['{}'].
]

{ #category : #accessing }
MCClassDefinition >> type [
	^ type
]

{ #category : #installing }
MCClassDefinition >> unload [
	Environment current removeClassNamed: name
]

{ #category : #accessing }
MCClassDefinition >> variables [
	^ variables
]

{ #category : #accessing }
MCClassDefinition >> workingCopy [
	^ self actualClass workingCopy
]
