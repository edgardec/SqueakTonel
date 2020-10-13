"
This Parser is part of a package designed to allow for experiments with alternatives to ST-80 syntax.  The particular alternative offered by this parser eliminates colons, left-arrows and up-arrows, and adds prefix keywords for common control constructs.

ST-80									SQ-00
-------									-------
a + b between: c and: c + 4				a + b between (c) and (c + 4)
a _ 3.0									Set a to 3.0
^ self size + 3							Return self size + 3
a > b									Test (a > b)
	ifTrue: ['greater']						ifTrue ['greater']
	ifFalse: ['less']							ifFalse ['less']
1 to: 9 do:								Repeat (1) to (9) do
	[:i | Transcript cr; show: i]				[Set i. | Transcript cr; show (i)]

The use of prefix keywords is currently ad-hoc;  in other words they are built into the parser, and there is not a way to define a method pattern to include a prefix keyword.  Most of the work has been done to support this, though, as selectors can now have the form
	#:prefix:kwd1:kwd2:
and they will respond appropriately to #keywords and #numArgs.

A test method in the class ensures that every method in the system can be pretty-printed in the alternative syntax, and that compiling the resulting text produces exactly the same bytecodes as the original method.
"
Class {
	#name : #DialectParser,
	#superclass : #Parser,
	#instVars : [
		'dialect'
	],
	#category : #'Etoys-Squeakland-System-Compiler'
}

