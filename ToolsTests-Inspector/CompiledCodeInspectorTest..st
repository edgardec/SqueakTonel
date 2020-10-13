Class {
	#name : #CompiledCodeInspectorTest,
	#superclass : #InspectorTest,
	#classVars : [
		'InnerTestObject'
	],
	#category : #'ToolsTests-Inspector'
}

{ #category : #running }
CompiledCodeInspectorTest >> createObject [
	"Note that we cannot return the block directly but require the indirection of #evaluate: because the resulting block will be modified during the tests. A block directly embedded in this #createObject method, however, would be re-used across test runs."
	
	InnerTestObject := super createObject.
	^ Compiler new
		evaluate: '[String withAll: #[67 97 114 112 101] "Carpe", #Squeak, InnerTestObject printString] method'
		in: nil
		to: self "Required for access to InnerTestObject"
]

{ #category : #running }
CompiledCodeInspectorTest >> evaluateObject [

	^ (FullBlockClosure
		receiver: nil
		outerContext: nil
		method: self object
		copiedValues: nil) value
]

{ #category : #failures }
CompiledCodeInspectorTest >> expectedFieldExpressionFailures [

	^ #('source code')
]

{ #category : #'support - error' }
CompiledCodeInspectorTest >> makeObjectInvalid [

	InnerTestObject beInvalid.
]

{ #category : #'support - error' }
CompiledCodeInspectorTest >> selectInvalidField [

	self inspector selectFieldSuchThat: [:field |
		field type = #literal and: [field value "binding" value == InnerTestObject]].
]

{ #category : #running }
CompiledCodeInspectorTest >> tearDown [

	InnerTestObject := nil.
	super tearDown.
]

{ #category : #tests }
CompiledCodeInspectorTest >> testCustomField [

	self
		during: [self inspector addCustomField]
		type: 'self allLiterals'.
	
	self assertFieldVisible: 'self allLiterals'.
	self assertFieldSelected: 'self allLiterals'.
	self assertValuePaneShows: '*#[*]*Squeak*'.
]

{ #category : #tests }
CompiledCodeInspectorTest >> testFieldList [
	
	#(self '*bytecodes*' 'header' 'literal*') do: [:label |
		self assertFieldVisible: label].
]

{ #category : #tests }
CompiledCodeInspectorTest >> testValuePaneModify [
	"Overridden to specify the kind of value to modify in a compiled-code object: the bytecodes. Looking at #createObject, we try to replace the pushConstant of the byte array at 34 with the one at 35. So, the beginning of the resulting string will change from 'CarpeSqueak' to 'SqueakSqueak'."
	
	self assert: 35 equals: (self object at: 38). "pushConstant: #[ ... ]"
	self assert: 36 equals: (self object at: 39). 	"pushConstant: #Squeak"
	self assert: (self evaluateObject beginsWith: 'CarpeSqueak').
		
	self inspector selectFieldNamed: '38'. "pushConstant: #[ ... ]"
	self assertFieldSelected: '38'.
	self inValuePaneTypeAndAccept: '36'. "pushConstant: #Squeak"

	self assert: 36 equals: (self object at: 38). "pushConstant: #Squeak"
	self assert: 36 equals: (self object at: 39). "pushConstant: #Squeak"	
	self assert: (self evaluateObject beginsWith: 'SqueakSqueak').
]

{ #category : #tests }
CompiledCodeInspectorTest >> testValuePaneModifyLiteral [

	self inspector selectFieldSuchThat: [:field |
		field type = #literal and: [field value = #Squeak]].

	self assert: (self evaluateObject beginsWith: 'CarpeSqueak').
	self inValuePaneTypeAndAccept: '#Smalltalk'.	
	self assert: (self evaluateObject beginsWith: 'CarpeSmalltalk').
]
