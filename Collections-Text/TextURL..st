Class {
	#name : #TextURL,
	#superclass : #TextAction,
	#instVars : [
		'url'
	],
	#category : #'Collections-Text'
}

{ #category : #'fileIn\/Out' }
TextURL class >> scanCharacter [
	"The character used to identify a subclass of TextAttribute for filein and fileout"
	^$R
]

{ #category : #'fileIn\/Out' }
TextURL class >> scanFrom: strm [
	"read a link in the funny format used by Text styles on files. Rhttp://www.disney.com;"

	^ self new url: (strm upTo: $;)
]

{ #category : #comparing }
TextURL >> = other [ 
	^ (other class == self class) 
		and: [other info = self info]
]

{ #category : #'initialize-release' }
TextURL >> analyze: aString [

	| list |
	list := super analyze: aString.

	(UIManager default request: 'URL to open' translated initialAnswer: (list at: 1))
		in: [:answer | answer ifEmpty: [url := list at: 1] ifNotEmpty: [url := answer]].
	
	^ list at: 2
]

{ #category : #comparing }
TextURL >> hash [
	"#hash is re-implemented because #= is re-implemented"
	^url hash
]

{ #category : #accessing }
TextURL >> info [
	^ url
]

{ #category : #accessing }
TextURL >> url: aString [
	url := aString
]

{ #category : #'fileIn\/fileOut' }
TextURL >> writeScanOn: strm [

	strm nextPut: self class scanCharacter; nextPutAll: url; nextPut: $;
]
