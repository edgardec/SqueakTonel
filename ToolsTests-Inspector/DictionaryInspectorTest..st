Class {
	#name : #DictionaryInspectorTest,
	#superclass : #CollectionInspectorTest,
	#category : #'ToolsTests-Inspector'
}

{ #category : #running }
DictionaryInspectorTest >> createObject [

	^ Dictionary withAll: {
		1 -> #discovery.
		7 -> #navel.
		11 -> #smith }
]

{ #category : #running }
DictionaryInspectorTest >> createObjectWithTruncation [

	^ (1 to: 150)
		collect: [:number | number -> #genericApple]
		as: Dictionary
]

{ #category : #tests }
DictionaryInspectorTest >> testAddElement [
	"The user will add a new key to the dictionary, not a value behind that key. That value needs to be set separatedly."

	self deny: (self object includesKey: 9).
	
	self
		during: [self inspector addElement]
		type: '3 ** 2'. "9"
	
	self assert: (self object includesKey: 9).
	
	self assertFieldVisible: '9'.
	self assertFieldSelected: '9'.
	
	self assertValuePaneShows: 'nil'.
	self inValuePaneTypeAndAccept: '#ontario'.
	self assertValuePaneShows: '#ontario'.
	
	self assert: #ontario equals: (self object at: 9).
]

{ #category : #tests }
DictionaryInspectorTest >> testFieldList [
	"Check whether the most important fields are visible."
	
	#(self 'all inst vars' tally array) do: [:label |
		self assertFieldVisible: label].
	
	self object keysDo: [:key | self assertFieldVisible: key printString].
]

{ #category : #tests }
DictionaryInspectorTest >> testObjectChanged [

	"1) Add a new key, which adds a new field to the list of fields."
	self denyFieldVisible: '9'.
	self object at: 9 put: nil.
	self denyFieldVisible: '9'.
	self simulateStepping.
	self assertFieldVisible: '9'.

	"2) Change the value behind the key, which changes the value-pane's contents."
	self inspector selectFieldNamed: '9'.
	self assertFieldSelected: '9'.
	self assertValuePaneShows: 'nil'.
	self object at: 9 put: #ontario.
	self assertValuePaneShows: 'nil'.
	self simulateStepping.
	self assertValuePaneShows: '#ontario'.
]
