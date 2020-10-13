Class {
	#name : #SyntaxTestMethods,
	#superclass : #PasteUpMorph,
	#instVars : [
		'letterActors',
		'wild',
		'leftMargin',
		'rightMargin',
		'switch',
		'current',
		'jumpSwitch',
		'hotIndex'
	],
	#classVars : [
		'Goal'
	],
	#category : #'Etoys-Squeakland-Etoys-Tile Scriptors'
}

{ #category : #'as yet unclassified' }
SyntaxTestMethods >> altStyleTester [

	self doFirstThatWorks
		if: [self = 1] do: [self + 1];
		if: [self = 2] do: [self + 2];
		if: [self = 3] do: [self + 3];
		if: [self = 4] do: [self + 4];
		if: [true] do: [self + 5]
	
	
]

{ #category : #'as yet unclassified' }
SyntaxTestMethods >> bobsplace2: letter after: before newLine: isNewLine [ 
	"Position this letter. Put its left edge where the previous letter's right edge is. Move down to the next line if isNewLine is true. Add some 	leading for condensed or expanded text."

	(self doFirstThatWorks)
		if: [before isNil]
			do: [self selfWrittenAsIll march: letter to: leftMargin topRight];
		if: [isNewLine]
			do: 
				[self selfWrittenAsIll march: letter
					to: leftMargin right @ (before bottom + 1)];
		if: [true] do: [self selfWrittenAsIll march: letter to: before topRight]
]

{ #category : #'as yet unclassified' }
SyntaxTestMethods >> bobsplace: letter after: before newLine: isNewLine [ 
	"Position this letter. Put its left edge where the previous letter's right 	edge is. Move down to the next line if isNewLine is true. Add some 	leading for condensed or expanded text."

	before isNil
		ifTrue: [self selfWrittenAsIll march: letter to: leftMargin topRight]
		ifFalse: 
			[isNewLine 
				ifTrue: 
					[self selfWrittenAsIll march: letter
						to: leftMargin right @ (before bottom + 1)]
				ifFalse: [self selfWrittenAsIll march: letter to: before topRight]].
	^self
]

{ #category : #'as yet unclassified' }
SyntaxTestMethods >> doAndCollect [

	self do: [ :j | j isEmpty ifFalse: [j size]].
	self collect: [ :each | each asString withBlanksTrimmed].
	
]

{ #category : #'as yet unclassified' }
SyntaxTestMethods >> makeRandomString [

	| newString foo |

	newString := String new: Goal contents size.
	foo := Goal contents size.
	^newString collect: [ :oldLetter | 'abcdefghijklmnopqrstuvwxyz' atRandom]

]

{ #category : #'as yet unclassified' }
SyntaxTestMethods >> repeatExample [

	self
		repeatFor: (1 to: 50)
		doing: [ :i | i + 3]
]

{ #category : #'as yet unclassified' }
SyntaxTestMethods >> st76LeftArrowTest: foo [

	foo contentsGetz: foo contents asUppercase
	
	
]

{ #category : #'as yet unclassified' }
SyntaxTestMethods >> wordyTestMethod [

	self selfWrittenAsMe = 1 ifTrue: [
		self selfWrittenAsMy size.
		self selfWrittenAsIll stop.
		self selfWrittenAsIm large.
		self selfWrittenAsThis helps.
	].

]
