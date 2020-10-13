Class {
	#name : #TextStub,
	#superclass : #WidgetStub,
	#category : #'ToolBuilder-SUnit'
}

{ #category : #simulating }
TextStub >> accept: aString [
	state at: #getText put: aString.
	^ self model perform: spec setText with: aString asText
]

{ #category : #simulating }
TextStub >> color [
	^ state at: #color
]

{ #category : #events }
TextStub >> stateVariables [
	^ #(color selection getText)
]

{ #category : #simulating }
TextStub >> text [
	^ state at: #getText
]
