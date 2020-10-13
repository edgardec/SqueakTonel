"
I am a tool builder, that is an object which knows how to create concrete widgets from abstract specifications. Those specifications are used by tools which want to be able to function in diverse user interface paradigms, such as MVC, Morphic, Tweak, wxWidgets etc.

The following five specs must be supported by all implementations:
	* PluggableButton
	* PluggableList
	* PluggableText
	* PluggablePanel
	* PluggableWindow

The following specs are optional:
	* PluggableTree: If not supported, the tool builder must answer nil when asked for a pluggableTreeSpec. Substitution will require client support so clients must be aware that some tool builders may not support trees (MVC for example, or Seaside). See examples in FileListPlus or TestRunnerPlus.
	* PluggableMultiSelectionList: If multi-selection lists are not supported, tool builder will silently support regular single selection lists.
	* PluggableInputField: Intended as a HINT for the builder that this widget will be used as a single line input field. Unless explicitly supported it will be automatically substituted by PluggableText.
	* PluggableActionButton: Intended as a HINT for the builder that this widget will be used as push (action) button. Unless explicitly supported it will be automatically substituted by PluggableButton.
	* PluggableRadioButton: Intended as a HINT for the builder that this widget will be used as radio button. Unless explicitly supported it will be automatically substituted by PluggableButton.
	* PluggableCheckBox: Intended as a HINT for the builder that this widget will be used as check box. Unless explicitly supported it will be automatically substituted by PluggableButton.

"
Class {
	#name : #ToolBuilder,
	#superclass : #Object,
	#instVars : [
		'parent'
	],
	#category : #'ToolBuilder-Kernel'
}

