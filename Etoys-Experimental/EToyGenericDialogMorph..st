Class {
	#name : #EToyGenericDialogMorph,
	#superclass : #AlignmentMorphBob1,
	#instVars : [
		'namedFields'
	],
	#category : #'Etoys-Experimental'
}

{ #category : #initialization }
EToyGenericDialogMorph >> defaultBorderColor [
	"answer the default border color/fill style for the receiver"
	^ (Color r: 0.9 g: 0.801 b: 0.2)
]

{ #category : #initialization }
EToyGenericDialogMorph >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 2
]

{ #category : #'as yet unclassified' }
EToyGenericDialogMorph >> genericTextFieldNamed: aString [ 
	| newField |
	newField := ShowEmptyTextMorph new
		beAllFont: self myFont;
		contentsWrapped: '';
		extent: 400 @ 20.
	namedFields at: aString put: newField.
	^ newField
]

{ #category : #'as yet unclassified' }
EToyGenericDialogMorph >> inAColumnForText: someMorphs [ 
	^ (self inAColumn: someMorphs) hResizing: #shrinkWrap;
		 color: (Color r: 0.85 g: 0.9 b: 1);
		 borderColor: (Color r: 0.6 g: 0.7 b: 1);
		 borderWidth: 1;
		 useRoundedCorners
]

{ #category : #initialization }
EToyGenericDialogMorph >> initialize [
	"initialize the state of the receiver"
super initialize.
""
	namedFields := Dictionary new.
	
	self rebuild
]

{ #category : #'as yet unclassified' }
EToyGenericDialogMorph >> lockedString: aString [ 
	^ self lockedString: aString font: self myFont
]

{ #category : #'as yet unclassified' }
EToyGenericDialogMorph >> lockedString: aString font: aFont [
	^ (self inARow: {(StringMorph contents: aString font: aFont) lock})
]

{ #category : #'as yet unclassified' }
EToyGenericDialogMorph >> myFont [
	^ Preferences standardEToysFont
]

{ #category : #initialization }
EToyGenericDialogMorph >> rebuild [
	"rebuilds the receiver"
	^ self
]

{ #category : #'as yet unclassified' }
EToyGenericDialogMorph >> rightLockedString: aString [ 
	^ self rightLockedString: aString font: self myFont
]

{ #category : #'as yet unclassified' }
EToyGenericDialogMorph >> rightLockedString: aString font: aFont [ 

	^ self inARightColumn: {(StringMorph contents: aString font: aFont) lock}
]
