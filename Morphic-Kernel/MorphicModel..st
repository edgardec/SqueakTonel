"
MorphicModels are used to represent structures with state and behavior as well as graphical structure.  A morphicModel is usually the root of a morphic tree depicting its appearance.  The tree is constructed concretely by adding its consituent morphs to a world.

When a part is named in a world, it is given a new slot in the model.  When a part is sensitized, it is named, and a set of mouse-driven methods is also generated in the model.  These may be edited to induce particular behavior.  When a variable is added through the morphic world, it is given a slot in the model, along with a set of access methods.

In addition for public variables (and this is the default for now), methods are generated and called in any outer model in which this model gets embedded, thus propagating variable changes outward.
"
Class {
	#name : #MorphicModel,
	#superclass : #BorderedMorph,
	#instVars : [
		'model',
		'slotName',
		'open'
	],
	#classVars : [
		'TimeOfError'
	],
	#classInstVars : [
		'prototype'
	],
	#category : #'Morphic-Kernel'
}

{ #category : #compiling }
MorphicModel class >> acceptsLoggingOfCompilation [
	"Dont log sources for my automatically-generated subclasses.  Can easily switch this back when it comes to deal with Versions, etc."

	^ self == MorphicModel or: [(name last isDigit) not]
]

{ #category : #compilation }
MorphicModel class >> categoryForSubclasses [
	^ 'Morphic-Models'
]

{ #category : #compilation }
MorphicModel class >> chooseNewName [
	"Choose a new name for the receiver, persisting until an acceptable name is provided or until the existing name is resubmitted"

	| oldName newName |
	oldName := self name.
		[newName := (UIManager default request: 'Please give this Model a name'
					initialAnswer: oldName) asSymbol.
		newName = oldName ifTrue: [^ self].
		Smalltalk includesKey: newName]
		whileTrue:
		[self inform: 'Sorry, that name is already in use.'].
	self rename: newName.
]

{ #category : #compilation }
MorphicModel class >> compileAccessorsFor: varName [
	self compile: (
'&var
	"Return the value of &var"
	^ &var'
			copyReplaceAll: '&var' with: varName)
		classified: 'public access' notifying: nil.
	self compile: (
'&varPut: newValue
	"Assign newValue to &var.
	Add code below to update related graphics appropriately..."

	&var := newValue.'
			copyReplaceAll: '&var' with: varName)
		classified: 'public access' notifying: nil.
	self compile: (
'&var: newValue
	"Assigns newValue to &var and updates owner"
	&var := newValue.
	self propagate: &var as: ''&var:'''
			copyReplaceAll: '&var' with: varName)
		classified: 'private - propagation' notifying: nil.

]

{ #category : #compilation }
MorphicModel class >> compilePropagationForVarName: varName slotName: slotName [
	self compile: ((
'&slot&var: newValue
	"The value of &var in &slot has changed to newValue.
	This value can be read elsewhere in code with
		&slot &var
	and it can be stored into with
		&slot &varPut: someValue"

	"Add code for appropriate response here..."'
			copyReplaceAll: '&var' with: varName)
			copyReplaceAll: '&slot' with: slotName)
		classified: 'input events' notifying: nil.

]

{ #category : #queries }
MorphicModel class >> hasPrototype [
	"Return true if there is a prototype for this morph."

	^ prototype ~~ nil

]

{ #category : #'new-morph participation' }
MorphicModel class >> includeInNewMorphMenu [
	"Only include Models that are appropriate"
	^ false
]

{ #category : #'instance creation' }
MorphicModel class >> new [
	"Return a copy of the prototype, if there is one.
	Otherwise create a new instance normally."

	self hasPrototype ifTrue: [^ prototype veryDeepCopy].
	^ super new

]

{ #category : #'instance creation' }
MorphicModel class >> newBounds: bounds model: thang slotName: nameOfThisPart [
	^ (super new model: thang slotName: nameOfThisPart)
		newBounds: bounds
]

{ #category : #testing }
MorphicModel class >> officialClass [
	"We want to make a new instance of the receiver, which is a subclass of MorphicModel.  Answer who to make a new subclass of.  Also used to tell if a given class is a UniClass, existing only for its single instance."

	^ self name last isDigit ifTrue: [MorphicModel] ifFalse: [self]
		"MorphicModel7 can not have subclasses, but Slider and SystemWindow may"
]

{ #category : #'prototype access' }
MorphicModel class >> prototype [
	"Return the prototype for this morph."

	^ prototype

]

{ #category : #'prototype access' }
MorphicModel class >> prototype: aMorph [
	"Store a copy of the given morph as a prototype to be copied to make new instances."

	aMorph ifNil: [prototype := nil. ^ self].

	prototype := aMorph veryDeepCopy.
	(prototype isMorphicModel) ifTrue: 
		[prototype model: nil slotName: nil].

]

{ #category : #housekeeping }
MorphicModel class >> removeUninstantiatedModels [
	"With the user's permission, remove the classes of any models that have neither instances nor subclasses."
	"MorphicModel removeUninstantiatedModels"

	| candidatesForRemoval |
	Smalltalk garbageCollect.
	candidatesForRemoval :=
		MorphicModel subclasses select: [:c |
			(c instanceCount = 0) and: [c subclasses size = 0]].
	candidatesForRemoval do: [:c | | ok |
		ok := self confirm: 'Are you certain that you
want to delete the class ', c name, '?'.
		ok ifTrue: [c removeFromSystem]].

]

{ #category : #compiling }
MorphicModel class >> wantsChangeSetLogging [
	"Log changes for MorphicModel itself and for things like PlayWithMe2, but not for automatically-created subclasses like MorphicModel1, MorphicModel2, etc."

	^ self == MorphicModel or:
		[(self class name beginsWith: 'Morphic') not]
]

{ #category : #menu }
MorphicModel >> addCustomMenuItems: aCustomMenu hand: aHandMorph [

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	model ifNotNil: [model addModelMenuItemsTo: aCustomMenu forMorph: self hand: aHandMorph].
	self isOpen ifTrue: [aCustomMenu add: 'close editing' translated action: #closeToEdits]
			ifFalse: [aCustomMenu add: 'open editing' translated action: #openToEdits].

]

{ #category : #'graph model' }
MorphicModel >> addModelYellowButtonMenuItemsTo: aCustomMenu forMorph: aMorph hand: aHandMorph [ 

	Preferences noviceMode ifFalse: [
		super addModelYellowButtonMenuItemsTo: aCustomMenu forMorph: aMorph hand: aHandMorph].
	^ aCustomMenu
]

{ #category : #compilation }
MorphicModel >> addPartNameLike: className withValue: aMorph [
	| otherNames i default partName stem |
	stem := className first asLowercase asString , className allButFirst.
	otherNames := self class allInstVarNames.
	i := 1.
	[otherNames includes: (default := stem, i printString)]
		whileTrue: [i := i + 1].
	partName := UIManager default
		request: 'Please give this part a name'
		initialAnswer: default.
	(otherNames includes: partName)
		ifTrue: [self inform: 'Sorry, that name is already used'. ^ nil].
	self class addInstVarName: partName.
	self instVarAt: self class instSize put: aMorph.  "Assumes added as last field"
	^ partName
]

{ #category : #'submorphs-accessing' }
MorphicModel >> allKnownNames [
	"Return a list of all known names based on the scope of the receiver.  If the receiver is a member of a uniclass, incorporate the original 1997 logic that queries the known names of the values of all the instance variables."

	| superNames |
	superNames := super allKnownNames.	"gather them from submorph tree"
	^self belongsToUniClass 
		ifTrue: 
			[superNames , (self instanceVariableValues 
						select: [:e | e notNil and: [e knownName notNil]]
						thenCollect: [:e | e knownName])]
		ifFalse: [superNames]
]

{ #category : #'drag and drop' }
MorphicModel >> allowSubmorphExtraction [
	^ self isOpen

]

{ #category : #geometry }
MorphicModel >> charactersOccluded [
	"Subclasses override as necessary to keep smart-splitters balanced."
	^ 0
]

{ #category : #naming }
MorphicModel >> choosePartName [
	"When I am renamed, get a slot, make default methods, move any existing methods.  ** Does not clean up old inst var name or methods**  "

	| old |
	old := slotName.
	super choosePartName.
	slotName ifNil: [^self].	"user chose bad slot name"
	self model: self world model slotName: slotName.
	old isNil
		ifTrue: [self compilePropagationMethods]
		ifFalse: [self copySlotMethodsFrom: old]
	"old ones not erased!"
]

{ #category : #menu }
MorphicModel >> closeToEdits [
	"Disable this morph's ability to add and remove morphs via drag-n-drop."

	open := false

]

{ #category : #compilation }
MorphicModel >> compileAccessForSlot: aSlotName [
	"Write the method to get at this inst var.  "
	"Instead call the right thing to make this happen?"

	| s  |
	s := WriteStream on: (String new: 2000).
	s nextPutAll: aSlotName; cr; tab; nextPutAll: '^', aSlotName.
	self class
		compile: s contents
		classified: 'public access'
		notifying: nil.

]

{ #category : #compilation }
MorphicModel >> compilePropagationMethods [
	
	(self class organization listAtCategoryNamed: 'private - propagation' asSymbol)
		do: [:sel | | varName |
			varName := sel allButLast.
			model class compilePropagationForVarName: varName slotName: slotName]
]

{ #category : #initialization }
MorphicModel >> defaultBorderColor [
	"answer the default border color/fill style for the receiver"
	^ Color yellow
]

{ #category : #initialization }
MorphicModel >> defaultBounds [
"answer the default bounds for the receiver"
	^ 0 @ 0 corner: 200 @ 100
]

{ #category : #initialization }
MorphicModel >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color transparent
]

{ #category : #'submorphs-add\/remove' }
MorphicModel >> delete [
	(model isMorphicModel) ifFalse: [^super delete].
	slotName ifNotNil: 
			[(UIManager default confirm: 'Shall I remove the slot ' , slotName 
						, '
along with all associated methods?') 
				ifTrue: 
					[(model class selectors select: [:s | s beginsWith: slotName]) 
						do: [:s | model class removeSelector: s].
					(model class instVarNames includes: slotName) 
						ifTrue: [model class removeInstVarName: slotName]]
				ifFalse: 
					[(UIManager default 
						confirm: '...but should I at least dismiss this morph?
[choose no to leave everything unchanged]') 
							ifFalse: [^self]]].
	super delete
]

{ #category : #initialization }
MorphicModel >> duplicate: newGuy from: oldGuy [
	"oldGuy has just been duplicated and will stay in this world.  Make sure all the MorphicModel requirements are carried out for the copy.  Ask user to rename it.  "

	newGuy installModelIn: oldGuy world.
	newGuy copySlotMethodsFrom: oldGuy slotName.
]

{ #category : #printing }
MorphicModel >> initString [

	^ String streamContents:
		[:s | s nextPutAll: self class name;
			nextPutAll: ' newBounds: (';
			print: bounds;
			nextPutAll: ') model: self slotName: ';
			print: slotName]
]

{ #category : #initialization }
MorphicModel >> initialize [
	"initialize the state of the receiver"
	super initialize.
""
	open := false
]

{ #category : #'debug and other' }
MorphicModel >> installModelIn: aWorld [

	self wantsSlot ifFalse: [^ self].  "No real need to install"
	slotName := aWorld model addPartNameLike: self class name withValue: self.
	slotName ifNil: [^ self].  "user chose bad slot name"
	self model: aWorld model slotName: slotName.
	self compilePropagationMethods.
	aWorld model compileAccessForSlot: slotName.

]

{ #category : #classification }
MorphicModel >> isMorphicModel [
	^true
]

{ #category : #'drag and drop' }
MorphicModel >> isOpen [
	"Support drag/drop and other edits."
	^ open
]

{ #category : #accessing }
MorphicModel >> model [ 
	^ model
]

{ #category : #initialization }
MorphicModel >> model: anObject [
	"Set my model and make me me a dependent of the given object."

	model ifNotNil: [model removeDependent: self].
	anObject ifNotNil: [anObject addDependent: self].
	model := anObject.

]

{ #category : #initialization }
MorphicModel >> model: thang slotName: nameOfThisPart [
	model := thang.
	slotName := nameOfThisPart.
	open := false.
]

{ #category : #accessing }
MorphicModel >> modelOrNil [
	^ model
]

{ #category : #compilation }
MorphicModel >> nameFor: aMorph [
	"Return the name of the slot containing the given morph or nil if that morph has not been named."

	| allNames start |
	allNames := self class allInstVarNames.
	start := MorphicModel allInstVarNames size + 1.
	start to: allNames size do: [:i |
		(self instVarAt: i) == aMorph ifTrue: [^ allNames at: i]].
	^ nil

]

{ #category : #geometry }
MorphicModel >> newBounds: newBounds [
	self bounds: newBounds
]

{ #category : #menu }
MorphicModel >> openToEdits [
	"Enable this morph's ability to add and remove morphs via drag-n-drop."

	open := true

]

{ #category : #compilation }
MorphicModel >> propagate: value as: partStoreSelector [
	model ifNil: [^ self].
"
	Later we can cache this for more speed as follows...
	(partName == cachedPartName and: [slotName == cachedSlotName])
		ifFalse: [cachedPartName := partName.
				cachedSlotName := slotName.
				cachedStoreSelector := (slotName , partStoreSelector) asSymbol].
	model perform: cachedStoreSelector with: value].
"
	model perform: (self slotSelectorFor: partStoreSelector) with: value
]

{ #category : #geometry }
MorphicModel >> recomputeBounds [

	| bnds |
	bnds := submorphs first bounds.
	bounds := bnds origin corner: bnds corner. "copy it!"
	fullBounds := nil.
	bounds := self fullBounds.

]

{ #category : #caching }
MorphicModel >> releaseCachedState [
	"Release cached state of the receiver"

	(model ~~ self and: [model respondsTo: #releaseCachedState]) ifTrue:
		[model releaseCachedState].
	super releaseCachedState
]

{ #category : #compilation }
MorphicModel >> removeAll [
	"Clear out all script methods and subpart instance variables in me.  Start over."
	"self removeAll"
	"MorphicModel2 removeAll"

self class == MorphicModel ifTrue: [^ self].	"Must be a subclass!"
self class removeCategory: 'scripts'.
self class instVarNames do: [:nn | self class removeInstVarName: nn].
]

{ #category : #accessing }
MorphicModel >> slotName [
	^ slotName
]

{ #category : #compilation }
MorphicModel >> slotSelectorFor: selectorBody [
	| selector |
	model ifNil: [^ nil].
	"Make up selector from slotname if any"
	selector := (slotName ifNil: [selectorBody]
					ifNotNil: [slotName , selectorBody]) asSymbol.
	(model canUnderstand: selector) ifFalse:
		[self halt: 'Compiling a null response for ' , model class name , '>>' , selector].
	^ selector
]

{ #category : #compilation }
MorphicModel >> use: cachedSelector orMakeModelSelectorFor: selectorBody in: selectorBlock [
	| selector |
	model ifNil: [^ nil].
	cachedSelector ifNil:
			["Make up selector from slotname if any"
			selector := (slotName ifNil: [selectorBody]
								ifNotNil: [slotName , selectorBody]) asSymbol.
			(model class canUnderstand: selector) ifFalse:
				[(self confirm: 'Shall I compile a null response for'
							, Character cr asString
							, model class name , '>>' , selector)
						ifFalse: [self halt].
				model class compile: (String streamContents:
								[:s | selector keywords doWithIndex:
										[:k :i | s nextPutAll: k , ' arg' , i printString].
								s cr; nextPutAll: '"Automatically generated null response."'.
								s cr; nextPutAll: '"Add code below for appropriate behavior..."'.])
							classified: 'input events'
							notifying: nil]]
		ifNotNil:
			[selector := cachedSelector].
	^ selectorBlock value: selector
]

{ #category : #accessing }
MorphicModel >> wantsSlot [
	"Override this default for models that want to be installed in theri model"
	^ false
]
