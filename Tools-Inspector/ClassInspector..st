"
I am an Inspector that is specialized for inspecting Class objects. I show fields for my class variables and the shared pools I use.
"
Class {
	#name : #ClassInspector,
	#superclass : #Inspector,
	#category : #'Tools-Inspector'
}

{ #category : #'fields - streaming' }
ClassInspector >> streamClassVariablesOn: aStream [
	
	self object classVarNames do: [:name |
		aStream nextPut: ((self newFieldForType: #classVar key: name)
			shouldStyleName: true;
			valueGetter: [:object | object classPool at: name];
			valueSetter: [:object :value | object classPool at: name put: value];
			yourself)]
]

{ #category : #'fields - streaming' }
ClassInspector >> streamSharedPoolsOn: aStream [

	self object sharedPools doWithIndex: [:pool :index |
		aStream nextPut: ((self newFieldForType: #poolDictionary key: (self environment keyAtIdentityValue: pool))
			shouldStyleName: true;
			valueGetter: [:object | object sharedPools at: index];
			valueSetter: [:object :value | object sharedPools at: index put: value];
			yourself)].
]

{ #category : #'fields - streaming' }
ClassInspector >> streamVariableFieldsOn: aStream [
	"Add fields for class variables and pool dictionaries."
	
	super streamVariableFieldsOn: aStream.
	self
		streamClassVariablesOn: aStream;
		streamSharedPoolsOn: aStream.
]
