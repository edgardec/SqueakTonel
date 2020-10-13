Class {
	#name : #CollectionInspectorTest,
	#superclass : #InspectorTest,
	#category : #'ToolsTests-Inspector'
}

{ #category : #running }
CollectionInspectorTest >> createObject [

	^ OrderedCollection new
		addAll: #(discovery navel smith);
		yourself
]

{ #category : #running }
CollectionInspectorTest >> createObjectWithTruncation [

	^ (1 to: 500) asOrderedCollection
]

{ #category : #support }
CollectionInspectorTest >> fieldTypeOfIndexedVariable [

	^ #element
]

{ #category : #'support - error' }
CollectionInspectorTest >> makeObjectInvalid [

	self object at: 1 put: InspectorTestObject newInvalid.
	self simulateStepping.
]

{ #category : #'support - error' }
CollectionInspectorTest >> selectInvalidField [
	
	self inspector selectFieldNamed: '1'.
]

{ #category : #tests }
CollectionInspectorTest >> testAddElement [
	"Add a new element through the Smalltalk expression '6 * 7' and check whether the field representing that new element will be selected automatically."

	| objectSize |
	objectSize := self object size.
	
	self assertFieldVisible: objectSize asString.
	self deny: (self object includes: 42).
	
	self
		during: [self inspector addElement]
		type: '6 * 7'. "42"

	self assert: (self object includes: 42).
		
	self assertFieldVisible: (objectSize + 1) asString.
	self assertFieldSelected: (objectSize + 1) asString.
	self assertValuePaneShows: '42'.
]

{ #category : #'tests - special' }
CollectionInspectorTest >> testAddElementError [
	"Not all collections support addition or removal of elements."

	self class == CollectionInspectorTest ifFalse: [^ self "Pass the test automatically"].

	self inspector object: Array new.
	self
		should: [self inspector addElement: 1]
		raise: Error.
]

{ #category : #tests }
CollectionInspectorTest >> testAddElementMenu [

	| testMenuEntry |
	testMenuEntry := [self fieldListMenu items anySatisfy: [:item | '*add*element*' match: item contents ]].

	self inspector selectField: nil.
	self assert: testMenuEntry.
	self inspector ensureSelectedField.
	self assert: testMenuEntry.
]

{ #category : #'tests - special' }
CollectionInspectorTest >> testAddElementMenuHidden [

	| testMenuEntry |
	self class == CollectionInspectorTest ifFalse: [^ self "Pass the test automatically"].

	testMenuEntry := [self fieldListMenu items anySatisfy: [:item | '*add*element*' match: item contents ]].

	self inspector object: Array new.
	self deny: testMenuEntry.
]

{ #category : #tests }
CollectionInspectorTest >> testCustomField [

	self
		during: [self inspector addCustomField]
		type: 'self take: 5'.
	
	self assertFieldVisible: 'self take: 5'.
	self assertFieldSelected: 'self take: 5'.
	self assertValuePaneShows: '*navel*'.
]

{ #category : #tests }
CollectionInspectorTest >> testFieldList [

	#(self 'all inst vars') do: [:label | self assertFieldVisible: label].
	1 to: self object size do: [:index | self assertFieldVisible: index printString].
]

{ #category : #tests }
CollectionInspectorTest >> testRemoveElement [
	"Remove an element from the collection-under-inspection by selecting any element's field first and then removing that selected element."
	
	| element |
	self assert: self object size > 1.
	self inspector selectFieldSuchThat: [:field | field type = #element].

	element := self inspector selection.
	self assert: (self object includes: element).
	
	self inspector removeSelection.
	self deny: (self object includes: element).

	"The next remaining element will automatically be selected."
	self assert: #element equals: self inspector selectedField type.
	self assert: (self object includes: self inspector selection).
]

{ #category : #tests }
CollectionInspectorTest >> testUninitialized [
	"Single stepping through a debugger can observe the object state after creation but before initialization. Thus 'object size' may throw an exception for trying to do arithmetic on nil."
	
	self inspector selectFieldNamed: 'self'.
	self assertFieldSelected: 'self'.
	self assertValuePaneWorks.
	
	self inspector object: self object class basicNew.
	self assertFieldSelected: 'self'.
	self denyValuePaneWorks. "It's okay because the inspector is still working."
]

{ #category : #tests }
CollectionInspectorTest >> testValuePaneModify [

	| overwrittenElement |
	self inspector selectFieldSuchThat: [:field | field type = #element].
	overwrittenElement := self inspector selection.

	self assert: (self object includes: overwrittenElement).
	self deny: (self object includes: #ontario).
		
	self inValuePaneTypeAndAccept: '#ontario'.
	self assertValuePaneShows: '#ontario'.
	
	self deny: (self object includes: overwrittenElement).
	self assert: (self object includes: #ontario).
]
