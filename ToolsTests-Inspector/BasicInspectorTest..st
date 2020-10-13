Class {
	#name : #BasicInspectorTest,
	#superclass : #InspectorTest,
	#category : #'ToolsTests-Inspector'
}

{ #category : #failures }
BasicInspectorTest >> expectedFieldExpressionFailures [

	^ #('self')
]

{ #category : #'support - error' }
BasicInspectorTest >> selectInvalidField [
	"Create a custom field. The existing fields will all work because the basic inspector shows only minimal information about the object."
	
	self
		during: [self inspector addCustomField]
		type: 'self printString'.
]

{ #category : #tests }
BasicInspectorTest >> testFieldList [

	#(self 'class' 'size') do: [:label |
		self assertFieldVisible: label].
]

{ #category : #tests }
BasicInspectorTest >> testFieldSelf [
	"The basic inspector sends as little messages as possible to the object-under-inspector. So, just look for the correct class name in a field's contents."

	| namePattern |
	namePattern := '*{1}*' format: { (thisContext objectClass: self object) name }.
	self assert: (self inspector fields anySatisfy: [:field | namePattern match: field value]).
]
