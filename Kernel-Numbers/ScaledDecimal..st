"
ScaledDecimal provides a numeric representation of fixed point decimal numbers able to accurately represent decimal fractions.  It supports unbounded precision, with no limit to the number of digits before and after the decimal point.
	ScaledDecimal complies with the ANSI protocols:

	Object
	number
	ScaledDecimal
	????
#todo. ""finish protocol list.""

Implementation Notes:

In order to fullfil exact arithmetic requirements, ScaledDecimal is implemented using a Fraction (or an Integer if fraction part is zero) in the fraction instance variable, and a positive Integer number of digits after the decimal point in the scale instance variable. 

A scaled decimal will perform arithmetic by coercing the arguments to fractions, and perform the operations with exact arithmetic.

Note that the denominator needs not being a power of two. If denominator has other prime factors than 2 and 5, then it cannot be printed in decimal form with a finite number of digits. Instead, the printed representation will be truncated to the number of digits prescribed in scale. But beware, the number still has hidden precision.

Example: 
| x |
x := 1 / 3.0s2.
^{ x printString -> 'truncated print'.
  3 * x -> 'but full precision'}

"
Class {
	#name : #ScaledDecimal,
	#superclass : #Number,
	#instVars : [
		'fraction',
		'scale'
	],
	#category : #'Kernel-Numbers'
}

