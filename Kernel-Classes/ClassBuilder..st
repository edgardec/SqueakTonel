"
Responsible for creating a new class or changing the format of an existing class (from a class definition in a browser or a fileIn). This includes validating the definition, computing the format of instances, creating or modifying the accompanying Metaclass, setting up the class and metaclass objects themselves, registering the class as a global, recompiling methods, modifying affected subclasses, mutating existing instances to the new format, and more.

You typically only need to use or modify this class, or even know how it works, when making fundamental changes to how the Smalltalk system and language works.

Implementation notes:
ClassBuilder relies on the assumption that it can see ALL subclasses of some class. If there are any existing subclasses of some class, regardless of whether they have instances or not, regardless of whether they are considered obsolete or not, ClassBuilder MUST SEE THEM.

"
Class {
	#name : #ClassBuilder,
	#superclass : #Object,
	#instVars : [
		'environ',
		'classMap',
		'instVarMap',
		'progress',
		'maxClassIndex',
		'currentClassIndex'
	],
	#classVars : [
		'QuietMode'
	],
	#category : #'Kernel-Classes'
}

{ #category : #accessing }
ClassBuilder class >> beSilent: aBool [
	"ClassDefiner beSilent: true"
	"ClassDefiner beSilent: false"
	QuietMode := aBool.
]

{ #category : #accessing }
ClassBuilder class >> beSilentDuring: aBlock [
	"Temporarily suppress information about what is going on"
	| wasSilent result |
	wasSilent := self isSilent.
	self beSilent: true.
	result := aBlock value.
	self beSilent: wasSilent.
	^result
]

{ #category : #'cleanup obsolete classes' }
ClassBuilder class >> checkClassHierarchyConsistency [
	"Check the consistency of the class hierarchy. The class hierarchy is consistent if the following
	two logical equivalences hold for classes A and B:
	- B is obsolete and 'B superclass' yields A  <-->  'A obsoleteSubclasses' contains B
	- B is not obsolete and 'B superclass' yields A  <-->  'A subclasses' contains B"
	self informUserDuring:[:bar|
		self checkClassHierarchyConsistency: bar.
	].
]

{ #category : #'cleanup obsolete classes' }
ClassBuilder class >> checkClassHierarchyConsistency: informer [
	"Check the consistency of the class hierarchy. The class hierarchy is consistent if the following
	two logical equivalences hold for classes A and B:
	- B is obsolete and 'B superclass' yields A  <-->  'A obsoleteSubclasses' contains B
	- B is not obsolete and 'B superclass' yields A  <-->  'A subclasses' contains B"
	| classes |
	Transcript cr; show: 'Start checking the class hierarchy...'.
	Smalltalk garbageCollect.
	classes := Metaclass allInstances.
	classes keysAndValuesDo: [:index :meta |
		informer value:'Validating class hierarchy ', (index * 100 // classes size) printString,'%'.
		meta allInstances do: [:each | self checkClassHierarchyConsistencyFor: each].
		self checkClassHierarchyConsistencyFor: meta.
	].
	Transcript show: 'OK'.
]

{ #category : #'cleanup obsolete classes' }
ClassBuilder class >> checkClassHierarchyConsistencyFor: aClassDescription [
	"Check whether aClassDescription has a consistent superclass and consistent regular and obsolete
	subclasses"

	| mySuperclass |
	mySuperclass := aClassDescription superclass.
	(mySuperclass subclasses includes: aClassDescription) = aClassDescription isObsolete
			ifTrue: [self error: 'Something wrong!'].
	mySuperclass ifNil: [^ self].  "Obsolete subclasses of nil cannot be stored"
	(mySuperclass obsoleteSubclasses includes: aClassDescription) = aClassDescription isObsolete
			ifFalse: [self error: 'Something wrong!'].

	aClassDescription subclasses do: [:each |
		each isObsolete ifTrue: [self error: 'Something wrong!'].
		each superclass == aClassDescription ifFalse: [self error: 'Something wrong!']
	].
	aClassDescription obsoleteSubclasses do: [:each |
		each isObsolete ifFalse: [self error: 'Something wrong!'].
		each superclass == aClassDescription ifFalse: [self error: 'Something wrong!']
	].
]

{ #category : #'cleanup obsolete classes' }
ClassBuilder class >> cleanupAndCheckClassHierarchy [
	"Makes the class hierarchy consistent and removes obsolete classes from the SystemDictionary.
	Afterwards it checks whether the hierarchy is really consistent."
	self informUserDuring:[:bar|
		self cleanupAndCheckClassHierarchy: bar.
	].

]

{ #category : #'cleanup obsolete classes' }
ClassBuilder class >> cleanupAndCheckClassHierarchy: informer [
	"Makes the class hierarchy consistent and removes obsolete classes from the SystemDictionary.
	Afterwards it checks whether the hierarchy is really consistent."

	Transcript cr; show: '*** Before cleaning up ***'.
	self countReallyObsoleteClassesAndMetaclasses.
	self cleanupClassHierarchy: informer.
	self checkClassHierarchyConsistency: informer.
	Transcript cr; cr; show: '*** After cleaning up ***'.
	self countReallyObsoleteClassesAndMetaclasses.
]

{ #category : #'cleanup obsolete classes' }
ClassBuilder class >> cleanupClassHierarchy [
	"Makes the class hierarchy consistent and removes obsolete classes from the SystemDictionary."
	self informUserDuring:[:bar|
		self cleanupClassHierarchy: bar.
	].
]

{ #category : #'cleanup obsolete classes' }
ClassBuilder class >> cleanupClassHierarchy: informer [
	"Makes the class hierarchy consistent and removes obsolete classes from the SystemDictionary."
	| classes |
	Transcript cr; show: 'Start fixing the class hierarchy and cleaning up...'.
	Smalltalk garbageCollect.
	classes := Metaclass allInstances.
	classes keysAndValuesDo: [:index :meta |
		informer value:'Fixing  class hierarchy ', (index * 100 // classes size) printString,'%'.
		"Check classes before metaclasses (because Metaclass>>isObsolete
		checks whether the related class is obsolete)"
		meta allInstances do: [:each | self cleanupClassHierarchyFor: each].
		self cleanupClassHierarchyFor: meta.
	].
	Transcript show: 'DONE'.
]

{ #category : #'cleanup obsolete classes' }
ClassBuilder class >> cleanupClassHierarchyFor: aClassDescription [
	
	| myName mySuperclass |
	mySuperclass := aClassDescription superclass.
	(self isReallyObsolete: aClassDescription) ifTrue: [
		
		"Remove class >>>from SystemDictionary if it is obsolete"
		myName := aClassDescription name asString.
		Smalltalk globals keys do: [:each | 
			(each asString = myName and: [(Smalltalk at: each) == aClassDescription])
				ifTrue: [Smalltalk globals removeKey: each]].

		"Make class officially obsolete if it is not"
		(aClassDescription name asString beginsWith: 'AnObsolete')
			ifFalse: [aClassDescription obsolete].

		aClassDescription isObsolete 
			ifFalse: [self error: 'Something wrong!'].

		"Add class to obsoleteSubclasses of its superclass"
		mySuperclass
			ifNil: [self error: 'Obsolete subclasses of nil cannot be stored'].
		(mySuperclass obsoleteSubclasses includes: aClassDescription)
			ifFalse: [mySuperclass addObsoleteSubclass: aClassDescription].
	] ifFalse:[
		"check if superclass has aClassDescription in its obsolete subclasses"
		mySuperclass ifNil:[mySuperclass := Class]. "nil subclasses"
		mySuperclass removeObsoleteSubclass: aClassDescription.
	].
	"And remove its obsolete subclasses if not actual superclass"
	aClassDescription obsoleteSubclasses do:[:obs|
		obs superclass == aClassDescription ifFalse:[
			aClassDescription removeObsoleteSubclass: obs]].

]

{ #category : #'cleanup obsolete classes' }
ClassBuilder class >> countReallyObsoleteClassesAndMetaclasses [
	"Counting really obsolete classes and metaclasses"

	| metaSize classSize |
	Smalltalk garbageCollect.
	metaSize := self reallyObsoleteMetaclasses size.
	Transcript cr; show: 'Really obsolete metaclasses: ', metaSize printString.
	classSize := self reallyObsoleteClasses size.
	Transcript cr; show: 'Really obsolete classes: ', classSize printString; cr.
	"Metaclasses must correspond to classes!"
	metaSize ~= classSize 
		ifTrue: [self error: 'Serious metalevel inconsistency!!'].
]

{ #category : #'cleanup obsolete classes' }
ClassBuilder class >> isReallyObsolete: aClassDescription [
	"Returns whether the argument class is *really* obsolete. (Due to a bug, the method isObsolete
	isObsolete does not always return the right answer"

	^ aClassDescription isObsolete or: [(aClassDescription superclass subclasses includes: aClassDescription) not]
]

{ #category : #accessing }
ClassBuilder class >> isSilent [
	^QuietMode == true
]

{ #category : #'cleanup obsolete classes' }
ClassBuilder class >> reallyObsoleteClasses [
	| obsoleteClasses |
	obsoleteClasses := OrderedCollection new.
	Metaclass allInstances do: [:meta | meta allInstances do: [:each | 
		(self isReallyObsolete: each) ifTrue: [obsoleteClasses add: each]]].
	^ obsoleteClasses
]

{ #category : #'cleanup obsolete classes' }
ClassBuilder class >> reallyObsoleteMetaclasses [
	^ Metaclass allInstances select: [:each | self isReallyObsolete: each].
]

{ #category : #public }
ClassBuilder >> class: oldClass instanceVariableNames: instVarString [
	"This is the basic initialization message to change the definition of
	an existing Metaclass"
	oldClass isMeta ifFalse:[^self error: oldClass name, 'is not a Metaclass'].
	^self class: oldClass instanceVariableNames: instVarString unsafe: false
]

{ #category : #'class definition' }
ClassBuilder >> class: oldClass instanceVariableNames: instVarString unsafe: unsafe [
	"This is the basic initialization message to change the definition of
	an existing Metaclass"
	| instVars newClass needNew copyOfOldClass |
	environ := oldClass environment.
	instVars := Scanner new scanFieldNames: instVarString.
	unsafe ifFalse:[
		"Run validation checks so we know that we have a good chance for recompilation"
		(self validateInstvars: instVars from: oldClass forSuper: oldClass superclass) ifFalse:[^nil].
		(self validateSubclassFormat: oldClass typeOfClass from: oldClass forSuper: oldClass superclass extra: instVars size) ifFalse:[^nil]].
	"See if we need a new subclass or not"
	needNew := self needsSubclassOf: oldClass superclass type: oldClass typeOfClass instanceVariables: instVars from: oldClass.
	needNew ifNil:[^nil]. "some error"
	needNew ifFalse:[^oldClass]. "no new class needed"

	"Create the new class"
	copyOfOldClass := oldClass copy.
	newClass := self 
		newSubclassOf: oldClass superclass 
		type: oldClass typeOfClass
		instanceVariables: instVars
		from: oldClass.
		
	newClass := self recompile: false from: oldClass to: newClass mutate: false.
	self doneCompiling: newClass.
	SystemChangeNotifier uniqueInstance classDefinitionChangedFrom: copyOfOldClass to: newClass.
	^newClass
]

{ #category : #'class format' }
ClassBuilder >> computeFormat: type instSize: newInstSize forSuper: newSuper [
	"Compute the new format for making oldClass a subclass of newSuper.
	 Answer the format or nil if there is any problem."
	| instSize isVar isPointers isWeak bitsUnitSize |
	type == #compiledMethod ifTrue:
		[newInstSize > 0 ifTrue:
			[self error: 'A compiled method class cannot have named instance variables'.
			^nil].
		^CompiledMethod format].
	instSize := newInstSize + (newSuper ifNil:[0] ifNotNil:[newSuper instSize]).
	instSize > 65535 ifTrue:
		[self error: 'Class has too many instance variables (', instSize printString,')'.
		^nil].
	type == #normal ifTrue:[isVar := isWeak := false. isPointers := true].
	type == #bytes ifTrue:[isVar := true. bitsUnitSize := 1. isPointers := isWeak := false].
	type == #shorts ifTrue:[isVar := true. bitsUnitSize := 2. isPointers := isWeak := false].
	type == #words ifTrue:[isVar := true. bitsUnitSize := 4. isPointers := isWeak := false].
	type == #longs ifTrue:[isVar := true. bitsUnitSize := 8. isPointers := isWeak := false].
	type == #variable ifTrue:[isVar := isPointers := true. isWeak := false].
	type == #weak ifTrue:[isVar := isWeak := isPointers := true].
	type == #ephemeron ifTrue:[isVar := false. isWeak := isPointers := true].
	type == #immediate ifTrue:[isVar := isWeak := isPointers := false].
	(isPointers not and: [instSize > 0]) ifTrue:
		[self error: 'A non-pointer class cannot have named instance variables'.
		^nil].
	^self format: instSize variable: isVar bitsUnitSize: bitsUnitSize pointers: isPointers weak: isWeak
]

{ #category : #initialize }
ClassBuilder >> doneCompiling: aClass [
	"The receiver has finished modifying the class hierarchy.
	Do any necessary cleanup."
	aClass doneCompiling.
	Behavior flushObsoleteSubclasses.
]

{ #category : #'class format' }
ClassBuilder >> format: nInstVars variable: isVar bitsUnitSize: bitsUnitSize pointers: isPointers weak: isWeak [
	"Compute the format for the given instance specfication.
	 Above Cog Spur the class format is
		<5 bits inst spec><16 bits inst size>
	 where the 5-bit inst spec is
			0	= 0 sized objects (UndefinedObject True False et al)
			1	= non-indexable objects with inst vars (Point et al)
			2	= indexable objects with no inst vars (Array et al)
			3	= indexable objects with inst vars (Context BlockClosure AdditionalMethodState et al)
			4	= weak indexable objects with inst vars (WeakArray et al)
			5	= weak non-indexable objects with inst vars (ephemerons) (Ephemeron)
			6	= unused
			7	= immediates (SmallInteger, Character, SmallFloat64)
			8	= unused
			9	= 64-bit indexable
		10-11	= 32-bit indexable (Bitmap, WideString)
		12-15	= 16-bit indexable
		16-23	= 8-bit indexable (ByteString)
		24-31	= compiled methods (CompiledMethod)"
	| instSpec |
	instSpec := isWeak
					ifTrue:
						[isVar
							ifTrue: [4]
							ifFalse: [5]]
					ifFalse:
						[isPointers
							ifTrue:
								[isVar
									ifTrue: [nInstVars > 0 ifTrue: [3] ifFalse: [2]]
									ifFalse: [nInstVars > 0 ifTrue: [1] ifFalse: [0]]]
							ifFalse:
								[isVar
									ifTrue: [bitsUnitSize caseOf: {
											[1] -> [16].
											[2] -> [12].
											[4] -> [10].
											[8] -> [9] }]
									ifFalse: [7]]].
	^(instSpec bitShift: 16) + nInstVars
]

{ #category : #private }
ClassBuilder >> informUserDuring: aBlock [
	self class isSilent ifTrue:[^aBlock value].
	UIManager default informUserDuring:[:bar|
		progress := bar.
		aBlock value].
	progress := nil.
]

{ #category : #initialize }
ClassBuilder >> initialize [
	environ := Smalltalk.
	instVarMap := IdentityDictionary new.
]

{ #category : #public }
ClassBuilder >> moveInstVarNamed: instVarName from: srcClass to: dstClass after: prevInstVarName [
	"Move the given instVar from srcClass to dstClass"
	(srcClass instVarNames includes: instVarName)
		ifFalse:[^self error: instVarName,' is not an instance variable of ', srcClass name].
	(prevInstVarName isNil or:[dstClass instVarNames includes: prevInstVarName])
		ifFalse:[^self error: prevInstVarName, 'is not an instance variable of', dstClass name].
	(srcClass inheritsFrom: dstClass) ifTrue:[
		"Move the instvar up the hierarchy."
		(self validateClass: srcClass forMoving: instVarName upTo: dstClass)
			ifFalse:[^false].
	].
	(dstClass inheritsFrom: srcClass) ifTrue:[
		"Move the instvar down the hierarchy"
		(self validateClass: srcClass forMoving: instVarName downTo: dstClass)
			ifFalse:[^false].
	].
	^self silentlyMoveInstVarNamed: instVarName from: srcClass to: dstClass after: prevInstVarName
]

{ #category : #'class mutation' }
ClassBuilder >> mutate: oldClass to: newClass [
	"Mutate the old class and subclasses into newClass and subclasses.
	Note: This method is slightly different from: #mutate:toSuper: since
	here we are at the root of reshaping and have two distinct roots."
	self showProgressFor: oldClass.
	"Convert the subclasses"
	oldClass subclasses do:[:oldSubclass| 
		| newSubclass |
		newSubclass := self reshapeClass: oldSubclass toSuper: newClass.
		self mutate: oldSubclass to: newSubclass.
	].
	"And any obsolete ones"
	oldClass obsoleteSubclasses do:[:oldSubclass|
		oldSubclass ifNotNil:[
			| newSubclass |
			newSubclass := self reshapeClass: oldSubclass toSuper: newClass.
			self mutate: oldSubclass to: newSubclass.
		].
	].
	self update: oldClass to: newClass.
	^newClass
]

{ #category : #'class definition' }
ClassBuilder >> name: className inEnvironment: env subclassOf: newSuper type: type instanceVariableNames: instVarString classVariableNames: classVarString poolDictionaries: poolString category: category [
	"Define a new class in the given environment"
	^self 
		name: className 
		inEnvironment: env 
		subclassOf: newSuper 
		type: type 
		instanceVariableNames: instVarString 
		classVariableNames: classVarString 
		poolDictionaries: poolString 
		category: category
		unsafe: false
]

{ #category : #'class definition' }
ClassBuilder >> name: className inEnvironment: env subclassOf: newSuper type: type instanceVariableNames: instVarString classVariableNames: classVarString poolDictionaries: poolString category: category unsafe: unsafe [
	"Define a new class in the given environment.
	If unsafe is true do not run any validation checks.
	This facility is provided to implement important system changes."
	| oldClass instVars classVars copyOfOldClass newClass |
 
	environ := env.
	instVars := Scanner new scanFieldNames: instVarString.
	classVars := (Scanner new scanFieldNames: classVarString) collect: [:x | x asSymbol].

	"Validate the proposed name"
	unsafe ifFalse:[(self validateClassName: className) ifFalse:[^nil]].
	oldClass := env at: className ifAbsent:[nil].
	oldClass isBehavior 
		ifFalse: [oldClass := nil]  "Already checked in #validateClassName:"
		ifTrue: [
			copyOfOldClass := oldClass copy.
			copyOfOldClass superclass addSubclass: copyOfOldClass].
	
	
	[ | newCategory needNew force organization oldCategory |
	unsafe ifFalse:[
		"Run validation checks so we know that we have a good chance for recompilation"
		(self validateSuperclass: newSuper forSubclass: oldClass) ifFalse:[^nil].
		(self validateInstvars: instVars from: oldClass forSuper: newSuper) ifFalse:[^nil].
		(self validateClassvars: classVars from: oldClass forSuper: newSuper) ifFalse:[^nil].
		(self validateSubclassFormat: type from: oldClass forSuper: newSuper extra: instVars size) ifFalse:[^nil]].

	"See if we need a new subclass"
	needNew := self needsSubclassOf: newSuper type: type instanceVariables: instVars from: oldClass.
	needNew == nil ifTrue:[^nil]. "some error"

	(needNew and:[unsafe not]) ifTrue:[
		"Make sure we don't redefine any dangerous classes"
		(self tooDangerousClasses includes: oldClass name) ifTrue:[
			self error: oldClass name, ' cannot be changed'.
		].
		"Check if the receiver should not be redefined"
		(oldClass ~~ nil and:[oldClass shouldNotBeRedefined]) ifTrue:[
			self notify: oldClass name asText allBold, 
						' should not be redefined. \Proceed to store over it.' withCRs]].

	needNew ifTrue:[
		"Create the new class"
		newClass := self 
			newSubclassOf: newSuper 
			type: type 
			instanceVariables: instVars
			from: oldClass.
		newClass == nil ifTrue:[^nil]. "Some error"
		newClass setName: className.
		newClass environment: environ.
	] ifFalse:[
		"Reuse the old class"
		newClass := oldClass.
	].

	"Install the class variables and pool dictionaries... "
	force := (newClass declare: classVarString) | (newClass sharing: poolString).

	"... classify ..."
	category ifNotNil: [
		newCategory := category asSymbol.
		organization := environ ifNotNil:[environ organization].
		oldClass isNil ifFalse: [oldCategory := (organization categoryOfElement: oldClass name) asSymbol].
		organization classify: newClass name under: newCategory suppressIfDefault: true].

	"... recompile ..."
	newClass := self recompile: force from: oldClass to: newClass mutate: false.

	"... export if not yet done ..."
	(environ at: newClass name ifAbsent:[nil]) == newClass ifFalse:[
		[environ at: newClass name put: newClass]
			on: AttemptToWriteReadOnlyGlobal do:[:ex| ex resume: true].
		environ flushClassNameCache.
	].


	newClass doneCompiling.
	"... notify interested clients ..."
	oldClass isNil ifTrue: [
		SystemChangeNotifier uniqueInstance classAdded: newClass inCategory: newCategory.
		^ newClass].
	newCategory ~= oldCategory 
		ifTrue: [SystemChangeNotifier uniqueInstance class: newClass recategorizedFrom: oldCategory to: category]
		ifFalse: [SystemChangeNotifier uniqueInstance classDefinitionChangedFrom: copyOfOldClass to: newClass.].
] ensure: 
		[copyOfOldClass ifNotNil: [copyOfOldClass superclass removeSubclass: copyOfOldClass].
		Behavior flushObsoleteSubclasses.
		].
	^newClass
]

{ #category : #'class definition' }
ClassBuilder >> needsSubclassOf: newSuper type: type instanceVariables: instVars from: oldClass [
	"Answer whether we need a new subclass to conform to the requested changes"
	| newFormat |
	"Compute the format of the new class"
	newFormat := self computeFormat: type instSize: instVars size forSuper: newSuper.
	newFormat ifNil: [^nil].

	"Check if we really need a new subclass"
	oldClass ifNil:[^true]. "yes, it's a new class"
	newSuper == oldClass superclass ifFalse:[^true]. "yes, it's a superclass change"
	newFormat = oldClass format ifFalse:[^true]. "yes, it's a format change"
	instVars = oldClass instVarNames ifFalse:[^true]. "yes, it's an iVar change"

	^false

]

{ #category : #'class definition' }
ClassBuilder >> newSubclassOf: newSuper type: type instanceVariables: instVars from: oldClass [
	"Create a new subclass of the given superclass with the given specification."
	| newFormat newClass |
	"Compute the format of the new class"
	newFormat := self computeFormat: type instSize: instVars size forSuper: newSuper.

	newFormat ifNil: [^nil].

	(oldClass == nil or:[oldClass isMeta not]) 
		ifTrue:[newClass := self privateNewSubclassOf: newSuper from: oldClass]
		ifFalse:[newClass := oldClass shallowCopy].

	newClass 
		superclass: newSuper
		methodDictionary: (oldClass ifNil: [MethodDictionary new] ifNotNil: [oldClass methodDict copy])
		format: newFormat;
		setInstVarNames: instVars.

	oldClass ifNotNil:[
		newClass organization: oldClass organization.
		"Recompile the new class"
		oldClass hasMethods 
			ifTrue:[newClass compileAllFrom: oldClass].

		oldClass hasTraitComposition ifTrue: [
			newClass setTraitComposition: oldClass traitComposition copyTraitExpression ].
		oldClass class hasTraitComposition ifTrue: [
			newClass class setTraitComposition: oldClass class traitComposition copyTraitExpression ].
		
		self recordClass: oldClass replacedBy: newClass.
	].

	(oldClass == nil or:[oldClass isObsolete not]) 
		ifTrue:[newSuper addSubclass: newClass]
		ifFalse:[newSuper addObsoleteSubclass: newClass].

	^newClass
]

{ #category : #private }
ClassBuilder >> privateNewSubclassOf: newSuper [
	"Create a new meta and non-meta subclass of newSuper"
	"WARNING: This method does not preserve the superclass/subclass invariant!"
	| newSuperMeta newMeta |
	newSuperMeta := newSuper ifNil:[Class] ifNotNil:[newSuper class].
	newMeta := Metaclass new.
	newMeta 
		superclass: newSuperMeta 
		methodDictionary: MethodDictionary new 
		format: newSuperMeta format.
	^newMeta new

]

{ #category : #private }
ClassBuilder >> privateNewSubclassOf: newSuper from: oldClass [
	"Create a new meta and non-meta subclass of newSuper using oldClass as template"
	"WARNING: This method does not preserve the superclass/subclass invariant!"
	| newSuperMeta oldMeta newMeta |
	oldClass ifNil:[^self privateNewSubclassOf: newSuper].
	newSuperMeta := newSuper ifNil:[Class] ifNotNil:[newSuper class].
	oldMeta := oldClass class.
	newMeta := oldMeta shallowCopy.
	newMeta 
		superclass: newSuperMeta
		methodDictionary: oldMeta methodDict copy
		format: (self computeFormat: oldMeta typeOfClass 
					instSize: oldMeta instVarNames size 
					forSuper: newSuperMeta);
		setInstVarNames: oldMeta instVarNames;
		organization: oldMeta organization.
	"Recompile the meta class"
	oldMeta hasMethods 
		ifTrue:[newMeta compileAllFrom: oldMeta].
	"Record the meta class change"
	self recordClass: oldMeta replacedBy: newMeta.
	"And create a new instance"
	^newMeta adoptInstance: oldClass from: oldMeta
]

{ #category : #'class definition' }
ClassBuilder >> recompile: force from: oldClass to: newClass mutate: forceMutation [
	"Do the necessary recompilation after changine oldClass to newClass.
	If required (e.g., when oldClass ~~ newClass) mutate oldClass to newClass
	and all its subclasses. If forceMutation is true force a mutation even
	if oldClass and newClass are the same."

	oldClass == nil ifTrue:[^ newClass].

	(newClass == oldClass and:[force not and:[forceMutation not]]) ifTrue:[
		^newClass].

	currentClassIndex := 0.
	maxClassIndex := oldClass withAllSubclasses size.

	(oldClass == newClass and:[forceMutation not]) ifTrue:[
		"Recompile from newClass without mutating"
		self informUserDuring:[
			newClass isSystemDefined ifFalse:[progress := nil].
			CurrentReadOnlySourceFiles cacheDuring: [
				newClass withAllSubclassesDo:[:cl|
					self showProgressFor: cl.
					cl compileAll]]].
		^newClass].
	"Recompile and mutate oldClass to newClass"
	self informUserDuring:[
		newClass isSystemDefined ifFalse:[progress := nil].
		CurrentReadOnlySourceFiles cacheDuring: [
			self mutate: oldClass to: newClass].
	].
	^oldClass "now mutated to newClass"
]

{ #category : #private }
ClassBuilder >> recordClass: oldClass replacedBy: newClass [
	"Keep the changes up to date when we're moving instVars around"
	(instVarMap includesKey: oldClass name) ifTrue:[
		SystemChangeNotifier uniqueInstance classDefinitionChangedFrom: oldClass to: newClass.
	].
]

{ #category : #private }
ClassBuilder >> reservedNames [
	"Return a list of names that must not be used for variables"
	^#(self super thisContext #true #false #nil)
]

{ #category : #'class mutation' }
ClassBuilder >> reshapeClass: oldClass toSuper: newSuper [
	"Reshape the given class to the new super class. Recompile all the methods in the newly created class. Answer the new class."
	| instVars |
	instVars := instVarMap at: oldClass name ifAbsent: [oldClass instVarNames].

	^self newSubclassOf: newSuper 
			type: oldClass typeOfClass 
			instanceVariables: instVars 
			from: oldClass
]

{ #category : #private }
ClassBuilder >> showProgressFor: aClass [
	"Announce that we're processing aClass"
	progress == nil ifTrue:[^self].
	aClass isObsolete ifTrue:[^self].
	currentClassIndex := currentClassIndex + 1.
	(aClass hasMethods and: [aClass wantsRecompilationProgressReported]) ifTrue:
		[progress value: ('Recompiling ', aClass name,' (', currentClassIndex printString,'/', maxClassIndex printString,')')]
]

{ #category : #'class definition' }
ClassBuilder >> silentlyMoveInstVarNamed: instVarName from: srcClass to: dstClass after: prevInstVarName [
	"Move the instvar from srcClass to dstClass.
	Do not perform any checks."
	| srcVars dstVars dstIndex newClass copyOfSrcClass copyOfDstClass |
	copyOfSrcClass := srcClass copy.
	copyOfDstClass := dstClass copy.
	
	srcVars := srcClass instVarNames copyWithout: instVarName.
	srcClass == dstClass
		ifTrue:[dstVars := srcVars]
		ifFalse:[dstVars := dstClass instVarNames].
	dstIndex := dstVars indexOf: prevInstVarName.
	dstVars := (dstVars copyFrom: 1 to: dstIndex),
				(Array with: instVarName),
				(dstVars copyFrom: dstIndex+1 to: dstVars size).
	instVarMap at: srcClass name put: srcVars.
	instVarMap at: dstClass name put: dstVars.
	(srcClass inheritsFrom: dstClass) ifTrue:[
		newClass := self reshapeClass: dstClass toSuper: dstClass superclass.
		self recompile: false from: dstClass to: newClass mutate: true.
	] ifFalse:[
		(dstClass inheritsFrom: srcClass) ifTrue:[
			newClass := self reshapeClass: srcClass toSuper: srcClass superclass.
			self recompile: false from: srcClass to: newClass mutate: true.
		] ifFalse:[ "Disjunct hierarchies"
			srcClass == dstClass ifFalse:[
				newClass := self reshapeClass: dstClass toSuper: dstClass superclass.
				self recompile: false from: dstClass to: newClass mutate: true.
			].
			newClass := self reshapeClass: srcClass toSuper: srcClass superclass.
			self recompile: false from: srcClass to: newClass mutate: true.
		].
	].
	self doneCompiling: srcClass.
	self doneCompiling: dstClass.
	SystemChangeNotifier uniqueInstance classDefinitionChangedFrom: copyOfSrcClass to: srcClass.
	SystemChangeNotifier uniqueInstance classDefinitionChangedFrom: copyOfDstClass to: dstClass.
]

{ #category : #public }
ClassBuilder >> superclass: aClass
	ephemeronSubclass: t instanceVariableNames: f 
	classVariableNames: d poolDictionaries: s category: cat [
	"This is the standard initialization message for creating a new class as a 
	subclass of an existing class (the receiver) in which the subclass is to 
	have ephemeron semantics, i.e. where the object will be queued for
	finalization when the key (first) inst var is not reachable other than through
	the other fields of ephemerons with unreachable keys."
	| env |
	aClass isPointers ifFalse:
		[^self error: 'cannot make a pointer subclass of a class with non-pointer fields'].
	aClass instSize + f substrings size < 2 ifTrue:
		[^self error: 'cannot make an ephemeron class with less than two named instance variables'].
	env := CurrentEnvironment signal ifNil: [aClass environment].
	^self 
		name: t
		inEnvironment: env
		subclassOf: aClass
		type: #ephemeron
		instanceVariableNames: f
		classVariableNames: d
		poolDictionaries: s
		category: cat
]

{ #category : #public }
ClassBuilder >> superclass: aClass
	immediateSubclass: t instanceVariableNames: f 
	classVariableNames: d poolDictionaries: s category: cat [
	"This is the standard initialization message for creating a
	 new immediate class as a subclass of an existing class."
	| env |
	aClass instSize > 0
		ifTrue: [^self error: 'cannot make an immediate subclass of a class with named fields'].
	aClass isVariable
		ifTrue: [^self error: 'cannot make an immediate subclass of a class with indexed instance variables'].
	aClass isPointers
		ifFalse: [^self error: 'cannot make an immediate subclass of a class without pointer fields'].
	"Cope with pre-environment and environment versions. Simplify asap."
	env := (Smalltalk classNamed: #EnvironmentRequest)
				ifNil: [aClass environment]
				ifNotNil: [:erc| erc signal ifNil: [aClass environment]].
	^self 
		name: t
		inEnvironment: env
		subclassOf: aClass
		type: #immediate
		instanceVariableNames: f
		classVariableNames: d
		poolDictionaries: s
		category: cat
]

{ #category : #public }
ClassBuilder >> superclass: newSuper
	subclass: t instanceVariableNames: f 
	classVariableNames: d poolDictionaries: s category: cat [ 
	"This is the standard initialization message for creating a new class as a 
	subclass of an existing class."
	| env |
	env := CurrentEnvironment signal ifNil: [newSuper environment].
	^self 
		name: t
		inEnvironment: env
		subclassOf: newSuper
		type: newSuper typeOfClass
		instanceVariableNames: f
		classVariableNames: d
		poolDictionaries: s
		category: cat
]

{ #category : #public }
ClassBuilder >> superclass: aClass
	variableByteSubclass: n instanceVariableNames: f
	classVariableNames: d poolDictionaries: s category: cat [
	"This is the standard initialization message for creating a new class as a subclass of an
	 existing class in which the subclass is to have indexable 8-bit byte-sized nonpointer variables."
	| existingOrSuperclass actualType env |
	aClass instSize > 0 ifTrue:
		[^self error: 'cannot make a byte subclass of a class with named fields'].
	(aClass isVariable and: [aClass isBytes not]) ifTrue:
		[^self error: 'cannot make an 8-bit byte subclass of a class with 16, 32 or 64 bit fields'].
	(aClass isVariable and: [aClass isPointers]) ifTrue:
		[^self error: 'cannot make a byte subclass of a class with pointer fields'].
	existingOrSuperclass := aClass environment at: n ifAbsent: [aClass].
	actualType := existingOrSuperclass typeOfClass == #compiledMethod
						ifTrue: [#compiledMethod]
						ifFalse: [#bytes].
	env := CurrentEnvironment signal ifNil: [aClass environment].
	^self 
		name: n
		inEnvironment: env
		subclassOf: aClass
		type: actualType
		instanceVariableNames: f
		classVariableNames: d
		poolDictionaries: s
		category: cat
]

{ #category : #public }
ClassBuilder >> superclass: aClass
	variableDoubleByteSubclass: t instanceVariableNames: f
	classVariableNames: d poolDictionaries: s category: cat [
	"This is the standard initialization message for creating a new class as a subclass of an
	 existing class in which the subclass is to have indexable 16-bit-sized nonpointer variables."
	| oldClassOrNil env |
	aClass instSize > 0
		ifTrue: [^self error: 'cannot make a byte subclass of a class with named fields'].
	(aClass isVariable and: [aClass isShorts not])
		ifTrue: [^self error: 'cannot make a 16-bit short subclass of a class with 8, 32 or 64 bit fields'].
	(aClass isVariable and: [aClass isPointers])
		ifTrue: [^self error: 'cannot make a byte subclass of a class with pointer fields'].
	oldClassOrNil := aClass environment at: t ifAbsent:[nil].
	env := CurrentEnvironment signal ifNil: [aClass environment].
	^self 
		name: t
		inEnvironment: env
		subclassOf: aClass
		type: #shorts
		instanceVariableNames: f
		classVariableNames: d
		poolDictionaries: s
		category: cat
]

{ #category : #public }
ClassBuilder >> superclass: aClass
	variableDoubleWordSubclass: t instanceVariableNames: f
	classVariableNames: d poolDictionaries: s category: cat [
	"This is the standard initialization message for creating a new class as a subclass of an
	 existing class in which the subclass is to have indexable 16-bit-sized nonpointer variables."
	| oldClassOrNil env |
	aClass instSize > 0
		ifTrue: [^self error: 'cannot make a byte subclass of a class with named fields'].
	(aClass isVariable and: [aClass isLongs not])
		ifTrue: [^self error: 'cannot make a 64-bit long subclass of a class with 8, 16 or 32 bit fields'].
	(aClass isVariable and: [aClass isPointers])
		ifTrue: [^self error: 'cannot make a byte subclass of a class with pointer fields'].
	oldClassOrNil := aClass environment at: t ifAbsent:[nil].
	env := CurrentEnvironment signal ifNil: [aClass environment].
	^self 
		name: t
		inEnvironment: env
		subclassOf: aClass
		type: #longs
		instanceVariableNames: f
		classVariableNames: d
		poolDictionaries: s
		category: cat
]

{ #category : #public }
ClassBuilder >> superclass: aClass
	variableSubclass: t instanceVariableNames: f 
	classVariableNames: d poolDictionaries: s category: cat [
	"This is the standard initialization message for creating a new class as a 
	subclass of an existing class in which the subclass is to 
	have indexable pointer variables."
	
	| env |
	aClass isBits ifTrue: 
		[^self error: 'cannot make a pointer subclass of a class with non-pointer fields'].
	env := CurrentEnvironment signal ifNil: [aClass environment].
	^self 
		name: t
		inEnvironment: env
		subclassOf: aClass
		type: #variable
		instanceVariableNames: f
		classVariableNames: d
		poolDictionaries: s
		category: cat
]

{ #category : #public }
ClassBuilder >> superclass: aClass
	variableWordSubclass: t instanceVariableNames: f 
	classVariableNames: d poolDictionaries: s category: cat [
	"This is the standard initialization message for creating a new class as a subclass of an
	 existing class in which the subclass is to have indexable 32-bit word-sized nonpointer variables."
	| env |
	aClass instSize > 0
		ifTrue: [^self error: 'cannot make a word subclass of a class with named fields'].
	(aClass isVariable and: [aClass isWords not])
		ifTrue: [^self error: 'cannot make a 32-bit word subclass of a class with 8, 16 or 64 bit fields'].
	(aClass isVariable and: [aClass isPointers])
		ifTrue: [^self error: 'cannot make a word subclass of a class with pointer fields'].
	env := CurrentEnvironment signal ifNil: [aClass environment].
	^self 
		name: t
		inEnvironment: env
		subclassOf: aClass
		type: #words
		instanceVariableNames: f
		classVariableNames: d
		poolDictionaries: s
		category: cat
]

{ #category : #public }
ClassBuilder >> superclass: aClass
	weakSubclass: t instanceVariableNames: f 
	classVariableNames: d poolDictionaries: s category: cat [
	"This is the standard initialization message for creating a new class as a 
	subclass of an existing class (the receiver) in which the subclass is to 
	have weak indexable pointer variables."
	| env |
	aClass isBits 
		ifTrue: [^self error: 'cannot make a pointer subclass of a class with non-pointer fields'].
	env := CurrentEnvironment signal ifNil: [aClass environment].
	^self 
		name: t
		inEnvironment: env
		subclassOf: aClass
		type: #weak
		instanceVariableNames: f
		classVariableNames: d
		poolDictionaries: s
		category: cat
]

{ #category : #private }
ClassBuilder >> tooDangerousClasses [
	"Return a list of class names which will not be modified in the public interface"
	^#(
		"Object will break immediately"
		ProtoObject Object
		"Contexts and their superclasses"
		InstructionStream Context BlockClosure
		"Superclasses of basic collections"
		Collection SequenceableCollection ArrayedCollection
		"Collections known to the VM"
		Array Bitmap String Symbol ByteArray CompiledCode CompiledMethod CompiledBlock
		"Basic Numbers & Magnitudes"
		Magnitude Number SmallInteger Float BoxedFloat64 SmallFloat64 Character
		"Misc other"
		LookupKey Association Link Point Rectangle Behavior PositionableStream UndefinedObject
	)

]

{ #category : #'class mutation' }
ClassBuilder >> update: oldClass to: newClass [
	"Convert oldClass, all its instances and possibly its meta class into newClass,
	 instances of newClass and possibly its meta class. The process is surprisingly
	 simple in its implementation and surprisingly complex in its nuances and potentially
	 bad side effects.
	 We can rely on two assumptions (which are critical):
		#1: The method #updateInstancesFrom: will not create any lasting pointers to
			 'old' instances ('old' is quote on quote since #updateInstancesFrom: will do
			 a become of the old vs. the new instances and therefore it will not create
			 pointers to *new* instances before the #become: which are *old* afterwards)
		#2: The non-preemptive execution of the critical piece of code guarantees that
			 nobody can get a hold by 'other means' (such as process interruption and
			 reflection) on the old instances.
	 Given the above two, we know that after #updateInstancesFrom: there are no pointers
	 to any old instances. After the forwarding become there will be no pointers to the old
	 class or meta class either.
	 Andreas Raab, 2/27/2003 23:42"
	| meta |
	meta := oldClass isMeta.
	"Note: Everything from here on will run without the ability to get interrupted
	to prevent any other process to create new instances of the old class."
	["Note: The following removal may look somewhat obscure and needs an explanation.
	  When we mutate the class hierarchy we create new classes for any existing subclass.
	  So it may look as if we don't have to remove the old class from its superclass. However,
	  at the top of the hierarchy (the first class we reshape) that superclass itself is not newly
	  created so therefore it will hold both the oldClass and newClass in its (obsolete or not)
	  subclasses. Since the #become: below will transparently replace the pointers to oldClass
	  with newClass the superclass would have newClass in its subclasses TWICE. With rather
	  unclear effects if we consider that we may convert the meta-class hierarchy itself (which
	  is derived from the non-meta class hierarchy).
	  Due to this problem ALL classes are removed from their superclass just prior to converting
	  them. Here, breaking the superclass/subclass invariant really doesn't matter since we will
	  effectively remove the oldClass (becomeForward:) just a few lines below."

		oldClass superclass removeSubclass: oldClass.
		oldClass superclass removeObsoleteSubclass: oldClass.

		"make sure that the VM cache is clean"
		oldClass methodDict do: [:cm | cm flushCache].
		
		"Convert the instances of oldClass into instances of newClass"
		newClass updateInstancesFrom: oldClass.

		meta
			ifTrue:
				[{oldClass} elementsForwardIdentityAndHashTo: {newClass}.
				 oldClass updateMethodBindingsTo: oldClass binding]
			ifFalse:
				[{oldClass. oldClass class} elementsForwardIdentityAndHashTo: {newClass. newClass class}.
				 oldClass updateMethodBindingsTo: oldClass binding.
				 oldClass class updateMethodBindingsTo: oldClass class binding].

		"eem 5/31/2014 07:22 At this point there used to be a garbage collect whose purpose was
		 to ensure no old instances existed after the becomeForward:.  Without the GC it was possible
		 to resurrect old instances using e.g. allInstancesDo:.  This was because the becomeForward:
		 updated references from the old objects to new objects but didn't destroy the old objects.
		 But as of late 2013/early 2014 becomeForward: has been modified to free all the old objects."]
			valueUnpreemptively
]

{ #category : #validation }
ClassBuilder >> validateClass: srcClass forMoving: iv downTo: dstClass [
	"Make sure that we don't have any accesses to the instVar left"
	srcClass withAllSubclassesDo:[:cls|
		(cls == dstClass or:[cls inheritsFrom: dstClass]) ifFalse:[
			(cls whichSelectorsAccess: iv) isEmpty ifFalse:[
				self notify: (iv printString asText allBold), ' is still used in ', cls name asText allBold,'.
Proceed to move it to Undeclared'.
			].
		].
	].
	^true
]

{ #category : #validation }
ClassBuilder >> validateClass: srcClass forMoving: iv upTo: dstClass [
	"Make sure we don't have this instvar already"
	dstClass withAllSubclassesDo:[:cls|
		(cls == srcClass or:[cls inheritsFrom: srcClass]) ifFalse:[
			cls isPointers ifFalse:[
				self error: dstClass name, ' cannot have instance variables'.
				^false].
			cls instSize >= 254 ifTrue:[
				self error: cls name, ' has more than 254 instance variables'.
				^false].
			(cls instVarNames includes: iv) ifTrue:[
				self notify: (iv printString asText allBold),' is defined in ', cls name asText allBold,'
Proceed to move it up to ', dstClass name asText allBold,' as well'.
				instVarMap at: cls name put: (cls instVarNames copyWithout: iv)].
		].
	].
	^true
]

{ #category : #validation }
ClassBuilder >> validateClassName: aString [
	"Validate the new class name"
	aString first canBeGlobalVarInitial ifFalse:[
		self error: 'Class names must be capitalized'.
		^false].
	environ at: aString ifPresent:[:old|
		(old isKindOf: Behavior) ifFalse:[
			self notify: aString asText allBold, 
						' already exists!\Proceed will store over it.' withCRs]].
	^true
]

{ #category : #validation }
ClassBuilder >> validateClassvars: classVarArray from: oldClass forSuper: newSuper [
	"Check if any of the classVars of oldClass conflict with the new superclass"
	| usedNames classVars temp |
	classVarArray isEmpty ifTrue:[^true]. "Okay"

	"Validate the class var names"
	usedNames := classVarArray asSet.
	usedNames size = classVarArray size 
		ifFalse:[	classVarArray do:[:var|
					usedNames remove: var ifAbsent:[temp := var]].
				self error: temp,' is multiply defined'. ^false].
	(usedNames includesAnyOf: self reservedNames) 
		ifTrue:[	self reservedNames do:[:var|
					(usedNames includes: var) ifTrue:[temp := var]].
				self error: temp,' is a reserved name'. ^false].

	newSuper == nil ifFalse:[
		usedNames := newSuper allClassVarNames asSet.
		classVarArray do:[:iv|
			(usedNames includes: iv) ifTrue:[
				newSuper withAllSuperclassesDo:[:cl|
					(cl classVarNames includes: iv) ifTrue:[temp := cl]].
				(DuplicateVariableError new)
					superclass: temp;
					variable: iv;
					signal: iv,' is already defined in ', temp name]]].

	oldClass == nil ifFalse:[
		usedNames := Set new: 20.
		oldClass allSubclassesDo:[:cl| usedNames addAll: cl classVarNames].
		classVars := classVarArray.
		newSuper == nil ifFalse:[classVars := classVars, newSuper allClassVarNames asArray].
		classVars do:[:iv|
			(usedNames includes: iv) ifTrue:[
				(DuplicateVariableError new)
					superclass: oldClass;
					variable: iv;
					signal: iv, ' is already defined in a subclass of ', oldClass name]]].
	^true
]

{ #category : #validation }
ClassBuilder >> validateInstvars: instVarArray from: oldClass forSuper: newSuper [ 
	"Check if any of the instVars of oldClass conflict with the new superclass"
	| usedNames |
	usedNames := instVarArray asSet.
	oldClass ifNotNil: [ oldClass withAllSubclassesDo: [ : each | each == oldClass ifFalse: [usedNames addAll: each instVarNames] ] ].
	"Anything to possibly conflict?"
	usedNames isEmpty ifTrue: [ ^ true ].
	newSuper allowsSubInstVars ifFalse:
		[ self error: newSuper printString , ' does not allow subclass inst vars. See allowsSubInstVars.'.
		^ false ].
	instVarArray asSet size = instVarArray size ifFalse:
		[ self error: instVarArray asBag sortedCounts first value, ' is multply defined.'.
		^ false ].
	(usedNames intersection: self reservedNames) ifNotEmpty:
		[ : reservedWords | self error: reservedWords anyOne , ' is a reserved name'.
		^ false ].
	newSuper ifNotNil:
		[ | offendingVars |
		"If any variable names in subclasses conflict names in the new superclass, report the offending class and instVar name."
		newSuper withAllSuperclasses
			detect: [ : each | (offendingVars := each instVarNames intersection: usedNames) notEmpty ]
			ifFound:
				[ : offendingSuperclass | 
				DuplicateVariableError new
					 superclass: offendingSuperclass ;
					 variable: offendingVars anyOne ;
					 signal: offendingVars anyOne , ' is already defined in ' , offendingSuperclass name ]
			ifNone: [ "no name conflicts" ] ].
	^ true
]

{ #category : #validation }
ClassBuilder >> validateSubclass: subclass canKeepLayoutFrom: oldClass forSubclassFormat: newType [ 
	"Returns whether the immediate subclasses of oldClass can keep its layout"
	"Note: Squeak does not appear to model classFormat relationships.. so I'm putting some logic here. bkv 4/2/2003"
	
	"Only run this test for a real subclass - otherwise this prevents changing
	a class from #subclass: to #variableSubclass: etc."
	subclass = oldClass ifTrue:[^true].

	 "isWeak implies isVariant"					
	 (oldClass isVariable and: [ subclass isWeak ])
		ifFalse: [ "In general we discourage format mis-matches"
				  (subclass typeOfClass == newType) 
				   	ifFalse: [ self error: subclass name,' cannot be recompiled'.
							  ^ false ]].
	^ true
]

{ #category : #validation }
ClassBuilder >> validateSubclassFormat: newType from: oldClass forSuper: newSuper extra: newInstSize [
	"Validate the # of instVars and the format of the subclasses"
	| deltaSize |
	oldClass == nil ifTrue: [^ true]. "No subclasses"
	"Compute the # of instvars needed for all subclasses"
	deltaSize := newInstSize.
	(oldClass notNil)
		ifTrue: [deltaSize := deltaSize - oldClass instVarNames size].
	(newSuper notNil)
		ifTrue: [deltaSize := deltaSize + newSuper instSize].
	(oldClass notNil and: [oldClass superclass notNil]) 
		ifTrue: [deltaSize := deltaSize - oldClass superclass instSize].
	(oldClass == nil)
		 ifTrue: [ (deltaSize > 254)
					ifTrue: [ self error: 'More than 254 instance variables'.
							^ false].
				  ^ true].

	oldClass withAllSubclassesDo: [:sub |  ( sub instSize + deltaSize > 254 )
											ifTrue: [ self error: sub name,' has more than 254 instance variables'.
					 								^ false].

										"If we get this far, check whether the immediate subclasses of oldClass can keep its layout."
               							(newType ~~ #normal) 
											ifTrue: [ self validateSubclass: sub canKeepLayoutFrom: oldClass forSubclassFormat: newType ]].

	^ true
]

{ #category : #validation }
ClassBuilder >> validateSuperclass: aSuperClass forSubclass: aClass [
	"Check if it is okay to use aSuperClass as the superclass of aClass"
	aClass == nil ifTrue:["New class"
		(aSuperClass == nil or:[aSuperClass isBehavior and:[aSuperClass isMeta not]])
			ifFalse:[self error: aSuperClass name,' is not a valid superclass'.
					^false].
		^true].
	aSuperClass == aClass superclass ifTrue:[^true]. "No change"
	(aClass isMeta) "Not permitted - meta class hierarchy is derived from class hierarchy"
		ifTrue:[^self error: aClass name, ' must inherit from ', aClass superclass name].
	"Check for circular references"
	(aSuperClass ~~ nil and:[aSuperClass == aClass or:[aSuperClass inheritsFrom: aClass]])
		ifTrue:[self error: aSuperClass name,' inherits from ', aClass name.
				^false].
	^true
]
