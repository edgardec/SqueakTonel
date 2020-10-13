"
I am a context for compiling methods. I maintain the namespace of classes and global variables that are visible to the methods compiled within me.

I have the following instance variables:

info <EnvironmentInfo>
Metadata about me and the code I contain.

declarations <IdentityDictionary>
Bindings for class and other globals that have been declared inside me.

bindings <IdentityDictionary>
Bindings for all the class and global variables visible from the compiler.
It generally includes the declarations (see importSelf), plus other imports from other environments, including aliases.

policies      <Collection of: NamePolicy>
The list of rules for importing and exporting bindings to other environments.

observers      <Collection of: Environment>
These are the environments importing some bindings from self, and which should be notified whenever we add/remove/change some binding.

"
Class {
	#name : #Environment,
	#superclass : #Object,
	#instVars : [
		'info',
		'declarations',
		'bindings',
		'undeclared',
		'policies',
		'observers'
	],
	#classVars : [
		'Default',
		'Instances'
	],
	#category : #'Environments-Core'
}

{ #category : #'class initialization' }
Environment class >> cleanUp [
	self allInstancesDo:
		[:env | env purgeUndeclared]
]

{ #category : #accessing }
Environment class >> current [
	^ CurrentEnvironment signal ifNil: [self default]
]

{ #category : #accessing }
Environment class >> default [
	^ Default
]

{ #category : #accessing }
Environment class >> default: anEnvironment [
	Default := anEnvironment
]

{ #category : #'class initialization' }
Environment class >> initialize [
	self install
]

{ #category : #'class initialization' }
Environment class >> install [
	| smalltalk env |
	self environment class == self ifTrue:
		[Transcript 
			cr; 
			show: 'Can''t install environments; they''re already installed'.
		^ self].

	smalltalk := Smalltalk globals.
	env := self basicNew initializeWithSystemDictionary: smalltalk.
	Default := env.
	Instances ifNil: [Instances := IdentityDictionary new].
	Instances at: env info name put: env.
	(smalltalk at: #Undeclared) becomeForward: (env at: #Undeclared).
	smalltalk becomeForward: env.
	Smalltalk garbageCollect.
]

{ #category : #'instance creation' }
Environment class >> named: aSymbol [
	| symbol |
	symbol := aSymbol asSymbol.
	^ Instances 
		at: symbol
		ifAbsentPut: [ self withName: symbol ]
]

{ #category : #'class initialization' }
Environment class >> uninstall [
	| globals sysdict |
	self environment class == self ifFalse: 
		[Transcript 
			cr; 
			show: 'Can''t uninstall environments; they''re not currently installed'.
		^ self].
	
	globals := Smalltalk globals declarations.
	sysdict := SystemDictionary new: globals size.
	globals do: [:ea | sysdict add: ea].
	Smalltalk globals becomeForward: sysdict.
]

{ #category : #'instance creation' }
Environment class >> withName: aString [
	^ self basicNew initializeWithName: aString
]

{ #category : #updating }
Environment >> addAllBindings [
	declarations associationsDo:
		[:ea | self binding: ea addedTo: self]
]

{ #category : #observing }
Environment >> addObserver: anObject [
	observers add: anObject
]

{ #category : #'classes and traits' }
Environment >> allClasses [
	^ Array streamContents:
		[:out |
		self allClassesDo:
			[:class |
			out nextPut: class]]
]

{ #category : #'classes and traits' }
Environment >> allClassesAndTraits [
	^ Array streamContents:
		[:out | self allClassesAndTraitsDo:
			[:value | out nextPut: value]]
]

{ #category : #'classes and traits' }
Environment >> allClassesAndTraitsDo: aBlock [
	declarations keysAndValuesDo:
		[:key :value |
		((value isBehavior) and: [key == value name]) ifTrue:
			[aBlock value: value]]
]

{ #category : #'classes and traits' }
Environment >> allClassesDo: aBlock [
	self allClassesAndTraitsDo:
		[:value |
		 value isTrait ifFalse:
			[aBlock value: value]]
]

{ #category : #'classes and traits' }
Environment >> allTraits [
	^ Array streamContents:
		[:out |
		self allTraitsDo: 
			[:value | out nextPut: value]]	
]

{ #category : #'classes and traits' }
Environment >> allTraitsDo: aBlock [
	self allClassesAndTraitsDo:
		[:value |
		value isTrait ifTrue:
			[aBlock value: value]]
]

{ #category : #emulating }
Environment >> associationAt: aSymbol [
	"Senders of this should probably be using #bindingOf:"
	
	self flag: #review.
	^ declarations associationAt: aSymbol
]

{ #category : #emulating }
Environment >> associationAt: aSymbol ifAbsent: aBlock [
	"Senders of this should probably be using #bindingOf:"
	
	self flag: #review.
	^ declarations associationAt: aSymbol ifAbsent: aBlock
]

{ #category : #emulating }
Environment >> associationOrUndeclaredAt: key [
	^ bindings associationAt: key ifAbsent:
		[undeclared at: key put: nil.
		undeclared associationAt: key]
	
]

{ #category : #emulating }
Environment >> associationsDo: aBlock [
	"Evaluate aBlock for each of the receiver's elements (key/value associations)."

	declarations associationsDo: aBlock
]

{ #category : #emulating }
Environment >> at: aSymbol [
	^ declarations at: aSymbol
]

{ #category : #emulating }
Environment >> at: aSymbol ifAbsent: aBlock [
	^ declarations at: aSymbol ifAbsent: aBlock
]

{ #category : #emulating }
Environment >> at: aSymbol ifAbsentPut: aBlock [ 
	^self at: aSymbol ifAbsent: [
                self at: aSymbol put: aBlock value ]
]

{ #category : #emulating }
Environment >> at: aSymbol ifPresent: aBlock [
	^ declarations at: aSymbol ifPresent: aBlock
]

{ #category : #emulating }
Environment >> at: aSymbol ifPresent: presentBlock ifAbsent: absentBlock [
	^ declarations
		at: aSymbol
		ifPresent: presentBlock
		ifAbsent: absentBlock.
]

{ #category : #emulating }
Environment >> at: key ifPresentAndInMemory: aBlock [
	^ declarations
		at: key
		ifPresent: 
			[:v |
			v isInMemory ifTrue:
				[aBlock value: v]]
]

{ #category : #emulating }
Environment >> at: aSymbol put: anObject [
	^ self bind: aSymbol to: anObject
]

{ #category : #evaluating }
Environment >> beCurrentDuring: aBlock [
	"Evaluate aBlock with me as the current dynamic Environment"
	^ aBlock on: CurrentEnvironment do: [:e | e resume: self]
]

{ #category : #binding }
Environment >> bind: aSymbol to: anObject [
	| binding newBinding |
	newBinding := aSymbol => anObject.
	
	binding := declarations associationAt: aSymbol ifAbsent: [nil].
	binding ifNotNil: 
		[binding class == newBinding class
			ifTrue: [binding value: anObject]
			ifFalse: [binding becomeForward: newBinding].
		^anObject].
	
	binding := undeclared associationAt: aSymbol ifAbsent: [nil].
	binding
	        ifNil: [binding := newBinding]
	        ifNotNil: 
			[undeclared removeKey: aSymbol.
			binding class == newBinding class
				ifTrue: [binding value: anObject]
				ifFalse: [binding becomeForward: newBinding]].
			
	declarations add: binding.
	self binding: binding addedTo: self.
	^anObject

]

{ #category : #updating }
Environment >> binding: aBinding addedTo: anEnvironment [
	policies do:
		[:ea | ea binding: aBinding addedTo: anEnvironment notify: self]
]

{ #category : #updating }
Environment >> binding: aBinding removedFrom: anEnvironment [
	policies do:
		[:ea | ea binding: aBinding removedFrom: anEnvironment notify: self]
]

{ #category : #binding }
Environment >> bindingOf: aSymbol [
	^ self bindingOf: aSymbol ifAbsent: nil
]

{ #category : #binding }
Environment >> bindingOf: aSymbol ifAbsent: aBlock [
	^ bindings bindingOf: aSymbol ifAbsent: aBlock
]

{ #category : #'classes and traits' }
Environment >> classAndTraitNames [
	| names |
	names := Array streamContents:
		[:out |
		self allClassesAndTraitsDo:
			[:value |
			out nextPut: value name]].
	names sort.
	^ names
]

{ #category : #'classes and traits' }
Environment >> classNamed: aString [
	^ self classOrTraitNamed: aString
]

{ #category : #'classes and traits' }
Environment >> classNames [
	^ (self allClasses collect: [:ea | ea name]) sort
]

{ #category : #'classes and traits' }
Environment >> classOrTraitNamed: aString [ 
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

	^declarations at: baseName asSymbol ifPresent:
		[ :global |
 		global isBehavior ifTrue:
			[ meta
				ifFalse: [ global ]
				ifTrue: [ global classSide ]]]
]

{ #category : #emulating }
Environment >> collect: aBlock [
	^ declarations collect: aBlock
]

{ #category : #binding }
Environment >> declarationOf: aSymbol [
	^ declarations bindingOf: aSymbol
]

{ #category : #declaring }
Environment >> declarations [
	^ Array streamContents:
		[:out | declarations associationsDo:
			[:ea | out nextPut: ea]]
]

{ #category : #'initialize-release' }
Environment >> destroy [
	
	self allClasses do: [:ea | ea removeFromSystem].
	declarations keys do: [:ea | self unbind: ea].
	policies do: [:ea | ea removeObserver: self].
	observers do: [:ea | ea stopObserving: self].
]

{ #category : #emulating }
Environment >> do: aBlock [ 
	"Evaluate aBlock for each of the receiver's values."

	self valuesDo: aBlock
]

{ #category : #emulating }
Environment >> environment [
	^ self
]

{ #category : #private }
Environment >> errorKeyNotFound: key [
	"Signal KeyNotFound error"
	^(KeyNotFound key: key) signal
]

{ #category : #configuring }
Environment >> export: spec [
	| policy |
	policy := BindingPolicy 
		environment: self
		policy: (ExplicitNamePolicy spec: spec) 
		addSelector: #notifyObserversOfBindingAdded:
		removeSelector: #notifyObserversOfBindingRemoved:.
	policies := policies copyWith: policy
]

{ #category : #configuring }
Environment >> exportAddingPrefix: aString [
	| policy |
	policy := BindingPolicy 
		environment: self
		policy: (AddPrefixNamePolicy prefix: aString) 
		addSelector: #notifyObserversOfBindingAdded:
		removeSelector: #notifyObserversOfBindingRemoved:.
	policies := policies copyWith: policy
]

{ #category : #configuring }
Environment >> exportRemovingPrefix: aString [
	| policy |
	policy := BindingPolicy 
		environment: self
		policy: (RemovePrefixNamePolicy prefix: aString)
		addSelector: #notifyObserversOfBindingAdded:
		removeSelector: #notifyObserversOfBindingRemoved:.
	policies := policies copyWith: policy
]

{ #category : #configuring }
Environment >> exportSelf [
	| policy |
	policy := BindingPolicy
		environment: self 
		policy: (AllNamePolicy new)
		addSelector: #notifyObserversOfBindingAdded:
		removeSelector: #notifyObserversOfBindingRemoved:.
	policies := policies copyWith: policy
]

{ #category : #operations }
Environment >> fileIn: aStream announcing: aString [
	(EnvironmentLoader for: self) 
		fileIn: aStream 
		announcing: aString

]

{ #category : #'classes and traits' }
Environment >> flushClassNameCache [
	"We don't have one"
]

{ #category : #'classes and traits' }
Environment >> forgetClass: aClass logged: aBool [
	(self hasBindingOf: aClass name) ifFalse: [ ^ self ].
	aBool ifTrue: 
		[SystemChangeNotifier uniqueInstance 
			classRemoved: aClass fromCategory: aClass category].
	self organization removeElement: aClass name.
	Smalltalk removeFromStartUpList: aClass.
	Smalltalk removeFromShutDownList: aClass.
	self unbind: aClass name
]

{ #category : #configuring }
Environment >> from: anEnvironment import: spec [ 
	| policy |
	policy := BindingPolicy 
		environment: anEnvironment
		policy: (ExplicitNamePolicy spec: spec)
		addSelector: #showBinding:
		removeSelector: #hideBinding:.
	policies := policies copyWith: policy.
	anEnvironment addObserver: self.
	anEnvironment addAllBindings.
]

{ #category : #binding }
Environment >> hasBindingOf: aSymbol [
	^ declarations includesKey: aSymbol
]

{ #category : #'classes and traits' }
Environment >> hasClassNamed: aString [
	Symbol hasInterned: aString ifTrue:
		[:symbol | 
		^ (declarations at: symbol ifAbsent: [nil])
			isKindOf: Class].
	^ false.
]

{ #category : #binding }
Environment >> hideBinding: aBinding [
	(bindings bindingOf: aBinding key) == aBinding ifFalse: [^ self].
	self undeclare: aBinding key from: bindings
]

{ #category : #configuring }
Environment >> import: anEnvironment [
	| policy |
	policy := BindingPolicy 
		environment: anEnvironment 
		policy: AllNamePolicy new
		addSelector: #showBinding:
		removeSelector: #hideBinding:.
	policies := policies copyWith: policy.
	anEnvironment addObserver: self.
	anEnvironment addAllBindings.
]

{ #category : #configuring }
Environment >> import: anEnvironment addingPrefix: aString [ 
	
	| import |
	import := BindingPolicy
		environment: anEnvironment
		policy: (AddPrefixNamePolicy prefix: aString)
		addSelector: #showBinding:
		removeSelector: #hideBinding:.
	policies := policies copyWith: import.
	anEnvironment addObserver: self.
	anEnvironment addAllBindings.
]

{ #category : #configuring }
Environment >> import: anEnvironment removingPrefix: aString [ 
	
	| import |
	import := BindingPolicy
		environment: anEnvironment
		policy: (RemovePrefixNamePolicy prefix: aString)
		addSelector: #showBinding:
		removeSelector: #hideBinding:.
	policies := policies copyWith: import.
	anEnvironment addObserver: self.
	anEnvironment addAllBindings.
]

{ #category : #configuring }
Environment >> importSelf [
	| policy |
	policy := BindingPolicy
		environment: self
		policy: AllNamePolicy new
		addSelector: #showBinding:
		removeSelector: #hideBinding:.
	policies := policies copyWith: policy.
	
	declarations associationsDo:
		[:ea | (bindings includesKey: ea key) ifFalse:
			[bindings add: ea]]
]

{ #category : #emulating }
Environment >> includes: value [
	^ declarations includes: value
]

{ #category : #emulating }
Environment >> includesKey: key [
	^ declarations includesKey: key
]

{ #category : #accessing }
Environment >> info [
	^ info
]

{ #category : #'initialize-release' }
Environment >> initialize [
	declarations := IdentityDictionary new.
	bindings := IdentityDictionary new. 
	undeclared := WeakIdentityDictionary new.
	policies := Array new. 
	observers := IdentitySet new.
]

{ #category : #'initialize-release' }
Environment >> initializeWithName: aString [
	| smalltalk |
	self initialize.
	info := EnvironmentInfo name: aString.
.
	smalltalk := SmalltalkImage basicNew.
	smalltalk globals: self.
	declarations at: #Smalltalk put: smalltalk.
	declarations at: #Undeclared put: undeclared.
]

{ #category : #'initialize-release' }
Environment >> initializeWithSystemDictionary: old [
	
	self initialize.
	info := EnvironmentInfo 
		name: 'Smalltalk'
		organization: old organization
		packages: PackageOrganizer default.
	old associationsDo: [:assc | declarations add: assc].
	(old at: #Undeclared) associationsDo: [:assc | undeclared add: assc].
	(declarations at: #Smalltalk) instVarNamed: 'globals' put: self.
	declarations at: #Undeclared put: undeclared.
]

{ #category : #declaring }
Environment >> isUndeclared: aSymbol [
	^ undeclared includesKey: aSymbol
]

{ #category : #emulating }
Environment >> keyAtIdentityValue: anObject [
	^ declarations keyAtIdentityValue: anObject.
]

{ #category : #emulating }
Environment >> keyAtIdentityValue: anObject ifAbsent: aBlock [
	^ declarations keyAtIdentityValue: anObject ifAbsent: aBlock
]

{ #category : #emulating }
Environment >> keyAtValue: anObject [
	^ self keyAtIdentityValue: anObject
]

{ #category : #emulating }
Environment >> keys [
	^ declarations keys
]

{ #category : #emulating }
Environment >> keysAndValuesDo: aBlock [
	^self associationsDo: [:assoc |
		aBlock value: assoc key value: assoc value].
]

{ #category : #emulating }
Environment >> keysDo: aBlock [ 
	"Evaluate aBlock for each of the receiver's keys."

	declarations keysDo: aBlock
]

{ #category : #updating }
Environment >> notifyObserversOfBindingAdded: aBinding [
	observers do: [:ea | ea binding: aBinding addedTo: self]
]

{ #category : #updating }
Environment >> notifyObserversOfBindingRemoved: aBinding [
	observers do: [:ea | ea binding: aBinding removedFrom: self]
]

{ #category : #emulating }
Environment >> objectForDataStream: refStrm [
	| dp |
	"I am about to be written on an object file.  Write a reference to Smalltalk instead."

	dp := DiskProxy global: #Smalltalk selector: #globals args: #().
	refStrm replace: self with: dp.
	^ dp
]

{ #category : #accessing }
Environment >> organization [
	^ info organization
]

{ #category : #emulating }
Environment >> poolUsers [
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
				ifTrue: [refs := (self systemNavigation allClasses
								select: [:c | c sharedPools identityIncludes: pool]
								thenCollect: [:c | c name]) asOrderedCollection.
					refs
						add: (self systemNavigation
								allCallsOn: (self associationAt: k)).
					poolUsers at: k put: refs]].
	^ poolUsers
]

{ #category : #printing }
Environment >> printOn: aStream [
	aStream nextPutAll: info name
]

{ #category : #declaring }
Environment >> purgeUndeclared [
	undeclared removeUnreferencedKeys
]

{ #category : #operations }
Environment >> recompileAll [	
	self allClassesAndTraits 
		do: [:classOrTrait | classOrTrait compileAll] 
		displayingProgress:[:classOrTrait| 'Recompiling ', classOrTrait]



]

{ #category : #private }
Environment >> remove: binding from: aDictionary readdAfter: aBlock [

	aDictionary
		removeKey: binding key
		ifAbsent: [ ^aBlock value ].
	^aBlock ensure: [ aDictionary add: binding ]
]

{ #category : #'classes and traits' }
Environment >> removeClassNamed: aString [
	declarations 
		at: aString asSymbol 
		ifPresent: [:class | class removeFromSystem]
		ifAbsent: 
			[Transcript cr; show: 'Removal of class named ', aString, 
			' ignored because ', aString, ' does not exist.']
]

{ #category : #emulating }
Environment >> removeKey: key [ 
	"Remove key from the receiver.
	If key is not in the receiver, notify an error."
	self flag: #review.
	^ self removeKey: key ifAbsent: [self errorKeyNotFound: key].
]

{ #category : #emulating }
Environment >> removeKey: aSymbol ifAbsent: aBlock [
	| binding |
	self flag: #review.

	(declarations includesKey: aSymbol) ifFalse: [^aBlock value].
	binding := (declarations associationAt: aSymbol).
	declarations removeKey: aSymbol.
	self
		binding: binding
		removedFrom: self.
	^ binding value
]

{ #category : #observing }
Environment >> removeObserver: anObject [
	observers remove: anObject ifAbsent: []
]

{ #category : #'classes and traits' }
Environment >> renameClass: aClass as: newName [ 
	^self renameClass: aClass from: aClass name to: newName
]

{ #category : #'classes and traits' }
Environment >> renameClass: aClass from: oldName [
	^self renameClass: aClass from: oldName to: aClass name
]

{ #category : #'classes and traits' }
Environment >> renameClass: aClass from: oldName to: newName [
	"Rename the class, aClass, to have the title newName."

	| oldBinding newBinding category |
	category := self organization categoryOfElement: oldName.
	self organization classify: newName under: category suppressIfDefault: true.
	self organization removeElement: oldName.
	
	oldBinding := self declarationOf: oldName.
	declarations removeKey: oldName.
	self binding: oldBinding removedFrom: self.
	" re-route now undeclared oldBinding "
	oldBinding value: aClass.

	newBinding := newName => aClass.
	aClass updateMethodBindingsTo: newBinding.
	declarations add: newBinding. 
	self binding: newBinding addedTo: self.
	
	Smalltalk renamedClass: aClass from: oldName to: newName.
	SystemChangeNotifier uniqueInstance 
		classRenamed: aClass 
		from: oldName 
		to: newName 
		inCategory: category
]

{ #category : #'classes and traits' }
Environment >> renameClassNamed: oldName as: newName [
	declarations
		at: oldName
		ifPresent: [:class | class rename: newName]
		ifAbsent:
			[Transcript cr; show: 'Class-rename for ', oldName, 
			' ignored because ', oldName, ' does not exist.']
]

{ #category : #accessing }
Environment >> rootClasses [
	"return a collection of classes which have a nil superclass"
	^ (self select: [:each | each isBehavior and: [each superclass isNil]]) asOrderedCollection.
]

{ #category : #emulating }
Environment >> scopeFor: aSymbol from: lower envtAndPathIfFound: aBlock [
	^ (declarations includesKey: aSymbol)
		ifTrue: [aBlock value: self value: String new]
		
]

{ #category : #emulating }
Environment >> select: aBlock [
	^ declarations select: aBlock
]

{ #category : #binding }
Environment >> showBinding: aBinding [
	| binding |
	binding := undeclared associationAt: aBinding key ifAbsent: [nil].
	binding ifNotNil:
		[undeclared removeKey: binding key.
		binding becomeForward: aBinding].
	
	binding := bindings associationAt: aBinding key ifAbsent: [nil].
	binding ifNotNil:
		[binding == aBinding ifTrue: [^self].
		bindings removeKey: binding key].
	
	bindings add: aBinding.
]

{ #category : #observing }
Environment >> stopObserving: anEnvironment [
	policies := policies reject: [:ea | ea environment == anEnvironment].
]

{ #category : #emulating }
Environment >> storeDataOn: aDataStream [
	"I don't get stored.  Use a DiskProxy"

	self error: 'use a DiskProxy to store me'
]

{ #category : #'classes and traits' }
Environment >> traitNames [
	^ self allTraits collect: [:ea | ea name]
]

{ #category : #binding }
Environment >> unbind: aSymbol [
	| binding |
	binding := declarations bindingOf: aSymbol ifAbsent: [^ self].
	undeclared declare: aSymbol from: declarations.
	declarations removeKey: aSymbol ifAbsent: [  ].
	[ undeclared at: aSymbol put: nil ]
		on: AttemptToWriteReadOnlyGlobal
		do: [ :n | n resume: true ].
	self binding: binding removedFrom: self
]

{ #category : #declaring }
Environment >> undeclare: aSymbol [
	^ (undeclared bindingOf: aSymbol) ifNil:
		[undeclared add: aSymbol => nil]
]

{ #category : #declaring }
Environment >> undeclare: aSymbol from: aNamespace [
	| binding |
	binding := self undeclare: aSymbol.
	(aNamespace bindingOf: aSymbol) ifNotNil:
		[:old |
		aNamespace removeKey: aSymbol.
		old becomeForward: binding].
	^ binding
]

{ #category : #accessing }
Environment >> undeclared [
	^ undeclared
]

{ #category : #binding }
Environment >> valueOf: aSymbol [
	^ self valueOf: aSymbol ifAbsent: nil
]

{ #category : #binding }
Environment >> valueOf: aSymbol ifAbsent: aBlock [
	^ (self bindingOf: aSymbol ifAbsent: [^ aBlock value]) value
]

{ #category : #emulating }
Environment >> valuesDo: aBlock [ 
	"Evaluate aBlock for each of the receiver's values."

	declarations valuesDo: aBlock
]

{ #category : #emulating }
Environment >> veryDeepCopyWith: aCopier [
	^ self
]
