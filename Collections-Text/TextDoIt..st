Class {
	#name : #TextDoIt,
	#superclass : #TextAction,
	#instVars : [
		'evalString'
	],
	#category : #'Collections-Text'
}

{ #category : #'instance creation' }
TextDoIt class >> evalString: str [
	^ self new evalString: str
]

{ #category : #'fileIn\/Out' }
TextDoIt class >> scanCharacter [
	"The character used to identify a subclass of TextAttribute for filein and fileout"
	^$d
]

{ #category : #'fileIn\/Out' }
TextDoIt class >> scanFrom: strm [
	"read a doit in the funny format used by Text styles on files. d10 factorial;;  end with two semicolons"

	| pos end doit |
	pos := strm position.
	[strm skipTo: $;. strm peek == $;] whileFalse.
	end := strm position - 1.
	strm position: pos.
	doit := strm next: end-pos.
	strm skip: 2.  ";;"
	^ self evalString: doit
]

{ #category : #comparing }
TextDoIt >> = textAttribute [
	^ textAttribute class == self class
		and: [textAttribute evalString = evalString]
]

{ #category : #'event handling' }
TextDoIt >> actOnClickFor: anObject [
	"Note: evalString gets evaluated IN THE CONTEXT OF anObject
	 -- meaning that self and all instVars are accessible"
	Compiler evaluate: evalString for: anObject.
	^ true 
]

{ #category : #'initialize-release' }
TextDoIt >> analyze: aString [

	| list |
	list := super analyze: aString.
	evalString := (list at: 1) asString.
	^ list at: 2
]

{ #category : #html }
TextDoIt >> closeHtmlOn: aStream [ 

	self evalString lines size > 1 ifTrue: [
		aStream 
			breakLines: true;
			nextPutAll: '</pre>'].
	aStream nextPutAll: '</code>'.

]

{ #category : #accessing }
TextDoIt >> emphasizeScanner: scanner [
	scanner addEmphasis: 4
]

{ #category : #accessing }
TextDoIt >> evalString [
	^evalString
]

{ #category : #accessing }
TextDoIt >> evalString: str [
	evalString := str 
]

{ #category : #comparing }
TextDoIt >> hash [
	^evalString hash
]

{ #category : #accessing }
TextDoIt >> info [
	^ evalString
]

{ #category : #html }
TextDoIt >> openHtmlOn: aStream [ 

	aStream nextPutAll: '<code>'.
	self evalString lines size > 1 ifTrue: [
		aStream 
			breakLines: false;
			cr; 
			nextPutAll: '<pre>'].
]

{ #category : #html }
TextDoIt >> shouldFormBlocks [

	^ true
]

{ #category : #'fileIn\/fileOut' }
TextDoIt >> writeScanOn: strm [

	strm nextPut: self class scanCharacter; nextPutAll: evalString; nextPutAll: ';;'
]
