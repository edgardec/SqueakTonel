"
MatrixTransformMorph is similar to TransformMorph but uses a MatrixTransform2x3 instead of a MorphicTransform. It is used by clients who want use the BalloonEngine for vector-based scaling instead of the standard WarpBlt pixel-based mechanism.
"
Class {
	#name : #MatrixTransformMorph,
	#superclass : #Morph,
	#instVars : [
		'transform'
	],
	#category : #'Morphic-Balloon'
}

{ #category : #'rotate scale and flex' }
MatrixTransformMorph >> addFlexShell [
	"No flex shell necessary"
	self lastRotationDegrees: 0.0.
]

{ #category : #initialize }
MatrixTransformMorph >> asFlexOf: aMorph [
	"Initialize me with position and bounds of aMorph,
	and with an offset that provides centered rotation."
	self addMorph: aMorph.
	self setRotationCenterFrom: aMorph center .
	self lastRotationDegrees: 0.0. 
	self computeBounds
]

{ #category : #'halos and balloon help' }
MatrixTransformMorph >> balloonHelpTextForHandle: aHandle [
	aHandle eventHandler firstMouseSelector == #changeRotationCenter:with:
		ifTrue:[^'set center of rotation'].
	^super balloonHelpTextForHandle: aHandle
]

{ #category : #geometry }
MatrixTransformMorph >> boundsChangedFrom: oldBounds to: newBounds [
	oldBounds extent = newBounds extent ifFalse:[
		transform := transform composedWithGlobal:
			(MatrixTransform2x3 withOffset: oldBounds origin negated).
		transform := transform composedWithGlobal:
			(MatrixTransform2x3 withScale: newBounds extent / oldBounds extent).
		transform := transform composedWithGlobal:
			(MatrixTransform2x3 withOffset: newBounds origin).
	].
	transform offset: transform offset + (newBounds origin - oldBounds origin)
]

{ #category : #flexing }
MatrixTransformMorph >> changeRotationCenter: evt with: rotHandle [
	| pos |
	pos := evt cursorPoint.
	rotHandle referencePosition: pos.
	self referencePosition: pos.
]

{ #category : #updating }
MatrixTransformMorph >> changed [
	^self invalidRect: (self fullBounds insetBy: -1)
]

{ #category : #geometry }
MatrixTransformMorph >> computeBounds [
	| box |
	(submorphs isNil or:[submorphs isEmpty]) ifTrue:[^self].
	box := nil.
	submorphs do:[:m| | subBounds |
		subBounds := self transform localBoundsToGlobal: m bounds.
		box 
			ifNil:[box := subBounds]
			ifNotNil:[box := box quickMerge: subBounds].
	].
	box ifNil:[box := 0@0 corner: 20@20].
	fullBounds := bounds := box
]

{ #category : #'geometry testing' }
MatrixTransformMorph >> containsPoint: aPoint [
	self visible ifFalse:[^false].
	(bounds containsPoint: aPoint) ifFalse: [^ false].
	self hasSubmorphs
		ifTrue: [self submorphsDo: 
					[:m | (m fullContainsPoint: (self transform globalPointToLocal: aPoint))
							ifTrue: [^ true]].
				^ false]
		ifFalse: [^ true]
]

{ #category : #drawing }
MatrixTransformMorph >> drawOn: aCanvas [
]

{ #category : #drawing }
MatrixTransformMorph >> drawSubmorphsOn: aCanvas [
	aCanvas asBalloonCanvas transformBy: self transform
		during:[:myCanvas| super drawSubmorphsOn: myCanvas].
]

{ #category : #geometry }
MatrixTransformMorph >> extent: extent [
	self handleBoundsChange:[super extent: extent]
]

{ #category : #layout }
MatrixTransformMorph >> fullBounds [
	
	fullBounds ifNil:[
		fullBounds := self bounds.
		submorphs do:[:m| | subBounds |
			subBounds := (self transform localBoundsToGlobal: m fullBounds).
			fullBounds := fullBounds quickMerge: subBounds.
		].
	].
	^fullBounds
]

{ #category : #'geometry testing' }
MatrixTransformMorph >> fullContainsPoint: aPoint [
	| p |
	self visible ifFalse:[^false].
	(self fullBounds containsPoint: aPoint) ifFalse:[^false].
	(self containsPoint: aPoint) ifTrue:[^true].
	p := self transform globalPointToLocal: aPoint.
	submorphs do:[:m|
		(m fullContainsPoint: p) ifTrue:[^true].
	].
	^false
]

{ #category : #geometry }
MatrixTransformMorph >> handleBoundsChange: aBlock [
	| oldBounds newBounds |
	oldBounds := bounds.
	aBlock value.
	newBounds := bounds.
	self boundsChangedFrom: oldBounds to: newBounds.
]

{ #category : #flexing }
MatrixTransformMorph >> hasNoScaleOrRotation [
	^true
]

{ #category : #'rotate scale and flex' }
MatrixTransformMorph >> heading [
	"Return the receiver's heading (in eToy terms)"
	^ self forwardDirection + self innerAngle
]

{ #category : #'rotate scale and flex' }
MatrixTransformMorph >> heading: newHeading [
	"Set the receiver's heading (in eToy terms)"
	self rotateBy: ((newHeading - self forwardDirection) - self innerAngle).
]

{ #category : #initialization }
MatrixTransformMorph >> initialize [
"initialize the state of the receiver"
	super initialize.
""
	transform := MatrixTransform2x3 identity
]

{ #category : #flexing }
MatrixTransformMorph >> innerAngle [
	^ (self transform a11 @ self transform a21) degrees
]

{ #category : #'change reporting' }
MatrixTransformMorph >> invalidRect: rect from: aMorph [
	aMorph == self
		ifTrue:[super invalidRect: rect from: self]
		ifFalse:[super invalidRect: (self transform localBoundsToGlobal: rect) from: aMorph].
]

{ #category : #flexing }
MatrixTransformMorph >> lastRotationDegrees [
	^(self valueOfProperty: #lastRotationDegrees) ifNil:[0.0].
]

{ #category : #flexing }
MatrixTransformMorph >> lastRotationDegrees: deg [
	deg = 0.0 
		ifTrue:[self removeProperty: #lastRotationDegrees]
		ifFalse:[self setProperty: #lastRotationDegrees toValue: deg]
]

{ #category : #private }
MatrixTransformMorph >> privateFullMoveBy: delta [
	self privateMoveBy: delta.
	transform offset: transform offset + delta.
]

{ #category : #flexing }
MatrixTransformMorph >> removeFlexShell [
	"Do nothing"
]

{ #category : #flexing }
MatrixTransformMorph >> rotateBy: delta [
	| pt m |
	delta = 0.0 ifTrue:[^self].
	self changed.
	pt := self transformFromWorld globalPointToLocal: self referencePosition.
	m := MatrixTransform2x3 withOffset: pt.
	m := m composedWithLocal: (MatrixTransform2x3 withAngle: delta).
	m := m composedWithLocal: (MatrixTransform2x3 withOffset: pt negated).
	self transform: (transform composedWithLocal: m).
	self changed.
]

{ #category : #'rotate scale and flex' }
MatrixTransformMorph >> rotationCenter [
	| pt |
	pt := self transform localPointToGlobal: super rotationCenter.
	^pt - bounds origin / bounds extent asFloatPoint
]

{ #category : #'rotate scale and flex' }
MatrixTransformMorph >> rotationCenter: aPoint [
	super rotationCenter: (self transform globalPointToLocal: bounds origin + (bounds extent * aPoint))
]

{ #category : #flexing }
MatrixTransformMorph >> rotationDegrees: degrees [
	| last delta |
	last := self lastRotationDegrees.
	delta := degrees - last.
	self rotateBy: delta.
	self lastRotationDegrees: degrees.
]

{ #category : #'rotate scale and flex' }
MatrixTransformMorph >> setDirectionFrom: aPoint [
	| delta degrees |
	delta := (self transformFromWorld globalPointToLocal: aPoint) - super rotationCenter.
	degrees := delta degrees + 90.0.
	self forwardDirection: (degrees \\ 360) rounded.

]

{ #category : #menus }
MatrixTransformMorph >> setRotationCenterFrom: aPoint [

	super setRotationCenterFrom: (self transformFromWorld localPointToGlobal: aPoint)

]

{ #category : #flexing }
MatrixTransformMorph >> transform [
	^ transform ifNil: [MatrixTransform2x3 identity]
]

{ #category : #accessing }
MatrixTransformMorph >> transform: aMatrixTransform [
	transform := aMatrixTransform.
	self computeBounds.
]

{ #category : #'event handling' }
MatrixTransformMorph >> transformFrom: uberMorph [
	(owner isNil or:[self == uberMorph]) ifTrue:[^self transform].
	^(owner transformFrom: uberMorph) asMatrixTransform2x3 composedWithLocal: self transform
]

{ #category : #geometry }
MatrixTransformMorph >> transformedBy: aTransform [
	self transform: (self transform composedWithGlobal: aTransform).
]

{ #category : #drawing }
MatrixTransformMorph >> visible: aBoolean [ 
	"set the 'visible' attribute of the receiver to aBoolean"
	extension ifNil: [aBoolean ifTrue: [^ self]].
	self assureExtension visible: aBoolean
]
