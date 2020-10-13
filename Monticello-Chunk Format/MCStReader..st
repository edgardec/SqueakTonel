Class {
	#name : #MCStReader,
	#superclass : #MCSnapshotReader,
	#category : #'Monticello-Chunk Format'
}

{ #category : #constants }
MCStReader class >> extension [
	^ 'st'
]

{ #category : #private }
MCStReader >> addDefinitionsFromDoit: aString [
	(MCDoItParser forDoit: aString) ifNotNil:
		[:parser |
		parser addDefinitionsTo: definitions]
]

{ #category : #private }
MCStReader >> categoryFromDoIt: aString [
	| tokens  |
	tokens := Scanner new scanTokens: aString.
	tokens size = 3 ifFalse: [self error: 'Unrecognized category definition'].
	^ tokens at: 3
]

{ #category : #converting }
MCStReader >> classDefinitionFrom: aPseudoClass [
	| tokens traitCompositionString lastIndex classTraitCompositionString typeOfSubclass className |
	tokens := Scanner new scanTokens: aPseudoClass definition.
	traitCompositionString := ((ReadStream on: aPseudoClass definition)
		match: 'uses:';
		upToAll: 'instanceVariableNames:') withBlanksTrimmed.
	classTraitCompositionString := ((ReadStream on: aPseudoClass metaClass definition asString)
		match: 'uses:';
		upToAll: 'instanceVariableNames:') withBlanksTrimmed.
	traitCompositionString isEmpty ifTrue: [traitCompositionString := '{}'].
	classTraitCompositionString isEmpty ifTrue: [classTraitCompositionString := '{}'].
	lastIndex := tokens size.

	className := tokens at: 3.
	typeOfSubclass := self typeOfSubclass: (tokens at: 2).
	"Compiled code classes are special cases of the #bytes class type"
	(#bytes == typeOfSubclass and: [self compiledCodeClassNames includes: className])
		ifTrue: [typeOfSubclass := #compiledMethod].

	^ MCClassDefinition
		name: className
		superclassName: (tokens at: 1)
		traitComposition: traitCompositionString
		classTraitComposition: classTraitCompositionString
		category: (tokens at: lastIndex)
		instVarNames: ((tokens at: lastIndex - 6) findTokens: ' ')
		classVarNames: ((tokens at: lastIndex - 4) findTokens: ' ')
		poolDictionaryNames: ((tokens at: lastIndex - 2) findTokens: ' ')
		classInstVarNames: (self classInstVarNamesFor: aPseudoClass)
		type: typeOfSubclass
		comment: (self commentFor: aPseudoClass)
		commentStamp: (self commentStampFor: aPseudoClass)
]

{ #category : #converting }
MCStReader >> classInstVarNamesFor: aPseudoClass [
	| tokens |
	
	self flag: #traits.
	aPseudoClass metaClass hasDefinition ifFalse: [^ #()].
	tokens := Scanner new scanTokens: aPseudoClass metaClass definition.
	"tokens size = 4 ifFalse: [self error: 'Unrecognized metaclass definition']."
	^ tokens last findTokens: ' '
]

{ #category : #converting }
MCStReader >> commentFor: aPseudoClass [
	| comment |
	comment := aPseudoClass organization classComment.
	^ comment asString = ''
		ifTrue: [comment]
		ifFalse: [comment string]
]

{ #category : #converting }
MCStReader >> commentStampFor: aPseudoClass [
	| comment |
	comment := aPseudoClass organization classComment.
	^  [comment stamp] on: MessageNotUnderstood do: [nil]
]

{ #category : #private }
MCStReader >> compiledCodeClassNames [
	"Answer the names of classes for which the type is #compiledMethod. Traditionally,
	this was only class CompiledMehod, but later refactorings require that CompiledCode
	and its subclasses be treated as type #compiledMethod."

	^{ #CompiledCode . #CompiledBlock . #CompiledMethod }
]

{ #category : #evaluating }
MCStReader >> loadDefinitions [
	| filePackage |
	filePackage :=
		FilePackage new
			fullName: 'ReadStream';
			fileInFrom: self readStream.
	definitions := OrderedCollection new.
	filePackage classes do:
		[:pseudoClass |
		pseudoClass hasDefinition
			ifTrue: [definitions add:
					(pseudoClass asMCDefinitionBy: self)].
		definitions addAll: (self methodDefinitionsFor: pseudoClass).
		definitions addAll: (self methodDefinitionsFor: pseudoClass metaClass)].
	filePackage doIts do:
		[:ea |
		self addDefinitionsFromDoit: ea string].
	
]

{ #category : #converting }
MCStReader >> methodDefinitionsFor: aPseudoClass [
	^ aPseudoClass selectors collect: 
		[:ea |
		 MCMethodDefinition
			className: aPseudoClass name
			classIsMeta: aPseudoClass isMeta
			selector: ea
			category: (aPseudoClass organization categoryOfElement: ea)
			timeStamp: (aPseudoClass stampAt: ea)
			source: (aPseudoClass sourceCodeAt: ea)]
]

{ #category : #evaluating }
MCStReader >> readStream [
	^ ('!!

', stream contents) readStream
]

{ #category : #converting }
MCStReader >> systemOrganizationFromRecords: changeRecords [
	| categories |
	categories := changeRecords
					select: [:ea | 'SystemOrganization*' match: ea string]
					thenCollect: [:ea | (self categoryFromDoIt: ea string)].
	^ categories isEmpty ifFalse: [MCOrganizationDefinition categories: categories asArray]
]

{ #category : #converting }
MCStReader >> traitDefinitionFrom: aPseudoTrait [
	| tokens traitCompositionString lastIndex |
	tokens := Scanner new scanTokens: aPseudoTrait definition.
	traitCompositionString := ((ReadStream on: aPseudoTrait definition)
		match: 'uses:';
		upToAll: 'category:') withBlanksTrimmed.
	traitCompositionString isEmpty ifTrue: [traitCompositionString := '{}'].
	lastIndex := tokens size.
	^ MCTraitDefinition
		name: (tokens at: 3)
		traitComposition: traitCompositionString
		category: (tokens at: lastIndex)
		comment: (self commentFor: aPseudoTrait)
		commentStamp: (self commentStampFor: aPseudoTrait)
]

{ #category : #private }
MCStReader >> typeOfSubclass: aSymbol [
	#(
		(subclass: normal)
		(variableSubclass: variable)
		(variableByteSubclass: bytes)
		(variableDoubleByteSubclass: shorts)
		(variableWordSubclass: words)
		(variableDoubleWordSubclass: longs)
		(weakSubclass: weak)
		(ephemeronSubclass: ephemeron)
		(immediateSubclass: immediate)
		) do: [:ea | ea first = aSymbol ifTrue: [^ ea second]].
	self error: 'Unrecognized class definition'
]
