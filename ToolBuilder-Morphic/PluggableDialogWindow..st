Class {
	#name : #PluggableDialogWindow,
	#superclass : #DialogWindow,
	#instVars : [
		'model',
		'getTitleSelector',
		'getMessageSelector',
		'getChildrenSelector',
		'getButtonsSelector',
		'closeDialogSelector'
	],
	#category : #'ToolBuilder-Morphic'
}

{ #category : #accessing }
PluggableDialogWindow >> closeDialogSelector [

	^ closeDialogSelector
]

{ #category : #accessing }
PluggableDialogWindow >> closeDialogSelector: anObject [

	closeDialogSelector := anObject
]

{ #category : #'submorphs-add\/remove' }
PluggableDialogWindow >> delete [

	self model okToClose ifFalse: [^ self].
	
	self closeDialogSelector ifNotNil: [:sel | self model perform: sel].
	
	self model
		windowIsClosing;
		release.
	self model: nil.
	
	super delete.
]

{ #category : #accessing }
PluggableDialogWindow >> getButtonsSelector [

	^ getButtonsSelector
]

{ #category : #accessing }
PluggableDialogWindow >> getButtonsSelector: anObject [

	getButtonsSelector := anObject
]

{ #category : #accessing }
PluggableDialogWindow >> getChildrenSelector [

	^ getChildrenSelector
]

{ #category : #accessing }
PluggableDialogWindow >> getChildrenSelector: anObject [

	getChildrenSelector := anObject
]

{ #category : #accessing }
PluggableDialogWindow >> getMessageSelector [

	^ getMessageSelector
]

{ #category : #accessing }
PluggableDialogWindow >> getMessageSelector: anObject [

	getMessageSelector := anObject
]

{ #category : #accessing }
PluggableDialogWindow >> getTitleSelector [

	^ getTitleSelector
]

{ #category : #accessing }
PluggableDialogWindow >> getTitleSelector: anObject [

	getTitleSelector := anObject
]

{ #category : #accessing }
PluggableDialogWindow >> model [
	^ model
]

{ #category : #accessing }
PluggableDialogWindow >> model: anObject [

	model ifNotNil: [model removeDependent: self].
	anObject ifNotNil: [anObject addDependent: self].
	model := anObject.
]

{ #category : #updating }
PluggableDialogWindow >> update: what [

	what ifNil:[^self].

	what == self getTitleSelector ifTrue:[self title: (model perform: self getTitleSelector)].
	what == self getMessageSelector ifTrue:[self message: (model perform: self getMessageSelector)].
	
	what == self getChildrenSelector ifTrue:[
		self paneMorph removeAllMorphs.
		(self model perform: self getChildrenSelector)
			do: [:m| m hResizing: #spaceFill; vResizing: #spaceFill];
			in: [:children | self paneMorph addAllMorphs: children]].

	what == self getButtonsSelector ifTrue:[
		self buttonRow
			removeAllMorphs;
			addAllMorphs: (self model perform: self getButtonsSelector).
		self updateButtonProperties].
	
	what == #close ifTrue: [^ self delete].

	super update: what.
]

{ #category : #updating }
PluggableDialogWindow >> updateButtonProperties [

	self buttons do: [:ea |
		ea setProperty: #normalColor toValue: ea offColor.
		ea setProperty: #normalLabel toValue: ea label.
		ea hResizing: #rigid; vResizing: #rigid].
	
	self updateButtonExtent.
]
