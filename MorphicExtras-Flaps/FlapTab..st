"
The tab associated with a flap.

nb: slidesOtherObjects and inboard are instance variables relating to disused features.  The feature implementations still exist in the system, but the UI to them has been sealed off.
"
Class {
	#name : #FlapTab,
	#superclass : #ReferenceMorph,
	#instVars : [
		'flapShowing',
		'edgeToAdhereTo',
		'slidesOtherObjects',
		'popOutOnDragOver',
		'popOutOnMouseOver',
		'inboard',
		'dragged',
		'lastReferentThickness',
		'edgeFraction',
		'labelString'
	],
	#category : #'MorphicExtras-Flaps'
}

{ #category : #printing }
FlapTab class >> defaultNameStemForInstances [
	^ 'flap tab' translatedNoop
]

{ #category : #testing }
FlapTab class >> givenID: aFlapID matches: pureID [
	"eg, FlapTab givenID: 'Stack Tools2' matches: 'Stack Tools' "

	^ aFlapID = pureID or:
		[(aFlapID beginsWith: pureID)
			and: [(aFlapID copyFrom: pureID size+1 to: aFlapID size)
					allSatisfy: [:c | c isDigit]]]
]

{ #category : #'new-morph participation' }
FlapTab class >> includeInNewMorphMenu [
	"Not to be instantiated from the menu"
	^ false
]

{ #category : #access }
FlapTab >> acquirePlausibleFlapID [
	"Give the receiver a flapID that is globally unique; try to hit the mark vis a vis the standard system flap id's, for the case when this method is invoked as part of the one-time transition"

	| wording |
	wording := self wording.
	(wording isEmpty or: [wording = '---']) ifTrue: [wording := 'Flap' translated].
	
	^ self provideDefaultFlapIDBasedOn: wording
]

{ #category : #initialization }
FlapTab >> adaptToWorld [
	| wasShowing new |
	(wasShowing := self flapShowing) ifTrue:
					[self hideFlap].
	(self respondsTo: #unhibernate) ifTrue: [
		(new := self unhibernate) == self ifFalse: [
			^ new adaptToWorld]].
	wasShowing ifTrue:
		[self spanWorld.
		self positionObject: self.
		self showFlap]
]

{ #category : #menu }
FlapTab >> addCustomMenuItems: aMenu hand: aHandMorph [
	"Add further items to the menu as appropriate"

	aMenu add: 'tab color...' translated target: self action: #changeColor.
	aMenu add: 'flap color...' translated target: self action: #changeFlapColor.
	aMenu addLine.
	aMenu addUpdating: #edgeString action: #setEdgeToAdhereTo.
	aMenu addLine.
	aMenu addUpdating: #textualTabString action: #textualTab.
	aMenu addUpdating: #graphicalTabString action: #graphicalTab.
	aMenu addUpdating: #solidTabString enablement: #notSolid action: #solidTab.
	aMenu addLine.

	(referent isKindOf: PasteUpMorph) ifTrue: 
		[aMenu addUpdating: #partsBinString action: #togglePartsBinMode].
	aMenu addUpdating: #dragoverString action: #toggleDragOverBehavior.
	aMenu addUpdating: #mouseoverString action: #toggleMouseOverBehavior.
	aMenu addLine.
	aMenu addUpdating: #isGlobalFlapString enablement: #sharedFlapsAllowed action: #toggleIsGlobalFlap.
	aMenu balloonTextForLastItem: 'If checked, this flap will be available in all morphic projects; if not, it will be private to this project.' translated.

	aMenu addLine.
	aMenu addUpdating: #compactFlapString target: self action: #changeCompactFlap.
	aMenu add: 'destroy this flap' translated action: #destroyFlap.

	"aMenu addUpdating: #slideString action: #toggleSlideBehavior.
	aMenu addUpdating: #inboardString action: #toggleInboardness.
	aMenu addUpdating: #thicknessString ('thickness... (current: ', self thickness printString, ')') action: #setThickness."


]

{ #category : #menus }
FlapTab >> addGestureMenuItems: aMenu hand: aHandMorph [
	"If the receiver wishes the Genie menu items, add a line to the menu and then those Genie items, else do nothing"
]

{ #category : #menus }
FlapTab >> addTitleForHaloMenu: aMenu [
	aMenu addTitle: self externalName updatingSelector: #flapMenuTitle updateTarget: self
]

{ #category : #'show & hide' }
FlapTab >> adjustPositionAfterHidingFlap [
	self positionObject: self
]

{ #category : #positioning }
FlapTab >> adjustPositionVisAVisFlap [
	| sideToAlignTo opposite |
	opposite := Utilities oppositeSideTo: edgeToAdhereTo.
	sideToAlignTo := inboard
		ifTrue:	[opposite]
		ifFalse:	[edgeToAdhereTo].
	self perform: sideToAlignTo asSimpleSetter with: (referent perform: opposite)
]

{ #category : #edge }
FlapTab >> applyEdgeFractionWithin: aBoundsRectangle [
	"Make the receiver reflect remembered edgeFraction"

	| newPosition |
	edgeFraction ifNil: [^ self].
	self isCurrentlySolid ifTrue: [^ self].
	newPosition := self
		ifVertical:
			[self left @  (self edgeFraction * (aBoundsRectangle height - self height))]
		ifHorizontal:
			[(self edgeFraction * (aBoundsRectangle width - self width) @ self top)].

	self position: (aBoundsRectangle origin + newPosition)
	
]

{ #category : #'solid tabs' }
FlapTab >> applyTabThickness: newThickness [
	(self orientation == #vertical)
			ifTrue:
				[submorphs first width: newThickness asNumber]
			ifFalse:
				[submorphs first height: newThickness asNumber].
	self fitContents.
	self positionReferent. 
	self adjustPositionVisAVisFlap
]

{ #category : #menu }
FlapTab >> applyThickness: newThickness [
	| toUse |
	toUse := newThickness asNumber max: 0.
	(self orientation == #vertical)
			ifTrue:
				[referent width: toUse]
			ifFalse:
				[referent height: toUse].
	self positionReferent. 
	self adjustPositionVisAVisFlap
]

{ #category : #'mouseover & dragover' }
FlapTab >> arrangeToPopOutOnDragOver: aBoolean [
	aBoolean
		ifTrue:
			[self on: #mouseEnterDragging send: #showFlapIfHandLaden: to: self.
			referent on: #mouseLeaveDragging send: #maybeHideFlapOnMouseLeaveDragging to: self.
			self on: #mouseLeaveDragging send: #maybeHideFlapOnMouseLeaveDragging to: self]
		ifFalse:
			[self on: #mouseEnterDragging send: nil to: nil.
			referent on: #mouseLeaveDragging send: nil to: nil.
			self on: #mouseLeaveDragging send: nil to: nil]
]

{ #category : #'mouseover & dragover' }
FlapTab >> arrangeToPopOutOnMouseOver: aBoolean [
	aBoolean
		ifTrue:
			[self on: #mouseEnter send: #showFlap to: self.
			referent on: #mouseLeave send: #hideFlapUnlessBearingHalo to: self.
			self on: #mouseLeave send: #maybeHideFlapOnMouseLeave to: self]
		ifFalse:
			[self on: #mouseEnter send: nil to: nil.
			self on: #mouseLeave send: nil to: nil.
			referent on: #mouseLeave send: nil to: nil]
]

{ #category : #'textual tabs' }
FlapTab >> assumeString: aString font: aFont orientation: orientationSymbol color: aColor [ 
	| aTextMorph workString tabStyle |
	labelString := aString asString.
	workString := orientationSymbol == #vertical 
				ifTrue: 
					[String streamContents: 
							[:s | 
							labelString do: [:c | s nextPut: c] separatedBy: [s nextPut: Character cr]]]
				ifFalse: [labelString]. 
	tabStyle := (TextStyle new)
				leading: 0;
				newFontArray: (Array with: aFont).
	aTextMorph := (TextMorph new setTextStyle: tabStyle) 
				contents: (workString asText addAttribute: (TextKern kern: 3)).
	aTextMorph wrapFlag: true.
	self removeAllMorphs.
	self borderStyle: (BorderStyle raised width: 2).
	aColor ifNotNil: [self color: aColor].
	self addMorph: aTextMorph centered.
	aTextMorph lock
	"
FlapTab allSubInstancesDo: [:ft | ft reformatTextualTab]
"
]

{ #category : #miscellaneous }
FlapTab >> balloonTextForFlapsMenu [
	"Answer the balloon text to show on a menu item in the flaps menu that governs the visibility of the receiver in the current project"

	| id |
	id := self flapID.
	#(
	('Squeak'		'Has a few generally-useful controls; it is also a place where you can "park" objects' translatedNoop)
	('Tools'			'A quick way to get browsers, change sorters, file lists, etc.' translatedNoop)
	('Widgets'		'A variety of controls and media tools' translatedNoop)
	('Supplies' 		'Supplies' translatedNoop)
	('Help'			'A flap providing documentation, tutorials, and other help' translatedNoop)
	('Stack Tools' 	'Tools for building stacks.  Caution!  Powerful but young and underdocumented' translatedNoop)
	('Scripting'		'Tools useful when doing tile scripting' translatedNoop)
	('Navigator'		'Project navigator:  includes controls for navigating through linked projects.  Also supports finding, loading and publishing projects in a shared environment' translatedNoop)
	('Painting'		'A flap housing the paint palette.  Click on the closed tab to make make a new painting' translatedNoop)) do:
		[:pair | (FlapTab givenID: id matches: pair first translated) ifTrue: [^ pair second translated]].

	^ self balloonText
]

{ #category : #menu }
FlapTab >> changeColor [
	self isCurrentlyGraphical
		ifTrue:
			[^ self inform: 'Color only pertains to a flap tab when the 
tab is textual or "solid".  This tab is
currently graphical, so color-choice
does not apply.' translated].
	super changeColor
	

]

{ #category : #menu }
FlapTab >> changeFlapColor [
	(self flapShowing)
		ifTrue:
			[referent changeColor]
		ifFalse:
			[self inform: 'The flap itself needs to be open
before you can change its
color.' translated]
]

{ #category : #'solid tabs' }
FlapTab >> changeTabSolidity [
	"Presently no actual options associated with this menu item if the flap is currently alreadly solid, so entertain the user with an anuran sound.  However, in latest scheme, the corresponding menu item is disabled in this circumstance, so this method is effectively unreachable."

	self playSoundNamed: 'croak'
]

{ #category : #menu }
FlapTab >> changeTabText [
	"Allow the user to change the text on the tab"

	| reply |
	reply := UIManager default
		request: 'new wording for this tab:' translated
		initialAnswer: self existingWording.
	reply isEmptyOrNil ifTrue: [^ self].
	self changeTabText: reply.

]

{ #category : #'textual tabs' }
FlapTab >> changeTabText: aString [ 

	| label |
	aString isEmptyOrNil ifTrue: [^ self].
	label := Locale current languageEnvironment class flapTabTextFor: aString in: self.
	label isEmptyOrNil ifTrue: [^ self].
	self useStringTab: label.
	submorphs first delete.
	self assumeString: label
		font: Preferences standardFlapFont
		orientation: (Flaps orientationForEdge: self edgeToAdhereTo)
		color: nil.

]

{ #category : #'solid tabs' }
FlapTab >> changeTabThickness [
	| newThickness |
	newThickness := UIManager default request: 'New thickness:'
				initialAnswer: self tabThickness printString.
	newThickness notEmpty ifTrue: [self applyTabThickness: newThickness]
]

{ #category : #edge }
FlapTab >> computeEdgeFraction [
	"Compute and remember the edge fraction"

	| aBox aFraction |
	self isCurrentlySolid ifTrue: [^ edgeFraction ifNil: [self edgeFraction: 0.5]].

	aBox := ((self pasteUpMorph ifNil: [self currentWorld]) bounds) insetBy: (self extent // 2).
	aFraction := self
		ifVertical: 
			[(self center y - aBox top) / (aBox height max: 1)]
		ifHorizontal:
			[(self center x - aBox left) / (aBox width max: 1)].
	^ self edgeFraction: aFraction
]

{ #category : #menu }
FlapTab >> destroyFlap [
	"Destroy the receiver"

	| reply request |
	request := self isGlobalFlap
		ifTrue:
			['Caution -- this would permanently
remove this flap, so it would no longer be
available in this or any other project.
Do you really want to this? ' translated]
		ifFalse:
			['Caution -- this is permanent!  Do
you really want to do this? ' translated].
	reply := self confirm: request translated orCancel: [^ self].
	reply ifTrue:
		[self isGlobalFlap
			ifTrue:
				[Flaps removeFlapTab: self keepInList: false.
				self currentWorld reformulateUpdatingMenus]
			ifFalse:
				[referent isInWorld ifTrue: [referent delete].
				self delete]]
]

{ #category : #'submorphs-add\/remove' }
FlapTab >> dismissViaHalo [
	"Dismiss the receiver (and its referent), unless it resists"

	self resistsRemoval ifTrue:
		[(UIManager default chooseFrom: #( 'Yes' 'Um, no, let me reconsider') 
				title: 'Really throw this flap away?') = 2 ifFalse: [^ self]].

	referent delete.
	self delete
]

{ #category : #'mouseover & dragover' }
FlapTab >> dragoverString [
	"Answer the string to be shown in a menu to represent the 
	dragover status"
	^ (popOutOnDragOver
		ifTrue: ['<yes>']
		ifFalse: ['<no>']), 'pop out on dragover' translated
]

{ #category : #edge }
FlapTab >> edgeFraction [
	^ edgeFraction ifNil: [self computeEdgeFraction]
]

{ #category : #edge }
FlapTab >> edgeFraction: aNumber [
	"Set my edgeFraction to the given number, without side effects"

	edgeFraction := aNumber asFloat
]

{ #category : #edge }
FlapTab >> edgeString [
	^ 'cling to edge... (current: {1})' translated format: {edgeToAdhereTo translated}
]

{ #category : #edge }
FlapTab >> edgeToAdhereTo [
	^ edgeToAdhereTo
]

{ #category : #edge }
FlapTab >> edgeToAdhereTo: e [
	edgeToAdhereTo := e asSymbol
]

{ #category : #menu }
FlapTab >> existingWording [
	^ labelString
]

{ #category : #layout }
FlapTab >> fitContents [
	self isCurrentlyTextual ifFalse: [^ super fitContents].
	self ifVertical:
		[self extent: submorphs first extent + (2 * self borderWidth) + (0 @ 4).
		submorphs first position: self position + self borderWidth + (1 @ 4)]
	ifHorizontal:
		[self extent: submorphs first extent + (2 * self borderWidth) + (8 @ -1).
		submorphs first position: self position + self borderWidth + (5 @ 1)]
]

{ #category : #positioning }
FlapTab >> fitOnScreen [
	"19 sept 2000 - allow flaps in any paste up"
	| constrainer t l |
	constrainer := (owner ifNil: [self]) clearArea.
	self flapShowing "otherwise no point in doing this"
		ifTrue:[self spanWorld].
	self orientation == #vertical ifTrue: [
		t := ((self top min: (constrainer bottom- self height)) max: constrainer top).
		t = self top ifFalse: [self top: t].
	] ifFalse: [
		l := ((self left min: (constrainer right - self width)) max: constrainer left).
		l = self left ifFalse: [self left: l].
	].
	self flapShowing ifFalse: [self positionObject: self atEdgeOf: constrainer].

]

{ #category : #access }
FlapTab >> flapID [
	"Answer the receiver's flapID, creating it if necessary"

	^ self knownName ifNil: [self acquirePlausibleFlapID]
]

{ #category : #access }
FlapTab >> flapID: anID [
	"Set the receiver's flapID"

	self setNameTo: anID
]

{ #category : #access }
FlapTab >> flapIDOrNil [
	"If the receiver has a flapID, answer it, else answer nil"

	^ self knownName
]

{ #category : #menu }
FlapTab >> flapMenuTitle [
	^ 'flap: ' translated , self wording
]

{ #category : #access }
FlapTab >> flapShowing [
	^ flapShowing == true
]

{ #category : #'graphical tabs' }
FlapTab >> graphicalTab [
	self isCurrentlyGraphical
		ifTrue:
			[self changeTabGraphic]
		ifFalse:
			[self useGraphicalTab]
]

{ #category : #'graphical tabs' }
FlapTab >> graphicalTabString [
	^ (self isCurrentlyGraphical
		ifTrue: ['choose new graphic...' translated]
		ifFalse: ['use graphical tab' translated]) 
]

{ #category : #'show & hide' }
FlapTab >> hideFlap [
	| aWorld |
	aWorld := self world ifNil: [self currentWorld].
	referent privateDelete.
	aWorld removeAccommodationForFlap: self.
	flapShowing := false.
	self isInWorld ifFalse: [aWorld addMorphFront: self].
	self adjustPositionAfterHidingFlap.
	aWorld haloMorphs do:
		[:m | m target isInWorld ifFalse: [m delete]]
]

{ #category : #'show & hide' }
FlapTab >> hideFlapUnlessBearingHalo [
	self hasHalo ifFalse: [self hideFlapUnlessOverReferent]
]

{ #category : #'show & hide' }
FlapTab >> hideFlapUnlessOverReferent [
	"Hide the flap unless the mouse is over my referent."

	| aWorld where |
	(referent isInWorld and: 
		[where := self outermostWorldMorph activeHand lastEvent cursorPoint.
			referent bounds containsPoint: (referent globalPointToLocal: where)])
				ifTrue: [^ self].
	(aWorld := self world) ifNil: [^ self].  "In case flap tabs just got hidden"
	self referent delete.
	aWorld removeAccommodationForFlap: self.
	flapShowing := false.
	self isInWorld ifFalse:
		[self inboard ifTrue: [aWorld addMorphFront: self]].
	self adjustPositionAfterHidingFlap
]

{ #category : #edge }
FlapTab >> ifVertical: block1 ifHorizontal: block2 [
	"Evaluate and return the value of either the first or the second block, depending whether I am vertically or horizontally oriented"

	^ self orientation == #vertical
		ifTrue:
			[block1 value]
		ifFalse:
			[block2 value]
	
]

{ #category : #'disused options' }
FlapTab >> inboard [
	^ inboard == true
]

{ #category : #'disused options' }
FlapTab >> inboard: aBoolean [
	inboard := aBoolean
]

{ #category : #initialization }
FlapTab >> initialize [
"initialize the state of the receiver"
	super initialize.
""
	edgeToAdhereTo := #left.
	flapShowing := false.
	slidesOtherObjects := false.
	popOutOnDragOver := false.
	popOutOnMouseOver := false.
	inboard := false.
	dragged := false
]

{ #category : #'solid tabs' }
FlapTab >> isCurrentlySolid [
	"Don't never use double negatives"

	^ self notSolid not
]

{ #category : #menu }
FlapTab >> isCurrentlyTextual [
	| first |
	^submorphs notEmpty and: 
			[((first := submorphs first) isKindOf: StringMorph) 
				or: [first isTextMorph]]
]

{ #category : #classification }
FlapTab >> isFlapTab [
	^true
]

{ #category : #globalness }
FlapTab >> isGlobalFlap [
	"Answer whether the receiver is currently a shared flap"

	^ Flaps globalFlapTabsIfAny includes: self
]

{ #category : #globalness }
FlapTab >> isGlobalFlapString [
	"Answer a string to construct a menu item representing control 
	over whether the receiver is or is not a shared flap"
	^ (self isGlobalFlap
		ifTrue: ['<yes>']
		ifFalse: ['<no>'])
		, 'shared by all projects' translated
]

{ #category : #accessing }
FlapTab >> labelString [
	^labelString
]

{ #category : #'show & hide' }
FlapTab >> lastReferentThickness: anInteger [
	"Set the last remembered referent thickness to the given integer"

	lastReferentThickness := anInteger
]

{ #category : #layout }
FlapTab >> layoutChanged [
	self fitOnScreen.
	^super layoutChanged
]

{ #category : #'mouseover & dragover' }
FlapTab >> makeNewDrawing: evt [
	self flapShowing ifTrue:[
		self world makeNewDrawing: evt.
	] ifFalse:[
		self world assureNotPaintingEvent: evt.
	].
]

{ #category : #'show & hide' }
FlapTab >> maybeHideFlapOnMouseLeave [
	self hasHalo ifTrue: [^ self].
	referent isInWorld ifFalse: [^ self].
	self hideFlapUnlessOverReferent.

]

{ #category : #'show & hide' }
FlapTab >> maybeHideFlapOnMouseLeaveDragging [
	| aWorld |
	self hasHalo ifTrue: [^ self].
	referent isInWorld ifFalse: [^ self].
	(dragged or: [referent bounds containsPoint: self cursorPoint])
		ifTrue:	[^ self].
	aWorld := self world.
	referent privateDelete.  "could make me worldless if I'm inboard"
	aWorld ifNotNil: [aWorld removeAccommodationForFlap: self].
	flapShowing := false.
	self isInWorld ifFalse: [aWorld addMorphFront: self].
	self adjustPositionAfterHidingFlap
]

{ #category : #'WiW support' }
FlapTab >> morphicLayerNumber [
	^self flapShowing ifTrue: [26] ifFalse: [25] 	"As navigators"
]

{ #category : #'event handling' }
FlapTab >> mouseMove: evt [
	"Handle a mouse-move event.   The event, a MorphicEvent, is passed in."

	| aPosition newReferentThickness adjustedPosition thick |

	dragged ifFalse: [(thick := self referentThickness) > 0
			ifTrue: [lastReferentThickness := thick]].
	((self containsPoint: (aPosition := evt cursorPoint)) and: [dragged not])
		ifFalse:
			[flapShowing ifFalse: [self showFlap].
			adjustedPosition := aPosition - evt hand targetOffset.
			(edgeToAdhereTo == #bottom)
				ifTrue:
					[newReferentThickness := inboard
						ifTrue:
							[self world height - adjustedPosition y]
						ifFalse:
							[self world height - adjustedPosition y - self height]].

			(edgeToAdhereTo == #left)
					ifTrue:
						[newReferentThickness :=
							inboard
								ifTrue:
									[adjustedPosition x + self width]
								ifFalse:
									[adjustedPosition x]].

			(edgeToAdhereTo == #right)
					ifTrue:
						[newReferentThickness :=
							inboard
								ifTrue:
									[self world width - adjustedPosition x]
								ifFalse:
									[self world width - adjustedPosition x - self width]].

			(edgeToAdhereTo == #top)
					ifTrue:
						[newReferentThickness :=
							inboard
								ifTrue:
									[adjustedPosition y + self height]
								ifFalse:
									[adjustedPosition y]].
		
			self isCurrentlySolid ifFalse:
				[(#(left right) includes: edgeToAdhereTo)
					ifFalse:
						[self left: adjustedPosition x]
					ifTrue:
						[self top: adjustedPosition y]].

			((edgeToAdhereTo == #left) and: [(self  valueOfProperty: #rigidThickness) notNil]) ifTrue:
				[newReferentThickness := referent width].

			self applyThickness: newReferentThickness.
			dragged := true.
			self fitOnScreen.
			self computeEdgeFraction]
]

{ #category : #'event handling' }
FlapTab >> mouseUp: evt [
	"The mouse came back up, presumably after having dragged the tab.  Caution: if not operating full-screen, this notification can easily be *missed*, which is why the edge-fraction-computation is also being done on mouseMove."

	super mouseUp: evt.
	(self referentThickness <= 0 or:
		[(referent isInWorld and: [(referent boundsInWorld intersects: referent owner boundsInWorld) not])]) ifTrue:
			[self hideFlap.
			flapShowing := false].
	self fitOnScreen.
	dragged ifTrue:
		[self computeEdgeFraction.
		dragged := false].
	Flaps doAutomaticLayoutOfFlapsIfAppropriate
]

{ #category : #'mouseover & dragover' }
FlapTab >> mouseoverString [
	"Answer the string to be shown in a menu to represent the  
	mouseover status"
	^ (popOutOnMouseOver
		ifTrue: ['<yes>']
		ifFalse: ['<no>'])
		, 'pop out on mouseover' translated 
]

{ #category : #'solid tabs' }
FlapTab >> notSolid [
	"Answer whether the receiver is currenty not solid.  Used for determining whether the #solidTab menu item should be enabled"

	^ self isCurrentlyTextual or: [self isCurrentlyGraphical]
]

{ #category : #'objects from disk' }
FlapTab >> objectForDataStream: refStrm [
	"I am about to be written on an object file.  If I am a global flap, write a proxy instead."

	| dp |
	self isGlobalFlap ifTrue:
		[dp := DiskProxy global: #Flaps selector: #globalFlapTabOrDummy: 
					args: {self flapID}.
		refStrm replace: self with: dp.
		^ dp].

	^ super objectForDataStream: refStrm
]

{ #category : #'show & hide' }
FlapTab >> openFully [
	"Make an educated guess at how wide or tall we are to be, and open to that thickness"

	| thickness amt |
	thickness := referent boundingBoxOfSubmorphs extent max: (100 @ 100).
	self applyThickness: (amt := self orientation == #horizontal
			ifTrue:
				[thickness y]
			ifFalse:
				[thickness x]).
	self lastReferentThickness: amt.
	self showFlap
]

{ #category : #access }
FlapTab >> orientation [
	^ (#left == edgeToAdhereTo or: [#right == edgeToAdhereTo])
		ifTrue:		[#vertical]
		ifFalse:		[#horizontal]
]

{ #category : #'change reporting' }
FlapTab >> ownerChanged [
	self fitOnScreen.
	^super ownerChanged.
]

{ #category : #'parts bin' }
FlapTab >> partsBinString [
	"Answer the string to be shown in a menu to represent the 
	parts-bin status"
	^ (referent isPartsBin
		ifTrue: ['<yes>']
		ifFalse: ['<no>']), 'parts-bin' translated
]

{ #category : #thumbnail }
FlapTab >> permitsThumbnailing [
	^ false
]

{ #category : #positioning }
FlapTab >> positionObject: anObject [
        "anObject could be myself or my referent"

	| pum clearArea |
	pum := self pasteUpMorph ifNil: [^ self].

	clearArea := Morph newBounds: pum clearArea.
	^self 
		positionObject: anObject 
		atEdgeOf: clearArea
]

{ #category : #positioning }
FlapTab >> positionObject: anObject atEdgeOf: container [
        "anObject could be myself or my referent"

        edgeToAdhereTo == #left ifTrue: [^ anObject left: container left].
        edgeToAdhereTo == #right ifTrue: [^ anObject right: container right].
        edgeToAdhereTo == #top ifTrue: [^ anObject top: container top].
        edgeToAdhereTo == #bottom ifTrue: [^ anObject bottom: container bottom]
]

{ #category : #positioning }
FlapTab >> positionReferent [
	self positionObject: referent
]

{ #category : #menu }
FlapTab >> preserveDetails [
	"The receiver is being switched to use a different format.  Preserve the existing details (e.g. wording if textual, grapheme if graphical) so that if the user reverts back to the current format, the details will be right"

	| thickness |
	color = Color transparent ifFalse: [self setProperty: #priorColor toValue: color].
	self isCurrentlyTextual
		ifTrue:
			[self setProperty: #priorWording toValue: self existingWording]
		ifFalse:
			[self isCurrentlyGraphical
				ifTrue:
					[self setProperty: #priorGraphic toValue: submorphs first form]
				ifFalse:
					[thickness := (self orientation == #vertical)
						ifTrue:	[self width]
						ifFalse:	[self height].
					self setProperty: #priorThickness toValue: thickness]]
]

{ #category : #printing }
FlapTab >> printOn: aStream [
	"Append a textual representation of the receiver to aStream"

	super printOn: aStream.
	aStream nextPutAll: ' "', self wording, '"'
]

{ #category : #initialization }
FlapTab >> provideDefaultFlapIDBasedOn: aStem [
	"Provide the receiver with a default flap id"

	| aNumber usedIDs anID  |
	aNumber := 0.
	usedIDs := FlapTab allSubInstances select: [:f | f ~~ self] thenCollect: [:f | f flapIDOrNil].
	anID := aStem.
	[usedIDs includes: anID] whileTrue:
		[aNumber := aNumber + 1.
		anID := aStem, (aNumber asString)].
	self flapID: anID.
	^ anID
]

{ #category : #access }
FlapTab >> referentThickness [
	referent ifNil: [^ 32].
	^ (self orientation == #horizontal)
		ifTrue:
			[referent height]
		ifFalse:
			[referent width]
]

{ #category : #'textual tabs' }
FlapTab >> reformatTextualTab [
	"The font choice possibly having changed, reformulate the receiver"

	self isCurrentlyTextual ifFalse: [^ self].
	self assumeString: self existingWording font: Preferences standardFlapFont orientation: self orientation color: self color
]

{ #category : #rounding }
FlapTab >> roundedCorners [
	edgeToAdhereTo == #bottom ifTrue: [^ #(1 4)].
	edgeToAdhereTo == #right ifTrue: [^ #(1 2)].
	edgeToAdhereTo == #left ifTrue: [^ #(3 4)].
	^ #(2 3)  "#top and undefined"

]

{ #category : #edge }
FlapTab >> setEdge: anEdge [
	"Set the edge as indicated, if possible"

	| newOrientation e |
	e := anEdge asSymbol.
	self edgeToAdhereTo = anEdge ifTrue: [^ self].
	newOrientation := nil.
	self orientation == #vertical
		ifTrue: [(#top == e or: [#bottom == e]) ifTrue:
					[newOrientation := #horizontal]]
		ifFalse: [(#top == e or: [#bottom == e]) ifFalse:
					[newOrientation := #vertical]].
	self edgeToAdhereTo: e.
	newOrientation ifNotNil: [self transposeParts].
	referent isInWorld ifTrue: [self positionReferent].
	self adjustPositionVisAVisFlap
]

{ #category : #edge }
FlapTab >> setEdgeToAdhereTo [
	| aMenu |
	aMenu := MenuMorph new defaultTarget: self.
	#(left top right bottom) do:
		[:sym | aMenu add: sym asString translated target: self selector:  #setEdge: argument: sym].
	aMenu popUpEvent: self currentEvent in: self world
]

{ #category : #initialization }
FlapTab >> setName: nameString edge: edgeSymbol color: flapColor [
	"Set me up with the usual..."

	self setNameTo: nameString.
	self edgeToAdhereTo: edgeSymbol; inboard: false.
	self assumeString: nameString font: Preferences standardFlapFont
		orientation: self orientation color: flapColor.
	self setToPopOutOnDragOver: true.
	self setToPopOutOnMouseOver: false.

]

{ #category : #'mouseover & dragover' }
FlapTab >> setToPopOutOnDragOver: aBoolean [
	self arrangeToPopOutOnDragOver:  (popOutOnDragOver := aBoolean)
]

{ #category : #'mouseover & dragover' }
FlapTab >> setToPopOutOnMouseOver: aBoolean [
	self arrangeToPopOutOnMouseOver:  (popOutOnMouseOver := aBoolean)
]

{ #category : #menu }
FlapTab >> sharedFlapsAllowed [
	"Answer (for the benefit of a menu item for which I am the target) whether the system presently allows shared flaps"

	^ Flaps sharedFlapsAllowed
]

{ #category : #'show & hide' }
FlapTab >> showFlap [
	"Open the flap up"

	| thicknessToUse flapOwner |

	"19 sept 2000 - going for all paste ups <- raa note"
	flapOwner := self pasteUpMorph.
	self referentThickness <= 0
		ifTrue:
			[thicknessToUse := lastReferentThickness ifNil: [100].
			self orientation == #horizontal
				ifTrue:
					[referent height: thicknessToUse]
				ifFalse:
					[referent width: thicknessToUse]].
	inboard ifTrue:
		[self stickOntoReferent].  "makes referent my owner, and positions me accordingly"
	referent pasteUpMorph == flapOwner
		ifFalse:
			[flapOwner accommodateFlap: self.  "Make room if needed"
			flapOwner addMorphFront: referent.
			flapOwner startSteppingSubmorphsOf: referent.
			self positionReferent.
			referent adaptToWorld: flapOwner].
	inboard  ifFalse:
		[self adjustPositionVisAVisFlap].
	flapShowing := true.
	
	self pasteUpMorph hideFlapsOtherThan: self ifClingingTo: edgeToAdhereTo.

	flapOwner bringTopmostsToFront
]

{ #category : #'show & hide' }
FlapTab >> showFlapIfHandLaden: evt [
	"The hand has drifted over the receiver with the button down.  If the hand is carrying anything, show the flap.  If the hand is empty, the likely cause is that it's manipulating a scrollbar or some such, so in that case don't pop the flap out."

	evt hand hasSubmorphs ifTrue: [self showFlap]
]

{ #category : #'disused options' }
FlapTab >> slidesOtherObjects [
	^ slidesOtherObjects
]

{ #category : #'solid tabs' }
FlapTab >> solidTab [
	self isCurrentlySolid
		ifFalse:
			[self useSolidTab]
		ifTrue:
			[self changeTabSolidity]
]

{ #category : #'solid tabs' }
FlapTab >> solidTabString [
	^ (self isCurrentlySolid
		ifTrue: ['currently using solid tab' translated]
		ifFalse: ['use solid tab' translated]) 
]

{ #category : #positioning }
FlapTab >> spanWorld [
	| container area |
	
	container := self pasteUpMorph
				ifNil: [self currentWorld].

	area := container clearArea.

	self orientation == #vertical ifTrue: [
		referent vResizing == #rigid
			ifTrue: [referent height: area height].
		referent hResizing == #rigid
			ifTrue: [referent width: (referent width min: area width - self width)].
		referent top: area top.
		referent bottom: (area bottom min: referent bottom)
	]
	ifFalse: [
		referent hResizing == #rigid
			ifTrue: [referent width: area width].
		referent vResizing == #rigid
			ifTrue: [referent height: (referent height min: area height - self height)].
		referent left: area left.
		referent right: (area right min: referent right)
	].

]

{ #category : #'mouseover & dragover' }
FlapTab >> startOrFinishDrawing: evt [
	| w |
	self flapShowing ifTrue:[
		(w := self world) makeNewDrawing: evt at:  w center.
	] ifFalse:[
		self world endDrawing: evt.
	].
]

{ #category : #positioning }
FlapTab >> stickOntoReferent [
	"Place the receiver directly onto the referent -- for use when the referent is being shown as a flap"
	| newPosition |
	referent addMorph: self.
	edgeToAdhereTo == #left
		ifTrue:
			[newPosition := (referent width - self width) @ self top].
	edgeToAdhereTo == #right
		ifTrue:
			[newPosition := (referent left @ self top)].
	edgeToAdhereTo == #top
		ifTrue:
			[newPosition := self left @ (referent height - self height)].
	edgeToAdhereTo == #bottom
		ifTrue:
			[newPosition := self left @ referent top].
	self position: newPosition
]

{ #category : #events }
FlapTab >> tabSelected [
	"The user clicked on the tab.  Show or hide the flap.  Try to be a little smart about a click on a tab whose flap is open but only just barely."

	dragged == true ifTrue:
		[^ dragged := false].
	self flapShowing
		ifTrue:
			[self referentThickness < 23  "an attractive number"
				ifTrue:
					[self openFully]
				ifFalse:
					[self hideFlap]]
		ifFalse:
			[self showFlap]
]

{ #category : #access }
FlapTab >> tabThickness [
	^ (self orientation == #vertical)
		ifTrue:
			[self width]
		ifFalse:
			[self height]
]

{ #category : #'textual tabs' }
FlapTab >> textualTab [
	self isCurrentlyTextual
		ifTrue:
			[self changeTabText]
		ifFalse:
			[self useTextualTab]
]

{ #category : #'textual tabs' }
FlapTab >> textualTabString [
	^ (self isCurrentlyTextual
		ifTrue: ['change tab wording...' translated]
		ifFalse: ['use textual tab' translated]) 
]

{ #category : #menu }
FlapTab >> thicknessString [
	^ 'thickness... (currently ', self thickness printString, ')'
]

{ #category : #'mouseover & dragover' }
FlapTab >> toggleDragOverBehavior [
	self arrangeToPopOutOnDragOver:  (popOutOnDragOver := popOutOnDragOver not)
]

{ #category : #globalness }
FlapTab >> toggleIsGlobalFlap [
	"Toggle whether the receiver is currently a global flap or not"

	| oldWorld |
	self hideFlap.
	oldWorld := self currentWorld.
	self isGlobalFlap
		ifTrue:
			[Flaps removeFromGlobalFlapTabList: self.
			oldWorld addMorphFront: self]
		ifFalse:
			[self delete.
			Flaps addGlobalFlap: self.
			self currentWorld addGlobalFlaps].
	self currentWorld reformulateUpdatingMenus.
]

{ #category : #'mouseover & dragover' }
FlapTab >> toggleMouseOverBehavior [
	self arrangeToPopOutOnMouseOver:  (popOutOnMouseOver := popOutOnMouseOver not)
]

{ #category : #'parts bin' }
FlapTab >> togglePartsBinMode [
	referent setPartsBinStatusTo: referent isPartsBin not
]

{ #category : #positioning }
FlapTab >> transposeParts [
	"The receiver's orientation has just been changed from vertical to horizontal or vice-versa."
	"First expand the flap to screen size, letting the submorphs lay out to fit,
	and then shrink the minor dimension back to the last row."

	self isCurrentlyTextual ifTrue:  "First recreate the tab with proper orientation"
		[self assumeString: self existingWording font: Preferences standardFlapFont
			orientation: self orientation color: self color].
	self orientation == #vertical
		ifTrue:	"changed from horizontal"
			[referent listDirection: #topToBottom; wrapDirection: #leftToRight.
			referent hasSubmorphs ifTrue:
				[referent extent: self currentWorld extent.
				referent fullBounds.  "Needed to trigger layout"
				referent width: (referent submorphs collect: [:m | m right]) max
									- referent left + self width]]
		ifFalse:
			[referent listDirection: #leftToRight; wrapDirection: #topToBottom.
			referent hasSubmorphs ifTrue:
				[referent extent: self currentWorld extent.
				referent fullBounds.  "Needed to trigger layout"
				referent height: (referent submorphs collect: [:m | m bottom]) max
									- referent top + self height]].
	referent hasSubmorphs ifFalse: [referent extent: 100@100].

	self spanWorld.
	flapShowing ifTrue: [self showFlap]
]

{ #category : #'solid tabs' }
FlapTab >> useSolidTab [
	| thickness colorToUse |
	self preserveDetails.

	thickness := self valueOfProperty: #priorThickness ifAbsent: [20].
	colorToUse := self valueOfProperty: #priorColor ifAbsent: [Color red muchLighter].
	self color: colorToUse.
	self removeAllMorphs.
	
	(self orientation == #vertical)
		ifTrue:
			[self width: thickness.
			self height: self currentWorld height.
			self position: (self position x @ 0)]
		ifFalse:
			[self height: thickness.
			self width: self currentWorld width.
			self position: (0 @ self position y)].

	self borderWidth: 0.
	self layoutChanged.
]

{ #category : #'textual tabs' }
FlapTab >> useStringTab: aString [
	| aLabel |
	labelString := aString asString.
	aLabel := StringMorph  new contents: labelString.
	self addMorph: aLabel.
	aLabel position: self position.
	aLabel highlightColor: self highlightColor; regularColor: self regularColor.
	aLabel lock.
	self fitContents.
	self layoutChanged
]

{ #category : #'textual tabs' }
FlapTab >> useTextualTab [
	| stringToUse colorToUse |
	self preserveDetails.
	colorToUse := self valueOfProperty: #priorColor ifAbsent: [Color green muchLighter].
	submorphs notEmpty ifTrue: [self removeAllMorphs].
	stringToUse := self valueOfProperty: #priorWording ifAbsent: ['Unnamed Flap' translated].
	self assumeString: stringToUse font:  Preferences standardFlapFont orientation: self orientation color: colorToUse
]

{ #category : #rounding }
FlapTab >> wantsRoundedCorners [
	^self isCurrentlyTextual or:[super wantsRoundedCorners]
]

{ #category : #menu }
FlapTab >> wording [
	^ self isCurrentlyTextual
		ifTrue:
			[self existingWording]
		ifFalse:
			[self valueOfProperty: #priorWording ifAbsent: ['---']]
]
