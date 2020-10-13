Class {
	#name : #MCClassTraitParser,
	#superclass : #MCDoItParser,
	#category : #'Monticello-Modeling'
}

{ #category : #constants }
MCClassTraitParser class >> pattern [
	^ '*classTrait*uses:*'
]

{ #category : #reader }
MCClassTraitParser >> addDefinitionsTo: aCollection [
	| tokens  definition traitCompositionString |
	tokens := Scanner new scanTokens: source.
	traitCompositionString := ((ReadStream on: source)
		match: 'uses:';
		upToEnd) withBlanksTrimmed.
	definition := MCClassTraitDefinition
		baseTraitName: (tokens at: 1) 
		classTraitComposition: traitCompositionString.
	aCollection add: definition

]
