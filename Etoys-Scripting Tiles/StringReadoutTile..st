Class {
	#name : #StringReadoutTile,
	#superclass : #TileMorph,
	#category : #'Etoys-Scripting Tiles'
}

{ #category : #misc }
StringReadoutTile >> basicWidth [
	^ 26
]

{ #category : #'event handling' }
StringReadoutTile >> handlesMouseDown: evt [ 
	^ true
]

{ #category : #accessing }
StringReadoutTile >> literal: anObject [
	literal := anObject.
	self updateLiteralLabel.
	submorphs last informTarget
]

{ #category : #'event handling' }
StringReadoutTile >> mouseStillDown: evt [ 
	(self labelMorph notNil
			and: [self labelMorph containsPoint: evt cursorPoint])
		ifTrue: [^ self labelMorph mouseDown: evt].
	^ super mouseStillDown: evt
]

{ #category : #literal }
StringReadoutTile >> setLiteralTo: anObject width: w [
	"like literal:width: but does not inform the target"
	literal := anObject.
	self updateLiteralLabel.
	submorphs last setWidth: w.
	self updateLiteralLabel
]
