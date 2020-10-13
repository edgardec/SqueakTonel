"
Rather than testing a single class, this set of tests looks at the interactions between Character, String, Integer and Color using hex and printStringHex
"
Class {
	#name : #HexTest,
	#superclass : #TestCase,
	#category : #'Tests-Hex'
}

{ #category : #tests }
HexTest >> testCharacterHex [
| result |
result := $a hex.
self assert: result = '61'.
result := $A hex.
self assert: result = '41'.



]

{ #category : #tests }
HexTest >> testColorPrintHtmlString [
self assert: (Color red printHtmlString ) = ( Color red asHTMLColor allButFirst asUppercase).


]

{ #category : #tests }
HexTest >> testIntegerHex [
	| result |
	result := 15 asInteger hex.
	self assert: result = '16rF'.
	result := 0 asInteger hex.
	self assert: result = '16r0'.
	result := 255 asInteger hex.
	self assert: result = '16rFF'.
	result := 90 asInteger hex.
	self assert: result = '16r5A'
]

{ #category : #tests }
HexTest >> testStringAsHex [
| result |
result := 'abc' asHex.
self assert: result = '616263'.



]