{ #category : #'instance creation' }
ScaledDecimal class >> newFromNumber: aNumber scale: scaleIn [ 
	"Answer a new instance of me."
	| temp |
	temp := self basicNew.
	temp setFraction: aNumber asFraction scale: scaleIn.
	^ temp
]

{ #category : #'instance creation' }
ScaledDecimal class >> readFrom: stringOrStream [ 
	"Answer a decimal number as described on stringOrStream.
	The number may not include a leading radix specification, as in 16rFADE,
	nor an exponent like 1.0e-3
	It might have a scale specification at end or not like 10.3s2
	If not, number of digits after decimal point will be used as scale"
	
	^(SqNumberParser on: stringOrStream) nextScaledDecimal
]

{ #category : #constants }
ScaledDecimal class >> zero [
	"Answer the receiver's representation of zero."
	^ self newFromNumber: 0 scale: 0
]

{ #category : #arithmetic }
ScaledDecimal >> * operand [ 
	"Implementation of Number 'arithmetic' method."
	(operand isKindOf: ScaledDecimal) ifTrue: [^ ScaledDecimal newFromNumber: fraction * operand asFraction scale: (scale max: operand scale)].
	^ operand adaptToScaledDecimal: self andSend: #*
]

{ #category : #arithmetic }
ScaledDecimal >> + operand [ 
	"Implementation of Number 'arithmetic' method."
	(operand isKindOf: ScaledDecimal) ifTrue: [^ ScaledDecimal newFromNumber: fraction + operand asFraction scale: (scale max: operand scale)].
	^ operand adaptToScaledDecimal: self andSend: #+
]

{ #category : #arithmetic }
ScaledDecimal >> - operand [ 
	"Implementation of Number 'arithmetic' method."
	(operand isKindOf: ScaledDecimal) ifTrue: [^ ScaledDecimal newFromNumber: fraction - operand asFraction scale: (scale max: operand scale)].
	^ operand adaptToScaledDecimal: self andSend: #-
]

{ #category : #arithmetic }
ScaledDecimal >> / operand [ 
	"Implementation of Number 'arithmetic' method."
	#ScalDec.
	"Protocol: ANSI <number>."
	operand = 0 ifTrue: [^ (ZeroDivide dividend: self) signal].
	(operand isKindOf: ScaledDecimal) ifTrue: [^ ScaledDecimal newFromNumber: fraction / operand asFraction scale: (scale max: operand scale)].
	^ operand adaptToScaledDecimal: self andSend: #/
]

{ #category : #comparing }
ScaledDecimal >> < operand [ 
	"Implementation of Number 'comparing' method."
	(operand isKindOf: ScaledDecimal) ifTrue: [^ fraction < operand asFraction].
	^ operand adaptToScaledDecimal: self andCompare: #<
]

{ #category : #comparing }
ScaledDecimal >> <= operand [ 
	"Implementation of Number 'comparing' method."
	(operand isKindOf: ScaledDecimal) ifTrue: [^ fraction <= operand asFraction].
	^ operand adaptToScaledDecimal: self andCompare: #<=
]

{ #category : #comparing }
ScaledDecimal >> = comparand [ 
	"Implementation of Number 'comparing' method."
	comparand isNumber ifFalse: [^ false].
	(comparand isKindOf: ScaledDecimal) ifTrue: [^ fraction = comparand asFraction].
	^ comparand adaptToScaledDecimal: self andCompare: #=
]

{ #category : #comparing }
ScaledDecimal >> > operand [ 
	"Implementation of Number 'comparing' method."
	(operand isKindOf: ScaledDecimal) ifTrue: [^ fraction > operand asFraction].
	^ operand adaptToScaledDecimal: self andCompare: #>
]

{ #category : #comparing }
ScaledDecimal >> >= operand [ 
	"Implementation of Number 'comparing' method."
	(operand isKindOf: ScaledDecimal) ifTrue: [^ fraction >= operand asFraction].
	^ operand adaptToScaledDecimal: self andCompare: #>=
]

{ #category : #converting }
ScaledDecimal >> adaptToFraction: receiver andSend: arithmeticOpSelector [ 
	"Convert a Fraction to aScaledDecimal and do the arithmetic. 
	receiver arithmeticOpSelector self."
	^(receiver asScaledDecimal: scale) perform: arithmeticOpSelector with: self
]

{ #category : #converting }
ScaledDecimal >> adaptToInteger: receiver andSend: arithmeticOpSelector [ 
	"Convert receiver to a ScaledDecimal and do the arithmetic. 
	receiver arithmeticOpSelector self."
	^ (receiver asScaledDecimal: 0)
		perform: arithmeticOpSelector with: self
]

{ #category : #converting }
ScaledDecimal >> asExactFloat [
	^fraction asExactFloat
]

{ #category : #converting }
ScaledDecimal >> asFloat [
	"Reimplementation - Number 'converting' method."
	^ fraction asFloat
]

{ #category : #converting }
ScaledDecimal >> asFraction [
	"Implementation - Number 'converting' method."
	^ fraction
]

{ #category : #converting }
ScaledDecimal >> asScaledDecimal: scaleIn [ 
	"Reimplementation - Number 'converting' method."
	^ ScaledDecimal newFromNumber: fraction scale: scaleIn
]

{ #category : #converting }
ScaledDecimal >> asSpecies: number [ 
	"Convert number to a ScaledDecimal."
	#Numeric.
	"add 200/01/19 For ANSI <number>support."
	^ ScaledDecimal newFromNumber: number scale: scale
]

{ #category : #private }
ScaledDecimal >> denominator [
	"Private - Answer an Integer, the denominator part of the receiver."
	^ fraction denominator
]

{ #category : #'mathematical functions' }
ScaledDecimal >> floorLog: radix [
	"Unlike super, this version is exact when radix is integer"
	
	^self asFraction floorLog: radix
]

{ #category : #'truncation and round off' }
ScaledDecimal >> fractionPart [
	"Answer the fractional part of the receiver."
	^ ScaledDecimal newFromNumber: fraction fractionPart scale: scale
]

{ #category : #comparing }
ScaledDecimal >> hash [
	"Reimplementation of Object 'comparing' method."
	^ fraction hash
]

{ #category : #'truncation and round off' }
ScaledDecimal >> integerPart [
	"Answer the integer part of the receiver."
	^ ScaledDecimal newFromNumber: fraction integerPart scale: scale
]

{ #category : #testing }
ScaledDecimal >> isAnExactFloat [
	^fraction isAnExactFloat
]

{ #category : #testing }
ScaledDecimal >> isLiteral [
	"Answer if this number could be a well behaved literal.
	Well, it would only if evaluating back to self.
	This is not the case of all ScaledDecimals.
	Some has an infinite precision and would need an infinite number of digits to print literally.
	Try for example (3.00s2 reciprocal)."
	
	^fraction denominator = 1 "first test trivial case before engaging arithmetic"
	
		or: ["Exactly we should test:
			(fraction numerator * (10 raisedTo; scale)) \\ fraction denominator = 0.
			But since we can assume fraction is reduced already this will be simply:"
			
			(10 raisedTo: scale) \\ fraction denominator = 0]
	
	
]

{ #category : #testing }
ScaledDecimal >> isScaledDecimal [
	"Reimplementation - Number 'testing' method."
	^ true
]

{ #category : #comparing }
ScaledDecimal >> isZero [
	"Answer whether the receiver is equal to its class' zero"
	^ fraction numerator = 0
]

{ #category : #comparing }
ScaledDecimal >> literalEqual: other [
	"Testing equality is not enough.
	It is also necessary to test number of decimal places (scale).
	Otherwise we cannot compile both literals 0.5s1 and 0.50s2 in the same method"
	
	^(super literalEqual: other) and: [self scale = other scale]
]

{ #category : #'mathematical functions' }
ScaledDecimal >> ln [
	"Unlike super, avoid FLoat overflow/underflow"
	
	^self asFraction ln
]

{ #category : #'mathematical functions' }
ScaledDecimal >> log [
	"Unlike super, avoid FLoat overflow/underflow"
	
	^self asFraction log
]

{ #category : #'mathematical functions' }
ScaledDecimal >> log2 [
	"Unlike super, avoid Float overflow/underflow"
	
	^self asFraction log2
]

{ #category : #arithmetic }
ScaledDecimal >> negated [
	"Reimplementation of Number 'arithmetic' method."
	^ ScaledDecimal newFromNumber: fraction negated scale: scale
]

{ #category : #testing }
ScaledDecimal >> negative [

	^fraction negative
]

{ #category : #'mathematical functions' }
ScaledDecimal >> nthRoot: anInteger [
	"Answer the nth root of the receiver.
	Preserve receiver class and scale if answer is exact.
	Otherwise, answer a Float to denote inexactness."
	| nthRoot |
	nthRoot := self asFraction nthRoot: anInteger.
	^nthRoot isFloat
		ifTrue: [nthRoot]
		ifFalse: [nthRoot asScaledDecimal: scale]
]

{ #category : #private }
ScaledDecimal >> numerator [
	"Private - Answer an Integer, the numerator part of the receiver."
	^ fraction numerator
]

{ #category : #printing }
ScaledDecimal >> printAsLiteralOn: aStream [
	^self printOn: aStream
]

{ #category : #printing }
ScaledDecimal >> printFractionAsDecimalOn: stream [ 
	"Please note: this is different from printOn:showingDecimalPlaces: because it prints truncated."

	fraction printTruncatedOn: stream showingDecimalPlaces: scale
]

{ #category : #printing }
ScaledDecimal >> printOn: stream [

	self
		printFractionAsDecimalOn: stream;
		printScaleOn: stream
]

{ #category : #printing }
ScaledDecimal >> printOn: aStream showingDecimalPlaces: placesDesired [
	"Same as super, except the fraction knows better how to do it."

	fraction printOn: aStream showingDecimalPlaces: placesDesired
]

{ #category : #printing }
ScaledDecimal >> printScaleOn: stream [

	stream nextPut: $s.
	scale printOn: stream
]

{ #category : #printing }
ScaledDecimal >> printString [
	"Reimplementation - Number 'printing' method."
	| tempStream |
	tempStream := WriteStream on: (String new: 10).
	self printOn: tempStream.
	^ tempStream contents
]

{ #category : #'mathematical functions' }
ScaledDecimal >> raisedToFraction: aFraction [
	| result |
	result := self asFraction raisedToFraction: aFraction.
	^result isFloat
		ifTrue: [result]
		ifFalse: [result asScaledDecimal: scale]
]

{ #category : #'mathematical functions' }
ScaledDecimal >> raisedToInteger: aNumber [
	^self class newFromNumber: (fraction raisedToInteger: aNumber) scale: scale
]

{ #category : #arithmetic }
ScaledDecimal >> reciprocal [
	"Reimplementation of Number 'arithmetic' method."
	self = 0 ifTrue: [^ (ZeroDivide dividend: 1) signal].
	^ ScaledDecimal newFromNumber: fraction reciprocal scale: scale
]

{ #category : #private }
ScaledDecimal >> scale [
	"Private - Answer a integer which represents the total number of digits 
	used to represent the fraction part of the receiver, including trailing 
	zeroes. "
	^ scale
]

{ #category : #private }
ScaledDecimal >> setFraction: fractionIn scale: scaleIn [ 
	"Private - Set the fraction to fractionIn and the total number of digits 
	used to represent the fraction part of the receiver, including trailing 
	zeroes, to the Integer scaleIn."
	fraction := fractionIn.
	scale := scaleIn
]

{ #category : #'mathematical functions' }
ScaledDecimal >> sqrt [
	"Answer the square root of the receiver.
	Preserve receiver class and scale if answer is exact.
	Otherwise, answer a Float to denote inexactness."
	| squareRoot |
	squareRoot := self asFraction sqrt.
	^squareRoot isFloat
		ifTrue: [squareRoot]
		ifFalse: [squareRoot asScaledDecimal: scale]
]

{ #category : #'mathematical functions' }
ScaledDecimal >> squared [
	"Reimplementation - Number 'mathematical functions' method."
	"not used ->"
	^ ScaledDecimal newFromNumber: fraction squared scale: scale
]

{ #category : #printing }
ScaledDecimal >> storeOn: aStream [ 
	"SxaledDecimal sometimes have more digits than they print (potentially an infinity).
	In this case, do not use printOn: because it would loose some extra digits"
	
	self shouldBePrintedAsLiteral
		ifTrue: [self printOn: aStream]
		ifFalse: [aStream
			nextPut: $(;
		 	store: fraction numerator;
			nextPut: $/;
			store: fraction denominator;
			nextPut: $s;
			store: scale;
			nextPut: $)]
]

{ #category : #'truncation and round off' }
ScaledDecimal >> truncated [
	"Reimplementation of Number 'truncation and round off' method."
	^ fraction truncated
]
