"
I am a TestCase for PasteUpMorph.
"
Class {
	#name : #PasteUpMorphTest,
	#superclass : #ClassTestCase,
	#category : #'MorphicTests-Worlds'
}

{ #category : #tests }
PasteUpMorphTest >> testCursorWrapped [
	"self debug: #testCursorWrapped"
	| holder |
	holder := PasteUpMorph new.
	self assert: holder cursor = 1.
	holder cursorWrapped: 2.
	self assert: holder cursor = 1.
	holder addMorph: Morph new;
		 addMorph: Morph new;
		 addMorph: Morph new.
	holder cursorWrapped: 3.
	self assert: holder cursor = 3.
	holder cursorWrapped: 5.
	self assert: holder cursor = 2.
	holder cursorWrapped: 0.
	self assert: holder cursor = 3.
	holder cursorWrapped: -1.
	self assert: holder cursor = 2.
]

{ #category : #tests }
PasteUpMorphTest >> testCursorWrappedWithFraction [
	"self debug: #testCursorWrappedWithFraction"
	| holder |
	holder := PasteUpMorph new.
	holder addMorph: Morph new;
		 addMorph: Morph new;
		 addMorph: Morph new.
	holder cursorWrapped: 3.5.
	self assert: holder cursor = 3.5.
	holder cursorWrapped: 5.5.
	self assert: holder cursor = 2.5.
	holder cursorWrapped: 0.5.
	self assert: holder cursor = 3.5.
	holder cursorWrapped: -0.5.
	self assert: holder cursor = 2.5.
]

{ #category : #tests }
PasteUpMorphTest >> testGridToGradient [
	"A trivial test for checking that you can change from a grid to a  
	gradient background. A recent [FIX] will make this pass."
	| pum |
	pum := PasteUpMorph new.
	pum setStandardTexture.
	"The following should fail without the fix"
	self
		shouldnt: [pum gradientFillColor: Color red]
		raise: MessageNotUnderstood
]

{ #category : #tests }
PasteUpMorphTest >> testPlayWithMe1Romoval [
	"A trivial test for checking that PlayWithMe classes are all removed"
	self deny: ( Smalltalk hasClassNamed: 'PlayWithMe1' ) .
]
