"
The fundamental user-scriptable entity.  Always represented by a user-specific subclass of Player; instance vars and methods relate to user-defined structures.

costume  is a Morph, the primary morph I am currently wearing for graphical display.

Scripts are defined in subclasses of Player.  These are UniClasses.

Messages in scripts are sent to Players.  A Player may delegate to its costume, or to an object the costume suggests.  Or, a Player may designate some other object to receive the script messages it does not understand. (see doesNotUnderstand:) 
"
Class {
	#name : #Player,
	#superclass : #Model,
	#instVars : [
		'costume',
		'costumes'
	],
	#classVars : [
		'BiggestSubclassNumber',
		'TimeOfError'
	],
	#pools : [
		'References'
	],
	#classInstVars : [
		'scripts',
		'slotInfo',
		'variableDocks'
	],
	#category : #'Etoys-Scripting'
}

{ #category : #other }
Player class >> abandonOldReferenceScheme [
	"Abandon the old reference scheme"

	"(ActiveWorld presenter allExtantPlayers collect:
		[:aPlayer | aPlayer class]) asSet do:
			[:aPlayerClass | aPlayerClass abandonOldReferenceScheme]"

	self isUniClass ifTrue:
		[self userScriptsDo:
			[:aScript | aScript recompileScriptFromTilesUnlessTextuallyCoded].
		self class selectors do:
			[:sel | self class removeSelector: sel].
		self class instVarNames do:
			[:aName | self class removeInstVarName: aName].
		self organization removeEmptyCategories.
		self class organization removeEmptyCategories]
]

