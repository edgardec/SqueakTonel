"
A TextFontChange encodes a font change applicable over a given range of text.  The font number is interpreted relative to the textStyle governing display of this text.
"
Class {
	#name : #TextFontChange,
	#superclass : #TextAttribute,
	#instVars : [
		'fontNumber'
	],
	#category : #'Collections-Text'
}

{ #category : #'instance creation' }
TextFontChange class >> defaultFontChange [
	"Answer a TextFontChange that represents the default font"

	^ self new fontNumber: TextStyle default defaultFontIndex
]

{ #category : #'instance creation' }
TextFontChange class >> font1 [
	^ self new fontNumber: 1
]

{ #category : #'instance creation' }
TextFontChange class >> font2 [
	^ self new fontNumber: 2
]

{ #category : #'instance creation' }
TextFontChange class >> font3 [
	^ self new fontNumber: 3
]

{ #category : #'instance creation' }
TextFontChange class >> font4 [
	^ self new fontNumber: 4
]

{ #category : #'instance creation' }
TextFontChange class >> fontNumber: n [
	^ self new fontNumber: n
]

{ #category : #'fileIn\/Out' }
TextFontChange class >> scanCharacter [
	"The character used to identify a subclass of TextAttribute for filein and fileout"
	^$f
]

{ #category : #'fileIn\/Out' }
TextFontChange class >> scanFrom: strm [
	^self fontNumber: (Integer readFrom: strm ifFail: [0])
]

{ #category : #comparing }
TextFontChange >> = other [ 
	^ (other class == self class) 
		and: [other fontNumber = fontNumber]
]

{ #category : #html }
TextFontChange >> closeHtmlOn: aStream [ 
	"put on the given stream the tag to close the html  
	representation of the receiver"
	| font |
	font := TextStyle default fontAt: fontNumber.
	font closeHtmlOn: aStream
]

{ #category : #testing }
TextFontChange >> dominates: other [
	^ other isKindOf: TextFontChange
]

{ #category : #accessing }
TextFontChange >> emphasizeScanner: scanner [
	"Set the font for text display"
	scanner setFont: fontNumber
]

{ #category : #accessing }
TextFontChange >> fontNumber [
	^ fontNumber
]

{ #category : #accessing }
TextFontChange >> fontNumber: int [
	fontNumber := int
]

{ #category : #private }
TextFontChange >> forFontInStyle: aTextStyle do: aBlock [
	aBlock value: (aTextStyle fontAt: fontNumber)
]

{ #category : #comparing }
TextFontChange >> hash [
	"#hash is re-implemented because #= is re-implemented"
	^fontNumber hash
]

{ #category : #html }
TextFontChange >> openHtmlOn: aStream [ 
	"put on the given stream the tag to open the html  
	representation of the receiver"
	| font |
	font := TextStyle default fontAt: fontNumber.
	font openHtmlOn: aStream
]

{ #category : #printing }
TextFontChange >> printOn: strm [
	super printOn: strm.
	strm nextPutAll: ' font: '; print: fontNumber
]

{ #category : #'fileIn\/fileOut' }
TextFontChange >> writeScanOn: strm [

	strm nextPut: self class scanCharacter.
	fontNumber printOn: strm.
]
