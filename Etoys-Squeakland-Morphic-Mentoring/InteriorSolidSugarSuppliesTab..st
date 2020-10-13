"
A ""solid"" flap tab used in conjunction with the sugar supplies bin used on the interior of an event theatre.
"
Class {
	#name : #InteriorSolidSugarSuppliesTab,
	#superclass : #InteriorFlapTab,
	#instVars : [
		'sugarNavBar'
	],
	#category : #'Etoys-Squeakland-Morphic-Mentoring'
}

{ #category : #menu }
InteriorSolidSugarSuppliesTab >> addCustomMenuItems: aMenu hand: aHand [
	"Overridden in order to thwart super."


]

{ #category : #'show & hide' }
InteriorSolidSugarSuppliesTab >> adjustPositionAfterHidingFlap [
	"The flap has has been hidden; adjust the tab's position.  In this case, the tab reduces to zero height."

	super adjustPositionAfterHidingFlap.
	self setProperty: #heightWhenOpen toValue: self height.
	self height: 0	
]

{ #category : #initialization }
InteriorSolidSugarSuppliesTab >> arrangeToPopOutOnDragOver: aBoolean [
	"Set up the receiver with the right dragover properties."

	aBoolean
		ifTrue:
			[referent on: #mouseLeaveDragging send: #maybeHideFlapOnMouseLeaveDragging to: self.
			self on: #mouseLeaveDragging send: #maybeHideFlapOnMouseLeaveDragging to: self]
		ifFalse:
			[self on: #mouseEnterDragging send: nil to: nil.
			referent on: #mouseLeaveDragging send: nil to: nil.
			self on: #mouseLeaveDragging send: nil to: nil]
]

{ #category : #positioning }
InteriorSolidSugarSuppliesTab >> fitOnScreen [
	"19 sept 2000 - allow flaps in any paste up"
	| constrainer t l |
	constrainer := owner ifNil: [self].
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

{ #category : #initialization }
InteriorSolidSugarSuppliesTab >> initialize [
	"Set up the receiver to have a solid tab."

	super initialize.
	self beSticky
]

{ #category : #'event handling' }
InteriorSolidSugarSuppliesTab >> mouseMove: evt [
	"Handle a mouse-move within the solid tab."

	| aPosition newReferentThickness adjustedPosition thick aWorldlet |
	true ifTrue: [^ self].
	dragged ifFalse: [(thick := self referentThickness) > 0
		ifTrue: [lastReferentThickness := thick]].

	aWorldlet := self ownerThatIsA: Worldlet.
	aPosition := evt cursorPoint - aWorldlet position.
	edgeToAdhereTo == #top
		ifTrue:
			[adjustedPosition := aPosition - evt hand targetOffset.
			newReferentThickness := adjustedPosition y - self navBarHeight]
		ifFalse:
			[adjustedPosition := aPosition - evt hand targetOffset.
			newReferentThickness := aWorldlet height - (adjustedPosition y + self navBarHeight + self height)].

	self applyThickness: newReferentThickness.
	dragged := true.
	self fitOnScreen
]

{ #category : #mechanics }
InteriorSolidSugarSuppliesTab >> navBarHeight [
	"Answer the height of the nav-bar of the evt theatre with which the receiver is associated."

	^ sugarNavBar height
]

{ #category : #initialization }
InteriorSolidSugarSuppliesTab >> naviHeight: anInteger [
	"Set the navigator height."

	submorphs ifEmpty: [^ self].
	submorphs first extent: anInteger@anInteger.

]

{ #category : #mechanics }
InteriorSolidSugarSuppliesTab >> positionObject: anObject atEdgeOf: container [
	"Position an object -- either the receiver or its referent -- on the edge of the container."

	| extra |
	extra := self navBarHeight - 2.
	edgeToAdhereTo == #top
		ifTrue:
			[anObject top: container top + extra]
		ifFalse: 
			[anObject bottom: (container bottom - extra)] 
]

{ #category : #'show & hide' }
InteriorSolidSugarSuppliesTab >> showFlap [
	"Open the flap up"

	self height: (self valueOfProperty: #heightWHenOpen ifAbsent: [20]).
	super showFlap
]

{ #category : #positioning }
InteriorSolidSugarSuppliesTab >> spanWorld [
	"Make the receiver's width commensurate with that of the container."

	super spanWorld.
	self width:  self pasteUpMorph width
]

{ #category : #accessing }
InteriorSolidSugarSuppliesTab >> sugarNavBar: aBar [
	"Establish the value of the sugarNavBar instance variable."

	sugarNavBar := aBar
]

{ #category : #mechanics }
InteriorSolidSugarSuppliesTab >> wantsToBeTopmost [
	"Answer if the receiver want to be one of the topmost objects in its owner"

	^ self flapShowing

]
