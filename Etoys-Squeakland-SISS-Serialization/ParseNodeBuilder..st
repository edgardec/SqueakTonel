Class {
	#name : #ParseNodeBuilder,
	#superclass : #Object,
	#instVars : [
		'context',
		'encoder'
	],
	#category : #'Etoys-Squeakland-SISS-Serialization'
}

{ #category : #all }
ParseNodeBuilder >> assign: sexp [

	| varNode valueNode |
	varNode := self parse: sexp elements first.
	valueNode := self parse: sexp elements second.
	^ AssignmentNode new
		variable: varNode
				value: valueNode
				from: encoder
				sourceRange: nil.
]

{ #category : #all }
ParseNodeBuilder >> blockParameter: sexp [

	^ encoder autoBind: (sexp attributeAt: #name) asSymbol.
]

{ #category : #all }
ParseNodeBuilder >> condition: sexp [

	| selector rec y n |
	selector := #ifTrue:ifFalse:.
	rec := self parse: sexp elements first.
	y := self parse: sexp elements second.
	n := self parse: sexp elements third.
	^ MessageNode new
				receiver: rec
				selector: selector
				arguments: (Array with: y with: n)
				precedence: (selector precedence)
				from: encoder
				sourceRange: nil.
]

{ #category : #all }
ParseNodeBuilder >> literal: sexp [

	| type value |
	type := Smalltalk at: (sexp attributeAt: #type ifAbsent: []) asSymbol.
	value := sexp attributeAt: #value ifAbsent: [].
	(type inheritsFrom: Symbol) ifTrue: [
		value := '#', value.
	] ifFalse: [
		(type inheritsFrom: String) ifTrue: [
			^ encoder encodeLiteral: value.
		] ifFalse: [
			((type = Character) and: [value isString and: [value size = 1]]) ifTrue: [
				^ encoder encodeLiteral: value first
			]
		]
	].

	^ encoder encodeLiteral: (type readFromString: value).
]

{ #category : #all }
ParseNodeBuilder >> parameter: sexp [

	^ encoder bindArg: (sexp attributeAt: #name).
]

{ #category : #all }
ParseNodeBuilder >> parse: sexp [

	^ self perform: (sexp keyword, ':') asSymbol with: sexp.
]

{ #category : #all }
ParseNodeBuilder >> return: sexp [

	| val |
	val := self parse: sexp elements first.
	^ ReturnNode new expr: val.
]

{ #category : #all }
ParseNodeBuilder >> script: sexp with: aDictionary in: aWorld [

	| playerClassId playerClass selector n selOrFalse argSexp arguments block tmps |
	context := aDictionary.
	playerClassId := sexp attributeAt: #playerClass.
	playerClass := aDictionary at: playerClassId asSymbol ifAbsent: [self error: ''].	
	encoder := ScriptEncoder new init: playerClass context: nil notifying: nil; referenceObject: aWorld.
	selector := (sexp attributeAt: #scriptName) asSymbol.
	n := MethodNode new.
	selOrFalse := encoder encodeSelector: selector.

	tmps := sexp elements detect: [:e | e keyword = #temporary] ifNone: [nil].
	tmps ifNotNil: [
		tmps elements  do: [:t |
			self temporary: t.
		].
	].

	argSexp := (sexp elements select: [:e | e keyword == #parameter]) sort: [:a :b | (a attributeAt: #position) asNumber < (b attributeAt: #position) asNumber].
	arguments := argSexp collect: [:e | self parse: e].
	block := self parse: (sexp elements detect: [:e | e keyword == #sequence]).
	^ n
		selector: selOrFalse
		arguments: arguments
		precedence: selector precedence
		temporaries: #()
		block: block
		encoder: encoder
		primitive: 0.
]

{ #category : #all }
ParseNodeBuilder >> selector: sexp [

	| value |
	value := sexp attributeAt: #selector ifAbsent: [].
	^ encoder encodeSelector: value.
]

{ #category : #all }
ParseNodeBuilder >> send: sexp [

	| selector rec args |
	selector := sexp elements first attributeAt: #selector.
	rec := self parse: sexp elements second.
	args := (sexp elements copyFrom: 3 to: sexp elements size) collect: [:e |
		self parse: e.
	].
	^ MessageNode new
				receiver: rec
				selector: selector asSymbol
				arguments: args
				precedence: (selector asSymbol precedence)
				from: encoder
				sourceRange: nil.
]

{ #category : #all }
ParseNodeBuilder >> sequence: sexp [

	| statements ret args |
	args := sexp elements select: [:e | e keyword == #parameter].
	statements := sexp elements reject: [:e | e keyword == #parameter].
	args := args collect: [:e | self blockParameter: e].
	statements := statements collect: [:e | self parse: e].
	ret := (statements size > 0 and: [statements last isMemberOf: ReturnNode]).
	args do: [:variable | variable scope: -1].
	^ BlockNode new arguments: args statements: statements returns: ret from: encoder.
]

{ #category : #all }
ParseNodeBuilder >> temporary: sexp [

	| value |
	value := sexp attributeAt: #value ifAbsent: [].
	^ encoder bindTemp: value asSymbol
]

{ #category : #all }
ParseNodeBuilder >> variable: sexp [

	| value type |
	value := sexp attributeAt: #value ifAbsent: [].
	type := sexp attributeAt: #type ifAbsent: [].
	type = 'Player' ifTrue: [
		value = 'self' ifFalse: [
			value := sexp attributeAt: #idref
		].
	].
	value first canBeGlobalVarInitial ifTrue: [
		^ encoder encodeVariable: value
	] ifFalse: [
		value first isDigit ifTrue: [
			^ encoder encodeVariable: (context at: value asSymbol) uniqueNameForReference.
		]
	].
	^ encoder encodeVariable: value.
]
