Class {
	#name : #CompilerExceptionsTest,
	#superclass : #TestCase,
	#instVars : [
		'text',
		'selectionInterval',
		'originalText',
		'previousSelection',
		'originalSelection',
		'tearDowns'
	],
	#category : #'Tests-Compiler'
}

{ #category : #assertions }
CompilerExceptionsTest >> assertCanceled [

	self
		assertText: originalText;
		assertSelection: previousSelection.
]

{ #category : #assertions }
CompilerExceptionsTest >> assertSelection: selectionMatch [

	selectionMatch isBlock ifTrue: [
		^ self assertSelection: selectionMatch value].
	^ self
		assert: selectionMatch
		equals: (selectionMatch isInterval
			ifTrue: [self selectionInterval]
			ifFalse: [self selection])
]

{ #category : #assertions }
CompilerExceptionsTest >> assertSucceeded [

	^ self assertSucceeded: originalText
]

{ #category : #assertions }
CompilerExceptionsTest >> assertSucceeded: textMatch [

	self
		assertText: textMatch;
		assertSelection: originalSelection.
]

{ #category : #assertions }
CompilerExceptionsTest >> assertText: textMatch [

	text isBlock ifTrue: [
		^ self assertText: text value].
	^ (textMatch respondsTo: #matches:)
		ifTrue: [
			self assert: [textMatch matches: text]]
		ifFalse: [
			self assert: textMatch equals: text]
]

{ #category : #private }
CompilerExceptionsTest >> compile: sourceString [

	| result |
	originalText := text := sourceString.
	previousSelection := originalSelection := 1 to: text size + 1.
	selectionInterval := nil.
	result := self class
		compileSilently: text
		classified: 'generated'
		notifying: self.
	result ifNil: [^ self].
	selectionInterval := originalSelection.
]

{ #category : #private }
CompilerExceptionsTest >> compiling: sourceCode shouldRaise: exceptionClass andSelect: selectionMatch testing: tests [

	| referenceTest |
	referenceTest := [] -> [].
	(tests copyWithFirst: referenceTest) associationsDo: [:test |
		self
			should: [self compile: sourceCode]
			raise: exceptionClass
			thenDo: [:exception |
				self assertSelection: selectionMatch.
				previousSelection := self selectionInterval.
				(self handlerBlockFor: test key) cull: exception].
		(self testBlockFor: test value) value].
]

{ #category : #emulating }
CompilerExceptionsTest >> correctFrom: start to: stop with: aString [

	| delta userSelection |
	userSelection := self selectionInterval.
	text := (text first: start - 1) , aString , (text allButFirst: stop).
	delta := aString size - (stop - start + 1).
	self
		selectInvisiblyFrom: userSelection first + (userSelection first > start ifFalse: [ 0 ] ifTrue: [ delta ])
		to: userSelection last + (userSelection last > start ifFalse: [ 0 ] ifTrue: [ delta ]).
]

{ #category : #private }
CompilerExceptionsTest >> handlerBlockFor: message [

	^ message isBlock
		ifTrue: [message]
		ifFalse: [[:ex | [ex pass] valueSupplyingAnswer: message]]
]

{ #category : #emulating }
CompilerExceptionsTest >> nextTokenFrom: start direction: dir [
	"simple token-finder for compiler automated corrections"
	| loc str |
	loc := start + dir.
	str := self text.
	[(loc between: 1 and: str size) and: [(str at: loc) isSeparator]]
		whileTrue: [loc := loc + dir].
	^ loc
]

{ #category : #private }
CompilerExceptionsTest >> removeGeneratedMethods [

	self class removeCategory: 'generated'
]

{ #category : #emulating }
CompilerExceptionsTest >> selectFrom: start to: end [ 

	selectionInterval := start to: end.
]

{ #category : #emulating }
CompilerExceptionsTest >> selectIntervalInvisibly: anInterval [

	selectionInterval := anInterval
]

{ #category : #emulating }
CompilerExceptionsTest >> selectInvisiblyFrom: start to: end [ 

	^ self
		selectFrom: start to: end
]

{ #category : #private }
CompilerExceptionsTest >> selection [

	^ text copyFrom: self selectionInterval start to: self selectionInterval stop
]

{ #category : #emulating }
CompilerExceptionsTest >> selectionInterval [

	^ selectionInterval ifNil: [1 to: self text size]
]

{ #category : #running }
CompilerExceptionsTest >> setUp [

	super setUp.
	tearDowns := OrderedCollection new.
	Symbol hasInterned: self unknownSelector ifTrue: [:symbol |
		tearDowns add: [Symbol intern: symbol]].
	Symbol extern: self unknownSelector.
]

{ #category : #assertions }
CompilerExceptionsTest >> should: aBlock raise: anExceptionalEvent thenDo: aHandlerBlock [

	| raised result |
	raised := false.
	result := aBlock
		on: anExceptionalEvent
		do: [:ex |
			raised := true.
			aHandlerBlock cull: ex].
	self assert: raised description: ('aBlock should have raised {1}' translated format: {anExceptionalEvent}).
	^ result
]

{ #category : #running }
CompilerExceptionsTest >> tearDown [

	self removeGeneratedMethods.
	Symbol extern: self unknownSelector.
	tearDowns do: #value.
	super tearDown.
]

{ #category : #tests }
CompilerExceptionsTest >> testAmbiguousSelector [ 

	self
		compiling: 'griffle ^1--1'
		shouldRaise: AmbiguousSelector
		andSelect: '--'
		testing: {
			[:ex | ex resume] -> [self assertCanceled].
			[:ex | ex resume: '-- '] -> 'griffle ^1-- 1' }.
	self
		compiling: 'griffle ^1@-1'
		shouldRaise: AmbiguousSelector
		andSelect: '@-'
		testing: {
			[:ex | ex resume] -> [self assertCanceled].
			[:ex | ex resume: '@ -'] -> 'griffle ^1@ -1' }.
	self
		compiling: 'griffle ^1+-1'
		shouldRaise: AmbiguousSelector
		andSelect: '+-'
		testing: {
			[:ex | ex resume] -> [self assertCanceled].
			[:ex | ex resume: '+- '] -> ['griffle ^1+- 1'] }.
]

{ #category : #private }
CompilerExceptionsTest >> testBlockFor: test [

	^ test isBlock
		ifTrue: [test]
		ifFalse: [[self assertSucceeded: test]]
]

{ #category : #tests }
CompilerExceptionsTest >> testUndeclaredVariable [

	self 
		compiling: 'griffle ^ goo'
		shouldRaise: UndeclaredVariable
		andSelect: 'goo'
		testing: {
			false -> [self assertCanceled] }.
	self
		compiling: 'griffle ^ [ goo ] value'
		shouldRaise: UndeclaredVariable
		andSelect: 'goo'
		testing: {
			false -> [self assertCanceled] }.
	self 
		compiling: 'griffle goo := 42'
		shouldRaise: UndeclaredVariable
		andSelect: 'goo'
		testing: {
			false -> [self assertCanceled].
			'declare method temp' -> 'griffle | goo |\goo := 42' withCRs }.
	self
		compiling: 'griffle ^ [ goo := 42 ] value'
		shouldRaise: UndeclaredVariable
		andSelect: 'goo'
		testing: {
			false -> [self assertCanceled].
			'declare method temp' -> 'griffle | goo |\^ [ goo := 42 ] value' withCRs.
			'declare block-local temp' -> 'griffle ^ [ | goo | goo := 42 ] value' withCRs }.
]

{ #category : #tests }
CompilerExceptionsTest >> testUndefinedVariable [

	self 
		compiling: 'griffle | goo | ^ goo'
		shouldRaise: UndefinedVariable
		andSelect: [(text allRangesOfRegexMatches: '(?<=\^ )goo') first]
		testing: {
			true -> [self assertSucceeded].
			false -> [self assertCanceled] }.
	self
		compiling: 'griffle [ | goo | ^ goo ] value'
		shouldRaise: UndefinedVariable
		andSelect: [(text allRangesOfRegexMatches: '(?<=\^ )goo') first]
		testing: {
			true -> [self assertSucceeded].
			false -> [self assertCanceled] }.
]

{ #category : #tests }
CompilerExceptionsTest >> testUnknownSelector [

	self 
		compiling: 'griffle self ' , self unknownSelector
		shouldRaise: UnknownSelector
		andSelect: self unknownSelector
		testing: {
			false -> [self assertCanceled].
			'yourself' -> [self assertSucceeded: 'griffle self yourself'].
			self unknownSelector -> [
				self assertSucceeded.
				self assert: (Symbol hasInterned: self unknownSelector ifTrue: [:symbol |]).
				Symbol extern: self unknownSelector] }.
	self
		compiling: 'griffle [ self ' , self unknownSelector , ' ] value'
		shouldRaise: UnknownSelector
		andSelect: self unknownSelector
		testing: {
			false -> [self assertCanceled].
			'yourself' -> [self assertSucceeded: 'griffle [ self yourself ] value'].
			self unknownSelector -> [
				self assertSucceeded.
				self assert: (Symbol hasInterned: self unknownSelector ifTrue: [:symbol |])] }.
]

{ #category : #tests }
CompilerExceptionsTest >> testUnusedVariable [

	self 
		compiling: 'griffle | goo | ^nil'
		shouldRaise: UnusedVariable
		andSelect: [self text]
		testing: {
			[:ex | ex resume] -> [self assertCanceled].
			false -> [self assertSucceeded].
			true -> [self assertSucceeded: 'griffle\s*\^nil' asRegex] }.
	self
		compiling: 'griffle ^[ | goo | ]'
		shouldRaise: UnusedVariable
		andSelect: [self text]
		testing: {
			[:ex | ex resume] -> [self assertCanceled].
			false -> [self assertSucceeded].
			true -> [self assertSucceeded: 'griffle \^\[\s*\]' asRegex] }.
]

{ #category : #emulating }
CompilerExceptionsTest >> text [
	
	^text
]

{ #category : #private }
CompilerExceptionsTest >> unknownSelector [

	^ 'yourrsellff'
]
