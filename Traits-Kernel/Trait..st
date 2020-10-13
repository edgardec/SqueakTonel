"
Defines a trait in the system. Like Class, I concretize my superclass by providing instance variables for the name and the environment.
"
Class {
	#name : #Trait,
	#superclass : #TraitDescription,
	#instVars : [
		'name',
		'environment',
		'classTrait',
		'category'
	],
	#category : #'Traits-Kernel'
}

{ #category : #public }
Trait class >> allTraitsDo: aBlock [
	"Evaluate aBlock with all the instance and class traits present in the system"
	
	Smalltalk allTraitsDo: [ :aTrait |
		aBlock
			value: aTrait instanceSide;
			value: aTrait classSide ]
]

{ #category : #'load-unload' }
Trait class >> convertClassToTrait: aClass [
	"Convert the given class to a trait"
	| aTrait |
	"Move the class out of the way"
	aClass environment removeKey: aClass name.

	"Create the trait in its place"
	aTrait := Trait named: aClass name
				uses: {}
				category: aClass category.

	aClass organization commentRemoteStr ifNotNil:[
		aTrait classComment: aClass organization classComment 
				stamp: aClass organization commentStamp].

	aClass selectorsAndMethodsDo:[:sel :meth|
		aTrait compile: (aClass sourceCodeAt: sel)
			classified: (aClass organization categoryOfElement: sel)
			withStamp: (aClass compiledMethodAt: sel) timeStamp
			notifying: nil].

	aClass classSide selectorsAndMethodsDo:[:sel :meth|
		aTrait classSide compile: (aClass classSide sourceCodeAt: sel)
			classified: (aClass classSide organization categoryOfElement: sel)
			withStamp: (aClass classSide compiledMethodAt: sel) timeStamp
			notifying: nil].

	aClass obsolete.
	^aTrait

]

{ #category : #'load-unload' }
Trait class >> convertTraitToClass: aTrait [
	"Convert the given trait to a class"
	| aClass |
	"Move the trait out of the way"
	aTrait environment removeKey: aTrait name.
	"Create the class in its place"
	aClass := Object subclass: aTrait name
				instanceVariableNames: ''
				classVariableNames: ''
				poolDictionaries: ''
				category: aTrait category.

	aTrait organization commentRemoteStr ifNotNil:[
		aClass classComment: aTrait organization classComment 
				stamp: aTrait organization commentStamp].

	aTrait selectorsAndMethodsDo:[:sel :meth|
		aClass compile: (aTrait sourceCodeAt: sel)
			classified: (aTrait organization categoryOfElement: sel)
			withStamp: (aTrait compiledMethodAt: sel) timeStamp
			notifying: nil].

	aTrait classSide selectorsAndMethodsDo:[:sel :meth|
		aClass classSide compile: (aTrait classSide sourceCodeAt: sel)
			classified: (aTrait classSide organization categoryOfElement: sel)
			withStamp: (aTrait classSide compiledMethodAt: sel) timeStamp
			notifying: nil].

	aTrait obsolete.
	^aClass

]

{ #category : #'load-unload' }
Trait class >> flattenTraitMethodsInClass: aClass [
	"Flatten all the trait methods in the given class"
	
	(aClass isTrait or:[aClass hasTraitComposition]) ifFalse:[^self].
	self storeTraitInfoInClass: aClass.
	aClass selectorsAndMethodsDo:[:sel :meth| | oldClass |
		(aClass includesLocalSelector: sel) ifFalse:[
			oldClass := meth methodHome.
			aClass compile: (aClass sourceCodeAt: sel)
				classified: (aClass organization categoryOfElement: sel)
				withStamp: (oldClass compiledMethodAt: sel ifAbsent:[meth]) timeStamp
				notifying: nil]].
	aClass traitComposition: #().
]

{ #category : #'load-unload' }
Trait class >> initialize [
	"Install after loading"
	self install.
]

{ #category : #'load-unload' }
Trait class >> install [
	"Make me the default Trait implementation"
	ClassDescription traitImpl: self.
	"And restore any previously flattened traits"
	self restoreAllTraits.

]

{ #category : #public }
Trait class >> named: aSymbol uses: aTraitCompositionOrCollection category: aString [
	"Dispatch through ClassDescription for alternative implementations"
	^ClassDescription newTraitNamed: aSymbol uses: aTraitCompositionOrCollection category: aString
]

{ #category : #'instance creation' }
Trait class >> named: aSymbol uses: aTraitComposition category: aString env: anEnvironment [
	| trait oldTrait systemCategory |
	systemCategory := aString asSymbol.
	trait := anEnvironment at: aSymbol ifAbsent: [nil].
	(trait == nil or:[trait isMemberOf: Trait]) ifFalse: [
		^self error: trait name , ' is not a Trait'].

	oldTrait := trait shallowCopy.
	trait ifNil:[trait := Trait new].

	trait
		setName: aSymbol
		andRegisterInCategory: systemCategory
		environment: anEnvironment.

	trait uses: aTraitComposition.
	
	"... notify interested clients ..."
	oldTrait ifNil:[
		SystemChangeNotifier uniqueInstance classAdded: trait inCategory: systemCategory.
	] ifNotNil:[
		SystemChangeNotifier uniqueInstance traitDefinitionChangedFrom: oldTrait to: trait.
		systemCategory = oldTrait category  ifFalse:[
			SystemChangeNotifier uniqueInstance class: trait 
				recategorizedFrom: oldTrait category to: systemCategory].
	].
	^ trait
]

{ #category : #public }
Trait class >> newTemplateIn: categoryString [
	^String streamContents: [:stream |
		stream
			nextPutAll: 'Trait named: #NameOfTrait';
			cr; tab;
			nextPutAll: 'uses: {}';
			cr; tab;
			nextPutAll: 'category: ';
			nextPut: $';
			nextPutAll: categoryString;
			nextPut: $' ]
]

{ #category : #public }
Trait class >> newTraitComposition [
	"Creates a new TraitComposition"
	^TraitComposition new
]

{ #category : #public }
Trait class >> newTraitNamed: aSymbol uses: aTraitCompositionOrCollection category: aString [
	"Creates a new trait."
	| env |
	env := self environment.
	^self
		named: aSymbol
		uses: aTraitCompositionOrCollection
		category: aString
		env: env
]

{ #category : #public }
Trait class >> newTraitNamed: aSymbol uses: aTraitCompositionOrCollection category: aString in: anEnvironment [
	"Creates a new trait."
	^self
		named: aSymbol
		uses: aTraitCompositionOrCollection
		category: aString
		env: anEnvironment
]

{ #category : #'load-unload' }
Trait class >> removeAllTraits [		"Trait removeAllTraits"
	"Removes all traits currently in use. 
	Preserves enough information so that traits can be recovered."
	| converted remain |
	converted := Set new.
	Smalltalk allClasses do:[:aClass|
		self flattenTraitMethodsInClass: aClass classSide.
		self flattenTraitMethodsInClass: aClass.
		converted add: aClass.
	] displayingProgress: 'Flattening classes'.

	remain := Smalltalk allTraits asSet.
	(1 to: remain size) do:[:i| | trait |
		trait := remain 
			detect:[:any| any users allSatisfy:[:aClass| converted includes: aClass]]
			ifNone:[self error: 'Cyclic traits detected'].
		remain remove: trait.
		self flattenTraitMethodsInClass: trait classSide.
		self flattenTraitMethodsInClass: trait.
		converted add: trait.
	] displayingProgress: 'Flattening traits'.

	"Convert all traits to classes"
	Smalltalk allTraits
		do:[:trait| self convertTraitToClass: trait] 
		displayingProgress:[:trait| 'Converting ', trait name].

]

{ #category : #'load-unload' }
Trait class >> restoreAllTraits [		"Trait restoreAllTraits"
	"Restores traits that had been previously removed.
	This is the inverse operation to removeAllTraits."
	| classes |
	classes := Smalltalk allClasses select:[:aClass| aClass includesSelector: #traitInfo].
	classes do:[:aClass| | method |
		method := aClass compiledMethodAt: #traitInfo.
		(method pragmaAt: #traitDefinition:) ifNotNil:[:pragma| 
			pragma arguments first
				ifTrue:[self convertClassToTrait: aClass]].
	] displayingProgress:[:aClass| 'Creating trait ', aClass name].
	classes := Smalltalk allClassesAndTraits select:[:aClass| 
		(aClass includesSelector: #traitInfo) 
			or:[aClass classSide includesSelector: #traitInfo]].
	classes do:[:aClass|
		self restoreCompositionOf: aClass.
		self restoreCompositionOf: aClass classSide.
	] displayingProgress:[:aClass| 'Updating ', aClass name].

]

{ #category : #'load-unload' }
Trait class >> restoreCompositionOf: aClass [
	"Restore the trait composition for the given class"
	| method requires composition |
	method := aClass compiledMethodAt: #traitInfo ifAbsent:[^self].
	aClass removeSelector: #traitInfo.
	requires := (method pragmaAt: #traitRequires:) 
		ifNil:[#()]
		ifNotNil:[:pragma| pragma arguments first].
	(requires allSatisfy:[:tn| (Smalltalk at: tn ifAbsent:[nil]) isKindOf: Trait])
		ifFalse:[^self inform: 'Cannot restore composition of ', aClass name].
	composition := (method pragmaAt: #traitComposition:) 
		ifNil:[^self]
		ifNotNil:[:pragma| Compiler evaluate: pragma arguments first].
	aClass uses: composition.
	aClass traitComposition selectorsAndMethodsDo:[:sel :meth|
		| oldMethod newMethod |
		newMethod := meth methodHome compiledMethodAt: sel.
		oldMethod := aClass compiledMethodAt: sel ifAbsent:[newMethod].
		oldMethod timeStamp = newMethod timeStamp
				ifTrue:[aClass removeSelector: sel]].
]

{ #category : #'load-unload' }
Trait class >> storeTraitInfoInClass: aClass [
	"Store trait information in the given class"
	| code |
	code := WriteStream on: (String new: 100).
	code nextPutAll: 'traitInfo
	"This method contains information to restore the trait structure
	for the receiver when traits are loaded or unloaded"'.
	aClass isTrait ifTrue:[
		code crtab; nextPutAll: '"This class was originally a trait"'.
		code crtab; nextPutAll: '<traitDefinition: true>'.
	].
	aClass hasTraitComposition ifTrue:[
		code crtab; nextPutAll: '"The trait composition for the receiver"'.
		code crtab; nextPutAll: '<traitComposition: ', aClass traitCompositionString storeString,'>'.
		code crtab; nextPutAll: '"The required traits for this trait"'.
		code crtab; nextPutAll: '<traitRequires: ', (aClass traits collectAsTraitComposition: [:t| t baseTrait name]),'>'.
	].
	aClass compile: code contents.

]

{ #category : #'load-unload' }
Trait class >> unloadTraits [
	"Trait unloadTraits"
	Trait traitImpl == self ifTrue:[Trait traitImpl: nil].
	self removeAllTraits.
	Behavior compileSilently: 'updateTraits' classified: 'accessing'.
	ClassDescription removeSelectorSilently: #updateTraits.
	ClassOrganizer organization classify: #traitComposition under: 'accessing'.
	(MCPackage named: 'Traits') unload.
	ClassOrganizer removeSelectorSilently: #traitComposition.
	Behavior removeSelectorSilently: #updateTraits.
	CurrentReadOnlySourceFiles cacheDuring: [
		Compiler recompileAll ]
]

{ #category : #converting }
Trait >> asTraitComposition [
	"Convert me into a trait composition"
	^TraitComposition with: self
]

{ #category : #accessing }
Trait >> baseTrait [
	^self
]

{ #category : #compiling }
Trait >> bindingOf: varName [
	"Answer the binding of some variable resolved in the scope of the receiver"
	^self environment bindingOf: varName asSymbol.
]

{ #category : #accessing }
Trait >> category [
	"Answer the system organization category for the receiver. First check whether the
	category name stored in the ivar is still correct and only if this fails look it up
	(latter is much more expensive)"

	| result |
	category ifNotNil: [ :symbol |
		((SystemOrganization listAtCategoryNamed: symbol) includes: self name)
			ifTrue: [ ^symbol ] ].
	category := (result := SystemOrganization categoryOfElement: self name).
	^result
]

{ #category : #accessing }
Trait >> category: aString [ 
	"Categorize the receiver under the system category, aString, removing it from 
	any previous categorization."

	| oldCategory |
	oldCategory := category.
	aString isString
		ifTrue: [
			category := aString asSymbol.
			SystemOrganization classify: self name under: category ]
		ifFalse: [self errorCategoryName].
	SystemChangeNotifier uniqueInstance
		class: self recategorizedFrom: oldCategory to: category
]

{ #category : #accessing }
Trait >> classTrait [
	^classTrait
]

{ #category : #initialize }
Trait >> definition [
	^String streamContents: [:stream |
		stream nextPutAll: 'Trait named: ';
				store: self name.
		stream cr; tab; nextPutAll: 'uses: ';
				nextPutAll: self traitComposition asString.
		stream cr; tab; nextPutAll: 'category: ';
				store: self category asString].
]

{ #category : #accessing }
Trait >> environment [
	^environment
]

{ #category : #accessing }
Trait >> environment: anObject [
	environment := anObject
]

{ #category : #'fileIn\/Out' }
Trait >> fileOutOn: aFileStream moveSource: moveSource toFile: fileIndex [
	super fileOutOn: aFileStream moveSource: moveSource toFile: fileIndex.
	self classSide hasMethods ifTrue:[
		aFileStream cr; nextPutAll: '"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!'; cr; cr.
			self classSide
				fileOutOn: aFileStream
				moveSource: moveSource
				toFile: fileIndex].
]

{ #category : #testing }
Trait >> hasClassTrait [
	^true
]

{ #category : #initialize }
Trait >> initialize [
	super initialize.
	classTrait := ClassTrait for: self.
]

{ #category : #testing }
Trait >> isBaseTrait [
	^true
]

{ #category : #testing }
Trait >> isObsolete [
	"Return true if the receiver is obsolete."
	^(self environment at: name ifAbsent: [nil]) ~~ self
]

{ #category : #initialize }
Trait >> isValidTraitName: aSymbol [
	^(aSymbol isEmptyOrNil
		or: [aSymbol first isLetter not
		or: [aSymbol anySatisfy: [:character | character isAlphaNumeric not]]]) not
]

{ #category : #accessing }
Trait >> name [
	^name
]

{ #category : #accessing }
Trait >> name: aSymbol [
	name := aSymbol
]

{ #category : #initialize }
Trait >> obsolete [
	self name: ('AnObsolete' , self name) asSymbol.
	self classTrait obsolete.
	super obsolete
]

{ #category : #initialize }
Trait >> removeFromSystem [
	self removeFromSystem: true
]

{ #category : #initialize }
Trait >> removeFromSystem: logged [
	self environment forgetClass: self logged: logged.
	self obsolete
]

{ #category : #initialize }
Trait >> rename: aString [ 
	"The new name of the receiver is the argument, aString."

	| newName |
	(newName := aString asSymbol) ~= self name
		ifFalse: [^ self].
	(self environment includesKey: newName)
		ifTrue: [^ self error: newName , ' already exists'].
	((self environment undeclared includesKey: newName)
		and: [(self environment undeclared unreferencedKeys includes: newName) not])
		ifTrue: [self inform: 'There are references to, ' , aString printString , '
from Undeclared. Check them after this change.'].
	self environment renameClass: self as: newName.
	name := newName
]

{ #category : #initialize }
Trait >> setName: aSymbol andRegisterInCategory: categorySymbol environment: aSystemDictionary [
	(self isValidTraitName: aSymbol) ifFalse: [self error:'Invalid trait name'].

	(self environment == aSystemDictionary
		and: [self name = aSymbol
			and: [self category = categorySymbol]]) ifTrue: [^self].
		
	((aSystemDictionary includesKey: aSymbol) and: [(aSystemDictionary at: aSymbol) ~~ self])
		ifTrue: [self error: 'The name ''' , aSymbol , ''' is already used'].

	(self environment notNil and: [self name notNil and: [self name ~= aSymbol]]) ifTrue: [
		self environment renameClass: self as: aSymbol].
	
	self name: aSymbol.
	self environment: aSystemDictionary.	
	[self environment at: self name put: self]
		on: AttemptToWriteReadOnlyGlobal
		do: [:n | n resume: true].
	self environment organization classify: self name under: categorySymbol.
	^ true
]

{ #category : #accessing }
Trait >> theMetaClass [
	^self classTrait
]

{ #category : #initialize }
Trait >> unload [
	"For polymorphism with classes. Do nothing"
]
