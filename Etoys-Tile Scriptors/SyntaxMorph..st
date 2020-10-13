"
A single class of morph that holds any piece of Smalltalk syntax, and allows it to be a tile.  Tiles can be dragged in or out of a method. 

In the message list pane of a Browser, choose 'tile scriptor'.  Bring up a second one to steal parts from.  If you use a Protocol Browser, and choose tiles, there will be two buttons that bring up menus with many tiles on them.

Clicking multiple times selects enclosing phrases of code.  Dragging lets you take away a copy.  Any tile may be replaced by dropping on it.  Shift-click to edit the text of any tile.  Change variable and message names, but do not change the part-of-speech (objects to selector).

Each SyntaxMorph holds a ParseNode.  After editing, the parseNode is only good as a part-of-speech indicator.  Only the Class of a parseNode is important.  It's state is not kept up to date with the tile edits (but maybe it should be).  (For MessageNodes, whether the receiver slot is nil is significant.)

The correspondence between SyntaxMorphs and parseNodes in the real parse tree is not one-to-one.  Several extra levels of SyntaxMorph were added as aligners to make the horizontal and vertical layout right.  These sometimes have nil for the parseNode.

When accept the method, we pass over the tree of SyntaxMorphs, gathering their printStrings and inserting punctuation.  See (SyntaxMorph>>printOn:indent:).  We send the result to the compiler.  (We do not use the parse tree we already have.)

To turn on type checking: 
Preferences enable: #eToyFriendly
or for testing:     World project projectParameters at: #fullCheck put: true.

Colors of tiles:  Each tile has a current color (inst car color) and a deselectedColor (a property).  The deselectedColor may be governed by the part of speech, or not.  (translateColor: is only used when a tile is created, to set deselectedColor.)  From deselectedColor (set by #setDeselectedColor), the color changes to:
	lightBrown when selected (not the submorphs) in #select
	translucent when held in the hand (allMorphs) in #lookTranslucent
	green when a drop target (allMorphs) (change the owners back) #dropColor, 
		#trackDropZones 
deselectedColor is moderated by the darkness setting, #scaleColorByUserPref:.  (as it is put into color in #color:)

Code to produce an individual tile is: 
	(SyntaxMorph new) attachTileForCode: '''abc''' nodeType: LiteralNode.
see offerTilesMenuFor:in: for many other phrases that produce useful tiles.

AssignmentNode:  If three submorphs, is a statement, and is a noun.  If one submorph, is just the left arrow.  When dropped on a variable, it creates a new assignment statement. 
"
Class {
	#name : #SyntaxMorph,
	#superclass : #AlignmentMorph,
	#instVars : [
		'parseNode',
		'markerMorph'
	],
	#classVars : [
		'AllSpecs',
		'ContrastFactor',
		'DownRightArrow',
		'SelfTile',
		'SizeScaleFactor'
	],
	#category : #'Etoys-Tile Scriptors'
}

