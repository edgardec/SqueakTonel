"
I add a number of facilities to those in ClassDescription:
	A set of all my subclasses (defined in ClassDescription, but only used here and below)
	A name by which I can be found in a SystemDictionary
	A classPool for class variables shared between this class and its metaclass
	A list of sharedPools which probably should be supplanted by some better mechanism.

My instances describe the representation and behavior of objects. I add more comprehensive programming support facilities to the basic attributes of Behavior and the descriptive facilities of ClassDescription.

The slot 'subclasses' is a redundant structure.  It is never used during execution, but is used by the development system to simplify or speed certain operations.  
"
Class {
	#name : #Class,
	#superclass : #ClassDescription,
	#instVars : [
		'subclasses',
		'name',
		'classPool',
		'sharedPools',
		'environment',
		'category'
	],
	#category : #'Kernel-Classes'
}

{ #category : #'fileIn\/Out' }
Class class >> fileOutPool: aString [
	"file out the global pool named aString"
	
	| internalStream |
	internalStream := WriteStream on: (String new: 1000).
	self new fileOutPool: (self environment at: aString asSymbol) onFileStream: internalStream.

	FileStream writeSourceCodeFrom: internalStream baseName: aString isSt: true useHtml: false.
]

{ #category : #inquiries }
Class class >> rootsOfTheWorld [
	"return a collection of classes which have a nil superclass"
	^Smalltalk globals rootClasses
]

{ #category : #'instance creation' }
Class class >> template: aSystemCategoryName [ 
	"Answer an expression that can be edited and evaluated in order to define a new class."

	^ self templateForSubclassOf: Object name category: aSystemCategoryName 
]

{ #category : #'instance creation' }
Class class >> templateForSubclassOf: priorClassName category: systemCategoryName [ 
	"Answer an expression that can be edited and evaluated in order to define a new class, given that the class previously looked at was as given"

	^priorClassName asString, ' subclass: #NameOfSubclass
	instanceVariableNames: ''''
	classVariableNames: ''''
	poolDictionaries: ''''
	category: ''' , systemCategoryName asString , ''''
]

{ #category : #'class variables' }
Class >> addClassVarName: aString [ 
	"Add the argument, aString, as a class variable of the receiver.
	Signal an error if the first character of aString is not capitalized,
	or if it is already a variable named in the class."
	| symbol oldState |
	oldState := self copy.
	aString first canBeGlobalVarInitial
		ifFalse: [^self error: aString, ' class variable name should be capitalized; proceed to include anyway.'].
	symbol := aString asSymbol.
	self withAllSubclasses do: 
		[:subclass | 
		(self canFindWithoutEnvironment: symbol) ifTrue: [
			(DuplicateVariableError new)
				superclass: superclass; "fake!!!"
				variable: aString;
				signal: aString, ' is already defined']].
	classPool == nil ifTrue: [classPool := Dictionary new].
	(classPool includesKey: symbol) ifFalse: 
		["Pick up any refs in Undeclared"
		classPool declare: symbol from: self environment undeclared.
		SystemChangeNotifier uniqueInstance classDefinitionChangedFrom: oldState to: self]
]

{ #category : #'instance variables' }
Class >> addInstVarName: aString [
	"Add the argument, aString, as one of the receiver's instance variables."
	^(ClassBuilder new)
		name: self name
		inEnvironment: self environment
		subclassOf: self superclass
		type: self typeOfClass
		instanceVariableNames: self instanceVariablesString, ' ', aString
		classVariableNames: self classVariablesString
		poolDictionaries: self sharedPoolsString
		category: self category

]

{ #category : #'pool variables' }
Class >> addSharedPool: aSharedPool [ 
	"Add the argument, aSharedPool, as one of the receiver's shared pools. 
	Create an error if the shared pool is already one of the pools.
	This method will work with shared pools that are plain Dictionaries or thenewer SharedPool subclasses"

	(self sharedPools includes: aSharedPool)
		ifTrue: [^self error: 'This is already in my shared pool list'].
	sharedPools == nil
		ifTrue: [sharedPools := OrderedCollection with: aSharedPool]
		ifFalse: [sharedPools add: aSharedPool]
]

{ #category : #'accessing class hierarchy' }
Class >> addSubclass: aSubclass [ 
	"Make the argument, aSubclass, be one of the subclasses of the receiver. 
	Create an error notification if the argument's superclass is not the receiver."
	
	aSubclass superclass ~~ self 
		ifTrue: [^self error: aSubclass name , ' is not my subclass'].
	subclasses == nil
		ifTrue:	[subclasses := Array with: aSubclass.
				^self].
	subclasses do:[:cl| cl == aSubclass ifTrue:[^self]]. "Already my subclass"
	subclasses := subclasses copyWith: aSubclass.
]

{ #category : #'class variables' }
Class >> allClassVarNames [
	"Answer a Set of the names of the receiver's class variables, including those defined in the superclasses of the receiver."
	| aSet |
	^ self superclass == nil
		ifTrue: 
			[self classVarNames asSet]  "This is the keys so it is a new Set."
		ifFalse: 
			[aSet := self superclass allClassVarNames.
			aSet addAll: self classVarNames.
			aSet]
]

{ #category : #'pool variables' }
Class >> allSharedPools [
	"Answer a Set of the pools the receiver shares, including those defined  
	in the superclasses of the receiver."
	| aSet | 
	^self superclass == nil
		ifTrue: [self sharedPools copy]
		ifFalse: [aSet := self superclass allSharedPools.
			aSet addAll: self sharedPools.
			aSet]
]

{ #category : #compiling }
Class >> binding [
	"Answer a binding for the receiver, sharing if possible"
	(self environment bindingOf: name ifAbsent: nil) ifNotNil:
		[:bindingOrNil|
		bindingOrNil value == self ifTrue:
			[^bindingOrNil]].
	^ClassBinding key: nil value: self
]

{ #category : #compiling }
Class >> bindingOf: varName [
	^ self bindingOf: varName environment: self environment
]

{ #category : #compiling }
Class >> bindingOf: varName environment: anEnvironment [
	"Answer the binding of some variable resolved in the scope of the receiver"
	| aSymbol binding |
	aSymbol := varName asSymbol.

	"First look in local classVar dictionary."
	binding := self classPool bindingOf: aSymbol.
	binding ifNotNil:[^binding].

	"Next look in local shared pools."
	self sharedPools do:[:pool | 
		binding := pool bindingOf: aSymbol.
		binding ifNotNil:[^binding].
	].

	"Next look into superclass pools"
	superclass ifNotNil: [^ superclass bindingOf: aSymbol environment: anEnvironment].
	
	"No more superclass... Last look in declared environment."
	^anEnvironment bindingOf: aSymbol


]

{ #category : #compiling }
Class >> canFindWithoutEnvironment: varName [
	"This method is used for analysis of system structure -- see senders."
	"Look up varName, in the context of the receiver. Return true if it can be found without using the declared environment."

	"First look in classVar dictionary."
	(self classPool bindingOf: varName) ifNotNil:[^true].

	"Next look in shared pools."
	self sharedPools do:[:pool | 
		(pool bindingOf: varName) ifNotNil:[^true].
	].

	"Finally look higher up the superclass chain and fail at the end."
	superclass == nil
		ifTrue: [^ false]
		ifFalse: [^ superclass canFindWithoutEnvironment: varName].


]

{ #category : #organization }
Class >> category [
	"Answer the system organization category for the receiver. First check whether the
	category name stored in the ivar is still correct and only if this fails look it up
	(latter is much more expensive)"

	category ifNotNil: [ :symbol |
		((self environment organization listAtCategoryNamed: symbol) includes: self name)
			ifTrue: [ ^symbol ] ].
	category := self environment organization categoryOfElement: self name.
	^category
]

{ #category : #organization }
Class >> category: aString [ 
	"Categorize the receiver under the system category, aString, removing it from 
	any previous categorization."

	| oldCategory |
	oldCategory := category.
	aString isString
		ifTrue: [
			category := aString asSymbol.
			self environment organization classify: self name under: category ]
		ifFalse: [self errorCategoryName]
]

{ #category : #accessing }
Class >> classPool [
	"Answer the dictionary of class variables."

	classPool == nil
		ifTrue: [^Dictionary new]
		ifFalse: [^classPool]
]

{ #category : #accessing }
Class >> classPool: aDictionary [
	classPool := aDictionary
]

{ #category : #accessing }
Class >> classPoolFrom: aClass [
	"share the classPool with aClass."

	classPool := aClass classPool
]

{ #category : #'class variables' }
Class >> classVarNames [
	"Answer a collection of the names of the class variables defined in the receiver."

	^self classPool keys asArray sort
]

{ #category : #compiling }
Class >> compileAllFrom: oldClass [
	"Recompile all the methods in the receiver's method dictionary (not the
	subclasses). Also recompile the methods in the metaclass."

	super compileAllFrom: oldClass.
	self class compileAllFrom: oldClass class
]

{ #category : #copying }
Class >> copy [ 
	"Answer a copy of the receiver without a list of subclasses.
	 This copy is used by the ClassBuilder when mutating classes on redefinition.
	 (SystemNavigation new browseAllCallsOn: #copy localTo: ClassBuilder)"
	| newClass |
	newClass := self class copy new
		superclass: superclass
		methodDict: self methodDict copy
		format: format
		name: name
		organization: self organization copy
		instVarNames: instanceVariables copy
		classPool: classPool copy
		sharedPools: sharedPools copy.
	Class instSize+1 to: self class instSize do:
		[:offset | newClass instVarAt: offset put: (self instVarAt: offset)].
	^ newClass
]

{ #category : #'initialize-release' }
Class >> deactivate [
	"A remnant from the 3.3a modules work, retained . Does nothing, but may be overridden in Metaclasses."
]

{ #category : #'initialize-release' }
Class >> declare: varString [ 
	"Declare class variables common to all instances. Answer whether 
	recompilation is advisable."

	| newVars conflicts |
	
	newVars := 
		(Scanner new scanFieldNames: varString)
			collect: [:x | x asSymbol].
	newVars do:
		[:var | var first canBeGlobalVarInitial
			ifFalse: [self error: var, ' class variable name should be capitalized; proceed to include anyway.']].
	conflicts := false.
	classPool == nil 
		ifFalse: [(classPool keys reject: [:x | newVars includes: x]) do: 
					[:var | self removeClassVarName: var]].
	(newVars reject: [:var | self classPool includesKey: var])
		do: [:var | "adding"
			"check if new vars defined elsewhere"
			(self canFindWithoutEnvironment: var) ifTrue: [
					(DuplicateVariableError new)
						superclass: superclass; "fake!!!"
						variable: var;
						signal: var, ' is already defined'.
					conflicts := true]].
	newVars size > 0
		ifTrue: 
			[classPool := self classPool.
			"in case it was nil"
			newVars do: [:var | classPool declare: var from: self environment undeclared]].
	^conflicts
]

{ #category : #'class variables' }
Class >> ensureClassPool [

	^classPool ifNil: [classPool := Dictionary new].
]

{ #category : #organization }
Class >> environment [

	environment == nil ifTrue: [^ super environment].
	^ environment
]

{ #category : #organization }
Class >> environment: anEnvironment [

	environment := anEnvironment
]

{ #category : #'subclass creation' }
Class >> ephemeronSubclass: t instanceVariableNames: f classVariableNames: d poolDictionaries: s category: cat [ 
	"This is the standard initialization message for creating a new class as a 
	subclass of an existing class (the receiver) in which the subclass is to 
	have ephemeron semantics, i.e. where the object will be queued for
	finalization when the key (first) inst var is not reachable other than through
	the other fields of ephemerons with unreachable keys."
	^ClassBuilder new
		superclass: self
		ephemeronSubclass: t
		instanceVariableNames: f
		classVariableNames: d
		poolDictionaries: s
		category: cat
]

{ #category : #'class name' }
Class >> externalName [
	"Answer a name by which the receiver can be known."

	^ name
]

{ #category : #'fileIn\/Out' }
Class >> fileOut [
	"Create a file whose name is the name of the receiver with '.st' as the 
	extension, and file a description of the receiver onto it."
	^ self fileOutAsHtml: false
]

{ #category : #'fileIn\/Out' }
Class >> fileOutAsHtml: useHtml [
	"File a description of the receiver onto a new file whose base name is the name of the receiver."

	| internalStream |
	internalStream := WriteStream on: (String new: 100).
	internalStream header; timeStamp.

	self sharedPools size > 0 ifTrue: [
		self shouldFileOutPools
			ifTrue: [self fileOutSharedPoolsOn: internalStream]].
	self fileOutOn: internalStream moveSource: false toFile: 0.
	internalStream trailer.

	FileStream writeSourceCodeFrom: internalStream baseName: self name isSt: true useHtml: useHtml.

]

{ #category : #'fileIn\/Out' }
Class >> fileOutInitializerOn: aStream [
	^self class fileOutInitializerOn: aStream
]

{ #category : #'fileIn\/Out' }
Class >> fileOutOn: aFileStream moveSource: moveSource toFile: fileIndex [ 
	"File a description of the receiver on aFileStream. If the boolean argument,
	moveSource, is true, then set the trailing bytes to the position of aFileStream and
	to fileIndex in order to indicate where to find the source code."
	^self fileOutOn: aFileStream moveSource: moveSource toFile: fileIndex initializing: true
]

{ #category : #'fileIn\/Out' }
Class >> fileOutOn: aFileStream moveSource: moveSource toFile: fileIndex initializing: aBool [
	"File a description of the receiver on aFileStream. If the boolean argument,
	moveSource, is true, then set the trailing bytes to the position of aFileStream and
	to fileIndex in order to indicate where to find the source code."

	Transcript cr; show: self name.
	super
		fileOutOn: aFileStream
		moveSource: moveSource
		toFile: fileIndex.
	self class nonTrivial
		ifTrue:
			[aFileStream cr; nextPutAll: '"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!'; cr; cr.
			self class
				fileOutOn: aFileStream
				moveSource: moveSource
				toFile: fileIndex
				initializing: aBool]
]

{ #category : #'fileIn\/Out' }
Class >> fileOutPool: aPool onFileStream: aFileStream [ 
	| aPoolName |
	(aPool  isKindOf: SharedPool class) ifTrue:[^self notify: 'we do not fileout SharedPool type shared pools for now'].
	aPoolName := self environment keyAtIdentityValue: aPool.
	Transcript cr; show: aPoolName.
	aFileStream nextPutAll: 'Transcript show: ''' , aPoolName , '''; cr!'; cr.
	aFileStream nextPutAll: 'Smalltalk at: #' , aPoolName , ' put: Dictionary new!'; cr.
	aPool keys asArray sort do: [ :aKey |
		| aValue |
		aValue := aPool at: aKey.
		aFileStream nextPutAll: aPoolName , ' at: #''' , aKey asString , '''', ' put:  '.
		(aValue isKindOf: Number)
			ifTrue: [aValue printOn: aFileStream]
			ifFalse: [aFileStream nextPutAll: '('.
					aValue printOn: aFileStream.
					aFileStream nextPutAll: ')'].
		aFileStream nextPutAll: '!'; cr].
	aFileStream cr
]

{ #category : #'fileIn\/Out' }
Class >> fileOutSharedPoolsOn: aFileStream [
	"file out the shared pools of this class after prompting the user about each pool"
	| poolsToFileOut |
	poolsToFileOut := self sharedPools select: 
		[:aPool | (self shouldFileOutPool: (self environment keyAtIdentityValue: aPool))].
	poolsToFileOut do: [:aPool | self fileOutPool: aPool onFileStream: aFileStream].
	
]

{ #category : #testing }
Class >> hasMethods [
	"Answer a Boolean according to whether any methods are defined for the 
	receiver (includes whether there are methods defined in the receiver's 
	metaclass)."

	^super hasMethods or: [self class hasMethods]
]

{ #category : #'subclass creation' }
Class >> immediateSubclass: t instanceVariableNames: f classVariableNames: d poolDictionaries: s category: cat [ 
	"This is the standard initialization message for creating a new
	 immediate class as a subclass of an existing class (the receiver)."
	^ClassBuilder new
		superclass: self
		immediateSubclass: t
		instanceVariableNames: f
		classVariableNames: d
		poolDictionaries: s
		category: cat
]

{ #category : #testing }
Class >> isAbstract [
	"Answer true if I am to be considered an abstract class.
	An abstract class shall better not be instantiated.
	Or its instances may miss some important behavior.
	Typically, a class with methods sending #subclassResponsibility might be considered abstract.
	But we can't erect this as a general rule, it might be that the message is never sent.
	By default, all classes are concrete, up to each one to declare itself abstract."
	
	^false
]

{ #category : #testing }
Class >> isDeprecated [
	"Check for \d\d(Deprecated).* name. Optimized for speed. Accept false-positives if category cache is not valid anymore. See #category."
	
	^ ((category ifNil: [self category]) findString: 'Deprecated' startingAt: 3 caseSensitive: true) > 0
]

{ #category : #testing }
Class >> isObsolete [
	"Return true if the receiver is obsolete."
	^(self environment at: name ifAbsent: [nil]) ~~ self
]

{ #category : #testing }
Class >> isSystemDefined [
	"Answer true if the receiver is a system-defined class, and not a UniClass (an instance-specific lightweight class)"

	^ self == self officialClass
]

{ #category : #compiling }
Class >> metaCompilerClass [
	"BE CAREFUL! If you provide your own class to treat class-side (resp. meta) methods, you MUST account for the #meta*Class selector to use the default implementation in that case. That is, the methods behind #meta*Class MUST always get the default Smalltalk treatment."
	
	^ super compilerClass
]

{ #category : #compiling }
Class >> metaDecompilerClass [
	"BE CAREFUL! If you provide your own class to treat class-side (resp. meta) methods, you MUST account for the #meta*Class selector to use the default implementation in that case. That is, the methods behind #meta*Class MUST always get the default Smalltalk treatment."

	^ super decompilerClass
]

{ #category : #compiling }
Class >> metaEvaluatorClass [
	"BE CAREFUL! If you provide your own class to treat class-side (resp. meta) methods, you MUST account for the #meta*Class selector to use the default implementation in that case. That is, the methods behind #meta*Class MUST always get the default Smalltalk treatment."

	^ super evaluatorClass
]

{ #category : #printing }
Class >> metaFormatterClass [
	"BE CAREFUL! If you provide your own class to treat class-side (resp. meta) methods, you MUST account for the #meta*Class selector to use the default implementation in that case. That is, the methods behind #meta*Class MUST always get the default Smalltalk treatment."

	^ super formatterClass
]

{ #category : #compiling }
Class >> metaParserClass [
	"BE CAREFUL! If you provide your own class to treat class-side (resp. meta) methods, you MUST account for the #meta*Class selector to use the default implementation in that case. That is, the methods behind #meta*Class MUST always get the default Smalltalk treatment."

	^ super parserClass
]

{ #category : #printing }
Class >> metaPrettyPrinterClass [
	"BE CAREFUL! If you provide your own class to treat class-side (resp. meta) methods, you MUST account for the #meta*Class selector to use the default implementation in that case. That is, the methods behind #meta*Class MUST always get the default Smalltalk treatment."

	^ super prettyPrinterClass
]

{ #category : #accessing }
Class >> name [
	"Answer the name of the receiver."

	name == nil
		ifTrue: [^super name]
		ifFalse: [^name]
]

{ #category : #'class name' }
Class >> nameForViewer [
	"Answer the name to be shown in the header of a viewer looking at the receiver"

	^ self name ifNil: ['Unnamed class']
]

{ #category : #'subclass creation' }
Class >> newEnvironment [
	
	self flag: #uniclasses.
	^ (Environment withName: 'EnvironmentForUniClass')
		at: self name asSymbol put: self;
		importSelf;
		yourself
]

{ #category : #'subclass creation' }
Class >> newSubclass [

	self flag: #uniclasses.	
	^ self newUniqueClassInstVars: '' classInstVars: ''

"Point newSubclass new"
]

{ #category : #'fileIn\/Out' }
Class >> objectForDataStream: refStrm [
	"I am about to be written on an object file.  Write a reference to a class in Smalltalk instead."

	refStrm insideASegment
		ifFalse: ["Normal use"
			^ DiskProxy global: self theNonMetaClass name selector: #withClassVersion:
				args: {self classVersion}]
		ifTrue: ["recording objects to go into an ImageSegment"
			self isSystemDefined ifFalse: [^ self].		"do trace Player classes"
			(refStrm rootObject includes: self) ifTrue: [^ self].
				"is in roots, intensionally write out, ^ self"
			
			"A normal class.  remove it from references.  Do not trace."
			refStrm references removeKey: self ifAbsent: []. 	"already there"
			^ nil]

]

{ #category : #'initialize-release' }
Class >> obsolete [
	"Change the receiver and all of its subclasses to an obsolete class."
	self == Object 
		ifTrue: [^self error: 'Object is NOT obsolete'].
	self setName: 'AnObsolete' , self name.
	Object class instSize + 1 to: self class instSize do:
		[:i | self instVarAt: i put: nil]. "Store nil over class instVars."
	self classPool: nil.
	self sharedPools: nil.
	self class obsolete.
	super obsolete.
]

{ #category : #testing }
Class >> officialClass [
	"I am not a UniClass.  (See Player officialClass).  Return the class you use to make new subclasses."

	^ self
]

{ #category : #compiling }
Class >> possibleVariablesFor: misspelled continuedFrom: oldResults [

	| results |
	results := misspelled correctAgainstDictionary: self classPool continuedFrom: oldResults.
	self sharedPools do: [:pool | 
		results := misspelled correctAgainstDictionary: pool continuedFrom: results ].
	superclass == nil
		ifTrue: 
			[ ^ misspelled correctAgainstDictionary: self environment continuedFrom: results ]
		ifFalse:
			[ ^ superclass possibleVariablesFor: misspelled continuedFrom: results ]
]

{ #category : #'fileIn\/Out' }
Class >> reformatAll [ 
	"Reformat all methods in this class.
	Leaves old code accessible to version browsing"
	super reformatAll.		"me..."
	self class reformatAll	"...and my metaclass"
]

{ #category : #'class variables' }
Class >> removeClassVarName: aString [ 
	"Remove the class variable whose name is the argument, aString, from 
	the names defined in the receiver, a class. Create an error notification if 
	aString is not a class variable or if it is still being used in the code of 
	the class."

	| aSymbol |
	aSymbol := aString asSymbol.
	(classPool includesKey: aSymbol)
		ifFalse: [^self error: aString, ' is not a class variable'].
	self withAllSubclasses do:[:subclass |
		(Array with: subclass with: subclass class) do:[:classOrMeta |
			(classOrMeta whichSelectorsReferTo: (classPool associationAt: aSymbol))
				isEmpty ifFalse: [
					InMidstOfFileinNotification signal ifTrue: [
						Transcript cr; show: self name, ' (' , aString , ' is Undeclared) '.
						^self environment undeclare: aSymbol from: classPool].
					(self confirm: (aString,' is still used in code of class ', classOrMeta name,
						'.\Is it okay to move it to Undeclared?') withCRs)
						ifTrue:[^ self environment undeclare: aSymbol from: classPool]
						ifFalse:[^self]]]].
	classPool removeKey: aSymbol.
	classPool isEmpty ifTrue: [classPool := nil].

]

{ #category : #'fileIn\/Out' }
Class >> removeFromChanges [
	"References to the receiver, a class, and its metaclass should no longer be included in the system ChangeSet.
	7/18/96 sw: call removeClassAndMetaClassChanges:"

	ChangeSet current removeClassAndMetaClassChanges: self
]

{ #category : #'initialize-release' }
Class >> removeFromSystem [
	"Forget the receiver from the Smalltalk global dictionary. Any existing 
	instances will refer to an obsolete version of the receiver."
	self removeFromSystem: true.
]

{ #category : #'initialize-release' }
Class >> removeFromSystem: logged [
	"Forget the receiver from the Smalltalk global dictionary. Any existing 
	instances will refer to an obsolete version of the receiver."
	
	"keep the class name and category for triggering the system change message. If we wait to long, then we get obsolete information which is not what we want."

	"tell class to deactivate and unload itself-- two separate events in the module system"
	self deactivate; unload.
	self superclass ifNotNil:
		["If we have no superclass there's nothing to be remembered"
		self superclass addObsoleteSubclass: self].
	self environment forgetClass: self logged: logged.
	self obsolete.
]

{ #category : #'initialize-release' }
Class >> removeFromSystemUnlogged [
	"Forget the receiver from the Smalltalk global dictionary. Any existing instances will refer to an obsolete version of the receiver.  Do not log the removal either to the current change set nor to the system changes log"
	^self removeFromSystem: false
]

{ #category : #'instance variables' }
Class >> removeInstVarName: aString [ 
	"Remove the argument, aString, as one of the receiver's instance variables."

	| newInstVarString |
	(self instVarNames includes: aString)
		ifFalse: [self error: aString , ' is not one of my instance variables'].
	newInstVarString := ''.
	(self instVarNames copyWithout: aString) do: 
		[:varName | newInstVarString := newInstVarString , ' ' , varName].
	^(ClassBuilder new)
		name: self name
		inEnvironment: self environment
		subclassOf: self superclass
		type: self typeOfClass
		instanceVariableNames: newInstVarString
		classVariableNames: self classVariablesString
		poolDictionaries: self sharedPoolsString
		category: self category
]

{ #category : #'pool variables' }
Class >> removeSharedPool: aDictionary [ 
	"Remove the pool dictionary, aDictionary, as one of the receiver's pool 
	dictionaries. Create an error notification if the dictionary is not one of 
	the pools.
	: Note that it removes the wrong one if there are two empty Dictionaries in the list."

	| satisfiedSet workingSet aSubclass |
	(self sharedPools includes: aDictionary)
		ifFalse: [^self error: 'the dictionary is not in my pool'].

	"first see if it is declared in a superclass in which case we can remove it."
	(self selectSuperclasses: [:class | class sharedPools includes: aDictionary]) isEmpty
		ifFalse: [sharedPools remove: aDictionary.
				sharedPools isEmpty ifTrue: [sharedPools := nil].
				^self]. 

	"second get all the subclasses that reference aDictionary through me rather than a 
	superclass that is one of my subclasses."

	workingSet := self subclasses asOrderedCollection.
	satisfiedSet := Set new.
	[workingSet isEmpty] whileFalse:
		[aSubclass := workingSet removeFirst.
		(aSubclass sharedPools includes: aDictionary)
			ifFalse: 
				[satisfiedSet add: aSubclass.
				workingSet addAll: aSubclass subclasses]].

	"for each of these, see if they refer to any of the variables in aDictionary because 
	if they do, we can not remove the dictionary."
	satisfiedSet add: self.
	satisfiedSet do: 
		[:sub | 
		aDictionary associationsDo: 
			[:aGlobal | 
			(sub whichSelectorsReferTo: aGlobal) isEmpty 
				ifFalse: [^self error: aGlobal key 
								, ' is still used in code of class '
								, sub name]]].
	sharedPools remove: aDictionary.
	sharedPools isEmpty ifTrue: [sharedPools := nil]
]

{ #category : #'accessing class hierarchy' }
Class >> removeSubclass: aSubclass [ 
	"If the argument, aSubclass, is one of the receiver's subclasses, remove it."

	subclasses == nil ifFalse:
		[subclasses :=  subclasses copyWithout: aSubclass.
		subclasses isEmpty ifTrue: [subclasses := nil]].

]

{ #category : #'class name' }
Class >> rename: aString [ 
	"The new name of the receiver is the argument, aString."

	| oldName newName |
	(newName := aString asSymbol) = (oldName := self name)
		ifTrue: [^ self].
	(self environment includesKey: newName)
		ifTrue: [^ self error: newName , ' already exists'].
	((self environment undeclared includesKey: newName)
		and: [(self environment undeclared unreferencedKeys includes: newName) not])
		ifTrue: [RemarkNotification signal: 'There are references to ' , aString printString , '
from Undeclared. Check them after this change.'].
	name := newName.
	self environment renameClass: self from: oldName
]

{ #category : #private }
Class >> setName: aSymbol [
	"Private - set the name of the class"
	name := aSymbol.
]

{ #category : #'pool variables' }
Class >> sharedPools [
	"Answer a Set of the pool dictionaries declared in the receiver."

	sharedPools == nil
		ifTrue: [^OrderedCollection new]
		ifFalse: [^sharedPools]
]

{ #category : #'pool variables' }
Class >> sharedPools: aCollection [
	sharedPools := aCollection
]

{ #category : #'initialize-release' }
Class >> sharing: poolString [ 
	"Set up sharedPools. Answer whether recompilation is advisable."
	| oldPools |
	oldPools := self sharedPools.
	sharedPools := OrderedCollection new.
	(Scanner new scanFieldNames: poolString) do: 
		[:poolName | 
		sharedPools add: (self environment at: poolName asSymbol ifAbsent:[
			(self confirm: 'The pool dictionary ', poolName,' does not exist.',
						'\Do you want it automatically created?' withCRs)
				ifTrue:[self environment at: poolName asSymbol put: Dictionary new]
				ifFalse:[^self error: poolName,' does not exist']])].
	sharedPools isEmpty ifTrue: [sharedPools := nil].
	oldPools do: [:pool |
				| found |
				found := self sharedPools anySatisfy: [:p | p == pool].
				found ifFalse: [^ true "A pool got deleted"]].
	^ false
]

{ #category : #'fileIn\/Out' }
Class >> shouldFileOutPool: aPoolName [
	"respond with true if the user wants to file out aPoolName"
	^self confirm: ('FileOut the sharedPool ', aPoolName, '?')
]

{ #category : #'fileIn\/Out' }
Class >> shouldFileOutPools [
	"respond with true if the user wants to file out the shared pools"
	^self confirm: 'FileOut selected sharedPools?'
]

{ #category : #private }
Class >> spaceUsed [

	"Object spaceUsed"
	^ super spaceUsed + self class spaceUsed
]

{ #category : #'fileIn\/Out' }
Class >> storeDataOn: aDataStream [
	"I don't get stored.  Use a DiskProxy"

	(aDataStream insideASegment and: [self isSystemDefined not]) ifTrue: [
		^ super storeDataOn: aDataStream].	"do trace me"
	self error: 'use a DiskProxy to store a Class'
]

{ #category : #'subclass creation' }
Class >> subclass: t instanceVariableNames: f classVariableNames: d poolDictionaries: s category: cat [ 
	"This is the standard initialization message for creating a new class as a 
	subclass of an existing class (the receiver)."
	^(ClassBuilder new)
		superclass: self
		subclass: t
		instanceVariableNames: f
		classVariableNames: d
		poolDictionaries: s
		category: cat

]

{ #category : #'subclass creation' }
Class >> subclass: t uses: aTraitCompositionOrArray instanceVariableNames: f classVariableNames: d poolDictionaries: s category: cat [ 
	| newClass copyOfOldClass |
	copyOfOldClass := self copy.
	newClass := self
		subclass: t
		instanceVariableNames: f
		classVariableNames: d
		poolDictionaries: s
		category: cat.
		
	
	newClass setTraitComposition: aTraitCompositionOrArray asTraitComposition.
	SystemChangeNotifier uniqueInstance
		classDefinitionChangedFrom: copyOfOldClass to: newClass.
	^newClass
]

{ #category : #'accessing class hierarchy' }
Class >> subclasses [
	"Answer a Set containing the receiver's subclasses."

	^subclasses == nil
		ifTrue: [#()]
		ifFalse: [subclasses copy]
]

{ #category : #'accessing class hierarchy' }
Class >> subclassesDo: aBlock [ 
	"Evaluate the argument, aBlock, for each of the receiver's immediate subclasses."
	subclasses == nil 
		ifFalse:[subclasses do: aBlock]
]

{ #category : #'accessing class hierarchy' }
Class >> subclassesDoGently: aBlock [ 
	"Evaluate the argument, aBlock, for each of the receiver's immediate subclasses."
	subclasses == nil 
		ifFalse: [subclasses do: aBlock]
]

{ #category : #'initialize-release' }
Class >> superclass: sup methodDict: md format: ft name: nm organization: org instVarNames: nilOrArray classPool: pool sharedPools: poolSet [ 
	"Answer an instance of me, a new class, using the arguments of the 
	message as the needed information.
	Must only be sent to a new instance; else we would need Object flushCache."

	superclass := sup.
	methodDict := md.
	format := ft.
	name := nm.
	instanceVariables := nilOrArray.
	classPool := pool.
	sharedPools := poolSet.
	self organization: org.
]

{ #category : #'initialize-release' }
Class >> superclass: aClass methodDictionary: mDict format: fmt [
	"Basic initialization of the receiver"
	super superclass: aClass methodDictionary: mDict format: fmt.
	subclasses := nil. "Important for moving down the subclasses field into Class"

]

{ #category : #'initialize-release' }
Class >> unload [
	"Sent when a the class is removed.  Does nothing, but may be overridden by (class-side) subclasses."

]

{ #category : #'subclass creation' }
Class >> variableByteSubclass: t instanceVariableNames: f 
	classVariableNames: d poolDictionaries: s category: cat [
	"This is the standard initialization message for creating a new class as a 
	subclass of an existing class (the receiver) in which the subclass is to 
	have indexable 8-bit byte-sized nonpointer variables."
	^ClassBuilder new
		superclass: self
		variableByteSubclass: t
		instanceVariableNames: f
		classVariableNames: d
		poolDictionaries: s
		category: cat
]

{ #category : #'subclass creation' }
Class >> variableByteSubclass: t uses: aTraitCompositionOrArray instanceVariableNames: f 
	classVariableNames: d poolDictionaries: s category: cat [
	"This is the standard initialization message for creating a new class as a 
	subclass of an existing class (the receiver) in which the subclass is to 
	have indexable 8-bit byte-sized nonpointer variables."
	
	| newClass copyOfOldClass |
	copyOfOldClass := self copy.
	newClass := self
		variableByteSubclass: t 
		instanceVariableNames: f
		classVariableNames: d
		poolDictionaries: s
		category: cat.
	
	newClass setTraitComposition: aTraitCompositionOrArray asTraitComposition.
	SystemChangeNotifier uniqueInstance
		classDefinitionChangedFrom: copyOfOldClass to: newClass.
	^newClass
]

{ #category : #'subclass creation' }
Class >> variableDoubleByteSubclass: t instanceVariableNames: f 
	classVariableNames: d poolDictionaries: s category: cat [
	"This is the standard initialization message for creating a new class as a 
	subclass of an existing class (the receiver) in which the subclass is to 
	have indexable 16-bit double byte-sized nonpointer variables."
	^ClassBuilder new
		superclass: self
		variableDoubleByteSubclass: t
		instanceVariableNames: f
		classVariableNames: d
		poolDictionaries: s
		category: cat
]

{ #category : #'subclass creation' }
Class >> variableDoubleByteSubclass: t uses: aTraitCompositionOrArray instanceVariableNames: f 
	classVariableNames: d poolDictionaries: s category: cat [
	"This is the standard initialization message for creating a new class as a 
	subclass of an existing class (the receiver) in which the subclass is to 
	have indexable 16-bit double byte-sized nonpointer variables."
	
	| newClass copyOfOldClass |
	copyOfOldClass := self copy.
	newClass := self
		variableDoubleByteSubclass: t 
		instanceVariableNames: f
		classVariableNames: d
		poolDictionaries: s
		category: cat.
	
	newClass setTraitComposition: aTraitCompositionOrArray asTraitComposition.
	SystemChangeNotifier uniqueInstance
		classDefinitionChangedFrom: copyOfOldClass to: newClass.
	^newClass
]

{ #category : #'subclass creation' }
Class >> variableDoubleWordSubclass: t instanceVariableNames: f 
	classVariableNames: d poolDictionaries: s category: cat [
	"This is the standard initialization message for creating a new class as a 
	subclass of an existing class (the receiver) in which the subclass is to 
	have indexable 64-bit word-sized nonpointer variables."
	^ClassBuilder new
		superclass: self
		variableDoubleWordSubclass: t
		instanceVariableNames: f
		classVariableNames: d
		poolDictionaries: s
		category: cat
]

{ #category : #'subclass creation' }
Class >> variableDoubleWordSubclass: t uses: aTraitCompositionOrArray instanceVariableNames: f 
	classVariableNames: d poolDictionaries: s category: cat [
	"This is the standard initialization message for creating a new class as a 
	subclass of an existing class (the receiver) in which the subclass is to 
	have indexable 64-bit word-sized nonpointer variables."
	
	| newClass copyOfOldClass |
	copyOfOldClass := self copy.
	newClass := self
		variableDoubleWordSubclass: t 
		instanceVariableNames: f
		classVariableNames: d
		poolDictionaries: s
		category: cat.
	
	newClass setTraitComposition: aTraitCompositionOrArray asTraitComposition.
	SystemChangeNotifier uniqueInstance
		classDefinitionChangedFrom: copyOfOldClass to: newClass.
	^newClass
]

{ #category : #'subclass creation' }
Class >> variableSubclass: t instanceVariableNames: f 
	classVariableNames: d poolDictionaries: s category: cat [
	"This is the standard initialization message for creating a new class as a 
	subclass of an existing class (the receiver) in which the subclass is to 
	have indexable pointer variables."
	^(ClassBuilder new)
		superclass: self
		variableSubclass: t
		instanceVariableNames: f
		classVariableNames: d
		poolDictionaries: s
		category: cat

]

{ #category : #'subclass creation' }
Class >> variableSubclass: t uses: aTraitCompositionOrArray instanceVariableNames: f 
	classVariableNames: d poolDictionaries: s category: cat [
	"This is the standard initialization message for creating a new class as a 
	subclass of an existing class (the receiver) in which the subclass is to 
	have indexable pointer variables."
	
	| newClass copyOfOldClass |
	copyOfOldClass := self copy.
	newClass := self
		variableSubclass: t 
		instanceVariableNames: f
		classVariableNames: d
		poolDictionaries: s
		category: cat.
	
	newClass setTraitComposition: aTraitCompositionOrArray asTraitComposition.
	SystemChangeNotifier uniqueInstance
		classDefinitionChangedFrom: copyOfOldClass to: newClass.
	^newClass	
]

{ #category : #'subclass creation' }
Class >> variableWordSubclass: t instanceVariableNames: f 
	classVariableNames: d poolDictionaries: s category: cat [
	"This is the standard initialization message for creating a new class as a 
	subclass of an existing class (the receiver) in which the subclass is to 
	have indexable 32-bit word-sized nonpointer variables."
	^ClassBuilder new
		superclass: self
		variableWordSubclass: t
		instanceVariableNames: f
		classVariableNames: d
		poolDictionaries: s
		category: cat
]

{ #category : #'subclass creation' }
Class >> variableWordSubclass: t uses: aTraitCompositionOrArray instanceVariableNames: f 
	classVariableNames: d poolDictionaries: s category: cat [
	"This is the standard initialization message for creating a new class as a 
	subclass of an existing class (the receiver) in which the subclass is to 
	have indexable 32-bit word-sized nonpointer variables."
	
	| newClass copyOfOldClass |
	copyOfOldClass := self copy.
	newClass := self
		variableWordSubclass: t 
		instanceVariableNames: f
		classVariableNames: d
		poolDictionaries: s
		category: cat.
	
	newClass setTraitComposition: aTraitCompositionOrArray asTraitComposition.
	SystemChangeNotifier uniqueInstance
		classDefinitionChangedFrom: copyOfOldClass to: newClass.
	^newClass	
]

{ #category : #'subclass creation' }
Class >> weakSubclass: t instanceVariableNames: f 
	classVariableNames: d poolDictionaries: s category: cat [
	"This is the standard initialization message for creating a new class as a 
	subclass of an existing class (the receiver) in which the subclass is to 
	have weak indexable pointer variables."
	^(ClassBuilder new)
		superclass: self
		weakSubclass: t
		instanceVariableNames: f
		classVariableNames: d
		poolDictionaries: s
		category: cat
]

{ #category : #'subclass creation' }
Class >> weakSubclass: t uses: aTraitCompositionOrArray instanceVariableNames: f 
	classVariableNames: d poolDictionaries: s category: cat [
	"This is the standard initialization message for creating a new class as a 
	subclass of an existing class (the receiver) in which the subclass is to 
	have weak indexable pointer variables."
	
	| newClass copyOfOldClass |
	copyOfOldClass := self copy.
	newClass := self
		weakSubclass: t 
		instanceVariableNames: f
		classVariableNames: d
		poolDictionaries: s
		category: cat.
	
	newClass setTraitComposition: aTraitCompositionOrArray asTraitComposition.
	SystemChangeNotifier uniqueInstance
		classDefinitionChangedFrom: copyOfOldClass to: newClass.
	^newClass	

]

{ #category : #testing }
Class >> whichSelectorsStoreInto: varName [ 
	"Answer a collection of selectors whose methods access the argument, varName, as a named class variable. Or let super try with a named instance variable."
	| ref |
	ref := self classPool
		associationAt: varName
		ifAbsent: [ ^ super whichSelectorsStoreInto: varName ].
	^self methodDict keys select: [:aSelector | (self methodDict at: aSelector) writesRef: ref ]
]

{ #category : #'fileIn\/Out' }
Class >> withClassVersion: aVersion [
	aVersion = self classVersion ifTrue:[^self].
	^self error: 'Invalid class version'
]
