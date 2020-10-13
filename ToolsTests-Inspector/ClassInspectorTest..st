Class {
	#name : #ClassInspectorTest,
	#superclass : #InspectorTest,
	#classVars : [
		'InnerTestObject'
	],
	#category : #'ToolsTests-Inspector'
}

{ #category : #running }
ClassInspectorTest >> createObject [

	InnerTestObject := super createObject.
	^ self class
]

{ #category : #'support - error' }
ClassInspectorTest >> makeObjectInvalid [

	InnerTestObject beInvalid.
]

{ #category : #'support - error' }
ClassInspectorTest >> selectInvalidField [

	self inspector selectFieldSuchThat: [:field |
		field type = #classVar and: [field value == InnerTestObject]].
]

{ #category : #running }
ClassInspectorTest >> tearDown [

	InnerTestObject := nil.
	super tearDown.
]

{ #category : #tests }
ClassInspectorTest >> testCustomField [

	self
		during: [self inspector addCustomField]
		type: 'self packageInfo'.
	
	self assertFieldVisible: 'self packageInfo'.
	self assertFieldSelected: 'self packageInfo'.
	self assertValuePaneShows: '*ToolsTests*'.
]

{ #category : #tests }
ClassInspectorTest >> testFieldList [
	
	#(self 'all inst vars' superclass InnerTestObject) do: [:label |
		self assertFieldVisible: label].
]

{ #category : #tests }
ClassInspectorTest >> testPoolDictionaries [
	"All class inspectors should list the referenced pool dictionaries. Use an existing class from the base system that is known to rely of such a pool. If we would add our own references, loading these tests could raise extra dialog prompts."

	self denyFieldVisible: 'TextConstants'.
	self inspector object: TextStyle.
	self assertFieldVisible: 'TextConstants'.
]

{ #category : #tests }
ClassInspectorTest >> testValuePaneModify [

	self inspector selectFieldNamed: 'InnerTestObject'.
	self assertFieldSelected: 'InnerTestObject'.
	
	self deny: 42 equals: InnerTestObject.
	self inValuePaneTypeAndAccept: '42'.
	self assert: 42 equals: InnerTestObject.
]
