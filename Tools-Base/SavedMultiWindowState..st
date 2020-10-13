"
A SavedMultiWindowState is a collection of states of inactive windows for a multi-window tool ui where one can select between multiple copies of a tool sharing a single system window, each tol having its own state.  It manages switching between windows, swapping unaccepted edit state (e.g. in text views) as it does so.

Instance Variables
	currentModelIndex:		<Integer>
	modelDependents:		<IdentitySet>
	modelStates:			<OrderedCollection of: (Array
													with: modelState <Object>
													with: unacceptedEditStates <WeakIdentityKeyDictionary>) >
	models:					<OrderedCollection of: Model>

currentModelIndex
	- index into models and modelStates of current window selection

modelDependents
	- set of all dependents

modelStates
	- the pairs of model-specific selection state and widget-specfic unaccepted edit state for each unselected/inactive window

models
	- the models for each window

"
Class {
	#name : #SavedMultiWindowState,
	#superclass : #Object,
	#instVars : [
		'models',
		'modelStates',
		'modelDependents',
		'currentModelIndex',
		'prototype'
	],
	#category : #'Tools-Base'
}

{ #category : #'instance creation' }
SavedMultiWindowState class >> on: aModel [
	^self new on: aModel
]

{ #category : #operations }
SavedMultiWindowState >> addNewWindow [
	self addWindow: prototype shallowCopy
]

{ #category : #operations }
SavedMultiWindowState >> addWindow: aModel [
	aModel multiWindowState: self.
	self assert: models size = modelStates size.
	models := models
					copyReplaceFrom: currentModelIndex + 1
					to: currentModelIndex
					with: (Array with: aModel).
	modelStates := modelStates
					copyReplaceFrom: currentModelIndex + 1
					to: currentModelIndex
					with: (Array with: self emptyEditState).
	self assert: models size = modelStates size.
	self selectWindowIndex: (currentModelIndex = 0 ifTrue: [currentModelIndex := 1] ifFalse: [currentModelIndex + 1]).
	self assert: models size = modelStates size.
	1 to: models size do:
		[:idx|
		self assert: (idx = currentModelIndex
					or: [(modelStates at: idx) isArray and: [(modelStates at: idx) size = 2]])]
]

{ #category : #operations }
SavedMultiWindowState >> copyWindow [
	self addWindow: (models at: currentModelIndex) copy breakDependents
]

{ #category : #accessing }
SavedMultiWindowState >> currentModelIndex [
	^currentModelIndex
]

{ #category : #selecting }
SavedMultiWindowState >> editState [
	| textState |
	textState := WeakIdentityKeyDictionary new.
	modelDependents do:
		[:dep|
		dep canHaveUnacceptedEdits ifTrue:
			[textState at: dep put: dep unacceptedEditState]].
	^textState
]

{ #category : #accessing }
SavedMultiWindowState >> emptyEditState [
	^#(nil ())
]

{ #category : #'initialize-release' }
SavedMultiWindowState >> initialize [
	models := OrderedCollection new.
	modelStates := OrderedCollection new.
	modelDependents := IdentitySet new.
	currentModelIndex := 0
]

{ #category : #accessing }
SavedMultiWindowState >> models [
	^models
]

{ #category : #testing }
SavedMultiWindowState >> okToClose [
	"Answer if the unaccepted edit states are void.  If they are not then
	 offer to select a window with non-empty unaccepted edit state."

	modelStates withIndexDo:
		[:savedState :index|
		savedState ifNotNil:
			[(savedState last anySatisfy: [:editState| editState notNil]) ifTrue:
				[(PopUpMenu
					confirm: 'One or more windows have unsaved changes.'
					trueChoice: 'Close Anyway'
					falseChoice: 'Select Unsaved') ifTrue: [^true].
				 self selectWindowIndex: index.
				 ^false]]].
	^true
]

{ #category : #'initialize-release' }
SavedMultiWindowState >> on: aModel [
	prototype := aModel shallowCopy.
	self addWindow: aModel
]

{ #category : #accessing }
SavedMultiWindowState >> prototype [
	^prototype
]

{ #category : #operations }
SavedMultiWindowState >> removeCurrentWindow [
	"Remove the current pane."
	| deletedIndex |
	self assert: models size > 1.
	self assert: models size = modelStates size.
	(models at: currentModelIndex) okToChange ifFalse:
		[^self].
	deletedIndex := currentModelIndex.
	self selectWindowIndex: (currentModelIndex = 1
								ifTrue: [currentModelIndex + 1]
								ifFalse: [currentModelIndex - 1]).
	models := models copyWithoutIndex: deletedIndex.
	modelStates :=  modelStates copyWithoutIndex: deletedIndex.
	currentModelIndex > deletedIndex ifTrue:
		[currentModelIndex := currentModelIndex - 1].
	(models at: currentModelIndex) changed: #relabel
]

{ #category : #selecting }
SavedMultiWindowState >> restoreEditState: aWeakDictionary [
	aWeakDictionary keysAndValuesDo:
		[:depOrNil :unacceptedEditState|
		depOrNil ifNotNil:
			[depOrNil unacceptedEditState: unacceptedEditState]]
]

{ #category : #selecting }
SavedMultiWindowState >> selectWindowIndex: index [
	| currentModel newModel newModelState |
	index = currentModelIndex ifTrue: [^self].

	currentModel := models at: currentModelIndex.
	newModel := models at: index.
	modelDependents addAll: currentModel dependents.
	modelStates at: currentModelIndex put: { currentModel saveMultiWindowState. self editState }.
	"the become makes things confusing.  currentModel will end up being newModel and vice verce"
	models swap: currentModelIndex with: index.
	currentModel become: newModel.
	currentModel := models at: currentModelIndex.
	newModel := models at: index.
	newModel myDependents: (DependentsArray withAll: modelDependents asArray).
	currentModel myDependents: nil.
	"Change currentModelIndex before restoreMultiWIndowState: so label index is shown correctly"
	currentModelIndex := index.
	newModelState := modelStates at: index.
	newModelState first ifNotNil: "emptyState has nil for savedModelState.  Don;t restore state for a new window"
		[:savedModelState| newModel restoreMultiWindowState: savedModelState].
	self restoreEditState: newModelState last.
	modelStates at: index put: nil.
	newModel changed: #relabel
]

{ #category : #operations }
SavedMultiWindowState >> selectWindowsMenu [
	| menu currentItem |
	menu := MenuMorph new defaultTarget: self.
	models withIndexDo:
		[:model :index| | modelLabel |
		modelLabel := index = currentModelIndex
							ifTrue: [model multiWindowName]
							ifFalse: [model multiWindowNameForState: (modelStates at: index) first].
		models size > 1 ifTrue:
			[modelLabel := index printString, '. ', modelLabel].
		menu
			add: (index = currentModelIndex
					ifTrue: [Text string: modelLabel attribute: TextEmphasis bold]
					ifFalse:
						[((modelStates at: index) last anySatisfy: [:editState| editState notNil])
							ifTrue: [Text string: modelLabel attribute: TextColor red]
							ifFalse: [modelLabel]])
			target: self
			selector: #selectWindowIndex:
			argument: index.
		index = currentModelIndex ifTrue:
			[currentItem := menu lastItem]].
	menu
		addLine;
		add: 'new window' target: self selector: #addNewWindow;
		add: 'copy this window' target: self selector: #copyWindow;
		add: 'remove this window' target: self selector: #removeCurrentWindow.
	models size <= 1 ifTrue:
		[menu lastItem isEnabled: false].
	menu selectItem: currentItem event: nil.
	^menu
]