{ #category : #'instance creation' }
ToolBuilder class >> build: aClass [
	^self default build: aClass
]

{ #category : #accessing }
ToolBuilder class >> default [
	"Answer the default tool builder"
	^ Project uiManager toolBuilder

]

{ #category : #accessing }
ToolBuilder class >> findDefault [
	"Answer a default tool builder"
	| builderClass |
	"Note: The way the following is phrased ensures that you can always make 'more specific' builders merely by subclassing a tool builder and implementing a more specific way of reacting to #isActiveBuilder. For example, a BobsUIToolBuilder can subclass MorphicToolBuilder and (if enabled, say Preferences useBobsUITools) will be considered before the parent (generic MorphicToolBuilder)."
	builderClass := self allSubclasses 
		detect:[:any| any isActiveBuilder and:[
			any subclasses noneSatisfy:[:sub| sub isActiveBuilder]]] ifNone:[nil].
	builderClass ifNotNil: [^builderClass ].
	^self error: 'ToolBuilder not found'
]

{ #category : #services }
ToolBuilder class >> getBoundsForWindow: window [
	"Return the bounds for the given window."

	self subclassResponsibility.
]

{ #category : #accessing }
ToolBuilder class >> isActiveBuilder [
	"Answer whether I am the currently active builder"
	^false
]

{ #category : #'instance creation' }
ToolBuilder class >> open: aClass [
	^self default open: aClass
]

{ #category : #'instance creation' }
ToolBuilder class >> open: aClass label: aString [
	^self default open: aClass label: aString
]

{ #category : #services }
ToolBuilder class >> setBoundsForWindow: window to: rectangle [
	"Set the bounds for the given window."

	self subclassResponsibility.
]

{ #category : #building }
ToolBuilder >> build: anObject [
	"Build the given object using this tool builder"
	^anObject buildWith: self
]

{ #category : #building }
ToolBuilder >> buildAll: aList in: newParent [
	"Build the given set of widgets in the new parent"
	| prior |
	aList ifNil:[^self].
	prior := parent.
	parent := newParent.
	aList do:[:each| each buildWith: self].
	parent := prior.

]

{ #category : #'widgets optional' }
ToolBuilder >> buildPluggableActionButton: spec [
	^self buildPluggableButton: spec
]

{ #category : #'widgets optional' }
ToolBuilder >> buildPluggableAlternateMultiSelectionList: aSpec [
	
	^ self buildPluggableList: aSpec
]

{ #category : #'widgets required' }
ToolBuilder >> buildPluggableButton: aSpec [
	^self subclassResponsibility
]

{ #category : #'widgets optional' }
ToolBuilder >> buildPluggableCheckBox: spec [
	^self buildPluggableButton: spec
]

{ #category : #'widgets optional' }
ToolBuilder >> buildPluggableCodePane: aSpec [
	^self buildPluggableText: aSpec
]

{ #category : #'widgets optional' }
ToolBuilder >> buildPluggableDialog: spec [

	| windowSpec |
	windowSpec := self pluggableWindowSpec new.
	windowSpec children: (spec children ifNil: [OrderedCollection new]).
	
	"TODO: Convert the dialog's message into some element in the children."
		
	spec buttons ifNotNil: [:buttons | windowSpec children addAll: buttons].
	windowSpec
		model: spec model;
		extent: spec extent;
		label: spec title.
	^ self buildPluggableWindow: windowSpec
]

{ #category : #'widgets optional' }
ToolBuilder >> buildPluggableDropDownList: spec [
	^self buildPluggableList: spec
]

{ #category : #'widgets optional' }
ToolBuilder >> buildPluggableInputField: aSpec [
	^self buildPluggableText: aSpec
]

{ #category : #'widgets required' }
ToolBuilder >> buildPluggableList: aSpec [
	^self subclassResponsibility
]

{ #category : #'widgets required' }
ToolBuilder >> buildPluggableMenu: menuSpec [ 

	self subclassResponsibility.
]

{ #category : #'widgets required' }
ToolBuilder >> buildPluggableMenuItem: menuSpec [ 

	self subclassResponsibility.
]

{ #category : #'widgets required' }
ToolBuilder >> buildPluggableMultiColumnList: aSpec [
	^self subclassResponsibility
]

{ #category : #'widgets optional' }
ToolBuilder >> buildPluggableMultiSelectionList: aSpec [
	^self buildPluggableList: aSpec
]

{ #category : #'widgets required' }
ToolBuilder >> buildPluggablePanel: aSpec [
	^self subclassResponsibility
]

{ #category : #'widgets optional' }
ToolBuilder >> buildPluggableRadioButton: spec [
	^self buildPluggableButton: spec
]

{ #category : #'widgets optional' }
ToolBuilder >> buildPluggableScrollPane: spec [

	^ spec children
		ifNotNil: [self buildPluggablePanel: spec]
		ifNil: [spec morph ifNil: [spec morphClass new]]
]

{ #category : #'widgets required' }
ToolBuilder >> buildPluggableSpacer: aSpec [

	^ self subclassResponsibility
]

{ #category : #'widgets required' }
ToolBuilder >> buildPluggableText: aSpec [
	^self subclassResponsibility
]

{ #category : #'widgets required' }
ToolBuilder >> buildPluggableTree: aSpec [
	^self subclassResponsibility
]

{ #category : #'widgets required' }
ToolBuilder >> buildPluggableWindow: aSpec [
	^self subclassResponsibility
]

{ #category : #opening }
ToolBuilder >> close: aWidget [
	"Close a previously opened widget"
	^self subclassResponsibility
]

{ #category : #initialize }
ToolBuilder >> initialize [

]

{ #category : #opening }
ToolBuilder >> open: anObject [
	"Build and open the object. Answer the widget opened."
	^self subclassResponsibility
]

{ #category : #opening }
ToolBuilder >> open: anObject label: aString [
	"Build an open the object, labeling it appropriately.  Answer the widget opened."
	^self subclassResponsibility
]

{ #category : #opening }
ToolBuilder >> openDebugger: aSpec [
	"Build and open a debugger from the given spec.
	Answer the widget opened. Subclasses can override this
	method if opening a debugger has specific requirements
	different from opening other widgets."
 
	^ self open: aSpec

]

{ #category : #opening }
ToolBuilder >> openDebugger: aSpec label: aString [
	"Build and open a debugger from the given spec, labeling it appropriately.
	Answer the widget opened. Subclasses can override this
	method if opening a debugger has specific requirements
	different from opening other widgets."
 
	^self open: aSpec label: aString

]

{ #category : #opening }
ToolBuilder >> openDebugger: aSpec label: aString closing: topView [
	"Build and open a debugger from the given spec, labeling it appropriately.
	Answer the widget opened. Subclasses can override this
	method if opening a debugger has specific requirements
	different from opening other widgets."
 
	self close: topView.
	^ self open: aSpec label: aString

]

{ #category : #accessing }
ToolBuilder >> parent [
	^parent
]

{ #category : #accessing }
ToolBuilder >> parent: aWidget [
	parent := aWidget
]

{ #category : #defaults }
ToolBuilder >> pluggableActionButtonSpec [
	^PluggableActionButtonSpec
]

{ #category : #defaults }
ToolBuilder >> pluggableAlternateMultiSelectionListSpec [
	^ PluggableAlternateMultiSelectionListSpec
]

{ #category : #defaults }
ToolBuilder >> pluggableButtonSpec [
	^PluggableButtonSpec
]

{ #category : #defaults }
ToolBuilder >> pluggableCheckBoxSpec [
	^PluggableCheckBoxSpec
]

{ #category : #defaults }
ToolBuilder >> pluggableCodePaneSpec [
	^PluggableCodePaneSpec
]

{ #category : #defaults }
ToolBuilder >> pluggableDialogSpec [
	^PluggableDialogSpec
]

{ #category : #defaults }
ToolBuilder >> pluggableDropDownListSpec [
	^PluggableDropDownListSpec
]

{ #category : #defaults }
ToolBuilder >> pluggableInputFieldSpec [
	^PluggableInputFieldSpec
]

{ #category : #defaults }
ToolBuilder >> pluggableListSpec [
	^PluggableListSpec
]

{ #category : #defaults }
ToolBuilder >> pluggableMenuSpec [
	^ PluggableMenuSpec
]

{ #category : #defaults }
ToolBuilder >> pluggableMultiColumnListSpec [
	^PluggableMultiColumnListSpec
]

{ #category : #defaults }
ToolBuilder >> pluggableMultiSelectionListSpec [
	^PluggableMultiSelectionListSpec
]

{ #category : #defaults }
ToolBuilder >> pluggablePanelSpec [
	^PluggablePanelSpec
]

{ #category : #defaults }
ToolBuilder >> pluggableRadioButtonSpec [
	^PluggableRadioButtonSpec
]

{ #category : #defaults }
ToolBuilder >> pluggableScrollPaneSpec [
	^ PluggableScrollPaneSpec
]

{ #category : #defaults }
ToolBuilder >> pluggableSpacerSpec [
	^ PluggableSpacerSpec
]

{ #category : #defaults }
ToolBuilder >> pluggableTextSpec [
	^PluggableTextSpec
]

{ #category : #defaults }
ToolBuilder >> pluggableTreeSpec [
	^PluggableTreeSpec
]

{ #category : #defaults }
ToolBuilder >> pluggableWindowSpec [
	^PluggableWindowSpec
]

{ #category : #opening }
ToolBuilder >> runModal: aWidget [
	"Run the (previously opened) widget modally, e.g., 
	do not return control to the sender before the user has responded."
	^self subclassResponsibility
]

{ #category : #accessing }
ToolBuilder >> widgetAt: widgetID [
	"Answer the widget with the given ID"
	^self widgetAt: widgetID ifAbsent:[nil]
]

{ #category : #accessing }
ToolBuilder >> widgetAt: widgetID ifAbsent: aBlock [
	"Answer the widget with the given ID"
	^aBlock value
]
