"
ObjectExplorer provides a hierarchical alternative to #inspect. Simply evaluate an expression like:

World explore

and enjoy.
"
Class {
	#name : #ObjectExplorer,
	#superclass : #AbstractHierarchicalList,
	#instVars : [
		'root',
		'currentParent',
		'inspector',
		'monitorList',
		'expression'
	],
	#category : #'Tools-Explorer'
}

{ #category : #defaults }
ObjectExplorer class >> about [

	StringHolder new textContents: self comment; openLabel: 'about ',self asString
]

{ #category : #'instance creation' }
ObjectExplorer class >> explore: anObject [

	^ self new explore: anObject
]

{ #category : #defaults }
ObjectExplorer class >> nodeClass [

	^ ObjectExplorerWrapper
]

{ #category : #'instance creation' }
ObjectExplorer class >> openOn: anObject [

	^ ToolBuilder open: (self explore: anObject)
]

{ #category : #'instance creation' }
ObjectExplorer class >> openOn: anObject withLabel: label [ 
     "ObjectExplorer openOn: Smalltalk withLabel: 'Smalltalk'"

	^ ToolBuilder open: (self explore: anObject) label: label
]

{ #category : #styling }
ObjectExplorer >> aboutToStyle: aStyler [

	aStyler
		classOrMetaClass: self object class;
		parseAMethod: false.
	^true
	
]

{ #category : #'menus - actions' }
ObjectExplorer >> browseClassHierarchy [
	"Create and schedule a class list browser on the receiver's hierarchy."

	self systemNavigation
		spawnHierarchyForClass: self selectedClass
		selector: nil.
]

{ #category : #'menus - actions' }
ObjectExplorer >> browseClassRefs [

	self selectedClass ifNotNil: [:cls |
		cls isTrait ifFalse: [self systemNavigation browseAllCallsOnClass: cls]]
]

{ #category : #'menus - actions' }
ObjectExplorer >> browseFull [

	^ self selectedClass ifNotNil: [:cls | ToolSet browseClass: cls]
]

{ #category : #'menus - actions' }
ObjectExplorer >> browseVariableAssignments [

	(self selectedClass notNil and: [self selectedClass isTrait not])
		ifTrue: [self systemNavigation browseVariableAssignments: self selectedClass].
]

{ #category : #'menus - actions' }
ObjectExplorer >> browseVariableReferences [

	(self selectedClass notNil and: [self selectedClass isTrait not])
		ifTrue: [self systemNavigation browseVariableReferences: self selectedClass].
]

{ #category : #toolbuilder }
ObjectExplorer >> buildWith: builder [

	| windowSpec treeSpec textSpec buttonSpec buttonOffset tool |
	windowSpec := builder pluggableWindowSpec new.
	windowSpec
		model: self;
		children: OrderedCollection new;
		label: #label;
		extent: self initialExtent.
	
	treeSpec := builder pluggableTreeSpec new.
	treeSpec
		model: self;
		nodeClass: self class nodeClass;
		roots: #getList;
		keyPress: #explorerKey:from:event:;
		getSelected: #currentSelection;
		setSelected: #currentSelection:;
		setSelectedParent: #currentParent:;
		menu: #genericMenu:;
		dragItem: #getDragItem:;
		autoDeselect: false;
		columns: (ObjectExplorerWrapper showContentsInColumns
			ifTrue: [{
				[:listMorph | (listMorph filteredItems collect: [:item |
					item preferredWidthOfColumn: 1]) max].
				nil "take all the space"}]);
		frame: (0@0 corner: 1@0.71).
	windowSpec children add: treeSpec.

	buttonOffset := (Preferences standardButtonFont widthOfString: 'inspect') * 3/2.

	textSpec := builder pluggableCodePaneSpec new.
	textSpec
		model: self;
		getText: #expression;
		editText: #expression:;
		menu: #codePaneMenu:shifted:;
		help: 'Evaluate expressions for the current tree selection...' translated;
		frame: (LayoutFrame fractions: (0@0.71 corner: 1@1) offsets: (0@0 corner: buttonOffset negated@0)).
	windowSpec children add: textSpec.

	buttonSpec := builder pluggableButtonSpec new
		model: self;
		label: 'inspect';
		action: #inspectObject;
		help: 'Switch to an inspector tool';
		frame: (LayoutFrame fractions: (1@0.71 corner: 1@1) offsets: (buttonOffset negated@0 corner: 0 @ 0)).
	windowSpec children add: buttonSpec.
	
	tool := builder build: windowSpec.
	self changed: #expandRootsRequested.
	^ tool
]

{ #category : #'menus - actions' }
ObjectExplorer >> chasePointersForSelection [
	
	PointerFinder on: self object except: self possibleReferencesToSelection
]

{ #category : #menus }
ObjectExplorer >> codePaneMenu: aMenu shifted: shifted [
	"Note that unless we override perform:orSendTo:, PluggableTextController will respond to all menu items"
	^ StringHolder codePaneMenu: aMenu shifted: shifted

]

{ #category : #'menus - actions' }
ObjectExplorer >> copyName [
	"Copy the name of the current variable, so the user can paste it into the window below and work with it."
	
	Clipboard clipboardText: self currentSelection key.	
]

{ #category : #'menus - actions' }
ObjectExplorer >> copyValue [
	"Copy a description of the value of the current variable, so the user can paste it into the window below and work with it."
	
	Clipboard clipboardText: self currentSelection value asStringOrText.	
]

{ #category : #accessing }
ObjectExplorer >> currentParent [
	^ currentParent
]

{ #category : #accessing }
ObjectExplorer >> currentParent: anObject [
	currentParent := anObject.
]

{ #category : #accessing }
ObjectExplorer >> currentSelection [

	^ currentSelection
]

{ #category : #accessing }
ObjectExplorer >> currentSelection: anObject [

	self currentSelection == anObject ifTrue: [
		self changed: #objectChanged with: anObject.
		^ self].
	
	currentSelection := anObject.
	
	self changed: #currentSelection.
	self changed: #style.
]

{ #category : #'menus - actions' }
ObjectExplorer >> defsOfSelection [
	"Open a browser on all defining references to the selected instance variable, if that's what currently selected. "
	
	self selectedParentClass ifNil: [^ self changed: #flash].
	self selectedParentClass isVariable ifTrue: [^ self changed: #flash].
	self selectedInstVarName ifNil: [^ self changed: #flash].

	self systemNavigation browseAllStoresInto: self selectedInstVarName from: self selectedParentClass.
]

{ #category : #accessing }
ObjectExplorer >> doItContext [
	"Answer the context in which a text selection can be evaluated."

	^nil
]

{ #category : #accessing }
ObjectExplorer >> doItReceiver [
	"Answer the object that should be informed of the result of evaluating a
	text selection."

	^ self object
]

{ #category : #'user interface' }
ObjectExplorer >> explore: anObject [

	self rootObject: anObject.
]

{ #category : #'menus - actions' }
ObjectExplorer >> explorePointersForSelection [
	
	self flag: #tooMany. "mt: Note that we might want to ignore references caused by this tool."
	self object explorePointers.
]

{ #category : #'menus - actions' }
ObjectExplorer >> exploreSelection [

	self object explore.
]

{ #category : #menus }
ObjectExplorer >> explorerKey: aChar from: view event: event [

	event anyModifierKeyPressed ifFalse: [^ false].

	self object ifNotNil: [
		aChar == $i ifTrue: [self inspectSelection. ^ true].
		aChar == $I ifTrue: [self exploreSelection. ^ true].

		aChar == $b ifTrue:	[self browseFull. ^ true].
		aChar == $h ifTrue:	[self browseClassHierarchy. ^ true].
		aChar == $c ifTrue: [self copyName. ^ true].
		aChar == $p ifTrue: [self browseFullProtocol. ^ true].
		aChar == $N ifTrue: [self browseClassRefs. ^ true].
		aChar == $v ifTrue: [self viewerForValue. ^ true]].

	^ false
]

{ #category : #accessing }
ObjectExplorer >> expression [

	^ expression
]

{ #category : #accessing }
ObjectExplorer >> expression: aString [

	expression := aString.
]

{ #category : #'accessing - view' }
ObjectExplorer >> findDeepSubmorphsIn: aMorph that: aBlock [

	| selectedSubmorphs |
	selectedSubmorphs := aMorph submorphs select: aBlock.
	^ selectedSubmorphs, (aMorph submorphs collect: [:each |
		self findDeepSubmorphsIn: each that: aBlock]) flatten
]

{ #category : #menus }
ObjectExplorer >> genericMenu: aMenu [ 

	^ self menu: aMenu for: #(treeListMenu treeListMenuShifted:)
]

{ #category : #'user interface' }
ObjectExplorer >> getDragItem: binding [

	^ binding value
]

{ #category : #accessing }
ObjectExplorer >> getList [
	"This explorer shows bindings in a tree structure. Create the root binding here."
	
	^ {self root}
]

{ #category : #'user interface' }
ObjectExplorer >> initialExtent [

	^350@250
]

{ #category : #'menus - actions' }
ObjectExplorer >> inspectBasic [
	"Bring up a non-special inspector"

	self object basicInspect.
]

{ #category : #toolbuilder }
ObjectExplorer >> inspectObject [
	"Switch to an inspector tool."
	
	| window currentBounds |
	currentBounds := ToolBuilder findDefault getBoundsForWindow: self containingWindow.

	"Close first because MVC fiddles around with processes."
	self changed: #close. 
		
	window := ToolSet inspect: self rootObject.
	
	"---- In MVC, the lines after this will not be executed ---"

	window model setExpression: self expression.
	ToolBuilder findDefault setBoundsForWindow: window to: currentBounds.
]

{ #category : #'menus - actions' }
ObjectExplorer >> inspectSelection [

	self object inspect.
]

{ #category : #'accessing - other' }
ObjectExplorer >> inspector [
	
	^ inspector ifNil: [inspector := Inspector new]
]

{ #category : #accessing }
ObjectExplorer >> label [

	^ [self rootObject printStringLimitedTo: 40] ifError: ['a ' , self rootObject class]
]

{ #category : #menus }
ObjectExplorer >> mainTreeListMenu: aMenu [
	<treeListMenu>

	aMenu addStayUpItemSpecial.

	aMenu addList: #(
		('inspect (i)'						inspectSelection)
		('explore (I)'						exploreSelection)
		-
		('method refs to this inst var'		referencesToSelection)
		('methods storing into this inst var'	defsOfSelection)
		('objects pointing to this value'		objectReferencesToSelection)
		('chase pointers'					chasePointersForSelection)
		('explore pointers'					explorePointersForSelection)
		-
		('browse full (b)'					browseFull)
		('browse hierarchy (h)'				browseClassHierarchy)
		('browse protocol (p)'				browseFullProtocol)
		-
		('references... (r)'					browseVariableReferences)
		('assignments... (a)'				browseVariableAssignments)
		('class refs (N)'						browseClassRefs)
		-
		('copy name (c)'					copyName)		
		('copy value'						copyValue)		
		('basic inspect'						inspectBasic)).

	Smalltalk isMorphic ifTrue: [
		aMenu addList: #(
			-
			('viewer for this value (v)'		viewerForValue))].

	aMenu addList: #(
		-
		('monitor changes'		monitorSelection)).
				
	monitorList isEmptyOrNil ifFalse: [
		aMenu addList: #(
			('stop monitoring all'		stopMonitoring))].
				
	^ aMenu
]

{ #category : #monitoring }
ObjectExplorer >> monitor: aBinding [
	"Start stepping and watching the given binding for changes."

	aBinding ifNil: [ ^self ].
	self world ifNil: [ ^self ].
	self monitorList add: aBinding.
	
	self world startStepping: self at: Time millisecondClockValue selector: #step arguments: #() stepTime: 2000.
]

{ #category : #monitoring }
ObjectExplorer >> monitorList [
	^monitorList ifNil: [ monitorList := WeakOrderedCollection new ].
]

{ #category : #'menus - actions' }
ObjectExplorer >> monitorSelection [

	self monitor: self currentSelection.
]

{ #category : #'accessing - objects' }
ObjectExplorer >> object [

	^ self currentSelection value
]

{ #category : #'menus - actions' }
ObjectExplorer >> objectReferencesToSelection [
	"Open a list inspector on all the objects that point to the value of the selected instance variable, if any.  "

	self object ifNil: [^ self changed: #flash].

	self systemNavigation
		browseAllObjectReferencesTo: self object
		except: {self currentSelection. self currentParent. self parentObject}
		ifNone: [:obj | self changed: #flash].
]

{ #category : #'accessing - objects' }
ObjectExplorer >> parentObject [

	^ self currentParent value
]

{ #category : #'accessing - view' }
ObjectExplorer >> possibleReferencesToSelection [

	^ {self}, self visibleObjectExplorerWrappers
]

{ #category : #'menus - actions' }
ObjectExplorer >> referencesToSelection [
	"Open a browser on all references to the selected instance variable, if that's what currently selected."
	
	self selectedParentClass ifNil: [^ self changed: #flash].
	self selectedParentClass isVariable ifTrue: [^ self changed: #flash].
	self selectedInstVarName ifNil: [^ self changed: #flash].

	self systemNavigation browseAllAccessesTo: self selectedInstVarName from: self selectedParentClass.
]

{ #category : #monitoring }
ObjectExplorer >> release [
	self world ifNotNil: [ self world stopStepping: self selector: #step ].
	super release.
]

{ #category : #'user interface' }
ObjectExplorer >> representsSameBrowseeAs: anotherObjectExplorer [
	^ self rootObject == anotherObjectExplorer rootObject
]

{ #category : #accessing }
ObjectExplorer >> root [

	^ root ifNil: [root := 'root' -> nil]
]

{ #category : #'accessing - objects' }
ObjectExplorer >> rootObject [

	^ self root value
]

{ #category : #'accessing - objects' }
ObjectExplorer >> rootObject: anObject [

	self root value: anObject.

	self changed: #label.
	self changed: #getList.
	self changed: #expandRootsRequested.

	self currentSelection: self getList first.
]

{ #category : #'accessing - other' }
ObjectExplorer >> selectedClass [
	"Answer the class of the receiver's current selection"

	^self doItReceiver class

]

{ #category : #'accessing - other' }
ObjectExplorer >> selectedInstVarName [

	self parentObject ifNil: [^ nil].
	(self parentObject class allInstVarNames includes: self currentSelection key)
		ifTrue: [^ self currentSelection key asSymbol].
	^ nil
]

{ #category : #'accessing - other' }
ObjectExplorer >> selectedParentClass [

	^ self parentObject ifNotNil: [:o | o class]
]

{ #category : #'accessing - other' }
ObjectExplorer >> setExpression: aString [

	self expression: aString.
	self changed: #expression.
]

{ #category : #monitoring }
ObjectExplorer >> shouldGetStepsFrom: aWorld [
	^self monitorList notEmpty
]

{ #category : #monitoring }
ObjectExplorer >> step [
	"Let all views know that some of my objects need to be updated."

	self monitorList do: [ :object |
		object ifNotNil: [self changed: #objectChanged with: object]].
	self monitorList ifEmpty: [ 
		self world stopStepping: self selector: #step ].
]

{ #category : #monitoring }
ObjectExplorer >> stopMonitoring [
	monitorList := nil.
	self world stopStepping: self selector: #step
]

{ #category : #'menus - actions' }
ObjectExplorer >> viewerForValue [

	self object beViewed.
]

{ #category : #'accessing - view' }
ObjectExplorer >> views [

	^ self findDeepSubmorphsIn: self world that: [:morph | 
		morph modelOrNil = self]
]

{ #category : #'accessing - view' }
ObjectExplorer >> visibleListItems [

	| lists |
	lists := self views select: [:morph |
		(morph isKindOf: PluggableTreeMorph)].
	^ (lists collect: [:each|
		each items]) flatten
]

{ #category : #'accessing - view' }
ObjectExplorer >> visibleObjectExplorerWrappers [

	| listItems |
	listItems := self visibleListItems.
	^ listItems collect: [:each | each complexContents]
]

{ #category : #monitoring }
ObjectExplorer >> world [

	^ Project current world
]
