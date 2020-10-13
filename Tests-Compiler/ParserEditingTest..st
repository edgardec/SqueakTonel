Class {
	#name : #ParserEditingTest,
	#superclass : #TestCase,
	#category : #'Tests-Compiler'
}

{ #category : #support }
ParserEditingTest >> parse: aString into: aTrinaryBlock [
	| parser code |
	parser := self class newParser.
	code := aString withCRs.
	^aTrinaryBlock
		value: (parser parse: code class: self class; yourself)
		value: parser tempsMark
		value: code
]

{ #category : #tests }
ParserEditingTest >> testTempsMarkBinary [
	self parse: '+ arg false' into:
		[:parser :tempsMark :code|
		 self assert: tempsMark = (code indexOf: $f)].
	self parse: '+ arg\	false' into:
		[:parser :tempsMark :code|
		 self assert: tempsMark = (code indexOf: $f)].
	self parse: '+ arg\	<pragma>\	false' into:
		[:parser :tempsMark :code|
		 self assert: (tempsMark = (code indexOf: $f) or: [tempsMark = (code indexOf: $<)])].
	self parse: '+ arg | foo | false' into:
		[:parser :tempsMark :code|
		 self assert: tempsMark = (code lastIndexOf: $|)].
	self parse: '+ arg\ | foo | false' into:
		[:parser :tempsMark :code|
		 self assert: tempsMark = (code lastIndexOf: $|)].
	self parse: '+ arg\	<pragma>\ | foo | false' into:
		[:parser :tempsMark :code|
		 self assert: tempsMark = (code lastIndexOf: $|)].
	self parse: '+ arg\	| foo |\	<pragma>\	false' into:
		[:parser :tempsMark :code|
		 self assert: tempsMark = (code lastIndexOf: $|)]
]

{ #category : #tests }
ParserEditingTest >> testTempsMarkKeyword [
	self parse: 'key: word false' into:
		[:parser :tempsMark :code|
		 self assert: tempsMark = (code indexOf: $f)].
	self parse: 'key: word\	false' into:
		[:parser :tempsMark :code|
		 self assert: tempsMark = (code indexOf: $f)].
	self parse: 'key: word\	<pragma>\	false' into:
		[:parser :tempsMark :code|
		 self assert: (tempsMark = (code indexOf: $f) or: [tempsMark = (code indexOf: $<)])].
	self parse: 'key: word | foo | false' into:
		[:parser :tempsMark :code|
		 self assert: tempsMark = (code lastIndexOf: $|)].
	self parse: 'key: word\ | foo | false' into:
		[:parser :tempsMark :code|
		 self assert: tempsMark = (code lastIndexOf: $|)].
	self parse: 'key: word\	<pragma>\ | foo | false' into:
		[:parser :tempsMark :code|
		 self assert: tempsMark = (code lastIndexOf: $|)].
	self parse: 'key: word\	| foo |\	<pragma>\	false' into:
		[:parser :tempsMark :code|
		 self assert: tempsMark = (code lastIndexOf: $|)]
]

{ #category : #tests }
ParserEditingTest >> testTempsMarkUnary [
	self parse: 'unary false' into:
		[:parser :tempsMark :code|
		 self assert: tempsMark = (code indexOf: $f)].
	self parse: 'unary\	false' into:
		[:parser :tempsMark :code|
		 self assert: tempsMark = (code indexOf: $f)].
	self parse: 'unary\	<pragma>\	false' into:
		[:parser :tempsMark :code|
		 self assert: (tempsMark = (code indexOf: $f) or: [tempsMark = (code indexOf: $<)])].
	self parse: 'unary | foo | false' into:
		[:parser :tempsMark :code|
		 self assert: tempsMark = (code lastIndexOf: $|)].
	self parse: 'unary\ | foo | false' into:
		[:parser :tempsMark :code|
		 self assert: tempsMark = (code lastIndexOf: $|)].
	self parse: 'unary\	<pragma>\ | foo | false' into:
		[:parser :tempsMark :code|
		 self assert: tempsMark = (code lastIndexOf: $|)].
	self parse: 'unary\	| foo |\	<pragma>\	false' into:
		[:parser :tempsMark :code|
		 self assert: tempsMark = (code lastIndexOf: $|)]
]
