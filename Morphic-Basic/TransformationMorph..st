"
A TransformationMorph is like a transformMorph, except that it does not clip, and its bounds include its entire submorph.  TransformationMorphs are assumed to have only one submorph -- the idea is that it is a wrapper that enables its submorph to scale and rotate.  A TMorph may come to have more than one submorph if, eg, a menu sprouts a sub menu, using the transformationMorph temporarily as its world, but this ability is only sparsely supported (as in layoutChanged).

See TransformationMorph class example1 method.
"
Class {
	#name : #TransformationMorph,
	#superclass : #TransformMorph,
	#category : #'Morphic-Basic'
}

{ #category : #example }
TransformationMorph class >> example1 [
	| stringMorph transformationMorph |
	stringMorph := 'vertical text' asMorph.
	transformationMorph := TransformationMorph new asFlexOf: stringMorph.
	transformationMorph angle: Float pi / 2.
	transformationMorph position: 5@5.
	transformationMorph openInWorld.
]

{ #category : #private }
TransformationMorph >> adjustAfter: changeBlock [ 
	"Cause this morph to remain cetered where it was before, and
	choose appropriate smoothing, after a change of scale or rotation."
	| oldRefPos |
	oldRefPos := self referencePosition.
	changeBlock value.
	self chooseSmoothing.
	self penUpWhile: [self position: self position + (oldRefPos - self referencePosition)].
	self layoutChanged.
	owner ifNotNil: [owner invalidRect: bounds]

]

{ #category : #initialization }
TransformationMorph >> asFlexOf: aMorph [
	"Initialize me with position and bounds of aMorph,
	and with an offset that provides centered rotation."
	| pos |
	pos := aMorph position.
	self addMorph: aMorph.
	aMorph position: (aMorph extent // 2) negated.
	self position: pos.
	transform := transform withOffset: aMorph position - pos

]

{ #category : #private }
TransformationMorph >> chooseSmoothing [
	"Choose appropriate smoothing, after a change of scale or rotation."

	smoothing := (self scale < 1.0 or: [self angle ~= (self angle roundTo: Float pi / 2.0)]) 
		ifTrue: [ 2]
		ifFalse: [1]
]

{ #category : #geometry }
TransformationMorph >> computeBounds [
	self hasSubmorphs ifTrue:
		[bounds := (transform localBoundsToGlobal:
					(Rectangle merging:
						(self submorphs collect: [:m | m fullBounds]))) truncated
				expandBy: 1].
	fullBounds := bounds.
]

{ #category : #drawing }
TransformationMorph >> drawOn: aCanvas [
	submorphs isEmpty ifTrue: [super drawOn: aCanvas]
]

{ #category : #geometry }
TransformationMorph >> extent: newExtent [

	self renderedMorph == self
		ifTrue: [super extent: newExtent]
		ifFalse: [
			self adjustAfter: [
				| scaleFactor |
				scaleFactor := (self scale * newExtent r / self fullBounds extent r) max: 0.1.
				self scale: (scaleFactor detentBy: 0.1 atMultiplesOf: 1.0 snap: false)]].
]

{ #category : #initialization }
TransformationMorph >> flexing: aMorph byTransformation: tfm [
	"Initialize me with position and bounds of aMorph,
	and with an offset that provides centered rotation."

	(aMorph isKindOf: TransformationMorph)
		ifTrue: [aMorph submorphsDo: [:m | self addMorph: m shallowCopy]]
		ifFalse: [self addMorph: aMorph].
	transform := tfm.
	self chooseSmoothing.
	self layoutChanged.
]

{ #category : #'rotate scale and flex' }
TransformationMorph >> forwardDirection [
	"Return the rendee's forward direction. 
	If I have no rendee then return 0.0 degrees "
	| rendee |
	( rendee := self renderedMorph) == self  ifTrue: [ ^ 0.0 ] .
	
	^ rendee forwardDirection
]

{ #category : #'rotate scale and flex' }
TransformationMorph >> forwardDirection: degrees [
 "If we have a rendee set its forward direction. Else do nothing." 

| rendee |
( rendee := self renderedMorph) == self ifTrue: [ ^ self  ] .
	^rendee forwardDirection: degrees
]

{ #category : #'dropping\/grabbing' }
TransformationMorph >> grabTransform [
	"Return the transform for the receiver which should be applied during grabbing"
	self renderedMorph isWorldMorph 
		ifTrue:[^owner ifNil:[IdentityTransform new] ifNotNil:[owner grabTransform]].
	^owner ifNil:[self transform] ifNotNil:[owner grabTransform composedWithLocal: self transform]
]

{ #category : #accessing }
TransformationMorph >> hasNoScaleOrRotation [

	^ transform isPureTranslation

]

{ #category : #'rotate scale and flex' }
TransformationMorph >> heading [
	"End recusion when necessary."
	| rendee |
	(rendee := self renderedMorph) == self ifTrue: [ ^0.0 ] .
	^ rendee heading
]

{ #category : #'rotate scale and flex' }
TransformationMorph >> heading: newHeading [
 "If we have a rendee set its heading. Else do nothing." 

| rendee |
( rendee := self renderedMorph) == self ifTrue: [ ^ self  ] .
	^rendee heading: newHeading
]

{ #category : #initialization }
TransformationMorph >> initialize [

	super initialize.
	
	self
		color: ((Color gray: 0.7) alpha: 0.5);
		borderStyle: (DashedBorder color: (Color gray: 0.4) width: 1).
]

{ #category : #naming }
TransformationMorph >> innocuousName [
	| r |
	^ (r := self renderedMorph) == self
		ifTrue: [super innocuousName] ifFalse: [r innocuousName]
]

{ #category : #classification }
TransformationMorph >> isFlexMorph [

	^ true

]

{ #category : #classification }
TransformationMorph >> isRenderer [

	^ true

]

{ #category : #testing }
TransformationMorph >> isSticky [
submorphs isEmpty ifFalse: [ ^ 	submorphs first isSticky ] .
	
^false
]

{ #category : #layout }
TransformationMorph >> layoutChanged [
	"Recompute bounds as a result of change"
	self computeBounds.
	super layoutChanged
]

{ #category : #printing }
TransformationMorph >> printOn: aStream [ 
	super printOn: aStream.
	submorphs isEmpty 
		ifTrue: [aStream nextPutAll: ' with no transformee!']
		ifFalse: [aStream nextPutAll: ' on ' , submorphs first printString]
]

{ #category : #'rotate scale and flex' }
TransformationMorph >> referencePosition [
	"Answer the  receiver's reference position, bullet-proofed against infinite recursion in the unlikely but occasionally-seen case that I am my own renderee"

	| rendered |
	^ (rendered := self renderedMorph) == self
		ifTrue:
			[super referencePosition]
		ifFalse:
			[transform localPointToGlobal: rendered referencePosition]
]

{ #category : #menu }
TransformationMorph >> removeFlexShell [
	"Remove the shell used to make a morph rotatable and scalable."

	| oldHalo unflexed pensDown myWorld refPos aPosition |
	self isInWorld ifFalse: [^self].
	refPos := self referencePosition.
	myWorld := self world.
	oldHalo := self halo.
	submorphs isEmpty ifTrue: [^ self delete].
	aPosition := (owner submorphIndexOf: self) ifNil: [1].
	unflexed := self firstSubmorph.
	pensDown := OrderedCollection new.
	self allMorphsDo:  "Note any pens down -- must not be down during the move"
		[:m | | player |
		((player := m player) notNil and: [player getPenDown]) ifTrue:
			[m == player costume ifTrue:
				[pensDown add: player.
				player setPenDown: false]]].
	self submorphs do: [:m |
		m position: self center - (m extent // 2).
		owner addMorph: m asElementNumber: aPosition].
	unflexed absorbStateFromRenderer: self.
	pensDown do: [:p | p setPenDown: true].
	oldHalo ifNotNil: [oldHalo setTarget: unflexed].
	myWorld ifNotNil: [myWorld startSteppingSubmorphsOf: unflexed].
	self delete.
	unflexed referencePosition: refPos.
	^ unflexed
]

{ #category : #classification }
TransformationMorph >> renderedMorph [
"We are a renderer. Answer appropriately."

submorphs isEmpty ifTrue: [^self].
	^self firstSubmorph renderedMorph
]

{ #category : #'submorphs-add\/remove' }
TransformationMorph >> replaceSubmorph: oldMorph by: newMorph [
	| t b |
	t := transform.
	b := bounds.
	super replaceSubmorph: oldMorph by: newMorph.
	transform := t.
	bounds := b.
	self layoutChanged
]

{ #category : #'rotate scale and flex' }
TransformationMorph >> rotationDegrees [
	"Overwritten because we can directly inform about the rotation."
	
	^ self angle radiansToDegrees negated
]

{ #category : #'rotate scale and flex' }
TransformationMorph >> rotationDegrees: degrees [
	"Overwritten because we know how to rotate our submorphs."
	
	self adjustAfter:[self angle: degrees degreesToRadians negated]
]

{ #category : #accessing }
TransformationMorph >> scaleFactor [
	"Answer the scaleFactor"

	^ transform scale
]

{ #category : #accessing }
TransformationMorph >> scaleToMatch: aPoint [ 
	| scaleFactor tfm originalScale |
	tfm := transform withScale: 1.0.
	originalScale := ((tfm localBoundsToGlobal: self renderedMorph fullBounds) 
				corner - (tfm localPointToGlobal: self renderedMorph referencePosition)) 
				r.
	"Catch cases where the reference point is on fullBounds corner"
	originalScale := originalScale max: 1.0.
	scaleFactor := (aPoint - self referencePosition) r / originalScale.
	scaleFactor := scaleFactor < 1.0 
				ifTrue: 
					[scaleFactor 
						detentBy: 0.05
						atMultiplesOf: 0.25
						snap: false]
				ifFalse: 
					[scaleFactor 
						detentBy: 0.1
						atMultiplesOf: 0.5
						snap: false].
	self adjustAfter: [self scale: ((scaleFactor min: 8.0) max: 0.1)]
]

{ #category : #'rotate scale and flex' }
TransformationMorph >> setDirectionFrom: aPoint [
	| delta degrees inner |
	inner := self renderedMorph.
	inner == self ifTrue:[^self].
	delta := (inner transformFromWorld globalPointToLocal: aPoint) - inner referencePosition.
	degrees := delta degrees + 90.0.
	self forwardDirection: (degrees \\ 360) rounded.

]

{ #category : #'dropping\/grabbing' }
TransformationMorph >> shouldDropOnMouseUp [
	
	^ self renderedMorph in: [:target |
		target == self
			ifTrue: [super shouldDropOnMouseUp]
			ifFalse: [target shouldDropOnMouseUp]]
]

{ #category : #'geometry eToy' }
TransformationMorph >> simplySetVisible: aBoolean [
	"Set the receiver's visibility property.  This mild circumlocution is because my own #visible: method would also set the visibility flag of my flexee, which in this case is pointless because it's the flexee that calls this."

	super visible: aBoolean
]

{ #category : #'stepping and presenter' }
TransformationMorph >> stepTime [
	"Answer the stepTime of my rendered morph if posible"

	| rendered |
	rendered := self renderedMorph.
	rendered = self ifTrue: [^super stepTime].	"Hack to avoid infinite recursion"
	^rendered stepTime.
	
]

{ #category : #geometry }
TransformationMorph >> transformedBy: aTransform [
	self changed.
	self transform: (self transform composedWithGlobal: aTransform).
	self computeBounds.
	self changed.
]

{ #category : #'geometry eToy' }
TransformationMorph >> visible: aBoolean [
	"Set the receiver's visibility property"

	super visible: aBoolean.
	submorphs isEmptyOrNil ifFalse: [submorphs first visible: aBoolean]
]

{ #category : #'halos and balloon help' }
TransformationMorph >> wantsHaloFromClick [

	^ self renderedMorph == self
]
