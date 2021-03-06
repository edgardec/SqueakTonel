Class {
	#name : #UndeclaredVariableReference,
	#superclass : #Notification,
	#instVars : [
		'parser',
		'varName',
		'varStart',
		'varEnd'
	],
	#category : #'Compiler-Support'
}

{ #category : #exceptionDescription }
UndeclaredVariableReference >> defaultAction [
	^parser correctVariable: varName interval: (varStart to: varEnd)
]

{ #category : #accessing }
UndeclaredVariableReference >> parser [
	^parser
]

{ #category : #accessing }
UndeclaredVariableReference >> parser: aParser [
	parser := aParser
]

{ #category : #accessing }
UndeclaredVariableReference >> varEnd [
	^varEnd
]

{ #category : #accessing }
UndeclaredVariableReference >> varEnd: aNumber [
	varEnd := aNumber
]

{ #category : #accessing }
UndeclaredVariableReference >> varName [
	^varName
]

{ #category : #accessing }
UndeclaredVariableReference >> varName: aString [
	varName := aString
]

{ #category : #accessing }
UndeclaredVariableReference >> varStart [
	^varStart
]

{ #category : #accessing }
UndeclaredVariableReference >> varStart: aNumber [
	varStart := aNumber
]
