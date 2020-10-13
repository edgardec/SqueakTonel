"
create a hanging indent. 
"
Class {
	#name : #TextIndent,
	#superclass : #TextAttribute,
	#instVars : [
		'amount'
	],
	#category : #'Collections-Text'
}

{ #category : #'instance creation' }
TextIndent class >> amount: amount [
	"create a TextIndent which will indent by the given amount.  Currently this is a number of tabs, but may change in the futur"
	^super new amount: amount
]

{ #category : #example }
TextIndent class >> example [
	"TextIndent example"
	| text pg |

	"create an example text with some indentation"
	text := 'abcdao euoaeuo aeuo aeuoaeu o aeuoeauefgh bcd efghi'  asText.
	text addAttribute: (TextColor red)  from: 3 to: 8.
	text addAttribute: (TextIndent amount: 1) from: 1 to: 2.
	text addAttribute: (TextIndent amount: 2) from: 20 to: 35.

	"stick it in a paragraph and display it"
	pg := text asParagraph.
	pg compositionRectangle: (0@0 extent: 100@200).
	pg textStyle alignment: 2.
	pg displayAt: 0@0.

]

{ #category : #'fileIn\/Out' }
TextIndent class >> scanCharacter [
	"The character used to identify a subclass of TextAttribute for filein and fileout"
	^ $I
]

{ #category : #'fileIn\/Out' }
TextIndent class >> scanFrom: aStream [

	^ self amount: (Integer readFrom: aStream)
]

{ #category : #'instance creation' }
TextIndent class >> tabs: numTabs [
	"create an indentation by the given number of tabs"
	^self amount: numTabs
]

{ #category : #accessing }
TextIndent >> amount [
	"number of tab spaces to indent by"
	^amount
]

{ #category : #accessing }
TextIndent >> amount: anInteger [
	"change the number of tabs to indent by"
	amount := anInteger
]

{ #category : #condensing }
TextIndent >> dominates: aTextAttribute [
	"Indentation should replace any existing alignment or indentation."
	^ aTextAttribute isTextIndent
		or: [ aTextAttribute isTextAlignment ]
]

{ #category : #'setting indentation' }
TextIndent >> emphasizeScanner: scanner [
	scanner indentationLevel: amount
]

{ #category : #testing }
TextIndent >> isTextIndent [
	^ true
]

{ #category : #printing }
TextIndent >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: ' amount: '.
	amount printOn: aStream
]

{ #category : #testing }
TextIndent >> shouldFormBlocks [

	^ true
]

{ #category : #'fileIn\/fileOut' }
TextIndent >> writeScanOn: aStream [

	aStream
		nextPut: self class scanCharacter;
		store: self amount.
]
