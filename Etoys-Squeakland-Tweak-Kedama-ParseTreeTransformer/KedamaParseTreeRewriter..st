Class {
	#name : #KedamaParseTreeRewriter,
	#superclass : #Object,
	#instVars : [
		'parseTree',
		'attributedTree',
		'notedRewrite',
		'patterns',
		'encoder'
	],
	#classVars : [
		'Debug'
	],
	#category : #'Etoys-Squeakland-Tweak-Kedama-ParseTreeTransformer'
}

{ #category : #accessing }
KedamaParseTreeRewriter >> attributedTree: tree [

	attributedTree := tree.

]

{ #category : #private }
KedamaParseTreeRewriter >> createBlockNodeFromMessageNode: aMessageNode [

	| newNode argNode statement |
	argNode := encoder encodeVariable: 'xxxObj'.
	statement := MessageNode new
		receiver: argNode
		selector: aMessageNode selector
		arguments: aMessageNode arguments
		precedence: aMessageNode selector precedence
		from: encoder.
	newNode := BlockNode new
		arguments: (Array with: argNode)
		statements: (Array with: statement)
		returns: false
		from: encoder.

	^ newNode
]

{ #category : #private }
KedamaParseTreeRewriter >> createMessageNode: aMessageNode inParentNode: parentNode receiverNode: receiverNameOrNode selector: selectorSymbolOrNode arguments: argumentsArray [

	| recv sel n |
	recv := receiverNameOrNode isString ifTrue: [
		TempVariableNode new name: receiverNameOrNode index: 0 type: 2.
		"encoder encodeVariable: receiverNameOrNode."
	] ifFalse: [
		receiverNameOrNode.
	].

	sel := selectorSymbolOrNode isString ifTrue: [
		selectorSymbolOrNode asSymbol
	] ifFalse: [
		selectorSymbolOrNode key.
	].

	n := MessageNode new
		receiver: recv
		selector: sel
		arguments: argumentsArray
		precedence: sel precedence
		from: encoder.

	^ n
]

{ #category : #initialization }
KedamaParseTreeRewriter >> initialize [

	super initialize.
	notedRewrite := IdentityDictionary new.

]

{ #category : #private }
KedamaParseTreeRewriter >> makeBlockNodeArguments: args statements: statementsArray returns: returnBool [

	| realArgs |
	realArgs := args collect: [:arg |
		arg isString
			ifTrue: [TempVariableNode new name: arg index: 1 type: 2; yourself
					"encoder autoBind: arg"]
			ifFalse: [arg]
	].
	
	^ BlockNode new
		arguments: realArgs
		statements: statementsArray
		returns: returnBool
		from: encoder.

]

{ #category : #private }
KedamaParseTreeRewriter >> noteRewriteMessageNode: aMessageNode inParentNode: parentNode withReceiver: receiver selector: selector arguments: arguments [

	notedRewrite
		at: aMessageNode
		put: {aMessageNode. parentNode. receiver. selector. arguments}.

]

{ #category : #accessing }
KedamaParseTreeRewriter >> parseTree [

	^ parseTree.

]

{ #category : #accessing }
KedamaParseTreeRewriter >> parseTree: tree [

	parseTree := tree.

]

{ #category : #private }
KedamaParseTreeRewriter >> rewriteBlockNode: aBlockNode inParentNode: parentNode arguments: argNodes statements: statementsArray returns: returnBool [

	| newNode |
	newNode := BlockNode new
		arguments: argNodes
		statements: statementsArray
		returns: returnBool
		from: encoder.

	parentNode replaceNode: aBlockNode with: newNode.

]

{ #category : #private }
KedamaParseTreeRewriter >> rewriteMessageNode: aMessageNode inParentNode: parentNode receiverNode: receiverNameOrNode selector: selectorSymbolOrNode arguments: argumentsArray [

	| newNode |
	newNode := self createMessageNode: aMessageNode inParentNode: parentNode receiverNode: receiverNameOrNode selector: selectorSymbolOrNode arguments: argumentsArray.

	parentNode replaceNode: aMessageNode with: newNode.

]

{ #category : #accessing }
KedamaParseTreeRewriter >> setEncoderFor: playerScripted in: aWorld [

	encoder := ScriptEncoder new init: playerScripted class context: nil notifying: nil; referenceObject: aWorld.

]

{ #category : #'entry point' }
KedamaParseTreeRewriter >> visit: node andParent: parent [

	self subclassResponsibility
]
