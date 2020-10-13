Class {
	#name : #WidgetStub,
	#superclass : #Object,
	#instVars : [
		'spec',
		'state'
	],
	#category : #'ToolBuilder-SUnit'
}

{ #category : #'instance creation' }
WidgetStub class >> fromSpec: aSpec [
	^ self new setSpec: aSpec
]

{ #category : #simulating }
WidgetStub >> model [
	^ spec model
]

{ #category : #accessing }
WidgetStub >> name [
	^ spec name ifNil: [' ']
]

{ #category : #printing }
WidgetStub >> printOn: aStream [
	aStream
		print: self class;
		nextPut: $<;
		nextPutAll: self name;
		nextPut: $>
]

{ #category : #events }
WidgetStub >> refresh [
	self stateVariables do: [:var | self refresh: var]
]

{ #category : #events }
WidgetStub >> refresh: var [
	| value |
	value := spec perform: var.
	self refresh: var with: value
]

{ #category : #events }
WidgetStub >> refresh: var with: value [
	state 
		at: var 
		put: (value isSymbol
		 		ifTrue: [spec model perform: value]
				ifFalse: [value])
]

{ #category : #'initialize-release' }
WidgetStub >> setSpec: aSpec [
	state := IdentityDictionary new.
	spec := aSpec.
	spec model addDependent: self.
	self refresh.
]

{ #category : #accessing }
WidgetStub >> spec [
	^ spec
]

{ #category : #events }
WidgetStub >> stateVariables [
	^ #()
]

{ #category : #events }
WidgetStub >> update: aSymbol [
	
	self stateVariables do:
		[:var | 
		(spec perform: var) == aSymbol ifTrue:
			[self refresh: var with: aSymbol.
			^ self]]
]

{ #category : #accessing }
WidgetStub >> widgetNamed: aString [
	^ self name = aString 
		ifTrue: [self]
		ifFalse: [nil]
]
