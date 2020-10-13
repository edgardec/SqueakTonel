Class {
	#name : #MCDoItParser,
	#superclass : #Object,
	#instVars : [
		'source'
	],
	#category : #'Monticello-Chunk Format'
}

{ #category : #'accessing class hierarchy' }
MCDoItParser class >> concreteSubclasses [
	^ self allSubclasses reject: [:c | c isAbstract]
]

{ #category : #'instance creation' }
MCDoItParser class >> forDoit: aString [
	^ (self subclassForDoit: aString) ifNotNil: [:c | c new source: aString]
]

{ #category : #testing }
MCDoItParser class >> isAbstract [
	^ self pattern isNil
]

{ #category : #constants }
MCDoItParser class >> pattern [
	^ nil
]

{ #category : #private }
MCDoItParser class >> subclassForDoit: aString [
	^ self concreteSubclasses detect: [:ea | ea pattern match: aString] ifNone: []
]

{ #category : #evaluating }
MCDoItParser >> addDefinitionsTo: aCollection [
	self subclassResponsibility 
]

{ #category : #accessing }
MCDoItParser >> source [
	^ source
]

{ #category : #accessing }
MCDoItParser >> source: aString [
	source := aString
]
