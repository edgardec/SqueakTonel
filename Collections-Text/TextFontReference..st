"
A TextFontReference encodes a font change applicable over a given range of text.  The font reference is absolute:  unlike a TextFontChange, it is independent of the textStyle governing display of this text.
"
Class {
	#name : #TextFontReference,
	#superclass : #TextFontChange,
	#instVars : [
		'font'
	],
	#category : #'Collections-Text'
}

{ #category : #'fileIn\/Out' }
TextFontReference class >> scanCharacter [
	"The character used to identify a subclass of TextAttribute for filein and fileout"
	^$F
]

{ #category : #'fileIn\/Out' }
TextFontReference class >> scanFrom: strm [
	^self toFont: 
		(StrikeFont familyName: (strm upTo: $#) size: (Number readFrom: strm ifFail: [0]))
]

{ #category : #'as yet unclassified' }
TextFontReference class >> toFont: aFont [
	^ self new toFont: aFont
]

{ #category : #comparing }
TextFontReference >> = other [ 
	^ (other class == self class) 
		and: [other font = font]
]

{ #category : #testing }
TextFontReference >> couldDeriveFromPrettyPrinting [
	^ false
]

{ #category : #'initialize-release' }
TextFontReference >> emphasizeScanner: scanner [
	"Set the actual font for text display"
	scanner setActualFont: font
]

{ #category : #accessing }
TextFontReference >> font [

	^ font
]

{ #category : #private }
TextFontReference >> forFontInStyle: aTextStyle do: aBlock [
	aBlock value: font
]

{ #category : #comparing }
TextFontReference >> hash [
	"#hash is re-implemented because #= is re-implemented"
	^font hash
]

{ #category : #comparing }
TextFontReference >> printOn: aStream [
	aStream nextPutAll: 'a TextFontReference(';
		print: font;
		nextPut: $)
]

{ #category : #'initialize-release' }
TextFontReference >> toFont: aFont [

	font := aFont
]

{ #category : #'fileIn\/fileOut' }
TextFontReference >> writeScanOn: strm [

	strm nextPut: self class scanCharacter.
	strm nextPutAll: font familyName; nextPut: $#.
	font height printOn: strm.
]
