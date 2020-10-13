Class {
	#name : #MorphicTestTextModelWithEvaluationSupport,
	#superclass : #MorphicTestTextModel,
	#category : #'MorphicTests-Text Support'
}

{ #category : #'do-its general' }
MorphicTestTextModelWithEvaluationSupport >> evaluateExpression: anExpression [

	self flags add: #expressionEvaluated.
	self result: (Compiler evaluate: anExpression asString).
	^ self result
]
