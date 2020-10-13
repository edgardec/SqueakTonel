Class {
	#name : #MCSystemCategoryParser,
	#superclass : #MCDoItParser,
	#category : #'Monticello-Chunk Format'
}

{ #category : #constants }
MCSystemCategoryParser class >> pattern [
	^ 'SystemOrganization*'
]

{ #category : #evaluating }
MCSystemCategoryParser >> addDefinitionsTo: aCollection [
	| definition |
	definition := aCollection detect: [:ea | ea isOrganizationDefinition ] ifNone: [aCollection add: (MCOrganizationDefinition categories: #())].
	definition categories: (definition categories copyWith: self category).
]

{ #category : #evaluating }
MCSystemCategoryParser >> category [
	| tokens  |
	tokens := Scanner new scanTokens: source.
	tokens size = 3 ifFalse: [self error: 'Unrecognized category definition'].
	^ tokens at: 3
]
