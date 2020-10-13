Class {
	#name : #TextEditorTest,
	#superclass : #TestCase,
	#instVars : [
		'model',
		'widget'
	],
	#category : #'MorphicTests-Text Support'
}

{ #category : #running }
TextEditorTest >> editor [

	^ widget textMorph editor
]

{ #category : #running }
TextEditorTest >> setUp [

	super setUp.
	model := MorphicTestTextModel new.
	widget := PluggableTextMorph on: model text: #contents accept: #contents:.
	
	"We don't do real keyboard event handling. To be sure to set the model in the editor."
	self editor model: model.
	
	model contents: ''.
]

{ #category : #tests }
TextEditorTest >> test01Setup [

	self assert: model dependents size = 1.
	self assert: self editor model == model.
	self assert: widget text isEmpty.
	self assert: model contents isEmpty.
]

{ #category : #tests }
TextEditorTest >> test02EvaluateExpression [

	model := MorphicTestTextModelWithEvaluationSupport new.
	widget model: model.
	
	self text: '3+4'.
	self editor doIt.

	self
		assert: (model hasFlag: #expressionEvaluated);
		assert: 7 equals: model result.
]

{ #category : #tests }
TextEditorTest >> test03DebugExpression [

	self text: 'Morph new'.
	self editor debugIt.

	self
		assert: (model hasFlag: #expressionDebugged);
		assert: (model result isKindOf: Morph).
]

{ #category : #tests }
TextEditorTest >> test04PrintIt [

	self text: '3+4'.
	self editor printIt.

	self
		assert: (model hasFlag: #printed);
		assert: '7' equals: model result.
]

{ #category : #tests }
TextEditorTest >> test05ExploreIt [

	self text: '1@1 corner: 20@20'.
	self editor exploreIt.

	self
		assert: (model hasFlag: #explored);
		assert: (model result isKindOf: Rectangle).
]

{ #category : #tests }
TextEditorTest >> test06InspectIt [

	self text: '1@1 corner: 20@20'.
	self editor inspectIt.
	
	self
		assert: (model hasFlag: #inspected);
		assert: (model result isKindOf: Rectangle).
]

{ #category : #tests }
TextEditorTest >> test07DoItReceiver [

	self text: 'self color'.
	model result: (Morph new color: Color yellow).
	self editor doIt.
	
	self
		assert: (model hasFlag: #expressionEvaluated);
		assert: Color yellow equals: model result.
]

{ #category : #running }
TextEditorTest >> text: aString [
	"Text editors have a short lifetime in pluggable text morphs."
	
	model contents: aString.
	
	"We don't do real keyboard event handling. To be sure to set the model in the editor."
	self editor model: model.
]
