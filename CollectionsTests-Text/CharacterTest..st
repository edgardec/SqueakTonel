"
This is the unit test for the class Character. Unit tests are a good way to exercise the functionality of your system in a repeatable and automatic manner. They are therefore recommended if you plan to release anything. For more information, see: 
	- http://www.c2.com/cgi/wiki?UnitTest
	- http://minnow.cc.gatech.edu/squeak/1547
	- the sunit class category
"
Class {
	#name : #CharacterTest,
	#superclass : #ClassTestCase,
	#category : #'CollectionsTests-Text'
}

{ #category : #'tests - various' }
CharacterTest >> testCharacterSeparators [
	"Regression test"

	| result |
	result := '/', Character separators.
	self assert: result size = (Character separators size + 1).

	result := '/', CharacterSet separators.
	self assert: result size = (CharacterSet separators asArray size + 1).

]

{ #category : #'tests - creation' }
CharacterTest >> testCodePoint [
	self assert: (Character codePoint: $A asciiValue) = $A.
	self assert: (Character codePoint: 500) asciiValue = 500.
]

{ #category : #'tests - creation' }
CharacterTest >> testDigitValue [
	"Answer the Character whose digit value is x. For example,
	 answer $9 for x=9, $0 for x=0, $A for x=10, $Z for x=35.
	Results outside this range are undefined."

	self assert: $0 = (Character digitValue: 0).
	self assert: $1 = (Character digitValue: 1).
	self assert: $9 = (Character digitValue: 9).
	self assert: $A = (Character digitValue: 10).
	self assert: $B = (Character digitValue: 11).
	self assert: $F = (Character digitValue: 15).
	self assert: $G = (Character digitValue: 16).
	self assert: $P = (Character digitValue: 25).
	self assert: $Z = (Character digitValue: 35).


]

{ #category : #'tests - Class Methods' }
CharacterTest >> testNew [

	self should: [Character new] raise: Error.
]

{ #category : #'tests - printing' }
CharacterTest >> testPrintString [
	self assert: $a printString = '$a'.
	self assert: $5 printString = '$5'.
	self assert: $@ printString = '$@'.

	self assert: Character cr printString = 'Character cr'.
	self assert: Character lf printString = 'Character lf'.
	self assert: Character space printString = 'Character space'.

	self assert: Character null printString = 'Character null'.
	self assert: (Character value: 17) printString = 'Character value: 17'.
]

{ #category : #'tests - printing' }
CharacterTest >> testPrintStringAll [
	Character allByteCharacters do: [ :each |
		self assert: (self class newCompiler 
			evaluate: each printString) = each ].
]

{ #category : #'tests - printing' }
CharacterTest >> testStoreString [
	self assert: $a storeString = '$a'.
	self assert: $5 storeString = '$5'.
	self assert: $@ storeString = '$@'.

	self assert: Character cr storeString = 'Character cr'.
	self assert: Character lf storeString = 'Character lf'.
	self assert: Character space storeString = 'Character space'.

	self assert: Character null storeString = 'Character null'.
	self assert: (Character value: 17) storeString = '(Character value: 17)'.
]

{ #category : #'tests - printing' }
CharacterTest >> testStoreStringAll [
	Character allByteCharacters do: [ :each |
		self assert: (self class newCompiler 
			evaluate: each storeString) = each ].
]
