"
-- Regular Expression Matcher v 1.1 (C) 1996, 1999 Vassili Bykov
--
A match start optimizer, handy for searching a string. Takes a regex syntax tree and sets itself up so that prefix characters or matcher states that cannot start a match are later recognized with #canStartMatch:in: method.

Used by RxMatcher, but can be used by other matchers (if implemented) as well.
"
Class {
	#name : #RxMatchOptimizer,
	#superclass : #Object,
	#instVars : [
		'ignoreCase',
		'prefixes',
		'nonPrefixes',
		'conditions',
		'testBlock',
		'methodPredicates',
		'nonMethodPredicates',
		'predicates',
		'nonPredicates'
	],
	#category : #'Regex-Core'
}

{ #category : #private }
RxMatchOptimizer >> addCondition: aSymbol [

	^(conditions ifNil: [ conditions := IdentitySet new: 1 ]) add: aSymbol
]

{ #category : #private }
RxMatchOptimizer >> addMethodPredicate: aSelector [

	^(methodPredicates ifNil: [ methodPredicates := IdentitySet new: 1 ]) add: aSelector
]

{ #category : #private }
RxMatchOptimizer >> addNonMethodPredicate: aSelector [

	^(nonMethodPredicates ifNil: [ nonMethodPredicates := IdentitySet new: 1 ]) add: aSelector
]

{ #category : #private }
RxMatchOptimizer >> addNonPredicate: nonPredicate [

	^(nonPredicates ifNil: [ nonPredicates := Set new: 1 ]) add: nonPredicate
]

{ #category : #private }
RxMatchOptimizer >> addNonPrefixes: aSet [

	aSet size = 0 ifTrue: [ ^aSet ].
	^nonPrefixes
		ifNil: [ nonPrefixes := aSet ]
		ifNotNil: [ nonPrefixes addAll: aSet ]
]

{ #category : #private }
RxMatchOptimizer >> addPredicate: predicate [

	^(predicates ifNil: [ predicates := Set new: 1 ]) add: predicate
]

{ #category : #private }
RxMatchOptimizer >> addPrefix: aCharacter [

	^(prefixes ifNil: [ prefixes := CharacterSet new ]) add: aCharacter
]

{ #category : #private }
RxMatchOptimizer >> addPrefixes: aSet [

	aSet size = 0 ifTrue: [ ^aSet ].
	^prefixes
		ifNil: [ prefixes := aSet ]
		ifNotNil: [ prefixes addAll: aSet ]
]

{ #category : #accessing }
RxMatchOptimizer >> canStartMatch: aCharacter in: aMatcher [ 
	"Answer whether a match could commence at the given lookahead
	character, or in the current state of <aMatcher>. True answered
	by this method does not mean a match will definitly occur, while false
	answered by this method *does* guarantee a match will never occur."

	aCharacter ifNil: [ ^true ].
	^testBlock value: aCharacter value: aMatcher
]

{ #category : #accessing }
RxMatchOptimizer >> conditionTester [
	"#any condition is filtered at the higher level;
	it cannot appear among the conditions here."

	| matchConditions size |
	conditions ifNil: [ ^nil ].
	(size := conditions size) = 0 ifTrue: [ ^nil ].
	size = 1 ifTrue: [
		| matchCondition |
		matchCondition := conditions anyOne.
		"Special case all of the possible conditions."
		#atBeginningOfLine == matchCondition ifTrue: [^[:c :matcher | matcher atBeginningOfLine]].
		#atEndOfLine == matchCondition ifTrue: [^[:c :matcher | matcher atEndOfLine]].
		#atBeginningOfWord == matchCondition ifTrue: [^[:c :matcher | matcher atBeginningOfWord]].
		#atEndOfWord == matchCondition ifTrue: [^[:c :matcher | matcher atEndOfWord]].
		#atWordBoundary == matchCondition ifTrue: [^[:c :matcher | matcher atWordBoundary]].
		#notAtWordBoundary == matchCondition ifTrue: [^[:c :matcher | matcher notAtWordBoundary]].
		RxParser signalCompilationException: 'invalid match condition'].
	"More than one condition. Capture them as an array in scope."
	matchConditions := conditions asArray.
	^[ :c :matcher |
		matchConditions anySatisfy: [ :conditionSelector |
			matcher perform: conditionSelector ] ]
]

{ #category : #private }
RxMatchOptimizer >> determineTestMethod [
	"Answer a block closure that will work as a can-match predicate.
	Answer nil if no viable optimization is possible (too many chars would
	be able to start a match)."

	| testers size |
	conditions ifNotNil: [
		(conditions includes: #any) ifTrue: [ ^nil ] ].
	testers := {
		self prefixTester.
		self nonPrefixTester.
		self conditionTester.
		self methodPredicateTester.
		self nonMethodPredicateTester.
		self predicateTester.
		self nonPredicateTester } reject: [ :each | each isNil ].
	(size := testers size) = 0 ifTrue: [ ^nil ].
	size = 1 ifTrue: [ ^testers first ].
	^[ :char :matcher | testers anySatisfy: [ :t | t value: char value: matcher ] ]
]

{ #category : #testing }
RxMatchOptimizer >> hasTestBlock [

	^testBlock notNil
]

{ #category : #'initialize-release' }
RxMatchOptimizer >> initialize: aRegex ignoreCase: aBoolean [ 
	"Set `testMethod' variable to a can-match predicate block:
	two-argument block which accepts a lookahead character
	and a matcher (presumably built from aRegex) and answers 
	a boolean indicating whether a match could start at the given
	lookahead. "

	ignoreCase := aBoolean.
	aRegex dispatchTo: self.
	"If the whole expression is nullable, end-of-line is an implicit can-match condition!"
	aRegex isNullable ifTrue: [ self addCondition: #atEndOfLine ].
	testBlock := self determineTestMethod
]

{ #category : #accessing }
RxMatchOptimizer >> methodPredicateTester [

	| p size |
	methodPredicates ifNil: [ ^nil ].
	(size := methodPredicates size) = 0 ifTrue: [ ^nil ].
	size = 1 ifTrue: [
		| selector |
		"might be a pretty common case"
		selector := methodPredicates anyOne.
		^[ :char :matcher | 
			RxParser doHandlingMessageNotUnderstood: [
				char perform: selector ] ] ].
	p := methodPredicates asArray.
	^[ :char :matcher | 
		RxParser doHandlingMessageNotUnderstood: [
			p anySatisfy: [ :sel | char perform: sel ] ] ]
]

{ #category : #accessing }
RxMatchOptimizer >> nonMethodPredicateTester [

	| p size |
	nonMethodPredicates ifNil: [ ^nil ].
	(size := nonMethodPredicates size) = 0 ifTrue: [ ^nil ].
	size = 1 ifTrue: [
		| selector |
		selector := nonMethodPredicates anyOne.
		^[ :char :matcher | 
			RxParser doHandlingMessageNotUnderstood: [
				(char perform: selector) not ] ] ].
	p := nonMethodPredicates asArray.
	^[:char :m | 
		RxParser doHandlingMessageNotUnderstood: [
			(p allSatisfy: [:sel | char perform: sel ]) not ] ]
]

{ #category : #private }
RxMatchOptimizer >> nonPredicateTester [

	| p |
	nonPredicates ifNil: [ ^nil ].
	nonPredicates size = 1 ifTrue:  [
		| predicate |
		predicate := nonPredicates anyOne.
		^[ :char :matcher | (predicate value: char) not ] ].
	p := nonPredicates asArray.
	^[ :char :matcher | (p allSatisfy: [ :some | some value: char ]) not ]
]

{ #category : #private }
RxMatchOptimizer >> nonPrefixTester [

	nonPrefixes ifNil: [ ^nil ].
	nonPrefixes size = 1 ifTrue: [
		| nonPrefixChar |
		nonPrefixChar := nonPrefixes anyOne.
		^[ :char :matcher | (char == nonPrefixChar) not ] ].
	^[ :char : matcher | (nonPrefixes includes: char) not ]
]

{ #category : #private }
RxMatchOptimizer >> predicateTester [

	| p |
	predicates ifNil: [ ^nil ].
	predicates size = 1 ifTrue: [
		| pred |
		pred := predicates anyOne.
		^[ :char :matcher | pred value: char ] ].
	p := predicates asArray. 
	^[ :char :matcher | p anySatisfy: [:some | some value: char ] ]
]

{ #category : #private }
RxMatchOptimizer >> prefixTester [

	| p |
	prefixes ifNil: [ ^nil ].
	prefixes size = 1 ifTrue: [
		| prefixChar |
		prefixChar := prefixes anyOne.
		ignoreCase ifTrue: [ 
			| lowercasePrefixChar |
			lowercasePrefixChar := prefixChar asLowercase.
			prefixChar := prefixChar asUppercase.
			prefixChar == lowercasePrefixChar ifFalse: [
				^[ :char :matcher | char == prefixChar or: [ char == lowercasePrefixChar ] ] ] ].
		^[ :char :matcher | char == prefixChar ] ].
	ignoreCase ifTrue: [
		prefixes copy do: [ :each |
			| character |
			(character := each asUppercase) == each
				ifFalse: [ prefixes add: character ]
				ifTrue: [ 
					(character := each asLowercase) == each ifFalse: [
						prefixes add: character ] ] ] ].
	prefixes size < 10 ifTrue: [ "10 is an empirical value"
		p := prefixes asArray.
		^[ :char :matcher | p instVarsInclude: char ] ].
	^[ :char :matcher | prefixes includes: char ]
]

{ #category : #'double dispatch' }
RxMatchOptimizer >> syntaxAny [
	"Any special char is among the prefixes."

	self addCondition: #any
]

{ #category : #'double dispatch' }
RxMatchOptimizer >> syntaxBeginningOfLine [
	"Beginning of line is among the prefixes."

	self addCondition: #atBeginningOfLine
]

{ #category : #'double dispatch' }
RxMatchOptimizer >> syntaxBeginningOfWord [
	"Beginning of line is among the prefixes."

	self addCondition: #atBeginningOfWord
]

{ #category : #'double dispatch' }
RxMatchOptimizer >> syntaxBranch: branchNode [
	"If the head piece of the branch is transparent (allows 0 matches),
	we must recurse down the branch. Otherwise, just the head atom
	is important."

	(branchNode piece isNullable and: [branchNode branch notNil])
		ifTrue: [branchNode branch dispatchTo: self].
	branchNode piece dispatchTo: self
]

{ #category : #'double dispatch' }
RxMatchOptimizer >> syntaxCharSet: charSetNode [ 
	"All these (or none of these) characters is the prefix."

	(charSetNode enumerableSetIgnoringCase: ignoreCase) ifNotNil: [ :enumerableSet |
		charSetNode isNegated
			ifTrue: [ self addNonPrefixes: enumerableSet ]
			ifFalse: [ self addPrefixes: enumerableSet ] ].

	charSetNode predicates ifNotNil: [ :charsetPredicates |
		charSetNode isNegated
			ifTrue: [ 
				charsetPredicates do: [ :each | self addNonPredicate: each ] ]
			ifFalse: [ 
				charsetPredicates do: [ :each | self addPredicate: each ] ] ]
]

{ #category : #'double dispatch' }
RxMatchOptimizer >> syntaxCharacter: charNode [
	"This character is the prefix, of one of them."

	self addPrefix: charNode character
]

{ #category : #'double dispatch' }
RxMatchOptimizer >> syntaxEndOfLine [
	"Beginning of line is among the prefixes."

	self addCondition: #atEndOfLine
]

{ #category : #'double dispatch' }
RxMatchOptimizer >> syntaxEndOfWord [

	self addCondition: #atEndOfWord
]

{ #category : #'double dispatch' }
RxMatchOptimizer >> syntaxEpsilon [
	"Empty string, terminate the recursion (do nothing)."
]

{ #category : #'double dispatch' }
RxMatchOptimizer >> syntaxLookaround: lookaroundNode forward: forward positive: positive [
	"Do nothing."
]

{ #category : #'double dispatch' }
RxMatchOptimizer >> syntaxMessagePredicate: messagePredicateNode [ 

	messagePredicateNode negated ifTrue: [
		^self addNonMethodPredicate: messagePredicateNode selector ].
	self addMethodPredicate: messagePredicateNode selector
]

{ #category : #'double dispatch' }
RxMatchOptimizer >> syntaxNonWordBoundary [

	self addCondition: #notAtWordBoundary
]

{ #category : #'double dispatch' }
RxMatchOptimizer >> syntaxPiece: pieceNode [
	"Pass on to the atom."

	pieceNode atom dispatchTo: self
]

{ #category : #'double dispatch' }
RxMatchOptimizer >> syntaxPredicate: predicateNode [ 

	self addPredicate: predicateNode predicate
]

{ #category : #'double dispatch' }
RxMatchOptimizer >> syntaxRegex: regexNode [
	"All prefixes of the regex's branches should be combined.
	Therefore, just recurse."

	regexNode branch dispatchTo: self.
	regexNode regex ifNotNil: [ :regex |
		regex dispatchTo: self ]
]

{ #category : #'double dispatch' }
RxMatchOptimizer >> syntaxWordBoundary [

	self addCondition: #atWordBoundary
]
