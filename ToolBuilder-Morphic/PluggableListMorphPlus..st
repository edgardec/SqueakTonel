"
Extensions for PluggableListMorph needed by ToolBuilder
"
Class {
	#name : #PluggableListMorphPlus,
	#superclass : #PluggableListMorph,
	#instVars : [
		'dragItemSelector',
		'dropItemSelector',
		'wantsDropSelector',
		'dragTypeSelector',
		'dragStartedSelector'
	],
	#category : #'ToolBuilder-Morphic'
}

{ #category : #'drag and drop' }
PluggableListMorphPlus >> acceptDroppingMorph: aTransferMorph event: evt [

	dropItemSelector ifNil: [^ self].
	potentialDropRow ifNil: [^ self].
	
	model
		perform: dropItemSelector
		withEnoughArguments: {
			aTransferMorph passenger.
			self modelIndexFor: potentialDropRow.
			aTransferMorph shouldCopy.
			aTransferMorph}.
			
	self resetPotentialDropRow.
	evt hand releaseMouseFocus: self.
	Cursor normal show.

]

{ #category : #accessing }
PluggableListMorphPlus >> dragItemSelector [
	^dragItemSelector
]

{ #category : #accessing }
PluggableListMorphPlus >> dragItemSelector: aSymbol [
	dragItemSelector := aSymbol.
	aSymbol ifNotNil:[self dragEnabled: true].
]

{ #category : #accessing }
PluggableListMorphPlus >> dragStartedSelector [
	^ dragStartedSelector
]

{ #category : #accessing }
PluggableListMorphPlus >> dragStartedSelector: symbol [
	dragStartedSelector := symbol.
]

{ #category : #accessing }
PluggableListMorphPlus >> dragTypeSelector [
	^dragTypeSelector
]

{ #category : #accessing }
PluggableListMorphPlus >> dragTypeSelector: aSymbol [
	dragTypeSelector := aSymbol.
]

{ #category : #accessing }
PluggableListMorphPlus >> dropItemSelector [
	^dropItemSelector
]

{ #category : #accessing }
PluggableListMorphPlus >> dropItemSelector: aSymbol [
	dropItemSelector := aSymbol.
	aSymbol ifNotNil:[self dropEnabled: true].
]

{ #category : #'drag and drop' }
PluggableListMorphPlus >> startDrag: evt [ 

	| item itemMorph modelIndex |	
	dragItemSelector ifNil:[^self].
	evt hand hasSubmorphs ifTrue: [^ self].
	self model okToChange ifFalse: [^ self].

	"Ensure selection to save additional click."
	(self modelIndexFor: (self rowAtLocation: evt position)) in: [:evtIndex |
		self selectionIndex = evtIndex ifFalse: [self changeModelSelection: evtIndex]].

	item := self selection ifNil: [^ self].
	itemMorph := StringMorph contents: item asStringOrText.
	modelIndex := self modelIndexFor: self selectionIndex.

	[ "Initiate drag."
		(self model perform: dragItemSelector with: modelIndex) ifNotNil: [:passenger | | ddm |
			ddm := (self valueOfProperty: #dragTransferClass ifAbsent: [TransferMorph]) withPassenger: passenger from: self.
			ddm dragTransferType: (self dragTypeSelector ifNotNil: [:s | self model perform: s with: modelIndex]).
			ddm updateFromUserInputEvent: evt.
			self dragStartedSelector ifNotNil: [:s | self model perform: s with: itemMorph with: ddm].
			evt hand grabMorph: ddm.
			self mouseEnterDragging: evt "Enable internal move"].
	] ensure: [Cursor normal show]
]

{ #category : #accessing }
PluggableListMorphPlus >> wantsDropSelector [
	^wantsDropSelector
]

{ #category : #accessing }
PluggableListMorphPlus >> wantsDropSelector: aSymbol [
	wantsDropSelector := aSymbol
]

{ #category : #'drag and drop' }
PluggableListMorphPlus >> wantsDroppedMorph: aTransferMorph event: anEvent [

	dropItemSelector ifNil: [^ false].
	(aTransferMorph isKindOf: TransferMorph) ifFalse: [^ false].
	wantsDropSelector ifNil: [^ true].

	^ model perform: wantsDropSelector withEnoughArguments: {
		aTransferMorph passenger.
		aTransferMorph dragTransferType.
		aTransferMorph source.
		aTransferMorph}
]
