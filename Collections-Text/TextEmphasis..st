"
A TextEmphasis, encodes a characteristic applicable to all fonts.  The encoding is as follows:
	1	bold
	2	itallic
	4	underlined
	8	narrow
	16	struck out
"
Class {
	#name : #TextEmphasis,
	#superclass : #TextAttribute,
	#instVars : [
		'emphasisCode',
		'setMode'
	],
	#category : #'Collections-Text'
}

{ #category : #'instance creation' }
TextEmphasis class >> bold [
	^ self new emphasisCode: 1
]

{ #category : #'fileIn\/Out' }
TextEmphasis class >> consumeIdentifierFrom: scanStream. [
	"Do not consume the identifier character. Leave it in the stream
	for use in identifying the type of emphasis."

]

{ #category : #'instance creation' }
TextEmphasis class >> italic [
	^ self new emphasisCode: 2
]

{ #category : #'instance creation' }
TextEmphasis class >> narrow [
	^ TextKern kern: -1
]

{ #category : #'instance creation' }
TextEmphasis class >> normal [
	^ self new emphasisCode: 0
]

{ #category : #'fileIn\/Out' }
TextEmphasis class >> scanCharacters [
	"All scan characters corresponding to this class. See writeScanOn:"
	^ #( $b $i $n $= $u )
]

{ #category : #'fileIn\/Out' }
TextEmphasis class >> scanFrom: strm [
	^strm next
		caseOf: {
			[ $b ] -> [ self bold ] .	
			[ $i ] -> [ self italic ] .	
			[ $u ] -> [ self underlined ] .	
			[ $= ] -> [ self struckOut ] .	
			[ $n ] -> [ self normal ]
		}
		otherwise: [self error: 'unrecognized identifier ']
]

{ #category : #'instance creation' }
TextEmphasis class >> struckOut [
	^ self new emphasisCode: 16
]

{ #category : #'instance creation' }
TextEmphasis class >> underlined [
	^ self new emphasisCode: 4
]

{ #category : #comparing }
TextEmphasis >> = other [ 
	^ (other class == self class) 
		and: [other emphasisCode = emphasisCode]
]

{ #category : #html }
TextEmphasis >> closeHtmlOn: aStream [ 
	"put on the given stream the tag to close the html  
	representation of the receiver"
	emphasisCode = 1
		ifTrue: [aStream nextPutAll: '</b>'].
	emphasisCode = 2
		ifTrue: [aStream nextPutAll: '</i>'].
	emphasisCode = 4
		ifTrue: [aStream nextPutAll: '</u>'].
	emphasisCode = 16
		ifTrue: [aStream nextPutAll: '</s>'].
]

{ #category : #testing }
TextEmphasis >> dominatedByCmd0 [
	"Cmd-0 should turn off emphasis"
	^ true
]

{ #category : #testing }
TextEmphasis >> dominates: other [
	(emphasisCode = 0 and: [other dominatedByCmd0]) ifTrue: [^ true].
	^ (other class == self class)
		and: [emphasisCode = other emphasisCode]
]

{ #category : #accessing }
TextEmphasis >> emphasisCode [
	^ emphasisCode
]

{ #category : #'initialize-release' }
TextEmphasis >> emphasisCode: int [
	emphasisCode := int.
	setMode := true
]

{ #category : #accessing }
TextEmphasis >> emphasizeScanner: scanner [
	"Set the emphasist for text scanning"
	scanner addEmphasis: emphasisCode
]

{ #category : #comparing }
TextEmphasis >> hash [
	"#hash is re-implemented because #= is re-implemented"
	^emphasisCode hash

]

{ #category : #html }
TextEmphasis >> openHtmlOn: aStream [ 
	"put on the given stream the tag to open the html  
	representation of the receiver"
	emphasisCode = 1
		ifTrue: [aStream nextPutAll: '<b>'].
	emphasisCode = 2
		ifTrue: [aStream nextPutAll: '<i>'].
	emphasisCode = 4
		ifTrue: [aStream nextPutAll: '<u>'].
	emphasisCode = 16
		ifTrue: [aStream nextPutAll: '<s>']
]

{ #category : #printing }
TextEmphasis >> printOn: strm [
	super printOn: strm.
	strm nextPutAll: ' code: '; print: emphasisCode
]

{ #category : #accessing }
TextEmphasis >> set [
	^ setMode and: [emphasisCode ~= 0]
]

{ #category : #'initialize-release' }
TextEmphasis >> turnOff [
	setMode := false
]

{ #category : #'fileIn\/fileOut' }
TextEmphasis >> writeScanOn: strm [

	emphasisCode = 1 ifTrue: [strm nextPut: $b].
	emphasisCode = 2 ifTrue: [strm nextPut: $i].
	emphasisCode = 0 ifTrue: [strm nextPut: $n].
	emphasisCode = 16 ifTrue: [strm nextPut: $=].
	emphasisCode = 4 ifTrue: [strm nextPut: $u].
]
