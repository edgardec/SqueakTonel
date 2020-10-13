"
A TextColor encodes a text color change applicable over a given range of text.
"
Class {
	#name : #TextColor,
	#superclass : #TextAttribute,
	#instVars : [
		'color'
	],
	#category : #'Collections-Text'
}

{ #category : #constants }
TextColor class >> black [
	^ self new color: Color black
]

{ #category : #constants }
TextColor class >> blue [
	^ self new color: Color blue
]

{ #category : #'instance creation' }
TextColor class >> color: aColor [
	^ self new color: aColor
]

{ #category : #constants }
TextColor class >> cyan [
	^ self new color: Color cyan
]

{ #category : #constants }
TextColor class >> gray [
	^ self new color: Color gray
]

{ #category : #constants }
TextColor class >> green [
	^ self new color: Color green
]

{ #category : #constants }
TextColor class >> magenta [
	^ self new color: Color magenta
]

{ #category : #constants }
TextColor class >> red [
	^ self new color: Color red
]

{ #category : #'fileIn\/Out' }
TextColor class >> scanCharacter [
	"The character used to identify a subclass of TextAttribute for filein and fileout"
	^$c
]

{ #category : #'fileIn\/Out' }
TextColor class >> scanFrom: strm [
	"read a color in the funny format used by Text styles on files. c125000255 or cblue;"

	| r g b |
	strm peek isDigit
		ifTrue:
			[r := (strm next: 3) asNumber.
			g := (strm next: 3) asNumber.
			b := (strm next: 3) asNumber.
			^ self color: (Color r: r g: g b: b range: 255)].
	"A name of a color"
	^ self color: (Color perform: (strm upTo: $;) asSymbol)
]

{ #category : #constants }
TextColor class >> white [ 
	^ self new color: Color white
]

{ #category : #constants }
TextColor class >> yellow [
	^ self new color: Color yellow
]

{ #category : #comparing }
TextColor >> = other [ 
	^ (other class == self class) 
		and: [other color = color]
]

{ #category : #html }
TextColor >> closeHtmlOn: aStream [ 
	"put on the given stream the tag to close the html  
	representation of the receiver"
	aStream nextPutAll: '</font>'
]

{ #category : #accessing }
TextColor >> color [
	^ color
]

{ #category : #accessing }
TextColor >> color: aColor [
	color := aColor
]

{ #category : #testing }
TextColor >> dominatedByCmd0 [
	"Cmd-0 should remove text color"
	^ true
]

{ #category : #scanning }
TextColor >> dominates: other [
	^ other class == self class
]

{ #category : #scanning }
TextColor >> emphasizeScanner: scanner [
	"Set the emphasis for text display"
	scanner textColor: color
]

{ #category : #comparing }
TextColor >> hash [
	^ color hash
]

{ #category : #html }
TextColor >> openHtmlOn: aStream [ 
	"put on the given stream the tag to open the html  
	representation of the receiver"
	aStream nextPutAll: '<font color="#' , color printHtmlString , '">'
]

{ #category : #printing }
TextColor >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: ' code: '; print: color
]

{ #category : #'fileIn\/fileOut' }
TextColor >> writeScanOn: strm [
	"Two formats.  c125000255 or cblue;"

	| nn |
	strm nextPut: self class scanCharacter.
	(nn := color name) ifNotNil: [
		(self class respondsTo: nn) ifTrue: [
			^ strm nextPutAll: nn; nextPut: $;]].
	(Array with: color red with: color green with: color blue) do: [:float |
		| str |
		str := '000', (float * 255) asInteger printString.
		strm nextPutAll: (str copyFrom: str size-2 to: str size)]
]
