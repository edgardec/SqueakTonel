Class {
	#name : #MenuStub,
	#superclass : #WidgetStub,
	#category : #'ToolBuilder-SUnit'
}

{ #category : #'as yet unclassified' }
MenuStub >> click: aString [
	| item |
	item := self items detect: [:ea | ea label = aString] ifNone: [^ self].
	item action isSymbol
		ifTrue: [self model perform: item action]
		ifFalse: [item action value]
]

{ #category : #'as yet unclassified' }
MenuStub >> items [
	^ spec items
]

{ #category : #'as yet unclassified' }
MenuStub >> labels [
	^ self items keys
]
