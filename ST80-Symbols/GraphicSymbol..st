"
I represent a structured picture built from primitive display objects and other instances of me.
"
Class {
	#name : #GraphicSymbol,
	#superclass : #OrderedCollection,
	#type : #variable,
	#category : #'ST80-Symbols'
}

{ #category : #accessing }
GraphicSymbol >> computeBoundingBox [
	"Compute a boundingBox that encloses all of the Paths in this symbol"

	^Rectangle merging: (self collect: [:each | each computeBoundingBox])

]

{ #category : #displaying }
GraphicSymbol >> displayOn: aDisplayMedium transformation: aTransformation clippingBox: clipRect rule: anInteger fillColor: aForm [ 
	"Display the receiver on the Display where aTransformation is provided 
	as an argument, rule is anInteger and mask is aForm. No translation. 
	Information to be displayed must be confined to the area that intersects 
	with clipRect."

	self do: 
		[:element | 
		element
			displayOn: aDisplayMedium
			transformation: aTransformation
			clippingBox: clipRect
			rule: anInteger
			fillColor: aForm]
]

{ #category : #displaying }
GraphicSymbol >> displayTransformation: aTransformation clippingBox: clipRect rule: anInteger fillColor: aForm [
	"Display the receiver where aTransformation is provided as an argument, 
	rule is anInteger and mask is aForm. No translation. Information to be 
	displayed must be confined to the area that intersects with clipRect."

	self displayOn: Display transformation: aTransformation clippingBox: clipRect
		rule: anInteger fillColor: aForm
]
