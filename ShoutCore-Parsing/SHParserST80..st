"
I am a Smalltalk method / expression parser.

Rather than creating an Abstract Syntax Tree, I create a sequence of SHRanges (in my 'ranges' instance variable), which represent the tokens within the String I am parsing.

I am used by a SHTextStylerST80 to parse method source strings.
I am able to parse incomplete / incorrect methods, and so can be used to parse methods that are being edited.

Instance Variables
	allowBlockArgumentAssignment:		<Boolean>
	allowUnderscoreAssignments:		<Boolean>
	allowUnderscoreSelectors:		<Boolean>
	arguments:		<OrderedCollection<OrderedCollection<String>|nil>
	bracketDepth:		<Integer>
	classOrMetaClass:		<Class|nil>
	currentToken:		<String|nil>
	currentTokenFirst:		<Character>
	currentTokenSourcePosition:		<Integer|nil>
	currentTokenType:		<Symbol|nil>
	environment:		<Environment>
	errorBlock:		<Block>
	instanceVariables:		<Array>
	parseAMethod:		<Boolean>
	ranges:		<OrderedCollection<SHRange>>
	source:		<String>
	sourcePosition:		<Integer>
	temporaries:		<OrderedCollection<OrderedCollection<String>|nil>
	workspace:		<Workspace|nil>
	context:		<Context|nil>

allowBlockArgumentAssignment
	The value cached at the beginning of parsing of Scanner allowBlockArgumentAssignment.

allowUnderscoreAssignments
	The value cached at the beginning of parsing of Scanner allowUnderscoreAsAssignment.

allowUnderscoreSelectors
	The value cached at the beginning of parsing of Scanner prefAllowUnderscoreSelectors.

arguments
	This OrderedCollection has an element for each scope encapsulating the current scope.
	The current scope's arguments are stored in the last element. The first element holds the outermost scope's arguments.
	Each element is nil when the corresponding scope doesn't have any arguments, and the element is an OrderedCollection with the names of the arguments declared at the given scope when there's at least one.
	The size of this variable is the same as the size of temporaries.

bracketDepth
	Stores the number of unclosed brackets ""(""  and parentheses ""["" before the current sourcePosition.

classOrMetaClass
	The Class or MetaClass instance, class and pool variables should be looked up during parsing or nil when not parsing code in the context of a class (e.g. when parsing code written in a Workspace). Having this set doesn't mean a method is being parsed.

currentToken
	The token being analyzed for which the next range should be created for.

currentTokenFirst
	The first character of currentToken cached for quick access or a space character when there are no more tokens to parse.
	Being always a Character helps avoiding extra checks.

currentTokenSourcePosition
	The position of source the current token starts at or nil when there are no more tokens to process.

currentTokenType
	The type of the current token calculated lazily by #currentTokenType. When it has been calculated, Its value is one of #keyword, #assignment, #ansiAssignment, #binary, #name, #other and occasionally #invalid.

environment
	The Environment globals and classes should be looked up at during parsing when classOrMetaClass is nil. Its value is Smalltalk globals by default.

errorBlock
	A block used to quickly stop parsing in case of an unrecoverable parse error.

instanceVariables
	An Array with the instance variable names of classOrMetaClass or an empty Array when classOrMetaClass is nil.

parseAMethod
	A way to tell the parser to parse source as a code snippet instead of a method. Mainly used by inspectors.

ranges
	The SHRanges parsed by the parser.

source
	The source code as a String to be parsed.

sourcePosition
	souce is treated as a stream by the parser. This variable stores the stream position.

temporaries
	This OrderedCollection has an element for each scope encapsulating the current scope.
	The current scope's temporaries are stored in the last element. The first element holds the outermost scope's temporaries.
	Each element is nil when the corresponding scope doesn't have any temporary variables, and the element is an OrderedCollection with the names of the temporaries declared at the given scope when there's at least one.
	The size of this variable is the same as the size of arguments.

workspace
	The Workspace in whose context variables should be looked up during parsing or nil when not parsing code in a workspace.

context
	The Context in which variables should be looked up during parsing or nil when not parsing within a context.

Example (explore it):

	ranges := SHParserST80 new
		classOrMetaClass: Object;
		source: 'testMethod ^self';
		parse;
		ranges
		
Benchmark (print it):

	SHParserST80 benchmark
"
Class {
	#name : #SHParserST80,
	#superclass : #Object,
	#instVars : [
		'classOrMetaClass',
		'source',
		'workspace',
		'arguments',
		'sourcePosition',
		'currentToken',
		'currentTokenFirst',
		'temporaries',
		'instanceVariables',
		'errorBlock',
		'currentTokenSourcePosition',
		'bracketDepth',
		'ranges',
		'environment',
		'allowUnderscoreAssignments',
		'allowUnderscoreSelectors',
		'allowBlockArgumentAssignment',
		'parseAMethod',
		'currentTokenType',
		'context'
	],
	#category : #'ShoutCore-Parsing'
}

{ #category : #benchmarking }
SHParserST80 class >> benchmark [

	| methods methodCount totalTime averageTime min median percentile80 percentile95 percentile99 max |
	Smalltalk garbageCollect.
	methods := OrderedCollection new: 100000.
	CurrentReadOnlySourceFiles cacheDuring: [
		| parser |
		parser := SHParserST80 new.
		SystemNavigation default allSelectorsAndMethodsDo: [ :class :selector :method |
			| source start ranges |
			source := method getSource asString.
			start := Time utcMicrosecondClock.
			ranges := parser
				rangesIn: source
				classOrMetaClass: class
				workspace: nil
				environment: nil.
			methods addLast: { Time utcMicrosecondClock - start. method. ranges size } ] ].
	methods sort: #first asSortFunction.
	methodCount := methods size.
	totalTime := methods detectSum: #first.
	averageTime := (totalTime / methodCount) rounded.
	
	min := methods first.
	median := methods at: methodCount // 2.
	percentile80 := methods at: (methodCount * 0.8) floor.
	percentile95 := methods at: (methodCount * 0.95) floor.
	percentile99 := methods at: (methodCount * 0.99) floor.
	max := methods last.
	^'
	Methods		{1}
	Total			{2}ms
	Average		{3}ms
	Min				{4}ms {5} range(s) ({6})
	Median			{7}ms {8} ranges ({9})
	80th percentile	{10}ms {11} ranges ({12})
	95th percentile	{13}ms {14} ranges ({15})
	99th percentile	{16}ms {17} ranges ({18})
	Max			{19}ms {20} ranges ({21})' format: ({
		methodCount asString.
		totalTime.
		averageTime.
		min first.
		min third asString.
		min second reference.
		median first.
		median third asString.
		median second reference.
		percentile80 first.
		percentile80 third asString.
		percentile80 second reference.
		percentile95 first.
		percentile95 third asString.
		percentile95 second reference.
		percentile99 first.
		percentile99 third asString.
		percentile99 second reference.
		max first.
		max third asString.
		max second reference } replace: [ :each |
			each isNumber 
				ifTrue: [ (each / 1000) printShowingDecimalPlaces: 3 ]
				ifFalse: [ each ] ])
]

