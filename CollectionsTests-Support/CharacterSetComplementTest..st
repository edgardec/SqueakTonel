"
CharacterSetComplementTest hold unit tests for CharacterSetComplement
"
Class {
	#name : #CharacterSetComplementTest,
	#superclass : #ClassTestCase,
	#category : #'CollectionsTests-Support'
}

{ #category : #tests }
CharacterSetComplementTest >> testIncludes [
	| set complement |
	set := 'abc' as: CharacterSet.
	complement := set complement.
	self assert: (set noneSatisfy: [:e | complement includes: e]).
	self assert: (($d to: $z) allSatisfy: [:e | complement includes: e]).
]

{ #category : #tests }
CharacterSetComplementTest >> testPrintString [
	|s|
	s := CharacterSet separators complement printString.
	self assert: (s includesSubstring: 'complement') description: 'Doesn''t describe its fundamental characteristic'.
	self assert: (s includesSubstring: 'Character space') description: 'Doesn''t mention an important separator'.
]

{ #category : #tests }
CharacterSetComplementTest >> testReject [
	| set complement subset |
	set := 'abc' as: CharacterSet.
	complement := set complement.
	subset := complement reject: [:c | c isVowel].
	self assert: (subset includes: $z). "Not a vowel, it is in the subset"
	self deny: (subset includes: $e). "a vowel should be rejected"
	self deny: (subset includes: $b). "Not a vowel, but not in the original set"
]

{ #category : #tests }
CharacterSetComplementTest >> testSelect [
	| set complement digits |
	set := 'abc012' as: CharacterSet.
	complement := set complement.
	digits := complement select: [:c | c isDigit].
	self assert: (digits includes: $9).
	self deny: (digits includes: $1).
	self deny: (digits includes: $z).
]
