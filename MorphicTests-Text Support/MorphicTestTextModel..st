Class {
	#name : #MorphicTestTextModel,
	#superclass : #ValueHolder,
	#instVars : [
		'flags',
		'result'
	],
	#category : #'MorphicTests-Text Support'
}

{ #category : #'do-its general' }
MorphicTestTextModel >> debugExpression: anExpression [

	self flags add: #expressionDebugged.
	self result: (Compiler evaluate: anExpression).
]

{ #category : #'do-its support' }
MorphicTestTextModel >> doItContext [

	self flags add: #doItContext.
	^ nil
]

{ #category : #'do-its support' }
MorphicTestTextModel >> doItReceiver [

	self flags add: #doItReceiver.
	^ self result
]

{ #category : #'do-its' }
MorphicTestTextModel >> exploreIt: expression result: object [

	self flags add: #explored.
	self result: object.
]

{ #category : #'do-its general' }
MorphicTestTextModel >> expressionEvaluated: anExpression result: anObject [

	self flags add: #expressionEvaluated.
	self result: anObject.
]

{ #category : #accessing }
MorphicTestTextModel >> flags [

	^ flags ifNil: [flags := Bag new]
]

{ #category : #accessing }
MorphicTestTextModel >> hasFlag: aSymbol [

	^ self flags includes: aSymbol
]

{ #category : #'do-its' }
MorphicTestTextModel >> inspectIt: expression result: object [

	self flags add: #inspected.
	self result: object.
]

{ #category : #'do-its' }
MorphicTestTextModel >> printIt: expression result: object [

	self flags add: #printed.
	self result: object printString.
]

{ #category : #accessing }
MorphicTestTextModel >> result [

	^ result
]

{ #category : #accessing }
MorphicTestTextModel >> result: anObject [

	result := anObject.
]
