"
I am a specialization of EllipseMorph that knows enough to remain circular.

"
Class {
	#name : #CircleMorph,
	#superclass : #EllipseMorph,
	#category : #'Morphic-Basic'
}

{ #category : #'instance creation' }
CircleMorph class >> newPin [
	"Construct a pin for embedded attachment"
	"CircleMorph newPin openInHand"
	^self new
		removeAllMorphs;
		extent: 18@18;
		hResizing: #rigid;
		vResizing: #rigid;
		layoutPolicy: nil;
		color: Color orange lighter;
		borderColor: Color orange darker;
		borderWidth: 2;
		name: 'Pin'
]

{ #category : #'parts bin' }
CircleMorph class >> supplementaryPartsDescriptions [
	"Extra items for parts bins"

	^ {DescriptionForPartsBin
		formalName: 'Circle' translatedNoop
		categoryList: {'Graphics' translatedNoop}
		documentation: 'A circular shape' translatedNoop
		globalReceiverSymbol: #CircleMorph 
		nativitySelector: #newStandAlone.

	DescriptionForPartsBin
		formalName: 'Pin' translatedNoop
		categoryList: {'Connectors' translatedNoop}
		documentation: 'An attachment point for Connectors that you can embed in another Morph.' translatedNoop
		globalReceiverSymbol: #NCPinMorph 
		nativitySelector: #newPin.
}
]

{ #category : #'rotate scale and flex' }
CircleMorph >> addFlexShellIfNecessary [
	"When scaling or rotating from a halo, I can do this without a flex shell"

	^ self

]

{ #category : #geometry }
CircleMorph >> bounds: aRectangle [
	| size |
	size := aRectangle width min: aRectangle height.
	super bounds: (Rectangle origin: aRectangle origin extent: size @ size).
]

{ #category : #geometry }
CircleMorph >> extent: aPoint [
	| size oldRotationCenter |
	oldRotationCenter := self rotationCenter.
	size := aPoint x min: aPoint y.
	super extent: size @ size.
	self rotationCenter: oldRotationCenter.
]

{ #category : #'rotate scale and flex' }
CircleMorph >> heading [
	"Overwritten to store the angle in #forwardDirection."
	
	^ self rotationDegrees
]

{ #category : #'rotate scale and flex' }
CircleMorph >> heading: newHeading [
	"Overwritten to store the angle in #forwardDirection."

	self rotationDegrees: newHeading.
]

{ #category : #'parts bin' }
CircleMorph >> initialize [
	super initialize.
	self extent: 40@40;
		color: Color green lighter
]

{ #category : #'parts bin' }
CircleMorph >> initializeToStandAlone [
	^super initializeToStandAlone
		extent: 40@40;
		color: Color green lighter;
		yourself
]

{ #category : #'rotate scale and flex' }
CircleMorph >> privateMoveBy: delta [
	self setProperty: #referencePosition toValue: self referencePosition + delta.
	self setProperty: #originalCenter toValue: (self valueOfProperty: #originalCenter ifAbsent: [ self center ]) + delta.
	super privateMoveBy: delta.

]

{ #category : #'rotate scale and flex' }
CircleMorph >> referencePosition [ 
	"Return the current reference position of the receiver"
	^ self valueOfProperty: #referencePosition ifAbsent: [ self center ]

]

{ #category : #'rotate scale and flex' }
CircleMorph >> rotationCenter [
	"Return the rotation center of the receiver. The rotation center defines the relative offset inside the receiver's bounds for locating the reference position."
	| refPos |
	refPos := self referencePosition.
	^ (refPos - self bounds origin) / self bounds extent asFloatPoint
]

{ #category : #'rotate scale and flex' }
CircleMorph >> rotationCenter: aPointOrNil [
	"Set the new rotation center of the receiver. The rotation center defines the relative offset inside the receiver's bounds for locating the reference position."
	| newRef box |
	aPointOrNil isNil
		ifTrue: [self removeProperty: #referencePosition.
			self removeProperty: #originalCenter.
			self removeProperty: #originalAngle. ]
		ifFalse: [ box := self bounds.
				newRef := box origin + (aPointOrNil * box extent).
				self setRotationCenterFrom: newRef ].


]

{ #category : #'rotate scale and flex' }
CircleMorph >> rotationDegrees [

	^ self forwardDirection
]

{ #category : #'rotate scale and flex' }
CircleMorph >> rotationDegrees: degrees [
	| ref newPos flex origAngle origCenter |
	ref := self referencePosition.
	origAngle := self valueOfProperty: #originalAngle ifAbsentPut: [ self heading ].
	origCenter := self valueOfProperty: #originalCenter ifAbsentPut: [ self center ].
	flex := (MorphicTransform offset: ref negated)
			withAngle: (degrees - origAngle) degreesToRadians.
	newPos := (flex transform: origCenter) - flex offset.
	self position: (self position + newPos - self center) asIntegerPoint.
	self setProperty: #referencePosition toValue: ref.
	self setProperty: #originalAngle toValue: origAngle.
	self setProperty: #originalCenter toValue: origCenter.
	self forwardDirection: degrees.
	self changed.

]

{ #category : #menus }
CircleMorph >> setRotationCenterFrom: aPoint [
	"Called by halo rotation code.
	Circles store their referencePosition."
	self setProperty: #referencePosition toValue: aPoint.
	self setProperty: #originalCenter toValue: self center.
	self setProperty: #originalAngle toValue: self heading.
]

{ #category : #geometry }
CircleMorph >> transformedBy: aTransform [
	aTransform isIdentity ifTrue:[^self].
	^self center: (aTransform localPointToGlobal: self center).

]
