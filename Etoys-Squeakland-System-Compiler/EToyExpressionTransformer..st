Class {
	#name : #EToyExpressionTransformer,
	#superclass : #Object,
	#instVars : [
		'method',
		'stack',
		'inputQueue',
		'encoder'
	],
	#category : #'Etoys-Squeakland-System-Compiler'
}

{ #category : #all }
EToyExpressionTransformer >> inputQueueEmpty [

	^ inputQueue isEmpty
]

{ #category : #all }
EToyExpressionTransformer >> inputQueueNext [

	| e f |
	e := inputQueue removeFirst.
	inputQueue size > 0 ifTrue: [
		f := inputQueue removeFirst.
		(f isMemberOf: MessageNode) ifTrue: [
			self pushAMessageNode: f
		] ifFalse: [
			inputQueue addFirst: f
		].
	].
	^ e.

			
		
]

{ #category : #all }
EToyExpressionTransformer >> inputQueuePeek [

	^ inputQueue size > 0 ifTrue: [inputQueue first] ifFalse: [nil]

]

{ #category : #all }
EToyExpressionTransformer >> newMessageFor: aMessageNode encoder: e [

	encoder := e.
	inputQueue := OrderedCollection new: 3.
	self pushAMessageNode: aMessageNode.
	stack := OrderedCollection new: 3.

]

{ #category : #all }
EToyExpressionTransformer >> precl [

	stack size = 0 ifTrue: [^ 0].
	stack size = 1 ifTrue: [^ self precl: stack last].
	stack last isSymbol ifTrue: [^ 0].
	^ self precl: (stack at: stack size - 1).

]

{ #category : #all }
EToyExpressionTransformer >> precl: anObject [

	(#(#max: #min:) includes: anObject) ifTrue: [^ 1].
	(#(#+ #-) includes: anObject) ifTrue: [^ 2].
	(#(#* #/ #// #\\) includes: anObject) ifTrue: [^ 3].
	^ 0.

]

{ #category : #all }
EToyExpressionTransformer >> precr: anObject [

	anObject ifNil: [^ 0].
	(#(#max: #min:) includes: anObject) ifTrue: [^ 1].
	(#(#+ #-) includes: anObject) ifTrue: [^ 2].
	(#(#* #/ #// #\\) includes: anObject) ifTrue: [^ 3].
	^ 4.

]

{ #category : #all }
EToyExpressionTransformer >> pushAMessageNode: node [

	| s |
	node isEToyBinaryExp ifTrue: [
		inputQueue addLast: node receiver.
		inputQueue addLast: ((s := node selector) isSymbol ifTrue: [s] ifFalse: [s key]).
		inputQueue addLast: node arguments first.
	] ifFalse: [
		inputQueue addLast: node
	].

]

{ #category : #all }
EToyExpressionTransformer >> reduceOnStack [

	| list left sel right m |
	list := stack removeLast: 3.
	left := list at: 1.
	sel := list at: 2.
	right := list at: 3.

	m := MessageNode new
				receiver: left
				selector: sel
				arguments: (Array with: right)
				precedence: (sel precedence)
				from: encoder
				sourceRange: nil.
	stack addLast: m.

]

{ #category : #all }
EToyExpressionTransformer >> transform [

	| leftPrec rightPrec n |
	[(self inputQueueEmpty and: [stack size = 1]) not] whileTrue: [
		leftPrec := self precl.
		rightPrec := self precr: (n := self inputQueuePeek).
		leftPrec >= rightPrec ifTrue: [
			self reduceOnStack.
		] ifFalse: [
			self inputQueueNext.
			stack addLast: n.
		].
	].
	^ stack last.



]
