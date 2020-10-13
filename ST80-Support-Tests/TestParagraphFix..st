"
This class tests whether locating characters past the end of a text is possible in all cases.
"
Class {
	#name : #TestParagraphFix,
	#superclass : #TestCase,
	#instVars : [
		'para'
	],
	#category : #'ST80-Support-Tests'
}

{ #category : #running }
TestParagraphFix >> setUp [
	para := 'i i' asParagraph
]

{ #category : #tests }
TestParagraphFix >> testCharacterBlockAfterReplacingAll [
	para replaceFrom: 1 to: 3 with: 'mmm' displaying: false.
	self assert: (para characterBlockForIndex: 4) stringIndex = 4
]

{ #category : #tests }
TestParagraphFix >> testCharacterBlockAfterReplacingOther [
	para replaceFrom: 3 to: 3 with: 'm' displaying: false.
	self assert: (para characterBlockForIndex: 4) stringIndex = 4
]

{ #category : #tests }
TestParagraphFix >> testCharacterBlockAfterReplacingSpace [
	para replaceFrom: 3 to: 3 with: ' ' displaying: false.
	self assert: (para characterBlockForIndex: 4) stringIndex = 4
]

{ #category : #tests }
TestParagraphFix >> testCharacterBlockNormal [
	self assert: (para characterBlockForIndex: 4) stringIndex = 4
]
