Class {
	#name : #CompiledMethodTrailerTest,
	#superclass : #TestCase,
	#category : #'KernelTests-Methods'
}

{ #category : #tests }
CompiledMethodTrailerTest >> testEmbeddingSourceCode [

	| trailer newTrailer code |
	
	trailer := CompiledMethodTrailer new.
	
	code := 'foo'.
	trailer sourceCode: code.
	newTrailer := trailer testEncoding.
	
	self assert: (trailer kind == #EmbeddedSourceQCompress ).
	self assert: (newTrailer sourceCode = code).

	"the last bytecode index must be at 0"
	self assert: (newTrailer endPC = 0).

	code := 'testEmbeddingSourceCode

	| trailer newTrailer code |
	
	trailer := CompiledMethodTrailer new.
	
	trailer sourceCode: code.
	newTrailer := trailer testEncoding.
	
	self assert: (newTrailer sourceCode = code).'.

	trailer sourceCode: code.
	self assert: (trailer kind == #EmbeddedSourceZip ).
	newTrailer := trailer testEncoding.
	
	self assert: (newTrailer sourceCode = code).
	"the last bytecode index must be at 0"
	self assert: (newTrailer endPC = 0).

]

{ #category : #tests }
CompiledMethodTrailerTest >> testEmbeddingTempNames [

	| trailer newTrailer code |
	
	trailer := CompiledMethodTrailer new.
	
	code := 'foo'.
	trailer tempNames: code.
	newTrailer := trailer testEncoding.
	
	self assert: (trailer kind == #TempsNamesQCompress ).
	self assert: (newTrailer tempNames = code).
	"the last bytecode index must be at 0"
	self assert: (newTrailer endPC = 0).
	

	code := 'testEmbeddingSourceCode

	| trailer newTrailer code |
	
	trailer := CompiledMethodTrailer new.
	
	trailer sourceCode: code.
	newTrailer := trailer testEncoding.
	
	self assert: (newTrailer sourceCode = code).'.

	trailer tempNames: code.
	self assert: (trailer kind == #TempsNamesZip ).
	newTrailer := trailer testEncoding.
	
	self assert: (newTrailer tempNames = code).
	"the last bytecode index must be at 0"
	self assert: (newTrailer endPC = 0).

]

{ #category : #tests }
CompiledMethodTrailerTest >> testEncodingNoTrailer [

	| trailer |
	
	trailer := CompiledMethodTrailer new.
	
	"by default it should be a no-trailer"	
	self assert: (trailer kind == #NoTrailer ).
	self assert: (trailer size = 1).
	
	trailer := trailer testEncoding.
	
	self assert: (trailer kind == #NoTrailer ).
	self assert: (trailer size = 1).
	"the last bytecode index must be at 0"
	self assert: (trailer endPC = 0).

]

{ #category : #tests }
CompiledMethodTrailerTest >> testEncodingSourcePointer [

	| trailer |
	
	trailer := CompiledMethodTrailer new.
	
	CompiledMethod allInstancesDo: [:method | | ptr |
		trailer method: method.
		self assert: ( (ptr := method sourcePointer) == trailer sourcePointer).
		"the last bytecode index must be at 0"
		ptr ~= 0 ifTrue: [
			self assert: (method endPC = trailer endPC) ].
	 ].
]

{ #category : #tests }
CompiledMethodTrailerTest >> testEncodingVarLengthSourcePointer [

	| trailer newTrailer |
	
	trailer := CompiledMethodTrailer new.
	
	trailer sourcePointer: 1.
	newTrailer := trailer testEncoding.
	
	self assert: (newTrailer sourcePointer = 1).
	
	trailer sourcePointer: 16r100000000000000.
	newTrailer := trailer testEncoding.
	self assert: (newTrailer sourcePointer = 16r100000000000000).
	"the last bytecode index must be at 0"
	self assert: (newTrailer endPC = 0).

]

{ #category : #tests }
CompiledMethodTrailerTest >> testEncodingZeroSourcePointer [

	| trailer |
	
	trailer := CompiledMethodTrailer new.

	self assert: 
		(trailer sourcePointer: 0) testEncoding sourcePointer = 0
	
]

{ #category : #tests }
CompiledMethodTrailerTest >> testSourceByIdentifierEncoding [

	| trailer id |
	
	trailer := CompiledMethodTrailer new.
	
	id := UUID new asString.
	trailer sourceIdentifier: id.
	
	self assert: (trailer kind == #SourceByStringIdentifier ).
	
	trailer := trailer testEncoding.
	
	self assert: (trailer kind == #SourceByStringIdentifier ).
	self assert: (trailer sourceIdentifier = id).
	"the last bytecode index must be at 0"
	self assert: (trailer endPC = 0).

]

{ #category : #tests }
CompiledMethodTrailerTest >> testSourceBySelectorEncoding [

	| trailer |
	
	trailer := CompiledMethodTrailer new.
	
	trailer setSourceBySelector.
	
	self assert: (trailer kind == #SourceBySelector ).
	self assert: (trailer size = 1).
	
	trailer := trailer testEncoding.
	
	self assert: (trailer kind == #SourceBySelector ).
	self assert: (trailer size = 1).
	"the last bytecode index must be at 0"
	self assert: (trailer endPC = 0).

]
