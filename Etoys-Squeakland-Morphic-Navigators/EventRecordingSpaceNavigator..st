"
A custom navigator to use within the content area of an EventRecordingSpace.
"
Class {
	#name : #EventRecordingSpaceNavigator,
	#superclass : #ProjectNavigationMorph,
	#category : #'Etoys-Squeakland-Morphic-Navigators'
}

{ #category : #'the actions' }
EventRecordingSpaceNavigator >> doNewPainting [
	"Make a new painting"

	| worldlet |
	self currentWorld assureNotPaintingElse: [^ self].
	worldlet := self ownerThatIsA: Worldlet.
	worldlet closeNavigatorFlap.
	worldlet makeNewDrawing: (self currentEvent copy setPosition: worldlet center).
]
