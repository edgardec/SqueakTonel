"
This class represents the array of 8 bit wide characters.

"
Class {
	#name : #ByteString,
	#superclass : #String,
	#type : #bytes,
	#category : #'Collections-Strings'
}

{ #category : #primitives }
ByteString class >> compare: string1 with: string2 collated: order [
	"Return 1, 2 or 3, if string1 is <, =, or > string2, with the collating order of characters given by the order array."

	| len1 len2 c1 c2 |
	<primitive: 'primitiveCompareString' module: 'MiscPrimitivePlugin'>
	<var: #string1 declareC: 'unsigned char *string1'>
	<var: #string2 declareC: 'unsigned char *string2'>
	<var: #order declareC: 'unsigned char *order'>

	len1 := string1 size.
	len2 := string2 size.
	1 to: (len1 min: len2) do:
		[:i |
		c1 := order at: (string1 basicAt: i) + 1.
		c2 := order at: (string2 basicAt: i) + 1.
		c1 = c2 ifFalse: 
			[c1 < c2 ifTrue: [^ 1] ifFalse: [^ 3]]].
	len1 = len2 ifTrue: [^ 2].
	len1 < len2 ifTrue: [^ 1] ifFalse: [^ 3].

]

{ #category : #primitives }
ByteString class >> findFirstInString: aString  inSet: inclusionMap  startingAt: start [
	| i stringSize |
	<primitive: 'primitiveFindFirstInString' module: 'MiscPrimitivePlugin'>
	<var: #aString declareC: 'unsigned char *aString'>
	<var: #inclusionMap  declareC: 'char *inclusionMap'>

	inclusionMap size ~= 256 ifTrue: [ ^0 ].

	i := start.
	stringSize := aString size.
	[ i <= stringSize and: [ (inclusionMap at: (aString basicAt: i) + 1) = 0 ] ] whileTrue: [ 
		i := i + 1 ].

	i > stringSize ifTrue: [ ^0 ].
	^i
]

{ #category : #primitives }
ByteString class >> indexOfAscii: anInteger inString: aString startingAt: start [

	| stringSize |
	<primitive: 'primitiveIndexOfAsciiInString' module: 'MiscPrimitivePlugin'>
	<var: #aString type: #'unsigned char *'>

	stringSize := aString size.
	start to: stringSize do: [:pos |
		(aString basicAt: pos) = anInteger ifTrue: [^ pos]].

	^ 0
]

{ #category : #primitives }
ByteString class >> stringHash: aString initialHash: speciesHash [
	"Answer the hash of a byte-indexed string, using speciesHash as the initial value.
	 See SmallInteger>>hashMultiply."
	<primitive: 'primitiveStringHash' module: 'MiscPrimitivePlugin'>
	
	^super stringHash: aString initialHash: speciesHash
]

{ #category : #primitives }
ByteString class >> translate: aString from: start  to: stop  table: table [
	"translate the characters in the string by the given table, in place"
	<primitive: 'primitiveTranslateStringWithTable' module: 'MiscPrimitivePlugin'>
	<var: #table  declareC: 'unsigned char *table'>
	<var: #aString  declareC: 'unsigned char *aString'>

	start to: stop do: [ :i |
		aString at: i put: (table at: (aString basicAt: i) + 1) ]
]

{ #category : #accessing }
ByteString >> applyLanguageInformation: languageEnvironment [

]

{ #category : #converting }
ByteString >> asByteArray [
	| ba sz |
	sz := self byteSize.
	ba := ByteArray new: sz.
	ba replaceFrom: 1 to: sz with: self startingAt: 1.
	^ba
]

{ #category : #converting }
ByteString >> asIntegerSigned: signed [
	"Return the first decimal integer I can find or nil."

	| index integerValue result size negative |
	(size := self size) <= 16 ifFalse: [ ^super asIntegerSigned: signed ].
	"Find the first character between $0 and $9."
	index := 0.
	[ 
		(index := index + 1) <= size ifFalse: [ ^nil "There are no digits in this string." ].
		(integerValue := self basicAt: index) <= 47 "$0 asInteger - 1"
			or: [ 58 "$9 asInteger + 1" <= integerValue ] ] whileTrue.
	"Check the sign."
	negative := signed and: [ 2 <= index and: [ (self at: index - 1) == $- ] ].
	"Parse the number."
	result := integerValue - 48 "$0 asInteger".
	[ (index := index + 1) <= size
		and: [ (integerValue := self basicAt: index) <= 57 "$9 asInteger"
		and: [ 48 "$0 asInteger" <= integerValue ] ] ]  whileTrue: [
		result := result * 10 + integerValue - 48 ].
	negative ifTrue: [ ^result negated ].
	^result
]

{ #category : #converting }
ByteString >> asOctetString [

	^ self.

]

{ #category : #accessing }
ByteString >> at: index [ 
	"Primitive. Answer the Character stored in the field of the receiver
	indexed by the argument. Fail if the index argument is not an Integer or
	is out of bounds. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 63>
	^ Character value: (super at: index)
]

{ #category : #accessing }
ByteString >> at: index put: aCharacter [
	"Primitive. Store the Character in the field of the receiver indicated by the index.
	 Fail if the index is not an Integer or is out of bounds, or if the argument is not a
	 Character, or the Character's code is outside the 0-255 range, or if the receiver
	 is read-only. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 64 error: ec>
	aCharacter isCharacter ifFalse:
		[^self errorImproperStore].
	index isInteger
		ifTrue:
			[ec == #'no modification' ifTrue:
				[^thisContext modificationForbiddenFor: self at: index putCharacter: aCharacter].
			 aCharacter isOctetCharacter ifFalse: "Convert to WideString"
				[self becomeForward: (WideString from: self).
				^self at: index put: aCharacter].
			 self errorSubscriptBounds: index]
		ifFalse: [self errorNonIntegerIndex]
]

{ #category : #accessing }
ByteString >> byteAt: index [
	<primitive: 60>
	^(self at: index) asciiValue
]

{ #category : #accessing }
ByteString >> byteAt: index put: value [
	<primitive: 61>
	self at: index put: value asCharacter.
	^value
]

{ #category : #accessing }
ByteString >> byteSize [
	^self size
]

{ #category : #testing }
ByteString >> canBeToken [
	"Optimized version for the common case."
	
	^ (self findSubstring: '~' in: self startingAt: 1 matchTable: Tokenish) = 0 
		
]

{ #category : #converting }
ByteString >> convertFromCompoundText [

	| readStream writeStream converter |
	readStream := self readStream.
	writeStream := String new writeStream.
	converter := CompoundTextConverter new.
	converter ifNil: [^ self].
	[readStream atEnd] whileFalse: [
		writeStream nextPut: (converter nextFromStream: readStream)].
	^ writeStream contents

]

{ #category : #converting }
ByteString >> convertFromSystemString [

	| readStream writeStream converter |
	readStream := self readStream.
	writeStream := String new writeStream.
	converter := LanguageEnvironment defaultSystemConverter.
	converter ifNil: [^ self].
	[readStream atEnd] whileFalse: [
		writeStream nextPut: (converter nextFromStream: readStream)].
	^ writeStream contents

]

{ #category : #comparing }
ByteString >> findSubstring: key in: body startingAt: start matchTable: matchTable [
	"Answer the index in the string body at which the substring key first occurs, at or beyond start.  The match is determined using matchTable, which can be used to effect, eg, case-insensitive matches.  If no match is found, zero will be returned.

	The algorithm below is not optimum -- it is intended to be translated to C which will go so fast that it wont matter."
	| index |
	<primitive: 'primitiveFindSubstring' module: 'MiscPrimitivePlugin'>
	<var: #key type: #'unsigned char *'>
	<var: #body type: #'unsigned char *'>
	<var: #matchTable type: #'unsigned char *'>

	key size = 0 ifTrue: [^ 0].
	(start max: 1) to: body size - key size + 1 do:
		[:startIndex |
		index := 1.
		[(matchTable at: (body basicAt: startIndex+index-1) + 1)
			= (matchTable at: (key basicAt: index) + 1)]
			whileTrue:
				[index = key size ifTrue: [^ startIndex].
				index := index+1]].
	^ 0
"
' ' findSubstring: 'abc' in: 'abcdefabcd' startingAt: 1 matchTable: CaseSensitiveOrder 1
' ' findSubstring: 'abc' in: 'abcdefabcd' startingAt: 2 matchTable: CaseSensitiveOrder 7
' ' findSubstring: 'abc' in: 'abcdefabcd' startingAt: 8 matchTable: CaseSensitiveOrder 0
' ' findSubstring: 'abc' in: 'abcdefABcd' startingAt: 2 matchTable: CaseSensitiveOrder 0
' ' findSubstring: 'abc' in: 'abcdefABcd' startingAt: 2 matchTable: CaseInsensitiveOrder 7
"
]

{ #category : #private }
ByteString >> hashWithInitialHash: speciesHash [
	"Answer the hash of a byte-indexed string, using speciesHash as the initial value.
	 See SmallInteger>>hashMultiply."
	<primitive: 'primitiveStringHash' module: 'MiscPrimitivePlugin'>

	^super hashWithInitialHash: speciesHash
]

{ #category : #accessing }
ByteString >> indexOfAnyOf: aCollection startingAt: start [
	"Use double dispatching for speed"
	^aCollection findFirstInByteString: self startingAt: start
]

{ #category : #testing }
ByteString >> isByteString [
	"Answer whether the receiver is a ByteString"
	^true
]

{ #category : #testing }
ByteString >> isOctetString [
	"Answer whether the receiver can be represented as a byte string. 
	This is different from asking whether the receiver *is* a ByteString 
	(i.e., #isByteString)"
	^ true.

]

{ #category : #enumerating }
ByteString >> occurrencesOf: anObject [ 
	"Answer how many of the receiver's elements are equal to anObject. Optimized version."

	| tally |
	anObject isCharacter ifFalse: [ ^0 ].
	anObject asInteger > 255 ifTrue: [ ^0 ].
	tally := 0.
	1 to: self size do: [ :index |
		(self at: index) == anObject ifTrue: [ tally := tally + 1 ] ].
	^tally
]

{ #category : #accessing }
ByteString >> replaceFrom: start to: stop with: replacement startingAt: repStart [ 
	"Primitive. This destructively replaces elements from start to stop in the receiver starting at index, repStart, in the collection, replacement. Answer the receiver. Range checks are performed in the primitive only. Optional. See Object documentation whatIsAPrimitive."
	<primitive: 105>
	replacement class == WideString ifTrue: [
		self becomeForward: (WideString from: self).
	]. 

	super replaceFrom: start to: stop with: replacement startingAt: repStart.

]

{ #category : #converting }
ByteString >> squeakToUtf8 [
	"Convert the given string (self) to UTF-8 from Squeak's internal representation."

	^UTF8TextConverter encodeByteString: self
]

{ #category : #converting }
ByteString >> substrings [
	"Answer an array of the substrings that compose the receiver."
	
	^Array streamContents: [ :stream |
		| end start |
		end := 1.
		"find one substring each time through this loop"
		[ "find the beginning of the next substring"
			(start := self 
				indexOfAnyOf: CharacterSet nonSeparators 
				startingAt: end) = 0 ]
			whileFalse: [
				"find the end"
				end := self 
					indexOfAnyOf: CharacterSet separators 
					startingAt: start
					ifAbsent: [ self size + 1 ].
				stream nextPut: (self copyFrom: start to: end - 1) ] ]
]

{ #category : #converting }
ByteString >> utf8ToSqueak [
	"Convert the given string (self) from UTF-8 to Squeak's internal representation."
	
	^UTF8TextConverter decodeByteString: self

]
