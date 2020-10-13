"
I provide the special tile of 'patchValueIn' setter.

"
Class {
	#name : #KedamaSetPixelValueTile,
	#superclass : #AssignmentTileMorph,
	#instVars : [
		'patchTile'
	],
	#category : #'Etoys-StarSqueak'
}

{ #category : #'initialization-support' }
KedamaSetPixelValueTile >> addPatchTile [

	| m1 desiredW m2 label |
	m1 := TilePadMorph new.
	label := 	StringMorph contents: 'setValueIn' font: ScriptingSystem fontForTiles.

	m2 := TileMorph new.
	m2 extent: 20@22.
	m2 minWidth: 20.
	m1 extent: (m2 extent + (2@2)).
	m1 setType: #Patch.
	m1 addMorph: m2.

	desiredW := m1 width + 6.
	self extent: (desiredW max: self basicWidth) @ self class defaultH.
	m1 position: (bounds center x - (m1 width // 2)) @ (bounds top + 1).

	self addMorphBack: m1.
	self addMorphFront: label.
	patchTile := m1.

]

{ #category : #initialization }
KedamaSetPixelValueTile >> initialize [

	super initialize.
	type := #Patch.
	operatorOrExpression := #setPatchValueIn:to:.
	self addPatchTile.
	self line1: 'setPatchValue:'.

]

{ #category : #'tile protocol' }
KedamaSetPixelValueTile >> line1: line1 [

	| chopped label label2 tail headIndex |
	(line1 select: [:e | e = $:]) size >= 2 ifTrue: [^ self].
	self removeAllMorphs.
	headIndex := line1 indexOf: $: ifAbsent: [line1 indexOf: Character space].

	chopped := line1 copyFrom: 1 to: headIndex - 1.
	tail := line1 copyFrom: chopped size + 2 to: line1 size.
	label := 	StringMorph contents: (chopped) font: ScriptingSystem fontForTiles.
	label2 := StringMorph contents: tail font: ScriptingSystem fontForTiles.

	self addMorphBack: label.
	self addMorphBack: patchTile.
	self addMorphBack: label2.

]

{ #category : #'tile protocol' }
KedamaSetPixelValueTile >> setAssignmentSuffix: aString [
	assignmentSuffix := aString.
	self computeOperatorOrExpression.
	type := #operator.
 	self addArrowsIfAppropriate; updateLiteralLabel
]

{ #category : #'initialization-support' }
KedamaSetPixelValueTile >> setPatchDefaultTo: aPlayer [

	patchTile submorphs first setToReferTo: aPlayer.

]

{ #category : #'tile protocol' }
KedamaSetPixelValueTile >> storeCodeOn: aStream indent: tabCount [ 
	"We have a hidden arg. Output two keywords with interspersed arguments."

"	| parts |

	parts := operatorOrExpression keywords.
	aStream nextPutAll: parts first.
	aStream space.
	patchTile submorphs first storeCodeOn: aStream indent: tabCount.
	aStream space.
	aStream nextPutAll: ' to: '.
"

	aStream nextPutAll: 'setPatchValueIn:'.
			aStream space."Simple assignment, don't need existing value"
	patchTile submorphs first storeCodeOn: aStream indent: tabCount.
	aStream nextPutAll: ' to: '.

	assignmentSuffix = ':' 
		ifFalse: 
			["Assignments that require that old values be retrieved"

			aStream nextPutAll: '( '.
			self assignmentReceiverTile storeCodeOn: aStream indent: tabCount.
			aStream space.
			aStream nextPutAll: 'getPatchValueIn:'.
			patchTile submorphs first storeCodeOn: aStream indent: tabCount.
			aStream nextPutAll: ')'.
			aStream space.
			aStream nextPutAll: (self operatorForAssignmentSuffix: assignmentSuffix).
			aStream space]
]

{ #category : #'tile protocol' }
KedamaSetPixelValueTile >> updateLiteralLabel [
	self computeOperatorOrExpression.
	"super basicUpdateLiteralLabel"

]