{ #category : #accessing }
SyntaxMorph class >> allSpecs [
	"Return all specs that the Viewer knows about. Cache them."
	"SyntaxMorph allSpecs"

	^AllSpecs ifNil: [
		AllSpecs := Dictionary new.
		(EToyVocabulary morphClassesDeclaringViewerAdditions)
			do: [:cls | cls allAdditionsToViewerCategories keysAndValuesDo: [ :k :v | 
				(AllSpecs at: k ifAbsentPut: [ OrderedCollection new ]) addAll: v ] ].
		AllSpecs
	]
]

{ #category : #accessing }
SyntaxMorph class >> clearAllSpecs [
	"Clear the specs that the Viewer knows about."
	"SyntaxMorph clearAllSpecs"

	AllSpecs := nil.
]

{ #category : #'as yet unclassified' }
SyntaxMorph class >> column: aColor on: aParseNode [

	| c color |
	color := self translateColor: aColor.
	(c := self newColumn)
		parseNode: aParseNode;
		layoutInset: c standardInset;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		color: color;
		borderWidth: 1;
		borderColor: c stdBorderColor;
		wrapCentering: #topLeft;
		cellPositioning: c standardCellPositioning.
	^c

]

{ #category : #'as yet unclassified' }
SyntaxMorph class >> methodNodeOuter: aNode [

	^(self column: #method on: aNode) methodNodeOuter: aNode

]

{ #category : #'as yet unclassified' }
SyntaxMorph class >> noTileColor [

	^ true
]

{ #category : #'as yet unclassified' }
SyntaxMorph class >> row: aColor on: aParseNode [

	| r color |
	color := self translateColor: aColor.
	(r := self newRow)
		parseNode: aParseNode;
		layoutInset: r standardInset;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		color: color;
		borderWidth: 1;
		borderColor: r stdBorderColor;
		wrapCentering: #topLeft;
		cellPositioning: r standardCellPositioning.
	^r
]

{ #category : #'as yet unclassified' }
SyntaxMorph class >> setSize: oldExtent andMakeResizable: outerMorph [
	| tw |
	(tw := outerMorph findA: ScrollPane) ifNil: [^self].
	tw hResizing: #spaceFill;
		vResizing: #spaceFill;
		color: Color transparent;
		setProperty: #hideUnneededScrollbars toValue: true.
	outerMorph 
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		cellPositioning: #topLeft.
	outerMorph fullBounds.

]

{ #category : #accessing }
SyntaxMorph class >> sourceCodeTemplate [
	"Return the default tile method template"

	^ 'anEmpty: input1 method: input2
	"Edit the name above and the code below to make your own method"
	3 + 4.
	"Drag tiles in here.  Use the ''tiles'' and ''vars'' menus to get new tiles"
	^ ''this is a statement'' sort'  

]

{ #category : #'as yet unclassified' }
SyntaxMorph class >> standardInset [

	^ self alansTest1 ifTrue: [1] ifFalse: [-1 @ -1]
]

{ #category : #'as yet unclassified' }
SyntaxMorph class >> test [

"
SyntaxMorph test
"
	self testClass: MessageNode andMethod: #asMorphicSyntaxIn:.
	"self testClass: MethodNode andMethod: #asMorphicSyntaxIn:."


]

{ #category : #'as yet unclassified' }
SyntaxMorph class >> testAll [

	| systNav total count|
"
SyntaxMorph testAll
"
	systNav := self systemNavigation.
	count := total := 0.
	systNav allBehaviorsDo: [ :aClass | total := total + 1].
'Testing all behaviors'
	displayProgressFrom: 0 to: total
	during: [ :bar |
		systNav allBehaviorsDo: [ :aClass |
			bar value: (count := count + 1).
			aClass methodsDo: [ :m |
				| source tree |
				source := m getSourceFromFile.
				tree := Compiler new 
					parse: source 
					in: aClass 
					notifying: nil.
				tree asMorphicSyntaxUsing: SyntaxMorph.
			].
		].	].



]

{ #category : #'as yet unclassified' }
SyntaxMorph class >> testAllMethodsOver: methodSize [ 
	"MessageTally spyOn: [SyntaxMorph testAllMethodsOver: 600]"
	"Add up the total layout area for syntax morphs representing all  
	methods over the given size. This is a stress-test for SyntaxMorph  
	layout. A small value for the total area is also a figure of merit in the  
	presentation of Squeak source code in general."
	"Results:  
	#(69 600 180820874 103700) 11/4  
	70% build morphs, 12% get source, 9% layout, 8% parse, 1% roundoff  
	Folded wide receivers, don't center keywords any more.  
	#(68 600 160033784 127727) 11/9  
	76% build morphs, 8% get source, 8% layout, 8% parse, 0% roundoff  
	Folded more messages, dropped extra vertical spacing in blocks.  
	#(68 600 109141704 137308) 11/10  
	79% build morphs, 6% get source, 8% layout, 7% parse  
	Folded more messages, dropped extra horizontal spacing.  
	#(68 600 106912968 132171) 11/10  
	80% build morphs, ??% get source, 11% layout, 7% parse  
	Unfolded keyword messages that will fit on one line.  
	#(68 600 96497372 132153) 11/10  
	81% build morphs, ??% get source, 8% layout, 8% parse  
	After alignment rewrite...  
	#(74 600 101082316 244799) 11/12  
	76% build morphs, 4% get source, 15% layout, 5% parse  
	After alignment rewrite...  
	#(74 600 101250620 204972) 11/15  
	74% build morphs, 6% get source, 13% layout, 7% parse  
	"
	| biggies stats area |
	biggies := self systemNavigation 
				allMethodsSelect: [:cm | cm size > methodSize].
	stats := OrderedCollection new.
	'Laying out all ' , biggies size printString , ' methods over ' , methodSize printString , ' bytes...'
		displayProgressFrom: 1
		to: biggies size
		during: [:bar | biggies
				withIndexDo: [:methodRef :i | | time | 
					bar value: i.
					Utilities
						setClassAndSelectorFrom: methodRef
						in: [:aClass :aSelector | | source | 
							source := (aClass compiledMethodAt: aSelector) getSourceFromFile.
							time := Time
										millisecondsToRun: [ | tree morph |
											tree := Compiler new
														parse: source
														in: aClass
														notifying: nil.
											morph := tree asMorphicSyntaxUsing: SyntaxMorph.
											area := morph fullBounds area]].
					stats add: {methodRef. area. time}]].
	^ {{
			biggies size.
			methodSize.
			stats detectSum: [:a | a second].
			stats detectSum: [:a | a third]
		}.
		stats asArray sort: [:x :y | x third >= y third]}
]

{ #category : #'as yet unclassified' }
SyntaxMorph class >> testClass: aClass andMethod: aSelector [
	| tree |
	tree := Compiler new 
		parse: (aClass sourceCodeAt: aSelector) 
		in: aClass 
		notifying: nil.
	(tree asMorphicSyntaxUsing: SyntaxMorph)
		parsedInClass: aClass;
		openInWindow
]

{ #category : #'as yet unclassified' }
SyntaxMorph class >> translateColor: aColorOrSymbol [

	aColorOrSymbol isColor  ifTrue: [^ aColorOrSymbol].
	aColorOrSymbol == #comment  ifTrue: [^ Color blue lighter].
	aColorOrSymbol == #block  ifTrue: [^ Color r: 0.903 g: 1.0 b: 0.903].
	aColorOrSymbol == #method  ifTrue: [^ Color r: 0.903 g: 1.0 b: 0.903].
	aColorOrSymbol == #text  ifTrue: [^ Color r: 0.9 g: 0.9 b: 0.9].

	self noTileColor ifTrue: [^ Color r: 1.0 g: 0.839 b: 0.613].	"override"

	aColorOrSymbol == #assignment  ifTrue: [^ Color paleGreen].
	aColorOrSymbol == #keyword1  ifTrue: [^ Color paleBuff].	"binary"
	aColorOrSymbol == #keyword2  ifTrue: [^ Color paleBuff lighter].	"multipart" 
	aColorOrSymbol == #cascade  ifTrue: [^ Color paleYellow darker].	"has receiver"
	aColorOrSymbol == #cascade2  ifTrue: [^ Color paleOrange].	"one send in the cascade"
	aColorOrSymbol == #literal  ifTrue: [^ Color paleMagenta].
	aColorOrSymbol == #message  ifTrue: [^ Color paleYellow].
	aColorOrSymbol == #method  ifTrue: [^ Color white].
	aColorOrSymbol == #error  ifTrue: [^ Color red].
	aColorOrSymbol == #return  ifTrue: [^ Color lightGray].
	aColorOrSymbol == #variable  ifTrue: [^ Color paleTan].
	aColorOrSymbol == #brace  ifTrue: [^ Color paleOrange].
	aColorOrSymbol == #tempVariable  ifTrue: [^ Color paleYellow mixed: 0.75 with: Color paleGreen
		"Color yellow lighter lighter"].
	aColorOrSymbol == #blockarg2  ifTrue: [
			^ Color paleYellow mixed: 0.75 with: Color paleGreen].	"arg itself"
	aColorOrSymbol == #blockarg1  ifTrue: [^ Color paleRed].	"container"
		"yellow mixed: 0.5 with: Color white"

	^ Color tan	"has to be something!"
]

{ #category : #'alans styles' }
SyntaxMorph >> aSimpleStringMorphWith: aString [

	self alansTest1 ifTrue: [
		^StringMorph contents: aString font: self alansCurrentFontPreference
	].

	^StringMorph contents: aString
]

{ #category : #menus }
SyntaxMorph >> accept [
	"Turn my current state into the text of a method.  Compile it in my class."

	^ self acceptInCategory: ClassOrganizer default
]

{ #category : #layout }
SyntaxMorph >> acceptDroppingMorph: aMorph event: evt [
	| itNoun old |
	"Two cases: 1) a phrase being dropped into a block.  Add a new line.
		2) aMorph is replacing self by dropping on it.
	For the moment, you have to drop it the right place (the end of a tile if it is complex).  We do not look at enclosing morphs"

	itNoun := aMorph isNoun.
	self withAllOwnersDo:
		[:m | (m isSyntaxMorph and: [m isBlockNode])
				ifTrue: [m stopStepping; removeDropZones]].
	self isBlockNode & itNoun ifTrue:
		[(aMorph nodeClassIs: TempVariableNode) ifTrue:
				["If I am a BlockNode, and it is a TempVariableNode, add it into list"
				(self addBlockArg: aMorph)].
		"If I am a BlockNode and it is a noun add it as a new line"
		^ self addToBlock: aMorph event: evt].
				
	self isBlockNode ifTrue: [
		 (aMorph nodeClassIs: CommentNode) ifTrue: [^ self addToBlock: aMorph event: evt].
		 (aMorph nodeClassIs: ReturnNode) ifTrue: [^ self addToBlock: aMorph event: evt]].

	"Later add args and keywords.  later allow comments to be dropped"

	"Can't put statement, literal, assignment, or cascade into left side of assignment"
	(owner isSyntaxMorph) ifTrue:
		[(owner nodeClassIs: AssignmentNode) ifTrue:
			[(owner submorphIndexOf: self) = 1 ifTrue:
				[aMorph isAVariable ifFalse: [ ^ self]]]].

	(aMorph nodeClassIs: AssignmentNode) ifTrue: [
		itNoun ifFalse: ["create a new assignment"
			self isAVariable ifTrue: [^ self newAssignment]
					ifFalse: [^ self]]].	"only assign to a variable"

	aMorph deselect.
	(old := owner) replaceSubmorph: self by: aMorph.	"do the normal replacement"
	(old isSyntaxMorph) ifTrue: [old cleanupAfterItDroppedOnMe].	"now owned by no one"

]

{ #category : #menus }
SyntaxMorph >> acceptIfInScriptor [
	| root |
	"If I am in a ScriptEditorMorph, tell my root to accept the new changes."

	(self ownerThatIsA: ScriptEditorMorph) ifNotNil: [
		root := self rootTile.
		root ifNotNil: [root accept]]. 
]

{ #category : #menus }
SyntaxMorph >> acceptIgnoring: aString [
	"If I am inside a ScriptEditorMorph, tell my root to accept the new changes.  Ignore the argument, which is the string whose conents just changed."

	thisContext sender receiver removeProperty: #syntacticallyCorrectContents.
	self acceptIfInScriptor
]

{ #category : #menus }
SyntaxMorph >> acceptInCategory: categoryString [
	"Turn my current state into the text of a method.  Compile it in my class."
	| cls sc sel |
	self isMethodNode ifFalse: [
		self rootTile == self ifTrue: [^ self].  "not in a script"
		^ self rootTile accept  "always accept at the root"].
	(cls := self parsedInClass) ifNil: [^ self].
	sel := cls compile: self decompile classified: categoryString.
	(sc := self firstOwnerSuchThat: [:mm | mm class == ScriptEditorMorph]) 
		ifNotNil: [sc hibernate; unhibernate].	"rebuild the tiles"
	^ sel
]

{ #category : #menus }
SyntaxMorph >> acceptSilently [
	"Turn my current state into the text of a method.
	Compile it in my class.  Don't rebuild the tiles."
	| cls |
	self isMethodNode ifFalse: [
		self rootTile == self ifTrue: [^ false].  "not in a script"
		^ self rootTile acceptSilently  "always accept at the root"].
	(self ownerThatIsA: ScriptEditorMorph) ifNil: [^ false].
	(cls := self parsedInClass) ifNil: [^ false].
	cls compile: self decompile classified: 'scripts'.
	^ true
]

{ #category : #menus }
SyntaxMorph >> acceptUnlogged [
	"This is an exact copy of acceptSilently, except it does not log to the source file.
	Used for all but the last of scrolling number changes."
	| cls |
	self isMethodNode ifFalse:
		[self rootTile == self ifTrue: [^ self].  "not in a script"
		^ self rootTile acceptUnlogged  "always accept at the root"].
	(self ownerThatIsA: ScriptEditorMorph) ifNil: [^ self].
	(cls := self parsedInClass) ifNil: [^ self].
	cls compile: self decompile
		classified: ClassOrganizer default
		withStamp: nil
		notifying: nil
		logSource: false.

]

{ #category : #accessing }
SyntaxMorph >> actualObject [
	| sub |
	"Who is self in these tiles?  Usually a Player."


	(self nodeClassIs: LiteralVariableNode) ifTrue: [
		(sub := self findA: StringMorph) ifNil: [^ nil].
		"Need to decompile here for odd synonyms of 'self' ?"
		^ Compiler evaluate: sub contents for: Player].

	(self nodeClassIs: VariableNode) ifTrue: [
		(sub := self findA: StringMorph) ifNil: [^ nil].
		^ References at: (self cleanUpString: sub) asSymbol ifAbsent: [nil]].

	(self nodeClassIs: LiteralNode) ifTrue: [
		(sub := self findA: StringMorph) ifNil: [^ nil].
		^ Compiler evaluate: sub contents for: nil].

	(sub := self findA: SyntaxMorph) ifNil: [^ nil].
	^ sub actualObject	"receiver"
]

{ #category : #'pop ups' }
SyntaxMorph >> addArg: index [ 
	"I rep a SelectorNode.  My string has been replaced.  Append an argument to my owner."

	"See if any sample args are recorded"

	| sel rec aVocabulary mi sample descrip mthNode tiles |
	sel := self decompile asString asSymbol.
	rec := self receiverObject.
	sample := rec class == Error 
				ifFalse: 
					[aVocabulary := self vocabularyToUseWith: rec.
					mi := aVocabulary methodInterfaceAt: sel ifAbsent: [nil].
					mi ifNil: [5]
						ifNotNil: 
							[descrip := mi argumentVariables at: index.
							descrip sample]]
				ifTrue: [5]. 
	mthNode := self string: sample storeString toTilesIn: sample class.
	tiles := mthNode submorphs at: mthNode submorphs size - 1.	"before the ^ self"
	self owner addMorphBack: tiles
]

{ #category : #layout }
SyntaxMorph >> addBlockArg: aMorph [
	"Add a temporary to a block or the method.  Return true if succeed"
	"(aMorph nodeClassIs: TempVariableNode) is known to be true."
	"***NOTE: This method should be combined with addTempVar:"

	| tempHolder tt var nn |
	owner isMethodNode ifTrue: [
		^ (self addTempVar: aMorph)].	"Node for them is not inside the block"
		"If exists, drop the temp in this block and let user extend it."
	nn := aMorph decompile string.	"name"
	(self isKnownVarName: nn) ifTrue: [^ false].	"already defined"

	tt := self firstSubmorph.
	tempHolder := tt firstSubmorph isSyntaxMorph 
				ifTrue: [(tt nodeClassIs: BlockArgsNode) 
							ifTrue: [tt] ifFalse: [nil]]
				ifFalse: [nil].

	tempHolder ifNil: ["make new row"
		tempHolder := self addRow: #blockarg1 on: (BlockArgsNode new).
		tempHolder addNoiseString: self noiseBeforeBlockArg.
		tempHolder submorphs last firstSubmorph emphasis: TextEmphasis bold emphasisCode.
		tempHolder useRoundedCorners.

		self addMorphFront: tempHolder.
		aMorph parseNode name: nn key: nn code: nil.
		aMorph parseNode asMorphicSyntaxIn: tempHolder.
		tempHolder cleanupAfterItDroppedOnMe.
		^ true].

	"Know this variable is not present, so add it"

	aMorph parseNode name: nn key: nn code: nil.
	tempHolder addMorphBack: (tempHolder transparentSpacerOfSize: 4@4).
	var := tempHolder addRow: #tempVariable on: aMorph parseNode.
	var layoutInset: 1.
	var addMorphBack: (self aSimpleStringMorphWith: nn).
	var cleanupAfterItDroppedOnMe.
	^ true

]

{ #category : #layout }
SyntaxMorph >> addColumn: aColorOrSymbol on: aNode [
	| col |
	self addMorphBack: (col := self class column: aColorOrSymbol on: aNode).

"col setProperty: #howCreated toValue: thisContext longStack."

	self alansTest1 ifTrue: [
		(aColorOrSymbol == #block and: [self isMethodNode not]) ifTrue: [
			col setConditionalPartStyle.
		].
	].
	^ col

]

{ #category : #layout }
SyntaxMorph >> addNoiseString: aNoiseString [

	^self addNoiseString: aNoiseString emphasis: TextEmphasis normal emphasisCode.

]

{ #category : #layout }
SyntaxMorph >> addNoiseString: aNoiseString emphasis: anInteger [

	self alansTest1 ifFalse: [^self].
	^(self addColumn: #keyword1 on: nil)
		layoutInset: 1;
		addMorphBack: ((self noiseStringMorph: aNoiseString)  emphasis: anInteger)

]

{ #category : #layout }
SyntaxMorph >> addRow: aColorOrSymbol on: aNode [

	| row |
	self addMorphBack: (row := self class row: aColorOrSymbol on: aNode).

"row setProperty: #howCreated toValue: thisContext longStack."

	^row

]

{ #category : #layout }
SyntaxMorph >> addSingleKeywordRow: aStringLikeItem [

	| row sMorph modifiedString |

	(row := self class row: #text on: nil) borderWidth: 1.

	modifiedString := self substituteKeywordFor: aStringLikeItem.
	sMorph := self addString: modifiedString special: true.
	sMorph font: (self fontToUseForSpecialWord: modifiedString).
	modifiedString = aStringLikeItem ifFalse: [
		sMorph setProperty: #syntacticallyCorrectContents toValue: aStringLikeItem].

	row addMorph: sMorph.
	self addMorphBack: row.
	^row
]

{ #category : #layout }
SyntaxMorph >> addString: literalOrVarName special: aBoolean [

	| answer |
	"Create and return an UpdatingStringMorph containing the value.  Use an UpdatingStringMorph, so it can inform its owner when it has been edited. Keep the getSelector being nil"

	answer := (self anUpdatingStringMorphWith: literalOrVarName special: aBoolean)
		target: self;
		putSelector: #acceptIgnoring:;
		useStringFormat.

	^answer

]

{ #category : #layout }
SyntaxMorph >> addTempVar: aMorph [ 
	"know we are a block inside a MethodNode" 
	"(aMorph nodeClassIs: TempVariableNode) is known to be true."
	| tempHolder ii tt var nn |
	nn := aMorph decompile string.	"name"
	(self isKnownVarName: nn) ifTrue: [^ false].	"already defined"

	tempHolder := nil.
	(ii := owner submorphIndexOf: self) = 1 ifFalse: [
		tt := owner submorphs at: ii - 1.
		tt isSyntaxMorph ifTrue: [
			(tt nodeClassIs: MethodTempsNode) ifTrue: [tempHolder := tt].
			(tt nodeClassIs: UndefinedObject) ifTrue: [tempHolder := tt findA: MethodTempsNode]]].

	tempHolder ifNil: [
		tempHolder := owner addRow: #tempVariable on: MethodTempsNode new.
		tempHolder addNoiseString: self noiseBeforeBlockArg.
		tempHolder submorphs last firstSubmorph emphasis: TextEmphasis bold emphasisCode.
		tempHolder useRoundedCorners.

		owner addMorph: tempHolder inFrontOf: self.
		aMorph parseNode name: nn key: nn code: nil.
		aMorph parseNode asMorphicSyntaxIn: tempHolder.
		tempHolder cleanupAfterItDroppedOnMe.
		^ true].

	aMorph parseNode name: nn key: nn code: nil.
	tempHolder addMorphBack: (tempHolder transparentSpacerOfSize: 4@4).
	var := tempHolder addRow: #tempVariable on: aMorph parseNode.
	var layoutInset: 1.
	var addMorphBack: (self addString: nn special: false).
	var cleanupAfterItDroppedOnMe.
	^ true
]

{ #category : #'node to morph' }
SyntaxMorph >> addTemporaries: temporaries [ 
	| tempMorph outerMorph w2 |
	temporaries notEmpty ifFalse: [^self].
	self alansTest1 
		ifFalse: 
			[tempMorph := self addRow: #tempVariable on: MethodTempsNode new.
			temporaries do: [:temp | temp asMorphicSyntaxIn: tempMorph]
				separatedBy: 
					[tempMorph addMorphBack: (tempMorph transparentSpacerOfSize: 4 @ 4)].
			^self].
	outerMorph := self addRow: #tempVariable on: nil.
	outerMorph setSpecialTempDeclarationFormat1.
	outerMorph 
		addMorphBack: (w2 := self noiseStringMorph: self noiseBeforeBlockArg).
	w2 emphasis: TextEmphasis bold emphasisCode.
	tempMorph := outerMorph addRow: #tempVariable on: MethodTempsNode new.
	tempMorph setSpecialTempDeclarationFormat2.
	temporaries do: 
			[:temp | 
			tempMorph 
				addToken: temp name
				type: #tempVariableDeclaration
				on: temp]
		separatedBy: [tempMorph addMorphBack: self tokenVerticalSeparator]
]

{ #category : #'node to morph' }
SyntaxMorph >> addTemporaryControls [

	| row stdSize |
	
	stdSize := 8@8.
	row := AlignmentMorph newRow
		color: Color transparent;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap.
	self addMorphBack: row.

	{
		Morph new
			extent: stdSize; 
			color: Color paleBlue darker;
			setBalloonText: 'Change the contrast';
			on: #mouseUp send: #controlContrast2: to: self;
			on: #mouseMove send: #controlContrast2: to: self;
			on: #mouseDown send: #controlContrast2: to: self.

	"Removed because it's default is giant tiles, which no one wants. --tk
		Morph new
			extent: stdSize; 
			color: Color green;
			setBalloonText: 'Change basic spacing';
			on: #mouseUp send: #controlSpacing2: to: self;
			on: #mouseMove send: #controlSpacing2: to: self;
			on: #mouseDown send: #controlSpacing2: to: self.
	"

		Morph new
			extent: stdSize; 
			color: Color lightRed;
			setBalloonText: 'Change basic style';
			on: #mouseUp send: #changeBasicStyle to: self.

	} do: [ :each |
		row addMorphBack: each.
		row addMorphBack: (self transparentSpacerOfSize: stdSize).
	].

]

{ #category : #layout }
SyntaxMorph >> addTextRow: aStringLikeItem [

	| row tt |
	(row := self class row: #text on: nil) borderWidth: 1.
	(tt := TextMorph new) contents: aStringLikeItem.
	row addMorph: tt.
	"row addMorph: (self addString: (aStringLikeItem copyWithout: Character cr) special: false)."
	self addMorphBack: row.
	^row
]

{ #category : #layout }
SyntaxMorph >> addToBlock: aMorph event: evt [
	"Insert a new line of code.  Figure out who it goes before.  If evt Y is within an existing line (to the right of a tile), then replace that tile."

	| whereDropped dropBefore replace |
	whereDropped := "self pointFromWorld:" evt cursorPoint.
	dropBefore := self submorphs 
		detect: [:each | each isSyntaxMorph ifTrue: [
			whereDropped y < each top ifTrue: [true]	"before this one"
				ifFalse: [whereDropped y < each bottom 
							ifTrue: [replace := true]	"replace this one"
							ifFalse: [false]]]] "try next line"
		ifNone: [nil].
	(aMorph nodeClassIs: ReturnNode) ifTrue: [dropBefore := nil].
		"Returns are always at the end. (Watch out for comments)"

	dropBefore 
		ifNil: [self addMorphBack: aMorph]
		ifNotNil: [
			replace ifNotNil: [aMorph deselect.
				self replaceSubmorph: dropBefore by: aMorph.	"replace it!"
				^ dropBefore cleanupAfterItDroppedOnMe].	"now owned by no one"
			self addMorph: aMorph inFrontOf: dropBefore].
	self cleanupAfterItDroppedOnMe.

]

{ #category : #layout }
SyntaxMorph >> addToken: aString type: aColorOrSymbol on: aNode [

	| sMorph modifiedString noiseWord row |

	row := (self addRow: aColorOrSymbol on: aNode) layoutInset: 1.
	self alansTest1 ifFalse: [
		sMorph := self addString: aString special: false.
		row addMorphBack: sMorph.
		^row
	].

	noiseWord := [ :w |
		w ifNotNil: [
			row 
				addMorphBack: (self noiseStringMorph: w);
				addMorphBack: (self tokenVerticalSeparator)
		].
	].
	(self shouldBeBrokenIntoWords: aColorOrSymbol) ifTrue: [
		modifiedString := self substituteKeywordFor: aString.
		sMorph := self addString: modifiedString special: (aColorOrSymbol ~= #assignmentArrow).
			"(#(unary keywordGetz keywordSetter unaryGetter) includes: aColorOrSymbol)"
		modifiedString = aString ifFalse: [
			sMorph setProperty: #syntacticallyCorrectContents toValue: aString].
		sMorph setProperty: #syntacticReformatting toValue: aColorOrSymbol;
			contents: modifiedString.
	] ifFalse: [
		sMorph := self addString: (modifiedString := aString) special: false.
	].
	(#(keyword2 upArrow) includes: aColorOrSymbol) ifTrue: [
		sMorph 
			font: (self fontToUseForSpecialWord: modifiedString).
	].
	(#(keyword2 unary assignmentArrow methodHeader1 methodHeader2) includes: aColorOrSymbol) ifTrue: [
		sMorph emphasis: TextEmphasis bold emphasisCode.
	].
	aColorOrSymbol == #blockarg1 ifTrue: [
	].
	(aColorOrSymbol == #variable or: [aColorOrSymbol == #tempVariable]) ifTrue: [
		aString = 'self' ifTrue: [
			sMorph setProperty: #wordyVariantOfSelf toValue: true.
		].
		noiseWord value: (self noiseWordBeforeVariableNode: aNode string: aString).
	].

	row addMorphBack: sMorph.
	^row
]

{ #category : #layout }
SyntaxMorph >> addTokenSpecialCase: aString type: aColorOrSymbol on: aNode [

	| sMorph modifiedString noiseWord col |

	noiseWord := nil.
	sMorph := self addString: aString special: false.
	(aColorOrSymbol == #keyword2) ifTrue: [
		modifiedString := aString = 'if:' ifTrue: ['Test'] ifFalse: ['Yes'].
		sMorph 
			font: (self fontToUseForSpecialWord: modifiedString); 
			setProperty: #syntacticallyCorrectContents toValue: aString;
			contents: modifiedString.
	].

	col := (self addRow: aColorOrSymbol on: aNode) layoutInset: 1.
	noiseWord ifNotNil: [
		col 
			addMorphBack: (self noiseStringMorph: noiseWord);
			addMorphBack: (self transparentSpacerOfSize: 3@1)
	].
	col addMorphBack: sMorph.
	^col
]

{ #category : #layout }
SyntaxMorph >> addUnaryRow: aStringLikeItem style: aSymbol [

	| row sMorph modifiedString fontToUse |

	(row := self class row: #text on: nil) borderWidth: 1.
	modifiedString := self substituteKeywordFor: aStringLikeItem.
	sMorph := self addString: modifiedString special: true.
	fontToUse := self fontToUseForSpecialWord: modifiedString.

	sMorph 
		font: fontToUse emphasis: 1;
		setProperty: #syntacticReformatting toValue: #unary.
	modifiedString = aStringLikeItem ifFalse: [
		sMorph setProperty: #syntacticallyCorrectContents toValue: aStringLikeItem].
	row addMorph: sMorph.
	self addMorphBack: row.
	^row
]

{ #category : #'node to morph' }
SyntaxMorph >> alanBinaryPostRcvr: aNode key: key args: args [

	| nodeWithNilReceiver row |

"==
Repeat for collection [ collect ( from foo. blah blah foo blah) ]
Repeat for 1 to 50 [ do ( from i. blah blab i blah ) ]
=="

	nodeWithNilReceiver := aNode copy receiver: nil.
	(row := self addRow: #keyword2 on: nodeWithNilReceiver)
		borderWidth: 1;
		parseNode: (nodeWithNilReceiver as: MessageNode);
		borderColor: row stdBorderColor.
	row addToken: key asString
		type: #binary
		on: (SelectorNode new key: key asString code: nil "fill this in?").
	args first asMorphicSyntaxIn: row.

]

{ #category : #'node to morph' }
SyntaxMorph >> alanKeywordMessage: aNode isAConditional: template key: key args: args [

	| nodeWithNilReceiver column keywords row onlyOne |

	(key == #collect: and: [args first isKindOf: BlockNode]) ifTrue: [
		^self
			alanKwdCollect: aNode 
			isAConditional: template 
			key: key 
			args: args
	].
	key == #repeatFor:doing: ifTrue: [
		^self
			alanKwdRepeatForDoing: aNode 
			isAConditional: template 
			key: key 
			args: args
	].
	key == #if:do: ifTrue: [
		^self
			alanKwdIfDo: aNode 
			isAConditional: template 
			key: key 
			args: args
	].
	(args size = 1 and: [key endsWith: 'Getz:']) ifTrue: [
		^self
			alanKwdSetter: aNode 
			isAConditional: 0 
			key: key 
			args: args
	].
	(args size = 1 and: [self isStandardSetterKeyword: key]) ifTrue: [
		^self
			alanKwdSetter2: aNode 
			isAConditional: 0 
			key: key 
			args: args
	].
	nodeWithNilReceiver := aNode copy receiver: nil.
	template = 1 ifTrue: [
		self listDirection: #topToBottom.
	].
	column := self addColumn: #keyword1 on: nodeWithNilReceiver.
	keywords := key keywords.
	onlyOne := args size = 1.
	onlyOne ifFalse: ["necessary for three keyword messages!"
		column setProperty: #deselectedBorderColor toValue: column compoundBorderColor].
	keywords
		with: (args first: keywords size)
		do: [:kwd :arg |
			template = 1 ifTrue: [
				column addMorphBack: (column transparentSpacerOfSize: 3@3).
			].
			(row := column addRow: #keyword2 on: nodeWithNilReceiver)
				parseNode: (nodeWithNilReceiver as: 
						(onlyOne ifTrue: [MessageNode] ifFalse: [MessagePartNode]));
				borderColor: row stdBorderColor.
			template = 1 ifTrue: [row addMorphBack: (row transparentSpacerOfSize: 20@6)].
			row addToken: kwd
				type: #keyword2
				on: (onlyOne ifTrue: [SelectorNode new key: kwd code: nil "fill this in?"]
								ifFalse: [KeyWordNode new]).
			(arg asMorphicSyntaxIn: row) setConditionalPartStyle.
		].
	onlyOne ifTrue: [
		self replaceSubmorph: column by: row.
		column := row.
	].
			

]

{ #category : #'node to morph' }
SyntaxMorph >> alanKwdCollect: aNode isAConditional: template key: key args: args [

	| nodeWithNilReceiver row kwdHolder |

	nodeWithNilReceiver := aNode copy receiver: nil.
	(row := self addRow: #keyword2 on: nodeWithNilReceiver)
		borderWidth: 1;
		parseNode: (nodeWithNilReceiver as: MessageNode);
		borderColor: row stdBorderColor.
	kwdHolder := row
		addToken: key
		type: #keyword2
		on: (SelectorNode new key: key code: nil "fill this in?").
	kwdHolder firstSubmorph 
		setProperty: #syntacticallyCorrectContents toValue: key asString;
		contents: ''.

	args first asMorphicCollectSyntaxIn: row.

]

{ #category : #'node to morph' }
SyntaxMorph >> alanKwdIfDo: aNode isAConditional: template key: key args: args [
	"(know it has more than one arg)"
	| nodeWithNilReceiver column keywords |

	nodeWithNilReceiver := aNode copy receiver: nil.
	column := self addColumn: #keyword1 on: nodeWithNilReceiver.
	"column borderColor: column compoundBorderColor."
	keywords := key keywords.
	keywords
		with: (args first: keywords size)
		do: [:kwd :arg | | row |
			(row := column addRow: #keyword2 on: nodeWithNilReceiver)
				parseNode: (nodeWithNilReceiver as: MessagePartNode).
			kwd = 'do:' ifTrue: [
				row addMorphBack: (row transparentSpacerOfSize: 26@6).
			] ifFalse: [
				row addMorphBack: (row transparentSpacerOfSize: 10@6).
			].
			row addTokenSpecialCase: kwd
				type: #keyword2
				on: KeyWordNode new.
			(arg asMorphicSyntaxIn: row) setConditionalPartStyle.
		].
			

]

{ #category : #'node to morph' }
SyntaxMorph >> alanKwdRepeatForDoing: aNode isAConditional: template key: key args: args [

	| nodeWithNilReceiver column keywords |

	nodeWithNilReceiver := aNode copy receiver: nil.
	column := self addColumn: #keyword1 on: nodeWithNilReceiver.
	keywords := key keywords.
	keywords
		with: (args first: keywords size)
		do: [:kwd :arg | | row |
			(row := column addRow: #keyword2 on: nodeWithNilReceiver)
				parseNode: (nodeWithNilReceiver as: MessagePartNode).
			row addToken: kwd
				type: #keyword2
				on: KeyWordNode new.
			(arg asMorphicSyntaxIn: row) setConditionalPartStyle.
		].

]

{ #category : #'node to morph' }
SyntaxMorph >> alanKwdSetter2: aNode isAConditional: template key: key args: args [
	"translates
		foo setHeading: 0
	to
		foo's heading := 0
	"
	| kwdHolder wordy |
	kwdHolder := self
		addToken: key
		type: #keywordSetter
		on: (SelectorNode new key: key code: nil "fill this in?").
	wordy := self translateToWordySetter: key.
	kwdHolder firstSubmorph 
		setProperty: #syntacticReformatting toValue: #keywordSetter;
		contents: wordy;
		emphasis: TextEmphasis bold emphasisCode.
	wordy = key asString ifFalse: [
		kwdHolder firstSubmorph 
			setProperty: #syntacticallyCorrectContents toValue: key asString].

	(args first asMorphicSyntaxIn: self) setConditionalPartStyle
			

]

{ #category : #'node to morph' }
SyntaxMorph >> alanKwdSetter: aNode isAConditional: template key: key args: args [

	| nodeWithNilReceiver row kwdHolder |

	nodeWithNilReceiver := aNode copy receiver: nil.
	(row := self addRow: #keyword2 on: nodeWithNilReceiver)
		borderWidth: 1;
		parseNode: (nodeWithNilReceiver as: MessageNode);
		borderColor: row stdBorderColor.
	row addNoiseString: '''s' emphasis: TextEmphasis bold emphasisCode.
	kwdHolder := row
		addToken: key
		type: #keywordGetz
		on: (SelectorNode new key: key code: nil "fill this in?").
	kwdHolder firstSubmorph 
		setProperty: #syntacticReformatting toValue: #keywordGetz;
		setProperty: #syntacticallyCorrectContents toValue: key asString;
		contents: (self splitAtCapsAndDownshifted: (key asString allButLast: 5));
		emphasis: TextEmphasis bold emphasisCode.
	row addNoiseString: '_' emphasis: TextEmphasis bold emphasisCode.

	(args first asMorphicSyntaxIn: row) setConditionalPartStyle
			

]

{ #category : #'node to morph' }
SyntaxMorph >> alanUnaryGetter: aNode key: key [
	"I am a MessageNode.  Fill me with a SelectorNode {getX} whose string is {'s x}.  All on one level."

	| selSyn usm wordy |
	selSyn := self
		addToken: key
		type: #unaryGetter
		on: (SelectorNode new key: key code: nil "fill this in?").
	usm := selSyn firstSubmorph.
	usm setProperty: #syntacticReformatting toValue: #unaryGetter.
	wordy := self translateToWordyGetter: key.
	wordy = key asString ifFalse: [
		usm setProperty: #syntacticallyCorrectContents toValue: key asString].
	usm contents: wordy; emphasis: TextEmphasis bold emphasisCode.

]

{ #category : #'node to morph' }
SyntaxMorph >> alanUnaryPostRcvr: aNode key: key selector: selector [

	| row |

	(self isStandardGetterSelector: key) ifTrue: [
		^self alanUnaryGetter: aNode key: key
	].
	row := (self addUnaryRow: key style: #unary) layoutInset: 1.
	^ row parseNode: selector

]

{ #category : #'alans styles' }
SyntaxMorph >> alansCurrentFontPreference [

	^nil		"StrikeFont familyName: 'ComicBold' size: 16"
]

{ #category : #'node to morph' }
SyntaxMorph >> alansMessageNode: aNode receiver: receiver selector: selector keywords: key arguments: args [ 
	| receiverMorph testAndReceiver anotherSelf wordyMorph template |
	template := self alansTemplateStyleFor: key.
	receiver ifNotNil: 
			["i.e. not a cascade"

			anotherSelf := self constructSelfVariant: receiver and: key.
			anotherSelf ifNotNil: 
					[wordyMorph := self addString: anotherSelf special: false.
					wordyMorph setProperty: #wordyVariantOfSelf toValue: true.
					self addMorph: wordyMorph.
					self layoutInset: 1.
					^self].
			testAndReceiver := self.
			template = 1 
				ifTrue: 
					[testAndReceiver := self addRow: #keyword1 on: nil.
					self setSpecialOuterTestFormat.
					testAndReceiver addNoiseString: 'Test'].
			false 
				ifTrue: 
					["template = 2"

					testAndReceiver := self addRow: #keyword1 on: nil.
					"self setSpecialOuterTestFormat."
					testAndReceiver addNoiseString: 'Repeat for'].
			receiverMorph := receiver asMorphicSyntaxIn: testAndReceiver.
			template = 1 ifTrue: [receiverMorph setConditionalPartStyle]].

	"unary messages"
	args isEmpty 
		ifTrue: 
			[^self 
				alanUnaryPostRcvr: aNode
				key: key
				selector: selector].

	"binary messages"
	key last = $: 
		ifFalse: 
			[^self 
				alanBinaryPostRcvr: aNode
				key: key
				args: args].

	"keyword messages"
	receiverMorph ifNotNil: [receiverMorph setConditionalPartStyle].
	self setSpecialOuterTestFormat.
	self 
		alanKeywordMessage: aNode
		isAConditional: template
		key: key
		args: args
]

{ #category : #'alans styles' }
SyntaxMorph >> alansTemplateStyleFor: key [

	(#(ifTrue: ifFalse: ifTrue:ifFalse: ifFalse:ifTrue:) includes: key) ifTrue: [^1].
	(#(do: collect:) includes: key) ifTrue: [^2].
	(#(if:do:) includes: key) ifTrue: [^3].
	^0

]

{ #category : #'formatting options' }
SyntaxMorph >> alansTest1 [
	
	| root |

	root := self rootTile ifNil: [self].
	^root valueOfProperty: #alansNewStyle ifAbsent: [self usingClassicTiles not]
]

{ #category : #'alans styles' }
SyntaxMorph >> anUpdatingStringMorphWith: aString special: aBoolean [

	self alansTest1 ifTrue: [
		^(aBoolean ifTrue: [SyntaxUpdatingStringMorph] ifFalse: [UpdatingStringMorph])
			 contents: aString
			font: self alansCurrentFontPreference
	].
	^UpdatingStringMorph contents: aString
]

{ #category : #'type checking' }
SyntaxMorph >> argTypeFor: aSelector [
	"Answer the type of the argument of this selector.  Return #unknown if not found."

	| itsInterface |
	aSelector numArgs = 0 
		ifTrue: [self inform: aSelector, ' does not take an argument'. ^ #error "7"].
	itsInterface := self currentVocabulary methodInterfaceAt: aSelector ifAbsent:
		[^ #unknown].
	^ itsInterface typeForArgumentNumber: 1
]

{ #category : #accessing }
SyntaxMorph >> argumentNodes [
	"Return a collection of this message's argument nodes.  "

	| cls coll rec |
	parseNode ifNil: [^ #()].
	cls := parseNode class.
	cls == SelectorNode ifTrue: [^ #()].
	cls == KeyWordNode ifTrue: [^ #()].

	coll := OrderedCollection new.
	rec := self receiverNode.
	submorphs do: [:sub | 
		(sub isSyntaxMorph and: [sub ~~ rec]) ifTrue: [
			sub isNoun ifTrue: [coll addLast: sub]	"complete arg"
				ifFalse: [coll := coll, sub argumentNodes]]].	"MessagePartNode, MessageNode with no receiver"
	^ coll
]

{ #category : #'pop ups' }
SyntaxMorph >> assignmentArrow [
	"Offer to embed this variable in a new assignment statement.  (Don't confuse this with upDownAssignment:, which runs the up and down arrows that rotate among assignment types.)"
	| rr |

	self isAVariable ifFalse: [^ nil].
	self isDeclaration ifTrue: [^ nil].
	^ (rr := RectangleMorph new)
		extent: 11@13; borderWidth: 1; color: Color lightGreen;
		borderColor: Color gray;
		addMorph: ((self noiseStringMorph: '_') topLeft: rr topLeft + (3@0));
		on: #mouseUp send: #newAssignment to: self

]

{ #category : #'node to morph' }
SyntaxMorph >> assignmentNode: aNode variable: variable value: value [

	| row v expMorph |

	row := self addRow: #assignment on: aNode.
	v := variable asMorphicSyntaxIn: row.
	self alansTest1 ifTrue: [v setConditionalPartStyle; layoutInset: 2].
	row addToken: ' := ' type: #assignmentArrow on: aNode.
	expMorph := value asMorphicSyntaxIn: row.
	self alansTest1 ifTrue: [
		row setSpecialOuterTestFormat.
		(expMorph hasProperty: #deselectedColor) ifFalse: [expMorph setConditionalPartStyle].
	].
	^row

]

{ #category : #'new tiles' }
SyntaxMorph >> attachTileForCode: expression nodeType: nodeClass [
	| nn master tile |
	"create a new tile for a part of speech, and put it into the hand"

	"a few special cases"
	expression = 'self' ifTrue: [
		^ (((self string: expression toTilesIn: Object) 
				findA: ReturnNode) findA: nodeClass) attachToHand].

	expression = '<me by name>' ifTrue: ["Tile for the variable in References"
		nn := nodeClass knownName ifNil: [#+].
		(self world referencePool at: nn asSymbol ifAbsent: [nil]) == nodeClass ifTrue: [
			^ self attachTileForCode: nn nodeType: LiteralVariableNode].
		"otherwise just give a tile for self"
		^ self attachTileForCode: 'self' nodeType: VariableNode].

	expression = '<assignment>' ifTrue: ["do something really special"
		master := self class new.
		master addNoiseString: '  :=  ' emphasis: 1.
		tile := master firstSubmorph.
		^ (tile parseNode: AssignmentNode new) attachToHand].	"special marker"
		"When this is dropped on a variable, enclose it in 
			a new assignment statement"

	"general case -- a tile for a whole line of code is returned"
	^ ((self string: expression toTilesIn: Object) 
				findA: nodeClass) attachToHand.
]

{ #category : #'new tiles' }
SyntaxMorph >> attachToHand [
	"Adjust my look and attach me to the hand"

	self roundedCorners.
	self currentHand attachMorph: self.
	Preferences tileTranslucentDrag
		ifTrue: [self lookTranslucent.
			self align: self center with: self currentHand position "+ self cursorBaseOffset"]
		ifFalse: [
			self align: self topLeft with: self currentHand position + self cursorBaseOffset].
]

{ #category : #accessing }
SyntaxMorph >> balloonText [

	^(('Value: ',(self getCurrentValue ifNil: [^nil])) 
		withNoLineLongerThan: 35) truncateWithElipsisTo: 300
]

{ #category : #'node to morph' }
SyntaxMorph >> blockNode: aNode arguments: arguments statements: statements [ 
	| row column |
	column := self addColumn: #block on: aNode.
	self alansTest1 ifFalse: [column layoutInset: 5 @ -1].
	self alansTest1 
		ifTrue: 
			[column setProperty: #deselectedBorderColor toValue: self lighterColor].
	aNode addCommentToMorph: column.
	arguments notEmpty 
		ifTrue: 
			[row := column addRow: #blockarg1 on: BlockArgsNode new.
			row addNoiseString: self noiseBeforeBlockArg.
			arguments do: 
					[:arg | 
					row 
						addToken: arg name
						type: #blockarg2
						on: arg]].
	statements do: 
			[:each | 
			(row := each asMorphicSyntaxIn: column) borderWidth: 1.
			self alansTest1 ifTrue: [row setSpecialOuterTestFormat].
			each addCommentToMorph: column].
	^column
]

{ #category : #'node to morph' }
SyntaxMorph >> blockNodeCollect: aNode arguments: arguments statements: statements [ 
	| row column c2 r2 r3 |
	column := self addColumn: #blockCollectOnly on: aNode.
	self alansTest1 ifFalse: [column layoutInset: 5 @ -1].
	aNode addCommentToMorph: column.
	arguments notEmpty 
		ifTrue: 
			[row := column addRow: #blockarg1 on: BlockArgsNode new.
			row addNoiseString: 'collect using' emphasis: TextEmphasis bold emphasisCode.
			r3 := row addRow: #blockarg1b on: nil.	"aNode"
			r3 setConditionalPartStyle.
			arguments do: 
					[:arg | 
					r3 
						addToken: arg name
						type: #blockarg2
						on: arg]].
	r2 := column addRow: #block on: aNode.
	r2 setProperty: #ignoreNodeWhenPrinting toValue: true.
	r2 addNoiseString: self noiseBeforeBlockArg emphasis: TextEmphasis bold emphasisCode.
	c2 := r2 addColumn: #block on: aNode.
	c2 setProperty: #ignoreNodeWhenPrinting toValue: true.
	statements do: 
			[:each | 
			(each asMorphicSyntaxIn: c2) borderWidth: 1.
			each addCommentToMorph: c2].
	^column
]

{ #category : #accessing }
SyntaxMorph >> borderColor: colorOrSymbolOrNil [

	self borderColor = colorOrSymbolOrNil ifFalse: [
		super borderColor: colorOrSymbolOrNil.
		self bounds area < 40000
			ifTrue: [self invalidRect: self bounds]
			ifFalse: [(self bounds areasOutside: (self bounds insetBy: self borderWidth))
						do: [:r | self invalidRect: r]]].

]

{ #category : #'node to morph' }
SyntaxMorph >> cascadeNode: aNode receiver: receiver messages: messages [
	| row |

	self alansTest1 ifTrue: [
		row := self addColumn: #cascade on: aNode.
		row setSpecialOuterTestFormat.
	] ifFalse: [
		row := self addRow: #cascade on: aNode
	].
	receiver asMorphicSyntaxIn: row.
	messages do: [:m | m asMorphicSyntaxIn: row].
	^ row

"	(node2 := aNode copy) receiver: nil messages: messages.
	cascadeMorph := row addColumn: #cascade2 on: node2.
	messages do: [ :m | m asMorphicSyntaxIn: cascadeMorph].
	^row
"

]

{ #category : #'node to morph' }
SyntaxMorph >> changeBasicStyle [

	self removeAllMorphs.
	self setProperty: #alansNewStyle toValue: self alansTest1 not.
	self methodNodeOuter: parseNode

]

{ #category : #'pop ups' }
SyntaxMorph >> changeSound: upDown [
	| ind arg st soundChoices index it current |
	"move in the list of sounds.  Adjust arg tile after me"

	ind := owner submorphs indexOf: self.
	arg := owner submorphs atWrap: ind+1.
	arg isSyntaxMorph ifFalse: [^ self].
	st := arg submorphs detect: [:mm | mm isKindOf: StringMorph] ifNone: [^ self].
	soundChoices := SoundService default sampledSoundChoices.
	current := st contents copyFrom: 2 to: st contents size-1.	"remove string quotes"
	index := soundChoices indexOf: current.
	index > 0 ifTrue:
		[st contents: (it := soundChoices atWrap: index + upDown) printString.
		self playSoundNamed: it].

]

{ #category : #accessing }
SyntaxMorph >> cleanUpString: stringSubMorph [

	
	^ stringSubMorph 
		valueOfProperty: #syntacticallyCorrectContents 
		ifAbsent: [ | style rawData |
			style := stringSubMorph valueOfProperty: #syntacticReformatting.
			rawData := stringSubMorph contents.
			 (#(unary tempVariableDeclaration blockarg2 methodHeader1 tempVariable variable) includes: style) ifTrue: [
				rawData := self unSpaceAndUpShift: rawData appending: nil.
			].
			style == #keywordGetz ifTrue: [
				rawData := self unSpaceAndUpShift: rawData appending: 'Getz:'.
			].
			style == #keywordSetter ifTrue: [
				rawData := self unSpaceAndUpShift: 'set ',rawData appending: ':'.
			].
			style == #unaryGetter ifTrue: [
				rawData := self unSpaceAndUpShift: 'get ',rawData appending: nil.
			].
			(#(keyword2 methodHeader2) includes: style)  ifTrue: [
				rawData := self unSpaceAndUpShift: rawData appending: ':'.
			].
			rawData
		]

]

{ #category : #'dropping\/grabbing' }
SyntaxMorph >> cleanupAfterItDroppedOnMe [
	"A tile just dropped into me.  Clean up"

	self layoutChanged.  "** Isn't this already implied by the addMorph: ?"
	"Auto-accept on drop if in a scriptor"
	self acceptIfInScriptor.
]

{ #category : #accessing }
SyntaxMorph >> color: aColorOrSymbol [

	| deselectedColor cc |
	aColorOrSymbol isColor ifTrue: [
		self valueOfProperty: #deselectedColor ifAbsent: ["record my color the first time"
			self setProperty: #deselectedColor toValue: aColorOrSymbol.
			^ super color: (self scaleColorByUserPref: aColorOrSymbol)].
		^ super color: aColorOrSymbol].

	deselectedColor := self valueOfProperty: #deselectedColor ifAbsent: [nil].
	deselectedColor ifNotNil: [^ super color: (self scaleColorByUserPref: deselectedColor)].

	aColorOrSymbol == #comment  ifTrue: [^ self color: Color blue lighter].
	SyntaxMorph noTileColor ifTrue: [	"override"
		^ self color: Color transparent].	"Fix this to be real color!"

	(cc := self class translateColor: aColorOrSymbol) isColor
		ifTrue: [^ self color: cc]
		ifFalse: [Transcript show: aColorOrSymbol, ' needs to be handled in translateColor:'; cr.
			^ self color: Color transparent].	"help!"
]

{ #category : #'change reporting' }
SyntaxMorph >> colorChangedForSubmorph: colorPatch [
	| sel newSel cc ms phrase completeMsg |
	"reporting a color change"

	(self nodeClassIs: MessageNode) ifFalse: [^ nil].
	(sel := self selector) ifNil: [^ nil].
	(Color colorNames includes: sel) | (sel == #r:g:b:) ifFalse: [^ nil].
		"a standard color name"
	"replace self with new tiles from the color"
	(newSel := (cc := colorPatch color) name) 
		ifNil: [ms := MessageSend receiver: Color selector: #r:g:b: arguments: 
				(Array with: cc red with: cc green with: cc blue).
			phrase := ms asTilesIn: Color globalNames: true]
		ifNotNil: [ms := MessageSend receiver: Color selector: newSel arguments: #().
			phrase := ms asTilesIn: Color globalNames: true].
	self deletePopup.
	completeMsg := self isNoun ifTrue: [self] ifFalse: [owner].
	completeMsg owner replaceSubmorph: completeMsg by: phrase.
	"rec setSelection: {rec. nil. rec}."
	phrase acceptIfInScriptor.
]

{ #category : #'pop ups' }
SyntaxMorph >> colorPatch [
	"Return a color patch button that lets the user choose a color and modifies the code"
	| cc patch sel completeMsg |
	
	
	((self nodeClassIs: MessageNode) "or: [self nodeClassIs: SelectorNode]") ifFalse: [^ nil].
	(sel := self selector) ifNil: [^ nil].
	(Color colorNames includes: sel) | (sel == #r:g:b:) ifFalse: [^ nil].
		"a standard color name"
	completeMsg := self isNoun ifTrue: [self] 
				ifFalse: [owner isNoun ifTrue: [owner] ifFalse: [owner owner]].

	(cc := completeMsg try) class == Color ifFalse: [^ nil].
	patch := ColorTileMorph new colorSwatchColor: cc.
		"sends colorChangedForSubmorph: to the messageNode"
	patch color: Color transparent; borderWidth: 0.  patch submorphs last delete.
	^ patch
]

{ #category : #highlighting }
SyntaxMorph >> compoundBorderColor [ 

	^ self valueOfProperty: #deselectedBorderColor ifAbsent: [Color veryLightGray]

]

{ #category : #'alans styles' }
SyntaxMorph >> constructSelfVariant: receiver and: key [

	| wordy |
	(receiver isKindOf: VariableNode) ifFalse: [^nil].
	receiver name = 'self'  ifFalse: [^nil].
	(wordy := self translateFromWordySelfVariant: key) ifNil: [^nil].
	^wordy


]

{ #category : #'formatting options' }
SyntaxMorph >> controlContrast2: evt [

	| origin scale startingContrastX |

	evt isMouseUp ifTrue: [
		^self removeProperty: #startingPointForSomeAdjustment
	].
	evt isMouseDown ifTrue: [
		^self setProperty: #startingPointForSomeAdjustment toValue: evt cursorPoint
	].
	ContrastFactor ifNil: [ContrastFactor := 0.5].
	scale := 200.0.
	startingContrastX := ContrastFactor * scale.
	origin := self valueOfProperty: #startingPointForSomeAdjustment.
	ContrastFactor := (evt cursorPoint x - origin x + startingContrastX) / scale min: 1.0 max: 0.0.
	self finalAppearanceTweaks.

]

{ #category : #'formatting options' }
SyntaxMorph >> controlContrast: evt [

	"old version. may be some scripts saved with me, so don't crash"
	^self
]

{ #category : #'formatting options' }
SyntaxMorph >> controlSpacing2: evt [

	| origin scale startingContrastX |

	evt isMouseUp ifTrue: [
		^self removeProperty: #startingPointForSomeAdjustment
	].
	evt isMouseDown ifTrue: [
		^self setProperty: #startingPointForSomeAdjustment toValue: evt cursorPoint
	].
	SizeScaleFactor ifNil: [SizeScaleFactor := 0.15].
	scale := 200.0.
	startingContrastX := SizeScaleFactor * scale.
	origin := self valueOfProperty: #startingPointForSomeAdjustment.
	SizeScaleFactor := (evt cursorPoint x - origin x + startingContrastX) / scale min: 1.0 max: 0.0.
	self finalAppearanceTweaks.

]

{ #category : #'formatting options' }
SyntaxMorph >> controlSpacing: evt [

	"old version. may be some scripts saved with me, so don't crash"
	^self
]

{ #category : #'card in a stack' }
SyntaxMorph >> couldHoldSeparateDataForEachInstance [
	"Answer whether this type of morph is inherently capable of holding separate data for each instance ('card data')"

	^ true
]

{ #category : #player }
SyntaxMorph >> currentDataValue [
	"Answer the current data value held by the receiver"

	^ self readOut valueFromContents
]

{ #category : #selection }
SyntaxMorph >> currentSelectionDo: blockForSelection [
	| rootTile |
	(rootTile := self rootTile) isMethodNode ifFalse:
		 [^ blockForSelection value: nil value: nil value: nil].
	rootTile valueOfProperty: #selectionSpec ifPresentDo:
		[:selectionSpec | ^ blockForSelection
							value: selectionSpec first
							value: selectionSpec second
							value: selectionSpec third].
	^ blockForSelection value: nil value: nil value: nil
]

{ #category : #macpal }
SyntaxMorph >> currentVocabulary [
	"Answer the current vocabulary associated with the receiver.  If none is yet set, determine an appropriate vocabulary and cache it within my properties dictionary."

	| aVocab aSym |
	aSym := self valueOfProperty: #currentVocabularySymbol ifAbsent: [nil].
	aSym ifNil:
		[aVocab := self valueOfProperty: #currentVocabulary ifAbsent: [nil].
		aVocab ifNotNil:
			[aSym := aVocab vocabularyName.
			self removeProperty: #currentVocabulary.
			self setProperty: #currentVocabularySymbol toValue: aSym]].

	aSym ifNotNil:
		[^ Vocabulary vocabularyNamed: aSym].
	aVocab := super currentVocabulary.
	self setProperty: #currentVocabularySymbol toValue: aVocab vocabularyName.
	^ aVocab
]

{ #category : #'event handling' }
SyntaxMorph >> cursorBaseOffset [

	^ 7@14

]

{ #category : #'alans styles' }
SyntaxMorph >> darkerColor [

	^(Color r: 1.0 g: 0.839 b: 0.613)	"Color lightBrown lighter lighter."

]

{ #category : #debugging }
SyntaxMorph >> debugger [

	^ self rootTile valueOfProperty: #debugger
]

{ #category : #debugging }
SyntaxMorph >> debugger: x [

	self rootTile setProperty: #debugger toValue: x
]

{ #category : #menus }
SyntaxMorph >> decompile [
	| stream |
	"Produce Smalltalk code.  We have a tree of SyntaxMorphs, but not a tree of ParseNodes.  The user has dragged in many SyntaxMorphs, each with its own parseNode, but those nodes are not sewn together in a tree.  The only data we get from a ParseNode is its class.
	We produce really ugly code.  But we compile it and decompile (prettyPrint) again for user to see."

	stream := ColoredCodeStream on: (Text new: 400).
	self printOn: stream indent: 1.	"Tree walk and produce text of the code"
	^ stream contents
]

{ #category : #'pop ups' }
SyntaxMorph >> deleteLine [
	| temp |
	temp := owner.
	self deletePopup.
	self delete.
	temp setSelection: nil.
	temp acceptIfInScriptor.
]

{ #category : #'pop ups' }
SyntaxMorph >> deletePopup [

	self valueOfProperty: #myPopup ifPresentDo:
		[:panel | panel delete. self removeProperty: #myPopup]
]

{ #category : #selection }
SyntaxMorph >> deselect [
	self allMorphsDo:
		[:m | m isSyntaxMorph ifTrue: [m setDeselectedColor]].

	"Note following is wasteful because we do a deselect before each select, and it is often the same morph."
	self deletePopup
]

{ #category : #'pop ups' }
SyntaxMorph >> dismisser [
	"Return the icon to delete this line of tiles.  I am an entire line in a block."
	| handle handleSpec colorToUse iconName form |

	(owner isSyntaxMorph and: [owner nodeClassIs: BlockNode]) ifFalse: [^ nil].
	handleSpec := Preferences haloSpecifications fourth.	"dismiss"
	handle := EllipseMorph
			newBounds: (Rectangle center: 10@10 extent: 16 asPoint)
			color: (colorToUse := Color colorFrom: handleSpec color).
	iconName := handleSpec iconSymbol.
	form := ScriptingSystem formAtKey: iconName.	"#'Halo-Dismiss'"
	handle addMorphCentered: (ImageMorph new
				image: form; 
				color: colorToUse makeForegroundColor;
				lock).
	handle on: #mouseDown send: #deleteLine to: self.
	^ handle
]

{ #category : #accessing }
SyntaxMorph >> dissectMessage [
	"I am a MessageNode.  Return {receiverNode or nil, selector, (keyword nodes), (argument nodes)}.  Ignore all spacing morphs."

	
]

{ #category : #drawing }
SyntaxMorph >> drawOn: aCanvas [

	super drawOn: aCanvas.
	self isBlockNode ifFalse: [^self].
	self alansTest1 ifTrue: [^self].

	self immediatelyBelowTheMethodNode ifTrue: [
		aCanvas fillRectangle: (self topLeft + (0 @ -1) extent: self width @ 1) color: Color gray
	] ifFalse: [
		aCanvas fillRectangle: (self topLeft + (1 @ 1) extent: 2 @ (self height-2)) color: Color gray.
		aCanvas fillRectangle: (self topLeft + (1 @ 1) extent: 4 @ 1) color: Color gray.
		aCanvas fillRectangle: (self bottomLeft + (1 @ -1) extent: 4 @ 1) color: Color gray
	].

]

{ #category : #highlighting }
SyntaxMorph >> dropColor [
	^ Color green darker
]

{ #category : #'pop ups' }
SyntaxMorph >> dupTile: evt [

	| dup |
	self deletePopup.
	"self deselect."
	dup := self duplicateMorph: evt.
	Preferences tileTranslucentDrag
		ifTrue: [dup align: dup center with: evt hand position.
				dup lookTranslucent]
		ifFalse: [dup align: dup topLeft
					with: evt hand position + self cursorBaseOffset].

]

{ #category : #'pop ups' }
SyntaxMorph >> duplicator [
	"Return the icon to duplicate this tile."
	| handle handleSpec colorToUse iconName form |

	handleSpec := Preferences haloSpecifications at: 11.	"duplicate"
	handle := EllipseMorph
			newBounds: (Rectangle center: 10@10 extent: 16 asPoint)
			color: (colorToUse := Color colorFrom: handleSpec color).
	iconName := handleSpec iconSymbol.
	form := ScriptingSystem formAtKey: iconName.	"#'Halo-Dup'"
	handle addMorphCentered: (ImageMorph new
				image: form; 
				color: colorToUse makeForegroundColor;
				lock).
	handle on: #mouseDown send: #dupTile: to: self.
	^ handle
]

{ #category : #accessing }
SyntaxMorph >> editor [
	"In parallel with the interface for text morphs, we respond to this, but in our case we are our own editor"

	^ self
]

{ #category : #accessing }
SyntaxMorph >> enclosingPane [
	"The object that owns this script layout"

	| oo higher |
	oo := self owner.
	[higher := oo isSyntaxMorph.
	higher := higher or: [oo class == TransformMorph].
	higher := higher or: [oo class == ScrollPane].
	higher ifFalse: [^ oo].
	higher] whileTrue: [oo := oo owner].

]

{ #category : #'pop ups' }
SyntaxMorph >> event: arg1 arrow: arg2 upDown: arg3 [
	"Reorder the arguments for existing event handlers"
	(arg3 isMorph and:[arg3 eventHandler notNil]) ifTrue:[arg3 eventHandler fixReversedValueMessages].
	^self upDown: arg1 event: arg2 arrow: arg3
]

{ #category : #'pop ups' }
SyntaxMorph >> extend [
	| messageNodeMorph first |
	"replace this noun with a new message like (arg + 1).  If type is not known, ask the user to type in a selector.  Use nil as arg.  Let user drag something to it afterwards."

	"Later do evaluation of self to see what type and offer right selector"
	self deselect.
	messageNodeMorph := (MessageSend receiver: 1 selector: #+ arguments: #(1))
								asTilesIn: Player globalNames: false.
	owner replaceSubmorph: self by: messageNodeMorph.
	first := messageNodeMorph submorphs detect: [:mm | mm isSyntaxMorph].
	messageNodeMorph replaceSubmorph: first by: self.
	self acceptIfInScriptor.
]

{ #category : #'pop ups' }
SyntaxMorph >> extendArrow [
	"Return the extend arrow button.  It replaces the argument with a new message.
	I am a number or getter messageNode."
	| patch |
	
	self isNoun ifFalse: [^ nil].
	self isDeclaration ifTrue: [^ nil].
	patch := (ImageMorph new image: (TileMorph classPool at: #SuffixPicture)).
	patch on: #mouseDown send: #extend to: self.
	^ patch
]

{ #category : #viewer }
SyntaxMorph >> externalName [

	^ self knownName ifNil: [
		parseNode ifNil: ['Syntax -- (extra layer)']
				ifNotNil: [self parseNode class printString]]
]

{ #category : #'visual properties' }
SyntaxMorph >> fillStyle: aFillStyle [

	aFillStyle isColor 
		ifTrue: [self color: aFillStyle]	"so we will process it"
		ifFalse: [super fillStyle: aFillStyle].

]

{ #category : #'node to morph' }
SyntaxMorph >> finalAppearanceTweaks [
	| deletes |
	SizeScaleFactor ifNil: [SizeScaleFactor := 0.15].
	SizeScaleFactor := 0.0.	"disable this feature.  Default was for giant tiles"
	self usingClassicTiles 
		ifTrue: 
			[self 
				allMorphsDo: [:each | (each isSyntaxMorph) ifTrue: [each lookClassic]].
			^self].
	deletes := OrderedCollection new.
	self allMorphsDo: 
			[:each | | lw | 
			(each respondsTo: #setDeselectedColor) ifTrue: [each setDeselectedColor].
			"(each hasProperty: #variableInsetSize) ifTrue: [
			each layoutInset: 
				((each valueOfProperty: #variableInsetSize) * SizeScaleFactor) rounded]."
			each isSyntaxMorph 
				ifTrue: 
					[lw := each layoutInset.
					lw isPoint ifTrue: [lw := lw x].
					each layoutInset: lw @ 0	"(6 * SizeScaleFactor) rounded"]].
	deletes do: [:each | each delete]
]

{ #category : #'submorphs-accessing' }
SyntaxMorph >> findA: aClass [
	| ans |
	"Allow finding on the class of the parseNode"

	(ans := super findA: aClass) ifNotNil: [^ ans].
	submorphs do: [:ss | 
		ss isSyntaxMorph ifTrue: [
			ss parseNode class == aClass ifTrue: [^ ss]]].
	^ nil
]

{ #category : #layout }
SyntaxMorph >> foldMessage [
	"I am a message whose receiver is wide, and whose message part is a column.
	Rearrange me so that the message part appears indented under the receiver part."
	| messageRow node2 |
	node2 := parseNode copy receiver: nil.
	messageRow := SyntaxMorph row: #keyword1 on: node2.

	messageRow 
		addMorph: (self transparentSpacerOfSize: 20@10);
		addMorphBack: submorphs last.		"<<handle noise words better"
	self listDirection: #topToBottom;
		wrapCentering: #topLeft;
		addMorphBack: (self transparentSpacerOfSize: 4@4);
		addMorphBack: messageRow.

]

{ #category : #layout }
SyntaxMorph >> foldMessageOneArg [
	"I am a message that is wide, a row with receiver and a row with selector and arg.
	Rearrange me so that the message part appears indented under the receiver part."
	| messageRow node2 |
	node2 := parseNode copy receiver: nil.
	messageRow := SyntaxMorph row: #keyword1 on: node2.
	messageRow addMorph: (self transparentSpacerOfSize: 20@10);
			addMorphBack: submorphs second;
			addMorphBack: submorphs second.  "was the third"
	self listDirection: #topToBottom;
		wrapCentering: #topLeft;
		addMorphBack: messageRow.

]

{ #category : #'alans styles' }
SyntaxMorph >> fontToUseForSpecialWord: aString [

	^(#('Yes' 'No' 'Test') includes: aString) ifTrue: [
		(StrikeFont familyName: 'Helvetica' size: 14)
	] ifFalse: [
		nil	"(StrikeFont familyName: 'ComicBold' size: 16)"
	]
]

{ #category : #accessing }
SyntaxMorph >> getCurrentValue [

	parseNode ifNil: [^nil].
	parseNode class == Symbol ifTrue: [^nil].	"special"
	^parseNode currentValueIn: self hostContext
]

{ #category : #printing }
SyntaxMorph >> getHeader: strm [
	| se |
	"We are in an EToy scriptor and the method header line has been removed.  Try to recover the method name.  Fail if method has args (deal with this later)."

	(se := self ownerThatIsA: ScriptEditorMorph) ifNotNil: [
		se scriptName numArgs > 0 ifTrue: [^ false].	"abort"
		strm nextPutAll: se scriptName].
	^ true
]

{ #category : #menus }
SyntaxMorph >> getMenuBlock [

	^ nil
]

{ #category : #highlighting }
SyntaxMorph >> grabColor [

	"Not the select color, but the mouseOver border color.  Means it could be grabbed"
	^ Color paleOrange mixed: 0.5 with: Color brown
]

{ #category : #'event handling' }
SyntaxMorph >> handlesKeyboard: evt [
	^ evt keyCharacter = Character backspace
]

{ #category : #'event handling' }
SyntaxMorph >> handlesMouseDown: evt [ 
	evt yellowButtonPressed ifTrue: [^true].
	parseNode isNil ifTrue: [^false].
	owner isSyntaxMorph 
		ifTrue: [(owner isMethodNode and: [self isBlockNode not]) ifTrue: [^false]].	"Can only take block out of a MethodNode"
	^true
]

{ #category : #'event handling' }
SyntaxMorph >> handlesMouseOver: evt [
	"Am I a tile that could be picked up?"

	^ true
]

{ #category : #'event handling' }
SyntaxMorph >> handlesMouseOverDragging: evt [

	^ evt hand hasSubmorphs
		and: [evt hand firstSubmorph isSyntaxMorph]

]

{ #category : #'dropping\/grabbing' }
SyntaxMorph >> highlightForDrop: evt [

	(self wantsDroppedMorph: evt hand firstSubmorph event: evt)
		ifTrue: [self color: self dropColor].
]

{ #category : #highlighting }
SyntaxMorph >> highlightForGrab: evt [

	self borderColor: self grabColor.
]

{ #category : #debugging }
SyntaxMorph >> hostContext [

	^nil		"we don't have one"
]

{ #category : #'node types' }
SyntaxMorph >> immediatelyBelowTheMethodNode [

	^(owner respondsTo: #isMethodNode) and: [owner isMethodNode]
]

{ #category : #'new tiles' }
SyntaxMorph >> instVarTile: aName [
	"Make and put into hand a tile for an instance variable"

	| sm |
	sm := ((VariableNode new
					name: aName
					index: 1
					type: 1 "LdInstType") asMorphicSyntaxIn: SyntaxMorph new).
	sm roundedCorners.
	self currentHand attachMorph: sm.
	Preferences tileTranslucentDrag
		ifTrue: [sm lookTranslucent.
			sm align: sm center with: self currentHand position "+ self cursorBaseOffset"]
		ifFalse: [
			sm align: sm topLeft with: self currentHand position + self cursorBaseOffset]
]

{ #category : #'node types' }
SyntaxMorph >> isAVariable [
	"There are three kinds of variable nodes"

	((parseNode class == TempVariableNode) or: [
		(parseNode class == LiteralVariableNode) or: [
			parseNode class == VariableNode]]) ifFalse: [^ false].
	^ (ClassBuilder new reservedNames includes: 
			self decompile string withoutTrailingBlanks) not
]

{ #category : #'node types' }
SyntaxMorph >> isBlockNode [
	^ parseNode class == BlockNode
]

{ #category : #'node types' }
SyntaxMorph >> isDeclaration [
	"Return true if I am a TempVarNode inside a declaration of some kind, including a method arg"

	| opc |
	owner isSyntaxMorph ifFalse: [^ false].
	opc := owner parseNode class.
	opc == BlockArgsNode ifTrue: [^ true].
	opc == MethodTempsNode ifTrue: [^ true].
	opc == SelectorNode ifTrue: [^ true].
	^ false
]

{ #category : #layout }
SyntaxMorph >> isKnownVarName: newVarName [
	"Return true if this variable is already known, as an argument, temp var, block temp, or instance variable."

	| syntLevel |
	(self parsedInClass allInstVarNames includes: newVarName) ifTrue: [^ true].
	syntLevel := self.
	[syntLevel tempVarNodesDo: [:node | 
		node decompile string = newVarName ifTrue: [^ true]].
	 (syntLevel := syntLevel owner) isSyntaxMorph] whileTrue.
	^ false
]

{ #category : #'node types' }
SyntaxMorph >> isLeafTile [
	self hasSubmorphs ifFalse: [^false].
	(self firstSubmorph isSyntaxMorph) ifTrue: [^false].
	(self firstSubmorph isMemberOf: Morph) ifTrue: [^false].
	^true
]

{ #category : #'node types' }
SyntaxMorph >> isMethodNode [
	^ parseNode class == MethodNode
]

{ #category : #'node types' }
SyntaxMorph >> isNoun [
	"Consider these to be nouns:  MessageNode with receiver, CascadeNode with receiver, AssignmentNode, TempVariableNode, LiteralNode, VariableNode, LiteralVariableNode."

	(#(TempVariableNode LiteralNode VariableNode LiteralVariableNode) includes:
		(parseNode class name)) ifTrue: [^ true].

	(self nodeClassIs: MessageNode) ifTrue: [^ parseNode receiver notNil].
	(self nodeClassIs: CascadeNode) ifTrue: [^ parseNode receiver notNil].
	(self nodeClassIs: AssignmentNode) ifTrue: [^ submorphs size >= 3].

	^ false
]

{ #category : #selection }
SyntaxMorph >> isSelectable [
	| ss |
	"Spacer morphs enclose other morphs with the same parseNode"
	self submorphs size > 1 ifTrue: [
		ss := self submorphs second.
		ss isSyntaxMorph ifTrue: [
			ss parseNode == parseNode ifTrue: [
				^ self submorphs first class ~~ Morph]]].
		
"	(self nodeClassIs: SelectorNode) ifTrue: [^ false].
	(self nodeClassIs: KeyWordNode) ifTrue: [^ false].
"
	self isMethodNode ifTrue: [^ false].
	parseNode ifNil: [^ false].
	^ true
]

{ #category : #'node types' }
SyntaxMorph >> isSelfTile [

	^ parseNode class == VariableNode and: [self decompile asString = 'self ']
	
]

{ #category : #'node to morph' }
SyntaxMorph >> isStandardGetterSelector: key [

	self flag: #yoCharCases.

	key size > 3 ifFalse: [^false].
	(key beginsWith: 'get') ifFalse: [^false].
	key fourth isUppercase ifFalse: [^false].
	^true

]

{ #category : #'node to morph' }
SyntaxMorph >> isStandardSetterKeyword: key [

	self flag: #yoCharCases.

	key size > 4 ifFalse: [^false].
	(key endsWith: ':') ifFalse: [^false].
	(key beginsWith: 'set') ifFalse: [^false].
	key fourth isUppercase ifFalse: [^false].
	^true

]

{ #category : #classification }
SyntaxMorph >> isSyntaxMorph [
	^ true
]

{ #category : #'dropping\/grabbing' }
SyntaxMorph >> justDroppedInto: aMorph event: evt [
	aMorph isSyntaxMorph ifFalse:
		[Preferences tileTranslucentDrag
			ifTrue: [self setDeselectedColor]
			ifFalse: [self align: self topLeft with: self topLeft - self cursorBaseOffset]].
	self removeProperty: #beScript.
	^ super justDroppedInto: aMorph event: evt
]

{ #category : #'event handling' }
SyntaxMorph >> keyStroke: evt [
	"Handle a keystroke event."
	| spacer |
	evt keyCharacter = Character backspace ifTrue:
		[(owner notNil and: [owner isSyntaxMorph]) ifTrue:
			[owner isBlockNode ifTrue:
				["Delete a statement."
				(spacer := self submorphAfter) class == AlignmentMorph
						ifTrue: [spacer delete].
				self delete].
			]].

]

{ #category : #'alans styles' }
SyntaxMorph >> lighterColor [

	^Color gray: 0.9		
"(Color r: 0.935 g: 0.935 b: 0.935)"
"paleGreen lighter"

]

{ #category : #vocabulary }
SyntaxMorph >> limitClassToUseWith: aValue vocabulary: aVocabulary [ 
	"Answer the most generic whose method should be shown in a selector pop-up in the receiver that is put up on behalf of aValue"

	(aValue isNumber) ifTrue: [^Number].
	"Ted: This hook allows you to intervene as suits your purposes here if you don't like the defaults."
	^aValue defaultLimitClassForVocabulary: aVocabulary
]

{ #category : #'formatting options' }
SyntaxMorph >> lookClassic [
	self isLeafTile ifTrue: [self layoutInset: 2@4]
]

{ #category : #drawing }
SyntaxMorph >> lookTranslucent [

	self setDeselectedColor.
	super color: (self color alpha: 0.25).
	submorphs do: [:mm | (mm respondsTo: #lookTranslucent) 
		ifTrue: [mm lookTranslucent]
		ifFalse: ["mm color: color"]].

]

{ #category : #accessing }
SyntaxMorph >> messageNode [
	"Return the enclosing messageNode that is the full message.  It has a receiver."

	^self orOwnerSuchThat: [:oo | oo receiverNode notNil]
]

{ #category : #'node to morph' }
SyntaxMorph >> messageNode: aNode receiver: receiver selector: selector keywords: key arguments: args [ 
	| keywords column row receiverMorph receiverWidth messageWidth onlyOne nodeWithNilReceiver isAConditional |
	self alansTest1 
		ifTrue: 
			[^self 
				alansMessageNode: aNode
				receiver: receiver
				selector: selector
				keywords: key
				arguments: args].
	isAConditional := #(#ifTrue: #ifFalse: #ifTrue:ifFalse: #ifFalse:ifTrue:) 
				includes: key.
	receiver ifNotNil: 
			["i.e. not a cascade"

			receiverMorph := receiver asMorphicSyntaxIn: self].
	keywords := key keywords.
	args isEmpty 
		ifTrue: 
			[row := (self addSingleKeywordRow: key) layoutInset: 1.
			^row parseNode: selector].
	receiverWidth := receiver ifNil: [0]
				ifNotNil: [receiverMorph fullBounds width].
	onlyOne := args size = 1.
	(receiverWidth <= 80 and: [onlyOne]) 
		ifTrue: 
			[self 
				messageOneArg: key
				receiver: receiver
				selector: selector
				args: args.
			^self].
	nodeWithNilReceiver := aNode copy receiver: nil.
	column := self addColumn: #keyword1 on: nodeWithNilReceiver.
	"onlyOne ifTrue: [column parseNode: nil].	is a spacer"
	messageWidth := 0.
	keywords with: (args copyFrom: 1 to: keywords size)
		do: 
			[:kwd :arg | 
			isAConditional 
				ifTrue: [column addMorphBack: (column transparentSpacerOfSize: 3 @ 3)].
			(row := column addRow: #keyword2 on: nodeWithNilReceiver)
				borderWidth: 1;
				parseNode: (nodeWithNilReceiver 
							as: (onlyOne ifTrue: [MessageNode] ifFalse: [MessagePartNode]));
				borderColor: row stdBorderColor.
			isAConditional 
				ifTrue: [row addMorphBack: (row transparentSpacerOfSize: 20 @ 6)].
			row 
				addToken: kwd
				type: #keyword2
				on: (onlyOne 
						ifTrue: [SelectorNode new key: kwd code: nil	"fill this in?"]
						ifFalse: [KeyWordNode new]).
			arg asMorphicSyntaxIn: row.
			messageWidth := messageWidth + row fullBounds width].
	onlyOne 
		ifTrue: 
			[self replaceSubmorph: column by: row.
			column := row].
	receiverMorph ifNil: [^self].
	receiverWidth + messageWidth < 350 
		ifTrue: 
			[isAConditional ifFalse: [self unfoldMessage].
			^self].
	((receiverWidth > 200 
		or: [receiverWidth > 80 and: [column fullBounds height > 20]]) or: 
				[receiverMorph fullBounds width > 30 
					and: [column fullBounds height > 100 or: [column fullBounds width > 250]]]) 
		ifTrue: [^self foldMessage]
]

{ #category : #'node to morph' }
SyntaxMorph >> messageOneArg: key receiver: receiver selector: selector args: args [

	| row firstArgMorph |

	row := (self addSingleKeywordRow: key) layoutInset: 1.
	row parseNode: selector.
	firstArgMorph := args first asMorphicSyntaxIn: self.
	receiver ifNil: [^ self].
	(firstArgMorph fullBounds height > 100
			or: [firstArgMorph fullBounds width > 250])
		ifTrue: [self foldMessageOneArg].

]

{ #category : #'node to morph' }
SyntaxMorph >> methodNodeInner: aNode selectorOrFalse: selectorOrFalse precedence: precedence arguments: arguments temporaries: temporaries primitive: primitive block: block [
	| header selNode |

	selNode := selectorOrFalse class == SelectorNode 
		ifTrue: [selectorOrFalse] 
		ifFalse: [SelectorNode new key: selectorOrFalse code: nil].
	header := self addRow: Color white on: selNode.
	precedence = 1
		ifTrue: [header addToken: aNode selector type: #methodHeader1 on: selNode]
		ifFalse: [aNode selector keywords with: arguments do:
					[:kwd :arg | 
					header addToken: kwd type: #methodHeader2 on: selNode.
					(arg asMorphicSyntaxIn: header) color: #blockarg2]].
	aNode addCommentToMorph: self.
	self addTemporaries: temporaries.
	(primitive > 0 and: [(primitive between: 255 and: 519) not]) ifTrue:
		["Dont decompile <prim> for, eg, ^ self "
		self addTextRow: (String streamContents: [ :strm | aNode printPrimitiveOn: strm])].
	block asMorphicSyntaxIn: self.
	^ self

]

{ #category : #'node to morph' }
SyntaxMorph >> methodNodeOuter: aNode [

	| block |
	
	self borderWidth: 0.
	aNode asMorphicSyntaxIn: self.
	self alansTest1 ifTrue: [self addTemporaryControls].
	self finalAppearanceTweaks.
		"self setProperty: #deselectedColor toValue: Color transparent."
	block := self findA: BlockNode.
		"block setProperty: #deselectedColor toValue: Color transparent."
	block submorphs size = 1 ifTrue: [^ self].	"keep '^ self' if that is the only thing in method"
	block submorphs last decompile string = '^  self ' ifTrue: [
		block submorphs last delete].
	^ self
]

{ #category : #'dropping\/grabbing' }
SyntaxMorph >> morphToDropInPasteUp: aPasteUp [
	"If property #beScript is true, create a scriptor around me."

	| actualObject itsSelector aScriptor adjustment handy tw blk |
	(self valueOfProperty: #beScript ifAbsent: [false]) ifFalse: [^ self].
	self removeProperty: #beScript.
	actualObject := self actualObject ifNil: [
					self valueOfProperty: #scriptedPlayer ifAbsent: [nil]].
	actualObject ifNil: [^ self].
	self removeProperty: #scriptedPlayer.
	actualObject assureUniClass.

	itsSelector := self userScriptSelector.
	aScriptor := itsSelector isEmptyOrNil
		ifFalse:
			[adjustment := 0@0.
			actualObject scriptEditorFor: itsSelector]
		ifTrue:
			[adjustment := 60 @ 20.
			actualObject newScriptorAround: self].
	aScriptor ifNil: [^self].
	handy := aPasteUp primaryHand.

	aScriptor position: handy position - adjustment.
	aPasteUp addMorphFront: aScriptor.	"do this early so can find World"
	aScriptor showingMethodPane ifFalse: [
		"(tw := aScriptor findA: TwoWayScrollPane) ifNil:
			[itsSelector ifNil: ['blank script'.
				tw := aScriptor findA: TwoWayScrollPane.
				blk := (tw scroller findA:  SyntaxMorph ""MethodNode"") findA: BlockNode.
				blk addMorphFront: self]].
		"
		SyntaxMorph setSize: nil andMakeResizable: aScriptor.
		].
	^ aScriptor

]

{ #category : #'event handling' }
SyntaxMorph >> mouseDown: evt [ 
	| dup rootTile |
	evt yellowButtonPressed ifTrue: [^ self showMenu: evt].
	(rootTile := self rootTile) isMethodNode ifTrue:
		[self currentSelectionDo:
			[:innerMorph :mouseDownLoc :outerMorph |
			(outerMorph notNil and: [self == innerMorph])
				ifTrue: ["Click on prior selection -- record click point."
						self setSelection: {self. evt cursorPoint. outerMorph}]
				ifFalse: ["A new selection sequence."
						self setSelection: {self. evt cursorPoint. nil}]].
		^ self].

	"Out in the world -- treat as a unit"
	rootTile isSticky ifTrue: [^ self].	"later may allow to be selected"
	rootTile isPartsDonor 
		ifTrue: [dup := rootTile duplicate.
				dup setProperty: #beScript toValue: true]
		ifFalse: [dup := rootTile].
	evt hand attachMorph: dup.
	Preferences tileTranslucentDrag
		ifTrue: [^ dup lookTranslucent]
		ifFalse: [^ dup align: dup topLeft with: evt hand position + self cursorBaseOffset]

]

{ #category : #'event handling' }
SyntaxMorph >> mouseEnter: evt [
	"Highlight this level as a potential grab target"

"Transcript cr; print: self; show: ' enter'."
	self rootTile isMethodNode ifFalse: [^ self]. 	"not in a script"
	self unhighlightOwnerBorder.
	self highlightForGrab: evt.
	evt hand newKeyboardFocus: self.

]

{ #category : #'event handling' }
SyntaxMorph >> mouseEnterDragging: evt [
	"Highlight this level as a potential drop target"

"self isBlockNode ifTrue: [Transcript cr; print: self; show: ' enterDragging']."
	self rootTile isMethodNode ifFalse: [^ self]. 	"not in a script"

	evt hand hasSubmorphs ifFalse: [^ self].  "Don't react to empty hand"
	self unhighlightOwnerBorder.
	self isBlockNode ifFalse: [self highlightForDrop: evt.
		(self firstOwnerSuchThat: [:m | m isSyntaxMorph and: [m color = self dropColor]])
			ifNotNil: [:m | m unhighlight]].

	self isBlockNode ifTrue:
		[(self firstOwnerSuchThat: [:m | m isSyntaxMorph and: [m isBlockNode]])
			ifNotNil: [:m | "Suspend outer block."
						m stopStepping; removeDropZones].
		self startStepping]

]

{ #category : #'event handling' }
SyntaxMorph >> mouseLeave: evt [ 
	"Move grab highlight back out a level"

	"Transcript cr; print: self; show: ' leave'."

	self rootTile isMethodNode ifFalse: [^self].	"not in a script"
	self unhighlightBorder.
	(owner notNil and: [owner isSyntaxMorph]) 
		ifTrue: [owner highlightForGrab: evt]
]

{ #category : #'event handling' }
SyntaxMorph >> mouseLeaveDragging: evt [ 
	"Transcript cr; print: self; show: ' leaveDragging'."

	self rootTile isMethodNode ifFalse: [^self].	"not in a script"
	self isBlockNode 
		ifTrue: 
			[self
				stopStepping;
				removeDropZones.
			(self firstOwnerSuchThat: [:m | m isSyntaxMorph and: [m isBlockNode]]) 
				ifNotNil: [:m | m startStepping].	"Activate outer block."
			self submorphs do: 
					[:ss | 
					"cancel drop color in line beside mouse"

					ss color = self dropColor ifTrue: [ss setDeselectedColor]]].

	"Move drop highlight back out a level"
	self unhighlight.
	(owner notNil and: [owner isSyntaxMorph]) 
		ifTrue: [owner isBlockNode ifFalse: [owner highlightForDrop: evt]]
]

{ #category : #'event handling' }
SyntaxMorph >> mouseMove: evt [
	
	owner isSyntaxMorph ifFalse: [^ self].

false ifTrue: ["for now, do not drag off a tile"
	self currentSelectionDo:
		[:innerMorph :mouseDownLoc :outerMorph | | dup selection |
		mouseDownLoc ifNotNil: [
			(evt cursorPoint dist: mouseDownLoc) > 4 ifTrue:
				["If drag 5 pixels, then tear off a copy of outer selection."
				selection := outerMorph ifNil: [self].
				selection deletePopup.
				evt hand attachMorph: (dup := selection duplicate).
				Preferences tileTranslucentDrag
					ifTrue: [dup lookTranslucent]
					ifFalse: [dup align: dup topLeft
								with: evt hand position + self cursorBaseOffset].
				self setSelection: nil.	"Why doesn't this deselect?"
				(self firstOwnerSuchThat: [:m | m isSyntaxMorph and: [m isBlockNode]])
					ifNotNil: [:m | "Activate enclosing block."
								m startStepping]]]].
	].
]

{ #category : #'event handling' }
SyntaxMorph >> mouseUp: evt [
	
	self rootTile isMethodNode ifFalse: [^ self].
	self currentSelectionDo:
		[:innerMorph :mouseDownLoc :outerMorph | | newSel |
		newSel := outerMorph
			ifNil: [self "first click"]
			ifNotNil: [(outerMorph firstOwnerSuchThat:
							[:m | m isSyntaxMorph and: [m isSelectable]]) ifNil: [self]].
		newSel isMethodNode ifTrue: [^ self setSelection: nil].
		self setSelection: {self. nil. newSel}]

]

{ #category : #'pop ups' }
SyntaxMorph >> newAssignment [
	"I am a variableNode.  Place me inside an assignment statement."

	| new old |
	parseNode name: self decompile.	"in case user changed name"
	new := owner assignmentNode: AssignmentNode new variable: parseNode 
					value: parseNode copy.
	self deselect.
	(old := owner) replaceSubmorph: self by: new.	"do the normal replacement"
	(old isSyntaxMorph) ifTrue: [old cleanupAfterItDroppedOnMe].	"now owned by no one"

]

{ #category : #'node types' }
SyntaxMorph >> nodeClassIs: aParseNodeClass [
	"Test the class of my parseNode"

	^ parseNode class == aParseNodeClass
]

{ #category : #'alans styles' }
SyntaxMorph >> noiseBeforeBlockArg [

	^ self alansTest1 ifTrue: [' Use'] ifFalse: [' from']
]

{ #category : #'alans styles' }
SyntaxMorph >> noiseStringMorph: aNoiseString [

	| sMorph |

	sMorph := self aSimpleStringMorphWith: aNoiseString.
	sMorph 
		font: (self fontToUseForSpecialWord: aNoiseString); 
		setProperty: #noiseWord toValue: true.

	^sMorph

]

{ #category : #'alans styles' }
SyntaxMorph >> noiseWordBeforeVariableNode: aNode string: aString [

	(#('self' 'nil') includes: aString) ifFalse: [
		aNode code ifNil: [^'my'].
		aNode type < 4 ifTrue: [^'my']
	].
	^nil
]

{ #category : #'pop ups' }
SyntaxMorph >> offerPopUp [
	"Put up a halo to allow user to change
		Literals (Integer, true),
		Selector (beep: sound, +,-,*,//,\\, r:g:b:, setX: incX: decX: for any X,),
		Variable (Color),
		not AssignmentNode (:= inc dec),
	Extend arrows on each literal, variable, and message, (block that is by itself).
	Retract arrows on each literal or variable, or message or block that is an argument.
	Any literal can be changed by Shift-clicking and typing."

	| panel any upDown retract extend colorPatch edge dismiss rr duplicate |
	(self hasProperty: #myPopup) ifTrue: [^self].	"already has one"
	any := false.
	(upDown := self upDownArrows) ifNotNil: [any := true].	"includes menu of selectors"
	(retract := self retractArrow) ifNotNil: [any := true].
	(extend := self extendArrow) ifNotNil: [any := true].
	(dismiss := self dismisser) ifNotNil: [any := true].
	(duplicate := self duplicator) ifNotNil: [any := true].
	"(assign := self assignmentArrow) ifNotNil: [any := true].
			get from menu or any other assignment"
	submorphs last class == ColorTileMorph 
		ifFalse: [(colorPatch := self colorPatch) ifNotNil: [any := true]].
	any ifFalse: [^self].
	"Transcript cr; print: parseNode class; space; 
		print: (self hasProperty: #myPopup); endEntry."
	panel := (RectangleMorph new)
				color: Color transparent;
				borderWidth: 0.
	upDown ifNotNil: 
			[panel addMorphBack: upDown first.
			upDown first align: upDown first topLeft with: panel topLeft + (0 @ 0).
			panel addMorphBack: upDown second.
			upDown second align: upDown second topLeft
				with: upDown first bottomLeft + (0 @ 1).
			upDown size > 2 
				ifTrue: 
					[panel addMorphBack: upDown third.
					upDown third align: upDown third topLeft
						with: upDown first topRight + (2 @ 3)]].
	rr := self right.
	colorPatch ifNotNil: 
			[rr := rr + colorPatch submorphs first width + 1.
			self addMorphBack: colorPatch	"always in tile"
			"colorPatch align: colorPatch topLeft 
					with: panel topLeft + (1@1)"].
	retract ifNotNil: 
			[edge := panel submorphs isEmpty 
						ifTrue: [panel left]
						ifFalse: [panel submorphs last right].
			panel addMorphBack: retract.
			retract align: retract topLeft with: (edge + 2) @ (panel top + 3)].
	extend ifNotNil: 
			[edge := panel submorphs isEmpty 
						ifTrue: [panel left]
						ifFalse: [panel submorphs last right].
			panel addMorphBack: extend.
			extend align: extend topLeft with: (edge + 2) @ (panel top + 3)].
	duplicate ifNotNil: 
			[edge := panel submorphs isEmpty 
						ifTrue: [panel left]
						ifFalse: [panel submorphs last right].
			panel addMorphBack: duplicate.
			duplicate align: duplicate topLeft with: (edge + 2) @ (panel top + 1)].
	dismiss ifNotNil: 
			[edge := panel submorphs isEmpty 
						ifTrue: [panel left]
						ifFalse: [panel submorphs last right].
			panel addMorphBack: dismiss.
			dismiss align: dismiss topLeft with: (edge + 2) @ (panel top + 1)].
	"	assign ifNotNil: [
		edge := panel submorphs isEmpty 
			ifTrue: [panel left] 
			ifFalse: [panel submorphs last right].
		panel addMorphBack: assign.
		assign align: assign topLeft with: (edge+2) @ (panel top + 2)].
"
	panel align: panel topLeft with: rr @ (self top - 2).
	panel extent: panel submorphs last bottomRight - panel topLeft.
	self setProperty: #myPopup toValue: panel.
	self addMorphBack: panel	"Any reason ever to have panel below?"
	"(owner listDirection = #topToBottom and: [self listDirection = #leftToRight])
		ifTrue: [self addMorphBack: panel]
		ifFalse: [owner addMorph: panel after: self]."
]

{ #category : #menus }
SyntaxMorph >> offerTilesMenuFor: aReceiver in: aLexiconModel [
	"Offer a menu of tiles for assignment and constants"

	| menu |
	menu := MenuMorph new addTitle: 'Hand me a tile for...'.
	menu addLine.
	menu add: '(accept method now)' target: aLexiconModel selector: #acceptTiles.
	menu submorphs last color: Color red darker.
	menu addLine.

	menu add: 'me, by name' target: self  selector: #attachTileForCode:nodeType: 
				argumentList: {'<me by name>'. aReceiver}.
	menu add: 'self' target: self  selector: #attachTileForCode:nodeType: 
				argumentList: {'self'. VariableNode}.
	menu add: '_   (assignment)' target: self  selector: #attachTileForCode:nodeType: 
				argumentList: {'<assignment>'. nil}.
	menu add: '"a Comment"' target: self  selector: #attachTileForCode:nodeType: 
				argumentList: {'"a comment"\' withCRs. CommentNode}.
	menu submorphs last color: Color blue.
	menu add: 'a Number' target: self  selector: #attachTileForCode:nodeType: 
				argumentList: {'5'. LiteralNode}.
	menu add: 'a Character' target: self  selector: #attachTileForCode:nodeType: 
				argumentList: {'$z'. LiteralNode}.
	menu add: '''abc''' target: self selector: #attachTileForCode:nodeType: 
				argumentList: {'''abc'''. LiteralNode}.
	menu add: 'a Symbol constant' target: self selector: #attachTileForCode:nodeType: 
				argumentList: {'#next'. LiteralNode}.
	menu add: 'true' target: self selector: #attachTileForCode:nodeType: 
				argumentList: {'true'. VariableNode}.
	menu add: 'a Test' target: self  selector: #attachTileForCode:nodeType: 
				argumentList: {'true ifTrue: [self] ifFalse: [self]'. MessageNode}.
	menu add: 'a Loop' target: self selector: #attachTileForCode:nodeType: 
				argumentList: {'1 to: 10 do: [:index | self]'. MessageNode}.
	menu add: 'a Block' target: self selector: #attachTileForCode:nodeType: 
				argumentList: {'[self]'. BlockNode}.
	menu add: 'a Class or Global' target: self selector: #attachTileForCode:nodeType: 
				argumentList: {'Character'. LiteralVariableNode}.
	menu add: 'a Reply' target: self selector: #attachTileForCode:nodeType: 
				argumentList: {'| temp | temp'. ReturnNode}.
	menu popUpInWorld: self world.
]

{ #category : #menus }
SyntaxMorph >> offerVarsMenuFor: aReceiver in: aLexiconModel [
	"Offer a menu of tiles for assignment and constants"

	| menu instVarList cls |
	menu := MenuMorph new addTitle: 'Hand me a tile for...'.
	menu addLine.
	menu add: '(accept method now)' target: aLexiconModel selector: #acceptTiles.
	menu submorphs last color: Color red darker.
	menu addLine.
	menu add: 'new temp variable' target: self selector: #attachTileForCode:nodeType: 
				argumentList: {'| temp | temp'. TempVariableNode}.

	instVarList := OrderedCollection new.
	cls := aReceiver class.
	[instVarList addAllFirst: cls instVarNames.
	 cls == aLexiconModel limitClass] whileFalse: [cls := cls superclass].
	instVarList do: [:nn |
		menu add: nn target: self selector: #instVarTile: argument: nn].
	menu popUpInWorld: self world.
]

{ #category : #'type checking' }
SyntaxMorph >> okToBeReplacedBy: aSyntaxMorph [
	"Return true if it is OK to replace me with aSyntaxMorph.  Enforce the type rules in the old EToy green tiles."

	| itsType myType |
	(Preferences eToyFriendly or: [Preferences typeCheckingInTileScripting])
		ifFalse: [^ true].	"not checking unless one of those prefs is true"
	(parseNode class == BlockNode and: [aSyntaxMorph parseNode class == BlockNode]) 
		ifTrue: [^ true].
	(parseNode class == ReturnNode and: [aSyntaxMorph parseNode class == ReturnNode]) 
		ifTrue: [^ true].
	parseNode class == KeyWordNode ifTrue: [^ false].
	aSyntaxMorph parseNode class == KeyWordNode ifTrue: [^ false].
	parseNode class == SelectorNode ifTrue: [^ false].
	aSyntaxMorph parseNode class == SelectorNode ifTrue: [^ false].
	owner isSyntaxMorph ifFalse: [^ true].	"only within a script"
		"Transcript show: aSyntaxMorph resultType printString, ' dropped on ', 
			self receiverOrArgType printString; cr.
		"
	(itsType := aSyntaxMorph resultType) == #unknown ifTrue: [^ true].
	(myType := self receiverOrArgType) == #unknown ifTrue: [^ true].
		"my type in enclosing message"
	^ myType = itsType
]

{ #category : #initialization }
SyntaxMorph >> openInWindow [

	| sel |
	sel := ''.
	self firstSubmorph allMorphs do: [:rr | 
		(rr isKindOf: StringMorph) ifTrue: [sel := sel, rr contents]].

	^ self inAScrollPane
		color: Color paleOrange;
		openInWindowLabeled: 'Tiles for ', self parsedInClass printString, '>>', sel
]

{ #category : #printing }
SyntaxMorph >> ownerPrecedence [
	"Return the selector precedence of my owner.  1 for unary (asInteger), 2 for binary arithmetic (+), and 3 for keyword selectors (from:to:).  Subtract 0.5 if self is an arg, not the receiver (the case of a + (b + c))"

	| oo below sel pp |
	oo := owner.
	below := self.
	
	[oo isSyntaxMorph ifFalse: [^10].	"I do not need parens"
	oo parseNode isNil] 
			whileTrue: 
				[below := oo.
				oo := oo owner].
	(sel := oo selector) ifNil: [^10].
	(pp := sel precedence) = 3 ifTrue: [^2.5].	"keyword messages need parens"
	^oo receiverNode == below ifTrue: [pp] ifFalse: [pp - 0.5]
]

{ #category : #accessing }
SyntaxMorph >> parseNode [
	
	^parseNode
		
	
]

{ #category : #accessing }
SyntaxMorph >> parseNode: x [
	
	parseNode := x
		
	
]

{ #category : #accessing }
SyntaxMorph >> parsedInClass [

	^ self rootTile parseNode encoder classEncoding
]

{ #category : #accessing }
SyntaxMorph >> parsedInClass: x [

	self parsedInClass == x ifFalse: [self error: 'inconsistent value']
]

{ #category : #printing }
SyntaxMorph >> printAssignmentNodeOn: strm indent: level [
	"sometimes an assignment is in parens"
	| parens above |

	parens := submorphs size >= 3.
	parens ifTrue: [
		above := self ownerPrecedence.	"high if not in an expression"
		parens := above <= 3].	"assignment is a noun inside a message"
	parens ifTrue: [strm nextPut: $( ].
	self
		submorphsDoIfSyntax: [ :sub |
			sub printOn: strm indent: level.
			strm ensureASpace.
		]
		ifString: [ :sub |
			strm ensureNoSpace. 	":= will have a leading space"
			self printSimpleStringMorph: sub on: strm
		].
	parens ifTrue: [strm ensureNoSpace; nextPut: $) ].

]

{ #category : #printing }
SyntaxMorph >> printBlockArgsNodeOn: strm indent: level [

	

	self
		submorphsDoIfSyntax: [ :sub | | argString |
			(argString := sub decompile) isEmpty ifFalse: [
				strm 
					nextPut: $:;
					nextPutAll: argString;
					space
			].
		] 
		ifString: [ :sub |
			"self printSimpleStringMorph: sub on: strm	<<<< do we need this??"
		].
	strm nextPut: $|; crtab: level.


]

{ #category : #printing }
SyntaxMorph >> printBlockNodeOn: strm indent: level [

	| lev inASyntaxButNotOutermost |

	lev := level.
	inASyntaxButNotOutermost := owner isSyntaxMorph and: [ owner isMethodNode not].
	inASyntaxButNotOutermost ifTrue: [strm nextPut: $[.  lev := lev+1].
	self
		submorphsDoIfSyntax: [ :sub | | subNodeClass |
			sub printOn: strm indent: lev.
			subNodeClass := sub parseNode class.
			(#(BlockArgsNode ReturnNode CommentNode) includes: subNodeClass name) ifFalse: [
				strm ensureNoSpace; nextPut: $.].
			subNodeClass == BlockArgsNode
				ifTrue: [strm space]
				ifFalse: [strm crtab: lev].
		] 
		ifString: [ :sub |
			self printSimpleStringMorph: sub on: strm
		].
	inASyntaxButNotOutermost ifTrue: [strm nextPut: $] ].


]

{ #category : #printing }
SyntaxMorph >> printCascadeNodeOn: strm indent: level [

	| parens cnt me above |

	parens := parseNode receiver notNil.
	parens ifTrue: [me := self selector precedence.
		above := self ownerPrecedence.	"high if not in an expression"
		parens := me > above].
	parens ifTrue: [strm nextPut: $( ].
	cnt := 0.
	self
		submorphsDoIfSyntax: [ :sub |
			cnt := cnt + 1.
			"maybe we want to test sub isCascadePart for the following???"
			cnt > 2 ifTrue: [strm nextPutAll: '; '].
			sub printOn: strm indent: level.
			strm ensureASpace.
		]
		ifString: [ :sub |
			self printSimpleStringMorph: sub on: strm
		].
	parens ifTrue: [strm ensureNoSpace; nextPut: $) ].

]

{ #category : #printing }
SyntaxMorph >> printMessageNodeOn: strm indent: level [

	| parens me above |

	parens := parseNode receiver notNil.
	parens ifTrue: [me := self selector precedence.
		above := self ownerPrecedence.	"high if not in an expression"
		parens := me > above].
	parens ifTrue: [strm nextPut: $( ].
	self
		submorphsDoIfSyntax: [ :sub |
			sub printOn: strm indent: level.
			strm ensureASpace.
		]
		ifString: [ :sub |
			self printSimpleStringMorph: sub on: strm
		].
	parens ifTrue: [strm ensureNoSpace; nextPut: $) ].

]

{ #category : #printing }
SyntaxMorph >> printMethodNodeOn: strm indent: level [

	(self findA: SelectorNode) ifNil: [
		(self getHeader: strm) ifFalse: [^ self].		"might fail"
		strm crtab: level].
	self 
		submorphsDoIfSyntax: [ :sub |
			sub printOn: strm indent: level.
			strm crtab: level.
		]
		ifString: [ :sub |
			self printSimpleStringMorph: sub on: strm
		]. 
	strm last == $. ifTrue: [strm skip: -1].  "ugh!  erase duplicate final period"
]

{ #category : #printing }
SyntaxMorph >> printMethodTempsNodeOn: strm indent: level [

	strm nextPut: $|; space.
	self
		submorphsDoIfSyntax: [ :sub |
			sub printOn: strm indent: level.
			strm space.
		]
		ifString: [ :sub |
			self printSimpleStringMorph: sub on: strm
		].
	strm nextPut: $|; crtab: level.

]

{ #category : #printing }
SyntaxMorph >> printOn: strm [

	super printOn: strm.
	strm space; nextPutAll: parseNode class name.
]

{ #category : #printing }
SyntaxMorph >> printOn: strm indent: level [

	| nodeClass |

	(self hasProperty: #ignoreNodeWhenPrinting) ifFalse: [
		nodeClass := parseNode class.
		nodeClass == VariableNode ifTrue: [^self printVariableNodeOn: strm indent: level].
		nodeClass == LiteralVariableNode ifTrue: [^self printVariableNodeOn: strm indent: level].
		nodeClass == MessageNode ifTrue: [^self printMessageNodeOn: strm indent: level].
		nodeClass == BlockNode ifTrue: [^self printBlockNodeOn: strm indent: level].
		nodeClass == BlockArgsNode ifTrue: [^self printBlockArgsNodeOn: strm indent: level].
		nodeClass == MethodNode ifTrue: [^self printMethodNodeOn: strm indent: level].
		nodeClass == MethodTempsNode ifTrue: [^self printMethodTempsNodeOn: strm indent: level].
		nodeClass == CascadeNode ifTrue: [^self printCascadeNodeOn: strm indent: level].
		nodeClass == AssignmentNode ifTrue: [^self printAssignmentNodeOn: strm indent: level].
	].
	self
		submorphsDoIfSyntax: [ :sub |
			sub printOn: strm indent: level.
			strm ensureASpace.
		]
		ifString: [ :sub |
			self printSimpleStringMorph: sub on: strm
		].

]

{ #category : #printing }
SyntaxMorph >> printSimpleStringMorph: aMorph on: strm [

	| trialContents |

	(aMorph hasProperty: #wordyVariantOfSelf) ifTrue: [
		strm nextPutAll: 'self '.
		strm nextPutAll: ((self translateToWordySelfVariant: aMorph contents) ifNil: [^self]).
		^self
	].
	(aMorph hasProperty: #noiseWord) ifFalse: [
		trialContents := self cleanUpString: aMorph.
		strm nextPutAll: trialContents
	].

]

{ #category : #printing }
SyntaxMorph >> printStatementsOn: aStream indent: indent [

	"seemed to be necessary to see top node in explorer"

	^parseNode printStatementsOn: aStream indent: indent
]

{ #category : #printing }
SyntaxMorph >> printVariableNodeOn: strm indent: level [

	"nil out any old association"
	parseNode key isVariableBinding ifTrue: [
		parseNode 
			name: parseNode name 
			key: nil 
			code: parseNode code
	].
	self
		submorphsDoIfSyntax: [ :sub |
			sub printOn: strm indent: level.
			strm ensureASpace.
		]
		ifString: [ :sub |
			self printSimpleStringMorph: sub on: strm
		].

]

{ #category : #menus }
SyntaxMorph >> putOnBackground [
	"Place the receiver, formerly private to its card, onto the shared background.  If the receiver needs data carried on its behalf by the card, such data will be represented on every card."

	| updStr |
	(updStr := self readOut) ifNotNil: ["If has a place to put per-card data, set that up."
		updStr getSelector ifNotNil: [
			self setProperty: #holdsSeparateDataForEachInstance toValue: true]].
	super putOnBackground.
]

{ #category : #accessing }
SyntaxMorph >> readOut [
	"Find and return an UpdatingStringMorph, possibly in a NumericReadoutTile"

	^ ((self findA: NumericReadoutTile) ifNil: [^ nil]) findA: UpdatingStringMorph
]

{ #category : #accessing }
SyntaxMorph >> receiverNode [
	"If I am (have) a MessageNode, return the node of the receiver.  Watch out for foolish noise words."

	parseNode class == MessageNode ifFalse: [^ nil].
	parseNode receiver ifNil: [^ nil].
	submorphs do: [:ss | 
		ss isSyntaxMorph ifTrue: [
			ss parseNode ifNotNil: ["not noise word"
				ss isNoun ifTrue: [^ ss] 
					ifFalse: [^ nil "found selector"]]]].
	^ nil
]

{ #category : #accessing }
SyntaxMorph >> receiverObject [
	"Return some object that could be the receiver to me (a selector).  Either the actual object who is the receiver in this message, or a guy of the right class."

	| rec value mm |
	(rec := owner) isSyntaxMorph ifFalse: [^ nil].
	rec := rec receiverNode.
	rec ifNil: [(rec := owner owner) isSyntaxMorph ifFalse: [^ nil].
				rec := rec receiverNode].	
	rec ifNil: [(rec := owner owner owner) isSyntaxMorph ifFalse: [^ nil].
				rec := rec receiverNode].
	rec isSelfTile ifTrue: [
		^ ((mm := self containingWindow model) respondsTo: #targetObject) 
			ifTrue: [mm targetObject]
			ifFalse: [mm selectedClassOrMetaClass new]].
	value := rec ifNotNil: [rec try].
	value class == Error ifTrue: [
		value := Vocabulary instanceWhoRespondsTo: self selector].
	^ value
]

{ #category : #'type checking' }
SyntaxMorph >> receiverOrArgType [
	| ty |
	"Return my type in my role as a receiver or as an argument.  Ask my enclosing message first, then ask myself.  (If owner accepts any #object, and I am a #point, do return #object.)"

	^ (ty := self receiverOrArgTypeAbove) == #unknown
		ifTrue: [self resultType]
		ifFalse: [ty]
]

{ #category : #'type checking' }
SyntaxMorph >> receiverOrArgTypeAbove [
	"Return the type for me according to the message that encloses me."

	| enclosing sub list |
	(self nodeClassIs: BlockNode) ifTrue: [^#command].
	enclosing := owner.
	sub := self.
	
	[enclosing isSyntaxMorph ifFalse: [^#unknown].
	(enclosing nodeClassIs: MessageNode) 
		ifTrue: 
			[list := enclosing submorphs 
						select: [:ss | ss isSyntaxMorph and: [ss parseNode notNil]].
			list size = 1 
				ifFalse: 
					[^(list indexOf: sub) = 1 
						ifTrue: [enclosing receiverTypeFor: enclosing selector]
						ifFalse: [enclosing argTypeFor: enclosing selector]]].
	(enclosing nodeClassIs: BlockNode) ifTrue: [^#command].
	sub := enclosing.
	enclosing := enclosing owner] repeat
]

{ #category : #'type checking' }
SyntaxMorph >> receiverTypeFor: aSelector [
	"Answer the type of the receiver of this selector.  Return #unknown if not found."

	| itsInterface |

	aSelector ifNil: [^ #unknown].
	itsInterface := self currentVocabulary methodInterfaceAt: aSelector ifAbsent:
		[^ #unknown].
	^ itsInterface receiverType
]

{ #category : #'insertion drop zones' }
SyntaxMorph >> removeDropZones [
	"Remove the insertion drop-zone morphs."

	self submorphsDo:
		[:mm | (mm isMemberOf: BorderedMorph) ifTrue: [mm delete]].

]

{ #category : #layout }
SyntaxMorph >> removeReturnNode [
	| blk |
	"If last line is ^ self, remove it.  I am a methodNode.  Keep if no other tiles in the block."

	blk := self findA: BlockNode.
	blk submorphs last decompile string = '^self ' ifTrue: [
		(blk submorphs count: [:ss | ss isSyntaxMorph]) > 1 ifTrue: [
			blk submorphs last delete]].
]

{ #category : #accessing }
SyntaxMorph >> rename: newSelector [
	| keywords mainSel list last |
	"Attempt to change the name as listed in my tiles.  Can change the number of argumtents.  MethodNode (SelectorNode (SelectorNode (string))) or MethodNode (SelectorNode (SelectorNode (string) TempVarNode() SelectorNode (string) TempVarNode()))"

	self isMethodNode ifFalse: [
		self rootTile == self ifTrue: [^ self].  "not in a script"
		^ self rootTile rename: newSelector  "always do at the root"].

	keywords := newSelector keywords.
	mainSel := self findA: SelectorNode.
	list := mainSel submorphs select: [:mm | 
		mm isSyntaxMorph and: [mm parseNode class == SelectorNode]].
	1 to: (list size min: keywords size) do: [:ind |
		((list at: ind) findA: UpdatingStringMorph) contents: (keywords at: ind)].
	keywords size + 1 to: list size do: [:ind | "removing keywords"
		[last := mainSel submorphs last.
		 (last isSyntaxMorph and: [last parseNode class == TempVariableNode])] whileFalse: [
				last delete].
		[last := mainSel submorphs last.
		 (last isSyntaxMorph and: [last parseNode class == SelectorNode])] whileFalse: [
				last delete].	"the TempVariableNode and others"
		mainSel submorphs last delete.	"the SelectorNode"
		].
	list size + 1 to: keywords size do: [:ind | "adding keywords"
		"add a SelectorNode, add a spacer, add a TempVarNode"
		mainSel addToken: (keywords at: ind) type: #keyword1 
			on: (SelectorNode new key: (keywords at: ind) code: nil).
		mainSel addMorphBack: (mainSel transparentSpacerOfSize: 4@4).
		(TempVariableNode new name: 'arg', ind printString index: ind type: nil scope: nil)
			 asMorphicSyntaxIn: mainSel].
]

{ #category : #'pop ups' }
SyntaxMorph >> replaceKeyWord: evt menuItem: stringMorph [
	"Replace my entire message (which may be multi-part) with the one specified.  Preserve all argument tiles, either in the new message or in the world outside the scriptor.  I am a SelectorNode or KeyWordNode."

	| menu new news newSel mm newTree newRec newArgs top oldArgNodes share ctrY |
	(menu := stringMorph owner owner) class == RectangleMorph ifTrue: [
		menu delete].
	new := stringMorph contents.
	new first = $( ifTrue: [^ self].	"Cancel"
	new first = $  ifTrue: [^ self].	"nothing"
	news := String streamContents: [:strm | "remove fake args"
		(new findBetweenSubStrs: {' 5'. Character space.}) do: [:part | strm nextPutAll: part]].
	newSel := stringMorph valueOfProperty: #syntacticallyCorrectContents.
	newSel ifNil: [newSel := news].
	mm := MessageSend receiver: 5 selector: newSel 
			arguments: ((Array new: newSel numArgs) atAllPut: 5).
	newTree := mm asTilesIn: Object globalNames: false.
	newRec := newTree receiverNode.
	newArgs := newTree argumentNodes.
	ctrY := self fullBoundsInWorld center y.
	top := self messageNode.
	newRec owner replaceSubmorph: newRec by: top receiverNode.
	oldArgNodes := top argumentNodes.
	share := newArgs size min: oldArgNodes size.
	(newArgs first: share) with: (oldArgNodes first: share) do: [:newNode :oldNode | 
		newNode owner replaceSubmorph: newNode by: oldNode].
	"later get nodes for objects of the right type for new extra args"

	top owner replaceSubmorph: top by: newTree.

	"Deposit extra args in the World"
	(oldArgNodes copyFrom: share+1 to: oldArgNodes size) do: [:leftOver |
		(leftOver parseNode class == LiteralNode and: [leftOver decompile asString = '5']) 
			ifFalse: [newTree pasteUpMorph addMorphFront: leftOver.
				leftOver position: newTree enclosingPane fullBoundsInWorld right - 20 @ ctrY.
				ctrY := ctrY + 26]
			ifTrue: [leftOver delete]].
	newTree acceptIfInScriptor.
]

{ #category : #'pop ups' }
SyntaxMorph >> replaceSel: evt menuItem: stringMorph [
	"I rep a SelectorNode.  Replace my selector with new one that was just chosen from a menu"

	| menu new old newSel ms oa na case news |
	(menu := stringMorph owner owner) class == RectangleMorph ifTrue: [
		menu delete].
	new := stringMorph contents.
	new first = $( ifTrue: [^ self].	"Cancel"
	new first = $  ifTrue: [^ self].	"nothing"
	news := String streamContents: [:strm | "remove fake args"
		(new findBetweenSubStrs: {' 5'. Character space.}) do: [:part | strm nextPutAll: part]].
	newSel := stringMorph valueOfProperty: #syntacticallyCorrectContents.
	newSel ifNil: [newSel := news].
	old := (ms := self findA: StringMorph) valueOfProperty: #syntacticallyCorrectContents.
	old ifNil: [old := (self findA: StringMorph) contents].
	oa := old numArgs.  na := newSel numArgs.  case := 5.
	(oa = 1) & (na = 1) ifTrue: [case := 1]. 
	(oa = 0) & (na = 0) ifTrue: [case := 2].
	(oa = 1) & (na  = 0) ifTrue: [case := 3].
	(oa = 0) & (na  = 1) ifTrue: [case := 4].
	case <= 4 ifTrue: ["replace the selector"
		ms contents: news.	"not multi-part"
		ms setProperty: #syntacticallyCorrectContents toValue: newSel].
	case = 3 ifTrue: [owner tossOutArg: 1].
	case = 4 ifTrue: [self addArg: 1].
	"more cases here.  Rebuild the entire MessageNode"
	
	self acceptIfInScriptor.
]

{ #category : #'type checking' }
SyntaxMorph >> resultType [
	"Look up my result type.  If I am a constant, use that class.  If I am a message, look up the selector."

	| list value soundChoices |
	parseNode class == BlockNode ifTrue: [^#blockContext].
	parseNode class == AssignmentNode ifTrue: [^#command].
	parseNode class == ReturnNode ifTrue: [^#command].	"Need more restriction than this"
	list := submorphs 
				select: [:ss | ss isSyntaxMorph and: [ss parseNode notNil]].
	list size > 1 ifTrue: [^self resultTypeFor: self selector].
	list size = 1 
		ifTrue: 
			["test for levels that are just for spacing in layout"

			(list first isSyntaxMorph and: [list first nodeClassIs: MessageNode]) 
				ifTrue: [^list first resultType]].	"go down one level"
	value := self try.
	value class == Error ifTrue: [^#unknown].
	(value isNumber) ifTrue: [^#Number].
	(value isKindOf: Boolean) ifTrue: [^#Boolean].
	(value isForm) ifTrue: [^#Graphic].
	(value isPlayerLike and: [value costume renderedMorph isMemberOf: KedamaPatchMorph]) ifTrue: [^#Patch].
	value isString
		ifTrue: 
			[soundChoices := #('silence').	"default, if no SampledSound class"
			Smalltalk at: #SampledSound
				ifPresent: [:sampledSound | soundChoices := sampledSound soundNames].
			(soundChoices includes: value) ifTrue: [^#Sound]].
	(value isPlayerLike) ifTrue: [^#Player].
	^value class name asLowercase	"asSymbol (not needed)"
]

{ #category : #'type checking' }
SyntaxMorph >> resultTypeFor: aSelector [
	"Answer the result type of selector.  Return #unknown if not found."

	| itsInterface |
	aSelector ifNil: [self inform: 'Please tell Ted how you caused this'.
		^ #abs "a bogus type"].
	itsInterface := self currentVocabulary methodInterfaceAt: aSelector ifAbsent:
		[^ #unknown].
	^ itsInterface resultType
]

{ #category : #'pop ups' }
SyntaxMorph >> retract [
	"replace this message with its receiver.  I am the message node."
	| rec cascade msg |
	(self nodeClassIs: CascadeNode) ifTrue:
		["This is a piece of a cascaded message -- just delete it"
		self deletePopup.
		cascade := owner.
		self delete.
		cascade setSelection: {cascade. nil. cascade}.
		^ cascade acceptIfInScriptor].
	self deletePopup.
	(rec := self receiverNode)
		ifNil: [msg := owner.
			rec := owner receiverNode.
			msg owner replaceSubmorph: msg by: rec]
		ifNotNil: [owner replaceSubmorph: self by: rec].
	rec setSelection: {rec. nil. rec}.
	rec acceptIfInScriptor.
]

{ #category : #'pop ups' }
SyntaxMorph >> retractArrow [
	"Return the retract arrow button.  It replaces the current message with its receiver.
	I am in a MessageNode whose first subnode is not a MessagePartNode.  I did not encounter a block on the way up to it.  I am the last subnode in every owner up to it."
	| patch |

	(self nodeClassIs: MessageNode) ifFalse: [^ nil].
	(owner isSyntaxMorph and: [owner parseNode == parseNode]) ifTrue: [^ nil].

	patch := (ImageMorph new image: (TileMorph classPool at: #RetractPicture)).
	patch on: #mouseDown send: #retract to: self.
	^ patch
]

{ #category : #initialization }
SyntaxMorph >> returnNode: aNode expression: expr [

	| row expMorph sMorph aNoiseString |
	row := self addRow: #return on: aNode.
	self alansTest1 ifTrue: [
		row setSpecialOuterTestFormat.
		aNoiseString := ' Reply '.
		sMorph := self aSimpleStringMorphWith: aNoiseString.
		sMorph 
			emphasis: TextEmphasis bold emphasisCode;
			setProperty: #syntacticallyCorrectContents toValue: '^'.

		row addMorphBack: sMorph.
	] ifFalse: [
		row addToken: '^ ' type: #upArrow on: aNode.
	].
	expMorph := expr asMorphicSyntaxIn: row.
	self alansTest1 ifTrue: [
		(expMorph hasProperty: #deselectedColor) ifFalse: [expMorph setConditionalPartStyle].
	].
	expr addCommentToMorph: row.
	^row

]

{ #category : #'node types' }
SyntaxMorph >> rootTile [
	^self 
		orOwnerSuchThat: [:m | m owner isNil or: [m owner isSyntaxMorph not]]
]

{ #category : #initialization }
SyntaxMorph >> sample: arg1 [
"a comment"
| temp1 |
temp1 := 5.
temp1 yourself.
temp1 min: arg1.
]

{ #category : #selection }
SyntaxMorph >> scaleColorByUserPref: aColor [
	
	| myRoot underLyingColor |

	myRoot := self rootTile.
	underLyingColor := myRoot ifNil: [Color transparent] ifNotNil: [myRoot color].
	[underLyingColor isTransparent and: [(myRoot := myRoot owner) notNil]] whileTrue: [
		underLyingColor := myRoot color.
	].
	
	"rude hack to get the desired effect before we have an owner"

	underLyingColor isTransparent ifTrue: [underLyingColor := Color r: 0.903 g: 1.0 b: 0.903].
	^aColor mixed: (ContrastFactor ifNil: [0.3]) with: underLyingColor

"Would like to be able to make MethodNode and outer Block be transparent.  This method does not allow that.  Consider (^ myRoot color) inside the whileTrue.  Consider setting underLyingColor to (myRoot valueOfProperty: #deselectedBorderColor ifAbsent: [myRoot color]) in second line."
]

{ #category : #selection }
SyntaxMorph >> select [
	self deselect.
	"Outer block is not colored and has no popup"
	(owner isSyntaxMorph and: [owner nodeClassIs: MethodNode]) 
		ifTrue: [self setDeselectedColor "normal"]
		ifFalse: [self color: Color lightBrown].
	self borderStyle: (BorderStyle raised width: self borderWidth).
	self offerPopUp.
]

{ #category : #accessing }
SyntaxMorph >> selector [
	"Find the selector I represent, or have inside of me.  My parseNode is a SelectorNode or a MessageNode."

	| sel cnt |
	parseNode class == SelectorNode 
		ifTrue: [^self decompile asString asSymbol].
	parseNode class == KeyWordNode ifTrue: [^self decompile asString asSymbol].
	parseNode class == MessageNode | (parseNode class == MessagePartNode) 
		ifFalse: [^nil].
	"Must be one of those to have a selector"
	"Beware of messageParts.  If MessagePartNode, only returns this one keyword."
	sel := ''.
	cnt := 0.
	submorphs do: 
			[:mm | 
			mm isSyntaxMorph 
				ifTrue: 
					[cnt := cnt + 1.
					(mm nodeClassIs: SelectorNode) ifTrue: [^mm selector].
					(mm nodeClassIs: MessagePartNode) ifTrue: [sel := sel , mm selector].
					(mm nodeClassIs: KeyWordNode) ifTrue: [sel := sel , mm decompile asString].
					(mm nodeClassIs: ReturnNode) ifTrue: [cnt := cnt - 1].
					(mm nodeClassIs: MessageNode) 
						ifTrue: 
							[parseNode receiver ifNil: [sel := mm selector].
							cnt = 2 & (sel isEmpty) 
								ifTrue: 
									["not the receiver.  Selector and arg"

									sel := mm selector]]]].
	sel ifNil: [^nil].
	sel notEmpty ifTrue: [^sel asSymbol].
	^nil
]

{ #category : #'pop ups' }
SyntaxMorph >> selectorMenu [
	"Put up a menu of all selectors that my receiver could be sent.  Replace me with the one chosen.  (If fewer args, put the tiles for the extra arg to the side, in script's owner (world?).)
	Go ahead and eval receiver to find out its type.  Later, mark selectors for side effects, and don't eval those.
	Put up a table.  Each column is a viewer category."

	| cats value catNames all ind aVocabulary limitClass |
	cats := #().
	all := Set new.
	value := self receiverObject.
	value class == Error ifTrue: [^ nil].
	
	aVocabulary := self vocabularyToUseWith: value.
	limitClass := self limitClassToUseWith: value vocabulary: aVocabulary.
	catNames := value categoriesForVocabulary: aVocabulary limitClass: limitClass.
	cats := catNames collect: [:nn | | interfaces list | 
		list := OrderedCollection new.
		interfaces := value methodInterfacesForCategory: nn 
						inVocabulary: aVocabulary limitClass: limitClass.
		interfaces do: [:mi | | setter wording words | 
			(all includes: mi selector) ifFalse: [
				"list add: (self aSimpleStringMorphWith: mi elementWording).  Expensive"
				words := mi selector.
				(words beginsWith: 'get ') ifTrue: [words := words allButFirst: 4].
				mi selector last == $: ifTrue: [
					words := String streamContents: [:strm | "add fake args"
						(words findTokens: $:) do: [:part | strm nextPutAll: part; nextPutAll: ' 5 ']].
					words := words allButLast].
				mi selector isInfix ifTrue: [words := words, ' 5'].
				words := self splitAtCapsAndDownshifted: words.	
				list add: (self anUpdatingStringMorphWith: words special: true).
				words = mi selector ifFalse: [
					list last setProperty: #syntacticallyCorrectContents toValue: mi selector].
				all add: mi selector].
			setter := mi companionSetterSelector asString.
			(setter = 'nil') | (all includes: setter) ifFalse: ["need setters also"
				wording := (self translateToWordySetter: setter).
				list add:  (self aSimpleStringMorphWith: wording, ' 5').
				wording = setter ifFalse: [
					list last setProperty: #syntacticallyCorrectContents 
						toValue: setter].
				all add: setter]].
		list].
	(ind := catNames indexOf: 'scripts') > 0 ifTrue: [
		(cats at: ind) first contents = 'empty script' ifTrue: [(cats at: ind) removeFirst]].
	cats first addFirst: (self aSimpleStringMorphWith: ' ').	"spacer"
	cats first addFirst: (self aSimpleStringMorphWith: '( from ', value class name, ' )').
	cats first first color: (Color green mixed: 0.25 with: Color black).
	self selectorMenuAsk: cats.	"The method replaceSel:menuItem: does the work.  
		and replaces the selector."
	
]

{ #category : #'pop ups' }
SyntaxMorph >> selectorMenuAsk: listOfLists [
	"I represent a SelectorNode to be replaced by one of the selectors in one of the category lists.  Each list has pre-built StringMorphs in it."

	| menu |
	listOfLists isEmpty ifTrue: [^ nil].
	listOfLists first addFirst: (self aSimpleStringMorphWith: '( Cancel )').
	listOfLists first first color: Color red.
	menu := RectangleMorph new.
	menu listDirection: #leftToRight; layoutInset: 3; cellInset: 1 @ 0.
	menu layoutPolicy: TableLayout new; hResizing: #shrinkWrap; 
		vResizing: #shrinkWrap; color: (Color r: 0.767 g: 1.0 b: 0.767);
		useRoundedCorners; cellPositioning: #topLeft.
	listOfLists do: [:ll | | col |
		col := Morph new.
	 	col listDirection: #topToBottom; layoutInset: 0; cellInset: 0 @ 0.
		col layoutPolicy: TableLayout new; hResizing: #shrinkWrap.
		col color: Color transparent; vResizing: #shrinkWrap.
		menu addMorphBack: col.
		ll do: [:ss | 
			col addMorphBack: ss.
			ss on: #mouseUp send: #replaceKeyWord:menuItem: to: self]
		].
	self world addMorph: menu.
	menu setConstrainedPosition: (owner localPointToGlobal: self topRight) + (10 @ -30) 
			hangOut: false.

]

{ #category : #'alans styles' }
SyntaxMorph >> setConditionalPartStyle [

	self specialColor: self lighterColor andBorder: self darkerColor.
	self useRoundedCorners.
	self borderWidth: 1.

]

{ #category : #selection }
SyntaxMorph >> setDeselectedColor [
	"The normal color of the tile, stored with the tile"
	| deselectedColor deselectedBorderColor |

	deselectedColor := self valueOfProperty: #deselectedColor ifAbsent: [nil].
	deselectedBorderColor := self valueOfProperty: #deselectedBorderColor ifAbsent: [nil].
	deselectedColor ifNotNil: [
		deselectedColor := self scaleColorByUserPref: deselectedColor].
	deselectedBorderColor ifNotNil: [
		deselectedBorderColor := self scaleColorByUserPref: deselectedBorderColor].
	self 
		color: (deselectedColor ifNil: [Color transparent]);
		borderColor: (deselectedBorderColor ifNil: [Color transparent])
]

{ #category : #'card & stack' }
SyntaxMorph >> setNewContentsFrom: stringOrNumberOrNil [
	"Using stringOrNumberOrNil as a guide, set the receiver's contents afresh.  If the input parameter is nil, the a default value stored in a property of the receiver, if any, will supply the new initial content.  This method is only called when a VariableDock is attempting to put a new value."

	(self readOut ifNil: [^ self]) setNewContentsFrom: stringOrNumberOrNil.
]

{ #category : #selection }
SyntaxMorph >> setSelection: newSpec [ 
	"A selectionSpec is {Inner morph.  Where clicked.  Outer morph}.
	First mouseDown starts a selection (with outerMorph isNil).
	Dragging more than 4 pixels means to grab a copy of the current outer selection.
		The current selection is the outerMorph, or the inner if it is nil.
	Each mouseUp extends the selection to the next outer morph that is selectable.
		Except if this is the first click."

	| rootTile |
	(rootTile := self rootTile) valueOfProperty: #selectionSpec
		ifPresentDo: [:oldSpec | oldSpec third ifNotNil: [:m | m deselect]].
	(newSpec isNil or: [newSpec third isNil and: [self isMethodNode]]) 
		ifTrue: 
			[self deselect.
			^rootTile removeProperty: #selectionSpec].

	"Select outer morph of the new selection"
	newSpec third isNil 
		ifTrue: [self select	"first click down"]
		ifFalse: [newSpec third select	"subsequent clicks"].
	rootTile setProperty: #selectionSpec toValue: newSpec
]

{ #category : #'pop ups' }
SyntaxMorph >> setSelector: stringLike in: stringMorph [
	"Store the new selector and accept method."

	| aSymbol myType str |
	aSymbol := stringLike asSymbol.
	(ScriptingSystem helpStringOrNilFor: aSymbol) ifNotNil:
		[:aString |
			self setBalloonText: aString translated].
	myType := stringMorph valueOfProperty: #syntacticReformatting ifAbsent: [#none].
	str := aSymbol.
	(self isStandardSetterKeyword: str) ifTrue: [str := self translateToWordySetter: str].
	(self isStandardGetterSelector: str) ifTrue: [str := self translateToWordyGetter: str].
	(self shouldBeBrokenIntoWords: myType) 
		ifTrue: [str := self substituteKeywordFor: str].
	stringMorph contents: str.
	"parseNode key: aSymbol code: nil."
	str = stringLike ifFalse:
		[stringMorph setProperty: #syntacticallyCorrectContents toValue: aSymbol].
	self acceptSilently
]

{ #category : #'alans styles' }
SyntaxMorph >> setSpecialOuterTestFormat [

	self 
		specialColor: self darkerColor 
		andBorder: self lighterColor.
	self useRoundedCorners.
	self layoutInset: 1.
	"self setProperty: #variableInsetSize toValue: 6."

]

{ #category : #'alans styles' }
SyntaxMorph >> setSpecialTempDeclarationFormat1 [

	"the outer template for temp defs"

	self 
		specialColor: self darkerColor 
		andBorder: self lighterColor.
	"self 
		specialColor: (Color lightYellow) 
		andBorder: (Color r: 0.581 g: 0.774 b: 0.903)."
	self useRoundedCorners.
	self layoutInset: 1.
	self cellPositioning: #center.
	"self setProperty: #variableInsetSize toValue: 6."

]

{ #category : #'alans styles' }
SyntaxMorph >> setSpecialTempDeclarationFormat2 [

	"the inner template for temp defs"

	self 
		specialColor: self lighterColor 
		andBorder:  self darkerColor.
	"self 
		specialColor: (Color r: 1.0 g: 1.0 b: 0.548) 
		andBorder:  (Color r: 0.581 g: 0.774 b: 0.903)."
	self useRoundedCorners.
	self layoutInset: 1.
	"self setProperty: #variableInsetSize toValue: 6."

]

{ #category : #'card & stack' }
SyntaxMorph >> setTarget: aPlayer [
	"Find my UpdatingStringMorph and set its getSelector, putSelector, and target"

	| updatingString |
	(updatingString := self readOut) ifNil: [^ self].
	updatingString putSelector: (self knownName asSetterSelector).
	updatingString getSelector: (self knownName asGetterSelector).
	updatingString target: aPlayer. 
]

{ #category : #'alans styles' }
SyntaxMorph >> shouldBeBrokenIntoWords: aSymbol [

	^#(methodHeader1 methodHeader2 keyword2 upArrow 
		tempVariable tempVariableDeclaration blockarg2 variable
		keywordGetz keywordSetter unaryGetter
		assignmentArrow) includes: aSymbol
]

{ #category : #menus }
SyntaxMorph >> showCode [
	"Turn my current state into the text of a method.  Put it in a window."

	(Workspace new contents: self rootTile decompile) openLabel: self printString,' code'

	

]

{ #category : #menus }
SyntaxMorph >> showMenu: evt [
	| menu |
	menu := MenuMorph new.
	self rootTile isMethodNode ifTrue:
		[menu add: 'accept method' target: self selector: #accept.
		menu addLine.

		menu add: 'new temp variable' target: self selector: #attachTileForCode:nodeType: 
					argumentList: {'| temp | temp'. TempVariableNode}.
		menu addLine.

		self parsedInClass allInstVarNames do: [:nn |
			menu add: nn,' tile' target: self selector: #instVarTile: argument: nn].
		menu addLine.

		menu add: 'show code' target: self selector: #showCode.
		menu add: 'try out' target: self selector: #try.
		menu popUpAt: evt hand position forHand: evt hand in: self world].




]

{ #category : #'alans styles' }
SyntaxMorph >> specialColor: c1 andBorder: c2 [

	self color: (self scaleColorByUserPref: c1).
	self setProperty: #deselectedColor toValue: c1.
	self borderColor: (self scaleColorByUserPref: c2).
	self setProperty: #deselectedBorderColor toValue: c2.

]

{ #category : #'alans styles' }
SyntaxMorph >> splitAtCapsAndDownshifted: aString [

	self flag: #yoCharCases.

	^String streamContents: [ :strm |
		aString do: [ :each | 
			each = $: ifFalse: [
				each isUppercase ifTrue: [strm nextPut: Character null;  
						 	nextPut: Character null; 
						 	nextPut: Character null; 
							nextPut: each asLowercase]
					ifFalse: [strm nextPut: each]
			].
		]
	].
]

{ #category : #'alans styles' }
SyntaxMorph >> standardCellPositioning [

	^ self alansTest1 ifTrue: [#leftCenter] ifFalse: [#topLeft]
]

{ #category : #'alans styles' }
SyntaxMorph >> standardInset [

	parseNode class == BlockNode ifTrue: [^ 5 @ 1].
		"allow pointing beside a line so can replace it"
	^ self alansTest1 ifTrue: [1] ifFalse: [-1]
]

{ #category : #highlighting }
SyntaxMorph >> stdBorderColor [ 

	"put choices of how to do the border here"
	^ self valueOfProperty: #deselectedBorderColor ifAbsent: [Color transparent]
]

{ #category : #'stepping and presenter' }
SyntaxMorph >> step [
	super step.
	self isBlockNode ifTrue: [self trackDropZones].

]

{ #category : #testing }
SyntaxMorph >> stepTime [

	^ 50
]

{ #category : #'new tiles' }
SyntaxMorph >> string: anExpression toTilesIn: playerClass [
	| code tree methodNode |
	"Construct SyntaxMorph tiles for some code.  Returns the main BlockNode of a doIt."

	"This is really cheating!  Make a true parse tree later. -tk"
	code := String streamContents: [:strm | 
		strm nextPutAll: 'doIt'; cr; tab; nextPutAll: anExpression].
	"decompile to tiles"
	tree := Compiler new 
		parse: code 
		in: playerClass
		notifying: nil.
	methodNode := tree asMorphicSyntaxUsing: SyntaxMorph.
	anExpression first == $" ifTrue: ["a comment" 
		"(methodNode findA: CommentNode) firstSubmorph color: Color blue."
		^ methodNode].
	^ methodNode submorphs detect: [:mm | 
		(mm respondsTo: #parseNode) 
			ifTrue: [mm parseNode class == BlockNode] 
			ifFalse: [false]].

]

{ #category : #printing }
SyntaxMorph >> structure [
	"Print my structure from inner to outer."
	^ String streamContents: [:s |
		self withAllOwnersDo:
			[:m | m isSyntaxMorph ifTrue:
				[s cr; print: m parseNode class.
				((m nodeClassIs: MessageNode) or: [m nodeClassIs: TileMessageNode]) ifTrue:
					[s space; nextPutAll: m parseNode selector key]]]]
]

{ #category : #'dropping\/grabbing' }
SyntaxMorph >> structureMatchWith: aMorph [
	| meNoun itNoun |
	"Return true if the node types would allow aMorph to replace me.  This tests the gross structure of the method only."

	meNoun := self isNoun.
	itNoun := aMorph isNoun.

	"Consider these nouns to be equal:  TempVariableNode, LiteralNode, VariableNode, (MessageNode with receiver), CascadeNode, AssignmentNode"
	meNoun & itNoun ifTrue: [^ true].
	meNoun & aMorph isBlockNode ifTrue: [^ true].

	"If I am a BlockNode, and it is a TempVariableNode, add it into list"
	"If I am a BlockNode, and it is a noun, add it as a new line"
	self isBlockNode ifTrue:
		[itNoun ifTrue: [^ true].
		(aMorph nodeClassIs: ReturnNode) ifTrue:
			[^ self submorphs
				noneSatisfy: [:mm | (mm isSyntaxMorph) and: [mm nodeClassIs: ReturnNode]]].	"none already in this block"
				"If I am a BlockNode, and it is a ReturnNode, add to end"
		(aMorph nodeClassIs: CommentNode) ifTrue: [^ true]].

	(self isMethodNode) ifTrue: [^ false].	"Later add args and keywords"
		"Later allow comments to be dropped in"
		"Add MethodTemps by dropping into the main block"

	(self nodeClassIs: ReturnNode) & (aMorph parseNode class == MessageNode) 
		ifTrue: [^ true].		"Command replace Return"
	(self nodeClassIs: MessageNode) & (aMorph parseNode class == ReturnNode) ifTrue: [
		(owner submorphs select: [:ss | ss isSyntaxMorph]) last == self
			ifTrue: [^ true]].	"Return replace last command"

	(aMorph nodeClassIs: AssignmentNode) ifTrue: [
		itNoun ifFalse: ["create a new assignment"
			^ self isAVariable & self isDeclaration not]].	"only assign to a variable"

	"If nodes are of equal class, replace me with new one."
	(self nodeClassIs: aMorph parseNode class) ifTrue: [
		(self nodeClassIs: MessageNode) 
				ifFalse: [^ true]	"normal match"
				ifTrue: [^ self receiverNode == aMorph receiverNode]].	"both nil"

	^ false "otherwise reject"
]

{ #category : #printing }
SyntaxMorph >> submorphsDoIfSyntax: block1 ifString: block2 [ 

	^self submorphsDoIfSyntax: block1 ifString: block2 otherwise: [ :sub | ]

]

{ #category : #printing }
SyntaxMorph >> submorphsDoIfSyntax: block1 ifString: block2 otherwise: block3 [ 
	submorphs do: 
			[:sub | 
			sub isSyntaxMorph 
				ifTrue: [block1 value: sub]
				ifFalse: 
					[(sub isKindOf: StringMorph) 
						ifTrue: [block2 value: sub]
						ifFalse: 
							[(sub isTextMorph) 
								ifTrue: [block2 value: sub]
								ifFalse: [block3 value: sub]]]]
]

{ #category : #'alans styles' }
SyntaxMorph >> substituteKeywordFor: aString [

	aString isEmpty ifTrue: [^aString asString].
	aString asString = '^ ' ifTrue: [^'answer'].
	aString asString = 'ifTrue:' ifTrue: [^'Yes'].
	aString asString = 'ifFalse:' ifTrue: [^'No'].
	aString asString = 'self' ifTrue: [^'self'].
	aString first isUppercase ifTrue: [^aString asString].

	^self splitAtCapsAndDownshifted: aString
]

{ #category : #scripting }
SyntaxMorph >> tearOffTile [
	"For a SyntaxMorph, this means give a copy of me"

	| dup |
	dup := self duplicate.
	self currentHand attachMorph: dup.
	^ Preferences tileTranslucentDrag
		ifTrue: [dup lookTranslucent]
		ifFalse: [dup align: dup topLeft with: self currentHand position + self cursorBaseOffset]
]

{ #category : #layout }
SyntaxMorph >> tempVarNodesDo: aBlock [
	"Execute the block for any block temporary variables, method temps, or method args we have"

	| tempHolder argsHolder |
	((self parseNode class == MethodNode) or: [self parseNode class == BlockNode]) ifTrue: [
		self submorphsDoIfSyntax: [:sub | 
				(sub nodeClassIs: MethodTempsNode) ifTrue: [tempHolder := sub].
				((sub nodeClassIs: UndefinedObject) and: [tempHolder isNil]) ifTrue: [
					tempHolder := sub findA: MethodTempsNode].
				(sub nodeClassIs: BlockArgsNode) ifTrue: [tempHolder := sub].
				(sub nodeClassIs: SelectorNode) ifTrue: [argsHolder := sub].
				]
			ifString: [:sub | ].
		tempHolder ifNotNil: ["Temp variables"
			tempHolder submorphsDoIfSyntax: [:sm | 
					(sm nodeClassIs: TempVariableNode) ifTrue: [aBlock value: sm]]
				ifString: [:sm | ]].
		argsHolder ifNotNil: ["arguments"
			argsHolder submorphsDoIfSyntax: [:sm | 
					(sm nodeClassIs: TempVariableNode) ifTrue: [aBlock value: sm]]
				ifString: [:sm | ]].
		].
	"otherwise do nothing"
]

{ #category : #tests }
SyntaxMorph >> test [
	3 > 4 ifTrue: [].
	^ self
]

{ #category : #tests }
SyntaxMorph >> testForNode: targetNode andDo: aBlock [ 
	targetNode == parseNode ifTrue: [aBlock value: self].
	self submorphsDo: 
			[:each | 
			(each isSyntaxMorph) 
				ifTrue: [each testForNode: targetNode andDo: aBlock]]
]

{ #category : #tests }
SyntaxMorph >> toDo [
"
Biggies...
[ ]	Integrate with EToy scriptors
	releaseCachedState can discard all morphic structure.

[ ]	Options:
	Show / hide syntax markers (like [], (), ., :, ;, etc)
	No color / color-in-focus / full color
	Tiles / textiles / text

[ ]	ParsedTextMorph -- looks like text but has all same substructure

[ ]	Introduce notion of an UnParsedNode -- maybe a flag in ParseNode
	Text -> UnParsed -> Parsed -> CodeGen

[ ]	Need DnD evaluator, or some sort of '!' button on any entity (halo?)
	Also inspector / browser

[ ]	All the type help we can get

Details ...
[ ]	Open up the parse of BraceNodes

[ ]	Verify that all pastes are OK

[ ]	Colors not yet right for colored version.

[ ]	Start work on show / hide of syntax markers -- (), [], etc.

[ ]	Start work on textiles (grabable entites in 'normal' text)

[ ]	Need autoscroll during drag for drop

[ ]	Use, eg, shift-drag to move, del to delete

[ ]	What about invalid drops -- stick on cursor?

System...
[ ]	Only keep history 7 deep; option to clear on quit
	clear command above spaceLeft

[ ]	Compute each page of prefs viewer on demand instead of as now.

[ ]	Offer a search command that will gather up all preferences that match a given string (name or help string)

Preferences enable: #noTileColor.
Preferences disable: #noTileColor.
Smalltalk browseAllSelect: [:cm | cm size > 600]
SyntaxMorph testAll
"
]

{ #category : #'alans styles' }
SyntaxMorph >> tokenVerticalSeparator [

	^Morph new 
		color: Color transparent;
		extent: 3@3;
		lock

]

{ #category : #'pop ups' }
SyntaxMorph >> tossOutArg: extras [

	"Remove the tiles for the last N keywords and arguments.  Place the tiles beside the current window.  I am a SyntaxMorph for a MessageNode."

	| cnt |
	cnt := 0.
	 submorphs copy reverseDo: [:sub | | ctr |
		ctr := sub fullBoundsInWorld center.
		sub delete.
		(sub isSyntaxMorph and: [sub parseNode notNil]) ifTrue: [
			sub isNoun ifTrue: [
				self pasteUpMorph addMorphFront: sub.
				sub position: self enclosingPane fullBoundsInWorld right - 20 @ ctr y].
			(cnt := cnt + 1) >= extras ifTrue: [^ self]]].
]

{ #category : #'insertion drop zones' }
SyntaxMorph >> trackDropZones [
	| hand i localPt insertion insHt ii prevBot nxtHt d c1 c2 ht2 spacer1 spacer2 wid ht1 dc each |
	hand := self primaryHand.
	("hand lastEvent redButtonPressed &" hand hasSubmorphs
		and: [(self hasOwner: hand) not]) ifFalse: [^ self].

	insertion := hand firstSubmorph renderedMorph.
	insertion isSyntaxMorph ifFalse: [^ self].
	insertion isNoun ifFalse: [(insertion nodeClassIs: CommentNode) ifFalse: [^ self]].
	localPt := self globalPointToLocal: hand position.
	insHt := insertion height.  "**just use standard line height here"
	self removeDropZones.  "Maybe first check if in right place, then just tweak heights."
	i := (ii := self indexOfMorphAbove: localPt) min: submorphs size-1.
	prevBot := i <= 0 ifTrue: [(self innerBounds) top]
					ifFalse: [(self submorphs at: i) bottom].
	nxtHt := (submorphs isEmpty
		ifTrue: [insertion]
		ifFalse: [self submorphs at: i+1]) height.
	d := ii > i ifTrue: [nxtHt "for consistent behavior at bottom"]
			ifFalse: [0 max: (localPt y - prevBot min: nxtHt)].

	"Top and bottom spacer heights cause continuous motion..."
	c1 := Color transparent.  c2 := Color transparent.
	ht2 := d*insHt//nxtHt.  ht1 := insHt - ht2.
	wid := self width - (2*self borderWidth) - (2*self layoutInset).
	wid isPoint ifTrue: [wid := wid x].
	(spacer1 := BorderedMorph newBounds: (0@0 extent: wid@ht1)
				color: (ht1 > (insHt//2) ifTrue: [c1] ifFalse: [c2]))
					borderWidth: 1; borderColor: spacer1 color.
	self privateAddMorph: spacer1 atIndex: (i+1 max: 1).
	(spacer2 := BorderedMorph newBounds: (0@0 extent: wid@ht2)
				color: (ht2 > (insHt//2+1) ifTrue: [c1] ifFalse: [c2]))
					borderWidth: 1; borderColor: spacer2 color.
	spacer1 setProperty: #dropZone toValue: true.
	spacer2 setProperty: #dropZone toValue: true.
	self privateAddMorph: spacer2 atIndex: (i+3 min: submorphs size+1).
	self fullBounds.  "Force layout prior to testing for cursor containment"

	"Maintain the drop target highlight -- highlight spacer if hand is in it."
	{spacer1. spacer2} do:
		[:spacer | (spacer containsPoint: localPt) ifTrue:
			[spacer color: self dropColor.
			"Ignore border color.  Maybe do it later.
			self borderColor = self dropColor
				ifTrue: [self borderColor: self stdBorderColor]"]].
	"If no submorph (incl spacers) highlighted, then re-highlight the block."
	"Ignore border color.  Maybe do it later.
	((self wantsDroppedMorph: insertion event: hand lastEvent) and:
		[(self submorphs anySatisfy: [:m | m containsPoint: localPt]) not])
			ifTrue: [self borderColor: self dropColor].
	"

	"Dragging a tile within a Block, if beside a tile, color it a dropzone"
	"Transcript show: localPt y printString; space; show: submorphs first top 
		printString; space; show: submorphs last top printString; cr."
	dc := self dropColor.
	1 to: ((ii+4 min: submorphs size) max: 1) do: [:ind | 
		each := submorphs at: ind.
		each isSyntaxMorph ifTrue: [
			localPt y >= each top 
				ifTrue: ["in this one or beyond"
					(localPt y < each bottom) 
						ifTrue: [(each submorphs anySatisfy: [:m | 
								m containsPoint: localPt])
							ifTrue: [each setDeselectedColor]
							ifFalse: [each color: dc]]
						ifFalse: [each color = dc ifTrue: [each setDeselectedColor]]]
				ifFalse: [each color = dc ifTrue: [each setDeselectedColor]]]].

]

{ #category : #'alans styles' }
SyntaxMorph >> translateFromWordySelfVariant: key [

	#selfWrittenAsMe == key ifTrue: [^'me'].
	#selfWrittenAsMy == key ifTrue: [^'my'].
	#selfWrittenAsIll == key ifTrue: [^'I''ll'].
	#selfWrittenAsIm == key ifTrue: [^'I''m'].
	#selfWrittenAsThis == key ifTrue: [^'this'].
	^nil


]

{ #category : #'alans styles' }
SyntaxMorph >> translateToWordyGetter: key [
	"  setBlob:  becomes  's blob :=  "

	^ '''s ', 
	  (self splitAtCapsAndDownshifted: (key asString allButFirst: 3) 
			withFirstCharacterDownshifted)
]

{ #category : #'alans styles' }
SyntaxMorph >> translateToWordySelfVariant: aString [

	| lc |
	lc := aString asLowercase.
	lc = 'me' ifTrue: [^#selfWrittenAsMe].
	lc = 'my' ifTrue: [^#selfWrittenAsMy].
	lc = 'i''ll' ifTrue: [^#selfWrittenAsIll].
	lc = 'i''m' ifTrue: [^#selfWrittenAsIm].
	lc = 'this' ifTrue: [^#selfWrittenAsThis].
	^nil


]

{ #category : #'alans styles' }
SyntaxMorph >> translateToWordySetter: key [
	"  setBlob:  becomes  's blob :=  "

	^ '''s ', 
	  (self splitAtCapsAndDownshifted: (key asString allButFirst: 3) allButLast 
			withFirstCharacterDownshifted), 
	  ' _'
]

{ #category : #layout }
SyntaxMorph >> try [
	"Evaluate me once"

	(#(MessageNode LiteralNode VariableNode) includes: parseNode class name) 
		ifFalse: [^ Error new].
	^ [Compiler evaluate: self decompile
				for: self actualObject.	"should do something to the player"
		] ifError: [ :a :b | Error new].
]

{ #category : #accessing }
SyntaxMorph >> unSpaceAndUpShift: aString appending: extraChars [ 
	| answer upShiftNext |
	answer := WriteStream on: String new.
	upShiftNext := false.
	aString do: 
			[:ch | 
			upShiftNext :=( ch == Character space) 
				ifTrue: [ true]
				ifFalse: 
					[answer nextPut: (upShiftNext ifTrue: [ch asUppercase] ifFalse: [ch]).
					 false]].
	answer := answer contents.
	extraChars isEmptyOrNil ifTrue: [^answer].
	(answer endsWith: extraChars) ifFalse: [answer := answer , extraChars].
	^answer
]

{ #category : #layout }
SyntaxMorph >> unfoldMessage [
	"I am a message whose message part is a column.
	Rearrange me so that the entire message is one row."
	| messageRow |
	messageRow := self submorphs last.
	self removeMorph: messageRow.
	messageRow submorphs do: [:m | self addMorphBack: m].


]

{ #category : #highlighting }
SyntaxMorph >> unhighlight [

	self setDeselectedColor.
]

{ #category : #highlighting }
SyntaxMorph >> unhighlightBorder [

	self currentSelectionDo: [:innerMorph :mouseDownLoc :outerMorph |
		(self == outerMorph or: [owner notNil and: [owner isSyntaxMorph not]])
			ifFalse: [self borderColor: self stdBorderColor]
			ifTrue: [
				(self hasProperty: #deselectedBorderColor)
					ifTrue: [self borderColor: (self valueOfProperty: #deselectedBorderColor)]
					ifFalse: [self borderStyle: (BorderStyle raised width: self borderWidth)]] ].
]

{ #category : #highlighting }
SyntaxMorph >> unhighlightOwner [
	"Unhighlight my owner"

	(owner notNil and: [owner isSyntaxMorph]) ifTrue: [owner unhighlight]
]

{ #category : #highlighting }
SyntaxMorph >> unhighlightOwnerBorder [
	"Unhighlight my owner's border"

	(owner notNil and: [owner isSyntaxMorph]) 
		ifTrue: [owner unhighlightBorder]
]

{ #category : #'pop ups' }
SyntaxMorph >> upDown: delta event: evt arrow: arrowMorph [

	| st |
	st := submorphs detect: [:mm | mm isKindOf: StringMorph] ifNone: [^ self].
	(self nodeClassIs: LiteralNode) ifTrue:
		[ "+/- 1"
		st contents: (self decompile asNumber + delta) printString.
		^ self acceptUnlogged].
	(self nodeClassIs: VariableNode) ifTrue:
		[ "true/false"
		st contents: (self decompile string = 'true') not printString.
		^ self acceptSilently ifFalse: [self changed].
			"maybe set parseNode's key"].

	(self upDownArithOp: delta) ifTrue: [^ self].	"+ - // *   < > <= =   beep:"

	(self upDownAssignment: delta) ifTrue: [^ self].
		"Handle assignment --  increaseBy:  <-   multiplyBy:"

]

{ #category : #'pop ups' }
SyntaxMorph >> upDownArithOp: delta [
	"Change a + into a -.  Also do sounds (change the arg to the beep:)."

	| aList index st |
	st := submorphs detect: [:mm | mm isKindOf: StringMorph] ifNone: [^ self].
	(self nodeClassIs: SelectorNode) ifTrue:
		[aList := #(+ - * / // \\ min: max:).
		(index := aList indexOf: self decompile asString) > 0 ifTrue:
			[self setSelector: (aList atWrap: index + delta) in: st.  ^ true].

		aList := #(= ~= > >= isDivisibleBy: < <=).
		(index := aList indexOf: self decompile asString) > 0 ifTrue:
			[self setSelector: (aList atWrap: index + delta) in: st.  ^ true].

		aList := #(== ~~).
		(index := aList indexOf: self decompile asString) > 0 ifTrue:
			[self setSelector: (aList atWrap: index + delta) in: st.  ^ true].

		'beep:' = self decompile asString ifTrue:
			["replace sound arg"
			self changeSound: delta.
			self acceptSilently.  ^ true].
		].
	^ false
]

{ #category : #'pop ups' }
SyntaxMorph >> upDownArrows [
	"Return an array of two up/down arrow buttons.
	It replaces the selector or arg with a new one.
	I am a number or boolean or a selector (beep:, +,-,*,//,\\, or setX: incX: decX: for any X."
	| patch any noMenu |
	any := (self nodeClassIs: LiteralNode) and: [parseNode key isNumber].
	any := any or: [(self nodeClassIs: VariableNode) and:
						[(#('true' 'false') includes: self decompile asString)]].
	noMenu := any.

	any := any or: [self nodeClassIs: SelectorNode].	"arrows and menu of selectors"
	any := any or: [self nodeClassIs: KeyWordNode].
	any ifFalse: [^ nil].

	patch := {(ImageMorph new image: TileMorph upPicture)
				on: #mouseDown send: #upDown:event:arrow: to: self withValue: 1;
				on: #mouseStillDown send: #upDownMore:event:arrow: 
					to: self withValue: 1;
				on: #mouseUp send: #upDownDone to: self.
			(ImageMorph new image: TileMorph downPicture)
				on: #mouseDown send: #upDown:event:arrow: to: self withValue: -1;
				on: #mouseStillDown send: #upDownMore:event:arrow: 
					to: self withValue: -1;
				on: #mouseUp send: #upDownDone to: self}.
	noMenu ifFalse: [patch := patch, {(RectangleMorph new)
						extent: 6@10; borderWidth: 1;
						borderColor: Color gray;
						on: #mouseUp send: #selectorMenu to: self}.
					patch last color: ((self nodeClassIs: SelectorNode) 
						ifTrue: [Color lightGreen] ifFalse: [Color red darker])].
	^ patch
]

{ #category : #'pop ups' }
SyntaxMorph >> upDownAssignment: delta [
	"Rotate between increaseBy:  decreaseBy:   :=  multiplyBy:"

	| st now want instVar |
	st := submorphs detect: [:mm | mm isKindOf: StringMorph] ifNone: [^ self].
	(self nodeClassIs: SelectorNode) ifTrue:
		["kinds of assignment"
		((now := self decompile asString) beginsWith: 'set') ifTrue:
			["a setX: 3"
			want := 1+delta.  instVar := (now allButFirst: 3) allButLast].
		(now endsWith: 'IncreaseBy:') ifTrue:
			["a xIncreaseBy: 3 a setX: (a getX +3)."
			want := 2+delta.  instVar := now allButLast: 11].
		(now endsWith: 'DecreaseBy:') ifTrue:
			["a xDecreaseBy: 3 a setX: (a getX -3)."
			want := 3+delta.  instVar := now allButLast: 11].
		(now endsWith: 'MultiplyBy:') ifTrue:
			["a xMultiplyBy: 3 a setX: (a getX *3)."
			want := 4+delta.  instVar := now allButLast: 11].
		want ifNil: [^ false].
		instVar := instVar asLowercase.
		want := #(1 2 3 4) atWrap: want.
		want = 1 ifTrue:
			["setter method is present"
			self setSelector: ('set', instVar capitalized, ':') in: st.  ^ true].
		want = 2 ifTrue:
			["notUnderstood will create the method if needed"
			self setSelector: instVar, 'IncreaseBy:' in: st.  ^ true].
		want = 3 ifTrue:
			["notUnderstood will create the method if needed"
			self setSelector: instVar, 'DecreaseBy:' in: st.  ^ true].
		want = 4 ifTrue:
			["notUnderstood will create the method if needed"
			self setSelector: instVar, 'MultiplyBy:' in: st.  ^ true].
		].
	^ false

]

{ #category : #'pop ups' }
SyntaxMorph >> upDownDone [

	(self nodeClassIs: LiteralNode) ifTrue:
		[self acceptSilently.  "Final compilation logs source"
		self removeProperty: #timeOfLastTick;
			removeProperty: #currentDelay].

]

{ #category : #'pop ups' }
SyntaxMorph >> upDownMore: delta event: evt arrow: arrowMorph [

	| st delay1 delay2 now timeOfLastTick currentDelay |
	(self nodeClassIs: LiteralNode) ifFalse: [^ self].
	st := submorphs detect: [:mm | mm isKindOf: StringMorph] ifNone: [^ self].
	delay1 := 300.  "ms"
	delay2 := 50.  "ms"
	now := Time millisecondClockValue.
	timeOfLastTick := (self valueOfProperty: #timeOfLastTick) ifNil: [now - delay1].
	currentDelay := (self valueOfProperty: #currentDelay) ifNil: [delay1].
	now >= (timeOfLastTick + currentDelay) ifTrue:
		[self setProperty: #timeOfLastTick toValue: now.
		"decrease the delay"
		self setProperty: #currentDelay toValue: (currentDelay*8//10 max: delay2).
		st contents: (self decompile asNumber + delta) printString.
		^ self acceptUnlogged].

]

{ #category : #updating }
SyntaxMorph >> update: aSymbol [

	| bingo saveOwner newMorph db |

	(db := self debugger) ifNil: [^super update: aSymbol].
	aSymbol == #contents ifTrue: [
		saveOwner := owner.
		db removeDependent: self.
		markerMorph ifNotNil: [markerMorph delete. markerMorph := nil].
		newMorph := db createSyntaxMorph.
		self delete.
		saveOwner addMorph: newMorph.
		saveOwner owner setScrollDeltas.
		newMorph update: #contentsSelection.
	].
	aSymbol == #contentsSelection ifTrue: [
		markerMorph ifNil: [
			markerMorph := RectangleMorph new.
			markerMorph
				color: Color transparent;
				borderWidth: 2;
				borderColor: Color red;
				lock.
			owner addMorphFront: markerMorph.
		].
		bingo := parseNode rawSourceRanges keyAtValue: db pcRange ifAbsent: [nil].
		self testForNode: bingo andDo: [ :foundMorph | 
			markerMorph
				position: foundMorph position;
				extent: foundMorph extent.
			owner owner scrollIntoView: foundMorph bounds extra: 0.5.
			^self
		].
	].
	super update: aSymbol
]

{ #category : #accessing }
SyntaxMorph >> userScriptSelector [
	"user wrote this script"

	^ self valueOfProperty: #userScriptSelector
]

{ #category : #accessing }
SyntaxMorph >> userScriptSelector: sel [
	"user wrote this script"

	self setProperty: #userScriptSelector toValue: sel.
]

{ #category : #'formatting options' }
SyntaxMorph >> usingClassicTiles [ 

	^ Preferences uniTilesClassic
]

{ #category : #'node to morph' }
SyntaxMorph >> vanillaMessageNode: aNode receiver: receiver selector: selector arguments: arguments [

	| substitute row sel |
	sel := #message.
	((self nodeClassIs: CascadeNode) and: [self parseNode receiver ~~ aNode]) ifTrue: [
		sel := #keyword2.
		receiver ifNotNil: [self inform: 'receiver should be nil']].
	row := self addRow: sel on: aNode.
	substitute := aNode as: TileMessageNode.
	(aNode macroPrinter == #printCaseOn:indent:) ifTrue: [
		aNode asMorphicCaseOn: row indent: nil.
		^ self].
	aNode macroPrinter
		ifNotNil: 
			[substitute perform: aNode macroPrinter with: row with: nil]
		ifNil: 
			[substitute 
				printKeywords: selector key
				arguments: arguments
				on: row
				indent: nil].
	^ row addTransparentSpacerOfSize: 3@0.	"horizontal spacing only"

]

{ #category : #player }
SyntaxMorph >> variableDocks [
	"Answer a list of VariableDock objects for docking up my data with an instance held in my containing playfield.  For a numeric-readout tile."

	"Is CardPlayer class holding my variableDock, or should I be using the caching mechanism in Morph>>variableDocks?"
	| updatingString lab nn aGetter |
	(updatingString := self readOut) ifNil: [^ #()].
	updatingString getSelector ifNil: [
		lab := self submorphNamed: 'label' ifNone: [self defaultName].
		nn := lab contents asString.
		"nn at: 1 put: nn first asUppercase."
		updatingString getSelector: (aGetter := 'get',nn) asSymbol;
			putSelector: (ScriptingSystem setterSelectorForGetter: aGetter).
		].
	^ Array with: (VariableDock new 
			variableName: (updatingString getSelector allButFirst: 3) withFirstCharacterDownshifted 
			type: #number 
			definingMorph: updatingString 
			morphGetSelector: #valueFromContents 
			morphPutSelector: #acceptValue:)
]

{ #category : #vocabulary }
SyntaxMorph >> vocabularyToUseWith: aValue [ 
	"Answer a vocabulary to use with the given value"

	(aValue isNumber) ifTrue: [^Vocabulary numberVocabulary].
	(aValue isKindOf: Time) ifTrue: [^Vocabulary vocabularyForClass: Time].
	(aValue isString) ifTrue: [^Vocabulary vocabularyForClass: String].
	aValue class isUniClass ifTrue: [^Vocabulary eToyVocabulary].
	^self currentVocabulary
]

{ #category : #'dropping\/grabbing' }
SyntaxMorph >> wantsDroppedMorph: aMorph event: evt [ 
	"For the moment, you have to drop it the right place.  We do not look at enclosing morphs"

	"Two ways to do this:  Must always destroy old node, then drag in new one.
		Or, drop replaces what you drop on.  Nasty with blocks."

	(aMorph isSyntaxMorph) ifFalse: [^false].
	(self structureMatchWith: aMorph) ifFalse: [^false].	"gross structure"

	"Only look at types if NoviceMode -- building EToys"
	^self okToBeReplacedBy: aMorph	"test the types"

	"^ true"
]

{ #category : #'event handling' }
SyntaxMorph >> wantsKeyboardFocusFor: aSubmorph [
	| doEdit |
	"only let strings edit on shift-click.  Editing on ordinary click defeats the brown selection and tile dragging."

	doEdit := self world primaryHand lastEvent shiftPressed.
	doEdit ifTrue: ["remove the arrows during editing"
		self valueOfProperty: #myPopup ifPresentDo: [:panel |
			panel delete. self removeProperty: #myPopup]].
	^ doEdit
]

{ #category : #testing }
SyntaxMorph >> wantsSteps [
	"Only step this morph if we explicitly send startStepping"

	^ false
]
