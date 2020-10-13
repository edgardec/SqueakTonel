"
PluggableInputField is intended as a HINT for the builder that this widget will be used as a single line input field. Unless explicitly supported it will be automatically substituted by PluggableText.
"
Class {
	#name : #PluggableInputFieldSpec,
	#superclass : #PluggableTextSpec,
	#category : #'ToolBuilder-Kernel'
}

{ #category : #building }
PluggableInputFieldSpec >> buildWith: builder [
	^builder buildPluggableInputField: self
]

{ #category : #accessing }
PluggableInputFieldSpec >> hardLineWrap [

	^ false
]

{ #category : #accessing }
PluggableInputFieldSpec >> softLineWrap [

	^ super softLineWrap ifNil: [false]
]
