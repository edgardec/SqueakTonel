"
See BorderedMorph

BorderedMorh new borderStyle: (BorderStyle inset width: 2); openInWorld.
"
Class {
	#name : #BorderStyle,
	#superclass : #Object,
	#classVars : [
		'Default'
	],
	#category : #'Morphic-Borders'
}

{ #category : #'instance creation' }
BorderStyle class >> borderStyleChoices [
	"Answer the superset of all supported borderStyle symbols"

	^ #(simple inset raised complexAltFramed complexAltInset complexAltRaised complexFramed complexInset complexRaised)
]

{ #category : #'instance creation' }
BorderStyle class >> borderStyleForSymbol: sym [
	"Answer a border style corresponding to the given symbol"

	| aSymbol |
	aSymbol := sym == #none ifTrue: [#simple] ifFalse: [sym].
	^ (self borderStyleChoices includes: aSymbol)
		ifTrue: [self perform: aSymbol]
		ifFalse: [nil]
"
	| aSymbol selector |
	aSymbol := sym == #none ifTrue: [#simple] ifFalse: [sym].
	selector := Vocabulary eToyVocabulary translationKeyFor: aSymbol.
	selector isNil ifTrue: [selector := aSymbol].
	^ self perform: selector
"

]

{ #category : #'instance creation' }
BorderStyle class >> color: aColor width: aNumber [
	^self width: aNumber color: aColor
]

{ #category : #'instance creation' }
BorderStyle class >> complexAltFramed [
	^ComplexBorder style: #complexAltFramed
]

{ #category : #'instance creation' }
BorderStyle class >> complexAltInset [
	^ComplexBorder style: #complexAltInset
]

{ #category : #'instance creation' }
BorderStyle class >> complexAltRaised [
	^ComplexBorder style: #complexAltRaised
]

{ #category : #'instance creation' }
BorderStyle class >> complexFramed [
	^ComplexBorder style: #complexFramed
]

{ #category : #'instance creation' }
BorderStyle class >> complexInset [
	^ComplexBorder style: #complexInset
]

{ #category : #'instance creation' }
BorderStyle class >> complexRaised [
	^ComplexBorder style: #complexRaised
]

{ #category : #'instance creation' }
BorderStyle class >> default [
	^Default ifNil:[Default := self new]
]

{ #category : #'instance creation' }
BorderStyle class >> inset [
	^InsetBorder new
]

{ #category : #'instance creation' }
BorderStyle class >> raised [
	^RaisedBorder new
]

{ #category : #'instance creation' }
BorderStyle class >> simple [
	"Answer a simple border style"

	^ SimpleBorder new
]

{ #category : #'instance creation' }
BorderStyle class >> thinGray [
	^ self width: 1 color: Color gray
]

{ #category : #'instance creation' }
BorderStyle class >> width: aNumber [
	^self width: aNumber color: Color black
]

{ #category : #'instance creation' }
BorderStyle class >> width: aNumber color: aColor [
	"Since I am abstact, use SimpleBorder instead."
	
	^ (self == BorderStyle ifTrue: [SimpleBorder] ifFalse: [self]) new
		color: aColor;
		width: aNumber;
		yourself
]

{ #category : #comparing }
BorderStyle >> = aBorderStyle [
	^self species = aBorderStyle species
		and:[self style == aBorderStyle style
		and:[self width = aBorderStyle width
		and:[self color = aBorderStyle color]]].
]

{ #category : #accessing }
BorderStyle >> baseColor [
	^Color transparent
]

{ #category : #accessing }
BorderStyle >> baseColor: aColor [
	"Ignored"
]

{ #category : #accessing }
BorderStyle >> color [
	^Color transparent
]

{ #category : #accessing }
BorderStyle >> color: aColor [
	"Ignored"
]

{ #category : #drawing }
BorderStyle >> drawLineFrom: startPoint to: stopPoint on: aCanvas [
	^aCanvas line: startPoint to: stopPoint width: self width color: self color
]

{ #category : #drawing }
BorderStyle >> frameOval: aRectangle on: aCanvas [
	"Frame the given rectangle on aCanvas"
	aCanvas frameOval: aRectangle width: self width color: self color
]

{ #category : #drawing }
BorderStyle >> framePolygon: vertices on: aCanvas [
	"Frame the given rectangle on aCanvas"
	self framePolyline: vertices on: aCanvas.
	self drawLineFrom: vertices last to: vertices first on: aCanvas.
]

{ #category : #drawing }
BorderStyle >> framePolyline: vertices on: aCanvas [ 
	"Frame the given rectangle on aCanvas"

	| prev next |
	prev := vertices first.
	2 to: vertices size
		do: 
			[:i | 
			next := vertices at: i.
			self 
				drawLineFrom: prev
				to: next
				on: aCanvas.
			prev := next]
]

{ #category : #drawing }
BorderStyle >> frameRectangle: aRectangle on: aCanvas [
	"Frame the given rectangle on aCanvas"
	aCanvas frameRectangle: aRectangle width: self width color: self color
]

{ #category : #comparing }
BorderStyle >> hash [
	"hash is implemented because #= is implemented"
	^self species hash bitXor: (self width hash bitXor: self color hash)
]

{ #category : #accessing }
BorderStyle >> inset [
	"Possible inset when honoring this border style. The default implementation uses #width to return a uniform inset."
	^ self width
]

{ #category : #testing }
BorderStyle >> isBorderStyle [
	^true
]

{ #category : #testing }
BorderStyle >> isComplex [
	^false
]

{ #category : #initialize }
BorderStyle >> releaseCachedState [
	"Release any associated cached state"
]

{ #category : #accessing }
BorderStyle >> style [
	^#none
]

{ #category : #'color tracking' }
BorderStyle >> trackColorFrom: aMorph [
	"If necessary, update our color to reflect a change in aMorphs color"
]

{ #category : #accessing }
BorderStyle >> width [
	^0
]

{ #category : #accessing }
BorderStyle >> width: aNumber [
	"Ignored"
]
