"
This class tests the same things as its superclass, but for NewParagraph which is used in the Morphic environment.
"
Class {
	#name : #TestNewParagraphFix,
	#superclass : #TestParagraphFix,
	#category : #'ST80-Support-Tests'
}

{ #category : #running }
TestNewParagraphFix >> setUp [
	| morph |
	morph := TextMorph new contents: 'i i'.
	morph fit.
	para := morph paragraph
]

{ #category : #tests }
TestNewParagraphFix >> testCharacterBlockAfterReplacingAll [
	^super testCharacterBlockAfterReplacingAll
]

{ #category : #tests }
TestNewParagraphFix >> testCharacterBlockAfterReplacingOther [
	^super testCharacterBlockAfterReplacingOther
]

{ #category : #tests }
TestNewParagraphFix >> testCharacterBlockAfterReplacingSpace [
	^super testCharacterBlockAfterReplacingSpace
]

{ #category : #tests }
TestNewParagraphFix >> testCharacterBlockNormal [
	^super testCharacterBlockNormal
]
