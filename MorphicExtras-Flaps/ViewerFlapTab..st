"
ViewerFlapTab are flap tabs for etoy scripting viewers.
"
Class {
	#name : #ViewerFlapTab,
	#superclass : #FlapTab,
	#instVars : [
		'scriptedPlayer'
	],
	#category : #'MorphicExtras-Flaps'
}

{ #category : #printing }
ViewerFlapTab class >> defaultNameStemForInstances [
	^ 'viewerFlapTab' translatedNoop
]

{ #category : #'new-morph participation' }
ViewerFlapTab class >> includeInNewMorphMenu [
	"Not to be instantiated from the menu"
	^ false
]

{ #category : #menu }
ViewerFlapTab >> addCustomMenuItems: aMenu hand: aHandMorph [
	"Add further items to the menu as appropriate.  NB: Cannot call super here."

	aMenu add: 'flap color...' translated target: self action: #changeFlapColor.
	aMenu addLine.
	aMenu addUpdating: #edgeString action: #setEdgeToAdhereTo.
	aMenu addUpdating: #dragoverString action: #toggleDragOverBehavior.
	aMenu addUpdating: #mouseoverString action: #toggleMouseOverBehavior.
	aMenu addLine.
	aMenu addUpdating: #compactFlapString target: self action: #changeCompactFlap.

	aMenu add: 'destroy this flap' translated action: #destroyFlap
]

{ #category : #'show & hide' }
ViewerFlapTab >> adjustPositionAfterHidingFlap [
	"we add the width of flap itself to our referent, to reflect the actual width from the edge of the screen, including the space we leave for other flaps. see also ViewerFlapTab>>fitOnScreen"
	self flag: #todo.
	self referent width: self referent width + self width.
	super adjustPositionAfterHidingFlap.
]

{ #category : #'submorphs-accessing' }
ViewerFlapTab >> allNonSubmorphMorphs [
	"Return a collection containing all morphs in this morph which are not currently in the submorph containment hierarchy.  Especially the non-showing pages in BookMorphs."

	^ flapShowing 
		ifTrue: [#()]
		ifFalse: [Array with: referent]
]

{ #category : #compact }
ViewerFlapTab >> changeCompactFlap [
	self makeFlapCompact: self isFlapCompact not.
]

{ #category : #compact }
ViewerFlapTab >> compactFlapString [
	^ (self isFlapCompact
		ifTrue: ['<on>compact flap']
		ifFalse: ['<off>']), 'compact flap' translated
]

{ #category : #positioning }
ViewerFlapTab >> fitOnScreen [
	| constrainer |
	super fitOnScreen.
	"We want to leave a margin for the flaps on the side and for the global flaps at the top (like the Sugar navbar) so we reduce the referents top and its width. We undo this before hiding the flap in ViewerFlapTab>>adjustPositionAfterHidingFlap"
	self flag: #todo.
	constrainer := (owner ifNil: [self]) clearArea.
	self flapShowing ifTrue: [
		Flaps globalFlapTabsIfAny
			do: [:each |
				(each edgeToAdhereTo = #top and: [each bottom > self referent top])
					ifTrue: [self referent top: each bottom].
				(each edgeToAdhereTo = #top and: [each bottom > self top])
					ifTrue: [self top: each bottom]].
		self referent width: constrainer right - self width -  self right].
]

{ #category : #menu }
ViewerFlapTab >> graphicalMorphForTab [
	"Answer a graphical morph to serve as my tab's display"

	^ ThumbnailMorph new objectToView: scriptedPlayer viewSelector: #graphicForViewerTab
]

{ #category : #transition }
ViewerFlapTab >> hibernate [
	"drop my viewer to save space when writing to the disk."

	referent submorphs do: 
		[:m | (m isViewer) ifTrue: [m delete]]
]

{ #category : #transition }
ViewerFlapTab >> initializeFor: aPlayer topAt: aTop [

	scriptedPlayer := aPlayer.
	self useGraphicalTab.
	self top: aTop
]

{ #category : #accessing }
ViewerFlapTab >> isCurrentlyGraphical [
	^ true
]

{ #category : #compact }
ViewerFlapTab >> isFlapCompact [
	"Return true if the referent of the receiver represents a 'compact' flap"
	referent layoutPolicy ifNil:[^false].
	referent layoutPolicy isTableLayout ifFalse:[^false].
	referent vResizing == #shrinkWrap ifFalse:[^false].
	^true
]

{ #category : #compact }
ViewerFlapTab >> makeFlapCompact: aBool [
	"Return true if the referent of the receiver represents a 'compact' flap"
	aBool ifTrue:[
		referent
			layoutPolicy: TableLayout new;
			vResizing: #shrinkWrap;
			useRoundedCorners.
	] ifFalse:[
		referent
			layoutPolicy: nil;
			vResizing: #rigid;
			useSquareCorners.
	].
]

{ #category : #access }
ViewerFlapTab >> scriptedPlayer [
	^ scriptedPlayer
]

{ #category : #transition }
ViewerFlapTab >> unhibernate [
	"recreate my viewer"

	| wasShowing viewer |
	referent ifNotNil: [referent isViewer ifTrue: [^self]].
	wasShowing := flapShowing.
	"guard against not-quite-player-players"
	viewer := ((scriptedPlayer respondsTo: #costume) 
				and: [scriptedPlayer costume isMorph]) 
					ifTrue: [self presenter viewMorph: scriptedPlayer costume]
					ifFalse: [self presenter viewObjectDirectly: scriptedPlayer]. 
	wasShowing ifFalse: [self hideFlap].
	^viewer
]
