"
A watcher that follows its watchee around.

attachmentEdge:  can be #left, #right #bottom, #top, #topLeft, #topRight, #bottomLeft, #bottomRight, #center)

offset:  (x,y) offset from the nominal attachment point.
"
Class {
	#name : #FollowingWatcher,
	#superclass : #WatcherWrapper,
	#instVars : [
		'attachmentEdge',
		'offset'
	],
	#category : #'Etoys-Squeakland-Etoys-Scripting Support'
}

{ #category : #scripting }
FollowingWatcher class >> additionsToViewerCategories [
	"Answer a list of (<categoryName> <list of category specs>) pairs that characterize the phrases this kind of morph wishes to add to various Viewer categories."

	^ #((basic (
			(slot attachmentOffset  'the amounts by which the position of the watcher should be offset from the nominal attachment point' Point readWrite Player getAttachmentOffset  Player  setAttachmentOffset:)
			(slot attachmentEdge  'The attachment edge -- which edge or corner the watcher should be aligned with' AttachmentEdge readWrite Player getAttachmentEdge  Player  setAttachmentEdge:) 
)))
]

{ #category : #accessing }
FollowingWatcher >> addCustomMenuItems: aMenu hand: aHand [
	"Add morph-specific items to a menu."

	aMenu addUpdating:  #attachmentEdgeString  action: #chooseAttachmentEdge.

	aMenu add: ('offset (currently {1})' translated format: {offset printString}) action: #chooseOffset.
	aMenu balloonTextForLastItem: 'fine-tune the position of this watcher relative to its chosen attachment edge' translated
]

{ #category : #accessing }
FollowingWatcher >> attachmentEdge [
	"Answer the value of attachmentEdge"

	^ attachmentEdge
]

{ #category : #accessing }
FollowingWatcher >> attachmentEdge: anObject [
	"Set the value of attachmentEdge"

	attachmentEdge := anObject
]

{ #category : #accessing }
FollowingWatcher >> attachmentEdgeString [
	"Answer a string to serve as the wording of the menu item inviting the use to choose the attachment edge."

	^ 'choose attachment edge (now {1})' translated format: {attachmentEdge asString translated}
]

{ #category : #accessing }
FollowingWatcher >> attachmentOffset [
	"Answer the amount by which the watcher should be offset from its nominal attachment point near the watchee."

	^ offset
]

{ #category : #accessing }
FollowingWatcher >> attachmentOffset: anAmount [
	"Set the amount by which the watcher should be offset from its nominal attachment point near the watchee."

	offset := anAmount
]

{ #category : #initialization }
FollowingWatcher >> buildForPlayer: aPlayer getter: aGetter [ 
	"Build up basic structure"

	super buildForPlayer: aPlayer getter: aGetter.
	self firstSubmorph beTransparent; borderWidth: 0.
	self beTransparent; borderWidth: 0
]

{ #category : #initialization }
FollowingWatcher >> buildReadout: aGetter [
	"Build and answer a readout for the given getter."

	| readout |
	readout := super buildReadout: aGetter.
	((readout submorphs size > 0) and: [readout firstSubmorph isKindOf: StringMorph]) ifTrue:
		[readout firstSubmorph font: ScriptingSystem fontForAttachedWatchers; unlock].
	^ readout
]

{ #category : #copying }
FollowingWatcher >> burnishForReplacing [
	"Final appearance modifications before the receiver is inserted as a replacement for an earlier version of the watcher. "

	self allMorphsDo: [:m | (m isKindOf: StringMorph) ifTrue: [m font: ScriptingSystem fontForAttachedWatchers]]
]

{ #category : #accessing }
FollowingWatcher >> chooseAttachmentEdge [
	"Put up a menu allowing the user to choose which edge of the object being watched the receiver should attach itself to."

	| choice |
	choice := (SelectionMenu selections: #(top topRight right bottomRight  bottom bottomLeft left topLeft center)) startUpWithCaption: ('attachment edge
currently: ', attachmentEdge translated).
	choice isEmptyOrNil ifFalse:
		[self attachmentEdge: choice]
]

{ #category : #accessing }
FollowingWatcher >> chooseOffset [
	"Allow the user to select a new offset to apply to the positioning of the receiver with respect to the object it follows."

	| result aPoint |
	result := FillInTheBlank request: 'offset' translated initialAnswer: offset printString.
	result isEmptyOrNil ifTrue: [^ self].
	aPoint := [Compiler evaluate: result] on: Error do: [^ self inform: 'error' translated].
	(aPoint isKindOf: Point) ifFalse: [^ self inform: 'error' translated].
	offset := aPoint
]

{ #category : #initialization }
FollowingWatcher >> fancyForPlayer: aPlayer getter: aGetter [ 
	"Configure the receiver to be a 'following' watcher labeled with the variable name but not with the player name."

	| aLabel |
	self buildForPlayer: aPlayer getter: aGetter.
	aLabel := StringMorph contents: variableName translated , ' = ' font: ScriptingSystem fontForAttachedWatchers.
	aLabel setProperty: #watcherLabel toValue: true.
	self addMorphFront: aLabel
]

{ #category : #accessing }
FollowingWatcher >> initialize [
	"Initialize the receiver."

	super initialize.
	attachmentEdge := #bottom.
	offset := 0@0
]

{ #category : #initialization }
FollowingWatcher >> openInWorld [
	"Open the receiver near the watchee, but if possible avoiding attached-watcher locations already in use."

	| aMorph others |
	super openInWorld.
	self allMorphsDo: [:m | (m isKindOf: StringMorph) ifTrue: [m font: ScriptingSystem fontForAttachedWatchers]].
	(aMorph := player costume) isInWorld ifTrue:
		[others := aMorph owner submorphs
			select:
				[:m | m ~~ self and: [m isKindOf: self class] and: [m associatedPlayer == player]]
			thenCollect:
				[:m | m attachmentEdge].
		attachmentEdge := #(bottom left top right topLeft topRight bottomRight bottomLeft) detect:
			[:edge | (others includes: edge) not] ifNone: [#bottom]]
]

{ #category : #copying }
FollowingWatcher >> prospectiveReplacement [
	"Answer another watcher of the same class which will serve as the replacement for the receiver.  This is used when the whole apparatus needs to be rebuilt after, for example, a type change or a name change."

	| replacement |
	replacement := super prospectiveReplacement.
	replacement attachmentEdge: attachmentEdge.
	replacement attachmentOffset: offset.
	^ replacement
]

{ #category : #stepping }
FollowingWatcher >> step [
	"Periodic activity:  follow watchee round."

	| itsCostume morphToMove itsPlayfield |
	super step.
	(itsCostume := player costume) isInWorld ifTrue:
		[((morphToMove := self topRendererOrSelf) owner == (itsPlayfield := itsCostume owner))  ifFalse:
			[itsPlayfield addMorphFront: morphToMove].
		morphToMove center: itsCostume center.

		(#(bottomLeft bottom bottomRight) includes: attachmentEdge) ifTrue:
			[morphToMove top: itsCostume bottom].
		(#(topLeft top topRight) includes: attachmentEdge) ifTrue:
			[morphToMove bottom: itsCostume top].
		(#(topLeft left bottomLeft) includes: attachmentEdge) ifTrue:
			[morphToMove right: itsCostume left].
		(#(topRight right bottomRight) includes: attachmentEdge) ifTrue:
			[morphToMove left: itsCostume right].

		morphToMove position: (morphToMove position + offset)]
]

{ #category : #initialization }
FollowingWatcher >> unlabeledForPlayer: aPlayer getter: aGetter [ 
	"build a simple watcher"

	| readout |
	self buildForPlayer: aPlayer getter: aGetter.
	readout := self submorphs last.
	(readout isKindOf: TileMorph)
		ifTrue: [readout labelMorph lock: true.
			readout labelMorph font: ScriptingSystem fontForAttachedWatchers.
			readout labelMorph beSticky]
]
