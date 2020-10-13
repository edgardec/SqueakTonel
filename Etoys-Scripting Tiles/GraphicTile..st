"
A tile representing a graphic image.
"
Class {
	#name : #GraphicTile,
	#superclass : #TileMorph,
	#category : #'Etoys-Scripting Tiles'
}

{ #category : #initialization }
GraphicTile >> initialize [
"initialize the state of the receiver"
	super initialize.
""
	type := #literal.
	self
		useForm: (ScriptingSystem formAtKey: #Menu)
]

{ #category : #accessing }
GraphicTile >> resultType [
	"Answer the result type of the argument represented by the receiver"

	^ #Graphic
]

{ #category : #initialization }
GraphicTile >> setLiteral: anObject [
	"Set the receiver's literal to be anObject. No readout morph here."

	type := #literal.
	self setLiteralInitially: anObject.

]

{ #category : #'code generation' }
GraphicTile >> storeCodeOn: aStream indent: tabCount [
	"Write code that will reconstitute the receiver"

	aStream nextPutAll: (self referenceWorld uniqueNameForReferenceFor: literal)
]

{ #category : #initialization }
GraphicTile >> useForm: aForm [
	"Set the receiver to represent the given form"

	| thumbnail |
	self removeAllMorphs.
	literal := aForm.
	thumbnail := ThumbnailMorph  new objectToView: self viewSelector: #literal.
	self addMorphBack: thumbnail.
	thumbnail extent: 16 @ 16.
]
