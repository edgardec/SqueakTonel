Class {
	#name : #MethodMorph,
	#superclass : #PluggableTextMorph,
	#category : #'Etoys-Scripting'
}

{ #category : #'as yet unclassified' }
MethodMorph class >> defaultNameStemForInstances [
	^ 'Method' translatedNoop
]

{ #category : #'new-morph participation' }
MethodMorph class >> includeInNewMorphMenu [
	"Not to be instantiated from the menu"
	^ false
]

{ #category : #initialization }
MethodMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	
]

{ #category : #'as yet unclassified' }
MethodMorph >> installRollBackButtons: target [
	| mine |
	"If I don't already have such a button, put one in at the upper right.  Set its target to the furtherest enclosing book.  Send chooseAndRevertToVersion when clicked.  Stay in place via scrollBar install."

	mine := self submorphNamed: #chooseAndRevertToVersion ifNone: [nil].
	mine ifNil: [mine := SimpleButtonMorph new.
		"mine height: mine height - 2."
		mine label: 'Roll Back'; cornerStyle: #square.
		mine color: Color white; borderColor: Color black.
		mine actionSelector: #chooseAndRevertToVersion.
		mine align: mine topRight with: (self findA: ScrollBar) topLeft +(1@1).
		self addMorphFront: mine.
		mine height: mine height - 5 "14"].
	mine target: target.
]

{ #category : #scrolling }
MethodMorph >> showScrollBar [
	"Copied down and modified to get rid of the ruinous comeToFront of the inherited version."

	| scriptor |
	(submorphs includes: scrollBar)
		ifTrue: [^ self].
	self vResizeScrollBar.
	self privateAddMorph: scrollBar atIndex: 1.
	retractableScrollBar
		ifTrue:
			["Bring the pane to the front so that it is fully visible"
			"self comeToFront. -- thanks but no thanks"
			(scriptor := self ownerThatIsA: ScriptEditorMorph)
				ifNotNil:
					[scriptor comeToFront]]
		ifFalse: [self layoutChanged]
]

{ #category : #'stepping and presenter' }
MethodMorph >> step [
	model updateCodePaneIfNeeded
]

{ #category : #testing }
MethodMorph >> stepTime [
	^ 3000
]
