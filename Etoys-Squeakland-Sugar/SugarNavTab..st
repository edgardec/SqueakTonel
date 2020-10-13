Class {
	#name : #SugarNavTab,
	#superclass : #FlapTab,
	#category : #'Etoys-Squeakland-Sugar'
}

{ #category : #scripting }
SugarNavTab class >> additionsToViewerCategories [
	"Answer a list of (<categoryName> <list of category specs>) pairs that characterize the phrases this kind of morph wishes to add to various Viewer categories."

	^ #(

	(navigator (
(command useGreenLook 'use green look')
(command useGrayLook 'use gray look')
(slot highlightColor 'The highlight color for the navigator bar' Color readWrite Player getHighlightColor Player setHighlightColor:)
)))
]

{ #category : #menu }
SugarNavTab >> addCustomMenuItems: aMenu hand: aHandMorph [
	"Add further items to the menu as appropriate"

	aMenu addLine.
	"aMenu addUpdating: #edgeString action: #setEdgeToAdhereTo."
	"aMenu add: 'destroy this flap' translated action: #destroyFlap." "we do not want accidental removal"

	aMenu addLine.

	aMenu add: 'use default green look' translated action: #makeGreen.
	aMenu add: 'use default gray look' translated action: #makeGray.
	aMenu add: 'color...' translated target: self action: #changeColor.
	aMenu add: 'highlight color...' translated target: self action: #changeHighlightColor.
	aMenu add: 'height...' translated target: self action: #changeNaviHeight.

]

{ #category : #positioning }
SugarNavTab >> adjustPositionAfterHidingFlap [
	self showFlap.
	referent checkForResize.
	self goBehind.
]

{ #category : #events }
SugarNavTab >> changeColor [

	referent ifNil: [^ self].
	ColorPickerMorph new
		choseModalityFromPreference;
		sourceHand: self activeHand;
		target: referent;
		selector: #color:;
		originalColor: referent color;
		putUpFor: self near: self fullBoundsInWorld
]

{ #category : #events }
SugarNavTab >> changeHighlightColor [

	referent ifNil: [^ self].
	ColorPickerMorph new
		choseModalityFromPreference;
		sourceHand: self activeHand;
		target: referent;
		selector: #highLightColor:;
		originalColor: referent color;
		putUpFor: self near: self fullBoundsInWorld
]

{ #category : #events }
SugarNavTab >> changeNaviHeight [

	| f n |
	referent ifNil: [^ self].

	f := FillInTheBlank request: 'new height of the bar' initialAnswer: referent height asString.
	n := f asNumber min: (Display height // 2) max: 0.
	self naviHeight: n.
]

{ #category : #positioning }
SugarNavTab >> collapsedMode [
	"Answer whether the receiver is currently showing only as a single open-nav-bar button at top-right of the screen."

	^ self hasProperty: #collapsedMode
]

{ #category : #positioning }
SugarNavTab >> collapsible [
	"Answer whether the receiver can be collapsed."

	^ false
]

{ #category : #events }
SugarNavTab >> handleMouseMove: evt [

]

{ #category : #positioning }
SugarNavTab >> hideFlap [

]

{ #category : #initialization }
SugarNavTab >> hideNavBar [
	"Hide the nav bar."

	self setProperty: #collapsedMode toValue: true.
	referent delete.
	referent showOnlyShowNavBarButton.
	self hResizing: #shrinkWrap.
	referent layoutInset: 0@0.
	self edgeToAdhereTo: #topRight.
	self occupyTopRightCorner.
	self addMorphBack: referent
]

{ #category : #accessing }
SugarNavTab >> highlightColor [
	"Answer the highlight color used by buttons in the nav bar."

	^ referent highLightColor
]

{ #category : #accessing }
SugarNavTab >> highlightColor: aColor [
	"Set the highlight color to be used with buttons in the sugar nav bar."

	^ referent highLightColor: aColor
]

{ #category : #initialization }
SugarNavTab >> makeGray [

	referent ifNotNil: [referent makeGray].

]

{ #category : #initialization }
SugarNavTab >> makeGreen [

	referent ifNotNil: [referent makeGreen].

]

{ #category : #events }
SugarNavTab >> mouseMove: evt [

]

{ #category : #events }
SugarNavTab >> mouseUp: evt [


]

{ #category : #positioning }
SugarNavTab >> naviHeight: anInteger [

	referent ifNotNil: [referent naviHeight: anInteger].

]

{ #category : #initialization }
SugarNavTab >> nonStandardMorphs [

	^ (submorphs copy reject: [:e | e isMemberOf: SugarNavigatorBar]) collect: [:e | Array with: e with: e position - self position]
]

{ #category : #positioning }
SugarNavTab >> occupyTopRightCorner [
	"Make the receiver be the correct size, and occupy the top-right corner of the screen."

	| worldBounds toUse |
	worldBounds := Project current world bounds.
"	toUse := Preferences useArtificialSweetenerBar
		ifFalse:
			[75]
		ifTrue:
			[(ActiveWorld  extent >= (1200 @ 900))
				ifTrue:
					[75]
				ifFalse:
					[40]]."
	toUse := 40.  "Trying for the moment to use the smaller icon always when in this mode."

	referent height: toUse; resizeButtonsAndTabTo: toUse.
	self extent: toUse @ toUse.
	self topRight: worldBounds topRight
]

{ #category : #accessing }
SugarNavTab >> okayToBrownDragEasily [
	

	^ false
]

{ #category : #accessing }
SugarNavTab >> okayToResizeEasily [
	"Answer whether the receiver would be glad to offer a grow handle."

	^ false
]

{ #category : #accessing }
SugarNavTab >> okayToRotateEasily [
	"Answer whether it is appropriate for a rotation handle to be shown for the receiver. "

	^ false
]

{ #category : #positioning }
SugarNavTab >> positionReferent [

]

{ #category : #menu }
SugarNavTab >> setEdge: anEdge [

	super setEdge: anEdge.
	referent setEdge: anEdge.
]

{ #category : #menu }
SugarNavTab >> setEdgeToAdhereTo [
	| aMenu |
	aMenu := MenuMorph new defaultTarget: self.
	#(top bottom) do:
		[:sym | aMenu add: sym asString translated target: self selector:  #setEdge: argument: sym].
	aMenu popUpEvent: self currentEvent in: self world
]

{ #category : #positioning }
SugarNavTab >> showFlap [
	"Open the flap up"

	| thicknessToUse flapOwner |

	"19 sept 2000 - going for all paste ups <- raa note"
	self lazyUnhibernate.
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
			self addMorph: referent.
			flapOwner startSteppingSubmorphsOf: referent.
			self positionReferent.
			referent adaptToWorld: flapOwner].
	inboard  ifFalse:
		[self adjustPositionVisAVisFlap].
	flapShowing := false.  "This is really tricky...  It is a way to always show it"
	self owner addMorphBack: self.

]

{ #category : #initialization }
SugarNavTab >> showNavBar [
	"Show the full nav-bar across the top of the screen."

	self removeProperty: #collapsedMode.
	referent delete.
	
	referent rebuildButtons; hResizing: #spaceFill.
	Preferences useArtificialSweetenerBar ifTrue: [referent configureForSqueakland].

	self hResizing: #spaceFill.
	self edgeToAdhereTo: #top.
	self position: 0@0.
	
	self addMorph: referent
]

{ #category : #positioning }
SugarNavTab >> spanWorld [
	"Make the receiver's height or width commensurate with that of the container."

	| container |

	self collapsedMode ifTrue:
		[^ self occupyTopRightCorner].

	container := self pasteUpMorph ifNil: [self currentWorld].
	(self orientation == #vertical) ifTrue: [
		referent vResizing == #rigid 
			ifTrue:[referent spanContainerVertically: container height].
		referent hResizing == #rigid 
			ifTrue:[referent width: (referent width min: container width - self width)].
		referent top: container top + self referentMargin y.
	] ifFalse: [
		referent hResizing == #rigid
			ifTrue:[referent width: container width].
		referent vResizing == #rigid
			ifTrue:[referent height: (referent height min: container height - self height)].
		referent left: container left + self referentMargin x.
	] 
]

{ #category : #events }
SugarNavTab >> wantsHalo [

	^ false.

]

{ #category : #events }
SugarNavTab >> wantsHaloFromClick [

	^ true.

]

{ #category : #menu }
SugarNavTab >> wantsHaloHandleWithSelector: aSelector inHalo: aHaloMorph [
	"Answer whether the receiver would like to offer the halo handle with the given selector (e.g. #addCollapseHandle:)"

	(#(addDupHandle: addMakeSiblingHandle: addCollapseHandle: ) includes: aSelector) ifTrue:
		[^ false].

	^ super wantsHaloHandleWithSelector: aSelector inHalo: aHaloMorph

]

{ #category : #positioning }
SugarNavTab >> wantsToBeTopmost [

	^ false.

]

{ #category : #menu }
SugarNavTab >> wording [

	^ 'Sugar Navigation Flap' translated.

]
