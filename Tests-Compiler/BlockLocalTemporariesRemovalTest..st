"
I test if the parser can remove unused temporaries properly from methods and blocks. I implement several methods to be able to act like a TextEditor.
"
Class {
	#name : #BlockLocalTemporariesRemovalTest,
	#superclass : #TestCase,
	#instVars : [
		'sourceCode'
	],
	#category : #'Tests-Compiler'
}

{ #category : #'test helper' }
BlockLocalTemporariesRemovalTest >> assert: someCode isChangedDuringParsingTo: someOtherCode withRemovalOfTemporariesNamed: someTempNames [ 
	| failBlock |
	self sourceCode: someCode.
	failBlock := [ self fail ].
	[ self class
		compile: self sourceCode
		notifying: self
		trailer: CompiledMethodTrailer empty
		ifFail: failBlock ]
			on: UnusedVariable
			do:
				[ : aNotification | [ aNotification openMenuIn: nil ] 
					valueSupplyingAnswers: (someTempNames 
						collect: [:tempName | {tempName . true}]) , {{'*' . false }} ].
	self assert: self sourceCode = someOtherCode
]

{ #category : #requesting }
BlockLocalTemporariesRemovalTest >> correctFrom: start to: stop with: aString [
	
	| loc |
	aString = '#insert period' ifTrue:
		[loc := start.
		[(loc := loc-1)>0 and: [(self sourceCode at: loc) isSeparator]]
			whileTrue: [loc := loc-1].
		^ self correctFrom: loc+1 to: loc with: '.'].
	
	self sourceCode: (self sourceCode copyReplaceFrom: start to: stop with: aString)
]

{ #category : #requesting }
BlockLocalTemporariesRemovalTest >> deselect [
]

{ #category : #examples }
BlockLocalTemporariesRemovalTest >> methodWithBlockVariable [

	| foo |
	[ | bar | ] value
]

{ #category : #requesting }
BlockLocalTemporariesRemovalTest >> nextTokenFrom: start direction: dir [
	"simple token-finder for compiler automated corrections"
	| loc |
	loc := start + dir.
	[(loc between: 1 and: self sourceCode size) and: [(self sourceCode at: loc) isSeparator]]
		whileTrue: [loc := loc + dir].
	^ loc
]

{ #category : #requesting }
BlockLocalTemporariesRemovalTest >> select [
]

{ #category : #requesting }
BlockLocalTemporariesRemovalTest >> selectFrom: aPoisition to: anotherPosition [
]

{ #category : #requesting }
BlockLocalTemporariesRemovalTest >> selectInvisiblyFrom: userSelection to: last [
]

{ #category : #requesting }
BlockLocalTemporariesRemovalTest >> selectionInterval [

	^ Interval from: 0 to: 0
]

{ #category : #accessing }
BlockLocalTemporariesRemovalTest >> sourceCode [
	^ sourceCode
]

{ #category : #accessing }
BlockLocalTemporariesRemovalTest >> sourceCode: anObject [
	sourceCode := anObject
]

{ #category : #tests }
BlockLocalTemporariesRemovalTest >> testBlockTemporaries [

	| someCode someOtherCode |
	
	someCode := 'test
	| temp |
	[ | foo | ]'.
	someOtherCode := 'test
	| temp |
	[  ]'.
	self assert: someCode isChangedDuringParsingTo: someOtherCode withRemovalOfTemporariesNamed: #('foo').
	
	someCode := 'test
	[ | foo | ]'.
	someOtherCode := 'test
	[  ]'.
	self assert: someCode isChangedDuringParsingTo: someOtherCode withRemovalOfTemporariesNamed: #('foo').
	
	someCode := 'test
	| temp |
	[ | foo | ]'.
	someOtherCode := 'test
	[  ]'.
	self assert: someCode isChangedDuringParsingTo: someOtherCode withRemovalOfTemporariesNamed: #('foo' 'temp').
]

{ #category : #tests }
BlockLocalTemporariesRemovalTest >> testComplex [

	| someCode someOtherCode |
	
	someCode := 'removeUnusedTemps: methodNode
	"Scan for unused temp names, and prompt the user about the prospect of removing each one found"

	| madeChanges tempsMarkHolder unusedTempNames tempMarkHoldersToChange encoder requestor|
	encoder := requestor := 1.
	madeChanges := false.
	tempMarkHoldersToChange := OrderedCollection new.
	tempsMarkHolder := self collectTemporaryDeclarationsFrom: methodNode.
	unusedTempNames := encoder unusedTempNames select: 
		[ :temp | (encoder lookupVariable: temp ifAbsent: [ ]) isUndefTemp 
				and: [ UnusedVariable name: temp ]].
	tempsMarkHolder do: [ :currentBlock | ||
		tempMarkHoldersToChange add: currentBlock.
		unusedTempNames do: 
			[ :temp || someAdditionalTemps |
			(self 
				removeUnusedTemporaryNamed: temp 
				from: requestor text asString 
				lookingAt: currentBlock
				movingTempMarksOf: tempMarkHoldersToChange) ifTrue: [ madeChanges := true ]]].
	madeChanges
		ifTrue: [ self removeEmptyTempDeclarationsFrom: methodNode.
			ReparseAfterSourceEditing signal ]'.
	someOtherCode := 'removeUnusedTemps: methodNode
	"Scan for unused temp names, and prompt the user about the prospect of removing each one found"

	| madeChanges tempsMarkHolder unusedTempNames tempMarkHoldersToChange encoder requestor|
	encoder := requestor := 1.
	madeChanges := false.
	tempMarkHoldersToChange := OrderedCollection new.
	tempsMarkHolder := self collectTemporaryDeclarationsFrom: methodNode.
	unusedTempNames := encoder unusedTempNames select: 
		[ :temp | (encoder lookupVariable: temp ifAbsent: [ ]) isUndefTemp 
				and: [ UnusedVariable name: temp ]].
	tempsMarkHolder do: [ :currentBlock | 
		tempMarkHoldersToChange add: currentBlock.
		unusedTempNames do: 
			[ :temp |
			(self 
				removeUnusedTemporaryNamed: temp 
				from: requestor text asString 
				lookingAt: currentBlock
				movingTempMarksOf: tempMarkHoldersToChange) ifTrue: [ madeChanges := true ]]].
	madeChanges
		ifTrue: [ self removeEmptyTempDeclarationsFrom: methodNode.
			ReparseAfterSourceEditing signal ]'.
	self assert: someCode isChangedDuringParsingTo: someOtherCode withRemovalOfTemporariesNamed: #('someAdditionalTemps')
]

{ #category : #tests }
BlockLocalTemporariesRemovalTest >> testRegression [

	| someCode someOtherCode |
	
	someCode := 'test
	| temp |'.
	someOtherCode := 'test
	'.
	self assert: someCode isChangedDuringParsingTo: someOtherCode withRemovalOfTemporariesNamed: #('temp').
	
	someCode :=  'test
	| temp |'.
	someOtherCode := 'test
	| temp |'.
	self assert: someCode isChangedDuringParsingTo: someOtherCode withRemovalOfTemporariesNamed: #().
	
	someCode :=  'test
	| temp temptemp |'.
	someOtherCode := 'test
	| temp |'.
	self assert: someCode isChangedDuringParsingTo: someOtherCode withRemovalOfTemporariesNamed: #('temptemp').
	
]

{ #category : #requesting }
BlockLocalTemporariesRemovalTest >> text [

	^ self sourceCode
]
