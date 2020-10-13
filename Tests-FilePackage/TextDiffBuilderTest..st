Class {
	#name : #TextDiffBuilderTest,
	#superclass : #TestCase,
	#category : #'Tests-FilePackage'
}

{ #category : #private }
TextDiffBuilderTest >> convertToString: anArray lineEndingSelector: aSymbol [

	^String streamContents: [ :stream |
		anArray do: [ :each |
			stream nextPutAll: each asString; perform: aSymbol ] ]
]

{ #category : #private }
TextDiffBuilderTest >> patchSequenceFor: x and: y [

	^self 
		patchSequenceFor: x
		lineEnding: #cr
		and: y
		lineEnding: #cr
		ignoreLineEndings: false
]

{ #category : #private }
TextDiffBuilderTest >> patchSequenceFor: x lineEnding: xLineEnding and: y lineEnding: yLineEnding ignoreLineEndings: ignoreLineEndings [

	^(TextDiffBuilder
		from: (self convertToString: x lineEndingSelector: xLineEnding)
		to:  (self convertToString: y lineEndingSelector: yLineEnding)
		ignoreLineEndings: ignoreLineEndings) buildPatchSequence
]

{ #category : #tests }
TextDiffBuilderTest >> testEmptyLcs1 [

	| patch |
	patch := self patchSequenceFor: #(a b c) and: #().
	self validatePatch: patch matches: 0 insertions: 0 removals: 3
]

{ #category : #tests }
TextDiffBuilderTest >> testEmptyLcs2 [

	| patch |
	patch := self patchSequenceFor: #() and: #(a b c).
	self validatePatch: patch matches: 0 insertions: 3 removals: 0
]

{ #category : #tests }
TextDiffBuilderTest >> testEmptyLcs3 [

	| patch |
	patch := self patchSequenceFor: #(a b c) and: #(d e f g).
	self validatePatch: patch matches: 0 insertions: 4 removals: 3.
	patch do: [ :each |
		each key = #remove ifTrue: [ self assert: ('abc' includes: each value first) ].
		each key = #insert ifTrue: [ self assert: ('defg' includes: each value first) ] ]
]

{ #category : #tests }
TextDiffBuilderTest >> testEmptySequences [

	| patch |
	patch := self patchSequenceFor: #() and: #().
	self validatePatch: patch matches: 0 insertions: 0 removals: 0
]

{ #category : #tests }
TextDiffBuilderTest >> testIfPatchIsMinimal [

	| patch |
	patch := self patchSequenceFor: #(a a a b) and: #(a b a a).
	self validatePatch: patch matches: 3 insertions: 1 removals: 1. "lcs is aaa"
	patch do: [ :each | 
		each key = #match 
			ifTrue: [ self assert: $a equals: each value first ]
			ifFalse: [ self assert: $b equals: each value first ] ]
]

{ #category : #tests }
TextDiffBuilderTest >> testIfSequence1 [
	"lcs is any one letter sequence"
	
	| patch |
	patch := self patchSequenceFor: #(a b c d) and: #(d c b a).
	self validatePatch: patch matches: 1 insertions: 3 removals: 3. "lcs is any one letter sequence"
]

{ #category : #tests }
TextDiffBuilderTest >> testIfSequence2 [

	| patch |
	patch := self patchSequenceFor: #(a b c d) and: #(c d b a).
	self validatePatch: patch matches: 2 insertions: 2 removals: 2. "lcs is cd"
	patch do: [ :each | 
		each key = #match 
			ifTrue: [ self assert: ('cd' includes: each value first) ]
			ifFalse: [ self assert: ('ab' includes: each value first) ] ]
]

{ #category : #tests }
TextDiffBuilderTest >> testIfSequence3 [

	| patch |
	patch := self patchSequenceFor: #(a b c d) and: #(b d c a).
	self validatePatch: patch matches: 2 insertions: 2 removals: 2. "lcs is bd"
	patch do: [ :each | 
		each key = #match 
			ifTrue: [ self assert: ('bd' includes: each value first) ]
			ifFalse: [ self assert: ('ac' includes: each value first) ] ]
]

{ #category : #tests }
TextDiffBuilderTest >> testIfSequence4 [

	| patch |
	patch := self patchSequenceFor: #(a b c d) and: #(d b c a).
	self validatePatch: patch matches: 2 insertions: 2 removals: 2. "lcs is bc"
	patch do: [ :each | 
		each key = #match 
			ifTrue: [ self assert: ('bc' includes: each value first) ]
			ifFalse: [ self assert: ('ad' includes: each value first) ] ]
]

{ #category : #tests }
TextDiffBuilderTest >> testIfSequence5 [

	| patch matches nonMatches |
	patch := self patchSequenceFor: #(a b c d) and: #(c d a b).
	self validatePatch: patch matches: 2 insertions: 2 removals: 2. "lcs is ab or cd"
	matches := (patch select: [ :each | each key = #match ])
		collect: [ :each | each value first ] as: String.
	self assert: (#('ab' 'cd') includes: matches).
	nonMatches := #('ab' 'cd') detect: [ :each | each ~= matches ].
	patch do: [ :each | 
		each key = #match 
			ifTrue: [ self assert: (matches includes: each value first) ]
			ifFalse: [ self assert: (nonMatches includes: each value first) ] ]
]

{ #category : #tests }
TextDiffBuilderTest >> testIfSequence6 [

	| patch |
	patch := self patchSequenceFor: #(a b c d) and: #(d a b c).
	self validatePatch: patch matches: 3 insertions: 1 removals: 1. "lcs is abc"
	patch do: [ :each | 
		each key = #match 
			ifTrue: [ self assert: ('abc' includes: each value first) ]
			ifFalse: [ self assert: $d equals: each value first ] ]
]

{ #category : #tests }
TextDiffBuilderTest >> testIgnoreLineEndings1 [

	#(cr lf crlf) do: [ :firstLineEnding |
		#(cr lf crlf) do: [ :secondLineEnding |
			| patch |
			patch := self 
				patchSequenceFor: #(a b c d)
				lineEnding: firstLineEnding
				and: #(d c b a)
				lineEnding: secondLineEnding
				ignoreLineEndings: true.
			self validatePatch: patch matches: 1 insertions: 3 removals: 3. "lcs is any one letter sequence" ] ]
]

{ #category : #tests }
TextDiffBuilderTest >> testIgnoreLineEndings2 [

	#(cr lf crlf) do: [ :firstLineEnding |
		#(cr lf crlf) do: [ :secondLineEnding |
			| patch |
			patch := self 
				patchSequenceFor: #(a b)
				lineEnding: firstLineEnding
				and: #(a b)
				lineEnding: secondLineEnding
				ignoreLineEndings: false.
			firstLineEnding = secondLineEnding
				ifTrue: [ self validatePatch: patch matches: 2 insertions: 0 removals: 0 ]
				ifFalse: [ self validatePatch: patch matches: 0 insertions: 2 removals: 2 ] ] ]
]

{ #category : #tests }
TextDiffBuilderTest >> testSameSequence [

	| patch |
	patch := self patchSequenceFor: #(a b c) and: #(a b c).
	self validatePatch: patch matches: 3 insertions: 0 removals: 0
]

{ #category : #tests }
TextDiffBuilderTest >> testSameSequenceWithRepetitions [

	| patch |
	patch := self patchSequenceFor: #(a a b a) and: #(a a b a).
	self validatePatch: patch matches: 4 insertions: 0 removals: 0
]

{ #category : #private }
TextDiffBuilderTest >> validatePatch: patch matches: matches insertions: insertions removals: removals [

	self 
		assert: matches equals: (patch count: [ :each | each key = #match ]);
		assert: insertions equals: (patch count: [ :each | each key = #insert ]);
		assert: removals equals: (patch count: [ :each | each key = #remove ]);
		assert: matches + insertions + removals equals: patch size
]
