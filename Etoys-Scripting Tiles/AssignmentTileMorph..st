Class {
	#name : #AssignmentTileMorph,
	#superclass : #TileMorph,
	#instVars : [
		'assignmentRoot',
		'assignmentSuffix',
		'dataType'
	],
	#category : #'Etoys-Scripting Tiles'
}

{ #category : #arrow }
AssignmentTileMorph >> addArrowsIfAppropriate [
	"If the receiver's slot is of an appropriate type, add arrows to the tile."

	(Vocabulary vocabularyForType: dataType)
		ifNotNil:
			[:aVocab | aVocab wantsAssignmentTileVariants ifTrue:
				[self addArrows]].
	(assignmentSuffix = ':') ifTrue:
		[ self addMorphBack: (ImageMorph new image: (ScriptingSystem formAtKey: #NewGets)).
		(self findA: StringMorph) ifNotNil: [ :sm |
			(sm contents endsWith: ' :') ifTrue: [ sm contents: (sm contents allButLast: 2) ]]]
]

{ #category : #'code generation' }
AssignmentTileMorph >> assignmentReceiverTile [
	"Answer the TilePadMorph that should be sent storeCodeOn:indent: to get the receiver of the assignment properly stored on the code stream"

	^ owner submorphs first
]

{ #category : #'player viewer' }
AssignmentTileMorph >> assignmentRoot [
	"Answer the assignment root"

	^ assignmentRoot
]

{ #category : #initialization }
AssignmentTileMorph >> computeOperatorOrExpression [
	"Compute the operator or expression to use, and set the wording correectly on the tile face"

	| aSuffix wording anInterface getter doc |
	operatorOrExpression := (assignmentRoot, assignmentSuffix) asSymbol.
	aSuffix := self currentVocabulary translatedWordingFor:  assignmentSuffix.
	getter := assignmentRoot asGetterSelector.
	anInterface := self currentVocabulary methodInterfaceAt: getter ifAbsent: [Vocabulary eToyVocabulary methodInterfaceAt: getter ifAbsent: [nil]].
	wording := anInterface ifNotNil: [anInterface wording] ifNil: [assignmentRoot copyWithout: $:].
	(anInterface notNil and: [(doc := anInterface documentation) notNil])
		ifTrue:
			[self setBalloonText: doc].
	operatorReadoutString := wording translated, ' ', aSuffix.
 	self line1: operatorReadoutString.
	self addArrowsIfAppropriate
]

{ #category : #'as yet unclassified' }
AssignmentTileMorph >> fixLayoutOfSubmorphsNotIn: aCollection [ 
	super fixLayoutOfSubmorphsNotIn: aCollection.
	self updateLiteralLabel; updateWordingToMatchVocabulary; layoutChanged; fullBounds
]

{ #category : #initialization }
AssignmentTileMorph >> initialize [
"initialize the state of the receiver"
	super initialize.
""
	type := #operator.
	assignmentSuffix := ':'
]

{ #category : #'code generation' }
AssignmentTileMorph >> operatorForAssignmentSuffix: aString [
	"Answer the operator associated with the receiver, assumed to be one of the compound assignments"

	| toTest |
	toTest := aString asString.
	#(	('Incr:'				'+')
		('Decr:'				'-')
		('Mult:'				'*'))
	do:
		[:pair | toTest = pair first ifTrue: [^ pair second]].
	^ toTest

	"AssignmentTileMorph new operatorForAssignmentSuffix: 'Incr:'"
]

{ #category : #accessing }
AssignmentTileMorph >> options [
	^ {#(#':' #Incr: #Decr: #Mult: ). {nil. nil. nil. nil}}
]

{ #category : #initialization }
AssignmentTileMorph >> setAssignmentSuffix: aString [
	assignmentSuffix := aString.
	self computeOperatorOrExpression.
	type := #operator.
 	self line1: (ScriptingSystem wordingForOperator: operatorOrExpression).
	self addArrowsIfAppropriate; updateLiteralLabel
]

{ #category : #initialization }
AssignmentTileMorph >> setRoot: aString [
	"Establish the assignment root, and update the label on the tile"

	assignmentRoot := aString.
	self updateLiteralLabel
]

{ #category : #initialization }
AssignmentTileMorph >> setRoot: aString dataType: aSymbol [
	assignmentRoot := aString.
	assignmentSuffix := ':'.
	dataType := aSymbol.
	self updateLiteralLabel
]

{ #category : #'code generation' }
AssignmentTileMorph >> storeCodeOn: aStream indent: tabCount [ 
	"Generate code for an assignment statement.  The code generated looks presentable in the case of simple assignment, though the code generated for the increment/decrement/multiply cases is still the same old assignGetter... sort for now"
aStream nextPutAll: (assignmentRoot asSetterSelector).
			aStream space."Simple assignment, don't need existing value"
	assignmentSuffix = ':' 

		ifFalse: 
			["Assignments that require that old values be retrieved"

			
			self assignmentReceiverTile storeCodeOn: aStream indent: tabCount.
			aStream space.
			aStream nextPutAll: (assignmentRoot asGetterSelector).
			aStream space.
			aStream nextPutAll: (self operatorForAssignmentSuffix: assignmentSuffix).
			aStream space]
]

{ #category : #'player viewer' }
AssignmentTileMorph >> updateLiteralLabel [
	self computeOperatorOrExpression.
	super updateLiteralLabel
]

{ #category : #initialization }
AssignmentTileMorph >> updateWordingToMatchVocabulary [
	"The current vocabulary has changed; change the wording on my face, if appropriate"

	self computeOperatorOrExpression
]

{ #category : #accessing }
AssignmentTileMorph >> value [
	^ assignmentSuffix
]

{ #category : #accessing }
AssignmentTileMorph >> value: anObject [ 
	self setAssignmentSuffix: anObject.
	self acceptNewLiteral
]
