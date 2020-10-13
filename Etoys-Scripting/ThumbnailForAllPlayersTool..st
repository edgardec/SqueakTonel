"
A thumbnail for use in an All-Players tool
"
Class {
	#name : #ThumbnailForAllPlayersTool,
	#superclass : #ThumbnailMorph,
	#category : #'Etoys-Scripting'
}

{ #category : #stepping }
ThumbnailForAllPlayersTool >> step [
	"periodic action"

	| aMorph |
	((aMorph := objectToView costume) notNil and: [aMorph isInWorld]) ifTrue:
		[super step]  "don't bother changing my readout to blank when/if object disappears"
]

{ #category : #stepping }
ThumbnailForAllPlayersTool >> stepTime [
	"Don't update too aggressively"

	^ 2500
]
