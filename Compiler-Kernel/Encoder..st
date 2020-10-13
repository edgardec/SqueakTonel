"
I encode names and literals into tree nodes with byte codes for the compiler. Byte codes for literals are not assigned until the tree-sizing pass of the compiler, because only then is it known which literals are actually needed. I also keep track of sourceCode ranges during parsing and code generation so I can provide an inverse map for the debugger.
"
Class {
	#name : #Encoder,
	#superclass : #ParseNode,
	#instVars : [
		'scopeTable',
		'nTemps',
		'supered',
		'requestor',
		'class',
		'selector',
		'literalStream',
		'selectorSet',
		'litIndSet',
		'litSet',
		'sourceRanges',
		'globalSourceRanges',
		'addedExtraLiterals',
		'optimizedSelectors',
		'cue'
	],
	#category : #'Compiler-Kernel'
}

{ #category : #visiting }
Encoder >> accept: aVisitor [
	"I am not really a ParseNode.  Only here to access constants defined in parseNode."
	self shouldNotImplement
]

{ #category : #results }
Encoder >> allLiterals [
	addedExtraLiterals ifFalse:
		[addedExtraLiterals := true.
		"Put the optimized selectors in literals so as to browse senders more easily"
		optimizedSelectors := optimizedSelectors reject: [:e| literalStream originalContents hasLiteral: e].
		optimizedSelectors isEmpty ifFalse: [
			"Use one entry per literal if enough room, else make anArray"
			literalStream position + optimizedSelectors size + 2 >= self maxNumLiterals
				ifTrue: [self litIndex: optimizedSelectors asArray]
				ifFalse: [optimizedSelectors do: [:e | self litIndex: e]]].
		"Add a slot for selector or MethodProperties"
		self litIndex: nil.
		self litIndex: self associationForClass].
	^literalStream contents
]

{ #category : #results }
Encoder >> associationForClass [
	| assoc |
	assoc := self environment associationAt: cue getClass name ifAbsent: [nil].
	^assoc value == cue getClass
		ifTrue: [assoc]
		ifFalse: [Association new value: cue getClass]
]

{ #category : #temps }
Encoder >> autoBind: name [ 
	"Declare a block argument as a temp if not already declared."
	| node |
	node := scopeTable 
			at: name
			ifAbsent: 
				[(self lookupInPools: name ifFound: [:assoc | assoc])
					ifTrue: [self warnAboutShadowed: name].
				^ (self reallyBind: name) nowHasDef nowHasRef scope: 1].
	node isTemp
		ifTrue: [node scope >= 0 ifTrue:
					[^ self notify: 'Name already used in this method'].
				node nowHasDef nowHasRef scope: 1]
		ifFalse: [^ self notify: 'Name already used in this class'].
	^node
]

{ #category : #temps }
Encoder >> bindArg: name [ 
	"Declare an argument."
	| node |
	nTemps >= 15
		ifTrue: [^self notify: 'Too many arguments'].
	node := self bindTemp: name.
	^ node nowHasDef nowHasRef
]

{ #category : #temps }
Encoder >> bindBlockArg: name within: aBlockNode [
	"With standard Smalltalk-80 (BlueBook) blocks it used to be legal to use a
	 method temp as a block argument.  This shouldn't be the case with the
	 current compiler, which checks for temp names already being used as
	 block arguments.  But it is easily fooled by local block temps in optimized
	 blocks, e.g.
		false
			ifTrue: [| temp |]
			ifFalse:[[:temp|]]
	Rather than fix this we keep the semantics and fix it in the closure compiler."
	^self autoBind: name
]

{ #category : #temps }
Encoder >> bindBlockTemp: name [ 
	"Declare a temporary block variable; complain if it's not a field or class variable."

	| node |

	node := scopeTable at: name ifAbsent: [^self reallyBind: name].
	node isTemp
		ifTrue: [
			node scope >= 0 ifTrue: [^ self notify: 'Name already used in this method'].
			node scope: 0]
		ifFalse: [^self notify: 'Name already used in this class'].
	^node

]

{ #category : #temps }
Encoder >> bindBlockTemp: name within: aBlockNode [
	"The BlockContext compiler (the Smalltalk-80 BlueBook compiler)
	 does provide support for ANSI block syntax, but not for ANSI block
	 semantics.  Here all temps live at the same level, the method level.
	 The approach taken to two block-local temps in different blocks is to
	 merge them into a single temp.  e.g.
		expr
			ifTrue: [|temp| self statementOne]
			ifFalse: [|temp| self statementTwo]
	 is effectvely transformed into
		| temp |
		expr
			ifTrue: [self statementOne]
			ifFalse: [self statementTwo]
	 and
		expr do: [:each| | temp | ...].
		expr do: [:each| | temp | ...].
	 is also effectively transformed into
		| temp |
		expr do: [:each|  ...].
		expr do: [:each| ...].

	 The closure compiler treats the former similarly, but not the latter.
	 The indirection through #bindBlockTemp:within: allows the closure encoder to do this."
	^self bindBlockTemp: name
]

{ #category : #temps }
Encoder >> bindTemp: name [ 
	"Declare a temporary; error not if a field or class variable."
	scopeTable at: name ifPresent:[:node|
		"When non-interactive raise the error only if its a duplicate"
		node isTemp
			ifTrue:[^self notify:'Name already used in this method']
			ifFalse:[self warnAboutShadowed: name]].
	^self reallyBind: name
]

{ #category : #temps }
Encoder >> bindTemp: name in: methodSelector [
	"Declare a temporary; error not if a field or class variable."
	scopeTable at: name ifPresent:[:node|
		"When non-interactive raise the error only if its a duplicate"
		(node isTemp or:[requestor interactive])
			ifTrue:[^self notify:'Name already used in this method']
			ifFalse:[Transcript 
				show: '(', name, ' is shadowed in "' , cue getClass printString , '>>' , methodSelector printString , '")']].
	^self reallyBind: name
]

{ #category : #private }
Encoder >> bindUndeclaredTemp: name [
	^scopeTable at: name put: (self newUndeclaredTemp: name)
]

{ #category : #encoding }
Encoder >> cantStoreInto: varName [

	^StdVariables includesKey: varName
]

{ #category : #private }
Encoder >> classEncoding [
	"This is a hack so that the parser may findout what class it was parsing for when it wants to create a syntax error view."
	^ cue getClass
]

{ #category : #encoding }
Encoder >> doItInContextName [
	^'ThisContext'
]

{ #category : #encoding }
Encoder >> encodeLiteral: object [
	^self
		name: object
		key: object
		class: LiteralNode
		type: LdLitType
		set: litSet
]

{ #category : #encoding }
Encoder >> encodeSelector: aSelector [

	^self
		name: aSelector
		key: aSelector
		class: SelectorNode
		type: SendType
		set: selectorSet
]

{ #category : #encoding }
Encoder >> encodeVariable: name [
	^ self encodeVariable: name sourceRange: nil ifUnknown: [ self undeclared: name ]
]

{ #category : #encoding }
Encoder >> encodeVariable: name ifUnknown: action [
	^self encodeVariable: name sourceRange: nil ifUnknown: action
]

{ #category : #encoding }
Encoder >> encodeVariable: name sourceRange: range ifUnknown: action [
	| varNode |
	varNode := scopeTable
					at: name
					ifAbsent: 
						[(self lookupInPools: name 
							ifFound: [:assoc | varNode := self global: assoc name: name])
							ifTrue: [varNode]
							ifFalse: [^action value]].
	range ifNotNil:
		[name first canBeGlobalVarInitial ifTrue:
			[globalSourceRanges addLast: { name. range. false }]].

	(varNode isTemp and: [varNode scope < 0]) ifTrue:
		[^OutOfScopeNotification signal
			ifTrue: [action value]
			ifFalse: [self notify: 'out of scope']].
	^varNode
]

{ #category : #encoding }
Encoder >> environment [
	"Answer the environment of the current compilation context,
	 be it in a class or global (e.g. a workspace)"
	^cue environment
]

{ #category : #'initialize-release' }
Encoder >> fillDict: dict with: nodeClass mapping: keys to: codeArray [
	| codeStream |
	codeStream := ReadStream on: codeArray.
	keys do: 
		[:key | dict 
				at: key
				put:  (nodeClass new name: key key: key code: codeStream next)]
]

{ #category : #temps }
Encoder >> fixTemp: name [
	| node |
	node := scopeTable at: name ifAbsent: [].
	(node isTemp and: [node isIndirectTempVector not]) ifFalse:
		[self error: 'can only fix a floating temp var'].
	node index: nTemps.
	nTemps := nTemps + 1.
	^node
]

{ #category : #temps }
Encoder >> floatTemp: node [
	(node == (scopeTable at: node name ifAbsent: [])
	 and: [node isTemp
	 and: [node index = (nTemps - 1)]]) ifFalse:
		[self error: 'can only float the last allocated temp var'].
	nTemps := nTemps - 1
]

{ #category : #private }
Encoder >> global: ref name: name [

	^self
		name: name
		key: ref
		class: LiteralVariableNode
		type: LdLitIndType
		set: litIndSet
]

{ #category : #'source mapping' }
Encoder >> globalSourceRanges [

	^ globalSourceRanges
]

{ #category : #'initialize-release' }
Encoder >> init: aCue notifying: anObject [
	"The use of the variable requestor is a bit confusing here. This is
	*not* the original requestor, which is available through the cue.
	It's the Parser instance that is using the encoder."

	self setCue: aCue.
	requestor := anObject.
	nTemps := 0.
	supered := false.
	self initScopeAndLiteralTables.
	cue getClass variablesAndOffsetsDo:
		[:variable "<String|CFieldDefinition>" :offset "<Integer|nil>" |
		offset isNil
			ifTrue: [scopeTable at: variable name put: (FieldNode new fieldDefinition: variable)]
			ifFalse: [scopeTable
						at: variable
						put: (offset >= 0
								ifTrue: [InstanceVariableNode new
											name: variable index: offset]
								ifFalse: [MaybeContextInstanceVariableNode new
											name: variable index: offset negated])]].
	cue context ifNotNil:
		[| homeNode |
		 homeNode := self bindArg: self doItInContextName.
		 "0th temp = aContext passed as arg"
		 cue context tempNames withIndexDo:
			[:variable :index|
			variable ~= self doItInContextName ifTrue:
				[scopeTable
					at: variable
					put: (MessageAsTempNode new
							receiver: homeNode
							selector: #namedTempAt:
							arguments: (Array with: (self encodeLiteral: index))
							precedence: 3
							from: self)]]].
	sourceRanges := Dictionary new: 32.
	globalSourceRanges := OrderedCollection new: 32
]

{ #category : #'initialize-release' }
Encoder >> initScopeAndLiteralTables [

	scopeTable := StdVariables copy.
	litSet := StdLiterals copy.
	"comments can be left hanging on nodes from previous compilations.
	 probably better than this hack fix is to create the nodes afresh on each compilation."
	scopeTable do:
		[:varNode| varNode comment: nil].
	litSet do:
		[:varNode| varNode comment: nil].
	selectorSet := StdSelectors copy.
	litIndSet := Dictionary new: 16.
	literalStream := WriteStream on: (Array new: 32).
	addedExtraLiterals := false.
	optimizedSelectors := Set new
]

{ #category : #private }
Encoder >> interactive [
	"Answer true if compilation is interactive"

	^requestor interactive
]

{ #category : #encoding }
Encoder >> litIndex: literal [
	| p |
	p := literalStream position.
	p = self maxNumLiterals ifTrue:
		[self notify: 'More than ', self maxNumLiterals printString, ' literals referenced.\You must split or otherwise simplify this method.\The ' withCRs, (self maxNumLiterals + 1) printString, 'th literal is: ', literal printString. ^nil].
	literal isLiteral ifTrue: "filters out BlockClosures, ExternalLibraryFunctions"
		[self setReadOnlyIfAppropriate: literal].
	"Would like to show where it is in the source code, but that info is hard to get."
	literalStream nextPut: literal.
	^p
]

{ #category : #results }
Encoder >> literals [
	"Should only be used for decompiling primitives"
	^ literalStream contents
]

{ #category : #private }
Encoder >> lookupInPools: varName ifFound: assocBlock [

	^Symbol
		hasInterned: varName
		ifTrue:
			[:sym|
			(cue bindingOf: sym)
				ifNil: [^false]
				ifNotNil: [:assoc| assocBlock value: assoc]]
]

{ #category : #encoding }
Encoder >> lookupVariable: name ifAbsent: aBlock [
	"Answer the binding of name in the scope table or aBlock's vaue if none.
	 Do not bind and do not lookup in pools.  Used for correction, explanation etc"
	^scopeTable at: name ifAbsent: aBlock
]

{ #category : #accessing }
Encoder >> maxIndexableLiterals [
	"Answer the maximum number of literals supported by the receiver's
	 bytecode set. This is a nominal value based on the Blue Book bytecode
	 set; subclasses answer a more accurate value."
	^63
]

{ #category : #accessing }
Encoder >> maxNumLiterals [
	^CompiledMethod maxNumLiterals min: self maxIndexableLiterals
]

{ #category : #temps }
Encoder >> maxTemp [

	^nTemps
]

{ #category : #accessing }
Encoder >> methodNodeClass [
	^MethodNode
]

{ #category : #private }
Encoder >> name: name key: key class: leafNodeClass type: type set: dict [ 
	^dict at: key
		ifAbsentPut: 
			[leafNodeClass new 
				name: name
				key: key
				index: nil
				type: type]
]

{ #category : #temps }
Encoder >> newTemp: name [

	nTemps := nTemps + 1.
	^ TempVariableNode new
		name: name
		index: nTemps - 1
		type: LdTempType
		scope: 0
]

{ #category : #temps }
Encoder >> newUndeclaredTemp: name [
	^UndeclaredVariableNode new name: name
]

{ #category : #encoding }
Encoder >> noteOptimizedSelector: aSymbol [
	"Register a selector as being optimized.
	These optimized selectors will later be registered into the literals so that tools can easily browse senders."
	optimizedSelectors add: aSymbol
]

{ #category : #'source mapping' }
Encoder >> noteSourceRange: range forNode: node [

	sourceRanges at: node put: range
]

{ #category : #'initialize-release' }
Encoder >> noteSuper [

	supered := true
]

{ #category : #'error handling' }
Encoder >> notify: string [
	"Put a separate notifier on top of the requestor's window"
	| req |
	requestor == nil
		ifFalse: 
			[req := requestor.
			self release.
			req notify: string].
	^false
]

{ #category : #'error handling' }
Encoder >> notify: string at: location [

	| req |
	requestor == nil
		ifFalse: 
			[req := requestor.
			self release.
			req notify: string at: location].
	^false
]

{ #category : #private }
Encoder >> possibleNamesFor: proposedName [
	| results |
	results := cue getClass 
		possibleVariablesFor: proposedName 
		continuedFrom: nil.
	^ proposedName correctAgainst: nil continuedFrom: results.

]

{ #category : #private }
Encoder >> possibleVariablesFor: proposedVariable [

	| results |
	results := proposedVariable correctAgainstDictionary: scopeTable
								continuedFrom: nil.
	proposedVariable first canBeGlobalVarInitial ifTrue:
		[ results := cue getClass possibleVariablesFor: proposedVariable
						continuedFrom: results ].
	^ proposedVariable correctAgainst: nil continuedFrom: results.

]

{ #category : #'source mapping' }
Encoder >> rawSourceRanges [

	^ sourceRanges 
]

{ #category : #private }
Encoder >> reallyBind: name [

	| node |
	node := self newTemp: name.
	scopeTable at: name put: node.
	^node
]

{ #category : #'initialize-release' }
Encoder >> release [

	requestor := nil
]

{ #category : #accessing }
Encoder >> selector [
	^selector
]

{ #category : #accessing }
Encoder >> selector: aSymbol [
	selector := aSymbol
]

{ #category : #private }
Encoder >> setCue: aCue [
	cue := aCue.
	
	"Also set legacy instance variables for methods that
	don't use cue yet"
	class := cue getClass.
]

{ #category : #encoding }
Encoder >> setReadOnlyIfAppropriate: literal [
	"If literal is not read-only and should be, set it to be read-only, along with any other such literals it may contain."
	(literal isReadOnlyObject
	 or: [literal isVariableBinding]) ifFalse:
		[literal setIsReadOnlyObject: true.
		 literal isArray ifTrue:
			[literal do: [:subLiteral| self setReadOnlyIfAppropriate: subLiteral]]]
]

{ #category : #encoding }
Encoder >> sharableLitIndex: literal [
	"Special access prevents multiple entries for post-allocated super send special selectors"
	1 to: literalStream position do:
		[:index|
		(literal literalEqual: (literalStream originalContents at: index)) ifTrue:
			[^index - 1]].
	^self litIndex: literal
]

{ #category : #'source mapping' }
Encoder >> sourceMap [
	"Answer with a sorted set of associations (pc range)."

	^sourceRanges associations
		replace: [ :association | 	Association key: association key pc value: association value ];
		sort
]

{ #category : #'source mapping' }
Encoder >> sourceRangeFor: node [

	^sourceRanges at: node
]

{ #category : #results }
Encoder >> tempNames [ 

	^ self tempNodes collect:
		[:node | (node isMemberOf: MessageAsTempNode)
					ifTrue: [scopeTable keyAtValue: node]
					ifFalse: [node key]]
]

{ #category : #results }
Encoder >> tempNodes [

	| tempNodes |
	tempNodes := OrderedCollection new.
	scopeTable associationsDo:
		[:assn |
		assn value isArray
			ifTrue: [assn value do: [:temp| tempNodes add: temp]]
			ifFalse: [assn value isTemp ifTrue: [tempNodes add: assn value]]].
	^tempNodes sort: [:n1 :n2 | n1 index <= n2 index]
]

{ #category : #'initialize-release' }
Encoder >> temps: tempVars literals: lits class: cl [ 
	"Initialize this encoder for decompilation."

	self setCue: (CompilationCue class: cl).
	supered := false.
	nTemps := tempVars size.
	tempVars do: [:node | scopeTable at: node name put: node].
	literalStream := WriteStream on: (Array new: lits size).
	literalStream nextPutAll: lits.
	sourceRanges := Dictionary new: 32.
	globalSourceRanges := OrderedCollection new: 32.
]

{ #category : #results }
Encoder >> tempsAndBlockArgs [
	| tempNodes |
	tempNodes := OrderedCollection new.
	scopeTable associationsDo:
		[:assn | | var |
		var := assn value.
		(var isTemp
		 and: [var isMethodArg not
		 and: [var scope = 0 or: [var scope = -1]]]) ifTrue:
			[tempNodes add: var]].
	^tempNodes
]

{ #category : #encoding }
Encoder >> undeclared: name [ 
	| sym |
	(requestor notNil and: [requestor interactive]) ifTrue:
		[ requestor requestor == #error: ifTrue: [ requestor error: 'Undeclared' ].
		^ self notify: 'Undeclared' ].
	"Allow knowlegeable clients to squash the undeclared warning if they want (e.g.
	 Diffing pretty printers that are simply formatting text).  As this breaks
	 compilation it should only be used by clients that want to discard the result
	 of the compilation.  To squash the warning use e.g.
		[Compiler format: code in: class notifying: nil decorated: false]
			on: UndeclaredVariableWarning
			do: [:ex| ex resume: false]"
	sym := name asSymbol.
	^ (UndeclaredVariableWarning new
		name: name
		selector: selector
		class: cue getClass) signal
		ifTrue:
			[ | undeclared |
			undeclared := cue environment undeclared.
			[ undeclared
				at: sym
				put: nil ]
				on: AttemptToWriteReadOnlyGlobal
				do: [ : noti | noti resume: true ].
			self
				global: (undeclared associationAt: sym)
				name: sym ]
		ifFalse:
			[ self
				global: (Association key: sym)
				name: sym ]
]

{ #category : #results }
Encoder >> undeclaredTemps [ 
	^(scopeTable select: [:var | var isVariableNode and: [var isUndeclared]]) values
]

{ #category : #results }
Encoder >> unusedTempNames [ 
	| unused |
	unused := OrderedCollection new.
	scopeTable associationsDo:
		[:assn | | name |
		(assn value isUnusedTemp) ifTrue:
			[name := assn value key.
			 name ~= self doItInContextName ifTrue: [unused add: name]]].
	^ unused
]

{ #category : #private }
Encoder >> warnAboutShadowed: name [
	requestor addWarning: name,' is shadowed'.
	selector ifNotNil:
		[Transcript cr; show: cue getClass name,'>>', selector, '(', name,' is shadowed)']
]
