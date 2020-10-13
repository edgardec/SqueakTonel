"
A MorphicUIBugTest is a class for testing the shortcomings and repairs of the MorphicUI manager.
.

Instance Variables
	cases:		<aCollection>

cases
	- a list of morphs that may need to be deleted during teardown.
	the tests are expected to fill this list it starts out empty by default.
	
	

"
Class {
	#name : #MorphicUIManagerTest,
	#superclass : #TestCase,
	#instVars : [
		'cases',
		'uiManager'
	],
	#category : #'MorphicTests-ToolBuilder'
}

{ #category : #accessing }
MorphicUIManagerTest >> defaultTimeout [
	^ super defaultTimeout * 10 "seconds"
]

{ #category : #private }
MorphicUIManagerTest >> findWindowInWorldLabeled: aLabel [
	"Look in the world and in the hand for windows. Yes, windows may spawn in the hand."
	| world |
	world := Project current world.
	^ world submorphs, (world hands gather: [:hand | hand submorphs])
		detect: [ :each |
			each isSystemWindow
				and: [ each label = aLabel ] ]
		ifNone: [].
]

{ #category : #'initialize-release' }
MorphicUIManagerTest >> setUp [
	"default. tests will add morphs to list. Teardown will delete."

	cases := #().
	uiManager := MorphicUIManager new.
]

{ #category : #'initialize-release' }
MorphicUIManagerTest >> tearDown [
	"default. tests will add morphs to list. Teardown will delete."

	cases do: [ :each | each delete ].
]

{ #category : #tests }
MorphicUIManagerTest >> testOpenWorkspace [
	"self new testOpenWorkspace"
	"MorphicUIBugTest run: #testOpenWorkspace"
	
	| window myLabel foundWindow myModel |
	myLabel := 'Workspace from SUnit test' .
	foundWindow := self findWindowInWorldLabeled: myLabel .
	self assert: foundWindow isNil.
	
	window := uiManager edit: '"MorphicUIBugTest run: #openWorkspaceTest"'  label: myLabel.
	foundWindow := self findWindowInWorldLabeled: myLabel.
	cases := Array with: foundWindow . "For teardown."

	myModel := foundWindow submorphs detect: #isMorphicModel.
	self assert: myModel model class == Workspace.
	self assert: foundWindow model class == Workspace.
]

{ #category : #tests }
MorphicUIManagerTest >> testOpenWorkspaceAns [
	"Test if method opening a workspace answers the window opened"

	"MorphicUIBugTest run: #testOpenWorkspaceAns"

	| window myLabel foundWindow |
	myLabel := 'Workspace from ', 'SUnit test' .
	foundWindow := self findWindowInWorldLabeled: myLabel .
	self assert: ( foundWindow isNil ) .

	window := uiManager edit: '"MorphicUIBugTest run: #openWorkspaceTest"'  label: myLabel.
	foundWindow := self findWindowInWorldLabeled: myLabel .
	
	cases := Array with: foundWindow . "For teardown."
	self assert: ( window == foundWindow ) .
]

{ #category : #tests }
MorphicUIManagerTest >> testShowAllBinParts [
	"self new testShowAllBinParts"
	"MorphicUIBugTest run: #testShowAllBinParts"

	| tool |
	self
		shouldnt: [tool := ObjectsTool  initializedInstance showAll openCenteredInWorld]
		raise: Error.
	
	cases := Array with: tool.
]

{ #category : #tests }
MorphicUIManagerTest >> testUIManagerNoAcceptInitially [
	"Ensure that UIManager does not invoke the accept: action initially."

	| accepted window |
	accepted := false.
	window := uiManager edit: Text new label: 'Test' accept: [:val| accepted := true].
	window delete.
	self deny: accepted.
]
