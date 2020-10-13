"
A TextKern encodes a kerning change applicable over a given range of text.  Positive values of kern spread letters out, negative kern will cause them to overlap more.  Note that kerns other than 0 will display somewhat slower, as kerning is not yet supported in the text scanning primitive. 
"
Class {
	#name : #TextKern,
	#superclass : #TextAttribute,
	#instVars : [
		'kern',
		'active'
	],
	#category : #'Collections-Text'
}

{ #category : #'fileIn\/Out' }
TextKern class >> consumeIdentifierFrom: scanStream. [
	"Do not consume the identifier character. Leave it in the stream
	for use in identifying the kern value."

]

{ #category : #'instance creation' }
TextKern class >> kern: kernValue [
	^ self new kern: kernValue
]

{ #category : #'fileIn\/Out' }
TextKern class >> scanCharacters [
	"All scan characters corresponding to this class. See writeScanOn:"
	^ #( $- $+ )
]

{ #category : #'fileIn\/Out' }
TextKern class >> scanFrom: strm [
	| char k |
	char := strm next.
	char = $+
		ifTrue: [
			k := 1.
			[strm atEnd not and: [strm peek = char]]
				whileTrue: [strm next. k := k + 1].
			^ self kern: k].
	char = $-
		ifTrue: [
			k := -1.
			[strm atEnd not and: [strm peek = char]]
				whileTrue: [strm next. k := k - 1].
			^ self kern: k].
	self error: 'invalid identifier character'
			
	

]

{ #category : #comparing }
TextKern >> = other [ 
	^ (other class == self class) 
		and: [other kern = kern]
]

{ #category : #testing }
TextKern >> couldDeriveFromPrettyPrinting [
	^ false
]

{ #category : #testing }
TextKern >> dominatedByCmd0 [
	"Cmd-0 should turn off kerning"
	^ true
]

{ #category : #testing }
TextKern >> dominates: other [
	"NOTE: The use of active in this code is specific to its use in the method
		Text class addAttribute: att toArray: others"
	(active and: [other class == self class and: [other kern + kern = 0]])
		ifTrue: [active := false.  ^ true].  "can only dominate once"
	^ false
]

{ #category : #kerning }
TextKern >> emphasizeScanner: scanner [
	"Augment (or diminish) the kerning offset for text display"
	scanner addKern: kern
]

{ #category : #comparing }
TextKern >> hash [
	"#hash is re-implemented because #= is re-implemented"
	^kern hash
]

{ #category : #testing }
TextKern >> isKern [
	^true
]

{ #category : #accessing }
TextKern >> kern [
	^ kern
]

{ #category : #'initialize-release' }
TextKern >> kern: kernValue [
	kern := kernValue.
	self reset.
]

{ #category : #'initialize-release' }
TextKern >> reset [
	active := true
]

{ #category : #'initialize-release' }
TextKern >> set [
	^ active
]

{ #category : #'fileIn\/fileOut' }
TextKern >> writeScanOn: strm [

	kern > 0 ifTrue: [
		1 to: kern do: [:kk | strm nextPut: $+]].
	kern < 0 ifTrue: [
		1 to: 0-kern do: [:kk | strm nextPut: $-]].
]
