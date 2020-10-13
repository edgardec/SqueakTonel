"
This class represents the array of 32 bit wide characters.

"
Class {
	#name : #WideString,
	#superclass : #String,
	#type : #words,
	#category : #'Collections-Strings'
}

{ #category : #enumeration }
WideString class >> allMultiStringMethods [  

	^CurrentReadOnlySourceFiles cacheDuring: [
		self systemNavigation allMethodsSelect: [ :method |
			method getSource asString isOctetString not ] ]
]

{ #category : #enumeration }
WideString class >> allNonAsciiMethods [

	^CurrentReadOnlySourceFiles cacheDuring: [
		self systemNavigation allMethodsSelect: [ :method |
			method getSource asString isAsciiString not ] ]
]

{ #category : #'instance creation' }
WideString class >> from: aString [ 

	| newString |
	(aString isMemberOf: self)
		ifTrue: [^ aString copy].
	newString := self new: aString size.
	1 to: aString size do: [:index | newString basicAt: index put: (aString basicAt: index)].
	^ newString

]

{ #category : #'instance creation' }
WideString class >> fromByteArray: aByteArray [ 

	| inst |
	aByteArray size \\ 4 = 0 ifFalse: [^ ByteString fromByteArray: aByteArray ].
	inst := self new: aByteArray size // 4.
	4 to: aByteArray size by: 4 do: [:i |
		inst basicAt: i // 4
			put: ((aByteArray at: i - 3) << 24) + 
				((aByteArray at: i - 2) << 16) +
				 ((aByteArray at: i - 1) << 8) +
				(aByteArray at: i)
	].

	^ inst

]

{ #category : #'instance creation' }
WideString class >> fromISO2022JPString: string [ 

	| tempFileName stream contents |
	tempFileName := Time millisecondClockValue printString , '.txt'.
	FileDirectory default deleteFileNamed: tempFileName ifAbsent: [].
	stream := StandardFileStream fileNamed: tempFileName.
	[stream nextPutAll: string]
		ensure: [stream close].
	stream := FileStream fileNamed: tempFileName.
	contents := stream contentsOfEntireFile.
	FileDirectory default deleteFileNamed: tempFileName ifAbsent: [].
	^ contents

]

{ #category : #'instance creation' }
WideString class >> fromPacked: aLong [
	"Convert from a longinteger to a String of length 4."

	| s val |
	s := self new: 1.
	val := (((aLong digitAt: 4) << 24) bitOr:((aLong digitAt: 3) << 16))
				bitOr: (((aLong digitAt: 2) << 8) bitOr: (aLong digitAt: 1)).
	s basicAt: 1 put: val.
	^ s.

"WideString fromPacked: 'TEXT' asPacked"

]

{ #category : #'instance creation' }
WideString class >> fromString: aString [ 
	"Answer an instance of me that is a copy of the argument, aString."

	| inst |
	(aString isMemberOf: self) ifTrue: [
		^ aString copy.
	].
	inst := self new: aString size.
	1 to: aString size do: [:pos |
		inst basicAt: pos put: (aString basicAt: pos).
	].
	^ inst.

]

{ #category : #converting }
WideString >> asFourCode [

	| result |
	self size = 1 ifFalse: [^self error: 'must be exactly four octets'].
	result := self basicAt: 1.
	(result bitAnd: 16r80000000) = 0 
		ifFalse: [self error: 'cannot resolve fourcode'].
	(result bitAnd: 16r40000000) = 0 ifFalse: [^result - 16r80000000].
	^ result

]

{ #category : #converting }
WideString >> asLowercase [
	^self collect: [:e | e asLowercase]
]

{ #category : #converting }
WideString >> asPacked [
	^self inject: 0 into: [:pack :next | pack * 16r100000000 + next asInteger].
]

{ #category : #converting }
WideString >> asUppercase [
	^self collect: [:e | e asUppercase]
]

{ #category : #accessing }
WideString >> at: index [
	"Answer the Character stored in the field of the receiver indexed by the
	 argument.  Primitive.  Fail if the index argument is not an Integer or is out
	 of bounds.  Essential.  See Object documentation whatIsAPrimitive."

	<primitive: 63>
	^index isInteger
		ifTrue:
			[self errorSubscriptBounds: index]
		ifFalse:
			[index isNumber
				ifTrue: [self at: index asInteger]
				ifFalse: [self errorNonIntegerIndex]]
]

{ #category : #accessing }
WideString >> at: index put: aCharacter [
	"Primitive. Store the Character in the field of the receiver indicated by
	 the index. Fail if the index is not an Integer or is out of bounds, or if
	 the argument is not a Character, or if the receiver is read-only.
	 Essential. See Object documentation whatIsAPrimitive."

	<primitive: 64 error: ec>
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
WideString >> byteAt: index [

	| d r |
	d := (index + 3) // 4.
	r := (index - 1) \\ 4 + 1.
	^ (self wordAt: d) digitAt: ((4 - r) + 1).

]

{ #category : #accessing }
WideString >> byteAt: index put: aByte [

	| d r w |
	d := (index + 3) // 4.
	r := (index - 1) \\ 4 + 1.
	w := (self wordAt: d) bitAnd: ((16rFF<<((4 - r)*8)) bitInvert32).
	w := w + (aByte<<((4 - r)*8)).
	self basicAt: d put: w.
	^ aByte.

]

{ #category : #accessing }
WideString >> byteSize [

	^ self size * 4.

]

{ #category : #converting }
WideString >> copyFrom: start to: stop [

	| n |
	n := super copyFrom: start to: stop.
	n isOctetString ifTrue: [^ n asOctetString].
	^ n.

]

{ #category : #testing }
WideString >> includesUnifiedCharacter [

	^ self isUnicodeStringWithCJK

]

{ #category : #testing }
WideString >> isUnicodeStringWithCJK [

	self do: [:c |
		(c isTraditionalDomestic not and: [Unicode isUnifiedKanji: c charCode]) ifTrue: [
			^ true
		].
	].

	^ false.

]

{ #category : #testing }
WideString >> isWideString [
	"Answer whether the receiver is a WideString"
	^true
]

{ #category : #private }
WideString >> mutateJISX0208StringToUnicode [

	| c |
	1 to: self size do: [:i |
		c := self at: i.
		(c leadingChar = JISX0208 leadingChar or: [
			c leadingChar = (JISX0208 leadingChar bitShift: 2)]) ifTrue: [
			self basicAt: i put: (Character leadingChar: JapaneseEnvironment leadingChar code: (c asUnicode)) asciiValue.
		]
	].

]

{ #category : #accessing }
WideString >> replaceFrom: start to: stop with: replacement startingAt: repStart [ 

	<primitive: 105>
	replacement class == ByteString ifTrue: [
		^self replaceFrom: start to: stop with: replacement asWideString startingAt: repStart ]. 
	^super replaceFrom: start to: stop with: replacement startingAt: repStart.

]

{ #category : #accessing }
WideString >> wordAt: index [
	<primitive: 60>
	^ (self basicAt: index).

]

{ #category : #accessing }
WideString >> wordAt: index put: anInteger [
	<primitive: 61>
	self basicAt: index put: anInteger.

]
