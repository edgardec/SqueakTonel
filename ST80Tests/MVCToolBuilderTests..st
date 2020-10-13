"
Tests for the MVC tool builder.
"
Class {
	#name : #MVCToolBuilderTests,
	#superclass : #ToolBuilderTests,
	#category : #ST80Tests
}

{ #category : #support }
MVCToolBuilderTests >> acceptWidgetText [
	widget hasUnacceptedEdits: true.
	widget controller accept.
]

{ #category : #support }
MVCToolBuilderTests >> changeListWidget [
	widget changeModelSelection: widget getCurrentSelectionIndex + 1.
]

{ #category : #support }
MVCToolBuilderTests >> expectedButtonSideEffects [
	^#(getState)
]

{ #category : #support }
MVCToolBuilderTests >> fireButtonWidget [
	widget performAction.
]

{ #category : #support }
MVCToolBuilderTests >> setUp [
	super setUp.
	builder := MVCToolBuilder new.
]

{ #category : #support }
MVCToolBuilderTests >> tearDown [
	ScreenController new restoreDisplay.
	super tearDown
]

{ #category : #'tests-not applicable' }
MVCToolBuilderTests >> testAddAction [
	"MVCToolBuilder does not implement #buildPluggableMenu:"
]

{ #category : #'tests-not applicable' }
MVCToolBuilderTests >> testAddTargetSelectorArgumentList [
	"MVCToolBuilder does not implement #buildPluggableMenu:"
]

{ #category : #'tests-not applicable' }
MVCToolBuilderTests >> testButtonFiresBlock [
	"MVC buttons only support action Symbols"
]

{ #category : #'tests-not applicable' }
MVCToolBuilderTests >> testButtonFiresMessage [
	"MVC buttons only support action Symbols, not MessageSends"
]

{ #category : #'tests-not applicable' }
MVCToolBuilderTests >> testButtonInitiallyDisabled [
	"MVC does not have button enablement"
]

{ #category : #'tests-not applicable' }
MVCToolBuilderTests >> testButtonInitiallyDisabledSelector [
	"MVC does not have button enablement"
]

{ #category : #'tests-not applicable' }
MVCToolBuilderTests >> testGetButtonColor [
	"MVC buttons do not have color"
]

{ #category : #'tests-not applicable' }
MVCToolBuilderTests >> testGetButtonEnabled [
	"MVC does not have button enablement"
]

{ #category : #'tests-not applicable' }
MVCToolBuilderTests >> testGetInputFieldColor [
	"MVC input fields do not have color"
]

{ #category : #'tests-not applicable' }
MVCToolBuilderTests >> testGetPanelChildren [
	"MVC panels do not allow changing children"
]

{ #category : #'tests-not applicable' }
MVCToolBuilderTests >> testGetTextColor [
	"not supported in MVC"
]

{ #category : #'tests-not applicable' }
MVCToolBuilderTests >> testGetWindowChildren [
	"not supported in MVC"
]

{ #category : #'tests-not applicable' }
MVCToolBuilderTests >> testGetWindowLabel [
	"not supported in MVC"
]

{ #category : #'tests-not applicable' }
MVCToolBuilderTests >> testTreeExpandPath [
	"MVCToollBuilder does not implement trees"
]

{ #category : #'tests-not applicable' }
MVCToolBuilderTests >> testTreeExpandPathFirst [
	"MVCToollBuilder does not implement trees"
]

{ #category : #'tests-not applicable' }
MVCToolBuilderTests >> testTreeGetSelectionPath [
	"MVCToollBuilder does not implement trees"
]

{ #category : #'tests-not applicable' }
MVCToolBuilderTests >> testTreeRoots [
	"MVCToollBuilder does not implement trees"
]

{ #category : #'tests-not applicable' }
MVCToolBuilderTests >> testTreeWidgetID [
	"MVCToollBuilder does not implement trees"
]

{ #category : #'tests-not applicable' }
MVCToolBuilderTests >> testWindowCloseAction [
	"This can only work if we're actually run in MVC"
	Project current isMVC ifTrue: [super testWindowCloseAction]
]
