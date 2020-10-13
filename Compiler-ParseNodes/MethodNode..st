"
I am the root of the parse tree..

Instance Variables
	arguments:			<SequenceableCollection>
	block:				<BlockNode>
	encoder:			<BytecodeEncoder>
	localsPool:			<IdentitySet>
	locationCounter:	<Integer>
	precedence:		<Integer>
	primitive:			<Integer>
	properties:			<AdditionalMethodState|nil>
	selectorOrFalse:	<Object>
	sourceText:		<String|Text>
	temporaries:		<SequenceableCollection>

arguments
	- the collection of parsed or decompiled method arguments

block
	- the BlockNode holding the method's statements

encoder
	- the object that comprises the copiler's scope table, literal pool and back-end bytecode generator

localsPool
	- a set used to determine the set of copied values for each block in the method

locationCounter
	- an integer used to mark block scopes for the purposes of the closure transformation.  See BlockNode>>#analyseArguments:temporaries:rootNode:

precedence
	- the precedence of the method's selector (see Symbol>>precedence)

primitive
	- if non-zero this is the integer code of the method's primitive

properties
	- the object used to accumulate method properties (a.k.a. pragmas)

selectorOrFalse
	- the method's selector or false if this is a doit

sourceText
	- the source test from which the method was compiled

temporaries
	- the collection of parsed or decompiled method temporaries

"
Class {
	#name : #MethodNode,
	#superclass : #ParseNode,
	#instVars : [
		'selectorOrFalse',
		'precedence',
		'arguments',
		'block',
		'primitive',
		'encoder',
		'temporaries',
		'properties',
		'sourceText',
		'locationCounter',
		'localsPool'
	],
	#category : #'Compiler-ParseNodes'
}

