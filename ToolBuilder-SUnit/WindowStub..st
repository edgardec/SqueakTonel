Class {
	#name : #WindowStub,
	#superclass : #CompositeStub,
	#category : #'ToolBuilder-SUnit'
}

{ #category : #simulating }
WindowStub >> close [
	spec model perform: spec closeAction
]

{ #category : #events }
WindowStub >> stateVariables [
	^ super stateVariables, #(label)
]
