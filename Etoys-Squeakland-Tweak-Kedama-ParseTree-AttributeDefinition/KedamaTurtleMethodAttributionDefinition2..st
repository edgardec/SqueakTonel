Class {
	#name : #KedamaTurtleMethodAttributionDefinition2,
	#superclass : #KedamaAttributeDefnition,
	#category : #'Etoys-Squeakland-Tweak-Kedama-ParseTree-AttributeDefinition'
}

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> addNodeInfoTo: dict receiverObject: myReceiverObject stmtChain: myStmtChain scriptReceiver: rec messageType: myMessageType isStatement: myIsStatement isInTest: myIsInTest parentNode: parentNode [

	| n sym var infos testFlag isInAllTest lastTestStmt readOrWrite patchGet |
	infos := WriteStream on: (Array new: 2).
	testFlag := #none.
	readOrWrite := (Player readOrWriteOrNil: self selector key).
	isInAllTest := myStmtChain inject: false into: [:subTotal :next | subTotal | (next at: 2)].
	(isInAllTest and: [myIsInTest not]) ifTrue: [testFlag := #testBody].
	myIsInTest ifTrue: [testFlag := #testCond].
	myIsInTest ifTrue: [
		lastTestStmt := myStmtChain reverse detect: [:e | e second] ifNone: [self halt].
		(dict at: lastTestStmt first) add: (Array with: myReceiverObject with: self selector with: self receiver with: #read with: testFlag).
		^ dict
	].

	self receiver isLeaf ifTrue: [
		myReceiverObject isPlayerLike ifTrue: [
			(#(#getPatchValueIn: setPatchValueIn:to:) includes: self selector key) ifTrue: [
				patchGet := self selector key = #getPatchValueIn:.
				n := self arguments first.
				n isLeaf ifTrue: [
					sym := (n key isKindOf: LookupKey) ifTrue: [n key key] ifFalse: [n key].
					var := Compiler evaluate: sym for: rec notifying: nil logged: false.
					infos nextPut: (Array with: var with: self selector key with: self receiver key with: (patchGet ifTrue: [#read] ifFalse: [#write]) with: testFlag).
					infos nextPut: (Array with: myReceiverObject with: self selector key with: self receiver key with: (patchGet ifTrue: [#write] ifFalse: [#read]) with: testFlag).
				] ifFalse: [
					infos nextPut: (Array with: myReceiverObject with: self selector key with: self receiver key with: #read with: testFlag).
				].
			] ifFalse: [
				infos nextPut: (Array with: myReceiverObject with: self selector key with: self receiver key
					with: readOrWrite with: testFlag).
			].
		].
	] ifFalse: [
		(myIsStatement and: [myMessageType ~~ #condition]) ifTrue: [
			infos nextPut: (Array with: nil with: self selector key with: self receiver
				with: readOrWrite with: testFlag).
		]
	].

	infos contents do: [:q |
		myStmtChain do: [:stmt |
			(dict at: (stmt at: 1)) addFirst: q
		].
	].
				
	^ dict.
]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> addToStmtChain: parentStmtChain isStatement: myIsStatement [

	| isTest |
	isTest := self messageType value = #condition.
	myIsStatement ifTrue: [
		^ parentStmtChain copyWith: (Array with: self with: isTest).
	].
	^ parentStmtChain

]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> assignmentMsgType [

	^ #assignment.

]

{ #category : #definition }
KedamaTurtleMethodAttributionDefinition2 class >> attributeDefinition [

	^ #(
		(ParseNode rvr inh)
		(ParseNode myNode inh)
		(ParseNode blockType inh) "#none, #default, #top, #condition, or #sequential"
		(ParseNode isStatement inh)
		(ParseNode isTopStatement inh)
		(ParseNode messageType synth)

		(ParseNode receiverObject synth)

		(ParseNode isInTest inh)
		(ParseNode stmtChain inh)

		(ParseNode nodeInfoIn inh)
		(ParseNode nodeInfoOut synth)

		(ParseNode primaryBreedPair inh)
		(ParseNode statementType inh) "#none, #parallel, #sequential, or #die"
		(ParseNode rewriteInfoIn inh)
		(ParseNode rewriteInfoOut synth)
	).

]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> blockRewriteInfo: parentRewriteInfo statementType: myStmtType primaryBreedPair: myPrimaryBreedPair [

	(#(parallel sequential die) includes: myStmtType) ifFalse: [^ parentRewriteInfo].
	myPrimaryBreedPair ifNil: [^ parentRewriteInfo].
	^ Array with: myPrimaryBreedPair first with: ('var', myPrimaryBreedPair first identityHash printString, self identityHash printString).

]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> blockType: parentType parentMessageType: parentMessageType [

	parentType = #none ifTrue: [^ #top].
	parentMessageType = #condition ifTrue: [^ #condition].
	parentMessageType = #sequential ifTrue: [^ #sequential].
	^ #default.

]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> defaultBlockType: parentBlockType [

	^ #default.


]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> defaultMessageType [

	^ #none.

]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> determineStatementType: parentStmtType fromDict: dict primaryBreedPair: myPrimaryBreedPair messageType: myMessageType isStatement: myIsStatement receiverObject: myReceiverObject [

	| vectorTurtle turtleSelectors participants reads writes unknownReceiverSelectors |
		"Do the calculation only at the statement level."
	myIsStatement ifFalse: [^ parentStmtType].
		"If there is a doSequentially: block, the block is sequential."

	participants := dict at: self.
	(participants select: [:e | (e first notNil and: [e first isPrototypeTurtlePlayer])]) size = 0 ifTrue: [^ #none].
	myMessageType = #sequential ifTrue: [^ #sequential].

	parentStmtType = #sequential ifTrue: [^ #sequential].

	"If there is not turtle involved in the statement, it is not transformed."
	myPrimaryBreedPair ifNil: [^ #none].


	vectorTurtle := myPrimaryBreedPair first.
	myMessageType = #condition ifTrue: [
		reads := IdentitySet new.
		writes := IdentitySet new.
	
		participants do: [:list |
			((list first = vectorTurtle) and: [list fifth = #testBody and: [list fourth isNil and: [
				vectorTurtle selectorIncludesSequentialCommand: list second]]])
					ifTrue: [^ #sequential].
			(((list at: 5) = #testBody or: [(list at: 5) = #testCond]) and: [(list at: 4) ~= #read]) ifTrue: [
				list first ifNotNil: [writes add: list first]].
			(((list at: 5) = #testBody or: [(list at: 5) = #testCond]) and: [(list at: 4) = #read]) ifTrue: [
				list first ifNotNil: [reads add: list first]].
		].
		((writes
			intersection: reads)
				copyWithout: vectorTurtle) ifNotEmpty: [
					^ #sequential
		].
		^ #parallel.
	].

	reads := IdentitySet new.
	writes := IdentitySet new.
	turtleSelectors := OrderedCollection new.
	unknownReceiverSelectors := OrderedCollection new.
	participants do: [:list |
		list first = vectorTurtle ifTrue: [
			((vectorTurtle isBreedSelector: list second) or: [
				(vectorTurtle isUserDefinedSelector: list second)]) ifFalse: [
					turtleSelectors add: list second.
			].
		].
		list first
			ifNil: [unknownReceiverSelectors add: list second]
			ifNotNil: [
				((list at: 4) == #read) ifTrue: [reads add: list first].
				((list at: 4) == #read) ifFalse: [writes add: list first].
			].
		(vectorTurtle containsSequentialSelector: list second) ifTrue: [^ #sequential].
	].
	(turtleSelectors includes: #die) ifTrue: [^ #die].
	(((self isKindOf: AssignmentNode) and: [myReceiverObject = vectorTurtle])
		and: [vectorTurtle isBreedSelector: self property property]) ifTrue: [^ #none].

	(vectorTurtle areOkaySelectors: unknownReceiverSelectors) ifFalse: [
		^ #sequential.
	].

	(vectorTurtle vectorizableTheseSelectors: turtleSelectors) ifFalse: [^ #sequential].
	((reads intersection: writes) copyWithout: vectorTurtle) ifNotEmpty: [^ #sequential].

	"Check the hard way. If any leaf nodes"
	self nodesDo: [:node |
		(node isMessageNode and: [vectorTurtle containsSequentialSelector: node selector])
			ifTrue: [^ #sequential]].
	
	^ #parallel.


]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> firstInReceivers: receivers [

	^ receivers first.

]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> initialBlockType [

	^ #none.

]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> initialDictForBodyParticipants [

	^ Dictionary new.

]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> initialDictForNodeInfo [

	^ Dictionary new.

]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> initialEmptyDict [

	^ Dictionary new.

]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> initialEmptyList [

	^ #().

]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> initialEmptyOrderedCollection [

	^ OrderedCollection new.

]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> initialFalse [

	^ false.

]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> initialNil [

	^ nil.

]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> isStmt: parentBlockType [

	^ parentBlockType = #top or: [parentBlockType = #condition].

]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> isTest: parentIsInTest parentNode: parentNode [

	parentIsInTest = true ifTrue: [^ true].
	^ ((parentNode isMemberOf: MessageNode) and: [parentNode receiver = self and: [ parentNode messageType value = #condition]])

]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> isTopStmt: parentTopStmt [

	parentTopStmt = nil ifTrue: [^ true].
	^ false.

]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> isTopStmtForBlock: parentTopStmt [

	parentTopStmt = nil ifTrue: [^ nil].
	^ false.

]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> msgType [

	(#(ifTrue: ifFalse: ifTrue:ifFalse: ifFalse:ifTrue:) includes: self selector key) ifTrue: [
		^ #condition
	].

	(#(whileTrue: whileFalse:) includes: self selector key) ifTrue: [
		^ #loop
	].
	(#(doSequentially:) includes: self selector key) ifTrue: [
		^ #sequential
	].
	^ #none.


]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> parentRewriteInfo: parentRewriteInfo primaryBreedPair: myBreedPair isStatement: myIsStatement isTopStatement: myIsTopStatement [

	myIsTopStatement ifTrue: [
		myBreedPair ifNil: [^ parentRewriteInfo].
		^ myBreedPair.
	].
	myIsStatement ifTrue: [
		myBreedPair ifNil: [^ parentRewriteInfo].
		parentRewriteInfo ifNil: [^ parentRewriteInfo].
		parentRewriteInfo first = myBreedPair first ifFalse: [
			^ myBreedPair.
		].
	].

	^ parentRewriteInfo

]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> primaryBreedPair: parentPrimaryBreedPair fromDict: dict isStatement: myIsStatement [

	| turtlesInfo n |
	myIsStatement ifTrue: [
		turtlesInfo := (dict at: self) select: [:e | e first notNil and: [(e first isPrototypeTurtlePlayer) and: [(e first isBreedSelector: e second) not]]].
		(turtlesInfo collect: [:p | p first]) asSet size = 0 ifTrue: [^ parentPrimaryBreedPair].
		n := turtlesInfo first third.
		^ Array with: (turtlesInfo first first) with: ((n isKindOf: LookupKey) ifTrue: [n key] ifFalse: [n]).
	].
	^ parentPrimaryBreedPair.

]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> rcvr [

	^ true.

]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> rcvr: rec [

	^ rec.

]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> rewriteInfo: parentRewriteInfo statementType: myStatementType primaryBreedPair: myPrimaryBreedPair isStatement: myIsStatement [

	myIsStatement ifTrue: [
		(#(parallel sequential die) includes: myStatementType) ifFalse: [^ nil].
		myPrimaryBreedPair ifNil: [^ nil].
		^ Array with: myPrimaryBreedPair first with: ('var', myPrimaryBreedPair first identityHash printString, self identityHash printString).
	].
	^ parentRewriteInfo.

]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> rewriteVariable: recObject with: myPrimaryBreedPair rewriteInfo: myRewriteInfo [

	myPrimaryBreedPair ifNil: [^ nil].
	myPrimaryBreedPair first = recObject ifTrue: [^ myRewriteInfo].
	^ nil.

]

{ #category : #definition }
KedamaTurtleMethodAttributionDefinition2 class >> semanticRuleSignatures [

	^ #(
		(start MethodNode initialFalse #())
		(rvr ParseNode rcvr: #((rvr parentInh)))
		(rvr MethodNode rcvr #())

		(myNode ParseNode thisNode #())

		(blockType ParseNode defaultBlockType: #((blockType parentInh)))
		(blockType BlockNode blockType:parentMessageType: #((blockType parentInh) (messageType parentInh)))
		(blockType MethodNode initialBlockType #())

		(isStatement ParseNode isStmt: #((blockType parentInh)))
		(isStatement MethodNode initialFalse #())

		(isTopStatement ParseNode isTopStmt: #((isTopStatement parentInh)))
		(isTopStatement BlockNode isTopStmtForBlock: #((isTopStatement parentInh)))
		(isTopStatement MethodNode initialNil #())

		(messageType ParseNode defaultMessageType #())
		(messageType MessageNode msgType #())
		(messageType AssignmentNode assignmentMsgType #())

		(receiverObject ParseNode firstInReceivers: #((receiverObject allChildrenSynth)))
		(receiverObject LeafNode initialNil #())
		(receiverObject BlockNode initialNil #())
		(receiverObject VariableNode variableReceiver: #((rvr myInh)))

		(isInTest ParseNode isTest:parentNode: #((isInTest parentInh) (myNode parentInh)))
		(isInTest MethodNode initialFalse #())

		(stmtChain ParseNode transfer: #((stmtChain parentInh)))
		(stmtChain MethodNode initialEmptyList #())
		(stmtChain MessageNode addToStmtChain:isStatement: #((stmtChain parentInh) (isStatement myInh)))

		(nodeInfoIn ParseNode transfer: #((nodeInfoIn parentInhFirstChild)))
		(nodeInfoIn ParseNode transfer: #((nodeInfoOut elderSiblingSynth)))
		(nodeInfoIn MessageNode transfer:isStatement: #((nodeInfoIn parentInhFirstChild) (isStatement myInh)))
		(nodeInfoIn MessageNode transfer:isStatement: #((nodeInfoOut elderSiblingSynth) (isStatement myInh)))
		(nodeInfoIn MethodNode initialDictForNodeInfo #())

		(nodeInfoOut ParseNode transfer: #((nodeInfoIn myInh)))
		(nodeInfoOut ParseNode transfer: #((nodeInfoOut lastChildSynth)))
		(nodeInfoOut MessageNode 
			addNodeInfoTo:receiverObject:stmtChain:scriptReceiver:messageType:isStatement:isInTest:parentNode:
			#((nodeInfoOut lastChildSynth) (receiverObject mySynth) (stmtChain myInh) (rvr myInh) (messageType mySynth) (isStatement myInh) (isInTest myInh) (myNode parentSynth)))

		#(primaryBreedPair ParseNode transfer: #((primaryBreedPair parentInh)))
		#(primaryBreedPair MethodNode initialNil #())
		#(primaryBreedPair MessageNode primaryBreedPair:fromDict:isStatement: #((primaryBreedPair parentInh) (nodeInfoOut mySynth) (isStatement myInh)))

		#(statementType ParseNode transfer: #((statementType parentInh)))
		#(statementType MethodNode initialNil #())
		#(statementType MessageNode determineStatementType:fromDict:primaryBreedPair:messageType:isStatement:receiverObject: #((statementType parentInh) (nodeInfoOut mySynth) (primaryBreedPair mySynth) (messageType mySynth) (isStatement mySynth) (receiverObject mySynth)))

		#(rewriteInfoIn ParseNode transfer: #((rewriteInfoOut parentSynth)))
		#(rewriteInfoIn MethodNode initialNil #())
		#(rewriteInfoIn MessageNode parentRewriteInfo:primaryBreedPair:isStatement:isTopStatement: #((rewriteInfoOut parentSynth) (primaryBreedPair mySynth) (isStatement mySynth) (isTopStatement mySynth)))

		#(rewriteInfoOut ParseNode transfer: #((rewriteInfoIn myInh)))
		#(rewriteInfoOut BlockNode blockRewriteInfo:statementType:primaryBreedPair: #((rewriteInfoIn myInh) (statementType myInh) (primaryBreedPair mySynth)))
		#(rewriteInfoOut MessageNode rewriteInfo:statementType:primaryBreedPair:isStatement: #((rewriteInfoIn myInh) (statementType myInh) (primaryBreedPair mySynth) (isStatement mySynth)))
		(rewriteInfoOut VariableNode rewriteVariable:with:rewriteInfo: ((receiverObject mySynth) (primaryBreedPair myInh) (rewriteInfoIn myInh)))
		

	).

]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> thisNode [

	^ self.

]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> transfer: val [

	^ val.

]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> transfer: givenNodeInfo isStatement: myIsStatement [

	myIsStatement ifTrue: [givenNodeInfo at: self put: OrderedCollection new].
	^ givenNodeInfo.

]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> transferBlockType: parentBlockType [

	^ #default.


]

{ #category : #rules }
KedamaTurtleMethodAttributionDefinition2 class >> variableReceiver: rec [
	| var sym |
	sym := (self key isKindOf: LookupKey) ifTrue: [^ self key value] ifFalse: [self key].
	var := Compiler new evaluate: sym asString in: nil to: rec notifying: nil ifFail: [] logged: false.
	^ var.

]
