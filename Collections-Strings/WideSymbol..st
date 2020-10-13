"
This class represents the symbols containing 32bit characters.
"
Class {
	#name : #WideSymbol,
	#superclass : #Symbol,
	#type : #words,
	#category : #'Collections-Strings'
}

{ #category : #accessing }
WideSymbol >> at: index [ 
	"Answer the Character stored in the field of the receiver indexed by the argument."
	^ Character value: (self wordAt: index).

]

{ #category : #accessing }
WideSymbol >> at: anInteger put: anObject [ 
	"You cannot modify the receiver."

	self errorNoModification

]

{ #category : #accessing }
WideSymbol >> byteAt: index [

	| d r |
	d := (index + 3) // 4.
	r := (index - 1) \\ 4 + 1.
	^ (self wordAt: d) digitAt: ((4 - r) + 1).

]

{ #category : #accessing }
WideSymbol >> byteAt: index put: aByte [
	self errorNoModification.
]

{ #category : #accessing }
WideSymbol >> byteSize [

	^ self size * 4.

]

{ #category : #private }
WideSymbol >> fixUponLoad: aProject seg: anImageSegment [
	"We are in an old project that is being loaded from disk. 
	Fix up conventions that have changed."
	| ms |
	"Yoshiki did not put MultiSymbols into outPointers in older 
images!
	When all old images are gone, remove this method."
	ms := Symbol intern: self asString.
	self == ms ifFalse: [
		"For a project from older m17n image, this is necessary."
		self becomeForward: ms.
		aProject projectParameters at: #MultiSymbolInWrongPlace put: true
	].

	"MultiString>>capitalized was not implemented 
correctly. 
	Fix eventual accessors and mutators here."
	((self beginsWith: 'get')
		and:[(self at: 4) asInteger < 256
		and:[(self at: 4) isLowercase]]) ifTrue:[
			ms := self asString.
			ms at: 4 put: (ms at: 4) asUppercase.
			ms := ms asSymbol.
			self becomeForward: ms.
			aProject projectParameters at: #MultiSymbolInWrongPlace put: true.
		].
	((self beginsWith: 'set')
		and:[(self at: 4) asInteger < 256
		and:[(self at: 4) isLowercase
		and:[self last = $:
		and:[(self occurrencesOf: $:) = 1]]]]) ifTrue:[
			ms := self asString.
			ms at: 4 put: (ms at: 4) asUppercase.
			ms := ms asSymbol.
			self becomeForward: ms.
			aProject projectParameters at: #MultiSymbolInWrongPlace put: true.
		].
	^ super fixUponLoad: aProject seg: anImageSegment	"me, 
not the label"

]

{ #category : #testing }
WideSymbol >> isWideString [
	"Answer whether the receiver is a WideString"
	^true
]

{ #category : #private }
WideSymbol >> mutateJISX0208StringToUnicode [

	| c |
	1 to: self size do: [:i |
		c := self at: i.
		(c leadingChar = JISX0208 leadingChar or: [
			c leadingChar = (JISX0208 leadingChar bitShift: 2)]) ifTrue: [
			self basicAt: i put: (Character leadingChar: JapaneseEnvironment leadingChar code: (c asUnicode)) asciiValue.
		]
	].

]

{ #category : #private }
WideSymbol >> pvtAt: index put: aCharacter [
	"Primitive. Store the Character in the field of the receiver indicated by
	 the index. Fail if the index is not an Integer or is out of bounds, or if
	 the argument is not a Character, or if the receiver is read-only.
	 Essential. See Object documentation whatIsAPrimitive."

	<primitive: 61 error: ec>
	aCharacter isCharacter ifFalse:
		[^self errorImproperStore].
	index isInteger
		ifTrue:
			[ec == #'no modification' ifTrue:
				[^thisContext modificationForbiddenFor: self at: index putCharacter: aCharacter].
			self errorSubscriptBounds: index]
		ifFalse: [self errorNonIntegerIndex]
]

{ #category : #accessing }
WideSymbol >> species [
	"Answer the preferred class for reconstructing the receiver."
	^WideString

]

{ #category : #private }
WideSymbol >> string: aString [
	1 to: aString size do: [:j | self pvtAt: j put: (aString at: j) asInteger].
	^self
]

{ #category : #accessing }
WideSymbol >> wordAt: index [
	<primitive: 60>
	^ (self basicAt: index).

]

{ #category : #accessing }
WideSymbol >> wordAt: index put: anInteger [
	self errorNoModification.
]
