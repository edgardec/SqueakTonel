Class {
	#name : #StringType,
	#superclass : #DataType,
	#category : #'Protocols-Type Vocabularies'
}

{ #category : #'initial value' }
StringType >> initialValueForASlotFor: aPlayer [
	"Answer the value to give initially to a newly created slot of the given type in the given player"

	^ 'abc'
]

{ #category : #initialization }
StringType >> initialize [
	"Initialize the receiver (automatically called when instances are created via 'new')"

	
	super initialize.
	self vocabularyName: #String.

#((accessing 			'The basic info'
		(at: at:put: size endsWithDigit findString: findTokens: includesSubstring: indexOf: indexOf:startingAt: indexOf:startingAt:ifAbsent: lineCorrespondingToIndex: lineCount lineNumber: startsWithDigit numArgs))
(#'more accessing' 		'More basic info'
		(allButFirst allButFirst: allButLast allButLast: at:ifAbsent: atAllPut: atPin: atRandom: atWrap: atWrap:put: fifth first first: fourth from:to:put: last last: lastIndexOf: lastIndexOf:ifAbsent: middle replaceAll:with: replaceFrom:to:with: replaceFrom:to:with:startingAt: second sixth third))
(comparing				'Determining which comes first alphabeticly'
		(< <= = > >= beginsWith: endsWith: endsWithAnyOf: howManyMatch: match:))
(testing 				'Testing'
		(includes: isEmpty ifNil: ifNotNil: isAllDigits isAllSeparators isString lastSpacePosition))
(converting 			'Converting it to another form'
		(asCharacter asDate asInteger asLowercase asNumber asString asStringOrText asSymbol asText asTime asUppercase asUrl capitalized keywords numericSuffix romanNumber reversed splitInteger surroundedBySingleQuotes withBlanksTrimmed withSeparatorsCompacted withoutTrailingBlanks withoutTrailingDigits asSortedCollection))
(copying 				'Make another one like me'
		(copy copyFrom:to: copyUpTo: copyUpToLast: shuffled))
(enumerating		'Passing over the letters'
		(collect: collectWithIndex: do: from:to:do: reverseDo: select: withIndexDo: detect: detect:ifNone:))
) do: [:item | | aMethodCategory | 
			aMethodCategory := ElementCategory new categoryName: item first.
			aMethodCategory documentation: item second.
			item third do:
				[:aSelector | | aMethodInterface | 
					aMethodInterface := MethodInterface new initializeFor: aSelector.
					self atKey: aSelector putMethodInterface: aMethodInterface.
					aMethodCategory elementAt: aSelector put: aMethodInterface].
			self addCategory: aMethodCategory].

]
