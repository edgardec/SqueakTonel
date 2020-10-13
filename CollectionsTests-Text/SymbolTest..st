"
This is the unit test for the class Symbol. Unit tests are a good way to exercise the functionality of your system in a repeatable and automatic manner. They are therefore recommended if you plan to release anything. For more information, see: 
	- http://www.c2.com/cgi/wiki?UnitTest
	- http://minnow.cc.gatech.edu/squeak/1547
	- the sunit class category
"
Class {
	#name : #SymbolTest,
	#superclass : #ClassTestCase,
	#category : #'CollectionsTests-Text'
}

{ #category : #tests }
SymbolTest >> testCapitalized [

	| uc lc |		
	uc := #MElViN.
	lc := #mElViN.
	self assert:  lc capitalized = uc.
	self assert: uc capitalized = uc.

]

{ #category : #'tests - testing' }
SymbolTest >> testIsBinaryReturnsFalseForKeywordSelectors [
	self deny: #do: isBinary.
	self deny: #ifTrue:ifFalse: isBinary.
	self deny: #with:with:with:with: isBinary.
]

{ #category : #'tests - testing' }
SymbolTest >> testIsBinaryReturnsFalseForUnarySelectors [
	self deny: #timesRepeat isBinary.
	self deny: #once isBinary.
	self deny: #isBinary isBinary.
]

{ #category : #'tests - testing' }
SymbolTest >> testIsBinaryReturnsTrueForOperatorLikeSymbols [
	self assert: #+ isBinary.
	self assert: #>>= isBinary.
	self assert: #| isBinary.
]

{ #category : #tests }
SymbolTest >> testNumArgs2 [
    "TODO: need to be extended to support shrinking and for selectors like #+ " 
	
	self assert: (#test numArgs: 0) = #test.
	self assert: (#test numArgs: 1) = #test:.
	self assert: (#test numArgs: 2) = #test:with:.
	self assert: (#test numArgs: 3) = #test:with:with:.
	

	self assert: (#test: numArgs: 0) = #test:.
	self assert: (#test: numArgs: 1) = #test:.
	self assert: (#test: numArgs: 2) = #test:with:.
	self assert: (#test: numArgs: 3) = #test:with:with:.
	
	self assert: (#test:with: numArgs: 0) = #test:with:.
	self assert: (#test:with: numArgs: 1) = #test:with:.
	self assert: (#test:with: numArgs: 2) = #test:with:.
	self assert: (#test:with: numArgs: 3) = #test:with:with:.
	self assert: (#test:with: numArgs: 4) = #test:with:with:with:.
	
	self assert: (#test:with:with: numArgs: 0) = #test:with:with:.
	self assert: (#test:with:with: numArgs: 1) = #test:with:with:.
	self assert: (#test:with:with: numArgs: 2) = #test:with:with:.
	self assert: (#test:with:with: numArgs: 3) = #test:with:with:.
	self assert: (#test:with:with: numArgs: 4) = #test:with:with:with:.
]

{ #category : #tests }
SymbolTest >> testWithFirstCharacterDownshifted [

	| uc lc empty |		
	uc := #MElViN.
	lc := #mElViN.
	empty := #' '.
	self assert:  uc withFirstCharacterDownshifted = lc.
	self assert: lc withFirstCharacterDownshifted = lc.
	

]
