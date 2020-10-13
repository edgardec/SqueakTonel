"
Tests for the Morphic tool builder.
"
Class {
	#name : #MorphicToolBuilderTests,
	#superclass : #ToolBuilderTests,
	#category : #'MorphicTests-ToolBuilder'
}

{ #category : #support }
MorphicToolBuilderTests >> acceptWidgetText [
	widget hasUnacceptedEdits: true.
	widget accept.
]

{ #category : #support }
MorphicToolBuilderTests >> buttonWidgetEnabled [
	"Answer whether the current widget (a button) is currently enabled"
	^widget enabled
]

{ #category : #support }
MorphicToolBuilderTests >> changeListWidget [
	widget changeModelSelection: widget getCurrentSelectionIndex + 1.
]

{ #category : #support }
MorphicToolBuilderTests >> expectedButtonSideEffects [
	^#()
]

{ #category : #support }
MorphicToolBuilderTests >> fireButtonWidget [
	widget performAction.
]

{ #category : #support }
MorphicToolBuilderTests >> fireMenuItemWidget [
	(widget itemWithWording: 'Menu Item')
		ifNotNil: [:item | item doButtonAction]
]

{ #category : #support }
MorphicToolBuilderTests >> getState [
	queries add: #getState.
	^false
]

{ #category : #'tests-button' }
MorphicToolBuilderTests >> makeButton [
	super makeButton.
	widget wantsGradient: false.
	^ widget
]

{ #category : #support }
MorphicToolBuilderTests >> setUp [
	super setUp.
	builder := MorphicToolBuilder new.
]

{ #category : #'tests-window' }
MorphicToolBuilderTests >> testWindowDynamicLabel [
	self makeWindow.
	self assert: (widget label = 'TestLabel').
]

{ #category : #'tests-window' }
MorphicToolBuilderTests >> testWindowStaticLabel [
	| spec |
	spec := builder pluggableWindowSpec new.
	spec model: self.
	spec children: #().
	spec label: 'TestLabel'.
	widget := builder build: spec.
	self assert: (widget label = 'TestLabel').
]

{ #category : #support }
MorphicToolBuilderTests >> widgetColor [
	"Answer color from widget"
	^widget color
]