{ #category : #visiting }
MethodNode >> accept: aVisitor [
	^aVisitor visitMethodNode: self
]

{ #category : #'closure analysis' }
MethodNode >> addLocalsToPool: locals [ "<Set of: TempVariableNode>"
	localsPool isNil ifTrue:
		[localsPool := IdentitySet new].
	localsPool addAll: locals
]

{ #category : #accessing }
MethodNode >> arguments [
	"For transformations etc, not used in compilation"
	^arguments
]

{ #category : #accessing }
MethodNode >> arguments: aSequence [
	"For transformations etc, not used in compilation"
	arguments := aSequence
]

{ #category : #converting }
MethodNode >> asColorizedSmalltalk80Text [
	"Answer a colorized Smalltalk-80-syntax string description of the parse tree whose root is the receiver."

	| printText |
	printText := self printString asText.
	^(Smalltalk at: #SHTextStylerST80 ifAbsent: [nil])
		ifNotNil: [:stylerClass| stylerClass new styledTextFor: printText]
		ifNil: [printText]
]

{ #category : #'initialize-release' }
MethodNode >> block [
	^ block
]

{ #category : #'debugger support' }
MethodNode >> blockExtentsToTempsMap [
	"Answer a Dictionary of blockExtent to temp locations for the current method.
	 This is used by the debugger to locate temp vars in contexts.  A temp map
	 entry is a pair of the temp's name and its index, where an index is either an
	 integer for a normal temp or a pair of the index of the indirect temp vector
	 containing  the temp and the index of the temp in its indirect temp vector."

	^encoder blockExtentsToTempsMap ifNil:
		[| methNode |
		methNode := encoder classEncoding newParser
						encoderClass: encoder class;
						parse: (sourceText ifNil: [self decompileString])
						class: self methodClass.
		"As a side effect generate: creates data needed for the map."
		methNode generate.
		methNode encoder blockExtentsToTempsMap]
]

{ #category : #accessing }
MethodNode >> body [
	^block
]

{ #category : #converting }
MethodNode >> decompileString [ 
	"Answer a string description of the parse tree whose root is the receiver."

	^self fullPrintString

]

{ #category : #converting }
MethodNode >> decompileText [ 
	"Answer a string description of the parse tree whose root is the receiver."

	^self asColorizedSmalltalk80Text
]

{ #category : #'code generation' }
MethodNode >> encoder [
	^ encoder
]

{ #category : #'closure analysis' }
MethodNode >> ensureClosureAnalysisDone [
	block blockExtent ifNil:
		[temporaries := block analyseArguments: arguments temporaries: temporaries rootNode: self]
]

{ #category : #converting }
MethodNode >> ensureNotQuick [
	"If the receiver is quick (can be generated as a Quick method, ^self,^inst var or ^ special constant)
	 make it not so.  This is used to create break-pointable versions of quick methods.   Answer if the
	 receiver was quick."
	^block ensureNotQuick: encoder
]

{ #category : #'code generation' }
MethodNode >> generate [
	"The receiver is the root of a parse tree. Answer a CompiledMethod. The
	argument, trailer, is the references to the source code that is stored with 
	every CompiledMethod."

	^self generate: CompiledMethodTrailer empty using: CompiledMethod
]

{ #category : #'code generation' }
MethodNode >> generate: trailer [ 
	"The receiver is the root of a parse tree. Answer a CompiledMethod.
	 The argument, trailer, is arbitrary but is typically either the reference
	 to the source code that is stored with every CompiledMethod, or an
	 encoding of the method's temporary names."

	^self generate: trailer using: CompiledMethod
]

{ #category : #'code generation' }
MethodNode >> generate: trailer ifQuick: methodBlock [
	^self generate: trailer using: CompiledMethod ifQuick: methodBlock
]

{ #category : #'code generation' }
MethodNode >> generate: trailer using: aCompiledMethodClass [
	"The receiver is the root of a parse tree. Answer an instance of aCompiledMethodClass.
	 The argument, trailer, is arbitrary but is typically either the reference to the source code
	 that is stored with every CompiledMethod, or an encoding of the method's temporary names."

	| method |
	self generate: trailer
		using: aCompiledMethodClass
		ifQuick:
			[:m |
			  m	literalAt: 2 put: encoder associationForClass;
				properties: properties.
			^m].
	method := encoder generateMethodOfClass: aCompiledMethodClass trailer: trailer from: self.
	method properties: properties.
	^method
]

{ #category : #'code generation' }
MethodNode >> generate: trailer using: aCompiledMethodClass ifQuick: methodBlock [
	| v |
	(primitive = 0 and: [arguments size = 0 and: [block isQuick]]) ifFalse:
		[^self].
	v := block code.
	v < 0 ifTrue:
		[^self].
	v = LdSelf ifTrue:
		[^methodBlock value: (aCompiledMethodClass toReturnSelfTrailerBytes: trailer)].
	(v between: LdTrue and: LdMinus1 + 3) ifTrue:
		[^methodBlock value: (aCompiledMethodClass toReturnConstant: v - LdSelf trailerBytes: trailer)].
	v < ((CodeBases at: LdInstType) + (CodeLimits at: LdInstType)) ifTrue:
		[^methodBlock value: (aCompiledMethodClass toReturnField: v trailerBytes: trailer)].
	v // 256 = 1 ifTrue:
		[^methodBlock value: (aCompiledMethodClass toReturnField: v \\ 256 trailerBytes: trailer)]
]

{ #category : #'code generation' }
MethodNode >> generateWithTempNames [
	"Answer a CompiledMethod with temps names encoded in its trailer."
	| methodSansTempNames |
	"The encoder computes the schematic temp names during generation, so 
	 generate a method without temp names first.  If the method is quick there are
	 no temps and hence no temp names."
	methodSansTempNames := self
									generate: CompiledMethodTrailer empty
									using: CompiledMethod.
	^methodSansTempNames
		copyWithTrailerBytes:
			((CompiledMethodTrailer new tempNames:
				(methodSansTempNames isQuick
					ifTrue: ['']
					ifFalse: [encoder schematicTempNamesString])))
]

{ #category : #'debugger support' }
MethodNode >> hasGeneratedMethod [
	^encoder hasGeneratedMethod
]

{ #category : #'closure analysis' }
MethodNode >> locationCounter [
	^locationCounter
]

{ #category : #printing }
MethodNode >> methodClass [

	^ encoder classEncoding
]

{ #category : #'closure analysis' }
MethodNode >> noteBlockEntry: aBlock [
	"Evaluate aBlock with the numbering for the block entry."
	locationCounter isNil ifTrue:
		[locationCounter := -1].
	aBlock value: locationCounter + 1.
	locationCounter := locationCounter + 2
]

{ #category : #'closure analysis' }
MethodNode >> noteBlockExit: aBlock [
	"Evaluate aBlock with the numbering for the block exit."
	aBlock value: locationCounter + 1.
	locationCounter := locationCounter + 2
]

{ #category : #'code generation' }
MethodNode >> parserClass [
	"Which parser produces this class of parse node"

	^ Parser
]

{ #category : #converting }
MethodNode >> preen [
	"Preen for pretty-printing and/or decompilation.
	 i.e. post-process to cover up for inadequacies in both algorithms.

	 Currently two cases:

		preenLocalIfNotNilArg: blockNode
		hiding the assignment to the arg of an inlined block arg to ifNotNil:,
			(var := expr) ifNil: [...] ifNotNil: [...]    =>    expr ifNil: [...] ifNotNil: [:var| ...].

		preenTempsConflictingWithBlockNode: temps
		hiding the declaration of a temp that is redeclared in some block"

	self preenableNodes keysAndValuesDo:
		[:nodeOrArray :selector |
		 self perform: selector with: nodeOrArray]
]

{ #category : #'converting-private' }
MethodNode >> preenIfNotNilNode: messageNode [
	"Transform a (var := expr) ifNil: [...] ifNotNil: [...] where var is only used in the ifNotNil: block
	 and convert it to expr ifNil: [...] ifNotNil: [:var| ...].  Deal both with the pretty-print case where
	 the block already declares the variable and the decompile case where it does not."

	| variable |
	self assert: (messageNode isMessageNode
				and: [messageNode macroPrinter == #printIfNilNotNil:indent:
				and: [messageNode receiver receiver isAssignmentNode]]).
	variable := messageNode receiver receiver variable.
	self assert: (variable isTemp and: [variable isRemote not]).
	messageNode arguments last arguments isEmpty
		ifTrue: [messageNode arguments last arguments: { variable }]
		ifFalse:
			[self assert: messageNode arguments last arguments asArray = { variable }.
			 variable := nil].
	messageNode receiver receiver: messageNode receiver receiver value.
	variable ifNil: [^self].
	self nodesDo:
		[:node|
		((node == self or: [node isBlockNode])
		 and: [node temporaries includes: variable]) ifTrue:
			[node temporaries: (node temporaries copyWithout: variable)]]
]

{ #category : #'converting-private' }
MethodNode >> preenNilNodeFollowingNilIfNode: aNilIfMessageNode [
	self nodesDo:
		[:node| | statements indices |
		 (node isBlockNode
		  and: [(statements := node statements) includes: aNilIfMessageNode]) ifTrue:
			[indices := (2 to: statements size) reject:
							[:i|
							(statements at: i) == NodeNil
							and: [(statements at: i - 1) isNilIf]].
			 node statements: (({1}, indices) collect: [:i| statements at: i])]]
]

{ #category : #'converting-private' }
MethodNode >> preenTempsConflictingWithBlockNode: temps [
	"Push temps that conflict with other blocks down into their narrowest enclosing block scope."
	temps do:
		[:tempVar|
		(self accept: (NarrowerVariableScopeFinder new ofVariable: tempVar)) ifNotNil:
			[:enclosingScope |
			 self assert: enclosingScope isBlockNode.
			 self nodesDo:
				[:node|
				 ((node == self or: [node isBlockNode])
				  and: [node temporaries includes: tempVar]) ifTrue:
					[node temporaries: (node temporaries copyWithout: tempVar)]].
			 enclosingScope temporaries: enclosingScope temporaries, { tempVar }]]
]

{ #category : #'converting-private' }
MethodNode >> preenableNodes [
	"Answer a Dictionary from node or sequence of nodes to preen method selector for nodes
	 in the tree that require post-processing after either a format or a decompile.  Such issues
	 are the variable for an ifNotNil: which is local to the ifNotNil: block but, due to the inlining
	 of ifNotNil: appears to be declared at the outer level, and, similarly, a temporary variable
	 that conflicts with one of the same name in a block when, were the variable declared
	 local to some inlined block it would no longer conflict.  The resulting dictionary is used to
	 perform the value with the key (node or array) as argument to preen the tree."

	| preenableNodes priorBlocks priorVariables |
	preenableNodes := Dictionary new.
	priorBlocks := OrderedCollection new.
	priorVariables := Set new.
	self nodesWithPrecedingStatementsDo:
		[:node :preceedingStatementOrNil| | variable temps |
		(node isMessageNode
		and: [node macroPrinter == #printIfNilNotNil:indent:
		and: [node receiver isMessageNode
		and: [node receiver selector key == #==
		and: [node receiver receiver isAssignmentNode
		and: [(variable := node receiver receiver variable) isTemp
		and: [variable isRemote not
		and: [variable isOnlySubnodeOf: node in: self]]]]]]]) ifTrue:
			[preenableNodes at: node put: #preenIfNotNilNode:.
			 priorVariables add: variable].
		node isBlockNode ifTrue:
			[temps := OrderedCollection new.
			 node temporaries do:
				[:temp|
				 priorBlocks do:
					[:aBlock|
					 aBlock temporaries do:
						[:priorTemp|
						 (priorVariables includes: priorTemp) ifFalse:
							[priorTemp key = temp key ifTrue:
								[temps addLast: priorTemp]]]]].
			 temps isEmpty ifFalse:
				[preenableNodes at: temps put: #preenTempsConflictingWithBlockNode:].
			 priorBlocks addLast: node].
		(node == NodeNil
		 and: [preceedingStatementOrNil notNil
		 and: [preceedingStatementOrNil isMessageNode
		 and: [preceedingStatementOrNil isNilIf]]]) ifTrue:
			[preenableNodes at: preceedingStatementOrNil put: #preenNilNodeFollowingNilIfNode:]].
	^preenableNodes
]

{ #category : #accessing }
MethodNode >> primitive [
	^primitive
]

{ #category : #accessing }
MethodNode >> primitiveErrorVariableName [
	"Answer the primitive error code temp name, or nil if none."
	(primitive isInteger and: [primitive > 0]) ifTrue:
		[properties pragmas do:
			[:pragma| | kwds ecIndex |
			((kwds := pragma keyword keywords) first = 'primitive:'
			and: [(ecIndex := kwds indexOf: 'error:') > 0]) ifTrue:
				[^pragma argumentAt: ecIndex]]].
	^nil

	"(Parser new parse: (MethodNode sourceCodeAt: #primitiveErrorVariableName) class: Parser) primitiveErrorVariableName"

	"(Parser new parse: 'foo <primitive: 111 error: ''foo''> self primitiveFailed' class: Object) primitiveErrorVariableName"

	"(Parser new parse: 'foo <primitive: 111 error: foo> self primitiveFailed' class: Object) primitiveErrorVariableName"

	"(Parser new parse: 'foo <primitive: 111> self primitiveFailed' class: Object) primitiveErrorVariableName"

	"(Parser new parse: 'foo <primitive: ''foo'' error: foo module: ''bar''> self primitiveFailed' class: Object) primitiveErrorVariableName"

	"(Parser new parse: 'foo <primitive: ''foo'' module: ''bar'' error: foo> self primitiveFailed' class: Object) primitiveErrorVariableName"

	"(Parser new parse: 'foo <primitive: 111 error: foo> self primitiveFailed' class: Object) generate"
]

{ #category : #printing }
MethodNode >> printOn: aStream [
	| selectorNode |
	selectorNode := self selectorNode.
	precedence = 1
		ifTrue:
			[selectorNode isForFFICall
				ifTrue: [selectorNode
							printAsFFICallWithArguments: arguments
							on: aStream
							indent: 0]
				ifFalse: [aStream nextPutAll: selectorNode key]]
		ifFalse:
			[selectorNode key keywords with: arguments do:
				[:kwd :arg |
				aStream nextPutAll: kwd; space; nextPutAll: arg key; space]].
	comment == nil ifFalse:
		[aStream crtab: 1.
		 self printCommentOn: aStream indent: 1].
	block printTemporaries: temporaries on: aStream doPrior: [aStream crtab: 1].
	primitive > 0 ifTrue:
		[(primitive between: 255 and: 519) ifFalse:  "Dont decompile quick prims  e.g, ^ self or ^instVar"
			[aStream crtab: 1.
			 self printPrimitiveOn: aStream]].
	self printPropertiesOn: aStream.
	self printPragmasOn: aStream.
	aStream crtab: 1.
	block printStatementsOn: aStream indent: 0
]

{ #category : #printing }
MethodNode >> printPragmasOn: aStream [
	properties ifNil: [^self].
	properties pragmas do:
		[:pragma|
		"Primitives are printed in printPrimitiveOn:; skip these"
		(Parser primitivePragmaSelectors includes: pragma keyword) ifFalse:
			[aStream crtab: 1; nextPut: $<; print: pragma message; nextPut: $>]]
]

{ #category : #printing }
MethodNode >> printPrimitiveOn: aStream [
	"Print the primitive on aStream"
	| primDecl |
	primitive = 0 ifTrue:
		[^self].
	primitive = 120 ifTrue: "External call spec"
		[^aStream print: encoder literals first].
	aStream nextPutAll: '<primitive: '.
	primitive = 117
		ifTrue:
			[primDecl := encoder literals at: 1.
			 (primDecl at: 2) asString printOn: aStream.
			 (primDecl at: 1) ifNotNil:
				[:moduleName|
				aStream nextPutAll:' module: '.
				moduleName asString printOn: aStream]]
		ifFalse:
			[aStream print: primitive].
	self primitiveErrorVariableName ifNotNil:
		[:primitiveErrorVariableName|
		 aStream nextPutAll: ' error: '; nextPutAll: primitiveErrorVariableName].
	aStream nextPut: $>.
	((Smalltalk classNamed: #StackInterpreter) ifNil: [Smalltalk classNamed: #Interpreter]) ifNotNil:
		[:interpreterClass|
		 aStream nextPutAll: ' "', (interpreterClass primitiveTable at: primitive + 1), '" ']
]

{ #category : #printing }
MethodNode >> printPropertiesOn: aStream [
	properties ifNil: [^self].
	properties propertyKeysAndValuesDo:
		[:prop :val|
		aStream crtab; nextPut: $<.
		prop = #on:in:
			ifTrue:
				[prop keywords with: val do:
					[:k :v | aStream nextPutAll: k; space; nextPutAll: v; space]]
			ifFalse:
				[prop = #on
					ifTrue: [aStream nextPutAll: prop; nextPutAll:': '; nextPutAll: val] 
					ifFalse: [aStream nextPutAll: prop; nextPutAll:': '; print: val]]. 
		aStream nextPut: $>]
]

{ #category : #printing }
MethodNode >> printWithClosureAnalysisOn: aStream [ 
	self ensureClosureAnalysisDone.
	precedence = 1
		ifTrue: 
			[(self selector includesSubstring: '()/')
				ifTrue: [aStream nextPutAll: (self selector copyUpTo: $)).
						arguments
							do: [:arg| aStream nextPutAll: arg key]
							separatedBy: [aStream nextPutAll: ', '].
						aStream nextPut: $)]
				ifFalse: [aStream nextPutAll: self selector]]  "no node for method selector"
		ifFalse: 
			[self selector keywords with: arguments do: 
				[:kwd :arg | 
				aStream nextPutAll: kwd; space.
				arg printDefinitionForClosureAnalysisOn: aStream.
				aStream space]].
	comment == nil ifFalse: 
			[aStream crtab: 1.
			 self printCommentOn: aStream indent: 1].
	temporaries size > 0 ifTrue: 
			[aStream crtab: 1; nextPut: $|.
			temporaries do: [:temp | 
				aStream space.
				temp printDefinitionForClosureAnalysisOn: aStream].
			aStream space; nextPut: $|].
	primitive > 0 ifTrue:
		[(primitive between: 255 and: 519) ifFalse:  "Dont decompile quick prims  e.g, ^ self or ^instVar"
			[aStream crtab: 1.
			 self printPrimitiveOn: aStream]].
	self printPropertiesOn: aStream.
	self printPragmasOn: aStream.
	aStream crtab: 1.
	block printWithClosureAnalysisStatementsOn: aStream indent: 0
]

{ #category : #'code generation' }
MethodNode >> properties [
	^properties
]

{ #category : #'source mapping' }
MethodNode >> rawSourceRanges [

	^self rawSourceRangesAndMethodDo: [:rawSourceRanges :method| rawSourceRanges]
]

{ #category : #'source mapping' }
MethodNode >> rawSourceRangesAndMethodDo: aBinaryBlock [
	"Evaluate aBinaryBlock with the rawSourceRanges and method generated from the receiver."

	| methNode method |
	methNode := encoder classEncoding newParser
					encoderClass: encoder class;
					parse: (sourceText "If no source, use decompile string as source to map from"
							ifNil: [self decompileString]
							ifNotNil: [sourceText])
					class: self methodClass.
	method := methNode generate.  "set bytecodes to map to"
	^aBinaryBlock
		value: methNode encoder rawSourceRanges
		value: method
]

{ #category : #'closure analysis' }
MethodNode >> referencedValuesWithinBlockExtent: anInterval [ 
	^(localsPool select:
		[:temp|
		 temp isReferencedWithinBlockExtent: anInterval]) collect:
			[:temp|
			temp isRemote ifTrue: [temp remoteNode] ifFalse: [temp]]
]

{ #category : #'primitive error codes' }
MethodNode >> removeAndRenameLastTempIfErrorCode [
	self primitiveErrorVariableName ifNotNil:
		[:primitiveErrorVariableName|
		 temporaries last
			name: primitiveErrorVariableName
			key: primitiveErrorVariableName
			code: temporaries last code.
		 temporaries removeLast].
]

{ #category : #accessing }
MethodNode >> removeProperty: aSymbol [
	properties := properties copyWithout: (Association
											key: aSymbol
											value: (properties propertyValueAt: aSymbol))
]

{ #category : #'debugger support' }
MethodNode >> schematicTempNamesString [
	"Answer the temp names for the current method node in a form that captures
	 temp structure.  The temps at each method and block scope level occur
	 space-separated, with any indirect temps enclosed in parentheses.  Each block
	 level is enclosed in square brackets.  e.g.
		'method level temps (indirect temp)[block args and temps (indirect)]'
	 This representation can be reconstituted into a blockExtentsToTempsMap
	 by a CompiledMethod that has been copied with the schematicTempNamesString."
	encoder hasGeneratedMethod ifFalse:
		["create the encoder's blockExtentsToLocals map, except if the method is quick
		  in which case it has no temps."
		self generate isQuick ifTrue:
			[^'']].
	^encoder schematicTempNamesString
]

{ #category : #'code generation' }
MethodNode >> selector [ 
	"Answer the message selector for the method represented by the receiver."

	(selectorOrFalse isSymbol)
		ifTrue: [^selectorOrFalse].
	^selectorOrFalse key.

]

{ #category : #'initialize-release' }
MethodNode >> selector: symbol [

	selectorOrFalse := symbol
]

{ #category : #'initialize-release' }
MethodNode >> selector: selOrFalse arguments: args precedence: p temporaries: temps block: blk encoder: anEncoder primitive: prim [ 
	
	self 
		selector: selOrFalse
		arguments: args
		precedence: p
		temporaries: temps
		block: blk encoder:
		anEncoder 
		primitive: prim 
		properties: AdditionalMethodState new.
]

{ #category : #'initialize-release' }
MethodNode >> selector: selOrFalse arguments: args precedence: p temporaries: temps block: blk encoder: anEncoder primitive: prim properties: propDict [
	"Initialize the receiver with respect to the arguments given."

	encoder := anEncoder.
	selectorOrFalse := selOrFalse.
	precedence := p.
	arguments := args.
	temporaries := temps.
	block := blk.
	primitive := prim.
	properties := propDict.
]

{ #category : #'code generation' }
MethodNode >> selectorNode [
	"Answer a SelectorNode for the message selector of the method represented by the receiver."

	^(selectorOrFalse isKindOf: SelectorNode)
		ifTrue: [selectorOrFalse]
		ifFalse: [SelectorNode new key: selectorOrFalse]
]

{ #category : #printing }
MethodNode >> sourceText [

	^ sourceText ifNil: [self printString]
]

{ #category : #'initialize-release' }
MethodNode >> sourceText: stringOrText [

	sourceText := stringOrText
]

{ #category : #printing }
MethodNode >> tempNames [
	^ encoder tempNames
]

{ #category : #accessing }
MethodNode >> temporaries [
	"For transformations etc, not used in compilation"
	^temporaries
]

{ #category : #accessing }
MethodNode >> temporaries: aSequence [
	"For transformations etc, not used in compilation"
	temporaries := aSequence
]
