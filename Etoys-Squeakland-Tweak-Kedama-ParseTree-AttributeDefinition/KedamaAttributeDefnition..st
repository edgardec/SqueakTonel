Class {
	#name : #KedamaAttributeDefnition,
	#superclass : #Object,
	#category : #'Etoys-Squeakland-Tweak-Kedama-ParseTree-AttributeDefinition'
}

{ #category : #'as yet unclassified' }
KedamaAttributeDefnition class >> attributeDefinition [

	^ #().
	"#((CParseNode #const #synth))"
	"
	-> 
	evaluator defineAttributeNamed: #const at: CParseNode type: #synth.
"
]

{ #category : #'as yet unclassified' }
KedamaAttributeDefnition class >> generateAttributeDefinitionInput [

	| attrs |
	attrs := self attributeDefinition, #((MethodNode #start #intrinsic)).

	^ String streamContents: [:strm |
		attrs do: [:line |
			strm nextPutAll: ('self defineAttributeNamed: #{1} at: {2} type: #{3}.' format: {line second. (Smalltalk at: line first). line third}).
		].
		strm nextPutAll: 'self generateInstVarAndAccessors.'
	].

]

{ #category : #'as yet unclassified' }
KedamaAttributeDefnition class >> generateEvaluatorCreationString [

	^ ''.

]

{ #category : #'as yet unclassified' }
KedamaAttributeDefnition class >> generateEvaluatorInput [

	^ self generateEvaluatorCreationString,
	 self generateAttributeDefinitionInput,
	self generateSemanticRuleSignatureInput.

]

{ #category : #'as yet unclassified' }
KedamaAttributeDefnition class >> generateSemanticRuleSignatureInput [

	| sigs inputs inputString encodeStream |
	sigs := self semanticRuleSignatures, #((start MethodNode initialNil #())).


	^ String streamContents: [:strm |
		sigs do: [:line |
			encodeStream := WriteStream on: String new.
			inputs := line fourth.
			inputString := String streamContents: [:in |
				in nextPutAll: '{'.
				inputs do: [:input |
					in nextPutAll: ('(InputSpec new attributeName: #{1}; type: #{2}; yourself). ' format: input).
				].
				in nextPutAll: '}'.
			].
			(self class sourceCodeAt: line third) asString do: [:c | encodeStream nextPut: c. c = $' ifTrue: [encodeStream nextPut: c.]].
			strm nextPutAll: ('self
				defineSemanticRuleFor: (ParseNodeAttribute new attributeName: #{1}; grammarClass: {2}; yourself)
				rule: ''{3}''
				selector: #{4}
				uses: {5}.' format: {line first. line second. encodeStream contents. line third. inputString}).
			strm cr.
		].
	].

]

{ #category : #'as yet unclassified' }
KedamaAttributeDefnition class >> semanticRuleSignatures [

	^ #().

	"^ #(
		#(const CParseNode mergeConst: #((const allChildrenSynt)))
		#(const CLeafNode initialConst #())
		#(const CSelectorNode selectorConst #()))."


]
