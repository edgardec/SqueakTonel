Class {
	#name : #SorterTokenMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'morphRepresented'
	],
	#category : #'MorphicExtras-Palettes'
}

{ #category : #initialization }
SorterTokenMorph >> defaultBorderColor [
	"answer the default border color/fill style for the receiver"
	^ Color blue
]

{ #category : #initialization }
SorterTokenMorph >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 1
]

{ #category : #initialization }
SorterTokenMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color transparent
]

{ #category : #layout }
SorterTokenMorph >> fitContents [
	submorphs size = 1 ifTrue: [self bounds: (submorphs first bounds insetBy: (-1 @ -1))]
]

{ #category : #initialization }
SorterTokenMorph >> forMorph: aMorph [ 
	| it |
	morphRepresented := aMorph.
	aMorph submorphs notEmpty 
		ifTrue: 
			[self addMorphBack: (it := aMorph submorphs first veryDeepCopy).
			it position: self position + (1 @ 1).
			it lock].
	self fitContents
]

{ #category : #thumbnail }
SorterTokenMorph >> morphRepresented [
	^ morphRepresented
]
