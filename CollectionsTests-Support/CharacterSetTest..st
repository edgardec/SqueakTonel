"
CharacterSetTest holds tests for CharacterSet
"
Class {
	#name : #CharacterSetTest,
	#superclass : #TestCase,
	#category : #'CollectionsTests-Support'
}

{ #category : #tests }
CharacterSetTest >> testComplement [
	| set complement |
	set := 'abc' as: CharacterSet.
	complement := set complement.
	self assert: (set noneSatisfy: [:e | complement includes: e]).
	self assert: (($d to: $z) allSatisfy: [:e | complement includes: e]).
]

{ #category : #tests }
CharacterSetTest >> testCopy [
    | theOriginal theCopy |
    theOriginal := CharacterSet newFrom: 'abc'.
    theCopy := theOriginal copy.
    theCopy remove: $a.
    ^self assert: (theOriginal includes: $a) description: 'Changing the copy should not change the original'.
]

{ #category : #tests }
CharacterSetTest >> testIncludes [
	| set |
	set := 'abc' as: CharacterSet.
	self assert: (($a to: $c) allSatisfy: [:e | set includes: e]).
	self assert: (($d to: $z) noneSatisfy: [:e | set includes: e]).
]

{ #category : #tests }
CharacterSetTest >> testIntersection [
	| intersection |
	intersection := ('abc' as: CharacterSet) intersection: ('bcde' as: CharacterSet).
	self assert: intersection = ('bc' as: CharacterSet)
]

{ #category : #tests }
CharacterSetTest >> testIntersectionOfComplement [
	| intersection |
	intersection := ('abcd' as: CharacterSet) complement intersection: ('cdef' as: CharacterSet) complement.
	self assert: intersection = ('abcdef' as: CharacterSet) complement.
]

{ #category : #tests }
CharacterSetTest >> testIntersectionOfLazy [
	| digits intersection1 intersection2 az lazyNonDigitNonSeparator lazyNotazNotUppercase |
	digits := ($0 to: $9) as: CharacterSet.
	az := ($a to: $z) as: CharacterSet.
	lazyNonDigitNonSeparator := digits complement reject: #isSeparator.
	lazyNotazNotUppercase := az complement reject: #isUppercase.
	intersection1 := lazyNotazNotUppercase intersection: lazyNonDigitNonSeparator.
	intersection2 := lazyNonDigitNonSeparator intersection: lazyNotazNotUppercase.
	self assert: (digits noneSatisfy: [:d | intersection1 includes: d]).
	self assert: (digits noneSatisfy: [:d | intersection2 includes: d]).
	self assert: ('abc' noneSatisfy: [:d | intersection1 includes: d]).
	self assert: ('abc' noneSatisfy: [:d | intersection2 includes: d]).
	self assert: ('ABC' noneSatisfy: [:d | intersection1 includes: d]).
	self assert: ('ABC' noneSatisfy: [:d | intersection2 includes: d]).
	self assert: (Character separators noneSatisfy: [:d | intersection1 includes: d]).
	self assert: (Character separators noneSatisfy: [:d | intersection2 includes: d]).
	self assert: ('()[]{}' allSatisfy: [:d | intersection1 includes: d]).
	self assert: ('()[]{}' allSatisfy: [:d | intersection2 includes: d]).
]

{ #category : #tests }
CharacterSetTest >> testIntersectionOfNonLazyWithLazyIsNotLazy [
	| nonDigit az lazyLetters |
	nonDigit := (($0 to: $9) as: CharacterSet) complement.
	lazyLetters := nonDigit select: #isLetter.
	az := ($a to: $z) asCharacterSet.
	self assert: (az intersection: lazyLetters) equals: az.
	self assert: (lazyLetters intersection: az) equals: az.
]

{ #category : #tests }
CharacterSetTest >> testIntersectionWithComplement [
	| intersection intersection2 |
	intersection := ('abcd' as: CharacterSet) intersection: ('cdef' as: CharacterSet) complement.
	self assert: intersection = ('ab' as: CharacterSet).
	intersection2 := ('cdef' as: CharacterSet) complement intersection: ('abcd' as: CharacterSet).
	self assert: intersection2 = intersection. "Intersection is symmetric"
]

{ #category : #tests }
CharacterSetTest >> testUnion [
	| union |
	union := ('abc' as: CharacterSet) union: ('bcde' as: CharacterSet).
	self assert: union = ('abcde' as: CharacterSet)
]

{ #category : #tests }
CharacterSetTest >> testUnionOfComplement [
	| union |
	union := ('abcd' as: CharacterSet) complement union: ('cdef' as: CharacterSet) complement.
	self assert: union = ('cd' as: CharacterSet) complement.
]

{ #category : #tests }
CharacterSetTest >> testUnionOfLazy [
	| digits nonDigit lazyLetters lazyNonLetters union1 union2 |
	digits := ($0 to: $9) as: CharacterSet.
	nonDigit := digits complement.
	lazyLetters := nonDigit select: #isLetter.
	lazyNonLetters := nonDigit reject: #isLetter.
	union1 := lazyNonLetters union: lazyLetters.
	union2 := lazyLetters union: lazyNonLetters.
	self assert: (digits noneSatisfy: [:d | union1 includes: d]).
	self assert: (digits noneSatisfy: [:d | union2 includes: d]).
	self assert: ('abc' allSatisfy: [:d | union1 includes: d]).
	self assert: ('abc' allSatisfy: [:d | union2 includes: d]).
	self assert: ('()[]{}' allSatisfy: [:d | union1 includes: d]).
	self assert: ('()[]{}' allSatisfy: [:d | union2 includes: d]).
]

{ #category : #tests }
CharacterSetTest >> testUnionWithComplement [
	| union union2 |
	union := ('abc' as: CharacterSet) union: ('bcde' as: CharacterSet) complement.
	self assert: union = ('de' as: CharacterSet) complement.
	union2 := ('bcde' as: CharacterSet) complement union: ('abc' as: CharacterSet).
	self assert: union2 = union. "union is symmetric"
]

{ #category : #tests }
CharacterSetTest >> testUnionWithLazy [
	| digits nonDigit lazyLetters az union1 union2 |
	digits := ($0 to: $9) as: CharacterSet.
	nonDigit := digits complement.
	lazyLetters := nonDigit select: #isLetter.
	union1 := digits union: lazyLetters.
	union2 := lazyLetters union: digits.
	az := ($a to: $z) as: CharacterSet.
	self assert: (digits allSatisfy: [:d | union1 includes: d]).
	self assert: (digits allSatisfy: [:d | union2 includes: d]).
	self assert: (az allSatisfy: [:d | union1 includes: d]).
	self assert: (az allSatisfy: [:d | union2 includes: d]).
	self assert: ('()[]{}' noneSatisfy: [:d | union1 includes: d]).
	self assert: ('()[]{}' noneSatisfy: [:d | union2 includes: d]).
]
