"
When dropped by the user, a cursor is presented, allowing the user to grab a rectangular patch from the screen.
"
Class {
	#name : #LassoPatchMorph,
	#superclass : #ImageMorph,
	#category : #'MorphicExtras-Widgets'
}

{ #category : #'instance creation' }
LassoPatchMorph class >> authoringPrototype [
	"Answer a prototype  for use in a parts bin"

	^ self new image: (ScriptingSystem formAtKey: 'Lasso'); markAsPartsDonor; setBalloonText: 'Drop this on the desktop and you can then grab a patch from the screen with a lasso.'; yourself
]

{ #category : #'parts bin' }
LassoPatchMorph class >> descriptionForPartsBin [
	"Answer a description of the receiver to be used in a parts bin"

	^ self partName:	'Lasso' translatedNoop
		categories:		{'Graphics' translatedNoop}
		documentation:	'Drop this icon to grab a patch from the screen with a lasso.' translatedNoop
]

{ #category : #initialization }
LassoPatchMorph >> initialize [
	"Initialize the receiver.  Sets its image to the lasso picture"

	super initialize.
	self image: (ScriptingSystem formAtKey: 'Lasso')
]

{ #category : #initialization }
LassoPatchMorph >> initializeToStandAlone [
	"Initialize the receiver such that it can live on its own.  Sets its image to the lasso picture"

	super initializeToStandAlone.
	self image: (ScriptingSystem formAtKey: 'Lasso')
]

{ #category : #dropping }
LassoPatchMorph >> justDroppedInto: aPasteUpMorph event: anEvent [
	"This message is sent to a dropped morph after it has been dropped on--and been accepted by--a drop-sensitive morph"

	super justDroppedInto: aPasteUpMorph event: anEvent.
	
	aPasteUpMorph isPartsBin ifFalse: [
		"Do not show this morph in the screenshot."
		self hide.
		anEvent hand hide.
		self refreshWorld.

		[aPasteUpMorph grabLassoFromScreen: anEvent]
			ensure: [anEvent hand show]].

	"Just needed for this operation. Remove."	
	self delete.
]

{ #category : #dropping }
LassoPatchMorph >> wantsToBeDroppedInto: aMorph [
	"Only wanted by the world"

	^ aMorph isWorldMorph
]
