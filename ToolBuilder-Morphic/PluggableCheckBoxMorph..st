Class {
	#name : #PluggableCheckBoxMorph,
	#superclass : #AlignmentMorph,
	#instVars : [
		'model',
		'actionSelector',
		'valueSelector',
		'label'
	],
	#category : #'ToolBuilder-Morphic'
}

{ #category : #'as yet unclassified' }
PluggableCheckBoxMorph class >> on: anObject getState: getStateSel action: actionSel label: labelSel [

	^ self new
		on: anObject
		getState: getStateSel
		action: actionSel
		label: labelSel
		menu: nil

]

{ #category : #accessing }
PluggableCheckBoxMorph >> actionSelector [
	"Answer the value of actionSelector"

	^ actionSelector
]

{ #category : #accessing }
PluggableCheckBoxMorph >> actionSelector: anObject [
	"Set the value of actionSelector"

	actionSelector := anObject
]

{ #category : #installing }
PluggableCheckBoxMorph >> basicPanel [
	^BorderedMorph new
		beTransparent;
		extent: 0@0;
		borderWidth: 0;
		layoutInset: 0;
		cellGap: 0;
		layoutPolicy: TableLayout new;
		listCentering: #topLeft;
		cellPositioning: #center;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		yourself
]

{ #category : #installing }
PluggableCheckBoxMorph >> horizontalPanel [
	^self basicPanel
		cellPositioning: #center;
		listDirection: #leftToRight;
		yourself.
]

{ #category : #initialization }
PluggableCheckBoxMorph >> initialize [

	super initialize.
	self color: Color transparent.
]

{ #category : #installing }
PluggableCheckBoxMorph >> installButton [

	| aButton |
	aButton := UpdatingThreePhaseButtonMorph checkBox
		target: self model;
		actionSelector: self actionSelector;
		getSelector: self valueSelector;
		label: self label;
		yourself.

	self addMorph: (self horizontalPanel
		addMorphBack: aButton;
		
		yourself).
]

{ #category : #accessing }
PluggableCheckBoxMorph >> label [
	"Answer the value of label"

	^ label
]

{ #category : #accessing }
PluggableCheckBoxMorph >> label: anObject [
	"Set the value of label"

	label := anObject
]

{ #category : #accessing }
PluggableCheckBoxMorph >> model [
	"Answer the value of model"

	^ model.

]

{ #category : #accessing }
PluggableCheckBoxMorph >> model: anObject [
	"Set the value of model"

	model := anObject
]

{ #category : #initialization }
PluggableCheckBoxMorph >> on: anObject getState: getStateSel action: actionSel label: labelSel menu: menuSel [

	self model: anObject.
	self valueSelector: getStateSel.
	self actionSelector: actionSel.
	self label: (self model perform: labelSel).

]

{ #category : #accessing }
PluggableCheckBoxMorph >> valueSelector [
	"Answer the value of valueSelector"

	^ valueSelector
]

{ #category : #accessing }
PluggableCheckBoxMorph >> valueSelector: anObject [
	"Set the value of valueSelector"

	valueSelector := anObject
]
