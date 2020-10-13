Class {
	#name : #GraphicType,
	#superclass : #DataType,
	#category : #'Protocols-Type Vocabularies'
}

{ #category : #'initial value' }
GraphicType >> initialValueForASlotFor: aPlayer [
	"Answer the value to give initially to a newly created slot of the given type in the given player"

	^ ScriptingSystem formAtKey: #PaintTab
]

{ #category : #initialization }
GraphicType >> initialize [
	"Initialize the receiver (automatically called when instances are created via 'new')"

	super initialize.
	self vocabularyName: #Graphic.
]
