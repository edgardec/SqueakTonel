"
I am a tool that allows to inspect and modify the internal representation of an object. As a StringHolder, the string I represent is the value of the currently selected inspector field, which may be an instance variable, of the observed object.

Beside the #contents in my value pane, I have an extra code pane that holds an #expression to be evaluated on the inspected object -- not the currently selected inspector field.

Take a look at my ""fields ..."" protocols as well as InspectorField.

(Note that the idea of ""elements"" from the CollectionInspector bleeds a little bit down into this interface to simplify the implementation of field truncation as well as #inspectOne. Sorry for that. Usually, the inspected object will only produce ""fields"" to display, and maybe ""items"" in a pop-up menu. Only collections have ""elements"".)
"
Class {
	#name : #Inspector,
	#superclass : #StringHolder,
	#instVars : [
		'object',
		'context',
		'fields',
		'customFields',
		'selectionIndex',
		'expression',
		'contentsTyped',
		'fieldListStyler',
		'shouldStyleValuePane',
		'selectionUpdateTime'
	],
	#classVars : [
		'CachedAllInstVarsLabel',
		'CurrentLocale'
	],
	#category : #'Tools-Inspector'
}

{ #category : #'instance creation' }
Inspector class >> inspect: anObject [ 
	"Answer a new (sub)instance of me to provide an inspector for anObject."

	^ self new inspect: anObject
]

{ #category : #'instance creation' }
Inspector class >> on: anObject [ 
	"Answer a new instance of me to provide an inspector for anObject."
	
	^ self new object: anObject
]

{ #category : #'instance creation' }
Inspector class >> openOn: anObject [
	"Open an inspector for anObject."
	
	^ ToolBuilder open: (self on: anObject)
]

{ #category : #'instance creation' }
Inspector class >> openOn: anObject withLabel: label [
	"Open an inspector with a specific label. Use this to set the inspector into context to explain why that object is inspected."

	^ ToolBuilder open: (self on: anObject) label: label
]

{ #category : #'user interface - styling' }
Inspector >> aboutToStyle: aStyler requestor: anObject [
	"We have two text fields in this tool: code pane and value pane. Do always style the code pane."
	
	self updateStyler: aStyler requestor: anObject.
	
	^ (anObject knownName = #valuePane)
		==> [shouldStyleValuePane == true
			"Fields can override styling so that contents are always styled."
			or: [self selectedField notNil ==> [self selectedField shouldStyleValue]]]
]

{ #category : #'menu - construction' }
Inspector >> addClassItemsTo: aMenu [

	aMenu addTranslatedList: #(
		-
		('browse full (b)'			browseClass)
		('browse hierarchy (h)'		browseClassHierarchy)
		('browse protocol (p)'		browseFullProtocol)).

	self typeOfSelection = #self ifFalse: [^ self].
	
	aMenu addTranslatedList: #(
		-
		('references... (r)'			browseVariableReferences)
		('assignments... (a)'		browseVariableAssignments)
		('class refs (N)'				browseClassRefs)).
]

{ #category : #'menu - construction' }
Inspector >> addCollectionItemsTo: aMenu [

	aMenu
		add: 'inspect element...' translated
		target: self
		selector: #inspectOne.
]

{ #category : #'fields - custom' }
Inspector >> addCustomField [

	^ self addCustomField: (self requestCustomFieldOrCancel: [^ self])
]

{ #category : #'fields - custom' }
Inspector >> addCustomField: aField [

	aField type: #custom.
	self customFields add: aField.
	self updateFields.
	self selectField: aField.
]

{ #category : #'menu - construction' }
Inspector >> addEtoysItemsTo: aMenu [

	aMenu addLine; addTranslatedList: {
		{ 'tile for this value (t)'.		[self selectionOrObject tearOffTile] }.
		{ 'viewer for this value (v)'. [self selectionOrObject beViewed] }}.
]

{ #category : #'menu - construction' }
Inspector >> addFieldItemsTo: aMenu [

	aMenu addTranslatedList: #(
		-
		('copy name (c)'	copyName)
		('copy expression'	copyExpression		'Copy a code snippet that returns the field''s value when evaluated on the inspected object.')).
]

{ #category : #'menu - construction' }
Inspector >> addInstVarItemsTo: aMenu [

	aMenu addTranslatedList: #(
		-
		('references (r)'			browseVariableReferences)
		('assignments (a)'		browseVariableAssignments)).
]

{ #category : #'menu - construction' }
Inspector >> addObjectItemsTo: aMenu [
	"The following menu items trigger actions appropricate to all kinds of objects."

	self typeOfSelection = #ellipsis ifTrue: [^ self].

	aMenu addTranslatedList: {
		{'inspect (i)'.		#inspectSelection}.
		{'explore (I)'.		#exploreSelection}.
		{'basic inspect'.	#inspectSelectionBasic.
			'Inspect all instvars of the object, regardless of\any possible specialized Inspector for this type' withCRs}}.

	aMenu addTranslatedList: {
		#-.
		{'inspect pointers'.		#objectReferencesToSelection. 'objects pointing to this value'}.
		{'chase pointers'.		#chaseSelectionPointers}.
		{'explore pointers'.		#exploreSelectionPointers} }.
]

{ #category : #private }
Inspector >> allInstVarsTranslated [
	"Alas translation is slow enough that we notice the slow down in trying to step in the debugger..."
	(CurrentLocale ~= Locale current
	 or: [CachedAllInstVarsLabel isNil]) ifTrue:
		[CurrentLocale := Locale current.
		 CachedAllInstVarsLabel :=  'all inst vars' translated].
	^CachedAllInstVarsLabel
]

{ #category : #'user interface' }
Inspector >> applyUserInterfaceTheme [

	super applyUserInterfaceTheme.

	self fieldListStyler ifNotNil: [:styler |
		styler reset.
		self updateFieldList].
]

{ #category : #'menu - commands' }
Inspector >> browseClass [
	"Open a full browser on the class of the selected item"

	^ ToolSet browseClass: self classOfSelection
]

{ #category : #'menu - commands' }
Inspector >> browseClassHierarchy [
	"Open a class list browser on the receiver's hierarchy."

	^ self systemNavigation browseHierarchy: self classOfSelection
]

{ #category : #'menu - commands' }
Inspector >> browseVariableAssignments [

	^ self selectedInstVarName
		ifNotNil: [:instVar | self systemNavigation
			browseAllStoresInto: instVar 
			from: self object class]
		ifNil: [self systemNavigation browseVariableAssignments: self object class]
]

{ #category : #'menu - commands' }
Inspector >> browseVariableReferences [

	^ self selectedInstVarName
		ifNotNil: [:instVar | self systemNavigation
			browseAllAccessesTo: instVar 
			from: self object class]
		ifNil: [self systemNavigation browseVariableReferences: self object class]
]

{ #category : #toolbuilder }
Inspector >> buildCodePaneWith: builder [
	"Overridden. Note that I do not hold #contents in my code pane. See my value pane for that."
	
	^ builder pluggableCodePaneSpec new
		model: self;
		getText: #expression; 
		editText: #expression:;
		help: 'Evaluate expressions on inspected object' translated;
		menu: #codePaneMenu:shifted:;
		askBeforeDiscardingEdits: false;
		yourself
]

{ #category : #toolbuilder }
Inspector >> buildExploreButtonWith: builder [
	
	^ builder pluggableButtonSpec new
		model: self;
		label: 'explore' translated;
		action: #replaceInspectorWithExplorer;
		help: 'Switch to an explorer tool' translated;
		yourself
]

{ #category : #toolbuilder }
Inspector >> buildFieldListWith: builder [

	^ builder pluggableListSpec new
		model: self;
		list: #fieldList;
		getIndex: #selectionIndex;
		setIndex: #selectionIndex:;
		autoDeselect: true;
		menu: #fieldListMenu:shifted:;
		dragItem: #dragFromFieldList:;
		dropItem: #dropOnFieldList:at:shouldCopy:;
		keyPress: #inspectorKey:from:;
		yourself
]

{ #category : #toolbuilder }
Inspector >> buildValuePaneWith: builder [
	"The value pane holds this StringHolder's contents."

	^ builder pluggableCodePaneSpec new
		model: self;
		name: #valuePane;
		getText: #contents;
		setText: #contents:notifying:;
		editText: #typeValue:; "Turn on code styling as you type."
		help: 'Selected field''s value' translated;
		menu: #codePaneMenu:shifted:; "Share the menu with the code pane."
		yourself
]

{ #category : #toolbuilder }
Inspector >> buildWith: builder [
	"Inspector openOn: SystemOrganization"
	
	| windowSpec buttonOffset |
	buttonOffset := (Preferences standardButtonFont widthOfString: 'explore') * 3/2.
	windowSpec := self buildWindowWith: builder specs: {
		(0@0 corner: 0.3@0.71)
			-> [self buildFieldListWith: builder].
		(0.3@0.0 corner: 1@0.71)
			-> [self buildValuePaneWith: builder].
		(LayoutFrame fractions: (0@0.71 corner: 1@1) offsets: (0@0 corner: buttonOffset negated@0))
			-> [self buildCodePaneWith: builder].
		(LayoutFrame fractions: (1@0.71 corner: 1@1) offsets: (buttonOffset negated@0 corner: 0 @ 0))
			-> [self buildExploreButtonWith: builder].
	}.
	^ builder build: windowSpec
]

{ #category : #'menu - commands' }
Inspector >> chaseSelectionPointers [

	| selected saved |
	self hasSelection ifFalse: [^ self changed: #flash].
	selected := self selectionOrObject.
	saved := self object.
	self object: nil.
	^ [(selected respondsTo: #chasePointers)
		flag: #ct "Do we indeed need to isolate Tools-Inspector and Tools-Debugger?";
		flag: #ct "ToolSet";
		ifTrue: [selected chasePointers]
		ifFalse: [selected inspectPointers]]
			ensure: [self object: saved]
]

{ #category : #'selection - convenience' }
Inspector >> classOfSelection [
	"Answer the class of the receiver's current selection"

	^ self selectionOrObject class
]

{ #category : #'accessing - contents' }
Inspector >> contents: aString notifying: aController [
	"Try to change the contents of the selected field. This is the usual callback for all string holders."
	
	| result |
	result := self object class evaluatorClass new
		evaluate: aString
		in: self doItContext
		to: self doItReceiver
		notifying: aController
		ifFail: [^ false].
	
	^ self replaceSelectionValue: result
]

{ #category : #'fields - error handling' }
Inspector >> contentsForErrorDoing: aBlock [

	^ 'An error occurred while inspecting this object. {1} to debug the error.'
			translated asText format: {
				Text
					string: 'Click here' translated
					attributes: { TextEmphasis bold. PluggableTextAttribute evalBlock: aBlock }}
]

{ #category : #'fields - truncation' }
Inspector >> contentsForTruncationOf: truncatedKeys [

	^ ('<Fields named {1} to {2} are not shown. {3} to inspect one of those fields or select "inspect element" from any field''s menu.>' translated asText
		addAttribute: TextEmphasis italic;
		format: {
			truncatedKeys first storeString.
			truncatedKeys last storeString. 
			'Click here' translated asText
				addAttribute: (PluggableTextAttribute evalBlock: [self inspectOneOf: truncatedKeys]);
				yourself. })
]

{ #category : #'accessing - contents' }
Inspector >> contentsTyped [

	^ contentsTyped
]

{ #category : #'accessing - contents' }
Inspector >> contentsTyped: aStringOrText [

	contentsTyped := aStringOrText.
]

{ #category : #accessing }
Inspector >> context [

	^ context
]

{ #category : #accessing }
Inspector >> context: ctxt [
	"Set the context of inspection, which is used for syntax highlighting and code evaluation."

	context := ctxt.
]

{ #category : #'menu - commands' }
Inspector >> copyExpression [
	"From the selected field, copy the code expression that returns the contents of the value pane into the clipboard."

	(self expressionForField: self selectedField)
		ifNil: [self error: 'Cannot determine field expression' translated]
		ifNotNil: [:fieldExpression | Clipboard clipboardText: fieldExpression].
]

{ #category : #'menu - commands' }
Inspector >> copyName [
	"Copy the name of the selected field into clipboard."

	self selectedFieldName
		ifNil: [self error: 'Cannot determine field name.' translated]
		ifNotNil: [:name | Clipboard clipboardText: name].
]

{ #category : #accessing }
Inspector >> customFields [
	
	^ customFields
]

{ #category : #'user interface' }
Inspector >> defaultIntegerBase [
	"Answer the default base in which to print integers.
	 Defer to the class of the instance."
	
	^ (self object class respondsTo: #defaultIntegerBaseInDebugger)
		ifTrue: [self object class perform: #defaultIntegerBaseInDebugger]
		ifFalse: [10]
]

{ #category : #accessing }
Inspector >> doItContext [
	"Answer the context in which a text selection can be evaluated."

	^ self context
]

{ #category : #accessing }
Inspector >> doItReceiver [
	"Answer the object that should be informed of the result of evaluating a text selection."

	^ self object
]

{ #category : #'fields - drag and drop' }
Inspector >> dragFromFieldList: index [

	^ (self fields at: index ifAbsent: [nil])
		ifNotNil: [:fieldToDrag | fieldToDrag rememberInspector]
]

{ #category : #'fields - drag and drop' }
Inspector >> dropOnFieldList: anObjectOrField at: index shouldCopy: shouldCopyField [
	"Drop an object to change a field's value or drop a field to add it to the list of custom fields."
	
	(shouldCopyField and: [anObjectOrField isKindOf: self fieldClass])
		ifTrue: [
			self flag: #refactor. "mt: Instead of abusing #shouldCopy, write a separate hook for dropping fields between list items to insert fields."
			self addCustomField: anObjectOrField forgetInspector copy]
		ifFalse: [
			self selectionIndex: index.
			self replaceSelectionValue: anObjectOrField value].
]

{ #category : #'menu - private' }
Inspector >> elementAt: indexOrKey [
	"Backstop to simplify #inspectOne for all kinds of inspectors."

	^ (self elementGetterAt: indexOrKey) value: self object
]

{ #category : #'menu - private' }
Inspector >> elementGetterAt: indexOrKey [
	"Backstop to simplify #inspectOne for all kinds of inspectors."

	^ [:object | (self fields detect: [:field | field key = indexOrKey]) getValueFor: self] 
]

{ #category : #'fields - error handling' }
Inspector >> emphasizeError: errorMessage [

	^ ('<{1}>' asText format: { errorMessage })
		addAttribute: self textColorForError;
		yourself
]

{ #category : #selection }
Inspector >> ensureSelectedField [
	"If there is no field selected, try to select the first one."

	self hasSelection
		ifFalse: [self selectionIndex: 1].

	^ self selectedField
]

{ #category : #'menu - commands' }
Inspector >> exploreSelection [

	^ self selectionOrObject explore
]

{ #category : #'menu - commands' }
Inspector >> exploreSelectionPointers [

	^ self selectionOrObject explorePointers
]

{ #category : #'accessing - contents' }
Inspector >> expression [
	"The code string in the code pane. Recorded for Inspector/Explorer switching. See #replaceInspectorWithExplorer."

	^ expression ifNil: ['']
]

{ #category : #'accessing - contents' }
Inspector >> expression: aStringOrText [
	"The code string in the code pane. Recorded for Inspector/Explorer switching. See #replaceInspectorWithExplorer."

	expression := aStringOrText.
]

{ #category : #fields }
Inspector >> expressionForField: anInspectorField [
	"Subclasses can override this to configure the way to retrieve the source-code expression for the field."

	^ anInspectorField valueGetterExpression
]

{ #category : #fields }
Inspector >> fieldAllInstVars [

	^ (self newFieldForType: #all key: #allInstVars)
		name: self allInstVarsTranslated; emphasizeName;
		valueGetter: [:object | object longPrintString]; printValueAsIs;
		yourself
]

{ #category : #initialization }
Inspector >> fieldClass [

	^ InspectorField
]

{ #category : #'user interface' }
Inspector >> fieldList [
	"Return a list of texts that identify the fields for the object under inspection so that the user can make an informed decision on what to inspect."
	
	^ self fieldListStyler
		ifNil: [self fields collect: [:field | field name]]
		ifNotNil: [:styler |
			self updateStyler: styler.
			self fields collect: [:field |
				field shouldStyleName
					ifTrue: [styler styledTextFor: field name asText]
					ifFalse: [field name]]]
]

{ #category : #menu }
Inspector >> fieldListMenu: aMenu [
	"Arm the supplied menu with items for the field-list of the receiver"
	^ self menu: aMenu for: #(fieldListMenu fieldListMenuShifted:)

]

{ #category : #menu }
Inspector >> fieldListMenu: aMenu shifted: shifted [
	"Arm the supplied menu with items for the field-list of the receiver"
	^ self
		menu: aMenu
		for: #(fieldListMenu fieldListMenuShifted:)
		shifted: shifted
]

{ #category : #'user interface - styling' }
Inspector >> fieldListStyler [
	"This is an extra styler to style the items in the field list. Note that both code and value pane use their own styler."
	
	^ fieldListStyler
]

{ #category : #fields }
Inspector >> fieldSelf [

	^ (self newFieldForType: #self key: #self)
		shouldStyleName: true;
		valueGetter: [:object | object];
		valueSetter: [:object :value | self object: value]; "Switch to another object-under-inspection."
		yourself
]

{ #category : #accessing }
Inspector >> fields [

	 ^ fields ifNil: [#()]
]

{ #category : #'user interface' }
Inspector >> getContents [
	
	| newContents |
	selectionUpdateTime := 0.

	self hasSelection ifFalse: [^ ''].
	
	selectionUpdateTime := [
		newContents := self selection in: [:object |
			self selectedField shouldPrintValueAsIs
				ifTrue: [object asStringOrText] "Show strings and texts without quoting and without ellipsis."
				ifFalse: [
					object isInteger
						ifTrue: [object storeStringBase: self defaultIntegerBase]
						ifFalse: [object printString]]].
	] timeToRun.

	^ newContents
]

{ #category : #'fields - custom' }
Inspector >> hasCustomFields [

	^ self customFields notEmpty
]

{ #category : #selection }
Inspector >> hasSelection [
	"Use #selectedField instead of #selectionIndex to guard against invalid #selectionIndex. Can happen, for example, when adding elements to sets."
	
	^ self selectedField notNil
]

{ #category : #initialization }
Inspector >> initialExtent [
	"Answer the desired extent for the receiver when it is first opened on the screen.  "

	^ 350 @ 250
]

{ #category : #initialization }
Inspector >> initialize [

	super initialize.
	
	customFields := OrderedCollection new.
	selectionIndex := 0.
	
	fieldListStyler := (Smalltalk classNamed: #SHTextStylerST80)
		ifNotNil: [:class | class new].
]

{ #category : #initialization }
Inspector >> inspect: anObject [ 
	"Reinitialize the receiver so that it is inspecting anObject. Become an instance of the appropriate inspectorClass.
	
	Normally the receiver will be of the correct class (as defined by anObject inspectorClass), because it will have just been created by sending inspect to anObject.  However, the debugger uses two embedded inspectors, which are re-targetted on the current receiver each time the stack frame changes.  The left-hand inspector in the debugger has its class changed by the code here."

	| inspectorClass |
	inspectorClass := anObject inspectorClass.
	self class ~= inspectorClass ifTrue: [
		self class format = inspectorClass format
			ifTrue: [self primitiveChangeClassTo: inspectorClass basicNew]
			ifFalse: [self becomeForward: (self as: inspectorClass)]].
	
	self object: anObject.
]

{ #category : #'menu - commands' }
Inspector >> inspectOne [
	"This is the most generic case to inspect a specific element from the inspected object. Since trunction of fields is a generic feature, support lookup for those truncated objects also for non-collections."

	self inspectOneOf: (
		self fields
			select: [:field | field key notNil]
			thenCollect: [:field | field key]).
]

{ #category : #'menu - commands' }
Inspector >> inspectOneOf: someKeys [

	| elements labels choice |
	someKeys size = 0 ifTrue: [^ self inform: 'Nothing to inspect.' translated].
	someKeys size = 1 ifTrue: [^ (self elementAt: someKeys first) inspect].
	someKeys size > 50 ifTrue: [^ self inspectOneOfFrom: someKeys first to: someKeys last].
	
	elements := someKeys collect: [:key | [self elementAt: key] ifError: ['<???>']].
	labels := someKeys with: elements collect: [:key :element |
		'{1} -> {2}' format: {
			key printString.
			[element printString withoutLineEndings withBlanksCondensed truncateWithElipsisTo: 75]
				ifError: ['<???>']}].
	choice := Project uiManager chooseFrom: labels title: 'Inspect which field?'.
	choice = 0 ifTrue: [^ self].
	
	(elements at: choice) inspect.
]

{ #category : #'menu - commands' }
Inspector >> inspectOneOfFrom: firstKey to: lastKey [
	"Let the user specify the desired field's key in the form of a Smalltalk literal or otherwise simple code expression."

	| choiceString |
	choiceString := Project uiManager
		request: ('Enter the name of the field to inspect.\Names range from {1} to {2}.' translated withCRs
			format: {firstKey storeString. lastKey storeString})
		initialAnswer: firstKey storeString.
	choiceString isEmptyOrNil ifTrue: [^ self].

	(self elementAt: (Compiler evaluate: choiceString)) inspect.
]

{ #category : #'menu - commands' }
Inspector >> inspectSelection [
	"Create and schedule an Inspector on the receiver's model's currently selected object."

	self hasSelection ifFalse: [^ self changed: #flash].
	^ self selectionOrObject inspect
]

{ #category : #'menu - commands' }
Inspector >> inspectSelectionBasic [
	"Bring up an inspector that focuses on the very basics of an object."

	^ ToolSet basicInspect: self selectionOrObject
]

{ #category : #menu }
Inspector >> inspectorKey: aChar from: view [
	"Respond to a Command key issued while the cursor is over my field list"

	^ aChar
		caseOf: {
			[$x]	->	[self removeSelection].
			
			[$i]		->	[self inspectSelection].
			[$I]		->	[self exploreSelection].
			[$b]	->	[self browseClass].
			[$h]	->	[self browseClassHierarchy].
			[$p]	->	[self browseFullProtocol].
			[$r]		->	[self browseVariableReferences].
			[$a]	->	[self browseVariableAssignments].
			[$N]	->	[self browseClassRefs].
			[$c]	->	[self copyName].
			[$t]		->	[self tearOffTile].
			[$v]	->	[self viewerForValue] }
		otherwise:	[self arrowKey: aChar from: view]
]

{ #category : #'user interface - window' }
Inspector >> labelString [
	"See #windowTitle. All tools chose to implement #labelString."
	
	^ '{1}{2}' format: {
		self object defaultLabelForInspector.
		self object isReadOnlyObject
			ifTrue: [' (read-only)']
			ifFalse: ['']}
]

{ #category : #menu }
Inspector >> mainFieldListMenu: aMenu [
	"Arm the supplied menu with items for the field-list of the receiver"
	<fieldListMenu>
	aMenu addStayUpItemSpecial.
	
	self addObjectItemsTo: aMenu.
	
	(#(self ellipsis element nil) includes: self typeOfSelection)
		ifTrue: [self addCollectionItemsTo: aMenu].

	self typeOfSelection = #instVar
		ifTrue: [self addInstVarItemsTo: aMenu].

	self addFieldItemsTo: aMenu.
	self addClassItemsTo: aMenu.
	
	Smalltalk isMorphic ifTrue: [
		self flag: #refactor. "mt: Extract Etoys-specific extension."
		"ct: We could use the <fieldListMenu> pragma if it had a priority argument!"
		self addEtoysItemsTo: aMenu].

	^ aMenu
]

{ #category : #menu }
Inspector >> metaFieldListMenu: aMenu [
	<fieldListMenu"Shifted: true">
	self flag: #ct "we need keyboard support for shifted menus. Maybe add an item 'More...'?".

	aMenu addLine.
	aMenu addTranslatedList: #(
		('add field...'	#addCustomField)).
	self selectedField ifNotNil: [:field |
		field isCustom ifTrue: [
			field addCustomItemsFor: self to: aMenu]].
	^ aMenu
]

{ #category : #'updating - steps' }
Inspector >> modelWakeUpIn: aWindow [
	
	self updateFields.
]

{ #category : #'fields - custom' }
Inspector >> newCustomField [

	^ (self newFieldForType: #custom)
		valueGetterExpression: 'self yourself';
		yourself
]

{ #category : #fields }
Inspector >> newFieldForType: aSymbol [

	^ self fieldClass type: aSymbol
]

{ #category : #fields }
Inspector >> newFieldForType: aSymbol key: anObject [

	^ self fieldClass type: aSymbol key: anObject
]

{ #category : #selection }
Inspector >> noteSelectionIndex: anInteger for: aSymbol [
	
	self flag: #mvcOnly.
	aSymbol == #fieldList ifTrue:
		[selectionIndex := anInteger].
]

{ #category : #accessing }
Inspector >> object [
	"Answer the object being inspected by the receiver."

	^object
]

{ #category : #accessing }
Inspector >> object: anObject [
	"Set anObject to be the object being inspected by the receiver. The current contents, including edits, in the value pane become void because the new object is likely to have new fields with different contents."

	self object == anObject ifTrue: [^ self].
	self resetContents.
	
	object := anObject.
	self changed: #object.
	
	self changed: #windowTitle.

	self updateFields.
]

{ #category : #'menu - commands' }
Inspector >> objectReferencesToSelection [
	"Open a list inspector on all the objects that point to the value of the selected object."

	^ self systemNavigation
		browseAllObjectReferencesTo: self selectionOrObject
		except: (Array with: self with: self object)
		ifNone: [:obj | self changed: #flash]
]

{ #category : #'user interface - window' }
Inspector >> okToClose [

	^ super okToClose and: [self okToDiscardCustomFields]
]

{ #category : #'user interface - window' }
Inspector >> okToDiscardCustomFields [

	^ self hasCustomFields ==> [self confirm: (String streamContents: [:s |
		s nextPutAll: 'All custom fields will be discarded:' translated.
		self customFields do: [:field | 
			s crtab; nextPutAll: field name] ])]
]

{ #category : #'fields - custom' }
Inspector >> removeCustomField: aField [

	aField isCustom
		ifFalse: [^ self changed: #flash].
	(self customFields includes: aField)
		ifFalse: [^ self changed: #flash].

	(self confirm: ('Do you really want to remove the field ''{1}''?' translated format: {aField name}))
		ifFalse: [^ self].

	self customFields remove: aField.
	self updateFields.
]

{ #category : #'menu - commands' }
Inspector >> removeSelection [
	"In general, we can always remove custom fields. Specialized inspectors can offer to remove other fields such as those representing collection elements."

	self selectedField ifNotNil: [:field |
		field isCustom ifTrue: [self removeCustomField: field]].
]

{ #category : #toolbuilder }
Inspector >> replaceInspectorWithExplorer [
	"Switch to an explorer tool. If there are custom fields, the user can choose to not discard them, which will just spawn a new explorer tool besides this inspector."
	
	| window currentBounds |
	self okToDiscardCustomFields
		ifFalse: [^ self object explore].
	
	self customFields removeAll.
	self changed: #acceptChanges. "We copy the current state anyway. See below."
	currentBounds := ToolBuilder default class getBoundsForWindow: self containingWindow.

	"Close first because MVC fiddles around with processes."
	self changed: #close. 
		
	window := ToolSet explore: self object.
	
	"---- In MVC, the lines after this will not be executed ---"

	window model setExpression: self expression.
	ToolBuilder default class setBoundsForWindow: window to: currentBounds.
]

{ #category : #selection }
Inspector >> replaceSelectionValue: anObject [ 
	"Set the value of the selected field to anObject. We have to answer whether this replacement worked or not."
	
	| target |
	(target := self ensureSelectedField) ifNil: [^ false].
	
	target type = #self ifTrue: [
		^ (self confirm: 'This will exchange the inspected object.' translated)
			ifTrue: [self inspect: anObject. true]
			ifFalse: [false]].

	target isReadOnly ifTrue: [
		self inform: 'You cannot replace the selected field because\it is read-only. Try to add a field setter.' withCRs.
		^ false].

	self contentsTyped: nil. "Ensure to refresh the contents view."

	target
		setValueFor: self
		to: anObject.
		
	^ true
]

{ #category : #'user interface' }
Inspector >> representsSameBrowseeAs: anotherInspector [

	^ self object == anotherInspector object
]

{ #category : #'fields - custom' }
Inspector >> requestCustomFieldOrCancel: aBlock [

	^ self newCustomField
		requestCustomFor: self
		orCancel: aBlock
]

{ #category : #initialization }
Inspector >> resetContents [

	self setContents: nil.
]

{ #category : #initialization }
Inspector >> resetFields [

	"1) Discard existing fields."
	fields ifNotNil: [
		fields do: [:field | field removeDependent: self].
		fields := nil "Just in case there is an error in the following calls."].
	
	"2a) Create new fields."
	fields := Array streamContents: [:stream |
		| workBlock |
		workBlock := [self streamFieldsOn: stream].
		workBlock ifError: [self streamErrorDoing: workBlock on: stream]].
	
	"2b) Establish field dependency."
	fields do: [:field | field addDependent: self].
	
	"3) Tell the views."
	self updateFieldList.
]

{ #category : #selection }
Inspector >> selectField: aField [ 

	self selectionIndex: (self fields indexOf: aField ifAbsent: [0])
]

{ #category : #selection }
Inspector >> selectFieldNamed: aString [
	"Select the field that is labeled aFieldName, or nothing, is there is no match."

	self selectFieldSuchThat: [:field | field name = aString].
]

{ #category : #selection }
Inspector >> selectFieldSuchThat: aBlock [
	"Select the first field for which aBlock evaluates to true."

	self selectionIndex: (self fields findFirst: aBlock).
]

{ #category : #'selection - convenience' }
Inspector >> selectedClass [

	^ self object class
]

{ #category : #selection }
Inspector >> selectedField [

	^ self fields
		at: self selectionIndex
		ifAbsent: [nil]
]

{ #category : #selection }
Inspector >> selectedFieldName [

	^ self selectedField ifNotNil: [:field | field name]
]

{ #category : #'selection - convenience' }
Inspector >> selectedInstVarName [

	^ self selectedField ifNotNil: [:field |
		field type = #instVar
			ifTrue: [field key]
			ifFalse: [nil]].
]

{ #category : #selection }
Inspector >> selection [
	"Answer the value of the selected variable slot, that is an object."

	^ self selectedField getValueFor: self
]

{ #category : #accessing }
Inspector >> selectionIndex [

	^ selectionIndex
]

{ #category : #accessing }
Inspector >> selectionIndex: anInteger [
	"Changes the index to determine the currently selected field. If the field is already selected, update the fields contents in the value pane."

	self selectionIndex = anInteger
		ifTrue: [^ self updateContentsSafely].
	
	selectionIndex := anInteger.
	self changed: #selectionIndex.
	
	self updateContentsSafely.
]

{ #category : #'selection - convenience' }
Inspector >> selectionIsReadOnly [
	"Answer if the current selected variable is not modifiable via acceptance in the code pane.  For example, a selection of 'all inst vars' is unmodifiable."

	^ self selectedField
		ifNil: [true]
		ifNotNil: [:field | field isReadOnly]
]

{ #category : #'selection - convenience' }
Inspector >> selectionOrObject [
	"My selection. If nothing useful is selected, return the inspected object instead."

	self hasSelection ifFalse: [^ self object].
	self typeOfSelection = #ellipsis ifTrue: [^ self object].

	^ self selection
]

{ #category : #initialization }
Inspector >> setContents: aStringOrText [
	"Do not style the value pane anymore. Clear the #contentsTyped buffer."

	shouldStyleValuePane := false.
	super setContents: aStringOrText.
	self contentsTyped: nil.
]

{ #category : #initialization }
Inspector >> setContentsTyped: aStringOrText [
	"Simulate typing."
	
	shouldStyleValuePane := true.
	self contentsTyped: aStringOrText.
	
	self flag: #refactor. "mt: #changed: is not able to specify the receiver ..."
	self valuePane ifNotNil: [:pane |
		pane update: #editString with: aStringOrText].
]

{ #category : #initialization }
Inspector >> setExpression: aString [
	"Set the code string in the code pane after switching between Inspector/Explorer. See #replaceInspectorWithExplorer."

	self expression: aString.
	self changed: #expression.
]

{ #category : #'updating - steps' }
Inspector >> stepAt: millisecondClockValue in: aWindow [

	self updateFields.
]

{ #category : #'updating - steps' }
Inspector >> stepTimeIn: aWindow [
	"Minimum step time is 1 second. If the fetching of contents takes more than 100 milliseconds, increase the step time accordingly to keep the system responsive."
	
	^ (selectionUpdateTime ifNil: [0]) * 10 max: 1000
]

{ #category : #'fields - streaming' }
Inspector >> streamBaseFieldsOn: aStream [

	aStream
		nextPut: self fieldSelf;
		nextPut: self fieldAllInstVars.
]

{ #category : #'fields - streaming' }
Inspector >> streamCustomFieldsOn: aStream [

	aStream nextPutAll: self customFields.
]

{ #category : #'fields - error handling' }
Inspector >> streamError: aMessageString on: aStream [

	aStream nextPut: ((self newFieldForType: #error)
		name: (Text
			string: '<error>' translated
			attribute: self textColorForError);
		valueGetter: [:object | self emphasizeError: aMessageString];
		printValueAsIs;
		yourself)
]

{ #category : #'fields - error handling' }
Inspector >> streamErrorDoing: aBlock on: aStream [

	self
		streamError: (self contentsForErrorDoing: aBlock)
		on: aStream.
]

{ #category : #'fields - streaming' }
Inspector >> streamFieldsOn: aStream [

	self
		streamBaseFieldsOn: aStream;
		streamVariableFieldsOn: aStream;
		streamCustomFieldsOn: aStream.
]

{ #category : #'fields - streaming' }
Inspector >> streamIndexedVariablesOn: aStream [
	"Truncate indexed variables if there are too many of them."
	
	self
		streamOn: aStream
		truncate: (1 to: self object basicSize)
		collectFields: [:index |
			(self newFieldForType: #indexed key: index)
				valueGetter: [:object | object basicAt: index];
				valueSetter: [:object :value | object basicAt: index put: value];
				yourself]
]

{ #category : #'fields - streaming' }
Inspector >> streamInstanceVariablesOn: aStream [

	(self object perform: #class "do not inline send of #class, receiver could be a proxy") allInstVarNames doWithIndex: [:name :index |		
		aStream nextPut: ((self newFieldForType: #instVar key: name)
			shouldStyleName: true;
			valueGetter: [:object | object instVarNamed: name];
			valueSetter: [:object :value | object instVarNamed: name put: value];
			yourself)].
]

{ #category : #'fields - truncation' }
Inspector >> streamOn: aStream truncate: aList collectFields: aBlock [

	^ self
		streamOn: aStream
		truncate: aList
		collectFields: aBlock
		ellipsisFrom: [:truncatedObjects | (self newFieldForType: #ellipsis)
			name: '...';
			valueGetter: [:object | self contentsForTruncationOf: truncatedObjects];
			printValueAsIs;
			yourself]
]

{ #category : #'fields - truncation' }
Inspector >> streamOn: aStream truncate: someObjects collectFields: fieldBlock ellipsisFrom: ellipsisBlock [
	"Create fields for someObjects using fieldBlock. Using the current #truncationLimit, create an extra ellipsis field to hide objects that go beyond this limit."

	(someObjects size <= self truncationLimit or: [self truncationLimit < 0])
		ifTrue: [^ aStream nextPutAll: (someObjects collect: [:each | fieldBlock value: each])].
		
	someObjects readStream in: [:readStream |
		aStream
			nextPutAll: ((readStream next: self truncationLimit - self truncationTail - 1)
				collect: [:each | fieldBlock value: each]);
			nextPut: (ellipsisBlock value: (readStream upToPosition: readStream size - self truncationTail));
			nextPutAll: (readStream upToEnd
				collect: [:each | fieldBlock value: each])].
]

{ #category : #'fields - streaming' }
Inspector >> streamVariableFieldsOn: aStream [

	self
		streamInstanceVariablesOn: aStream;
		streamIndexedVariablesOn: aStream.
]

{ #category : #'user interface' }
Inspector >> textColorForError [

	^ TextColor color: ((self userInterfaceTheme get: #errorColor for: #TestRunner) ifNil: [Color red])
]

{ #category : #'fields - truncation' }
Inspector >> truncationLimit [
	"The maximum number of fields to show when truncating a list of objects. For example, collections can have a very big number of indexed variables and the inspecter would become slow without this limit. Keep the system responsive. Note that there is an extra ellipsis field for the truncated items so that users can manually select the (truncated) indexed variable to inspect.
	
	Choose a limit < 0 to not truncate any fields."

	^ 100
]

{ #category : #'fields - truncation' }
Inspector >> truncationTail [
	"The number of fields to show at the end of a truncated field run."

	^ 10
]

{ #category : #'selection - convenience' }
Inspector >> typeOfSelection [

	^ self selectedField ifNotNil: [:field | field type]
]

{ #category : #'user interface - styling' }
Inspector >> typeValue: aTextOrString [
	"Style field value contents only after the user typed."
	
	contentsTyped := aTextOrString.

	shouldStyleValuePane == true ifFalse: [
		shouldStyleValuePane := true.
		self changed: #style].
]

{ #category : #updating }
Inspector >> update [
	"For convenience."

	self updateFields.
]

{ #category : #updating }
Inspector >> update: what [

	what = #field ifTrue: [
		self updateFieldList.
		self updateContentsSafely].
	
	^ super update: what
]

{ #category : #updating }
Inspector >> update: what with: parameter [

	what = #deleteField
		ifTrue: [self removeCustomField: parameter].
	
	^ super update: what with: parameter
]

{ #category : #updating }
Inspector >> updateContentsSafely [
	"Force update contents of selected field. Do not style the contents anymore. Discard unaccepted changes in text fields."
	
	| workBlock |
	workBlock := [self getContents].
	self setContents: (workBlock
		ifError: [self emphasizeError: (self contentsForErrorDoing: workBlock)]).
]

{ #category : #updating }
Inspector >> updateFieldList [

	self changed: #fieldList.
	self changed: #selectionIndex. "In case a field got renamed, tell the view that the selection did not change at all. The view would otherwise assume it is gone after updating the list and clear the selection. That's a little interference with the built-in list filtering mechanism in the view."
]

{ #category : #updating }
Inspector >> updateFields [
	"Reset the collection of fields. Since amount and content my change, try to keep the current selection by field identity or field name."

	| field edits |
	field := self hasSelection ifTrue: [self selectedField]. "Save user selection"
	edits := self contentsTyped. "Save user edits"
	
	self resetFields.

	"Restore user selection"
	field ifNotNil: [
		(self fields identityIncludes: field)
			ifTrue: [self selectField: field]
			ifFalse: [self selectFieldNamed: field name]].

	"Restore user edits only if selection was restored."
	(edits notNil and: [self selectedField = field or: [self selectedFieldName = field name]])
		ifTrue: [self setContentsTyped: edits].

]

{ #category : #'updating - steps' }
Inspector >> updateListsAndCodeIn: aWindow [
	"Not needed. We have everything in place to update from here. See #updateFields. No need to update through views."
]

{ #category : #'user interface - styling' }
Inspector >> updateStyler: aStyler [
	
	self updateStyler: aStyler requestor: self.
]

{ #category : #'user interface - styling' }
Inspector >> updateStyler: aStyler requestor: anObject [
	"Use this method to update our fieldListStyler and all view stylers."
	
	aStyler
		environment: self environment;
		classOrMetaClass: (self doItReceiver perform: #class "do not inline send of #class, receiver could be a proxy");
		context: self doItContext;
		parseAMethod: false.
]

{ #category : #'user interface' }
Inspector >> valuePane [
	"Private. This is a workaround to interact with the value pane directly and not interfere with the code pane."

	^ self dependents
		detect: [:object | object knownName = #valuePane]
		ifNone: []
]

{ #category : #'updating - steps' }
Inspector >> wantsStepsIn: aWindow [
	"Independent of #smartUpdating preference".
	
	^ true
]
