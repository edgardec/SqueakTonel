Class {
	#name : #ContextVariablesInspectorTest,
	#superclass : #ContextInspectorTest,
	#category : #'ToolsTests-Debugger'
}

{ #category : #failures }
ContextVariablesInspectorTest >> expectedFieldExpressionFailures [

	^ #('stack top')
]

{ #category : #tests }
ContextVariablesInspectorTest >> testCustomField [

	self
		during: [self inspector addCustomField]
		type: 'thisContext isDead'.
	
	self assertFieldVisible: 'thisContext isDead'.
	self assertFieldSelected: 'thisContext isDead'.
	self assertValuePaneShows: 'false'.
]

{ #category : #tests }
ContextVariablesInspectorTest >> testFieldList [

	#(thisContext 'stack top' 'all temp vars' '*arg*' '*temp*')
		do: [:label | self assertFieldVisible: label].
]

{ #category : #tests }
ContextVariablesInspectorTest >> testInspectorClass [
	"This is inspector is a variation of regular context inspectors and is used in debuggers. So, after calling #inspect: the inspector class will indeed change to the regular one."
	
	| previousInspectorClass |
	self assert: self object inspectorClass ~~ self inspector class.
	previousInspectorClass := self inspector class.
	self inspector inspect: self object.
	self deny: previousInspectorClass equals: self inspector class.
	self assert: self object inspectorClass equals: self inspector class.
]
