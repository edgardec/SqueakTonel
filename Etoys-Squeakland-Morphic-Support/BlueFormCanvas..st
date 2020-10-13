Class {
	#name : #BlueFormCanvas,
	#superclass : #FormCanvas,
	#category : #'Etoys-Squeakland-Morphic-Support'
}

{ #category : #drawing }
BlueFormCanvas >> drawMorph: aMorph [
	"Draw a morph on the receiver"

     (self isVisible: aMorph bounds) ifTrue: [self frameRectangle: aMorph bounds color: Color blue]


]
