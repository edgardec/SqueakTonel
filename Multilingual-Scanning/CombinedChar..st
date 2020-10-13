Class {
	#name : #CombinedChar,
	#superclass : #Object,
	#instVars : [
		'codes',
		'combined'
	],
	#classVars : [
		'Compositions',
		'Decompositions',
		'Diacriticals'
	],
	#category : #'Multilingual-Scanning'
}

{ #category : #'as yet unclassified' }
CombinedChar class >> isDiacriticals: unicode [

	^ Diacriticals includes: unicode.

]

{ #category : #'as yet unclassified' }
CombinedChar class >> parseCompositionMappingFrom: stream [
"
	self halt.
	self parseCompositionMapping
"

	| line fieldEnd point fieldStart compositions toNumber diacritical result |

	toNumber := [:quad | ('16r', quad) asNumber].

	Compositions := IdentityDictionary new: 2048.
	Decompositions := IdentityDictionary new: 2048.
	Diacriticals := IdentitySet new: 2048.

	[(line := stream nextLine) size > 0] whileTrue: [
		fieldEnd := line indexOf: $; startingAt: 1.
		point := ('16r', (line copyFrom: 1 to: fieldEnd - 1)) asNumber.
		2 to: 6 do: [:i |
			fieldStart := fieldEnd + 1.
			fieldEnd := line indexOf: $; startingAt: fieldStart.
		].
		compositions := line copyFrom: fieldStart to: fieldEnd - 1.
		(compositions size > 0 and: [compositions first ~= $<]) ifTrue: [
			compositions := compositions substrings collect: toNumber.
			compositions size > 1 ifTrue: [
				diacritical := compositions first.
				Diacriticals add: diacritical.
				result := compositions second.
				(Decompositions includesKey: point) ifTrue: [
					self error: 'should not happen'.
				] ifFalse: [
					Decompositions at: point put: (Array with: diacritical with: result).
				].
				(Compositions includesKey: diacritical) ifTrue: [
					(Compositions at: diacritical) at: result put: point.
				] ifFalse: [
					Compositions at: diacritical
						put: (IdentityDictionary new at: result put: point; yourself).
				].
			].
		].
	].

]

{ #category : #composition }
CombinedChar >> add: char [

	| dict elem |
	codes ifNil: [codes := Array with: char. combined := char. ^ true].
	dict := Compositions at: combined charCode ifAbsent: [^ false].
	elem := dict at: char charCode ifAbsent: [^ false].
	codes := codes copyWith: char.
	combined := Character leadingChar: self base leadingChar code: elem.
	^ true.

]

{ #category : #accessing }
CombinedChar >> asCharacter [
"return my base char"
	^self base 
]

{ #category : #accessing }
CombinedChar >> asInteger [
"return my base chars asInteger"
	^self base asInteger
]

{ #category : #accessing }
CombinedChar >> asciiValue [
"return my base chars ascii"
	^self base asciiValue
]

{ #category : #accessing }
CombinedChar >> base [

	^ codes first.

]

{ #category : #accessing }
CombinedChar >> charCode [
"return my base chars charCode"
	^self base charCode
]

{ #category : #accessing }
CombinedChar >> combined [

	^ combined.

]

{ #category : #accessing }
CombinedChar >> leadingChar [
"return my base chars leadingChar"
	^self base leadingChar
]

{ #category : #composition }
CombinedChar >> simpleAdd: char [

	| dict elem |
	codes ifNil: [codes := Array with: char. combined := char. ^ true].

	dict := Compositions at: combined charCode ifAbsent: [^ false].

	elem := dict at: char charCode ifAbsent: [^ false].

	combined := Character leadingChar: self base leadingChar code: elem.
	codes at: 1 put: combined.
	^ true.

]
