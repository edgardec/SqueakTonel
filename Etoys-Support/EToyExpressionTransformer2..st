Class {
	#name : #EToyExpressionTransformer2,
	#superclass : #Object,
	#instVars : [
		'method',
		'stack',
		'inputQueue',
		'encoder'
	],
	#category : #'Etoys-Support'
}

{ #category : #all }
EToyExpressionTransformer2 >> inputQueueEmpty [

	^ inputQueue isEmpty
]

{ #category : #all }
EToyExpressionTransformer2 >> inputQueueNext [
	"It would do the check of selector node that #inputQueuePeek does, but not necessary."

	^ inputQueue removeFirst.

]

{ #category : #all }
EToyExpressionTransformer2 >> inputQueuePeek [

	| v |
	inputQueue size > 0 ifFalse: [^ nil].
	v := inputQueue first.
	(v isMemberOf: SelectorNode) ifTrue: [^ v key asSymbol].
	^ v.

]

{ #category : #all }
EToyExpressionTransformer2 >> newNodeFromList: aList encoder: e [

	encoder := e.
	inputQueue := aList asOrderedCollection.
	stack := OrderedCollection new: 3.

]

{ #category : #all }
EToyExpressionTransformer2 >> precl [

	stack size = 0 ifTrue: [^ 0].
	stack size = 1 ifTrue: [^ self precl: stack last].
	stack last isSymbol ifTrue: [^ 0].
	^ self precl: (stack at: stack size - 1).

]

{ #category : #all }
EToyExpressionTransformer2 >> precl: anObject [

	(#(#max: #min:) includes: anObject) ifTrue: [^ 1].
	(#(#+ #-) includes: anObject) ifTrue: [^ 2].
	(#(#* #/ #// #\\) includes: anObject) ifTrue: [^ 3].
	^ 0.

]

{ #category : #all }
EToyExpressionTransformer2 >> precr: anObject [

	anObject ifNil: [^ 0].
	(#(#max: #min:) includes: anObject) ifTrue: [^ 1].
	(#(#+ #-) includes: anObject) ifTrue: [^ 2].
	(#(#* #/ #// #\\) includes: anObject) ifTrue: [^ 3].
	^ 4.

]

{ #category : #all }
EToyExpressionTransformer2 >> reduceOnStack [

	| list left sel right m |
	list := stack removeLast: 3.
	left := list at: 1.
	sel := list at: 2.
	self flag: #tfel.
	sel isSymbol ifFalse: [sel := sel key].
	right := list at: 3.

	m :=	 MessageNode new
				receiver: left
				selector: sel
				arguments: (Array with: right)
				precedence: (sel precedence)
				from: encoder
				sourceRange: nil.
	stack addLast: m.

]

{ #category : #all }
EToyExpressionTransformer2 >> transform [

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
