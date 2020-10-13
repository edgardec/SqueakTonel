"
I am an inspector that is specialized to inspecting the variables of a Context. I am typically displayed as part of a Debugger, where I sit besides an inspector for the receiver object. That's why a traditional Contextinspector would not work because it makes ""ThisContext"" be ""self"".

At some point, this should subclass from Contextinspector.
"
Class {
	#name : #ContextVariablesInspector,
	#superclass : #ContextInspector,
	#classVars : [
		'ShowStackVariables'
	],
	#category : #'Tools-Debugger'
}

{ #category : #preferences }
ContextVariablesInspector class >> showStackVariables [
	<preference: 'Show stack variables in debugger'
		category: #debug
		description: 'When true, append the unnamed stack variables (if any) below the named temps in the debugger''s context inspector.'
		type: #Boolean>
	^ ShowStackVariables ifNil: [false]
]

{ #category : #preferences }
ContextVariablesInspector class >> showStackVariables: aBoolean [

	ShowStackVariables := aBoolean.
]

{ #category : #code }
ContextVariablesInspector >> doItContext [

	^object
]

{ #category : #code }
ContextVariablesInspector >> doItReceiver [

	^object ifNotNil: [object receiver]
]

{ #category : #private }
ContextVariablesInspector >> expressionForField: anInspectorField [
	"Use #ThisContext instead of #self. Note the capital 'T' to not refer to the special keyword #thisContext, which would return the current execution context but not the one we are currently inspecting."
	
	^ anInspectorField expressionWithReceiverName: #ThisContext
]

{ #category : #fields }
ContextVariablesInspector >> fieldAllTempVars [

	^ (self newFieldForType: #all key: #allTempVars)
		name: self allTempVarsTranslated; emphasizeName;
		valueGetter: [:object | object tempsAndValues]; printValueAsIs;
		yourself
]

{ #category : #fields }
ContextVariablesInspector >> fieldSelf [

	^ super fieldSelf
		name: 'thisContext';
		yourself
]

{ #category : #fields }
ContextVariablesInspector >> fieldStackTop [
	
	^ (self newFieldForType: #stackTop key: #stackTop)
		name: self stackTopTranslated; emphasizeName;
		valueGetter: [:context | context top];
		valueGetterExpression: 'ThisContext top';
		yourself
]

{ #category : #'fields - streaming' }
ContextVariablesInspector >> streamBaseFieldsOn: aStream [

	self object ifNil: [^ self].
	aStream nextPut: self fieldSelf.
	self object actualStackSize > 0
		ifTrue: [aStream nextPut: self fieldStackTop].
	aStream nextPut: self fieldAllTempVars.
]

{ #category : #'fields - streaming' }
ContextVariablesInspector >> streamIndexedVariablesOn: aStream [

	self class showStackVariables ifTrue: [
		self streamStackVariablesOn: aStream].
]

{ #category : #'fields - streaming' }
ContextVariablesInspector >> streamInstanceVariablesOn: aStream [
	"Just show the (named) temporary variables to the list. Hide internals. The receiver is in the debugger's companion inspector."

	self streamTemporaryVariablesOn: aStream.
]

{ #category : #'fields - streaming' }
ContextVariablesInspector >> streamTemporaryVariablesOn: aStream [
	"Overwritten to change the visuals of temps in debuggers."
	
	| tempNames |
	tempNames := [self object tempNames] ifError: [
		^ self streamError: 'Invalid temporaries' translated on: aStream].
	
	tempNames doWithIndex: [:name :index |
		aStream nextPut: ((self newFieldForType: #tempVar key: name)
			shouldStyleName: true;
			valueGetter: [:context | context namedTempAt: index];
			valueSetter: [:context :value | context namedTempAt: index put: value];
			yourself)].
]
