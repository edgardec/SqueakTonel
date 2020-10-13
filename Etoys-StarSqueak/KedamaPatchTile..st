"
A special Tile that represents the Patch.

"
Class {
	#name : #KedamaPatchTile,
	#superclass : #TileMorph,
	#category : #'Etoys-StarSqueak'
}

{ #category : #initialization }
KedamaPatchTile >> initialize [

	super initialize.
	type := #objRef.
	self extent: 16@16.

]

{ #category : #'tile protocol' }
KedamaPatchTile >> resultType [
	"Answer the result type of the argument represented by the receiver"

	^ #Patch.

]

{ #category : #'tile protocol' }
KedamaPatchTile >> setLiteral: anObject [
	"Set the receiver's literal to be anObject. No readout morph here."

	type := #literal.
	self setLiteralInitially: anObject.

]

{ #category : #'tile protocol' }
KedamaPatchTile >> storeCodeOn: aStream indent: tabCount [
	"Write code that will reconstitute the receiver"

	aStream nextPutAll: literal uniqueNameForReference
]

{ #category : #'initialization support' }
KedamaPatchTile >> usePatch: aPatch [

	self setToReferTo: aPatch.

]
