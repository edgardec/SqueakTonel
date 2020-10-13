Class {
	#name : #KedamaExamplerPlayer,
	#superclass : #Player,
	#instVars : [
		'kedamaWorld',
		'turtles',
		'sequentialStub'
	],
	#category : #'Etoys-StarSqueak'
}

{ #category : #compiling }
KedamaExamplerPlayer class >> isUniClass [

	^ self ~~ self officialClass
]

{ #category : #all }
KedamaExamplerPlayer class >> officialClass [

	^ KedamaExamplerPlayer
]

{ #category : #compiling }
KedamaExamplerPlayer class >> wantsChangeSetLogging [
	"Log changes for Player itself, but not for automatically-created subclasses like Player1, Player2, but *do* log it for uniclasses that have been manually renamed."

	^ (self == KedamaExamplerPlayer or:
		[(self name beginsWith: 'KedamaExamplerPlayer') not]) or:
			[Preferences universalTiles]
]

{ #category : #'method management' }
KedamaExamplerPlayer >> acceptScript: aScriptEditorMorph for: aSelector [
	"Accept the tile code in the script editor as the code for the given selector.  This branch is only for the classic-tile system, 1997-2001"
	| aUniclassScript str node |
	(aScriptEditorMorph generateParseNodeDirectly and: [(node := aScriptEditorMorph methodNode) notNil]) ifTrue: [
		str := node printString.
		self class compileSilently: str classified: 'scripts' for: self.
		turtles class compileSilently: str classified: 'scripts' for: self.
		sequentialStub class compileSilently: str classified: 'scripts' for: self.
	] ifFalse: [
		str := aScriptEditorMorph methodString.
		self class compileSilently: str classified: 'scripts' for: self.
		turtles class compileSilently: str classified: 'scripts' for: self.
		sequentialStub class compileSilently: str classified: 'scripts' for: self.
	].
	aUniclassScript := self class assuredMethodInterfaceFor: aSelector asSymbol.
	aUniclassScript currentScriptEditor: aScriptEditorMorph.
	aScriptEditorMorph world ifNotNil: [aScriptEditorMorph world removeHighlightFeedback].

]

{ #category : #'player protocol' }
KedamaExamplerPlayer >> addInstanceVarNamed: aName withValue: aValue [

	self basicAddInstanceVarNamed: aName withValue: aValue.
	"turtles := kedamaWorld turtlesOf: self."
	turtles addInstanceVarNamed: aName withValue: aValue.

]

{ #category : #'player protocol' }
KedamaExamplerPlayer >> chooseSlotTypeFor: aGetter [
	"Let the user designate a type for the slot associated with the given getter"

	| typeChoices typeChosen slotName |
	slotName := aGetter inherentSelector.
	typeChoices := Vocabulary typeChoices.

	typeChosen := UIManager default chooseFrom: (typeChoices collect: [:t | t translated])values: typeChoices title: 
		('Choose the TYPE
for ' translated, slotName, '
(currently ' translated, (self slotInfoAt: slotName) type translated, ')').
	typeChosen isEmptyOrNil ifTrue: [^ self].
	(self typeForSlot: slotName) capitalized = typeChosen ifTrue: [^ self].

	(self slotInfoAt: slotName) type: typeChosen.
	self class allInstancesDo:   "allSubInstancesDo:"
		[:anInst | anInst instVarNamed: slotName asString put: 
			(anInst valueOfType: typeChosen from: (anInst instVarNamed: slotName))].
	turtles setVectorSlotTypeFor: slotName typeChosen: typeChosen.
	sequentialStub ifNotNil: [sequentialStub setScalarSlotTypeFor: slotName typeChosen: typeChosen].
	self updateAllViewers.	"does siblings too"

]

{ #category : #'subclass players management' }
KedamaExamplerPlayer >> clonedSequentialStub [

	^sequentialStub shallowCopy
]

{ #category : #'player commands' }
KedamaExamplerPlayer >> colorFromPatch: aPatch [

]

{ #category : #'player commands' }
KedamaExamplerPlayer >> colorToPatch: aPatch [

]

{ #category : #'method management' }
KedamaExamplerPlayer >> compileInstVarAccessorsFor: varName [

	self basicCompileInstVarAccessorsFor: varName.
	"turtles := kedamaWorld turtlesOf: self."
	turtles compileVectorInstVarAccessorsFor: varName.
	sequentialStub compileScalarInstVarAccessorsFor: varName.

]

{ #category : #'subclass players management' }
KedamaExamplerPlayer >> createSequenceStub [

	| class |
	class := self class createSequencialStubSubclass.
	sequentialStub := class new.
	sequentialStub kedamaWorld: kedamaWorld.
	sequentialStub examplerPlayer: self.
	sequentialStub turtles: turtles.

]

{ #category : #deleting }
KedamaExamplerPlayer >> delete [

	turtles delete.
	sequentialStub delete.

	self class removeFromSystem: false.

	self becomeForward: UnscriptedPlayer new

]

{ #category : #'command execution' }
KedamaExamplerPlayer >> doCommand: aBlock [

	| ret |
	ret := self doExamplerCommand: aBlock.
	turtles ifNotNil: [aBlock value: turtles].

	^ ret.

]

{ #category : #'command execution' }
KedamaExamplerPlayer >> doDieCommand: aBlock [

	| ret origSize |
	ret := self doExamplerCommand: aBlock.
	turtles initializeDeletingIndex.
	origSize := turtles size.
	1 to: origSize do: [:i |
		i > origSize ifTrue: [^ ret].
		sequentialStub index: (turtles nextDeletingIndex).
		aBlock value: sequentialStub.
	].

	^ ret.


]

{ #category : #'command execution' }
KedamaExamplerPlayer >> doExamplerCommand: aBlock [

	 "^ aBlock value: self."
]

{ #category : #'command execution' }
KedamaExamplerPlayer >> doSequentialCommand: aBlock [

	| ret pred |
	ret := self doExamplerCommand: aBlock.
	self getGrouped ifFalse: [
		pred := turtles arrays at: 7.
		1 to: turtles size do: [:i |
			(pred at: i) = 1 ifTrue: [
				sequentialStub index: i.
				aBlock value: sequentialStub.
			].
		].
	] ifTrue: [
		aBlock value: turtles.
	].
	turtles invalidateTurtleMap.
	^ ret.


]

{ #category : #'player commands' }
KedamaExamplerPlayer >> getBlueComponentIn: aPatch [

	^ 0.

]

{ #category : #'slot-accessing' }
KedamaExamplerPlayer >> getColorOpaque [

	^ self getColor.

]

{ #category : #'player commands' }
KedamaExamplerPlayer >> getGreenComponentIn: aPatch [

	^ 0.

]

{ #category : #'slot-accessing' }
KedamaExamplerPlayer >> getNormal [

	^ 0.0.

]

{ #category : #'player commands' }
KedamaExamplerPlayer >> getRedComponentIn: aPatch [

	^ 0.

]

{ #category : #'player commands' }
KedamaExamplerPlayer >> getTurtleAt: aPlayer [

	^ turtles getTurtleAt: aPlayer.


]

{ #category : #'player commands' }
KedamaExamplerPlayer >> getTurtleOf: aBreedPlayer [

	^ self.


]

{ #category : #'slot-accessing' }
KedamaExamplerPlayer >> getVisible [

	^ self costume renderedMorph visible

]

{ #category : #'slot-accessing' }
KedamaExamplerPlayer >> getWho [

	^ 1.

]

{ #category : #'slot getters\/setters' }
KedamaExamplerPlayer >> getXAndY [

	^ self turtles getXAndY
]

{ #category : #testing }
KedamaExamplerPlayer >> isPrototypeTurtlePlayer [

	^ true.

]

{ #category : #accessing }
KedamaExamplerPlayer >> kedamaWorld [

	^ kedamaWorld.

]

{ #category : #accessing }
KedamaExamplerPlayer >> kedamaWorld: k [

	kedamaWorld := k.

]

{ #category : #accessing }
KedamaExamplerPlayer >> nearestIDFor: aNumber [

	| whoArray last next smaller bigger |
	whoArray := turtles arrays first.
	whoArray isEmpty ifTrue: [^ nil].
	aNumber < whoArray first ifTrue: [^ whoArray first].

	last := whoArray at: 1.
	2 to: whoArray size do: [:i |
		(last <= aNumber and: [aNumber < (next := whoArray at: i)]) ifTrue: [
			smaller := last.
			bigger := next.
			(smaller - aNumber) abs <= (bigger - aNumber) abs ifTrue: [^ smaller] ifFalse: [^ bigger].
		].
		last := next.
	].
	^ last.

]

{ #category : #'method management' }
KedamaExamplerPlayer >> recompileAccessorsOf: oldSlotName to: newSlotName inPlayer: aPlayer [
	"Note that aPlayer has renamed a slot formerly known as oldSlotName to be newSlotName"

	self isPrototypeTurtlePlayer ifTrue: [
		sequentialStub ifNotNil: [sequentialStub noteRenameOf: oldSlotName to: newSlotName inPlayer: aPlayer].
		turtles noteRenameOf: oldSlotName to: newSlotName inPlayer: aPlayer.
	].

]

{ #category : #'player protocol' }
KedamaExamplerPlayer >> removeSlotNamed: aSlotName [

	self basicRemoveSlotNamed: aSlotName.
	turtles removeVectorSlotNamed: aSlotName.
	sequentialStub removeSlotNamed: aSlotName.

]

{ #category : #'player protocol' }
KedamaExamplerPlayer >> renameSlot: oldSlotName newSlotName: newSlotName [

	self basicRenameSlot: oldSlotName newSlotName: newSlotName.
	turtles renameVectorSlot: oldSlotName newSlotName: newSlotName.
	self recompileAccessorsOf: oldSlotName to: newSlotName inPlayer: self.

]

{ #category : #'slot-accessing' }
KedamaExamplerPlayer >> setHeading: degree [


]

{ #category : #'slot-accessing' }
KedamaExamplerPlayer >> setNormal: degree [


]

{ #category : #'slot-accessing' }
KedamaExamplerPlayer >> setTurtleCount: aNumber [

	"self allOpenViewers do: [:v | v resetWhoIfNecessary]."
	super setCostumeSlot: #turtleCount: toValue: aNumber.

]

{ #category : #'slot-accessing' }
KedamaExamplerPlayer >> turn: degree [


]

{ #category : #'subclass players management' }
KedamaExamplerPlayer >> turtles [

	^ turtles.

]

{ #category : #copying }
KedamaExamplerPlayer >> veryDeepInner: deepCopier [
	"Special code that handles user-added instance variables of a uniClass.
	Copy all of my instance variables.  Some need to be not copied at all, but shared.  This is special code for the dictionary.  See DeepCopier."

	kedamaWorld := kedamaWorld veryDeepCopyWith: deepCopier.
	turtles := turtles veryDeepCopyWith: deepCopier.
	sequentialStub := sequentialStub veryDeepCopyWith: deepCopier.
	super veryDeepInner: deepCopier.

]

{ #category : #accessing }
KedamaExamplerPlayer >> whoAt: index [

	| whoArray |
	whoArray := turtles arrays first.
	index < 1 ifTrue: [^ 0].
	index > whoArray size ifTrue: [^ 0].

	^ whoArray at: index.

]
