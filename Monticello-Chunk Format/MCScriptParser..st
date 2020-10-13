Class {
	#name : #MCScriptParser,
	#superclass : #MCDoItParser,
	#category : #'Monticello-Chunk Format'
}

{ #category : #constants }
MCScriptParser class >> pattern [
	^'(PackageInfo named: *'
]

{ #category : #evaluating }
MCScriptParser >> addDefinitionsTo: aCollection [
	| tokens  definition |
	tokens := Scanner new scanTokens: source.
	definition := MCScriptDefinition
		scriptSelector: tokens second allButLast
		script: tokens third
		packageName: tokens first third.
	aCollection add: definition.
]
