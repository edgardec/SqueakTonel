Class {
	#name : #CompositeStub,
	#superclass : #WidgetStub,
	#category : #'ToolBuilder-SUnit'
}

{ #category : #accessing }
CompositeStub >> children [
	^ state at: #children ifAbsent: [#()]
]

{ #category : #accessing }
CompositeStub >> children: anObject [
	state at: #children put: anObject
]

{ #category : #accessing }
CompositeStub >> stateVariables [
	^ #(children)
]

{ #category : #accessing }
CompositeStub >> widgetNamed: aString [
	self name = aString
		ifTrue: [^ self]
		ifFalse: [self children do: [:ea | (ea widgetNamed: aString) ifNotNil: [:w | ^ w]]].
	^ nil
]
