"
An alignment morph designed for use in scripting Viewers; it wraps a set of phrases in a category viewer, and repels attempts to drop phrases upon it.
"
Class {
	#name : #PhraseWrapperMorph,
	#superclass : #AlignmentMorph,
	#category : #'Etoys-Squeakland-Etoys-Scripting'
}

{ #category : #'new-morph participation' }
PhraseWrapperMorph class >> includeInNewMorphMenu [
	"Not to be instantiated from the menu"
	^ false
]

{ #category : #'parts bin' }
PhraseWrapperMorph >> isPartsBin [
	^ true
]

{ #category : #'dropping\/grabbing' }
PhraseWrapperMorph >> repelsMorph: aMorph event: ev [
	^ (aMorph isKindOf: PhraseTileMorph) or:
		[aMorph hasProperty: #newPermanentScript]
]
