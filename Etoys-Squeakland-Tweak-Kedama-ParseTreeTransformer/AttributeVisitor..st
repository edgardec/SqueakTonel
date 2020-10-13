Class {
	#name : #AttributeVisitor,
	#superclass : #Object,
	#instVars : [
		'tree',
		'attributes',
		'evaluator',
		'allOccurences'
	],
	#category : #'Etoys-Squeakland-Tweak-Kedama-ParseTreeTransformer'
}

{ #category : #all }
AttributeVisitor >> allOccurences [

	^ allOccurences.

]

{ #category : #all }
AttributeVisitor >> newWith: aParseTree for: anEvaluator [

	attributes := IdentityDictionary new.
	allOccurences := WriteStream on: (Array new: 1000).
	tree := aParseTree.
	evaluator := anEvaluator.
	tree visitBy: self.

]

{ #category : #debugging }
AttributeVisitor >> occurencesForAttribute: attrName [

	^ allOccurences contents select: [:e | e attributeName = attrName].

]

{ #category : #debugging }
AttributeVisitor >> occurencesForNode: aParseNode [

	^ allOccurences contents select: [:e | e node = aParseNode].

]

{ #category : #debugging }
AttributeVisitor >> occurencesForNodeClass: aParseNodeClass [

	^ allOccurences contents select: [:e | e node class = aParseNodeClass].

]

{ #category : #all }
AttributeVisitor >> tree [

	^ tree.

]

{ #category : #all }
AttributeVisitor >> visit: node [

	| defs occurence ocs |
	defs := evaluator attributeDefinitionsOf: node class.
	ocs := OrderedCollection new.
	defs do: [:def |
		occurence := ParseNodeAttributeOccurence new
			attributeName: def attributeName;
			rawGetter: def rawGetter;
			setter: def setter;
			grammarClass: node class;
			addRules: def rules;
			type: def type;
			node: node.
		node perform: def setter with: occurence.
		ocs add: occurence.
		allOccurences nextPut: occurence.
	].
	node xxxOccurences: ocs.
]
