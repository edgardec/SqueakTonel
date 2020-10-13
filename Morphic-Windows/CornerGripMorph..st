"
I am the superclass of a hierarchy of morph specialized in allowing the user to resize windows.
"
Class {
	#name : #CornerGripMorph,
	#superclass : #AbstractResizerMorph,
	#instVars : [
		'target'
	],
	#classVars : [
		'DrawCornerResizeHandles',
		'DrawEdgeResizeHandles'
	],
	#category : #'Morphic-Windows'
}

{ #category : #preferences }
CornerGripMorph class >> drawCornerResizeHandles [
	<preference: 'Draw Corner Resize Handles'
		category: 'windows'
		description: 'Set whether the resize handles on windows should be drawn on the window frame. This does not enable nor disable the resizing function'
		type: #Boolean>
	^ DrawCornerResizeHandles ifNil: [ false ]
]

{ #category : #preferences }
CornerGripMorph class >> drawCornerResizeHandles: aBoolean [
	
	DrawCornerResizeHandles := aBoolean.
	Project current restoreDisplay.
]

{ #category : #preferences }
CornerGripMorph class >> drawEdgeResizeHandles [
	<preference: 'Draw Edge Resize Handles'
		category: 'windows'
		description: 'Set whether the resize handles on windows should be drawn on the window frame. This does not enable nor disable the resizing function.'
		type: #Boolean>
	^ DrawEdgeResizeHandles ifNil: [ false ]
]

{ #category : #preferences }
CornerGripMorph class >> drawEdgeResizeHandles: aBoolean [
	
	DrawEdgeResizeHandles := aBoolean.
	Project current restoreDisplay.
]

{ #category : #accessing }
CornerGripMorph >> defaultHeight [

	^ self class handleLength
]

{ #category : #accessing }
CornerGripMorph >> defaultWidth [

	^ self class handleLength
]

{ #category : #accessing }
CornerGripMorph >> drawCornerResizeHandles [
	^ self valueOfProperty: #drawCornerResizeHandles ifAbsent: [self class drawCornerResizeHandles]
]

{ #category : #accessing }
CornerGripMorph >> drawCornerResizeHandles: aBoolean [
	self setProperty: #drawCornerResizeHandles toValue: aBoolean.
	self changed.
]

{ #category : #accessing }
CornerGripMorph >> handleInset [

	^ (handleInset notNil or: [self owner isNil])
		ifTrue: [handleInset ifNil: [1]]
		ifFalse: [self owner borderWidth max: 1]
]

{ #category : #'event handling' }
CornerGripMorph >> handlesMouseDown: anEvent [
	^ true
]

{ #category : #'event handling' }
CornerGripMorph >> handlesMouseOver: anEvent [
	^true
]

{ #category : #initialization }
CornerGripMorph >> initialize [

	super initialize.
	self extent: self defaultWidth @ self defaultHeight.
	self layoutFrame: self gripLayoutFrame.
]

{ #category : #'event handling' }
CornerGripMorph >> mouseDown: anEvent [ 
	"Disable drop shadow to improve performance while resizing."

	super mouseDown: anEvent.

	self target ifNil: [^ self].
	self target fastFramingOn ifFalse: [
		self setProperty: #targetHadDropShadow toValue: target hasDropShadow.
		self target hasDropShadow: false].
]

{ #category : #'event handling' }
CornerGripMorph >> mouseMove: anEvent [ 
	
	| delta |
	self target ifNil: [^ self].
	self target fastFramingOn 
		ifTrue: [delta := self target doFastWindowReframe: self ptName] 
		ifFalse: [
			delta := self referencePoint ifNil: [0@0] ifNotNil: [anEvent position - self referencePoint].
			self referencePoint: anEvent position.
			self apply: delta.
			self bounds: (self bounds origin + delta extent: self bounds extent)].
]

{ #category : #'event handling' }
CornerGripMorph >> mouseUp: anEvent [ 
	"Restore target drop shadow if there was one. See #mouseDown:."
	
	self target ifNil: [^ self].
	self target fastFramingOn ifFalse: [
		(self valueOfProperty: #targetHadDropShadow ifAbsent: [false]) ifTrue: [self target hasDropShadow: true].
		self removeProperty: #targetHadDropShadow].
]

{ #category : #accessing }
CornerGripMorph >> showHandle [

	^ showHandle ifNil: [self class drawCornerResizeHandles]
]

{ #category : #accessing }
CornerGripMorph >> target [

	^ target
]

{ #category : #accessing }
CornerGripMorph >> target: aMorph [

	target := aMorph
]
