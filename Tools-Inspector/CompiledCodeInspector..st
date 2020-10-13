"
I am an inspector specialized for inspecting CompiledMethods.
"
Class {
	#name : #CompiledCodeInspector,
	#superclass : #Inspector,
	#category : #'Tools-Inspector'
}

{ #category : #fields }
CompiledCodeInspector >> fieldByteCodes [

	^ (self newFieldForType: #all key: #byteCodes)
		name: 'all bytecodes' translated; emphasizeName;
		valueGetter: [:object | object symbolic]; printValueAsIs;
		yourself
]

{ #category : #fields }
CompiledCodeInspector >> fieldDecompile [

	^ (self newFieldForType: #code key: #decompile)
		name: 'decompiled' translated; emphasizeName;
		valueGetter: [:compiledCode | compiledCode decompile decompileString]; printValueAsIs;
		yourself
]

{ #category : #fields }
CompiledCodeInspector >> fieldHeader [

	^ (self newFieldForType: #misc key: #header)
		name: 'header' translated; emphasizeName;
		valueGetter: [:object | object headerDescription]; printValueAsIs;
		yourself
]

{ #category : #fields }
CompiledCodeInspector >> fieldSource [

	^ (self newFieldForType: #code key: #source)
		name: 'source code' translated; emphasizeName;
		valueGetter: [:compiledCode | '"{1}"\{2}' withCRs format: {compiledCode methodClass. compiledCode getSource}]; printValueAsIs;
		shouldStyleValue: true;
		yourself
]

{ #category : #'fields - streaming' }
CompiledCodeInspector >> streamBaseFieldsOn: aStream [
	"Instead of 'all inst vars' show all byte codes and header summary."
	
	aStream
		nextPut: self fieldSelf;
		nextPut: self fieldSource;
		nextPut: self fieldDecompile;
		nextPut: self fieldByteCodes;
		nextPut: self fieldHeader.
]

{ #category : #'fields - streaming' }
CompiledCodeInspector >> streamByteCodesOn: aStream [

	self
		streamOn: aStream
		truncate: (self object initialPC to: self object size)
		collectFields: [:pc |
			(self newFieldForType: #bytecode key: pc)
				valueGetter: [:compiledCode | compiledCode at: pc];
				flag: #dangerous; "mt: We might want to disallow inadvertent changes here..."
				valueSetter: [:compiledCode :bytecode | compiledCode at: pc put: bytecode; voidCogVMState];
				yourself]
]

{ #category : #'fields - streaming' }
CompiledCodeInspector >> streamIndexedVariablesOn: aStream [
	"Separate all indexed variables in literals and byte codes."
	
	self
		streamLiteralsOn: aStream;
		streamByteCodesOn: aStream.
]

{ #category : #'fields - streaming' }
CompiledCodeInspector >> streamLiteralsOn: aStream [

	self flag: #decompile. "mt: Use #to: and #do: instead of #to:do: to avoid inlining to preserve bindings in enumeration block for later decompilation. See InspectorField."
	(1 to: self object numLiterals) do: [:index |
		aStream nextPut: ((self newFieldForType: #literal key: index)
			name: 'literal' , index;
			valueGetter: [:compiledCode | compiledCode literalAt: index];
			flag: #dangerous; "mt: We might want to disallow inadvertent changes here..."
			valueSetter: [:compiledCode :literal | compiledCode literalAt: index put: literal; voidCogVMState];
			yourself)].
]

{ #category : #'user interface - styling' }
CompiledCodeInspector >> updateStyler: aStyler requestor: anObject [
	"Overridden to configure the styler to parse method source code correctly."
	
	| parseAMethod classOrMetaClass |
	self selectedField
		ifNil: [super updateStyler: aStyler requestor: anObject]
		ifNotNil: [:field |
			(anObject knownName = #valuePane and: [field type = #code])
				ifTrue: [parseAMethod := true. classOrMetaClass := self object methodClass]
				ifFalse: [parseAMethod := false. classOrMetaClass := self doItReceiver class].
			
			aStyler
				environment: self environment;
				classOrMetaClass: classOrMetaClass;
				context: self doItContext;
				parseAMethod: parseAMethod].
	

]
