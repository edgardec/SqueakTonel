Class {
	#name : #EToyTextNode,
	#superclass : #TextMorph,
	#instVars : [
		'children',
		'firstDisplay'
	],
	#category : #'Etoys-Outliner'
}

{ #category : #'new-morph participation' }
EToyTextNode class >> includeInNewMorphMenu [

	^ false
]

{ #category : #'as yet unclassified' }
EToyTextNode class >> newNode [

	^self new contents: (
		Text
			string: 'new item'
			attribute: (TextFontChange fontNumber: 2)
	)
]

{ #category : #'as yet unclassified' }
EToyTextNode >> addChild: aTextNode [

	children add: aTextNode.

]

{ #category : #'as yet unclassified' }
EToyTextNode >> addNewChildAfter: anotherOrNilOrZero [

	| where newNode |

	anotherOrNilOrZero = 0 ifTrue: [
		newNode := EToyTextNode newNode.
		children := {newNode} asOrderedCollection,children.
		^newNode
	].
	where := children indexOf: anotherOrNilOrZero ifAbsent: [children size].
	children add: (newNode := EToyTextNode newNode) afterIndex: where.
	^newNode

]

{ #category : #'as yet unclassified' }
EToyTextNode >> children [

	^children

]

{ #category : #'as yet unclassified' }
EToyTextNode >> clipToOwner: aBoolean [

	aBoolean ifFalse: [^self setContainer: nil].
	self setContainer: (SimplerTextContainer new for: self minWidth: textStyle lineGrid*2)
]

{ #category : #'as yet unclassified' }
EToyTextNode >> firstDisplay [

	^firstDisplay ifNil: [false]
]

{ #category : #'as yet unclassified' }
EToyTextNode >> firstDisplayedOnLevel: level [

	firstDisplay := false.
	text addAttribute: (TextFontChange fontNumber: ((5 - level) max: 1)).

]

{ #category : #initialization }
EToyTextNode >> initialize [

	| newStyle |
	super initialize.
	firstDisplay := true.
	children := OrderedCollection new.
	(newStyle := TextStyle named: #Palatino) ifNotNil: [
		textStyle := newStyle copy defaultFontIndex: 2
	].


]

{ #category : #'event handling' }
EToyTextNode >> keyStroke: evt [

	(owner notNil and: [owner keyStroke: evt]) ifTrue: [^self].
	^super keyStroke: evt.
]

{ #category : #'event handling' }
EToyTextNode >> keyboardFocusChange: aBoolean [

	super keyboardFocusChange: aBoolean.
	aBoolean ifTrue: [owner takeFocus].


]

{ #category : #'as yet unclassified' }
EToyTextNode >> removeChild: aTextNode [

	children remove: aTextNode ifAbsent: [].

]

{ #category : #'as yet unclassified' }
EToyTextNode >> showInOpenedState [

	| answer |
	answer := self valueOfProperty: #showInOpenedState ifAbsent: [false].
	self removeProperty: #showInOpenedState.
	^answer
]

{ #category : #'as yet unclassified' }
EToyTextNode >> withAllChildrenDo: aBlock [

	aBlock value: self.
	children do: [ :each | each withAllChildrenDo: aBlock].
]
