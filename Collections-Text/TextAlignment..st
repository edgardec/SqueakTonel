Class {
	#name : #TextAlignment,
	#superclass : #TextAttribute,
	#instVars : [
		'alignment'
	],
	#pools : [
		'TextConstants'
	],
	#category : #'Collections-Text'
}

{ #category : #'as yet unclassified' }
TextAlignment class >> alignmentSymbol: alignmentCode [
	^#(leftFlush rightFlush centered justified) at: (alignmentCode + 1)
]

{ #category : #'instance creation' }
TextAlignment class >> centered [
	^self new alignment: Centered
]

{ #category : #'instance creation' }
TextAlignment class >> justified [
	^self new alignment: Justified
]

{ #category : #'instance creation' }
TextAlignment class >> leftFlush [
	^self new alignment: LeftFlush
]

{ #category : #'instance creation' }
TextAlignment class >> rightFlush [
	^self new alignment: RightFlush
]

{ #category : #'fileIn\/Out' }
TextAlignment class >> scanCharacter [
	"The character used to identify a subclass of TextAttribute for filein and fileout"
	^$a
]

{ #category : #'fileIn\/Out' }
TextAlignment class >> scanFrom: strm [
	^self new alignment: (Integer readFrom: strm ifFail: [0])
]

{ #category : #comparing }
TextAlignment >> = other [ 
	^ (other class == self class) 
		and: [other alignment = alignment]
]

{ #category : #accessing }
TextAlignment >> alignment [
	^alignment
]

{ #category : #accessing }
TextAlignment >> alignment: aNumber [
	alignment := aNumber.
]

{ #category : #html }
TextAlignment >> closeHtmlOn: aHtmlReadWriter [ 

	self alignment = Centered ifTrue: [aHtmlReadWriter nextPutAll: '</center>'].
	({ Justified. LeftFlush. RightFlush. } includes: self alignment)
		ifTrue: [aHtmlReadWriter nextPutAll: '</div>'].

]

{ #category : #testing }
TextAlignment >> dominates: other [
	"Alignment dominates other alignments or indentations."
	^ other isTextAlignment or: [ other isTextIndent ]
]

{ #category : #accessing }
TextAlignment >> emphasizeScanner: scanner [
	"Set the emphasist for text scanning"
	scanner setAlignment: alignment.
]

{ #category : #comparing }
TextAlignment >> hash [
	"#hash is re-implemented because #= is re-implemented"
	^ alignment hash
]

{ #category : #testing }
TextAlignment >> isTextAlignment [
	^ true
]

{ #category : #html }
TextAlignment >> openHtmlOn: aHtmlReadWriter [ 

	self alignment = Centered ifTrue: [aHtmlReadWriter nextPutAll: '<center>'].
	self alignment = Justified ifTrue: [aHtmlReadWriter nextPutAll: '<div align=justify>'].
	self alignment = LeftFlush ifTrue: [aHtmlReadWriter nextPutAll: '<div align=left>'].
	self alignment = RightFlush ifTrue: [aHtmlReadWriter nextPutAll: '<div align=right>'].

]

{ #category : #testing }
TextAlignment >> shouldFormBlocks [

	^ true
]

{ #category : #'fileIn\/fileOut' }
TextAlignment >> writeScanOn: strm [

	strm nextPut: self class scanCharacter.
	alignment printOn: strm.
]
