Class {
	#name : #UnderscoreSelectorsTest,
	#superclass : #TestCase,
	#category : #'Tests-Compiler'
}

{ #category : #support }
UnderscoreSelectorsTest >> assertSelector: aSymbol hasPrecedence: expected [
	| actual |
	actual := aSymbol precedence.
	self assert: actual = expected
]

{ #category : #support }
UnderscoreSelectorsTest >> assertString: aString hasNumArgs: anInteger [
	| num |
	num := aString numArgs.
	self assert: num = anInteger
]

{ #category : #support }
UnderscoreSelectorsTest >> pref: aBoolean during: aBlock [
	| tmp |
	tmp := Scanner prefAllowUnderscoreSelectors.
	[Scanner prefAllowUnderscoreSelectors: aBoolean.
	aBlock value] ensure: 
		[Scanner prefAllowUnderscoreSelectors: tmp].
]

{ #category : #tests }
UnderscoreSelectorsTest >> testA0NoUnderscoreAllowed [
	self pref: true during: [self assertString: 'ab' hasNumArgs: 0]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testA0NoUnderscoreForbidden [
	self pref: false during: [self assertString: 'ab' hasNumArgs: 0]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testA0UnderscoreAllowed [
	self pref: true during: [self assertString: 'a_b' hasNumArgs: 0]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testA0UnderscoreForbidden [
	self pref: false during: [self assertString: 'a_b' hasNumArgs: -1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testA1NoUnderscoreAllowed [
	self pref: true during: [self assertString: 'ab:' hasNumArgs: 1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testA1NoUnderscoreForbidden [
	self pref: false during: [self assertString: 'ab:' hasNumArgs: 1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testA1UnderscoreAllowed [
	self pref: true during: [self assertString: 'a_b:' hasNumArgs: 1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testA1UnderscoreForbidden [
	self pref: false during: [self assertString: 'a_b:' hasNumArgs: -1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testA2NoUnderscoreAllowed [
	self pref: true during: [self assertString: 'ab:cd:' hasNumArgs: 2]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testA2NoUnderscoreForbidden [
	self pref: false during: [self assertString: 'ab:cd:' hasNumArgs: 2]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testA2UnderscoreAllowed [
	self pref: true during: [self assertString: 'a_b:cd:' hasNumArgs: 2]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testA2UnderscoreForbidden [
	self pref: false during: [self assertString: 'a_b:cd:' hasNumArgs: -1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testB1Allowed [
	self pref: true during: [self assertString: '+' hasNumArgs: 1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testB1Forbidden [
	self pref: false during: [self assertString: '+' hasNumArgs: 1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testB2Allowed [
	self pref: true during: [self assertString: '++' hasNumArgs: 1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testB2Forbidden [
	self pref: false during: [self assertString: '++' hasNumArgs: 1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testEmpty [
	self assertString: '' hasNumArgs: -1
]

{ #category : #tests }
UnderscoreSelectorsTest >> testInvalidUnderscoreAllowed [
	self pref: true during: [self assertString: '3' hasNumArgs: -1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testInvalidUnderscoreForbidden [
	self pref: false during: [self assertString: '3' hasNumArgs: -1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testLeadingColonAllowed [
	self pref: true during: [self assertString: ':if:then:else:' hasNumArgs: -1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testLeadingColonForbidden [
	self pref: false during: [self assertString: #':if:then:else:' hasNumArgs: -1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testNoTrailingColonAllowed [
	self pref: true during: [self assertString: 'nextPut:andCR' hasNumArgs: -1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testNoTrailingColonForbidden [
	self pref: false during: [self assertString: 'nextPut:andCR' hasNumArgs: -1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testP1InternalUnderscore [
	
	self 
		assertSelector: #'is_symbol' 
		hasPrecedence: 1.

]

{ #category : #tests }
UnderscoreSelectorsTest >> testP1LeadingUnderscore [
	self 
		assertSelector: #'_isSymbol' 
		hasPrecedence: 1.

]

{ #category : #tests }
UnderscoreSelectorsTest >> testP1SingleUnderscore [
	self
		assertSelector: #'_'
		hasPrecedence: 1
]

{ #category : #tests }
UnderscoreSelectorsTest >> testP1Traditional [
	self
		assertSelector: #isSymbol
		hasPrecedence: 1
]

{ #category : #tests }
UnderscoreSelectorsTest >> testP1TrailingUnderscore [
	self
		assertSelector: #'isSymbol_'
		hasPrecedence: 1
]

{ #category : #tests }
UnderscoreSelectorsTest >> testP2Traditional [
	self
		assertSelector: #+
		hasPrecedence: 2
]

{ #category : #tests }
UnderscoreSelectorsTest >> testP3InternalUnderscore [
	self
		assertSelector: #'with_value:'
		hasPrecedence: 3
]

{ #category : #tests }
UnderscoreSelectorsTest >> testP3LeadingUnderscore [
	self
		assertSelector: #'_value:'
		hasPrecedence: 3
]

{ #category : #tests }
UnderscoreSelectorsTest >> testP3Traditional [
	self
		assertSelector: #value:
		hasPrecedence: 3
]

{ #category : #tests }
UnderscoreSelectorsTest >> testP3TrailingUnderscore [
	self
		assertSelector: #'value_:'
		hasPrecedence: 3
]

{ #category : #tests }
UnderscoreSelectorsTest >> testSelA0NoUnderscoreAllowed [
	self pref: true during: [self assertString: #'ab' hasNumArgs: 0]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testSelA0NoUnderscoreForbidden [
	self pref: false during: [self assertString: #'ab' hasNumArgs: 0]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testSelA0UnderscoreAllowed [
	self pref: true during: [self assertString: #'a_b' hasNumArgs: 0]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testSelA0UnderscoreForbidden [
	self pref: false during: [self assertString: #'a_b' hasNumArgs: 0]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testSelA1NoUnderscoreAllowed [
	self pref: true during: [self assertString: #'ab:' hasNumArgs: 1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testSelA1NoUnderscoreForbidden [
	self pref: false during: [self assertString: #'ab:' hasNumArgs: 1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testSelA1UnderscoreAllowed [
	self pref: true during: [self assertString: #'a_b:' hasNumArgs: 1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testSelA1UnderscoreForbidden [
	self pref: false during: [self assertString: #'a_b:' hasNumArgs: 1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testSelA2NoUnderscoreAllowed [
	self pref: true during: [self assertString: #'ab:cd:' hasNumArgs: 2]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testSelA2NoUnderscoreForbidden [
	self pref: false during: [self assertString: #'ab:cd:' hasNumArgs: 2]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testSelA2UnderscoreAllowed [
	self pref: true during: [self assertString: #'a_b:cd:' hasNumArgs: 2]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testSelA2UnderscoreForbidden [
	self pref: false during: [self assertString: #'a_b:cd:' hasNumArgs: 2]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testSelB1Allowed [
	self pref: true during: [self assertString: #'+' hasNumArgs: 1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testSelB1Forbidden [
	self pref: false during: [self assertString: #'+' hasNumArgs: 1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testSelB2Allowed [
	self pref: true during: [self assertString: #'++' hasNumArgs: 1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testSelB2Forbidden [
	self pref: false during: [self assertString: #'++' hasNumArgs: 1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testSelEmpty [
	self assertString: #'' hasNumArgs: -1
]

{ #category : #tests }
UnderscoreSelectorsTest >> testSelInvalidUnderscoreAllowed [
	self pref: true during: [self assertString: #'3' hasNumArgs: -1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testSelInvalidUnderscoreForbidden [
	self pref: false during: [self assertString: #'3' hasNumArgs: -1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testSelLeadingColonAllowed [
	self pref: true during: [self assertString: #':if:then:else:' hasNumArgs: -1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testSelNoTrailingColonAllowed [
	self pref: true during: [self assertString: #'nextPut:andCR' hasNumArgs: -1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testSelNoTrailingColonForbidden [
	self pref: false during: [self assertString: #'nextPut:andCR' hasNumArgs: -1]
]

{ #category : #tests }
UnderscoreSelectorsTest >> testTokenishFalse [
	self pref: false during: [self deny: $_ tokenish].
]

{ #category : #tests }
UnderscoreSelectorsTest >> testTokenishTrue [
	self pref: true during: [self assert: $_ tokenish].
]
