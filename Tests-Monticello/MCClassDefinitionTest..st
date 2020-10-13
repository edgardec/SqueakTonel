Class {
	#name : #MCClassDefinitionTest,
	#superclass : #MCTestCase,
	#instVars : [
		'previousChangeSet'
	],
	#category : #'Tests-Monticello'
}

{ #category : #'as yet unclassified' }
MCClassDefinitionTest class >> classAComment [
	^ 'This is a mock class. The Monticello tests manipulated it to simulate a developer modifying code in the image.'
]

{ #category : #'as yet unclassified' }
MCClassDefinitionTest class >> classACommentStamp [
	^  'cwp 8/10/2003 16:43'
]

{ #category : #'as yet unclassified' }
MCClassDefinitionTest class >> restoreClassAComment [
	Smalltalk 
		at: #MCMockClassA 
		ifPresent: [:a | a classComment: self classAComment stamp: self classACommentStamp]
]

{ #category : #running }
MCClassDefinitionTest >> classAComment [
	^ self class classAComment
]

{ #category : #running }
MCClassDefinitionTest >> creationMessage [
	^ MessageSend
		receiver: MCClassDefinition
		selector: #name:superclassName:category:instVarNames:classVarNames:poolDictionaryNames:classInstVarNames:type:comment:commentStamp:
]

{ #category : #running }
MCClassDefinitionTest >> tearDown [

	super tearDown.
	Smalltalk at: 'MCMockClassC' ifPresent: [:c | c removeFromSystem]
]

{ #category : #tests }
MCClassDefinitionTest >> testCannotLoad [
	| d |
	d :=  self mockClass: 'MCMockClassC' super: 'NotAnObject'.
	self should: [d load] raise: Error.
	self deny: (Smalltalk hasClassNamed: 'MCMockClassC').
]

{ #category : #tests }
MCClassDefinitionTest >> testComparison [
	| d1 d2 d3 d4 |
	d1 := self mockClass: 'A' super: 'X'.
	d2 := self mockClass: 'A' super: 'Y'.
	d3 := self mockClass: 'B' super: 'X'.
	d4 := self mockClass: 'B' super: 'X'.
	
	self assert: (d1 isRevisionOf: d2).
	self deny: (d1 isSameRevisionAs: d2).

	self assert: (d3 isRevisionOf: d4).
	self assert: (d3 isSameRevisionAs: d4).
	
	self deny: (d1 isRevisionOf: d3).
	self deny: (d4 isRevisionOf: d2).
]

{ #category : #tests }
MCClassDefinitionTest >> testCreation [
	| d |
	d :=  self mockClassA asClassDefinition.
	self assert: d className = #MCMockClassA.
	self assert: d superclassName = #MCMock.
	self assert: d type = #normal.
	self assert: d category = self mockCategoryName.
	self assert: d instVarNames asArray = #('ivar').
	self assert: d classVarNames asArray = #('CVar').
	self assert: d classInstVarNames asArray = #().
	self assert: d comment isString.
	self assert: d comment = self classAComment.
	self assert: d commentStamp = self mockClassA organization commentStamp
]

{ #category : #tests }
MCClassDefinitionTest >> testDefinitionString [
	| d |
	d := self mockClassA asClassDefinition.
	self assert: d definitionString = self mockClassA definition.
]

{ #category : #tests }
MCClassDefinitionTest >> testEquals [
	| a b |
	a := self mockClass: 'ClassA' super: 'SuperA'.
	b := self mockClass: 'ClassA' super: 'SuperA'.
	self assert: a = b
]

{ #category : #tests }
MCClassDefinitionTest >> testEqualsSensitivity [
	| message a b defA args defB |
	message := self creationMessage.
	a := #(ClassA SuperA CategoryA #(iVarA) #(CVarA) #(PoolA) #(ciVarA)
			typeA 'A comment' 'A').
	b := #(ClassB SuperB CategoryB #(iVarB) #(CVarB) #(PoolB) #(ciVarB)
			typeB 'B comment' 'B').
	
	defA := message valueWithArguments: a.
	1 to: 8 do: [:index |
				args := a copy.
				args at: index put: (b at: index).
				defB := message valueWithArguments: args.
				self deny: defA = defB.]
]

{ #category : #'tests - class type' }
MCClassDefinitionTest >> testKindOfSubclass [
	{self mockClassA. String. ByteString. WideString. BlockClosure. WeakArray. BoxedFloat64. SmallFloat64. CompiledMethod. ByteArray. DoubleByteArray. IntegerArray. DoubleWordArray. }
		do: [:c |
			self assert: c asClassDefinition kindOfSubclass equals: c kindOfSubclass]
]

{ #category : #'tests - class type' }
MCClassDefinitionTest >> testKindOfSubclassForCompiledBlock [
	"CompiledCode and its subclasses are a special case."
	| classDef |
	"CompiledBlock should be like CompiledMethod, both now are subclassed from CompiledCode"
	classDef := self mockClass: #CompiledBlock super: #CompiledCode.
	self assert: #compiledMethod equals: classDef type.
	self assert: CompiledBlock typeOfClass equals: classDef type
]

{ #category : #'tests - class type' }
MCClassDefinitionTest >> testKindOfSubclassForCompiledCode [
	"CompiledCode and its subclasses are a special case."
	| classDef |
	"CompiledMethod is now a subclass of CompiledCode, which is also of type #compiledMethod"
	classDef := self mockClass: #CompiledCode super: #ByteArray.
	self assert: #compiledMethod equals: classDef type.
	self assert: CompiledCode typeOfClass equals: classDef type
]

{ #category : #'tests - class type' }
MCClassDefinitionTest >> testKindOfSubclassForCompiledMethod [
	"CompiledCode and its subclasses are a special case."
	| classDef |
	classDef := self mockClass: #CompiledMethod super: #CompiledCode.
	self assert: #compiledMethod equals: classDef type.
	self assert: CompiledMethod typeOfClass equals: classDef type
]

{ #category : #'tests - class type' }
MCClassDefinitionTest >> testKindOfSubclassForSocketAddress [
	"A subclass of ByteArray that is not treated specially"
	| classDef |
	classDef := self mockClass: #SocketAddress super: #ByteArray.
	self assert: #bytes equals: classDef type.
	self assert: SocketAddress typeOfClass equals: classDef type
]

{ #category : #tests }
MCClassDefinitionTest >> testLoadAndUnload [
	| d c |
	d :=  self mockClass: 'MCMockClassC' super: 'Object'.
	d load.
	self assert: (Smalltalk hasClassNamed: 'MCMockClassC').
	c := (Smalltalk classNamed: 'MCMockClassC').
	self assert: (c isKindOf: Class).
	self assert: c superclass = Object.
	self assert: c instVarNames isEmpty.
	self assert: c classVarNames isEmpty.
	self assert: c sharedPools isEmpty.
	self assert: c category = self mockCategoryName.
	self assert: c organization classComment = (self commentForClass: 'MCMockClassC').
	self assert: c organization commentStamp = (self commentStampForClass: 'MCMockClassC').
	d unload.
	self deny: (Smalltalk hasClassNamed: 'MCMockClassC').
]
