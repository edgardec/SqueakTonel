Class {
	#name : #KedamaEvaluatorNodeState,
	#superclass : #Object,
	#classInstVars : [
		'dictionary'
	],
	#category : #'Etoys-Squeakland-Tweak-Kedama-ParseTreeTransformer'
}

{ #category : #accessing }
KedamaEvaluatorNodeState class >> dictionary [

	^ dictionary
]

{ #category : #'class initialization' }
KedamaEvaluatorNodeState class >> initialize [
	"self initialize"
	dictionary := IdentityDictionary new
]

{ #category : #'instance creation' }
KedamaEvaluatorNodeState class >> new [

	self error: 'This class is not meant to be instantianted'
]

{ #category : #'state access' }
KedamaEvaluatorNodeState class >> stateFor: anInstance at: aVariableName [

	^ (self dictionary at: aVariableName) at: anInstance ifAbsentPut: [nil]
]

{ #category : #'state access' }
KedamaEvaluatorNodeState class >> stateFor: anInstance at: aVariableName put: anObject [

	^ (self dictionary at: aVariableName) at: anInstance put: anObject
]
