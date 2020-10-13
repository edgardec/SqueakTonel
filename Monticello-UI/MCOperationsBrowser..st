Class {
	#name : #MCOperationsBrowser,
	#superclass : #MCCodeTool,
	#instVars : [
		'selection',
		'reverts'
	],
	#category : #'Monticello-UI'
}

{ #category : #'instance creation' }
MCOperationsBrowser class >> items: aCollection [ 
	^ self new
		 setItems: aCollection ;
		 yourself
]

{ #category : #preferences }
MCOperationsBrowser class >> themeProperties [

	^ super themeProperties, {
		{ #revertedOperationAttributes. 'Colors' . 'Text attributes to use for reverted operations in MC tools.' }.
		{ #ignoredOperationAttributes. 'Colors' . 'Text attributes to use for ignored operations in MC tools.' }.
		
		"{ #rejectedOperationAttributes. 'Colors' . 'Text attributes to use for rejected operations in MC tools.' }.
		{ #acceptedOperationAttributes. 'Colors' . 'Text attributes to use for accepted operations in MC tools.' }.
		{ #conflictingOperationAttributes. 'Colors' . 'Text attributes to use for conflicting operations in MC tools.' }."
	}
]

{ #category : #selecting }
MCOperationsBrowser >> advanceSelection [

	self selection < items size
		ifTrue: [self selection: self selection + 1]
]

{ #category : #accessing }
MCOperationsBrowser >> annotations [
	^selection ifNil: [ super annotations ]
		ifNotNil: [ selection annotations ]
]

{ #category : #updating }
MCOperationsBrowser >> applyUserInterfaceTheme [

	super applyUserInterfaceTheme.
	
	self changed: #list.
]

{ #category : #actions }
MCOperationsBrowser >> browseSelectionOrigin [
	| mcDefinition |
	selection ifNil: [ UIManager inform: 'Make a selection.' ].
	mcDefinition := selection definition.
	Cursor wait showWhile:
		[ mcDefinition mcModel ifNotNil:
			[ : mcModel | (mcModel originOf: mcDefinition)
				ifNil: [ UIManager inform: mcDefinition asString , ' was not found in any historical MC repository.' ]
				ifNotNilDo:
					[ : version | version open ] ] ]
]

{ #category : #ui }
MCOperationsBrowser >> buttonSpecs [
	^ #((Invert invert 'Show the reverse set of changes')
		 (Export export 'Export the changes as a change set'))
]

{ #category : #accessing }
MCOperationsBrowser >> changeSetNameForInstall [
	"Answer the name of the change set into which my selection will be installed.
	Derive this from my label.
	If I have no label, use the current change set."

	| tokens |
	label ifNil: [ ^ChangeSet current name ].
	tokens := label findTokens: ' '.
	tokens removeAllFoundIn: { 'changes'. 'between'. 'and' }.
	(tokens size = 3 and: [ tokens second = '<working' ]) ifTrue: [ ^tokens first, '-to-working' ].
	tokens size = 2 ifFalse: [ ^'InstalledPatches' ].
	^'{1}-to-{2}' format: tokens 
]

{ #category : #ui }
MCOperationsBrowser >> defaultLabel [
	^ label ifNil: [ 'Revisions Browser' ]
]

{ #category : #actions }
MCOperationsBrowser >> filterOutUnchangedMethods [
	"Remove from the list methods that only have changed timestamps"
	| unchangedMethods |
	unchangedMethods := self unchangedMethods.
	(self confirm: ('Ignore {1} methods that only differ in timestamp?' translated
		format: {unchangedMethods size}))
		ifTrue:
			[items := items reject: [:op| op isUnchangedMethod].
			 self changed: #list]

]

{ #category : #actions }
MCOperationsBrowser >> installSelection [
	| loader |
	selection ifNotNil:
		[loader := MCPackageLoader new.
		selection applyTo: loader.
		loader loadWithName: self changeSetNameForInstall.
		self reverts remove: selection ifAbsent: [].
		self changed: #list ]
]

{ #category : #selecting }
MCOperationsBrowser >> invert [
	items replace: [:ea | ea inverse].
	self changed: #list; changed: #text; changed: #selection
]

{ #category : #accessing }
MCOperationsBrowser >> isViewingRevisions [
	^self items size > 1 and:
		[self items allSatisfy:
			[:each | each definition isRevisionOf: self items first definition]]
]

{ #category : #accessing }
MCOperationsBrowser >> list [
	| showRevision |
	showRevision := self isViewingRevisions.
	^ self items collect: [:each | | summary |
		summary := showRevision ifTrue: [each summaryAndRevision] ifFalse: [each summary].
		(self reverts includes: each)
			ifFalse: [summary]
			ifTrue: [Text
				string: '( ', summary, ' )'
				attributes: (self userInterfaceTheme revertedOperationAttributes ifNil: [{TextEmphasis struckOut}])]]
]

{ #category : #menus }
MCOperationsBrowser >> methodListKey: aKeystroke from: aListMorph [
	aKeystroke caseOf: {
		[$x] -> [self revertSelection] } 
	otherwise: [super methodListKey: aKeystroke from: aListMorph ]
]

{ #category : #menus }
MCOperationsBrowser >> methodListMenu: aMenu [
	selection ifNotNil:
		[aMenu addList: #(
			('install'	 installSelection)
			('revert (x)'	 revertSelection)
			('browse origin' browseSelectionOrigin) 
			-)].
	self unchangedMethods ifNotEmpty:
		[aMenu addList: #(
			('revert unchanged methods...'	revertUnchangedMethods) 
			('filter out unchanged methods...'	filterOutUnchangedMethods) 
			-)].
	super methodListMenu: aMenu.
	^ aMenu
]

{ #category : #ui }
MCOperationsBrowser >> perform: selector orSendTo: otherTarget [
	"Selector was just chosen from a menu by a user.  If can respond, then
perform it on myself. If not, send it to otherTarget, presumably the
editPane from which the menu was invoked."

	(self respondsTo: selector)
		ifTrue: [^ self perform: selector]
		ifFalse: [^ otherTarget perform: selector]
]

{ #category : #actions }
MCOperationsBrowser >> revertSelection [
	| loader |
	selection ifNotNil:
		[loader := MCPackageLoader new.
		selection inverse applyTo: loader.
		self environmentInDisplayingImage beCurrentDuring: [loader loadWithName: self changeSetNameForInstall].
		self reverts add: selection.
		self
			advanceSelection;
			changed: #list ]
]

{ #category : #actions }
MCOperationsBrowser >> revertUnchangedMethods [
	"revert methods that only have changed timestamps"
	| loader unchangedMethods |
	unchangedMethods := self unchangedMethods.
	(self confirm: ('Revert {1} methods that only differ in timestamp?' translated
		format: {unchangedMethods size}))
		ifTrue:
			[loader := MCPackageLoader new.
			unchangedMethods do: [:op | op inverse applyTo: loader].
			loader loadWithName: self changeSetNameForInstall].

]

{ #category : #accessing }
MCOperationsBrowser >> reverts [
	^ reverts ifNil: [reverts := Set new]
]

{ #category : #subclassResponsibility }
MCOperationsBrowser >> selectedClass [
	| definition |
	selection ifNil: [ ^nil ].
	(definition := selection definition) ifNil: [ ^nil ].
	definition isMethodDefinition ifFalse: [ ^nil ].
	definition className in: [:className | | environment |
		environment := self environmentInDisplayingImage.
		^ environment at: className ifAbsent: [environment valueOf: className]]
]

{ #category : #subclassResponsibility }
MCOperationsBrowser >> selectedClassOrMetaClass [
	| definition |
	selection ifNil: [ ^nil ].
	(definition := selection definition) ifNil: [ ^nil ].
	(definition isMethodDefinition or: [definition isClassDefinition]) ifFalse: [ ^nil ].
	^ definition actualClassIn: self environmentInDisplayingImage
]

{ #category : #subclassResponsibility }
MCOperationsBrowser >> selectedMessageCategoryName [
	| definition |
	selection ifNil: [ ^nil ].
	(definition := selection definition) ifNil: [ ^nil ].
	definition isMethodDefinition ifFalse: [ ^nil ].
	^definition category
]

{ #category : #subclassResponsibility }
MCOperationsBrowser >> selectedMessageName [
	| definition |
	selection ifNil: [ ^nil ].
	(definition := selection definition) ifNil: [ ^nil ].
	definition isMethodDefinition ifFalse: [ ^nil ].
	^definition  selector
]

{ #category : #selecting }
MCOperationsBrowser >> selection [
	^ selection 
		ifNil: [0]
		ifNotNil: [self items indexOf: selection]
]

{ #category : #selecting }
MCOperationsBrowser >> selection: aNumber [ 
	selection := self items
		at: aNumber
		ifAbsent: [  ].
	self
		 changed: #selection ;
		 changed: #text ;
		 changed: #annotations
]

{ #category : #text }
MCOperationsBrowser >> text [
	^ selection ifNil: [''] ifNotNil: [selection source]
]

{ #category : #text }
MCOperationsBrowser >> text: aTextOrString [
	self changed: #text
]

{ #category : #accessing }
MCOperationsBrowser >> unchangedMethods [
	^ items select: [:op | op isUnchangedMethod]
]

{ #category : #ui }
MCOperationsBrowser >> widgetSpecs [
	Preferences annotationPanes ifFalse: [ ^#(
		((listMorph:selection:menu:keystroke: list selection methodListMenu: methodListKey:from:) (0 0 1 0.4) (0 0 0 0))
		((textMorph: text) (0 0.4 1 1))
		) ].

	^ #(
		((listMorph:selection:menu:keystroke: list selection methodListMenu: methodListKey:from:) (0 0 1 0.4) (0 0 0 0))
		((textMorph: annotations) (0 0.4 1 0.4) (0 0 0 defaultAnnotationPaneHeight))
		((textMorph: text) (0 0.4 1 1) (0 defaultAnnotationPaneHeight 0 0))
	)
]
