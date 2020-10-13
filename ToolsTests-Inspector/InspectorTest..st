Class {
	#name : #InspectorTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'inspector'
	],
	#category : #'ToolsTests-Inspector'
}

{ #category : #testing }
InspectorTest class >> shouldInheritSelectors [

	^ true
]

{ #category : #'assertions - matching' }
InspectorTest >> assert: pattern matches: actual [

	self
		assert: [(actual isString or: [actual isText]) and: [pattern match: actual]]
		description: [self comparingStringBetweenMatch: pattern and: actual]
]

{ #category : #'assertions - ui' }
InspectorTest >> assertFieldSelected: fieldName [
	"Looking at the inspector's #fieldList, which contains the list of labels visible to the user, check whether that list contains fieldName, which is the label the user is looking for."

	self
		assert: (self inspector selectionIndex
			between: 1
			and: self inspector fieldList size);
		assert: fieldName 
		matches: (self inspector fieldList at: self inspector selectionIndex) asString.
]

{ #category : #'assertions - ui' }
InspectorTest >> assertFieldVisible: fieldNameOrPattern [

	self assert: (self inspector fieldList anySatisfy: [:label |
					label asString = fieldNameOrPattern
						or: [fieldNameOrPattern match: label] ]).
]

{ #category : #assertions }
InspectorTest >> assertMenuWorks [

	| aMenu |
	aMenu := self fieldListMenu.
	self
		assert: aMenu items notEmpty;
		assert: (aMenu items allSatisfy: [:item | item contents notEmpty]).
]

{ #category : #'assertions - ui' }
InspectorTest >> assertNoFieldSelected [

	self assert: self inspector selectionIndex = 0.
]

{ #category : #'assertions - ui' }
InspectorTest >> assertValuePaneShows: contents [

	self assert: contents matches: self inspector contents.
]

{ #category : #assertions }
InspectorTest >> assertValuePaneWorks [

	^ self denyValuePaneShows: '<*error*debug*>'
]

{ #category : #'assertions - matching' }
InspectorTest >> comparingStringBetweenMatch: pattern and: actual [

	^ 'Pattern {1} is not matched by actual {2}' format: (
		{pattern. actual} collect: [:arg | arg printStringLimitedTo: 10])
]

{ #category : #running }
InspectorTest >> createObject [

	^ InspectorTestObject new
		apple: #discovery;
		orange: #navel;
		yourself
]

{ #category : #running }
InspectorTest >> createObjectWithTruncation [
	"Create an object that will surely trigger truncation of inspector fields when being inspected."

	^ (InspectorTestObject new: 500)
		apple: #discovery;
		orange: #navel;
		yourself
]

{ #category : #'assertions - matching' }
InspectorTest >> deny: pattern matches: actual [

	self
		deny: [(actual isString or: [actual isText]) and: [pattern match: actual]]
		description: ['Actually matches {1}' format: {pattern}]
]

{ #category : #'assertions - ui' }
InspectorTest >> denyFieldSelected: fieldName [

	self deny: (self inspector fieldList at: self inspector selectionIndex) asString = fieldName.
]

{ #category : #'assertions - ui' }
InspectorTest >> denyFieldVisible: fieldName [

	self assert: (self inspector fieldList noneSatisfy: [:label |
					label asString = fieldName]).
]

{ #category : #'assertions - ui' }
InspectorTest >> denyNoFieldSelected [

	self assert: self inspector selectionIndex > 0.
]

{ #category : #'assertions - ui' }
InspectorTest >> denyValuePaneShows: contents [

	self deny: contents matches: self inspector contents.
]

{ #category : #assertions }
InspectorTest >> denyValuePaneWorks [

	^ self assertValuePaneShows: '*error*debug*'
]

{ #category : #'support - ui' }
InspectorTest >> during: block confirm: boolean [
	"When evaluating the block, there will be a dialog showing up that requests the user to confirm something. Simulate that interaction here."

	block valueSupplyingAnswer: {'*'. boolean}.
]

{ #category : #'support - ui' }
InspectorTest >> during: block type: expression [
	"When evaluating the block, there will be a dialog showing up that requests the user to type something. Simulate that interaction here."

	block valueSupplyingAnswer: {'*'. expression}.
]

{ #category : #failures }
InspectorTest >> expectedFieldExpressionFailures [
	"List all fields whose 'Get field expression' feature does not yet work."

	^ #()
]

{ #category : #support }
InspectorTest >> fieldListMenu [

	^ self inspector fieldListMenu: MenuMorph new
]

{ #category : #support }
InspectorTest >> fieldTypeOfIndexedVariable [

	^ #indexed
]

{ #category : #'support - ui' }
InspectorTest >> inValuePaneTypeAndAccept: aString [
	"The user types aString in the value pane and accepts those contents."

	self inspector contents: aString notifying: nil.
]

{ #category : #accessing }
InspectorTest >> inspector [

	^ inspector
]

{ #category : #'support - error' }
InspectorTest >> makeObjectInvalid [
	"Violate some contract so that the inspector cannot call #printString on some field anymore without getting an error."

	self object beInvalid.
]

{ #category : #accessing }
InspectorTest >> object [

	^ self inspector object
]

{ #category : #'support - error' }
InspectorTest >> selectInvalidField [

	self inspector selectFieldNamed: 'self'.
]

{ #category : #running }
InspectorTest >> setUp [

	super setUp.
	inspector := self targetClass on: self createObject.
]

{ #category : #assertions }
InspectorTest >> shouldntRaiseWhileDebugging: aBlock [

	aBlock newProcess runUntil: [:ctxt |
		self
			shouldnt: [inspector inspect: ctxt receiver]
			raise: Error, Warning, Halt.
		false].
]

{ #category : #'support - ui' }
InspectorTest >> simulateStepping [

	self inspector stepAt: 0 in: nil.
]

{ #category : #tests }
InspectorTest >> testCustomField [

	self
		during: [self inspector addCustomField]
		type: 'self fruits'.
	
	self assertFieldVisible: 'self fruits'.
	self assertFieldSelected: 'self fruits'.
	self assertValuePaneShows: '*discovery*navel*'.
]

{ #category : #tests }
InspectorTest >> testCustomFieldRemove [

	self assert: 0 equals: self inspector customFields size.
	self during: [self inspector addCustomField] type: 'self'.
	self assert: 1 equals: self inspector customFields size.

	self assert: self inspector selectedField type = #custom.
	self during: [self inspector removeSelection] confirm: true.
	self assert: 0 equals: self inspector customFields size.
]

{ #category : #tests }
InspectorTest >> testDebugConstruction [

	self shouldntRaiseWhileDebugging: [
		self createObject]
]

{ #category : #tests }
InspectorTest >> testExpressions [
	"All fields should provide an evaluable expression to be evaluated on the inspected objects to retrieve that field's value. Try to test that by re-setting that expression as a getter and compare the resulting values."

	self inspector fields
		reject: [:field | self expectedFieldExpressionFailures includes: field name asString]
		thenDo: [:field |
			| expression content |
			(expression := self inspector expressionForField: field) ifNil: [self fail].
			content := field getValueFor: self inspector. 		
			field setGetterFor: self inspector to: expression ifFail: [self fail].
			self assert: content equals: (field getValueFor: self inspector)].
]

{ #category : #tests }
InspectorTest >> testFieldList [
	"Check whether the most important fields are visible."
	
	#(self 'all inst vars' apple orange) do: [:label |
		self assertFieldVisible: label].
]

{ #category : #'tests - special' }
InspectorTest >> testFieldListError [
	"Choose an inspector that messes up field streaming. Check whether the field list shows still something informative."

	self class == InspectorTest ifFalse: [^ self "Pass the test automatically."].
	
	inspector := InspectorTestInspector on: Object new.
	
	self assertFieldVisible: '<error>'.
	inspector ensureSelectedField.
	self assertFieldSelected: '<error>'.
	self assertValuePaneShows: '*error*debug*'.
]

{ #category : #tests }
InspectorTest >> testFieldListMenu [
	"Select one field after another and check whether the menu can be invoked."

	self assertNoFieldSelected.
	self assertMenuWorks.

	1 to: self inspector fieldList size do: [:index |
		self inspector selectionIndex: index.
		self denyNoFieldSelected.
		self assertMenuWorks].
	
]

{ #category : #tests }
InspectorTest >> testFieldSelf [
	"There should be at least one field pointing to the inspected object itself."

	self assert: (self inspector fields anySatisfy: [:field | field value == self object]).
]

{ #category : #tests }
InspectorTest >> testInspectorClass [
	"Be sure to use the correct inspector for our object-under-inspection. If this test fails, #targetClass or #setUp might be wrong."

	| previousInspectorClass |
	previousInspectorClass := self inspector class.
	self inspector inspect: self object.
	self assert: previousInspectorClass equals: self inspector class.
]

{ #category : #'tests - special' }
InspectorTest >> testObjectChanged [
	
	self class == InspectorTest ifFalse: [^ self "Pass the test automatically."].
	
	self inspector selectFieldNamed: 'self'.
	self denyValuePaneShows: '*ontario*'.
	
	self object apple: #ontario.
	self denyValuePaneShows: '*ontario*'.
	
	self simulateStepping.
	self assertValuePaneShows: '*ontario*'.
]

{ #category : #'tests - special' }
InspectorTest >> testTruncationEllipsis [
	"Even the most generic inspector supports truncation of indexed variables."

	| ellipsis |
	(self class includesSelector: #createObjectWithTruncation)
		ifFalse: [^ self "Run this test only if explicitely refined."].
	
	self inspector object: self createObjectWithTruncation.
	self assert: self inspector class = self targetClass. "No change."
	
	self assert: self inspector fields size >= self inspector truncationLimit.
	self assertFieldVisible: '...'.

	self inspector selectFieldSuchThat: [:field | field type = #ellipsis].
	ellipsis := self inspector selectedField.

	self assert: '*...*' matches: ellipsis name.
	self assertValuePaneShows: '*not shown*'.
	
	self inspector fields do: [:field |
		"All visible elements are from that object."
		self assert: (field type = #element) ==> [self inspector object includes: field value]].
]

{ #category : #'tests - special' }
InspectorTest >> testTruncationEllipsisMenu [

	(self class includesSelector: #createObjectWithTruncation)
		ifFalse: [^ self "Run this test only if explicitely refined."].
		
	self inspector object: self createObjectWithTruncation.
	self inspector selectFieldSuchThat: [:field | field type = #ellipsis].
	self assertMenuWorks.
]

{ #category : #'tests - special' }
InspectorTest >> testTruncationTail [

	| ellipsisIndex firstElementIndex |
	(self class includesSelector: #createObjectWithTruncation)
		ifFalse: [^ self "Run this test only if explicitely refined."].
		
	self inspector object: self createObjectWithTruncation.
	
	firstElementIndex := self inspector fields
		findFirst: [:field | field type = self fieldTypeOfIndexedVariable].
	ellipsisIndex := self inspector fields
		findFirst: [:field | field type = #ellipsis].

	self
		assert: self inspector truncationLimit
		equals: ellipsisIndex - firstElementIndex + 1 + self inspector truncationTail;
		assert: self inspector truncationTail
		equals: self inspector fields size - ellipsisIndex.
]

{ #category : #tests }
InspectorTest >> testValuePane [
	"Select one field after another and check whether the value pane shows non-error contents."

	self assertNoFieldSelected.
	self assertValuePaneWorks.

	1 to: self inspector fieldList size do: [:index |
		self inspector selectionIndex: index.
		self denyNoFieldSelected.
		self assertValuePaneWorks].
]

{ #category : #tests }
InspectorTest >> testValuePaneError [

	self makeObjectInvalid.
	self assertValuePaneWorks.
	
	self selectInvalidField.
	self denyValuePaneWorks.
]

{ #category : #tests }
InspectorTest >> testValuePaneModify [

	self inspector selectFieldNamed: #apple.

	self deny: #ontario equals: self object apple.
	self assertValuePaneShows: '#discovery'.
		
	self inValuePaneTypeAndAccept: '#ontario'.

	self assert: #ontario equals: self object apple.
	self assertValuePaneShows: '#ontario'.
]
