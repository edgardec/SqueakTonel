"
My instances add instance-specific behavior to various class-describing objects in the system. This typically includes messages for initializing class variables and instance creation messages particular to a class. There is only one instance of a particular Metaclass, namely the class which is being described. A Metaclass shares the class variables of its instance.
	
[Subtle] In general, the superclass hierarchy for metaclasses parallels that for classes. Thus,
	Integer superclass == Number, and
	Integer class superclass == Number class.
However there is a singularity at Object. Here the class hierarchy terminates, but the metaclass hierarchy must wrap around to Class, since ALL metaclasses are subclasses of Class. Thus,
	Object superclass == nil, and
	Object class superclass == Class.

[Subtle detail] A class is know by name to an environment.  Typically this is the SystemDictionary named Smalltalk.  If we ever make lightweight classes that are not in Smalltalk, they must be in some environment.  Specifically, the code that sets 'wasPresent' in name:inEnvironment:subclassOf:instanceVariableNames:variable:words:pointers:classVariableNames:poolDictionaries:category:comment:changed: must continue to work.
"
Class {
	#name : #Metaclass,
	#superclass : #ClassDescription,
	#instVars : [
		'thisClass'
	],
	#category : #'Kernel-Classes'
}

{ #category : #'anti-corruption' }
Metaclass class >> isScarySelector: newbieSelector [

	"Return true if newbieSelector is already a part of Metaclass protocol."
	(Metaclass includesSelector: newbieSelector) ifTrue: [^ true].
	(ClassDescription includesSelector: newbieSelector) ifTrue: [^ true].
	(Behavior includesSelector: newbieSelector) ifTrue: [^ true].
	^ false

]

{ #category : #compiling }
Metaclass >> acceptsLoggingOfCompilation [
	"Answer whether the receiver's method submisions and class defintions should be logged to the changes file and to the current change set.  The metaclass follows the rule of the class itself.  6/18/96 sw"

	^ thisClass acceptsLoggingOfCompilation
]

{ #category : #'instance variables' }
Metaclass >> addInstVarName: aString [ 
	"Add the argument, aString, as one of the receiver's instance variables."

	| fullString |
	fullString := String streamContents: [:strm |
		self instVarNames do: [:aString2 | strm nextPutAll: aString2; space].
		strm nextPutAll: aString].
	self instanceVariableNames: fullString
]

{ #category : #'class hierarchy' }
Metaclass >> addObsoleteSubclass: aClass [
	"Do nothing."
]

{ #category : #'class hierarchy' }
Metaclass >> addSubclass: aClass [
	"Do nothing."
]

{ #category : #'initialize-release' }
Metaclass >> adoptInstance: oldInstance from: oldMetaClass [ 
	"Recreate any existing instances of the argument, oldClass, as instances of 
	the receiver, which is a newly changed class. Permute variables as 
	necessary."
	thisClass class == self ifTrue:[^self error:'Metaclasses have only one instance'].
	oldMetaClass isMeta ifFalse:[^self error:'Argument must be Metaclass'].
	oldInstance class == oldMetaClass ifFalse:[^self error:'Not the class of argument'].
	^thisClass := self 
		newInstanceFrom: oldInstance 
		variable: self isVariable 
		size: self instSize 
		map: (self instVarMappingFrom: oldMetaClass)
]

{ #category : #enumerating }
Metaclass >> allInstancesDo: aBlock [
	"There should be only one"
	thisClass class == self ifTrue:[^aBlock value: thisClass].
	^super allInstancesDo: aBlock
]

{ #category : #compiling }
Metaclass >> bindingOf: varName [

	^thisClass classBindingOf: varName
]

{ #category : #compiling }
Metaclass >> bindingOf: varName environment: anEnvironment [ 
	^ thisClass classBindingOf: varName environment: anEnvironment
]

{ #category : #testing }
Metaclass >> canZapMethodDictionary [
	"Return true if it is safe to zap the method dictionary on #obsolete"
	thisClass == nil
		ifTrue:[^true]
		ifFalse:[^thisClass canZapMethodDictionary]
]

{ #category : #organization }
Metaclass >> category [
	^ thisClass category
]

{ #category : #'pool variables' }
Metaclass >> classPool [
	"Answer the dictionary of class variables."

	^thisClass classPool
]

{ #category : #compiling }
Metaclass >> compilerClass [
	
	^ self theNonMetaClass metaCompilerClass
]

{ #category : #compiling }
Metaclass >> decompilerClass [
	
	^ self theNonMetaClass metaDecompilerClass
]

{ #category : #'fileIn\/Out' }
Metaclass >> definition [
	"Refer to the comment in ClassDescription|definition."

	^ String streamContents:[:strm |
		strm print: self.
		self traitComposition isEmpty ifFalse:[
			strm crtab; nextPutAll: 'uses: '; nextPutAll: self traitComposition asString.
		].
		strm
			crtab;
			nextPutAll: 'instanceVariableNames: ';
			store: self instanceVariablesString]
]

{ #category : #accessing }
Metaclass >> environment [
	^thisClass environment
]

{ #category : #compiling }
Metaclass >> evaluatorClass [
	
	^ self theNonMetaClass metaEvaluatorClass
]

{ #category : #'fileIn\/Out' }
Metaclass >> fileOutInitializerOn: aStream [
	(self methodDict includesKey: #initialize) ifTrue: 
		[aStream cr.
		aStream nextChunkPut: thisClass name , ' initialize'].
]

{ #category : #'fileIn\/Out' }
Metaclass >> fileOutOn: aFileStream moveSource: moveSource toFile: fileIndex [
	^self fileOutOn: aFileStream moveSource: moveSource toFile: fileIndex initializing: true
]

{ #category : #'fileIn\/Out' }
Metaclass >> fileOutOn: aFileStream moveSource: moveSource toFile: fileIndex initializing: aBool [
	super fileOutOn: aFileStream moveSource: moveSource toFile: fileIndex.
	(aBool
	 and: [moveSource == false
	 and: [self methodDict includesKey: #initialize]]) ifTrue: 
		[aFileStream cr; cr; nextChunkPut: thisClass name , ' initialize'; cr]
]

{ #category : #printing }
Metaclass >> formatterClass [
	
	^ self theNonMetaClass metaFormatterClass
]

{ #category : #'instance creation' }
Metaclass >> initializedInstance [
	thisClass class == self ifFalse: [^self new].
	^thisClass
]

{ #category : #'initialize-release' }
Metaclass >> instanceVariableNames: instVarString [ 
	"Declare additional named variables for my instance."
	^(ClassBuilder new)
		class: self
		instanceVariableNames: instVarString
]

{ #category : #testing }
Metaclass >> isMeta [
	^ true
]

{ #category : #testing }
Metaclass >> isObsolete [
	"Return true if the receiver is obsolete"
	^thisClass == nil "Either no thisClass"
		or:[thisClass class ~~ self "or I am not the class of thisClass"
			or:[thisClass isObsolete]] "or my instance is obsolete"
]

{ #category : #accessing }
Metaclass >> isSystemDefined [
	"Answer false if I am a UniClass (an instance-specific lightweight class)"

	^ true
]

{ #category : #accessing }
Metaclass >> name [
	"Answer a String that is the name of the receiver, either 'Metaclass' or 
	the name of the receiver's class followed by ' class'."

	thisClass == nil
		ifTrue: [^'a Metaclass']
		ifFalse: [^thisClass name , ' class']
]

{ #category : #'instance creation' }
Metaclass >> new [
	"The receiver can only have one instance. Create it or complain that
	one already exists."

	thisClass class ~~ self
		ifTrue: [^thisClass := self basicNew]
		ifFalse: [self error: 'A Metaclass should only have one instance!']
]

{ #category : #'fileIn\/Out' }
Metaclass >> nonTrivial [ 
	"Answer whether the receiver has any methods or instance variables."

	^ self instVarNames size > 0 or: [self methodDict size > 0 or: [self hasTraitComposition]]
]

{ #category : #'fileIn\/Out' }
Metaclass >> objectForDataStream: refStrm [
	| dp |
	"I am about to be written on an object file.  Write a reference to a class in Smalltalk instead."

	(refStrm insideASegment and: [self isSystemDefined not]) ifTrue: [
		^ self].	"do trace me"
	dp := DiskProxy global: self theNonMetaClass name selector: #class
			args: (Array new).
	refStrm replace: self with: dp.
	^ dp

]

{ #category : #'class hierarchy' }
Metaclass >> obsoleteSubclasses [
	"Answer the receiver's subclasses."
	thisClass == nil ifTrue:[^#()].
	^thisClass obsoleteSubclasses 
		select:[:aSubclass| aSubclass isMeta not] 
		thenCollect:[:aSubclass| aSubclass class]

	"Metaclass allInstancesDo:
		[:m | Compiler evaluate: 'subclasses:=nil' for: m logged: false]"
]

{ #category : #compiling }
Metaclass >> parserClass [
	
	^ self theNonMetaClass metaParserClass
]

{ #category : #compiling }
Metaclass >> possibleVariablesFor: misspelled continuedFrom: oldResults [

	^ thisClass possibleVariablesFor: misspelled continuedFrom: oldResults

]

{ #category : #copying }
Metaclass >> postCopy [
	"Don't share the reference to the sole instance."

	super postCopy.
	thisClass := nil.
]

{ #category : #printing }
Metaclass >> prettyPrinterClass [
	
	^ self theNonMetaClass metaPrettyPrinterClass
]

{ #category : #'instance variables' }
Metaclass >> removeInstVarName: aString [ 
	"Remove the argument, aString, as one of the receiver's instance variables."

	| newArray newString |
	(self instVarNames includes: aString)
		ifFalse: [self error: aString , ' is not one of my instance variables'].
	newArray := self instVarNames copyWithout: aString.
	newString := ''.
	newArray do: [:aString2 | newString := aString2 , ' ' , newString].
	self instanceVariableNames: newString
]

{ #category : #'class hierarchy' }
Metaclass >> removeObsoleteSubclass: aClass [
	"Do nothing."
]

{ #category : #'class hierarchy' }
Metaclass >> removeSubclass: aClass [
	"Do nothing."
]

{ #category : #private }
Metaclass >> replaceObsoleteInstanceWith: newInstance [
	thisClass class == self ifTrue:[^self error:'I am fine, thanks'].
	newInstance class == self ifFalse:[^self error:'Not an instance of me'].
	thisClass := newInstance.
]

{ #category : #accessing }
Metaclass >> soleInstance [
	"The receiver has only one instance. Answer it."

	^thisClass
]

{ #category : #'fileIn\/Out' }
Metaclass >> storeDataOn: aDataStream [
	"I don't get stored.  Use a DiskProxy"

	(aDataStream insideASegment and: [self isSystemDefined not]) ifTrue: [
		^ super storeDataOn: aDataStream].	"do trace me"
	self error: 'use a DiskProxy to store a Class'
]

{ #category : #'class hierarchy' }
Metaclass >> subclasses [
	"Answer the receiver's subclasses."
	thisClass == nil ifTrue:[^#()].
	^thisClass subclasses 
		select:[:aSubclass| aSubclass isMeta not] 
		thenCollect:[:aSubclass| aSubclass class]

	"Metaclass allInstancesDo:
		[:m | Compiler evaluate: 'subclasses:=nil' for: m logged: false]"
]

{ #category : #'class hierarchy' }
Metaclass >> subclassesDo: aBlock [
	"Evaluate aBlock for each of the receiver's immediate subclasses."
	thisClass subclassesDo:[:aSubclass|
		"The following test is for Class class which has to exclude
		the Metaclasses being subclasses of Class."
		aSubclass isMeta ifFalse:[aBlock value: aSubclass class]].
]

{ #category : #'class hierarchy' }
Metaclass >> subclassesDoGently: aBlock [
	"Evaluate aBlock for each of the receiver's immediate subclasses."
	thisClass subclassesDo: [:aSubclass |
		"The following test is for Class class which has to exclude
			the Metaclasses being subclasses of Class."
		aSubclass isInMemory ifTrue: [
			aSubclass isMeta ifFalse: [aBlock value: aSubclass class]]].
]

{ #category : #'accessing parallel hierarchy' }
Metaclass >> theMetaClass [
	"Sent to a class or metaclass, always return the metaclass"

	^self
]

{ #category : #'accessing parallel hierarchy' }
Metaclass >> theNonMetaClass [
	"Sent to a class or metaclass, always return the class"

	^thisClass
]

{ #category : #'initialize-release' }
Metaclass >> uses: aTraitCompositionOrArray instanceVariableNames: instVarString [ 
	| newComposition newMetaClass copyOfOldMetaClass |
	
	copyOfOldMetaClass := self copy.
	newMetaClass := self instanceVariableNames: instVarString.
	
	newComposition := aTraitCompositionOrArray asTraitComposition.
	newMetaClass setTraitComposition: newComposition.
	
	SystemChangeNotifier uniqueInstance
		classDefinitionChangedFrom: copyOfOldMetaClass to: newMetaClass
]

{ #category : #compiling }
Metaclass >> wantsChangeSetLogging [
	"Answer whether code submitted for the receiver should be remembered by the changeSet mechanism.The metaclass follows the rule of the class itself.  7/12/96 sw"

	^ thisClass wantsChangeSetLogging
]

{ #category : #compiling }
Metaclass >> wantsRecompilationProgressReported [
	"The metaclass follows the rule of the class itself."

	^ thisClass wantsRecompilationProgressReported
]

{ #category : #testing }
Metaclass >> whichSelectorsStoreInto: varName [ 
	"Answer a collection of selectors whose methods access the argument, varName, as a named class variable. Or let super try with a named instance variable."
	| ref |
	ref := self classPool
		associationAt: varName
		ifAbsent: [ ^ super whichSelectorsStoreInto: varName ].
	^self methodDict keys select: [:aSelector | (self methodDict at: aSelector) writesRef: ref ]
]
