"
I provide the red, green or blue component setter tile.

"
Class {
	#name : #KedamaSetColorComponentTile,
	#superclass : #AssignmentTileMorph,
	#instVars : [
		'patchTile'
	],
	#category : #'Etoys-StarSqueak'
}

{ #category : #'initalization support' }
KedamaSetColorComponentTile >> addPatchTile [

	| m1 desiredW m2 label |
	m1 := TilePadMorph new.
	label := 	StringMorph contents: (operatorOrExpression asString upTo: $:) translated font: ScriptingSystem fontForTiles.

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

{ #category : #'initalization support' }
KedamaSetColorComponentTile >> componentName: aSymbol [

	aSymbol = #blue ifTrue: [
		operatorOrExpression := #setBlueComponentIn:to:.
	].
	aSymbol = #green ifTrue: [
		operatorOrExpression := #setGreenComponentIn:to:.
	].
	aSymbol = #red ifTrue: [
		operatorOrExpression := #setRedComponentIn:to:.
	].
	self addPatchTile.


]

{ #category : #initialization }
KedamaSetColorComponentTile >> initialize [

	super initialize.
	type := #Patch.
	operatorOrExpression := #setBlueComponentIn:to:.
	self addPatchTile.
	self line1: 'setBlueComponent:'.

]

{ #category : #initialization }
KedamaSetColorComponentTile >> line1: line1 [

	| chopped label label2 tail headIndex |
	(line1 select: [:e | e = $:]) size >= 2 ifTrue: [^ self].
	self removeAllMorphs.
	headIndex := line1 indexOf: $: ifAbsent: [line1 indexOf: Character space].

	chopped := line1 copyFrom: 1 to: headIndex - 1.
	tail := line1 copyFrom: chopped size + 2 to: line1 size.
	label := 	StringMorph contents: (chopped) translated font: ScriptingSystem fontForTiles.
	label2 := StringMorph contents: tail translated font: ScriptingSystem fontForTiles.

	self addMorphBack: label.
	self addMorphBack: patchTile.
	self addMorphBack: label2.

]

{ #category : #'tile protocol' }
KedamaSetColorComponentTile >> setAssignmentSuffix: aString [
	assignmentSuffix := aString.
	self computeOperatorOrExpression.
	type := #operator.
 	self addArrowsIfAppropriate; updateLiteralLabel.

]

{ #category : #'initalization support' }
KedamaSetColorComponentTile >> setPatchDefaultTo: aPlayer [

	patchTile submorphs first setToReferTo: aPlayer.

]

{ #category : #initialization }
KedamaSetColorComponentTile >> storeCodeOn: aStream indent: tabCount [ 
	"We have a hidden arg. Output two keywords with interspersed arguments."

	| firstKeyword |
	(#('redComponentIn:' 'setRedComponentIn:') includes: assignmentRoot) ifTrue: [
		firstKeyword := 'setRedComponentIn'.
	].
	(#('greenComponentIn:' 'setGreenComponentIn:') includes: assignmentRoot) ifTrue: [
		firstKeyword := 'setGreenComponentIn'
	].
	(#('blueComponentIn:' 'setBlueComponentIn:') includes: assignmentRoot) ifTrue: [
		firstKeyword := 'setBlueComponentIn'
	].

	aStream nextPutAll: firstKeyword.
	aStream nextPut: $:.
			aStream space."Simple assignment, don't need existing value"
	patchTile submorphs first storeCodeOn: aStream indent: tabCount.
	aStream nextPutAll: ' to: '.

	assignmentSuffix = ':' 
		ifFalse: 
			["Assignments that require that old values be retrieved"

			aStream nextPutAll: '( '.
			self assignmentReceiverTile storeCodeOn: aStream indent: tabCount.
			aStream space.
			aStream nextPutAll: 'get', (firstKeyword copyFrom: 4 to: firstKeyword size), ':'.
			patchTile submorphs first storeCodeOn: aStream indent: tabCount.
			aStream nextPutAll: ')'.
			aStream space.
			aStream nextPutAll: (self operatorForAssignmentSuffix: assignmentSuffix).
			aStream space]
]

{ #category : #'initalization support' }
KedamaSetColorComponentTile >> updateLiteralLabel [
	self computeOperatorOrExpression.
	"super basicUpdateLiteralLabel"

]
