"
A ScriptEditor required to hold a Boolean
"
Class {
	#name : #BooleanScriptEditor,
	#superclass : #ScriptEditorMorph,
	#category : #'Etoys-Scripting Support'
}

{ #category : #other }
BooleanScriptEditor >> hibernate [ 
	"do nothing"
]

{ #category : #other }
BooleanScriptEditor >> storeCodeOn: aStream indent: tabCount [ 
	(submorphs notEmpty and: [submorphs first submorphs notEmpty]) 
		ifTrue: 
			[aStream nextPutAll: '('.
			super storeCodeOn: aStream indent: tabCount.
			aStream nextPutAll: ')'.
			^self].
	aStream nextPutAll: ' true '
]

{ #category : #other }
BooleanScriptEditor >> unhibernate [ 
	"do nothing"
]

{ #category : #'dropping\/grabbing' }
BooleanScriptEditor >> wantsDroppedMorph: aMorph event: evt [ 
	"Answer whether the receiver would be interested in accepting the morph"

	(submorphs anySatisfy: [:m | m isAlignmentMorph]) 
		ifTrue: [^ false].

	((aMorph isKindOf: ParameterTile) and: [aMorph scriptEditor == self topEditor])
		ifTrue: [^ true].
	(aMorph isKindOf: FunctionTile) ifTrue: [^ true].
	^ (aMorph isKindOf: PhraseTileMorph orOf: WatcherWrapper) 
		and: [(#(#Command #Unknown) includes: aMorph resultType capitalized) not]
]