{ #category : #housekeeping }
Player class >> abandonUnnecessaryUniclasses [
	"Player abandonUnnecessaryUniclasses"
	| oldCount oldFree newFree newCount report |
	oldCount := self subclasses size - 1.
	oldFree := Smalltalk garbageCollect.
	self allSubInstances do:
		[:aPlayer | aPlayer revertToUnscriptedPlayerIfAppropriate].

	ScriptingSystem spaceReclaimed.
	newFree := Smalltalk garbageCollect.
	newCount := self subclasses size - 1.
	report := 'Before: ', oldCount printString, ' uniclasses, ', oldFree
printString, ' bytes free
After:  ', newCount printString, ' uniclasses, ', newFree printString, '
bytes free'.
	Transcript cr; show: 'abandonUnnecessaryUniclasses:'; cr; show: report.
	^ report
	
]

{ #category : #'user-scripted subclasses' }
Player class >> addDocumentationForScriptsTo: aStream [
	"Add documentation for every script in the receiver to the stream"

	self scripts do:
		[:aScript |
			aScript selector ifNotNil:
				[aStream cr; cr.
				aStream nextPutAll: self typicalInstanceName, '.'.
				self printMethodChunk: aScript selector withPreamble: false on: aStream moveSource: false toFile: nil.
				aStream position: (aStream position - 2)]].
	self scripts size = 0 ifTrue:
		[aStream cr; tab; nextPutAll: 'has no scripts']
]

{ #category : #organization }
Player class >> addInstVarName: aString [

	^(ClassBuilder new)
		name: self name
		inEnvironment: (self environment import: Smalltalk globals)
		subclassOf: self superclass
		type: self typeOfClass
		instanceVariableNames: self instanceVariablesString, ' ', aString
		classVariableNames: self classVariablesString
		poolDictionaries: self sharedPoolsString
		category: self category

]

{ #category : #'user-scripted subclasses' }
Player class >> addMethodReferencesTo: aCollection [
	"For each extant script in the receiver, add a MethodReference object"

	
	self scripts do:
		[:aScript | | sel |
			(sel := aScript selector) ifNotNil:
				[aCollection add: (MethodReference class: self selector: sel)]]
]

{ #category : #scripts }
Player class >> assuredMethodInterfaceFor: aSelector [
	"Answer the method interface object for aSelector, creating it if it does not already exist."

	| selSym  aMethodInterface |
	selSym := aSelector asSymbol.
	aMethodInterface := self scripts at: selSym ifAbsentPut: 
		[self nascentUserScriptInstance playerClass: self selector: selSym].
	
	^ aMethodInterface
]

{ #category : #scripts }
Player class >> atSelector: aSelector putScript: aMethodWithInterface [
	"Place the given method interface in my directory of scripts, at the given selector"

	self scripts at: aSelector asSymbol put: aMethodWithInterface
]

{ #category : #'user-scripted subclasses' }
Player class >> baseUniclass [
	"Answer the uniclass that new instances should be instances of; this protocol allows for individual cards of a background to have their own class"

	| curr |
	curr := self.
	[curr theNonMetaClass superclass name endsWithDigit]
		whileTrue:
			[curr := curr superclass].
	^ curr

"CardPlayer100 baseUniclass 
CardPlayer100X baseUniclass
"
]

{ #category : #scripts }
Player class >> bringScriptsUpToDate [
	"Bring all the receiver's scripts up to date, after, for example, a name change"

	self scripts do:
		[:aUniclassScript |
			aUniclassScript bringUpToDate.
			aUniclassScript recompileScriptFromTilesUnlessTextuallyCoded]
]

{ #category : #other }
Player class >> chooseUniqueClassName [
	| ii className |
	ii := BiggestSubclassNumber ifNil: [1] ifNotNil: [BiggestSubclassNumber+1].
	[className := (self name , ii printString) asSymbol.
	 Smalltalk includesKey: className]
		whileTrue: [ii := ii + 1].
	BiggestSubclassNumber := ii.
	^ className	


]

{ #category : #other }
Player class >> chooseUniqueTurtleClassName [
	| ii className |
	className := self name.
	[className last isDigit] whileTrue: [className := className copyFrom: 1 to: className size - 1].

	ii := BiggestSubclassNumber ifNil: [1] ifNotNil: [BiggestSubclassNumber+1].
	[className := (className , ii printString) asSymbol.
	 Smalltalk includesKey: className]
		whileTrue: [ii := ii + 1].
	BiggestSubclassNumber := ii.
	^ className	


]

{ #category : #housekeeping }
Player class >> cleanUp: aggressive [
	"Nuke uni-classes when aggressively cleaning up"
	aggressive ifTrue:[
		self withAllSubclassesDo:[:aClass|
			aClass isUniClass ifTrue:[Smalltalk removeClassNamed: aClass name].
		].
	].
]

{ #category : #housekeeping }
Player class >> cleanseScripts [
	"Fix up various known structure errors in the uniclass relating to the scripts dctionary.  Answer the number of fixes made."

	| errs |
	scripts ifNil: [scripts := IdentityDictionary new].
	errs := 0.
	(scripts includesKey: nil) ifTrue: [errs := errs + 1.  scripts removeKey: nil].
	scripts keysAndValuesDo: 
		[:sel :uniclassScript | | ed |
			uniclassScript
				ifNil:
					[errs := errs + 1.
					Transcript cr; show: ' fix type 1, nil scripts key'.
					scripts removeKey: sel]
				ifNotNil:
					[(ed := uniclassScript currentScriptEditor)
						ifNil:
							[errs := errs + 1.
							Transcript cr; show: ' fix type 2, sel = ', sel.
							self someInstance removeScriptWithSelector: uniclassScript selector.]
						ifNotNil:
							[uniclassScript playerClassPerSe
								ifNil:
									[errs := errs + 1.
									Transcript cr; show: ' fix type 3, sel = ', sel.
									uniclassScript playerClass: self selector:  sel]
								ifNotNil:
									[(ed scriptName ~= uniclassScript selector) ifTrue:
										[errs := errs + 1.
										ed restoreScriptName: sel.
										Transcript cr; show: ' fix type 4, sel = ', sel.]]]]].
	^ errs
]

{ #category : #housekeeping }
Player class >> cleanseScriptsOfNilKeys [
	"If, owing to an earlier bug, the receiver's scripts dictionary has a nil key, remove that offender before he causes more trouble"

	scripts ifNotNil:
		[scripts removeKey: nil ifAbsent: []]
]

{ #category : #housekeeping }
Player class >> cleanseSlotInfo [
	| newInfo |
	slotInfo ifNotNil:
		[newInfo := IdentityDictionary new.
		slotInfo associationsDo:
			[:assoc | newInfo at: assoc key asSymbol put: assoc value].
		slotInfo := newInfo]

]

{ #category : #slots }
Player class >> compileAccessorsFor: varName [
	^ self compileInstVarAccessorsFor: varName
]

{ #category : #slots }
Player class >> compileInstVarAccessorsFor: varName [
	"Compile getters and setteres for the given instance variable name"

	| nameString |
	nameString := varName asString capitalized.
	self compileSilently: ('get{1}
	^ {2}' format: {nameString. varName})
		classified: 'access'.
	self compileSilently: ('set{1}: a{1}
	{2} := a{1}' format: {nameString. varName})
		classified: 'access'
]

{ #category : #namespace }
Player class >> compileReferenceAccessorFor: varName [
	"Compile reference accessors for the given variable.  If the #capitalizedReferences preference is true, then nothing is done here"

	Preferences capitalizedReferences ifTrue: [^ self].

	self class compileSilently: ((self referenceAccessorSelectorFor: varName), '
	^ ', varName)
		classified: 'reference'
]

{ #category : #compiling }
Player class >> compilerClass [

	^ ScriptCompiler
]

{ #category : #turtles }
Player class >> createSequencialStubSubclass [

	^ KedamaSequenceExecutionStub newUniqueClassInstVars: '' classInstVars: ''.

]

{ #category : #organization }
Player class >> environment [
	"If there are uniclasses of Player that do not have their custom environment set, create a new one on the fly. Can be removed in the future. See Class >> #newSubclass or the flag #uniclasses."
	
	^ (self isUniClass and: [super environment == Environment default])
		ifTrue: [self newEnvironment]
		ifFalse: [super environment]
]

{ #category : #housekeeping }
Player class >> freeUnreferencedSubclasses [
	"Player classes may hold in their class instance variables references
to instances of themselves that are housekeepingwise unreachable. This
method allows such loops to be garbage collected. This is done in three
steps:
	1. Remove user-created subclasses from the 'subclasses' set and from
Smalltalk. Only remove classes whose name begins with 'Player' and which
have no references.
	2. Do a full garbage collection.
	3. Enumerate all Metaclasses and find those whose soleInstance's
superclass is this class. Reset the subclasses set to this set of
classes, and add back to Smalltalk."
	"Player freeUnreferencedSubclasses"

	| oldFree candidatesForRemoval class |
	oldFree := Smalltalk garbageCollect.
	candidatesForRemoval := self subclasses asOrderedCollection select:
		[:aClass | (aClass name beginsWith: 'Player') and: [aClass name
endsWithDigit]].

	"Break all system links and then perform garbage collection."
	candidatesForRemoval do:
		[:c | self removeSubclass: c.  "Break downward subclass pointers."
		Smalltalk globals removeKey: c name ifAbsent: [].  "Break binding of global
name"].
	candidatesForRemoval := nil.
	Smalltalk garbageCollect.  "Now this should reclaim all unused
subclasses"

	"Now reconstruct system links to subclasses with valid references."
	"First restore any global references via associations"
	(Association allSubInstances select:
			[:assn | (assn key isSymbol)
					and: [(assn key beginsWith: 'Player')
					and: [assn key endsWithDigit]]])
		do: [:assn | class := assn value.
			(class isKindOf: self class) ifTrue:
				[self addSubclass: class.
				Smalltalk add: assn]].
	"Then restore any further direct references, creating new
associations."
	(Metaclass allInstances select:
			[:m | (m soleInstance name beginsWith: 'Player')
					and: [m soleInstance name endsWithDigit]])
		do: [:m | class := m soleInstance.
			((class isKindOf: self class) and: [(Smalltalk includesKey: class
name) not]) ifTrue:
				[self addSubclass: class.
				Smalltalk at: class name put: class]].
	SystemOrganization removeMissingClasses.
	^ Smalltalk garbageCollect - oldFree

]

{ #category : #'user-scripted subclasses' }
Player class >> initialInstance [
	self == Player ifTrue: [self error: 'must not instantiate naked Player'].
	^ super initialInstance
]

{ #category : #other }
Player class >> isSystemDefined [
	^ name endsWithDigit not
]

{ #category : #housekeeping }
Player class >> isUniClass [
	"UnscriptedPlayer reimplements to false"

	^ self ~~ Player
]

{ #category : #scripts }
Player class >> jettisonScripts [
	scripts := IdentityDictionary new
]

{ #category : #namespace }
Player class >> makeReferenceFor: anObject [

	| stem otherNames i partName |
	stem := anObject class name.
	(stem size > 5 and: [stem endsWith: 'Morph'])
		ifTrue: [stem := stem copyFrom: 1 to: stem size - 5].
	stem := stem first asLowercase asString, stem allButFirst.
	otherNames := self class allInstVarNames.
	i := 1.
	[otherNames includes: (partName := stem, i printString)]
		whileTrue: [i := i + 1].
	self class addInstVarName: partName.
	self instVarAt: self class instSize put: anObject.  "assumes added as last field"

	self compileReferenceAccessorFor: partName.
	^ self referenceAccessorSelectorFor: partName
]

{ #category : #other }
Player class >> nameForViewer [
	"Answer the name by which the receiver is to be referred in a viewer"

	^ self isUniClass
		ifTrue:
			[self someInstance getName]
		ifFalse:
			[super nameForViewer]
]

{ #category : #scripts }
Player class >> namedTileScriptSelectors [
	"Answer a list of all the selectors of named tile scripts"

	scripts ifNil: [^ OrderedCollection new].
	^ scripts select: [:aScript | aScript selector ~~ nil] 
		thenCollect: [:aScript | aScript selector]
]

{ #category : #scripts }
Player class >> namedUnaryTileScriptSelectors [
	"Answer a list of all the selectors of named unary tile scripts"

	
	scripts ifNil: [^ OrderedCollection new].
	^ scripts select: [:aScript | | sel | (sel := aScript selector) notNil and: [sel numArgs = 0]] 
		thenCollect: [:aScript | aScript selector]
]

{ #category : #scripts }
Player class >> nascentUserScriptInstance [
	"Answer a new script object of the appropriate class"

	| classToUse |
	classToUse := Preferences universalTiles
		ifTrue:	[MethodWithInterface]
		ifFalse:	[UniclassScript].
	^ classToUse new
]

{ #category : #'variable docks' }
Player class >> newVariableDocks: dockList [
	"Set the receiver's variableDocks to be the list provided in dockList.  Assimilate this new information into the receiver's slotInfo, which contains both automatically-generated variables such as the variable docks and also explicitly-user-specified variables"

	self variableDocks: dockList.
	self setSlotInfoFromVariableDocks
]

{ #category : #other }
Player class >> officialClass [
	"We want to make a new instance of the receiver, which is a subclass of Player.  Answer who to make a new subclass of.  Also used to tell if a given class is a UniClass, existing only for its single instance."
	^ Player
]

{ #category : #scripts }
Player class >> permanentUserScriptFor: aSelector player: aPlayer [
	"Create and answer a suitable script  object for the given player (who will be an instance of the receiver) and selector.  Save that script-interface object in my (i.e. the class's) directory of scripts"

	|  entry |
	scripts ifNil: [scripts := IdentityDictionary new].
	entry := self nascentUserScriptInstance playerClass: aPlayer class selector: aSelector.
	scripts at: aSelector put: entry.
	^ entry
]

{ #category : #housekeeping }
Player class >> playersWithUnnecessarySubclasses [
	"Return a list of all players whose scripts dictionaries contain entries with nil selectors"
	"Player playersWithUnnecessarySubclasses size"
	^ self withAllSubclasses select:
		[:p | p class isSystemDefined not and: [p scripts size = 0 and: [p instVarNames size = 0]]] 
]

{ #category : #scripts }
Player class >> privateScripts [
	"for copying"
	^ scripts
]

{ #category : #slots }
Player class >> privateSlotInfo [
	"for copying"
	^ slotInfo
]

{ #category : #namespace }
Player class >> referenceAccessorSelectorFor: varName [
	^ 'ref', (varName asString capitalized)
]

{ #category : #namespace }
Player class >> referenceSelectorFor: anObject [
	self class instVarNames do:  "Just those added in the unique subclass"
		[:aName | (self instVarNamed: aName) == anObject
			ifTrue:
				[^ self referenceAccessorSelectorFor: aName]].
	^ self makeReferenceFor: anObject
]

{ #category : #slots }
Player class >> removeAccessorsFor: varName [
	^ self removeInstVarAccessorsFor: varName
]

{ #category : #slots }
Player class >> removeInstVarAccessorsFor: varName [
	| nameString |

	nameString := varName asString capitalized.
	self removeSelector: ('get', nameString) asSymbol.
	self removeSelector: ('set', nameString, ':') asSymbol
]

{ #category : #slots }
Player class >> removeInstVarName: aName [
	self removeInstVarAccessorsFor: aName.
	super removeInstVarName: aName.
	self slotInfo removeKey: aName asSymbol ifAbsent: []
]

{ #category : #scripts }
Player class >> removeScriptNamed: aScriptName [
	aScriptName ifNotNil:
		[scripts removeKey: aScriptName.
		self removeSelectorSilently: aScriptName]
]

{ #category : #housekeeping }
Player class >> removeUninstantiatedSubclassesSilently [
	"Remove the classes of any subclasses that have neither instances nor subclasses.  Answer the number of bytes reclaimed"
	"Player removeUninstantiatedSubclassesSilently"

	| oldFree |
	oldFree := Smalltalk garbageCollect.
		
	self allSubclasses
		select: [:c | (c isSystemDefined not and: [c instanceCount = 0]) and: [c subclasses isEmpty]]
		thenDo: [:c | c removeFromSystemUnlogged].
		
	^ Smalltalk garbageCollect - oldFree
]

{ #category : #slots }
Player class >> renameSilentlyInstVar: oldName to: newName [
	(instanceVariables includes: oldName asString) ifFalse:
		[self error: oldName , ' is not defined in ', self name].
	self removeAccessorsFor: oldName.

	super renameSilentlyInstVar: oldName to: newName.
	self compileAccessorsFor: newName.
	slotInfo at: newName asSymbol put: (slotInfo at: oldName).
	slotInfo removeKey: oldName
]

{ #category : #'user-defined inst vars' }
Player class >> resortInstanceVariables: newList [
	"Accept a new ordering for instance variables"

	variableDocks := newList collect: [:aName | variableDocks detect: [:d | d variableName = aName]].
	self setNewInstVarNames: newList asOrderedCollection.
	self newVariableDocks: variableDocks.

]

{ #category : #scripts }
Player class >> scripts [
	"Answer the receiver's scripts -- an IdentityDictionary"

	scripts
		ifNil:
			[scripts := IdentityDictionary new]
		ifNotNil:
			[self cleanseScriptsOfNilKeys].
	^ scripts
]

{ #category : #scripts }
Player class >> scripts: aDict [
	"for copying"
	scripts := aDict
]

{ #category : #'user-defined inst vars' }
Player class >> setNewInstVarNames: listOfStrings [
	"Make listOfStrings be the new list of instance variable names for the receiver"

	| disappearing firstAppearing instVarString instVarList |
	instVarList := self instVarNames asOrderedCollection.
	disappearing := instVarList copy.
	disappearing removeAllFoundIn: listOfStrings.
	disappearing do:
		[:oldName | 	self removeAccessorsFor: oldName].
	firstAppearing := listOfStrings copy.
	firstAppearing removeAllFoundIn: instVarList.
	instVarString := String streamContents:
		[:aStream | listOfStrings do: [:aString | aStream nextPutAll: aString; nextPut: $ ]].

	superclass subclass: self name instanceVariableNames: instVarString 
		classVariableNames: '' poolDictionaries: '' category: self categoryForUniclasses.
	self flag: #todo. self flag: #uniclasses. "Discuss if we really want to hide uniclasses again"
	superclass environment forgetClass: self logged: false.
	superclass removeSubclass: self.
	firstAppearing do:
		[:newName | self compileAccessorsFor: newName].

]

{ #category : #'variable docks' }
Player class >> setSlotInfoFromVariableDocks [
	"Get the slotInfo fixed up after a change in background shape.  Those instance variables that are proactively added by the user will persist, whereas those that are automatically generated will be updated"

	self slotInfo copy do:  "Remove old automatically-created slots"
		[:aSlotInfo | | aDock |
		(aDock := aSlotInfo variableDock) ifNotNil:
			[slotInfo removeKey: aDock variableName]].

	self variableDocks do:  [:dock | | newInfo | "Generate fresh slots from variable docks"
			newInfo := SlotInformation new type: dock variableType.
			newInfo variableDock: dock.
			slotInfo at: dock variableName asSymbol put: newInfo]
]

{ #category : #slots }
Player class >> slotGettersOfType: aType [
	"Answer a list of gettter selectors for slots of mine of the given type"

	| aList |
	aList := OrderedCollection new.
	self slotInfo associationsDo:
		[:assoc |
			(assoc value type = aType) ifTrue:
				[aList add: assoc key asGetterSelector]].
	^ aList
]

{ #category : #slots }
Player class >> slotInfo [
	slotInfo ifNil: [slotInfo := IdentityDictionary new].
	^ slotInfo
]

{ #category : #slots }
Player class >> slotInfo: aDict [
	"for copying"
	slotInfo := aDict
]

{ #category : #'user-scripted subclasses' }
Player class >> tileScriptNames [
	scripts ifNil: [^ OrderedCollection new].
	"The following is an emergency workaround for damaged script dictionaries occurring in Alan's demo image 8/2/98; no selector should be nil but somehow some is, so here we filter such damaging things out"
	^ scripts collect: [:aScript | aScript selector] thenSelect: [:n | n ~~ nil]
]

{ #category : #scripts }
Player class >> tilesFrom: aString [
	| code tree syn block phrase |
	"Construct SyntaxMorph tiles for the String."

	"This is really cheating!  Make a true parse tree later. -tk"
	code := String streamContents: [:strm | 
		strm nextPutAll: 'doIt'; cr; tab.
		strm nextPutAll: aString].
	"decompile to tiles"
	tree := Compiler new 
		parse: code 
		in: self
		notifying: nil.
	syn := tree asMorphicSyntaxUsing: SyntaxMorph.
	block := syn submorphs detect: [:mm | 
		(mm respondsTo: #parseNode) ifTrue: [
			mm parseNode class == BlockNode] ifFalse: [false]].
	phrase := block submorphs detect: [:mm | 
		(mm respondsTo: #parseNode) ifTrue: [
			mm parseNode class == MessageNode] ifFalse: [false]].
	^ phrase


]

{ #category : #other }
Player class >> typicalInstanceName [
	"For the purpose of documentation, answer the name of a named instance of the receiver, if possible, else answer the class name"

	| known |
	known := (self allInstances collect: [:i | i knownName]) detect: [:n | n isEmptyOrNil not] ifNone: [nil].
	^ known ifNil: [self name]
]

{ #category : #scripts }
Player class >> userScriptForPlayer: aPlayer selector: aSelector [
	"Answer the user script for the player (one copy for all instances of the uniclass) and selector"

	|  newEntry existingEntry |
	scripts ifNil: [scripts := IdentityDictionary new].
	existingEntry := scripts at: aSelector ifAbsent: [nil].

	"Sorry for all the distasteful isKindOf: and isMemberOf: stuff here, folks; it arises out of concern for preexisting content saved on disk from earlier stages of this architecture.  Someday much of it could be cut loose"
	Preferences universalTiles
		ifTrue:
			[(existingEntry isMemberOf: MethodWithInterface) ifTrue: [^ existingEntry].
			newEntry := (existingEntry isKindOf: UniclassScript)
				ifTrue:
					[existingEntry as: MethodWithInterface] "let go of extra stuff if it was UniclassScript"
				ifFalse:
					[MethodWithInterface new playerClass: aPlayer class selector: aSelector].
			scripts at: aSelector put: newEntry.
			^ newEntry]
		ifFalse:
			[(existingEntry isKindOf: UniclassScript)
				ifTrue:
					[^ existingEntry]
				ifFalse:
					[newEntry := UniclassScript new playerClass: self selector: aSelector.
					scripts at: aSelector put: newEntry.
					existingEntry ifNotNil: "means it is a grandfathered UserScript that needs conversion"
						[newEntry convertFromUserScript: existingEntry].
					^ newEntry]]
]

{ #category : #scripts }
Player class >> userScriptsDo: aBlock [

	self scripts do: aBlock
]

{ #category : #other }
Player class >> variableDocks [
	"Backward compatibility -- answer the formal list of VariableDocks associated with the class, assuming the class to be a CardPlayer subclass.  Somewhere a long time ago evidently the players assigned to Worlds stopped being CardPlayers, so this method is now provided as a backstop."

	^ #()
]

{ #category : #'variable docks' }
Player class >> variableDocks: dockList [
	"Set the variable-dock list as indicated"

	variableDocks := dockList
]

{ #category : #other }
Player class >> wantsChangeSetLogging [
	"Log changes for Player itself, but not for automatically-created subclasses like Player1, Player2, but *do* log it for uniclasses that have been manually renamed."

	^ (self == Player or:
		[(self name beginsWith: 'Player') not]) or:
			[Preferences universalTiles]
]

{ #category : #other }
Player class >> wantsRecompilationProgressReported [
	"Report progress for Player itself, but not for automatically-created subclasses like Player1, Player2"

	^ self == Player or:
		[(self class name beginsWith: 'Player') not]
]

{ #category : #'scripts-vector' }
Player >> * aNumber [
	"Treating Players like vectors, return a new Player that is myself scaled by the number"

	| new |
	new := costume usableSiblingInstance player.
	new setX: self getX * aNumber asPoint x.
	new setY: self getY * aNumber asPoint y.
	^ new

]

{ #category : #'scripts-vector' }
Player >> + aPlayer [
	"Treating Players like vectors, add aPlayer to me and return a new Player"

	| new |
	new := costume usableSiblingInstance player.
	new setX: self getX + aPlayer asPoint x.
	new setY: self getY + aPlayer asPoint y.
	^ new
]

{ #category : #'scripts-vector' }
Player >> - aPlayer [
	"Treating Players like vectors, subtract aPlayer from me and return a new Player"

	| new |
	new := costume usableSiblingInstance player.
	new setX: self getX - aPlayer asPoint x.
	new setY: self getY - aPlayer asPoint y.
	^ new
]

{ #category : #'scripts-vector' }
Player >> / aNumber [
	"Treating Players like vectors, return a new Player that is myself divided by the number"

	| new |
	new := costume usableSiblingInstance player.
	new setX: self getX / aNumber asPoint x.
	new setY: self getY / aNumber asPoint y.
	^ new

]

{ #category : #'slots-kernel' }
Player >> absorbBackgroundDataFrom: aLine forInstanceVariables: slotNames [
	"Fill my background fields from the substrings in a tab-delimited line of data.  At the moment this only really cateres to string-valued items"

	slotNames doWithIndex:
		[:aSlotName :anIndex |
			aLine do:
				[:aValue |
					self instVarNamed: aSlotName put: aValue] toFieldNumber: anIndex]
]

{ #category : #'scripts-kernel' }
Player >> acceptScript: aScriptEditorMorph for: aSelector [
	"Accept the tile code in the script editor as the code for the given selector.  This branch is only for the classic-tile system, 1997-2001"

	| aUniclassScript node method |
	aScriptEditorMorph generateParseNodeDirectly ifTrue: [
		(node := aScriptEditorMorph methodNode) ifNotNil: [
			method := node generate: (CompiledMethodTrailer empty
														sourceCode: (node sourceText);
														yourself).
			self class addSelectorSilently: aScriptEditorMorph scriptName withMethod: method.
			SystemChangeNotifier uniqueInstance doSilently: [self class organization classify: aSelector under: 'scripts']
		].
	] ifFalse: [
		self class compileSilently: aScriptEditorMorph methodString
			classified: 'scripts' for: self.
	].
	aUniclassScript := self class assuredMethodInterfaceFor: aSelector asSymbol.
	aUniclassScript currentScriptEditor: aScriptEditorMorph.
	aScriptEditorMorph world ifNotNil: [aScriptEditorMorph world removeHighlightFeedback].

]

{ #category : #'scripts-kernel' }
Player >> acceptableScriptNameFrom: originalString forScriptCurrentlyNamed: currentName [
	"Produce an acceptable script name, derived from the current name, for the receiver.  This method will always return a valid script name that will be suitable for use in the given situation, though you might not like its beauty sometimes."

	| aString stemAndSuffix proscribed stem suffix withoutColon currentNumArgs withColon |
	withoutColon := originalString withFirstCharacterDownshifted copyWithoutAll: {$:. $ }.
	(currentName notNil and: [(currentName copyWithout: $:) = withoutColon])
		ifTrue:
			[^ currentName].  "viz. no change; otherwise, the #respondsTo: check gets in the way"

	currentNumArgs := currentName ifNil: [0] ifNotNil: [currentName numArgs].
	aString := withoutColon asIdentifier: false.  "get an identifier starting with a lowercase letter"
	stemAndSuffix := aString stemAndNumericSuffix.
	proscribed := #(self super thisContext costume costumes dependents #true #false size).

	stem := stemAndSuffix first.
	suffix := stemAndSuffix last.
	withoutColon := aString asSymbol.
	withColon := (withoutColon, ':') asSymbol.

	[(proscribed includes: withoutColon)
		or: [self respondsTo: withoutColon]
		or: [self respondsTo: withColon]
		or:	[Smalltalk includesKey: withoutColon]
		or: [Smalltalk includesKey: withColon]]
	whileTrue:
		[suffix := suffix + 1.
		withoutColon := (stem, suffix printString) asSymbol.
		withColon := (withoutColon, ':') asSymbol].

	^ currentNumArgs = 0
		ifTrue:
			[withoutColon]
		ifFalse:
			[withColon]
]

{ #category : #misc }
Player >> actorState [
	"Answer the receiver's actorState.  If the receiver has no costume, answer nil, else answer the costume's current actor state, creating it at this time if necessary."

	^ self costume ifNotNil: [costume actorState]

]

{ #category : #'scripts-kernel' }
Player >> addIdiosyncraticMenuItemsTo: aMenu forSlotSymol: slotSym [
	"The menu provided has the receiver as its argument, and is used as the menu for the given slot-symbol in a line of a Viewer.  Add special-case items"

	(#(copy getNewClone newClone) includes: slotSym) ifTrue:
		[aMenu add: 'give me a copy now' translated action: #handTheUserACopy].

	(slotSym == #penTrailGraphic) ifTrue:
		[aMenu add: 'hand me a picture of pen trail' translated action: #handUserPictureOfPenTrail].

"	(slotSym == #dropShadow) ifTrue:
		[aMenu add: 'set shadow offset' translated action: #setShadowOffset].

	(slotSym == #useGradientFill) ifTrue:
		[aMenu add: 'set gradient origin...' translated action: #setGradientOffset.
		aMenu add: 'set gradient direction...' translated action: #setGradientDirection]."

]

{ #category : #'slots-user' }
Player >> addInstanceVariable [
	"Offer the user the opportunity to add an instance variable, and if he goes through with it, actually add it."

	Project current world 
		addMorphInLayer: (NewVariableDialogMorph on: self costume)
		centeredNear: (self currentHand ifNil:[Sensor]) cursorPoint
]

{ #category : #'slots-user' }
Player >> addInstanceVariable2Named: nameSymbol type: typeChosen value: aValue [
	"Add an instance variable of the given name and type, and initialize it to have the given value"

	| initialValue setterSelector |
	self assureUniClass.
	self slotInfo at: nameSymbol put: (SlotInformation new initialize type: typeChosen).
	initialValue := aValue.
	self addInstanceVarNamed: nameSymbol withValue: aValue.
	self class compileAccessorsFor: nameSymbol.
	setterSelector := nameSymbol asSetterSelector.
	(self class allSubInstances copyWithout: self) do:
		[:anInstance | anInstance perform: setterSelector with: initialValue].
	self updateAllViewersAndForceToShow: #'instance variables'

]

{ #category : #'slots-user' }
Player >> addInstanceVariableNamed: nameSymbol type: typeChosen value: aValue [
	"Add an instance variable of the given name and type, and initialize it to have the given value"

	| initialValue setterSelector |
	self assureUniClass.
	self slotInfo at: nameSymbol put: (SlotInformation new type: typeChosen).
	initialValue := self initialValueForSlotOfType: typeChosen.
	self addInstanceVarNamed: nameSymbol withValue: aValue.
	self compileInstVarAccessorsFor: nameSymbol.
	setterSelector := nameSymbol asSetterSelector.
	(self class allSubInstances copyWithout: self) do:
		[:anInstance | anInstance perform: setterSelector with: initialValue].
	self regenerateScripts.
	self updateAllViewersAndForceToShow: ScriptingSystem nameForInstanceVariablesCategory

]

{ #category : #'slot-kedama' }
Player >> addPatchVarNamed: nameSymbol [

	| f |
	f := KedamaPatchMorph newExtent: self costume dimensions.
	f assuredPlayer assureUniClass.
	f setNameTo: (Project current world unusedMorphNameLike: f innocuousName).
	self addInstanceVariable2Named: nameSymbol type: #Patch value: f player.
	^ f
]

{ #category : #pen }
Player >> addPlayerMenuItemsTo: aMenu hand: aHandMorph [
	"Note that these items are primarily available in another way in an object's Viewer"

	| subMenu |
	subMenu := MenuMorph new defaultTarget: self.
	self getPenDown
		ifTrue: [subMenu add: 'lift pen' action: #liftPen]
		ifFalse: [subMenu add: 'lower pen' action: #lowerPen].
	subMenu add: 'choose pen size...' action: #choosePenSize.
	subMenu add: 'choose pen color...' action: #choosePenColor:.
	aMenu add: 'pen...' subMenu: subMenu.

	(costume renderedMorph isSketchMorph) ifTrue:
		[self belongsToUniClass
			ifFalse: 
				[aMenu add: 'adopt scripts from...' target: self action: #adoptScriptsFrom]
			ifTrue:
				[aMenu add: 'impart scripts to...' target: self action: #impartSketchScripts]]
]

{ #category : #'slots-user' }
Player >> addSpecialSetter: selector [
	| instVar code |
	"For the special setters, fooIncreaseBy:, fooDecreaseBy:, fooMultiplyBy:, add a method that does them."

 	self assureUniClass.
	instVar := (selector allButLast: 11) asLowercase.  "all three are 11 long!"
	(self respondsTo: ('set', instVar capitalized, ':') asSymbol) ifFalse: [^ false].
	code := String streamContents: [:strm |
		strm nextPutAll: selector, ' amount'; crtab.
		strm nextPutAll: 'self set', instVar capitalized, ': (self get', instVar capitalized; space.
		(selector endsWith: 'IncreaseBy:') ifTrue: [strm nextPut: $+].
		(selector endsWith: 'DecreaseBy:') ifTrue: [strm nextPut: $-].
		(selector endsWith: 'MultiplyBy:') ifTrue: [strm nextPut: $*].
		strm nextPutAll: ' amount)'].

	self class compileSilently: code classified: 'access' notifying: nil.
	^ true

]

{ #category : #'slot-kedama' }
Player >> addToPatchDisplayList: aPlayer [

	costume renderedMorph addToPatchDisplayList: aPlayer costume renderedMorph.

]

{ #category : #'slot-kedama' }
Player >> addToTurtleDisplayList: aPlayer [

	costume renderedMorph addToTurtleDisplayList: aPlayer "costume renderedMorph".

]

{ #category : #misc }
Player >> adoptScriptsFrom [
	"Let the user click on another object form which the receiver should obtain scripts and code"

	| aMorph |
	Sensor waitNoButton.
	aMorph := Project current world chooseClickTarget.
	aMorph ifNil: [^ Beeper beep].

	(aMorph renderedMorph isSketchMorph
		and: [aMorph player belongsToUniClass]
		and: [self belongsToUniClass not])
			ifTrue: [costume acquirePlayerSimilarTo: aMorph player]
			ifFalse: [Beeper beep].
]

{ #category : #misc }
Player >> allOpenViewers [
	"Answer a list of all the viewers open on the receiver.  Include viewers in closed flaps"

	| aWorld all |
	(aWorld := self costume world) ifNil: [^#()].
	all := aWorld allMorphs.
	aWorld closedViewerFlapTabs 
		do: [:aTab | all addAll: aTab referent allMorphs].
	^all 
		select: [:m | (m isStandardViewer) and: [m scriptedPlayer == self]]
]

{ #category : #misc }
Player >> allOpenViewersOnReceiverAndSiblings [
	"Answer a list of all the viewers open on the receiver and any of its sibling instances.  Include viewers in closed flaps"

	| aWorld all |
	(aWorld := self costume world) ifNil: [^#()].
	all := aWorld allMorphs.
	aWorld closedViewerFlapTabs 
		do: [:aTab | all addAll: aTab referent allMorphs].
	^all select: 
			[:m | 
			(m isStandardViewer) and: [m scriptedPlayer class == self class]]
]

{ #category : #'slot-kedama' }
Player >> allPatchAndTurtleMorphs [

	self costume ifNil: [^ #()].
	^ self costume patches, (self costume turtles collect: #costume)
]

{ #category : #'slots-user' }
Player >> allPossibleWatchersFromWorld [
	"Answer a list of all UpdatingStringMorphs, PlayerReferenceReadouts, ThumbnailMorphs, and  UpdatingReferenceMorphs in the Active world and its hidden book pages, etc., which have me or any of my siblings as targets"

	| a |
	a := IdentitySet new: 400.
	Project current world allMorphsAndBookPagesInto: a.
	^ a select: [:e | e isEtoyReadout and: [e target class == self class]]
]

{ #category : #'scripts-kernel' }
Player >> allScriptEditors [
	"Used presently only an one-shot efforts to update all tile scripts to new styles"

	^ self class tileScriptNames collect: [:n | self scriptEditorForNoCng: n]
]

{ #category : #'scripts-standard' }
Player >> append: aPlayer [ 
	"Add aPlayer to the list of objects logically 'within' me.  This is visually represented by its morph becoming my costume's last submorph.   Also allow text to be appended."

	| aCostume |
	(aPlayer isNil or: [aPlayer == self]) ifTrue: [^self].
	(aPlayer isText or: [aPlayer isString]) 
		ifTrue: 
			[self costume class == TextFieldMorph 
				ifTrue: [^self costume append: aPlayer]
				ifFalse: [^self]].
	(aCostume := self costume topRendererOrSelf) 
		addMorphNearBack: aPlayer costume.
	aPlayer costume goHome.	"assure it's in view"
	(aCostume isKindOf: PasteUpMorph) 
		ifTrue: [self setCursor: (aCostume submorphs indexOf: aPlayer costume).
				aCostume 	 updateSubmorphThumbnails]  "also forces redraw"
]

{ #category : #misc }
Player >> arrowDeltaFor: aGetSelector [
	"Answer the arrowDelta to use in conjunction with a readout for aGetSelector, which will be of the form 'getXXX'"

	costume ifNotNil:
		[^ costume renderedMorph arrowDeltaFor: aGetSelector].
	^ 1
	
	"For the future, possibly:  If we want the SlotInformation for a user-defined slot to be able to specify a standard arrowDelta for that slot, we'd include something like the following... 
	| aSlotName slotInfo |
	aSlotName := Utilities inherentSelectorForGetter: aGetSelector.
	(slotInfo := self slotInfoAt: aSlotName ifAbsent: [nil]) ifNotNil:
		[^ slotInfo arrowDelta]."

]

{ #category : #pen }
Player >> arrowheadsOnAllPens [
	"Only for the Player of a World"

	self costume arrowheadsOnAllPens
]

{ #category : #'scripts-vector' }
Player >> asPoint [

	^ self getX @ self getY
]

{ #category : #'slots-assignment' }
Player >> assignDecrGetter: getterSelector setter: setterSelector amt: aDecrement [
	self perform: setterSelector with:
		((self perform: getterSelector) - aDecrement)
]

{ #category : #'slots-assignment' }
Player >> assignGetter: getterSelector setter: setterSelector amt: amt [
	self perform: setterSelector with: amt
]

{ #category : #'slots-assignment' }
Player >> assignIncrGetter: getterSelector setter: setterSelector amt: anIncrement [
	self perform: setterSelector with:
		((self perform: getterSelector) + anIncrement)
]

{ #category : #'slots-assignment' }
Player >> assignMultGetter: getterSelector setter: setterSelector amt: aMultiplier [
	self perform: setterSelector with:
		((self perform: getterSelector) * aMultiplier)
]

{ #category : #'scripts-standard' }
Player >> assignStatus: newStatus toAllFor: scriptName [
	"Change the status of my script of the given name to be as specified in me and all of my siblings."

	| aWorld |
	(self existingScriptInstantiationForSelector: scriptName) ifNotNil:
		[:scriptInstantiation |
				scriptInstantiation status: newStatus.
				scriptInstantiation assignStatusToAllSiblings.
				^ (aWorld := self costume world) ifNotNil:
					[aWorld updateStatusForAllScriptEditors]]
]

{ #category : #'scripts-execution' }
Player >> assureEventHandlerRepresentsStatus [
	self instantiatedUserScriptsDo:
			[:aScriptInst | aScriptInst assureEventHandlerRepresentsStatus]
]

{ #category : #'scripts-execution' }
Player >> assureNoScriptOtherThan: aScriptInstantiation hasStatus: aStatus [
	self instantiatedUserScriptsDo:
		[:aScriptInst | aScriptInst == aScriptInstantiation  ifFalse: [aScriptInst resetToNormalIfCurrently:  aStatus]]
]

{ #category : #viewer }
Player >> assureUniClass [
	"If I am not currently a member of a UniClass, become one now"
]

{ #category : #costume }
Player >> availableCostumeNames [
	"Answer a list of class names (minus trailing ...Morph) to be offered in the thumbnail 'new-Costume' menu in the Viewer"

 	^ #(Book BouncingAtoms Curve Ellipse  Flasher Image Joystick  PasteUp Polygon Rectangle Ruler Sketch Star String Text  )

"  ScrollBar  SimpleButton SimpleSlider SimpleSwitch  UserFrame  "
]

{ #category : #costume }
Player >> availableCostumesForArrows [
	^ costumes ifNil: [Array new]
]

{ #category : #'slots-user' }
Player >> basicCompileInstVarAccessorsFor: varName [
	self class compileInstVarAccessorsFor: varName
]

{ #category : #'slots-user' }
Player >> basicRemoveSlotNamed: aSlotName [
	"The user has requested that an instance variable be removed..."

	| aSetter aGetter |
	(self okayToRemoveSlotNamed: aSlotName) ifFalse:
		[^ self inform: 'Sorry, ', aSlotName, ' is in
use in a script.'].

	aSetter := aSlotName asSetterSelector.
	aGetter := aSlotName asGetterSelector.
	((self systemNavigation allCallsOn: aSetter) size > 0 or: [(self systemNavigation allCallsOn: aGetter) size > 0]) ifTrue:
		[self inform: 
'Caution!  There may be scripts belonging to
other objects that may rely on the presence of
this variable.  If there are, they may now be broken.
You may need to fix them up manually.'].

	self class removeInstVarName: aSlotName asString.

	self updateAllViewers
]

{ #category : #'slots-user' }
Player >> basicRenameSlot: oldSlotName newSlotName: newSlotName [
	"Give an existing instance variable a new name"

	self class renameSilentlyInstVar: oldSlotName to: newSlotName.
	self renameSlotInWatchersOld: oldSlotName new: newSlotName.
	self regenerateScripts.

	self updateAllViewers.

	self presenter allExtantPlayers do:
		[:aPlayer | (aPlayer hasScriptReferencing: oldSlotName ofPlayer: self)
			ifTrue:
				[aPlayer noteRenameOf: oldSlotName to: newSlotName inPlayer: self]].

	self presenter hasAnyTextuallyCodedScripts
		ifTrue:
			[self inform: 
'Caution!  References in textually-coded scripts won''t be renamed.' translated].

	^ true
]

{ #category : #misc }
Player >> beNotZero: value [
	"This is a runtime check if the arg to divide in a script is zero.  If it is, put up a warning message.  Return 0.001 instead of 0.  Note the time.  If fails again within 1 min., don't tell the user again."

	| ret v result |
	value isNumber ifTrue: [^ self basicBeNotZero: value].
	ret := KedamaFloatArray new: value size.
	1 to: value size do: [:i |
		v := value at: i.
		v = 0 ifFalse: [result := v].
		"We have a problem"
		TimeOfError 
			ifNil: [TimeOfError := Time totalSeconds]
			ifNotNil: [(Time totalSeconds - TimeOfError) > 45 ifTrue: [
				TimeOfError := Time totalSeconds.	"in case user interrupt and reenter"
				self inform: 
				'Dividing by zero makes a number too
				large for even a Sorcerer to handle.
				Please change your script.' translated.
				TimeOfError := Time totalSeconds]].
		result := 0.001.
		ret at: i put: result.
	].
	^ ret.

]

{ #category : #misc }
Player >> beRevealedInActiveWorld [
	"Reveal my corresponding morph in the active world"

	self revealPlayerIn: Project current world
]

{ #category : #'slots-user' }
Player >> beep: anObject [
	"Play given sound or at least beep."

	| sound |
	anObject isString
		ifTrue:
			[sound := SoundService default playSoundNamedOrBeep: anObject.
			(sound respondsTo: #stopGracefully)
				ifTrue: [self costume setProperty: #sound toValue: anObject.
							self costume setProperty: #playingSound toValue: sound]]
		ifFalse:
			[SoundPlayer resumePlaying: anObject quickStart: true]

]

{ #category : #viewer }
Player >> belongsToUniClass [
	"UnscriptedPlayer reimplements to false"
	^ true
]

{ #category : #'slot-kedama' }
Player >> blueComponentFrom: another [

	costume renderedMorph blueComponentFrom: another costume renderedMorph.


]

{ #category : #'slot-kedama' }
Player >> blueComponentInto: another [

	costume renderedMorph blueComponentInto: another costume renderedMorph.


]

{ #category : #'slot getters\/setters' }
Player >> bookEmbodied [
	"Answer the book embodied by the receiver's costume; usually this is directly the receiver's costume, but in case it is not, we look up the owner chain for one.  This allows page-number messages to be sent to a *page* of the stack, as Alan is wont to do, and have them still find their way to the right place"

	| aMorph |
	^ ((aMorph := self costume renderedMorph) isKindOf: BookMorph)
		ifTrue:
			[aMorph]
		ifFalse:
			[aMorph ownerThatIsA: BookMorph]
]

{ #category : #'scripts-standard' }
Player >> bounce: soundName [ 
	"If the receiver's current bounds obtrude beyond the bounds of its container, then 'bounce' it back within the container, and make the indicated sound while doing so"

	| box bounced aCostume |
	(aCostume := self costume) ifNil: [^self].
	(aCostume owner isNil or: [aCostume owner isHandMorph]) ifTrue: [^self].
	box := aCostume owner bounds.
	bounced := false.
	aCostume left < box left 
		ifTrue: 
			[self headRight.
			bounced := true].
	aCostume right > box right 
		ifTrue: 
			[self headLeft.
			bounced := true].
	aCostume top < box top 
		ifTrue: 
			[self headDown.
			bounced := true].
	aCostume bottom > box bottom 
		ifTrue: 
			[self headUp.
			bounced := true].
	bounced ifTrue: [^self makeBounceSound: soundName]
]

{ #category : #'slot-kedama' }
Player >> bounceOn: aPlayer [

	^ false.

]

{ #category : #'slot-kedama' }
Player >> bounceOn: aPlayer color: c [

	^ false.

]

{ #category : #'slot-kedama' }
Player >> bounceOnColor: aPlayer [

	^ false.

]

{ #category : #misc }
Player >> browseEToyVocabulary [
	"Open a protocol browser on the receiver, showing its etoy vocabulary"

	| littleMe | 
	littleMe := self assureUniClass.

	(InstanceBrowser new useVocabulary: Vocabulary eToyVocabulary) openOnObject: littleMe  showingSelector: nil
]

{ #category : #misc }
Player >> browsePlayerClass [
	Browser newOnClass: self class label: 'Compiled scripts for ', self externalName
]

{ #category : #'slot getters\/setters' }
Player >> cameraPoint [

	^ self costume cameraPoint
]

{ #category : #'slot getters\/setters' }
Player >> cameraPoint: pt [

	self costume cameraPoint: pt

]

{ #category : #'slots-kernel' }
Player >> categories [
	"Answer a list of categories appropriate to the the receiver and its costumes"

	| aList |
	(self hasCostumeThatIsAWorld)
		ifTrue:	[^ self categoriesForWorld].

	aList := OrderedCollection new.
	self slotNames notEmpty ifTrue:
		[aList add: ScriptingSystem nameForInstanceVariablesCategory].
	aList addAll: costume categoriesForViewer.
	aList remove: ScriptingSystem nameForScriptsCategory ifAbsent: [].
	aList add: ScriptingSystem nameForScriptsCategory after: aList first.
	^ aList
]

{ #category : #'slots-kernel' }
Player >> categoriesForVocabulary: aVocabulary [
	"Answer a list of categories appropriate to the receiver and its costumes, in the given Vocabulary"

	| aList scriptsName |
	self hasCostumeThatIsAWorld
		ifTrue:
			[aList := self categoriesForWorld]
		ifFalse:
			[aList := OrderedCollection new.
			self slotNames ifNotEmpty:
				[aList add: ScriptingSystem nameForInstanceVariablesCategory].
			aList addAll: costume categoriesForViewer].
	aVocabulary addCustomCategoriesTo: aList.
	aList remove: ScriptingSystem nameForScriptsCategory ifAbsent: [].
	scriptsName := ScriptingSystem nameForScriptsCategory.
	aList size > 2 ifTrue: [
		aList add: scriptsName after: aList first.
	] ifFalse: [
		aList addLast: scriptsName.
	].
	^ aList
]

{ #category : #'slots-kernel' }
Player >> categoriesForWorld [
	"Answer the list of categories given that the receiver is the Player representing a World"

	| aList |
	aList := #(color #'fill & border' scripting #'pen trails' #'world geometry' playfield collections sound) asOrderedCollection.
	aList add: #input.
	Preferences eToyFriendly ifFalse:
		[aList addAll: #(preferences #'as object'  
display) ].

	aList addAll: {ScriptingSystem nameForInstanceVariablesCategory.  ScriptingSystem nameForScriptsCategory}.

	^ aList
]

{ #category : #costume }
Player >> ceaseHavingAParameterFor: aSelector [
	"Make the script represented by aSelector cease bearing a parameter"

	| newSel |
	self renameScript: aSelector newSelector: (newSel := (aSelector copyWithout: $:) asSymbol).

	(self scriptEditorFor: newSel) assureParameterTilesValid; install
]

{ #category : #costume }
Player >> changeParameterTypeFor: aSelector [
	"Change the parameter type for the given selector.  Not currently sent, since types are now set by direct manipulation in the Scriptor header.  If this were reinstated someday, there would probably be an issue about getting correct-looking Parameter tile(s) into the Scriptor header(s)"

	| current typeChoices typeChosen |
	current := self typeforParameterFor: aSelector.
	typeChoices := Vocabulary typeChoicesForUserVariables.
	typeChosen := (SelectionMenu selections: typeChoices lines: #()) startUpWithCaption: 
		('Choose the TYPE
for the parameter (currently {1})' translated format: {current}).
	self setParameterFor: aSelector toType: typeChosen


]

{ #category : #'scripts-standard' }
Player >> changeScript: scriptName toStatus: statusSymbol [
	"Change the script of the given name to have the given status, and get all relevant script-status controls updated"

	scriptName ifNil: [^ self].
	Symbol hasInterned: scriptName ifTrue:
		[:sym | self instantiatedUserScriptsDo:
			[:aScriptInstantiation | aScriptInstantiation selector == sym
				ifTrue:
					[aScriptInstantiation status: statusSymbol.
					aScriptInstantiation updateAllStatusMorphs]]]
]

{ #category : #translation }
Player >> changeTypesInWatchersOf: slotName [
	"The type of a variable has changed; adjust watchers to that fact."

	| aGetter |
	aGetter := slotName asGetterSelector.
	self allPossibleWatchersFromWorld do: [:aWatcher | | newWatcher |
		(aWatcher getSelector = aGetter) ifTrue:
			[(aWatcher ownerThatIsA: WatcherWrapper) ifNotNil:
				[:aWrapper |
					newWatcher := (aWrapper submorphs size = 1)
						ifTrue:
							[WatcherWrapper new unlabeledForPlayer: self getter: aGetter]
						ifFalse:
							[WatcherWrapper new fancyForPlayer: self getter: aGetter].
					newWatcher position: aWatcher position.
					aWrapper owner replaceSubmorph: aWrapper by: newWatcher]]]

]

{ #category : #pen }
Player >> choosePenColor: evt [
	self costume changeColorTarget:  self costume  selector: #penColor: originalColor: self getPenColor hand: evt hand
]

{ #category : #pen }
Player >> choosePenSize [
	^ self actorState choosePenSize
]

{ #category : #'slots-user' }
Player >> chooseSlotTypeFor: aGetter [
	"Let the user designate a type for the slot associated with the given getter"

	| typeChoices typeChosen slotName |
	slotName := aGetter inherentSelector.
	typeChoices := Vocabulary typeChoices.
	typeChosen := UIManager default 
		chooseFrom: (typeChoices collect: [:t | t translated]) 
		values: typeChoices
		title: ('Choose the TYPE
for ' translated, slotName, '
(currently ' translated, (self slotInfoAt: slotName) type translated, ')').
	typeChosen isEmptyOrNil ifTrue: [^ self].
	(self typeForSlot: slotName) capitalized = typeChosen ifTrue: [^ self].

	(self slotInfoAt: slotName) type: typeChosen.
	self class allInstancesDo:   "allSubInstancesDo:"
		[:anInst | anInst instVarNamed: slotName asString put: 
			(anInst valueOfType: typeChosen from: (anInst instVarNamed: slotName))].
	self updateAllViewers.	"does siblings too"
	self changeTypesInWatchersOf: slotName  "does siblings too"

]

{ #category : #'slots-user' }
Player >> chooseUserSlot [
	| names aMenu result |
	(names := self slotNames) size == 1
		ifTrue: [^ names first].
	aMenu := SelectionMenu selections: names.
	result := aMenu startUpWithCaption: 'Please choose a variable' translated.
	result isEmptyOrNil ifTrue: [^ nil].
	^ result
]

{ #category : #'scripts-standard' }
Player >> clear [

	self sendMessageToCostume: #clear.

]

{ #category : #costume }
Player >> clearOwnersPenTrails [
	"Clear the pen trails of the containing playfield"

	self costume referencePlayfield clearTurtleTrails
]

{ #category : #costume }
Player >> clearPenTrails [
	"Allow old code invoking the short-lived deviant clearPenTrails command to continue to work when imported from a bj image into a mainstream image.  For backward compatibility only!"

	self costume referencePlayfield clearTurtleTrails
]

{ #category : #pen }
Player >> clearTurtleTrails [
	"Clear all turtle trails within my costume, presumed to be a playfield"

	self costume renderedMorph clearTurtleTrails
]

{ #category : #misc }
Player >> color [
	^ self costume color
]

{ #category : #misc }
Player >> color: myColor sees: externalColor [
	"Answer whether any pixel of one color on my costume is coincident with any pixel of a second color in its surround.  Returns false if the costume is not currently in the world"

	self costume isInWorld ifFalse: [^ false].
	^ self costume color: myColor sees: externalColor
]

{ #category : #pen }
Player >> colorUnder [
	^ self costume colorUnder
]

{ #category : #'slots-user' }
Player >> compileInstVarAccessorsFor: varName [
	self class compileInstVarAccessorsFor: varName
]

{ #category : #'scripts-standard' }
Player >> contents [
	^ costume contents
]

{ #category : #'scripts-standard' }
Player >> contents: stuff [
	^ costume contents: stuff
]

{ #category : #copying }
Player >> copyUniClassWith: deepCopier [
	"my class is a subclass of Player.  Return another class just like my class.  Share the costume list."
	| newCls |
	newCls := self class officialClass 
		newUniqueClassInstVars: self class instanceVariablesString 
		classInstVars: self class class instanceVariablesString.
	newCls copyMethodDictionaryFrom: self class.
	newCls class copyMethodDictionaryFrom: self class class.
	newCls scripts: self class privateScripts.	"duplicate this in mapUniClasses"
	newCls slotInfo: (self class privateSlotInfo veryDeepCopyWith: deepCopier).
	newCls copyAddedStateFrom: self class.  "All class inst vars for inter Player refs"
	^ newCls

]

{ #category : #costume }
Player >> costume [
	^ costume
]

{ #category : #'customevents-costume' }
Player >> costume: aMorph [
	"Make aMorph be the receiver's current costume"
	| itsBounds |
	costume == aMorph ifTrue: [^ self].
	costume ifNotNil:
		[self rememberCostume: costume renderedMorph.
		itsBounds := costume bounds.
		(costume ownerThatIsA: HandMorph orA: PasteUpMorph) replaceSubmorph: costume topRendererOrSelf by: aMorph.
		aMorph position: itsBounds origin.
		aMorph actorState: costume actorStateOrNil.
		aMorph setNameTo: costume externalName].
	aMorph player: self.
	costume := aMorph.
	aMorph arrangeToStartStepping
]

{ #category : #costume }
Player >> costumeRespondingTo: aSelector [
	"Answer a costume that responds to the given selector, or nil if none"
	| aMorph |
	((aMorph := self costume renderedMorph) respondsTo: aSelector) ifTrue: [^ aMorph].
	costumes isEmptyOrNil ifFalse:
		[costumes do: [:aCostume | (aCostume respondsTo: aSelector) ifTrue: [^ aCostume]]].
	^ nil "usually an error will result"
]

{ #category : #testing }
Player >> costumes [
	^ costumes
]

{ #category : #costume }
Player >> costumesDo: aBlock [ 
	"Evaluate aBlock against every real (not flex) costume known to the receiver,
	starting with the current costume."

	costume ifNotNil: [ aBlock value: costume renderedMorph ].
	costumes
		ifNil: [^ self].
	costumes
		do: [:aCostume | aCostume ~~ costume
				ifTrue: [aBlock value: aCostume renderedMorph]]
]

{ #category : #'slot-kedama' }
Player >> createSlotForPatch: aPatchMorph [
	"anEmbeddedMorph has just been added to my costume because of explicit user action.  
	Create an instance variable and accessors for it as a Player-valued slot."
	| itsName openViewers |
	self costume isInWorld ifFalse: [ ^self ].

	itsName := aPatchMorph externalName asSymbol.

	self slotInfo
		at: itsName
		put: (SlotInformation new initialize type: #Patch).
	self addInstanceVarNamed: itsName withValue: (aPatchMorph assuredPlayer).
	self class compileAccessorsFor: itsName.
	openViewers := self allOpenViewersOnReceiverAndSiblings.
	openViewers isEmpty
		ifTrue: [^ self]
		ifFalse: [| aPresenter | 
			(aPresenter := self costume presenter)
				ifNil: [^ self].
			openViewers
				do: [:aViewer | aPresenter updateViewer: aViewer forceToShow: ScriptingSystem nameForInstanceVariablesCategory]]

]

{ #category : #'slot-kedama' }
Player >> decayPatchVariable [

	self costume renderedMorph evaporate.

]

{ #category : #misc }
Player >> decimalPlacesForGetter: aGetter [
	"Answer the number of decimal places wanted when displaying the getter's value.  Answer nil if this object does not have a personal preference regarding this getter."

	^ costume decimalPlacesForGetter: aGetter
]

{ #category : #'scripts-vector' }
Player >> decr: aPlayer [
	"Treating Players like vectors, subtract aPlayer from me"

	self setX: self getX - aPlayer asPoint x.
	self setY: self getY - aPlayer asPoint y.
]

{ #category : #misc }
Player >> defaultFloatPrecisionFor: aGetSelector [
	"Answer the float position to use in conjunction with a readout for aGetSelector, which will be of the form 'getXXX'"

	| aSlotName slotInfo |
	aSlotName := aGetSelector inherentSelector.
	(slotInfo := self slotInfoAt: aSlotName ifAbsent: [nil]) ifNotNil:
		[^ slotInfo floatPrecision].

	self costume ifNotNil:
		[^ self costume renderedMorph defaultFloatPrecisionFor: aGetSelector].
	^ 1
]

{ #category : #'user interface' }
Player >> defaultLabelForInspector [
	"Answer the default label to be used for an Inspector window on the receiver."
	^ self knownName ifNil: ['An unaffiliated Player'] ifNotNil: [self knownName]
]

{ #category : #'slot-kedama' }
Player >> defaultPatchPlayer [

	^ costume renderedMorph kedamaWorld defaultPatch player.

]

{ #category : #pen }
Player >> defaultPenColor [
	^ Color blue
]

{ #category : #pen }
Player >> defaultPenSize [
	^ 1
]

{ #category : #'slots-user' }
Player >> defaultValueOfType: aSymbol [
	"Answer a default value for the given type -- invoked in compiled user scripts when a parameter tile of the wrong type is present"

	^ self initialValueForSlotOfType: aSymbol
	"Not really intended for that purpose but seemingly serves adequately"
]

{ #category : #'card\/stack commands' }
Player >> deleteCard [
	"Tell the receiver's stack to delete the current card"

	self costume stackDo: [:aStack | aStack deleteCard]
]

{ #category : #'slot-kedama' }
Player >> die [

]

{ #category : #'slot-kedama' }
Player >> diffusePatchVariable [
	"Diffuse the patch variable of the given name."

	self costume renderedMorph diffuse.

]

{ #category : #'scripts-vector' }
Player >> dividedBy: aNumber [
	"Treating Players like vectors, divide myself by aNumber"

	self setX: self getX / aNumber asPoint x.
	self setY: self getY / aNumber asPoint y.

]

{ #category : #'scripts-standard' }
Player >> doButtonAction [
	"Do the button action of my costume"

	self costume renderedMorph doButtonAction
]

{ #category : #'slot-kedama' }
Player >> doCommand: aBlock [

	^ aBlock value: self.

]

{ #category : #'scripts-standard' }
Player >> doMenuItem: menuString [
	"Do the menu item whose wording is provided"

	self costume doMenuItem: menuString
]

{ #category : #'scripts-standard' }
Player >> doScript: scriptNameString [
	"On the next tick of the clock, run the given script once"

	Symbol hasInterned: scriptNameString ifTrue:
		[:sym | (self class includesSelector: sym) ifTrue:
			[costume addAlarm: #triggerScript: with: sym after: 1]]
]

{ #category : #'error handling' }
Player >> doesNotUnderstand: aMessage [ 
	 | ours |
"See it the message is a special setter that has not been defined.  Define it and try again."

	ours := false.
	(aMessage selector endsWith: 'IncreaseBy:') ifTrue: [ours := true].
	(aMessage selector endsWith: 'DecreaseBy:') ifTrue: [ours := true].
	(aMessage selector endsWith: 'MultiplyBy:') ifTrue: [ours := true].
	ours ifFalse: [^ super doesNotUnderstand: aMessage].
	(self addSpecialSetter: aMessage selector) ifFalse: ["not our inst var"
		^ super doesNotUnderstand: aMessage].
	^ aMessage sentTo: self
]

{ #category : #misc }
Player >> dummy [
	"this space for rent"
]

{ #category : #'scripts-kernel' }
Player >> editDescriptionForSelector:  aSelector [
	"Allow the user to edit the balloon-help description for the given selector"

	(self class userScriptForPlayer: self selector: aSelector) editDescription.
	self updateAllViewers
]

{ #category : #viewer }
Player >> elementTypeFor: aStringOrSymbol vocabulary: aVocabulary [
	"Answer whether aStringOrSymbol is best characterized as a #systemSlot, #systemScript, #userSlot, or #userScript.  This is ancient and odious but too tedious to rip out at this point."

	| aSymbol anInterface aSlotName |
	aSymbol := aStringOrSymbol asSymbol.
	aSlotName := aSymbol inherentSelector.
	(self slotInfo includesKey: aSlotName) ifTrue: [^ #userSlot].
	(self class isUniClass and: [self class scripts includesKey: aSymbol]) ifTrue: [^ #userScript].
	
	anInterface := aVocabulary methodInterfaceAt: aSymbol ifAbsent: [nil].
	^ anInterface
		ifNotNil:
			[(anInterface resultType == #unknown)
				ifTrue:
					[#systemScript]
				ifFalse:
					[#systemSlot]]
		ifNil:
			[#systemScript]
]

{ #category : #'scripts-kernel' }
Player >> emptyScript [
	"The empty script"
]

{ #category : #misc }
Player >> entryForPlayersTool: aPlayersTool [
	"Answer an entry for the receiver in the All Players tool"

	^ PlayerSurrogate newRow playerRepresented: self
]

{ #category : #misc }
Player >> erase [
	"Simply dismiss the receiver from the screen."

	self costume topRendererOrSelf dismissMorph
]

{ #category : #'customevents-scripts-kernel' }
Player >> existingScriptInstantiationForSelector: scriptName [
	"Answer the existing script instantiation for the given selector, or nil if none"

	scriptName ifNil: [^ nil].
	Symbol hasInterned: scriptName
		ifTrue: [ :sym |
			self costume actorStateOrNil ifNotNil: [ :actorState |
				^actorState instantiatedUserScriptsDictionary at: sym ifAbsent: [nil]]].
	^ nil
]

{ #category : #'scripts-kernel' }
Player >> expungeEmptyScripts [
	"Track down and destroy -- and destroy screen artifacts relating to -- all scripts belonging to the receiver that have no lines of code in them"

	| any |
	any := false.
	self class namedTileScriptSelectors do:
		[:aSel |
			(self isEmptyTileScript: aSel)
				ifTrue:
					[any := true.
					self removeScriptWithoutUpdatingViewers: aSel]].
	any ifTrue: [self updateAllViewersAndForceToShow: #scripts]
			

]

{ #category : #'scripts-kernel' }
Player >> expungeEmptyUnRenamedScripts [
	"Track down and destroy -- and destroy screen artifacts relating to -- all scripts belonging to the receiver that have not been named and that have no lines of code in them"

	| any |
	any := false.
	self class namedTileScriptSelectors do:
		[:aSel |
			(self isExpendableScript: aSel)
				ifTrue:
					[any := true.
					self removeScriptWithoutUpdatingViewers: aSel]].
	any ifTrue:
		[self updateAllViewersAndForceToShow: #scripts]
			

]

{ #category : #viewer }
Player >> externalName [
	"Answer an external name for the receiver.  If it has none, supply a backstop name"

	| aCostume |
	^ (aCostume := self costume) ifNotNil: [aCostume externalName] ifNil: ['an orphaned Player']
]

{ #category : #'slots-user' }
Player >> fancyWatcherFor: aGetter [
	"Anser a labeled readout for viewing a value textuallyi"

	| aWatcher aColor aLine itsName aSelector aLabel |
	aWatcher := self unlabeledWatcherFor: aGetter.
	aColor := Color r: 0.387 g: 0.581 b: 1.0.
	aLine := WatcherWrapper newRow.
	aLine player: self variableName: (aSelector := aGetter inherentSelector).
	itsName := aWatcher externalName.
	aWatcher setNameTo: 'readout'.
	aLine addMorphFront: (self tileReferringToSelf
				borderWidth: 0; layoutInset: 4@0;
				typeColor: aColor; 
				color: aColor; bePossessive).
	aLabel := StringMorph contents: aSelector translated, ' = ' font: ScriptingSystem fontForTiles.
	aLabel setProperty: #watcherLabel toValue: true.
	aLine addMorphBack: aLabel.
	aLine addMorphBack: aWatcher.
	aLine setNameTo: itsName.

	^ aLine
]

{ #category : #'scripts-standard' }
Player >> fire [
	"Do the button action of my costume"

	self costume renderedMorph fire
]

{ #category : #'scripts-execution' }
Player >> fireOnce [
	"If the receiver has any script armed to be triggered on mouse down and/or mouse-up, run those scripts now -- first the mouseDown ones, then the mouseUp ones."

	self instantiatedUserScriptsDo:
		[:aScriptInst |
			aScriptInst status == #mouseDown ifTrue: [aScriptInst fireOnce]].
	self instantiatedUserScriptsDo:
		[:aScriptInst |
			aScriptInst status == #mouseUp ifTrue: [aScriptInst fireOnce]].

]

{ #category : #'card\/stack commands' }
Player >> firstPage [
	self sendMessageToCostume: #firstPage
]

{ #category : #costume }
Player >> flipHorizontal [
	self costume flipHorizontal
]

{ #category : #costume }
Player >> flipVertical [
	self costume flipVertical
]

{ #category : #'scripts-standard' }
Player >> followPath [
	"If there is a path defined for this object, follow it now"

	self costume renderedMorph followPath
]

{ #category : #costume }
Player >> forgetOtherCostumes [
	self resetCostumeList.
	self updateAllViewers
]

{ #category : #'scripts-standard' }
Player >> forward: dist [ 
	"Move forward (viz. in the direction of my heading) by the given amount"

	| rho radians delta didStray p aCostume aPlayfield |
	(aCostume := self costume) isInWorld ifFalse: [^ self].
	aCostume isWorldOrHandMorph ifTrue: [^ self].
	aCostume owner isHandMorph ifTrue: [^ self].

	rho := (aCostume asNumber: dist) asFloat.
	radians := (self getHeadingUnrounded asFloat - 90.0) degreesToRadians.
	delta := (radians cos @ radians sin) * rho.

	(aPlayfield := aCostume pasteUpMorph) fenceEnabled ifTrue:
		[(aPlayfield bounds containsRect: aCostume bounds) ifFalse:
			["If I stray out of the bounds of my playfield, pull me back, but
			 without changing my heading as bounce would. Do nothing if
			 bounce has already corrected the direction."
			didStray := false.
			((aCostume left < aPlayfield left and: [delta x < 0]) or:
			 [aCostume right > aPlayfield right and: [delta x > 0]]) ifTrue:
				[delta := delta x negated @ delta y.
				didStray := true].
			((aCostume top < aPlayfield top and: [delta y < 0]) or:
			 [aCostume bottom > aPlayfield bottom and: [delta y > 0]]) ifTrue:
				[delta := delta x @ delta y negated.
				didStray := true].
			(didStray and: [Preferences fenceSoundEnabled]) ifTrue: [aCostume makeFenceSound]]].

	"use and record the fractional position"
	p := aCostume referencePosition + delta.
	aCostume referencePosition: p
]

{ #category : #'slot-kedama' }
Player >> gatherPatchesAndTurtles [

	| position |
	self costume owner ifNil: [^ self].
	position := self costume topRight + (5@0).
	self allPatchAndTurtleMorphs do: [:m |
		m ifNotNil: [
			m position: position.
			self costume owner addMorph: m.
			m visible: true.
			position := position + (0@(m height + 5))]].
]

{ #category : #'slot getters\/setters' }
Player >> getActWhen [
	"Answer the #actWhen status of my costume, which is expected to be a button with an #actWhen protocol"

	^ costume renderedMorph actWhen
]

{ #category : #'slot getters\/setters' }
Player >> getAllButFirstCharacter [ 
	"Answer a string consisting of all but the first character in its string"

	^ costume renderedMorph getAllButFirstCharacter
]

{ #category : #'slot getters\/setters' }
Player >> getAllowEtoyUserCustomEvents [
	"Answer whether to use the vector vocabulary."

	^ Preferences valueOfFlag: #allowEtoyUserCustomEvents
]

{ #category : #'slot getters\/setters' }
Player >> getAlpha [
	"Answer the alpha of the color of my costume."

	^ self getColor alpha
]

{ #category : #'slot getters\/setters' }
Player >> getAmount [
	^ self getValueFromCostume: #amount
]

{ #category : #'slot getters\/setters' }
Player >> getAngle [
	^ self getValueFromCostume: #angle
]

{ #category : #'slot-kedama' }
Player >> getAngleTo: aPlayer [

	^ 0.0.

]

{ #category : #'scripts-standard' }
Player >> getBackgroundColor [
	"Answer the background color; the costume is presumed to be a TextMorph"

	^  self costume renderedMorph backgroundColor ifNil: [Color transparent]
]

{ #category : #'slot getters\/setters' }
Player >> getBaseGraphic [
	"Answer a form representing the receiver's base graphic"

	| aMorph |
	^ ((aMorph := costume renderedMorph) isSketchMorph)
		ifTrue:
			[aMorph baseGraphic]
		ifFalse:
			[aMorph imageForm]
]

{ #category : #'slot getters\/setters' }
Player >> getBatchPenTrails [
	"Answer whether to batch pen trails."

	^ Preferences batchPenTrails
]

{ #category : #'slot-kedama' }
Player >> getBlueComponentIn: aPatch [
]

{ #category : #'slot getters\/setters' }
Player >> getBorderColor [
	"Answer the border color of my costume"

	^ costume renderedMorph borderStyle color ifNil: [costume renderedMorph borderStyle baseColor]
]

{ #category : #'slot getters\/setters' }
Player >> getBorderStyle [
	"Answer the border style"

	^ costume renderedMorph borderStyle style
]

{ #category : #'slot getters\/setters' }
Player >> getBorderWidth [
	"Answer the border width of my costume"

	^ costume renderedMorph borderStyle width
]

{ #category : #'slot getters\/setters' }
Player >> getBottom [
	"Answer the bottom coordinate, in the cartesian sense (decreases towards bottom of screen)"

	^ self costume cartesianBoundsTopLeft y - self costume height
]

{ #category : #'slot-kedama' }
Player >> getBottomEdgeMode [

	^ self getValueFromCostume: #bottomEdgeMode.

]

{ #category : #'slot getters\/setters' }
Player >> getBrightnessUnder [
	^ self costume colorUnder brightness * 100
]

{ #category : #'slot getters\/setters' }
Player >> getButton1 [
	^ self getValueFromCostume: #button1
]

{ #category : #'slot getters\/setters' }
Player >> getButton2 [
	^ self getValueFromCostume: #button2
]

{ #category : #'slot getters\/setters' }
Player >> getCameraPoint [

	^ self costume cameraPoint
]

{ #category : #'slot getters\/setters' }
Player >> getCardNumber [
	"Answer the current card number"

	| aStack |
	^ (aStack := self stackEmbodied) cardNumberOf: aStack currentCard
]

{ #category : #'slot getters\/setters' }
Player >> getCellInset [
	"Getter for costume's cellInset"

	^ costume cellInset
]

{ #category : #'slot getters\/setters' }
Player >> getCharacterAtCursor [
	"Answer the value of the text cursor"

	| aLoc aTextMorph aString |
	aLoc := (aTextMorph := self costume renderedMorph) cursor.
	aString := aTextMorph text string.
	^ (aString at: aLoc ifAbsent: ['·']) asString
]

{ #category : #'slot getters\/setters' }
Player >> getCharacters [
	"Answer the characters in my costume, likely a TextMorph"

	^ costume renderedMorph getCharacters
]

{ #category : #'slot getters\/setters' }
Player >> getClipSubmorphs [
	"Getter for costume's clipSubmorphs"

	^ costume renderedMorph clipSubmorphs
]

{ #category : #'slot getters\/setters' }
Player >> getColor [
	"Answer the color of my costume.  If it uses a gradient fill, answer the first color."

	| aFillStyle aMorph |
	^ ((self isFillStyle: (aFillStyle :=  (aMorph := self costume renderedMorph) fillStyle)) and: [aFillStyle isGradientFill] )
		ifTrue:
			[aFillStyle colorRamp first value]
		ifFalse:
			[aMorph color]
]

{ #category : #'slot getters\/setters' }
Player >> getColorOpaque [

	^ self getColor.

]

{ #category : #'slot getters\/setters' }
Player >> getColorUnder [
	"Answer the color beneath the center of the costume"

	^ self costume colorUnder
]

{ #category : #sound }
Player >> getConePosition [
	"Note: Performance hacked to allow real-time sound. Assumes costume is a SpeakerMorph."

	^ costume renderedMorph conePosition
]

{ #category : #'slot getters\/setters' }
Player >> getCostume [
	"Answer a form representing the receiver's primary graphic.  An earlier wording, disused but may persist in preexisting scripts."

	| aMorph |
	^ ((aMorph := costume renderedMorph) isSketchMorph)
		ifTrue:
			[aMorph form]
		ifFalse:
			[aMorph imageForm]
]

{ #category : #'slot getters\/setters' }
Player >> getCostumeAtCursor [
	"Answer the form representing the object at the current cursor.  An earlier wording, disused but may persist in preexisting scripts"

	| anObject aMorph |
	
	anObject := self getValueFromCostume: #valueAtCursor.
	^ anObject == 0  "weird return from GraphMorph"
		ifTrue:
			[ScriptingSystem formAtKey: #Paint]
		ifFalse:
			[((aMorph := anObject renderedMorph) isSketchMorph)
				ifTrue:
					[aMorph form]
				ifFalse:
					[anObject imageForm]]
]

{ #category : #'slot getters\/setters' }
Player >> getCount [
	"Answer the number of elements"

	^ self costume renderedMorph elementCount
]

{ #category : #'playing commands' }
Player >> getCurrentFrameForm [

	^ self sendMessageToCostume: #getCurrentFrameForm

]

{ #category : #'slot getters\/setters' }
Player >> getCursor [
	"Obtain the cursor setting from the receiver's costume"

	^ costume renderedMorph cursor

]

{ #category : #'slot getters\/setters' }
Player >> getCursorWrapped [
	"maintained for backward compatibility only, for preexisting etoys"

	^ self getCursor

]

{ #category : #'slot getters\/setters' }
Player >> getDescending [
	^  self getValueFromCostume: #descending
]

{ #category : #'slot-kedama' }
Player >> getDiffusionRate [

	^ self getValueFromCostume: #diffusionRate.

]

{ #category : #'slot-kedama' }
Player >> getDimensions [

	^ self getValueFromCostume: #dimensions.

]

{ #category : #'slot-kedama' }
Player >> getDimensionsHeight [

	^ (self getValueFromCostume: #dimensions) y.

]

{ #category : #'slot-kedama' }
Player >> getDimensionsWidth [

	^ (self getValueFromCostume: #dimensions) x.

]

{ #category : #'slot-kedama' }
Player >> getDisplayScaleMax [

	^ self getValueFromCostume: #displayMax.

]

{ #category : #'slot-kedama' }
Player >> getDisplayShiftAmount [

	^ self getValueFromCostume: #displayShiftAmount.

]

{ #category : #'slot-kedama' }
Player >> getDisplayType [

	^ self getValueFromCostume: #displayType.

]

{ #category : #'slot getters\/setters' }
Player >> getDistance [
	"Answer distance from the origin to the objet's position"

	^ (self getX @ self getY) r
]

{ #category : #'slot-kedama' }
Player >> getDistanceTo: aPlayer [

	^ 0.0.

]

{ #category : #pen }
Player >> getDotSize [
	"Answer the receiver's dotSize"

	^ self costume renderedMorph valueOfProperty: #trailDotSize ifAbsentPut: [6]
]

{ #category : #'slot getters\/setters' }
Player >> getDragEnabled [
	"Getter for costume's dragEnabled"

	^ costume dragEnabled
]

{ #category : #'slot getters\/setters' }
Player >> getDropEnabled [
	"Getter for costume's dropEnabled"

	^ costume dropEnabled
]

{ #category : #'slot getters\/setters' }
Player >> getDropProducesWatcher [
	"Answer the value of the dropProducesWatcher preference."

	^ Preferences dropProducesWatcher
]

{ #category : #'slot getters\/setters' }
Player >> getDropShadow [
	"Getter for costume's hasDropShadow"

	^ costume renderedMorph hasDropShadow
]

{ #category : #'slot getters\/setters' }
Player >> getEToyFriendly [
	"Answer the value of the eToyFriendly preference."

	^ Preferences eToyFriendly
]

{ #category : #'slot-kedama' }
Player >> getEvaporationRate [

	^ self getValueFromCostume: #evaporationRate.

]

{ #category : #'slot getters\/setters' }
Player >> getFenceEnabled [
	"Answer the value of the fenceEnabled preference."

	^ Preferences fenceEnabled
]

{ #category : #'slot getters\/setters' }
Player >> getFirstCharacter [
	"Answer a string consisting of the first character in my costume, likely itself a TextMorph"

	^ costume renderedMorph getFirstCharacter
]

{ #category : #'slot getters\/setters' }
Player >> getFirstElement [
	"Answer a player representing the receiver's costume's first submorph.  The costume is assumed to be some kind of PasteUpMorph.  In case it currently is empty, answer the Dot object as a place-holder."

	| itsMorphs |
	^ (itsMorphs := costume renderedMorph submorphs) notEmpty 
		ifFalse: [costume presenter standardPlayer]
		ifTrue: [itsMorphs first assuredPlayer]
]

{ #category : #'playing commands' }
Player >> getFrameGraphic [
	"Answer a form representing the receiver's costume's current graphic"

	^ self sendMessageToCostume: #getCurrentFrameForm

]

{ #category : #'slot getters\/setters' }
Player >> getGetListSelector [
	"Answer the selector used by my costume (a list) to obtain a fresh copy of its list"

	^ self costume renderedMorph getListSelector
]

{ #category : #'slot getters\/setters' }
Player >> getGraphic [
	"Answer a form representing the receiver's primary graphic"

	| aMorph |
	^ ((aMorph := costume renderedMorph) isSketchMorph)
		ifTrue:
			[aMorph topRendererOrSelf imageForm]
		ifFalse:
			[aMorph isPlayfieldLike
				ifTrue:
					[aMorph backgroundForm]
				ifFalse:
					[aMorph imageForm]]
]

{ #category : #'slot getters\/setters' }
Player >> getGraphicAtCursor [
	"Answer a form depicting the object at the current cursor"

	| anObject aMorph |
	
	anObject := self getValueFromCostume: #valueAtCursor.

	^ (anObject isNil or: [anObject == 0  "weird return from GraphMorph"])
		ifTrue:
			[ScriptingSystem formAtKey: #Paint]
		ifFalse:
			[((aMorph := anObject renderedMorph) isSketchMorph)
				ifTrue:
					[aMorph form]
				ifFalse:
					[aMorph isPlayfieldLike
						ifTrue:
							[aMorph backgroundForm]
						ifFalse:
							[aMorph imageForm]]]
]

{ #category : #'slot-kedama' }
Player >> getGreenComponentIn: aPatch [
]

{ #category : #'slot-kedama' }
Player >> getGrouped [

	^ self getValueFromCostume: #isGroup.

]

{ #category : #'slot getters\/setters' }
Player >> getHResizing [
	"Getter for costume's hResizing"

	^ costume hResizing
]

{ #category : #'slot getters\/setters' }
Player >> getHeading [
	"Answer the heading of the object, *formerly* ;-) always given as a whole number"

	^ self getHeadingUnrounded "rounded"
]

{ #category : #'slot getters\/setters' }
Player >> getHeadingTheta [
	"Answer the angle, in degrees, between the positive x-axis and the receiver's heading vector"

	| aHeading excess normalized |
	aHeading := self getHeadingUnrounded.
	excess := aHeading - (aHeading rounded).

	normalized := (450 - aHeading) \\ 360.
	^ normalized + excess
]

{ #category : #'slot getters\/setters' }
Player >> getHeadingUnrounded [
	^ self costume heading asSmallAngleDegrees
]

{ #category : #'slot getters\/setters' }
Player >> getHeight [
	"Answer the height of the object"

	^ self costume height
]

{ #category : #'slot getters\/setters' }
Player >> getHolder [
	"Answer the player belonging to my costume's container"

	^ costume topRendererOrSelf owner topRendererOrSelf assuredPlayer
]

{ #category : #'slot getters\/setters' }
Player >> getIndexInOwner [
	"Answer my costume's index in its owner"

	^ costume getIndexInOwner
]

{ #category : #'slot getters\/setters' }
Player >> getIsLocked [
	"Answer whether the receiver's costume is locked"

	^ costume isLocked
]

{ #category : #misc }
Player >> getIsOverColor: aColor [
	^ self seesColor: aColor
]

{ #category : #'playing commands' }
Player >> getIsRunning [
	^ self sendMessageToCostume: #getIsRunning
]

{ #category : #'slot getters\/setters' }
Player >> getIsUnderMouse [
	"Answer true or false, depending on whether the object currently is or is not under the mouse"

	costume isInWorld ifFalse: [^ false].
	^ costume containsPoint: (costume pointFromWorld: costume primaryHand lastEvent cursorPoint)
]

{ #category : #'slot getters\/setters' }
Player >> getKeepTickingWhilePainting [
	"Answer the value of the keepTickingWhilePainting preference."

	^ Preferences keepTickingWhilePainting
]

{ #category : #'slot getters\/setters' }
Player >> getKnobColor [
	^ self getValueFromCostume: #sliderColor
]

{ #category : #'slot getters\/setters' }
Player >> getLabel [
	"Answer the label of my costume"

	^ self costume renderedMorph label
]

{ #category : #'slot getters\/setters' }
Player >> getLastCharacter [
	"Answer my costume's last character."

	^ costume renderedMorph getLastCharacter
]

{ #category : #'slot getters\/setters' }
Player >> getLastKeystroke [
	"Answer the last keystroke fielded"

	^ Project current world lastKeystroke
]

{ #category : #'slot getters\/setters' }
Player >> getLastValue [

	^ self getValueFromCostume: #lastValue

]

{ #category : #'slot getters\/setters' }
Player >> getLayoutInset [
	"Getter for costume's layoutInset"

	^ costume layoutInset
]

{ #category : #'slot getters\/setters' }
Player >> getLeft [
	"answer the left coordinate"

	^ self costume cartesianBoundsTopLeft x
]

{ #category : #'slot-kedama' }
Player >> getLeftEdgeMode [

	^ self getValueFromCostume: #leftEdgeMode.

]

{ #category : #'slot getters\/setters' }
Player >> getLeftRight [
	^ self getValueFromCostume: #leftRight
]

{ #category : #'slot getters\/setters' }
Player >> getLength [
	"Answer the length of the object"

	| aLength cost |
	((cost  := self costume) isLineMorph) "annoying special case"
		ifTrue:
			[^ cost unrotatedLength].
	aLength := cost renderedMorph height.  "facing upward when unrotated"
	cost isRenderer
		ifTrue:
			[aLength := aLength * cost scaleFactor].
	^ aLength
]

{ #category : #'slot getters\/setters' }
Player >> getListCentering [
	"Getter for costume's listCentering"

	^ costume listCentering
]

{ #category : #'slot getters\/setters' }
Player >> getListDirection [
	"Getter for costume's listDirection"

	^ costume listDirection
]

{ #category : #'slot getters\/setters' }
Player >> getLuminanceUnder [
	^ self costume colorUnder luminance * 100
]

{ #category : #'slot getters\/setters' }
Player >> getMaxVal [
	^  self getValueFromCostume: #maxVal
]

{ #category : #'slot getters\/setters' }
Player >> getMinVal [
	^  self getValueFromCostume: #minVal
]

{ #category : #'slot getters\/setters' }
Player >> getMouseX [
	^ self costume renderedMorph mouseX
]

{ #category : #'slot getters\/setters' }
Player >> getMouseY [
	^ self costume renderedMorph mouseY.

]

{ #category : #'slot getters\/setters' }
Player >> getName [
	^ self externalName
]

{ #category : #'slot getters\/setters' }
Player >> getNewClone [
	"Answer a new player of the same class as the receiver, with a costume much like mine"

	| clone |
	clone :=  costume usableSiblingInstance.
	costume pasteUpMorph ifNotNil: [:parent | parent addMorph: clone].
	^ clone player

]

{ #category : #'slot getters\/setters' }
Player >> getNumberAtCursor [
	"Answer the number borne by the object at my costume's current cursor position"

	| renderedMorph aCostume |
	aCostume := self costume.
	((renderedMorph := aCostume renderedMorph) respondsTo: #valueAtCursor:) ifTrue: [^ renderedMorph valueAtCursor renderedMorph getNumericValue]
]

{ #category : #'slot getters\/setters' }
Player >> getNumericValue [
	"Answer the numeric value contained in my costume"

	^ costume renderedMorph getNumericValue
]

{ #category : #'scripts-standard' }
Player >> getObtrudes [
	"Answer whether the receiver's costume obtrudes beyond the bounds of its container"

	| aCostume |
	(aCostume := self costume) ifNil: [^ false].
	^ aCostume obtrudesBeyondContainer

]

{ #category : #'slot getters\/setters' }
Player >> getOffsetX [

	^ self costume offsetX
]

{ #category : #'slot getters\/setters' }
Player >> getOffsetY [

	^ self costume offsetY
]

{ #category : #'slot getters\/setters' }
Player >> getOliveHandleForScriptedObjects [

	"Answer the value of the oliveHandleForScriptedObjects preference."

	^ Preferences oliveHandleForScriptedObjects
]

{ #category : #'slot getters\/setters' }
Player >> getPageNumber [
	"Answer the current page number of my book"

	| aBook |
	^ (aBook := self bookEmbodied) pageNumberOf: aBook currentPage
]

{ #category : #'slot-kedama' }
Player >> getPatchName [

	^ (self perform: #getPatch) externalName.

]

{ #category : #'slot-kedama' }
Player >> getPatchValueIn: aPatch [

	^ 0.

]

{ #category : #'slot-kedama' }
Player >> getPatchesList [

	^ self getValueFromCostume: #patchesToDisplayAsString.

]

{ #category : #pen }
Player >> getPenArrowheads [
	"Answer a boolean indicating whether the receiver's pen will draw an arrowhead at the end of a stroke"
	^ self actorState getPenArrowheads
]

{ #category : #pen }
Player >> getPenColor [
	"Answer the current pen color"

	^ self actorState getPenColor
]

{ #category : #pen }
Player >> getPenDown [
	"Answer a boolean indicating whether the receiver's pen is currently down (true) or up (false)"
	^ self actorState getPenDown
]

{ #category : #pen }
Player >> getPenSize [
	"Answer a number indicating the current pen size"

	^ self actorState getPenSize
]

{ #category : #'slot-kedama' }
Player >> getPixelsPerPatch [

	^ self getValueFromCostume: #pixelsPerPatch.

]

{ #category : #'slot getters\/setters' }
Player >> getPlayerAtCursor [
	^ self getValueAtCursor
]

{ #category : #'slot getters\/setters' }
Player >> getPosition [
	"Answer the numeric value contained in my costume"
	^ costume renderedMorph getPosition
]

{ #category : #'slot getters\/setters' }
Player >> getRadialGradientFill [
	"Getter for costume's useGradientFill"

	| aStyle |
	^ (self isFillStyle: (aStyle := costume renderedMorph fillStyle)) and:
		[aStyle isGradientFill] and: [aStyle isRadialFill]
]

{ #category : #'slot-kedama' }
Player >> getRedComponentIn: aPatch [
]

{ #category : #'playing commands' }
Player >> getRepeat [
	^ self sendMessageToCostume: #getRepeat
]

{ #category : #'slot-kedama' }
Player >> getReplicated [

]

{ #category : #'slot getters\/setters' }
Player >> getResistsRemoval [
	"Answer whether the receiver is marked to resist removal"

	^ costume resistsRemoval
]

{ #category : #'slot getters\/setters' }
Player >> getRight [
	"Answer the coordinate of the right edge of the object"

	^ self costume cartesianBoundsTopLeft x + self costume width
]

{ #category : #'slot-kedama' }
Player >> getRightEdgeMode [

	^ self getValueFromCostume: #rightEdgeMode.

]

{ #category : #'slot getters\/setters' }
Player >> getRotationStyle [
	"Answer the symbol representing the rotation style"

	^ (#(rotate #'do not rotate' #'flip left right' #'flip up down') at:
		(#(normal none leftRight upDown ) indexOf: costume renderedMorph rotationStyle))
]

{ #category : #'card\/stack commands' }
Player >> getRoundedCorners [
	"Anwer the rounded-corners attribute of my costume"

	^ costume renderedMorph cornerStyle == #rounded
]

{ #category : #'slot getters\/setters' }
Player >> getSampleAtCursor [
	"Note: Performance hacked to allow real-time sound. Assumes costume is a GraphMorph."

	^ costume renderedMorph interpolatedValueAtCursor

]

{ #category : #'slot getters\/setters' }
Player >> getSaturationUnder [
	^ self costume colorUnder saturation * 100
]

{ #category : #'slot getters\/setters' }
Player >> getScale [

	^ self costume scale
]

{ #category : #'slot getters\/setters' }
Player >> getScaleFactor [
	"Answer the scale factor of the object"

	^ self costume scaleFactor
]

{ #category : #'slot getters\/setters' }
Player >> getSecondColor [
	"Getter for costume's second color, if it's using gradient fill; sonst answers white."

	| fil |
	^ ((self isFillStyle: (fil :=  costume renderedMorph fillStyle)) and: [fil isGradientFill])
		ifTrue:
			[fil  colorRamp last value]
		ifFalse:
			[Color white]
]

{ #category : #'slot getters\/setters' }
Player >> getShadowColor [
	"Getter for costume's shadowColor"

	^ costume renderedMorph shadowColor
]

{ #category : #'slot-kedama' }
Player >> getSniffRange [

	^ self getValueFromCostume: #sniffRange.

]

{ #category : #'slot getters\/setters' }
Player >> getSpeed [
	"If user defines a speed slot, it will override this.  This provides a backstop value for use with moveToward:, etc"

	^ 5 
]

{ #category : #'slot getters\/setters' }
Player >> getSticky [
	"Getter for costume's isSticky"

	^ costume isSticky
]

{ #category : #'slot getters\/setters' }
Player >> getStringContents [
	"Answer the String contents"

	^ self costume renderedMorph getCharacters
]

{ #category : #'slot getters\/setters' }
Player >> getSubtitlesFileName [
	"Answer the subtitlesFileName in my costume"
	^ costume renderedMorph getSubtitlesFileName
]

{ #category : #'slot getters\/setters' }
Player >> getTheta [
	"Answer the angle between the positive x-axis and the line connecting the origin and the object's position"

	^ (self getX @ self getY) degrees
]

{ #category : #'slot getters\/setters' }
Player >> getTop [
	"Answer the coordinate of the topmost point of the object, using cartesian sense"

	^ self costume cartesianBoundsTopLeft y
]

{ #category : #'slot-kedama' }
Player >> getTopEdgeMode [

	^ self getValueFromCostume: #topEdgeMode.

]

{ #category : #'playing commands' }
Player >> getTotalFrames [
	"Answer the receiver's costume's totalFrames.  Applies to MPEGMoviePlayerMorphs"

	^ self sendMessageToCostume: #totalFrames

]

{ #category : #'playing commands' }
Player >> getTotalSeconds [
	"Answer the total number of seconds in the receiver's costume, typically a movie"

	^ self sendMessageToCostume: #totalSeconds

]

{ #category : #pen }
Player >> getTrailStyle [
	"Answer the receiver's trailStyle"

	^ self actorState trailStyle
]

{ #category : #'customevents-custom events' }
Player >> getTriggeringObject [
	"Answer the Player that is triggering the current script,
	or the default UnscriptedPlayer if none."

	| rcvr |
	rcvr := GetTriggeringObjectNotification signal.

	^rcvr ifNil: [ self costume presenter standardPlayer ]
		ifNotNil: [ rcvr isMorph
				ifTrue: [ rcvr assuredPlayer ]
				ifFalse: [ rcvr ]]
]

{ #category : #'slot getters\/setters' }
Player >> getTruncate [
	^  self getValueFromCostume: #truncate
]

{ #category : #'slot-kedama' }
Player >> getTurtleCount [

	^ self getValueFromCostume: #turtleCount.

]

{ #category : #'slot-kedama' }
Player >> getTurtleVisible [

	^ self costume visible.

]

{ #category : #'slot-kedama' }
Player >> getTurtlesList [

	^ self getValueFromCostume: #turtlesToDisplayAsString.

]

{ #category : #'slot getters\/setters' }
Player >> getUpDown [
	^ self getValueFromCostume: #upDown
]

{ #category : #'slot-kedama' }
Player >> getUphillIn: aPatch [

	^ self costume heading.


]

{ #category : #'slot getters\/setters' }
Player >> getUseGradientFill [
	"Getter for costume's useGradientFill"

	| fil |
	^ (self isFillStyle: (fil := costume renderedMorph fillStyle))
		ifFalse:
			[false]
		ifTrue:
			[fil isGradientFill]
]

{ #category : #'slot-kedama' }
Player >> getUseLogDisplay [

	^ self getValueFromCostume: #useLogDisplay.

]

{ #category : #'slot getters\/setters' }
Player >> getUseVectorVocabulary [
	"Answer whether to use the vector vocabulary."

	^ Preferences useVectorVocabulary
]

{ #category : #'slot getters\/setters' }
Player >> getVResizing [
	"Getter for costume's vResizing"

	^ costume vResizing
]

{ #category : #'slot getters\/setters' }
Player >> getValueAtCursor [
	| anObject |
	anObject := self getValueFromCostume: #valueAtCursor.
	^ anObject == 0  "weird return from GraphMorph"
		ifTrue:
			[nil]
		ifFalse:
			[anObject assuredPlayer]
]

{ #category : #costume }
Player >> getValueFromCostume: aSelector [
	| aCostume |
	(aCostume := self costumeRespondingTo: aSelector) ifNotNil:
		[^ aCostume perform: aSelector].
	^ nil
]

{ #category : #'slot getters\/setters' }
Player >> getVideoFileName [
	"Answer the videoFileName in my costume"
	^ costume renderedMorph getVideoFileName
]

{ #category : #'slot getters\/setters' }
Player >> getViewingByIcon [
	"Answer whether my costume is currently viewing by icon"

	^ costume renderedMorph viewingNormally
]

{ #category : #'slot getters\/setters' }
Player >> getVolume [
	"Answer the numeric value contained in my costume"
	^ costume renderedMorph getVolume
]

{ #category : #'slot getters\/setters' }
Player >> getWidth [
	"Answer the width of the object"

	| aWidth cost |
	((cost := self costume) isLineMorph) "annoying special case"
		ifTrue:
			[^ cost unrotatedWidth].
	aWidth := cost renderedMorph width.  "facing upward when unrotated"

	cost isRenderer
		ifTrue:
			[aWidth := aWidth * cost scaleFactor].
	^ aWidth
]

{ #category : #'slot getters\/setters' }
Player >> getWrapDirection [
	"Getter for costume's wrapDirection"

	^ costume wrapDirection
]

{ #category : #'slot getters\/setters' }
Player >> getX [
		"emergency patch; unclear why not needed in getY; in any case, have
		 removed the getX/getY retrievals from the viewer in 2.0-final anyway"
	| aCostume |
	(aCostume := self costume) isInWorld ifFalse: [^ 100].
	^ aCostume x
]

{ #category : #'slot getters\/setters' }
Player >> getXAndY [

	^ self getX @ self getY

]

{ #category : #'slot getters\/setters' }
Player >> getY [
	"Answer the y coordinate of the object, relative to its container"

	^ self costume y
]

{ #category : #'card\/stack commands' }
Player >> goToCard: aCard [
	"Install aCard as the new current card of the stack"

	self stackDo: [:aStack | aStack goToCard: aCard]
]

{ #category : #'card\/stack commands' }
Player >> goToFirstCardInBackground [
	"Send the stack to the first card of the current background"

	costume stackDo: [:aStack | aStack goToFirstCardInBackground]
]

{ #category : #'card\/stack commands' }
Player >> goToFirstCardOfStack [
	"Send the stack to the first card of the entire stack"

	costume stackDo: [:aStack | aStack goToFirstCardOfStack]
]

{ #category : #'card\/stack commands' }
Player >> goToLastCardInBackground [
	"Send the stack to the final card of the current background"

	costume stackDo: [:aStack | aStack goToLastCardInBackground]
]

{ #category : #'card\/stack commands' }
Player >> goToLastCardOfStack [
	"Send the stack to the last card of the entire stack"

	costume stackDo: [:aStack | aStack goToLastCardOfStack]
]

{ #category : #'card\/stack commands' }
Player >> goToNextCardInStack [
	"Install the next card into the receiver's stack"

	self costume goToNextCardInStack
]

{ #category : #'card\/stack commands' }
Player >> goToPreviousCardInStack [
	"Install the previous card into the receiver's stack"

	self costume goToPreviousCardInStack
]

{ #category : #'scripts-standard' }
Player >> goToRightOf: aPlayer [ 
	"Place the object so that it lies directly to the right of the given object"

	| hisCostume aCostume |
	(aPlayer isNil or: [aPlayer == self]) ifTrue: [^self].
	(hisCostume := aPlayer costume) isInWorld ifFalse: [^self].
	aCostume := self costume.
	aCostume isWorldMorph ifTrue: [^ self].
	aCostume owner == hisCostume owner 
		ifFalse: [hisCostume owner addMorphFront: aCostume].
	aCostume 
		position: hisCostume bounds rightCenter - (0 @ (aCostume height // 2))
]

{ #category : #'card\/stack commands' }
Player >> goto: aPlayer [
	self sendMessageToCostume: #goto: with: aPlayer
]

{ #category : #'slot-kedama' }
Player >> grabPatchMorph [

	Project current world primaryHand attachMorph: costume renderedMorph.

]

{ #category : #misc }
Player >> grabPlayerIn: aWorld [
	"Invoked from a Viewer: rip my morph out of its container, wherever that may be, and place it in the hand, being careful to set things up so that if the subsequent drop is rejected, the morph will end up in a visible location on the screen"

	| aMorph newPosition |
	self costume == aWorld ifTrue: [^ self].
	self currentHand releaseMouseFocus.
	(aMorph := self costume) visible: true.
	newPosition := self currentHand position - (aMorph extent // 2).
	aMorph isInWorld
		ifTrue:
			[aMorph goHome.
			aMorph formerPosition: aMorph positionInWorld]
		ifFalse:
			[aMorph formerPosition: aWorld center].
	aMorph formerOwner: Project current world.
	aMorph position: newPosition.
	
	self currentHand
		targetOffset: aMorph position - self currentHand position;
		addMorphBack: aMorph.
]

{ #category : #misc }
Player >> grabPlayerInActiveWorld [
	"Invoked from a Viewer: rip my morph out of its container, wherever that may be, and place it in the hand, being careful to set things up so that if the subsequent drop is rejected, the morph will end up in a visible location on the screen"

	^ self grabPlayerIn: Project current world
]

{ #category : #misc }
Player >> grabScriptorForSelector: itsSelector in: aWorld [
	"Grab the scriptor for the given selector and place it in the hand"

	| editor |
	editor := self scriptEditorFor: itsSelector.
	editor fixLayout.
	aWorld currentHand attachMorph: (editor).
	
	
	
	
	

	
	
]

{ #category : #viewer }
Player >> graphicForViewerTab [
	"Answer the graphic to show in the tab of a Viewer looking at me"

	^ self costume renderedMorph
]

{ #category : #'slot-kedama' }
Player >> greenComponentFrom: another [

	costume renderedMorph greenComponentFrom: another costume renderedMorph.


]

{ #category : #'slot-kedama' }
Player >> greenComponentInto: another [

	costume renderedMorph greenComponentInto: another costume renderedMorph.


]

{ #category : #'slot getters\/setters' }
Player >> handTheUserACopy [
	"Called from the user-interface: hand the user a copy"

	^ costume currentHand attachMorph: self getNewClone costume
]

{ #category : #testing }
Player >> hasAnyBorderedCostumes [
	"Answer true if any costumes of the receiver are BorderedMorph descendents"

	self costumesDo:
		[:cost | (cost understandsBorderVocabulary) ifTrue: [^ true]].
	^ false
]

{ #category : #costume }
Player >> hasCostumeThatIsAWorld [

	self costumesDo: [ :aCostume | (aCostume isWorldMorph) ifTrue: [^ true]].
	^ false
]

{ #category : #costume }
Player >> hasOnlySketchCostumes [
	"Answer true if the only costumes assocaited with this Player are SketchMorph costumes"

	self costumesDo: [ :aCostume | aCostume isSketchMorph ifFalse: [^ false]].
	^ true
]

{ #category : #'scripts-kernel' }
Player >> hasScriptInvoking: scriptName ofPlayer: aPlayer [
	"Answer whether the receiver bears any script that invokes a script of the given name for  the given player"
	self allScriptEditors do:
		[:anEditor | (anEditor hasScriptInvoking: scriptName ofPlayer: aPlayer) ifTrue: [^ true]].
	^ false
]

{ #category : #'scripts-kernel' }
Player >> hasScriptReferencing: slotName ofPlayer: aPlayer [
	"Answer whether the receiver bears any script that references a slot of the given name for  the given player"
	self allScriptEditors do:
		[:anEditor | (anEditor hasScriptReferencing: slotName ofPlayer: aPlayer) ifTrue: [^ true]].
	^ false
]

{ #category : #'slots-user' }
Player >> hasUserDefinedScripts [
	^self class scripts notEmpty
]

{ #category : #viewer }
Player >> hasUserDefinedSlots [
	^self class slotInfo notEmpty
]

{ #category : #heading }
Player >> headDown [

	| radians |
	radians := (self getHeadingUnrounded - 90.0) degreesToRadians.
	self setHeading:
		(radians cos @ radians sin abs) theta radiansToDegrees + 90.0.

]

{ #category : #heading }
Player >> headLeft [

	| radians |
	radians := (self getHeadingUnrounded - 90.0) degreesToRadians.
	self setHeading: (radians cos abs negated @ radians sin) theta radiansToDegrees + 90.0.

]

{ #category : #heading }
Player >> headRight [

	| radians |
	radians := (self getHeadingUnrounded - 90.0) degreesToRadians.
	self setHeading: (radians cos abs @ radians sin) theta radiansToDegrees + 90.0.

]

{ #category : #heading }
Player >> headUp [

	| radians |
	radians := (self getHeadingUnrounded - 90.0) degreesToRadians.
	self setHeading: (radians cos @ radians sin abs negated) theta radiansToDegrees + 90.0.

]

{ #category : #'scripts-standard' }
Player >> hide [
	"Make the object be hidden, as opposed to visible"

	self currentHand ifNotNil: [:hand |
		(hand keyboardFocus == self costume renderedMorph) ifTrue: [
			hand releaseKeyboardFocus]].
	self costume hide.
]

{ #category : #misc }
Player >> impartSketchScripts [
	"Let the user designate another object to which my scripts and code should be imparted"

	| aMorph |
	Sensor waitNoButton.
	aMorph := Project current world chooseClickTarget.
	aMorph ifNil: [^ self].
	(aMorph renderedMorph isSketchMorph) ifTrue: [
		aMorph acquirePlayerSimilarTo: self].
]

{ #category : #'scripts-standard' }
Player >> include: anObject [
	"Add the object to my content"

	^ self append: anObject
]

{ #category : #'scripts-standard' }
Player >> includeAtCursor: aPlayer [ 
	"Add aPlayer to the list of objects logically 'within' me, at my current cursor position. ."

	| aCostume |
	(aPlayer isNil or: [aPlayer == self]) ifTrue: [^self].
	(aPlayer isText or: [aPlayer isString]) 
		ifTrue: 
			[^ self costume class == TextFieldMorph 
				ifTrue: [self costume append: aPlayer]
				ifFalse: [self]].
	aCostume := self costume topRendererOrSelf.
	(aCostume isKindOf: PasteUpMorph) 
		ifTrue:
			[aCostume addMorph: aPlayer costume asElementNumber: self getCursor.
			aCostume updateSubmorphThumbnails]  "also forces redraw"
		ifFalse:
			[aCostume addMorphBack: aPlayer.
			self setCursor: aCostume submorphs size].
	aPlayer costume goHome.	"assure it's in view"

]

{ #category : #'scripts-vector' }
Player >> incr: aPlayer [
	"Treating Players like vectors, add aPlayer to me"

	self setX: self getX + aPlayer asPoint x.
	self setY: self getY + aPlayer asPoint y.

]

{ #category : #misc }
Player >> indicateLocationOnScreen [
	"Give momentary feedback on screen until mouse button is clicked"

	| bds |
	bds := self costume boundsInWorld.
	5 timesRepeat:
		[Display reverse: bds.
		(Delay forMilliseconds: 80) wait.
		Display reverse: bds.
		(Delay forMilliseconds: 200) wait.].
	costume changed
]

{ #category : #viewer }
Player >> infoFor: anElement inViewer: aViewer [ 
	"The user made a gesture asking for info/menu relating"

	| aMenu elementType aSelector |
	elementType := self elementTypeFor: anElement
				vocabulary: aViewer currentVocabulary.
	elementType = #systemSlot | (elementType == #userSlot) 
		ifTrue: [^self slotInfoButtonHitFor: anElement inViewer: aViewer].
	aMenu := MenuMorph new defaultTarget: self.
	aMenu defaultTarget: self.
	aSelector := anElement asSymbol.
	elementType == #userScript 
		ifTrue: 
			[aMenu 
				add: 'destroy "' translated , anElement , '"'
				selector: #removeScriptWithSelector:
				argument: aSelector.
			aMenu 
				add: 'rename  "' translated, anElement , '"'
				selector: #renameScript:
				argument: aSelector.
			aSelector numArgs > 0 
				ifTrue: 
					[aMenu 
						add: 'remove parameter' translated
						selector: #ceaseHavingAParameterFor:
						argument: aSelector]
				ifFalse: 
					[aMenu 
						add: 'add parameter' translated
						selector: #startHavingParameterFor:
						argument: aSelector.
					aMenu 
						add: 'button to fire this script' translated
						selector: #tearOffButtonToFireScriptForSelector:
						argument: aSelector].
			aMenu 
				add: 'edit balloon help' translated
				selector: #editDescriptionForSelector:
				argument: aSelector].
	aMenu items isEmpty 
		ifTrue: 
			["Never 0 at the moment because of show categories addition"

			aMenu add: 'ok' translated action: nil].
	aMenu popUpInWorld: aViewer world
]

{ #category : #viewer }
Player >> initialTypeForSlotNamed: aName [
	"Answer the initial type to be ascribed to the given instance variable"

	^ #Number
]

{ #category : #'slots-user' }
Player >> initialValueForSlotOfType: aType [
	"Answer the default initial value to ascribe to a slot of the given type"

	^ (Vocabulary vocabularyForType: aType)
		initialValueForASlotFor: self
]

{ #category : #copying }
Player >> initializeCostumesFrom: aPlayer [
	"Used to copy costume info over from an UnscriptedPlayer to a Player UniClass"
	costume := aPlayer costume.
	costumes := aPlayer costumes
]

{ #category : #'scripts-standard' }
Player >> initiatePainting [
	(self costume isKindOf: PasteUpMorph) ifTrue:
		[self costume makeNewDrawingWithin]
]

{ #category : #'card\/stack commands' }
Player >> insertCard [
	"Insert a new card into the stack"

	self costume stackDo: [:aStack | aStack insertCard]
]

{ #category : #'scripts-standard' }
Player >> insertCharacters: aString [
	"Insert the given characters at my current cursor position"

	self costume renderedMorph insertCharacters: aString
]

{ #category : #'scripts-standard' }
Player >> insertContentsOf: aPlayer [
	"Insert the string contents of the given player at my given cursor position"

	self costume renderedMorph insertContentsOf: aPlayer
]

{ #category : #'customevents-scripts-kernel' }
Player >> instantiatedUserScriptsDo: aBlock [
	"Evaluate aBlock on behalf of all the instantiated user scripts in the receiver"

	| aState aCostume |
	((aCostume := self costume) notNil and: [(aState := aCostume actorStateOrNil) notNil]) ifTrue:
		[aState instantiatedUserScriptsDictionary do: aBlock]
]

{ #category : #'scripts-kernel' }
Player >> isEmptyTileScript: aScriptName [
	"Answer whether the script of the given name is an empty classic tile script.  Presently disused -- formerly it was all too easy to propagate many empty tile scripts but this difficulty has receded considerably with recent changes, so this has no senders other than from an unusual menu item, and will perhaps die soon"

	| aUserScript |
	Preferences universalTiles ifTrue: [^ false].
	aUserScript := self class userScriptForPlayer: self selector: aScriptName.
	^ (aUserScript instantiatedScriptEditorForPlayer: self) isEmpty

]

{ #category : #'scripts-kernel' }
Player >> isExpendableScript: aScriptName [
	^ (self isEmptyTileScript: aScriptName) and:
		[aScriptName beginsWith: self defaultScriptName]

]

{ #category : #'slot-kedama' }
Player >> isGroup: aBoolean [

	self setCostumeSlot: #isGroup: toValue: aBoolean.

]

{ #category : #testing }
Player >> isPlayer [
	^true
]

{ #category : #viewer }
Player >> isPlayerLike [
	"Return true if the receiver is a player-like object"
	^true
]

{ #category : #'slot-kedama' }
Player >> isPrototypeTurtlePlayer [

	^ false.
"
	costume ifNil: [^ false].
	^ costume renderedMorph isMemberOf: KedamaTurtleMorph
"
]

{ #category : #'slot-kedama' }
Player >> isSequentialStub [

	^ false.

]

{ #category : #macpal }
Player >> isUniversalTiles [
	"Return true if I (my world) uses universal tiles.  This message can be called in places where the current World is not known, such as when writing out a project.  For information about the writingUniversalTiles thing, contact Ted Kaehler."

	^ costume world
		ifNil:
			[ScriptEditorMorph writingUniversalTiles == true  "only valid during a project write"]
		ifNotNil:
			[Preferences universalTiles]
]

{ #category : #testing }
Player >> knownName [
	"Answer a name by which the receiver is known, or nil if none"

	^ costume knownName
]

{ #category : #costume }
Player >> knownSketchCostumeWithSameFormAs: aSketchMorph [ 
	| itsForm |
	itsForm := aSketchMorph form.
	^ costumes
		ifNotNil: [costumes
				detect: [:c | c isSketchMorph
						and: [c form == itsForm]]
				ifNone: []]
]

{ #category : #translation }
Player >> labelFromWatcher: w [
	"Answer the morph holding the label of the given watcher"

	^ w owner owner submorphs third submorphs second
]

{ #category : #'card\/stack commands' }
Player >> lastPage [
	self sendMessageToCostume: #lastPage
]

{ #category : #pen }
Player >> liftAllPens [
	self costume liftAllPens
]

{ #category : #pen }
Player >> liftPen [
	self actorState liftPen
]

{ #category : #'scripts-standard' }
Player >> loadSineWave [

	self sendMessageToCostume: #loadSineWave.

]

{ #category : #'scripts-standard' }
Player >> loadSound: soundName [

	| snd |
	snd := SoundService default soundNamed: soundName.
	snd ifNotNil: [self sendMessageToCostume: #loadSound: with: snd].

]

{ #category : #pen }
Player >> lowerAllPens [
	self costume lowerAllPens
]

{ #category : #pen }
Player >> lowerPen [
	self actorState lowerPen
]

{ #category : #misc }
Player >> makeBounceSound: soundName [
	"Having bounced off an edge, produce the given sound"

	SoundService soundEnabled
		ifTrue: [self costume playSoundNamed: soundName]
]

{ #category : #'scripts-kernel' }
Player >> makeIsolatedCodePaneForSelector: aSelector [
	"make an isolated code pane for the given selector"

	MethodHolder makeIsolatedCodePaneForClass: self class selector: aSelector

]

{ #category : #'scripts-standard' }
Player >> makeNewDrawingIn: paintPlacePlayer [ 
	| paintPlace |
	((paintPlacePlayer isNil 
		or: [((paintPlace := paintPlacePlayer costume) isKindOf: PasteUpMorph) not]) 
			or: [paintPlace isInWorld not]) 
			ifTrue: 
				[^self 
					inform: 'Error: not a plausible
place in which to make
a new drawing'].
	paintPlace makeNewDrawingWithin
]

{ #category : #'scripts-standard' }
Player >> menuItemAfter: menuString [
	^ self costume menuItemAfter: menuString
]

{ #category : #'scripts-standard' }
Player >> menuItemBefore: menuString [
	^ self costume menuItemBefore: menuString
]

{ #category : #'scripts-kernel' }
Player >> methodInterfaceForEmptyScript [
	"Answer a MethodInterface representing Andreas's 'emptyScript' feature"

	| anInterface |
	anInterface := MethodInterface new.
	anInterface receiverType: #Player.
	anInterface flagAttribute: #scripts.
	anInterface
		wording: (ScriptingSystem wordingForOperator: #emptyScript);
		helpMessage: 'an empty script; drop on desktop to get a new empty script for this object'.

	anInterface selector: #emptyScript type: nil setter: nil.
	^ anInterface
]

{ #category : #'slots-kernel' }
Player >> methodInterfacesForInstanceVariablesCategoryIn: aVocabulary [
	"Return a collection of methodInterfaces for the instance-variables category.  The vocabulary parameter, at present anyway, is not used."

	| aList |
	aList := OrderedCollection new.
	self slotInfo associationsDo:
		[:assoc | | itsSlotName anInterface |
			anInterface := MethodInterface new.
			itsSlotName := assoc key.
			anInterface
				wording: itsSlotName;
				helpMessage: 'a variable defined by this object' translated.

			anInterface selector: (itsSlotName asGetterSelector) type: assoc value type setter: (itsSlotName asSetterSelector).
			anInterface setToRefetch.
			aList add: anInterface].
	^ aList
]

{ #category : #scripting }
Player >> methodInterfacesForScriptsCategoryIn: aVocabulary [
	"Answer a list of method interfaces for the category #scripts, as seen in a viewer or other tool.  The vocabulary argument is not presently used."

	| myScripts |
	myScripts := self class scripts values collect: [:us |
		(us isKindOf: UserScript)
			ifTrue: [us as: MethodWithInterface]
			ifFalse: [us]].
	^ {self methodInterfaceForEmptyScript}, myScripts
]

{ #category : #'scripts-standard' }
Player >> moveToward: aPlayer [
	"Move a standard amount in the direction of the given player.  If the object has an instance variable named 'speed', the speed of the motion will be governed by that value"

	| myPosition itsPosition dist delta |
	((aPlayer ~~ self) and: [(self overlaps: aPlayer) not]) ifTrue:
		[((myPosition := self costume referencePosition) = (itsPosition := aPlayer costume referencePosition))
			ifFalse:
				[self setHeading: (myPosition bearingToPoint: itsPosition).
				delta := myPosition - itsPosition.
				dist := (delta x * delta x + (delta y * delta y)) sqrt.
				self forward: (self getSpeed min: dist)]]
]

{ #category : #'scripts-vector' }
Player >> multBy: aNumber [
	"Treating Players like vectors, scale myself by aNumber"

	self setX: self getX * aNumber asPoint x.
	self setY: self getY * aNumber asPoint y.

]

{ #category : #testing }
Player >> nameForViewer [
	"Answer the name to be used for the receiver in its Viewer"

	^ self getName
]

{ #category : #costume }
Player >> newCostume [

	| aMenu reply |
	aMenu := SelectionMenu selections: self availableCostumeNames.
	(reply := aMenu startUpWithCaption: 'choose a costume' translated) ifNil: [^ self].
	self wearCostumeOfName: reply.
	self updateAllViewers
]

{ #category : #'slot-kedama' }
Player >> newPatch [

	| f usedNames newName |
	f := KedamaPatchMorph newExtent: self costume renderedMorph dimensions.
	f assuredPlayer assureUniClass.
	f kedamaWorld: self costume renderedMorph.
	usedNames := Project current world allKnownNames, self class instVarNames.
	newName := Utilities keyLike: f innocuousName satisfying:
		[:aName | (usedNames includes: aName) not].
	f setNameTo: newName.
	self createSlotForPatch: f.
	self addToPatchDisplayList: f assuredPlayer.
	self costume world primaryHand attachMorph: f.
	^ f
]

{ #category : #viewer }
Player >> newScriptorAround: aPhrase [
	"Sprout a scriptor around aPhrase, thus making a new script.  aPhrase may either be a PhraseTileMorph (classic tiles 1997-2001) or a SyntaxMorph (2001 onward)"

	| aScriptEditor aUniclassScript tw blk |
Cursor wait showWhile: [
	aUniclassScript := self class permanentUserScriptFor: self unusedScriptName player: self.
	aScriptEditor := aUniclassScript instantiatedScriptEditorForPlayer: self.

	Preferences universalTiles ifTrue: [
		aScriptEditor install.
		"aScriptEditor hResizing: #shrinkWrap;
			vResizing: #shrinkWrap;
			cellPositioning: #topLeft;
			setProperty: #autoFitContents toValue: true."
		aScriptEditor insertUniversalTiles.  "Gets an empty SyntaxMorph for a MethodNode"
		tw := aScriptEditor findA: ScrollPane.
		aPhrase ifNotNil:
			[blk := (tw scroller findA: SyntaxMorph "MethodNode") findA: BlockNode.
			blk addMorphFront: aPhrase.
			aPhrase accept.
		].
		SyntaxMorph setSize: nil andMakeResizable: aScriptEditor.
	] ifFalse: [
		aPhrase 
				ifNotNil: [aScriptEditor phrase: aPhrase]	"does an install"
				ifNil: [aScriptEditor install]
	].
	self class allSubInstancesDo: [:anInst | anInst scriptInstantiationForSelector: aUniclassScript selector].
		"The above assures the presence of a ScriptInstantiation for the new selector in all siblings"
	self updateScriptsCategoryOfViewers.
].
	^ aScriptEditor
]

{ #category : #'scripts-kernel' }
Player >> newTextualScriptorFor: aSelector [
	"Sprout a scriptor for aSelector, opening up in textual mode.  Rather special-purpose, consult my lone sender"

	| aMethodWithInterface aScriptEditor |
	(self class includesSelector: aSelector) ifTrue: [self error: 'selector already exists'].

	aMethodWithInterface := self class permanentUserScriptFor: aSelector player: self.
	aScriptEditor := aMethodWithInterface instantiatedScriptEditorForPlayer: self.
	aScriptEditor install.
	aScriptEditor showSourceInScriptor.
	aMethodWithInterface selector numArgs = 0 ifTrue:
		[self class allSubInstancesDo: [:anInst | anInst scriptInstantiationForSelector: aMethodWithInterface selector]].
		"The above assures the presence of a ScriptInstantiation for the new selector in all siblings"

	self updateAllViewersAndForceToShow: #scripts.
	^ aScriptEditor
]

{ #category : #'slot-kedama' }
Player >> newTurtle [

	| m |
	m := KedamaTurtleMorph new openInWorld.
	self costume renderedMorph hasNoTurtleBreed ifTrue: [m color: Color red].
	self useTurtle: m player.
	m setNameTo: (Project current world unusedMorphNameLike: m innocuousName).
	self costume world primaryHand attachMorph: m.
	^ m
]

{ #category : #'slot-kedama' }
Player >> newTurtleSilently [

	| m |
	m := KedamaTurtleMorph new openInWorld.
	self useTurtle: m player.
	m turtleCount: 0.
	m setNameTo: (Project current world unusedMorphNameLike: m innocuousName).
	^ m
]

{ #category : #'card\/stack commands' }
Player >> nextPage [
	self sendMessageToCostume: #nextPage
]

{ #category : #pen }
Player >> noArrowheadsOnAllPens [
	"Only for the Player of a Playfield"

	self costume noArrowheadsOnAllPens
]

{ #category : #misc }
Player >> noteDecimalPlaces: aNumber forGetter: aGetter [
	"Note the given preference of decimal places for the given getter"
	| slotInfo |
	slotInfo := self slotInfoForGetter: aGetter.
	slotInfo ifNotNil:[ slotInfo floatPrecision: (Utilities floatPrecisionForDecimalPlaces: aNumber)].
	costume noteDecimalPlaces: aNumber forGetter: aGetter
]

{ #category : #'customevents-misc' }
Player >> noteDeletionOf: aMorph fromWorld: aWorld [
	"aMorph, while pointing to me as its costumee, has been deleted"
	"This may be too aggressive because deletion of a morph may not really mean deletion of its associated player -- in light of hoped-for multiple viewing"

	| viewers scriptors viewerFlaps |
	viewers := OrderedCollection new.
	viewerFlaps := OrderedCollection new.
	scriptors := OrderedCollection new.
	aWorld allMorphs do:
		[:m | m isAViewer ifTrue: [viewers add: m].
			((m isKindOf: ViewerFlapTab) and: [m scriptedPlayer == self])
				ifTrue:
					[viewerFlaps add: m].
			((m isKindOf: ScriptEditorMorph) and: [m myMorph == aMorph])
				ifTrue: [scriptors add: m]].

	aMorph  removeAllEventTriggersFor: self.
	aWorld removeAllEventTriggersFor: self.
	viewers do: [:v |  v noteDeletionOf: aMorph].
	viewerFlaps do: [:v  | v dismissViaHalo].
	scriptors do: [:s | s privateDelete] 
]

{ #category : #'scripts-kernel' }
Player >> noteRenameOf: oldSlotName to: newSlotName inPlayer: aPlayer [
	"Note that aPlayer has renamed a slot formerly known as oldSlotName to be newSlotName"

	self allScriptEditors do:
		[:anEditor | (anEditor showingMethodPane not and: [anEditor hasScriptReferencing: oldSlotName ofPlayer: aPlayer]) ifTrue: 
			[anEditor replaceReferencesToSlot: oldSlotName inPlayer: aPlayer with: newSlotName]]
]

{ #category : #misc }
Player >> offerAlternateViewerMenuFor: aViewer event: evt [
	"Put up an alternate Viewer menu on behalf of the receiver."

	| menu world  |
	world := aViewer world.
	menu := MenuMorph new defaultTarget: self.
	(costumes notNil and: [
		(costumes size > 1 or: [costumes size == 1 and: [costumes first ~~ costume renderedMorph]])]) ifTrue:
				[menu add: 'forget other costumes' translated target: self selector: #forgetOtherCostumes].
	
	menu add: 'expunge empty scripts' translated target: self action: #expungeEmptyScripts.
	menu addLine.
	menu
		add: 'choose vocabulary...' translated target: aViewer action: #chooseVocabulary;
		balloonTextForLastItem: 'Choose a different vocabulary for this Viewer.' translated.
	menu
		add: 'choose limit class...' translated target: aViewer action: #chooseLimitClass;
		balloonTextForLastItem: 'Specify what the limitClass should be for this Viewer -- i.e., the most generic class whose methods and categories should be considered here.' translated.
	
	menu
		add: 'open standard lexicon' translated target: aViewer action: #openLexicon;
		balloonTextForLastItem: 'open a window that shows the code for this object in traditional programmer format' translated.
	
	menu
		add: 'open lexicon with search pane' translated target: aViewer action: #openSearchingProtocolBrowser;
		balloonTextForLastItem: 'open a lexicon that has a type-in pane for search (not recommended!)' translated.
	
	
	menu addLine.
	menu add: 'inspect morph' translated target: costume selector: #inspect.
	menu add: 'inspect player' translated target: self selector: #inspect.
	self belongsToUniClass ifTrue: [
		menu add: 'browse class' translated target: self action: #browsePlayerClass.
		menu add: 'inspect class' translated target: self class action: #inspect].
	menu add: 'inspect this Viewer' translated target: aViewer selector: #inspect.
	menu add: 'inspect this Vocabulary' translated target: aViewer currentVocabulary selector: #inspect.
	
	menu addLine.
	menu add: 'relaunch this Viewer' translated target: aViewer action: #relaunchViewer.
	menu add: 'attempt repairs' translated target: Project current world action: #attemptCleanup.
	menu add: 'destroy all this object''s scripts' translated target: self action: #destroyAllScripts.
	menu add: 'view morph directly' translated target: aViewer action: #viewMorphDirectly.
	menu balloonTextForLastItem: 'opens a Viewer directly on the rendered morph.' translated.
	costume renderedMorph isSketchMorph ifTrue: [
		menu addLine.
		menu add: 'impart scripts to...' translated target: self action: #impartSketchScripts].
	
	^ menu popUpEvent: evt in: world
]

{ #category : #'slots-user' }
Player >> offerGetterTiles: slotName [ 
	"For a player-type slot, offer to build convenient compound tiles that otherwise would be hard to get"

	| typeChoices typeChosen thePlayerThereNow slotChoices slotChosen getterTiles aCategoryViewer playerGetter |
	typeChoices := Vocabulary typeChoices.
	typeChosen := UIManager default 
		chooseFrom: (typeChoices collect: [:t | t translated]) 
		values: typeChoices
		title: ('Choose the TYPE
of data to get from
{1}''s {2}' translated format: {self externalName. slotName translated}).
	typeChosen isEmptyOrNil ifTrue: [^self].
	thePlayerThereNow := self perform: slotName asGetterSelector.
	thePlayerThereNow 
		ifNil: [thePlayerThereNow := self presenter standardPlayer].
	slotChoices := thePlayerThereNow slotNamesOfType: typeChosen.
	slotChoices isEmpty 
		ifTrue: [^self inform: 'sorry -- no slots of that type' translated].
	slotChoices sort.
	slotChosen := UIManager default 
		chooseFrom: (slotChoices collect: [:t | t translated]) 
		values: slotChoices
		title: ('Choose the datum
you want to extract from {1}''s {2}' translated format: {self externalName. slotName translated}).
	slotChosen isEmptyOrNil ifTrue: [^self].
	"Now we want to tear off tiles of the form
		holder's valueAtCursor's foo"
	getterTiles := nil.
	aCategoryViewer := CategoryViewer new initializeFor: thePlayerThereNow
				categoryChoice: 'basic'.
	getterTiles := aCategoryViewer 
				getterTilesFor: slotChosen asGetterSelector
				type: typeChosen.
	aCategoryViewer := CategoryViewer new initializeFor: self
				categoryChoice: 'basic'.
	playerGetter := aCategoryViewer 
				getterTilesFor: slotName asGetterSelector
				type: #Player.
	getterTiles submorphs first acceptDroppingMorph: playerGetter event: nil.	"the pad"	"simulate a drop"
	getterTiles makeAllTilesGreen.
	getterTiles justGrabbedFromViewer: false.
	(getterTiles firstSubmorph)
		changeTableLayout;
		hResizing: #shrinkWrap;
		vResizing: #spaceFill.
	self currentHand attachMorph: getterTiles.
]

{ #category : #misc }
Player >> offerViewerMenuFor: aViewer event: evt [
	"Put up the Viewer menu on behalf of the receiver.  If the shift key is held down, put up the alternate menu. The menu omits the 'add a new variable' item when in eToyFriendly mode, as per request from teachers using Squeakland in 2003 once the button for adding a new variable was added to the viewer"

	| aMenu aWorld  |
	(evt notNil and: [evt shiftPressed and: [Preferences eToyFriendly not]]) ifTrue:
		[^ self offerAlternateViewerMenuFor: aViewer event: evt].

	aWorld := aViewer world.
	aMenu := MenuMorph new defaultTarget: self.
	aMenu title: self externalName.
	aMenu addStayUpItem.

	self costume renderedMorph offerCostumeViewerMenu: aMenu.

	Preferences eToyFriendly ifFalse: "exclude this from squeakland-like UI "
		[aMenu add: 'add a new variable' translated target: self action: #addInstanceVariable.
		aMenu balloonTextForLastItem: 'Add a new variable to this object and all of its siblings.  You will be asked to supply a name for it.' translated].

	aMenu add: 'add a new script' translated target: aViewer action: #newPermanentScript.
	aMenu balloonTextForLastItem: 'Add a new script that will work for this object and all of its siblings' translated.
	aMenu addLine.
	aMenu add: 'grab this object' translated target: self selector: #grabPlayerIn: argument: aWorld.
	aMenu balloonTextForLastItem: 'This will actually pick up the object this Viewer is looking at, and hand it to you.  Click the (left) button to drop it' translated.

	aMenu add: 'reveal this object' translated target: self selector: #revealPlayerIn: argument: aWorld.
	aMenu balloonTextForLastItem: 'If you have misplaced the object that this Viewer is looking at, use this item to (try to) make it visible' translated.

	aMenu add: 'tile representing this object' translated action: #tearOffTileForSelf.
	aMenu balloonTextForLastItem: 'choose this to obtain a tile which represents the object associated with this script' translated.
	aMenu addLine.

	aMenu add: 'add a search pane' translated target: aViewer action: #addSearchPane.
	aMenu add: 'Toggle showing name' translated target: self action: #toggleShowName.
	Preferences eToyFriendly ifFalse: [
		aMenu addLine.
		aMenu add: 'more...' translated target: self selector: #offerAlternateViewerMenuFor:event: argumentList: {aViewer. evt}].

	aMenu popUpEvent: evt in: aWorld

]

{ #category : #'scripts-kernel' }
Player >> okayToDestroyScriptNamed: scriptName [
	self costume world presenter allExtantPlayers do:
		[:aPlayer | (aPlayer hasScriptInvoking: scriptName ofPlayer: self)
			ifTrue:
				[^ false]].
	^ true
]

{ #category : #'scripts-kernel' }
Player >> okayToRemoveSlotNamed: aSlotName [
	(self costume renderedMorph isMemberOf: KedamaMorph) ifTrue: [
		aSlotName = 'patch' ifTrue: [^ false].
	].
	self costume world presenter allExtantPlayers do:
		[:aPlayer | (aPlayer hasScriptReferencing: aSlotName ofPlayer: self)
			ifTrue:
				[^ false]].
	^ true
]

{ #category : #misc }
Player >> openUnderlyingScriptorFor: aSelector [
	"Open the underlying scriptor for the given selector"

	self grabScriptorForSelector: aSelector in: self currentWorld
]

{ #category : #misc }
Player >> ordinalNumber [
	"Answer a number indicating the relative position of the receiver in its stack, if any, else 1"

	| aStack |
	^ (aStack := self stack) ifNotNil: [aStack cardIndexOf: self] ifNil: [nil]
]

{ #category : #misc }
Player >> overlaps: aPlayer [ 
	"Answer whether my costume overlaps that of another player"

	| goalCostume intersection |
	aPlayer ifNil: [^false].
	goalCostume := aPlayer costume.
	costume world == goalCostume world ifFalse: [^false].

	"check if the 2 player costumes intersect"
	intersection := costume bounds intersect: goalCostume bounds.
	(intersection width = 0 or: [intersection height = 0]) 
		ifTrue: [^false]
		ifFalse: 
			[ ^self costume overlapsShadowForm: goalCostume imageForm stencil bounds: goalCostume fullBounds ]
]

{ #category : #'scripts-standard' }
Player >> overlapsAny: aPlayer [ 
	"Answer true if my costume overlaps that of aPlayer, or any of its  
	siblings (if aPlayer is a scripted player)  
	or if my costume overlaps any morphs of the same class (if aPlayer is  
	unscripted)."
	| possibleCostumes itsCostume itsCostumeClass myShadow |
	(self ~= aPlayer
			and: [self overlaps: aPlayer])
		ifTrue: [^true].
	possibleCostumes := IdentitySet new.
	aPlayer belongsToUniClass
		ifTrue: [aPlayer class
				allSubInstancesDo: [:anInstance | (anInstance ~~ self
							and: [itsCostume := anInstance costume.
								(itsCostume bounds intersects: costume bounds)
									and: [itsCostume world == costume world]])
						ifTrue: [possibleCostumes add: itsCostume]]]
		ifFalse: [itsCostumeClass := aPlayer costume class.
			self costume world presenter allExtantPlayers
				do: [:ep | self ~= ep ifTrue:[ ep costume 
						ifNotNil: [:ea | (ea class == itsCostumeClass
									and: [ea bounds intersects: costume bounds])
								ifTrue: [possibleCostumes add: ea]]]]].
	possibleCostumes isEmpty
		ifTrue: [^ false].
	myShadow := costume shadowForm.
	^possibleCostumes
		anySatisfy: [:m | m overlapsShadowForm: myShadow bounds: costume fullBounds].
	

]

{ #category : #'customevents-scripts-kernel' }
Player >> pacifyScript: aSymbol [
	"Make sure the script represented by the symbol doesn't do damage by lingering in related structures on the morph side"

	| aUserScript |
	aUserScript := self class userScriptForPlayer: self selector: aSymbol.
	aUserScript ifNil: [self flag: #deferred.  ^ Beeper beep].  
	"Maddeningly, without this line here the thing IS nil and the debugger is in a bad state
	(the above note dates from 1/12/99 ?!"

	self class allInstancesDo:
		[:aPlayer | | itsCostume aHandler |
		aPlayer actorState instantiatedUserScriptsDictionary removeKey: aSymbol ifAbsent: [].
		itsCostume := aPlayer costume renderedMorph.
		(aHandler := itsCostume eventHandler) ifNotNil:
			[aHandler forgetDispatchesTo: aSymbol].
		itsCostume removeEventTrigger: aSymbol ]
]

{ #category : #'scripts-standard' }
Player >> pauseAll: scriptName [
	"Change the status of my script of the given name to be #paused in me and all of my siblings."

	self assignStatus: #paused toAllFor: scriptName
]

{ #category : #'scripts-standard' }
Player >> pauseScript: scriptName [
	"Change the status of my script of the given name to be #paused"

	self changeScript: scriptName toStatus: #paused
]

{ #category : #pen }
Player >> penColor: aColor [
	self actorState penColor: aColor
]

{ #category : #'scripts-standard' }
Player >> performScriptIfCan: scriptNameString [ 
	"If I understand the given script name, perform it now"
	^Symbol
		hasInterned: scriptNameString
		ifTrue: [:sym | (self class includesSelector: sym)
				ifTrue: [self triggerScript: sym]]
]

{ #category : #'playing commands' }
Player >> play [
	self sendMessageToCostume: #play
]

{ #category : #'playing commands' }
Player >> playUntilPosition: aNumber [

	 self sendMessageToCostume: #playUntilPosition: with: aNumber
]

{ #category : #'scripts-execution' }
Player >> prepareToBeRunning [
	self instantiatedUserScriptsDo:
		[:aScriptInstantiation | aScriptInstantiation prepareToBeRunning].
]

{ #category : #'scripts-standard' }
Player >> prepend: aPlayer [ 
	"Add aPlayer to the list of objects logically 'within' me.  This is visually represented by its morph becoming my costume's first submorph.   Also allow text to be prepended."

	| aCostume |
	(aPlayer isNil or: [aPlayer == self]) ifTrue: [^self].
	(aPlayer isText or: [aPlayer isString]) 
		ifTrue: 
			[^ self costume class == TextFieldMorph 
				ifTrue: [self costume prepend: aPlayer]
				ifFalse: [self]].
	(aCostume := self costume topRendererOrSelf) 
		addMorphFront: aPlayer costume.
	aPlayer costume goHome.	"assure it's in view"
	(aCostume isKindOf: PasteUpMorph) 
		ifTrue:
			[self setCursor: (aCostume submorphs indexOf: aPlayer costume).
			aCostume updateSubmorphThumbnails]
]

{ #category : #accessing }
Player >> presenter [
	"Convenience for calling from user scripts"
	^ self costume presenter
]

{ #category : #'card\/stack commands' }
Player >> previousPage [
	self sendMessageToCostume: #previousPage
]

{ #category : #printing }
Player >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: (' (', self identityHash printString, ')').
	self costume ifNil: [aStream nextPutAll: ' (with nil costume)'.  ^ self].
	aStream nextPutAll: ' named ', self externalName
]

{ #category : #costume }
Player >> rawCostume: aMorph [
	costume := aMorph
]

{ #category : #accessing }
Player >> readoutPlayer [

	^ self.

]

{ #category : #costume }
Player >> recaptureUniqueCostumes [
	"Recapture all unique sketch-like costumes. Debugging only."
	| unique |
	costumes ifNil:[^self].
	unique := PluggableSet new 
				equalBlock:[:s1 :s2| s1 form == s2 form];
				hashBlock:[:s| s form scaledIdentityHash].
	unique addAll: (costumes select:[:c| c isSketchMorph]).
	unique := unique asIdentitySet.
	costumes := costumes select:[:c|
		(c isSketchMorph) not or:[unique includes: c]].

]

{ #category : #'slot-kedama' }
Player >> redComponentFrom: another [

	costume renderedMorph redComponentFrom: another costume renderedMorph.


]

{ #category : #'slot-kedama' }
Player >> redComponentInto: another [

	costume renderedMorph redComponentInto: another costume renderedMorph.


]

{ #category : #'fileIn\/Out' }
Player >> releaseCachedState [
	"release all non-showing scriptors"

	self class userScriptsDo: [:userScript | userScript releaseCachedState].
]

{ #category : #costume }
Player >> rememberCostume: aCostume [
	"Put aCostume in my remembered-costumes list, as the final element"
	| costumeToRemember existing |
	costumeToRemember := aCostume renderedMorph.
		"Remember real morphs, not their transformations"
	costumes ifNil: [costumes := OrderedCollection new].
	existing := (costumeToRemember isSketchMorph)
		ifTrue:
			[self knownSketchCostumeWithSameFormAs: costumeToRemember]
		ifFalse:
			[costumes detect: [:c | c == costumeToRemember] ifNone: [nil]].
	costumes := costumes copyWithout: existing.
	costumes addLast: costumeToRemember
]

{ #category : #'scripts-standard' }
Player >> removeAll [
	"Remove all the elements from my companion morph's collection.  This is destructive!"

	costume ifNotNil: [costume removeAllMorphs]
]

{ #category : #'slot-kedama' }
Player >> removeAllFromPatchDisplayList [

	costume renderedMorph removeAllFromPatchDisplayList.

]

{ #category : #'slot-kedama' }
Player >> removeAllFromTurtleDisplayList [

	costume renderedMorph removeAllFromTurtleDisplayList.

]

{ #category : #'scripts-kernel' }
Player >> removeScript: aSymbol fromWorld: aWorld [
	"Remove the given script, and get the display right in aWorld"

	self removeScriptWithoutUpdatingViewers: aSymbol fromWorld: aWorld.
	self updateAllViewersAndForceToShow: #scripts

]

{ #category : #'scripts-kernel' }
Player >> removeScriptWithSelector: aSelector [
	"Remove the given script, and get the display right"

	self removeScript: aSelector fromWorld:  self currentWorld

]

{ #category : #'scripts-kernel' }
Player >> removeScriptWithoutUpdatingViewers: aSymbol [
	self pacifyScript: aSymbol.
	self removeScriptNamed: aSymbol.

	(self scriptorsForSelector: aSymbol inWorld: costume world) do:
		[:s | s privateDelete].

]

{ #category : #'scripts-kernel' }
Player >> removeScriptWithoutUpdatingViewers: aSymbol fromWorld: aWorld [
	self pacifyScript: aSymbol.
	self removeScriptNamed: aSymbol.

	(self scriptorsForSelector: aSymbol inWorld: aWorld) do:
		[:s | s privateDelete].

]

{ #category : #'slots-user' }
Player >> removeSlotNamed: aSlotName [
	"The user has requested that an instance variable be removed..."

	| aSetter aGetter |
	(self okayToRemoveSlotNamed: aSlotName) ifFalse:
		[^ self inform: ('Sorry, {1} is in
use in a script.' translated format: {aSlotName})].

	aSetter := aSlotName asSetterSelector.
	aGetter := aSlotName asGetterSelector.
	((self systemNavigation allCallsOn: aSetter) size > 0 or: [(self systemNavigation allCallsOn: aGetter) size > 0]) ifTrue:
		[self inform: 
'Caution!  There may be scripts belonging to
other objects that may rely on the presence of
this variable.  If there are, they may now be broken.
You may need to fix them up manually.' translated].

	self class removeInstVarName: aSlotName asString.

	self updateAllViewers
]

{ #category : #testing }
Player >> renameInternal: aName [

	^ self costume topRendererOrSelf renameInternal: aName
]

{ #category : #'scripts-kernel' }
Player >> renameScript: oldSelector [ 
	"The user has asked to rename the script formerly known by oldSelector; obtain a new selector from the user, check it out, and if all is well, ascribe the new name as appropriate"

	| reply newSelector aUserScript |
	self flag: #deferred.
	"Relax the restriction below, before too long"
	aUserScript := self class userScriptForPlayer: self selector: oldSelector.
	aUserScript okayToRename 
		ifFalse: 
			[self 
				inform: 'Sorry, we do not permit you to rename
classic-tiled scripts that are currently
textually coded.  Go back to tile scripts
and try again.  Humble apologies.' translated.
			^self].
	reply := FillInTheBlank request: 'Script Name' translated initialAnswer: oldSelector.
	reply isEmpty ifTrue: [^self].
	reply = oldSelector ifTrue: [^Beeper beep].
	newSelector := self acceptableScriptNameFrom: reply
				forScriptCurrentlyNamed: oldSelector.
	Preferences universalTiles 
		ifTrue: 
			["allow colons"

			(reply copyWithout: $:) = newSelector 
				ifTrue: [newSelector := reply asSymbol]
				ifFalse: [self inform: 'name will be modified']].
	self renameScript: oldSelector newSelector: newSelector
]

{ #category : #'scripts-kernel' }
Player >> renameScript: oldSelector newSelector: newSelector [
	"Rename the given script to have the new selector"

	|  aUserScript anInstantiation aDict |
	oldSelector = newSelector ifTrue: [^ self].
	oldSelector numArgs == 0
		ifTrue:
			[self class allInstancesDo:
				[:aPlayer | | itsCostume |
					anInstantiation := aPlayer scriptInstantiationForSelector: oldSelector.
					anInstantiation ifNotNil: [
						newSelector numArgs == 0
							ifTrue:
								[anInstantiation changeSelectorTo: newSelector].
						aDict := aPlayer costume actorState instantiatedUserScriptsDictionary.
						itsCostume := aPlayer costume renderedMorph.
						itsCostume renameScriptActionsFor: aPlayer from: oldSelector to: newSelector.
						self currentWorld renameScriptActionsFor: aPlayer from: oldSelector to: newSelector.
						aDict removeKey: oldSelector.

						newSelector numArgs  == 0 ifTrue:
							[aDict at: newSelector put: anInstantiation.
							anInstantiation assureEventHandlerRepresentsStatus]]]]
		ifFalse:
			[newSelector numArgs == 0 ifTrue:
				[self class allInstancesDo:
					[:aPlayer |
						anInstantiation := aPlayer scriptInstantiationForSelector: newSelector.
						anInstantiation ifNotNil: [anInstantiation assureEventHandlerRepresentsStatus]]]].

	aUserScript := self class userScriptForPlayer: self selector: oldSelector.

	aUserScript renameScript: newSelector fromPlayer: self.
		"updates all script editors, and inserts the new script in my scripts directory"

	self removeScriptNamed: oldSelector.
	((self existingScriptInstantiationForSelector: newSelector) notNil and:
		[newSelector numArgs > 0]) ifTrue: [self error: 'ouch'].

	self updateScriptsCategoryOfViewers.

	(self scriptEditorFor: newSelector) ifNotNil:
		[:e | e updateHeader]
]

{ #category : #'slots-user' }
Player >> renameSlot: oldSlotName [ 
	| reply newSlotName |
	reply := UIManager default request: 'New name for "' translated , oldSlotName , '":'
				initialAnswer: oldSlotName.
	reply isEmpty ifTrue: [^self].
	newSlotName := ScriptingSystem 
				acceptableSlotNameFrom: reply
				forSlotCurrentlyNamed: oldSlotName
				asSlotNameIn: self
				world: self costume currentWorld.
	self renameSlot: oldSlotName newSlotName: newSlotName
]

{ #category : #'slots-user' }
Player >> renameSlot: oldSlotName newSlotName: newSlotName [
	"Give an existing instance variable a new name"

	^ self basicRenameSlot: oldSlotName newSlotName: newSlotName.

]

{ #category : #translation }
Player >> renameSlotInWatchersOld: oldName new: newName [
	"A variable has been renamed; get all relevant extant watchers updated.  All this assumed to be happening in the ActiveWorld"

	| oldGetter |
	oldGetter := oldName asGetterSelector.
	self allPossibleWatchersFromWorld do: [:aWatcher | | wasStepping |
		(aWatcher getSelector = oldGetter) ifTrue:
			[(wasStepping := aWatcher isStepping) ifTrue: [aWatcher stopStepping].
			aWatcher getSelector: newName asGetterSelector.
			aWatcher putSelector ifNotNil:
				[aWatcher putSelector: (newName asSetterSelector)].
			((aWatcher isKindOf: UpdatingStringMorph) and: [aWatcher hasStructureOfComplexWatcher]) ifTrue:  "Old style fancy watcher"
				[aWatcher owner owner traverseRowTranslateSlotOld: oldName to: newName.
				(aWatcher target labelFromWatcher: aWatcher) contents: newName, ' = '].
			(aWatcher ownerThatIsA: WatcherWrapper) ifNotNil:
				[:wrapper | wrapper player: self variableName: newName].
			wasStepping ifTrue: [aWatcher startStepping]]]
]

{ #category : #testing }
Player >> renameTo: aName [

	^ self costume topRendererOrSelf renameTo: aName
]

{ #category : #costume }
Player >> renderedCostume: aMorph [
	"Make aMorph be the receiver's rendered costume; if flexing is currently in effect, make the new morph be flexed correspondingly"
	self renderedCostume: aMorph remember: true
]

{ #category : #costume }
Player >> renderedCostume: aMorph remember: rememberCostume [
	"Make aMorph be the receiver's rendered costume; if flexing is currently in effect, make the new morph be flexed correspondingly"

	| renderedMorph known anEventHandler w baseGraphic |
	renderedMorph := costume renderedMorph.
	renderedMorph == aMorph ifTrue: [^ self].
	baseGraphic := costume renderedMorph valueOfProperty: #baseGraphic.
	rememberCostume
		ifTrue: [self rememberCostume: renderedMorph].
	renderedMorph changed.
	w := renderedMorph world.
	"Copy 'player state' (e.g., state which should be associated with the player but is stored in the morph itself these days) from the old rendered morph the new morph."
	aMorph rotationStyle: renderedMorph rotationStyle.
	aMorph forwardDirection: renderedMorph forwardDirection.
	"Note: referencePosition is *not* state but #moveTo: behavior"
	aMorph referencePosition: renderedMorph referencePosition.
	anEventHandler := renderedMorph eventHandler.
	costume isFlexMorph
		ifTrue:
			[costume adjustAfter:
				[costume replaceSubmorph: renderedMorph by: aMorph]]
		ifFalse:
			[costume owner ifNotNil: [costume owner replaceSubmorph: costume by: aMorph].
			aMorph player: self.
			aMorph actorState: costume actorState.
			(known := costume knownName) ifNotNil:
				[aMorph setNameTo: known].
			costume := aMorph.
			w ifNotNil:
				[w stopStepping: renderedMorph.
				w startStepping: aMorph]].

	baseGraphic ifNotNil: [self setBaseGraphic: baseGraphic].
	aMorph eventHandler: anEventHandler.
	aMorph changed
]

{ #category : #costume }
Player >> resetCostumeList [
	costumes := nil
]

{ #category : #costume }
Player >> restoreBaseGraphic [
	"Restore my base graphic"

	| cos |
	((cos := self costume renderedMorph) isSketchMorph)
		ifTrue:
			[cos restoreBaseGraphic]
]

{ #category : #misc }
Player >> revealPlayerIn: aWorld [
	"Reveal the receiver if at all possible in the world; once it's visible, flash its image for a bit, and leave it with its halo showing"

	| aMorph |
	(aMorph := self costume) isInWorld ifTrue:
		[aMorph goHome.
		self indicateLocationOnScreen.
		aMorph owner ifNotNil: [:ownr | ownr layoutPolicy ifNil:
			[aMorph comeToFront]].
		aMorph addHalo.
		^ self].

	"It's hidden somewhere; search for it"
	aWorld submorphs do:
		[:m | (m succeededInRevealing: self) ifTrue:  "will have obtained halo already"
			[aWorld doOneCycle.
			self indicateLocationOnScreen.
			^ self]].

	"The morph is truly unreachable in this world at present.  So extract it from hyperspace, and place it at center of screen, wearing a halo."
	aMorph isWorldMorph ifFalse:
		[aWorld addMorphFront: aMorph.
		aMorph position: aWorld bounds center.
		aMorph addHalo]
]

{ #category : #misc }
Player >> revealPlayerNamed: aSymbol in: aWorld [ 
	| getter |
	getter := aSymbol asGetterSelector.
	^ (self perform: getter)
		revealPlayerIn: aWorld
]

{ #category : #'scripts-standard' }
Player >> reverse [

	self sendMessageToCostume: #reverse.

]

{ #category : #misc }
Player >> revertToUnscriptedPlayerIfAppropriate [
	| anInstance |
	(self class selectors notEmpty or: [self class instVarNames notEmpty]) 
		ifTrue: [^self].
	anInstance := UnscriptedPlayer new.
	anInstance initializeCostumesFrom: self.
	self becomeForward: anInstance
]

{ #category : #'playing commands' }
Player >> rewind [
	self sendMessageToCostume: #rewind
]

{ #category : #misc }
Player >> roundUpStrays [
	self sendMessageToCostume: #roundUpStrays
]

{ #category : #'scripts-execution' }
Player >> runAllClosingScripts [
	"Run all the receiver's scripts marked as #closing.  Return a boolean indicating whether any such scripts were encountered and run"

	| any |
	any := false.
	self instantiatedUserScriptsDo:
		[:aScriptInstantiation | aScriptInstantiation runIfClosing ifTrue: [any := true]].
	^ any
]

{ #category : #'scripts-execution' }
Player >> runAllOpeningScripts [
	"Run all the receiver's scripts marked as #opening.  Return a boolean indicating whether any such scripts were encountered and run"

	| any |
	any := false.
	self instantiatedUserScriptsDo:
		[:aScriptInstantiation | aScriptInstantiation runIfOpening ifTrue: [any := true]].
	^ any
]

{ #category : #'scripts-execution' }
Player >> runAllTickingScripts: nowTick [

	self instantiatedUserScriptsDo: [:aScriptInstantiation | aScriptInstantiation runIfTicking: nowTick]
]

{ #category : #'scripts-kernel' }
Player >> runScript: aSelector [
	"Called from script-activation buttons.  Provides a safe way to run a script that may have changed its name"
	(self respondsTo: aSelector) ifTrue:
		[^ self triggerScript: aSelector].
	self inform: 
('Oops, object "{1}" no longer has
a script named "{2}".
It must have been deleted or renamed.' translated 
	format: {self externalName.  aSelector})

]

{ #category : #'scripts-kernel' }
Player >> scriptEditorFor: aSelector [
	"Answer the receiver's script editor for aSelector"

	| aScriptEditor |
	aScriptEditor := (self class userScriptForPlayer: self selector: aSelector) instantiatedScriptEditorForPlayer: self.
	aScriptEditor updateToPlayer: self.
	aScriptEditor bringUpToDate.
	^ aScriptEditor
]

{ #category : #'scripts-kernel' }
Player >> scriptInstantiationForSelector: aSelector [
	"Answer a script instantiation for the given selector, creating it at this time if necessary"

	|  entry scriptDict classEntry actorState |
	actorState := self actorState.
	actorState ifNil: [^ nil].
	scriptDict := actorState instantiatedUserScriptsDictionary.
	entry := scriptDict at: aSelector ifAbsent: [nil].
	entry ifNil:
		[classEntry := self class userScriptForPlayer: self selector: aSelector.
		entry := ScriptInstantiation new player: self selector: aSelector status: classEntry defaultStatus.
		scriptDict at: aSelector put: entry].
	^ entry
]

{ #category : #'scripts-execution' }
Player >> scriptingError: aMessage [
	"An error arose, characterized by aMessage, when a script was being run.  For the moment, we report it to the transcript only"
	Transcript cr; show: 'Scripting error for ', self externalName, ': ', aMessage
]

{ #category : #'scripts-kernel' }
Player >> scriptorsForSelector: aSelector inWorld: aWorld [
	"Answer, for the purpose of deletion, a list of all scriptor objects for the given selector that are associated with any member of the receiver's uniclass"

	| scriptors |
	aWorld ifNil: [^ OrderedCollection new].
	scriptors := (aWorld allMorphs select:
		[:m | (((m isKindOf: ScriptEditorMorph) and: [m playerScripted class == self class]) and: [m scriptName == aSelector])] thenCollect: [:m | m topEditor]) asSet.
	^ scriptors asArray
]

{ #category : #misc }
Player >> seesColor: aColor [
	costume isInWorld ifFalse: [^ false].
	^ costume touchesColor: aColor
]

{ #category : #costume }
Player >> sendMessageToCostume: aSelector [
	| aCostume |
	(aCostume := self costumeRespondingTo: aSelector) ifNotNil:
		[^ aCostume perform: aSelector].
	^ nil
]

{ #category : #costume }
Player >> sendMessageToCostume: aSelector with: arg [
	| aCostume |
	(aCostume := self costumeRespondingTo: aSelector) ifNotNil:
		[^ aCostume perform: aSelector with: arg].
	^ nil
]

{ #category : #'slot getters\/setters' }
Player >> setActWhen: val [
	"Tell the receiver's costume (hopefully a button!) to set its actWhen parameter as indicated"

	costume renderedMorph actWhen: val
]

{ #category : #'slot getters\/setters' }
Player >> setAllButFirstCharacter: aString [
	"Set my costume's all-but-first characters to be aString"

	costume renderedMorph setAllButFirstCharacter: aString
]

{ #category : #'slot getters\/setters' }
Player >> setAllowEtoyUserCustomEvents: aValue [
	"Set the allowEtoyUserCustomEvents preferences"

	Preferences setPreference: #allowEtoyUserCustomEvents toValue: aValue
]

{ #category : #'slots-color components' }
Player >> setAlpha: aFloat [
	"Set the alpha component of my costume, if appropriate."

	| aColor aValue |
	aColor := self getColor.
	aValue := (aFloat / 100 max: 0) min: 1.
	self setColor: (Color
		r: aColor red
		g: aColor green
		b: aColor blue
		alpha: aValue)
]

{ #category : #'scripts-standard' }
Player >> setBackgroundColor: aColor [
	"Set the background color; the costume is presumed to be a text morph."

	self costume renderedMorph backgroundColor: aColor
]

{ #category : #'slot getters\/setters' }
Player >> setBaseGraphic: aGraphic [
	"Set the base graphic"

	| aMorph |
	^ ((aMorph := costume renderedMorph) isSketchMorph)
		ifTrue:
			[aMorph baseGraphic: aGraphic]
]

{ #category : #'slot getters\/setters' }
Player >> setBatchPenTrails: aValue [
	"Set the batchPenTrails preference."

	Preferences setPreference: #batchPenTrails toValue: aValue
]

{ #category : #'slot-kedama' }
Player >> setBlueComponentIn: aPatch to: value [

]

{ #category : #'slot getters\/setters' }
Player >> setBorderColor: aColor [ 
	"Set the border color as requested"

	costume renderedMorph borderColor: aColor
]

{ #category : #'slot getters\/setters' }
Player >> setBorderStyle: aSymbol [
	"Set the border style of my costume"

	costume renderedMorph setBorderStyle: aSymbol
]

{ #category : #'slot getters\/setters' }
Player >> setBorderWidth: aWidth [ 
	"Set the border width to the given number"
	costume renderedMorph borderWidth: aWidth
]

{ #category : #'slot getters\/setters' }
Player >> setBottom: w [
	"Set the bottom coordinate (cartesian sense) of the object as requested"

	| topLeftNow cost |
	cost := self costume.
	cost isWorldMorph ifTrue: [^ self].
	topLeftNow := cost cartesianBoundsTopLeft.
	^ cost bottom: cost top + topLeftNow y - w

]

{ #category : #'slot-kedama' }
Player >> setBottomEdgeMode: aSymbol [

	self setCostumeSlot: #bottomEdgeMode: toValue: aSymbol.

]

{ #category : #'slot getters\/setters' }
Player >> setCameraPoint: pt [

	self costume cameraPoint: pt

]

{ #category : #'slot getters\/setters' }
Player >> setCardNumber: aNumber [
	"Go to the given card number"

	self stackEmbodied goToCardNumber: aNumber
]

{ #category : #'slot getters\/setters' }
Player >> setCellInset: aValue [
	"Setter for costume's cellInset"

	costume cellInset: aValue
]

{ #category : #'slot getters\/setters' }
Player >> setCharacterAtCursor: aCharOrString [
	"Insert the given character at my cursor position"

	| aLoc aTextMorph aString charToUse newText |
	aLoc := (aTextMorph := self costume renderedMorph) cursor.
	charToUse := (aString := aCharOrString asString) size > 0
		ifTrue: [aString first]
		ifFalse: ['·'].
	newText := charToUse asString asText.
	(aTextMorph text attributesAt: aLoc) do: [:att | newText addAttribute: att].
	aTextMorph paragraph replaceFrom: aLoc to: aLoc with: newText displaying: true.
	aTextMorph updateFromParagraph.  
]

{ #category : #'slot getters\/setters' }
Player >> setCharacters: amt [
	"Set my costume's characters as indicated"

	costume renderedMorph setCharacters: amt
]

{ #category : #'slot getters\/setters' }
Player >> setClipSubmorphs: aBoolean [
	"Setter for costume's clipSubmorphs"

	costume renderedMorph clipSubmorphs: aBoolean.
	costume renderedMorph changed
]

{ #category : #'slot getters\/setters' }
Player >> setColor: aColor [
	"Set the color of the graphic as requested"

	| aFillStyle aMorph |
	(aFillStyle := (aMorph := self costume renderedMorph) fillStyle) isGradientFill
		ifTrue:
			[aFillStyle firstColor: aColor forMorph: aMorph hand: nil]
		ifFalse:
			[aMorph color: aColor]
]

{ #category : #'slot getters\/setters' }
Player >> setColorUnder: aValue [
	"Provide a soft landing for old readouts that may try to send this"
]

{ #category : #sound }
Player >> setConePosition: aNumber [
	"Note: Performance hacked to allow real-time sound. Assumes costume is a SpeakerMorph."

	costume renderedMorph conePosition: aNumber.
]

{ #category : #'slot getters\/setters' }
Player >> setCostume: aForm [
	"Set the receiver's graphic as indicated.  An earlier wording, disused but may persist in preexisting scripts."

	| aMorph |
	^ ((aMorph := costume renderedMorph) isSketchMorph)
		ifTrue:
			[aMorph form: aForm]
		ifFalse:
			["what to do?"]
]

{ #category : #costume }
Player >> setCostumeSlot: setterSelector toValue: aValue [
	| aCostume |
	(aCostume := self costumeRespondingTo: setterSelector) ifNotNil:
		[aCostume perform: setterSelector with: aValue]
]

{ #category : #'slot getters\/setters' }
Player >> setCursor: aNumber [
	"Set my costume's cursor to the given number"

	costume renderedMorph cursorWrapped: aNumber
]

{ #category : #'slot getters\/setters' }
Player >> setCursorWrapped: aNumber [
	"maintained for backward compatibility with existing etoys"

	^ self setCursor: aNumber

]

{ #category : #'slot getters\/setters' }
Player >> setDescending: aBoolean [
	self setCostumeSlot: #descending: toValue: aBoolean
]

{ #category : #'slot-kedama' }
Player >> setDiffusionRate: aNumber [

	^ self setCostumeSlot: #diffusionRate: toValue: aNumber.

]

{ #category : #'slot-kedama' }
Player >> setDimensions: asPoint [

	^ self setCostumeSlot: #dimensions: toValue: asPoint.

]

{ #category : #'slot-kedama' }
Player >> setDimensionsHeight: aNumber [

	^ self setDimensions: self getDimensionsWidth @ aNumber.

]

{ #category : #'slot-kedama' }
Player >> setDimensionsWidth: aNumber [

	^ self setDimensions: aNumber @ self getDimensionsHeight.

]

{ #category : #'slot-kedama' }
Player >> setDisplayScaleMax: aNumber [

	self setCostumeSlot: #displayMax: toValue: aNumber.

]

{ #category : #'slot-kedama' }
Player >> setDisplayShiftAmount: aNumber [

	self setCostumeSlot: #displayShiftAmount: toValue: aNumber.

]

{ #category : #'slot-kedama' }
Player >> setDisplayType: aSymbol [

	^ self setCostumeSlot: #displayType: toValue: aSymbol.

]

{ #category : #'slot getters\/setters' }
Player >> setDistance: aDistance [
	"Set the object's distance from the origin to be as indicated, preserving its angle."

	| cost |
	cost := self costume.
	cost isWorldMorph ifTrue: [^ self].
	cost cartesianXY: (Point r: aDistance degrees:  self getTheta)
]

{ #category : #pen }
Player >> setDotSize: aNumber [
	"Set the trail dot size as indicated, but confine matters to a reasonable range"

	self costume renderedMorph setProperty: #trailDotSize toValue: ((aNumber max: 1) min: 100)
]

{ #category : #'slot getters\/setters' }
Player >> setDragEnabled: aValue [
	"Setter for costume's dragEnabled"

	costume dragEnabled: aValue
]

{ #category : #'slot getters\/setters' }
Player >> setDropEnabled: aValue [
	"Setter for costume's dropEnabled"

	costume dropEnabled: aValue
]

{ #category : #'slot getters\/setters' }
Player >> setDropProducesWatcher: aValue [
	"Set the dropProducesWatcher preferences"

	Preferences setPreference: #dropProducesWatcher toValue: aValue
]

{ #category : #'slot getters\/setters' }
Player >> setDropShadow: aValue [
	"Setter for costume's dropShadow"

	| aMorph |
	(aMorph := costume renderedMorph) hasDropShadow ~~ aValue ifTrue: [aMorph toggleDropShadow]
]

{ #category : #'slot getters\/setters' }
Player >> setEToyFriendly: aValue [
	"Set the eToyFriendly preference."

	Preferences setPreference: #eToyFriendly toValue: aValue
]

{ #category : #'slot-kedama' }
Player >> setEvaporationRate: aNumber [

	self setCostumeSlot: #evaporationRate: toValue: aNumber.

]

{ #category : #'slot getters\/setters' }
Player >> setFenceEnabled: aValue [
	"Set the fenceEnabled preference."

	Preferences setPreference: #fenceEnabled toValue: aValue
]

{ #category : #'slot getters\/setters' }
Player >> setFirstCharacter: aChar [
	"Set my costume's first character to the indicated one"

	costume renderedMorph setFirstCharacter: aChar
]

{ #category : #'slot getters\/setters' }
Player >> setFirstElement: aPlayer [ 
	"Caution - this is a replacement operation!  Replace the receiver's costume's first element with the morph represented by aPlayer"

	| aCostume |
	(aPlayer == self or: [(aCostume := self costume) submorphs isEmpty]) 
		ifTrue: [^self].
	costume replaceSubmorph: aCostume submorphs first by: aPlayer costume
]

{ #category : #'slots-user' }
Player >> setFloatPrecisionFor: aReadout [
	"If appropriate, set the floatPrecision for the given watcher readout (an UpdatingStringMorph), whose getter is assumed already to be established."
	
	| precision  |
	(precision := self defaultFloatPrecisionFor: aReadout getSelector) ~= 1 ifTrue: [aReadout floatPrecision: precision]
]

{ #category : #'slot getters\/setters' }
Player >> setGetListSelector: sel [
	"Set the receiver's get-list-selector as indicated."

	costume renderedMorph getListSelector: sel
	
]

{ #category : #'slot getters\/setters' }
Player >> setGraphic: aForm [
	"Set the receiver's graphic as indicated"

	| aMorph |
	^ ((aMorph := costume renderedMorph) isSketchMorph)
		ifTrue:
			[aMorph form: aForm]
		ifFalse:
			[aMorph isPlayfieldLike
				ifTrue: 
					[aMorph backgroundForm: aForm]
				ifFalse:
					["what to do?"]]
]

{ #category : #'slot-kedama' }
Player >> setGreenComponentIn: aPatch to: value [

]

{ #category : #'slot-kedama' }
Player >> setGrouped: aBoolean [

	self setCostumeSlot: #isGroup: toValue: aBoolean.

]

{ #category : #'slot getters\/setters' }
Player >> setHResizing: aValue [
	"Setter for costume's hResizing"

	costume hResizing: aValue asSymbol
]

{ #category : #'slot getters\/setters' }
Player >> setHeading: newHeading [
	"Set the heading as indicated"

	| aCostume |
	aCostume := self costume.
	aCostume isWorldMorph ifTrue: [^ self].
	aCostume heading: newHeading.
	aCostume := self costume. "in case we just got flexed for no apparent reason"
	(aCostume isFlexMorph and:[aCostume hasNoScaleOrRotation]) 
		ifTrue:	[aCostume removeFlexShell]
]

{ #category : #'slot getters\/setters' }
Player >> setHeadingTheta: anAngle [
	"Set the heading theta"

	self setHeading: (450 - anAngle)
]

{ #category : #'slot getters\/setters' }
Player >> setHeight: w [
	"Set the height of the object as indicated"

	^ self costume height: w
]

{ #category : #'slot getters\/setters' }
Player >> setIndexInOwner: amt [
	"Move my costume to a different z-position within its container.  This is primarily in service of auto-line-layout views in which the z-ordering determines the left/right and top/bottom placement."

	costume setIndexInOwner: amt
]

{ #category : #'slot getters\/setters' }
Player >> setIsLocked: aBoolean [
	"Set my costume's isLocked"

	costume lock: aBoolean
]

{ #category : #'slot getters\/setters' }
Player >> setKeepTickingWhilePainting: aValue [
	"Set the keepTickingWhilePainting preferences"

	Preferences setPreference: #keepTickingWhilePainting toValue: aValue
]

{ #category : #'slot getters\/setters' }
Player >> setKnobColor: aColor [
	self setCostumeSlot: #sliderColor: toValue: aColor
]

{ #category : #'slot getters\/setters' }
Player >> setLabel: aLab [
	"Set the receiver's costume's label as specified"

	costume renderedMorph label: aLab
]

{ #category : #'slot getters\/setters' }
Player >> setLastCharacter: aChar [
	"Set my costume's last character to the indicated value, usually a string of length one."

	costume renderedMorph setLastCharacter: aChar
]

{ #category : #'slot getters\/setters' }
Player >> setLastKeystroke: aString [
	"Set the last keystroke fielded"

	^ self currentWorld lastKeystroke: aString
]

{ #category : #'slot getters\/setters' }
Player >> setLastValue: aNumber [

	self setCostumeSlot: #lastValue: toValue: aNumber.

]

{ #category : #'slot getters\/setters' }
Player >> setLayoutInset: aValue [
	"Setter for costume's layoutInset"

	costume layoutInset: aValue
]

{ #category : #'slot getters\/setters' }
Player >> setLeft: w [
	"Set the object's left coordinate as indicated"

	| topLeftNow cost |
	cost := self costume.
	cost isWorldMorph ifTrue: [^ self].
	topLeftNow := cost cartesianBoundsTopLeft.
	^ cost left: cost left - topLeftNow x + w

]

{ #category : #'slot-kedama' }
Player >> setLeftEdgeMode: aSymbol [

	self setCostumeSlot: #leftEdgeMode: toValue: aSymbol.

]

{ #category : #'slot getters\/setters' }
Player >> setLength: aLength [
	"Set the length of the receiver."

	| cost lengthToUse |
	cost := self costume.
	cost isWorldMorph ifTrue: [^self].
	cost isLineMorph
		ifTrue:
			[^ cost unrotatedLength: aLength].
	lengthToUse := cost isRenderer
		ifTrue:
			[aLength / cost scaleFactor]
		ifFalse:
			[aLength].
	cost renderedMorph height: lengthToUse
]

{ #category : #'slot getters\/setters' }
Player >> setListCentering: val [
	"Setter for costume's listCentering"

	costume listCentering: val
]

{ #category : #'slot getters\/setters' }
Player >> setListDirection: aValue [
	"Setter for costume's listDirection"

	costume listDirection: aValue asSymbol
]

{ #category : #'slot getters\/setters' }
Player >> setMaxVal: aNumber [
	self setCostumeSlot: #setMaxVal: toValue: aNumber
]

{ #category : #'slot getters\/setters' }
Player >> setMinVal: aNumber [
	self setCostumeSlot: #setMinVal: toValue: aNumber
]

{ #category : #'slot getters\/setters' }
Player >> setName: aName [
	^ self costume renameTo: aName
]

{ #category : #'slot getters\/setters' }
Player >> setNumberAtCursor: aNumber [
	"Place the given number into the morph residing at my costume's current cursor position"

	| renderedMorph aCostume |
	aCostume := self costume.
	((renderedMorph := aCostume renderedMorph) respondsTo: #valueAtCursor:) ifTrue: [^ renderedMorph valueAtCursor renderedMorph setNumericValue: aNumber]
]

{ #category : #'slot getters\/setters' }
Player >> setNumericValue: amt [
	"Set the receiver's numeric value to the amount.  This is passed on to the costume"

	costume renderedMorph setNumericValue: amt
]

{ #category : #'slot getters\/setters' }
Player >> setOffsetX: aNumber [

	^ self costume offsetX: aNumber
]

{ #category : #'slot getters\/setters' }
Player >> setOffsetY: aNumber [

	^ self costume offsetY: aNumber
]

{ #category : #'slot getters\/setters' }
Player >> setOliveHandleForScriptedObjects: aBoolean [
	"Set the value of the oliveHandleForScriptedObjects preference."

	Preferences setPreference: #oliveHandleForScriptedObjects toValue: aBoolean
]

{ #category : #'slot getters\/setters' }
Player >> setPageNumber: aNumber [
	"Set the page number of my book as indicated."

	self bookEmbodied goToPage: aNumber
]

{ #category : #costume }
Player >> setParameterFor: aSelector toType: aTypeSymbol [
	"Set the parameter type for the given selector"

	| aUniclassScript |
	aTypeSymbol isEmptyOrNil ifTrue: [^ self].
	(self typeforParameterFor: aSelector) = aTypeSymbol ifTrue: [^ self].
	aUniclassScript := self class scripts at: aSelector.
	aUniclassScript argumentVariables first variableType: aTypeSymbol.
	aUniclassScript currentScriptEditorDo:
		[:aScriptEditor | aScriptEditor assureParameterTilesValid].
	self updateAllViewersAndForceToShow: #scripts
	


]

{ #category : #'slot-kedama' }
Player >> setPatchValueIn: aPatch to: value [

]

{ #category : #pen }
Player >> setPenArrowheads: penDown [
	"Set whether the pen will draw arrowheads on the ends of strokes"

	self actorState setPenArrowheads: penDown.

]

{ #category : #pen }
Player >> setPenColor: aColor [
	"Set the turtle pen color as indicated"

	self actorState setPenColor: aColor
]

{ #category : #pen }
Player >> setPenDown: penDown [
	"Set the penDown state as indicated, to true or false"

	| morph trailMorph tfm |
	self actorState setPenDown: penDown.
	((morph := self costume) notNil and: [(trailMorph := morph trailMorph) notNil and: [morph isWorldMorph not]])
		ifTrue:
		[tfm := morph owner transformFrom: trailMorph.
		trailMorph notePenDown: penDown forPlayer: self
					at: (tfm localPointToGlobal: morph referencePosition)]

]

{ #category : #pen }
Player >> setPenSize: aSize [
	"Set the pen size as indicated"

	self actorState setPenSize: aSize
]

{ #category : #'slot-kedama' }
Player >> setPixelsPerPatch: aNumber [

	^ self setCostumeSlot: #pixelsPerPatch: toValue: aNumber.

]

{ #category : #'slot getters\/setters' }
Player >> setPosition: amt [ 
	"Set the receiver's numeric value to the amount. This is passed 
	on to the costume"
	costume renderedMorph setPosition: amt
]

{ #category : #'slots-user' }
Player >> setPrecisionFor: slotName [ 
	"Set the precision for the given slot name"

	| aList reply aGetter places |
	aGetter := slotName asGetterSelector.
	places := Utilities 
				decimalPlacesForFloatPrecision: (self defaultFloatPrecisionFor: aGetter).
	aList := #('0' '1' '2' '3' '4' '5' '6').
	reply := UIManager default
		chooseFrom: aList
		values: (aList collect: [:m | m asNumber])
		title: ('How many decimal places? (currently {1})' translated
						format: {places}).
	reply ifNotNil: 
			[(self slotInfo includesKey: slotName) 
				ifTrue: 
					["it's a user slot"

					(self slotInfoAt: slotName) 
						floatPrecision: (Utilities floatPrecisionForDecimalPlaces: reply).
					self class allInstancesDo: 
							[:anInst | | val | 
							reply = 0 
								ifFalse: 
									[((val := anInst instVarNamed: slotName asString) isInteger) 
										ifTrue: [anInst instVarNamed: slotName asString put: val asFloat]].
							anInst updateAllViewers]]
				ifFalse: 
					["it's specifying a preference for precision on a system-defined numeric slot"

					self noteDecimalPlaces: reply forGetter: aGetter.
					self updateAllViewers]]
]

{ #category : #'slot getters\/setters' }
Player >> setRadialGradientFill: aBoolean [
	"Setter for costume's radialGradientFill"

	| fil |
	(self isFillStyle: (fil := costume renderedMorph fillStyle)) ifTrue:
		[fil isGradientFill ifTrue:
			[fil isRadialFill ~~ aBoolean ifTrue:
				[fil radial: aBoolean.
				costume renderedMorph changed]]]
]

{ #category : #'slot-kedama' }
Player >> setRedComponentIn: aPatch to: value [

]

{ #category : #'playing commands' }
Player >> setRepeat: aBoolean [ 
	 self sendMessageToCostume: #setRepeat: with: aBoolean
]

{ #category : #'slot getters\/setters' }
Player >> setResistsRemoval: aBoolean [
	"Set the resistsRemoval property"

	^ costume resistsRemoval: aBoolean
]

{ #category : #'slot getters\/setters' }
Player >> setRight: w [
	"Set the right coordinate to the given value"

	| topLeftNow cost |
	cost := self costume.
	cost isWorldMorph ifTrue: [^ self].
	topLeftNow := cost cartesianBoundsTopLeft.
	^ cost right: cost left - topLeftNow x + w

]

{ #category : #'slot-kedama' }
Player >> setRightEdgeMode: aSymbol [

	self setCostumeSlot: #rightEdgeMode: toValue: aSymbol.

]

{ #category : #'slot getters\/setters' }
Player >> setRotationStyle: aStyleSymbol [
	"Set the rotation style to the indicated symbol; the external symbols seen are different, as you'll observe..."

	costume renderedMorph rotationStyle: 
		(#(normal none leftRight upDown ) at:
		(#(rotate #'do not rotate' #'flip left right' #'flip up down') indexOf: aStyleSymbol))
]

{ #category : #'card\/stack commands' }
Player >> setRoundedCorners: aBoolean [
	"Set the rounded-corners attribute as indicated"

	costume renderedMorph cornerStyle: (aBoolean ifTrue: [#rounded] ifFalse: [#square])
]

{ #category : #'slot getters\/setters' }
Player >> setSampleAtCursor: aNumber [
	"Note: Performance hacked to allow real-time sound. Assumes costume is a GraphMorph."

	self setCostumeSlot: #valueAtCursor: toValue: aNumber.

]

{ #category : #'slot getters\/setters' }
Player >> setScale: aNumber [

	^ self costume scale: aNumber
]

{ #category : #'slot getters\/setters' }
Player >> setScaleFactor: aNumber [
	"Set the scale factor to be the given value"

	| cost |
	cost := self costume.
	cost isWorldMorph ifTrue: [^ self].
	cost scaleFactor: ((aNumber asFloat max: 0.1) min: 10.0)
]

{ #category : #'slot getters\/setters' }
Player >> setSecondColor: aColor [
	"Setter for costume's second color, if it's using gradient fill; if not, does nothing"

	| morph fillStyle colorToUse |
	morph := costume renderedMorph.
	fillStyle := morph fillStyle.
	fillStyle isGradientFill ifFalse: [^ self].
	
	colorToUse := (costume isWorldMorph and: [aColor isColor])
		ifTrue: [aColor alpha: 1.0]  "reject any translucency"
		ifFalse: [aColor].
	fillStyle lastColor: colorToUse forMorph: morph hand: self currentHand.
]

{ #category : #'slot getters\/setters' }
Player >> setShadowColor: aValue [
	"Setter for costume's shadowColor"

	costume  renderedMorph shadowColor: aValue
]

{ #category : #'slot-kedama' }
Player >> setSniffRange: aNumber [

	self setCostumeSlot: #sniffRange: toValue: aNumber.

]

{ #category : #'slot getters\/setters' }
Player >> setSticky: val [
	"Setter for costume's sticky"

	costume sticky: val
]

{ #category : #'slot getters\/setters' }
Player >> setSubtitlesFileName: aString [ 
	"Set my costume's subtitlesFileName as indicated"
	costume renderedMorph setSubtitlesFileName: aString
]

{ #category : #'slot getters\/setters' }
Player >> setTheta: aTheta [
	"Set the object's position such that its rho is unchanged but the angle between the positive x-axis and the vector connecting the origin and the object's position is as given."

	| cost |
	cost := self costume.
	cost isWorldMorph ifTrue: [^ self].
	cost cartesianXY: (Point r: self getDistance degrees: aTheta)
]

{ #category : #'slot getters\/setters' }
Player >> setTop: w [
	"Set the top coordinate as indicated, using cartesian sense"

	| topLeftNow cost |
	cost := self costume.
	cost isWorldMorph ifTrue: [^ self].
	topLeftNow := cost cartesianBoundsTopLeft.
	^ cost top: cost top + topLeftNow y - w
]

{ #category : #'slot-kedama' }
Player >> setTopEdgeMode: aSymbol [

	self setCostumeSlot: #topEdgeMode: toValue: aSymbol.

]

{ #category : #pen }
Player >> setTrailStyle: aTrailStyle [
	"Set the trail style"

	self actorState trailStyle: aTrailStyle

]

{ #category : #'slot getters\/setters' }
Player >> setTruncate: aBoolean [
	self setCostumeSlot: #truncate: toValue: aBoolean
]

{ #category : #'slot-kedama' }
Player >> setTurtleCount: aNumber [

	self setCostumeSlot: #turtleCount: toValue: aNumber.

]

{ #category : #'slot-kedama' }
Player >> setTurtleVisible: aBoolean [

]

{ #category : #'slot getters\/setters' }
Player >> setUseGradientFill: aBoolean [
	"Setter for costume's useGradientFill"

	| fil |
	^ (self isFillStyle: (fil := costume renderedMorph fillStyle))
		ifTrue:
			[fil isGradientFill
				ifTrue:
					[aBoolean ifFalse: [costume renderedMorph useSolidFill]]
		ifFalse:
			[aBoolean ifTrue: [costume renderedMorph useGradientFill]]]
]

{ #category : #'slot-kedama' }
Player >> setUseLogDisplay: aBoolean [

	^ self setCostumeSlot: #useLogDisplay: toValue: aBoolean.

]

{ #category : #'slot getters\/setters' }
Player >> setUseVectorVocabulary: aValue [
	"Set the useVectorVocabulary preferences"

	Preferences setPreference: #useVectorVocabulary toValue: aValue
]

{ #category : #'slot getters\/setters' }
Player >> setVResizing: aValue [
	"Setter for costume's vResizing"

	costume vResizing: aValue asSymbol
]

{ #category : #'slot getters\/setters' }
Player >> setValueAtCursor: aPlayer [
	| renderedMorph aCostume |
	aCostume := self costume.
	((renderedMorph := aCostume renderedMorph) respondsTo: #valueAtCursor:) ifTrue: [^ renderedMorph valueAtCursor: aPlayer costume].

	(aCostume respondsTo: #valueAtCursor:) ifTrue: [aCostume valueAtCursor: aPlayer costume]
]

{ #category : #'slot getters\/setters' }
Player >> setVideoFileName: aString [ 
	"Set my costume's videoFileName as indicated"
	costume renderedMorph setVideoFileName: aString
]

{ #category : #'slot getters\/setters' }
Player >> setViewingByIcon: aVal [
	"Set the user's  costume's view-by-icon attribute as indictated"

	(aVal == false)
		ifTrue:
			["problematical - we always need *some* view"
			costume renderedMorph viewByName]
		ifFalse:
			[costume renderedMorph viewByIcon]
]

{ #category : #'slot getters\/setters' }
Player >> setVolume: amt [ 
	"Set the receiver's numeric value to the amount. This is passed 
	on to the costume"
	costume renderedMorph setVolume: amt
]

{ #category : #'slot getters\/setters' }
Player >> setWidth: aWidth [
	"Set the width"

	| cost widthToUse |
	cost := self costume.
	cost isWorldMorph ifTrue: [^ self].
	cost isLineMorph
		ifTrue:
			[^ cost unrotatedWidth: aWidth].
	widthToUse := cost isRenderer
		ifTrue:
			[aWidth / cost scaleFactor]
		ifFalse:
			[aWidth].
	cost renderedMorph width: widthToUse
]

{ #category : #'slot getters\/setters' }
Player >> setWrapDirection: aValue [
	"Setter for costume's wrapDirection"

	costume wrapDirection: aValue
]

{ #category : #'slot getters\/setters' }
Player >> setX: val [
	"Set the x coordinate as indicated"

	| aCostume |
	(aCostume := self costume) isInWorld ifFalse: [^ self].
	aCostume isWorldOrHandMorph ifTrue: [^ self].
	aCostume owner isHandMorph ifTrue: [^ self].
	^ aCostume x: val
]

{ #category : #'slot getters\/setters' }
Player >> setY: val [
	"Set the y coordinate as indicated"

	| aCostume |
	(aCostume := self costume) isInWorld ifFalse: [^ self].
	aCostume isWorldOrHandMorph ifTrue: [^ self].
	aCostume owner isHandMorph ifTrue: [^ self].
	^ aCostume y: val
]

{ #category : #'scripts-standard' }
Player >> show [
	"Make the object be visible, as opposed to hidden"

	self costume show
]

{ #category : #'scripts-standard' }
Player >> shuffleContents [
	"Tell my costume to rearrange its submorphs randomly"

	costume renderedMorph shuffleSubmorphs
]

{ #category : #macpal }
Player >> slotInfo [
	^ self class slotInfo
]

{ #category : #'slots-user' }
Player >> slotInfoAt: slotName [ 
	| info |
	info := self slotInfo at: slotName ifAbsent: [nil].
	info ifNil: [self slotInfo at: slotName put: (info := SlotInformation new)].
	(info isSymbol) ifTrue: ["bkward compat"
			self slotInfo at: slotName put: (info := SlotInformation new type: info)].
	^info
]

{ #category : #'slots-user' }
Player >> slotInfoAt: slotName ifAbsent: aBlock [
	"If the receiver has a slot of the given name, answer its slot info, else answer nil"

	| info |
	info := self slotInfo at: slotName ifAbsent: [^ aBlock value].
	^ info
]

{ #category : #'scripts-kernel' }
Player >> slotInfoButtonHitFor: aGetterSymbol inViewer: aViewer [
	"The user made a gesture asking for slot menu for the given getter symbol in a viewer; put up the menu."

	| aMenu slotSym aType typeVocab interface selector |

	 (#(+ - * /) includes: aGetterSymbol)
		ifTrue:
			 [^ self inform: aGetterSymbol, ' is used for vector operations'].

	slotSym := aGetterSymbol inherentSelector.
	aType := self typeForSlotWithGetter: aGetterSymbol asSymbol.
	aMenu := MenuMorph new defaultTarget: self.
	interface := aViewer currentVocabulary methodInterfaceAt: aGetterSymbol ifAbsent: [nil].
	selector := interface isNil
		ifTrue: [slotSym asString]
		ifFalse: [interface selector].
	aMenu addTitle: (selector, ' (', (aType asString translated), ')').

	aType = #Patch ifTrue: [
		aMenu add: 'grab morph' translated
			target: (self perform: aGetterSymbol)
			selector: #grabPatchMorph
			argument: #().
			aMenu addLine.
	].

	(typeVocab := Vocabulary vocabularyForType: aType) addWatcherItemsToMenu: aMenu forGetter: aGetterSymbol.

	(self slotInfo includesKey: slotSym)
		ifTrue:
			[aMenu add: 'change value type' translated selector: #chooseSlotTypeFor: argument: aGetterSymbol.
			typeVocab addUserSlotItemsTo: aMenu slotSymbol: slotSym.
			aMenu add: ('remove "{1}"' translated format: {slotSym}) selector: #removeSlotNamed: argument: slotSym.
			aMenu add: ('rename "{1}"' translated format: {slotSym}) selector: #renameSlot: argument: slotSym.			aMenu addLine].

	typeVocab addExtraItemsToMenu: aMenu forSlotSymbol: slotSym.  "e.g. Player type adds hand-me-tiles"

	aMenu add: 'show categories....' translated target: aViewer selector: #showCategoriesFor: argument: aGetterSymbol.
	self addIdiosyncraticMenuItemsTo: aMenu forSlotSymol: slotSym.

	aMenu items isEmpty ifTrue:
		[aMenu add: 'ok' translated action: #yourself].

	aMenu popUpForHand: aViewer primaryHand in: aViewer world
]

{ #category : #'slots-user' }
Player >> slotInfoForGetter: aGetter [
	"Answer a SlotInformation object which describes an instance variable of mine retrieved via the given getter, or nil if none"

	^ self slotInfo at: aGetter inherentSelector ifAbsent: [nil]
]

{ #category : #'slots-kernel' }
Player >> slotNames [
	^ self class instVarNames  "Could also get it from the slotInfo dictionary"
			
]

{ #category : #'slots-user' }
Player >> slotNamesOfType: aType [
	"Answer a list of potential slot names of the given type in the receiver"

	| fullList forViewer gettersToOffer |
	fullList := (ScriptingSystem systemSlotNamesOfType: aType),
		(self class slotGettersOfType: aType).
	forViewer := costume renderedMorph selectorsForViewer select:
		[:aSel | aSel beginsWith: 'get'].
	gettersToOffer := fullList select: [:anItem | forViewer includes: anItem].
	^ gettersToOffer collect:
		[:aSel | aSel inherentSelector]
]

{ #category : #'scripts-kernel' }
Player >> sourceCodeFor: sel [
	^ self class sourceCodeAt: sel ifAbsent: 
		[Player sourceCodeAt: sel ifAbsent: ['this space for rent']]
	
]

{ #category : #misc }
Player >> stack [
	"Answer the stack to which the receiver belongs.  This only searches via the costume's parent pointer, so there is no guarantee that the stack that is found actually contains the receiver in its card list"

	^ costume ifNotNil: [costume stack]
]

{ #category : #'slot getters\/setters' }
Player >> stackEmbodied [
	"Answer the stack embodied by the receiver's costume; usually this is directly the receiver's costume, but in case it is not, we look up the owner chain for one.  This allows card-number messages to be sent to a *page* of the stack, as Alan is wont to do, and have them still find their way to the right place"

	| aMorph |
	^ ((aMorph := self costume renderedMorph) isKindOf: StackMorph)
		ifTrue:
			[aMorph]
		ifFalse:
			[aMorph ownerThatIsA: StackMorph]
]

{ #category : #costume }
Player >> stamp [

	"stamp an image of ourself onto the pen trails form"

	costume pasteUpMorph addImageToPenTrailsFor: costume topRendererOrSelf
]

{ #category : #costume }
Player >> stampAndErase [

	self stamp.
	self erase.
]

{ #category : #'scripts-standard' }
Player >> startAll: scriptName [
	"Change the status of my script of the given name to be #ticking in me and all of my siblings."

	self assignStatus: #ticking toAllFor: scriptName
]

{ #category : #costume }
Player >> startHavingParameterFor: aSelector [
	"Start having a parameter for the given selector.  After this change, the script name will change by the addition of a colon."

	| newSelector |
	self renameScript: aSelector newSelector: (newSelector := (aSelector, ':') asSymbol).
	(self scriptEditorFor: newSelector) install
]

{ #category : #'scripts-execution' }
Player >> startRunning [
	self costume arrangeToStartStepping.
	self instantiatedUserScriptsDo:
		[:aScript | aScript startRunningIfPaused]
]

{ #category : #'scripts-execution' }
Player >> startRunningScripts [
	self startRunning.
	self costume arrangeToStartStepping.  "emergency patch, if not going already"
	self costume presenter startRunningScripts
]

{ #category : #'scripts-standard' }
Player >> startScript: scriptName [
	"Change the status of my script of the given name to be #ticking"

	self changeScript: scriptName toStatus: #ticking
]

{ #category : #menus }
Player >> step [
	"obsolete"
	^self stepAt: Time millisecondClockValue.
]

{ #category : #'scripts-execution' }
Player >> stepAt: nowTick [
	self runAllTickingScripts: nowTick
]

{ #category : #'playing commands' }
Player >> stop [
	self sendMessageToCostume: #stop
]

{ #category : #'scripts-standard' }
Player >> stopAll: scriptName [
	"Change the status of my script of the given name to be #normal in me and all of my siblings."

		self assignStatus: #normal toAllFor: scriptName
]

{ #category : #'scripts-execution' }
Player >> stopProgramatically [
	"stop running my ticking scripts -- called from running code"
	self instantiatedUserScriptsDo:
		[:aUserScript | aUserScript stopTicking].
	(self costume renderedMorph isKindOf: SpeakerMorph)
		ifTrue: [costume renderedMorph stopSound].  "turn off buffered speaker sound"
	self costume
		valueOfProperty: #playingSound
		ifPresentDo: [:sound |
			sound stopGracefully.
			self costume removeProperty: #playingSound].
]

{ #category : #'scripts-execution' }
Player >> stopRunning [
	self stopProgramatically
]

{ #category : #'scripts-standard' }
Player >> stopScript: scriptName [
	"Change the status of my script of the given name to be #normal"

	self changeScript: scriptName toStatus: #normal
]

{ #category : #'objects from disk' }
Player >> storeDataOn: aDataStream [
	"Discard all non-showing script editors"

	self releaseCachedState.
	super storeDataOn: aDataStream.

]

{ #category : #printing }
Player >> stringForReadout [
	^ self externalName
]

{ #category : #costume }
Player >> tearOffButtonToFireScriptForSelector: aSelector [
	"Tear off a button to fire the script for the given selector"

	| aButton props |
	Preferences useButtonPropertiesToFire ifFalse:
		[aButton := ScriptActivationButton new.
		aButton initializeForPlayer: self uniclassScript:  (self class scripts at: aSelector).
		^ aButton openInHand].

	(aButton := RectangleMorph new) useRoundedCorners; color: Color yellow.
	props := aButton ensuredButtonProperties.
	props
		target: self;
		actionSelector: #runScript:;
		arguments: {aSelector};
		delayBetweenFirings: 80;
		actWhen: #mouseUp;
		mouseDownHaloWidth: 8;
		wantsRolloverIndicator: true;
		mouseOverHaloWidth: 5;
		establishEtoyLabelWording.
	aButton width: aButton submorphs first width + 20; height: 20.
	self currentHand attachMorph: aButton.

]

{ #category : #'slots-user' }
Player >> tearOffFancyWatcherFor: aGetter [
	"Hand the user a labeled readout for viewing a numeric value"

	(WatcherWrapper new fancyForPlayer: self getter: aGetter) openInHand
]

{ #category : #misc }
Player >> tearOffTileForSelf [
	| tiles |
	self currentHand attachMorph: (tiles := self tileReferringToSelf).
	(tiles isSyntaxMorph) 
		ifTrue: 
			[Preferences tileTranslucentDrag 
				ifTrue: [tiles lookTranslucent]
				ifFalse: 
					[tiles align: tiles topLeft
						with: self currentHand position + tiles cursorBaseOffset]]
]

{ #category : #'slots-user' }
Player >> tearOffUnlabeledWatcherFor: aGetter [ 
	"Hand the user anUnlabeled readout for viewing a numeric value"
	(WatcherWrapper new unlabeledForPlayer: self getter: aGetter) openInHand
]

{ #category : #'slots-user' }
Player >> tearOffWatcherFor: aSlotGetter [
	"Tear off a simple textual watcher for the slot whose getter is provided"

	| aWatcher anInterface info isNumeric |

	info := self slotInfoForGetter: aSlotGetter.
	info
		ifNotNil:
			[isNumeric := info type == #Number]
		ifNil:
			[anInterface := Vocabulary eToyVocabulary methodInterfaceAt: aSlotGetter ifAbsent: [nil].
			isNumeric := anInterface notNil and: [anInterface resultType == #Number]].
	aWatcher := UpdatingStringMorph new.
	
	aWatcher
		growable: true;
		getSelector: aSlotGetter;
		putSelector: (info notNil
			ifTrue:
				[ScriptingSystem setterSelectorForGetter: aSlotGetter]
			ifFalse:
				[anInterface companionSetterSelector]);
		setNameTo: (info notNil
			ifTrue:
				[aSlotGetter inherentSelector]
			ifFalse:
				[anInterface wording]);
 		target: self.
	isNumeric
		ifFalse:
			[aWatcher useStringFormat]
		ifTrue:
			[self setFloatPrecisionFor: aWatcher].
	aWatcher
		step;
		fitContents;
		openInHand
]

{ #category : #'scripts-standard' }
Player >> tellAllContents: aMessageSelector [
	"Send the given message selector to all the content players within the receiver's morph"

	costume renderedMorph tellAllContents: aMessageSelector
]

{ #category : #'scripts-standard' }
Player >> tellAllSiblings: aMessageSelector [
	"Send the given message selector to all my sibling instances, but not to myself"

	Symbol hasInterned: aMessageSelector
		ifTrue: [ :sel |
	self belongsToUniClass
		ifTrue: [self class allSubInstancesDo: 
			[:anInstance | 
			anInstance isInTrash ifFalse: [
				anInstance ~~ self ifTrue: [ anInstance triggerScript: sel ]]]]
		ifFalse: [(sel ~~ #emptyScript) ifTrue:
				[ScriptingSystem reportToUser: ('Cannot "tell " ' translated, aMessageSelector, ' to ' translated, self externalName) ]]]
]

{ #category : #'scripts-standard' }
Player >> tellSelfAndAllSiblings: aMessageSelector [
	"Send the given message selector to all my sibling instances, including myself"

	Symbol hasInterned: aMessageSelector
		ifTrue: [ :sel |
	self belongsToUniClass
		ifTrue: [self class allSubInstancesDo:
			[:anInstance | 
			anInstance isInTrash ifFalse: [
				(anInstance respondsTo: sel) ifTrue:
		[anInstance triggerScript: sel ]]]]
		ifFalse: [(sel ~~ #emptyScript) ifTrue:
				[ScriptingSystem reportToUser: ('Cannot "tell " ' translated, aMessageSelector, ' to ' translated, self externalName) ]]]
]

{ #category : #misc }
Player >> thumbnailMenuEvt: anEvent forMorph: aMorph [
	"The mouse went down in the thumbnail of a Viewer for the receiver"

	^ self offerViewerMenuForEvt: anEvent morph: aMorph
]

{ #category : #misc }
Player >> tileReferringToSelf [

	| aTile |
	aTile := TileMorph new setToReferTo: self.
	aTile updateWordingToMatchVocabulary.
	^ aTile
]

{ #category : #viewer }
Player >> tileToRefer [
	"Answer a reference tile that comprises an alias to me.  Forgive this temporary and seemingly gratuituous revectoring as worlds collide"

	^ self tileReferringToSelf
]

{ #category : #'scripts-kernel' }
Player >> tilesToCall: aMethodInterface [
	"Answer a phrase for the non-typed command represented by aMethodInterface."

	| resultType cmd argType argTile selfTile aPhrase balloonTextSelector aDocString universal |
	self class namedTileScriptSelectors.

	resultType := aMethodInterface resultType.
	cmd := aMethodInterface selector.
	(universal := self isUniversalTiles)
		ifTrue:
			[aPhrase := self universalTilesForInterface: aMethodInterface]
		ifFalse: [cmd numArgs = 0
			ifTrue:
				[aPhrase := PhraseTileMorph new setOperator: cmd
					type: resultType
					rcvrType: #Player]
			ifFalse:
				["only one arg supported in classic tiles, so if this is fed
				with a selector with > 1 arg, results will be very strange"
				argType := aMethodInterface typeForArgumentNumber: 1.
				aPhrase := PhraseTileMorph new setOperator: cmd
					type: resultType
					rcvrType: #Player
					argType: argType.
				argTile := ScriptingSystem tileForArgType: argType.
				argTile position: aPhrase lastSubmorph position.
				aPhrase lastSubmorph addMorph: argTile]].

	(self slotInfo includesKey: cmd)
		ifTrue: [balloonTextSelector := #userSlot].

	(self belongsToUniClass and: [self class includesSelector: cmd])
		ifTrue:
			[aDocString := (self class userScriptForPlayer: self selector: cmd) documentation.
			aDocString
				ifNotNil: [aPhrase submorphs second setBalloonText: aDocString]
				ifNil: [balloonTextSelector := #userScript]].

	(universal ifTrue: [aPhrase submorphs second] ifFalse: [aPhrase operatorTile]) balloonTextSelector: 
			(balloonTextSelector ifNil: [cmd]).
	universal ifFalse:
		[selfTile := self tileToRefer.
		selfTile position: aPhrase firstSubmorph position.
		aPhrase firstSubmorph addMorph: selfTile.
		aPhrase makeAllTilesGreen.
		aPhrase justGrabbedFromViewer: false].
	^ aPhrase
]

{ #category : #'as yet unclassified' }
Player >> toggleShowName [
	| watcher |
	self costume ifNil: [^ self].
	watcher := self costume valueOfProperty: #nameWatcher ifAbsent: [nil].
	watcher
		ifNil: [
			watcher := FollowingWatcher new unlabeledForPlayer: self getter: #externalName.
			watcher openInWorld.]
		ifNotNil: [
			watcher delete.
			watcher := nil].
	self costume setProperty: #nameWatcher toValue: watcher.
]

{ #category : #'playing commands' }
Player >> totalFrames [

	^ self sendMessageToCostume: #totalFrames

]

{ #category : #'playing commands' }
Player >> totalSeconds [

	^ self sendMessageToCostume: #totalSeconds

]

{ #category : #misc }
Player >> touchesA: aPrototypicalPlayer [
	"Answer whether the receiver overlaps any player who wears a Sketch costume and who is of the same class as the prototypicalPlayer and who is wearing the same bitmap, but who is *not that player itself*!  This is an extreme case of a function highly customized (by Bob Arning) to suit a single, idiosycratic, and narrow demo need of Alan's.  Consult:
http://groups.yahoo.com/group/squeak/message/40560"

	| envelope trueGoal trueSelf |
	aPrototypicalPlayer ifNil: [^ false].
	envelope := costume owner ifNil: [^ false].
	trueSelf := costume renderedMorph.
	trueGoal := aPrototypicalPlayer costume renderedMorph.
	envelope submorphs do: [:each | | trueNeighbor itsPlayer |
		trueNeighbor := each renderedMorph.
		(trueNeighbor == trueGoal or: [trueNeighbor == trueSelf]) ifFalse:
			[(itsPlayer := each player) ifNotNil:
				[(itsPlayer overlaps: self) ifTrue:
					[(trueGoal appearsToBeSameCostumeAs: trueNeighbor) ifTrue: [^ true]]]]].
	^ false

]

{ #category : #pen }
Player >> trailStyleForAllPens: aTrailStyle [
	"Only for the Player of a World"

	self costume renderedMorph trailStyleForAllPens: aTrailStyle
]

{ #category : #'customevents-custom events' }
Player >> triggerCustomEvent: aSymbol [
	"Trigger whatever scripts may be connected to the custom event named aSymbol"

	self costume renderedMorph triggerCustomEvent: aSymbol
]

{ #category : #'customevents-custom events' }
Player >> triggerScript: aSymbol [ 
	"Perform the script of the given name,
	which is guaranteed to exist.
	However, it's possible that the script may still result in a DNU,
	which will be swallowed and reported to the Transcript."

	^ [[self perform: aSymbol]
		on: GetTriggeringObjectNotification do: [ :ex |
			ex isNested
				ifTrue: [ ex pass ]
				ifFalse: [ ex resume: self ]]]
		on: MessageNotUnderstood
		do: [:ex | 
			ScriptingSystem
				reportToUser: (String
						streamContents: [:s | s nextPutAll: self externalName;
								 nextPutAll: ': exception in script ' translated;
								 print: aSymbol;
								 nextPutAll: ' : ';
								 print: ex]).
			ex return: self
			"ex pass"]
]

{ #category : #name }
Player >> tryToRenameTo: aName [
	self costume topRendererOrSelf tryToRenameTo: aName
]

{ #category : #'scripts-standard' }
Player >> turn: degrees [
	"Rotate the heading of the object by the given number of degrees"

	degrees ifNil: [^ self].
	degrees = 0 ifTrue: [^ self].
	self setHeading: (self getHeading + degrees asFloat) \\ 360.0

]

{ #category : #'scripts-standard' }
Player >> turnToward: aPlayer [
	"Turn to face the given player, unless our positions coincide."

	|  aCostume myPosition itsPosition |
	(aPlayer == nil or: [aPlayer == self]) ifTrue: [^ self].
	aCostume := self costume.
	aCostume isWorldMorph ifTrue: [^ self].
	(self overlaps: aPlayer) ifFalse:
		[((myPosition := aCostume referencePosition) = (itsPosition := aPlayer costume referencePosition))
			ifFalse: "avoid division by zero ;-("
				[self setHeading: (myPosition bearingToPoint: itsPosition)]]

]

{ #category : #'slots-kernel' }
Player >> typeForSlot: aSlotName [
	"Answer the data type for values of the instance variable of the given name"

	| getter |
	(self slotInfo includesKey: aSlotName) ifTrue: [^ (self slotInfoAt: aSlotName) type].
	getter := (aSlotName beginsWith: 'get')
		ifTrue:
			[aSlotName]
		ifFalse:
			[aSlotName asGetterSelector].
	^ (self currentVocabulary methodInterfaceAt: getter ifAbsent: [self error: 'Unknown slot name: ', aSlotName]) resultType
]

{ #category : #'slots-kernel' }
Player >> typeForSlot: aSlotName vocabulary: aVocabulary [
	"Answer the data type for values of the instance variable of the given name.  Presently has no senders but retained for a while..."

	| getter inherentSelector |
	inherentSelector := aSlotName inherentSelector.
	(self slotInfo includesKey: inherentSelector) ifTrue: [^ (self slotInfoAt: inherentSelector) type].
	getter := (aSlotName beginsWith: 'get')
		ifTrue:
			[aSlotName]
		ifFalse:
			[aSlotName asGetterSelector].
	^ (aVocabulary methodInterfaceAt: getter ifAbsent: [self error: 'Unknown slot name: ', aSlotName]) resultType
]

{ #category : #'slots-kernel' }
Player >> typeForSlotWithGetter: aGetter [
	"Answer the data type for values of the instance variable of the given name"

	| getter inherentSelector |
	(#(color:sees: seesColor: touchesA: overlaps: overlapsAny:) includes: aGetter) ifTrue: [^ #Boolean].
	(#(+ * - /) includes: aGetter) ifTrue: [^ #Player].  "weird vector stuff"
  	"Annoying special cases"

	inherentSelector := aGetter inherentSelector.
	(self slotInfo includesKey: inherentSelector) ifTrue: [^ (self slotInfoAt: inherentSelector) type].
	getter := (aGetter beginsWith: 'get')
		ifTrue:
			[aGetter]
		ifFalse:
			[aGetter asGetterSelector].
	^ (Vocabulary eToyVocabulary methodInterfaceAt: getter ifAbsent: [self error: 'Unknown slot name: ', aGetter]) resultType
]

{ #category : #costume }
Player >> typeforParameterFor: aSelector [
	"Answer the type of the parameter for the given selector"

	(self class scripts at: aSelector ifAbsent: [nil]) ifNotNil:
		[:aScript | ^ aScript argumentVariables first variableType].
	self error: 'No parameter type for ', aSelector.
	^ #Number
]

{ #category : #misc }
Player >> unhideHiddenObjects [
	self sendMessageToCostume: #unhideHiddenObjects
]

{ #category : #misc }
Player >> uninstallFrom: aPlayfield [
	"The receiver is about to be supplanted by another instance which is about to be installed as the current 'card' in the playfield.  Exit gracefully"

	self runAllClosingScripts.
	self commitCardPlayerDataFrom: aPlayfield
]

{ #category : #viewer }
Player >> uniqueNameForReference [

	^ self costume referenceWorld uniqueNameForReferenceFor: self.

]

{ #category : #'scripts-kernel' }
Player >> universalTilesForInterface: aMethodInterface [
	"Return universal tiles for the given method interface.  Record who self is."

	| ms itsSelector argList makeSelfGlobal phrase aType |
	itsSelector := aMethodInterface selector.
	argList := OrderedCollection new.
	aMethodInterface argumentVariables doWithIndex:
		[:anArgumentVariable :anIndex | | argTile | 
			argTile := ScriptingSystem tileForArgType: (aType := aMethodInterface typeForArgumentNumber: anIndex).
			argList add: (aType == #Player 
				ifTrue: [argTile actualObject]
				ifFalse: [argTile literal]).	"default value for each type"].

	ms := MessageSend receiver: self selector: itsSelector arguments: argList asArray.
	"For CardPlayers, use 'self'.  For others, name me, and use my global name."
	makeSelfGlobal := self class officialClass ~~ CardPlayer.
	phrase := ms asTilesIn: self class globalNames: makeSelfGlobal.
	makeSelfGlobal ifFalse: [phrase setProperty: #scriptedPlayer toValue: self].
	^ phrase

]

{ #category : #'slots-user' }
Player >> unlabeledWatcherFor: aGetter [
	"Answer an unnlabeled readout for viewing a numeric-valued slot of mine"

	| aWatcher info anInterface watcherWording itsType vocab aSetter |
	info := self slotInfoForGetter: aGetter.
	info ifNotNil:
			[itsType := info type.
			watcherWording := aGetter inherentSelector.
			aSetter := watcherWording asSetterSelector]
		ifNil:
			[anInterface :=Vocabulary eToyVocabulary methodInterfaceAt: aGetter ifAbsent: [nil].
			anInterface
				ifNotNil:
					[itsType := anInterface resultType.
					aSetter := anInterface companionSetterSelector]
				ifNil:
					[itsType := #Unknown.
					aSetter := nil].
			watcherWording := anInterface ifNotNil: [anInterface wording] ifNil: ['*']].
	vocab := Vocabulary vocabularyForType: itsType.
	aWatcher := vocab updatingTileForTarget: self partName: watcherWording getter: aGetter setter: aSetter.

	aWatcher setNameTo: (self externalName, '''s ', watcherWording).
	aWatcher minHeight: (vocab wantsArrowsOnTiles ifTrue: [22] ifFalse: [14]).
	^ aWatcher
]

{ #category : #misc }
Player >> unusedScriptName [
	"answer a name of the form 'scriptN', where N is one higher than the highest-numbered similarly-named script"

	| defaultStem highestThus aPair |
	defaultStem := self defaultScriptName.
	highestThus := 0.
	self class tileScriptNames do:
		[:aName |
			aPair := (aName copyWithout: $:) stemAndNumericSuffix.
			aPair first = defaultStem ifTrue: [highestThus := highestThus max: aPair last]].
	^ (defaultStem, (highestThus + 1) printString) asSymbol
]

{ #category : #misc }
Player >> updateAllViewers [
	"The receiver's structure has changed, so viewers on it and its siblings need to be reconstituted."

	| aPresenter |
	(aPresenter := self costume presenter) ifNil: [^ self].
	self allOpenViewersOnReceiverAndSiblings do:
		[:aViewer | aPresenter updateViewer: aViewer]
]

{ #category : #misc }
Player >> updateAllViewersAndForceToShow: aCategory [
	"The receiver's structure has changed, so viewers on it and all its siblings need to be reconstituted."

	| aPresenter |
	(aPresenter := self costume presenter) ifNil: [^ self].
	self allOpenViewersOnReceiverAndSiblings do:
		[:aViewer | aPresenter updateViewer: aViewer forceToShow: aCategory]
]

{ #category : #'slots-kernel' }
Player >> usableMethodInterfacesIn: methodInterfaceList [
	"Filter the list given by methodInterfaceList, to remove items inappropriate to the receiver"

	self hasCostumeThatIsAWorld ifTrue:
		"Formerly we had been hugely restrictive here, but let's try the other extreme for a while..."
		[^ methodInterfaceList reject: [:anInterface |
			#(getShadowColor getDropShadow getRoundedCorners getBorderStyle getBorderColor getBorderWidth)  includes: anInterface selector]].

	self hasAnyBorderedCostumes ifTrue: [^ methodInterfaceList].

	^ self hasOnlySketchCostumes
		ifTrue:
			[methodInterfaceList select: [:anInterface | (#(getColor getSecondColor getBorderColor getBorderWidth getBorderStyle  getRoundedCorners getUseGradientFill getRadialGradientFill  getRed getGreen getBlue getAlpha getHue getBrightness getSaturation ) includes: anInterface selector) not]]
		ifFalse:
			[methodInterfaceList select: [:anInterface | (#(getBorderColor getBorderWidth) includes: anInterface selector) not]]
]

{ #category : #'slot-kedama' }
Player >> useTurtle: aPlayer [

	aPlayer costume renderedMorph kedamaWorld: costume renderedMorph.
	aPlayer costume renderedMorph install.

]

{ #category : #'slots-user' }
Player >> valueOfType: aType from: oldValue [
	"The user has changed a slot's type to aType; convert its former value, oldValue, to something of the appropriate type.  For now, does not take oldValue into account"
	^ self initialValueForSlotOfType: aType
]

{ #category : #copying }
Player >> veryDeepFixupWith: deepCopier [
	"Any uniClass inst var may have been weakly copied.  If they were in the tree being copied, fix them up, otherwise point to the originals."

	super veryDeepFixupWith: deepCopier.
	Player instSize + 1 to: self class instSize do:
		[:ii |
		| old |
		old := self instVarAt: ii.
		self instVarAt: ii put: (deepCopier references at: old ifAbsent: [old])].

]

{ #category : #copying }
Player >> veryDeepInner: deepCopier [
	"Special code that handles user-added instance variables of a uniClass.
	Copy all of my instance variables.  Some need to be not copied at all, but shared.  This is special code for the dictionary.  See DeepCopier."
	| instVar weak subAss |

	super veryDeepInner: deepCopier.
	"my own instance variables are completely normal"
	costume := costume veryDeepCopyWith: deepCopier.
	costumes := costumes veryDeepCopyWith: deepCopier.

	Player instSize + 1 to: self class instSize do: [:index |
		instVar := self instVarAt: index.
		weak := instVar isMorph | instVar isPlayerLike. 
		(subAss := deepCopier references associationAt: instVar ifAbsent: [nil])
				"use association, not value, so nil is an exceptional value"
			ifNil: [weak ifFalse: [
					self instVarAt: index put: (instVar veryDeepCopyWith: deepCopier)]]
			ifNotNil: [self instVarAt: index put: subAss value].
		].

]

{ #category : #misc }
Player >> viewerFlapTab [
	"If a viewer in a flap exists for me, return it."

	(costume world ifNil: [self currentWorld])
		submorphsDo: [:mm |
			(mm isKindOf: ViewerFlapTab)
				ifTrue:
					[mm scriptedPlayer == self
						ifTrue: [^mm]]].
	^nil
]

{ #category : #testing }
Player >> wantsSteps [
	"UnscriptedPlayer, with no scripts, overrides to false"
	^ true
]

{ #category : #costume }
Player >> wearCostumeOf: anotherPlayer [
	"Put on a costume similar to the one currently worn by anotherPlayer"

	| aForm itsMorph |
	aForm := anotherPlayer getGraphic deepCopy.
	aForm offset: 0 @ 0.
	itsMorph := anotherPlayer costume.
	costume rotationStyle: itsMorph rotationStyle.
	"costume forwardDirection: itsMorph forwardDirection."
	self setGraphic: aForm rotationCenter: itsMorph rotationCenter


"	self renderedCostume: (anotherPlayer costume renderedMorph asWearableCostumeOfExtent: self costume extent) remember: anotherPlayer costume shouldRememberCostume Unmatched comment quote ->s"
]

{ #category : #costume }
Player >> wearCostumeOfClass: aClass [
	"Assume that the costume in the library has player = nil"
	| newCostume |
	(costume renderedMorph isKindOf: aClass) ifTrue: [^ self].
	costumes ifNotNil:
		[costumes do:
			[:aCostume | (aCostume class  == aClass)
				ifTrue:
					[^ self renderedCostume: aCostume]]].

	newCostume := aClass new.
	self renderedCostume: newCostume
]

{ #category : #costume }
Player >> wearCostumeOfName: aName [
	| classToUse |
	classToUse := Smalltalk at: (aName, 'Morph') asSymbol ifAbsent: 
		[Smalltalk at: aName asSymbol].
	self wearCostumeOfClass: classToUse
]

{ #category : #misc }
Player >> width [
	^ self costume width
]

{ #category : #'scripts-standard' }
Player >> wrap [
	"If the object has gone outside the bounds of its container, zap it over to the opposite edge of the container, providing a 'wrapping' impression "

	self costume wrap
]
