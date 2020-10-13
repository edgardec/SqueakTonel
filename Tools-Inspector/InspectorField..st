"
I represent a single field of an Inspector in which I am composed.

I am basically a pair of #key and #value, but may have an extra human-readable #name to be shown in the Inspector's views. My #value can only be accessed in scope of an Inspector because I need an #object to work with.
"
Class {
	#name : #InspectorField,
	#superclass : #Object,
	#instVars : [
		'key',
		'valueGetter',
		'valueGetterExpression',
		'valueSetter',
		'valueSetterExpression',
		'name',
		'shouldStyleName',
		'shouldStyleValue',
		'shouldPrintValueAsIs',
		'type',
		'inspector'
	],
	#category : #'Tools-Inspector'
}

{ #category : #support }
InspectorField class >> generateExpressionFrom: aBlock argumentNames: argumentNames [

	| blockNode arguments variables context receiver |
	self flag: #experimental.
	blockNode := aBlock decompile veryDeepCopy. "some literals are singletons, see #becomeForward: below"
	arguments := blockNode arguments collect: #name.
	variables := Dictionary new.
	variables
		at: #true put: true;
		at: #false put: false;
		at: #nil put: nil.
	receiver := aBlock receiver.
	receiver class allInstVarNames
		withIndexDo: [:name :index |
			variables at: name put: (receiver instVarAt: index)].
	context := aBlock outerContext.
	context tempNames
		withIndexDo: [:name :index |
			variables at: name put: (context namedTempAt: index)].
	blockNode nodesDo: [:node |
		self flag: #ct. "Should we introduce #nodesCollect: instead of using dangerous #becomeForward:?"
		{
			[node isVariableNode not].
			[| argumentIndex |
			argumentIndex := arguments indexOf: node name.
			argumentIndex isZero
				ifFalse: [node name: (argumentNames at: argumentIndex)];
				not].
			[variables at: node name
				ifPresent: [:value |
					value isLiteral
						ifTrue: [node becomeForward: (LiteralNode new key: value)];
						yourself]
				ifAbsent: [^ nil]].
		} detect: #value ifNone: [^ nil]].
	^ String streamContents: [:stream |
		blockNode
			printStatementsOn: stream
			indent: 0].
]

{ #category : #'instance creation' }
InspectorField class >> type: aSymbol [

	^ self new
		type: aSymbol;
		yourself
]

{ #category : #'instance creation' }
InspectorField class >> type: aSymbol key: anObject [

	^ (self type: aSymbol)
		key: anObject
		yourself
]

{ #category : #'menu - construction' }
InspectorField >> addCustomItemsFor: anInspector to: aMenu [
	
	aMenu
		addLine;
		add: 'edit field name...' translated target: self selector: #editName;
		add: 'edit field getter...' translated target: self selector: #editGetterFor: argument: anInspector;
		add: (self valueSetter ifNil: ['add field setter...' translated] ifNotNil: ['edit field setter...' translated])
			target: self selector: #editSetterFor: argument: anInspector;
		addLine;
		add: ('remove field ''{1}'' (x)' translated format: {self name}) target: self selector: #delete.
]

{ #category : #initialization }
InspectorField >> deEmphasizeName [

	self flag: #hardcoded.
	self name: (self name asText
		addAttribute: (TextColor color: (self userInterfaceTheme get: #balloonTextColor for: #PluggableTextMorphPlus));
		yourself).
]

{ #category : #'custom - actions' }
InspectorField >> delete [
	"Request the deletion of this field in my inspector's list of (custom) fields."
	
	self changed: #deleteField with: self.
]

{ #category : #'custom - actions' }
InspectorField >> editGetterFor: aStringHolder [

	^ self editGetterFor: aStringHolder orCancel: []
]

{ #category : #'custom - actions' }
InspectorField >> editGetterFor: anInspector orCancel: aBlock [

	| code |
	code := Project uiManager
		request: 'Please enter an evaluable expression<br>to <b>get</b> this field''s value:' translated asTextFromHtml
		initialAnswer: self valueGetterExpression.
	code isEmptyOrNil ifTrue: [^ aBlock value].
	
	^ self setGetterFor: anInspector to: code ifFail: aBlock
]

{ #category : #'custom - actions' }
InspectorField >> editName [

	^ self editNameOrCancel: []
]

{ #category : #'custom - actions' }
InspectorField >> editNameOrCancel: aBlock [

	| newTitle |
	newTitle := Project uiManager
		request: 'Please enter a new name for this field:' translated withCRs
		initialAnswer: self name asString.
	newTitle isEmptyOrNil ifTrue: [^ aBlock value].
	self name: newTitle; emphasizeName.
	self changed: #field.
]

{ #category : #'custom - actions' }
InspectorField >> editSetterFor: anInspector [

	^ self editSetterFor: anInspector orCancel: []
]

{ #category : #'custom - actions' }
InspectorField >> editSetterFor: anInspector orCancel: aBlock [

	| code |
	code := Project uiManager
		request: 'Please enter an evaluable expression<br>to <b>set</b> this field''s value:' translated asTextFromHtml
		initialAnswer: (self valueSetterExpression ifNil: '[:value | self ___: value]').
	code isEmptyOrNil ifTrue: [^ aBlock value].
	^ self setSetterFor: anInspector to: code ifFail: aBlock
]

{ #category : #initialization }
InspectorField >> emphasizeName [

	| regularEmphasis customEmphasis |

	self flag: #hardcoded.
	regularEmphasis := TextEmphasis italic.
	customEmphasis := TextColor color: ((self userInterfaceTheme get: #highlightTextColor for: #SimpleHierarchicalListMorph) ifNil: [Color red]).

	self name: (self name asText
		addAttribute: (self isCustom ifTrue: [customEmphasis] ifFalse: [regularEmphasis]);
		yourself).
]

{ #category : #'accessing - code' }
InspectorField >> expressionWithReceiverName: receiverName [
	"The code string to run for getting the receiver's value. The receiver's name, which is usually #self, can be replaced to fit specific debugging scenarios such as ThisContext."

	^ valueGetterExpression ifNil: [
		self valueGetter isCompiledCode
			ifTrue: [ "precompiled user code"
				self valueGetter getSource ]
			ifFalse: [ "evaluable"
				self class
					generateExpressionFrom: self valueGetter
					argumentNames: {receiverName} ] ]
]

{ #category : #private }
InspectorField >> forgetInspector [

	inspector := nil.
]

{ #category : #evaluating }
InspectorField >> getValueFor: anInspector [

	^ self valueGetter isCompiledCode
		ifTrue: [ "precompiled user code"
			self valueGetter
				valueWithReceiver: anInspector doItReceiver
				arguments: ({anInspector doItContext} first: self valueGetter numArgs)]
		ifFalse: [ "evaluable"
			self valueGetter value: anInspector object ]
]

{ #category : #private }
InspectorField >> inspector [

	^ inspector ifNil: [self dependents
		detect: [:object | object isKindOf: Inspector]
		ifNone: [nil]]
]

{ #category : #testing }
InspectorField >> isCustom [

	^ self type = #custom
]

{ #category : #testing }
InspectorField >> isReadOnly [

	^ self valueSetter isNil
]

{ #category : #accessing }
InspectorField >> key [

	^ key
]

{ #category : #accessing }
InspectorField >> key: anObject [

	self key = anObject ifTrue: [^ self].
	key := anObject.
	self changed: #field.
]

{ #category : #accessing }
InspectorField >> name [
	"Answers most human-readable name for this field. Not that the key can be any kind of object but this message should answer something that is already printable such as String or Text. If the sender could not rely on this, quoted strings could be confused with regular strings."
	
	^ name ifNil: [valueGetterExpression ifNil: [key ifNil: [''] ifNotNil: [key asString]]]
]

{ #category : #accessing }
InspectorField >> name: aString [

	name = aString ifTrue: [^ self].
	name := aString.
	self changed: #field.
]

{ #category : #printing }
InspectorField >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPut: $<;
		print: self type;
		nextPut: $>.
	aStream
		nextPutAll: ' named ';
		print: self name asString.
]

{ #category : #initialization }
InspectorField >> printValueAsIs [

	self shouldPrintValueAsIs: true.
]

{ #category : #private }
InspectorField >> rememberInspector [

	inspector := self inspector.
]

{ #category : #custom }
InspectorField >> requestCustomFor: anInspector orCancel: aBlock [

	self setGetterFor: anInspector to: 'self yourself' ifFail: [^ self].
	self editGetterFor: anInspector orCancel: aBlock.
	self emphasizeName.
]

{ #category : #custom }
InspectorField >> setGetterFor: anInspector to: code ifFail: aBlock [

	| getter |
	getter := Compiler new
		compiledMethodFor: code
		in: anInspector doItContext
		to: anInspector doItReceiver
		notifying: nil
		ifFail: [^ aBlock value].

	self valueGetterExpression: code.	
	self valueGetter: getter.
	
	self changed: #field.
]

{ #category : #custom }
InspectorField >> setSetterFor: anInspector to: code ifFail: aBlock [

	| setter |
	setter := Compiler new
		evaluate: code
		in: anInspector doItContext
		to: anInspector doItReceiver
		environment: anInspector environment
		notifying: nil
		ifFail: [^ aBlock value]
		logged: false.
	
	self
		flag: #experimental; "ct: We might want to change this when input-request dialogs can work with source code. See also http://forum.world.st/Changeset-requestCode-cs-td5110502.html for this proposal."
		assert: [setter respondsTo: #value:]
		description: 'Setter must be evaluable like a block with one argument' translated.
	
	self valueSetterExpression: code.	
	self valueSetter: [:object :value | setter value: value].
	
	self changed: #field.
]

{ #category : #evaluating }
InspectorField >> setValueFor: anInspector to: value [

	self valueSetter isCompiledCode
		ifTrue: [ "precompiled user code"
			self valueSetter
				valueWithReceiver: anInspector doItReceiver
				arguments: ({value. anInspector doItContext} first: self valueSetter numArgs)]
		ifFalse: [ "evaluable"
			self valueSetter value: anInspector object value: value ].
	self changed: #field.
]

{ #category : #'accessing - printing' }
InspectorField >> shouldPrintValueAsIs [
	"Whether to call #asString or #printString on this field's value."

	^ shouldPrintValueAsIs ifNil: [false]
]

{ #category : #'accessing - printing' }
InspectorField >> shouldPrintValueAsIs: aBoolean [
	"Whether to call #asString or #printString on this field's value."

	shouldPrintValueAsIs := aBoolean.
]

{ #category : #'accessing - printing' }
InspectorField >> shouldStyleName [

	^ shouldStyleName ifNil: [false]
]

{ #category : #'accessing - printing' }
InspectorField >> shouldStyleName: aBoolean [

	self shouldStyleName = aBoolean ifTrue: [^ self].
	shouldStyleName := aBoolean.
	self changed: #field.
]

{ #category : #'accessing - printing' }
InspectorField >> shouldStyleValue [
	
	^ shouldStyleValue ifNil: [false]
]

{ #category : #'accessing - printing' }
InspectorField >> shouldStyleValue: aBoolean [

	self shouldStyleValue = aBoolean ifTrue: [^ self].
	shouldStyleValue := aBoolean.
	self changed: #field.
]

{ #category : #accessing }
InspectorField >> type [

	^ type
]

{ #category : #accessing }
InspectorField >> type: aSymbol [

	type := aSymbol
]

{ #category : #accessing }
InspectorField >> value [
	"For convenience only. If you have an #inspector, call #getValueFor: directly. It may be faster."

	^ self getValueFor: self inspector
]

{ #category : #accessing }
InspectorField >> value: anObject [
	"For convenience only. If you have an #inspector, call #setValueFor:to: directly. It may be faster."

	^ self setValueFor: self inspector to: anObject
]

{ #category : #'accessing - code' }
InspectorField >> valueGetter [
	"The valueGetter will be used to fetch a value for this field. See comment in #valueGetter:."

	^ valueGetter
]

{ #category : #'accessing - code' }
InspectorField >> valueGetter: evaluable [
	"The valueGetter will be used to fetch a value for this field. The corresponding inspctor will provide an object to fetch the value from.
	
	Here are some examples:
	
		[:object | object size] -- The most basic case.
		#negated --- A convenient shortcut.
		[:object | self print: object] --- A closured helper to fetch the value.
	
	It is also possible to store a compiled method as a valueGetter. Then, the corresponding inspector will provide both #doItReceiver and #doItContext to execute that method to fetch the value for this field. So, this is like storing a compiled do-it expression."

	valueGetter := evaluable.
]

{ #category : #'accessing - code' }
InspectorField >> valueGetterExpression [
	"The code string to run for getting the receiver's value."

	^ self expressionWithReceiverName: #self
]

{ #category : #'accessing - code' }
InspectorField >> valueGetterExpression: aString [

	valueGetterExpression := aString.
]

{ #category : #'accessing - code' }
InspectorField >> valueSetter [
	"The valueSetter will be used to manipulate the value for this field. See comment in #valueSetter:."

	^ valueSetter
]

{ #category : #'accessing - code' }
InspectorField >> valueSetter: oneArgEvaluable [
	"The valueSetter will be used to manipulate the value for this field. It follows the same semantics as the valueGetter, but expects one more argument, which is the new value to set. See also comment in #valueGetter:.
	
	Here are some examples:
	
		[:object :value | object someProperty: value] -- The most basic case.
		#someProperty: --- A convenient shortcut.
		[:object :value | self setProperty: value in: object] --- A closured helper to set the value."

	valueSetter := oneArgEvaluable
]

{ #category : #'accessing - code' }
InspectorField >> valueSetterExpression [

	^ valueSetterExpression
]

{ #category : #'accessing - code' }
InspectorField >> valueSetterExpression: aString [

	valueSetterExpression := aString.
]