{ #category : #'instance creation' }
SHParserST80 class >> new [
	^super new
		initialize;
		yourself
]

{ #category : #accessing }
SHParserST80 >> activeArguments [
	"Parsed arguments that are in the active scope"
	^ arguments
]

{ #category : #accessing }
SHParserST80 >> activeTemporaries [
	"Parsed temporaries that are in the active scope"
	^ temporaries
]

{ #category : #'recording ranges' }
SHParserST80 >> addRangeType: aSymbol [

	^self
		addRangeType: aSymbol
		start: currentTokenSourcePosition
		end: currentTokenSourcePosition + currentToken size - 1
]

{ #category : #'recording ranges' }
SHParserST80 >> addRangeType: aSymbol start: s end: e [

	^ranges addLast: (SHRange start: s end: e type: aSymbol)
]

{ #category : #accessing }
SHParserST80 >> classOrMetaClass: aClass [
    classOrMetaClass := aClass
]

{ #category : #scan }
SHParserST80 >> currentChar [
	^source at: sourcePosition ifAbsent: nil
]

{ #category : #'parse support' }
SHParserST80 >> currentTokenType [
	"Cache and return the type of currentToken of #(name keyword binary assignment ansiAssignment other)"
	
	^currentTokenType ifNil: [
		currentTokenType := currentToken ifNotNil: [ 
			currentTokenFirst isLetter
				ifFalse: [
					currentTokenFirst == $_
						ifTrue: [
							(allowUnderscoreSelectors
								and: [ currentToken size > 1
								and: [ currentToken last == $: ] ])
								ifTrue: [ #keyword ]
								ifFalse: [
									(allowUnderscoreAssignments and: [ currentToken = '_' ]) ifTrue: [
										#assignment ] ] ]
						ifFalse: [ 
							currentToken = ':='
								ifTrue: [ #ansiAssignment ]
								ifFalse: [
									(currentToken allSatisfy: [ :each | self isSelectorCharacter: each ]) ifTrue: [ #binary ] ] ] ]
				ifTrue: [ 
					currentToken last == $:
						ifTrue: [ #keyword ]
						ifFalse: [
							(currentToken last isAlphaNumeric or: [
								allowUnderscoreSelectors and: [
									currentToken last == $_ ] ])
								ifTrue: [ #name ] ] ] ].
		currentTokenType ifNil: [ currentTokenType := #other ] ]
]

{ #category : #accessing }
SHParserST80 >> environment: anObject [
	environment := anObject
]

{ #category : #'error handling' }
SHParserST80 >> fail [

	| start |
	start := (ranges isEmpty ifTrue: [ 1 ] ifFalse: [ ranges last end + 1 ]).
	start <= source size ifTrue: [
		self
			addRangeType: #excessCode
			start: start
			end: source size ].
	errorBlock value
]

{ #category : #'error handling' }
SHParserST80 >> failUnless: aBoolean [
	aBoolean ifFalse:[self fail]

]

{ #category : #'error handling' }
SHParserST80 >> failWhen: aBoolean [
	aBoolean ifTrue:[self fail]
]

{ #category : #accessing }
SHParserST80 >> initialize [
	environment := Smalltalk globals.
]

{ #category : #'parse support' }
SHParserST80 >> initializeInstanceVariables [

	instanceVariables := classOrMetaClass 
		ifNil: [ #() ]
		ifNotNil: [ classOrMetaClass allInstVarNames asArray ].
	allowUnderscoreAssignments := Scanner allowUnderscoreAsAssignment.
	allowUnderscoreSelectors := Scanner prefAllowUnderscoreSelectors.
	allowBlockArgumentAssignment := Scanner allowBlockArgumentAssignment.
	sourcePosition := 1.
	arguments
		ifNil: [ arguments := OrderedCollection with: nil ]
		ifNotNil: [ arguments reset; addLast: nil ].
	temporaries
		ifNil: [ temporaries := OrderedCollection with: nil ]
		ifNotNil: [ temporaries reset; addLast: nil ].
	context ifNotNil: [ self initializeVariablesFromContext ].
	bracketDepth := 0.
	ranges
		ifNil: [ ranges := OrderedCollection new: 40 "Covers over 80% of all methods." ]
		ifNotNil: [ ranges reset ]
]

{ #category : #'parse support' }
SHParserST80 >> initializeVariablesFromContext [

	| contextSourcePcIndex contextSource contextSourceParser |
	contextSourcePcIndex := (context debuggerMap
		rangeForPC: (context isDead ifTrue: [context endPC] ifFalse: [context pc])
		in: context method
		contextIsActiveContext: true "... to really use the context's pc.")
			start.
	contextSource := context method getSource.
	contextSourceParser := self class new
		classOrMetaClass: context method methodClass;
		environment: self environment;
		source: (contextSource first: (contextSourcePcIndex min: contextSource size));
		yourself.
	contextSourceParser parse.
	arguments := contextSourceParser activeArguments.
	temporaries  := contextSourceParser activeTemporaries
]

{ #category : #'character testing' }
SHParserST80 >> isDigit: aCharacter base: anInteger [
    "Answer true if aCharacter is a digit or a capital letter appropriate for base anInteger"

	| digitValue |
	^(digitValue := aCharacter digitValue) >= 0 and: [
		digitValue < anInteger ]
]

{ #category : #'character testing' }
SHParserST80 >> isSelectorCharacter: aCharacter [

	| asciiValue |
	('"#$'':().;[]{}^_'  includes: aCharacter) ifTrue: [ ^false ].
	aCharacter isSeparator ifTrue:[ ^false ].
	aCharacter isAlphaNumeric ifTrue: [ ^false ].
	(asciiValue := aCharacter asciiValue) = 30 ifTrue: [ ^false "the doIt char" ].
	^asciiValue ~= 0 "Any other char, but 0 is ok as a binary selector char."

]

{ #category : #scan }
SHParserST80 >> nextChar [
	
	^source at: (sourcePosition := sourcePosition + 1) ifAbsent: $ 
]

{ #category : #parse }
SHParserST80 >> parse [
	"Parse the receiver's text as a Smalltalk method"

	self parse: (parseAMethod ifNil: [ classOrMetaClass notNil ]).
	errorBlock := nil
]

{ #category : #parse }
SHParserST80 >> parse: isAMethod [ 
	"Parse the receiver's text. If isAMethod is true then treat text as a method, if false as an expression with no message pattern"

	self initializeInstanceVariables.
	errorBlock := [^false]. "This must be defined in this method, as the goal is to return from this method in case of an error."
	self scanNext.
	isAMethod ifTrue: [
		self
			parseMessagePattern;
			parsePragmaSequence ].
	self parseTemporaries.
	isAMethod ifTrue: [ self parsePragmaSequence ].
	self parseStatementList.
	currentToken ifNotNil: [ self fail ].
	^true
]

{ #category : #accessing }
SHParserST80 >> parseAMethod: aBoolean [

	parseAMethod := aBoolean
]

{ #category : #parse }
SHParserST80 >> parseArgument: expectedArgumentType [
	"Add currentToken to the current scope as argument. Scan past expectedArgumentType if the argument is valid."

	self currentTokenType == #name ifFalse: [ self fail ": name expected" ].
	(self reservedKeywordNames includes: currentToken) ifTrue: [
		"Reserved keyword"
		^self scanPast: #invalid ].
	
	1 to: arguments size do: [ :index |
		(arguments at: index) ifNotNil: [ :scopeArguments |
			(scopeArguments includes: currentToken) ifTrue: [
				"Name is already used."
				^self scanPast: #invalid ] ].
		(temporaries at: index) ifNotNil: [ :scopeTemporaries |
			(scopeTemporaries includes: currentToken) ifTrue: [
				"Name is already used."
				^self scanPast: #invalid ] ] ].
	
	arguments last 
		ifNil: [ arguments atLast: 1 put: (OrderedCollection with: currentToken) ]
		ifNotNil: [ :scopeArguments | scopeArguments addLast: currentToken ].
	^self scanPast: expectedArgumentType
]

{ #category : #parse }
SHParserST80 >> parseArray [
	[currentTokenFirst == $)] whileFalse: [self parseLiteralArrayElement].
	self scanPast: #arrayEnd
]

{ #category : #parse }
SHParserST80 >> parseBinary [ 

	self parseUnary.
	[ self currentTokenType == #binary ] 
		whileTrue: [
			self scanPast: (
				(Symbol lookup: currentToken)
					ifNotNil: [ #binary ]
					ifNil: [
						(Symbol thatStartsCaseSensitive: currentToken skipping: nil)
							ifNil: [ #undefinedBinary ]
							ifNotNil:[ #incompleteBinary ] ]). 	
			self
				parseTerm;
				parseUnary ]
]

{ #category : #parse }
SHParserST80 >> parseBinaryMessagePattern [

	self
		scanPast: #patternBinary;
		parseArgument: #patternArg
]

{ #category : #parse }
SHParserST80 >> parseBlock [

	arguments addLast: nil.
	temporaries addLast: nil.
	bracketDepth := bracketDepth + 1.
	self 
		scanPastBracket: #blockStart;
		parseBlockArguments;
		parseTemporaries;
		parseStatementList;
		failUnless: currentTokenFirst == $];
		scanPastBracket: #blockEnd.
	bracketDepth := bracketDepth - 1.
	arguments removeLast.
	temporaries removeLast
]

{ #category : #parse }
SHParserST80 >> parseBlockArguments [

	currentTokenFirst == $: ifFalse: [ ^self ].
	[ currentTokenFirst == $: ] whileTrue: [
		self
			scanPast: #blockArgColon;
			parseArgument: #blockPatternArg ].
	(self parseVerticalBarForTemporaries: #blockArgsBar) ifFalse: [
		self fail ": Missing block args bar" ]
]

{ #category : #parse }
SHParserST80 >> parseBraceArray [
	self parseStatementListForBraceArray.
	self failUnless: currentTokenFirst == $}.
	self scanPast: #rightBrace
]

{ #category : #parse }
SHParserST80 >> parseByteArray [

	[currentTokenFirst == $]] whileFalse: [
		currentTokenFirst isDigit
			ifTrue: [
				"do not parse the number, can be time consuming"
				self scanPast: #number]
			ifFalse: [ self fail ] ].
	self scanPast: #byteArrayEnd
]

{ #category : #parse }
SHParserST80 >> parseCascade [
	self parseKeyword.
	[currentTokenFirst == $;] 
		whileTrue: [
			self scanPast: #cascadeSeparator.
			self parseKeyword]
]

{ #category : #parse }
SHParserST80 >> parseCharSymbol [
	| s e |
	s := sourcePosition - 1.
	e := sourcePosition.
	self nextChar.
	self scanPast: #symbol start: s end: e
]

{ #category : #parse }
SHParserST80 >> parseExpression [

	| identifierType |
	self currentTokenType == #name ifFalse: [
		^self
			parseTerm;
			parseCascade ].
	self scanPast: (identifierType := self parseIdentifier).
	(self currentTokenType == #ansiAssignment or: [ currentTokenType == #assignment ])					
		ifFalse: [ ^self parseCascade ].
	(identifierType == #methodArg
		or: [ (identifierType == #blockArg
			and: [ allowBlockArgumentAssignment not ])
		or: [ self reservedKeywordNames includes: identifierType ] ])
		ifTrue: [
			"Cannot store into those variables."
			currentTokenType := #invalid ].
	self 
		scanPast: currentTokenType;
		parseExpression
]

{ #category : #'identifier testing' }
SHParserST80 >> parseIdentifier [
	"currentToken is either a name of an existing variable, a prefix of a variable or an undefined identifier. Return the appropriate range type for it."

	currentToken = #self ifTrue: [ ^#self ].
	currentToken = #true ifTrue: [ ^#true ].
	currentToken = #false ifTrue: [ ^#false ].
	currentToken = #nil ifTrue: [ ^#nil ].
	currentToken = #super ifTrue: [ ^#super ].
	currentToken = #thisContext ifTrue: [ ^#thisContext ].
	
	arguments size to: 1 by: -1 do: [ :level | 
		(arguments at: level) ifNotNil: [ :levelArguments |
			(levelArguments includes: currentToken) ifTrue: [ 
				^level = 1 
					ifTrue: [ #methodArg ]
					ifFalse: [ #blockArg ] ] ].
		(temporaries at: level) ifNotNil: [ :levelTemporaries |
			(levelTemporaries includes: currentToken) ifTrue: [
				^level = 1
					ifTrue: [ #tempVar ]
					ifFalse: [ #blockTempVar ] ] ] ].
		
	(instanceVariables includes: currentToken) ifTrue: [^#instVar].
	
	workspace 
		ifNotNil: [(workspace hasBindingOf: currentToken) ifTrue: [^#workspaceVar]].
	
	(Symbol lookup: currentToken) ifNotNil: [:sym | 
		classOrMetaClass
			ifNotNil: [
				classOrMetaClass theNonMetaClass withAllSuperclassesDo: [:c | 
					(c classPool bindingOf: sym) ifNotNil: [^#classVar].
					c sharedPools do: [:p | (p bindingOf: sym) ifNotNil: [^#poolConstant]].
					(c environment bindingOf: sym) ifNotNil: [^#globalVar]]]
			ifNil: [(environment bindingOf: sym) ifNotNil: [^#globalVar]]].
	^self parsePartialIdentifier
]

{ #category : #parse }
SHParserST80 >> parseKeyword [

	| keyword rangeIndices |
	self parseBinary.
	self currentTokenType == #keyword ifFalse: [ ^self ].
	[
		keyword := currentToken.
		self addRangeType: #keyword.
		rangeIndices := { ranges size }.
		self 
			scanNext;
			parseTerm;
			parseBinary.
    		[self currentTokenType == #keyword]
        		whileTrue: [
				keyword := keyword, currentToken. 
				self addRangeType: #keyword.
				"remember where this keyword token is in ranges"
				rangeIndices := rangeIndices copyWith: ranges size.
				self 
					scanNext;
					parseTerm;
					parseBinary ]
	] ensure: [ | type |
		"do this in an ensure so that it happens even if the errorBlock evaluates before getting here"
		"patch up the keyword tokens, so that incomplete and undefined ones look different"
		(keyword isEmpty or:[(Symbol lookup: keyword) notNil])
			ifFalse:[
				type := (Symbol thatStartsCaseSensitive: keyword skipping: nil)
					ifNil: [#undefinedKeyword]
					ifNotNil:[#incompleteKeyword].
				rangeIndices do: [:i | (ranges at: i) type: type]]]
]

{ #category : #parse }
SHParserST80 >> parseKeywordMessagePattern [   

	[ self currentTokenType == #keyword ] whileTrue: [ 
		self 
			scanPast: #patternKeyword;
			parseArgument: #patternArg ]
]

{ #category : #parse }
SHParserST80 >> parseLiteral: inArray [

	currentTokenFirst == $$ 
		ifTrue: [
			| pos |
			self failWhen: self currentChar isNil.
			self addRangeType: #'$'.
			pos := currentTokenSourcePosition + 1.
			self nextChar.
			^self scanPast: #character start: pos end: pos].
	currentTokenFirst isDigit
		ifTrue: [
			"do not parse the number, can be time consuming"
			^self scanPast: #number].
	currentToken = '-' 
		ifTrue: [
			| c |
			c := self currentChar.
			(inArray and: [c isNil or: [ c isDigit not ]]) 
				ifTrue: [
					"single - can be a symbol in an Array"
					^self scanPast: #symbol].
			self scanPast: #-.
			self failWhen: currentToken isNil.
			"token isNil ifTrue: [self fail: 'Unexpected End Of Input']."
			"do not parse the number, can be time consuming"
			^self scanPast: #number].
	currentTokenFirst == $' ifTrue: [^self parseString].
	currentTokenFirst == $# ifTrue: [^self parseSymbol].
	(inArray and: [currentToken notNil]) ifTrue: [^self scanPast: #symbol].
	self fail ": 'argument missing'"
]

{ #category : #parse }
SHParserST80 >> parseLiteralArrayElement [

	currentTokenFirst isLetter ifTrue: [
		#true = currentToken ifTrue: [ ^self scanPast: #true ].
		#false = currentToken ifTrue: [ ^self scanPast: #false ].
		#nil = currentToken ifTrue: [ ^self scanPast: #nil ].
		^self scanPast: #symbol ].
	currentTokenFirst == $( ifTrue: [
		self scanPast: #arrayStart.
		^self parseArray ].
	^self parseLiteral: true
]

{ #category : #parse }
SHParserST80 >> parseMessagePattern [   

	self currentTokenType 
		caseOf: {
			[ #name ] -> [ self parseUnaryMessagePattern ].
			[ #binary ] -> [ self parseBinaryMessagePattern ].
			[ #keyword ] -> [ self parseKeywordMessagePattern ] }
		otherwise: [ self fail ]
]

{ #category : #'identifier testing' }
SHParserST80 >> parsePartialIdentifier [
	"Decide whether currentToken is an #incompleteIdentifier or an #undefinedIdentifier.
	This method has many different return statements, but only returns two range parts so far.
	It might be changed to return different range types for different variable type prefixes."
	
	(self reservedKeywordNames anySatisfy: [:each | each beginsWith: currentToken]) 
		ifTrue: [^#incompleteIdentifier].

	arguments size to: 1 by: -1 do: [ :level | 
		(arguments at: level) ifNotNil: [ :levelArguments |
			(levelArguments anySatisfy: [ :each | each beginsWith: currentToken ]) ifTrue: [ 
				^level = 1 
					ifTrue: [ #incompleteIdentifier ]
					ifFalse: [ #incompleteIdentifier ] ] ].
		(temporaries at: level) ifNotNil: [ :levelTemporaries |
			(levelTemporaries anySatisfy: [ :each | each beginsWith: currentToken ]) ifTrue: [
				^level = 1
					ifTrue: [ #incompleteIdentifier ]
					ifFalse: [ #incompleteIdentifier ] ] ] ].
	
	(instanceVariables anySatisfy: [:each | each beginsWith: currentToken]) ifTrue: [^#incompleteIdentifier].

	workspace 
		ifNotNil: [(workspace hasBindingThatBeginsWith: currentToken) ifTrue: [^#incompleteIdentifier]].

	classOrMetaClass
		ifNotNil: [
			classOrMetaClass theNonMetaClass withAllSuperclassesDo: [:c | 
				(c classPool hasBindingThatBeginsWith: currentToken) ifTrue: [^#incompleteIdentifier].
				c sharedPools do: [:p | (p hasBindingThatBeginsWith: currentToken) ifTrue: [^#incompleteIdentifier]].
				(c environment hasBindingThatBeginsWith: currentToken) ifTrue: [^#incompleteIdentifier]]]
		ifNil: [(environment hasBindingThatBeginsWith: currentToken) ifTrue: [^#incompleteIdentifier]].
	^#undefinedIdentifier
]

{ #category : #'parse pragma' }
SHParserST80 >> parsePragmaBinary [

	self scanPast: #pragmaBinary.
	self currentTokenType == #name
		ifTrue:[self scanPast: (self resolvePragmaArgument: currentToken)] 
		ifFalse:[	self parseLiteral: false].
	self failUnless: currentToken = '>'.
	self scanPast: #primitiveOrExternalCallEnd
]

{ #category : #'parse pragma' }
SHParserST80 >> parsePragmaDefault [
	"Parse unary, binary, and keyword pragmas."
			
	self currentTokenType
		caseOf: {
			[ #name ] -> [ 
				self scanPast: #pragmaUnary.
				self failUnless: currentToken = '>'.
				self scanPast: #primitiveOrExternalCallEnd ].
			[ #binary ] -> [ self parsePragmaBinary ].
			[ #keyword ] -> [ self parsePragmaKeyword ] }
		otherwise: [ self fail ": 'Invalid External Function Calling convention'" ]. 
]

{ #category : #'parse pragma' }
SHParserST80 >> parsePragmaKeyword [

	[self currentTokenType == #keyword]
		whileTrue:[
			self scanPast: #pragmaKeyword.
			self currentTokenType == #name
				ifTrue:[self scanPast: (self resolvePragmaArgument: currentToken)] 
				ifFalse:[	self parseLiteral: false]].
	self failUnless: currentToken = '>'.
	self scanPast: #primitiveOrExternalCallEnd
]

{ #category : #'parse pragma' }
SHParserST80 >> parsePragmaSequence [

	[currentToken = '<' ]
		whileTrue: [
			self scanPast: #primitiveOrExternalCallStart.
			currentToken
				ifNotNil: [self parsePragmaStatement]
				ifNil: [self fail]].
]

{ #category : #'parse pragma' }
SHParserST80 >> parsePragmaStatement [
	"Parse a pragma statement. The leading '<' has already been consumed. The currentToken is the first one in the pragma. Use that token to dispatch to a custom pragma-parsing method if one can be found with a selector that matches it.
	
	Note that custom pragma parsers need to fulfill two requirements:
		- method selector must match the current token as simple getter,
				e.g., <apicall: ...> matches #apicall or <primitive: ...> matches #primitive
		- method must have pragma <pragmaParser> to be called."

	"1) Do not consider one-word pragmas such as <primitive> and <foobar>. Only keyword pragmas."
	currentToken last == $: ifTrue: [
		"2) Avoid interning new symbols for made-up pragmas such as #my for <my: 1 pragma: 2>."
		(Symbol lookup: currentToken allButLast) ifNotNil: [:parserSelector |
			SHParserST80 methodDict at: parserSelector ifPresent: [:parserMethod |
				"3) Only call methods that claim to be a custom pragma parser via <pragmaParser>."
				(parserMethod hasPragma: #pragmaParser)
					ifTrue: [^ self executeMethod: parserMethod]]]].	

	"X) No custom pragma parser found. Use the default one."
	^ self parsePragmaDefault
]

{ #category : #parse }
SHParserST80 >> parseStatement [
	currentTokenFirst == $^ ifTrue: [self scanPast: #return].
	self parseExpression
]

{ #category : #parse }
SHParserST80 >> parseStatementList [
	
	[[currentTokenFirst == $.] whileTrue: [self scanPast: #statementSeparator].
	(currentToken notNil and: [currentTokenFirst ~~ $]]) 
		ifTrue: [self parseStatement].
	currentTokenFirst == $.] 
			whileTrue: [self scanPast: #statementSeparator]
]

{ #category : #parse }
SHParserST80 >> parseStatementListForBraceArray [
	"same as parseStatementList, but does not allow empty statements e.g {...$a...}.
	A single terminating . IS allowed e.g. {$a.} "

	
	[currentTokenFirst ~~ $} ifTrue: [self parseStatement].
	currentTokenFirst == $.] 
		whileTrue: [self scanPast: #statementSeparator]
]

{ #category : #parse }
SHParserST80 >> parseString [
	
	| stringStart |
	stringStart := sourcePosition - 1.
	[
		(sourcePosition := source indexOf: $' startingAt: sourcePosition) = 0 ifTrue: [
			self
				addRangeType: #unfinishedString start: stringStart end: source size;
				fail ": 'unfinished string'"].
		self peekChar == $'
			ifTrue: [
				sourcePosition := sourcePosition + 1.
				true ]
			ifFalse: [ false ] ] 
		whileTrue: [ sourcePosition := sourcePosition + 1 ].
	sourcePosition := sourcePosition + 1.
	self scanPast: #string start: stringStart end: sourcePosition - 1
]

{ #category : #parse }
SHParserST80 >> parseStringOrSymbol [

	currentTokenFirst == $' ifTrue: [ ^self parseString ].
	currentTokenFirst == $# ifTrue: [ ^self parseSymbol ].
	self fail
]

{ #category : #parse }
SHParserST80 >> parseSymbol [

	| c |
	currentToken size = 1 ifTrue: [
		"if token is just the #, then scan whitespace and comments
		and then process the next character.
		Squeak allows space between the # and the start of the symbol 
		e.g. # (),  #  a, #  'sym' "
		self 
			addRangeType: #symbol;
			scanWhitespace ].
	c := self currentChar.
	self failWhen: (c isNil or: [c isSeparator]).
	c == $( ifTrue: [
		^self
			nextChar;
			scanPast: #arrayStart
				start: currentTokenSourcePosition
				end: currentTokenSourcePosition + 1;
			parseArray].
	c == $' ifTrue: [^self parseSymbolString].
	c == $[ ifTrue: [
		^self
			nextChar;
			scanPast: #byteArrayStart
				start: currentTokenSourcePosition
				end: currentTokenSourcePosition + 1;
			parseByteArray ].
	(self isSelectorCharacter: c) ifTrue: [ ^self parseSymbolSelector ].
	(c isLetter
		or: [ c == $: 
		or: [ c == $_ and: [ allowUnderscoreSelectors ] ] ]) 
			ifTrue: [^self parseSymbolIdentifier].
	^self parseCharSymbol
]

{ #category : #parse }
SHParserST80 >> parseSymbolIdentifier [

	| c start end |
	c := self currentChar.
	self failUnless: (
		c isLetter
			or: [ c == $: 
			or: [ allowUnderscoreSelectors and: [ c == $_ ] ] ]).
	start := sourcePosition.	
	[
		(c := self nextChar) isAlphaNumeric
			or: [ c == $:
			or: [ allowUnderscoreSelectors and: [ c == $_ ] ] ] ] whileTrue.
	end := sourcePosition - 1.
	c := source copyFrom: start - 1 to: end.
	self scanPast: #symbol start: start - 1 end: end.
	^c
]

{ #category : #parse }
SHParserST80 >> parseSymbolSelector [
	| start end |
	start := sourcePosition - 1.
	end := sourcePosition.
	[self isSelectorCharacter: self nextChar] 
		whileTrue: [end := sourcePosition].
	self scanPast: #symbol start: start end: end
]

{ #category : #parse }
SHParserST80 >> parseSymbolString [
	| first c last |
	first := sourcePosition.
	self nextChar.
	[(c := self currentChar) 
		ifNil: [
			self addRangeType: #unfinishedString start: first end: source size.
			self fail ": 'unfinished string'"].
	c ~~ $' or: [
		self peekChar == $' 
			ifTrue: [sourcePosition := sourcePosition + 1.true] 
			ifFalse: [false]]
	] whileTrue: [sourcePosition := sourcePosition + 1].
	last := sourcePosition.
	self
		nextChar;
		scanPast: #stringSymbol start: first - 1 end: last
]

{ #category : #parse }
SHParserST80 >> parseTemporaries [

	| barRangeType temporaryRangeType |
	temporaries size = 1
		ifTrue: [
			barRangeType := #methodTempBar.
			temporaryRangeType := #patternTempVar ]
		ifFalse: [
			barRangeType := #blockTempBar.
			temporaryRangeType := #blockPatternTempVar ].
	(self parseVerticalBarForTemporaries: barRangeType) ifFalse: [ ^self ].
	[ self currentTokenType == #name ] whileTrue: [
		self parseTemporary: temporaryRangeType ].
	(self parseVerticalBarForTemporaries: barRangeType) ifFalse: [
		self fail ": Missing closing temp bar" ]
]

{ #category : #parse }
SHParserST80 >> parseTemporary: expectedTemporaryType [
	"Add currentToken to the current scope as temporary. Scan past expectedTemporaryType if the argument is valid. Assume that currentTokenType is #name."

	(self reservedKeywordNames includes: currentToken) ifTrue: [
		"Reserved keyword"
		^self scanPast: #invalid ].
	
	1 to: arguments size do: [ :index |
		(arguments at: index) ifNotNil: [ :scopeArguments |
			(scopeArguments includes: currentToken) ifTrue: [
				"Name is already used."
				^self scanPast: #invalid ] ].
		(temporaries at: index) ifNotNil: [ :scopeTemporaries |
			(scopeTemporaries includes: currentToken) ifTrue: [
				"Name is already used."
				^self scanPast: #invalid ] ] ].
		
	temporaries last 
		ifNil: [ temporaries atLast: 1 put: (OrderedCollection with: currentToken) ]
		ifNotNil: [ :scopeTemporaries | scopeTemporaries addLast: currentToken ].
	^self scanPast: expectedTemporaryType
]

{ #category : #parse }
SHParserST80 >> parseTerm [

	currentToken ifNil: [ self fail ": Term expected" ].
	currentTokenFirst == $( ifTrue: [
		bracketDepth := bracketDepth + 1.
		self 
			scanPastBracket: #leftParenthesis;
			parseExpression;
			failUnless: currentTokenFirst == $);
			scanPastBracket: #rightParenthesis.
		^bracketDepth := bracketDepth - 1 ].
	currentTokenFirst == $[ ifTrue: [
		^self parseBlock ].
	currentTokenFirst == ${ ifTrue: [
		^self 
			scanPast: #leftBrace;
			parseBraceArray].
	self currentTokenType == #name ifTrue: [
		^self scanPast: self parseIdentifier ].
	self parseLiteral: false
]

{ #category : #parse }
SHParserST80 >> parseUnary [

	[ self currentTokenType == #name ] whileTrue: [
		self scanPast: (
			(Symbol lookup: currentToken)
				ifNotNil: [ #unary ]
				ifNil:[
					(Symbol thatStartsCaseSensitive: currentToken skipping: nil)
						ifNil: [ #undefinedUnary ]
						ifNotNil:[ #incompleteUnary ] ]) ]
]

{ #category : #parse }
SHParserST80 >> parseUnaryMessagePattern [
	
	 self scanPast: #patternUnary

]

{ #category : #parse }
SHParserST80 >> parseVerticalBarForTemporaries: barRangeType [

	currentTokenFirst == $| ifFalse: [ ^false ].
	currentToken size = 1
		ifTrue: [ self scanPast: barRangeType ]
		ifFalse: [
			"Apply a bit of surgery to separate the vertical bar from the rest of the token"
			self
				addRangeType: barRangeType
				start: currentTokenSourcePosition
				end: currentTokenSourcePosition.
			currentToken := currentToken allButFirst.
			currentTokenFirst := currentToken at: 1.
			currentTokenType := nil.
			currentTokenSourcePosition := currentTokenSourcePosition + 1 ].
	^true
]

{ #category : #'token testing' }
SHParserST80 >> parsingBlockArguments [
	^ranges notEmpty and: [ranges last type == #blockPatternArg]
]

{ #category : #scan }
SHParserST80 >> peekChar [

	^source at: sourcePosition + 1 ifAbsent: $ 
]

{ #category : #'parse pragma' }
SHParserST80 >> primitive [
	"Parse keywords and literals of primitive pragmas differently to emit different range tokens for different UI styling. This hook exists so that packages do not break primitive-pragma parsing by accident. Instead, this method needs to be replaced intentionally."
	<pragmaParser>

	self addRangeType: #primitive.

	self scanNext.
	currentTokenFirst isDigit
		ifTrue: [ self scanPast: #integer ]
		ifFalse: [
			self parseStringOrSymbol.
			currentToken = 'module:' ifTrue: [
				self scanPast: #module.
				self parseStringOrSymbol ] ].
	currentToken = 'error:' ifTrue: [
		self scanPast: #primitive. "there's no rangeType for error"
		self currentTokenType == #name
			ifTrue: [ self parseTemporary: #patternTempVar ]
			ifFalse: [ self parseStringOrSymbol ] ].
	self failUnless: currentToken = '>'.
	self scanPast: #primitiveOrExternalCallEnd
]

{ #category : #accessing }
SHParserST80 >> ranges [

	^ranges
]

{ #category : #parse }
SHParserST80 >> rangesIn: sourceString classOrMetaClass: aBehaviour workspace: aWorkspace  environment: anEnvironmentOrNil [
	^ self rangesIn: sourceString classOrMetaClass: aBehaviour workspace: aWorkspace environment: anEnvironmentOrNil context: nil
]

{ #category : #parse }
SHParserST80 >> rangesIn: sourceString classOrMetaClass: aBehaviour workspace: aWorkspace  environment: anEnvironmentOrNil context: aContextOrNil [
	anEnvironmentOrNil ifNotNil: [environment := anEnvironmentOrNil].
	aContextOrNil ifNotNil: [context := aContextOrNil].
	self
		workspace: aWorkspace;
		classOrMetaClass: aBehaviour;
		source: sourceString.
	self parse.
	^ranges
]

{ #category : #accessing }
SHParserST80 >> reservedKeywordNames [

	^#(#self #true #false #nil #super #thisContext)
]

{ #category : #'identifier testing' }
SHParserST80 >> resolvePartialPragmaArgument: aString [ 
	"check if any valid pragma argument begins with aString"
	
	(#('true' 'false' 'nil') anySatisfy: [:each | each beginsWith: aString]) 
		ifTrue: [^#incompleteIdentifier].
	"should really check that a matching binding is for a Class?"
	classOrMetaClass
		ifNotNil: [
			classOrMetaClass theNonMetaClass withAllSuperclassesDo: [:c | 
				(c environment hasBindingThatBeginsWith: aString) ifTrue: [^#incompleteIdentifier]]]
		ifNil: [(environment hasBindingThatBeginsWith: aString) ifTrue: [^#incompleteIdentifier]].
	^#undefinedIdentifier
]

{ #category : #'identifier testing' }
SHParserST80 >> resolvePragmaArgument: aString [ 
	(#('true' 'false' 'nil') includes: aString) ifTrue: [^aString asSymbol].
	"should really check that global is a class?"
	(Symbol lookup: aString) ifNotNil: [:sym | 
		classOrMetaClass 
			ifNotNil: [
				classOrMetaClass theNonMetaClass withAllSuperclassesDo: [:c | 
					(c environment bindingOf: sym) ifNotNil: [^#globalVar]]]
			ifNil: [(environment bindingOf: sym) ifNotNil: [^#globalVar]]].
	^self resolvePartialPragmaArgument: aString
]

{ #category : #scan }
SHParserST80 >> scanBinary [
	| c d |
	c := self currentChar.
	currentTokenSourcePosition := sourcePosition.
	currentToken := c asString.
	d := self nextChar.
	((self isSelectorCharacter: c) or: [c == $:]) ifFalse: [^currentToken].
	(c == $: and: [d == $=]) ifTrue: " := assignment"
		[currentToken := currentToken , d asString.
		 self nextChar.
		 ^currentToken].
	((c == $|) and: [self parsingBlockArguments]) ifTrue:
		[^currentToken].
	[self isSelectorCharacter: d] whileTrue:
		[currentToken := currentToken , d asString.
		 d := self nextChar].
	^currentToken
]

{ #category : #scan }
SHParserST80 >> scanComment [

	| start |
	start := sourcePosition.
	(sourcePosition := source indexOf: $" startingAt: start + 1) = 0 ifTrue: [
		sourcePosition := source size + 1.
		^self
			addRangeType: #unfinishedComment start: start end: source size;
			fail ].
	self
		addRangeType: #comment start: start end: sourcePosition;
		nextChar;
		scanWhitespace
]

{ #category : #scan }
SHParserST80 >> scanIdentifier [

	| c |
	currentTokenSourcePosition := sourcePosition.
	[
		(c := self nextChar) isAlphaNumeric
			or: [ c == $_ and: [ allowUnderscoreSelectors ] ] ] whileTrue.
	(c == $: and: [ self peekChar ~~ $= ]) 
		ifTrue: [ self nextChar ].
	currentToken := source copyFrom: currentTokenSourcePosition to: sourcePosition - 1
]

{ #category : #scan }
SHParserST80 >> scanNext [

	self scanWhitespace.
	currentTokenType := nil.
	currentTokenFirst := self currentChar ifNil: [
		" end of input "
		currentTokenFirst := $ .
		currentTokenSourcePosition := nil.
		currentToken := nil.
		^nil ].
	currentTokenFirst isDigit ifTrue: [ ^self scanNumber ].
	(currentTokenFirst isLetter or: [
		currentTokenFirst == $_ and: [ allowUnderscoreSelectors ] ])
			ifTrue: [ ^self scanIdentifier ].
	^self scanBinary
]

{ #category : #scan }
SHParserST80 >> scanNumber [

	| c |
	currentTokenSourcePosition := sourcePosition.
	self skipDigits.
	(c := self currentChar) == $r
		ifTrue: [
			| base |
			base := (source copyFrom: currentTokenSourcePosition to: sourcePosition - 1) asUnsignedInteger.
			base < 2 ifTrue: [ self fail ": radix must be greater than 1" ].
			self peekChar == $- ifTrue: [ self nextChar ].
			self skipDigitsBase: base.
			(c := self currentChar) == $. ifTrue: [
				(self isDigit: self peekChar base: base) ifTrue: [
					self skipDigitsBase: base].
				c := self currentChar ] ]
		ifFalse: [
			c == $. ifTrue: [
				self peekChar isDigit ifFalse: [
					^currentToken := source copyFrom: currentTokenSourcePosition to: sourcePosition - 1 ].
				self skipDigits.
				c := self currentChar ] ].
	c == $s 
		ifTrue: [
			(c := self nextChar) isDigit
				ifFalse: [ c isLetter ifTrue: [sourcePosition := sourcePosition - 1 ] ]
				ifTrue: [ self skipDigits ] ]
		ifFalse: [
			(c == $d
				or: [ c == $e
				or: [ c == $q ] ]) 
				ifTrue: [
					((c := self nextChar) isDigit or: [ c == $-  and: [ self peekChar isDigit ] ]) 
						ifFalse: [ sourcePosition := sourcePosition - 1 ]
						ifTrue: [ self skipDigits ] ] ].
	currentToken := source copyFrom: currentTokenSourcePosition to: sourcePosition - 1
]

{ #category : #scan }
SHParserST80 >> scanPast: rangeType [ 
	"record rangeType for current token .
	scan and answer the next token"

	^self
		addRangeType: rangeType;
		scanNext
]

{ #category : #scan }
SHParserST80 >> scanPast: rangeType level: level [
	"first level adds no suffix to the rangeType.
	Suffix from 1 to 7 added in cycles , ((level-2) mod(7) + 1)"
	| cycle typePlusCycle |
	
	cycle := level <= 1 
		ifTrue: [0]
		ifFalse:[ ((level - 2) \\ 7) + 1].
	typePlusCycle := cycle = 0 
		ifTrue:[rangeType]
		ifFalse:[(rangeType, cycle asString) asSymbol].
	^self scanPast: typePlusCycle

]

{ #category : #scan }
SHParserST80 >> scanPast: rangeType start: startInteger end: endInteger [
	"record rangeType for current token from startInteger to endInteger,
	 and scanNext token"

	^self 
		addRangeType: rangeType start: startInteger end: endInteger;
		scanNext
	

]

{ #category : #scan }
SHParserST80 >> scanPastBracket: rangeType [
	"first level adds no suffix to the rangeType.
	Suffix from 1 to 7 added in cycles , ((level-2) mod(7) + 1)"

	| rangeTypeForDepth |	
	rangeTypeForDepth := bracketDepth = 1
		ifTrue: [ rangeType ]
		ifFalse: [
			(rangeType 
				caseOf: {
					[ #blockStart ] -> [ #(blockStart1 blockStart2 blockStart3 blockStart4 blockStart5 blockStart6 blockStart7) ].
					[ #blockEnd ] -> [ #(blockEnd1 blockEnd2 blockEnd3 blockEnd4 blockEnd5 blockEnd6 blockEnd7) ].
					[ #leftParenthesis ] -> [ #(leftParenthesis1 leftParenthesis2 leftParenthesis3 leftParenthesis4 leftParenthesis5 leftParenthesis6 leftParenthesis7) ].
					[ #rightParenthesis ] -> [ #(rightParenthesis1 rightParenthesis2 rightParenthesis3 rightParenthesis4 rightParenthesis5 rightParenthesis6 rightParenthesis7) ] }
				otherwise: [ self fail ": 'Unknown range type ', rangeType asString" ]) atWrap: bracketDepth - 1 ].
	self scanPast: rangeTypeForDepth
	
]

{ #category : #scan }
SHParserST80 >> scanWhitespace [
	
	(self currentChar ifNil: [ ^self ]) isSeparator ifTrue: [
		sourcePosition := source
			indexOfAnyOf: CharacterSet nonSeparators
			startingAt: sourcePosition + 1.
		sourcePosition = 0 ifTrue: [ "Not found"
			sourcePosition := source size + 1 ] ].
	self currentChar == $" ifTrue: [ self scanComment ]
]

{ #category : #scan }
SHParserST80 >> skipDigits [

	| c |
	[ 
		(c := self nextChar asInteger) < 48 ifTrue: [ ^self ].
		c > 57 ifTrue: [ ^self ]  ] repeat
]

{ #category : #scan }
SHParserST80 >> skipDigitsBase: baseInteger [
 
	[ self isDigit: self nextChar base: baseInteger ] whileTrue

]

{ #category : #accessing }
SHParserST80 >> source [
	^source
]

{ #category : #accessing }
SHParserST80 >> source: aStringOrText [
	
	source := aStringOrText asString
]

{ #category : #accessing }
SHParserST80 >> workspace: aWorkspace [
    workspace := aWorkspace
]
