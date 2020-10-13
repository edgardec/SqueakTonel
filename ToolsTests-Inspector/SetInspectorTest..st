Class {
	#name : #SetInspectorTest,
	#superclass : #CollectionInspectorTest,
	#category : #'ToolsTests-Inspector'
}

{ #category : #running }
SetInspectorTest >> createObject [

	^ Set new
		addAll: #(navel discovery smith boskoop);
		yourself

]

{ #category : #running }
SetInspectorTest >> createObjectWithTruncation [

	^ (1 to: 150) asSet
]

{ #category : #'support - error' }
SetInspectorTest >> makeObjectInvalid [

	self object add: InspectorTestObject newInvalid.
	self simulateStepping.
]

{ #category : #'support - error' }
SetInspectorTest >> selectInvalidField [

	self inspector selectFieldSuchThat: [:field |
		field type = #element and: [field value class == InspectorTestObject]].
]

{ #category : #tests }
SetInspectorTest >> testAddElement [
	"Like super implementation but not checking the field names since we cannot now the exact indices of a set's internal array."

	self deny: (self object includes: 42).
	
	self
		during: [self inspector addElement]
		type: '6 * 7'. "42"

	self assert: (self object includes: 42).
	self assertValuePaneShows: '42'.
]

{ #category : #tests }
SetInspectorTest >> testFieldList [

	#(self 'all inst vars') do: [:label | self assertFieldVisible: label].

	self object do: [:element | self assert: (
		self inspector fields anySatisfy: [:field |
			field type =#element and: [field value == element]] )]
]

{ #category : #tests }
SetInspectorTest >> testNil [
	"Check proper use of a set's enclosed elements."

	self deny: (self object includes: nil).
	self deny: (self inspector fields anySatisfy: [:field | field value isNil]).
	
	self object add: nil.
	self simulateStepping.
	
	self assert: (self inspector fields anySatisfy: [:field | field value isNil]).
]
