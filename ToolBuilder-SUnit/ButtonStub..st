Class {
	#name : #ButtonStub,
	#superclass : #WidgetStub,
	#category : #'ToolBuilder-SUnit'
}

{ #category : #simulating }
ButtonStub >> click [
	| action |
	action := spec action.
	action isSymbol
		ifTrue: [self model perform: action]
		ifFalse: [action value]
]

{ #category : #simulating }
ButtonStub >> color [
	^ state at: #color
]

{ #category : #simulating }
ButtonStub >> isEnabled [
	^ state at: #enabled
]

{ #category : #simulating }
ButtonStub >> isPressed [
	^ state at: #state
]

{ #category : #simulating }
ButtonStub >> label [
	^ state at: #label
]

{ #category : #events }
ButtonStub >> stateVariables [
	^ #(label color state enabled)
]
