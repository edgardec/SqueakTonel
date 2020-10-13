Class {
	#name : #KedamaVectorParseTreeRewriter,
	#superclass : #KedamaParseTreeRewriter,
	#category : #'Etoys-Squeakland-Tweak-Kedama-ParseTreeTransformer'
}

{ #category : #'entry point' }
KedamaVectorParseTreeRewriter >> visit: node andParent: parent [

	| newNode possibleSelector selIndex parentRewriterBlock newNodeBlock |
	node isLeaf not ifTrue: [
		node getAllChildren do: [:child |
			self visit: child andParent: node.
		].
	].

	(node rewriteInfoOut notNil) ifTrue: [
		((node isMemberOf: VariableNode) or: [node isMemberOf: LiteralVariableNode]) ifTrue: [
			newNode := TempVariableNode new name: node rewriteInfoOut second index: 0 type: 2.
			parent replaceNode: node with: newNode.
		].
	].

	(node isMemberOf: MessageNode) ifTrue: [
		(node statementType = #sequential) ifTrue: [
			node selector key = #doSequentialCommand: ifTrue: [
				(node isStatement) ifTrue: [
					node receiver: node primaryBreedPair second.
				].
			]
		].
	].

	(node isMemberOf: MessageNode) ifTrue: [		
		newNodeBlock := [:selector :args |
			self
				createMessageNode: node
				inParentNode: parent
				receiverNode: (TempVariableNode new name: node rewriteInfoOut second index: 0 type: 2) 
				selector: selector
				arguments: args].									

		((selIndex := #(parallel sequential die) indexOf: node statementType) > 0) ifTrue: [
			possibleSelector := #(doCommand: doSequentialCommand: doDieCommand:) at: selIndex.
			
			parentRewriterBlock := [:newNod |
			self
				rewriteMessageNode: node
				inParentNode: parent
				receiverNode: node rewriteInfoIn second
				selector: possibleSelector
				arguments: {self
									makeBlockNodeArguments: {node rewriteInfoOut second}
									statements: {newNod} returns: false}].
			
			(node messageType = #condition) ifTrue: [
				newNode := newNodeBlock
									value: #test:ifTrue:ifFalse:
									value: {BlockNode withJust: node receiver. node arguments first. node arguments second}.
				(node isStatement) ifFalse: [
					parent replaceNode: node with: newNode.
				] ifTrue: [
					parentRewriterBlock value: newNode.
				].
			] ifFalse: [
				node selector key = #timesRepeat:
					ifTrue: [
						newNode := newNodeBlock
											value: #times:repeat:
											value: {node receiver. node arguments first}.
						(node isStatement) ifFalse: [
							parent replaceNode: node with: newNode.
						] ifTrue: [
							parentRewriterBlock value: newNode.
						].
					]
					ifFalse: [(node isStatement) ifTrue: [
						parentRewriterBlock value: node
					].
				].
			]
		].
	].

	(node isMemberOf: BlockNode) ifTrue: [
		(node rewriteInfoOut notNil) ifTrue: [
			self rewriteBlockNode: node inParentNode: parent arguments: (Array with: (TempVariableNode new name: node rewriteInfoOut second index: 0 type: 2)) statements: node statements returns: false.
		].
	].


]
