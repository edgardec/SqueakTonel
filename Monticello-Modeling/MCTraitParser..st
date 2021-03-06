Class {
	#name : #MCTraitParser,
	#superclass : #MCDoItParser,
	#category : #'Monticello-Modeling'
}

{ #category : #constants }
MCTraitParser class >> pattern [
	^ 'Trait named:*'
]

{ #category : #reader }
MCTraitParser >> addDefinitionsTo: aCollection [
	| tokens  definition traitCompositionString |
	tokens := Scanner new scanTokens: source.
	traitCompositionString := ((ReadStream on: source)
		match: 'uses:';
		upToAll: 'category:') withBlanksTrimmed.
	definition := MCTraitDefinition
		name: (tokens at: 3) 
		traitComposition: traitCompositionString
		category:  tokens last
		comment:  ''  
		commentStamp:   ''.
	aCollection add: definition.
]
