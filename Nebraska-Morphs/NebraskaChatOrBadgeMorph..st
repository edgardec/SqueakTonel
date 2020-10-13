Class {
	#name : #NebraskaChatOrBadgeMorph,
	#superclass : #NebraskaCommunicatorMorph,
	#category : #'Nebraska-Morphs'
}

{ #category : #'new-morph participation' }
NebraskaChatOrBadgeMorph class >> includeInNewMorphMenu [
	"Not to be instantiated from the menu"
	^ self ~~ NebraskaChatOrBadgeMorph
]
