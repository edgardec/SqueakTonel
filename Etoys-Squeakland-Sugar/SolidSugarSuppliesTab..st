"
Represents the horizontal ""solid"" tab by which the sugar-supplies flap can be resized.  When the supplies flap is *closed*, the tab is invisible.
"
Class {
	#name : #SolidSugarSuppliesTab,
	#superclass : #FlapTab,
	#instVars : [
		'sugarNavTab'
	],
	#category : #'Etoys-Squeakland-Sugar'
}

{ #category : #'show & hide' }
SolidSugarSuppliesTab >> addCustomMenuItems: aMenu hand: aHand [
	"Overridden in order to thwart super."


]

{ #category : #'show & hide' }
SolidSugarSuppliesTab >> adjustPositionAfterHidingFlap [
	"Make the receiver, in effect, invisible when the flap is closed."

	super adjustPositionAfterHidingFlap.
	self setProperty: #heightWhenOpen toValue: self height.
	self height: 0	
]

{ #category : #initialization }
SolidSugarSuppliesTab >> arrangeToPopOutOnDragOver: aBoolean [
	"Set up the receiver to respond appropriately to mouse-enter-dragging and mouse-leave-dragging situations."

	aBoolean
		ifTrue:
			[referent on: #mouseLeaveDragging send: #maybeHideFlapOnMouseLeaveDragging to: self.
			self on: #mouseLeaveDragging send: #maybeHideFlapOnMouseLeaveDragging to: self]
		ifFalse:
			[self on: #mouseEnterDragging send: nil to: nil.
			referent on: #mouseLeaveDragging send: nil to: nil.
			self on: #mouseLeaveDragging send: nil to: nil]
]

{ #category : #initialization }
SolidSugarSuppliesTab >> initialize [
	"Set up the receiver to have a solid tab."

	super initialize.
	self useSolidTab.
	"self applyThickness: 20."
]

{ #category : #'event handling' }
SolidSugarSuppliesTab >> mouseMove: evt [
	"Handle a mouse-move within the solid tab."

	| aPosition newReferentThickness adjustedPosition thick |
	dragged ifFalse: [(thick := self referentThickness) > 0
		ifTrue: [lastReferentThickness := thick]].

	aPosition := evt cursorPoint.
	edgeToAdhereTo == #top
		ifTrue:
			[adjustedPosition := aPosition - evt hand targetOffset.
			newReferentThickness := adjustedPosition y - sugarNavTab height]
		ifFalse:
			[adjustedPosition := aPosition + evt hand targetOffset.
			newReferentThickness := self world height - (adjustedPosition y + sugarNavTab height)].

	self applyThickness: newReferentThickness.
	dragged := true.
	self fitOnScreen.
	self computeEdgeFraction
]

{ #category : #mechanics }
SolidSugarSuppliesTab >> positionObject: anObject atEdgeOf: container [
	"Position an object -- either the receiver or its referent -- on the edge of the container."

	| extra |
	extra := (sugarNavTab notNil and: [referent isInWorld])
		ifTrue:
			[sugarNavTab height]
		ifFalse:
			[0].

	edgeToAdhereTo == #top ifTrue:
		[^ anObject top: container top + extra].

	"bottom..."
	anObject == self
		ifFalse:   "the parts bin"
			[anObject bottom: (container bottom - extra)]
		ifTrue:  "the tab"
			[anObject bottom: (container bottom - (self referentThickness + extra))] 
]

{ #category : #'show & hide' }
SolidSugarSuppliesTab >> showFlap [
	"Open the flap up"

	self height: (self valueOfProperty: #heightWHenOpen ifAbsent: [20]).
	super showFlap
]

{ #category : #positioning }
SolidSugarSuppliesTab >> spanWorld [
	"Make the receiver's width commensurate with that of the container."

	super spanWorld.
	self width:  self pasteUpMorph width
]

{ #category : #initialization }
SolidSugarSuppliesTab >> sugarNavTab: anObject [
	"Set the receiver's sugarNavTab."

	sugarNavTab := anObject
]

{ #category : #mechanics }
SolidSugarSuppliesTab >> wantsToBeTopmost [
	"Answer true iff flap is currently showing."

	^ self flapShowing

]
