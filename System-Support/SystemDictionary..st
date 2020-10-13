"
I represent a special dictionary used as global namespace for class names :

	Smalltalk globals classNames.

and for traits too:

	Smalltalk globals traitNames.
	
and a few other globals:

	(Smalltalk globals keys reject: [:k | (Smalltalk globals at: k) isBehavior])
			collect: [:k | k -> (Smalltalk globals at: k) class].

As the above example let you guess, the global namespace of Smalltalk system is accessed through:

	Smalltalk globals.
"
Class {
	#name : #SystemDictionary,
	#superclass : #IdentityDictionary,
	#instVars : [
		'cachedClassNames',
		'cachedNonClassNames'
	],
	#category : #'System-Support'
}

{ #category : #'classes and traits' }
SystemDictionary >> allClasses [  
	"Return all the class defines in the Smalltalk SystemDictionary"
	"Smalltalk allClasses"

	^ self classNames collect: [:name | self at: name]
]

{ #category : #'classes and traits' }
SystemDictionary >> allClassesAndTraits [
	"Return all the classes and traits defined in the Smalltalk SystemDictionary"

	^Array streamContents: [ :stream |
		self allClassesAndTraitsDo: [ :each | stream nextPut: each ] ]
]

{ #category : #'classes and traits' }
SystemDictionary >> allClassesAndTraitsDo: aBlock [
	
	self
		allClassesDo: aBlock;
		allTraitsDo: aBlock
]

{ #category : #'classes and traits' }
SystemDictionary >> allClassesDo: aBlock [
	"Evaluate the argument, aBlock, for each class in the system."

	self classNames do: [ :name |
		aBlock value: (self at: name) ]
]

{ #category : #'classes and traits' }
SystemDictionary >> allTraits [
	"Return all traits defined in the Smalltalk SystemDictionary"

	^ self traitNames collect: [:each | self at: each]
]

{ #category : #'classes and traits' }
SystemDictionary >> allTraitsDo: aBlock [
	"Evaluate the argument, aBlock, for each trait in the system."

	self traitNames do: [ :name |
		aBlock value: (self at: name) ]
]

{ #category : #'dictionary access' }
SystemDictionary >> associationOrUndeclaredAt: key [ 
	"return an association or install in undeclared.  Used for mating up ImageSegments."
	self flag: #environments.

	^ self associationAt: key ifAbsent: [
		Undeclared at: key put: nil.
		Undeclared associationAt: key]
]

{ #category : #'dictionary access' }
SystemDictionary >> at: aKey put: anObject [ 
	"Override from Dictionary to check Undeclared and fix up
	references to undeclared variables."
	| index element |
	(self includesKey: aKey) ifFalse: 
		[self declare: aKey from: (self at: #Undeclared).
		self flushClassNameCache].
	super at: aKey put: anObject.
	^ anObject
]

{ #category : #accessing }
SystemDictionary >> bindingOf: varName [
	"SystemDictionary includes Symbols only"
	^super bindingOf: varName asSymbol
]

{ #category : #accessing }
SystemDictionary >> bindingOf: varName ifAbsent: aBlock [
	"SystemDictionary includes Symbols only"
	^super bindingOf: varName asSymbol ifAbsent: aBlock
]

{ #category : #'classes and traits' }
SystemDictionary >> classAndTraitNames [
	"Answer a sorted collection of all class and trait (not including class-traits) names. The performance of this algorithm is O(n) if the classNames are already cached, otherwise O(n*log(n)) where n is self size."

	| classNames traitNames result temporary |
	classNames := self classNames.
	traitNames := self traitNames ifEmpty: [ ^classNames ].
	temporary := Array new: classNames size + traitNames size.
	result := temporary shallowCopy.
	temporary
		replaceFrom: 1
		to: classNames size
		with: classNames
		startingAt: 1;
		replaceFrom: classNames size + 1
		to: temporary size
		with: traitNames
		startingAt: 1;
		mergeFirst: 1
		middle: classNames size
		last: temporary size
		into: result
		by: nil.
	^result
]

{ #category : #'classes and traits' }
SystemDictionary >> classNamed: className [ 
	^self classOrTraitNamed: className.
]

{ #category : #'classes and traits' }
SystemDictionary >> classNames [
	"Answer a sorted collection of all class names. Use the return value of #fillCaches to avoid concurrency issues."
	
	^cachedClassNames ifNil: [ self fillCaches at: 1 ]
]

{ #category : #'classes and traits' }
SystemDictionary >> classOrTraitNamed: aString [ 
	"aString is either a class or trait name or a class or trait name followed by ' class' or 'classTrait' respectively.
	Answer the class or metaclass it names."

	| meta baseName |
	(aString endsWith: ' class')
		ifTrue: [meta := true.
				baseName := aString copyFrom: 1 to: aString size - 6]
		ifFalse: [
			(aString endsWith: ' classTrait')
				ifTrue: [
					meta := true.
					baseName := aString copyFrom: 1 to: aString size - 11]
				ifFalse: [
					meta := false.
					baseName := aString]].

	^self at: baseName asSymbol ifPresent:
		[ :global |
 		global isBehavior ifTrue:
			[ meta
				ifFalse: [ global ]
				ifTrue: [ global classSide ]]]
]

{ #category : #accessing }
SystemDictionary >> environment [
	"For conversion from Smalltalk to SystemDictionary"
	^self
]

{ #category : #'classes and traits' }
SystemDictionary >> fillCaches [
	"Fill cachedClassNames and cachedNonClassNames. Return an array with the calculated values."

	| classNames nonClassNames |
	classNames := OrderedCollection new: self size.
	nonClassNames := OrderedCollection new.
	self keysAndValuesDo: [ :key :value |
		value isInMemory ifTrue: [
			"The key == value name test below addresses two separate issues:
				1) Obsolete classes, where key = #Foo and value name = 'AnObsoleteFoo'
				2) Aliases, i.e., Smalltalk at: #OtherName put: aClass"
			((value isKindOf: Class) and: [ key == value name ])
				ifTrue: [ classNames add: key ]
				ifFalse: [ nonClassNames add: key ] ] ].
	classNames sort.
	cachedNonClassNames := nonClassNames sort.
	cachedClassNames := classNames.
	^{ classNames. nonClassNames }
]

{ #category : #'classes and traits' }
SystemDictionary >> flushClassNameCache [
	"Smalltalk flushClassNameCache"
	"Force recomputation of the cached list of class names and non-class names."

	cachedClassNames := cachedNonClassNames := nil
]

{ #category : #'classes and traits' }
SystemDictionary >> forgetClass: aClass logged: aBool [ 
	"Delete the class, aClass, from the system.
	Note that this doesn't do everything required to dispose of a class - to do that use Class>>removeFromSystem."

	aBool ifTrue: [SystemChangeNotifier uniqueInstance classRemoved: aClass fromCategory: aClass category].
	self organization removeElement: aClass name.
	Smalltalk removeFromStartUpList: aClass.
	Smalltalk removeFromShutDownList: aClass.
	aClass isObsolete ifFalse: [
		(self associationAt: aClass name ifAbsent: [ nil ]) ifNotNil: [ :oldBinding |
			| newBinding |
			newBinding := oldBinding shallowCopy.
			self replaceBinding: oldBinding in: aClass with: newBinding.
			(self isThisBindingReferred: oldBinding) ifTrue: [
				[oldBinding value: nil]
					on: AttemptToWriteReadOnlyGlobal
					do: [:ex | true].
				Undeclared add: oldBinding ] ] ].
	self removeKey: aClass name ifAbsent: [].
	self flushClassNameCache
]

{ #category : #'classes and traits' }
SystemDictionary >> hasClassNamed: aString [
	"Answer whether there is a class of the given name, but don't intern aString if it's not alrady interned.  4/29/96 sw"

	Symbol hasInterned: aString ifTrue: 
		[:aSymbol | ^ (self at: aSymbol ifAbsent: [nil]) isKindOf: Class].
	^ false
]

{ #category : #'classes and traits' }
SystemDictionary >> isThisBindingReferred: binding [

	self systemNavigation allSelectorsAndMethodsDo: [ :behavior :selector :method |
		(method instVarsInclude: binding) ifTrue: [ 
			method allLiteralsDo: [ :literal | "Avoid possible false positives from the primitive."
				literal == binding ifTrue: [ ^true ] ] ] ].
	^false
]

{ #category : #'classes and traits' }
SystemDictionary >> nonClassNames [
	"Answer a sorted collection of all non-class names. Use the return value of #fillCaches to avoid concurrency issues."
	
	^cachedNonClassNames ifNil: [ self fillCaches at: 2 ]
]

{ #category : #'objects from disk' }
SystemDictionary >> objectForDataStream: refStrm [
	| dp |
	"I am about to be written on an object file.  Write a reference to Smalltalk instead."

	dp := DiskProxy global: #Smalltalk selector: #globals
			args: #().
	refStrm replace: self with: dp.
	^ dp
]

{ #category : #accessing }
SystemDictionary >> organization [
	"Return the organizer for the receiver"
	^SystemOrganization
]

{ #category : #accessing }
SystemDictionary >> poolUsers [
	"Answer a dictionary of pool name -> classes that refer to it.
	Also includes any globally know dictionaries (such as
	Smalltalk, Undeclared etc) which although not strictly
	accurate is potentially useful information"
	"Smalltalk poolUsers"
	| poolUsers |
	poolUsers := Dictionary new.
	self keys
		do: [:k | "yes, using isKindOf: is tacky but for reflective code like
			this it is very useful. If you really object you can:-
			a) go boil your head.
			b) provide a better answer.
			your choice."
			| pool refs |
			(((pool := self at: k) isKindOf: Dictionary)
					or: [pool isKindOf: SharedPool class])
				ifTrue: [refs := self systemNavigation allClasses
								select: [:c | c sharedPools identityIncludes: pool]
								thenCollect: [:c | c name].
					refs
						add: (self systemNavigation
								allCallsOn: (self associationAt: k)).
					poolUsers at: k put: refs]].
	^ poolUsers
]

{ #category : #printing }
SystemDictionary >> printElementsOn: aStream [
	aStream nextPutAll:'(lots of globals)'
]

{ #category : #printing }
SystemDictionary >> printOn: aStream [
	self == Smalltalk globals
		ifTrue: [aStream nextPutAll: 'Smalltalk globals'.
			aStream nextPutAll:' "a SystemDictionary with lots of globals"']
		ifFalse: [super printOn: aStream]
]

{ #category : #'classes and traits' }
SystemDictionary >> removeClassNamed: aName [
	"Invoked from fileouts:  if there is currently a class in the system named aName, then remove it.  If anything untoward happens, report it in the Transcript.  "

	| oldClass |
	(oldClass := self at: aName asSymbol ifAbsent: [nil]) == nil
		ifTrue:
			[Transcript cr; show: 'Removal of class named ', aName, ' ignored because ', aName, ' does not exist.'.
			^ self].

	oldClass removeFromSystem
]

{ #category : #removing }
SystemDictionary >> removeKey: key ifAbsent: aBlock [
	"Remove key (and its associated value) from the receiver. If key is not in
	the receiver, answer the result of evaluating aBlock. Otherwise, answer
	the value externally named by key."

	self flushClassNameCache.
	^super removeKey: key ifAbsent: aBlock
]

{ #category : #'classes and traits' }
SystemDictionary >> renameClass: aClass as: newName [ 
	"Rename the class, aClass, to have the title newName."

	^self renameClass: aClass from: aClass name to: newName
]

{ #category : #'classes and traits' }
SystemDictionary >> renameClass: aClass from: oldName [ 
	"Rename the class, aClass, to have the title newName."

	^self renameClass: aClass from: oldName to: aClass name
]

{ #category : #'classes and traits' }
SystemDictionary >> renameClass: aClass from: oldName to: newName [
	"Rename the class, aClass, to have the title newName."

	| oldref category |
	category := SystemOrganization categoryOfElement: oldName.
	self organization classify: newName under: category suppressIfDefault: true.
	self organization removeElement: oldName.
	oldref := self associationAt: oldName.
	self removeKey: oldName.
	oldref key: newName.
	self add: oldref.  "Old association preserves old refs"
	Smalltalk renamedClass: aClass from: oldName to: newName.
	self flushClassNameCache.
	SystemChangeNotifier uniqueInstance classRenamed: aClass from: oldName to: newName inCategory: category
]

{ #category : #'classes and traits' }
SystemDictionary >> renameClassNamed: oldName as: newName [
	"Invoked from fileouts:  if there is currently a class in the system named oldName, then rename it to newName.  If anything untoward happens, report it in the Transcript.  "

	| oldClass |
	(oldClass := self at: oldName asSymbol ifAbsent: [nil]) == nil
		ifTrue:
			[Transcript cr; show: 'Class-rename for ', oldName, ' ignored because ', oldName, ' does not exist.'.
			^ self].

	oldClass rename: newName
]

{ #category : #'classes and traits' }
SystemDictionary >> replaceBinding: oldBinding in: aClass with: newBinding [
	"Replace oldBinding with newBinding in aClass. This method is expected to be used during the removal of aClass."

	aClass methodsDo: [ :method |
		1 to: method numLiterals do: [ :index |
			(method literalAt: index) == oldBinding ifTrue: [
				method literalAt: index put: newBinding ] ] ]
]

{ #category : #'classes and traits' }
SystemDictionary >> replaceBinding: oldBinding inAllMethodsWith: newBinding [
	"Replace oldBinding to newBinding in all methods in the system except for those which are the methods of the class of oldBinding. Return true if such replacement were made, false otherwise."

	| foundReferringMethod |
	foundReferringMethod := false.
	self systemNavigation allSelectorsAndMethodsDo: [ :behavior :selector :method |
		(behavior ~~ oldBinding value and: [
			method instVarsInclude: oldBinding ]) ifTrue: [ "Use the fast primitive first."
				"The penultimate literal holds the selector of the method, the last literal is the class."
				1 to: method numLiterals - 2 do: [ :index |
					(method literalAt: index) == oldBinding ifTrue: [
						foundReferringMethod := true.
						method 
							literalAt: index put: newBinding;
							flushCache ] ] ] ].
	^foundReferringMethod
]

{ #category : #private }
SystemDictionary >> scanFor: anObject [
	"Scan the key array for the first slot containing either a nil (indicating an empty slot) or an element that matches anObject. Answer the index of that slot or raise an error if no slot is found. This method will be overridden in various subclasses that have different interpretations for matching elements."

	| index start size |
	index := start := anObject hash \\ (size := array size) + 1.
	[ 
		| element |
		((element := array at: index) == nil or: [ element key == anObject ])
			ifTrue: [ ^index ].
		(index := index \\ size + 1) = start ] whileFalse.
	self errorNoFreeSpace
]

{ #category : #private }
SystemDictionary >> scanForEmptySlotFor: anObject [
	"Scan the key array for the first slot containing an empty slot (indicated by a nil). Answer the index of that slot. This method will be overridden in various subclasses that have different interpretations for matching elements."
	
	| index start size |
	index := start := anObject hash \\ (size := array size) + 1.
	[ 
		(array at: index) ifNil: [ ^index ].
		(index := index \\ size + 1) = start ] whileFalse.
	self errorNoFreeSpace
]

{ #category : #'dictionary access' }
SystemDictionary >> scopeFor: varName from: lower envtAndPathIfFound: envtAndPathBlock [
	"Null compatibility with partitioning into environments."

	(self includesKey: varName)
		ifTrue: [^ envtAndPathBlock value: self value: String new]
		ifFalse: [^ nil]
]

{ #category : #'objects from disk' }
SystemDictionary >> storeDataOn: aDataStream [
	"I don't get stored.  Use a DiskProxy"

	self error: 'use a DiskProxy to store me'
]

{ #category : #'classes and traits' }
SystemDictionary >> traitNames [
	"Answer a sorted collection of all traits (not including class-traits) names."

	^self nonClassNames select: [ :name |
		(name beginsWith: 'AnObsolete') not and: [
			self 
				at: name 
				ifPresent: [ :global | global isInMemory and: [ global isTrait ] ]
				ifAbsent: [ false ] ] ]
]

{ #category : #accessing }
SystemDictionary >> undeclared [
	^ self at: #Undeclared
]

{ #category : #copying }
SystemDictionary >> veryDeepCopyWith: deepCopier [
	"Return self.  I can't be copied.  Do not record me."
]
