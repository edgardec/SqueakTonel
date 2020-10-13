"
I am an Inspector that is specialized for inspecting Contexts.
"
Class {
	#name : #ContextInspector,
	#superclass : #Inspector,
	#classVars : [
		'CachedStackTopLabel',
		'CachedTempVarsLabel'
	],
	#category : #'Tools-Inspector'
}

{ #category : #private }
ContextInspector >> allTempVarsTranslated [
	"Alas translation is slow enough that we notice the slow down in trying to step in the debugger..."
	(CurrentLocale ~= Locale current
	 or: [CachedTempVarsLabel isNil]) ifTrue:
		[CurrentLocale := Locale current.
		 CachedTempVarsLabel :=  'all temp vars' translated].
	^CachedTempVarsLabel
]

{ #category : #'user interface' }
ContextInspector >> defaultIntegerBase [
	"Answer the default base in which to print integers.
	 Defer to the class of the instance."
	
	^ (self object receiver class respondsTo: #defaultIntegerBaseInDebugger)
		ifTrue: [self object receiver class perform: #defaultIntegerBaseInDebugger]
		ifFalse: [10]
]

{ #category : #private }
ContextInspector >> stackTopTranslated [
	"Alas translation is slow enough that we notice the slow down in trying to step in the debugger..."
	(CurrentLocale ~= Locale current
	 or: [CachedTempVarsLabel isNil]) ifTrue:
		[CurrentLocale := Locale current.
		 CachedStackTopLabel :=  'stack top' translated].
	^CachedStackTopLabel
]

{ #category : #'fields - streaming' }
ContextInspector >> streamFieldsOn: aStream [

	self object ifNil: [
		^ self streamError: 'Cannot inspect a nil context' translated on: aStream].
	self object method ifNil: [
		^ self streamError: 'Cannot inspect a context with nil method' translated on: aStream].
	
	super streamFieldsOn: aStream.
]

{ #category : #'fields - streaming' }
ContextInspector >> streamIndexedVariablesOn: aStream [
	"Just show (indexed) stack variables to the list."
	
	self streamStackVariablesOn: aStream.
]

{ #category : #'fields - streaming' }
ContextInspector >> streamInstanceVariablesOn: aStream [
	"Add (named) temporary variables to the list."

	super streamInstanceVariablesOn: aStream.
	self streamTemporaryVariablesOn: aStream.
]

{ #category : #'fields - streaming' }
ContextInspector >> streamStackVariablesOn: aStream [
	"If this context's stack pointer is not valid, silently skip streaming fields for stack variables. Do not stream an error field because freshly created or terminated contexts can be like this."

	self object stackPtr ifNil: [^ self].

	self flag: #decompile. "mt: Use #to: and #do: instead of #to:do: to avoid inlining to preserve bindings in enumeration block for later decompilation. See InspectorField."
	(self object numTemps + 1 to: self object stackPtr) do: [:index |
		aStream nextPut: ((self newFieldForType: #stackItem key: index)
			name: 'stack', index; deEmphasizeName;
			valueGetter: [:object | object at: index];
			valueSetter: [:object :value | object at: index put: value];
			yourself)]
]

{ #category : #'fields - streaming' }
ContextInspector >> streamTemporaryVariablesOn: aStream [

	| tempNames |
	tempNames := [self object tempNames] ifError: [
		^ self streamError: 'Invalid temporaries' translated on: aStream].
	
	tempNames doWithIndex: [:name :index |
		aStream nextPut: ((self newFieldForType: #tempVar key: name)
			name: ('[{1}]' format: {name});
			valueGetter: [:context | context namedTempAt: index];
			valueSetter: [:context :value | context namedTempAt: index put: value];
			yourself)]
]
