"
A pluggable panel morph which deals with changing children.
"
Class {
	#name : #PluggablePanelMorph,
	#superclass : #AlignmentMorph,
	#instVars : [
		'model',
		'getChildrenSelector'
	],
	#category : #'ToolBuilder-Morphic'
}

{ #category : #private }
PluggablePanelMorph >> canBeEncroached [
	^ submorphs allSatisfy:
		[ : each | each canBeEncroached ]
]

{ #category : #accessing }
PluggablePanelMorph >> children [
	^ model perform: getChildrenSelector
]

{ #category : #accessing }
PluggablePanelMorph >> getChildrenSelector [
	^getChildrenSelector
]

{ #category : #accessing }
PluggablePanelMorph >> getChildrenSelector: aSymbol [
	getChildrenSelector := aSymbol.
]

{ #category : #accessing }
PluggablePanelMorph >> model [
	^model
]

{ #category : #accessing }
PluggablePanelMorph >> model: aModel [
	model ifNotNil:[model removeDependent: self].
	model := aModel.
	model ifNotNil:[model addDependent: self].
]

{ #category : #update }
PluggablePanelMorph >> update: selectorSymbolOrNil [ 
	selectorSymbolOrNil ifNil: [ ^ self ].
	selectorSymbolOrNil = getChildrenSelector ifTrue:
		[ self
			 removeAllMorphs ;
			 addAllMorphs: self children .
			
		"Let my children take all the place unless my extent is described by them."
		self hResizing ~~ #shrinkWrap ifTrue:
			[ self submorphsDo: [ : m | m hResizing: #spaceFill ] ].
		self vResizing ~~ #shrinkWrap ifTrue:
			[ self submorphsDo: [ : m | m vResizing: #spaceFill ] ].
		
		"Tell dependents about this update. There is no pluggable notification for changed submorphs."
		self changed: #submorphs ].
]
