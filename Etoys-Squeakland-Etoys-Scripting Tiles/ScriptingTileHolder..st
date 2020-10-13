"
Serves as a wrapper for a scripting-tile element that otherwise would be bare on the desktop.
"
Class {
	#name : #ScriptingTileHolder,
	#superclass : #AlignmentMorph,
	#category : #'Etoys-Squeakland-Etoys-Scripting Tiles'
}

{ #category : #'instance creation' }
ScriptingTileHolder class >> around: aTile [
	"Answer a new instance of the receiver, surrounding the given tile."

	^ self new around: aTile
]

{ #category : #initialization }
ScriptingTileHolder >> around: aTileScriptingElement [
	"Make the receiver surround the given item, either a TileMorph or a PhraseTileMorph or something like a CompoundTIleMorph."

	self removeAllMorphs.
	self position: aTileScriptingElement position.
	self addMorph: aTileScriptingElement.
	aTileScriptingElement lock.

]

{ #category : #initialization }
ScriptingTileHolder >> fixLayout [

	self allMorphsDo: [:m | m fixLayoutOfSubmorphs].

]

{ #category : #'mouse handling' }
ScriptingTileHolder >> handlesMouseDown: evt [
	"Do I want to receive mouseDown events (mouseDown:, mouseMove:, mouseUp:)?"

	^ true
]

{ #category : #initialization }
ScriptingTileHolder >> initialize [
	"initialize the state of the receiver"

	super initialize.
	self hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		borderWidth: 3;
		borderColor: Color green muchDarker;
		cellInset: 0; layoutInset: 0
]

{ #category : #initialization }
ScriptingTileHolder >> localeChanged [

	self fixLayout.

]

{ #category : #'mouse handling' }
ScriptingTileHolder >> mouseDown: evt [
	"Handle a mouse-down event."

	| actualTile |
	actualTile := submorphs at: 1 ifAbsent: [^ self delete].  "Not expected to happen."
	actualTile unlock.
	self topRendererOrSelf delete.
	evt hand grabMorph: actualTile
]

{ #category : #initialization }
ScriptingTileHolder >> unhibernate [

	self fixLayout.

]
