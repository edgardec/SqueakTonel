Class {
	#name : #BorderGripMorph,
	#superclass : #CornerGripMorph,
	#category : #'Morphic-Windows'
}

{ #category : #drawing }
BorderGripMorph >> drawOn: aCanvas [

	super drawOn: aCanvas.
	
	self showHandle ifTrue: [
		self orientation = #vertical ifTrue: [
			aCanvas
				fillRoundRect: (((self width @ (self height * 0.25 min: self class handleLength)) center: self center) insetBy: self handleInset)
				radius: 3
				fillStyle: (SolidFillStyle color: self handleColor)].
		self orientation = #horizontal ifTrue: [
			aCanvas
				fillRoundRect: ((((self width * 0.25 min: self class handleLength) @ self height) center: self center) insetBy: self handleInset)
				radius: 3
				fillStyle: (SolidFillStyle color: self handleColor)] ].
]

{ #category : #accessing }
BorderGripMorph >> handleInset [

	^ (handleInset notNil or: [self owner isNil])
		ifTrue: [handleInset ifNil: [2]]
		ifFalse: [(self owner borderWidth max: 1) * 2]
]

{ #category : #layout }
BorderGripMorph >> layoutProportionallyInBounds: layoutBounds positioning: cellPositioning [

	super layoutProportionallyInBounds: layoutBounds positioning: cellPositioning.
	
	self flag: #workaround. "mt: We cannot know that our owner has always the correct properties at this time."
	self orientation = #vertical ifTrue: [
		self width: self class gripThickness + (self owner borderWidth * 2)].
	self orientation = #horizontal ifTrue: [
		self height: self class gripThickness + (self owner borderWidth * 2)].

]

{ #category : #accessing }
BorderGripMorph >> orientation [
	"#vertical or #horizontal"
	
	self subclassResponsibility.
]

{ #category : #accessing }
BorderGripMorph >> showHandle [

	^ showHandle ifNil: [self class drawEdgeResizeHandles]
]
