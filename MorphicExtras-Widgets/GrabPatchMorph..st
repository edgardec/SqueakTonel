"
When an instance of GrabPatchMorph is dropped by the user, it signals a desire to do a screen-grab of a rectangular area.
"
Class {
	#name : #GrabPatchMorph,
	#superclass : #ImageMorph,
	#category : #'MorphicExtras-Widgets'
}

{ #category : #'instance creation' }
GrabPatchMorph class >> authoringPrototype [
	"Answer a prototype for use in a parts bin"

	^ self new image: (ScriptingSystem formAtKey: 'GrabPatch'); markAsPartsDonor; setBalloonText: 'Use this to grab a rectangular patch from the screen'; yourself
]

{ #category : #'parts bin' }
GrabPatchMorph class >> descriptionForPartsBin [
	"Answer a description of the receiver's instances for a parts bin"

	^ self partName:	'Grab Patch' translatedNoop
		categories:		{'Graphics' translatedNoop}
		documentation:	'Use this to grab a rectangular patch from the screen' translatedNoop
]

{ #category : #initialization }
GrabPatchMorph >> initialize [
	"Initialize the receiver.  Emblazon the GrabPatch icon on its face"

	super initialize.
	self image: (ScriptingSystem formAtKey: 'GrabPatch').
	self setProperty: #ignorePartsBinDrop toValue: true
]

{ #category : #initialization }
GrabPatchMorph >> initializeToStandAlone [
	"Initialize the receiver.  Emblazon the GrabPatch icon on its face"

	super initializeToStandAlone.
	self image: (ScriptingSystem formAtKey: 'GrabPatch')
]

{ #category : #dropping }
GrabPatchMorph >> justDroppedInto: aPasteUpMorph event: anEvent [
	"This message is sent to a dropped morph after it has been dropped on--and been accepted by--a drop-sensitive morph"

	super justDroppedInto: aPasteUpMorph event: anEvent.
	
	aPasteUpMorph isPartsBin ifFalse: [
		"Do not show this morph in the screenshot."
		self hide.
		anEvent hand hide.
		self refreshWorld.

		[aPasteUpMorph grabDrawingFromScreen: anEvent]
			ensure: [anEvent hand show]].

	"Just needed for this operation. Remove."	
	self delete.
]

{ #category : #dropping }
GrabPatchMorph >> wantsToBeDroppedInto: aMorph [
	"Only into PasteUps that are not part bins"

	^ aMorph isPlayfieldLike
]
