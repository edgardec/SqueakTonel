"
When this is dropped inside some appropriate place, then painting is invoked for that place.
"
Class {
	#name : #PaintInvokingMorph,
	#superclass : #ImageMorph,
	#category : #'MorphicExtras-Widgets'
}

{ #category : #scripting }
PaintInvokingMorph class >> authoringPrototype [
	^ self new image: (ScriptingSystem formAtKey: 'Painting'); markAsPartsDonor; setBalloonText: 'drop this into any playfield or book page to make a new painting there'; yourself
]

{ #category : #'parts bin' }
PaintInvokingMorph class >> descriptionForPartsBin [
	^ self partName:	'Paint' translatedNoop
		categories:		{'Graphics' translatedNoop}
		documentation:	'Drop this icon to start painting a new object.' translatedNoop
]

{ #category : #'class initialization' }
PaintInvokingMorph class >> initialize [

	self registerInFlapsRegistry.
]

{ #category : #'class initialization' }
PaintInvokingMorph class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry"
	self environment
		at: #Flaps
		ifPresent: [:cl | cl registerQuad: {#PaintInvokingMorph. #new	. 'Paint' translatedNoop. 'Drop this into an area to start making a fresh painting there' translatedNoop}
						forFlapNamed: 'PlugIn Supplies'.
						cl registerQuad: {#PaintInvokingMorph. #new. 'Paint' translatedNoop. 'Drop this into an area to start making a fresh painting there' translatedNoop}
						forFlapNamed: 'Widgets'.
						cl registerQuad: {#PaintInvokingMorph. #new. 'Paint' translatedNoop. 'Drop this into an area to start making a fresh painting there' translatedNoop}
						forFlapNamed: 'Scripting']
]

{ #category : #'class initialization' }
PaintInvokingMorph class >> unload [
	"Unload the receiver from global registries"

	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self] 
]

{ #category : #initialization }
PaintInvokingMorph >> initialize [
	super initialize.
	self image: (ScriptingSystem formAtKey: 'Painting')
]

{ #category : #'parts bin' }
PaintInvokingMorph >> initializeToStandAlone [
	super initializeToStandAlone.
	self image: (ScriptingSystem formAtKey: 'Painting')
]

{ #category : #'dropping\/grabbing' }
PaintInvokingMorph >> justDroppedInto: aPasteUpMorph event: anEvent [
	"This message is sent to a dropped morph after it has been dropped on--and been accepted by--a drop-sensitive morph"
	aPasteUpMorph isPartsBin ifFalse:[
		self removeHalo.
		self delete.
		^aPasteUpMorph makeNewDrawing: anEvent].
	^super justDroppedInto: aPasteUpMorph event: anEvent
]

{ #category : #'dropping\/grabbing' }
PaintInvokingMorph >> wantsToBeDroppedInto: aMorph [
	"Only into PasteUps that are not part bins"
	^aMorph isPlayfieldLike
]
