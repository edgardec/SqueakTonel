Class {
	#name : #ContextInspectorTest,
	#superclass : #InspectorTest,
	#classVars : [
		'InnerTestObject'
	],
	#category : #'ToolsTests-Inspector'
}

{ #category : #running }
ContextInspectorTest >> createObject [

	InnerTestObject := super createObject.
	[[:arg1 :arg2 |
		| temp1 temp2 |
		temp1 := arg1 printString size - 1.
		temp2 := arg2 - 1.
		temp1 / temp2]
	value: InnerTestObject value: 1]
		on: Error do: [:error |
			^ error signalerContext sender copy
				push: 42;
				yourself].
	self error: 'Failed to set up context to inspect'
]

{ #category : #'support - error' }
ContextInspectorTest >> makeObjectInvalid [

	InnerTestObject beInvalid.
]

{ #category : #'support - error' }
ContextInspectorTest >> selectInvalidField [

	self inspector selectFieldSuchThat: [:field |
		field type = #tempVar and: [field value == InnerTestObject]].
]

{ #category : #running }
ContextInspectorTest >> tearDown [

	InnerTestObject := nil.
	super tearDown.
]

{ #category : #tests }
ContextInspectorTest >> testCustomField [

	self
		during: [self inspector addCustomField]
		type: 'self isDead'.
	
	self assertFieldVisible: 'self isDead'.
	self assertFieldSelected: 'self isDead'.
	self assertValuePaneShows: 'false'.
]

{ #category : #tests }
ContextInspectorTest >> testDebugConstruction [

	self shouldntRaiseWhileDebugging: [
		[| foo | (foo := self) yourself] asContext]
]

{ #category : #tests }
ContextInspectorTest >> testFieldList [
	"No need to look for the fields for temporaries because those will be covered in other tests, which is more useful. Only list the mandatory fields here."

	#(self 'all inst vars' 'sender' 'pc' 'stackp' 'method' 'closureOrNil' 'receiver')
		do: [:label | self assertFieldVisible: label].
]

{ #category : #tests }
ContextInspectorTest >> testValuePaneModify [
	"Try to change the values of all arguments and temporary variables. Check if the object-under-inspection receives those changes."

	| testObjectFound |
	testObjectFound := false.
	
	self object tempNames doWithIndex: [:temp :index |
		| prior current input |
		self inspector selectFieldSuchThat: [:field | field type = #tempVar and: [field key = temp]].
		self assertFieldSelected: '*', temp, '*'. "allow bells and whistles"
		
		prior := self object namedTempAt: index.
		self assert: (prior isNumber or: [prior == InnerTestObject]).

		testObjectFound := testObjectFound or: [prior == InnerTestObject].
		current := (prior isNumber ifTrue: [prior + 1] ifFalse: [#smith]).
		input := prior isNumber ifTrue: [self inspector contents, ' +1'] ifFalse: ['#smith'].
		
		self deny: current equals: (self object namedTempAt: index).
		self inValuePaneTypeAndAccept: input.
		self assert: current equals: (self object namedTempAt: index)].
	
	self assert: testObjectFound.
]
