Class {
	#name : #PluggableDropDownListSpec,
	#superclass : #PluggableWidgetSpec,
	#instVars : [
		'listSelector',
		'selectionSelector',
		'selectionSetter'
	],
	#category : #'ToolBuilder-Kernel'
}

{ #category : #building }
PluggableDropDownListSpec >> buildWith: builder [
	^builder buildPluggableDropDownList: self
]

{ #category : #accessing }
PluggableDropDownListSpec >> listSelector [
	"Answer the value of listSelector"

	^ listSelector
]

{ #category : #accessing }
PluggableDropDownListSpec >> listSelector: anObject [
	"Set the value of listSelector"

	listSelector := anObject
]

{ #category : #accessing }
PluggableDropDownListSpec >> selectionSelector [
	"Answer the value of selectionSelector"

	^ selectionSelector
]

{ #category : #accessing }
PluggableDropDownListSpec >> selectionSelector: anObject [
	"Set the value of selectionSelector"

	selectionSelector := anObject
]

{ #category : #accessing }
PluggableDropDownListSpec >> selectionSetter [
	"Answer the value of selectionSetter"

	^ selectionSetter
]

{ #category : #accessing }
PluggableDropDownListSpec >> selectionSetter: anObject [
	"Set the value of selectionSetter"

	selectionSetter := anObject
]
