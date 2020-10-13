Class {
	#name : #MultiResolutionCanvas,
	#superclass : #FormCanvas,
	#instVars : [
		'deferredMorphs'
	],
	#category : #'MorphicExtras-Support'
}

{ #category : #accessing }
MultiResolutionCanvas >> deferredMorphs [

	^deferredMorphs
]

{ #category : #accessing }
MultiResolutionCanvas >> deferredMorphs: aCollection [

	deferredMorphs := aCollection
]

{ #category : #'drawing-general' }
MultiResolutionCanvas >> fullDraw: aMorph [

	aMorph canDrawAtHigherResolution ifTrue: [
		deferredMorphs ifNil: [deferredMorphs := OrderedCollection new].
		deferredMorphs add: aMorph.
	] ifFalse: [
		super fullDraw: aMorph
	].
]

{ #category : #'initialize-release' }
MultiResolutionCanvas >> initializeFrom: aFormCanvas [

	origin := aFormCanvas origin.
	clipRect := aFormCanvas privateClipRect.
	form := aFormCanvas form.
	port := aFormCanvas privatePort.
	shadowColor := aFormCanvas shadowColor.

]
