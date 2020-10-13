Class {
	#name : #PinSpec,
	#superclass : #Object,
	#instVars : [
		'pinName',
		'direction',
		'localReadSelector',
		'localWriteSelector',
		'modelReadSelector',
		'modelWriteSelector',
		'defaultValue',
		'pinLoc'
	],
	#category : #'Etoys-Squeakland-Morphic-Components'
}

{ #category : #accessing }
PinSpec >> defaultValue [
	^ defaultValue
]

{ #category : #variables }
PinSpec >> hasVariable [
	^modelReadSelector notNil or: [modelWriteSelector notNil]
]

{ #category : #accessing }
PinSpec >> isInput [
	direction = #input ifTrue: [^ true].
	direction = #inputOutput ifTrue: [^ true].
	direction = #ioAsInput ifTrue: [^ true].
	^ false
]

{ #category : #accessing }
PinSpec >> isInputOnly [
	direction = #input ifTrue: [^ true].
	direction = #ioAsInput ifTrue: [^ true].
	^ false
]

{ #category : #accessing }
PinSpec >> isInputOutput [
	^ direction = #inputOutput
]

{ #category : #accessing }
PinSpec >> isOutput [
	direction = #output ifTrue: [^ true].
	direction = #inputOutput ifTrue: [^ true].
	direction = #ioAsOutput ifTrue: [^ true].
	^ false
]

{ #category : #accessing }
PinSpec >> isOutputOnly [
	direction = #output ifTrue: [^ true].
	direction = #ioAsOutput ifTrue: [^ true].
	^ false
]

{ #category : #accessing }
PinSpec >> localReadSelector [
	^ localReadSelector
]

{ #category : #accessing }
PinSpec >> localWriteSelector [
	^ localWriteSelector
]

{ #category : #accessing }
PinSpec >> modelReadSelector [
	^ modelReadSelector
]

{ #category : #accessing }
PinSpec >> modelReadSelector: a modelWriteSelector: b [
	modelReadSelector := a.
	modelWriteSelector := b
]

{ #category : #accessing }
PinSpec >> modelWriteSelector [
	^ modelWriteSelector
]

{ #category : #accessing }
PinSpec >> pinLoc [
	^ pinLoc
]

{ #category : #accessing }
PinSpec >> pinLoc: x [
	pinLoc := x
]

{ #category : #accessing }
PinSpec >> pinName [
	^ pinName
]

{ #category : #initialization }
PinSpec >> pinName: a direction: b localReadSelector: c localWriteSelector: d modelReadSelector: e modelWriteSelector: f defaultValue: g pinLoc: h [
	pinName := a.
	direction := b.
	localReadSelector := c.
	localWriteSelector := d.
	modelReadSelector := e.
	modelWriteSelector := f.
	defaultValue := g.
	pinLoc := h
]

{ #category : #variables }
PinSpec >> variableName [
	^ modelReadSelector
]
