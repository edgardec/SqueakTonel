"
AssignmentNode comment: 'I represent a (var_expr) construct.'
"
Class {
	#name : #AssignmentNode,
	#superclass : #ParseNode,
	#instVars : [
		'variable',
		'value'
	],
	#category : #'Compiler-ParseNodes'
}

{ #category : #visiting }
AssignmentNode >> accept: aVisitor [
	^aVisitor visitAssignmentNode: self
]

{ #category : #'closure analysis' }
AssignmentNode >> analyseTempsWithin: scopeBlock "<BlockNode>"  rootNode: rootNode "<MethodNode>" assignmentPools: assignmentPools [ "<Dictionary>"
	"N.B.  since assigment happens _after_ the value is evaluated the value is sent the message _first_."
	value analyseTempsWithin: scopeBlock rootNode: rootNode assignmentPools: assignmentPools.
	variable beingAssignedToAnalyseTempsWithin: scopeBlock rootNode: rootNode assignmentPools: assignmentPools
]

{ #category : #'code generation' }
AssignmentNode >> emitCodeForEffect: stack encoder: encoder [

	variable emitCodeForLoad: stack forValue: false encoder: encoder.
	value emitCodeForValue: stack encoder: encoder.
	pc := encoder nextPC. "debug pc is first byte of the store, i.e. the next byte".
	variable emitCodeForStorePop: stack encoder: encoder
]

{ #category : #'code generation' }
AssignmentNode >> emitCodeForValue: stack encoder: encoder [

	variable emitCodeForLoad: stack forValue: true encoder: encoder.
	value emitCodeForValue: stack encoder: encoder.
	pc := encoder nextPC. "debug pc is first byte of the store, i.e. the next byte".
	variable emitCodeForStore: stack encoder: encoder
]

{ #category : #private }
AssignmentNode >> ifNilTemporary [
	"(temp := object) == nil ifTrue: [...] ifFalse: [...]"
	
	^ self variable
]

{ #category : #private }
AssignmentNode >> ifNilValue [
	"(temp := object) == nil ifTrue: [...] ifFalse: [...]"
	
	^ self value
]

{ #category : #testing }
AssignmentNode >> isAssignmentNode [
	^true
]

{ #category : #printing }
AssignmentNode >> printOn: aStream indent: level [ 
	variable printOn: aStream indent: level.
	aStream nextPutAll: ' := '.
	value printOn: aStream indent: level + 2
]

{ #category : #printing }
AssignmentNode >> printOn: aStream indent: level precedence: p [

	aStream nextPut: $(.
	self printOn: aStream indent: level.
	aStream nextPut: $)
]

{ #category : #printing }
AssignmentNode >> printWithClosureAnalysisOn: aStream indent: level [ 
	variable printWithClosureAnalysisOn: aStream indent: level.
	aStream nextPutAll: ' := '.
	value printWithClosureAnalysisOn: aStream indent: level + 2
]

{ #category : #printing }
AssignmentNode >> printWithClosureAnalysisOn: aStream indent: level precedence: p [

	aStream nextPut: $(.
	self printWithClosureAnalysisOn: aStream indent: level.
	aStream nextPut: $)
]

{ #category : #'code generation' }
AssignmentNode >> sizeCodeForEffect: encoder [

	^(variable sizeCodeForLoad: encoder forValue: false)
	+ (value sizeCodeForValue: encoder)
	+ (variable sizeCodeForStorePop: encoder)
]

{ #category : #'code generation' }
AssignmentNode >> sizeCodeForValue: encoder [

	^(variable sizeCodeForLoad: encoder forValue: true)
	+ (value sizeCodeForValue: encoder)
	+ (variable sizeCodeForStore: encoder)
]

{ #category : #'initialize-release' }
AssignmentNode >> toDoIncrement: var [
	^(var = variable
	   and: [value isMessageNode]) ifTrue:
		[value toDoIncrement: var]
]

{ #category : #'initialize-release' }
AssignmentNode >> value [
	^ value
]

{ #category : #'equation translation' }
AssignmentNode >> variable [
	^variable
]

{ #category : #'initialize-release' }
AssignmentNode >> variable: aVariable value: expression [

	variable := aVariable.
	value := expression
]

{ #category : #'initialize-release' }
AssignmentNode >> variable: aVariable value: expression from: encoder [

	(aVariable isMemberOf: MessageAsTempNode)
		ifTrue: ["Case of remote temp vars"
				^ aVariable store: expression from: encoder].
	variable := aVariable.
	value := expression
]

{ #category : #'initialize-release' }
AssignmentNode >> variable: aVariable value: expression from: encoder sourceRange: range [

	encoder noteSourceRange: range forNode: self.
	^self
		variable: aVariable
		value: expression
		from: encoder
]
