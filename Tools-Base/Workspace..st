"
A Workspace is a text area plus a lot of support for executable code.  It is a great place to execute top-level commands to compute something useful, and it is a great place to develop bits of a program before those bits get put into class methods.

To open a new workspace, execute:

	Workspace open


A workspace can have its own variables, called ""workspace variables"", to hold intermediate results.  For example, if you type into a workspace ""x := 5"" and do-it, then later you could type in ""y := x * 2"" and y would become 10.

Additionally, in Morphic, a workspace can gain access to morphs that are on the screen.  If acceptDroppedMorphs is turned on, then whenever a morph is dropped on the workspace, a variable will be created which references that morph.  This functionality is toggled with the window-wide menu of a workspace.


The instance variables of this class are:

	bindings  -  holds the workspace variables for this workspace

	acceptDroppedMorphs - whether dropped morphs should create new variables
"
Class {
	#name : #Workspace,
	#superclass : #StringHolder,
	#instVars : [
		'bindings',
		'acceptDroppedMorphs',
		'acceptAction',
		'mustDeclareVariables',
		'shouldStyle',
		'environment'
	],
	#classVars : [
		'LookupPools',
		'ShouldStyle'
	],
	#category : #'Tools-Base'
}

{ #category : #'lookup pools' }
Workspace class >> addLookupPool: sharedPool [
	"Add a SharedPool that bindings should be looked up in."
	LookupPools ifNil: [LookupPools := IdentitySet new].
	LookupPools add: sharedPool
]

{ #category : #'lookup pools' }
Workspace class >> clearLookupPools [
	LookupPools := nil.

]

{ #category : #'instance creation' }
Workspace class >> prototypicalToolWindow [
	"Answer an example of myself seen in a tool window, for the benefit of parts-launching tools"

	| aWorkspace |
	aWorkspace := ToolBuilder build: self new.
	^ aWorkspace
]

{ #category : #'lookup pools' }
Workspace class >> removeLookupPool: sharedPool [
	"Workspaces should no longer look up bindings in the specified SharedPool."
	LookupPools ifNil: [^self].
	LookupPools remove: sharedPool ifAbsent: [].
]

{ #category : #preferences }
Workspace class >> shouldStyle [
	<preference: 'Shout styling in Workspace' 
		category: 'browsing' 
		description: 'If true, new workspaces use Shout to style their contents.' 
		type: #Boolean>
	^ ShouldStyle ifNil: [ false ]
]

{ #category : #preferences }
Workspace class >> shouldStyle: aBoolean [

	ShouldStyle := aBoolean
]

{ #category : #'code pane' }
Workspace >> aboutToStyle: aStyler [

	self shouldStyle ifFalse: [ ^false ].
	aStyler 
		classOrMetaClass: nil;
		workspace: self.
	^true
]

{ #category : #accessing }
Workspace >> acceptAction [
	^acceptAction
]

{ #category : #accessing }
Workspace >> acceptAction: anAction [
	acceptAction := anAction.
]

{ #category : #accessing }
Workspace >> acceptContents: aString [
	acceptAction ifNotNil:[acceptAction value: aString].
	^super acceptContents: aString.
]

{ #category : #'drag and drop' }
Workspace >> acceptDroppedMorphsWording [

	^ self acceptsDroppingMorphForReference
		ifTrue: ['<yes> create textual references to dropped morphs' translated]
		ifFalse: ['<no> create textual references to dropped morphs' translated]

]

{ #category : #'drag and drop' }
Workspace >> acceptDroppingMorph: dropee event: evt inMorph: targetMorph [ 
	"Return the dropee to its old position, and add a reference to it at the
	cursor point."
	| bindingName externalName reference |
	(dropee isKindOf: TransferMorph)
		ifTrue: [reference := dropee passenger.
			externalName := dropee passenger className]
		ifFalse: [reference := dropee.
			externalName := dropee externalName].
	externalName := externalName isOctetString
				ifTrue: [externalName]
				ifFalse: ['a' , externalName].
	bindingName := externalName withFirstCharacterDownshifted , reference identityHash printString.
	targetMorph correctSelectionWithString: bindingName , ' '.
	(self bindingOf: bindingName)
		value: reference.
	(dropee isKindOf: TransferMorph)
		ifFalse: [dropee rejectDropMorphEvent: evt].
	^ true"success"
]

{ #category : #'drag and drop' }
Workspace >> acceptsDroppingMorphForReference [

	^ acceptDroppedMorphs
		

]

{ #category : #'drag and drop' }
Workspace >> acceptsDroppingMorphForReference: trueFalse [

	acceptDroppedMorphs := trueFalse
		

]

{ #category : #'menu commands' }
Workspace >> addModelItemsToWindowMenu: aMenu [ 
	
	aMenu addLine.
	aMenu
		add: 'save contents to file...'
		target: self
		action: #saveContentsInFile.
	aMenu
		add: 'inspect variables'
		target: self
		action: #inspectBindings.
	aMenu
		add: 'reset variables'
		target: self
		action: #initializeBindings.
	aMenu
		addUpdating: #mustDeclareVariableWording
		target: self
		action: #toggleVariableDeclarationMode.
	aMenu
		addUpdating: #acceptDroppedMorphsWording
		target: self
		action: #toggleDroppingMorphForReference.

	self addToggleStylingMenuItemTo: aMenu.

]

{ #category : #'code pane menu' }
Workspace >> addToggleStylingMenuItemTo: aMenu [
	
	aMenu
		addUpdating: #toggleStylingLabel
		target: self
		action: #toggleStyling
]

{ #category : #'menu commands' }
Workspace >> appendContentsOfFile [
	"Prompt for a file, and if one is obtained, append its contents to the contents of the receiver.   Caution: as currently implemented this abandons any custom style information previously in the workspace.  Someone should fix this.  Also, for best results you should accept the contents of the workspace before requesting this."

	| fName |
	fName := UIManager default chooseFileMatching: '*' label: 'Choose file to add to workspace'.
	fName ifNil:[^self].
	
	FileStream oldFileNamed: fName do:[:aFileStream|
		contents := (contents ifNil: ['']) asString, aFileStream contentsOfEntireFile].
	self changed: #contents
]

{ #category : #binding }
Workspace >> bindingOf: aString [ 
	mustDeclareVariables ifTrue: [^ nil].
	"I want to have workspace that force the user to declare  
	variables. Still subclasses may want to do something else"
	(bindings includesKey: aString) ifFalse: [
		(self lookupInPools: aString)
			ifNotNil: [:val |
				"Caveat: since we're not inserting the pool's Association into
				 the dictionary, assigning a new value to the variable will only
				 affect the one Workspace (i.e. you can't assign to a variable in a
				 SharedPool)."
				bindings at: aString put: val]
			ifNil: [aString first isUppercase
					ifTrue: [^nil]
					ifFalse: [bindings at: aString put: nil]]
	].
	^ bindings associationAt: aString
]

{ #category : #toolbuilder }
Workspace >> buildCodePaneWith: builder [
	| textSpec |
	textSpec := builder pluggableCodePaneSpec new.
	textSpec 
		model: self;
		getText: #contents; 
		setText: #contents:notifying:; 
		selection: #contentsSelection; 
		menu: #codePaneMenu:shifted:.
	^textSpec
]

{ #category : #accessing }
Workspace >> contents: textOrString [
	super contents: textOrString.
	self changed: #contents.
]

{ #category : #'object fileIn' }
Workspace >> convertToCurrentVersion: varDict refStream: smartRefStrm [
	
	acceptDroppedMorphs ifNil: [acceptDroppedMorphs := false].
	^super convertToCurrentVersion: varDict refStream: smartRefStrm.


]

{ #category : #accessing }
Workspace >> environment [
	^ environment ifNil: [Smalltalk globals]
]

{ #category : #accessing }
Workspace >> environment: anEnvironment [
	
	environment := anEnvironment.
]

{ #category : #'menu commands' }
Workspace >> expressionEvaluated: anExpression result: anObject [

	self changed: #style
]

{ #category : #binding }
Workspace >> hasBindingOf: aString [ 
	^bindings includesKey: aString
]

{ #category : #'initialize-release' }
Workspace >> initialExtent [
 "Start small.  Window aspect ratio is 5 sqrt::1 . Good asthetics. -wiz"
	
	^ 447@200
]

{ #category : #'initialize-release' }
Workspace >> initialize [
	
	super initialize.
	self initializeBindings.
	acceptDroppedMorphs := false.
	mustDeclareVariables := false.
	environment := Environment current.
]

{ #category : #binding }
Workspace >> initializeBindings [
	
	bindings := Dictionary new
]

{ #category : #binding }
Workspace >> inspectBindings [
	
	bindings inspect
]

{ #category : #binding }
Workspace >> lookupInPools: aString [ 
	"Iterate through all of the lookup pools to find a match for the specified name."
	LookupPools ifNil: [^nil].
	LookupPools do: [:pool | (pool bindingOf: aString) ifNotNil: [:assoc | ^assoc value]].
	^nil

]

{ #category : #'variable declarations' }
Workspace >> mustDeclareVariableWording [
	
	^ mustDeclareVariables not
		ifTrue: ['<yes> automatically create variable declaration' translated]
		ifFalse: ['<no> automatically create variable declaration' translated]
]

{ #category : #accessing }
Workspace >> mustDeclareVariables: aBoolean [

	mustDeclareVariables := aBoolean
]

{ #category : #'menu commands' }
Workspace >> saveContentsInFile [
	"Pass along this message to the controller or morph.  (Possibly this Workspace menu item could be deleted, since it's now in the text menu.)"

	self changed: #saveContents

]

{ #category : #accessing }
Workspace >> setBindings: aDictionary [
	"Sets the Workspace to use the specified dictionary as its namespace"

	bindings := aDictionary.

]

{ #category : #'code pane menu' }
Workspace >> shouldStyle [

	^shouldStyle ifNil: [ self class shouldStyle ]
]

{ #category : #'code pane menu' }
Workspace >> shouldStyle: aBool [
	"If true, contents will by rendered w/ syntax-highlighting"

	shouldStyle := aBool
]

{ #category : #'drag and drop' }
Workspace >> toggleDroppingMorphForReference [

	acceptDroppedMorphs := acceptDroppedMorphs not.
		

]

{ #category : #'code pane menu' }
Workspace >> toggleStyling [

	shouldStyle := self shouldStyle not.
	self changed: #style.
]

{ #category : #'code pane menu' }
Workspace >> toggleStylingLabel [

	^self shouldStyle 
		ifTrue: [ '<on> syntax highlighting' ]
		ifFalse: [ '<off> syntax highlighting' ]
]

{ #category : #'variable declarations' }
Workspace >> toggleVariableDeclarationMode [

	mustDeclareVariables := mustDeclareVariables not
]

{ #category : #accessing }
Workspace >> wantsAnnotationPane [
	"We have nothing to annotate"
	^false
]

{ #category : #'drag and drop' }
Workspace >> wantsDroppedMorph: dropee event: evt inMorph: target [

	^ acceptDroppedMorphs or: [dropee isKindOf: TransferMorph]
		

]

{ #category : #accessing }
Workspace >> wantsOptionalButtons [
	"We have no optional buttons (yet)"
	^false
]
