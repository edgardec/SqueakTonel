Class {
	#name : #MorphListItemWrapper,
	#superclass : #ListItemWrapper,
	#category : #'Morphic-Widgets'
}

{ #category : #converting }
MorphListItemWrapper >> asString [
	"Answer the string representation of the receiver"
	^ item externalName
]

{ #category : #accessing }
MorphListItemWrapper >> contents [
	"Answer the receiver's contents"

	| tentative submorphs |
	tentative := item submorphs
				collect: [:each | each renderedMorph].

	submorphs := Preferences noviceMode
				ifTrue: [
					tentative
						reject: [:each |
							each isSystemWindow
								or: [each isDockingBar
								or: [(each isKindOf: HaloMorph)
								or: [(each hasProperty: #morphHierarchy)
								or: [each isFlapOrTab
								or: [each isObjectsTool]]]]]]]
				ifFalse: [
					tentative
						reject: [:each | each isKindOf: HaloMorph]].

	^ submorphs
		collect: [:each | self class with: each]
]

{ #category : #accessing }
MorphListItemWrapper >> icon [
	"Answer a form to be used as icon"
	^ item iconOrThumbnailOfSize: ((Preferences tinyDisplay ifTrue: [16] ifFalse: [28]))
]
