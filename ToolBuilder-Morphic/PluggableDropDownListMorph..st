Class {
	#name : #PluggableDropDownListMorph,
	#superclass : #AlignmentMorph,
	#instVars : [
		'model',
		'listSelector',
		'selectionSelector',
		'selectionSetter'
	],
	#category : #'ToolBuilder-Morphic'
}

{ #category : #drawing }
PluggableDropDownListMorph >> basicPanel [
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

{ #category : #accessing }
PluggableDropDownListMorph >> currentSelection [

	^ self model perform: selectionSelector
]

{ #category : #accessing }
PluggableDropDownListMorph >> currentSelection: obj [

	^ self model perform: selectionSetter with: obj
]

{ #category : #drawing }
PluggableDropDownListMorph >> horizontalPanel [
	^self basicPanel
		cellPositioning: #center;
		listDirection: #leftToRight;
		yourself.
]

{ #category : #drawing }
PluggableDropDownListMorph >> installDropDownList [

	| aButton aLabel |
	aButton := PluggableButtonMorph on: self model getState: nil action: nil.
	aLabel := (StringMorph contents: self model currentRemoteVatId translated
				font: (StrikeFont familyName: TextStyle defaultFont familyName
							pointSize: TextStyle defaultFont pointSize - 1)).
	self addMorph: (self horizontalPanel
		addMorphBack: aLabel;
		addMorphBack: aButton;
		yourself).
]

{ #category : #accessing }
PluggableDropDownListMorph >> list [
	"Answer the value of list"

	^ self model perform: self listSelector.
	
]

{ #category : #accessing }
PluggableDropDownListMorph >> listSelector [
	"Answer the value of listSelector"

	^ listSelector
]

{ #category : #accessing }
PluggableDropDownListMorph >> listSelector: anObject [
	"Set the value of listSelector"

	listSelector := anObject
]

{ #category : #accessing }
PluggableDropDownListMorph >> model [
	^ model
]

{ #category : #accessing }
PluggableDropDownListMorph >> model: anObject [
	"Set the value of model"

	model := anObject
]

{ #category : #accessing }
PluggableDropDownListMorph >> selectionSelector [
	"Answer the value of selectionSelector"

	^ selectionSelector
]

{ #category : #accessing }
PluggableDropDownListMorph >> selectionSelector: anObject [
	"Set the value of selectionSelector"

	selectionSelector := anObject
]

{ #category : #accessing }
PluggableDropDownListMorph >> selectionSetter [
	"Answer the value of selectionSetter"

	^ selectionSetter
]

{ #category : #accessing }
PluggableDropDownListMorph >> selectionSetter: anObject [
	"Set the value of selectionSetter"

	selectionSetter := anObject
]
