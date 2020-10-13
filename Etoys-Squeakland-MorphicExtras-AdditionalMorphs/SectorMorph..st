Class {
	#name : #SectorMorph,
	#superclass : #PolygonMorph,
	#instVars : [
		'angle'
	],
	#category : #'Etoys-Squeakland-MorphicExtras-AdditionalMorphs'
}

{ #category : #'viewer categories' }
SectorMorph class >> additionsToViewerCategories [
	"Answer additions to viewer categories."

	^ #((basic
			((slot angle 'the angle, in degrees, at the vertex of the sector' Number readWrite Player getSectorAngle Player setSectorAngle:)
			(slot radius 'length of a radius of the sector' Number readWrite Player getSectorRadius Player setSectorRadius:)))

		(sector
			((slot angle 'the angle, in degrees, at the vertex of the sector' Number readWrite Player getSectorAngle Player setSectorAngle:)
			(slot radius 'length of a radius of the sector' Number readWrite Player getSectorRadius Player setSectorRadius:)
			(slot showingHandles 'Whether the handles are showing' Boolean readWrite Player getShowingHandles  Player setShowingHandles:)
)))
]

{ #category : #'parts bin' }
SectorMorph class >> descriptionForPartsBin [
	^ self
		partName: 'Sector' translatedNoop
		categories: {'Graphics' translatedNoop}
		documentation: 'A sector tool that lets you create slices of a pie of any angle for applications like fractions or drawing' translatedNoop
]

{ #category : #'menu & halo' }
SectorMorph >> addCustomMenuItems: aMenu hand: aHandMorph [ 
	aMenu
		addUpdating: #handlesShowingPhrase
		target: self
		action: #showOrHideHandles
]

{ #category : #editing }
SectorMorph >> addHandles [
	| handle |
	self removeHandles.
	handle := EllipseMorph
				newBounds: (Rectangle center: vertices last extent: 16 @ 16)
				color: Color yellow.
	handle
		on: #mouseMove
		send: #dragEvent:fromHandle:
		to: self.
	handle
		on: #mouseUp
		send: #dropEvent:fromHandle:
		to: self.
	self addMorph: handle.
	handles := {handle}.
	self changed
]

{ #category : #accessing }
SectorMorph >> angle [
	^ angle
]

{ #category : #accessing }
SectorMorph >> angle: aNumber [ 
	angle = aNumber
		ifTrue: [^ self].
	angle := aNumber \\ 361.
	self update
]

{ #category : #updating }
SectorMorph >> computeBounds [
	super computeBounds.
	vertices ifNil: [^ self].
	self setRotationCenterFrom: vertices first
]

{ #category : #'event handling' }
SectorMorph >> dragEvent: evt fromHandle: morph [ 
	self angle: (evt position - vertices first * (1 @ -1)) degrees + self heading
]

{ #category : #'event handling' }
SectorMorph >> dropEvent: evt fromHandle: morph [ 
	self flag: #Richo
]

{ #category : #accessing }
SectorMorph >> extent: newExtent [ 
	self radius: (newExtent x max: newExtent y)
			/ 2
]

{ #category : #initialization }
SectorMorph >> initialize [
	angle := 45.
	super initialize.
	self initializeVertices; computeBounds
]

{ #category : #initialization }
SectorMorph >> initializeVertices [
	vertices := Array new: 50 withAll: 0 @ 0.
	vertices at: 1 put: bounds bottomLeft;
		 at: 2 put: bounds bottomRight.
	self updateVertices
]

{ #category : #accessing }
SectorMorph >> radius [
	^ vertices first dist: vertices second
]

{ #category : #accessing }
SectorMorph >> radius: aNumber [ 
	| v1 v2 dx dy ang dx2 dy2 |
	self radius = aNumber
		ifTrue: [^ self].
	v1 := vertices first.
	v2 := vertices second.
	dx := v2 x - v1 x.
	dx = 0
		ifTrue: [dx := 0.0001].
	dy := v2 y - v1 y.
	ang := (dy / dx) arcTan.
	(dx eToysLT: 0)
		ifTrue: [(dy eToysGT: 0)
				ifTrue: [ang:= ang + 3.1416]].
	(dx eToysLT: 0)
		ifTrue: [(dy eToysLT: 0)
				ifTrue: [ang:= ang + 3.1416]].
	dx2 := ang cos * aNumber.
	dy2 := ang sin * aNumber.
	vertices at: 2 put: v1 + (dx2 @ dy2).
	self update
]

{ #category : #updating }
SectorMorph >> update [
	self updateVertices; updateHandles; computeBounds
]

{ #category : #updating }
SectorMorph >> updateHandles [
	| ign |
	(ign := handles)
		ifNotNil: [handles first center: vertices last]
]

{ #category : #updating }
SectorMorph >> updateVertices [
	| nSegments sin cos xn yn xn1 yn1 |
	nSegments := vertices size - 2.
	sin := (angle / nSegments * (2 * Float pi / 360.0)) sin.
	cos := (angle / nSegments * (2 * Float pi / 360.0)) cos.
	xn := vertices second x - vertices first x.
	yn := vertices second y - vertices first y.
	3
		to: vertices size
		do: [:i | 
			xn1 := xn * cos + (yn * sin).
			yn1 := yn * cos - (xn * sin).
			vertices at: i put: vertices first + (xn1 @ yn1).
			xn := xn1.
			yn := yn1]
]
