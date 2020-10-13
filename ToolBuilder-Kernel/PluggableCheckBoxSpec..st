"
PluggableCheckBox is intended as a HINT for the builder that this widget will be used as check box. Unless explicitly supported it will be automatically substituted by PluggableButton.
"
Class {
	#name : #PluggableCheckBoxSpec,
	#superclass : #PluggableButtonSpec,
	#category : #'ToolBuilder-Kernel'
}

{ #category : #building }
PluggableCheckBoxSpec >> buildWith: builder [
	^builder buildPluggableCheckBox: self
]