{ #category : #'as yet unclassified' }
DialectParser class >> test [    "DialectParser test"

"PrettyPrints the source for every method in the system in the alternative syntax, and then compiles that source and verifies that it generates identical code.  No changes are actually made to the system.  At the time of this writing, only two methods caused complaints (reported in Transcript and displayed in browse window after running):

	BalloonEngineSimulation circleCosTable and
	BalloonEngineSimulation circleSinTable.

These are not errors, but merely a case of Floats embedded in literal arrays, and thus not specially checked for roundoff errors.

Note that if an error or interruption occurs during execution of this method, the alternativeSyntax preference will be left on.

NOTE:  Some methods may not compare properly until the system has been recompiled once.  Do this by executing...
		Smalltalk recompileAllFrom: 'AARDVAARK'.
"

	 | newCodeString methodNode oldMethod newMethod badOnes n heading |
	Preferences enable: #printAlternateSyntax.
	badOnes := OrderedCollection new.
	Transcript clear.
'Formatting and recompiling all classes...'
displayProgressAt: Sensor cursorPoint
from: 0 to: CompiledMethod instanceCount
during: [:bar | n := 0.
	Smalltalk allClassesDo:  "{MethodNode} do:"  "<- to check one class"
		[:nonMeta |  "Transcript cr; show: nonMeta name."
		{nonMeta. nonMeta class} do:
		[:cls |
		cls selectors do:
			[:selector | (n := n+1) \\ 100 = 0 ifTrue: [bar value: n].
			newCodeString := (cls compilerClass new)
				format: (cls sourceCodeAt: selector)
				in: cls notifying: nil decorated: Preferences colorWhenPrettyPrinting.
			heading := cls organization categoryOfElement: selector.
			methodNode := cls compilerClass new
						compile: newCodeString
						in: cls notifying: (SyntaxError new category: heading)
						ifFail: [].
			newMethod := methodNode generate: CompiledMethodTrailer empty.
			oldMethod := cls compiledMethodAt: selector.
			"Transcript cr; show: cls name , ' ' , selector."
			oldMethod = newMethod ifFalse:
				[Transcript cr; show: '***' , cls name , ' ' , selector.
				oldMethod size = newMethod size ifFalse:
					[Transcript show: ' difft size'].
				oldMethod header = newMethod header ifFalse:
					[Transcript show: ' difft header'].
				oldMethod literals = newMethod literals ifFalse:
					[Transcript show: ' difft literals'].
				Transcript endEntry.
				badOnes add: cls name , ' ' , selector]]]].
].
	self systemNavigation browseMessageList: badOnes sort name: 'Formatter Discrepancies'.
	Preferences disable: #printAlternateSyntax.

]

{ #category : #'as yet unclassified' }
DialectParser >> assignment: varNode [
	" 'set' (var) 'to' (expression) => AssignmentNode."
	| loc |
	(loc := varNode assignmentCheck: encoder at: prevMark + requestorOffset) >= 0
		ifTrue: [^self notify: 'Cannot store into' at: loc].
	varNode nowHasDef.
	self advance.  " to "
	self expression ifFalse: [^self expected: 'Expression'].
	parseNode := AssignmentNode new
				variable: varNode
				value: parseNode
				from: encoder.
	^ true
]

{ #category : #'as yet unclassified' }
DialectParser >> blockExpression [
	"[ ({:var} |) (| {temps} |) (statements) ] => BlockNode."

	| variableNodes temporaryBlockVariables |
	variableNodes := OrderedCollection new.

	"Gather parameters."
	(self matchToken: 'With') ifTrue:
		[[self match: #period]
			whileFalse: [variableNodes addLast: (encoder autoBind: self argumentName)]].

	temporaryBlockVariables := self temporaryBlockVariables.
	self statements: variableNodes innerBlock: true.
	parseNode temporaries: temporaryBlockVariables.

	(self match: #rightBracket) ifFalse: [^ self expected: 'Period or right bracket'].

	"The scope of the parameters and temporary block variables is no longer active."
	temporaryBlockVariables do: [:variable | variable scope: -1].
	variableNodes do: [:variable | variable scope: -1]
]

{ #category : #'as yet unclassified' }
DialectParser >> expression [

	^ self expressionWithInitialKeyword: ''

]

{ #category : #'as yet unclassified' }
DialectParser >> expressionWithInitialKeyword: kwdIfAny [

	| checkpoint |
	(hereType == #word and: [here = 'Set' and: [tokenType == #word]]) ifTrue:
			["Parse assignment statement 'Set' var 'to' expression"
			checkpoint := self checkpoint.
			self advance.
			token = 'to'
				ifTrue: [^ self assignment: self variable]
				ifFalse: [self revertToCheckpoint: checkpoint]].
	self matchKeyword
		ifTrue: ["It's an initial keyword."
				kwdIfAny isEmpty ifFalse: [self error: 'compiler logic error'].
				^ self expressionWithInitialKeyword: ':' , self advance , ':'].
	hereType == #leftBrace
		ifTrue: [self braceExpression]
		ifFalse: [self primaryExpression ifFalse: [^ false]].
	(self messagePart: 3 repeat: true initialKeyword: kwdIfAny)
		ifTrue: [hereType == #semicolon ifTrue: [self cascade]].
	^ true
]

{ #category : #'as yet unclassified' }
DialectParser >> matchKeyword [
	"Return true if we are looking at a keyword (and its argument)."

	hereType == #word ifFalse: [^ false].
	tokenType == #leftParenthesis ifTrue: [^ true].
	tokenType == #leftBracket ifTrue: [^ true].
	tokenType == #leftBrace ifTrue: [^ true].
	^ false
]

{ #category : #'as yet unclassified' }
DialectParser >> matchReturn [

	^ self matchToken: 'Answer'
]

{ #category : #'as yet unclassified' }
DialectParser >> messagePart: level repeat: repeat [

	^ self messagePart: level repeat: repeat initialKeyword: ''
]

{ #category : #'as yet unclassified' }
DialectParser >> messagePart: level repeat: repeat initialKeyword: kwdIfAny [

	| start receiver selector args precedence words keywordStart |
	[receiver := parseNode.
	(self matchKeyword and: [level >= 3])
		ifTrue: 
			[start := self startOfNextToken.
			selector := WriteStream on: (String new: 32).
			selector nextPutAll: kwdIfAny.
			args := OrderedCollection new.
			words := OrderedCollection new.
			[self matchKeyword]
				whileTrue: 
					[keywordStart := self startOfNextToken + requestorOffset.
					selector nextPutAll: self advance , ':'.
					words addLast: (keywordStart to: hereEnd + requestorOffset).
					self primaryExpression ifFalse: [^ self expected: 'Argument'].
					args addLast: parseNode].
			(Symbol hasInterned: selector contents ifTrue: [ :sym | selector := sym])
				ifFalse: [ selector := self correctSelector: selector contents
										wordIntervals: words
										exprInterval: (start to: self endOfLastToken)
										ifAbort: [ ^ self fail ] ].
			precedence := 3]
		ifFalse: [((hereType == #binary or: [hereType == #verticalBar])
				and: [level >= 2])
				ifTrue: 
					[start := self startOfNextToken.
					selector := self advance asSymbol.
					self primaryExpression ifFalse: [^self expected: 'Argument'].
					self messagePart: 1 repeat: true.
					args := Array with: parseNode.
					precedence := 2]
				ifFalse: [(hereType == #word
							and: [(#(leftParenthesis leftBracket leftBrace) includes: tokenType) not])
						ifTrue: 
							[start := self startOfNextToken.
							selector := self advance.
							args := #().
							words := OrderedCollection with: (start  + requestorOffset to: self endOfLastToken + requestorOffset).
							(Symbol hasInterned: selector ifTrue: [ :sym | selector := sym])
								ifFalse: [ selector := self correctSelector: selector
													wordIntervals: words
													exprInterval: (start to: self endOfLastToken)
													ifAbort: [ ^ self fail ] ].
							precedence := 1]
						ifFalse: [^args notNil]]].
	parseNode := MessageNode new
				receiver: receiver
				selector: selector
				arguments: args
				precedence: precedence
				from: encoder
				sourceRange: (start to: self endOfLastToken).
	repeat]
		whileTrue: [].
	^true
]

{ #category : #'as yet unclassified' }
DialectParser >> newMethodNode [

	^ DialectMethodNode new setDialect: #SQ00
]

{ #category : #'as yet unclassified' }
DialectParser >> parseArgsAndTemps: aString notifying: req [ 
	"Parse the argument, aString, notifying req if an error occurs. Otherwise, 
	answer a two-element Array containing Arrays of strings (the argument 
	names and temporary variable names)."

	aString == nil ifTrue: [^#()].
	doitFlag := false.		"Don't really know if a doit or not!"
	^self initPattern: aString
		return: [:pattern | (pattern at: 2) , self temporaries]
]

{ #category : #'as yet unclassified' }
DialectParser >> pattern: fromDoit inContext: ctxt [ 
	" unarySelector | binarySelector arg | keyword arg {keyword arg} =>  
	{selector, arguments, precedence}."
	| args selector checkpoint |
	doitFlag := fromDoit.
	fromDoit ifTrue:
			[ctxt == nil
				ifTrue: [^ {#DoIt. {}. 1}]
				ifFalse: [^ {#DoItIn:. {encoder encodeVariable: 'homeContext'}. 3}]].

	"NOTE: there is now an ambiguity between
	keywordSelector (argName) -and- unarySelector (first expression).
	Also, there is an amibuity (if there are no temp declarations) between
	keywordSelector (argName) -and- PrefixKeyword (some expression).
	We use duct tape for now."
	(hereType == #word and: [tokenType == #leftParenthesis]) ifTrue:
		[checkpoint := self checkpoint.  "in case we have to back out"
		selector := WriteStream on: (String new: 32).
			args := OrderedCollection new.
			[hereType == #word
				and: [tokenType == #leftParenthesis
				and: [here first isLowercase
						or: [(#('Test' 'Repeat' 'Answer') includes: here) not]]]]
				whileTrue: 
					[selector nextPutAll: self advance , ':'.  "selector part"
					self advance.  "open paren"
					(args size = 0 and: [tokenType ~~ #rightParenthesis]) ifTrue:
						["This is really a unary selector on a method that
						begins with a parenthesized expression.  Back out now"
						self revertToCheckpoint: checkpoint.
						^ {self advance asSymbol. {}. 1}].
					args addLast: (encoder bindArg: self argumentName).
			(self match: #rightParenthesis)
						ifFalse: [^ self expected: 'right parenthesis']].
			^ {selector contents asSymbol. args. 3}].

	hereType == #word ifTrue: [^ {self advance asSymbol. {}. 1}].

	(hereType == #binary or: [hereType == #verticalBar])
		ifTrue: 
			[selector := self advance asSymbol.
			args := Array with: (encoder bindArg: self argumentName).
			^ {selector. args. 2}].

	^ self expected: 'Message pattern'
]

{ #category : #'as yet unclassified' }
DialectParser >> temporaries [
	" [ 'Use' (variable)* '.' ]"
	| vars theActualText |
	(self matchToken: #'Use') ifFalse: 
		["no temps"
		doitFlag ifTrue: [cue requestor
				ifNil: [tempsMark := 1]
				ifNotNil: [tempsMark := cue requestor selectionInterval first].
			^ #()].
		tempsMark := prevEnd+1.
		tempsMark > 0 ifTrue:
			[theActualText := source contents.
			[tempsMark < theActualText size and: [(theActualText at: tempsMark) isSeparator]]
				whileTrue: [tempsMark := tempsMark + 1]].
			^ #()].
	vars := OrderedCollection new.
	[hereType == #word]
		whileTrue: [vars addLast: (encoder bindTemp: self advance)].
	(self match: #period) ifTrue: 
		[tempsMark := prevMark.
		^ vars].
	^ self expected: 'Period'
]
